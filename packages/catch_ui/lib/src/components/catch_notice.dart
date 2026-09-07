import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

import '../foundations/catch_icons.dart';
import '../foundations/catch_text_styles.dart';
import '../primitives/catch_surface.dart';
import 'catch_button.dart';
import 'catch_notice_data.dart';
import 'catch_notice_tone.dart';
import 'catch_person_avatar.dart';

class CatchNotice extends StatelessWidget {
  const CatchNotice({
    super.key,
    required this.notice,
    required this.dismissLabel,
    this.onDismiss,
  });

  final CatchNoticeData notice;

  /// Caller-resolved accessibility copy for the optional dismiss control.
  final String dismissLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = _NoticePalette.from(
      CatchTokens.of(context),
      notice.tone,
      accentColor: notice.accentColor,
    );
    final person = notice.person;
    final actionLabel = notice.actionLabel;
    final onAction = notice.onAction;

    return Semantics(
      container: true,
      liveRegion: true,
      onDismiss: notice.onOpen != null ? onDismiss : null,
      label: [
        notice.title,
        if (notice.message != null) notice.message!,
      ].join('. '),
      child: CatchSurface(
        onTap: notice.onOpen == null
            ? null
            : () {
                onDismiss?.call();
                notice.onOpen!();
              },
        elevation: CatchSurfaceElevation.overlay,
        borderColor: palette.border,
        backgroundColor: palette.background,
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s3,
        ),
        child: Row(
          children: [
            if (person != null)
              CatchPersonAvatar(
                size: CatchLayout.noticeIconExtent,
                name: person.name,
                imageUrl: person.imageUrl,
                initials: person.initials,
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.iconBackground,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                ),
                child: SizedBox.square(
                  dimension: CatchLayout.noticeIconExtent,
                  child: Icon(
                    notice.icon,
                    color: palette.icon,
                    size: CatchIcon.control,
                  ),
                ),
              ),
            const SizedBox(width: CatchSpacing.s3),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelL(
                      context,
                      color: palette.foreground,
                    ),
                  ),
                  if (notice.message != null) ...[
                    const SizedBox(height: CatchLayout.noticeTitleMessageGap),
                    Text(
                      notice.message!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(
                        context,
                        color: palette.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: CatchSpacing.s2),
              CatchButton(
                label: actionLabel,
                onPressed: onAction,
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
              ),
            ],
            if (onDismiss != null && notice.onOpen == null) ...[
              const SizedBox(width: CatchSpacing.s1),
              IconButton(
                tooltip: dismissLabel,
                onPressed: onDismiss,
                icon: Icon(
                  CatchIcons.closeRounded,
                  color: palette.secondary,
                  size: CatchIcon.md,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoticePalette {
  const _NoticePalette({
    required this.background,
    required this.foreground,
    required this.secondary,
    required this.icon,
    required this.iconBackground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color secondary;
  final Color icon;
  final Color iconBackground;
  final Color border;

  factory _NoticePalette.from(
    CatchTokens t,
    CatchNoticeTone tone, {
    Color? accentColor,
  }) {
    final toneColor =
        accentColor ??
        switch (tone) {
          CatchNoticeTone.status => t.accent,
          CatchNoticeTone.success => t.success,
          CatchNoticeTone.warning => t.warning,
          CatchNoticeTone.danger => t.danger,
          CatchNoticeTone.event => t.primary,
        };

    return _NoticePalette(
      background: Color.lerp(t.surface, toneColor, 0.08)!,
      foreground: t.ink,
      secondary: t.ink2,
      icon: toneColor,
      iconBackground: Color.lerp(t.surface, toneColor, 0.16)!,
      border: Color.lerp(t.line, toneColor, 0.32)!,
    );
  }
}
