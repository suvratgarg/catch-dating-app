import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:flutter/material.dart';

class CatchBottomSheetScaffold extends StatelessWidget {
  const CatchBottomSheetScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.glyph,
    this.badge,
    this.badgeTone = CatchBadgeTone.neutral,
    this.trailing,
    this.grabber = true,
    this.keyboardSafe = false,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? action;
  final IconData? glyph;
  final String? badge;
  final CatchBadgeTone badgeTone;
  final Widget? trailing;
  final bool grabber;
  final bool keyboardSafe;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomInset = keyboardSafe
        ? MediaQuery.of(context).viewInsets.bottom
        : 0.0;
    final effectivePadding =
        padding ??
        EdgeInsets.fromLTRB(
          CatchLayout.sheetHorizontalPadding,
          CatchLayout.sheetTopPadding,
          CatchLayout.sheetHorizontalPadding,
          bottomInset + CatchLayout.sheetBottomPadding,
        );
    final right = _rightSlot;
    final hasHeader = _hasText(title) || glyph != null || right != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(CatchLayout.sheetTopRadius),
          topRight: Radius.circular(CatchLayout.sheetTopRadius),
          bottomLeft: Radius.circular(CatchLayout.sheetBottomRadius),
          bottomRight: Radius.circular(CatchLayout.sheetBottomRadius),
        ),
        boxShadow: CatchElevation.overlay,
      ),
      child: Padding(
        padding: effectivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (grabber) ...[
              const BottomSheetGrabber(),
              const SizedBox(height: CatchLayout.sheetGrabberBottomMargin),
            ],
            if (hasHeader)
              glyph == null
                  ? _PlainSheetHeader(
                      title: title,
                      subtitle: subtitle,
                      trailing: right,
                    )
                  : _BrandedSheetHeader(
                      glyph: glyph!,
                      title: title,
                      subtitle: subtitle,
                      trailing: right,
                    ),
            if (hasHeader)
              const SizedBox(height: CatchLayout.sheetHeaderBodyGap),
            child,
            if (action != null) ...[gapH16, action!],
          ],
        ),
      ),
    );
  }

  Widget? get _rightSlot {
    if (_hasText(badge)) {
      return CatchBadge(label: badge!, tone: badgeTone, uppercase: true);
    }
    return trailing;
  }
}

class _PlainSheetHeader extends StatelessWidget {
  const _PlainSheetHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasText(title))
                Text(title!, style: CatchTextStyles.titleL(context)),
              if (_hasText(subtitle)) ...[
                gapH6,
                Text(
                  subtitle!,
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: CatchLayout.sheetHeaderGap),
          trailing!,
        ],
      ],
    );
  }
}

class _BrandedSheetHeader extends StatelessWidget {
  const _BrandedSheetHeader({
    required this.glyph,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData glyph;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.ink,
            borderRadius: BorderRadius.circular(
              CatchLayout.sheetGlyphTileRadius,
            ),
          ),
          child: SizedBox.square(
            dimension: CatchLayout.sheetGlyphTileSize,
            child: Icon(
              glyph,
              size: CatchLayout.sheetGlyphIconSize,
              color: t.primaryInk,
            ),
          ),
        ),
        const SizedBox(width: CatchLayout.sheetHeaderGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasText(title))
                Text(title!, style: CatchTextStyles.titleL(context)),
              if (_hasText(subtitle)) ...[
                gapH2,
                Text(
                  subtitle!,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: CatchLayout.sheetHeaderGap),
          trailing!,
        ],
      ],
    );
  }
}

bool _hasText(String? value) => value != null && value.isNotEmpty;
