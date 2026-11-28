import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/price_labels.dart';

import '../../helpers/helpers.dart';

void main() {
  testWidgets('writes whole US dollars without cents', (tester) async {
    late BuildContext context;
    await tester.pumpApp(
      Builder(
        builder: (built) {
          context = built;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(context.usdLabel(6), r'$6');
    expect(context.usdLabel(120), r'$120');
    expect(context.usdLabel(1200), r'$1,200');
  });
}
