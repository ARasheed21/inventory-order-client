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

// Constants.
export 'constants/strings.dart';

// Data ports.
export 'data/cache/read_cache.dart';
export 'data/network/api_http_client.dart';
export 'data/realtime/hint.dart';
export 'data/realtime/realtime_channel.dart';

// Design tokens.
export 'design/tokens.dart';

// Domain.
export 'domain/entities/session.dart';
export 'domain/failures.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/repositories/order_repository.dart';
export 'domain/resource_key.dart';

// Infrastructure observability facade.
export 'infrastructure/observability/reporter.dart';
