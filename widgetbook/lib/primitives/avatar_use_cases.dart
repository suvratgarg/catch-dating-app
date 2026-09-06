import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Caller colors and count copy',
  type: CatchAvatarColors,
  path: '[Core primitives]/People',
)
Widget avatarCallerColors(BuildContext context) {
  final t = CatchTokens.of(context);
  final colors = CatchAvatarColors(
    accent: t.success,
    deep: Color.lerp(t.success, CatchTokens.editorialBlack, 0.6)!,
    soft: Color.lerp(t.success, CatchTokens.editorialWhite, 0.85)!,
  );
  return WidgetbookCatalogFrame(
    title: 'Caller-owned avatar colors and copy',
    catalogId: 'catch.person_avatar.colors',
    children: [
      Wrap(
        spacing: CatchSpacing.s4,
        runSpacing: CatchSpacing.s3,
        children: [
          CatchPersonAvatar(size: 64, name: 'Asha Shah', colors: colors),
          CatchPersonAvatar(
            size: 64,
            name: 'Asha Shah',
            colors: colors,
            dim: true,
          ),
          CatchPersonAvatarStack(
            items: const [CatchPersonAvatarItem(name: 'Asha Shah')],
            totalCount: 8,
            limit: 3,
            size: 48,
            veiledCount: 2,
            veiledColors: colors,
            countLabelBuilder: (count) => '+$count',
          ),
        ],
      ),
    ],
  );
}
