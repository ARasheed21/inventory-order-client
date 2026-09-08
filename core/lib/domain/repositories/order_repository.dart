import 'package:fpdart/fpdart.dart';

import '../failures.dart';
import '../resource_key.dart';

/// Lightweight order read model summary used by the foundation's
/// hint→refetch demonstration screen.
final class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.status,
    required this.total,
  });

  final String id;
  final String status;
  final double total;
}

/// Domain contract for reading the authenticated customer's orders.
abstract interface class OrderRepository {
  /// Cache key under which the latest order list is stored.
  static final ResourceKey listKey = ResourceKey('orders', 'list');

  Future<Either<Failure, List<OrderSummary>>> listOrders();
}
