import json
import secrets
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import yaml


PORT = 8080
TOKEN_LIFETIME_SECONDS = 900
USERS = {}
TOKENS = {}


def load_contract() -> None:
    contract_path = Path('/app/contracts/api/openapi.yaml')
    contract = yaml.safe_load(contract_path.read_text(encoding='utf-8'))
    required_paths = {'/auth/register', '/auth/login', '/auth/refresh'}
    missing = required_paths.difference(contract.get('paths', {}))
    if missing:
        raise RuntimeError(f'OpenAPI contract is missing paths: {sorted(missing)}')


def token_pair(username: str) -> dict[str, object]:
    access_token = secrets.token_urlsafe(24)
    refresh_token = secrets.token_urlsafe(24)
    TOKENS[refresh_token] = username
    return {
        'username': username,
        'accessToken': access_token,
        'refreshToken': refresh_token,
        'expiresIn': TOKEN_LIFETIME_SECONDS,
    }


def error_payload(status: int, message: str, path: str) -> dict[str, object]:
    return {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'status': status,
        'error': 'Bad request' if status == 400 else 'Unauthorized',
        'message': message,
        'path': path,
    }


class Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        if self.path == '/actuator/health':
            self.send_json(200, {'status': 'UP'})
            return
        self.send_json(404, error_payload(404, 'Not found', self.path))

    def do_POST(self) -> None:
        payload = self.read_payload()
        if payload is None:
            self.send_json(400, error_payload(400, 'Invalid JSON body', self.path))
            return

        if self.path == '/auth/register':
            self.register(payload)
        elif self.path == '/auth/login':
            self.login(payload)
        elif self.path == '/auth/refresh':
            self.refresh(payload)
        else:
            self.send_json(404, error_payload(404, 'Not found', self.path))

    def register(self, payload: dict[str, object]) -> None:
        username = str(payload.get('username', ''))
        email = str(payload.get('email', ''))
        password = str(payload.get('password', ''))
        if not username or not email or len(password) < 8:
            self.send_json(400, error_payload(400, 'Invalid registration data', self.path))
            return
        if username in USERS:
            self.send_json(409, error_payload(409, 'Username already registered', self.path))
            return
        USERS[username] = {'email': email, 'password': password}
        self.send_json(201, token_pair(username))

    def login(self, payload: dict[str, object]) -> None:
        username = str(payload.get('username', ''))
        password = str(payload.get('password', ''))
        user = USERS.get(username)
        if user is None or user['password'] != password:
            self.send_json(401, error_payload(401, 'Invalid username or password', self.path))
            return
        self.send_json(200, token_pair(username))

    def refresh(self, payload: dict[str, object]) -> None:
        refresh_token = str(payload.get('refreshToken', ''))
        username = TOKENS.get(refresh_token)
        if username is None:
            self.send_json(401, error_payload(401, 'Invalid refresh token', self.path))
            return
        self.send_json(200, token_pair(username))

    def read_payload(self) -> dict[str, object] | None:
        try:
            length = int(self.headers.get('Content-Length', '0'))
            return json.loads(self.rfile.read(length))
        except (ValueError, json.JSONDecodeError):
            return None

    def send_json(self, status: int, payload: dict[str, object]) -> None:
        body = json.dumps(payload).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format: str, *args: object) -> None:
        return


if __name__ == '__main__':
    load_contract()
    server = ThreadingHTTPServer(('0.0.0.0', PORT), Handler)
    server.serve_forever()