import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:core/core.dart';

import 'package:inventory_app/config/theme.dart';

/// SC-003: sample screens must consume design tokens — no raw style
/// literals outside `core/lib/design/`.
void main() {
  testWidgets('placeholder screen renders from theme, not literals', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const _TokenProbe()),
      ),
    );

    expect(find.text(AppStrings.home.title), findsOneWidget);

    // The spacing extension carries token values into the widget tree.
    final BuildContext context = tester.element(find.byType(_TokenProbe));
    final AppSpacingExtension spacing = Theme.of(
      context,
    ).extension<AppSpacingExtension>()!;
    expect(spacing.md, AppSpacing.md);
    expect(spacing.sm, AppSpacing.sm);
  });
}

class _TokenProbe extends StatelessWidget {
  const _TokenProbe();

  @override
  Widget build(BuildContext context) {
    final AppSpacingExtension ext = Theme.of(
      context,
    ).extension<AppSpacingExtension>()!;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(ext.md),
        child: Column(
          children: <Widget>[
            Text(AppStrings.home.title),
            SizedBox(height: ext.sm),
          ],
        ),
      ),
    );
  }
}
