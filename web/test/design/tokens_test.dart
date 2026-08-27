import 'package:core/core.dart';
import 'package:jaspr_test/jaspr_test.dart';

import 'package:inventory_web/pages/home_page.dart';

/// SC-003 / FR-004 (web side): the page renders through token-backed
/// classes; dark-mode and breakpoint behavior live in tokens.css/styles.css.
void main() {
  group('HomePage', () {
    testComponents('renders all placeholder strings', (tester) async {
      tester.pumpComponent(const HomePage());

      expect(find.text(AppStrings.home.title), findsOneComponent);
      expect(find.text(AppStrings.common.appName), findsOneComponent);
      expect(find.text(AppStrings.home.placeholderBody), findsOneComponent);
    });

    testComponents('renders token-backed shell structure', (tester) async {
      tester.pumpComponent(const HomePage());

      // The shell <div class="home"> is styled exclusively by styles.css,
      // whose values come from tokens.css (mirrored core design tokens).
      expect(
        find.descendant(
          of: find.tag('div'),
          matching: find.text(AppStrings.home.placeholderBody),
        ),
        findsOneComponent,
      );
    });
  });
}
