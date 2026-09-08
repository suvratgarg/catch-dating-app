import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  testWidgets('toggle inputs preserve both geometry recipes', (tester) async {
    await matchCatchGolden(
      tester,
      'toggle_input_family',
      size: const Size(440, 220),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                CatchToggle(value: false, onChanged: (_) {}),
                CatchToggle(value: true, onChanged: (_) {}),
                const CatchToggle(value: false, onChanged: null),
                const CatchToggle(value: true, onChanged: null),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CatchFieldToggle(value: false, onChanged: (_) {}),
                CatchFieldToggle(value: true, onChanged: (_) {}),
                const CatchFieldToggle(value: false, onChanged: null),
                const CatchFieldToggle(value: true, onChanged: null),
              ],
            ),
          ],
        ),
      ),
    );
  }, tags: const ['golden']);
}
