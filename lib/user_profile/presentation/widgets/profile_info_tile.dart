import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

const _tilePadding = EdgeInsets.symmetric(vertical: CatchSpacing.s3);
const _profileInlineAnimationOffset = Offset(0, -0.04);
const _profileInfoTrailingWidth = 40.0;

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.valueEditor,
    this.isAddAffordance = false,
    this.isExpanded = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? valueEditor;
  final bool isAddAffordance;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final onTap = this.onTap;
    final valueContent = valueEditor != null
        ? KeyedSubtree(
            key: ValueKey('profile-info-$label-editor'),
            child: valueEditor!,
          )
        : Text(
            isAddAffordance ? '+ $value' : value,
            key: ValueKey('profile-info-$label-$value-$isAddAffordance'),
            style: CatchTextStyles.bodyL(
              context,
              color: isAddAffordance ? t.ink3 : null,
            ),
          );

    final row = Row(
      children: [
        Icon(icon, color: t.ink2),
        gapW16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: CatchTextStyles.bodyS(context)),
              gapH4,
              AnimatedSwitcher(
                duration: CatchMotion.fast,
                switchInCurve: CatchMotion.standardCurve,
                switchOutCurve: CatchMotion.standardCurve,
                transitionBuilder: _profileInlineTransition,
                child: valueContent,
              ),
            ],
          ),
        ),
        if (onTap != null)
          _ProfileInfoChevron(
            key: ValueKey('profile-info-$label-chevron'),
            label: label,
            isExpanded: isExpanded,
            isInteractive: valueEditor != null,
            onTap: onTap,
          ),
      ],
    );
    final animatedRow = AnimatedSize(
      duration: CatchMotion.base,
      curve: CatchMotion.standardCurve,
      alignment: Alignment.topCenter,
      child: row,
    );

    final tilePadding = valueEditor == null
        ? _tilePadding
        : const EdgeInsets.only(top: CatchSpacing.s3, bottom: CatchSpacing.s2);

    if (valueEditor != null) {
      return Padding(padding: tilePadding, child: animatedRow);
    }

    if (onTap == null) {
      return Padding(padding: tilePadding, child: animatedRow);
    }

    return Semantics(
      button: true,
      label: '$label: $value',
      expanded: isExpanded,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        child: Padding(padding: tilePadding, child: animatedRow),
      ),
    );
  }
}

class _ProfileInfoChevron extends StatelessWidget {
  const _ProfileInfoChevron({
    super.key,
    required this.label,
    required this.isExpanded,
    required this.isInteractive,
    required this.onTap,
  });

  final String label;
  final bool isExpanded;
  final bool isInteractive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final tooltip = isExpanded ? 'Collapse $label' : 'Edit $label';
    final chevron = Center(
      child: AnimatedRotation(
        turns: isExpanded ? -0.25 : 0,
        duration: CatchMotion.base,
        curve: CatchMotion.standardCurve,
        child: Icon(Icons.chevron_right_rounded, color: t.ink3, size: 20),
      ),
    );

    return SizedBox(
      width: _profileInfoTrailingWidth,
      height: _profileInfoTrailingWidth,
      child: isInteractive
          ? Semantics(
              button: true,
              label: tooltip,
              child: Tooltip(
                message: tooltip,
                child: InkResponse(
                  onTap: onTap,
                  radius: CatchSpacing.s5,
                  child: chevron,
                ),
              ),
            )
          : IgnorePointer(
              child: Tooltip(message: tooltip, child: chevron),
            ),
    );
  }
}

class ProfileInlineDisclosure extends StatelessWidget {
  const ProfileInlineDisclosure({
    super.key,
    required this.isExpanded,
    required this.header,
    required this.body,
  });

  final bool isExpanded;
  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        ProfileInlineAnimatedBody(isExpanded: isExpanded, child: body),
      ],
    );
  }
}

class ProfileInlineAnimatedBody extends StatelessWidget {
  const ProfileInlineAnimatedBody({
    super.key,
    required this.isExpanded,
    required this.child,
  });

  final bool isExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: CatchMotion.base,
        curve: CatchMotion.standardCurve,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: CatchMotion.base,
          switchInCurve: CatchMotion.standardCurve,
          switchOutCurve: CatchMotion.standardCurve,
          transitionBuilder: _profileInlineBodyTransition,
          child: isExpanded
              ? SizedBox(
                  key: const ValueKey('profile-inline-expanded'),
                  width: double.infinity,
                  child: child,
                )
              : const SizedBox(
                  key: ValueKey('profile-inline-collapsed'),
                  width: double.infinity,
                  height: 0,
                ),
        ),
      ),
    );
  }
}

Widget _profileInlineTransition(Widget child, Animation<double> animation) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: CatchMotion.standardCurve,
    reverseCurve: CatchMotion.standardCurve,
  );

  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: _profileInlineAnimationOffset,
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}

Widget _profileInlineBodyTransition(Widget child, Animation<double> animation) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: CatchMotion.standardCurve,
    reverseCurve: CatchMotion.standardCurve,
  );

  return FadeTransition(opacity: curved, child: child);
}
