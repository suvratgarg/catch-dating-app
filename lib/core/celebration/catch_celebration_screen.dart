import 'dart:async';

import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _celebrationInk = Colors.white;
const _celebrationCream = Colors.white;
const _celebrationActionInk = Color(0xFF24110A);

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
    final t = CatchTokens.of(context);
    final details = widget.details;
    final secondaryAction = widget.secondaryAction;

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
                        (CatchSpacing.s4 + CatchSpacing.s5),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: widget.onClose == null
                              ? const SizedBox(height: 44)
                              : IconBtn(
                                  background: _celebrationCream.withValues(
                                    alpha: 0.22,
                                  ),
                                  onTap: widget.onClose,
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: _celebrationInk,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 36),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: widget.visual ?? _CelebrationIcon(widget.icon),
                        ),
                        gapH24,
                        if (widget.eyebrow != null) ...[
                          Text(
                            widget.eyebrow!.toUpperCase(),
                            style:
                                CatchTextStyles.labelM(
                                  context,
                                  color: _celebrationCream.withValues(
                                    alpha: 0.9,
                                  ),
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
                          const SizedBox(height: 28),
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

class _CelebrationIcon extends StatelessWidget {
  const _CelebrationIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
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
                style: CatchTextStyles.bodyM(context, color: _celebrationInk),
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
            const Icon(Icons.bolt_rounded, color: _celebrationInk, size: 18),
            gapW10,
            Expanded(
              child: Text(
                note,
                style: CatchTextStyles.bodyS(context, color: _celebrationInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
