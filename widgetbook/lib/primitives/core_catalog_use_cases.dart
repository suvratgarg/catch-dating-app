import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_art.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_day_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_draggable_sheet_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_framework_error_view.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_page_dots.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_label.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_share_card_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_vertical_section.dart';
import 'package:catch_dating_app/core/widgets/src/catch_inline_message_surface.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_visual_atoms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _choices = <_Choice>[
  _Choice('Social run'),
  _Choice('Dinner'),
  _Choice('Rooftop mixer'),
];

const _activitySamples = <ActivityKind>[
  ActivityKind.socialRun,
  ActivityKind.pickleball,
  ActivityKind.dinner,
];

final _eventDetailStart = DateTime(2026, 6, 14, 6, 30);

Event _eventDetailEvent({
  String id = 'widgetbook-event-detail',
  String title = 'Sundowner 5K, Bandra seafront',
  ActivityKind activityKind = ActivityKind.socialRun,
  EventPolicyBundle? eventPolicy,
  List<UploadedPhoto> eventPhotos = const <UploadedPhoto>[],
  bool exactLocation = true,
  int capacityLimit = 12,
  int bookedCount = 9,
  int priceInPaise = 0,
  EventLifecycleStatus status = EventLifecycleStatus.active,
  DateTime? startTime,
}) {
  final start = startTime ?? _eventDetailStart;
  const meetingPoint = 'Carter Road Jetty';
  final location = exactLocation
      ? EventMeetingLocation.legacy(
          name: meetingPoint,
          latitude: 19.0676,
          longitude: 72.8227,
          notes: 'Bandra West',
        )
      : null;
  return Event(
    id: id,
    clubId: 'club-widgetbook',
    startTime: start,
    endTime: start.add(const Duration(hours: 1, minutes: 45)),
    meetingPoint: meetingPoint,
    meetingLocation: location,
    photoUrl: null,
    eventPhotos: eventPhotos,
    eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
    distanceKm: activityKind == ActivityKind.socialRun ? 5 : 0,
    pace: PaceLevel.easy,
    capacityLimit: capacityLimit,
    description:
        'An easy social pace along the seafront as the light goes gold, with coffee after for anyone who lingers.',
    priceInPaise: priceInPaise,
    bookedCount: bookedCount,
    waitlistedCount: 3,
    status: status,
    eventPolicy:
        eventPolicy ??
        EventPolicyBundle.openEvent(
          capacityLimit: capacityLimit,
          basePriceInPaise: priceInPaise,
        ),
  );
}

