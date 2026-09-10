/// Public API of the `core` package.
///
/// This is the ONLY import surface allowed for the `app` and `web` clients
/// (Constitution II, FR-003). Internal modules must never be imported
/// directly; violations fail the quality gate.
library;

// Application primitives.
export 'application/async_state.dart';
export 'application/env_config.dart';
export 'application/injection.dart';
export 'application/providers/auth_provider.dart';

// Constants.
export 'constants/strings.dart';

// Data ports.
export 'data/cache/read_cache.dart';
export 'data/cache/session_cache.dart';
export 'data/datasources/auth_remote_datasource.dart';
export 'data/network/api_http_client.dart';
export 'data/network/auth_interceptor.dart';
export 'data/network/failure_mapper.dart';
export 'data/realtime/hint.dart';
export 'data/realtime/realtime_channel.dart';

// Design tokens.
export 'design/tokens.dart';

// Domain.
export 'domain/entities/account.dart';
export 'domain/entities/profile.dart';
export 'domain/entities/session.dart';
export 'domain/failures.dart';
export 'domain/value_objects/email.dart';
export 'domain/value_objects/password.dart';
export 'domain/value_objects/username.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/repositories/order_repository.dart';
export 'domain/resource_key.dart';

// Infrastructure facades.
export 'infrastructure/observability/reporter.dart';
export 'infrastructure/observability/auth_logging.dart';
export 'infrastructure/security/credential_storage.dart';
export 'infrastructure/security/secure_storage_mobile.dart';
export 'infrastructure/security/secure_storage_web.dart';
