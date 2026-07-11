import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_card_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ProfileReactionCallback =
    FutureOr<void> Function(ProfileReactionTarget target, String? comment);

enum ProfileReactionControlsStyle { surface, overlay }

class ProfileReactionControls extends StatelessWidget {
  const ProfileReactionControls({
    super.key,
    required this.target,
    required this.onReact,
    this.style = ProfileReactionControlsStyle.surface,
    this.axis = Axis.horizontal,
    this.enabled = true,
    this.isPending = false,
  });

  final ProfileReactionTarget target;
  final ProfileReactionCallback onReact;
  final ProfileReactionControlsStyle style;
  final Axis axis;
  final bool enabled;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final actionsEnabled = enabled && !isPending;
    final children = [
      ReactionControlButton(
        tooltip: 'Like ${target.label}',
        icon: CatchIcons.favoriteBorderRounded,
        onPressed: actionsEnabled
            ? () => unawaited(Future.sync(() => onReact(target, null)))
            : null,
        style: style,
        isPending: isPending,
      ),
      ReactionControlButton(
        tooltip: 'Comment on ${target.label}',
        icon: CatchIcons.chatBubbleOutlineRounded,
        onPressed: actionsEnabled
            ? () => unawaited(_commentThenReact(context))
            : null,
        style: style,
        isPending: isPending,
      ),
    ];

    return axis == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: _withSpacing(children))
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: _withSpacing(children),
          );
  }

  List<Widget> _withSpacing(List<Widget> children) {
    if (children.length < 2) return children;
    final gap = axis == Axis.horizontal ? gapW8 : gapH8;
    return [children.first, gap, ...children.skip(1)];
  }

  Future<void> _commentThenReact(BuildContext context) async {
    final comment = await showProfileReactionCommentSheet(
      context: context,
      target: target,
    );
    if (comment == null) return;
    await onReact(target, comment);
  }
}

Future<String?> showProfileReactionCommentSheet({
  required BuildContext context,
  required ProfileReactionTarget target,
}) {
  return showCatchBottomSheet<String>(
    context: context,
    builder: (_) => ProfileReactionCommentSheet(target: target),
  );
}

class ProfileReactionCommentSheet extends StatefulWidget {
  const ProfileReactionCommentSheet({
    super.key,
    required this.target,
    this.initialComment,
  });

  final ProfileReactionTarget target;
  final String? initialComment;

  @override
  State<ProfileReactionCommentSheet> createState() =>
      _ProfileReactionCommentSheetState();
}

class _ProfileReactionCommentSheetState
    extends State<ProfileReactionCommentSheet> {
  late final TextEditingController _controller;

  String get _comment => _controller.text.trim();
  bool get _canSend => _comment.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment)
      ..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  void _handleChanged() => setState(() {});

  void _submit() {
    if (!_canSend) return;
    Navigator.of(context).pop(_comment);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchBottomSheetScaffold(
      title: 'Start with ${widget.target.label}',
      subtitle: 'Send a comment with your like.',
      keyboardSafe: true,
      action: Row(
        children: [
          CatchTextButton(
            label: 'Cancel',
            tone: CatchTextButtonTone.neutral,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          CatchButton(
            label: 'Send like',
            icon: Icon(CatchIcons.favoriteBorderRounded, size: CatchIcon.md),
            onPressed: _canSend ? _submit : null,
            size: CatchButtonSize.sm,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSurface(
            radius: CatchRadius.md,
            backgroundColor: t.raised,
            borderColor: t.line,
            padding: CatchInsets.contentDense,
            child: Text(
              widget.target.preview,
              style: CatchTextStyles.bodyLead(context, color: t.ink2),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          gapH14,
          CatchField.input(
            title: 'Comment',
            showLabel: false,
            controller: _controller,
            placeholder: 'Write something specific...',
            helperText:
                '${_comment.length} / $maxSwipeReactionCommentLength characters',
            maxLines: 4,
            minLines: 3,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxSwipeReactionCommentLength),
            ],
          ),
        ],
      ),
    );
  }
}

class ReactionControlButton extends StatelessWidget {
  const ReactionControlButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.style,
    this.isPending = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final ProfileReactionControlsStyle style;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);
    final isOverlay = style == ProfileReactionControlsStyle.overlay;
    final background = isOverlay
        ? CatchTokens.editorialWhite.withValues(
            alpha: CatchOpacity.reactionOverlayFill,
          )
        : palette.chipFill;
    final foreground = isOverlay ? palette.accent : palette.textSecondary;
    final border = isOverlay
        ? CatchTokens.editorialWhite.withValues(
            alpha: CatchOpacity.reactionOverlayBorder,
          )
        : palette.chipBorder;
    final isEnabled = onPressed != null && !isPending;

    return Semantics(
      label: tooltip,
      button: true,
      enabled: isEnabled,
      child: Tooltip(
        message: tooltip,
        child: AnimatedOpacity(
          opacity: isEnabled || isPending ? 1 : CatchOpacity.disabledControl,
          duration: const Duration(milliseconds: 120),
          child: Material(
            color: background,
            shape: CircleBorder(side: BorderSide(color: border)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isEnabled ? onPressed : null,
              child: SizedBox.square(
                dimension: CatchLayout.reactionControlExtent,
                child: Center(
                  child: isPending
                      ? SizedBox.square(
                          dimension: CatchLayout.reactionControlIconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              foreground,
                            ),
                          ),
                        )
                      : Icon(
                          icon,
                          color: foreground,
                          size: CatchLayout.reactionControlIconSize,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
