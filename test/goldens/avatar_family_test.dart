import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

const _colors = CatchAvatarColors(
  accent: Color(0xffba4630),
  deep: Color(0xff692344),
  soft: Color(0xffddbbbb),
);

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('avatar family at text scale $scale', (tester) async {
      await matchCatchGolden(
        tester,
        'avatar_family${scale == 1 ? '' : '@2.0'}',
        textScale: scale,
        size: const Size(440, 520),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24),
          child: DefaultTextStyle(
            style: CatchTextStyles.bodyL(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Initials, activity, counts and veils'),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    for (final avatar in _avatars())
                      SizedBox(
                        width: 96,
                        height: 88,
                        child: Center(child: avatar),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }, tags: const ['golden']);
  }
}

List<Widget> _avatars() => [
  const CatchPersonAvatar(size: 56, name: 'Dev Malhotra'),
  const CatchPersonAvatar(size: 56, name: 'Aanya Rao'),
  const CatchPersonAvatar(
    size: 56,
    name: 'Mira Shah',
    borderWidth: 2,
    borderColor: Colors.black,
  ),
  const CatchPersonAvatar(size: 56, name: 'Social run', colors: _colors),
  const CatchPersonAvatar(size: 56, name: 'Dinner', colors: _colors, dim: true),
  const CatchPersonAvatar(
    size: 56,
    name: 'Host team',
    shape: CatchPersonAvatarShape.square,
  ),
  CatchPersonAvatar.count(
    size: 56,
    count: 199,
    countLabelBuilder: (count) => '+$count',
  ),
  CatchPersonAvatar.count(
    size: 56,
    count: 3,
    countLabelBuilder: (count) => '$count invités',
  ),
  const CatchVeiledPersonAvatar(
    size: 56,
    colors: _colors,
    borderWidth: 2,
    borderColor: Colors.white,
  ),
];
