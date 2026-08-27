import 'dart:async';

import 'package:fpdart/fpdart.dart' as fp;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'package:core/core.dart';

/// Foundation demonstration page: proves the data plumbing end to end —
/// real-time pushes act as hints that trigger REST re-fetches (FR-007).
class HomePage extends StatefulComponent {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: unused_field – retained to prevent GC of the live subscription.
  StreamSubscription<RealtimeHint>? _hintSub;
  String? _lastHint;
  int _refetches = 0;

  @override
  void initState() {
    super.initState();
    _hintSub = getIt<RealtimeChannel>().hints.listen(_onHint);
  }

  void _onHint(RealtimeHint hint) {
    // Push = hint: invalidate cache entry, then re-fetch over REST.
    getIt<ReadCache>().invalidate(OrderRepository.listKey);
    unawaited(
      getIt<OrderRepository>().listOrders().then(
        (fp.Either<Failure, List<OrderSummary>> _) =>
            setState(() => _refetches++),
      ),
    );
    final OrderStatusHint statusHint = hint as OrderStatusHint;
    setState(
      () => _lastHint = '${statusHint.orderId}: ${statusHint.status.name}',
    );
  }

  Future<void> _signOut() async {
    await getIt<AuthRepository>().logout();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'home', [
      h1([.text(AppStrings.home.title)]),
      p(classes: 'app-name', [.text(AppStrings.common.appName)]),
      div(classes: 'body', [
        p([.text(AppStrings.home.placeholderBody)]),
        if (_lastHint != null)
          p(classes: 'muted', [.text('Last push: $_lastHint')]),
        if (_refetches > 0)
          p(classes: 'muted', [.text('Re-fetches triggered: $_refetches')]),
        button(onClick: () => _signOut(), [.text(AppStrings.common.signOut)]),
      ]),
    ]);
  }
}

