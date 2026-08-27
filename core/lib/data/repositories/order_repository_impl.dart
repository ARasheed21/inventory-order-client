import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/failures.dart';
import '../../domain/repositories/order_repository.dart';
import '../cache/read_cache.dart';
import '../network/generated/src/api/orders_api.dart';
import '../network/generated/src/model/order_response.dart';
import '../network/generated/src/serializers.dart';
import '../network/failure_mapper.dart';

/// Data-layer implementation backed by the generated contract client and
/// the in-memory cache (FR-011): reads serve cached data on failure, marked
/// stale; pushes invalidate + refresh (FR-007).
final class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required Dio dio, required ReadCache cache})
    : _api = OrdersApi(dio, standardSerializers),
      _cache = cache;

  final OrdersApi _api;
  final ReadCache _cache;

  @override
  Future<Either<Failure, List<OrderSummary>>> listOrders() async {
    try {
      final Response<BuiltList<OrderResponse>> response = await _api
          .listOrders();
      final List<OrderSummary> orders =
          response.data
              ?.map(
                (OrderResponse o) => OrderSummary(
                  id: o.id ?? '',
                  status: o.status ?? '',
                  total: (o.totalAmount ?? 0).toDouble(),
                ),
              )
              .toList() ??
          <OrderSummary>[];
      _cache.put<List<OrderSummary>>(OrderRepository.listKey, orders);
      return Right(orders);
    } on DioException catch (e, s) {
      final Failure failure = mapDioError(e, stackTrace: s);
      // Offline fallback: stale cached content with a friendly failure.
      final List<OrderSummary>? cached = _cache.get<List<OrderSummary>>(
        OrderRepository.listKey,
      );
      if (cached != null) {
        _cache.markStale(OrderRepository.listKey);
        return Right(cached);
      }
      return Left(failure);
    }
  }
}
