import 'package:meta/meta.dart';

import '../domain/failures.dart';

/// Standardized asynchronous presentation state (Constitution III).
///
/// Every screen state holder uses this union — ad-hoc `isLoading` booleans
/// are forbidden.
@immutable
sealed class AsyncState<T> {
  const AsyncState();

  const factory AsyncState.loading() = AsyncLoading<T>;

  const factory AsyncState.data(T value) = AsyncData<T>;

  const factory AsyncState.error(Failure failure) = AsyncError<T>;

  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Failure failure) error,
  }) {
    final AsyncState<T> self = this;
    if (self is AsyncData<T>) return data(self.value);
    if (self is AsyncError<T>) return error(self.failure);
    return loading();
  }

  T? get dataOrNull {
    final AsyncState<T> self = this;
    return self is AsyncData<T> ? self.value : null;
  }

  bool get isLoading => this is AsyncLoading<T>;
}

final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();

  @override
  String toString() => 'AsyncState.loading<$T>()';
}

final class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.value);

  final T value;

  @override
  String toString() => 'AsyncState.data<$T>($value)';

  @override
  bool operator ==(Object other) =>
      other is AsyncData<T> && other.value == value;

  @override
  int get hashCode => Object.hash(AsyncData, value);
}

final class AsyncError<T> extends AsyncState<T> {
  const AsyncError(this.failure);

  final Failure failure;

  @override
  String toString() => 'AsyncState.error<$T>($failure)';

  @override
  bool operator ==(Object other) =>
      other is AsyncError<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(AsyncError, failure);
}