List<UploadedPhoto> _eventDetailPhotos(int count) {
  return [
    for (var index = 0; index < count; index++)
      UploadedPhoto.fromUpload(
        url: 'https://example.invalid/catch-event-$index.jpg',
        storagePath: 'widgetbook/events/catch-event-$index.jpg',
        position: index,
        now: DateTime(2026, 6, 7, 8, index),
      ),
  ];
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchActionMenu,
  path: '[Core catalog]/Menus',
)
Widget catchActionMenuCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchActionMenu',
    catalogId: 'core.widgets.catch_action_menu',
    children: [
      _StateCard(
        label: 'interactive trigger',
        description:
            'Tap the trigger to inspect selected, disabled, and danger rows.',
        child: CatchActionMenu<String>(
          tooltip: 'Event actions',
          onSelected: _ignoreString,
          items: [
            CatchActionMenuItem(
              value: 'share',
              label: 'Share event',
              icon: CatchIcons.share,
            ),
            CatchActionMenuItem(
              value: 'saved',
              label: 'Saved',
              sublabel: 'Visible in your dashboard',
              icon: CatchIcons.savedOutlined,
              selected: true,
            ),
            CatchActionMenuItem(
              value: 'disabled',
              label: 'Invite guests',
              sublabel: 'Host has not opened invites',
              icon: CatchIcons.group,
              enabled: false,
            ),
            CatchActionMenuItem(
              value: 'cancel',
              label: 'Cancel booking',
              icon: CatchIcons.deleteOutline,
              isDestructive: true,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'disabled trigger',
        child: const CatchActionMenu<String>(
          tooltip: 'No actions',
          enabled: false,
          items: [],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchMenu,
  path: '[Core catalog]/Menus',
)
Widget catchMenuCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchMenu',
    catalogId: 'core.widgets.catch_menu',
    children: [
      _StateCard(
        label: 'rows',
        child: CatchMenu<String>(
          width: 280,
          onSelected: (value, _) => _ignoreString(value),
          items: [
            CatchMenuItem(
              value: 'going',
              label: 'Going',
              sublabel: 'Confirmed attendee view',
              icon: CatchIcons.checkCircle,
              selected: true,
            ),
            CatchMenuItem(
              value: 'waitlist',
              label: 'Waitlist',
              sublabel: 'Show demand and limits',
              icon: CatchIcons.scheduleOutlined,
            ),
            CatchMenuItem(
              value: 'disabled',
              label: 'Host controls',
              sublabel: 'Unavailable for guests',
              icon: CatchIcons.lockOutlineRounded,
              enabled: false,
            ),
            CatchMenuItem(
              value: 'danger',
              label: 'Remove from event',
              icon: CatchIcons.deleteOutline,
              danger: true,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget catchSearchFieldCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSearchField',
    catalogId: 'core.widgets.catch_search_field',
    children: const [
      _StateCard(label: 'empty / value / disabled', child: _SearchFieldDemo()),
      _StateCard(
        label: 'expanding header mode',
        child: _SearchFieldExpansionDemo(),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchMonoLabel,
  path: '[Core catalog]/Typography',
)
Widget catchMonoLabelCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchMonoLabel',
    catalogId: 'core.widgets.catch_mono_label',
    children: [
      _StateCard(
        label: 'metadata labels',
        child: _InlineWrap(
          children: [
            CatchMonoLabel('6 going', color: t.ink2),
            CatchMonoLabel('2.4 km away', color: t.primary),
            SizedBox(
              width: 110,
              child: CatchMonoLabel(
                'A very long metadata label',
                color: t.ink3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSectionLabel,
  path: '[Core catalog]/Typography',
)
Widget catchSectionLabelCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchSectionLabel',
    catalogId: 'core.widgets.catch_section_label',
    children: [
      _StateCard(
        label: 'plain / icon / truncated',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CatchSectionLabel(label: 'How it works'),
            gapH12,
            CatchSectionLabel(
              label: 'Social run format',
              icon: CatchIcons.directionsRunRounded,
              accentColor: t.primary,
            ),
            gapH12,
            SizedBox(
              width: 160,
              child: CatchSectionLabel(
                label: 'A very long activity section label',
                icon: CatchIcons.sparkle,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTextButton,
  path: '[Core catalog]/Actions',
)
Widget catchTextButtonCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchTextButton',
    catalogId: 'core.widgets.catch_text_button',
    children: [
      _StateCard(
        label: 'tones',
        child: _InlineWrap(
          children: [
            CatchTextButton(label: 'Retry', onPressed: _noop),
            CatchTextButton(
              label: 'Cancel',
              tone: CatchTextButtonTone.neutral,
              onPressed: _noop,
            ),
            CatchTextButton(
              label: 'Remove',
              tone: CatchTextButtonTone.danger,
              onPressed: _noop,
            ),
            const CatchTextButton(label: 'Disabled', onPressed: null),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchOtpCodeField,
  path: '[Core catalog]/Inputs',
)
Widget catchOtpCodeFieldCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchOtpCodeField',
    catalogId: 'core.widgets.catch_otp_code_field',
    children: const [
      _StateCard(label: 'editable platform input', child: _OtpCodeFieldDemo()),
    ],
  );
}

Widget catchRangeSliderCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchRangeSlider',
    catalogId: 'core.widgets.catch_range_slider',
    children: const [
      _StateCard(label: 'interactive', child: _RangeSliderDemo()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchFormFieldLabel,
  path: '[Core catalog]/Inputs',
)
Widget catchFormFieldLabelCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchFormFieldLabel',
    catalogId: 'core.widgets.catch_form_field_label',
    children: const [
      _StateCard(
        label: 'required / optional / error / large',
        child: _InlineWrap(
          children: [
            CatchFormFieldLabel(label: 'Name'),
            CatchFormFieldLabel(label: 'Note', isOptional: true),
            CatchFormFieldLabel(label: 'Activity', hasError: true),
            CatchFormFieldLabel(label: 'Host copy', large: true),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchControlShell,
  path: '[Core catalog]/Inputs',
)
Widget catchControlShellCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  Widget shell({
    required String label,
    CatchControlSize size = CatchControlSize.md,
    CatchControlShape shape = CatchControlShape.rounded,
    CatchControlTone tone = CatchControlTone.surface,
    bool enabled = true,
    bool hasError = false,
    bool focused = false,
  }) {
    return SizedBox(
      width: 180,
      child: CatchControlShell(
        size: size,
        shape: shape,
        tone: tone,
        enabled: enabled,
        hasError: hasError,
        focused: focused,
        child: Text(label, style: CatchTextStyles.bodyM(context, color: t.ink)),
      ),
    );
  }

  return _CatalogScreen(
    title: 'CatchControlShell',
    catalogId: 'core.widgets.catch_control_shell',
    children: [
      _StateCard(
        label: 'size / shape / tone / error / disabled',
        child: _InlineWrap(
          children: [
            shell(label: 'Regular field'),
            shell(
              label: 'Compact pill',
              size: CatchControlSize.compact,
              shape: CatchControlShape.pill,
              tone: CatchControlTone.raised,
            ),
            shell(label: 'Focused', focused: true),
            shell(label: 'Error', hasError: true),
            shell(label: 'Disabled', enabled: false),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchPageBody,
  path: '[Core catalog]/Layout',
)
Widget catchPageBodyCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchPageBody',
    catalogId: 'core.widgets.catch_page_body',
    children: [
      _StateCard(
        label: 'standard body insets',
        child: SizedBox(
          height: 160,
          child: ColoredBox(
            color: CatchTokens.of(context).raised,
            child: CatchPageBody(child: _textData('Page content')),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchFormStepBody,
  path: '[Core catalog]/Layout',
)
Widget catchFormStepBodyCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchFormStepBody',
    catalogId: 'core.widgets.catch_form_step_body',
    children: [
      _StateCard(
        label: 'form-step insets',
        child: SizedBox(
          height: 160,
          child: ColoredBox(
            color: CatchTokens.of(context).raised,
            child: CatchFormStepBody(child: _textData('Form step content')),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSliverPageBody,
  path: '[Core catalog]/Layout',
)
Widget catchSliverPageBodyCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSliverPageBody',
    catalogId: 'core.widgets.catch_sliver_page_body',
    children: [
      _StateCard(
        label: 'sliver-native insets',
        child: SizedBox(
          height: 220,
          child: ColoredBox(
            color: CatchTokens.of(context).raised,
            child: CustomScrollView(
              slivers: [
                CatchSliverPageBody(
                  sliver: _sliverTextData('Sliver page content'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTicketHero,
  path: '[Core catalog]/Motion',
)
Widget catchTicketHeroCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchTicketHero',
    catalogId: 'core.motion.catch_ticket_hero',
    children: [
      _StateCard(
        label: 'ticket hero wrapper',
        child: CatchTicketHero(
          prefix: 'event',
          id: 'widgetbook-ticket',
          child: CatchSurface.card(
            child: Text(
              'Ticket surface keeps the shared Hero tag and flight behavior.',
              style: CatchTextStyles.bodyM(context),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget catchOptionGroupCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchOptionGroup',
    catalogId: 'core.widgets.catch_option_group',
    children: const [
      _StateCard(label: 'label / mono / trailing', child: _OptionGroupDemo()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSelectChip,
  path: '[Core catalog]/Selection',
)
Widget catchSelectChipCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchSelectChip',
    catalogId: 'core.widgets.catch_select_chip',
    children: [
      _StateCard(
        label: 'resting / active / disabled',
        child: _InlineWrap(
          children: [
            CatchSelectChip(label: 'Low key', onTap: _noop),
            CatchSelectChip(
              label: 'Active',
              active: true,
              accentColor: t.like,
              onTap: _noop,
            ),
            const CatchSelectChip(label: 'Disabled', enabled: false),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchChipField,
  path: '[Core catalog]/Selection',
)
Widget catchChipFieldCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchChipField',
    catalogId: 'core.widgets.catch_chip_field',
    children: const [
      _StateCard(
        label: 'multi-select / single-select',
        child: _ChipFieldDemo(),
      ),
    ],
  );
}

Widget catchToggleCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchToggle',
    catalogId: 'core.widgets.catch_toggle',
    children: const [
      _StateCard(label: 'on / off / disabled', child: _ToggleDemo()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTopBarTabBar,
  path: '[Core catalog]/Navigation',
)
Widget catchTopBarTabBarCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchTopBarTabBar',
    catalogId: 'core.widgets.catch_top_bar_tab_bar',
    children: [
      _StateCard(
        label: 'inside CatchTopBar',
        child: DefaultTabController(
          length: 3,
          child: CatchTopBar(
            title: 'Explore',
            leadingType: CatchTopBarLeading.none,
            surface: true,
            bottom: const CatchTopBarTabBar(
              tabs: [
                Tab(text: 'Tonight'),
                Tab(text: 'Week'),
                Tab(text: 'Saved'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTopBarMenuAction,
  path: '[Core catalog]/Navigation',
)
Widget catchTopBarActionsCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchTopBar actions',
    catalogId: 'core.widgets.catch_top_bar_actions',
    children: [
      _StateCard(
        label: 'icon / text / menu',
        child: CatchTopBar(
          title: 'Event details',
          leadingType: CatchTopBarLeading.back,
          onBack: _noop,
          surface: true,
          actions: [
            CatchTopBarIconAction(
              icon: CatchIcons.savedOutlined,
              tooltip: 'Save',
              onPressed: _noop,
            ),
            CatchTopBarTextAction(label: 'Done', onPressed: _noop),
            CatchTopBarMenuAction<String>(
              tooltip: 'More',
              onSelected: _ignoreString,
              items: const [
                CatchActionMenuItem(value: 'share', label: 'Share'),
                CatchActionMenuItem(value: 'report', label: 'Report'),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTopBarIconAction,
  path: '[Core catalog]/Navigation',
)
Widget catchTopBarIconActionCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchTopBarIconAction',
    catalogId: 'core.widgets.catch_top_bar_icon_action',
    children: [
      _StateCard(
        label: 'default / plain / disabled',
        child: _InlineWrap(
          children: [
            CatchTopBarIconAction(
              icon: CatchIcons.savedOutlined,
              tooltip: 'Save',
              onPressed: _noop,
            ),
            CatchTopBarIconAction(
              icon: CatchIcons.share,
              tooltip: 'Share',
              variant: CatchIconButtonVariant.plain,
              onPressed: _noop,
            ),
            CatchTopBarIconAction(
              icon: CatchIcons.moreHorizRounded,
              tooltip: 'Disabled',
              onPressed: null,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTopBarTextAction,
  path: '[Core catalog]/Navigation',
)
Widget catchTopBarTextActionCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchTopBarTextAction',
    catalogId: 'core.widgets.catch_top_bar_text_action',
    children: [
      _StateCard(
        label: 'primary / neutral / disabled',
        child: _InlineWrap(
          children: [
            CatchTopBarTextAction(label: 'Done', onPressed: _noop),
            CatchTopBarTextAction(
              label: 'Skip',
              foregroundColor: t.ink2,
              onPressed: _noop,
            ),
            const CatchTopBarTextAction(label: 'Disabled', onPressed: null),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSliverHeader,
  path: '[Core catalog]/Navigation',
)
Widget catchSliverHeaderCatalogStates(BuildContext context) {
  final header = CatchSliverHeader(
    title: Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.screenPx,
        CatchSpacing.s4,
        CatchSpacing.screenPx,
        CatchSpacing.s3,
      ),
      child: Text(
        'Pinned search header',
        style: CatchTextStyles.headline(context),
      ),
    ),
    bottomHeight: CatchSliverHeader.compactSearchBottomHeight,
    bottom: const Padding(
      padding: EdgeInsets.fromLTRB(
        CatchSpacing.screenPx,
        CatchSliverHeader.searchControlTopPadding,
        CatchSpacing.screenPx,
        CatchSpacing.s2,
      ),
      child: CatchSearchField(value: 'Dinner'),
    ),
  );
  return _CatalogScreen(
    title: 'CatchSliverHeader',
    catalogId: 'core.widgets.catch_sliver_header',
    children: [
      _StateCard(
        label: 'scroll-away title / pinned bottom',
        child: SizedBox(
          height: 320,
          child: CustomScrollView(
            slivers: [
              ...header.buildSlivers(context),
              SliverList.builder(
                itemCount: 8,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CatchSpacing.screenPx,
                    vertical: CatchSpacing.s2,
                  ),
                  child: CatchSurface.card(child: Text('Result ${index + 1}')),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget catchStepHeaderCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchStepHeader',
    catalogId: 'core.widgets.catch_step_header',
    children: [
      _StateCard(
        label: 'header with progress',
        child: Column(
          children: [
            const CatchStepHeader(
              title: 'Event basics',
              subtitle: 'Set the foundation for guests.',
              kicker: 'Create event',
              step: 2,
              total: 5,
              onBack: _noop,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchStepProgress,
  path: '[Core catalog]/Navigation',
)
Widget catchStepProgressCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchStepProgress',
    catalogId: 'core.widgets.catch_step_progress',
    children: [
      _StateCard(
        label: 'counter / unlabeled',
        child: Column(
          children: [
            CatchStepProgress(currentStep: 1, totalSteps: 5, label: 'Basics'),
            SizedBox(height: CatchSpacing.s4),
            CatchStepProgress(
              currentStep: 3,
              totalSteps: 5,
              showCounter: false,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget catchTabDockCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchTabDock',
    catalogId: 'core.widgets.catch_tab_dock',
    children: const [
      _StateCard(label: 'interactive dock', child: _TabDockDemo()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchPageDots,
  path: '[Core catalog]/Navigation',
)
Widget catchPageDotsCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchPageDots',
    catalogId: 'core.widgets.catch_page_dots',
    children: [
      _StateCard(
        label: 'selected positions',
        child: Column(
          children: [
            CatchPageDots(selectedIndex: 0, itemCount: 4),
            SizedBox(height: CatchSpacing.s3),
            CatchPageDots(selectedIndex: 2, itemCount: 4),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSkeletonList,
  path: '[Core catalog]/Loading',
)
Widget catchSkeletonListCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSkeletonList',
    catalogId: 'core.widgets.catch_skeleton_list',
    children: [
      _StateCard(label: 'list', child: CatchSkeletonList(count: 3, height: 72)),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchLoadingIndicator,
  path: '[Core catalog]/Loading',
)
Widget catchLoadingIndicatorCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchLoadingIndicator',
    catalogId: 'core.widgets.catch_loading_indicator',
    children: [
      _StateCard(
        label: 'default / small / tinted',
        child: _InlineWrap(
          children: [
            const SizedBox.square(
              dimension: 48,
              child: CatchLoadingIndicator(),
            ),
            const SizedBox.square(
              dimension: 32,
              child: CatchLoadingIndicator(strokeWidth: 2),
            ),
            SizedBox.square(
              dimension: 48,
              child: CatchLoadingIndicator(color: t.primary),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchStartupLoadingScreen,
  path: '[Core catalog]/Loading',
)
Widget catchStartupLoadingScreenCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchStartupLoadingScreen',
    catalogId: 'core.widgets.catch_startup_loading_screen',
    children: const [
      _StateCard(
        label: 'branded boot surface',
        child: _PhoneFrame(height: 360, child: CatchStartupLoadingScreen()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchAsyncValueView,
  path: '[Core catalog]/Loading',
)
Widget catchAsyncValueViewCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchAsyncValueView',
    catalogId: 'core.widgets.catch_async_value_view',
    children: [
      _StateCard(
        label: 'data / loading / error',
        child: Column(
          children: [
            CatchAsyncValueView<String>(
              value: const AsyncValue.data('3 events ready'),
              data: (value) => CatchSurface.card(child: Text(value)),
            ),
            gapH12,
            const SizedBox(
              height: 80,
              child: CatchAsyncValueView<String>(
                value: AsyncValue.loading(),
                data: _textData,
              ),
            ),
            gapH12,
            SizedBox(
              height: 220,
              child: CatchAsyncValueView<String>(
                value: AsyncValue.error(
                  Exception('Could not load events'),
                  StackTrace.current,
                ),
                data: _textData,
                onRetry: _noop,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchAsyncValueSliver,
  path: '[Core catalog]/Loading',
)
Widget catchAsyncValueSliverCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchAsyncValueSliver',
    catalogId: 'core.widgets.catch_async_value_sliver',
    children: [
      _StateCard(
        label: 'sliver data / loading / error',
        child: SizedBox(
          height: 360,
          child: CustomScrollView(
            slivers: [
              CatchAsyncValueSliver<String>(
                value: const AsyncValue.data('Sliver data loaded'),
                data: (value) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(CatchSpacing.s4),
                    child: CatchSurface.card(child: Text(value)),
                  ),
                ),
              ),
              const CatchAsyncValueSliver<String>(
                value: AsyncValue.loading(),
                data: _sliverTextData,
              ),
              CatchAsyncValueSliver<String>(
                value: AsyncValue.error(
                  Exception('Could not load sliver list'),
                  StackTrace.current,
                ),
                data: _sliverTextData,
                onRetry: _noop,
                fillErrorRemaining: false,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchAsyncScreenLoading,
  path: '[Core catalog]/Loading',
)
Widget catchAsyncScreenLoadingCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchAsyncScreenLoading',
    catalogId: 'core.widgets.catch_async_screen_loading',
    children: const [
      _StateCard(
        label: 'screen skeleton',
        child: _PhoneFrame(
          height: 360,
          child: CatchAsyncScreenLoading(
            count: 4,
            itemHeight: CatchLayout.skeletonCardCompactHeight,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchAsyncSliverLoading,
  path: '[Core catalog]/Loading',
)
Widget catchAsyncSliverLoadingCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchAsyncSliverLoading',
    catalogId: 'core.widgets.catch_async_sliver_loading',
    children: const [
      _StateCard(
        label: 'sliver skeleton',
        child: SizedBox(
          height: 360,
          child: CustomScrollView(
            slivers: [
              CatchAsyncSliverLoading(
                count: 4,
                itemHeight: CatchLayout.skeletonCardCompactHeight,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchErrorScaffold,
  path: '[Core catalog]/Feedback',
)
Widget catchErrorScaffoldCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchErrorScaffold',
    catalogId: 'core.widgets.catch_error_scaffold',
    children: [
      _StateCard(
        label: 'root-level failure',
        child: SizedBox(
          height: 360,
          child: CatchErrorScaffold(
            title: 'Profile unavailable',
            message: 'We could not load this profile right now.',
            onRetry: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSliverErrorState,
  path: '[Core catalog]/Feedback',
)
Widget catchSliverErrorStateCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSliverErrorState',
    catalogId: 'core.widgets.catch_sliver_error_state',
    children: [
      _StateCard(
        label: 'fill remaining / inline sliver',
        child: SizedBox(
          height: 420,
          child: CustomScrollView(
            slivers: [
              CatchSliverErrorState(
                title: 'Feed unavailable',
                message: 'Try refreshing the feed.',
                onRetry: _noop,
                fillRemaining: false,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: CatchSpacing.s4),
              ),
              const CatchSliverErrorState(
                title: 'No connection',
                message: 'Reconnect to keep browsing.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchInlineErrorState,
  path: '[Core catalog]/Feedback',
)
Widget catchInlineErrorStateCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchInlineErrorState',
    catalogId: 'core.widgets.catch_inline_error_state',
    children: [
      _StateCard(
        label: 'regular / compact',
        child: Column(
          children: [
            CatchInlineErrorState(
              title: 'Could not save',
              message: 'Your changes are still local.',
              onRetry: _noop,
            ),
            gapH12,
            const CatchInlineErrorState(
              title: 'Unavailable',
              message: 'Try again later.',
              compact: true,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchErrorBanner,
  path: '[Core catalog]/Feedback',
)
Widget catchErrorBannerCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'Mutation error banner',
    catalogId: 'core.widgets.catch_error_banner',
    children: [
      _StateCard(
        label: 'persistent inline error',
        child: Column(
          children: [
            const CatchErrorBanner(message: 'Card details could not be saved.'),
            CatchErrorBanner.fromError(
              Exception('Booking failed. Try once more.'),
              onRetry: _noop,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchMutationErrorBanner,
  path: '[Core catalog]/Feedback',
)
Widget catchMutationErrorBannerCatalogStates(BuildContext context) {
  final mutation = Mutation<void>();
  return _CatalogScreen(
    title: 'CatchMutationErrorBanner',
    catalogId: 'core.widgets.catch_mutation_error_banner',
    children: [
      _StateCard(
        label: 'persistent mutation error',
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(mutation);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchButton(
                  label: 'Simulate failed save',
                  icon: Icon(CatchIcons.errorOutlineRounded),
                  onPressed: () => unawaited(
                    mutation
                        .run(ref, (_) async => throw StateError('Save failed'))
                        .catchError((_) {}),
                  ),
                ),
                gapH12,
                CatchMutationErrorBanner(mutation: state, onRetry: _noop),
              ],
            );
          },
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchInlineMessageSurface,
  path: '[Core catalog]/Feedback',
)
Widget catchInlineMessageSurfaceCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchInlineMessageSurface',
    catalogId: 'core.widgets.catch_inline_message_surface',
    children: [
      _StateCard(
        label: 'message / title / action',
        child: Column(
          children: [
            CatchInlineMessageSurface(
              title: 'Booking pending',
              message: 'We will confirm your spot after payment settles.',
              icon: CatchIcons.infoOutlineRounded,
              iconColor: t.primary,
              backgroundColor: t.surface,
              borderColor: t.line,
              actions: [CatchTextButton(label: 'View', onPressed: _noop)],
            ),
            gapH12,
            CatchInlineMessageSurface(
              message: 'Host approval is required for this event.',
              icon: CatchIcons.lockOutlineRounded,
              iconColor: t.ink2,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchMutationErrorListener,
  path: '[Core catalog]/Feedback',
)
Widget catchMutationErrorListenerCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'Action error snackbar',
    catalogId: 'core.widgets.catch_mutation_error_listener',
    children: [
      _StateCard(
        label: 'transient action failure',
        child: Builder(
          builder: (context) => CatchButton(
            label: 'Show action error',
            icon: Icon(CatchIcons.errorOutlineRounded),
            onPressed: () => showCatchErrorSnackBar(
              context,
              Exception('Share sheet is unavailable right now.'),
              onRetry: _noop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchMutationErrorListeners,
  path: '[Core catalog]/Feedback',
)
Widget catchMutationErrorListenersCatalogStates(BuildContext context) {
  final saveMutation = Mutation<void>();
  final deleteMutation = Mutation<void>();
  return _CatalogScreen(
    title: 'CatchMutationErrorListeners',
    catalogId: 'core.widgets.catch_mutation_error_listeners',
    children: [
      _StateCard(
        label: 'multiple snackbar boundaries',
        child: Consumer(
          builder: (context, ref, _) => CatchMutationErrorListeners(
            mutations: [saveMutation, deleteMutation],
            child: _InlineWrap(
              children: [
                CatchButton(
                  label: 'Fail save',
                  onPressed: () => unawaited(
                    saveMutation
                        .run(ref, (_) async => throw StateError('Save failed'))
                        .catchError((_) {}),
                  ),
                ),
                CatchButton(
                  label: 'Fail delete',
                  variant: CatchButtonVariant.danger,
                  onPressed: () => unawaited(
                    deleteMutation
                        .run(
                          ref,
                          (_) async => throw StateError('Delete failed'),
                        )
                        .catchError((_) {}),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchFrameworkErrorView,
  path: '[Core catalog]/Feedback',
)
Widget catchFrameworkErrorViewCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchFrameworkErrorView',
    catalogId: 'core.widgets.catch_framework_error_view',
    children: [
      _StateCard(
        label: 'user-safe / debug details',
        child: SizedBox(
          height: 360,
          child: CatchFrameworkErrorView(
            details: FlutterErrorDetails(
              exception: StateError('Widgetbook sample framework failure'),
            ),
            showDebugDetails: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchNoticeHost,
  path: '[Core catalog]/Feedback',
)
Widget catchNoticeHostCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchNoticeHost',
    catalogId: 'core.widgets.catch_notice_host',
    children: [
      _StateCard(
        label: 'overlay host',
        child: SizedBox(
          height: 220,
          child: CatchNoticeHost(
            persistentNotices: const [CatchNoticeData.offline()],
            child: CatchSurface.card(
              height: 180,
              child: Center(
                child: Text(
                  'App content under ambient notices',
                  style: CatchTextStyles.bodyM(context),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchActivityMapPin,
  path: '[Core catalog]/Activity',
)
Widget catchActivityMapPinCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchActivityMapPin',
    catalogId: 'core.widgets.catch_activity_map_pin',
    children: [
      _StateCard(
        label: 'resting / selected / sized',
        child: _InlineWrap(
          children: [
            CatchActivityMapPin(activityKind: ActivityKind.socialRun),
            CatchActivityMapPin(
              activityKind: ActivityKind.pickleball,
              selected: true,
              label: '6 PM',
            ),
            CatchActivityMapPin(
              activityKind: ActivityKind.dinner,
              selected: true,
              size: 54,
              label: 'Tonight',
            ),
          ],
        ),
      ),
    ],
  );
}

Widget catchDistanceRingCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchDistanceRing',
    catalogId: 'core.widgets.catch_distance_ring',
    children: [
      _StateCard(
        label: 'ring / tappable label',
        child: _InlineWrap(
          children: [
            const CatchDistanceRing(size: 96),
            CatchDistanceRing(size: 132, label: '2 km', onTap: _noop),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchDetailHeroBackdrop,
  path: '[Core catalog]/Media',
)
Widget catchDetailHeroBackdropCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchDetailHeroBackdrop',
    catalogId: 'core.widgets.catch_detail_hero_backdrop',
    children: [
      _StateCard(
        label: 'fallback / no scrim',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 220,
              height: 130,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(CatchRadius.md)),
                child: CatchDetailHeroBackdrop(),
              ),
            ),
            SizedBox(
              width: 220,
              height: 130,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(CatchRadius.md)),
                child: CatchDetailHeroBackdrop(showScrim: false),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchEventThumbnail,
  path: '[Core catalog]/Media',
)
Widget catchEventThumbnailCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchEventThumbnail',
    catalogId: 'core.widgets.catch_event_thumbnail',
    children: [
      _StateCard(
        label: 'fallback / scrims',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            _ThumbnailBox(
              child: CatchEventThumbnail(
                photoUrl: null,
                pace: PaceLevel.easy,
                activityKind: ActivityKind.socialRun,
              ),
            ),
            _ThumbnailBox(
              child: CatchEventThumbnail(
                photoUrl: null,
                pace: PaceLevel.moderate,
                activityKind: ActivityKind.dinner,
                scrim: CatchEventThumbnailScrim.full,
              ),
            ),
            _ThumbnailBox(
              child: CatchEventThumbnail(
                photoUrl: null,
                pace: PaceLevel.fast,
                activityKind: ActivityKind.pickleball,
                scrim: CatchEventThumbnailScrim.none,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchGradedImage,
  path: '[Core catalog]/Media',
)
Widget catchGradedImageCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchGradedImage / CatchGrade',
    catalogId: 'core.widgets.catch_graded_image',
    children: [
      _StateCard(
        label: 'raw / graded',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            _GradeSample(label: 'Raw', graded: false),
            _GradeSample(label: 'Graded', graded: true),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventActivityBackdrop,
  path: '[Core catalog]/Event cards',
)
Widget eventActivityBackdropCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventActivityVisualSpec / EventActivityBackdrop',
    catalogId: 'events.presentation.event_activity_visuals',
    children: [
      _StateCard(
        label: 'patterns / dense / icon alignment',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final kind in _activitySamples)
              ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.md),
                child: SizedBox(
                  width: 180,
                  height: 112,
                  child: EventActivityBackdrop(
                    visual: eventActivityVisual(kind, context: context),
                    dense: kind != ActivityKind.socialRun,
                    iconAlignment: kind == ActivityKind.dinner
                        ? Alignment.topRight
                        : Alignment.bottomRight,
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchEventCard,
  path: '[Core catalog]/Event cards',
)
Widget catchEventCardCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchEventCard',
    catalogId: 'core.widgets.catch_event_card',
    children: [
      _StateCard(
        label: 'ticket / status / compact width',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            CatchEventCard.ticket(
              width: 260,
              title: 'Bandra easy 5K',
              subtitle: 'Hosted by Catch Run Club',
              timeLabel: '7:30 PM',
              countdownLabel: 'Tonight',
              priceLabel: 'Free',
              capacityLabel: '12 going / 4 left',
              activityKind: ActivityKind.socialRun,
              statusLabel: "You're in",
              onTap: _noop,
            ),
            CatchEventCard.ticket(
              width: 260,
              title: 'Pickleball doubles mixer',
              subtitle: 'Courtside social rotations',
              timeLabel: '6 PM',
              countdownLabel: 'Sat',
              priceLabel: '₹799',
              capacityLabel: '8 going / 2 left',
              activityKind: ActivityKind.pickleball,
              onTap: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'spotlight',
        child: CatchEventCard.spotlight(
          title: 'Dinner for six',
          supportingLabel: 'A low-pressure table with rotating prompts.',
          timeLabel: '8 PM',
          countdownLabel: 'Fri',
          priceLabel: '₹1499',
          capacityLabel: '4 seats left',
          activityKind: ActivityKind.dinner,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'compact',
        child: SizedBox(
          width: 360,
          child: CatchEventCard.compact(
            title: 'Sunday sea-face social',
            subtitle: 'Hosted by Catch Run Club',
            timeLabel: '7 AM',
            countdownLabel: 'Sun',
            priceLabel: 'Free',
            capacityLabel: '18 going / 6 left',
            activityKind: ActivityKind.socialRun,
            statusLabel: 'Nearby',
            onTap: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventTicketPerforatedDivider,
  path: '[Core catalog]/Event cards',
)
Widget eventTicketSurfaceCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'Event ticket surface atoms',
    catalogId: 'events.widgets.event_ticket_surface',
    children: [
      _StateCard(
        label: 'perforated divider / clipped shape',
        child: Column(
          children: [
            const EventTicketPerforatedDivider(),
            gapH16,
            PhysicalShape(
              clipper: const EventTicketShapeClipper(
                cornerRadius: CatchRadius.lg,
                notchRadius: eventTicketNotchRadius,
                notchDepth: eventTicketNotchDepth,
                notchCenterY: 86,
              ),
              color: t.surface,
              elevation: CatchElevation.physicalTicket,
              child: SizedBox(
                height: 172,
                child: Column(
                  children: [
                    Expanded(
                      child: EventActivityBackdrop(
                        visual: eventActivityVisual(
                          ActivityKind.socialRun,
                          context: context,
                        ),
                        dense: true,
                      ),
                    ),
                    const EventTicketPerforatedDivider(),
                    const Padding(
                      padding: EdgeInsets.all(CatchSpacing.s4),
                      child: Text('Ticket body surface'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailHeroAppBar,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailHeroCatalogStates(BuildContext context) {
  final event = _eventDetailEvent();
  return _CatalogScreen(
    title: 'EventDetailHeroAppBar',
    catalogId: 'events.widgets.event_detail_hero_app_bar',
    children: [
      _StateCard(
        label: 'standard / saved / calendar action',
        child: _PhoneFrame(
          height: 460,
          child: CustomScrollView(
            slivers: [
              EventDetailHeroAppBar(
                event: event,
                isSaved: true,
                savePending: false,
                showAddToCalendar: true,
                onBack: _noop,
                onShare: (_) {},
                onToggleSaved: _noop,
                onAddToCalendar: (_) {},
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'ticket and spotlight modes',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            _PhoneFrame(
              height: 360,
              child: CustomScrollView(
                slivers: [
                  EventDetailHeroAppBar(
                    event: event,
                    isSaved: false,
                    savePending: true,
                    showAddToCalendar: false,
                    presentationMode: EventDetailPresentationMode.ticket,
                    onBack: _noop,
                    onShare: (_) {},
                    onToggleSaved: _noop,
                    onAddToCalendar: (_) {},
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            _PhoneFrame(
              height: 360,
              child: CustomScrollView(
                slivers: [
                  EventDetailHeroAppBar(
                    event: event,
                    isSaved: false,
                    savePending: false,
                    showAddToCalendar: true,
                    presentationMode: EventDetailPresentationMode.spotlightDark,
                    onBack: _noop,
                    onShare: (_) {},
                    onToggleSaved: _noop,
                    onAddToCalendar: (_) {},
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailTicketStubBand,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailTicketStubCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'EventDetailTicketStubBand',
    catalogId: 'events.widgets.event_detail_ticket_stub',
    children: [
      _StateCard(
        label: 'band / three cells / dark notch',
        child: Column(
          children: [
            EventDetailTicketStubBand(
              event: _eventDetailEvent(),
              notchBackgroundColor: t.bg,
            ),
            gapH16,
            ColoredBox(
              color: t.ink,
              child: EventDetailTicketStubBand(
                event: _eventDetailEvent(
                  activityKind: ActivityKind.dinner,
                  title: 'Dinner for six',
                  priceInPaise: 140000,
                ),
                notchBackgroundColor: t.ink,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailHintList,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailHintListCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailHintList',
    catalogId: 'events.widgets.event_detail_hint_list',
    children: [
      _StateCard(
        label: 'open event / approval event',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 320,
              child: EventDetailHintList(event: _eventDetailEvent()),
            ),
            SizedBox(
              width: 320,
              child: EventDetailHintList(
                event: _eventDetailEvent(
                  id: 'approval-event',
                  eventPolicy: EventPolicyBundle.requestToJoinEvent(
                    capacityLimit: 10,
                    basePriceInPaise: 0,
                  ),
                  bookedCount: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailItinerary,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailItineraryCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailItinerary',
    catalogId: 'events.widgets.event_detail_itinerary',
    children: [
      _StateCard(
        label: 'run / dinner',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 320,
              child: EventDetailItinerary(event: _eventDetailEvent()),
            ),
            SizedBox(
              width: 320,
              child: EventDetailItinerary(
                event: _eventDetailEvent(
                  id: 'dinner-itinerary',
                  activityKind: ActivityKind.dinner,
                  title: 'Dinner for six',
                  priceInPaise: 140000,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailPhotoStrip,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailPhotoStripCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailPhotoStrip',
    catalogId: 'events.widgets.event_detail_photo_strip',
    children: [
      _StateCard(
        label: 'three photos / partial photos / empty hidden',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EventDetailPhotoStrip(
              event: _eventDetailEvent(eventPhotos: _eventDetailPhotos(3)),
            ),
            gapH16,
            EventDetailPhotoStrip(
              event: _eventDetailEvent(
                id: 'partial-photo-strip',
                eventPhotos: _eventDetailPhotos(1),
              ),
            ),
            gapH16,
            EventDetailPhotoStrip(event: _eventDetailEvent(id: 'empty-strip')),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailMapCard,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailMapCardCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailMapCard',
    catalogId: 'events.widgets.event_detail_map_card',
    children: [
      _StateCard(
        label: 'pin ready / morning-of pin',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 320,
              child: EventDetailMapCard(
                event: _eventDetailEvent(),
                onTap: _noop,
              ),
            ),
            SizedBox(
              width: 320,
              child: EventDetailMapCard(
                event: _eventDetailEvent(
                  id: 'map-morning-of',
                  exactLocation: false,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailMechanismList,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailMechanismListCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailMechanismList',
    catalogId: 'events.widgets.event_detail_mechanism_list',
    children: [
      _StateCard(
        label: 'open / approval / balanced',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 320,
              child: EventDetailMechanismList(event: _eventDetailEvent()),
            ),
            SizedBox(
              width: 320,
              child: EventDetailMechanismList(
                event: _eventDetailEvent(
                  id: 'approval-mechanism',
                  eventPolicy: EventPolicyBundle.requestToJoinEvent(
                    capacityLimit: 10,
                    basePriceInPaise: 0,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: EventDetailMechanismList(
                event: _eventDetailEvent(
                  id: 'balanced-mechanism',
                  activityKind: ActivityKind.dinner,
                  eventPolicy: EventPolicyBundle.balancedSinglesEvent(
                    capacityLimit: 12,
                    basePriceInPaise: 140000,
                  ),
                  priceInPaise: 140000,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailHostCard,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailHostCardCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'EventDetailHostCard',
    catalogId: 'events.widgets.event_detail_host_card',
    children: [
      _StateCard(
        label: 'actions / no stats / dark surface',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 340,
              child: EventDetailHostCard(
                activityKind: ActivityKind.socialRun,
                hostName: 'Sunday sea-face crew',
                meta: 'HOSTING SINCE FEB 2026 - BANDRA',
                stats: const [
                  EventDetailHostStat(value: '23', label: 'Runs'),
                  EventDetailHostStat(value: '412', label: 'Runners'),
                  EventDetailHostStat(value: '92%', label: 'Return'),
                ],
                onMessage: _noop,
                onViewClub: _noop,
              ),
            ),
            const SizedBox(
              width: 340,
              child: EventDetailHostCard(
                activityKind: ActivityKind.dinner,
                hostName: 'Catch supper club',
                meta: 'HOSTING SINCE MAR 2026',
                verified: false,
              ),
            ),
            SizedBox(
              width: 340,
              child: EventDetailHostCard(
                activityKind: ActivityKind.pickleball,
                hostName: 'Courtside social',
                meta: 'HOSTING SINCE JAN 2026 - REPLIES FAST',
                stats: const [
                  EventDetailHostStat(value: '14', label: 'Mixers'),
                  EventDetailHostStat(value: '4.9', label: 'Rating'),
                ],
                surfaceColor: t.ink,
                borderColor: t.ink2,
                nameColor: t.primaryInk,
                metaColor: t.primaryInk.withValues(alpha: 0.72),
                statValueColor: t.primaryInk,
                statLabelColor: t.primaryInk.withValues(alpha: 0.62),
                dividerColor: t.ink2,
                onViewClub: _noop,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventDetailCta,
  path: '[Core catalog]/Event detail',
)
Widget eventDetailBookingDockCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'EventDetailCta / BookingDock states',
    catalogId: 'events.widgets.event_detail_booking_dock',
    children: [
      _StateCard(
        label: 'bookable / booked / waitlist / attended',
        description:
            'Representative dock states built from the lower-level dock primitive until EventDetailCta is split into a provider-free BookingDock adapter.',
        child: Column(
          children: [
            CatchBottomDock.cta(
              label: 'Join event - 3 spots left',
              onPressed: _noop,
              leadingContent: const PriceLeading(
                price: 'Free',
                note: '3 spots left',
                warn: true,
              ),
              buttonAccentColor: t.primary,
              catchLine: 'Matching opens for everyone who goes',
              catchLineAccent: t.primary,
            ),
            gapH12,
            CatchBottomDock.cta(
              label: 'Cancel booking',
              onPressed: _noop,
              leadingContent: const BookedLeading(),
            ),
            gapH12,
            CatchBottomDock.cta(label: 'Join waitlist', onPressed: _noop),
            gapH12,
            const CatchBottomDock.cta(
              label: 'You attended this event',
              onPressed: null,
              leadingContent: AttendedLeading(),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: EventActivityStamp,
  path: '[Core catalog]/Event cards',
)
Widget eventVisualAtomsCatalogStates(BuildContext context) {
  final visual = eventActivityVisual(ActivityKind.pickleball, context: context);
  return _CatalogScreen(
    title: 'Event visual atoms',
    catalogId: 'events.widgets.event_visual_atoms',
    children: [
      _StateCard(
        label: 'stamp / clock / status pill',
        child: _InlineWrap(
          children: [
            EventActivityStamp(visual: visual),
            EventClockMark(
              accent: visual.accent,
              time: const TimeOfDay(hour: 18, minute: 30),
              size: 42,
              centerDotRadius: 2,
            ),
            EventStatusPill(label: 'Going', color: visual.accent),
            EventStatusPill(
              label: 'Full',
              color: visual.accent,
              tone: EventStatusPillTone.dark,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchStatColumn,
  path: '[Core catalog]/Data display',
)
Widget catchStatColumnCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchStatColumn',
    catalogId: 'core.widgets.catch_stat_column',
    children: [
      _StateCard(
        label: 'plain / highlighted / centered / surfaced',
        child: _InlineWrap(
          children: [
            CatchStatColumn(value: '12', label: 'Going'),
            CatchStatColumn(
              value: '4',
              label: 'Left',
              highlight: true,
              monoValue: true,
            ),
            CatchStatColumn(
              icon: CatchIcons.group,
              value: '86%',
              label: 'Return rate',
              center: true,
            ),
            CatchStatColumn(
              icon: CatchIcons.confirmationNumberOutlined,
              value: 'Rs 1,200',
              label: 'Base',
              center: true,
              monoValue: true,
              surface: true,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchMetaDotRow,
  path: '[Core catalog]/Data display',
)
Widget catchMetaDotRowCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchMetaDotRow',
    catalogId: 'core.widgets.catch_meta_dot_row',
    children: [
      _StateCard(
        label: 'entries / trailing / truncation',
        child: SizedBox(
          width: 360,
          child: CatchMetaDotRow(
            entries: [
              CatchMetaEntry(label: 'Tonight', icon: CatchIcons.calendarAdd),
              CatchMetaEntry(
                label: 'Bandra West',
                icon: CatchIcons.pinOutlined,
              ),
              CatchMetaEntry(label: 'Easy pace'),
            ],
            trailing: CatchMetaEntry(label: '2.4 km'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchBottomDock,
  path: '[Core catalog]/Sheets and footers',
)
Widget catchBottomDockCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchBottomDock',
    catalogId: 'core.widgets.catch_bottom_dock',
    children: [
      _StateCard(
        label: 'safe-area utility dock',
        child: Column(
          children: [
            CatchBottomDock(
              child: Row(
                children: [
                  const Expanded(child: CatchSearchField(value: '')),
                  gapW12,
                  CatchIconButton(
                    onTap: _noop,
                    child: Icon(CatchIcons.sendRounded),
                  ),
                ],
              ),
            ),
            gapH12,
            CatchBottomDock(
              includeSafeArea: false,
              child: CatchButton(
                label: 'Apply filters',
                fullWidth: true,
                onPressed: _noop,
              ),
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'cta footer variants',
        child: Column(
          children: [
            CatchBottomDock.cta(
              label: 'Join event',
              onPressed: _noop,
              catchLine: 'Matching opens after check-in',
              catchLineAccent: t.primary,
            ),
            gapH12,
            CatchBottomDock.cta(
              label: 'Book spot',
              onPressed: _noop,
              leadingContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹799', style: CatchTextStyles.titleL(context)),
                  Text(
                    'incl. coffee',
                    style: CatchTextStyles.supporting(context),
                  ),
                ],
              ),
              footnote: 'Refundable until 24 hours before start.',
            ),
            gapH12,
            CatchBottomDock.cta(
              label: 'Joining',
              onPressed: _noop,
              isLoading: true,
            ),
            gapH12,
            const CatchBottomDock.cta(label: 'Sold out', onPressed: null),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchBottomSheetGrabber,
  path: '[Core catalog]/Sheets and footers',
)
Widget catchBottomSheetGrabberCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchBottomSheetGrabber',
    catalogId: 'core.widgets.catch_bottom_sheet_grabber',
    children: [
      _StateCard(
        label: 'default / wide',
        child: Column(
          children: [
            CatchBottomSheetGrabber(),
            SizedBox(height: CatchSpacing.s4),
            CatchBottomSheetGrabber(width: 64, height: 5),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchDraggableSheetShell,
  path: '[Core catalog]/Sheets and footers',
)
Widget catchDraggableSheetShellCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchDraggableSheetShell',
    catalogId: 'core.widgets.catch_draggable_sheet_shell',
    children: [
      _StateCard(
        label: 'persistent shell',
        child: SizedBox(
          height: 260,
          child: CatchDraggableSheetShell(
            child: ListView(
              padding: const EdgeInsets.all(CatchSpacing.s4),
              children: const [
                CatchSurface.card(
                  child: Text('Persistent map/list sheet content'),
                ),
                SizedBox(height: CatchSpacing.s3),
                CatchSurface.card(child: Text('Second row')),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchShareCardSheet,
  path: '[Core catalog]/Sheets and footers',
)
Widget catchShareCardSheetCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchShareCardSheet',
    catalogId: 'core.widgets.catch_share_card_sheet',
    children: [
      _StateCard(
        label: 'card preview / share action',
        child: CatchShareCardSheet(
          share: ExternalShareController((_) async {}),
          fileName: 'catch-card.png',
          buttonLabel: 'Share card',
          footnote: 'Preview rendered through RepaintBoundary.',
          card: CatchSurface.card(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CatchKicker(label: 'Tonight'),
                gapH8,
                Text('Bandra easy 5K', style: CatchTextStyles.titleL(context)),
                gapH6,
                Text(
                  'A social run with coffee after.',
                  style: CatchTextStyles.bodyS(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchHorizontalRail,
  path: '[Core catalog]/Sections',
)
Widget catchHorizontalRailCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchHorizontalRail',
    catalogId: 'core.widgets.catch_horizontal_rail',
    children: [
      _StateCard(
        label: 'rail',
        child: CatchHorizontalRail(
          title: 'Recommended',
          itemCount: 4,
          height: 128,
          itemBuilder: (context, index) =>
              CatchSurface.card(width: 136, child: Text('Card ${index + 1}')),
          trailing: CatchButton(label: 'More', onPressed: _noop),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchVerticalSection,
  path: '[Core catalog]/Sections',
)
Widget catchVerticalSectionCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchVerticalSection',
    catalogId: 'core.widgets.catch_vertical_section',
    children: [
      _StateCard(
        label: 'embedded list',
        child: CatchVerticalSection(
          title: 'Today',
          itemCount: 3,
          itemBuilder: (context, index) =>
              CatchSurface.card(child: Text('List item ${index + 1}')),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSectionHeader,
  path: '[Core catalog]/Sections',
)
Widget catchSectionHeaderCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSectionHeader',
    catalogId: 'core.widgets.catch_section_header',
    children: [
      _StateCard(
        label: 'plain / uppercase / trailing',
        child: Column(
          children: [
            CatchSectionHeader(
              title: 'Upcoming events',
              trailing: CatchTextButton(label: 'See all', onPressed: _noop),
            ),
            const CatchSectionHeader(
              title: 'metadata group',
              uppercase: true,
              heavy: true,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchDaySectionHeader,
  path: '[Core catalog]/Sections',
)
Widget catchDaySectionHeaderCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchDaySectionHeader',
    catalogId: 'core.widgets.catch_day_section_header',
    children: [
      _StateCard(
        label: 'regular / sticky delegate',
        child: Column(
          children: [
            const CatchDaySectionHeader(label: 'Today - Wed 27 May', count: 3),
            SizedBox(
              height: 180,
              child: CustomScrollView(
                slivers: [
                  const SliverPersistentHeader(
                    pinned: true,
                    delegate: CatchDaySectionHeaderDelegate(
                      label: 'Tomorrow - Thu 28 May',
                      count: 5,
                    ),
                  ),
                  SliverList.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CatchSpacing.screenPx,
                        vertical: CatchSpacing.s1,
                      ),
                      child: CatchSurface.card(
                        child: Text('Chronological item ${index + 1}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget catchPersonAvatarCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchPersonAvatar',
    catalogId: 'core.widgets.catch_person_avatar',
    children: [
      _StateCard(
        label: 'fallback / ring / status / obscured / square / count',
        child: _InlineWrap(
          children: [
            const CatchPersonAvatar(size: 48, name: 'Aarav Kapoor'),
            CatchPersonAvatar(
              size: 56,
              name: 'Riya Shah',
              borderWidth: 3,
              borderColor: t.primary,
            ),
            const CatchPersonAvatar(
              size: 48,
              name: 'Maya Patel',
              showStatusDot: true,
            ),
            const CatchPersonAvatar(
              size: 48,
              name: 'Hidden Guest',
              obscured: true,
            ),
            const CatchPersonAvatar(
              size: 48,
              name: 'Host Team',
              shape: CatchPersonAvatarShape.square,
            ),
            const CatchPersonAvatar(
              size: 48,
              name: 'Social run',
              initials: 'SR',
              activityKind: ActivityKind.socialRun,
            ),
            const CatchPersonAvatar(
              size: 48,
              name: 'Dinner',
              initials: 'DN',
              activityKind: ActivityKind.dinner,
              activityDim: true,
            ),
            const CatchPersonAvatar.count(size: 48, count: 8),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchPersonAvatarStack,
  path: '[Core catalog]/People',
)
Widget catchPersonAvatarStackCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchPersonAvatarStack',
    catalogId: 'core.widgets.catch_person_avatar_stack',
    children: [
      _StateCard(
        label: 'stack / veiled / overflow',
        child: _InlineWrap(
          children: [
            CatchPersonAvatarStack(
              items: [
                CatchPersonAvatarItem(name: 'Aarav Kapoor', initials: 'AK'),
                CatchPersonAvatarItem(name: 'Riya Shah', initials: 'RS'),
                CatchPersonAvatarItem(name: 'Maya Patel', initials: 'MP'),
              ],
              totalCount: 8,
            ),
            CatchPersonAvatarStack(
              items: [CatchPersonAvatarItem(name: 'Visible guest')],
              totalCount: 6,
              veiledCount: 3,
              activityKind: ActivityKind.dinner,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchIconTile,
  path: '[Core catalog]/Icon atoms',
)
Widget catchIconTileCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchIconTile',
    catalogId: 'core.widgets.catch_icon_tile',
    children: [
      _StateCard(
        label: 'default / tinted / compact',
        child: _InlineWrap(
          children: [
            CatchIconTile(icon: CatchIcons.eventOutlined, iconColor: t.primary),
            CatchIconTile(
              icon: CatchIcons.lockOutlineRounded,
              iconColor: t.danger,
              backgroundColor: t.primarySoft,
            ),
            CatchIconTile(
              icon: CatchIcons.sparkle,
              iconColor: t.ink,
              size: 32,
              iconSize: 16,
              radius: CatchRadius.sm,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchCelebrationScreen,
  path: '[Core catalog]/Moments',
)
Widget catchCelebrationScreenCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchCelebrationScreen',
    catalogId: 'core.celebration.catch_celebration_screen',
    children: [
      _StateCard(
        label: 'full-screen moment',
        child: _PhoneFrame(
          height: 640,
          child: CatchCelebrationScreen(
            kind: CelebrationMomentKind.eventJoined,
            playEffects: false,
            eyebrow: 'You are in',
            title: 'Spot booked',
            message: 'We saved your place for Bandra easy 5K.',
            details: [
              CelebrationDetail(
                label: 'When',
                value: 'Tonight at 7:30 PM',
                icon: CatchIcons.calendarAdd,
              ),
              CelebrationDetail(
                label: 'Where',
                value: 'Carter Road promenade',
                icon: CatchIcons.pinOutlined,
              ),
            ],
            note: 'Matching opens after check-in.',
            primaryAction: CelebrationAction(
              label: 'View event',
              onPressed: _noop,
              icon: Icon(CatchIcons.eventOutlined),
            ),
            secondaryAction: CelebrationAction(
              label: 'Invite a friend',
              onPressed: _noop,
              icon: Icon(CatchIcons.share),
              variant: CatchButtonVariant.secondary,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'paper confirmation',
        child: _PhoneFrame(
          height: 740,
          child: CatchCelebrationScreen(
            kind: CelebrationMomentKind.eventCreated,
            playEffects: false,
            appearance: CatchCelebrationAppearance.paper,
            showCloseButton: false,
            icon: CatchIcons.verifiedRounded,
            eyebrow: 'Event created',
            title: 'Your event is live.',
            message:
                'Sundowner 5K, Bandra seafront is now listed on Sunday sea-face crew.',
            details: [
              CelebrationDetail(
                label: 'When',
                value: 'Sun, 22 Jun · 6:30 – 8:00 AM',
                icon: CatchIcons.calendarMonthOutlined,
              ),
              CelebrationDetail(
                label: 'Where',
                value: 'Carter Road jetty, Bandra West',
                icon: CatchIcons.locationOnOutlined,
              ),
              CelebrationDetail(
                label: 'Event',
                value: '5 km easy social run',
                icon: CatchIcons.directionsRunRounded,
              ),
              CelebrationDetail(
                label: 'Capacity',
                value: '10 attendees',
                icon: CatchIcons.groupOutlined,
              ),
            ],
            note:
                'Bookings, waitlist, and attendance are tracked from Manage event.',
            primaryAction: CelebrationAction(
              label: 'Manage event',
              onPressed: _noop,
            ),
            secondaryAction: CelebrationAction(
              label: 'Back to club',
              onPressed: _noop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: ResponsiveBuilder,
  path: '[Core catalog]/Layout',
)
Widget responsiveBuilderCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ResponsiveBuilder',
    catalogId: 'core.responsive.responsive_builder',
    children: [
      _StateCard(
        label: 'compact / medium / expanded',
        child: SizedBox(
          height: 120,
          child: ResponsiveBuilder(
            compact: (_) =>
                const CatchSurface.card(child: Text('Compact layout')),
            medium: (_) =>
                const CatchSurface.card(child: Text('Medium layout')),
            expanded: (_) =>
                const CatchSurface.card(child: Text('Expanded layout')),
          ),
        ),
      ),
    ],
  );
}

class _CatalogScreen extends StatelessWidget {
  const _CatalogScreen({
    required this.title,
    required this.catalogId,
    required this.children,
  });

  final String title;
  final String catalogId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: CatchTextStyles.headline(context)),
                gapH4,
                CatchMonoLabel(catalogId, color: t.ink3),
                gapH20,
                for (final child in children) ...[
                  child,
                  if (child != children.last) gapH16,
                ],
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
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchKicker(label: label, color: t.primary),
          if (description != null) ...[
            gapH6,
            Text(description!, style: CatchTextStyles.supporting(context)),
          ],
          gapH14,
          child,
        ],
      ),
    );
  }
}

class _InlineWrap extends StatelessWidget {
  const _InlineWrap({
    required this.children,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  });

  final List<Widget> children;
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child, this.height = 520});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.bg,
            border: Border.all(color: t.line2),
          ),
          child: SizedBox(width: 390, height: height, child: child),
        ),
      ),
    );
  }
}

class _ThumbnailBox extends StatelessWidget {
  const _ThumbnailBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.md),
      child: SizedBox(width: 180, height: 112, child: child),
    );
  }
}

class _GradeSample extends StatelessWidget {
  const _GradeSample({required this.label, required this.graded});

  final String label;
  final bool graded;

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.expand,
      children: [
        CatchActivityArt(
          activityKind: ActivityKind.dinner,
          height: 140,
          radius: 0,
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s3),
            child: CatchBadge(label: label, tone: CatchBadgeTone.neutral),
          ),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.md),
      child: SizedBox(
        width: 180,
        height: 120,
        child: CatchGradedImage(enabled: graded, child: child),
      ),
    );
  }
}

class _SearchFieldDemo extends StatefulWidget {
  const _SearchFieldDemo();

  @override
  State<_SearchFieldDemo> createState() => _SearchFieldDemoState();
}

class _SearchFieldDemoState extends State<_SearchFieldDemo> {
  var _value = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CatchSearchField(
          value: _value,
          placeholder: 'Search events',
          onChanged: (value) => setState(() => _value = value),
          emptyTrailingIcon: CatchIcons.tuneRounded,
          emptyTrailingTooltip: 'Open filters',
          onEmptyTrailingPressed: _noop,
        ),
        gapH12,
        CatchSearchField(
          value: 'Dinner',
          placeholder: 'Search hosts',
          onChanged: (_) {},
        ),
        gapH12,
        const CatchSearchField(
          value: 'Disabled',
          placeholder: 'Search',
          enabled: false,
        ),
      ],
    );
  }
}

class _SearchFieldExpansionDemo extends StatefulWidget {
  const _SearchFieldExpansionDemo();

  @override
  State<_SearchFieldExpansionDemo> createState() =>
      _SearchFieldExpansionDemoState();
}

class _SearchFieldExpansionDemoState extends State<_SearchFieldExpansionDemo> {
  var _open = false;
  var _value = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: CatchSearchField(
        mode: CatchSearchFieldMode.expanding,
        progress: _open ? 1 : 0,
        maxWidth: 420,
        value: _value,
        placeholder: 'Search clubs',
        onChanged: (value) => setState(() => _value = value),
        onOpenSearch: () => setState(() => _open = true),
        onCloseSearch: () => setState(() => _open = false),
      ),
    );
  }
}

class _OtpCodeFieldDemo extends StatefulWidget {
  const _OtpCodeFieldDemo();

  @override
  State<_OtpCodeFieldDemo> createState() => _OtpCodeFieldDemoState();
}

class _OtpCodeFieldDemoState extends State<_OtpCodeFieldDemo> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '48');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchOtpCodeField(
      controller: _controller,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) {},
    );
  }
}

class _RangeSliderDemo extends StatefulWidget {
  const _RangeSliderDemo();

  @override
  State<_RangeSliderDemo> createState() => _RangeSliderDemoState();
}

class _RangeSliderDemoState extends State<_RangeSliderDemo> {
  var _values = const RangeValues(24, 36);

  @override
  Widget build(BuildContext context) {
    return CatchRangeSlider(
      values: _values,
      min: 18,
      max: 60,
      divisions: 42,
      minLabel: '18',
      maxLabel: '60',
      onChanged: (values) => setState(() => _values = values),
      semanticFormatterCallback: (value) => '${value.round()} years',
    );
  }
}

class _OptionGroupDemo extends StatefulWidget {
  const _OptionGroupDemo();

  @override
  State<_OptionGroupDemo> createState() => _OptionGroupDemoState();
}

class _OptionGroupDemoState extends State<_OptionGroupDemo> {
  var _selected = 'tonight';
  var _mono = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CatchOptionGroup<String>(
          options: const [
            CatchOption(value: 'tonight', label: 'Tonight'),
            CatchOption(value: 'week', label: 'This week'),
            CatchOption(value: 'saved', label: 'Saved'),
          ],
          selected: _selected,
          onChanged: (value) => setState(() => _selected = value),
          trailing: CatchBadge(label: '12'),
        ),
        gapH16,
        CatchOptionGroup<String>(
          options: const [
            CatchOption(value: 'all', label: 'All'),
            CatchOption(value: 'hosts', label: 'Hosts'),
            CatchOption(value: 'clubs', label: 'Clubs'),
          ],
          selected: _mono,
          variant: CatchOptionGroupVariant.mono,
          onChanged: (value) => setState(() => _mono = value),
        ),
      ],
    );
  }
}

class _ChipFieldDemo extends StatefulWidget {
  const _ChipFieldDemo();

  @override
  State<_ChipFieldDemo> createState() => _ChipFieldDemoState();
}

class _ChipFieldDemoState extends State<_ChipFieldDemo> {
  var _multi = <_Choice>{_choices.first};
  var _single = <_Choice>{_choices[1]};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchChipField<_Choice>(
          label: 'Activities',
          values: _choices,
          selected: _multi,
          multiSelect: true,
          onChanged: (next) => setState(() => _multi = next),
        ),
        gapH16,
        CatchChipField<_Choice>(
          label: 'One vibe',
          values: _choices,
          selected: _single,
          multiSelect: false,
          isOptional: true,
          allowEmptySingleSelection: true,
          onChanged: (next) => setState(() => _single = next),
        ),
      ],
    );
  }
}

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  var _on = true;
  var _off = false;

  @override
  Widget build(BuildContext context) {
    return _InlineWrap(
      children: [
        CatchToggle(
          value: _on,
          onChanged: (value) => setState(() => _on = value),
        ),
        CatchToggle(
          value: _off,
          onChanged: (value) => setState(() => _off = value),
        ),
        const CatchToggle(value: true, onChanged: null),
      ],
    );
  }
}

class _TabDockDemo extends StatefulWidget {
  const _TabDockDemo();

  @override
  State<_TabDockDemo> createState() => _TabDockDemoState();
}

class _TabDockDemoState extends State<_TabDockDemo> {
  var _active = 'home';

  @override
  Widget build(BuildContext context) {
    return CatchTabDock<String>(
      active: _active,
      onChanged: (value) => setState(() => _active = value),
      items: [
        CatchTabDockItem(
          id: 'home',
          icon: CatchIcons.homeOutlined,
          activeIcon: CatchIcons.homeRounded,
          label: 'Home',
        ),
        CatchTabDockItem(
          id: 'explore',
          icon: CatchIcons.search,
          label: 'Explore',
          badgeCount: 3,
        ),
        CatchTabDockItem(
          id: 'chats',
          icon: CatchIcons.chatBubbleOutlineRounded,
          label: 'Chats',
          badgeCount: 12,
        ),
      ],
    );
  }
}

class _Choice implements Labelled {
  const _Choice(this.label);

  @override
  final String label;
}

Widget _textData(String value) => CatchSurface.card(child: Text(value));

Widget _sliverTextData(String value) => SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(CatchSpacing.s4),
    child: CatchSurface.card(child: Text(value)),
  ),
);

void _noop() {}

void _ignoreString(String _) {}
