import 'dart:async';

import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/auth/presentation/otp_page.dart';
import 'package:catch_dating_app/auth/presentation/phone_page.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/events/presentation/calendar/calendar_screen.dart';
import 'package:catch_dating_app/events/presentation/calendar/calendar_screen_state.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_preview.dart';
import 'package:catch_dating_app/event_policies/presentation/event_policy_lab_screen.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_state.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/force_update/data/app_version_config_provider.dart';
import 'package:catch_dating_app/force_update/data/force_update_provider.dart';
import 'package:catch_dating_app/force_update/domain/app_version_config.dart';
import 'package:catch_dating_app/force_update/presentation/update_required_screen.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/profile_photo_editor_screen.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/photo_slot.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/labs/design_fixtures/utility_surface_fixtures.dart';
import 'package:catch_dating_app/launch_access/data/launch_access_config_provider.dart';
import 'package:catch_dating_app/launch_access/data/launch_access_repository.dart';
import 'package:catch_dating_app/launch_access/domain/launch_access_application.dart';
import 'package:catch_dating_app/launch_access/domain/launch_access_config.dart';
import 'package:catch_dating_app/launch_access/presentation/launch_access_application_screen.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_state.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_state.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _viewerUid = UtilitySurfaceFixtures.viewerUid;
final _viewer = UtilitySurfaceFixtures.viewer;
final _event = UtilitySurfaceFixtures.event;
final _eventWithoutCoordinate = UtilitySurfaceFixtures.eventWithoutCoordinate;
final _payments = UtilitySurfaceFixtures.payments;
final _reviews = UtilitySurfaceFixtures.reviews;
final _notifications = UtilitySurfaceFixtures.notifications;
final _calendarNow = UtilitySurfaceFixtures.now;
final _calendarJoinedEvents = <Event>[
  _calendarEvent(
    id: 'calendar-joined-tomorrow',
    startTime: _calendarNow.add(const Duration(days: 1, hours: 9)),
    meetingPoint: 'Sea Face Social run',
    notes: 'Meet by the Bandra promenade entrance.',
    distanceKm: 5,
    bookedCount: 9,
  ),
  _calendarEvent(
    id: 'calendar-cancelled',
    startTime: _calendarNow.add(const Duration(days: 3, hours: 11)),
    meetingPoint: 'Rain check coffee walk',
    notes: 'Cancelled by the host after weather warnings.',
    distanceKm: 3,
    bookedCount: 8,
    status: EventLifecycleStatus.cancelled,
  ),
  _calendarEvent(
    id: 'calendar-past',
    startTime: _calendarNow.subtract(const Duration(days: 3, hours: 2)),
    meetingPoint: 'Past Sunday loop',
    notes: 'Completed last weekend.',
    distanceKm: 7,
    bookedCount: 11,
  ),
];
final _calendarSavedEvents = <Event>[
  _calendarEvent(
    id: 'calendar-saved-only',
    startTime: _calendarNow.add(const Duration(days: 5, hours: 10)),
    meetingPoint: 'Saved supper club',
    notes: 'Bookmark-only state for the agenda badge.',
    distanceKm: 0,
    bookedCount: 10,
    priceInPaise: 120000,
  ),
];
final _calendarSummary = CalendarEventSummary.from(
  signedUpEvents: _calendarJoinedEvents,
  savedEvents: _calendarSavedEvents,
  now: _calendarNow,
);
const _calendarWeekHeaderPreviewHeight = 150.0;
const _calendarMonthHeaderPreviewHeight = 360.0;
const _calendarClubNames = {'design-club': 'Sea Face Social'};
const double _utilityDeviceFrameMaxWidth = 390;
const double _utilityDeviceFrameHeight = 720;
const double _utilitySheetFrameHeight = 560;
const double _utilityDialogFrameHeight = 360;
const double _utilityPhotoSlotWidth = 168;
const double _utilityPhotoSlotHeight = 224;
const _forceUpdateConfig = AppVersionConfig(
  minVersion: '4.2.0',
  minBuildAndroid: 420,
  minBuildIos: 420,
  storeUrlAndroid: 'https://play.google.com/store/apps/details?id=catch.app',
  storeUrlIos: 'https://apps.apple.com/app/catch/id000000000',
);
const _eventPolicyScenarios = [
  EventPolicyPreviewCatalog.inviteOnlyPrivateEvent,
  EventPolicyPreviewCatalog.balancedRatioEvent,
  EventPolicyPreviewCatalog.demandPricedBalancedEvent,
  EventPolicyPreviewCatalog.membersOnlyEvent,
];
final _profilePhotos = ProfileSurfaceFixtures.profilePhotos(
  owner: _viewerUid,
  seed: 'utility',
);
final _orderedPhotoPreviews = [
  for (final photo in _profilePhotos.take(3))
    OrderedPhotoPreview(id: photo.id, imageUrl: photo.url),
];
final _launchPendingApplication = LaunchAccessApplication(
  uid: _viewerUid,
  status: LaunchAccessApplicationStatus.pending,
  city: 'in-mh-mumbai',
  role: LaunchAccessRole.both,
  eventTypes: const [
    LaunchAccessEventType.runClub,
    LaunchAccessEventType.coffee,
  ],
  availabilityWindows: const [
    LaunchAccessAvailabilityWindow.weekdayEvenings,
    LaunchAccessAvailabilityWindow.saturdayMornings,
  ],
  wantsToHost: true,
  inviteCode: 'BETA-MUMBAI',
  instagramHandle: 'neharuns',
  referralSource: 'Sea Face Social',
  whyCatch: 'I want more low-pressure ways to meet people around events.',
  submissionCount: 2,
  createdAt: _calendarNow.subtract(const Duration(days: 6)),
  submittedAt: _calendarNow.subtract(const Duration(days: 1)),
  updatedAt: _calendarNow.subtract(const Duration(days: 1)),
);
final _launchApprovedApplication = _launchPendingApplication.copyWith(
  status: LaunchAccessApplicationStatus.approvedForProfile,
  reviewedAt: _calendarNow,
);

