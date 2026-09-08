FROM python:3.12-slim

WORKDIR /app

COPY docker/mock-backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY docker/mock-backend/server.py ./server.py
COPY contracts/api/openapi.yaml ./contracts/api/openapi.yaml

EXPOSE 8080

CMD ["python", "server.py"]