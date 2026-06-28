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
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
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
  });

  final ProfileReactionTarget target;
  final ProfileReactionCallback onReact;
  final ProfileReactionControlsStyle style;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final children = [
      _reactionControlButton(
        context,
        tooltip: 'Like ${target.label}',
        icon: CatchIcons.favoriteBorderRounded,
        onPressed: () => unawaited(Future.sync(() => onReact(target, null))),
        style: style,
      ),
      _reactionControlButton(
        context,
        tooltip: 'Comment on ${target.label}',
        icon: CatchIcons.chatBubbleOutlineRounded,
        onPressed: () => unawaited(_commentThenReact(context)),
        style: style,
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
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => ProfileReactionCommentSheet(target: target),
  );
}

class ProfileReactionCommentSheet extends StatefulWidget {
  const ProfileReactionCommentSheet({super.key, required this.target});

  final ProfileReactionTarget target;

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
    _controller = TextEditingController()..addListener(_handleChanged);
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

Widget _reactionControlButton(
  BuildContext context, {
  required String tooltip,
  required IconData icon,
  required VoidCallback onPressed,
  required ProfileReactionControlsStyle style,
}) {
  final palette = ProfileCardPalette.of(context);
  final isOverlay = style == ProfileReactionControlsStyle.overlay;
  final background = isOverlay
      ? CatchTokens.editorialLight.withValues(
          alpha: CatchOpacity.reactionOverlayFill,
        )
      : palette.chipFill;
  final foreground = isOverlay ? palette.accent : palette.textSecondary;
  final border = isOverlay
      ? CatchTokens.editorialLight.withValues(
          alpha: CatchOpacity.reactionOverlayBorder,
        )
      : palette.chipBorder;

  return Tooltip(
    message: tooltip,
    child: Material(
      color: background,
      shape: CircleBorder(side: BorderSide(color: border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: CatchLayout.reactionControlExtent,
          child: Icon(
            icon,
            color: foreground,
            size: CatchLayout.reactionControlIconSize,
          ),
        ),
      ),
    ),
  );
}
