import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_journey_steps.dart';
import 'package:catch_dating_app/core/widgets/catch_option_card.dart';
import 'package:catch_dating_app/core/widgets/catch_privacy_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchBadge,
  path: '[Core primitives]/Status',
)
Widget catchBadgeContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchBadge',
    contractId: 'catch.badge',
    states: const ['default', 'live', 'with-icon', 'truncated'],
    children: [
      _StateCard(
        label: 'default',
        child: _InlineWrap(
          children: const [
            CatchBadge(label: 'Queued'),
            CatchBadge(label: 'Brand', tone: CatchBadgeTone.brand),
            CatchBadge(label: 'Gold', tone: CatchBadgeTone.gold),
            CatchBadge(label: 'Action', size: CatchBadgeSize.action),
          ],
        ),
      ),
      _StateCard(
        label: 'live',
        child: const CatchBadge(label: 'Live now', tone: CatchBadgeTone.live),
      ),
      _StateCard(
        label: 'with-icon',
        child: CatchBadge(
          label: 'Verified',
          tone: CatchBadgeTone.success,
          icon: CatchIcons.checkCircle,
        ),
      ),
      _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: 124,
          child: CatchBadge(
            label: 'Very long review pending label',
            tone: CatchBadgeTone.warning,
            icon: CatchIcons.infoOutlineRounded,
            borderColor: t.warning,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchButton,
  path: '[Core primitives]/Actions',
)
Widget catchButtonContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchButton',
    contractId: 'catch.button',
    states: const [
      'default',
      'pressed',
      'hovered',
      'disabled',
      'loading',
      'full-width',
      'with-icon',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: _InlineWrap(
          children: [
            CatchButton(label: 'Continue', onPressed: _noop),
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
          ],
        ),
      ),
      _StateCard(
        label: 'pressed / hovered',
        description: 'Hover or press this target to review transient overlays.',
        child: CatchButton(
          label: 'Interactive target',
          accentColor: t.like,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: const CatchButton(label: 'Unavailable', onPressed: null),
      ),
      _StateCard(
        label: 'loading',
        child: CatchButton(label: 'Joining', isLoading: true, onPressed: _noop),
      ),
      _StateCard(
        label: 'full-width',
        child: CatchButton(
          label: 'Create event',
          fullWidth: true,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'with-icon',
        child: CatchButton(
          label: 'Add to calendar',
          icon: Icon(CatchIcons.calendarAdd),
          onPressed: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchChip,
  path: '[Core primitives]/Selection',
)
Widget catchChipContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchChip',
    contractId: 'catch.chip',
    states: const [
      'default',
      'active',
      'disabled',
      'with-icon',
      'removable',
      'activity-tinted',
    ],
    children: [
      _StateCard(
        label: 'default',
        child: _InlineWrap(
          children: [
            CatchChip(label: 'Tonight', onTap: _noop),
            CatchChip(label: 'Low key', onTap: _noop),
          ],
        ),
      ),
      _StateCard(
        label: 'active',
        child: CatchChip(label: 'Selected', active: true, onTap: _noop),
      ),
      _StateCard(
        label: 'disabled',
        child: const CatchChip(label: 'Sold out', enabled: false),
      ),
      _StateCard(
        label: 'with-icon',
        child: CatchChip(
          label: 'Weekend',
          icon: Icon(CatchIcons.weekend),
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'removable',
        child: CatchChip(
          label: 'Rooftop',
          icon: Icon(CatchIcons.pinOutlined),
          onRemove: _noop,
        ),
      ),
      _StateCard(
        label: 'activity-tinted',
        child: CatchChip(
          label: 'Run club',
          tintColor: t.like.withValues(alpha: CatchOpacity.subtleFill),
          inkColor: t.like,
          icon: Icon(CatchIcons.directionsRunRounded),
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchField,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchField',
    contractId: 'catch.field',
    states: const [
      'read',
      'edit',
      'nav',
      'toggle',
      'expanded-control',
      'error',
      'focused',
      'add',
    ],
    children: [
      _StateCard(
        label: 'read',
        child: _FieldWidth(
          child: CatchField(
            label: 'Host',
            value: 'Catch Hosts',
            icon: CatchIcons.hosted,
            mode: CatchFieldMode.read,
          ),
        ),
      ),
      _StateCard(
        label: 'edit',
        child: _FieldWidth(
          child: CatchField(
            label: 'Event name',
            initialValue: 'Thursday social run',
            icon: CatchIcons.eventOutlined,
            mode: CatchFieldMode.edit,
          ),
        ),
      ),
      _StateCard(
        label: 'nav',
        child: _FieldWidth(
          child: CatchField(
            label: 'Location',
            value: 'Fort Greene Park',
            icon: CatchIcons.pinOutlined,
            mode: CatchFieldMode.nav,
            showChevron: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(label: 'toggle', child: const _ToggleFieldDemo()),
      _StateCard(
        label: 'expanded-control',
        child: _FieldWidth(
          child: CatchField(
            label: 'Capacity',
            value: '24 seats',
            icon: CatchIcons.group,
            mode: CatchFieldMode.nav,
            initiallyExpanded: true,
            control: _InlineWrap(
              children: [
                CatchChip(label: '16', onTap: _noop),
                CatchChip(label: '24', active: true, onTap: _noop),
                CatchChip(label: '32', onTap: _noop),
              ],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'error',
        child: _FieldWidth(
          child: CatchField(
            label: 'Invite code',
            initialValue: 'ABC',
            icon: CatchIcons.keyOutlined,
            mode: CatchFieldMode.edit,
            error: 'Use a six character invite code.',
          ),
        ),
      ),
      _StateCard(
        label: 'focused',
        child: const _FieldWidth(
          child: CatchField(
            label: 'Handle',
            initialValue: 'catch-hosts',
            leadingUnit: '@',
            mode: CatchFieldMode.edit,
            autofocus: true,
          ),
        ),
      ),
      _StateCard(
        label: 'add',
        child: _FieldWidth(
          child: CatchField(
            label: 'Add another time',
            icon: CatchIcons.add,
            add: true,
            onTap: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchFieldGroup,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldGroupContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchFieldGroup',
    contractId: 'catch.field_group',
    states: const [
      'stacked-fields',
      'mixed-modes',
      'single-child',
      'long-copy',
    ],
    children: [
      _StateCard(
        label: 'stacked-fields',
        child: _FieldWidth(
          child: CatchFieldGroup(
            children: [
              CatchField(
                label: 'Host',
                value: 'Catch Hosts',
                icon: CatchIcons.hosted,
                mode: CatchFieldMode.read,
              ),
              CatchField(
                label: 'Visibility',
                value: 'Private to attendees',
                icon: CatchIcons.lockOutlineRounded,
                mode: CatchFieldMode.nav,
                onTap: _noop,
              ),
              CatchField(
                label: 'Allow reminders',
                value: 'Push and email',
                icon: CatchIcons.notificationsOutlined,
                mode: CatchFieldMode.toggle,
                toggled: true,
                onToggle: (_) {},
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'mixed-modes',
        child: _FieldWidth(
          child: CatchFieldGroup(
            children: [
              CatchField(
                label: 'Display name',
                initialValue: 'Suvrat',
                icon: CatchIcons.personOutlined,
                mode: CatchFieldMode.edit,
              ),
              CatchField(
                label: 'Invite code',
                initialValue: 'ABC',
                icon: CatchIcons.keyOutlined,
                mode: CatchFieldMode.edit,
                error: 'Use a six character invite code.',
              ),
              CatchField(
                label: 'Add another time',
                icon: CatchIcons.add,
                add: true,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'single-child',
        child: _FieldWidth(
          child: CatchFieldGroup(
            children: [
              CatchField(
                label: 'Event type',
                value: 'Dinner',
                icon: CatchIcons.dinner,
                mode: CatchFieldMode.read,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 360,
          child: CatchFieldGroup(
            children: [
              CatchField(
                label: 'Long public field label that should wrap cleanly',
                value:
                    'A very long value that needs to wrap without breaking the row group surface.',
                icon: CatchIcons.infoOutlineRounded,
                mode: CatchFieldMode.read,
              ),
              CatchField(
                label: 'Detailed location',
                value: 'The east entrance by the fountain near the market',
                icon: CatchIcons.pinOutlined,
                mode: CatchFieldMode.nav,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchIconButton,
  path: '[Core primitives]/Actions',
)
Widget catchIconButtonContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchIconButton',
    contractId: 'catch.icon_button',
    states: const [
      'default',
      'active',
      'disabled',
      'bordered',
      'float',
      'plain',
    ],
    children: [
      _StateCard(
        label: 'default / bordered',
        child: _InlineWrap(
          children: [
            CatchIconButton.icon(icon: CatchIcons.search, onTap: _noop),
            CatchIconButton.icon(
              icon: CatchIcons.notificationsOutlined,
              onTap: _noop,
            ),
            CatchIconButton.icon(
              icon: CatchIcons.moreHorizRounded,
              onTap: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'active',
        child: CatchIconButton.icon(
          icon: CatchIcons.checkCircle,
          active: true,
          accent: t.like,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: CatchIconButton.icon(
          icon: CatchIcons.close,
          disabled: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'float',
        child: _PhotoLikePanel(
          child: CatchIconButton.icon(
            icon: CatchIcons.close,
            variant: CatchIconButtonVariant.float,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'plain',
        child: CatchIconButton.icon(
          icon: CatchIcons.tuneRounded,
          variant: CatchIconButtonVariant.plain,
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchOptionCard,
  path: '[Core primitives]/Selection',
)
Widget catchOptionCardContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchOptionCard',
    contractId: 'catch.option_card',
    states: const ['default', 'selected', 'disabled-by-null-action'],
    children: [
      _StateCard(
        label: 'default',
        child: _OptionWidth(
          child: CatchOptionCard(
            title: 'Casual',
            description: 'Low commitment attendance with flexible arrival.',
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'selected',
        child: _OptionWidth(
          child: CatchOptionCard(
            title: 'Curated',
            description: 'Host approves each request before the event.',
            selected: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'disabled-by-null-action',
        child: const _OptionWidth(
          child: CatchOptionCard(
            title: 'Application only',
            description: 'Visible but not currently selectable.',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSegmentedControl,
  path: '[Core primitives]/Selection',
)
Widget catchSegmentedControlContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSegmentedControl',
    contractId: 'catch.segmented_control',
    states: const [
      'default',
      'selected',
      'expanded',
      'with-icons',
      'surface-style',
    ],
    children: [
      _StateCard(
        label: 'default / selected',
        child: _SegmentedControlDemo<String>(
          initialValue: 'day',
          segments: const [
            CatchSegment(value: 'day', label: 'Day'),
            CatchSegment(value: 'agenda', label: 'Agenda'),
            CatchSegment(value: 'list', label: 'List'),
          ],
        ),
      ),
      _StateCard(
        label: 'expanded',
        child: const _SegmentedWidth(
          child: _SegmentedControlDemo<String>(
            initialValue: 'hosts',
            expanded: true,
            segments: [
              CatchSegment(value: 'hosts', label: 'Hosts'),
              CatchSegment(value: 'guests', label: 'Guests'),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'with-icons',
        child: _SegmentedControlDemo<String>(
          initialValue: 'grid',
          segments: [
            CatchSegment(
              value: 'grid',
              label: 'Grid',
              icon: CatchIcons.gridViewRounded,
            ),
            CatchSegment(
              value: 'list',
              label: 'List',
              icon: CatchIcons.listRounded,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'surface-style',
        child: const _SegmentedControlDemo<String>(
          initialValue: 'now',
          style: CatchSegmentedControlStyle.surface,
          segments: [
            CatchSegment(value: 'now', label: 'Now'),
            CatchSegment(value: 'later', label: 'Later'),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSurface,
  path: '[Core primitives]/Surfaces',
)
Widget catchSurfaceContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchSurface',
    contractId: 'catch.surface',
    states: const [
      'surface',
      'raised',
      'primary-soft',
      'transparent',
      'tappable',
      'elevated',
    ],
    children: [
      _StateCard(
        label: 'surface',
        child: _SurfaceSpec(tone: CatchSurfaceTone.surface),
      ),
      _StateCard(
        label: 'raised',
        child: _SurfaceSpec(tone: CatchSurfaceTone.raised),
      ),
      _StateCard(
        label: 'primary-soft',
        child: _SurfaceSpec(tone: CatchSurfaceTone.primarySoft),
      ),
      _StateCard(
        label: 'transparent',
        child: _PhotoLikePanel(
          child: _SurfaceSpec(
            tone: CatchSurfaceTone.transparent,
            borderColor: t.surface,
            foregroundColor: t.surface,
          ),
        ),
      ),
      _StateCard(
        label: 'tappable',
        child: _SurfaceSpec(tone: CatchSurfaceTone.surface, onTap: _noop),
      ),
      _StateCard(
        label: 'elevated',
        child: const _InlineWrap(
          children: [
            _SurfaceSpec(label: 'Card', elevation: CatchSurfaceElevation.card),
            _SurfaceSpec(
              label: 'Raised',
              elevation: CatchSurfaceElevation.raised,
            ),
            _SurfaceSpec(
              label: 'Overlay',
              elevation: CatchSurfaceElevation.overlay,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTextField,
  path: '[Core primitives]/Inputs',
)
Widget catchTextFieldContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchTextField',
    contractId: 'catch.text_field',
    states: const [
      'empty',
      'filled',
      'focused',
      'disabled',
      'read-only',
      'error',
      'helper',
      'multiline',
      'clearable',
    ],
    children: [
      _StateCard(
        label: 'empty',
        child: const _FieldWidth(
          child: CatchTextField(label: 'Name', hintText: 'Add a public name'),
        ),
      ),
      _StateCard(
        label: 'filled',
        child: const _FieldWidth(
          child: CatchTextField(
            label: 'Club',
            initialValue: 'Fort Greene Run Club',
          ),
        ),
      ),
      _StateCard(
        label: 'focused',
        child: _FieldWidth(
          child: CatchTextField(
            label: 'Search',
            initialValue: 'social run',
            focused: true,
            prefixIcon: Icon(CatchIcons.search),
          ),
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: const _FieldWidth(
          child: CatchTextField(
            label: 'Email',
            initialValue: 'team@catch.events',
            enabled: false,
          ),
        ),
      ),
      _StateCard(
        label: 'read-only',
        child: const _FieldWidth(
          child: CatchTextField(
            label: 'Handle',
            initialValue: '@catch-hosts',
            readOnly: true,
          ),
        ),
      ),
      _StateCard(
        label: 'error',
        child: const _FieldWidth(
          child: CatchTextField(
            label: 'Capacity',
            initialValue: '0',
            errorText: 'Capacity must be at least 2.',
            keyboardType: TextInputType.number,
          ),
        ),
      ),
      _StateCard(
        label: 'helper',
        child: const _FieldWidth(
          child: CatchTextField(
            label: 'Invite note',
            helperText: 'Shown before guests request a spot.',
            helperTone: CatchTextFieldSupportTone.brand,
          ),
        ),
      ),
      _StateCard(
        label: 'multiline',
        child: const _FieldWidth(
          child: CatchTextField(
            label: 'Description',
            initialValue:
                'Meet by the fountain, then we will head out together.',
            maxLines: 4,
            minLines: 3,
          ),
        ),
      ),
      _StateCard(
        label: 'clearable',
        child: _FieldWidth(
          child: CatchTextField(
            label: 'Search hosts',
            initialValue: 'Run',
            showClearButton: true,
            suffixIcon: Icon(CatchIcons.search),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTopBar,
  path: '[Core primitives]/Navigation',
)
Widget catchTopBarContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchTopBar',
    contractId: 'catch.top_bar',
    states: const [
      'compact',
      'large',
      'with-leading',
      'with-action-icon',
      'with-action-text',
      'with-search',
      'surface',
      'bordered',
    ],
    children: [
      _StateCard(
        label: 'compact',
        child: const _TopBarFrame(
          child: CatchTopBar(title: 'Events', subtitle: 'Tonight nearby'),
        ),
      ),
      _StateCard(
        label: 'large',
        child: const _TopBarFrame(
          child: CatchTopBar(
            kicker: 'HOST MODE',
            title: 'Upcoming events',
            subtitle: 'Review requests and keep the room balanced.',
          ),
        ),
      ),
      _StateCard(
        label: 'with-leading',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Event details',
            leadingType: CatchTopBarLeading.back,
            onBack: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-action-icon',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Chats',
            actionIcon: CatchIcons.moreHorizRounded,
            actionLabel: 'More',
            onAction: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-action-text',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Preview',
            actionText: 'Done',
            onAction: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with-search',
        description: 'Use the search icon to review the expanded search state.',
        child: _TopBarFrame(
          child: CatchTopBar(
            title: 'Clubs',
            searchValue: 'run',
            searchPlaceholder: 'Search clubs',
            onSearch: _ignoreString,
          ),
        ),
      ),
      _StateCard(
        label: 'surface',
        child: const _TopBarFrame(
          child: CatchTopBar(title: 'Surface', surface: true),
        ),
      ),
      _StateCard(
        label: 'bordered',
        child: const _TopBarFrame(
          child: CatchTopBar(title: 'Bordered', border: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPrivacyBadge,
  path: '[Core primitives]/Status',
)
Widget catchPrivacyBadgeContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchPrivacyBadge',
    contractId: 'catch.privacy_badge',
    states: const ['private-to-you', 'catch-private', 'host-visible'],
    children: [
      _StateCard(label: 'private-to-you', child: CatchPrivacyBadge()),
      _StateCard(
        label: 'catch-private',
        child: CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.catchPrivate),
      ),
      _StateCard(
        label: 'host-visible',
        child: CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.host),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchJourneySteps,
  path: '[Core primitives]/Sections',
)
Widget catchJourneyStepsContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return _ContractScreen(
    title: 'CatchJourneySteps',
    contractId: 'catch.journey_steps',
    states: const ['numbered-trace', 'titles-only', 'accented', 'long-copy'],
    children: [
      const _StateCard(
        label: 'numbered-trace',
        child: CatchJourneySteps(
          steps: [
            CatchJourneyStep(
              title: 'Pick your room',
              body: 'Choose the event format and guest count.',
            ),
            CatchJourneyStep(
              title: 'Confirm the guest list',
              body: 'Review attendance, private access, and reminders.',
            ),
            CatchJourneyStep(
              title: 'Host the moment',
              body: 'Use check-in and post-event tools from the same flow.',
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'titles-only',
        child: CatchJourneySteps(
          accent: t.success,
          steps: const [
            CatchJourneyStep(title: 'Arrive'),
            CatchJourneyStep(title: 'Check in'),
            CatchJourneyStep(title: 'Start matching'),
          ],
        ),
      ),
      _StateCard(
        label: 'accented',
        child: CatchJourneySteps(
          accent: t.like,
          steps: const [
            CatchJourneyStep(
              title: 'Open requests',
              body: 'Let the host approve a balanced room.',
            ),
            CatchJourneyStep(
              title: 'Send reminders',
              body: 'Guests receive the final timing and arrival notes.',
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'long-copy',
        child: SizedBox(
          width: 360,
          child: CatchJourneySteps(
            steps: [
              CatchJourneyStep(
                title:
                    'A longer step title that should wrap without pushing the trace out of alignment',
                body:
                    'Long supporting copy stays in the content column while the numbered rail keeps a stable width.',
              ),
              CatchJourneyStep(
                title: 'A concise final step',
                body: 'The trace ends without a dangling connector.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchScreenBody,
  path: '[Core primitives]/Sections',
)
Widget catchScreenBodyContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchScreenBody',
    contractId: 'catch.screen_body',
    states: const [
      'scrolling-gutter',
      'non-scroll',
      'no-gutter',
      'custom-padding',
    ],
    children: [
      _StateCard(
        label: 'scrolling-gutter',
        child: _BodyFrame(
          child: CatchScreenBody(
            child: CatchSectionList(
              gap: CatchGaps.section,
              children: const [
                _BodySpec(label: 'Top section'),
                _BodySpec(label: 'Scrollable body content'),
                _BodySpec(label: 'Bottom padding remains tokenized'),
              ],
            ),
          ),
        ),
      ),
      const _StateCard(
        label: 'non-scroll',
        child: _BodyFrame(
          child: CatchScreenBody(
            scrollable: false,
            child: _BodySpec(label: 'Static body with standard gutter'),
          ),
        ),
      ),
      const _StateCard(
        label: 'no-gutter',
        child: _BodyFrame(
          child: CatchScreenBody(
            gutter: false,
            scrollable: false,
            pt: 0,
            pb: 0,
            child: _BodySpec(label: 'Embedded body without page gutter'),
          ),
        ),
      ),
      const _StateCard(
        label: 'custom-padding',
        child: _BodyFrame(
          child: CatchScreenBody(
            scrollable: false,
            padding: EdgeInsets.all(CatchSpacing.s4),
            child: _BodySpec(label: 'Body with explicit inset override'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchSectionStack,
  path: '[Core primitives]/Sections',
)
Widget catchSectionStackContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchSectionStack',
    contractId: 'catch.section_stack',
    states: const [
      'handoff-sections',
      'plain-sections',
      'custom-gap',
      'zero-padding',
    ],
    children: [
      const _StateCard(
        label: 'handoff-sections',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          children: [
            CatchDesignSection(
              first: true,
              lead: true,
              kicker: 'Room',
              count: 2,
              child: _BodySpec(label: 'Lead section keeps no top rule.'),
            ),
            CatchDesignSection(
              kicker: 'Guests',
              count: 24,
              child: _BodySpec(label: 'Next sections own the divider.'),
            ),
            CatchDesignSection(
              kicker: 'Follow up',
              child: _BodySpec(label: 'No ad-hoc gaps needed.'),
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'plain-sections',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          children: [
            _BodySpec(label: 'First plain section block'),
            _BodySpec(label: 'Second block follows stack rhythm'),
          ],
        ),
      ),
      const _StateCard(
        label: 'custom-gap',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          gap: CatchSpacing.s3,
          children: [
            _BodySpec(label: 'First block'),
            _BodySpec(label: 'Second block with explicit gap'),
          ],
        ),
      ),
      const _StateCard(
        label: 'zero-padding',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          children: [
            CatchFieldGroup(
              children: [
                CatchField(
                  label: 'Nested field',
                  value: 'Section stack can hold contracted primitives.',
                  mode: CatchFieldMode.read,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterTiles,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterTilesContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchRosterTiles',
    contractId: 'catch.roster_tiles',
    states: const ['default', 'selected', 'read-only', 'warning', 'danger'],
    children: [
      _StateCard(
        label: 'default / selected',
        child: CatchRosterTiles(
          selected: 'checked',
          onSelect: _ignoreString,
          items: const [
            CatchRosterTile(id: 'booked', value: '24', label: 'Booked'),
            CatchRosterTile(
              id: 'checked',
              value: '18',
              label: 'Checked',
              tone: CatchBadgeTone.success,
            ),
            CatchRosterTile(
              id: 'waiting',
              value: '5',
              label: 'Waiting',
              tone: CatchBadgeTone.gold,
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'read-only',
        child: CatchRosterTiles(
          selected: 'all',
          items: [
            CatchRosterTile(id: 'all', value: '31', label: 'All'),
            CatchRosterTile(id: 'vip', value: '4', label: 'VIP'),
            CatchRosterTile(id: 'late', value: '2', label: 'Late'),
          ],
        ),
      ),
      const _StateCard(
        label: 'warning / danger',
        child: CatchRosterTiles(
          selected: 'attention',
          items: [
            CatchRosterTile(
              id: 'attention',
              value: '3',
              label: 'Needs help',
              tone: CatchBadgeTone.warning,
            ),
            CatchRosterTile(
              id: 'declined',
              value: '2',
              label: 'Declined',
              tone: CatchBadgeTone.danger,
            ),
            CatchRosterTile(
              id: 'noshow',
              value: '1',
              label: 'No-show',
              tone: CatchBadgeTone.neutral,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterRow,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterRowContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchRosterRow',
    contractId: 'catch.roster_row',
    states: const [
      'button-action',
      'decision-action',
      'badge-action',
      'text-action',
      'empty-signal',
      'disabled-action',
      'truncated',
    ],
    children: [
      _StateCard(
        label: 'button-action',
        child: CatchRosterRow(
          person: 'Aanya Rao',
          meta: 'Paid - arrives 7:40 PM',
          signal: 'Checked in',
          tone: CatchBadgeTone.success,
          action: CatchRosterButtonAction(
            label: 'View',
            icon: CatchIcons.eye,
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'decision-action',
        child: CatchRosterRow(
          person: 'Dev Malhotra',
          meta: 'Request to join - first event',
          signal: 'Review',
          tone: CatchBadgeTone.warning,
          action: CatchRosterDecideAction(
            onProfile: _noop,
            onApprove: _noop,
            onDecline: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'badge-action',
        child: CatchRosterRow(
          person: 'Kabir Mehta',
          meta: 'Guest invite - +1',
          signal: 'Hosted',
          tone: CatchBadgeTone.gold,
          action: CatchRosterBadgeAction(
            label: 'VIP',
            tone: CatchBadgeTone.gold,
          ),
        ),
      ),
      const _StateCard(
        label: 'text-action',
        child: CatchRosterRow(
          person: 'Mira Shah',
          meta: 'Ticket refunded',
          signal: 'Cancelled',
          tone: CatchBadgeTone.danger,
          action: CatchRosterTextAction('Done'),
        ),
      ),
      const _StateCard(
        label: 'empty-signal',
        child: CatchRosterRow(
          person: 'Noor Khan',
          meta: 'Invite pending',
          action: CatchRosterTextAction('Waiting'),
        ),
      ),
      _StateCard(
        label: 'disabled-action',
        child: CatchRosterRow(
          person: 'Naina Bose',
          meta: 'Reminder already sent',
          signal: 'Pending',
          action: CatchRosterButtonAction(
            label: 'Sent',
            disabled: true,
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'truncated',
        child: SizedBox(
          width: 360,
          child: CatchRosterRow(
            person: 'A very long guest name that should ellipsize cleanly',
            meta: 'VIP invite with a very long arrival note and payment status',
            signal: 'Needs help',
            tone: CatchBadgeTone.warning,
            action: CatchRosterButtonAction(label: 'Open', onPressed: _noop),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRosterTable,
  path: '[Core primitives]/Host operations',
)
Widget catchRosterTableContractStates(BuildContext context) {
  return _ContractScreen(
    title: 'CatchRosterTable',
    contractId: 'catch.roster_table',
    states: const ['populated', 'empty', 'partial-columns', 'long-copy'],
    children: [
      _StateCard(
        label: 'populated',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'Aanya Rao',
              meta: 'Paid - checked in 7:42 PM',
              signal: 'Here',
              tone: CatchBadgeTone.success,
              action: CatchRosterButtonAction(
                label: 'Open',
                icon: CatchIcons.eye,
                onPressed: _noop,
              ),
            ),
            CatchRosterRow(
              person: 'Dev Malhotra',
              meta: 'Request to join',
              signal: 'Review',
              tone: CatchBadgeTone.warning,
              action: CatchRosterDecideAction(
                onProfile: _noop,
                onApprove: _noop,
                onDecline: _noop,
              ),
            ),
            const CatchRosterRow(
              person: 'Mira Shah',
              meta: 'Ticket refunded',
              signal: 'Cancelled',
              tone: CatchBadgeTone.danger,
              action: CatchRosterBadgeAction(label: 'Closed'),
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'empty',
        child: CatchRosterTable(
          columns: ['Guest', 'Signal', 'Action'],
          showEmpty: true,
          emptyTitle: 'No guests in this view',
          emptyMessage:
              'Change the roster filter or wait for guests to join this event.',
        ),
      ),
      const _StateCard(
        label: 'partial-columns',
        child: CatchRosterTable(
          columns: ['Guest', 'Signal'],
          rows: [
            CatchRosterRow(
              person: 'Noor Khan',
              meta: 'Invite pending',
              signal: 'Pending',
              action: CatchRosterTextAction('Waiting'),
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'long-copy',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Action'],
          rows: [
            CatchRosterRow(
              person: 'A very long guest name that should ellipsize cleanly',
              meta:
                  'VIP invite with a very long arrival note and payment status',
              signal: 'Needs help',
              tone: CatchBadgeTone.warning,
              action: CatchRosterButtonAction(label: 'Open', onPressed: _noop),
            ),
          ],
        ),
      ),
    ],
  );
}

void _noop() {}

void _ignoreString(String value) {}

class _ContractScreen extends StatelessWidget {
  const _ContractScreen({
    required this.title,
    required this.contractId,
    required this.states,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<String> states;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.bg,
      child: SingleChildScrollView(
        padding: CatchInsets.pageBodyRelaxed,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge(label: contractId, uppercase: true),
                const SizedBox(height: CatchSpacing.s3),
                Text(title, style: CatchTextStyles.headlineS(context)),
                const SizedBox(height: CatchSpacing.s3),
                _InlineWrap(
                  children: [
                    for (final state in states)
                      CatchBadge(
                        label: state,
                        size: CatchBadgeSize.md,
                        tone: CatchBadgeTone.neutral,
                      ),
                  ],
                ),
                const SizedBox(height: CatchSpacing.s6),
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: CatchSpacing.s4),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      radius: CatchRadius.lg,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatchBadge(label: label, uppercase: true),
              if (description != null) ...[
                const SizedBox(width: CatchSpacing.s3),
                Expanded(
                  child: Text(
                    description!,
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          child,
        ],
      ),
    );
  }
}

class _InlineWrap extends StatelessWidget {
  const _InlineWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _FieldWidth extends StatelessWidget {
  const _FieldWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 420, child: child);
  }
}

class _OptionWidth extends StatelessWidget {
  const _OptionWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 360, child: child);
  }
}

class _SegmentedWidth extends StatelessWidget {
  const _SegmentedWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 420, child: child);
  }
}

class _TopBarFrame extends StatelessWidget {
  const _TopBarFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      width: 420,
      child: child,
    );
  }
}

class _PhotoLikePanel extends StatelessWidget {
  const _PhotoLikePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      width: 260,
      height: 132,
      padding: CatchInsets.content,
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.like.withValues(alpha: 0.76),
            t.pass.withValues(alpha: 0.68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: child,
    );
  }
}

class _BodyFrame extends StatelessWidget {
  const _BodyFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _BodySpec extends StatelessWidget {
  const _BodySpec({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Text(label, style: CatchTextStyles.bodyS(context)),
    );
  }
}

class _SegmentedControlDemo<T> extends StatefulWidget {
  const _SegmentedControlDemo({
    required this.initialValue,
    required this.segments,
    this.expanded = false,
    this.style = CatchSegmentedControlStyle.filled,
  });

  final T initialValue;
  final List<CatchSegment<T>> segments;
  final bool expanded;
  final CatchSegmentedControlStyle style;

  @override
  State<_SegmentedControlDemo<T>> createState() =>
      _SegmentedControlDemoState<T>();
}

class _SegmentedControlDemoState<T> extends State<_SegmentedControlDemo<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant _SegmentedControlDemo<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CatchSegmentedControl<T>(
      segments: widget.segments,
      selected: _value,
      expanded: widget.expanded,
      style: widget.style,
      onChanged: (value) => setState(() => _value = value),
    );
  }
}

class _ToggleFieldDemo extends StatefulWidget {
  const _ToggleFieldDemo();

  @override
  State<_ToggleFieldDemo> createState() => _ToggleFieldDemoState();
}

class _ToggleFieldDemoState extends State<_ToggleFieldDemo> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return _FieldWidth(
      child: CatchField(
        label: 'Allow requests',
        value: _enabled ? 'Open' : 'Closed',
        icon: CatchIcons.notificationsOutlined,
        mode: CatchFieldMode.toggle,
        toggled: _enabled,
        onToggle: (enabled) => setState(() => _enabled = enabled),
      ),
    );
  }
}

class _SurfaceSpec extends StatelessWidget {
  const _SurfaceSpec({
    this.label = 'Preview surface',
    this.tone = CatchSurfaceTone.surface,
    this.elevation = CatchSurfaceElevation.none,
    this.borderColor,
    this.foregroundColor,
    this.onTap,
  });

  final String label;
  final CatchSurfaceTone tone;
  final CatchSurfaceElevation elevation;
  final Color? borderColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = foregroundColor ?? t.ink;

    return CatchSurface(
      tone: tone,
      elevation: elevation,
      borderColor: borderColor ?? t.line,
      onTap: onTap,
      width: 188,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: CatchTextStyles.titleS(context, color: color)),
          const SizedBox(height: CatchSpacing.s2),
          Text(
            onTap == null ? 'Static panel' : 'Tap target',
            style: CatchTextStyles.bodyS(
              context,
              color: color.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
