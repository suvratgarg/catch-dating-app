import 'dart:async';

import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _celebrationInk = CatchCelebrationColors.ink;
const _celebrationCream = CatchCelebrationColors.cream;
const _celebrationActionInk = CatchCelebrationColors.actionInk;

enum CatchCelebrationAppearance { immersive, paper }

class CelebrationDetail {
  const CelebrationDetail({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}

class CelebrationAction {
  const CelebrationAction({
    this.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = CatchButtonVariant.primary,
  });

  final Key? key;
  final String label;
  final VoidCallback onPressed;
  final Widget? icon;
  final CatchButtonVariant variant;
}

class CatchCelebrationScreen extends ConsumerStatefulWidget {
  const CatchCelebrationScreen({
    super.key,
    required this.kind,
    required this.title,
    required this.message,
    required this.primaryAction,
    this.eyebrow,
    this._icon,
    this.visual,
    this.details = const [],
    this.note,
    this.supplementalChildren = const [],
    this.secondaryAction,
    this.onClose,
    this.showCloseButton,
    this.playEffects = true,
    this.appearance = CatchCelebrationAppearance.immersive,
  });

  final CelebrationMomentKind kind;
  final String? eyebrow;
  final String title;
  final String message;
  final IconData? _icon;
  final Widget? visual;
  final List<CelebrationDetail> details;
  final String? note;
  final List<Widget> supplementalChildren;
  final CelebrationAction primaryAction;
  final CelebrationAction? secondaryAction;
  final VoidCallback? onClose;
  final bool? showCloseButton;
  final bool playEffects;
  final CatchCelebrationAppearance appearance;

  IconData get icon => _icon ?? CatchIcons.checkRounded;

  @override
  ConsumerState<CatchCelebrationScreen> createState() =>
      _CatchCelebrationScreenState();
}

class _CatchCelebrationScreenState
    extends ConsumerState<CatchCelebrationScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.playEffects) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          ref.read(celebrationEffectsControllerProvider).play(widget.kind),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appearance == CatchCelebrationAppearance.paper) {
      return _PaperCelebrationScaffold(screen: widget);
    }

    final t = CatchTokens.of(context);
    final details = widget.details;
    final secondaryAction = widget.secondaryAction;
    final showCloseButton = widget.showCloseButton ?? widget.onClose != null;

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: t.heroGrad),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  CatchSpacing.s4,
                  CatchSpacing.s5,
                  CatchSpacing.s5,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight -
                        CatchLayout.celebrationViewportVerticalPadding,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: !showCloseButton || widget.onClose == null
                              ? gapH44
                              : CatchIconButton(
                                  background: _celebrationCream.withValues(
                                    alpha: 0.22,
                                  ),
                                  onTap: widget.onClose,
                                  child: Icon(
                                    CatchIcons.closeRounded,
                                    color: _celebrationInk,
                                  ),
                                ),
                        ),
                        gapH36,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: widget.visual ?? _CelebrationIcon(widget.icon),
                        ),
                        gapH24,
                        if (widget.eyebrow != null) ...[
                          Text(
                            widget.eyebrow!.toUpperCase(),
                            style: CatchTextStyles.labelM(
                              context,
                              color: _celebrationCream.withValues(alpha: 0.9),
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                          gapH8,
                        ],
                        Text(
                          widget.title,
                          style: CatchTextStyles.display(
                            context,
                            color: _celebrationCream,
                          ),
                        ),
                        gapH14,
                        Text(
                          widget.message,
                          style: CatchTextStyles.bodyL(
                            context,
                            color: _celebrationCream.withValues(alpha: 0.92),
                          ),
                        ),
                        if (details.isNotEmpty) ...[
                          gapH28,
                          _CelebrationDetailsCard(details: details),
                        ],
                        if (widget.note != null) ...[
                          gapH16,
                          _CelebrationNote(note: widget.note!),
                        ],
                        for (final child in widget.supplementalChildren) ...[
                          gapH16,
                          child,
                        ],
                        const Spacer(),
                        gapH32,
                        CatchButton(
                          key: widget.primaryAction.key,
                          label: widget.primaryAction.label,
                          onPressed: widget.primaryAction.onPressed,
                          icon: widget.primaryAction.icon,
                          variant: CatchButtonVariant.light,
                          fullWidth: true,
                          backgroundColor: _celebrationCream,
                          foregroundColor: _celebrationActionInk,
                        ),
                        if (secondaryAction != null) ...[
                          gapH12,
                          CatchButton(
                            key: secondaryAction.key,
                            label: secondaryAction.label,
                            onPressed: secondaryAction.onPressed,
                            icon: secondaryAction.icon,
                            variant: secondaryAction.variant,
                            fullWidth: true,
                            backgroundColor: _celebrationCream.withValues(
                              alpha: 0.58,
                            ),
                            foregroundColor: _celebrationActionInk,
                            borderColor: _celebrationActionInk.withValues(
                              alpha: 0.16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaperCelebrationScaffold extends StatelessWidget {
  const _PaperCelebrationScaffold({required this.screen});

  final CatchCelebrationScreen screen;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final secondaryAction = screen.secondaryAction;
    final showCloseButton = screen.showCloseButton ?? screen.onClose != null;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchLayout.celebrationPaperTopPadding,
                CatchSpacing.s5,
                CatchLayout.celebrationPaperBottomPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      CatchLayout.celebrationPaperViewportVerticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showCloseButton && screen.onClose != null) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: CatchIconButton(
                          background: t.primarySoft,
                          onTap: screen.onClose,
                          child: Icon(
                            CatchIcons.closeRounded,
                            color: t.primary,
                          ),
                        ),
                      ),
                      gapH20,
                    ],
                    Align(
                      child:
                          screen.visual ?? _PaperCelebrationIcon(screen.icon),
                    ),
                    if (screen.eyebrow != null) ...[
                      gapH16,
                      Text(
                        screen.eyebrow!.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: CatchTextStyles.labelM(
                          context,
                          color: t.primary,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                    gapH8,
                    Text(
                      screen.title,
                      textAlign: TextAlign.center,
                      style: CatchTextStyles.display(context, color: t.ink),
                    ),
                    gapH10,
                    Align(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: Text(
                          screen.message,
                          textAlign: TextAlign.center,
                          style: CatchTextStyles.bodyM(context, color: t.ink2),
                        ),
                      ),
                    ),
                    if (screen.details.isNotEmpty) ...[
                      gapH24,
                      _PaperCelebrationDetailsCard(details: screen.details),
                    ],
                    if (screen.note != null) ...[
                      gapH12,
                      Text(
                        screen.note!,
                        textAlign: TextAlign.center,
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink3,
                        ),
                      ),
                    ],
                    for (final child in screen.supplementalChildren) ...[
                      gapH18,
                      child,
                    ],
                    const SizedBox(
                      height: CatchLayout.celebrationPaperActionTopGap,
                    ),
                    CatchButton(
                      key: screen.primaryAction.key,
                      label: screen.primaryAction.label,
                      onPressed: screen.primaryAction.onPressed,
                      icon: screen.primaryAction.icon,
                      fullWidth: true,
                      backgroundColor: t.primary,
                      foregroundColor: t.primaryInk,
                    ),
                    if (secondaryAction != null) ...[
                      gapH10,
                      CatchButton(
                        key: secondaryAction.key,
                        label: secondaryAction.label,
                        onPressed: secondaryAction.onPressed,
                        icon: secondaryAction.icon,
                        variant: secondaryAction.variant,
                        fullWidth: true,
                        backgroundColor: Colors.transparent,
                        foregroundColor: t.ink,
                        borderColor: t.line2,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaperCelebrationIcon extends StatelessWidget {
  const _PaperCelebrationIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      width: CatchSpacing.s16,
      height: CatchSpacing.s16,
      decoration: BoxDecoration(color: t.primarySoft, shape: BoxShape.circle),
      child: Icon(icon, color: t.primary, size: 30),
    );
  }
}

class _PaperCelebrationDetailsCard extends StatelessWidget {
  const _PaperCelebrationDetailsCard({required this.details});

  final List<CelebrationDetail> details;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        border: Border.all(color: t.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
        child: Column(
          children: [
            for (final entry in details.indexed) ...[
              _PaperCelebrationDetailRow(detail: entry.$2),
              if (entry.$1 != details.length - 1)
                Divider(color: t.line.withValues(alpha: 0.18), height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaperCelebrationDetailRow extends StatelessWidget {
  const _PaperCelebrationDetailRow({required this.detail});

  final CelebrationDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final icon = detail.icon;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: CatchLayout.celebrationPaperDetailRowVerticalPadding,
      ),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: t.ink3), gapW12],
          SizedBox(
            width: CatchLayout.celebrationDetailLabelWidth,
            child: Text(
              detail.label.toUpperCase(),
              style: CatchTextStyles.labelS(context, color: t.ink2),
            ),
          ),
          gapW12,
          Expanded(
            child: Text(
              detail.value,
              textAlign: TextAlign.right,
              style: CatchTextStyles.titleS(context, color: t.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationIcon extends StatelessWidget {
  const _CelebrationIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CatchLayout.celebrationIconExtent,
      height: CatchLayout.celebrationIconExtent,
      decoration: BoxDecoration(
        color: _celebrationCream.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(color: _celebrationCream.withValues(alpha: 0.28)),
      ),
      child: Icon(icon, color: _celebrationInk, size: 40),
    );
  }
}

class _CelebrationDetailsCard extends StatelessWidget {
  const _CelebrationDetailsCard({required this.details});

  final List<CelebrationDetail> details;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _celebrationCream.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        border: Border.all(color: _celebrationCream.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: Column(
          children: [
            for (final entry in details.indexed) ...[
              _CelebrationDetailRow(detail: entry.$2),
              if (entry.$1 != details.length - 1)
                Divider(
                  color: _celebrationInk.withValues(alpha: 0.20),
                  height: CatchSpacing.s4,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CelebrationDetailRow extends StatelessWidget {
  const _CelebrationDetailRow({required this.detail});

  final CelebrationDetail detail;

  @override
  Widget build(BuildContext context) {
    final icon = detail.icon;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: _celebrationInk),
          gapW10,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: CatchTextStyles.labelS(
                  context,
                  color: _celebrationInk.withValues(alpha: 0.74),
                ),
              ),
              gapH3,
              Text(
                detail.value,
                style: CatchTextStyles.bodyLead(
                  context,
                  color: _celebrationInk,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CelebrationNote extends StatelessWidget {
  const _CelebrationNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _celebrationCream.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        border: Border.all(color: _celebrationCream.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: Row(
          children: [
            Icon(CatchIcons.boltRounded, color: _celebrationInk, size: 18),
            gapW10,
            Expanded(
              child: Text(
                note,
                style: CatchTextStyles.supporting(
                  context,
                  color: _celebrationInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
