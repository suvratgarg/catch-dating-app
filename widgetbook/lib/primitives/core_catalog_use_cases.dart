import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_art.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_cta.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_browse_header.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_callout.dart';
import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_day_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_row.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_draggable_sheet_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_expanding_search.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_framework_error_view.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_info_group.dart';
import 'package:catch_dating_app/core/widgets/catch_info_row.dart';
import 'package:catch_dating_app/core/widgets/catch_journey_steps.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_page_dots.dart';
import 'package:catch_dating_app/core/widgets/catch_panel.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_privacy_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_card.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_label.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_select_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_settings_row.dart';
import 'package:catch_dating_app/core/widgets/catch_share_card_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_soft_band.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_status_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_vertical_section.dart';
import 'package:catch_dating_app/core/widgets/catch_viewport_curve_frame.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_ticket_surface.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_visual_atoms.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_tile.dart';
import 'package:flutter/material.dart';
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

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSelectMenu,
  path: '[Core catalog]/Inputs',
)
Widget catchSelectMenuCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSelectMenu',
    catalogId: 'core.widgets.catch_select_menu',
    children: [
      _StateCard(
        label: 'md rounded',
        description: 'Tap to inspect the shared popup panel.',
        child: _FieldWidth(
          child: CatchSelectMenu<_Choice>(
            values: _choices,
            value: _choices.first,
            itemLabel: (item) => item.label,
            prefixIcon: Icon(CatchIcons.eventOutlined),
            onChanged: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'compact pill / empty',
        child: _FieldWidth(
          child: CatchSelectMenu<_Choice>(
            values: _choices,
            hintText: 'Activity',
            itemLabel: (item) => item.label,
            size: CatchSelectMenuSize.compact,
            shape: CatchSelectMenuShape.pill,
            prefixIcon: Icon(CatchIcons.tuneRounded),
            onChanged: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'error and disabled',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchSelectMenu<_Choice>(
              values: _choices,
              hintText: 'Required',
              hasError: true,
              itemLabel: (item) => item.label,
              onChanged: (_) {},
            ),
            gapH12,
            CatchSelectMenu<_Choice>(
              values: _choices,
              value: _choices[1],
              enabled: false,
              itemLabel: (item) => item.label,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchDropdownField,
  path: '[Core catalog]/Inputs',
)
Widget catchDropdownFieldCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchDropdownField',
    catalogId: 'core.widgets.catch_dropdown_field',
    children: [
      _StateCard(
        label: 'selected',
        child: _FieldWidth(
          child: CatchDropdownField<_Choice>(
            label: 'Activity type',
            values: _choices,
            value: _choices.first,
            prefixIcon: Icon(CatchIcons.eventOutlined),
            onChanged: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'optional empty',
        child: _FieldWidth(
          child: CatchDropdownField<_Choice>(
            label: 'Vibe',
            values: _choices,
            isOptional: true,
            hintText: 'Pick a vibe',
            onChanged: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'validation error',
        child: _FieldWidth(
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: CatchDropdownField<_Choice>(
              label: 'Required choice',
              values: _choices,
              onChanged: (_) {},
              validator: (value) => value == null ? 'Choose an option' : null,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSearchField,
  path: '[Core catalog]/Search',
)
Widget catchSearchFieldCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSearchField',
    catalogId: 'core.widgets.catch_search_field',
    children: const [
      _StateCard(label: 'empty / value / disabled', child: _SearchFieldDemo()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchExpandingSearch,
  path: '[Core catalog]/Search',
)
Widget catchExpandingSearchCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchExpandingSearch',
    catalogId: 'core.widgets.catch_expanding_search',
    children: const [
      _StateCard(label: 'collapsed / expanded', child: _ExpandingSearchDemo()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchBrowseHeader,
  path: '[Core catalog]/Search',
)
Widget catchBrowseHeaderCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchBrowseHeader',
    catalogId: 'core.widgets.catch_browse_header',
    children: const [
      _StateCard(
        label: 'title with expanding search',
        child: _BrowseHeaderDemo(),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchPanel,
  path: '[Core catalog]/Surfaces',
)
Widget catchPanelCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchPanel',
    catalogId: 'core.widgets.catch_panel',
    children: [
      _StateCard(
        label: 'default / primary soft / tappable',
        child: _InlineWrap(
          children: [
            const CatchPanel(width: 220, child: Text('Default bounded group')),
            CatchPanel(
              width: 220,
              tone: CatchSurfaceTone.primarySoft,
              child: Text(
                'Primary soft note',
                style: CatchTextStyles.bodyM(context),
              ),
            ),
            CatchPanel(
              width: 220,
              borderColor: t.primary,
              onTap: _noop,
              child: const Text('Tappable panel'),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSoftBand,
  path: '[Core catalog]/Surfaces',
)
Widget catchSoftBandCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSoftBand',
    catalogId: 'core.widgets.catch_soft_band',
    children: [
      _StateCard(
        label: 'privacy note',
        child: CatchSoftBand(
          child: Text(
            'Only attendees can see this matching detail.',
            style: CatchTextStyles.bodyS(context),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchKicker,
  path: '[Core catalog]/Typography',
)
Widget catchKickerCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchKicker',
    catalogId: 'core.widgets.catch_kicker',
    children: [
      _StateCard(
        label: 'md / lg / tinted / truncated',
        child: _InlineWrap(
          children: [
            const CatchKicker(label: 'Today'),
            CatchKicker(
              label: 'Featured format',
              size: CatchKickerSize.lg,
              color: t.primary,
            ),
            const SizedBox(
              width: 120,
              child: CatchKicker(label: 'Very long metadata label'),
            ),
          ],
        ),
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
  type: CatchFieldGroup,
  path: '[Core catalog]/Inputs',
)
Widget catchFieldGroupCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchFieldGroup',
    catalogId: 'core.widgets.catch_field_group',
    children: [
      _StateCard(
        label: 'read / nav / toggle',
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
        label: 'mixed edit / error / add',
        child: _FieldWidth(
          child: CatchFieldGroup(
            children: [
              CatchField(
                label: 'Display name',
                initialValue: 'Suvrat',
                icon: CatchIcons.personOutlined,
                mode: CatchFieldMode.edit,
              ),
              const CatchField(
                label: 'Instagram',
                value: '@catch.events',
                leadingUnit: '@',
                mode: CatchFieldMode.read,
                error: 'Handle is already in use',
              ),
              CatchField(
                label: 'Add website',
                icon: CatchIcons.addRounded,
                add: true,
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
  name: 'Catalog states',
  type: CatchCodeInput,
  path: '[Core catalog]/Inputs',
)
Widget catchCodeInputCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchCodeInput',
    catalogId: 'core.widgets.catch_code_input',
    children: const [
      _StateCard(
        label: 'empty / partial / complete',
        child: Column(
          children: [
            CatchCodeInput(value: '', active: 0),
            SizedBox(height: CatchSpacing.s3),
            CatchCodeInput(value: '482', active: 3),
            SizedBox(height: CatchSpacing.s3),
            CatchCodeInput(value: '482913'),
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

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchNumberStepper,
  path: '[Core catalog]/Inputs',
)
Widget catchNumberStepperCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchNumberStepper',
    catalogId: 'core.widgets.catch_number_stepper',
    children: const [
      _StateCard(label: 'interactive', child: _NumberStepperDemo()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchRangeSlider,
  path: '[Core catalog]/Inputs',
)
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
  type: CatchOptionGroup,
  path: '[Core catalog]/Selection',
)
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

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchToggle,
  path: '[Core catalog]/Selection',
)
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
                  child: CatchPanel(child: Text('Result ${index + 1}')),
                ),
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
  type: CatchStepHeader,
  path: '[Core catalog]/Navigation',
)
Widget catchStepHeaderCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchStepHeader',
    catalogId: 'core.widgets.catch_step_header',
    children: [
      _StateCard(
        label: 'header / compatibility wrapper',
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
            gapH16,
            const CatchStepFlowHeader(
              title: 'Profile setup',
              subtitle: 'Zero-based wrapper',
              currentStep: 1,
              totalSteps: 4,
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

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchTabDock,
  path: '[Core catalog]/Navigation',
)
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
  type: CatchSkeleton,
  path: '[Core catalog]/Loading',
)
Widget catchSkeletonCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSkeleton',
    catalogId: 'core.widgets.catch_skeleton',
    children: [
      _StateCard(
        label: 'card / box / text / textBlock / circle / custom',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatchSkeleton.card(height: 84),
            gapH12,
            CatchSkeleton.box(
              width: 96,
              height: CatchSpacing.s5,
              radius: CatchRadius.pill,
            ),
            gapH12,
            CatchSkeleton.text(width: 180),
            gapH12,
            CatchSkeleton.textBlock(lines: 3),
            gapH12,
            Row(
              children: [
                CatchSkeleton.circle(size: 48),
                gapW12,
                Expanded(
                  child: CatchSkeleton.custom(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(CatchRadius.pill),
                      ),
                    ),
                  ),
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
              data: (value) => CatchPanel(child: Text(value)),
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
                    child: CatchPanel(child: Text(value)),
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
  type: CatchErrorState,
  path: '[Core catalog]/Feedback',
)
Widget catchErrorStateCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'Error surfaces',
    catalogId: 'core.widgets.catch_error_state',
    children: [
      _StateCard(
        label: 'content modes',
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: CatchErrorState(
                title: 'Unable to load events',
                message: 'Check your connection and try again.',
                onRetry: _noop,
              ),
            ),
            gapH12,
            CatchErrorState(
              title: 'Section failed',
              message: 'The recommendations rail could not refresh.',
              mode: CatchErrorStateMode.inline,
              onRetry: _noop,
            ),
            gapH12,
            CatchErrorState(
              title: 'Not available',
              message: 'This event is no longer open.',
              mode: CatchErrorStateMode.compact,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'root wrapper',
        child: SizedBox(
          height: 360,
          child: CatchErrorScaffold(
            title: 'Profile unavailable',
            message: 'We could not load this profile right now.',
            onRetry: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'sliver placement adapter',
        child: SizedBox(
          height: 360,
          child: CustomScrollView(
            slivers: [
              CatchSliverErrorState(
                title: 'Feed unavailable',
                message: 'Try refreshing the feed.',
                onRetry: _noop,
                fillRemaining: false,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'inline placement adapter',
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
  type: CatchNotice,
  path: '[Core catalog]/Feedback',
)
Widget catchNoticeCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchNotice',
    catalogId: 'core.widgets.catch_notice',
    children: [
      _StateCard(
        label: 'tones / action / persistent',
        child: Column(
          children: [
            CatchNotice(
              notice: CatchNoticeData(
                id: 'status',
                title: 'Event updated',
                message: 'The start time moved to 7:30 PM.',
                tone: CatchNoticeTone.status,
                actionLabel: 'View',
                onAction: _noop,
              ),
              onDismiss: _noop,
            ),
            gapH12,
            const CatchNotice(notice: CatchNoticeData.offline()),
            gapH12,
            CatchNotice(
              notice: const CatchNoticeData(
                id: 'success',
                title: 'Booking confirmed',
                tone: CatchNoticeTone.success,
              ),
              onDismiss: _noop,
            ),
          ],
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
            child: CatchPanel(
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
  type: CatchEmptyState,
  path: '[Core catalog]/Feedback',
)
Widget catchEmptyStateCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchEmptyState',
    catalogId: 'core.widgets.catch_empty_state',
    children: [
      _StateCard(
        label: 'stacked / inline / surface',
        child: Column(
          children: [
            CatchEmptyState(
              icon: CatchIcons.eventOutlined,
              title: 'No events yet',
              message: 'Follow a host to see upcoming plans.',
              action: CatchButton(label: 'Explore hosts', onPressed: _noop),
            ),
            gapH12,
            CatchEmptyState(
              icon: CatchIcons.search,
              title: 'No matches',
              message: 'Try widening your filters.',
              layout: CatchEmptyStateLayout.inline,
            ),
            gapH12,
            CatchEmptyState(
              icon: CatchIcons.group,
              title: 'Private roster',
              message: 'Attendees appear after you join.',
              surface: true,
              iconStyle: CatchEmptyStateIconStyle.bubble,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchCallout,
  path: '[Core catalog]/Feedback',
)
Widget catchCalloutCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchCallout',
    catalogId: 'core.widgets.catch_callout',
    children: [
      _StateCard(
        label: 'tones',
        child: Column(
          children: [
            CatchCallout(
              title: 'Host tip',
              message: 'Keep the first message short and specific.',
            ),
            SizedBox(height: CatchSpacing.s3),
            CatchCallout(
              message: 'This event is nearly full.',
              tone: CatchCalloutTone.warning,
            ),
            SizedBox(height: CatchSpacing.s3),
            CatchCallout(
              message: 'Payment details are encrypted.',
              tone: CatchCalloutTone.success,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchActivityArt,
  path: '[Core catalog]/Activity',
)
Widget catchActivityArtCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchActivityArt',
    catalogId: 'core.widgets.catch_activity_art',
    children: [
      _StateCard(
        label: 'activity kinds / dim / overlay child',
        child: Column(
          children: [
            for (final kind in _activitySamples) ...[
              CatchActivityArt(
                activityKind: kind,
                height: 118,
                dim: kind == ActivityKind.dinner,
                child: Padding(
                  padding: const EdgeInsets.all(CatchSpacing.s4),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      kind.label,
                      style: CatchTextStyles.titleL(
                        context,
                        color: CatchTokens.editorialLight,
                      ),
                    ),
                  ),
                ),
              ),
              if (kind != _activitySamples.last) gapH12,
            ],
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchActivityAvatar,
  path: '[Core catalog]/Activity',
)
Widget catchActivityAvatarCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchActivityAvatar',
    catalogId: 'core.widgets.catch_activity_avatar',
    children: [
      _StateCard(
        label: 'resting / ring / dim',
        child: _InlineWrap(
          children: [
            CatchActivityAvatar(
              activityKind: ActivityKind.socialRun,
              initials: 'SG',
            ),
            CatchActivityAvatar(
              activityKind: ActivityKind.pickleball,
              initials: 'AK',
              ring: true,
            ),
            CatchActivityAvatar(
              activityKind: ActivityKind.dinner,
              initials: 'RM',
              dim: true,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchActivityChip,
  path: '[Core catalog]/Activity',
)
Widget catchActivityChipCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchActivityChip',
    catalogId: 'core.widgets.catch_activity_chip',
    children: [
      _StateCard(
        label: 'soft / primary / override label',
        child: _InlineWrap(
          children: [
            CatchActivityChip(
              activityKind: ActivityKind.socialRun,
              onTap: _noop,
            ),
            CatchActivityChip(
              activityKind: ActivityKind.pickleball,
              primary: true,
              onTap: _noop,
            ),
            const CatchActivityChip(
              activityKind: ActivityKind.dinner,
              label: 'Dinner crew',
            ),
          ],
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

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchDistanceRing,
  path: '[Core catalog]/Activity',
)
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
  type: CatchEventTicketCard,
  path: '[Core catalog]/Event cards',
)
Widget catchEventTicketCardCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchEventTicketCard',
    catalogId: 'core.widgets.catch_event_ticket_card',
    children: [
      _StateCard(
        label: 'ticket / status / compact width',
        child: _InlineWrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            CatchEventTicketCard(
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
            CatchEventTicketCard(
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
            CatchBottomCta(
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
            CatchBottomCta(
              label: 'Cancel booking',
              onPressed: _noop,
              leadingContent: const BookedLeading(),
            ),
            gapH12,
            CatchBottomCta(label: 'Join waitlist', onPressed: _noop),
            gapH12,
            const CatchBottomCta(
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
  type: CatchEventSpotlightCard,
  path: '[Core catalog]/Event cards',
)
Widget catchEventSpotlightCardCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchEventSpotlightCard',
    catalogId: 'core.widgets.catch_event_spotlight_card',
    children: [
      _StateCard(
        label: 'featured',
        child: CatchEventSpotlightCard(
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
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchMetricStrip,
  path: '[Core catalog]/Data display',
)
Widget catchMetricStripCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchMetricStrip',
    catalogId: 'core.widgets.catch_metric_strip',
    children: [
      _StateCard(
        label: 'detail metrics',
        child: CatchMetricStrip(
          items: const [
            CatchMetricStripItem(value: '24', label: 'going'),
            CatchMetricStripItem(value: '4', label: 'left'),
            CatchMetricStripItem(value: '2.4', unit: 'km', label: 'away'),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchStatStrip,
  path: '[Core catalog]/Data display',
)
Widget catchStatStripCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchStatStrip',
    catalogId: 'core.widgets.catch_stat_strip',
    children: [
      _StateCard(
        label: '2-4 cells',
        child: CatchStatStrip(
          items: [
            CatchStatStripItem(value: '24', label: 'Members'),
            CatchStatStripItem(value: '6', label: 'Events'),
            CatchStatStripItem(value: '92%', label: 'Show rate'),
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
        label: 'plain / highlighted / centered',
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
  type: CatchRosterTiles,
  path: '[Core catalog]/Host operations',
)
Widget catchRosterTilesCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchRosterTiles',
    catalogId: 'hosts.widgets.catch_roster_tiles',
    children: [
      _StateCard(
        label: 'selected filters',
        child: CatchRosterTiles(
          selected: 'checked',
          onSelect: _ignoreString,
          items: const [
            CatchRosterTile(
              id: 'booked',
              value: '24',
              label: 'Booked',
              tone: CatchBadgeTone.neutral,
            ),
            CatchRosterTile(
              id: 'checked',
              value: '18',
              label: 'Checked',
              tone: CatchBadgeTone.success,
            ),
            CatchRosterTile(
              id: 'attention',
              value: '3',
              label: 'Needs help',
              tone: CatchBadgeTone.warning,
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'read-only summary',
        child: CatchRosterTiles(
          selected: 'waitlist',
          items: [
            CatchRosterTile(
              id: 'waitlist',
              value: '7',
              label: 'Waitlist',
              tone: CatchBadgeTone.gold,
            ),
            CatchRosterTile(
              id: 'declined',
              value: '2',
              label: 'Declined',
              tone: CatchBadgeTone.danger,
            ),
            CatchRosterTile(
              id: 'empty',
              value: '0',
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
  name: 'Catalog states',
  type: CatchRosterRow,
  path: '[Core catalog]/Host operations',
)
Widget catchRosterRowCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchRosterRow',
    catalogId: 'hosts.widgets.catch_roster_row',
    children: [
      _StateCard(
        label: 'button / badge / text actions',
        child: SizedBox(
          width: 620,
          child: Column(
            children: [
              CatchRosterRow(
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
              const CatchRosterRow(
                person: 'Kabir Mehta',
                meta: 'Guest invite - +1',
                signal: 'Hosted',
                tone: CatchBadgeTone.gold,
                action: CatchRosterBadgeAction(
                  label: 'VIP',
                  tone: CatchBadgeTone.gold,
                ),
              ),
              const CatchRosterRow(
                person: 'Mira Shah',
                meta: 'Ticket refunded',
                signal: 'Cancelled',
                tone: CatchBadgeTone.danger,
                action: CatchRosterTextAction('Done'),
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'decision targets / disabled button',
        child: SizedBox(
          width: 620,
          child: Column(
            children: [
              CatchRosterRow(
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
              CatchRosterRow(
                person: 'Naina Bose',
                meta: 'Reminder already sent',
                signal: 'Pending',
                tone: CatchBadgeTone.neutral,
                action: CatchRosterButtonAction(
                  label: 'Sent',
                  disabled: true,
                  onPressed: _noop,
                ),
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
  type: CatchRosterTable,
  path: '[Core catalog]/Host operations',
)
Widget catchRosterTableCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchRosterTable',
    catalogId: 'hosts.widgets.catch_roster_table',
    children: [
      _StateCard(
        label: 'populated table',
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
              action: CatchRosterBadgeAction(
                label: 'Closed',
                tone: CatchBadgeTone.neutral,
              ),
            ),
          ],
        ),
      ),
      const _StateCard(
        label: 'empty roster',
        child: CatchRosterTable(
          columns: ['Guest', 'Signal', 'Action'],
          showEmpty: true,
          emptyTitle: 'No guests in this view',
          emptyMessage:
              'Change the roster filter or wait for guests to join this event.',
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchBadge,
  path: '[Core catalog]/Status extras',
)
Widget catchStatusExtrasCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'Status atoms',
    catalogId: 'core.widgets.status_atoms',
    children: [
      _StateCard(
        label: 'privacy badge / sash / count pill / dot',
        child: _InlineWrap(
          children: [
            const CatchPrivacyBadge(),
            const CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.host),
            const CatchCornerSash(label: 'Hosted'),
            CatchCornerSash(
              label: "You're in",
              icon: CatchIcons.checkRounded,
              tone: CatchSashTone.success,
              alignment: CatchSashAlignment.topEnd,
            ),
            CatchCountPill(
              icon: CatchIcons.tuneRounded,
              label: 'Filters',
              badge: '3',
              onPressed: _noop,
            ),
            CatchStatusDot(color: t.success, borderColor: t.surface),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchPrivacyBadge,
  path: '[Core catalog]/Status extras',
)
Widget catchPrivacyBadgeCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchPrivacyBadge',
    catalogId: 'core.widgets.catch_privacy_badge',
    children: [
      _StateCard(
        label: 'visibility modes',
        child: _InlineWrap(
          children: [
            CatchPrivacyBadge(),
            CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.catchPrivate),
            CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.host),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchBottomCta,
  path: '[Core catalog]/Sheets and footers',
)
Widget catchBottomCtaCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchBottomCta',
    catalogId: 'core.widgets.catch_bottom_cta',
    children: [
      _StateCard(
        label: 'plain / leading / loading / disabled',
        child: Column(
          children: [
            CatchBottomCta(
              label: 'Join event',
              onPressed: _noop,
              catchLine: 'Matching opens after check-in',
              catchLineAccent: t.primary,
            ),
            gapH12,
            CatchBottomCta(
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
            CatchBottomCta(label: 'Joining', onPressed: _noop, isLoading: true),
            gapH12,
            const CatchBottomCta(label: 'Sold out', onPressed: null),
          ],
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
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchBottomSheetScaffold,
  path: '[Core catalog]/Sheets and footers',
)
Widget catchBottomSheetScaffoldCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchBottomSheetScaffold',
    catalogId: 'core.widgets.catch_bottom_sheet_scaffold',
    children: [
      _StateCard(
        label: 'plain / branded / action',
        child: Column(
          children: [
            CatchBottomSheetScaffold(
              title: 'Invite guests',
              subtitle: 'Share this event with people who fit the format.',
              badge: 'Host',
              action: CatchButton(
                label: 'Copy invite link',
                fullWidth: true,
                onPressed: _noop,
              ),
              child: const CatchSoftBand(child: Text('Invites close at 6 PM.')),
            ),
            gapH16,
            CatchBottomSheetScaffold(
              glyph: CatchIcons.sparkle,
              title: 'Good fit',
              subtitle: 'Guests will see this before joining.',
              child: const Text('Keep it social, specific, and short.'),
            ),
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
                CatchPanel(child: Text('Persistent map/list sheet content')),
                SizedBox(height: CatchSpacing.s3),
                CatchPanel(child: Text('Second row')),
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
          card: CatchPanel(
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
  type: CatchSectionCard,
  path: '[Core catalog]/Sections',
)
Widget catchSectionCardCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSectionCard',
    catalogId: 'core.widgets.catch_section_card',
    children: [
      _StateCard(
        label: 'header / trailing / body-only',
        child: Column(
          children: [
            CatchSectionCard(
              title: 'Profile strength',
              subtitle: 'A few details help hosts place you.',
              trailing: const Text('72%'),
              child: CatchStepProgress(currentStep: 2, totalSteps: 4),
            ),
            gapH12,
            const CatchSectionCard(child: Text('Body-only content block')),
          ],
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
              CatchPanel(width: 136, child: Text('Card ${index + 1}')),
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
              CatchPanel(child: Text('List item ${index + 1}')),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchJourneySteps,
  path: '[Core catalog]/Sections',
)
Widget catchJourneyStepsCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CatchJourneySteps',
    catalogId: 'core.widgets.catch_journey_steps',
    children: [
      _StateCard(
        label: 'numbered trace',
        child: CatchJourneySteps(
          accent: t.primary,
          steps: const [
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
        label: 'compact titles only',
        child: CatchJourneySteps(
          accent: t.success,
          steps: const [
            CatchJourneyStep(title: 'Arrive'),
            CatchJourneyStep(title: 'Check in'),
            CatchJourneyStep(title: 'Start matching'),
          ],
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
  type: CatchScreenBody,
  path: '[Core catalog]/Sections',
)
Widget catchScreenBodyCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchScreenBody',
    catalogId: 'core.widgets.catch_screen_body',
    children: [
      _StateCard(
        label: 'scrolling body gutter',
        child: _PhoneFrame(
          height: 420,
          child: CatchScreenBody(
            child: CatchSectionList(
              gap: CatchGaps.section,
              children: const [
                CatchPanel(child: Text('Screen gutter is owned by the body.')),
                CatchPanel(
                  child: Text('Content can scroll without rebuilding insets.'),
                ),
                CatchPanel(child: Text('Bottom padding stays tokenized.')),
              ],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'non-scroll / no gutter',
        child: CatchScreenBody(
          scrollable: false,
          gutter: false,
          pt: 0,
          pb: 0,
          child: const CatchPanel(
            child: Text('Embedded bodies can opt out of scroll and gutter.'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSectionStack,
  path: '[Core catalog]/Sections',
)
Widget catchSectionStackCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSectionStack',
    catalogId: 'core.widgets.catch_section_stack',
    children: [
      _StateCard(
        label: 'handoff section rhythm',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          children: const [
            CatchDesignSection(
              first: true,
              lead: true,
              activityKind: ActivityKind.dinner,
              kicker: 'Room',
              count: 2,
              child: CatchPanel(child: Text('Lead section keeps no top rule.')),
            ),
            CatchDesignSection(
              kicker: 'Guests',
              count: 24,
              child: CatchPanel(child: Text('Next sections own the divider.')),
            ),
            CatchDesignSection(
              kicker: 'Follow up',
              child: CatchPanel(child: Text('No ad-hoc gaps needed.')),
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'custom inserted gap',
        child: CatchSectionStack(
          padding: EdgeInsets.zero,
          gap: CatchSpacing.s3,
          children: const [
            CatchPanel(child: Text('First plain section block')),
            CatchPanel(child: Text('Second block with explicit stack gap')),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchDesignSection,
  path: '[Core catalog]/Sections',
)
Widget catchSectionLayoutCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'Section layout primitives',
    catalogId: 'core.widgets.catch_section_layout',
    children: [
      _StateCard(
        label: 'page body / section stack / design section',
        child: SizedBox(
          height: 320,
          child: CatchScreenBody(
            child: CatchSectionStack(
              padding: EdgeInsets.zero,
              children: [
                CatchDesignSection(
                  first: true,
                  lead: true,
                  activityKind: ActivityKind.socialRun,
                  kicker: 'Format',
                  count: 3,
                  child: const Text('Section-owned rhythm and divider rules.'),
                ),
                const CatchDesignSection(
                  kicker: 'Details',
                  child: Text('A second section with the standard separator.'),
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
                      child: CatchPanel(
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

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchDetailRow,
  path: '[Core catalog]/Rows',
)
Widget catchDetailRowCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchDetailRow',
    catalogId: 'core.widgets.catch_detail_row',
    children: [
      _StateCard(
        label: 'label/value rows',
        child: Column(
          children: [
            CatchDetailRow(label: 'Order', value: 'CH-1024'),
            SizedBox(height: CatchSpacing.s2),
            CatchDetailRow(label: 'Refund', value: 'Available until Fri 6 PM'),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchInfoRow,
  path: '[Core catalog]/Rows',
)
Widget catchInfoRowCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchInfoRow',
    catalogId: 'core.widgets.catch_info_row',
    children: [
      _StateCard(
        label: 'inline / stacked / toggle / add / danger',
        child: Column(
          children: [
            CatchInfoRow(
              icon: CatchIcons.personOutlined,
              label: 'Display name',
              value: 'Suvrat',
              trailing: CatchInfoRowTrailing.chevron,
              onTap: _noop,
            ),
            CatchInfoRow(
              icon: CatchIcons.eventOutlined,
              caption: 'Next event',
              label: 'Bandra easy 5K',
              value: 'Tonight',
              divider: true,
            ),
            CatchInfoRow(
              label: 'Allow host messages',
              trailing: CatchInfoRowTrailing.toggle,
              toggleValue: true,
              onToggleChanged: (_) {},
              divider: true,
            ),
            CatchInfoRow(label: 'Add phone number', add: true, divider: true),
            CatchInfoRow(
              icon: CatchIcons.deleteOutline,
              label: 'Delete account',
              danger: true,
              divider: true,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchInfoGroup,
  path: '[Core catalog]/Rows',
)
Widget catchInfoGroupCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchInfoGroup',
    catalogId: 'core.widgets.catch_info_group',
    children: [
      _StateCard(
        label: 'grouped rows',
        child: CatchInfoGroup(
          title: 'Account',
          rows: [
            CatchInfoRow(
              icon: CatchIcons.phoneOutlined,
              label: 'Phone',
              value: '+91 98765 43210',
            ),
            CatchInfoRow(
              icon: CatchIcons.lockOutlineRounded,
              label: 'Privacy',
              value: 'Private',
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchSettingsRow,
  path: '[Core catalog]/Rows',
)
Widget catchSettingsRowCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchSettingsRow',
    catalogId: 'core.widgets.catch_settings_row',
    children: [
      _StateCard(
        label: 'value / chevron / trailing / danger',
        child: Column(
          children: [
            CatchSettingsRow(
              icon: CatchIcons.phoneOutlined,
              label: 'Phone',
              value: '+91 98765 43210',
              onTap: _noop,
            ),
            CatchSettingsRow(
              icon: CatchIcons.notificationsOutlined,
              label: 'Push alerts',
              trailing: CatchToggle(value: true, onChanged: (_) {}),
              divider: true,
            ),
            CatchSettingsRow(
              icon: CatchIcons.deleteOutline,
              label: 'Delete account',
              danger: true,
              onTap: _noop,
              divider: true,
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchPersonAvatar,
  path: '[Core catalog]/People',
)
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
  type: CatchPersonRow,
  path: '[Core catalog]/People',
)
Widget catchPersonRowCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchPersonRow',
    catalogId: 'core.widgets.catch_person_row',
    children: [
      _StateCard(
        label: 'roster / chat / fresh / trailing',
        child: Column(
          children: [
            CatchPersonRow(
              data: const CatchPersonRowData(
                name: 'Riya Shah',
                metaLine: '5:30 /km - 26',
                contextLine: 'Bandra easy 5K',
              ),
              trailing: const CatchBadge(label: 'Joined'),
              onTap: _noop,
            ),
            CatchPersonRow(
              data: const CatchPersonRowData(
                name: 'Aarav Kapoor',
                contextLine: 'Dinner for six',
                lastMessage: 'See you there.',
                timestamp: '2m',
                unreadCount: 2,
                isFresh: true,
              ),
              onTap: _noop,
            ),
            const CatchPersonRow(
              data: CatchPersonRowData(
                name: 'Maya Patel',
                lastMessage: 'Typing...',
                isTyping: true,
                timestamp: 'now',
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
  type: CatchStatusBar,
  path: '[Core catalog]/Device frames',
)
Widget catchStatusBarCatalogStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchStatusBar',
    catalogId: 'core.widgets.catch_status_bar',
    children: [
      _StateCard(
        label: 'light / dark / surface',
        child: Column(
          children: [
            CatchStatusBar(surface: true),
            SizedBox(height: CatchSpacing.s3),
            ColoredBox(
              color: CatchTokens.editorialDark,
              child: CatchStatusBar(tone: CatchStatusBarTone.dark),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catalog states',
  type: CatchViewportCurveFrame,
  path: '[Core catalog]/Device frames',
)
Widget catchViewportCurveFrameCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchViewportCurveFrame',
    catalogId: 'core.widgets.catch_viewport_curve_frame',
    children: [
      _StateCard(
        label: 'curved clipped media',
        child: SizedBox(
          width: 260,
          height: 360,
          child: CatchViewportCurveFrame(
            padding: const EdgeInsets.all(CatchSpacing.s3),
            child: CatchActivityArt(
              activityKind: ActivityKind.socialRun,
              height: 360,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(CatchSpacing.s4),
                  child: Text(
                    'Phone glass clip',
                    style: CatchTextStyles.titleL(
                      context,
                      color: CatchTokens.editorialLight,
                    ),
                  ),
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
  type: ProfileInfoTile,
  path: '[Core catalog]/Profile',
)
Widget profileInfoTileCatalogStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ProfileInfoTile',
    catalogId: 'user_profile.profile_info_tile',
    children: [
      _StateCard(
        label: 'read / add / expanded editor',
        child: Column(
          children: [
            ProfileInfoTile(
              icon: CatchIcons.personOutlined,
              label: 'Name',
              value: 'Suvrat',
              onTap: _noop,
            ),
            ProfileInfoTile(
              icon: CatchIcons.workOutline,
              label: 'Work',
              value: 'Add work',
              isAddAffordance: true,
              onTap: _noop,
            ),
            ProfileInlineDisclosure(
              isExpanded: true,
              header: ProfileInfoTile(
                icon: CatchIcons.editOutlined,
                label: 'Prompt',
                value: 'Two truths and a lie',
                isExpanded: true,
                onTap: _noop,
              ),
              body: CatchPanel(
                child: CatchTextButton(label: 'Save prompt', onPressed: _noop),
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
            compact: (_) => const CatchPanel(child: Text('Compact layout')),
            medium: (_) => const CatchPanel(child: Text('Medium layout')),
            expanded: (_) => const CatchPanel(child: Text('Expanded layout')),
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

class _FieldWidth extends StatelessWidget {
  const _FieldWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 320, child: child);
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

class _ExpandingSearchDemo extends StatefulWidget {
  const _ExpandingSearchDemo();

  @override
  State<_ExpandingSearchDemo> createState() => _ExpandingSearchDemoState();
}

class _ExpandingSearchDemoState extends State<_ExpandingSearchDemo> {
  var _open = false;
  var _value = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: CatchExpandingSearch(
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

class _BrowseHeaderDemo extends StatefulWidget {
  const _BrowseHeaderDemo();

  @override
  State<_BrowseHeaderDemo> createState() => _BrowseHeaderDemoState();
}

class _BrowseHeaderDemoState extends State<_BrowseHeaderDemo> {
  var _searchActive = false;
  var _value = '';

  @override
  Widget build(BuildContext context) {
    return CatchBrowseHeader(
      title: 'Clubs',
      subtitle: 'Hosts and communities near you',
      searchActive: _searchActive,
      searchValue: _value,
      onOpenSearch: () => setState(() => _searchActive = true),
      onCloseSearch: () => setState(() => _searchActive = false),
      onSearchChanged: (value) => setState(() => _value = value),
      actions: [
        CatchCountPill(
          icon: CatchIcons.tuneRounded,
          badge: '2',
          onPressed: _noop,
        ),
      ],
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

class _NumberStepperDemo extends StatefulWidget {
  const _NumberStepperDemo();

  @override
  State<_NumberStepperDemo> createState() => _NumberStepperDemoState();
}

class _NumberStepperDemoState extends State<_NumberStepperDemo> {
  var _value = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CatchNumberStepper(
          value: _value,
          min: 1,
          max: 12,
          formatValue: (value) => '$value seats',
          onChanged: (value) => setState(() => _value = value.toInt()),
        ),
        gapH12,
        const CatchNumberStepper(
          value: 1,
          min: 1,
          max: 3,
          enabled: false,
          formatValue: _formatDuration,
        ),
      ],
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

Widget _textData(String value) => CatchPanel(child: Text(value));

Widget _sliverTextData(String value) => SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(CatchSpacing.s4),
    child: CatchPanel(child: Text(value)),
  ),
);

String _formatDuration(num value) => '$value hr';

void _noop() {}

void _ignoreString(String _) {}
