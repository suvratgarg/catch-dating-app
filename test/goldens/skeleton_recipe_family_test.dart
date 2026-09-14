import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  testWidgets('loading row recipes preserve their original geometry', (
    tester,
  ) async {
    await matchCatchGolden(
      tester,
      'skeleton_row_recipes',
      size: const Size(800, 660),
      builder: (_) => const Padding(
        padding: EdgeInsets.all(20),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            SizedBox(
              width: 370,
              child: CatchSkeleton.rows(
                count: 2,
                titleWidth: CatchLayout.skeletonTextSectionWideWidth,
              ),
            ),
            SizedBox(width: 370, child: CatchSkeleton.mediaRows(count: 2)),
            SizedBox(width: 370, child: CatchSkeleton.iconRows(count: 2)),
            SizedBox(
              width: 370,
              child: CatchSkeleton.mediaRows(count: 2, divided: true),
            ),
          ],
        ),
      ),
    );
  }, tags: const ['golden']);
}
