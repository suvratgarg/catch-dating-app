import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Cross-family comparison pages for reasoning about Catch component geometry.
///
/// The exhaustive state inventory remains on each component's "Contract
/// states" page. These pages deliberately compare only the states that reveal
/// shared silhouette, edge, spacing, alignment, plane, and viewport rules.

@widgetbook.UseCase(
  name: 'Geometry matrix',
  type: CatchSection,
  path: '[Geometry system]',
)
Widget fieldAndSectionGeometryMatrix(BuildContext context) {
  return _geometryPage(
    context,
    title: 'Fields and sections',
    contractIds: const ['catch.field', 'catch.section'],
    principles: const [
      'The outermost containing primitive owns the perimeter.',
      'Sibling rows share internal hairlines instead of stacked borders.',
      'Expanded and focused children preserve the section silhouette.',
    ],
    children: [
      _specimen(
        context,
        label: 'Approved section-header roles',
        description:
            'Field-row groups label the rows from outside the outline; contextual groups omit redundant labels; content cards keep their title inside.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final comparisonWidth = constraints.maxWidth >= 720
                ? (constraints.maxWidth - CatchSpacing.s4) / 2
                : constraints.maxWidth.clamp(0, _componentWidth).toDouble();
            return Wrap(
              spacing: CatchSpacing.s4,
              runSpacing: CatchSpacing.s5,
              children: [
                _sectionHeaderComparison(
                  context,
                  width: comparisonWidth,
                  label: 'Field-row group',
                  description:
                      'The label names the group; the outline begins with the rows.',
                  child: CatchSection.containedFieldRows(
                    title: 'Event settings',
                    children: _eventSettingRows(),
                  ),
                ),
                _sectionHeaderComparison(
                  context,
                  width: comparisonWidth,
                  label: 'Contextual field rows',
                  description:
                      'Omit the label when the page or step title already names the group.',
                  child: CatchSection.containedFieldRows(
                    children: _eventSettingRows(),
                  ),
                ),
                _sectionHeaderComparison(
                  context,
                  width: comparisonWidth,
                  label: 'Content card',
                  description:
                      'Keep an internal title when the whole surface is one actionable module.',
                  child: CatchSection.contained(
                    title: 'Event readiness',
                    subtitle: '3 of 4 setup steps complete',
                    trailing: CatchTextButton(
                      label: 'Review',
                      tone: CatchTextButtonTone.neutral,
                      onPressed: _noop,
                      padding: const EdgeInsets.symmetric(
                        horizontal: CatchSpacing.s1,
                      ),
                    ),
                    child: Text(
                      'Add the venue entry note before invitations go out.',
                      style: CatchTextStyles.supporting(
                        context,
                        color: CatchTokens.of(context).ink2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      _specimen(
        context,
        label: 'Standalone fields',
        description:
            'The field owns its active chrome when no section supplies a perimeter.',
        child: SizedBox(
          width: _componentWidth,
          child: Column(
            children: [
              CatchField.read(
                title: 'Host',
                body: 'Catch Hosts',
                icon: CatchIcons.hosted,
              ),
              CatchField.input(
                title: 'Public name',
                initialValue: 'Bandra Social Run',
                icon: CatchIcons.personOutlined,
                focused: true,
              ),
            ],
          ),
        ),
      ),
      _specimen(
        context,
        label: 'Contained row positions',
        description:
            'The section owns the rounded exterior; top, middle, and bottom rows meet on square internal edges.',
        child: SizedBox(
          width: _componentWidth,
          child: CatchSection.containedFieldRows(
            title: 'Event settings',
            children: [
              CatchField.read(
                title: 'Host',
                body: 'Catch Hosts',
                icon: CatchIcons.hosted,
              ),
              CatchField.nav(
                title: 'Location',
                body: 'Carter Road promenade',
                icon: CatchIcons.pinOutlined,
                onTap: _noop,
              ),
              CatchField.toggle(
                title: 'Allow reminders',
                body: 'Push and email',
                icon: CatchIcons.notificationsOutlined,
                value: true,
                onChanged: _ignoreBool,
              ),
            ],
          ),
        ),
      ),
      _specimen(
        context,
        label: 'Contained active child',
        description:
            'An expanded child overlaps one hairline without rounding an internal edge or drawing a second container.',
        child: SizedBox(
          width: _componentWidth,
          child: CatchSection.containedFieldRows(
            title: 'Guest preferences',
            children: [
              CatchField.read(
                title: 'Visibility',
                body: 'Private to attendees',
                icon: CatchIcons.lockOutlineRounded,
              ),
              CatchField.choices<String>(
                title: 'Languages',
                values: const ['English', 'Hindi', 'Marathi', 'Tamil'],
                itemLabel: (value) => value,
                selected: const {'English', 'Hindi'},
                initiallyOpen: true,
                onSelectionChanged: _ignoreStrings,
              ),
              CatchField.input(
                title: 'Arrival note',
                initialValue: 'Meet beside the cafe entrance.',
              ),
            ],
          ),
        ),
      ),
      _specimen(
        context,
        label: 'Next decision · what earns an outline',
        description:
            'The content is identical. Decide whether an ordinary page-level field group stays flat or receives a perimeter; plain remains reserved for a plane already owned by its parent.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final comparisonWidth = constraints.maxWidth >= 720
                ? (constraints.maxWidth - CatchSpacing.s4) / 2
                : constraints.maxWidth.clamp(0, _componentWidth).toDouble();
            return Wrap(
              spacing: CatchSpacing.s4,
              runSpacing: CatchSpacing.s5,
              children: [
                _sectionHeaderComparison(
                  context,
                  width: comparisonWidth,
                  label: 'Divided · page group',
                  description:
                      'Recommended default: type and hairlines provide hierarchy without adding another object.',
                  child: CatchSection.fieldRows(
                    title: 'Event settings',
                    children: _eventSettingRows(),
                  ),
                ),
                _sectionHeaderComparison(
                  context,
                  width: comparisonWidth,
                  label: 'Contained · bounded object',
                  description:
                      'Use when the fields are perceived and acted on as one discrete object.',
                  child: CatchSection.containedFieldRows(
                    title: 'Event settings',
                    children: _eventSettingRows(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Geometry matrix',
  type: CatchButton,
  path: '[Geometry system]',
)
Widget buttonGeometryMatrix(BuildContext context) {
  return _geometryPage(
    context,
    title: 'Buttons',
    contractIds: const ['catch.button', 'catch.icon_button'],
    principles: const [
      'Hierarchy changes color and border treatment, not the pill silhouette.',
      'Size changes preserve optical centering and minimum target intent.',
      'Loading and disabled states do not reflow the surrounding composition.',
    ],
    children: [
      _specimen(
        context,
        label: 'Hierarchy variants',
        child: Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CatchButton(label: 'Primary', onPressed: _noop),
            CatchButton(
              label: 'Secondary',
              variant: CatchButtonVariant.secondary,
              onPressed: _noop,
            ),
            CatchButton(
              label: 'Ghost',
              variant: CatchButtonVariant.ghost,
              onPressed: _noop,
            ),
            CatchButton(
              label: 'Danger',
              variant: CatchButtonVariant.danger,
              onPressed: _noop,
            ),
            CatchButton(
              label: 'Light',
              variant: CatchButtonVariant.light,
              onPressed: _noop,
            ),
          ],
        ),
      ),
      _specimen(
        context,
        label: 'Size ladder',
        child: Wrap(
          spacing: CatchSpacing.s4,
          runSpacing: CatchSpacing.s3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CatchButton(
              label: 'Small',
              size: CatchButtonSize.sm,
              onPressed: _noop,
            ),
            CatchButton(
              label: 'Medium',
              size: CatchButtonSize.md,
              onPressed: _noop,
            ),
            CatchButton(
              label: 'Large',
              size: CatchButtonSize.lg,
              onPressed: _noop,
            ),
          ],
        ),
      ),
      _specimen(
        context,
        label: 'State stability',
        child: Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const CatchButton(label: 'Disabled', onPressed: null),
            CatchButton(label: 'Loading', isLoading: true, onPressed: _noop),
            CatchButton(
              label: 'With icon',
              icon: Icon(CatchIcons.calendarAdd),
              onPressed: _noop,
            ),
          ],
        ),
      ),
      _specimen(
        context,
        label: 'Composition width',
        description:
            'Full-width actions fill their owner without becoming taller than the selected size token.',
        child: SizedBox(
          width: _componentWidth,
          child: CatchButton(
            label: 'Continue',
            size: CatchButtonSize.lg,
            fullWidth: true,
            onPressed: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Geometry matrix',
  type: CatchTopBar,
  path: '[Geometry system]',
)
Widget topBarGeometryMatrix(BuildContext context) {
  return _geometryPage(
    context,
    title: 'Top bars',
    contractIds: const ['catch.top_bar'],
    principles: const [
      'The primitive owns safe area, height, gutter, leading, and action lanes.',
      'Compact route and large editorial modes retain one alignment system.',
      'Search morphs inside the existing bar instead of replacing its row.',
    ],
    children: [
      _topBarSpecimen(
        context,
        label: 'Compact route',
        child: CatchTopBar(
          title: 'Event details',
          leadingType: CatchTopBarLeading.back,
          onBack: _noop,
        ),
      ),
      _topBarSpecimen(
        context,
        label: 'Large editorial',
        child: const CatchTopBar(
          kicker: 'HOST MODE',
          title: 'Upcoming events',
          subtitle: 'Review requests and keep the room balanced.',
        ),
      ),
      _topBarSpecimen(
        context,
        label: 'Identity and overflow',
        child: CatchTopBar.identity(
          identityName: 'Taylor from Sunday Social',
          identityPhotoUrl: null,
          onIdentityTap: _noop,
          surface: true,
          border: true,
          actions: [
            CatchActionMenu<String>(
              tooltip: 'Conversation actions',
              onSelected: _ignoreString,
              items: [
                CatchActionMenuItem(value: 'share', label: 'Share card'),
                CatchActionMenuItem(
                  value: 'block',
                  label: 'Block',
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
      _topBarSpecimen(
        context,
        label: 'Expanding search',
        description:
            'Use the search action to inspect the in-place width morph and title fade.',
        child: CatchTopBar(
          title: 'Explore',
          search: CatchTopBarSearch(
            value: '',
            placeholder: 'Search events and organizers',
            tooltip: 'Search Explore',
            onChanged: _ignoreString,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Geometry matrix',
  type: CatchTabBar,
  path: '[Geometry system]',
)
Widget bottomNavigationGeometryMatrix(BuildContext context) {
  final items = _navigationItems;

  return _geometryPage(
    context,
    title: 'Bottom navigation',
    contractIds: const ['catch.tab_bar'],
    principles: const [
      'Destinations share one selection indicator and equal destination lanes.',
      'Platform adaptation changes the outer chrome, not destination identity.',
      'Safe-area space belongs to navigation rather than each screen body.',
    ],
    children: [
      _specimen(
        context,
        label: 'Anchored Material chrome',
        child: SizedBox(
          width: _phoneWidth,
          child: Theme(
            data: Theme.of(context).copyWith(platform: TargetPlatform.android),
            child: CatchTabBar<String>(
              items: items,
              active: 'explore',
              onChanged: _ignoreString,
            ),
          ),
        ),
      ),
      _specimen(
        context,
        label: 'Floating Cupertino chrome',
        description:
            'The same destinations move into a floating plane with navigation-owned bottom clearance.',
        child: SizedBox(
          width: _phoneWidth,
          child: Theme(
            data: Theme.of(context).copyWith(platform: TargetPlatform.iOS),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(bottom: CatchSpacing.s6),
              ),
              child: CatchTabBar<String>(
                items: items,
                active: 'chats',
                onChanged: _ignoreString,
              ),
            ),
          ),
        ),
      ),
      _specimen(
        context,
        label: 'Large text',
        description:
            'Destination geometry reflows within the navigation owner at text scale 2.0.',
        child: SizedBox(
          width: _phoneWidth,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: CatchTabBar<String>(
              items: items,
              active: 'home',
              onChanged: _ignoreString,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Geometry matrix',
  type: CatchMenu,
  path: '[Geometry system]',
)
Widget menuGeometryMatrix(BuildContext context) {
  return _geometryPage(
    context,
    title: 'Menus',
    contractIds: const ['catch.menu'],
    principles: const [
      'The menu is a plane change; rows inside return to flat geometry.',
      'Commands and mutually exclusive choices share row metrics but not semantics.',
      'Anchoring and viewport clearance belong to the shared menu boundary.',
    ],
    children: [
      _specimen(
        context,
        label: 'Panel anatomy',
        child: CatchMenu<String>(
          width: CatchLayout.actionMenuWidth,
          onSelected: (value, _) => _ignoreString(value),
          items: [
            CatchMenuItem(
              value: 'share',
              label: 'Share event',
              sublabel: 'Send the event link',
              icon: CatchIcons.iosShareRounded,
            ),
            CatchMenuItem(
              value: 'going',
              label: 'Going',
              selected: true,
              role: CatchMenuItemRole.choice,
              icon: CatchIcons.checkCircle,
              startsSection: true,
            ),
            CatchMenuItem(
              value: 'host',
              label: 'Host controls',
              sublabel: 'Unavailable for guests',
              enabled: false,
              icon: CatchIcons.lockOutlineRounded,
            ),
            CatchMenuItem(
              value: 'remove',
              label: 'Remove from event',
              danger: true,
              icon: CatchIcons.deleteOutline,
            ),
          ],
        ),
      ),
      _specimen(
        context,
        label: 'Anchored command menu',
        description:
            'Open the trigger to inspect anchor alignment, flipping, and viewport clearance.',
        child: CatchActionMenu<String>(
          tooltip: 'Event actions',
          onSelected: _ignoreString,
          items: [
            CatchActionMenuItem(value: 'share', label: 'Share event'),
            CatchActionMenuItem(value: 'duplicate', label: 'Duplicate event'),
            CatchActionMenuItem(
              value: 'cancel',
              label: 'Cancel event',
              isDestructive: true,
            ),
          ],
        ),
      ),
      _specimen(
        context,
        label: 'Adaptive selection',
        description:
            'The same choice model opens as a compact sheet or an anchored wider-layout menu.',
        child: CatchAdaptiveSelectionControl<String>(
          title: 'Sort customers',
          subtitle: 'Choose how customers are ordered.',
          tooltip: 'Sort customers',
          value: 'last-seen',
          items: const [
            CatchSelectionMenuItem(value: 'last-seen', label: 'Last seen'),
            CatchSelectionMenuItem(
              value: 'most-attended',
              label: 'Most attended',
            ),
            CatchSelectionMenuItem(value: 'name', label: 'Name'),
          ],
          triggerLabel: (item) => 'Sort: ${item.label}',
          onSelected: _ignoreString,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Geometry matrix',
  type: CatchBottomSheetScaffold,
  path: '[Geometry system]',
)
Widget modalGeometryMatrix(BuildContext context) {
  return _geometryPage(
    context,
    title: 'Sheets and dialogs',
    contractIds: const [
      'catch.sheet',
      'catch.confirm_dialog',
      'catch.form_dialog',
    ],
    principles: const [
      'Modals establish a new plane; their internal fields and actions remain flat.',
      'Sheets own viewport edges, safe area, keyboard clearance, and top radii.',
      'Dialogs own a bounded centered silhouette and action reflow.',
    ],
    children: [
      _specimen(
        context,
        label: 'Live presentations',
        description:
            'Launch the real presenters to inspect scrim, viewport, safe-area, and dismissal behavior.',
        child: Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            CatchButton(
              label: 'Open sheet',
              onPressed: () => showCatchBottomSheet<void>(
                context: context,
                useRootNavigator: false,
                builder: (_) => CatchBottomSheetScaffold(
                  title: 'Invite guests',
                  subtitle: 'Share this event with people who fit the format.',
                  action: CatchButton(
                    label: 'Copy invite link',
                    fullWidth: true,
                    onPressed: _noop,
                  ),
                  child: const Text('Invites close at 6 PM.'),
                ),
              ),
            ),
            CatchButton(
              label: 'Open dialog',
              variant: CatchButtonVariant.secondary,
              onPressed: () => showCatchAdaptiveDialog<bool>(
                context: context,
                title: 'Join this event?',
                message:
                    'Your profile and first name will be shared with the host.',
                actions: const [
                  CatchDialogAction(label: 'Cancel', value: false),
                  CatchDialogAction(
                    label: 'Join',
                    value: true,
                    isDefault: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _specimen(
        context,
        label: 'Sheet composition',
        child: SizedBox(
          width: _phoneWidth,
          child: CatchBottomSheetScaffold(
            title: 'Arrival note',
            subtitle: 'Tell guests where to meet.',
            keyboardSafe: true,
            action: CatchButton(
              label: 'Save note',
              fullWidth: true,
              onPressed: _noop,
            ),
            child: const CatchField.input(
              title: 'Note',
              initialValue: 'Meet beside the cafe entrance.',
            ),
          ),
        ),
      ),
      _specimen(
        context,
        label: 'Dialog composition',
        child: CatchConfirmDialog<bool>(
          title: 'Cancel this event?',
          message: 'Guests will be notified immediately.',
          actions: const [
            CatchDialogAction(label: 'Keep event', value: false),
            CatchDialogAction(
              label: 'Cancel event',
              value: true,
              isDestructive: true,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _sectionHeaderComparison(
  BuildContext context, {
  required double width,
  required String label,
  required String description,
  required Widget child,
}) {
  final t = CatchTokens.of(context);

  return SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: CatchTextStyles.labelL(context, color: t.ink)),
        const SizedBox(height: CatchSpacing.s1),
        Text(
          description,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        const SizedBox(height: CatchSpacing.s3),
        child,
      ],
    ),
  );
}

List<Widget> _eventSettingRows() => [
  CatchField.read(title: 'Host', body: 'Catch Hosts', icon: CatchIcons.hosted),
  CatchField.nav(
    title: 'Location',
    body: 'Carter Road promenade',
    icon: CatchIcons.pinOutlined,
    onTap: _noop,
  ),
  CatchField.toggle(
    title: 'Allow reminders',
    body: 'Push and email',
    icon: CatchIcons.notificationsOutlined,
    value: true,
    onChanged: _ignoreBool,
  ),
];

Widget _geometryPage(
  BuildContext context, {
  required String title,
  required List<String> contractIds,
  required List<String> principles,
  required List<Widget> children,
}) {
  final t = CatchTokens.of(context);

  return ColoredBox(
    color: t.bg,
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CatchSpacing.s6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _reviewWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: CatchTextStyles.headline(context)),
                const SizedBox(height: CatchSpacing.s2),
                Text(
                  contractIds.join(' · '),
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                const SizedBox(height: CatchSpacing.s4),
                Text(
                  'Comparative geometry only. Use each component’s Contract states page for the exhaustive API and state inventory.',
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                const SizedBox(height: CatchSpacing.s4),
                for (final principle in principles) ...[
                  Text(
                    '— $principle',
                    style: CatchTextStyles.supporting(context),
                  ),
                  const SizedBox(height: CatchSpacing.s1),
                ],
                const SizedBox(height: CatchSpacing.s6),
                for (final indexed in children.indexed) ...[
                  if (indexed.$1 > 0) const SizedBox(height: CatchSpacing.s5),
                  indexed.$2,
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _specimen(
  BuildContext context, {
  required String label,
  required Widget child,
  String? description,
}) {
  final t = CatchTokens.of(context);

  return DecoratedBox(
    decoration: BoxDecoration(
      color: t.surface,
      border: Border.all(color: t.line),
      borderRadius: BorderRadius.circular(CatchRadius.lg),
    ),
    child: Padding(
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CatchTextStyles.titleL(context)),
          if (description != null) ...[
            const SizedBox(height: CatchSpacing.s1),
            Text(
              description,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          const SizedBox(height: CatchSpacing.s4),
          child,
        ],
      ),
    ),
  );
}

Widget _topBarSpecimen(
  BuildContext context, {
  required String label,
  required PreferredSizeWidget child,
  String? description,
}) {
  final t = CatchTokens.of(context);

  return _specimen(
    context,
    label: label,
    description: description,
    child: CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      width: _phoneWidth,
      child: child,
    ),
  );
}

const _reviewWidth = 960.0;
const _componentWidth = 420.0;
const _phoneWidth = 390.0;

final _navigationItems = <CatchTabBarItem<String>>[
  CatchTabBarItem(
    id: 'home',
    icon: CatchIcons.homeOutlined,
    activeIcon: CatchIcons.homeRounded,
    label: 'Home',
  ),
  CatchTabBarItem(
    id: 'explore',
    icon: CatchIcons.groupsOutlined,
    activeIcon: CatchIcons.groupsRounded,
    label: 'Explore',
  ),
  CatchTabBarItem(
    id: 'chats',
    icon: CatchIcons.chatBubbleOutlineRounded,
    activeIcon: CatchIcons.chatBubbleRounded,
    label: 'Chats',
    badgeCount: 3,
  ),
  CatchTabBarItem(
    id: 'you',
    icon: CatchIcons.personOutlined,
    activeIcon: CatchIcons.personRounded,
    label: 'You',
  ),
];

void _noop() {}

void _ignoreBool(bool _) {}

void _ignoreString(String _) {}

void _ignoreStrings(Set<String> _) {}
