import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchStatusBarTone { light, dark }

/// Handoff `StatusBar`: phone-frame iOS status row with mono time and system
/// glyphs.
class CatchStatusBar extends StatelessWidget {
  const CatchStatusBar({
    super.key,
    this.tone = CatchStatusBarTone.light,
    this.surface = false,
    this.time = '9:41',
  });

  final CatchStatusBarTone tone;
  final bool surface;
  final String time;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final foreground = tone == CatchStatusBarTone.dark
        ? CatchTokens.editorialDark.ink
        : t.ink;

    return ColoredBox(
      color: surface ? t.surface : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchLayout.statusBarHorizontalPadding,
          CatchLayout.statusBarTopPadding,
          CatchLayout.statusBarHorizontalPadding,
          CatchLayout.statusBarBottomPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: CatchTextStyles.statusBarTime(context, color: foreground),
            ),
            IconTheme(
              data: IconThemeData(
                color: foreground,
                size: CatchLayout.statusBarIconSize,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CatchIcons.statusCellSignal),
                  const SizedBox(width: CatchLayout.statusBarIconGap),
                  Icon(CatchIcons.statusWifi),
                  const SizedBox(width: CatchLayout.statusBarIconGap),
                  Icon(CatchIcons.statusBattery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
