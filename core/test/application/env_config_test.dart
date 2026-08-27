import 'package:test/test.dart';

import 'package:core/application/env_config.dart';

Map<String, String> baseEnv() => <String, String>{
  'API_BASE_URL': 'http://localhost:8080',
  'WS_URL': 'ws://localhost:8080/api/ws/websocket',
  'APP_ENV': 'dev',
};

void main() {
  group('EnvironmentConfig', () {
    test('parses a valid dev configuration', () {
      final EnvironmentConfig c = EnvironmentConfig.fromEnvironment(
        lookup: baseEnv(),
      );
      expect(c.apiBaseUrl.host, 'localhost');
      expect(c.apiBaseUrl.port, 8080);
      expect(c.wsUrl.scheme, 'ws');
      expect(c.environment, AppEnvironment.dev);
      expect(c.isReleaseLike, isFalse);
    });

    test('aborts when a required variable is missing', () {
      final Map<String, String> env = baseEnv()..remove('WS_URL');
      expect(
        () => EnvironmentConfig.fromEnvironment(lookup: env),
        throwsA(
          isA<MissingEnvironmentException>().having(
            (MissingEnvironmentException e) => e.variableName,
            'name',
            'WS_URL',
          ),
        ),
      );
    });

    test('rejects unknown APP_ENV values', () {
      final Map<String, String> env = baseEnv()..['APP_ENV'] = 'production';
      expect(
        () => EnvironmentConfig.fromEnvironment(lookup: env),
        throwsFormatException,
      );
    });

    test('release-like environments require DSN and pins', () {
      final Map<String, String> env = baseEnv()
        ..['APP_ENV'] = 'staging'
        ..['SENTRY_DSN'] = 'https://k@sentry.io/1';
      // Missing CERT_PINS -> abort.
      expect(
        () => EnvironmentConfig.fromEnvironment(lookup: env),
        throwsA(isA<MissingEnvironmentException>()),
      );
      env['CERT_PINS'] = ' pin1 , pin2 ';
      final EnvironmentConfig c = EnvironmentConfig.fromEnvironment(
        lookup: env,
      );
      expect(c.certPins, <String>['pin1', 'pin2']);
      expect(c.isReleaseLike, isTrue);
    });
  });
}
