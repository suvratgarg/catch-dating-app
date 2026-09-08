import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('compact action recipes at scale $scale', (tester) async {
      await matchCatchGolden(
        tester,
        'compact_action_family@$scale',
        size: const Size(440, 1400),
        textScale: scale,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              for (final tone in CatchTextButtonTone.values)
                Row(
                  children: [
                    Expanded(
                      child: CatchTextButton(
                        label: 'Try again',
                        tone: tone,
                        onPressed: _noop,
                      ),
                    ),
                    Expanded(
                      child: CatchTextButton(
                        label: 'Try again',
                        tone: tone,
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
              const CatchTextButton(
                label: 'Open a longer action',
                leading: Icon(Icons.open_in_new),
                onPressed: _noop,
              ),
              CatchTextButton(
                label: 'Custom color',
                onPressed: _noop,
                foregroundColor: CatchTokens.of(context).danger,
                backgroundColor: CatchTokens.of(context).surface,
                side: BorderSide(color: CatchTokens.of(context).line2),
                padding: const EdgeInsets.all(12),
              ),
              for (final variant in CatchIconButtonVariant.values)
                Wrap(
                  spacing: 24,
                  children: [
                    CatchIconButton.icon(
                      icon: Icons.favorite,
                      tooltip: 'Save',
                      variant: variant,
                      onTap: _noop,
                    ),
                    CatchIconButton.icon(
                      icon: Icons.favorite,
                      tooltip: 'Saved',
                      variant: variant,
                      active: true,
                      onTap: _noop,
                    ),
                    CatchIconButton.icon(
                      icon: Icons.favorite,
                      tooltip: 'Save unavailable',
                      variant: variant,
                      disabled: true,
                      onTap: _noop,
                    ),
                    CatchIconButton.counted(
                      icon: Icons.notifications,
                      tooltip: 'Notifications',
                      variant: variant,
                      count: 123,
                      onTap: _noop,
                    ),
                  ],
                ),
              const Wrap(
                spacing: 24,
                children: [
                  CatchIconAction(
                    icon: Icons.close,
                    tooltip: 'Close',
                    onPressed: _noop,
                  ),
                  CatchIconAction(
                    icon: Icons.close,
                    tooltip: 'Close unavailable',
                  ),
                  CatchIconAction(
                    icon: Icons.close,
                    tooltip: 'Close overlay',
                    variant: CatchIconButtonVariant.float,
                    onPressed: _noop,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }, tags: const ['golden']);
  }
}

void _noop() {}
