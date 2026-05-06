import 'dart:async';

import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.icon = Icons.check_rounded,
    this.visual,
    this.details = const [],
    this.note,
    this.supplementalChildren = const [],
    this.secondaryAction,
    this.onClose,
    this.playEffects = true,
  });

  final CelebrationMomentKind kind;
  final String? eyebrow;
  final String title;
  final String message;
  final IconData icon;
  final Widget? visual;
  final List<CelebrationDetail> details;
  final String? note;
  final List<Widget> supplementalChildren;
  final CelebrationAction primaryAction;
  final CelebrationAction? secondaryAction;
  final VoidCallback? onClose;
  final bool playEffects;

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
    const successInk = Color(0xFF1A1410);
    final t = CatchTokens.of(context);
    final details = widget.details;
    final secondaryAction = widget.secondaryAction;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: t.heroGrad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: widget.onClose == null
                      ? const SizedBox(height: 40)
                      : IconBtn(
                          background: successInk.withValues(alpha: 0.16),
                          onTap: widget.onClose,
                          child: const Icon(
                            Icons.close_rounded,
                            color: successInk,
                          ),
                        ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        gapH32,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: widget.visual ?? _CelebrationIcon(widget.icon),
                        ),
                        gapH20,
                        if (widget.eyebrow != null) ...[
                          Text(
                            widget.eyebrow!.toUpperCase(),
                            style:
                                CatchTextStyles.labelM(
                                  context,
                                  color: Colors.white.withValues(alpha: 0.86),
                                ).copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                          ),
                          gapH8,
                        ],
                        Text(
                          widget.title,
                          style: CatchTextStyles.displayXL(
                            context,
                            color: Colors.white,
                          ),
                        ),
                        gapH10,
                        Text(
                          widget.message,
                          style: CatchTextStyles.bodyL(
                            context,
                            color: Colors.white,
                          ),
                        ),
                        if (details.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          _CelebrationDetailsCard(details: details),
                        ],
                        if (widget.note != null) ...[
                          gapH14,
                          CatchSurface(
                            padding: const EdgeInsets.all(CatchSpacing.s4),
                            backgroundColor: successInk.withValues(alpha: 0.14),
                            borderColor: successInk.withValues(alpha: 0.18),
                            radius: CatchRadius.lg,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: successInk,
                                  size: 18,
                                ),
                                gapW10,
                                Expanded(
                                  child: Text(
                                    widget.note!,
                                    style: CatchTextStyles.bodyS(
                                      context,
                                      color: successInk,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        for (final child in widget.supplementalChildren) ...[
                          gapH14,
                          child,
                        ],
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
                CatchButton(
                  key: widget.primaryAction.key,
                  label: widget.primaryAction.label,
                  onPressed: widget.primaryAction.onPressed,
                  icon: widget.primaryAction.icon,
                  variant: widget.primaryAction.variant,
                  fullWidth: true,
                  backgroundColor: Colors.white,
                  foregroundColor: successInk,
                  borderColor: Colors.transparent,
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
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                    foregroundColor: successInk,
                    borderColor: successInk.withValues(alpha: 0.20),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CelebrationIcon extends StatelessWidget {
  const _CelebrationIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const successInk = Color(0xFF1A1410);

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: successInk.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: successInk.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: successInk, size: 38),
    );
  }
}

class _CelebrationDetailsCard extends StatelessWidget {
  const _CelebrationDetailsCard({required this.details});

  final List<CelebrationDetail> details;

  @override
  Widget build(BuildContext context) {
    const successInk = Color(0xFF1A1410);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      backgroundColor: successInk.withValues(alpha: 0.14),
      borderColor: successInk.withValues(alpha: 0.18),
      radius: CatchRadius.lg,
      child: Column(
        children: [
          for (final entry in details.indexed) ...[
            _CelebrationDetailRow(detail: entry.$2),
            if (entry.$1 != details.length - 1)
              Divider(
                color: successInk.withValues(alpha: 0.14),
                height: CatchSpacing.s4,
              ),
          ],
        ],
      ),
    );
  }
}

class _CelebrationDetailRow extends StatelessWidget {
  const _CelebrationDetailRow({required this.detail});

  final CelebrationDetail detail;

  @override
  Widget build(BuildContext context) {
    const successInk = Color(0xFF1A1410);
    final icon = detail.icon;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: successInk), gapW10],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: CatchTextStyles.labelS(
                  context,
                  color: successInk.withValues(alpha: 0.68),
                ),
              ),
              gapH3,
              Text(
                detail.value,
                style: CatchTextStyles.bodyM(context, color: successInk),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
