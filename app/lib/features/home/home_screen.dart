import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inventory_app/config/theme.dart' show AppSpacingExtension;

/// Foundation demonstration screen: proves the data plumbing end to end —
/// orders render from the repository (cache-aware), real-time pushes act as
/// hints that invalidate the cache and trigger a REST re-fetch (FR-007,
/// FR-011), and failures surface as friendly messages with retry.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late AsyncState<List<OrderSummary>> _orders;
  StreamSubscription<RealtimeHint>? _hintSub;
  RealtimeHint? _lastHint;

  @override
  void initState() {
    super.initState();
    _orders = const AsyncState<List<OrderSummary>>.loading();
    _load();
    _hintSub = getIt<RealtimeChannel>().hints.listen(_onHint);
  }

  @override
  void dispose() {
    unawaited(_hintSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _orders = const AsyncState<List<OrderSummary>>.loading());
    final Either<Failure, List<OrderSummary>> result =
        await getIt<OrderRepository>().listOrders();
    if (!mounted) return;
    setState(() {
      _orders = result.fold(
        AsyncState<List<OrderSummary>>.error,
        AsyncState<List<OrderSummary>>.data,
      );
    });
  }

  /// Pushes are hints only: invalidate cache, then re-fetch over REST.
  void _onHint(RealtimeHint hint) {
    getIt<ReadCache>().invalidate(OrderRepository.listKey);
    if (!mounted) return;
    setState(() => _lastHint = hint);
    _load();
  }

  Future<void> _signOut() async {
    await getIt<AuthRepository>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSpacingExtension spacing = theme.extension<AppSpacingExtension>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(AppStrings.home.title, style: theme.textTheme.headlineSmall),
          SizedBox(height: spacing.md),
          _orders.when(
            loading: () => const CircularProgressIndicator(),
            error: (Failure failure) => Column(
              children: <Widget>[
                Text(failure.userMessage, style: theme.textTheme.bodyMedium),
                SizedBox(height: spacing.sm),
                TextButton(
                  onPressed: _load,
                  child: Text(AppStrings.common.retry),
                ),
              ],
            ),
            data: (List<OrderSummary> orders) => Text(
              '${orders.length} order(s)',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (_lastHint != null) ...<Widget>[
            SizedBox(height: spacing.sm),
            Text(
              'Last push: ${_lastHint!.orderId.substring(0, 8)}… '
              '(${(_lastHint! as OrderStatusHint).status.name})',
              style: theme.textTheme.bodySmall,
            ),
          ],
          SizedBox(height: spacing.lg),
          TextButton(
            onPressed: _signOut,
            child: Text(AppStrings.common.signOut),
          ),
        ],
      ),
    );
  }
}
