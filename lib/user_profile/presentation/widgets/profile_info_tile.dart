import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:flutter/material.dart';

const _profileInfoTrailingWidth = CatchSpacing.s10;

Widget profileInfoTile({
  Key? key,
  required IconData icon,
  required String label,
  required String value,
  VoidCallback? onTap,
  bool isAddAffordance = false,
  bool isExpanded = false,
}) {
  return CatchField(
    key: key,
    icon: icon,
    title: label,
    body: isAddAffordance ? '+ $value' : value,
    bodyMaxLines: 4,
    mode: onTap == null ? CatchFieldMode.read : CatchFieldMode.nav,
    tone: isAddAffordance ? CatchFieldTone.primary : CatchFieldTone.normal,
    onTap: isExpanded ? null : onTap,
    showChevron: false,
    action: onTap == null
        ? null
        : Builder(
            builder: (context) => _profileInfoChevron(
              context: context,
              label: label,
              isExpanded: isExpanded,
              isInteractive: isExpanded,
              onTap: onTap,
            ),
          ),
  );
}

Widget _profileInfoChevron({
  required BuildContext context,
  required String label,
  required bool isExpanded,
  required bool isInteractive,
  required VoidCallback onTap,
}) {
  final t = CatchTokens.of(context);
  final tooltip = isExpanded ? 'Collapse $label' : 'Edit $label';
  final chevron = Center(
    child: AnimatedRotation(
      turns: isExpanded ? -0.25 : 0,
      duration: CatchMotion.base,
      curve: CatchMotion.standardCurve,
      child: Icon(
        CatchIcons.chevronRightRounded,
        color: t.ink3,
        size: CatchIcon.control,
      ),
    ),
  );

  return Semantics(
    button: true,
    enabled: isInteractive,
    label: tooltip,
    child: Tooltip(
      message: tooltip,
      child: SizedBox(
        key: ValueKey('profile-info-$label-chevron'),
        width: _profileInfoTrailingWidth,
        height: _profileInfoTrailingWidth,
        child: InkResponse(
          onTap: isInteractive ? onTap : null,
          radius: CatchSpacing.s5,
          child: chevron,
        ),
      ),
    ),
  );
}

Widget profileInlineDisclosure({
  required bool isExpanded,
  required Widget header,
  required Widget body,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      header,
      profileInlineAnimatedBody(isExpanded: isExpanded, child: body),
    ],
  );
}

Widget profileInlineAnimatedBody({
  required bool isExpanded,
  required Widget child,
}) {
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

Widget _profileInlineBodyTransition(Widget child, Animation<double> animation) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: CatchMotion.standardCurve,
    reverseCurve: CatchMotion.standardCurve,
  );

  return FadeTransition(opacity: curved, child: child);
}