@widgetbook.UseCase(
  name: 'Root shell',
  type: MyApp,
  path: '[P3 utility surfaces]/App root',
)
Widget myAppRootState(BuildContext context) {
  return const _UtilityCatalog(
    title: 'MyApp',
    contractId: 'app.root',
    children: [
      _StateCard(
        label: 'router shell with force-update pass-through',
        child: _DeviceFrame(child: _MyAppScope()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: AuthScreen,
  path: '[P3 utility surfaces]/Auth',
)
Widget authScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'AuthScreen',
    contractId: 'screen.auth.flow',
    children: [
      _StateCard(
        label: 'phone entry',
        child: _authFrame(child: const AuthScreen()),
      ),
      _StateCard(
        label: 'otp entry cooldown',
        child: _authFrame(
          mode: _AuthPreviewMode.otpEntry,
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'send code pending',
        child: _authFrame(
          mode: _AuthPreviewMode.sendCodePending,
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'send code error',
        child: _authFrame(
          mode: _AuthPreviewMode.sendCodeError,
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'verify code pending',
        child: _authFrame(
          mode: _AuthPreviewMode.verifyCodePending,
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'verify code error',
        child: _authFrame(
          mode: _AuthPreviewMode.verifyCodeError,
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'resend pending',
        child: _authFrame(
          mode: _AuthPreviewMode.resendPending,
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'resend error',
        child: _authFrame(
          mode: _AuthPreviewMode.resendError,
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'phone entry text scale 2',
        child: _authFrame(
          textScaler: const TextScaler.linear(2),
          child: const AuthScreen(),
        ),
      ),
      _StateCard(
        label: 'otp reduced motion',
        child: _authFrame(
          mode: _AuthPreviewMode.otpEntry,
          disableAnimations: true,
          child: const AuthScreen(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Phone entry states',
  type: PhonePage,
  path: '[P3 utility surfaces]/Auth',
)
Widget phonePageStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PhonePage',
    contractId: 'screen.auth.phone',
    children: [
      _StateCard(
        label: 'default country',
        child: _authFrame(child: const PhonePage()),
      ),
      _StateCard(
        label: 'send code pending',
        child: _authFrame(
          mode: _AuthPreviewMode.sendCodePending,
          child: const PhonePage(),
        ),
      ),
      _StateCard(
        label: 'send code error',
        child: _authFrame(
          mode: _AuthPreviewMode.sendCodeError,
          child: const PhonePage(),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: _authFrame(
          textScaler: const TextScaler.linear(2),
          child: const PhonePage(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Country code selector states',
  type: CountryCodeSelector,
  path: '[P3 utility surfaces]/Auth',
)
Widget countryCodeSelectorStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'CountryCodeSelector',
    contractId: 'component.auth.country_code_selector',
    children: [
      _StateCard(
        label: 'India default',
        child: Align(
          alignment: Alignment.centerLeft,
          child: CountryCodeSelector(countryCode: '+91', onChanged: _noopCode),
        ),
      ),
      _StateCard(
        label: 'US default',
        child: Align(
          alignment: Alignment.centerLeft,
          child: CountryCodeSelector(countryCode: '+1', onChanged: _noopCode),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'OTP entry states',
  type: OtpPage,
  path: '[P3 utility surfaces]/Auth',
)
Widget otpPageStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'OtpPage',
    contractId: 'screen.auth.otp',
    children: [
      _StateCard(
        label: 'verification code cooldown',
        child: _authFrame(
          mode: _AuthPreviewMode.otpEntry,
          child: const OtpPage(),
        ),
      ),
      _StateCard(
        label: 'verify pending',
        child: _authFrame(
          mode: _AuthPreviewMode.verifyCodePending,
          child: const OtpPage(),
        ),
      ),
      _StateCard(
        label: 'verify error',
        child: _authFrame(
          mode: _AuthPreviewMode.verifyCodeError,
          child: const OtpPage(),
        ),
      ),
      _StateCard(
        label: 'resend pending',
        child: _authFrame(
          mode: _AuthPreviewMode.resendPending,
          child: const OtpPage(),
        ),
      ),
      _StateCard(
        label: 'resend error',
        child: _authFrame(
          mode: _AuthPreviewMode.resendError,
          child: const OtpPage(),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: _authFrame(
          mode: _AuthPreviewMode.otpEntry,
          textScaler: const TextScaler.linear(2),
          child: const OtpPage(),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _authFrame(
          mode: _AuthPreviewMode.otpEntry,
          disableAnimations: true,
          child: const OtpPage(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: LaunchAccessApplicationScreen,
  path: '[P3 utility surfaces]/Launch access',
)
Widget launchAccessApplicationScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'LaunchAccessApplicationScreen',
    contractId: 'screen.launch_access.application',
    children: [
      _StateCard(
        label: 'gate disabled',
        child: _DeviceFrame(
          child: _LaunchAccessScope(
            config: LaunchAccessConfig.disabled,
            child: const LaunchAccessApplicationScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'uid loading',
        child: _DeviceFrame(
          child: _LaunchAccessScope(
            uidStream: UtilitySurfaceFixtures.loadingStream<String?>(),
            child: const LaunchAccessApplicationScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _LaunchAccessScope(
            uidStream: Stream<String?>.value(null),
            child: const LaunchAccessApplicationScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'new application',
        child: _DeviceFrame(
          child: IgnorePointer(
            child: _LaunchAccessScope(
              applicationStream: Stream.value(null),
              child: const LaunchAccessApplicationScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'approved status',
        child: _DeviceFrame(
          child: _LaunchAccessScope(
            applicationStream: Stream.value(_launchApprovedApplication),
            child: const LaunchAccessApplicationScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Form states',
  type: LaunchAccessApplicationForm,
  path: '[P3 utility surfaces]/Launch access',
)
Widget launchAccessApplicationFormStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'LaunchAccessApplicationForm',
    contractId: 'screen.launch_access.application.form',
    children: [
      _StateCard(
        label: 'blank application',
        child: const _DeviceFrame(
          child: IgnorePointer(
            child: _LaunchAccessScope(child: LaunchAccessApplicationForm()),
          ),
        ),
      ),
      _StateCard(
        label: 'seeded edit',
        child: _DeviceFrame(
          child: IgnorePointer(
            child: _LaunchAccessScope(
              child: LaunchAccessApplicationForm(
                application: _launchPendingApplication,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Grid states',
  type: PhotoGrid,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget photoGridStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PhotoGrid',
    contractId: 'component.image_uploads.photo_grid',
    children: [
      _StateCard(
        label: 'empty with first slot loading',
        child: PhotoGrid(
          profilePhotos: const [],
          loadingIndices: const {0},
          onSlotTapped: _noopIndex,
        ),
      ),
      _StateCard(
        label: 'filled editable grid',
        child: PhotoGrid(
          profilePhotos: _profilePhotos.take(4).toList(growable: false),
          onSlotTapped: _noopIndex,
          onDeletePhoto: _noopIndex,
          onReorderPhoto: _noopReorder,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Picker states',
  type: OrderedPhotoPicker,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget orderedPhotoPickerStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'OrderedPhotoPicker',
    contractId: 'component.image_uploads.ordered_photo_picker',
    children: [
      _StateCard(
        label: 'empty picker',
        child: OrderedPhotoPicker(
          label: Text(
            'Event photos',
            style: CatchTextStyles.sectionTitle(context),
          ),
          photos: const [],
          onAddPhotos: _noop,
          onRemovePhoto: _noopIndex,
          onReorderPhoto: _noopReorder,
          emptyActionLabel: 'Add event photos',
          addActionLabel: 'Add more',
        ),
      ),
      _StateCard(
        label: 'cover plus reorder',
        child: OrderedPhotoPicker(
          label: Text(
            'Club photos',
            style: CatchTextStyles.sectionTitle(context),
          ),
          photos: _orderedPhotoPreviews,
          onAddPhotos: _noop,
          onRemovePhoto: _noopIndex,
          onReorderPhoto: _noopReorder,
          emptyActionLabel: 'Add club photos',
          addActionLabel: 'Add more',
          showCoverBadge: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ordered tile states',
  type: OrderedPhotoTile,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget orderedPhotoTileStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'OrderedPhotoTile',
    contractId: 'component.image_uploads.ordered_photo_tile',
    children: [
      _StateCard(
        label: 'cover removable',
        child: Center(
          child: SizedBox(
            width: 260,
            height: 146,
            child: OrderedPhotoTile(
              photo: _orderedPhotoPreviews.first,
              index: 0,
              canReorder: true,
              showCoverBadge: true,
              showReorderHandle: true,
              onRemove: _noop,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'read only',
        child: Center(
          child: SizedBox(
            width: 260,
            height: 146,
            child: OrderedPhotoTile(
              photo: _orderedPhotoPreviews.last,
              index: 1,
              canReorder: false,
              showCoverBadge: false,
              showReorderHandle: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ordered add tile states',
  type: OrderedPhotoAddTile,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget orderedPhotoAddTileStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'OrderedPhotoAddTile',
    contractId: 'component.image_uploads.ordered_photo_add_tile',
    children: [
      _StateCard(
        label: 'active',
        child: Center(
          child: SizedBox(
            width: 260,
            height: 146,
            child: OrderedPhotoAddTile(label: 'Add event photos', onTap: _noop),
          ),
        ),
      ),
      _StateCard(
        label: 'disabled compact',
        child: Center(
          child: SizedBox(
            width: 160,
            height: 82,
            child: OrderedPhotoAddTile(label: 'Add more'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Slot states',
  type: PhotoSlot,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget photoSlotStates(BuildContext context) {
  final photo = _profilePhotos.first;
  return _UtilityCatalog(
    title: 'PhotoSlot',
    contractId: 'component.image_uploads.photo_slot',
    children: [
      _StateCard(
        label: 'active empty',
        child: _photoSlotFrame(
          child: PhotoSlot(
            index: 0,
            url: null,
            isLoading: false,
            isActive: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'uploading placeholder',
        child: _photoSlotFrame(
          child: PhotoSlot(
            index: 1,
            url: null,
            isLoading: true,
            isActive: true,
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'main photo with prompt',
        child: _photoSlotFrame(
          child: PhotoSlot(
            index: 0,
            url: photo.url,
            prompt: photo.prompt,
            badgeLabel: 'MAIN',
            isLoading: false,
            isActive: true,
            onTap: _noop,
            onDelete: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Main badge states',
  type: PhotoSlotMainBadge,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget photoSlotMainBadgeStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'PhotoSlotMainBadge',
    contractId: 'component.image_uploads.photo_slot_main_badge',
    children: [
      _StateCard(
        label: 'main badge',
        child: Align(
          alignment: Alignment.centerLeft,
          child: PhotoSlotMainBadge(label: 'MAIN'),
        ),
      ),
      _StateCard(
        label: 'cover badge',
        child: Align(
          alignment: Alignment.centerLeft,
          child: PhotoSlotMainBadge(label: 'Cover'),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Striped placeholder states',
  type: StripedPhotoPlaceholder,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget stripedPhotoPlaceholderStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'StripedPhotoPlaceholder',
    contractId: 'component.image_uploads.striped_photo_placeholder',
    children: [
      _StateCard(
        label: 'first slot',
        child: _photoSlotFrame(child: const StripedPhotoPlaceholder(index: 0)),
      ),
      _StateCard(
        label: 'sixth slot',
        child: _photoSlotFrame(child: const StripedPhotoPlaceholder(index: 5)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Editor states',
  type: ProfilePhotoEditorScreen,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget profilePhotoEditorScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ProfilePhotoEditorScreen',
    contractId: 'screen.image_uploads.profile_photo_editor',
    children: [
      _StateCard(
        label: 'existing photo editor',
        child: _DeviceFrame(
          child: IgnorePointer(
            child: _ProfilePhotoEditorScope(
              child: ProfilePhotoEditorScreen(
                index: 0,
                photo: _profilePhotos.first,
                canDelete: true,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Editor preview states',
  type: ProfilePhotoEditorPreview,
  path: '[P3 utility surfaces]/Image uploads',
)
Widget profilePhotoEditorPreviewStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ProfilePhotoEditorPreview',
    contractId: 'component.image_uploads.profile_photo_editor_preview',
    children: [
      _StateCard(
        label: 'existing image',
        child: Center(
          child: SizedBox(
            width: 260,
            height: 347,
            child: ProfilePhotoEditorPreview(
              cropKey: GlobalKey(),
              loading: false,
              url: _profilePhotos.first.url,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: Center(
          child: SizedBox(
            width: 260,
            height: 347,
            child: ProfilePhotoEditorPreview(
              cropKey: GlobalKey(),
              loading: true,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: Center(
          child: SizedBox(
            width: 260,
            height: 347,
            child: ProfilePhotoEditorPreview(
              cropKey: GlobalKey(),
              loading: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Gate states',
  type: ForceUpdateGate,
  path: '[P3 utility surfaces]/Force update',
)
Widget forceUpdateGateStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ForceUpdateGate',
    contractId: 'app.force_update.gate',
    children: [
      _StateCard(
        label: 'remote config loading',
        child: const _DeviceFrame(
          child: ForceUpdateGate(
            forceUpdate: AsyncLoading<bool>(),
            onRetry: _noop,
            refreshOnResume: false,
            child: _ForceUpdatePassThrough(),
          ),
        ),
      ),
      _StateCard(
        label: 'remote config error',
        child: _DeviceFrame(
          child: ForceUpdateGate(
            forceUpdate: AsyncError<bool>(
              StateError('Remote Config fetch failed'),
              StackTrace.empty,
            ),
            onRetry: _noop,
            refreshOnResume: false,
            child: const _ForceUpdatePassThrough(),
          ),
        ),
      ),
      _StateCard(
        label: 'update required',
        child: const _DeviceFrame(
          child: _ForceUpdateStoreScope(
            child: ForceUpdateGate(
              forceUpdate: AsyncData<bool>(true),
              onRetry: _noop,
              refreshOnResume: false,
              child: _ForceUpdatePassThrough(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'app content allowed',
        child: const _DeviceFrame(
          child: ForceUpdateGate(
            forceUpdate: AsyncData<bool>(false),
            onRetry: _noop,
            refreshOnResume: false,
            child: _ForceUpdatePassThrough(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Error state',
  type: ForceUpdateCheckErrorScreen,
  path: '[P3 utility surfaces]/Force update',
)
Widget forceUpdateCheckErrorScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ForceUpdateCheckErrorScreen',
    contractId: 'screen.force_update.check_error',
    children: [
      _StateCard(
        label: 'remote config check failed',
        child: _DeviceFrame(
          child: ForceUpdateCheckErrorScreen(
            error: StateError('Remote Config fetch failed'),
            onRetry: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: UpdateRequiredContent,
  path: '[P3 utility surfaces]/Force update',
)
Widget updateRequiredScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'UpdateRequiredContent',
    contractId: 'screen.force_update.required',
    children: [
      _StateCard(
        label: 'store link configured',
        child: const _DeviceFrame(
          child: UpdateRequiredContent(onUpdateNow: _noop),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: CalendarScreen,
  path: '[P3 utility surfaces]/Calendar',
)
Widget calendarScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarScreen',
    contractId: 'screen.calendar.home',
    children: [
      _StateCard(
        label: 'auth loading',
        child: _DeviceFrame(
          child: _CalendarScope(
            uidValue: const AsyncLoading<String?>(),
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out empty',
        child: _DeviceFrame(
          child: _CalendarScope(
            uidValue: const AsyncData<String?>(null),
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'events loading',
        child: _DeviceFrame(
          child: _CalendarScope(
            signedUpEventsValue: const AsyncLoading<List<Event>>(),
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'events error',
        child: _DeviceFrame(
          child: _CalendarScope(
            signedUpEventsValue: AsyncError<List<Event>>(
              StateError('Booked events failed'),
              StackTrace.empty,
            ),
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'empty planned events',
        child: _DeviceFrame(
          child: _CalendarScope(
            signedUpEventsValue: const AsyncData<List<Event>>([]),
            savedEventsValue: const AsyncData<List<Event>>([]),
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'club names loading',
        child: _DeviceFrame(
          child: _CalendarScope(
            clubNamesValue: const AsyncLoading<Map<String, String>>(),
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'club names error',
        child: _DeviceFrame(
          child: _CalendarScope(
            clubNamesValue: AsyncError<Map<String, String>>(
              StateError('Club names failed'),
              StackTrace.empty,
            ),
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'joined saved cancelled',
        child: _DeviceFrame(
          child: _CalendarScope(
            child: CalendarScreen(referenceNow: _calendarNow),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _CalendarScope(
              child: CalendarScreen(referenceNow: _calendarNow),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _CalendarScope(
              child: CalendarScreen(referenceNow: _calendarNow),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: Theme(
          data: AppTheme.dark,
          child: _DeviceFrame(
            child: _CalendarScope(
              child: CalendarScreen(referenceNow: _calendarNow),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Loading state',
  type: CalendarLoadingScreen,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarLoadingScreenStates(BuildContext context) {
  return const _DeviceFrame(child: Scaffold(body: CalendarLoadingScreen()));
}

@widgetbook.UseCase(
  name: 'Agenda section states',
  type: CalendarAgendaSliverSection,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarAgendaSliverSectionStates(BuildContext context) {
  final readyState = CalendarAgendaSectionState.from(
    summary: _calendarSummary,
    clubNames: const CalendarClubNameLookupState.ready(_calendarClubNames),
  );
  final emptyState = CalendarAgendaSectionState.from(
    summary: CalendarEventSummary.from(
      signedUpEvents: const <Event>[],
      savedEvents: const <Event>[],
      now: _calendarNow,
    ),
    clubNames: const CalendarClubNameLookupState.ready(_calendarClubNames),
  );

  Key dayKey(DateTime date) {
    return ValueKey<String>(
      'widgetbook-calendar-agenda-${date.toIso8601String()}',
    );
  }

  return _UtilityCatalog(
    title: 'CalendarAgendaSliverSection',
    contractId: 'component.calendar.agenda_section',
    children: [
      _StateCard(
        label: 'ready rows',
        child: SizedBox(
          height: _utilitySheetFrameHeight,
          child: CustomScrollView(
            slivers: [
              CalendarAgendaSliverSection(
                state: readyState,
                dayKeyBuilder: dayKey,
                onEventSelected: (_) {},
                onRetryClubNames: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'club names loading',
        child: SizedBox(
          height: _utilityDialogFrameHeight,
          child: CustomScrollView(
            slivers: [
              CalendarAgendaSliverSection(
                state: const CalendarAgendaClubNamesLoadingState(),
                dayKeyBuilder: dayKey,
                onEventSelected: (_) {},
                onRetryClubNames: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'club names error',
        child: SizedBox(
          height: _utilityDialogFrameHeight,
          child: CustomScrollView(
            slivers: [
              CalendarAgendaSliverSection(
                state: CalendarAgendaClubNamesErrorState(
                  StateError('Club names failed'),
                ),
                dayKeyBuilder: dayKey,
                onEventSelected: (_) {},
                onRetryClubNames: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: SizedBox(
          height: _utilityDialogFrameHeight,
          child: CustomScrollView(
            slivers: [
              CalendarAgendaSliverSection(
                state: emptyState,
                dayKeyBuilder: dayKey,
                onEventSelected: (_) {},
                onRetryClubNames: _noop,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Header states',
  type: CalendarDateHeader,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarDateHeaderStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarDateHeader',
    contractId: 'component.calendar.date_header',
    children: [
      _StateCard(
        label: 'week strip',
        child: SizedBox(
          height: _calendarWeekHeaderPreviewHeight,
          child: CalendarDateHeader(
            summary: _calendarSummary,
            selectedDate: _calendarSummary.anchorDate,
            expanded: false,
            onDateSelected: (_) {},
            onTodayPressed: _noop,
            onVerticalDragDelta: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'month grid',
        child: SizedBox(
          height: _calendarMonthHeaderPreviewHeight,
          child: CalendarDateHeader(
            summary: _calendarSummary,
            selectedDate: _calendarSummary.anchorDate,
            expanded: true,
            onDateSelected: (_) {},
            onTodayPressed: _noop,
            onVerticalDragDelta: (_) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton state',
  type: CalendarDateHeaderSkeleton,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarDateHeaderSkeletonStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarDateHeaderSkeleton',
    contractId: 'component.calendar.date_header_skeleton',
    children: const [
      _StateCard(label: 'loading', child: CalendarDateHeaderSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton state',
  type: CalendarWeekStripSkeleton,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarWeekStripSkeletonStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarWeekStripSkeleton',
    contractId: 'component.calendar.week_strip_skeleton',
    children: const [
      _StateCard(label: 'loading', child: CalendarWeekStripSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Title row state',
  type: CalendarTitleRow,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarTitleRowStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarTitleRow',
    contractId: 'component.calendar.title_row',
    children: [
      _StateCard(
        label: 'current month',
        child: CalendarTitleRow(title: 'July 2026', onTodayPressed: _noop),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stats state',
  type: CalendarStatsHeader,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarStatsHeaderStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarStatsHeader',
    contractId: 'component.calendar.stats_header',
    children: [
      _StateCard(
        label: 'joined saved cancelled',
        child: CalendarStatsHeader(summary: _calendarSummary),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton state',
  type: CalendarStatsHeaderSkeleton,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarStatsHeaderSkeletonStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarStatsHeaderSkeleton',
    contractId: 'component.calendar.stats_header_skeleton',
    children: const [
      _StateCard(label: 'loading', child: CalendarStatsHeaderSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton state',
  type: CalendarStatSkeleton,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarStatSkeletonStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarStatSkeleton',
    contractId: 'component.calendar.stat_skeleton',
    children: const [
      _StateCard(label: 'single stat', child: CalendarStatSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Week strip state',
  type: CalendarWeekStrip,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarWeekStripStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarWeekStrip',
    contractId: 'component.calendar.week_strip',
    children: [
      _StateCard(
        label: 'event markers',
        child: CalendarWeekStrip(
          summary: _calendarSummary,
          selectedDate: _calendarSummary.anchorDate,
          onDateSelected: (_) {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Month grid state',
  type: CalendarMonthGrid,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarMonthGridStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarMonthGrid',
    contractId: 'component.calendar.month_grid',
    children: [
      _StateCard(
        label: 'event markers',
        child: CalendarMonthGrid(
          summary: _calendarSummary,
          selectedDate: _calendarSummary.anchorDate,
          onDateSelected: (_) {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Divider state',
  type: CalendarStatDivider,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarStatDividerStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CalendarStatDivider',
    contractId: 'component.calendar.stat_divider',
    children: const [
      _StateCard(
        label: 'vertical rule',
        child: Center(child: CalendarStatDivider()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty message state',
  type: CalendarMessage,
  path: '[P3 utility surfaces]/Calendar/Components',
)
Widget calendarMessageStates(BuildContext context) {
  return const _DeviceFrame(
    child: Scaffold(
      body: CalendarMessage(
        title: 'No planned events yet',
        body: 'Events you book or save will show up here by day and time.',
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Scenario states',
  type: EventPolicyLabScreen,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyLabScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventPolicyLabScreen',
    contractId: 'screen.dev.event_policy_lab',
    children: [
      for (final scenario in _eventPolicyScenarios)
        _StateCard(
          label: scenario.title,
          child: _DeviceFrame(
            child: EventPolicyLabScreen(initialScenario: scenario),
          ),
        ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Header states',
  type: EventPolicyLabHeader,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyLabHeaderStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventPolicyLabHeader',
    contractId: 'screen.dev.event_policy_lab.header',
    children: [
      for (final scenario in _eventPolicyScenarios.take(2))
        _StateCard(
          label: scenario.title,
          child: EventPolicyLabHeader(scenario: scenario),
        ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Scenario picker',
  type: EventPolicyScenarioPicker,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyScenarioPickerState(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventPolicyScenarioPicker',
    contractId: 'screen.dev.event_policy_lab.scenario_picker',
    children: [
      _StateCard(
        label: 'scenario rail',
        child: EventPolicyScenarioPicker(
          selectedScenario: _eventPolicyScenarios.first,
          onSelected: _noopScenarioSelect,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Scenario card states',
  type: EventPolicyScenarioCard,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyScenarioCardStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventPolicyScenarioCard',
    contractId: 'screen.dev.event_policy_lab.scenario_card',
    children: [
      _StateCard(
        label: 'selected',
        child: EventPolicyScenarioCard(
          scenario: _eventPolicyScenarios.first,
          selected: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'unselected',
        child: EventPolicyScenarioCard(
          scenario: _eventPolicyScenarios.last,
          selected: false,
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Summary states',
  type: EventPolicySummary,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicySummaryStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventPolicySummary',
    contractId: 'screen.dev.event_policy_lab.summary',
    children: [
      for (final scenario in _eventPolicyScenarios.take(2))
        _StateCard(
          label: scenario.title,
          child: EventPolicySummary(scenario: scenario),
        ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Preview result rows',
  type: EventPolicyResultRows,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyResultRowsStates(BuildContext context) {
  final result = _eventPolicyResult(_eventPolicyScenarios.first);
  return _UtilityCatalog(
    title: 'EventPolicyResultRows',
    contractId: 'screen.dev.event_policy_lab.result_rows',
    children: [
      _StateCard(
        label: 'result list',
        child: EventPolicyResultRows(result: result),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Preview result row',
  type: EventPolicyResultRow,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyResultRowState(BuildContext context) {
  final row = _eventPolicyResult(_eventPolicyScenarios.first).rows.first;
  return _UtilityCatalog(
    title: 'EventPolicyResultRow',
    contractId: 'screen.dev.event_policy_lab.result_row',
    children: [
      _StateCard(
        label: row.probeLabel,
        child: EventPolicyResultRow(row: row),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cancellation rows',
  type: EventPolicyCancellationRows,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyCancellationRowsStates(BuildContext context) {
  final result = _eventPolicyResult(_eventPolicyScenarios.first);
  return _UtilityCatalog(
    title: 'EventPolicyCancellationRows',
    contractId: 'screen.dev.event_policy_lab.cancellation_rows',
    children: [
      _StateCard(
        label: 'cancellation list',
        child: EventPolicyCancellationRows(result: result),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cancellation row',
  type: EventPolicyCancellationRow,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyCancellationRowState(BuildContext context) {
  final row = _eventPolicyResult(
    _eventPolicyScenarios.first,
  ).cancellationRows.first;
  return _UtilityCatalog(
    title: 'EventPolicyCancellationRow',
    contractId: 'screen.dev.event_policy_lab.cancellation_row',
    children: [
      _StateCard(
        label: row.probeLabel,
        child: EventPolicyCancellationRow(row: row),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Debug output',
  type: EventPolicyDebugOutput,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyDebugOutputState(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventPolicyDebugOutput',
    contractId: 'screen.dev.event_policy_lab.debug_output',
    children: [
      _StateCard(
        label: 'debug map',
        child: EventPolicyDebugOutput(
          result: _eventPolicyResult(_eventPolicyScenarios.first),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Small primitives',
  type: EventPolicyLabSectionTitle,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicySmallPrimitiveStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventPolicy small primitives',
    contractId: 'screen.dev.event_policy_lab.small_primitives',
    children: [
      _StateCard(
        label: 'section title',
        child: EventPolicyLabSectionTitle(
          icon: CatchIcons.ruleRounded,
          title: 'Policy shape',
        ),
      ),
      _StateCard(
        label: 'summary line',
        child: EventPolicySummaryLine(
          icon: CatchIcons.queueOutlined,
          label: 'Waitlist',
          value: 'Balanced by cohort',
        ),
      ),
      _StateCard(
        label: 'divider',
        child: Builder(
          builder: (context) =>
              EventPolicyDividerLine(color: CatchTokens.of(context).line),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Summary line',
  type: EventPolicySummaryLine,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicySummaryLineState(BuildContext context) {
  return EventPolicySummaryLine(
    icon: CatchIcons.paymentsOutlined,
    label: 'Host payout',
    value: 'Settled after attendance',
  );
}

@widgetbook.UseCase(
  name: 'Divider',
  type: EventPolicyDividerLine,
  path: '[P3 utility surfaces]/Event policy lab',
)
Widget eventPolicyDividerLineState(BuildContext context) {
  return Builder(
    builder: (context) =>
        EventPolicyDividerLine(color: CatchTokens.of(context).line),
  );
}

@widgetbook.UseCase(
  name: 'Route states',
  type: EventLocationMapRouteScreen,
  path: '[P3 utility surfaces]/Event location map',
)
Widget eventLocationMapRouteStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventLocationMapRouteScreen',
    contractId: 'screen.event.location_map',
    children: [
      _StateCard(
        label: 'route loading',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: const AsyncLoading<EventDetailViewModel?>(),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'route error',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: AsyncError<EventDetailViewModel?>(
              StateError('Widgetbook event lookup failed'),
              StackTrace.empty,
            ),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'event not found',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: const AsyncData<EventDetailViewModel?>(null),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'pinned location',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: AsyncData<EventDetailViewModel?>(_eventVm(_event)),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Map states',
  type: EventLocationMapScreen,
  path: '[P3 utility surfaces]/Event location map',
)
Widget eventLocationMapScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventLocationMapScreen',
    contractId: 'screen.event.location_map.sections',
    children: [
      _StateCard(
        label: 'network tiles disabled',
        child: _DeviceFrame(
          child: EventLocationMapScreen(
            state: EventLocationMapState.fromEvent(
              _event,
              enableNetworkTiles: false,
            ),
            onGetDirections: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'no exact coordinate',
        child: _DeviceFrame(
          child: EventLocationMapScreen(
            state: EventLocationMapState.fromEvent(
              _eventWithoutCoordinate,
              enableNetworkTiles: false,
            ),
            onGetDirections: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ActivityScreen,
  path: '[P3 utility surfaces]/Notifications',
)
Widget activityScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ActivityScreen',
    contractId: 'screen.notifications.list',
    children: [
      _StateCard(
        label: 'uid loading',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            uidStream: _loadingStream<String?>(),
            notificationsStream: Stream.value(_notifications),
            child: const ActivityScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            uidStream: Stream<String?>.value(null),
            notificationsStream: Stream.value(_notifications),
            child: const ActivityScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'mark-all-read visible',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            notificationsStream: Stream.value(_notifications),
            child: const ActivityScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'activity error',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            notificationsStream: _errorStream('Activity stream failed'),
            child: const ActivityScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Section states',
  type: ActivitySection,
  path: '[P3 utility surfaces]/Notifications',
)
Widget activitySectionStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ActivitySection',
    contractId: 'screen.notifications.list.activity_body',
    children: [
      _StateCard(
        label: 'loading',
        child: _ActivitySectionScope(
          notificationsStream: _loadingStream<List<ActivityNotification>>(),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: _ActivitySectionScope(
          notificationsStream: Stream.value(const <ActivityNotification>[]),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
      _StateCard(
        label: 'error',
        child: _ActivitySectionScope(
          notificationsStream: _errorStream('Activity unavailable'),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
      _StateCard(
        label: 'grouped read and unread',
        child: _ActivitySectionScope(
          notificationsStream: Stream.value(_notifications),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
    ],
  );
}

Widget notificationRowStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'NotificationRow',
    contractId: 'screen.notifications.list.row',
    children: [
      _StateCard(
        label: 'unread event reminder',
        child: const NotificationRow(
          type: ActivityNotificationType.eventReminder,
          title: 'Event starts tomorrow',
          time: '2h',
          body: 'Sundowner 5K meets at Carter Road Jetty.',
          unread: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'read signup',
        child: const NotificationRow(
          type: ActivityNotificationType.eventSignup,
          title: 'You are booked',
          time: '5h',
          body: 'Your spot is confirmed for Wednesday evening.',
          divider: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'long copy',
        child: const NotificationRow(
          type: ActivityNotificationType.clubUpdate,
          title: 'Sea Face Social added a new slower return-to-running loop',
          time: 'yesterday',
          body:
              'The host posted pacing notes, regroup points, and cafe timing for members returning after a break.',
          unread: true,
          divider: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'non-navigable cancellation',
        child: const NotificationRow(
          type: ActivityNotificationType.eventCancelled,
          title: 'Morning run was cancelled',
          time: 'mon',
          body: 'Heavy rain moved the session to next week.',
          divider: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ReviewsHistoryScreen,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewsHistoryScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ReviewsHistoryScreen',
    contractId: 'screen.reviews.history',
    children: [
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _ReviewsScope(
            uidStream: Stream<String?>.value(null),
            profileStream: Stream.value(null),
            reviewsStream: Stream.value(_reviews),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _ReviewsScope(
            profileStream: _loadingStream<UserProfile?>(),
            reviewsStream: Stream.value(_reviews),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _ReviewsScope(
            profileStream: _errorStream('Profile failed'),
            reviewsStream: Stream.value(_reviews),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'reviews loading',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: _loadingStream<List<Review>>(),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'reviews error',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: _errorStream('Reviews failed'),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'empty reviews',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: Stream.value(const <Review>[]),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'review list with event context',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: Stream.value(_reviews),
            eventsStream: Stream.value([_event]),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'event context missing',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: Stream.value(_reviews.take(1).toList()),
            eventsStream: Stream.value(const <Event>[]),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'History body states',
  type: ReviewsHistoryBody,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewsHistoryBodyStates(BuildContext context) {
  final rows = _reviewHistoryRows();
  return _UtilityCatalog(
    title: 'ReviewsHistoryBody',
    contractId: 'screen.reviews.history.body',
    children: [
      _StateCard(
        label: 'content',
        child: SizedBox(
          height: 420,
          child: ReviewsHistoryBody(
            state: ReviewsHistoryContent(user: _viewer, rows: rows),
            onRetryProfile: _noop,
            onRetryReviews: _noop,
            onEditReview: _noopReviewHistoryEdit,
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: SizedBox(
          height: 320,
          child: ReviewsHistoryBody(
            state: const ReviewsHistoryEmpty(
              title: 'No reviews yet',
              message: 'Reviews you write after events will appear here.',
            ),
            onRetryProfile: _noop,
            onRetryReviews: _noop,
            onEditReview: _noopReviewHistoryEdit,
          ),
        ),
      ),
      _StateCard(
        label: 'error',
        child: SizedBox(
          height: 320,
          child: ReviewsHistoryBody(
            state: const ReviewsHistoryError(
              title: 'Reviews unavailable',
              message: 'Could not load your reviews.',
              retryTarget: ReviewsHistoryRetryTarget.reviews,
            ),
            onRetryProfile: _noop,
            onRetryReviews: _noop,
            onEditReview: _noopReviewHistoryEdit,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'History list states',
  type: ReviewsHistoryList,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewsHistoryListStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ReviewsHistoryList',
    contractId: 'screen.reviews.history.list',
    children: [
      _StateCard(
        label: 'rows',
        child: SizedBox(
          height: 360,
          child: ReviewsHistoryList(
            rows: _reviewHistoryRows(),
            onEditReview: _noopReviewHistoryEdit,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'History empty state',
  type: ReviewsHistoryEmptyState,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewsHistoryEmptyStateStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'ReviewsHistoryEmptyState',
    contractId: 'screen.reviews.history.empty',
    children: [
      _StateCard(
        label: 'signed out',
        child: SizedBox(
          height: 300,
          child: ReviewsHistoryEmptyState(
            title: 'Sign in to see reviews',
            message: 'Your past event reviews will appear here.',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'History skeleton states',
  type: ReviewsHistorySkeleton,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewsHistorySkeletonStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'ReviewsHistorySkeleton',
    contractId: 'screen.reviews.history.skeleton',
    children: [
      _StateCard(
        label: 'loading list',
        child: SizedBox(height: 360, child: ReviewsHistorySkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'History row skeleton states',
  type: ReviewHistoryItemSkeleton,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewHistoryItemSkeletonStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'ReviewHistoryItemSkeleton',
    contractId: 'screen.reviews.history.row_skeleton',
    children: [
      _StateCard(label: 'loading row', child: ReviewHistoryItemSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'History row states',
  type: ReviewHistoryItem,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewHistoryItemStates(BuildContext context) {
  final editableReview = _reviews.first;
  final responseReview = _reviewWithOwnerResponse();
  return _UtilityCatalog(
    title: 'ReviewHistoryItem',
    contractId: 'screen.reviews.history.row',
    children: [
      _StateCard(
        label: 'editable own review',
        child: ReviewHistoryItem(
          row: ReviewsHistoryRow(
            review: editableReview,
            contextLabel: 'Sunday Sea Face Crew · Jun 22',
            editEventId: editableReview.eventId,
          ),
          onEditReview: _noopReviewHistoryEdit,
        ),
      ),
      _StateCard(
        label: 'host response',
        child: ReviewHistoryItem(
          row: ReviewsHistoryRow(
            review: responseReview,
            contextLabel: 'Bandra afterglow run · missing event context',
            editEventId: null,
          ),
          onEditReview: _noopReviewHistoryEdit,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Card states',
  type: ReviewCard,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewCardStates(BuildContext context) {
  final responseReview = _reviewWithOwnerResponse();
  return _UtilityCatalog(
    title: 'ReviewCard',
    contractId: 'component.reviews.card',
    children: [
      _StateCard(
        label: 'attendee review',
        child: ReviewCard(review: _reviews.first, isOwn: false),
      ),
      _StateCard(
        label: 'own editable review',
        child: ReviewCard(review: _reviews.first, isOwn: true, onEdit: _noop),
      ),
      _StateCard(
        label: 'host response',
        child: ReviewCard(
          review: responseReview,
          isOwn: false,
          onRespond: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Preview section states',
  type: ReviewsPreviewSection,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewsPreviewSectionStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ReviewsPreviewSection',
    contractId: 'component.reviews.preview_section',
    children: [
      _StateCard(
        label: 'empty compact',
        child: const ReviewsPreviewSection(
          reviews: [],
          currentUid: _viewerUid,
          compactEmptyState: true,
        ),
      ),
      _StateCard(
        label: 'preview with aggregate',
        child: ReviewsPreviewSection(
          reviews: _reviews,
          currentUid: _viewerUid,
          showAllAction: true,
          onEditReview: _noopReviewEdit,
          onRespondToReview: _noopReviewEdit,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host response block',
  type: ReviewOwnerResponseBlock,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewOwnerResponseBlockState(BuildContext context) {
  return _UtilityCatalog(
    title: 'ReviewOwnerResponseBlock',
    contractId: 'component.reviews.host_response',
    children: [
      _StateCard(
        label: 'host response',
        child: ReviewOwnerResponseBlock(
          response: _reviewWithOwnerResponse().ownerResponse!,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Response sheet states',
  type: ReviewResponseSheet,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewResponseSheetStates(BuildContext context) {
  final responseReview = _reviewWithOwnerResponse();
  return _UtilityCatalog(
    title: 'ReviewResponseSheet',
    contractId: 'component.reviews.response_sheet',
    children: [
      _StateCard(
        label: 'new response',
        child: _SheetFrame(
          child: IgnorePointer(
            child: ReviewResponseSheet(review: _reviews.first),
          ),
        ),
      ),
      _StateCard(
        label: 'edit response',
        child: _SheetFrame(
          child: IgnorePointer(
            child: ReviewResponseSheet(review: responseReview),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Rating states',
  type: StarRating,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget starRatingStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'StarRating',
    contractId: 'component.reviews.star_rating',
    children: const [
      _StateCard(label: 'empty', child: StarRating(rating: 0)),
      _StateCard(label: 'three stars', child: StarRating(rating: 3)),
      _StateCard(label: 'five stars', child: StarRating(rating: 5)),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Picker states',
  type: StarRatingPicker,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget starRatingPickerStates(BuildContext context) {
  var rating = 3;
  return _UtilityCatalog(
    title: 'StarRatingPicker',
    contractId: 'component.reviews.star_rating_picker',
    children: [
      _StateCard(
        label: 'interactive picker',
        child: StatefulBuilder(
          builder: (context, setState) {
            return StarRatingPicker(
              rating: rating,
              onChanged: (value) => setState(() => rating = value),
            );
          },
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: WriteReviewSheet,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget writeReviewSheetStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'WriteReviewSheet',
    contractId: 'screen.reviews.history.edit_sheet',
    children: [
      _StateCard(
        label: 'write review',
        child: _SheetFrame(
          child: IgnorePointer(
            child: WriteReviewSheet(
              clubId: 'widgetbook-club',
              eventId: _event.id,
              reviewer: _viewer,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'edit review with delete action',
        child: _SheetFrame(
          child: IgnorePointer(
            child: WriteReviewSheet(
              clubId: 'widgetbook-club',
              eventId: _event.id,
              reviewer: _viewer,
              existingReview: _reviews.first,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: SettingsScreen,
  path: '[P3 utility surfaces]/Settings',
)
Widget settingsScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'SettingsScreen',
    contractId: 'screen.settings.account',
    children: [
      _StateCard(
        label: 'profile-backed account',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _SettingsScope(
            profileStream: _loadingStream<UserProfile?>(),
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'blocked accounts loading',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: _loadingStream<List<BlockedUser>>(),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'blocked accounts error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: _errorStream('Blocked users failed'),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'blocked accounts list',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(_blockedUsers),
            publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
            child: const SettingsScreen(),
          ),
        ),
      ),
    ],
  );
}

Widget settingsDangerDialogStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CatchConfirmDialog',
    contractId: 'screen.settings.account.destructive_dialog',
    children: [
      _StateCard(
        label: 'delete account confirmation',
        child: const _DialogFrame(
          child: CatchConfirmDialog<bool>(
            title: 'Delete account?',
            message:
                'This removes your public profile, signs you out, and keeps only the minimal records required for safety and payment history.',
            actions: [
              CatchDialogAction(label: 'Cancel', value: false),
              CatchDialogAction(
                label: 'Delete',
                value: true,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'sign out confirmation pattern',
        child: const _DialogFrame(
          child: CatchConfirmDialog<bool>(
            title: 'Log out?',
            message: 'You can sign back in with your phone number.',
            actions: [
              CatchDialogAction(label: 'Cancel', value: false),
              CatchDialogAction(label: 'Log out', value: true),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Mutation states',
  type: SettingsScreen,
  path: '[P3 utility surfaces]/Settings',
)
Widget settingsMutationStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'SettingsScreen mutation lifecycle',
    contractId: 'screen.settings.account.mutations',
    children: [
      _StateCard(
        label: 'preference save pending',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.preferencePending,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'preference save error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.preferenceError,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'delete account pending',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.deletePending,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'delete account error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.deleteError,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'sign out pending',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.signOutPending,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'unblock user error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(_blockedUsers),
            publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.unblockError,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: PaymentHistoryScreen,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistoryScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentHistoryScreen',
    contractId: 'screen.payments.history',
    children: [
      _StateCard(
        label: 'uid loading',
        child: _DeviceFrame(
          child: _PaymentScope(
            uidStream: _loadingStream<String?>(),
            paymentsStream: Stream.value(_payments),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'uid error',
        child: _DeviceFrame(
          child: _PaymentScope(
            uidStream: _errorStream('Auth session failed'),
            paymentsStream: Stream.value(_payments),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _PaymentScope(
            uidStream: Stream<String?>.value(null),
            paymentsStream: Stream.value(_payments),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'payments loading',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: _loadingStream<List<Payment>>(),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'payments error',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: _errorStream('Payments failed'),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'empty history',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: Stream.value(const <Payment>[]),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'status variants',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: Stream.value(_payments),
            eventsById: {
              for (final payment in _payments)
                payment.eventId: _utilityEvent(
                  id: payment.eventId,
                  meetingPoint: _eventTitleForPayment(payment),
                  notes: 'Receipt context',
                  latitude: 19.0676,
                  longitude: 72.8227,
                ),
            },
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'event title missing',
        child: _DeviceFrame(
          child: _PaymentScope(
            payments: _payments.take(1).toList(),
            paymentsStream: Stream.value(_payments.take(1).toList()),
            eventsById: const {},
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Provider states',
  type: PaymentHistoryListController,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistoryListControllerStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentHistoryListController',
    contractId: 'screen.payments.history.provider-list',
    children: [
      _StateCard(
        label: 'loaded',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: Stream.value(_payments),
            child: const PaymentHistoryListController(userId: _viewerUid),
          ),
        ),
      ),
      _StateCard(
        label: 'payments loading',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: _loadingStream<List<Payment>>(),
            child: const PaymentHistoryListController(userId: _viewerUid),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'List states',
  type: PaymentHistoryList,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistoryListStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentHistoryList',
    contractId: 'screen.payments.history.list',
    children: [
      _StateCard(
        label: 'empty',
        child: const _DeviceFrame(
          child: PaymentHistoryList(
            paymentHistory: PaymentHistoryViewModel(rows: []),
          ),
        ),
      ),
      _StateCard(
        label: 'status variants',
        child: _DeviceFrame(
          child: PaymentHistoryList(
            paymentHistory: _paymentHistoryViewModel(_payments),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Loading states',
  type: PaymentHistorySkeleton,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistorySkeletonStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'PaymentHistorySkeleton',
    contractId: 'screen.payments.history.skeleton',
    children: [
      _StateCard(
        label: 'loading list',
        child: _DeviceFrame(child: PaymentHistorySkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row skeleton states',
  type: PaymentHistoryTileSkeleton,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistoryTileSkeletonStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'PaymentHistoryTileSkeleton',
    contractId: 'screen.payments.history.row_skeleton',
    children: [
      _StateCard(label: 'loading row', child: PaymentHistoryTileSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty states',
  type: PaymentHistoryEmptyState,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistoryEmptyStateStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentHistoryEmptyState',
    contractId: 'screen.payments.history.empty',
    children: [
      _StateCard(
        label: 'no payments',
        child: _DeviceFrame(
          child: PaymentHistoryEmptyState(
            icon: CatchIcons.receiptLongOutlined,
            title: 'No payments yet',
            message: 'Event bookings and refunds will appear here.',
          ),
        ),
      ),
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: PaymentHistoryEmptyState(
            icon: CatchIcons.lockOutlineRounded,
            title: 'Sign in required',
            message: 'Sign in again to view payment history.',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row states',
  type: PaymentHistoryTile,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistoryTileStates(BuildContext context) {
  final paidPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.completed,
  );
  final pendingPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.pending,
  );
  final failedPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.refundFailed,
  );

  return _UtilityCatalog(
    title: 'PaymentHistoryTile',
    contractId: 'screen.payments.history.row',
    children: [
      _StateCard(
        label: 'paid',
        child: _DeviceFrame(
          child: PaymentHistoryTile(
            row: PaymentHistoryRow(
              payment: paidPayment,
              eventTitle: _eventTitleForPayment(paidPayment),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'pending',
        child: _DeviceFrame(
          child: PaymentHistoryTile(
            row: PaymentHistoryRow(
              payment: pendingPayment,
              eventTitle: _eventTitleForPayment(pendingPayment),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'refund attention',
        child: _DeviceFrame(
          child: PaymentHistoryTile(
            row: PaymentHistoryRow(
              payment: failedPayment,
              eventTitle: _eventTitleForPayment(failedPayment),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Receipt states',
  type: PaymentReceiptSheet,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentReceiptSheetStates(BuildContext context) {
  final failedPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.refundFailed,
  );
  return _UtilityCatalog(
    title: 'PaymentReceiptSheet',
    contractId: 'screen.payments.history.detail_sheet',
    children: [
      _StateCard(
        label: 'paid receipt',
        child: _SheetFrame(
          child: PaymentReceiptSheet(
            payment: _payments.first,
            eventTitle: 'Sundowner 5K receipt',
          ),
        ),
      ),
      _StateCard(
        label: 'failed signup help',
        child: _SheetFrame(
          child: PaymentReceiptSheet(
            payment: failedPayment,
            eventTitle: 'Refund needs attention',
            onHelp: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: PaymentConfirmationScreen,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentConfirmationScreenStates(BuildContext context) {
  final paidPayment = _payments.first;
  final pendingPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.pending,
  );
  return _UtilityCatalog(
    title: 'PaymentConfirmationScreen',
    contractId: 'screen.payments.confirmation',
    children: [
      _StateCard(
        label: 'event loading',
        child: _DeviceFrame(
          child: _PaymentScope(
            eventsById: const {},
            child: PaymentConfirmationScreen(
              data: _confirmationData(paidPayment),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'joined celebration',
        child: _DeviceFrame(
          child: _PaymentScope(
            eventsById: {_event.id: _event},
            child: IgnorePointer(
              child: PaymentConfirmationScreen(
                data: _confirmationData(paidPayment),
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'external checkout pending',
        child: _DeviceFrame(
          child: _PaymentScope(
            eventsById: {_event.id: _event},
            paymentsByPaymentId: {pendingPayment.paymentId: pendingPayment},
            child: IgnorePointer(
              child: PaymentConfirmationScreen(
                data: _confirmationData(
                  pendingPayment,
                  checkoutUrl: Uri.parse('https://checkout.example/pay'),
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
  name: 'Loading state',
  type: PaymentConfirmationLoadingScreen,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentConfirmationLoadingScreenStates(BuildContext context) {
  return const _UtilityCatalog(
    title: 'PaymentConfirmationLoadingScreen',
    contractId: 'screen.payments.confirmation.loading',
    children: [
      _StateCard(
        label: 'event loading',
        child: _DeviceFrame(child: PaymentConfirmationLoadingScreen()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Backdrop states',
  type: PaymentCheckoutEventBackdrop,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentCheckoutEventBackdropStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentCheckoutEventBackdrop',
    contractId: 'screen.payments.confirmation.checkout_backdrop',
    children: [
      _StateCard(
        label: 'event summary',
        child: _DeviceFrame(child: PaymentCheckoutEventBackdrop(event: _event)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Provider states',
  type: PaymentPendingCheckoutController,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentPendingCheckoutControllerStates(BuildContext context) {
  final pendingPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.pending,
  );
  return _UtilityCatalog(
    title: 'PaymentPendingCheckoutController',
    contractId: 'screen.payments.confirmation.pending_controller',
    children: [
      _StateCard(
        label: 'checkout pending',
        child: _DeviceFrame(
          child: _PaymentScope(
            eventsById: {_event.id: _event},
            paymentsByPaymentId: {pendingPayment.paymentId: pendingPayment},
            child: IgnorePointer(
              child: PaymentPendingCheckoutController(
                data: _confirmationData(
                  pendingPayment,
                  checkoutUrl: Uri.parse('https://checkout.example/pay'),
                ),
                event: _event,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body states',
  type: PaymentPendingCheckoutBody,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentPendingCheckoutBodyStates(BuildContext context) {
  final pendingPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.pending,
  );
  final failedPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.refundFailed,
  );
  return _UtilityCatalog(
    title: 'PaymentPendingCheckoutBody',
    contractId: 'screen.payments.confirmation.pending_body',
    children: [
      _StateCard(
        label: 'pending checkout',
        child: _DeviceFrame(
          child: IgnorePointer(
            child: PaymentPendingCheckoutBody(
              data: _confirmationData(
                pendingPayment,
                checkoutUrl: Uri.parse('https://checkout.example/pay'),
              ),
              event: _event,
              failed: false,
              providerLabel: 'Stripe',
              onOpenCheckout: _noop,
              onViewPaymentHistory: _noop,
              onBackToEvent: _noop,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'failed checkout',
        child: _DeviceFrame(
          child: IgnorePointer(
            child: PaymentPendingCheckoutBody(
              data: _confirmationData(
                failedPayment,
                checkoutUrl: Uri.parse('https://checkout.example/retry'),
              ),
              event: _event,
              failed: true,
              providerLabel: 'Stripe',
              onOpenCheckout: _noop,
              onViewPaymentHistory: _noop,
              onBackToEvent: _noop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Provider states',
  type: PaymentConfirmationBodyController,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentConfirmationBodyControllerStates(BuildContext context) {
  final paidPayment = _payments.first;
  return _UtilityCatalog(
    title: 'PaymentConfirmationBodyController',
    contractId: 'screen.payments.confirmation.body_controller',
    children: [
      _StateCard(
        label: 'joined celebration',
        child: _DeviceFrame(
          child: _PaymentScope(
            eventsById: {_event.id: _event},
            child: IgnorePointer(
              child: PaymentConfirmationBodyController(
                data: _confirmationData(paidPayment),
                event: _event,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body states',
  type: PaymentConfirmationBody,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentConfirmationBodyStates(BuildContext context) {
  final paidPayment = _payments.first;
  return _UtilityCatalog(
    title: 'PaymentConfirmationBody',
    contractId: 'screen.payments.confirmation.body',
    children: [
      _StateCard(
        label: 'joined celebration',
        child: _DeviceFrame(
          child: IgnorePointer(
            child: PaymentConfirmationBody(
              data: _confirmationData(paidPayment),
              event: _event,
              clubName: 'Bandra Breakers',
              onAddToCalendar: _noop,
              onOpenDirections: _noop,
              onInviteFriend: _noop,
              onReferralShare: _noop,
              onViewEvent: _noop,
              onBackHome: _noop,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Checkout sheet states',
  type: PaymentCheckoutSheet,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentCheckoutSheetStates(BuildContext context) {
  final pendingPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.pending,
  );
  final failedPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.refundFailed,
  );
  return _UtilityCatalog(
    title: 'PaymentCheckoutSheet',
    contractId: 'screen.payments.confirmation.checkout_sheet',
    children: [
      _StateCard(
        label: 'pending checkout',
        child: _SheetFrame(
          child: PaymentCheckoutSheet(
            data: _confirmationData(
              pendingPayment,
              checkoutUrl: Uri.parse('https://checkout.example/pay'),
            ),
            event: _event,
            failed: false,
            providerLabel: 'Stripe',
            onViewPaymentHistory: _noop,
            onBackToEvent: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'failed checkout',
        child: _SheetFrame(
          child: PaymentCheckoutSheet(
            data: _confirmationData(
              failedPayment,
              checkoutUrl: Uri.parse('https://checkout.example/retry'),
            ),
            event: _event,
            failed: true,
            providerLabel: 'Stripe',
            onOpenCheckout: _noop,
            onViewPaymentHistory: _noop,
            onBackToEvent: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Info surfaces',
  type: PaymentConfirmationHeadsUp,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentConfirmationInfoStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'Payment confirmation info',
    contractId: 'screen.payments.confirmation.info',
    children: [
      const _StateCard(label: 'heads up', child: PaymentConfirmationHeadsUp()),
      _StateCard(
        label: 'referral banner',
        child: IgnorePointer(child: PaymentReferralBanner(onShare: _noop)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Referral banner',
  type: PaymentReferralBanner,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentReferralBannerStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentReferralBanner',
    contractId: 'component.payments.referral_banner',
    children: [
      _StateCard(
        label: 'event referral prompt',
        child: IgnorePointer(child: PaymentReferralBanner(onShare: _noop)),
      ),
      _StateCard(
        label: 'provider wired',
        child: _PaymentScope(
          child: IgnorePointer(
            child: PaymentReferralBannerController(event: _event),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Referral banner controller',
  type: PaymentReferralBannerController,
  path: '[P3 utility surfaces]/Payment confirmation',
)
Widget paymentReferralBannerControllerStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentReferralBannerController',
    contractId: 'component.payments.referral_banner.controller',
    children: [
      _StateCard(
        label: 'provider wired',
        child: _PaymentScope(
          child: IgnorePointer(
            child: PaymentReferralBannerController(event: _event),
          ),
        ),
      ),
    ],
  );
}

class _MyAppScope extends StatefulWidget {
  const _MyAppScope();

  @override
  State<_MyAppScope> createState() => _MyAppScopeState();
}

class _MyAppScopeState extends State<_MyAppScope> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: Center(
            child: Text(
              'Widgetbook app root',
              style: CatchTextStyles.titleL(context),
            ),
          ),
        ),
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        goRouterProvider.overrideWithValue(_router),
        forceUpdateRequiredProvider.overrideWithValue(
          const AsyncData<bool>(false),
        ),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream<UserProfile?>.value(null),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class _ForceUpdateStoreScope extends StatelessWidget {
  const _ForceUpdateStoreScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appVersionConfigProvider.overrideWithValue(_forceUpdateConfig),
        externalUrlLauncherProvider.overrideWithValue(_noopLauncher),
      ],
      child: child,
    );
  }
}

class _ForceUpdatePassThrough extends StatelessWidget {
  const _ForceUpdatePassThrough();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: CatchInsets.contentSpacious,
            child: Text(
              'App content',
              style: CatchTextStyles.titleL(context, color: t.ink),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _authFrame({
  required Widget child,
  _AuthPreviewMode mode = _AuthPreviewMode.phoneEntry,
  TextScaler? textScaler,
  bool disableAnimations = false,
}) {
  return _DeviceFrame(
    child: _AuthScope(
      mode: mode,
      textScaler: textScaler,
      disableAnimations: disableAnimations,
      child: child,
    ),
  );
}

enum _AuthPreviewMode {
  phoneEntry,
  otpEntry,
  sendCodePending,
  sendCodeError,
  verifyCodePending,
  verifyCodeError,
  resendPending,
  resendError,
}

class _AuthScope extends StatelessWidget {
  const _AuthScope({
    required this.child,
    this.mode = _AuthPreviewMode.phoneEntry,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final _AuthPreviewMode mode;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    Widget scoped = ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          const _WidgetbookAuthRepository(),
        ),
        authInitialCountryDialCodeProvider.overrideWithValue('+91'),
      ],
      child: _AuthPreviewSeeder(mode: mode, child: child),
    );

    if (textScaler != null || disableAnimations) {
      scoped = _AuthMediaOverride(
        textScaler: textScaler,
        disableAnimations: disableAnimations,
        child: scoped,
      );
    }

    return scoped;
  }
}

class _AuthMediaOverride extends StatelessWidget {
  const _AuthMediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: textScaler ?? media.textScaler,
        disableAnimations: disableAnimations || media.disableAnimations,
      ),
      child: child,
    );
  }
}

class _AuthPreviewSeeder extends ConsumerStatefulWidget {
  const _AuthPreviewSeeder({required this.mode, required this.child});

  final _AuthPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_AuthPreviewSeeder> createState() => _AuthPreviewSeederState();
}

class _AuthPreviewSeederState extends ConsumerState<_AuthPreviewSeeder> {
  static const _phoneNumber = '9876543210';
  static const _countryCode = '+91';

  Completer<void>? _pendingCompleter;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_seed()));
  }

  @override
  void didUpdateWidget(covariant _AuthPreviewSeeder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _seeded = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_seed()));
    }
  }

  @override
  void dispose() {
    final completer = _pendingCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    super.dispose();
  }

  Future<void> _seed() async {
    if (!mounted || _seeded) return;
    _seeded = true;
    AuthController.sendOtpMutation.reset(ref);
    AuthController.verifyOtpMutation.reset(ref);

    switch (widget.mode) {
      case _AuthPreviewMode.phoneEntry:
        ref.read(authControllerProvider.notifier).goToStep(AuthStep.phone);
        break;
      case _AuthPreviewMode.otpEntry:
        await _seedOtpStep();
        break;
      case _AuthPreviewMode.sendCodePending:
        ref.read(authControllerProvider.notifier).goToStep(AuthStep.phone);
        _runPending(AuthController.sendOtpMutation);
        break;
      case _AuthPreviewMode.sendCodeError:
        ref.read(authControllerProvider.notifier).goToStep(AuthStep.phone);
        _runError(
          AuthController.sendOtpMutation,
          const NetworkException(
            'widgetbook-send-code-failed',
            'We could not send the code. Check your connection and try again.',
            context: BackendErrorContext(
              service: BackendService.auth,
              action: 'send verification code',
              resource: 'phone_auth',
            ),
          ),
        );
        break;
      case _AuthPreviewMode.verifyCodePending:
        await _seedOtpStep();
        _runPending(AuthController.verifyOtpMutation);
        break;
      case _AuthPreviewMode.verifyCodeError:
        await _seedOtpStep();
        _runError(
          AuthController.verifyOtpMutation,
          const ValidationException(
            'That code is invalid. Please try again.',
            code: 'invalid-verification-code',
            context: BackendErrorContext(
              service: BackendService.auth,
              action: 'verify sms code',
              resource: 'phone_auth',
            ),
          ),
        );
        break;
      case _AuthPreviewMode.resendPending:
        await _seedOtpStep();
        _runPending(AuthController.sendOtpMutation);
        break;
      case _AuthPreviewMode.resendError:
        await _seedOtpStep();
        _runError(
          AuthController.sendOtpMutation,
          const NetworkException(
            'widgetbook-resend-code-failed',
            'We could not resend the code. Please try again.',
            context: BackendErrorContext(
              service: BackendService.auth,
              action: 'resend verification code',
              resource: 'phone_auth',
            ),
          ),
        );
        break;
    }
  }

  Future<void> _seedOtpStep() async {
    await ref
        .read(authControllerProvider.notifier)
        .sendOtp(_phoneNumber, _countryCode);
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    _pendingCompleter = completer;
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, Object error) {
    unawaited(mutation.run(ref, (_) async => throw error).catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _WidgetbookAuthRepository implements AuthRepository {
  const _WidgetbookAuthRepository();

  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(null);

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(AppException e) verificationFailed,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
  }) async {
    codeSent('widgetbook-verification-id', null);
  }

  @override
  Future<void> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {}

  @override
  Future<void> signInWithCredential(AuthCredential credential) async {}

  @override
  Future<void> signOut() async {}
}

class _LaunchAccessScope extends StatelessWidget {
  const _LaunchAccessScope({
    required this.child,
    this.config = const LaunchAccessConfig(gateEnabled: true),
    this.uidStream,
    this.applicationStream,
  });

  final Widget child;
  final LaunchAccessConfig config;
  final Stream<String?>? uidStream;
  final Stream<LaunchAccessApplication?>? applicationStream;

  @override
  Widget build(BuildContext context) {
    final applicationStream = this.applicationStream;
    return ProviderScope(
      overrides: [
        launchAccessConfigProvider.overrideWith((ref) => config),
        uidProvider.overrideWith(
          (ref) => uidStream ?? Stream<String?>.value(_viewerUid),
        ),
        if (applicationStream != null)
          watchLaunchAccessApplicationProvider(
            _viewerUid,
          ).overrideWith((ref) => applicationStream),
      ],
      child: child,
    );
  }
}

class _ProfilePhotoEditorScope extends StatelessWidget {
  const _ProfilePhotoEditorScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        watchUserProfileProvider.overrideWith(
          (ref) => Stream<UserProfile?>.value(
            _viewer.copyWith(profilePhotos: _profilePhotos),
          ),
        ),
      ],
      child: child,
    );
  }
}

class _CalendarScope extends StatelessWidget {
  const _CalendarScope({
    required this.child,
    this.uidValue,
    this.signedUpEventsValue,
    this.savedEventsValue,
    this.clubNamesValue,
  });

  final Widget child;
  final AsyncValue<String?>? uidValue;
  final AsyncValue<List<Event>>? signedUpEventsValue;
  final AsyncValue<List<Event>>? savedEventsValue;
  final AsyncValue<Map<String, String>>? clubNamesValue;

  @override
  Widget build(BuildContext context) {
    final signedUpEvents =
        signedUpEventsValue ?? AsyncData<List<Event>>(_calendarJoinedEvents);
    final savedEvents =
        savedEventsValue ?? AsyncData<List<Event>>(_calendarSavedEvents);
    final lookupEvents = [
      ...?signedUpEvents.asData?.value,
      ...?savedEvents.asData?.value,
    ];
    final clubQuery = ClubNameLookupQuery(
      lookupEvents.map((event) => event.clubId),
    );

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(
          uidValue ?? const AsyncData<String?>(_viewerUid),
        ),
        watchSignedUpEventsProvider(
          _viewerUid,
        ).overrideWithValue(signedUpEvents),
        watchSavedEventDetailsForUserProvider(
          _viewerUid,
        ).overrideWithValue(savedEvents),
        if (clubQuery.clubIds.isNotEmpty)
          clubNameLookupProvider(clubQuery).overrideWithValue(
            clubNamesValue ??
                const AsyncData<Map<String, String>>(_calendarClubNames),
          ),
      ],
      child: child,
    );
  }
}

enum _SettingsMutationMode {
  preferencePending,
  preferenceError,
  deletePending,
  deleteError,
  signOutPending,
  unblockError,
}

class _SettingsMutationSeeder extends ConsumerStatefulWidget {
  const _SettingsMutationSeeder({required this.mode, required this.child});

  final _SettingsMutationMode mode;
  final Widget child;

  @override
  ConsumerState<_SettingsMutationSeeder> createState() =>
      _SettingsMutationSeederState();
}

class _SettingsMutationSeederState
    extends ConsumerState<_SettingsMutationSeeder> {
  Completer<void>? _pendingCompleter;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      _seed();
    });
  }

  @override
  void dispose() {
    final completer = _pendingCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    super.dispose();
  }

  void _seed() {
    switch (widget.mode) {
      case _SettingsMutationMode.preferencePending:
        _runPending(SettingsController.savePreferenceMutation);
        break;
      case _SettingsMutationMode.preferenceError:
        _runError(
          SettingsController.savePreferenceMutation,
          'Preference save failed',
        );
        break;
      case _SettingsMutationMode.deletePending:
        _runPending(SettingsController.requestAccountDeletionMutation);
        break;
      case _SettingsMutationMode.deleteError:
        _runError(
          SettingsController.requestAccountDeletionMutation,
          'Delete account failed',
        );
        break;
      case _SettingsMutationMode.signOutPending:
        _runPending(AuthSessionController.signOutMutation);
        break;
      case _SettingsMutationMode.unblockError:
        _runError(SettingsController.unblockUserMutation, 'Unblock failed');
        break;
    }
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    _pendingCompleter = completer;
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, String message) {
    unawaited(
      mutation
          .run(ref, (_) async => throw StateError(message))
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MapRouteScope extends StatelessWidget {
  const _MapRouteScope({required this.value, required this.child});

  final AsyncValue<EventDetailViewModel?> value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        eventDetailViewModelProvider(_event.id).overrideWithValue(value),
        externalUrlLauncherProvider.overrideWithValue(_noopLauncher),
      ],
      child: child,
    );
  }
}

class _ActivityScreenScope extends StatelessWidget {
  const _ActivityScreenScope({
    required this.child,
    required this.notificationsStream,
    this.uidStream,
  });

  final Widget child;
  final Stream<String?>? uidStream;
  final Stream<List<ActivityNotification>> notificationsStream;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith(
          (ref) => uidStream ?? Stream<String?>.value(_viewerUid),
        ),
        watchActivityNotificationsProvider(
          _viewerUid,
        ).overrideWith((ref) => notificationsStream),
      ],
      child: child,
    );
  }
}

class _ActivitySectionScope extends StatelessWidget {
  const _ActivitySectionScope({
    required this.notificationsStream,
    required this.child,
  });

  final Stream<List<ActivityNotification>> notificationsStream;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        watchActivityNotificationsProvider(
          _viewerUid,
        ).overrideWith((ref) => notificationsStream),
      ],
      child: child,
    );
  }
}

class _ReviewsScope extends StatelessWidget {
  const _ReviewsScope({
    required this.child,
    this.uidStream,
    this.profileStream,
    this.reviewsStream,
    this.eventsStream,
  });

  final Widget child;
  final Stream<String?>? uidStream;
  final Stream<UserProfile?>? profileStream;
  final Stream<List<Review>>? reviewsStream;
  final Stream<List<Event>>? eventsStream;

  @override
  Widget build(BuildContext context) {
    final eventIds = <String>{
      for (final review in _reviews)
        if (review.eventId != null) review.eventId!,
    };
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith(
          (ref) => uidStream ?? Stream<String?>.value(_viewerUid),
        ),
        watchUserProfileProvider.overrideWith(
          (ref) => profileStream ?? Stream<UserProfile?>.value(_viewer),
        ),
        watchReviewsByUserProvider(
          _viewerUid,
        ).overrideWith((ref) => reviewsStream ?? Stream.value(_reviews)),
        watchEventsByIdsProvider(
          EventsByIdQuery(eventIds),
        ).overrideWith((ref) => eventsStream ?? Stream.value([_event])),
      ],
      child: child,
    );
  }
}

class _SettingsScope extends StatelessWidget {
  const _SettingsScope({
    required this.child,
    this.profileStream,
    this.blockedUsersStream,
    this.publicProfiles = const {},
  });

  final Widget child;
  final Stream<UserProfile?>? profileStream;
  final Stream<List<BlockedUser>>? blockedUsersStream;
  final Map<String, PublicProfile> publicProfiles;

  @override
  Widget build(BuildContext context) {
    final query = PublicProfilesQuery(
      _blockedUsers.map((blocked) => blocked.uid),
    );
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream<String?>.value(_viewerUid)),
        watchUserProfileProvider.overrideWith(
          (ref) => profileStream ?? Stream<UserProfile?>.value(_viewer),
        ),
        watchBlockedUsersProvider.overrideWith(
          (ref) => blockedUsersStream ?? Stream.value(const <BlockedUser>[]),
        ),
        publicProfilesByIdsProvider(
          query,
        ).overrideWith((ref) async => publicProfiles),
        externalUrlLauncherProvider.overrideWithValue(_noopLauncher),
      ],
      child: child,
    );
  }
}

class _PaymentScope extends StatelessWidget {
  const _PaymentScope({
    required this.child,
    this.uidStream,
    this.payments,
    this.paymentsStream,
    this.paymentsByPaymentId,
    this.eventsById,
  });

  final Widget child;
  final Stream<String?>? uidStream;
  final List<Payment>? payments;
  final Stream<List<Payment>>? paymentsStream;
  final Map<String, Payment?>? paymentsByPaymentId;
  final Map<String, Event>? eventsById;

  @override
  Widget build(BuildContext context) {
    final payments = this.payments ?? _payments;
    final eventIds = {for (final payment in payments) payment.eventId};
    final batchedEvents = eventsById == null
        ? [
            for (final payment in payments)
              _utilityEvent(
                id: payment.eventId,
                meetingPoint: _eventTitleForPayment(payment),
                notes: 'Receipt context',
                latitude: 19.0676,
                longitude: 72.8227,
              ),
          ]
        : eventsById!.values.toList(growable: false);
    final paymentsById =
        paymentsByPaymentId ??
        {for (final payment in payments) payment.paymentId: payment};
    final eventOverrides = [
      for (final payment in payments)
        watchEventProvider(payment.eventId).overrideWith(
          (ref) => Stream<Event?>.value(eventsById?[payment.eventId]),
        ),
    ];
    final paymentOverrides = [
      for (final entry in paymentsById.entries)
        watchPaymentProvider(
          entry.key,
        ).overrideWith((ref) => Stream<Payment?>.value(entry.value)),
    ];
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith(
          (ref) => uidStream ?? Stream<String?>.value(_viewerUid),
        ),
        watchPaymentsForUserProvider(
          _viewerUid,
        ).overrideWith((ref) => paymentsStream ?? Stream.value(payments)),
        if (eventIds.isNotEmpty)
          watchEventsByIdsProvider(
            EventsByIdQuery(eventIds),
          ).overrideWith((ref) => Stream.value(batchedEvents)),
        watchClubProvider(
          _event.clubId,
        ).overrideWith((ref) => Stream<Club?>.value(null)),
        ...eventOverrides,
        ...paymentOverrides,
      ],
      child: child,
    );
  }
}

class _UtilityCatalog extends StatelessWidget {
  const _UtilityCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _utilityDeviceFrameMaxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: _utilityDeviceFrameHeight, child: child),
          ),
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: textScaler ?? media.textScaler,
        disableAnimations: disableAnimations || media.disableAnimations,
      ),
      child: child,
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _utilityDeviceFrameMaxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.bg,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(
              height: _utilitySheetFrameHeight,
              child: Align(alignment: Alignment.bottomCenter, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogFrame extends StatelessWidget {
  const _DialogFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.ink.withValues(alpha: CatchOpacity.confirmDialogScrim),
      child: SizedBox(
        height: _utilityDialogFrameHeight,
        child: Center(child: child),
      ),
    );
  }
}

EventDetailViewModel _eventVm(Event event) => EventDetailViewModel(
  event: event,
  userProfile: _viewer,
  reviews: const [],
  isAuthenticated: true,
  isHost: false,
  isSaved: false,
  participation: null,
);

Event _calendarEvent({
  required String id,
  required DateTime startTime,
  required String meetingPoint,
  required String notes,
  required double distanceKm,
  required int bookedCount,
  int priceInPaise = 0,
  EventLifecycleStatus status = EventLifecycleStatus.active,
}) {
  return UtilitySurfaceFixtures.eventFixture(
    id: id,
    meetingPoint: meetingPoint,
    notes: notes,
    latitude: 19.0676,
    longitude: 72.8227,
  ).copyWith(
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1, minutes: 30)),
    distanceKm: distanceKm,
    bookedCount: bookedCount,
    priceInPaise: priceInPaise,
    status: status,
  );
}

Event _utilityEvent({
  required String id,
  required String meetingPoint,
  required String? notes,
  required double? latitude,
  required double? longitude,
}) => UtilitySurfaceFixtures.eventFixture(
  id: id,
  meetingPoint: meetingPoint,
  notes: notes,
  latitude: latitude,
  longitude: longitude,
);

String _eventTitleForPayment(Payment payment) =>
    UtilitySurfaceFixtures.eventTitleForPayment(payment);

PaymentHistoryViewModel _paymentHistoryViewModel(Iterable<Payment> payments) {
  return PaymentHistoryViewModel(
    rows: [
      for (final payment in payments)
        PaymentHistoryRow(
          payment: payment,
          eventTitle: _eventTitleForPayment(payment),
        ),
    ],
  );
}

PaymentConfirmationData _confirmationData(Payment payment, {Uri? checkoutUrl}) {
  return PaymentConfirmationData(
    paymentId: payment.paymentId,
    orderId: payment.orderId,
    amountInPaise: payment.amount,
    currency: payment.currency,
    eventId: _event.id,
    provider: checkoutUrl == null ? 'razorpay' : 'stripe',
    status: payment.status,
    checkoutUrl: checkoutUrl,
  );
}

Review _reviewWithOwnerResponse() {
  final existing = _reviews.where((review) => review.ownerResponse != null);
  if (existing.isNotEmpty) return existing.first;
  return _reviews.first.copyWith(
    ownerResponse: ReviewOwnerResponse(
      hostUserId: 'host-mira',
      hostName: 'Mira Shah',
      message: 'Thanks for the thoughtful review. We will keep this route.',
      createdAt: _calendarNow,
      updatedAt: _calendarNow,
    ),
  );
}

List<ReviewsHistoryRow> _reviewHistoryRows() {
  final editableReview = _reviews.first;
  final responseReview = _reviewWithOwnerResponse();
  return [
    ReviewsHistoryRow(
      review: editableReview,
      contextLabel: 'Sunday Sea Face Crew · Jun 22',
      editEventId: editableReview.eventId,
    ),
    ReviewsHistoryRow(
      review: responseReview,
      contextLabel: 'Bandra afterglow run · missing event context',
      editEventId: null,
    ),
  ];
}

void _noopReviewEdit(Review review) {}

void _noopReviewHistoryEdit(ReviewsHistoryRow row) {}

void _noopIndex(int index) {}

void _noopReorder(int fromIndex, int toIndex) {}

final _blockedUsers = UtilitySurfaceFixtures.blockedUsers;

Stream<T> _loadingStream<T>() => UtilitySurfaceFixtures.loadingStream<T>();

Stream<T> _errorStream<T>(String message) =>
    UtilitySurfaceFixtures.errorStream<T>(message);

EventPolicyPreviewResult _eventPolicyResult(
  EventPolicyPreviewScenario scenario,
) {
  const harness = EventPolicyPreviewHarness();
  return harness.preview(scenario);
}

void _noopScenarioSelect(EventPolicyPreviewScenario scenario) {}

Future<bool> _noopLauncher(Uri uri, {Object? mode}) async {
  return true;
}

Widget _photoSlotFrame({required Widget child}) {
  return Center(
    child: SizedBox(
      width: _utilityPhotoSlotWidth,
      height: _utilityPhotoSlotHeight,
      child: child,
    ),
  );
}

void _noop() {}

void _noopCode(String _) {}
