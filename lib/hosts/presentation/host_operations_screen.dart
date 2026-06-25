import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_info_row.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_settings_row.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_club_edit_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_profile_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_settings_state.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostOperationsHomeScreen extends ConsumerWidget {
  const HostOperationsHomeScreen({
    super.key,
    this.initialClubId,
    this.initialTab = HostHomeTab.today,
  });

  final String? initialClubId;
  final HostHomeTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;
    final clubsAsync = uid == null
        ? null
        : ref.watch(_hostClubsForUserProvider(uid));
    final routeState = HostHomeRouteState.fromAsync(
      uid: uidAsync,
      clubs: clubsAsync,
    );

    return switch (routeState.status) {
      HostHomeRouteStatus.authRequired => const _HostAuthRequiredScreen(),
      HostHomeRouteStatus.loading => const _HostLoadingScreen(
        title: 'Host events',
      ),
      HostHomeRouteStatus.error => CatchErrorScaffold.fromError(
        routeState.error!,
        context: routeState.errorContext,
        onRetry: () => _retryHostHomeRoute(ref, routeState),
      ),
      HostHomeRouteStatus.empty => _HostEventsScaffold(
        clubs: routeState.clubs,
        currentUid: routeState.uid!,
        initialClubId: initialClubId,
        initialTab: initialTab,
      ),
      HostHomeRouteStatus.loaded => _HostEventsScaffold(
        clubs: routeState.clubs,
        currentUid: routeState.uid!,
        initialClubId: initialClubId,
        initialTab: initialTab,
      ),
    };
  }
}

class HostClubsScreen extends ConsumerWidget {
  const HostClubsScreen({
    super.key,
    this.initialClubId,
    this.initialTab = HostClubTab.organizer,
    this.initialExpandedEditField,
  });

  final String? initialClubId;
  final HostClubTab initialTab;
  final String? initialExpandedEditField;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null) return const _HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return CatchAsyncValueView<List<Club>>(
      value: clubsAsync,
      loadingBuilder: (_) =>
          const _HostLoadingScreen(title: 'Clubs', showTabRail: true),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      builder: (context, clubs) => _HostClubsScaffold(
        clubs: clubs,
        currentUid: uid,
        initialClubId: initialClubId,
        initialTab: initialTab,
        initialExpandedEditField: initialExpandedEditField,
      ),
    );
  }
}

void _retryHostHomeRoute(WidgetRef ref, HostHomeRouteState state) {
  final uid = state.uid;
  if (state.errorContext == AppErrorContext.auth || uid == null) {
    ref.invalidate(uidProvider);
    return;
  }
  ref.invalidate(_hostClubsForUserProvider(uid));
}

enum HostSettingsMode { edit, preview }

enum HostClubTab { organizer, edit, insights, preview }

enum HostHomeTab { today, events }

typedef HostHomeCreateEventCallback = void Function(Club club);
typedef HostHomeManageEventCallback = void Function(Club club, Event event);
typedef HostClubPreviewCallback = void Function(Club club);

enum HostHomeRouteStatus { authRequired, loading, error, empty, loaded }

@immutable
class HostHomeRouteState {
  const HostHomeRouteState._({
    required this.status,
    this.uid,
    this.clubs = const [],
    this.error,
    this.stackTrace,
    this.errorContext = AppErrorContext.club,
  });

  factory HostHomeRouteState.fromAsync({
    required AsyncValue<String?> uid,
    AsyncValue<List<Club>>? clubs,
  }) {
    if (uid.hasError) {
      return HostHomeRouteState._(
        status: HostHomeRouteStatus.error,
        error: uid.error,
        stackTrace: uid.stackTrace,
        errorContext: AppErrorContext.auth,
      );
    }

    final currentUid = uid.asData?.value;
    if (currentUid == null) {
      return uid.isLoading
          ? const HostHomeRouteState._(status: HostHomeRouteStatus.loading)
          : const HostHomeRouteState._(
              status: HostHomeRouteStatus.authRequired,
            );
    }

    final clubValue = clubs;
    if (clubValue == null || clubValue.isLoading) {
      return HostHomeRouteState._(
        status: HostHomeRouteStatus.loading,
        uid: currentUid,
      );
    }
    if (clubValue.hasError) {
      return HostHomeRouteState._(
        status: HostHomeRouteStatus.error,
        uid: currentUid,
        error: clubValue.error,
        stackTrace: clubValue.stackTrace,
      );
    }

    final resolvedClubs = List<Club>.unmodifiable(
      clubValue.asData?.value ?? const <Club>[],
    );
    return HostHomeRouteState._(
      status: resolvedClubs.isEmpty
          ? HostHomeRouteStatus.empty
          : HostHomeRouteStatus.loaded,
      uid: currentUid,
      clubs: resolvedClubs,
    );
  }

  final HostHomeRouteStatus status;
  final String? uid;
  final List<Club> clubs;
  final Object? error;
  final StackTrace? stackTrace;
  final AppErrorContext errorContext;
}

@immutable
class HostHomeScreenState {
  const HostHomeScreenState._({
    required this.clubs,
    required this.currentUid,
    required this.selectedClubIndex,
    required this.selectedTab,
  });

  factory HostHomeScreenState.resolve({
    required List<Club> clubs,
    required String currentUid,
    int selectedClubIndex = 0,
    String? selectedClubId,
    HostHomeTab selectedTab = HostHomeTab.today,
  }) {
    return HostHomeScreenState._(
      clubs: List<Club>.unmodifiable(clubs),
      currentUid: currentUid,
      selectedClubIndex: _resolveSelectedClubIndex(
        clubs: clubs,
        selectedClubIndex: selectedClubIndex,
        selectedClubId: selectedClubId,
      ),
      selectedTab: selectedTab,
    );
  }

  final List<Club> clubs;
  final String currentUid;
  final int selectedClubIndex;
  final HostHomeTab selectedTab;

  bool get hasClubs => clubs.isNotEmpty;
  bool get showClubPicker => clubs.length > 1;
  Club? get selectedClub => hasClubs ? clubs[selectedClubIndex] : null;
  String get title => selectedClub?.name ?? 'Host events';
  bool get selectedClubIsOwner => selectedClub?.isOwnedBy(currentUid) ?? false;
  String get selectedClubRoleLabel =>
      selectedClubIsOwner ? 'Owner' : 'Host team';

  HostHomeScreenState selectClubIndex(int index) {
    return HostHomeScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: index,
      selectedTab: selectedTab,
    );
  }

  HostHomeScreenState selectTab(HostHomeTab tab) {
    return HostHomeScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: selectedClubIndex,
      selectedTab: tab,
    );
  }
}

@immutable
class HostHomeEventRowsState {
  const HostHomeEventRowsState._({required this.rows});

  factory HostHomeEventRowsState.fromEvents(
    Iterable<Event> events, {
    int limit = 3,
  }) {
    final activeEvents = events.where((event) => !event.isCancelled).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final visibleEvents = activeEvents.take(limit).toList(growable: false);
    return HostHomeEventRowsState._(
      rows: [
        for (var index = 0; index < visibleEvents.length; index++)
          HostHomeEventRowData(event: visibleEvents[index], divider: index > 0),
      ],
    );
  }

  final List<HostHomeEventRowData> rows;

  bool get isEmpty => rows.isEmpty;
}

@immutable
class HostHomeEventRowData {
  const HostHomeEventRowData({required this.event, required this.divider});

  final Event event;
  final bool divider;

  String get title => event.title;
  String get timeRangeLabel => event.timeRangeLabel;
}

enum HostHomeEventsStatus { loading, error, empty, populated }

@immutable
class HostHomeEventsSectionState {
  const HostHomeEventsSectionState._({
    required this.status,
    this.rows = const HostHomeEventRowsState._(rows: []),
    this.error,
    this.stackTrace,
  });

  factory HostHomeEventsSectionState.fromAsync(AsyncValue<List<Event>> events) {
    if (events.isLoading) {
      return const HostHomeEventsSectionState._(
        status: HostHomeEventsStatus.loading,
      );
    }
    if (events.hasError) {
      return HostHomeEventsSectionState._(
        status: HostHomeEventsStatus.error,
        error: events.error,
        stackTrace: events.stackTrace,
      );
    }

    final rows = HostHomeEventRowsState.fromEvents(
      events.asData?.value ?? const <Event>[],
    );
    return HostHomeEventsSectionState._(
      status: rows.isEmpty
          ? HostHomeEventsStatus.empty
          : HostHomeEventsStatus.populated,
      rows: rows,
    );
  }

  final HostHomeEventsStatus status;
  final HostHomeEventRowsState rows;
  final Object? error;
  final StackTrace? stackTrace;
}

enum HostHomeTodayStatus { loading, error, empty, content }

@immutable
class HostHomeTodayDashboardState {
  const HostHomeTodayDashboardState._({
    required this.status,
    this.event,
    this.tasks = const <HostHomeTodayTaskData>[],
    this.error,
    this.stackTrace,
  });

  factory HostHomeTodayDashboardState.fromAsync(
    AsyncValue<List<Event>> events,
  ) {
    if (events.isLoading) {
      return const HostHomeTodayDashboardState._(
        status: HostHomeTodayStatus.loading,
      );
    }
    if (events.hasError) {
      return HostHomeTodayDashboardState._(
        status: HostHomeTodayStatus.error,
        error: events.error,
        stackTrace: events.stackTrace,
      );
    }

    final activeEvents = events.asData?.value
        .where((event) => !event.isCancelled)
        .toList();
    activeEvents?.sort((a, b) => a.startTime.compareTo(b.startTime));
    final event = activeEvents?.firstOrNull;
    if (event == null) {
      return const HostHomeTodayDashboardState._(
        status: HostHomeTodayStatus.empty,
      );
    }

    return HostHomeTodayDashboardState._(
      status: HostHomeTodayStatus.content,
      event: event,
      tasks: HostHomeTodayTaskData.forEvent(event),
    );
  }

  final HostHomeTodayStatus status;
  final Event? event;
  final List<HostHomeTodayTaskData> tasks;
  final Object? error;
  final StackTrace? stackTrace;
}

@immutable
class HostHomeTodayTaskData {
  const HostHomeTodayTaskData({
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.icon,
  });

  factory HostHomeTodayTaskData.approveRequests(Event event) {
    final waitlistCount = event.waitlistCount;
    return HostHomeTodayTaskData(
      title: 'Approve requests',
      body: waitlistCount > 0
          ? '$waitlistCount people want into ${event.title}'
          : 'Review pending guest requests before the event opens.',
      primaryActionLabel: 'Approve',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.personSearchOutlined,
    );
  }

  factory HostHomeTodayTaskData.offerWaitlist(Event event) {
    final waitlistCount = event.waitlistCount;
    final openCount = event.spotsRemaining;
    return HostHomeTodayTaskData(
      title: 'Offer waitlist spots',
      body: waitlistCount > 0
          ? '$waitlistCount waiting · $openCount spots open'
          : 'No waitlist pressure right now.',
      primaryActionLabel: waitlistCount > 0 ? 'Offer $waitlistCount' : 'Review',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.groupAddOutlined,
    );
  }

  factory HostHomeTodayTaskData.guestWaiting(Event event) {
    return HostHomeTodayTaskData(
      title: 'A guest is waiting on you',
      body: 'Reply before ${EventFormatters.time(event.startTime)}.',
      primaryActionLabel: 'Reply',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.chatBubbleOutlineRounded,
    );
  }

  factory HostHomeTodayTaskData.hostSetup(Event event) {
    return HostHomeTodayTaskData(
      title: 'Check host setup',
      body: 'Confirm entry flow, venue notes, and host cues.',
      primaryActionLabel: 'Check',
      secondaryActionLabel: 'Later',
      icon: CatchIcons.factCheckOutlined,
    );
  }

  static List<HostHomeTodayTaskData> forEvent(Event event) => [
    HostHomeTodayTaskData.approveRequests(event),
    HostHomeTodayTaskData.offerWaitlist(event),
    HostHomeTodayTaskData.guestWaiting(event),
    HostHomeTodayTaskData.hostSetup(event),
  ];

  final String title;
  final String body;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final IconData icon;
}

@immutable
class HostClubsScreenState {
  const HostClubsScreenState._({
    required this.clubs,
    required this.currentUid,
    required this.selectedClubIndex,
    required this.selectedTab,
  });

  factory HostClubsScreenState.resolve({
    required List<Club> clubs,
    required String currentUid,
    int selectedClubIndex = 0,
    String? selectedClubId,
    HostClubTab selectedTab = HostClubTab.organizer,
  }) {
    return HostClubsScreenState._(
      clubs: List<Club>.unmodifiable(clubs),
      currentUid: currentUid,
      selectedClubIndex: _resolveSelectedClubIndex(
        clubs: clubs,
        selectedClubIndex: selectedClubIndex,
        selectedClubId: selectedClubId,
      ),
      selectedTab: selectedTab,
    );
  }

  final List<Club> clubs;
  final String currentUid;
  final int selectedClubIndex;
  final HostClubTab selectedTab;

  bool get hasClubs => clubs.isNotEmpty;
  bool get showClubPicker => clubs.length > 1;
  Club? get selectedClub => hasClubs ? clubs[selectedClubIndex] : null;
  String get title => selectedClub?.name ?? 'Clubs';
  bool get selectedClubIsOwner => selectedClub?.isOwnedBy(currentUid) ?? false;

  HostClubsScreenState selectClubIndex(int index) {
    return HostClubsScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: index,
      selectedTab: selectedTab,
    );
  }

  HostClubsScreenState selectTab(HostClubTab tab) {
    return HostClubsScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: selectedClubIndex,
      selectedTab: tab,
    );
  }

  static int _resolveSelectedClubIndex({
    required List<Club> clubs,
    required int selectedClubIndex,
    String? selectedClubId,
  }) {
    if (clubs.isEmpty) return 0;
    final selectedId = selectedClubId;
    if (selectedId != null) {
      final index = clubs.indexWhere((club) => club.id == selectedId);
      if (index != -1) return index;
    }
    if (selectedClubIndex < 0) return 0;
    if (selectedClubIndex >= clubs.length) return clubs.length - 1;
    return selectedClubIndex;
  }
}

@immutable
class HostClubInsightsState {
  const HostClubInsightsState._({
    required this.clubId,
    required this.rangePreset,
    required this.granularity,
    required this.selectedEventId,
    required this.customStartDate,
    required this.customEndDate,
  });

  factory HostClubInsightsState.initial({
    required String clubId,
    DateTime? now,
  }) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    return HostClubInsightsState._(
      clubId: clubId,
      rangePreset: HostAnalyticsRangePreset.thirtyDays,
      granularity: HostAnalyticsGranularity.day,
      selectedEventId: null,
      customStartDate: DateTime(today.year, today.month, today.day - 29),
      customEndDate: today,
    );
  }

  final String clubId;
  final HostAnalyticsRangePreset rangePreset;
  final HostAnalyticsGranularity granularity;
  final String? selectedEventId;
  final DateTime customStartDate;
  final DateTime customEndDate;

  HostAnalyticsQuery get query {
    return HostAnalyticsQuery(
      clubId: clubId,
      eventId: selectedEventId,
      rangePreset: rangePreset,
      startDate: customStartDate,
      endDate: customEndDate,
      granularity: granularity,
    );
  }

  HostClubInsightsState selectClub(String clubId) {
    if (clubId == this.clubId) return this;
    return _copyWith(clubId: clubId, selectedEventId: null);
  }

  HostClubInsightsState selectRange(HostAnalyticsRangePreset rangePreset) {
    return _copyWith(rangePreset: rangePreset);
  }

  HostClubInsightsState selectGranularity(
    HostAnalyticsGranularity granularity,
  ) {
    return _copyWith(granularity: granularity);
  }

  HostClubInsightsState selectEvent(String eventId) {
    return _copyWith(selectedEventId: eventId);
  }

  HostClubInsightsState clearEvent() {
    if (selectedEventId == null) return this;
    return _copyWith(selectedEventId: null);
  }

  HostClubInsightsState selectCustomStartDate(DateTime date) {
    return _copyWith(
      rangePreset: HostAnalyticsRangePreset.custom,
      customStartDate: DateUtils.dateOnly(date),
    );
  }

  HostClubInsightsState selectCustomEndDate(DateTime date) {
    return _copyWith(
      rangePreset: HostAnalyticsRangePreset.custom,
      customEndDate: DateUtils.dateOnly(date),
    );
  }

  HostClubInsightsState _copyWith({
    String? clubId,
    HostAnalyticsRangePreset? rangePreset,
    HostAnalyticsGranularity? granularity,
    Object? selectedEventId = _unchanged,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return HostClubInsightsState._(
      clubId: clubId ?? this.clubId,
      rangePreset: rangePreset ?? this.rangePreset,
      granularity: granularity ?? this.granularity,
      selectedEventId: selectedEventId == _unchanged
          ? this.selectedEventId
          : selectedEventId as String?,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

const Object _unchanged = Object();

int _resolveSelectedClubIndex({
  required List<Club> clubs,
  required int selectedClubIndex,
  String? selectedClubId,
}) {
  if (clubs.isEmpty) return 0;
  final selectedId = selectedClubId;
  if (selectedId != null) {
    final index = clubs.indexWhere((club) => club.id == selectedId);
    if (index != -1) return index;
  }
  if (selectedClubIndex < 0) return 0;
  if (selectedClubIndex >= clubs.length) return clubs.length - 1;
  return selectedClubIndex;
}

const _hostClubTabRailKey = ValueKey('host-club-tab-rail');

class HostAccountScreen extends ConsumerStatefulWidget {
  const HostAccountScreen({super.key});

  @override
  ConsumerState<HostAccountScreen> createState() => _HostAccountScreenState();
}

class _HostAccountScreenState extends ConsumerState<HostAccountScreen> {
  var _selectedTab = HostSettingsMode.edit;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    final hostProfileAsync = uid == null
        ? const AsyncData<HostProfile?>(null)
        : ref.watch(watchHostProfileProvider(uid));
    final clubsAsync = uid == null
        ? const AsyncData<List<Club>>([])
        : ref.watch(_hostClubsForUserProvider(uid));
    final state = HostSettingsState.fromAsync(
      uid: uid,
      profile: hostProfileAsync,
      clubs: clubsAsync,
    );
    final profileForEdit = switch (state.profile) {
      HostSettingsProfileContent(:final profile) => profile,
      _ => null,
    };
    final ensureMutation = ref.watch(
      HostProfileController.ensureProfileMutation,
    );
    final signOutMutation = ref.watch(AuthSessionController.signOutMutation);
    final isEditMode = _selectedTab == HostSettingsMode.edit;

    return CatchMutationErrorListener(
      mutation: AuthSessionController.signOutMutation,
      errorContext: AppErrorContext.auth,
      child: CatchMutationErrorListeners(
        mutations: [
          HostProfileController.ensureProfileMutation,
          HostProfileController.saveProfileMutation,
        ],
        errorContext: AppErrorContext.profile,
        child: Scaffold(
          backgroundColor: t.bg,
          appBar: CatchTopBar(
            title: 'Host profile',
            showBackButton: false,
            border: true,
            actions: [
              CatchTopBarIconAction(
                tooltip: 'Sign out',
                icon: CatchIcons.logoutRounded,
                onPressed: signOutMutation.isPending
                    ? null
                    : () => unawaited(_signOut(context, ref)),
              ),
            ],
            bottom: HostSettingsTabRail(
              selected: _selectedTab,
              onChanged: (tab) => setState(() => _selectedTab = tab),
            ),
          ),
          body: ListView(
            padding: CatchInsets.pageBodyUnderHeader,
            children: [
              HostSettingsProfileSection(
                state: state.profile,
                editMode: isEditMode,
                creatingProfile: ensureMutation.isPending,
                onRetry: uid == null
                    ? null
                    : () => ref.invalidate(watchHostProfileProvider(uid)),
                onCreateProfile: uid == null
                    ? null
                    : () => unawaited(_createHostProfile()),
                onEditProfile: uid != null && profileForEdit != null
                    ? () => unawaited(_openProfileEditor(uid, profileForEdit))
                    : null,
              ),
              HostSettingsClubsSection(
                uid: uid,
                state: state.clubs,
                onRetry: uid == null
                    ? null
                    : () => ref.invalidate(_hostClubsForUserProvider(uid)),
                editMode: isEditMode,
                onOpenClub: (club) => _openSettingsClub(club, isEditMode, uid),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openProfileEditor(String uid, HostProfile profile) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => HostProfileEditorSheet(profile: profile),
    );
    if (saved == true && mounted) {
      showCatchSnackBar(context, 'Host profile saved.');
    }
  }

  Future<void> _createHostProfile() async {
    try {
      await HostProfileController.ensureProfileMutation.run(
        ref,
        (tx) async =>
            tx.get(hostProfileControllerProvider.notifier).ensureProfile(),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
      return;
    }
    if (!mounted) return;
    showCatchSnackBar(context, 'Host profile created.');
  }

  void _openSettingsClub(Club club, bool editMode, String? uid) {
    context.pushNamed(
      editMode && club.isOwnedBy(uid)
          ? Routes.hostEditClubScreen.name
          : Routes.hostClubDetailScreen.name,
      pathParameters: {'clubId': club.id},
      extra: club,
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final mutation = ref.read(AuthSessionController.signOutMutation);
    if (mutation.isPending) return;
    try {
      await AuthSessionController.signOutMutation.run(
        ref,
        (tx) async => tx.get(authSessionControllerProvider.notifier).signOut(),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
      return;
    }
    if (context.mounted) context.go(Routes.startScreen.path);
  }
}

class HostSettingsTabRail extends StatelessWidget
    implements PreferredSizeWidget {
  const HostSettingsTabRail({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HostSettingsMode selected;
  final ValueChanged<HostSettingsMode> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          0,
          CatchSpacing.s5,
          CatchSpacing.s2,
        ),
        child: CatchOptionGroup<HostSettingsMode>(
          selected: selected,
          onChanged: onChanged,
          options: const [
            CatchOption(value: HostSettingsMode.edit, label: 'Edit'),
            CatchOption(value: HostSettingsMode.preview, label: 'Preview'),
          ],
        ),
      ),
    );
  }
}

class HostSettingsSection extends StatelessWidget {
  const HostSettingsSection({
    super.key,
    required this.label,
    required this.children,
    this.first = false,
  });

  final String label;
  final List<Widget> children;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : CatchSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!first) ...[
            Divider(color: t.line, height: 1, thickness: 1),
            gapH18,
          ],
          Text(label, style: CatchTextStyles.kicker(context, color: t.ink2)),
          gapH10,
          ...children,
        ],
      ),
    );
  }
}

class HostSettingsProfileSection extends StatelessWidget {
  const HostSettingsProfileSection({
    super.key,
    required this.state,
    required this.editMode,
    this.creatingProfile = false,
    required this.onRetry,
    required this.onCreateProfile,
    required this.onEditProfile,
  });

  final HostSettingsProfileState state;
  final bool editMode;
  final bool creatingProfile;
  final VoidCallback? onRetry;
  final VoidCallback? onCreateProfile;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      HostSettingsProfileLoading() => const HostSettingsRowsSkeleton(),
      HostSettingsProfileError(:final error) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.profile,
        onRetry: onRetry,
      ),
      HostSettingsProfileMissing() => HostSettingsSection(
        label: 'Profile',
        first: true,
        children: [
          CatchSettingsRow(
            label: 'Display name',
            value: creatingProfile
                ? 'Creating profile...'
                : 'Create host profile',
            icon: CatchIcons.businessOutlined,
            trailing: creatingProfile
                ? const SizedBox.square(
                    dimension: CatchIcon.md,
                    child: CatchLoadingIndicator(
                      strokeWidth: CatchIcon.strokeSm,
                    ),
                  )
                : null,
            onTap: creatingProfile ? null : onCreateProfile,
            showChevron: !creatingProfile,
          ),
        ],
      ),
      HostSettingsProfileContent(:final profile) => _HostSettingsProfileRows(
        profile: profile,
        editMode: editMode,
        onEditProfile: onEditProfile,
      ),
    };
  }
}

class _HostSettingsProfileRows extends StatelessWidget {
  const _HostSettingsProfileRows({
    required this.profile,
    required this.editMode,
    required this.onEditProfile,
  });

  final HostProfile profile;
  final bool editMode;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final canEdit = editMode && onEditProfile != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostSettingsSection(
          label: 'Profile',
          first: true,
          children: [
            CatchSettingsRow(
              label: 'Display name',
              value: profile.displayName,
              icon: CatchIcons.personOutlineRounded,
              onTap: canEdit ? onEditProfile : null,
              showChevron: canEdit,
            ),
            CatchSettingsRow(
              label: 'Role title',
              value: profile.roleTitle?.trim().isNotEmpty == true
                  ? profile.roleTitle!.trim()
                  : 'Add role title',
              icon: CatchIcons.cardMembershipOutlined,
              divider: true,
              onTap: canEdit ? onEditProfile : null,
              showChevron: canEdit,
            ),
            CatchSettingsRow(
              label: 'Status',
              value: hostProfileStatusLabel(profile.status),
              icon: CatchIcons.checkCircleOutlineRounded,
              divider: true,
              showChevron: false,
            ),
          ],
        ),
        HostSettingsSection(
          label: 'Bio',
          children: [
            CatchSettingsRow(
              label: 'About you as a host',
              value: profile.bio?.trim().isNotEmpty == true
                  ? profile.bio!.trim()
                  : 'Add a host bio',
              icon: CatchIcons.chatBubbleOutlineRounded,
              valueMaxLines: 2,
              onTap: canEdit ? onEditProfile : null,
              showChevron: canEdit,
            ),
          ],
        ),
      ],
    );
  }
}

class HostSettingsClubsSection extends StatelessWidget {
  const HostSettingsClubsSection({
    super.key,
    required this.uid,
    required this.state,
    required this.onRetry,
    required this.editMode,
    required this.onOpenClub,
  });

  final String? uid;
  final HostSettingsClubsState state;
  final VoidCallback? onRetry;
  final bool editMode;
  final ValueChanged<Club> onOpenClub;

  @override
  Widget build(BuildContext context) {
    return HostSettingsSection(
      label: 'Clubs you host',
      children: [
        switch (state) {
          HostSettingsClubsLoading() => const HostSettingsRowsSkeleton(
            rowCount: 2,
          ),
          HostSettingsClubsError(:final error) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            onRetry: onRetry,
          ),
          HostSettingsClubsEmpty() => const _HostSettingsClubsEmptyState(),
          HostSettingsClubsContent(:final clubs) => _HostSettingsClubRows(
            uid: uid,
            clubs: clubs,
            onOpenClub: onOpenClub,
          ),
        },
      ],
    );
  }
}

class _HostSettingsClubsEmptyState extends StatelessWidget {
  const _HostSettingsClubsEmptyState();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(
      'No host clubs yet.',
      style: CatchTextStyles.supporting(context, color: t.ink2),
    );
  }
}

class _HostSettingsClubRows extends StatelessWidget {
  const _HostSettingsClubRows({
    required this.uid,
    required this.clubs,
    required this.onOpenClub,
  });

  final String? uid;
  final List<Club> clubs;
  final ValueChanged<Club> onOpenClub;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final club in clubs)
          CatchSettingsRow(
            label: club.isOwnedBy(uid) ? 'Owner' : 'Host team',
            value: club.name,
            icon: CatchIcons.groupOutlined,
            divider: club != clubs.first,
            onTap: () => onOpenClub(club),
          ),
      ],
    );
  }
}

class HostProfileEditorSheet extends ConsumerStatefulWidget {
  const HostProfileEditorSheet({super.key, required this.profile});

  final HostProfile profile;

  @override
  ConsumerState<HostProfileEditorSheet> createState() =>
      _HostProfileEditorSheetState();
}

class _HostProfileEditorSheetState
    extends ConsumerState<HostProfileEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.profile.displayName;
    _roleTitleController.text = widget.profile.roleTitle ?? '';
    _bioController.text = widget.profile.bio ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saveMutation = ref.watch(HostProfileController.saveProfileMutation);
    return Form(
      key: _formKey,
      child: CatchBottomSheetScaffold(
        title: 'Professional profile',
        subtitle: hostProfileStatusLabel(widget.profile.status),
        keyboardSafe: true,
        action: CatchButton(
          label: 'Save profile',
          icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
          isLoading: saveMutation.isPending,
          fullWidth: true,
          onPressed: saveMutation.isPending
              ? null
              : () => unawaited(_saveProfile()),
        ),
        child: HostProfileFields(
          status: widget.profile.status,
          displayNameController: _displayNameController,
          roleTitleController: _roleTitleController,
          bioController: _bioController,
          showStatus: false,
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    try {
      await HostProfileController.saveProfileMutation.run(
        ref,
        (tx) async => tx
            .get(hostProfileControllerProvider.notifier)
            .saveProfile(
              displayName: _displayNameController.text,
              roleTitle: _roleTitleController.text,
              bio: _bioController.text,
            ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
    }
  }
}

class HostProfileScreen extends ConsumerStatefulWidget {
  const HostProfileScreen({
    super.key,
    this.formAutovalidateMode = AutovalidateMode.disabled,
  });

  final AutovalidateMode formAutovalidateMode;

  @override
  ConsumerState<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends ConsumerState<HostProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();
  String? _loadedProfileKey;

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final compactTextScale = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final uid = ref.watch(uidProvider).asData?.value;
    final profileAsync = uid == null
        ? const AsyncData<HostProfile?>(null)
        : ref.watch(watchHostProfileProvider(uid));
    final state = HostProfileEditState.fromAsync(
      uid: uid,
      profile: profileAsync,
    );
    final ensureMutation = ref.watch(
      HostProfileController.ensureProfileMutation,
    );
    final saveMutation = ref.watch(HostProfileController.saveProfileMutation);
    if (state is HostProfileEditAuthRequired || uid == null) {
      return const _HostAuthRequiredScreen();
    }

    return CatchMutationErrorListeners(
      mutations: [
        HostProfileController.ensureProfileMutation,
        HostProfileController.saveProfileMutation,
      ],
      errorContext: AppErrorContext.profile,
      child: Scaffold(
        backgroundColor: t.bg,
        appBar: CatchTopBar(
          border: true,
          titleWidget: compactTextScale
              ? Text(
                  'Professional profile',
                  semanticsLabel: 'Host profile. Professional profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleL(context, color: t.ink),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOST PROFILE',
                      style: CatchTextStyles.kicker(context, color: t.ink3),
                    ),
                    gapH2,
                    Text(
                      'Professional profile',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.titleL(context, color: t.ink),
                    ),
                  ],
                ),
        ),
        body: _buildProfileBody(
          state,
          uid,
          creatingProfile: ensureMutation.isPending,
          savingProfile: saveMutation.isPending,
        ),
      ),
    );
  }

  Widget _buildProfileBody(
    HostProfileEditState state,
    String uid, {
    required bool creatingProfile,
    required bool savingProfile,
  }) {
    return switch (state) {
      HostProfileEditAuthRequired() => const SizedBox.shrink(),
      HostProfileEditLoading() => const HostSettingsRowsSkeleton(rowCount: 4),
      HostProfileEditError(:final error) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(watchHostProfileProvider(uid)),
      ),
      HostProfileEditMissing() => HostProfileMissingState(
        creating: creatingProfile,
        onCreateProfile: () => unawaited(_createHostProfile()),
      ),
      HostProfileEditContent(:final profile) => _buildProfileForm(
        profile: profile,
        savingProfile: savingProfile,
      ),
    };
  }

  Widget _buildProfileForm({
    required HostProfile profile,
    required bool savingProfile,
  }) {
    _syncControllers(profile);
    return Form(
      key: _formKey,
      autovalidateMode: widget.formAutovalidateMode,
      child: HostProfileForm(
        profile: profile,
        displayNameController: _displayNameController,
        roleTitleController: _roleTitleController,
        bioController: _bioController,
        saving: savingProfile,
        onSave: () => unawaited(_saveProfile()),
      ),
    );
  }

  void _syncControllers(HostProfile profile) {
    final key = [
      profile.uid,
      profile.displayName,
      profile.roleTitle,
      profile.bio,
      profile.updatedAt?.microsecondsSinceEpoch,
    ].join('|');
    if (_loadedProfileKey == key) return;
    _loadedProfileKey = key;
    _displayNameController.text = profile.displayName;
    _roleTitleController.text = profile.roleTitle ?? '';
    _bioController.text = profile.bio ?? '';
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    try {
      await HostProfileController.saveProfileMutation.run(
        ref,
        (tx) async => tx
            .get(hostProfileControllerProvider.notifier)
            .saveProfile(
              displayName: _displayNameController.text,
              roleTitle: _roleTitleController.text,
              bio: _bioController.text,
            ),
      );
      if (!mounted) return;
      showCatchSnackBar(context, 'Host profile saved.');
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
    }
  }

  Future<void> _createHostProfile() async {
    try {
      await HostProfileController.ensureProfileMutation.run(
        ref,
        (tx) async =>
            tx.get(hostProfileControllerProvider.notifier).ensureProfile(),
      );
    } catch (_) {
      // CatchMutationErrorListener owns user-facing error display.
    }
  }
}

class HostProfileForm extends StatelessWidget {
  const HostProfileForm({
    super.key,
    required this.profile,
    required this.displayNameController,
    required this.roleTitleController,
    required this.bioController,
    required this.saving,
    required this.onSave,
  });

  final HostProfile profile;
  final TextEditingController displayNameController;
  final TextEditingController roleTitleController;
  final TextEditingController bioController;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ListView(
      padding: CatchInsets.pageBodyUnderHeader,
      children: [
        CatchSurface(
          padding: CatchInsets.content,
          borderColor: t.line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HostProfileFields(
                status: profile.status,
                displayNameController: displayNameController,
                roleTitleController: roleTitleController,
                bioController: bioController,
              ),
              gapH18,
              CatchButton(
                label: 'Save profile',
                icon: Icon(CatchIcons.checkRounded, size: CatchIcon.md),
                isLoading: saving,
                fullWidth: true,
                onPressed: saving ? null : onSave,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HostProfileFields extends StatelessWidget {
  const HostProfileFields({
    super.key,
    required this.status,
    required this.displayNameController,
    required this.roleTitleController,
    required this.bioController,
    this.showStatus = true,
  });

  final HostProfileStatus status;
  final TextEditingController displayNameController;
  final TextEditingController roleTitleController;
  final TextEditingController bioController;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showStatus) ...[
          Text(
            hostProfileStatusLabel(status),
            style: CatchTextStyles.supporting(
              context,
              color: status == HostProfileStatus.active ? t.success : t.ink2,
            ),
          ),
          gapH14,
        ],
        CatchTextField(
          label: 'Display name',
          controller: displayNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          validator: _requiredDisplayName,
        ),
        gapH14,
        CatchTextField(
          label: 'Role title',
          isOptional: true,
          controller: roleTitleController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        gapH14,
        CatchTextField(
          label: 'Bio',
          isOptional: true,
          controller: bioController,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}

class HostProfileMissingState extends StatelessWidget {
  const HostProfileMissingState({
    super.key,
    required this.onCreateProfile,
    this.creating = false,
  });

  final VoidCallback onCreateProfile;
  final bool creating;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ListView(
      padding: CatchInsets.pageBodyUnderHeader,
      children: [
        CatchSurface(
          padding: CatchInsets.content,
          borderColor: t.line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No host profile yet',
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH8,
              Text(
                'Create a professional host identity before editing profile details.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              gapH18,
              CatchButton(
                label: 'Create host profile',
                icon: Icon(CatchIcons.businessOutlined, size: CatchIcon.md),
                isLoading: creating,
                onPressed: creating ? null : onCreateProfile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String? _requiredDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a display name.';
  }
  return null;
}

String hostProfileStatusLabel(HostProfileStatus status) {
  return switch (status) {
    HostProfileStatus.active => 'Active professional profile',
    HostProfileStatus.pending => 'Profile pending review',
    HostProfileStatus.suspended => 'Profile suspended',
  };
}

class _HostEventsScaffold extends StatefulWidget {
  const _HostEventsScaffold({
    required this.clubs,
    required this.currentUid,
    this.initialClubId,
    this.initialTab = HostHomeTab.today,
  });

  final List<Club> clubs;
  final String currentUid;
  final String? initialClubId;
  final HostHomeTab initialTab;

  @override
  State<_HostEventsScaffold> createState() => _HostEventsScaffoldState();
}

class _HostEventsScaffoldState extends State<_HostEventsScaffold> {
  late HostHomeScreenState _state;

  @override
  void initState() {
    super.initState();
    _state = HostHomeScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubId: widget.initialClubId,
      selectedTab: widget.initialTab,
    );
  }

  @override
  void didUpdateWidget(_HostEventsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = HostHomeScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubIndex: _state.selectedClubIndex,
      selectedClubId: _state.selectedClub?.id,
      selectedTab: _state.selectedTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final selectedClub = _state.selectedClub;

    if (_state.selectedTab == HostHomeTab.today) {
      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.screenPx,
              CatchSpacing.s12,
              CatchSpacing.screenPx,
              CatchSpacing.screenPb,
            ),
            children: [
              if (selectedClub == null)
                const _HostEmptyState(
                  title: 'Create your first club',
                  body:
                      'Create a club to publish events, manage attendees, and run Event Success.',
                )
              else
                HostTodayDashboardCard(
                  club: selectedClub,
                  currentUid: _state.currentUid,
                  clubs: _state.clubs,
                  showClubPicker: _state.showClubPicker,
                  onSwitchClubIndex: (index) =>
                      setState(() => _state = _state.selectClubIndex(index)),
                  onViewEvents: () => setState(
                    () => _state = _state.selectTab(HostHomeTab.events),
                  ),
                  onCreateEvent: _openCreateEvent,
                  onManageEvent: _openManageEvent,
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: t.bg,
      appBar: HostOperationsTopBar(
        kicker: 'OPERATIONS',
        title: _state.title,
        actions: [
          if (_state.showClubPicker)
            CatchTopBarMenuAction<int>(
              tooltip: 'Switch club',
              icon: CatchIcons.expandMoreRounded,
              items: [
                for (var index = 0; index < _state.clubs.length; index++)
                  CatchActionMenuItem(
                    value: index,
                    label:
                        '${_state.clubs[index].name} · '
                        '${_state.clubs[index].isOwnedBy(_state.currentUid) ? 'Owner' : 'Host team'}',
                  ),
              ],
              onSelected: (index) =>
                  setState(() => _state = _state.selectClubIndex(index)),
            ),
        ],
      ),
      body: ListView(
        padding: CatchInsets.pageBodyUnderHeader,
        children: [
          if (selectedClub == null)
            const _HostEmptyState(
              title: 'Create your first club',
              body:
                  'Create a club to publish events, manage attendees, and run Event Success.',
            )
          else
            HostEventsClubCard(
              club: selectedClub,
              currentUid: _state.currentUid,
              onCreateEvent: _openCreateEvent,
              onManageEvent: _openManageEvent,
            ),
        ],
      ),
    );
  }

  void _openCreateEvent(Club club) {
    context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: club,
    );
  }

  void _openManageEvent(Club club, Event event) {
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      extra: event,
    );
  }
}

class _HostClubsScaffold extends StatefulWidget {
  const _HostClubsScaffold({
    required this.clubs,
    required this.currentUid,
    required this.initialTab,
    this.initialClubId,
    this.initialExpandedEditField,
  });

  final List<Club> clubs;
  final String currentUid;
  final String? initialClubId;
  final HostClubTab initialTab;
  final String? initialExpandedEditField;

  @override
  State<_HostClubsScaffold> createState() => _HostClubsScaffoldState();
}

class _HostClubsScaffoldState extends State<_HostClubsScaffold> {
  late HostClubsScreenState _state;

  @override
  void initState() {
    super.initState();
    _state = HostClubsScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubId: widget.initialClubId,
      selectedTab: _effectiveInitialTab,
    );
  }

  @override
  void didUpdateWidget(_HostClubsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = HostClubsScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubIndex: _state.selectedClubIndex,
      selectedClubId: _state.selectedClub?.id,
      selectedTab: _state.selectedTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final selectedClub = _state.selectedClub;
    final organizerMode =
        selectedClub != null && _state.selectedTab == HostClubTab.organizer;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: organizerMode
          ? null
          : HostOperationsTopBar(
              kicker: 'HOST CLUBS',
              title: _state.title,
              bottom: selectedClub == null
                  ? null
                  : _HostClubTabRail(
                      selected: _state.selectedTab,
                      onChanged: _selectTab,
                    ),
              actions: [
                if (_state.showClubPicker)
                  CatchTopBarMenuAction<int>(
                    tooltip: 'Switch club',
                    icon: CatchIcons.expandMoreRounded,
                    items: _hostClubSwitcherItems(_state),
                    onSelected: _selectClubIndex,
                  ),
              ],
            ),
      body: SafeArea(
        top: organizerMode,
        bottom: false,
        child: ListView(
          padding: organizerMode
              ? const EdgeInsets.fromLTRB(
                  CatchSpacing.screenPx,
                  CatchSpacing.s12,
                  CatchSpacing.screenPx,
                  CatchSpacing.screenPb,
                )
              : CatchInsets.pageBodyUnderHeader,
          children: [
            if (selectedClub == null)
              const _HostEmptyState(
                title: 'No host clubs yet',
                body:
                    'Create a club or accept a host invite to start managing events.',
              )
            else
              switch (_state.selectedTab) {
                HostClubTab.edit => _HostClubProfileCard(
                  club: selectedClub,
                  currentUid: _state.currentUid,
                  isOwner: _state.selectedClubIsOwner,
                  initialExpandedField: widget.initialExpandedEditField,
                  onPreviewClub: _openClubPreview,
                ),
                HostClubTab.organizer => _HostClubOrganizerOverview(
                  club: selectedClub,
                  currentUid: _state.currentUid,
                  isOwner: _state.selectedClubIsOwner,
                  clubs: _state.clubs,
                  showClubPicker: _state.showClubPicker,
                  onSelectClubIndex: _selectClubIndex,
                  onSelectTab: _selectTab,
                  onPreviewClub: _openClubPreview,
                  onOpenSettings: _openHostSettings,
                ),
                HostClubTab.insights => _HostClubInsightsPane(
                  club: selectedClub,
                ),
                HostClubTab.preview => _HostClubPreviewPane(
                  club: selectedClub,
                  onPreviewClub: _openClubPreview,
                ),
              },
          ],
        ),
      ),
    );
  }

  HostClubTab get _effectiveInitialTab =>
      widget.initialExpandedEditField == null
      ? widget.initialTab
      : HostClubTab.edit;

  void _selectTab(HostClubTab tab) {
    setState(() => _state = _state.selectTab(tab));
  }

  void _selectClubIndex(int index) {
    setState(() => _state = _state.selectClubIndex(index));
  }

  void _openClubPreview(Club club) {
    context.pushNamed(
      Routes.hostClubDetailScreen.name,
      pathParameters: {'clubId': club.id},
      extra: club,
    );
  }

  void _openHostSettings() {
    context.pushNamed(Routes.hostSettingsScreen.name);
  }
}

class _HostClubTabRail extends StatelessWidget implements PreferredSizeWidget {
  const _HostClubTabRail({required this.selected, required this.onChanged});

  final HostClubTab selected;
  final ValueChanged<HostClubTab> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          0,
          CatchSpacing.s5,
          CatchSpacing.s2,
        ),
        child: CatchOptionGroup<HostClubTab>(
          key: _hostClubTabRailKey,
          selected: selected,
          onChanged: onChanged,
          options: const [
            CatchOption(value: HostClubTab.organizer, label: 'Organizer'),
            CatchOption(value: HostClubTab.edit, label: 'Edit'),
            CatchOption(value: HostClubTab.insights, label: 'Insights'),
            CatchOption(value: HostClubTab.preview, label: 'Preview'),
          ],
        ),
      ),
    );
  }
}

List<CatchActionMenuItem<int>> _hostClubSwitcherItems(
  HostClubsScreenState state,
) {
  return [
    for (var index = 0; index < state.clubs.length; index++)
      CatchActionMenuItem(
        value: index,
        label:
            '${state.clubs[index].name} · '
            '${state.clubs[index].isOwnedBy(state.currentUid) ? 'Owner' : 'Host team'}',
      ),
  ];
}

class HostOperationsTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const HostOperationsTopBar({
    super.key,
    required this.kicker,
    required this.title,
    this.actions = const [],
    this.bottom,
  });

  final String kicker;
  final String title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    CatchLayout.topBarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final compactTextScale = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    return CatchTopBar(
      border: true,
      actions: actions,
      bottom: bottom,
      titleWidget: compactTextScale
          ? Text(
              title,
              semanticsLabel: '$kicker. $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.titleL(context, color: t.ink),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker,
                  style: CatchTextStyles.kicker(context, color: t.ink3),
                ),
                gapH2,
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleL(context, color: t.ink),
                ),
              ],
            ),
    );
  }
}

class _HostSectionLabel extends StatelessWidget {
  const _HostSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(label, style: CatchTextStyles.kicker(context, color: t.ink3));
  }
}

class HostTodayDashboardCard extends ConsumerWidget {
  const HostTodayDashboardCard({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.onSwitchClubIndex,
    required this.onViewEvents,
    required this.onCreateEvent,
    required this.onManageEvent,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;
  final VoidCallback onViewEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final dashboardState = HostHomeTodayDashboardState.fromAsync(eventsAsync);

    return HostTodayDashboardSection(
      club: club,
      currentUid: currentUid,
      clubs: clubs,
      showClubPicker: showClubPicker,
      state: dashboardState,
      onSwitchClubIndex: onSwitchClubIndex,
      onRetryEvents: () => ref.invalidate(watchEventsForClubProvider(club.id)),
      onViewEvents: onViewEvents,
      onCreateEvent: onCreateEvent,
      onManageEvent: onManageEvent,
    );
  }
}

class HostTodayDashboardSection extends StatelessWidget {
  const HostTodayDashboardSection({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.state,
    required this.onSwitchClubIndex,
    required this.onViewEvents,
    required this.onCreateEvent,
    required this.onManageEvent,
    this.onRetryEvents,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final HostHomeTodayDashboardState state;
  final ValueChanged<int> onSwitchClubIndex;
  final VoidCallback onViewEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;
  final VoidCallback? onRetryEvents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostTodayHeader(
          club: club,
          currentUid: currentUid,
          clubs: clubs,
          showClubPicker: showClubPicker,
          onSwitchClubIndex: onSwitchClubIndex,
        ),
        gapH18,
        switch (state.status) {
          HostHomeTodayStatus.loading => const _HostTodayLoadingBody(),
          HostHomeTodayStatus.error => CatchInlineErrorState.fromError(
            state.error!,
            context: AppErrorContext.event,
            onRetry: onRetryEvents,
          ),
          HostHomeTodayStatus.empty => _HostTodayEmptyEvents(
            club: club,
            onCreateEvent: onCreateEvent,
            onViewEvents: onViewEvents,
          ),
          HostHomeTodayStatus.content => _HostTodayContent(
            club: club,
            event: state.event!,
            tasks: state.tasks,
            onManageEvent: onManageEvent,
          ),
        },
      ],
    );
  }
}

class _HostTodayHeader extends StatelessWidget {
  const _HostTodayHeader({
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.onSwitchClubIndex,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hostName = _hostFirstName(club, currentUid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TUESDAY EVENING',
                style: CatchTextStyles.kicker(context, color: t.ink3),
              ),
              gapH8,
              Text(
                'Good evening,\n$hostName',
                style: CatchTextStyles.headlineS(context, color: t.ink),
              ),
            ],
          ),
        ),
        gapW12,
        _HostTodayClubPill(
          club: club,
          currentUid: currentUid,
          clubs: clubs,
          showClubPicker: showClubPicker,
          onSwitchClubIndex: onSwitchClubIndex,
        ),
      ],
    );
  }
}

class _HostTodayClubPill extends StatelessWidget {
  const _HostTodayClubPill({
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.onSwitchClubIndex,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final initials = _initialsFor(club.name);

    return CatchSurface(
      borderColor: t.line2,
      backgroundColor: t.surface,
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.micro6,
        CatchSpacing.micro6,
        CatchSpacing.s3,
        CatchSpacing.micro6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: CatchSpacing.s3,
            backgroundColor: ActivityPalette.resolve(
              context,
              club.hostDefaults.primaryActivityKind,
            ).deep,
            child: Text(
              initials,
              style: CatchTextStyles.badge(context, color: t.darkPillInk),
            ),
          ),
          gapW8,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 104),
            child: Text(
              club.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
          if (showClubPicker) ...[
            gapW4,
            CatchTopBarMenuAction<int>(
              tooltip: 'Switch club',
              icon: CatchIcons.expandMoreRounded,
              items: [
                for (var index = 0; index < clubs.length; index++)
                  CatchActionMenuItem(
                    value: index,
                    label:
                        '${clubs[index].name} · '
                        '${clubs[index].isOwnedBy(currentUid) ? 'Owner' : 'Host team'}',
                  ),
              ],
              onSelected: onSwitchClubIndex,
            ),
          ],
        ],
      ),
    );
  }
}

class _HostTodayLoadingBody extends StatelessWidget {
  const _HostTodayLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        HostSummarySkeleton(),
        gapH14,
        HostEventRowsSkeleton(count: 3),
      ],
    );
  }
}

class _HostTodayEmptyEvents extends StatelessWidget {
  const _HostTodayEmptyEvents({
    required this.club,
    required this.onCreateEvent,
    required this.onViewEvents,
  });

  final Club club;
  final HostHomeCreateEventCallback onCreateEvent;
  final VoidCallback onViewEvents;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No active events yet',
            style: CatchTextStyles.sectionTitle(context, color: t.ink),
          ),
          gapH8,
          Text(
            'Create an event for ${club.name} to start filling the host dashboard.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH18,
          Row(
            children: [
              Expanded(
                child: CatchButton(
                  label: 'New event',
                  icon: Icon(CatchIcons.addRounded, size: CatchIcon.sm),
                  onPressed: () => onCreateEvent(club),
                ),
              ),
              gapW12,
              CatchButton(
                label: 'Events',
                variant: CatchButtonVariant.secondary,
                size: CatchButtonSize.sm,
                onPressed: onViewEvents,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HostTodayContent extends StatelessWidget {
  const _HostTodayContent({
    required this.club,
    required this.event,
    required this.tasks,
    required this.onManageEvent,
  });

  final Club club;
  final Event event;
  final List<HostHomeTodayTaskData> tasks;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostTodayEventHero(
          event: event,
          onPressed: () => onManageEvent(club, event),
        ),
        gapH24,
        _HostSectionLabel(label: 'NEEDS YOU · ${tasks.length}'),
        gapH12,
        for (final task in tasks) ...[
          _HostTodayTaskCard(task: task, onPrimary: () {}),
          gapH12,
        ],
      ],
    );
  }
}

class _HostTodayEventHero extends StatelessWidget {
  const _HostTodayEventHero({required this.event, required this.onPressed});

  final Event event;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, event.activityKind);
    const heroStart = Color(0xFF303663);
    const heroEnd = Color(0xFF16140F);

    return CatchSurface(
      borderRadius: BorderRadius.circular(CatchRadius.lg),
      clipBehavior: Clip.antiAlias,
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [heroStart, heroEnd],
      ),
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HostTodayCountdownPill(event: event),
          gapH16,
          Text(
            _todayEventHeroTitle(event),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.headlineS(
              context,
              color: CatchTokens.editorialLight,
            ),
          ),
          gapH14,
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_eventDayLabel(event)} · ${EventFormatters.time(event.startTime)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.editorialLight.withValues(
                      alpha: CatchOpacity.onDarkMuted,
                    ),
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: Text(
                  event.locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.editorialLight.withValues(
                      alpha: CatchOpacity.onDarkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          gapH16,
          Divider(
            height: CatchStroke.hairline,
            color: CatchTokens.editorialLight.withValues(alpha: 0.18),
          ),
          gapH14,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _HostTodayHeroMetric(
                value: '${event.signedUpCount}',
                label: 'Going',
              ),
              gapW20,
              _HostTodayHeroMetric(
                value: '${event.waitlistCount}',
                label: 'Waiting',
              ),
              gapW20,
              _HostTodayHeroMetric(
                value: '${_reviewCount(event)}',
                label: 'To review',
                valueColor: activity.accent,
              ),
              const Spacer(),
              const _HostTodayAvatarStack(),
            ],
          ),
          gapH20,
          CatchButton(
            label: 'Set up & run',
            fullWidth: true,
            backgroundColor: activity.accent,
            foregroundColor: CatchTokens.editorialLight,
            borderColor: Colors.transparent,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _HostTodayCountdownPill extends StatelessWidget {
  const _HostTodayCountdownPill({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: CatchTokens.editorialLight.withValues(alpha: 0.16),
      borderWidth: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.micro6,
      ),
      child: Text(
        'STARTS ${_eventStartLeadLabel(event)}',
        style: CatchTextStyles.monoLabel(
          context,
          color: CatchTokens.editorialLight,
        ),
      ),
    );
  }
}

class _HostTodayHeroMetric extends StatelessWidget {
  const _HostTodayHeroMetric({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: CatchTextStyles.titleL(
            context,
            color: valueColor ?? CatchTokens.editorialLight,
          ),
        ),
        gapH2,
        Text(
          label,
          style: CatchTextStyles.monoLabel(
            context,
            color: CatchTokens.editorialLight.withValues(
              alpha: CatchOpacity.onDarkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _HostTodayAvatarStack extends StatelessWidget {
  const _HostTodayAvatarStack();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: CatchSpacing.s16,
      height: CatchSpacing.s7,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          const _HostTodayAvatarDot(
            left: CatchSpacing.s0,
            fill: Color(0xFF2E271F),
            label: '',
          ),
          _HostTodayAvatarDot(
            left: CatchSpacing.s5,
            fill: t.surface,
            label: 'D',
          ),
          const _HostTodayAvatarDot(
            left: CatchSpacing.s10,
            fill: Color(0xFFD8E7D2),
            label: 'M',
          ),
        ],
      ),
    );
  }
}

class _HostTodayAvatarDot extends StatelessWidget {
  const _HostTodayAvatarDot({
    required this.left,
    required this.fill,
    required this.label,
  });

  final double left;
  final Color fill;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: CatchSpacing.s3,
        backgroundColor: CatchTokens.editorialDark.withValues(alpha: 0.28),
        child: CircleAvatar(
          radius: CatchSpacing.micro10,
          backgroundColor: fill,
          child: label.isEmpty
              ? null
              : Text(
                  label,
                  style: CatchTextStyles.badge(context, color: t.ink2),
                ),
        ),
      ),
    );
  }
}

class _HostTodayTaskCard extends StatelessWidget {
  const _HostTodayTaskCard({required this.task, required this.onPrimary});

  final HostHomeTodayTaskData task;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      backgroundColor: t.surface,
      padding: CatchInsets.content,
      child: Row(
        children: [
          Container(
            width: CatchSpacing.s9,
            height: CatchSpacing.s9,
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(CatchRadius.sm),
            ),
            child: Icon(task.icon, color: t.ink2, size: CatchIcon.md),
          ),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleS(context, color: t.ink),
                ),
                gapH4,
                Text(
                  task.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW12,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchButton(
                label: task.primaryActionLabel.toUpperCase(),
                size: CatchButtonSize.sm,
                accentColor: t.danger,
                onPressed: onPrimary,
              ),
              gapW8,
              CatchButton(
                label: task.secondaryActionLabel.toUpperCase(),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _hostFirstName(Club club, String currentUid) {
  final hostProfile = club.hostProfiles
      .where((profile) => profile.uid == currentUid)
      .firstOrNull;
  final fallbackName = hostProfile?.displayName.trim().isNotEmpty == true
      ? hostProfile!.displayName
      : club.hostName ?? '';
  final parts = fallbackName.trim().split(RegExp(r'\s+'));
  return parts.firstWhere((part) => part.isNotEmpty, orElse: () => 'Host');
}

String _initialsFor(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  final initials = parts
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part.characters.first.toUpperCase())
      .join();
  return initials.isEmpty ? 'CH' : initials;
}

String _eventDayLabel(Event event) {
  if (event.startTime.hour >= 17) return 'Tonight';
  return EventFormatters.longWeekday(event.startTime);
}

String _todayEventHeroTitle(Event event) {
  final weekday = EventFormatters.longWeekday(event.startTime);
  final period = event.startTime.hour < 12
      ? 'Morning'
      : event.startTime.hour < 17
      ? 'Afternoon'
      : 'Evening';
  final prefix = '$weekday $period ';
  if (event.title.startsWith(prefix)) {
    return '$weekday ${event.title.substring(prefix.length)}';
  }
  return event.title;
}

String _eventStartLeadLabel(Event event) {
  final weekday = EventFormatters.longWeekday(event.startTime).toUpperCase();
  final time = EventFormatters.time(event.startTime).toUpperCase();
  return '$weekday · $time';
}

int _reviewCount(Event event) {
  if (event.waitlistCount > 0) {
    return event.waitlistCount > 4 ? 4 : event.waitlistCount;
  }
  final pendingCount = event.signedUpCount - event.attendedCount;
  if (pendingCount <= 0) return 0;
  return pendingCount > 4 ? 4 : pendingCount;
}

class HostEventsClubCard extends ConsumerWidget {
  const HostEventsClubCard({
    super.key,
    required this.club,
    required this.currentUid,
    required this.onCreateEvent,
    required this.onManageEvent,
  });

  final Club club;
  final String currentUid;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final eventsState = HostHomeEventsSectionState.fromAsync(eventsAsync);
    final owner = club.isOwnedBy(currentUid);

    return HostEventsClubSection(
      club: club,
      roleLabel: owner ? 'Owner' : 'Host team',
      owner: owner,
      eventsState: eventsState,
      onRetryEvents: () => ref.invalidate(watchEventsForClubProvider(club.id)),
      onCreateEvent: onCreateEvent,
      onManageEvent: onManageEvent,
    );
  }
}

class HostEventsClubSection extends StatelessWidget {
  const HostEventsClubSection({
    super.key,
    required this.club,
    required this.roleLabel,
    required this.owner,
    required this.eventsState,
    required this.onCreateEvent,
    required this.onManageEvent,
    this.onRetryEvents,
  });

  final Club club;
  final String roleLabel;
  final bool owner;
  final HostHomeEventsSectionState eventsState;
  final VoidCallback? onRetryEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostMetaRow(club: club, roleLabel: roleLabel, owner: owner),
        gapH24,
        const _HostSectionLabel(label: 'Upcoming'),
        gapH8,
        switch (eventsState.status) {
          HostHomeEventsStatus.loading => const HostEventRowsSkeleton(),
          HostHomeEventsStatus.error => CatchInlineErrorState.fromError(
            eventsState.error!,
            context: AppErrorContext.event,
            onRetry: onRetryEvents,
          ),
          HostHomeEventsStatus.empty => _HostEventRows(
            club: club,
            rows: eventsState.rows,
            emptyTextColor: t.ink2,
            onCreateEvent: onCreateEvent,
            onManageEvent: onManageEvent,
          ),
          HostHomeEventsStatus.populated => _HostEventRows(
            club: club,
            rows: eventsState.rows,
            emptyTextColor: t.ink2,
            onCreateEvent: onCreateEvent,
            onManageEvent: onManageEvent,
          ),
        },
      ],
    );
  }
}

class _HostEventRows extends StatelessWidget {
  const _HostEventRows({
    required this.club,
    required this.rows,
    required this.emptyTextColor,
    required this.onCreateEvent,
    required this.onManageEvent,
  });

  final Club club;
  final HostHomeEventRowsState rows;
  final Color emptyTextColor;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows.rows)
          HostEventRow(row: row, onTap: () => onManageEvent(club, row.event)),
        CatchSettingsRow(
          label: 'Add event',
          icon: CatchIcons.addRounded,
          divider: !rows.isEmpty,
          onTap: () => onCreateEvent(club),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: CatchSpacing.s2),
            child: Text(
              'No active events yet.',
              style: CatchTextStyles.supporting(context, color: emptyTextColor),
            ),
          ),
      ],
    );
  }
}

class HostMetaRow extends StatelessWidget {
  const HostMetaRow({
    super.key,
    required this.club,
    required this.roleLabel,
    required this.owner,
  });

  final Club club;
  final String roleLabel;
  final bool owner;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final area = [
      if (club.area.trim().isNotEmpty) club.area.trim(),
      if (club.location.trim().isNotEmpty) club.location.trim(),
    ].join(' · ');

    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (area.isNotEmpty)
          Text(
            area.toUpperCase(),
            style: CatchTextStyles.monoLabel(context, color: t.ink3),
          ),
        CatchBadge(
          label: roleLabel,
          tone: owner ? CatchBadgeTone.solid : CatchBadgeTone.neutral,
          uppercase: true,
        ),
        CatchActivityChip(
          activityKind: club.hostDefaults.primaryActivityKind,
          primary: true,
        ),
      ],
    );
  }
}

class _HostClubOrganizerOverview extends ConsumerWidget {
  const _HostClubOrganizerOverview({
    required this.club,
    required this.currentUid,
    required this.isOwner,
    required this.clubs,
    required this.showClubPicker,
    required this.onSelectClubIndex,
    required this.onSelectTab,
    required this.onPreviewClub,
    required this.onOpenSettings,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSelectClubIndex;
  final ValueChanged<HostClubTab> onSelectTab;
  final HostClubPreviewCallback onPreviewClub;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final events = eventsAsync.asData?.value ?? const <Event>[];
    final activeEvents = events.where((event) => !event.isCancelled).toList();

    return Column(
      key: const ValueKey('host-club-organizer-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostOrganizerHeader(
          club: club,
          trailing: showClubPicker
              ? CatchTopBarMenuAction<int>(
                  tooltip: 'Switch club',
                  icon: CatchIcons.expandMoreRounded,
                  items: [
                    for (var index = 0; index < clubs.length; index++)
                      CatchActionMenuItem(
                        value: index,
                        label:
                            '${clubs[index].name} · '
                            '${clubs[index].isOwnedBy(currentUid) ? 'Owner' : 'Host team'}',
                      ),
                  ],
                  onSelected: onSelectClubIndex,
                )
              : null,
        ),
        if (isOwner) ...[
          gapH14,
          _HostOrganizerPayoutPrompt(
            uid: currentUid,
            onManagePayouts: () => onSelectTab(HostClubTab.edit),
          ),
        ],
        gapH16,
        _HostOrganizerMetricGrid(
          club: club,
          eventsLoaded: eventsAsync.hasValue,
          eventCount: events.length,
          activeEventCount: activeEvents.length,
        ),
        gapH12,
        CatchSurface(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
          borderColor: CatchTokens.of(context).line,
          child: CatchInfoRow(
            icon: CatchIcons.visibilityOutlined,
            label: 'How guests see you',
            value: 'Public page',
            trailing: CatchInfoRowTrailing.chevron,
            onTap: () => onPreviewClub(club),
          ),
        ),
        gapH24,
        _HostOrganizerSectionHeader(
          label: 'Team · ${club.displayHostProfiles.length}',
          actionLabel: isOwner ? 'Manage' : null,
          onAction: isOwner ? () => onSelectTab(HostClubTab.edit) : null,
        ),
        gapH10,
        _HostOrganizerTeamCard(
          profiles: club.displayHostProfiles,
          currentUid: currentUid,
        ),
        gapH24,
        _HostOrganizerSectionHeader(
          label: 'Trends · last 12 weeks',
          actionLabel: 'See insights',
          onAction: () => onSelectTab(HostClubTab.insights),
        ),
        gapH10,
        _HostOrganizerTrendStrip(
          memberCount: club.memberCount,
          activeEventCount: activeEvents.length,
          onTap: () => onSelectTab(HostClubTab.insights),
        ),
        gapH24,
        const _HostOrganizerSectionHeader(label: 'Manage'),
        gapH10,
        CatchSurface(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
          borderColor: CatchTokens.of(context).line,
          child: Column(
            children: [
              CatchInfoRow(
                icon: CatchIcons.paymentsOutlined,
                label: 'Payouts',
                value: isOwner ? 'Manage' : 'Owner only',
                trailing: isOwner
                    ? CatchInfoRowTrailing.chevron
                    : CatchInfoRowTrailing.none,
                onTap: isOwner ? () => onSelectTab(HostClubTab.edit) : null,
              ),
              CatchInfoRow(
                icon: CatchIcons.tuneRounded,
                label: 'Event defaults',
                value: 'Prefill new events',
                trailing: isOwner
                    ? CatchInfoRowTrailing.chevron
                    : CatchInfoRowTrailing.none,
                divider: true,
                onTap: isOwner ? () => onSelectTab(HostClubTab.edit) : null,
              ),
              CatchInfoRow(
                icon: CatchIcons.settingsOutlined,
                label: 'Settings',
                trailing: CatchInfoRowTrailing.chevron,
                divider: true,
                onTap: onOpenSettings,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HostOrganizerHeader extends StatelessWidget {
  const _HostOrganizerHeader({required this.club, this.trailing});

  final Club club;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final formats = _organizerFormats(club);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CatchPersonAvatar(
              size: 64,
              name: club.name,
              initials: _initialsForName(club.name),
              imageUrl: club.logoPhotoUrl,
              shape: CatchPersonAvatarShape.square,
            ),
            gapW14,
            Expanded(
              child: Text(
                _organizerMeta(club),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.monoLabel(context, color: t.ink3),
              ),
            ),
            if (trailing != null) ...[gapW12, trailing!],
          ],
        ),
        if (formats.isNotEmpty) ...[
          gapH14,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final format in formats)
                CatchBadge(label: format, uppercase: true),
            ],
          ),
        ],
      ],
    );
  }
}

class _HostOrganizerPayoutPrompt extends ConsumerWidget {
  const _HostOrganizerPayoutPrompt({
    required this.uid,
    required this.onManagePayouts,
  });

  final String uid;
  final VoidCallback onManagePayouts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(watchHostPaymentAccountProvider(uid));
    final account = accountAsync.asData?.value;
    if (account?.canAcceptInternationalPayments == true) {
      return const SizedBox.shrink();
    }

    final loading = accountAsync.isLoading && !accountAsync.hasValue;
    final error = accountAsync.hasError;
    final title = loading
        ? 'Checking payout status'
        : error
        ? 'Payout status needs attention'
        : 'Connect payouts to get paid';
    final message = loading
        ? 'We are checking whether this organizer can collect paid bookings.'
        : error
        ? 'Open payouts to retry status checks and continue setup.'
        : "Paid events can't collect until Stripe is set up.";

    final t = CatchTokens.of(context);
    final warningFill = Color.alphaBlend(
      t.warning.withValues(alpha: CatchOpacity.calloutFill),
      t.surface,
    );

    return CatchSurface(
      backgroundColor: warningFill,
      borderColor: Colors.transparent,
      radius: CatchRadius.md,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: CatchStroke.hairline),
            child: Icon(
              CatchIcons.warningAmberRounded,
              size: CatchIcon.md,
              color: t.warning,
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.labelL(context)),
                gapH2,
                Text(
                  message,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                if (!loading) ...[
                  gapH8,
                  SizedBox(
                    width: CatchLayout.hostPayoutSetupButtonWidth,
                    child: CatchButton(
                      label: 'Set up payouts',
                      size: CatchButtonSize.sm,
                      fullWidth: true,
                      onPressed: onManagePayouts,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostOrganizerMetricGrid extends StatelessWidget {
  const _HostOrganizerMetricGrid({
    required this.club,
    required this.eventsLoaded,
    required this.eventCount,
    required this.activeEventCount,
  });

  final Club club;
  final bool eventsLoaded;
  final int eventCount;
  final int activeEventCount;

  @override
  Widget build(BuildContext context) {
    final items = [
      _HostOrganizerMetricItem(
        value: _compactCount(club.memberCount),
        label: 'Members',
      ),
      _HostOrganizerMetricItem(
        value: _ratingValue(club),
        label: club.reviewCount > 0
            ? 'Rating · ${club.reviewCount} reviews'
            : 'Rating',
      ),
      _HostOrganizerMetricItem(
        value: eventsLoaded ? _compactCount(eventCount) : '-',
        label: 'Events hosted',
      ),
      _HostOrganizerMetricItem(
        value: eventsLoaded ? _compactCount(activeEventCount) : '-',
        label: 'Upcoming',
      ),
    ];

    return Column(
      children: [
        _HostOrganizerMetricRow(items: [items[0], items[1]]),
        gapH12,
        _HostOrganizerMetricRow(items: [items[2], items[3]]),
      ],
    );
  }
}

class _HostOrganizerMetricItem {
  const _HostOrganizerMetricItem({required this.value, required this.label});

  final String value;
  final String label;
}

class _HostOrganizerMetricRow extends StatelessWidget {
  const _HostOrganizerMetricRow({required this.items});

  final List<_HostOrganizerMetricItem> items;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: CatchLayout.hostOrganizerMetricRowHeight,
        child: Row(
          children: [
            Expanded(child: _HostOrganizerMetricTile(item: items[0])),
            ColoredBox(
              color: t.line,
              child: const SizedBox(width: CatchStroke.hairline),
            ),
            Expanded(child: _HostOrganizerMetricTile(item: items[1])),
          ],
        ),
      ),
    );
  }
}

class _HostOrganizerMetricTile extends StatelessWidget {
  const _HostOrganizerMetricTile({required this.item});

  final _HostOrganizerMetricItem item;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.numericLarge(context, color: t.ink),
          ),
          gapH4,
          Text(
            item.label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.monoLabelS(context, color: t.ink3),
          ),
        ],
      ),
    );
  }
}

class _HostOrganizerSectionHeader extends StatelessWidget {
  const _HostOrganizerSectionHeader({
    required this.label,
    this.actionLabel,
    this.onAction,
  });

  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: CatchTextStyles.monoLabel(context, color: t.ink2),
          ),
        ),
        if (actionLabel != null)
          CatchTextButton(
            label: actionLabel!,
            onPressed: onAction,
            tone: CatchTextButtonTone.neutral,
            minimumSize: const Size(0, CatchSpacing.s8),
          ),
      ],
    );
  }
}

class _HostOrganizerTeamCard extends StatelessWidget {
  const _HostOrganizerTeamCard({
    required this.profiles,
    required this.currentUid,
  });

  final List<ClubHostProfile> profiles;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    if (profiles.isEmpty) {
      return Text(
        'No host team members yet.',
        style: CatchTextStyles.supporting(context, color: t.ink2),
      );
    }

    final visibleProfiles = profiles.take(3).toList(growable: false);
    return CatchSurface(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
      borderColor: t.line,
      child: Column(
        children: [
          for (var index = 0; index < visibleProfiles.length; index++)
            _HostOrganizerTeamRow(
              profile: visibleProfiles[index],
              currentUid: currentUid,
              divider: index > 0,
            ),
        ],
      ),
    );
  }
}

class _HostOrganizerTeamRow extends StatelessWidget {
  const _HostOrganizerTeamRow({
    required this.profile,
    required this.currentUid,
    required this.divider,
  });

  final ClubHostProfile profile;
  final String currentUid;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isCurrentUser = profile.uid == currentUid;
    final roleLabel = profile.role == ClubHostRole.owner ? 'Owner' : 'Host';
    return Stack(
      children: [
        if (divider)
          Positioned(
            top: 0,
            left: CatchLayout.hostOrganizerTeamDividerInset,
            right: 0,
            child: ColoredBox(
              color: t.line.withValues(alpha: CatchOpacity.infoRowDivider),
              child: const SizedBox(height: CatchStroke.hairline),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
          child: Row(
            children: [
              CatchPersonAvatar(
                size: CatchLayout.skeletonAvatarCompactExtent,
                name: profile.displayName,
                imageUrl: profile.avatarUrl,
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.titleS(context, color: t.ink),
                    ),
                    gapH2,
                    Text(
                      isCurrentUser ? 'You · $roleLabel' : roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              if (profile.role == ClubHostRole.owner)
                const CatchBadge(
                  label: 'Owner',
                  tone: CatchBadgeTone.solid,
                  uppercase: true,
                )
              else
                Icon(
                  CatchIcons.chevronRightRounded,
                  size: CatchIcon.control,
                  color: t.ink3,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HostOrganizerTrendStrip extends StatelessWidget {
  const _HostOrganizerTrendStrip({
    required this.memberCount,
    required this.activeEventCount,
    required this.onTap,
  });

  final int memberCount;
  final int activeEventCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bars = _trendBars(memberCount: memberCount, events: activeEventCount);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HostTrendKpi(
                value: _compactCount(memberCount),
                label: 'Members',
              ),
              gapW16,
              _HostTrendKpi(
                value: _compactCount(activeEventCount),
                label: 'Active events',
              ),
              const Spacer(),
              Icon(CatchIcons.chevronRightRounded, size: CatchIcon.control),
            ],
          ),
          gapH16,
          SizedBox(
            height: CatchLayout.hostOrganizerTrendChartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < bars.length; index++) ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: bars[index],
                        widthFactor: 0.62,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: t.primary,
                            borderRadius: BorderRadius.circular(
                              CatchRadius.pill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (index < bars.length - 1) gapW4,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostTrendKpi extends StatelessWidget {
  const _HostTrendKpi({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: CatchTextStyles.titleS(context, color: t.ink)),
        gapH2,
        Text(label, style: CatchTextStyles.monoLabelS(context, color: t.ink3)),
      ],
    );
  }
}

List<String> _organizerFormats(Club club) {
  final tags = club.tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .take(4)
      .toList(growable: false);
  if (tags.isNotEmpty) return tags;
  return [club.hostDefaults.primaryActivityKind.label];
}

String _organizerMeta(Club club) {
  final parts = [
    if (club.area.trim().isNotEmpty) club.area.trim(),
    if (club.location.trim().isNotEmpty) club.location.trim(),
    'Since ${club.createdAt.year}',
  ];
  return parts.join(' · ').toUpperCase();
}

String _initialsForName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return '?';
  return words.take(2).map((word) => word.characters.first).join();
}

String _compactCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '$count';
}

String _ratingValue(Club club) {
  if (club.reviewCount <= 0 || club.rating <= 0) return 'New';
  final rounded = club.rating.roundToDouble();
  return club.rating == rounded
      ? rounded.toStringAsFixed(0)
      : club.rating.toStringAsFixed(1);
}

List<double> _trendBars({required int memberCount, required int events}) {
  final seed = (memberCount + events * 17).clamp(0, 999).toInt();
  return [
    for (var index = 0; index < 10; index++)
      (0.34 + (((seed + index * 13) % 58) / 100)).clamp(0.24, 0.96).toDouble(),
  ];
}

class _HostClubProfileCard extends ConsumerStatefulWidget {
  const _HostClubProfileCard({
    required this.club,
    required this.currentUid,
    required this.isOwner,
    required this.onPreviewClub,
    this.initialExpandedField,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final HostClubPreviewCallback onPreviewClub;
  final String? initialExpandedField;

  @override
  ConsumerState<_HostClubProfileCard> createState() =>
      _HostClubProfileCardState();
}

class _HostClubProfileCardState extends ConsumerState<_HostClubProfileCard> {
  String? _expandedField;

  @override
  void initState() {
    super.initState();
    _expandedField = widget.initialExpandedField;
  }

  bool _isExpanded(String fieldName) => _expandedField == fieldName;

  void _toggleField(String fieldName) {
    setState(() {
      _expandedField = _expandedField == fieldName ? null : fieldName;
    });
  }

  void _collapseField() {
    if (_expandedField == null) return;
    setState(() => _expandedField = null);
  }

  @override
  void didUpdateWidget(covariant _HostClubProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _expandedField = widget.initialExpandedField;
    } else if (oldWidget.initialExpandedField != widget.initialExpandedField) {
      _expandedField = widget.initialExpandedField;
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final isOwner = widget.isOwner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostMetaRow(
          club: club,
          roleLabel: isOwner ? 'Owner' : 'Host team',
          owner: isOwner,
        ),
        gapH24,
        HostSettingsSection(
          label: 'Identity',
          first: true,
          children: [
            _textEntry(
              club: club,
              fieldName: 'name',
              label: 'Club name',
              value: club.name,
              currentValue: club.name,
              icon: CatchIcons.groups3Outlined,
              validator: _requiredHostFieldValidator('Club name'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(name: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'location',
              label: 'City',
              value: _valueOrDash(club.location),
              currentValue: club.location,
              icon: CatchIcons.locationCityOutlined,
              validator: _requiredHostFieldValidator('City'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) =>
                  UpdateClubPatch(location: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'area',
              label: 'Area / neighbourhood',
              value: _valueOrDash(club.area),
              currentValue: club.area,
              icon: CatchIcons.locationOnOutlined,
              validator: _requiredHostFieldValidator('Area / neighbourhood'),
              normalizeInput: _normalizeSingleLineInput,
              patchForValue: (value) => UpdateClubPatch(area: value as String),
            ),
            _textEntry(
              club: club,
              fieldName: 'description',
              label: 'Description',
              value: _valueOrDash(club.description),
              currentValue: club.description,
              icon: CatchIcons.descriptionOutlined,
              maxLines: 3,
              minLines: 2,
              maxLength: 280,
              showCounter: true,
              keyboardType: TextInputType.multiline,
              validator: _requiredHostFieldValidator('Description'),
              normalizeInput: _normalizeMultilineInput,
              patchForValue: (value) =>
                  UpdateClubPatch(description: value as String),
            ),
          ],
        ),
        HostSettingsSection(
          label: 'Contact',
          children: [
            _textEntry(
              club: club,
              fieldName: 'instagramHandle',
              label: 'Instagram',
              value: _valueOrDash(club.instagramHandle),
              placeholder: '@yourclub',
              currentValue: club.instagramHandle ?? '',
              currentFieldValue: club.instagramHandle,
              icon: CatchIcons.alternateEmailRounded,
              keyboardType: TextInputType.text,
              normalizeInput: _normalizeSingleLineInput,
              toFieldValue: _optionalStringFieldValue,
              patchForValue: (value) => UpdateClubPatch(instagramHandle: value),
            ),
            _textEntry(
              club: club,
              fieldName: 'phoneNumber',
              label: 'Phone',
              value: _valueOrDash(club.phoneNumber),
              placeholder: '98765 43210',
              currentValue: club.phoneNumber ?? '',
              currentFieldValue: club.phoneNumber,
              icon: CatchIcons.phoneOutlined,
              keyboardType: TextInputType.phone,
              normalizeInput: _normalizeSingleLineInput,
              toFieldValue: _optionalStringFieldValue,
              patchForValue: (value) => UpdateClubPatch(phoneNumber: value),
            ),
            _textEntry(
              club: club,
              fieldName: 'email',
              label: 'Email',
              value: _valueOrDash(club.email),
              placeholder: 'hello@yourclub.com',
              currentValue: club.email ?? '',
              currentFieldValue: club.email,
              icon: CatchIcons.emailOutlined,
              keyboardType: TextInputType.emailAddress,
              normalizeInput: _normalizeSingleLineInput,
              validator: _optionalEmailValidator,
              toFieldValue: _optionalStringFieldValue,
              patchForValue: (value) => UpdateClubPatch(email: value),
            ),
          ],
        ),
        HostSettingsSection(
          label: 'Event defaults',
          children: [
            _activityDefaultEntry(club),
            _admissionDefaultEntry(club),
            _ageRangeDefaultEntry(club),
            _cancellationDefaultEntry(club),
          ],
        ),
        HostSettingsSection(
          label: 'Public profile',
          children: [
            CatchSettingsRow(
              label: 'Preview club page',
              value: 'Preview',
              icon: CatchIcons.visibilityOutlined,
              onTap: () => widget.onPreviewClub(club),
            ),
          ],
        ),
        if (isOwner) ...[
          HostSettingsSection(
            label: 'Payouts',
            children: [HostPaymentAccountCard(club: club)],
          ),
          HostSettingsSection(
            label: 'Host team',
            children: [
              HostTeamManagementSection(
                club: club,
                currentUid: widget.currentUid,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _textEntry({
    required Club club,
    required String fieldName,
    required String label,
    required String value,
    required String currentValue,
    required IconData icon,
    required UpdateClubPatch Function(Object? value) patchForValue,
    Object? currentFieldValue,
    String? placeholder,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool showCounter = false,
    String Function(String value)? normalizeInput,
    FormFieldValidator<String>? validator,
    Object? Function(String value)? toFieldValue,
  }) {
    if (!widget.isOwner) {
      return CatchSettingsRow(label: label, value: value, icon: icon);
    }

    return _HostInlineTextEntryEditor(
      key: ValueKey('host-inline-$fieldName'),
      clubId: club.id,
      icon: icon,
      label: label,
      value: value,
      currentValue: currentValue,
      currentFieldValue: currentFieldValue ?? currentValue,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      placeholder: placeholder,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCounter: showCounter,
      normalizeInput: normalizeInput,
      validator: validator,
      toFieldValue: toFieldValue,
      patchForValue: patchForValue,
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _activityDefaultEntry(Club club) {
    const fieldName = 'primaryActivityKind';
    final selected = club.hostDefaults.primaryActivityKind;
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Default activity',
        value: selected.label,
        icon: CatchIcons.eventOutlined,
      );
    }

    return _HostInlineOptionEditor<ActivityKind>(
      key: const ValueKey('host-inline-primaryActivityKind'),
      clubId: club.id,
      icon: CatchIcons.eventOutlined,
      label: 'Default activity',
      value: selected.label,
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      options: [
        for (final activityKind in ActivityKind.eventCreationDefaults)
          _HostInlineOption(
            value: activityKind,
            label: activityKind.label,
            accentColor: ActivityPalette.resolve(context, activityKind).accent,
          ),
      ],
      patchForValue: (activityKind) => UpdateClubPatch(
        hostDefaults: _hostDefaultsWithActivity(
          club.hostDefaults,
          activityKind,
        ),
      ),
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _admissionDefaultEntry(Club club) {
    const fieldName = 'admissionPreset';
    final selected = club.hostDefaults.eventPolicy.admissionPreset;
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Admission',
        value: _admissionDefaultLabel(selected),
        icon: CatchIcons.eventSeatOutlined,
      );
    }

    return _HostInlineOptionEditor<EventAdmissionDefaultPreset>(
      key: const ValueKey('host-inline-admissionPreset'),
      clubId: club.id,
      icon: CatchIcons.eventSeatOutlined,
      label: 'Admission',
      value: _admissionDefaultLabel(selected),
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      helperText: _admissionDefaultDescription(selected),
      options: [
        for (final preset in EventAdmissionDefaultPreset.values)
          _HostInlineOption(
            value: preset,
            label: _admissionDefaultLabel(preset),
          ),
      ],
      patchForValue: (preset) {
        final policy = club.hostDefaults.eventPolicy;
        return UpdateClubPatch(
          hostDefaults: club.hostDefaults.copyWith(
            eventPolicy: policy.copyWith(
              admissionPreset: preset,
              dynamicPricingEnabled:
                  preset == EventAdmissionDefaultPreset.balancedSingles
                  ? policy.dynamicPricingEnabled
                  : false,
            ),
          ),
        );
      },
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _ageRangeDefaultEntry(Club club) {
    const fieldName = 'ageRange';
    final policy = club.hostDefaults.eventPolicy;
    final value = '${policy.minAge}–${policy.maxAge}';
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Age range',
        value: value,
        icon: CatchIcons.cakeOutlined,
      );
    }

    return _HostInlineAgeRangeEditor(
      key: const ValueKey('host-inline-ageRange'),
      clubId: club.id,
      icon: CatchIcons.cakeOutlined,
      label: 'Age range',
      value: value,
      fieldName: fieldName,
      hostDefaults: club.hostDefaults,
      isExpanded: _isExpanded(fieldName),
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }

  Widget _cancellationDefaultEntry(Club club) {
    const fieldName = 'cancellationPolicyId';
    final selected = club.hostDefaults.eventPolicy.cancellationPolicyId;
    final selectedPolicy = club.hostDefaults.eventPolicy.cancellationPolicy;
    if (!widget.isOwner) {
      return CatchSettingsRow(
        label: 'Cancellation policy',
        value: selectedPolicy.title,
        icon: CatchIcons.eventBusyOutlined,
      );
    }

    return _HostInlineOptionEditor<EventCancellationPolicyId>(
      key: const ValueKey('host-inline-cancellationPolicyId'),
      clubId: club.id,
      icon: CatchIcons.eventBusyOutlined,
      label: 'Cancellation policy',
      value: selectedPolicy.title,
      currentValue: selected,
      fieldName: fieldName,
      isExpanded: _isExpanded(fieldName),
      helperText: selectedPolicy.attendeeSummary,
      options: [
        for (final policyId in EventCancellationPolicyId.values)
          _HostInlineOption(
            value: policyId,
            label: _cancellationPolicyFor(policyId).title,
          ),
      ],
      patchForValue: (policyId) {
        final policy = club.hostDefaults.eventPolicy;
        return UpdateClubPatch(
          hostDefaults: club.hostDefaults.copyWith(
            eventPolicy: policy.copyWith(cancellationPolicyId: policyId),
          ),
        );
      },
      onTap: () => _toggleField(fieldName),
      onSaved: _collapseField,
      onCancel: _collapseField,
    );
  }
}

class _HostClubInsightsPane extends ConsumerStatefulWidget {
  const _HostClubInsightsPane({required this.club});

  final Club club;

  @override
  ConsumerState<_HostClubInsightsPane> createState() =>
      _HostClubInsightsPaneState();
}

class _HostClubInsightsPaneState extends ConsumerState<_HostClubInsightsPane> {
  late HostClubInsightsState _state;

  @override
  void initState() {
    super.initState();
    _state = HostClubInsightsState.initial(clubId: widget.club.id);
  }

  @override
  void didUpdateWidget(covariant _HostClubInsightsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = _state.selectClub(widget.club.id);
  }

  @override
  Widget build(BuildContext context) {
    final query = _state.query;
    final analyticsAsync = ref.watch(hostAnalyticsProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostMetaRow(club: widget.club, roleLabel: 'Insights', owner: true),
        gapH24,
        _HostAnalyticsControls(
          rangePreset: _state.rangePreset,
          granularity: _state.granularity,
          customStartDate: _state.customStartDate,
          customEndDate: _state.customEndDate,
          selectedEventId: _state.selectedEventId,
          onRangeChanged: (preset) =>
              setState(() => _state = _state.selectRange(preset)),
          onGranularityChanged: (granularity) =>
              setState(() => _state = _state.selectGranularity(granularity)),
          onPickStartDate: _pickCustomStartDate,
          onPickEndDate: _pickCustomEndDate,
          onClearEvent: _clearEventScope,
        ),
        gapH20,
        CatchAsyncValueView<HostAnalyticsReport>(
          value: analyticsAsync,
          loadingBuilder: (_) => const HostAnalyticsReportSkeleton(),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            onRetry: () => ref.invalidate(hostAnalyticsProvider(query)),
          ),
          builder: (context, report) => _HostAnalyticsReportView(
            report: report,
            selectedEventId: _state.selectedEventId,
            onEventSelected: _selectEventScope,
            onClearEvent: _clearEventScope,
          ),
        ),
      ],
    );
  }

  Future<void> _pickCustomStartDate() async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _state.customStartDate,
      firstDate: _analyticsDateDaysAgo(366),
      lastDate: _state.customEndDate,
      title: 'Start date',
    );
    if (picked == null || !mounted) return;
    setState(() => _state = _state.selectCustomStartDate(picked));
  }

  Future<void> _pickCustomEndDate() async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _state.customEndDate,
      firstDate: _state.customStartDate,
      lastDate: DateUtils.dateOnly(DateTime.now()),
      title: 'End date',
    );
    if (picked == null || !mounted) return;
    setState(() => _state = _state.selectCustomEndDate(picked));
  }

  void _selectEventScope(String eventId) {
    setState(() => _state = _state.selectEvent(eventId));
  }

  void _clearEventScope() {
    setState(() => _state = _state.clearEvent());
  }
}

class _HostAnalyticsControls extends StatelessWidget {
  const _HostAnalyticsControls({
    required this.rangePreset,
    required this.granularity,
    required this.customStartDate,
    required this.customEndDate,
    required this.selectedEventId,
    required this.onRangeChanged,
    required this.onGranularityChanged,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onClearEvent,
  });

  final HostAnalyticsRangePreset rangePreset;
  final HostAnalyticsGranularity granularity;
  final DateTime customStartDate;
  final DateTime customEndDate;
  final String? selectedEventId;
  final ValueChanged<HostAnalyticsRangePreset> onRangeChanged;
  final ValueChanged<HostAnalyticsGranularity> onGranularityChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchOptionGroup<HostAnalyticsRangePreset>(
          selected: rangePreset,
          onChanged: onRangeChanged,
          variant: CatchOptionGroupVariant.mono,
          options: const [
            CatchOption(value: HostAnalyticsRangePreset.sevenDays, label: '7D'),
            CatchOption(
              value: HostAnalyticsRangePreset.thirtyDays,
              label: '30D',
            ),
            CatchOption(
              value: HostAnalyticsRangePreset.ninetyDays,
              label: '90D',
            ),
            CatchOption(value: HostAnalyticsRangePreset.month, label: 'MONTH'),
            CatchOption(
              value: HostAnalyticsRangePreset.custom,
              label: 'CUSTOM',
            ),
          ],
        ),
        gapH12,
        CatchOptionGroup<HostAnalyticsGranularity>(
          selected: granularity,
          onChanged: onGranularityChanged,
          variant: CatchOptionGroupVariant.mono,
          options: const [
            CatchOption(value: HostAnalyticsGranularity.day, label: 'DAY'),
            CatchOption(value: HostAnalyticsGranularity.week, label: 'WEEK'),
            CatchOption(value: HostAnalyticsGranularity.month, label: 'MONTH'),
          ],
        ),
        if (rangePreset == HostAnalyticsRangePreset.custom) ...[
          gapH12,
          Row(
            children: [
              Expanded(
                child: _HostAnalyticsDateButton(
                  label: 'Start',
                  value: _formatAnalyticsDate(customStartDate),
                  onTap: onPickStartDate,
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: _HostAnalyticsDateButton(
                  label: 'End',
                  value: _formatAnalyticsDate(customEndDate),
                  onTap: onPickEndDate,
                ),
              ),
            ],
          ),
        ],
        if (selectedEventId != null) ...[
          gapH12,
          CatchSurface(
            padding: CatchInsets.contentDense,
            borderColor: t.line,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Event scoped',
                    style: CatchTextStyles.labelM(context, color: t.ink2),
                  ),
                ),
                CatchButton(
                  label: 'All events',
                  onPressed: onClearEvent,
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.sm,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HostAnalyticsDateButton extends StatelessWidget {
  const _HostAnalyticsDateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.contentDense,
      borderColor: t.line,
      onTap: onTap,
      child: Row(
        children: [
          Icon(CatchIcons.calendarTodayOutlined, size: CatchIcon.sm),
          const SizedBox(width: CatchSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CatchTextStyles.labelS(context, color: t.ink3),
                ),
                gapH2,
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.monoLabel(context, color: t.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostAnalyticsReportView extends StatelessWidget {
  const _HostAnalyticsReportView({
    required this.report,
    required this.selectedEventId,
    required this.onEventSelected,
    required this.onClearEvent,
  });

  final HostAnalyticsReport report;
  final String? selectedEventId;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostAnalyticsMetricGrid(metrics: report.summaryCards),
        gapH24,
        _HostAnalyticsTrendPanel(points: report.trend),
        gapH24,
        _HostAnalyticsEventList(
          events: report.topEvents,
          selectedEventId: selectedEventId,
          onEventSelected: onEventSelected,
          onClearEvent: onClearEvent,
        ),
        gapH24,
        _HostAnalyticsReviewDiscoveryPanel(report: report),
        gapH24,
        _HostAnalyticsDataQualityPanel(rows: report.dataQuality),
      ],
    );
  }
}

class _HostAnalyticsMetricGrid extends StatelessWidget {
  const _HostAnalyticsMetricGrid({required this.metrics});

  final List<HostAnalyticsMetricCard> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - CatchSpacing.s3) / 2;
        return Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: _HostAnalyticsMetricTile(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _HostAnalyticsMetricTile extends StatelessWidget {
  const _HostAnalyticsMetricTile({required this.metric});

  final HostAnalyticsMetricCard metric;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final muted = metric.status == HostAnalyticsMetricStatus.missing;
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.mutedBorderUrgent)
          : t.line,
      backgroundColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.warningFill)
          : t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_metricIcon(metric.id), size: CatchIcon.sm, color: t.ink2),
              const Spacer(),
              if (metric.status != HostAnalyticsMetricStatus.ready)
                CatchBadge(
                  label: metric.status == HostAnalyticsMetricStatus.partial
                      ? 'Partial'
                      : 'Missing',
                  tone: metric.status == HostAnalyticsMetricStatus.partial
                      ? CatchBadgeTone.warning
                      : CatchBadgeTone.neutral,
                ),
            ],
          ),
          gapH12,
          Text(
            _formatMetricValue(metric),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.numericLarge(
              context,
              color: muted ? t.ink3 : t.ink,
            ),
          ),
          gapH4,
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelM(context, color: t.ink2),
          ),
          if (metric.caption case final caption?
              when caption.trim().isNotEmpty) ...[
            gapH8,
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class _HostAnalyticsTrendPanel extends StatelessWidget {
  const _HostAnalyticsTrendPanel({required this.points});

  final List<HostAnalyticsTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final totalBookings = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['bookings'] ?? 0),
    );
    final totalDemand = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['demand'] ?? 0),
    );
    final maxBookings = points.fold<num>(0, (max, point) {
      final value = point.metrics['bookings'] ?? 0;
      return value > max ? value : max;
    });

    return _HostAnalyticsSection(
      label: 'Funnel',
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Demand',
                    value: _formatCount(totalDemand),
                  ),
                ),
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Bookings',
                    value: _formatCount(totalBookings),
                  ),
                ),
              ],
            ),
            gapH16,
            SizedBox(
              height: CatchSpacing.s16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points.take(18)) ...[
                    if (point != points.first)
                      const SizedBox(width: CatchSpacing.micro6),
                    Expanded(
                      child: _HostAnalyticsBar(
                        value: point.metrics['bookings'] ?? 0,
                        maxValue: maxBookings,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostAnalyticsBar extends StatelessWidget {
  const _HostAnalyticsBar({required this.value, required this.maxValue});

  final num value;
  final num maxValue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final ratio = maxValue <= 0 ? 0.02 : (value / maxValue).clamp(0.06, 1);
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: ratio.toDouble(),
        child: CatchSurface(
          radius: CatchRadius.xs,
          borderWidth: 0,
          backgroundColor: value <= 0 ? t.line2 : t.ink,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _HostAnalyticsEventList extends StatelessWidget {
  const _HostAnalyticsEventList({
    required this.events,
    required this.selectedEventId,
    required this.onEventSelected,
    required this.onClearEvent,
  });

  final List<HostAnalyticsEventRow> events;
  final String? selectedEventId;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    return _HostAnalyticsSection(
      label: selectedEventId == null ? 'Top events' : 'Selected event',
      child: Column(
        children: [
          if (selectedEventId != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: CatchButton(
                label: 'All events',
                onPressed: onClearEvent,
                variant: CatchButtonVariant.ghost,
                size: CatchButtonSize.sm,
              ),
            ),
            gapH8,
          ],
          if (events.isEmpty)
            CatchSurface(
              padding: CatchInsets.content,
              borderColor: CatchTokens.of(context).line,
              child: Text(
                'No events in this range.',
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
            )
          else
            for (final event in events.take(5))
              _HostAnalyticsEventTile(
                event: event,
                divider: event != events.first,
                selected: event.eventId == selectedEventId,
                onTap: () => onEventSelected(event.eventId),
              ),
        ],
      ),
    );
  }
}

class _HostAnalyticsEventTile extends StatelessWidget {
  const _HostAnalyticsEventTile({
    required this.event,
    required this.divider,
    required this.selected,
    required this.onTap,
  });

  final HostAnalyticsEventRow event;
  final bool divider;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      children: [
        if (divider) Divider(height: 1, color: t.line),
        CatchSurface(
          tone: CatchSurfaceTone.transparent,
          borderWidth: 0,
          padding: CatchInsets.contentVertical,
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CatchIcons.eventOutlined, color: t.ink2),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.labelL(
                              context,
                              color: t.ink,
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: CatchSpacing.s2),
                          const CatchBadge(label: 'Selected'),
                        ],
                      ],
                    ),
                    gapH4,
                    Text(
                      EventFormatters.shortDate(event.startTime),
                      style: CatchTextStyles.bodyS(context, color: t.ink3),
                    ),
                    gapH8,
                    Wrap(
                      spacing: CatchSpacing.s2,
                      runSpacing: CatchSpacing.s2,
                      children: [
                        CatchBadge(
                          label: _analyticsEventStatusLabel(event.status),
                          tone: _analyticsEventStatusTone(event.status),
                        ),
                        CatchBadge(label: '${event.demandCount} demand'),
                        CatchBadge(label: '${event.bookedCount} booked'),
                        if (event.waitlistedCount > 0)
                          CatchBadge(
                            label: '${event.waitlistedCount} waitlisted',
                            tone: CatchBadgeTone.warning,
                          ),
                        CatchBadge(
                          label: '${event.checkedInCount} attended',
                          tone: CatchBadgeTone.success,
                        ),
                        if (event.mutualMatchCount > 0)
                          CatchBadge(
                            label: '${event.mutualMatchCount} matches',
                            tone: CatchBadgeTone.brand,
                          ),
                        if (event.chatStartedCount > 0)
                          CatchBadge(label: '${event.chatStartedCount} chats'),
                        if (event.repeatAttendeeCount > 0)
                          CatchBadge(
                            label: '${event.repeatAttendeeCount} repeat',
                          ),
                        if (event.checkoutStartedCount > 0)
                          CatchBadge(
                            label: '${event.checkoutStartedCount} checkouts',
                          ),
                        if (event.checkoutDropoffCount > 0)
                          CatchBadge(
                            label: '${event.checkoutDropoffCount} drop-off',
                            tone: CatchBadgeTone.warning,
                          ),
                        if (event.paymentFailedCount > 0)
                          CatchBadge(
                            label: '${event.paymentFailedCount} failed',
                            tone: CatchBadgeTone.danger,
                          ),
                        if (event.paymentRefundedCount > 0)
                          CatchBadge(
                            label: '${event.paymentRefundedCount} refunded',
                            tone: CatchBadgeTone.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Text(
                EventFormatters.priceInPaise(
                  event.grossRevenueMinor,
                  currencyCode: event.currency,
                ),
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatAnalyticsDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

DateTime _analyticsDateDaysAgo(int days) {
  final today = DateUtils.dateOnly(DateTime.now());
  return DateTime(today.year, today.month, today.day - days);
}

class _HostAnalyticsReviewDiscoveryPanel extends StatelessWidget {
  const _HostAnalyticsReviewDiscoveryPanel({required this.report});

  final HostAnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    return _HostAnalyticsSection(
      label: 'Reviews and saves',
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'New reviews',
                    value: '${report.reviewSummary.newReviews}',
                  ),
                ),
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Average rating',
                    value: report.reviewSummary.averageRating <= 0
                        ? '—'
                        : report.reviewSummary.averageRating.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Event saves',
                    value: '${report.discoverySummary.eventSaves}',
                  ),
                ),
                Expanded(
                  child: _HostAnalyticsInlineStat(
                    label: 'Responses',
                    value: '${report.reviewSummary.ownerResponseCount}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HostAnalyticsDataQualityPanel extends StatelessWidget {
  const _HostAnalyticsDataQualityPanel({required this.rows});

  final List<HostAnalyticsDataQuality> rows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return _HostAnalyticsSection(
      label: 'Data quality',
      child: Column(
        children: [
          for (final indexedRow in rows.indexed) ...[
            if (indexedRow.$1 > 0) gapH8,
            CatchSurface(
              padding: CatchInsets.contentDense,
              borderColor: t.line,
              backgroundColor:
                  indexedRow.$2.state == HostAnalyticsDataQualityState.ok
                  ? t.surface
                  : t.warning.withValues(alpha: CatchOpacity.warningFill),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    indexedRow.$2.state == HostAnalyticsDataQualityState.ok
                        ? CatchIcons.checkCircleOutlineRounded
                        : CatchIcons.warningAmberRounded,
                    size: CatchIcon.md,
                    color:
                        indexedRow.$2.state == HostAnalyticsDataQualityState.ok
                        ? t.success
                        : t.warning,
                  ),
                  const SizedBox(width: CatchSpacing.s3),
                  Expanded(
                    child: Text(
                      indexedRow.$2.detail,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HostAnalyticsInlineStat extends StatelessWidget {
  const _HostAnalyticsInlineStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: CatchTextStyles.numericMeta(context, color: t.ink)),
        gapH4,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.labelS(context, color: t.ink3),
        ),
      ],
    );
  }
}

class _HostAnalyticsSection extends StatelessWidget {
  const _HostAnalyticsSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HostSectionLabel(label: label),
        gapH8,
        child,
      ],
    );
  }
}

IconData _metricIcon(String metricId) {
  return switch (metricId) {
    'listingViews' || 'eventViews' => CatchIcons.visibilityOutlined,
    'bookings' => CatchIcons.confirmationNumberOutlined,
    'attendanceRate' => CatchIcons.factCheckOutlined,
    'revenue' => CatchIcons.accountBalanceWalletOutlined,
    'checkoutDropoff' ||
    'checkoutConversionRate' => CatchIcons.paymentsOutlined,
    'newReviews' => CatchIcons.rateReviewOutlined,
    'connections' => CatchIcons.favoriteOutlineRounded,
    'chats' => CatchIcons.chatBubbleOutlineRounded,
    _ => CatchIcons.insightsOutlined,
  };
}

String _formatMetricValue(HostAnalyticsMetricCard metric) {
  return switch (metric.unit) {
    HostAnalyticsMetricUnit.percent => '${metric.value.round()}%',
    HostAnalyticsMetricUnit.moneyMinor => EventFormatters.priceInPaise(
      metric.value.round(),
    ),
    HostAnalyticsMetricUnit.rating =>
      metric.value <= 0 ? '—' : metric.value.toStringAsFixed(1),
    HostAnalyticsMetricUnit.count => _formatCount(metric.value),
  };
}

String _analyticsEventStatusLabel(String status) {
  final normalized = status.trim();
  if (normalized.isEmpty || normalized == 'unknown') return 'Unknown';
  return normalized
      .split(RegExp(r'[_\-\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

CatchBadgeTone _analyticsEventStatusTone(String status) {
  return switch (status.trim().toLowerCase()) {
    'live' || 'active' || 'open' || 'published' => CatchBadgeTone.live,
    'completed' || 'past' => CatchBadgeTone.success,
    'draft' || 'pending' || 'scheduled' => CatchBadgeTone.warning,
    'cancelled' || 'canceled' => CatchBadgeTone.danger,
    _ => CatchBadgeTone.neutral,
  };
}

String _formatCount(num value) {
  final rounded = value.round();
  if (rounded >= 1000000) {
    return '${(rounded / 1000000).toStringAsFixed(1)}M';
  }
  if (rounded >= 1000) return '${(rounded / 1000).toStringAsFixed(1)}K';
  return '$rounded';
}

mixin _HostInlineClubSaveState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool get isSaving =>
      ref.read(HostClubEditController.updateClubMutation).isPending;

  Future<bool> saveClubPatch({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    if (isSaving) return false;
    if (patch.isEmpty) return true;

    try {
      await HostClubEditController.updateClubMutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClub(clubId: clubId, patch: patch),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget? buildSaveError(MutationState mutation) {
    if (!mutation.hasError) return null;
    return CatchErrorBanner(
      message: mutationErrorMessage(mutation, context: AppErrorContext.club),
    );
  }
}

class _HostInlineTextEntryEditor extends ConsumerStatefulWidget {
  const _HostInlineTextEntryEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.currentFieldValue,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    required this.patchForValue,
    this.placeholder,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.normalizeInput,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.validator,
    this.toFieldValue,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final UpdateClubPatch Function(Object? value) patchForValue;
  final String? placeholder;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final String Function(String value)? normalizeInput;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;

  @override
  ConsumerState<_HostInlineTextEntryEditor> createState() =>
      _HostInlineTextEntryEditorState();
}

class _HostInlineTextEntryEditorState
    extends ConsumerState<_HostInlineTextEntryEditor>
    with _HostInlineClubSaveState<_HostInlineTextEntryEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _focusNode = FocusNode();
    _controller.addListener(_clearValidationError);
    if (widget.isExpanded) {
      _requestFocusAfterExpansionFrame();
    }
  }

  @override
  void didUpdateWidget(covariant _HostInlineTextEntryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _controller.text = widget.currentValue;
    }
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _requestFocusAfterExpansionFrame();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_clearValidationError);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null) return;
    setState(() => _validationError = null);
  }

  void _requestFocusAfterExpansionFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isExpanded || isSaving || _focusNode.hasFocus) {
        return;
      }
      _focusNode.requestFocus();
    });
  }

  void _cancel() {
    _controller.text = widget.currentValue;
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final normalizedText =
        widget.normalizeInput?.call(_controller.text) ?? _controller.text;
    if (normalizedText != _controller.text) {
      _controller.text = normalizedText;
    }

    final validationError = widget.validator?.call(normalizedText);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    final rawValue = normalizedText.trim();
    final fieldValue = widget.toFieldValue != null
        ? widget.toFieldValue!(rawValue)
        : rawValue;
    if (_isUnchanged(fieldValue)) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: widget.patchForValue(fieldValue),
    );
    if (saved && mounted) widget.onSaved();
  }

  bool _isUnchanged(Object? fieldValue) {
    final currentFieldValue = widget.currentFieldValue;
    return fieldValue == currentFieldValue ||
        (fieldValue == null &&
            (currentFieldValue == null || widget.currentValue.trim().isEmpty));
  }

  @override
  Widget build(BuildContext context) {
    final saveMutation = ref.watch(HostClubEditController.updateClubMutation);
    final saving = saveMutation.isPending;
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: widget.value,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: saving,
      animateValueContent: false,
      valueContent: ProfileInlineTextValue(
        label: widget.label,
        displayValue: widget.value,
        placeholder: widget.placeholder,
        controller: _controller,
        focusNode: _focusNode,
        isEditing: widget.isExpanded,
        enabled: !saving,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        showCounter: widget.showCounter,
        collapseStackedBlankLines: widget.maxLines != 1,
        onSubmitted: (_) => _submit(),
      ),
      saveError: _validationError == null
          ? buildSaveError(saveMutation)
          : CatchErrorBanner(message: _validationError!),
      actionLeading: widget.showCounter && widget.maxLength != null
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Text(
                '${_controller.text.length} / ${widget.maxLength}',
                style: CatchTextStyles.labelM(context),
              ),
            )
          : null,
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}

class _HostInlineOption<T> {
  const _HostInlineOption({
    required this.value,
    required this.label,
    this.accentColor,
  });

  final T value;
  final String label;
  final Color? accentColor;
}

class _HostInlineOptionEditor<T> extends ConsumerStatefulWidget {
  const _HostInlineOptionEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.fieldName,
    required this.isExpanded,
    required this.options,
    required this.patchForValue,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.helperText,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final T currentValue;
  final String fieldName;
  final bool isExpanded;
  final List<_HostInlineOption<T>> options;
  final UpdateClubPatch Function(T value) patchForValue;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final String? helperText;

  @override
  ConsumerState<_HostInlineOptionEditor<T>> createState() =>
      _HostInlineOptionEditorState<T>();
}

class _HostInlineOptionEditorState<T>
    extends ConsumerState<_HostInlineOptionEditor<T>>
    with _HostInlineClubSaveState<_HostInlineOptionEditor<T>> {
  late T _selected = widget.currentValue;

  @override
  void didUpdateWidget(covariant _HostInlineOptionEditor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _selected = widget.currentValue;
    }
  }

  void _cancel() {
    setState(() => _selected = widget.currentValue);
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected == widget.currentValue) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: widget.patchForValue(_selected),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final saveMutation = ref.watch(HostClubEditController.updateClubMutation);
    final saving = saveMutation.isPending;
    final displayValue = widget.isExpanded
        ? _labelFor(_selected)
        : widget.value;
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: displayValue,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: saving,
      animateValueContent: false,
      saveError: buildSaveError(saveMutation),
      editorChildren: [
        if (widget.helperText != null) ...[
          Text(
            widget.helperText!,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
        ],
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final option in widget.options)
              CatchSelectChip(
                label: option.label,
                active: _selected == option.value,
                accentColor: option.accentColor,
                enabled: !saving,
                onTap: () => setState(() => _selected = option.value),
              ),
          ],
        ),
      ],
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }

  String _labelFor(T value) {
    for (final option in widget.options) {
      if (option.value == value) return option.label;
    }
    return widget.value;
  }
}

class _HostInlineAgeRangeEditor extends ConsumerStatefulWidget {
  const _HostInlineAgeRangeEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldName,
    required this.hostDefaults,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final String fieldName;
  final ClubHostDefaults hostDefaults;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<_HostInlineAgeRangeEditor> createState() =>
      _HostInlineAgeRangeEditorState();
}

class _HostInlineAgeRangeEditorState
    extends ConsumerState<_HostInlineAgeRangeEditor>
    with _HostInlineClubSaveState<_HostInlineAgeRangeEditor> {
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  String? _validationError;

  EventPolicyDefaults get _policy => widget.hostDefaults.eventPolicy;

  @override
  void initState() {
    super.initState();
    _minAgeController = TextEditingController(
      text: _optionalMinAgeText(_policy.minAge),
    );
    _maxAgeController = TextEditingController(
      text: _optionalMaxAgeText(_policy.maxAge),
    );
    _minAgeController.addListener(_clearValidationError);
    _maxAgeController.addListener(_clearValidationError);
  }

  @override
  void didUpdateWidget(covariant _HostInlineAgeRangeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.hostDefaults.eventPolicy.minAge != _policy.minAge ||
        oldWidget.hostDefaults.eventPolicy.maxAge != _policy.maxAge) {
      _minAgeController.text = _optionalMinAgeText(_policy.minAge);
      _maxAgeController.text = _optionalMaxAgeText(_policy.maxAge);
    }
  }

  @override
  void dispose() {
    _minAgeController.removeListener(_clearValidationError);
    _maxAgeController.removeListener(_clearValidationError);
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null) return;
    setState(() => _validationError = null);
  }

  void _cancel() {
    _minAgeController.text = _optionalMinAgeText(_policy.minAge);
    _maxAgeController.text = _optionalMaxAgeText(_policy.maxAge);
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final parsed = _parseAgeRange(
      minText: _minAgeController.text,
      maxText: _maxAgeController.text,
    );
    if (parsed.error != null) {
      setState(() => _validationError = parsed.error);
      return;
    }

    final minAge = parsed.minAge!;
    final maxAge = parsed.maxAge!;
    if (minAge == _policy.minAge && maxAge == _policy.maxAge) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: UpdateClubPatch(
        hostDefaults: widget.hostDefaults.copyWith(
          eventPolicy: _policy.copyWith(minAge: minAge, maxAge: maxAge),
        ),
      ),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final saveMutation = ref.watch(HostClubEditController.updateClubMutation);
    final saving = saveMutation.isPending;
    final displayValue = widget.isExpanded ? _draftValue : widget.value;
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: displayValue,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: saving,
      animateValueContent: false,
      saveError: _validationError == null
          ? buildSaveError(saveMutation)
          : CatchErrorBanner(message: _validationError!),
      editorChildren: [
        Row(
          children: [
            Expanded(
              child: CatchTextField(
                label: 'Min age',
                isOptional: true,
                controller: _minAgeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !saving,
              ),
            ),
            gapW12,
            Expanded(
              child: CatchTextField(
                label: 'Max age',
                isOptional: true,
                controller: _maxAgeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !saving,
              ),
            ),
          ],
        ),
      ],
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }

  String get _draftValue {
    final minAge = int.tryParse(_minAgeController.text.trim()) ?? 0;
    final maxAge = int.tryParse(_maxAgeController.text.trim()) ?? 99;
    return '$minAge–$maxAge';
  }
}

class _HostClubPreviewPane extends StatelessWidget {
  const _HostClubPreviewPane({required this.club, required this.onPreviewClub});

  final Club club;
  final HostClubPreviewCallback onPreviewClub;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          club.description,
          style: CatchTextStyles.bodyLead(context, color: t.ink),
        ),
        gapH18,
        CatchSettingsRow(
          label: 'Open public preview',
          value: 'Preview',
          icon: CatchIcons.visibilityOutlined,
          onTap: () => onPreviewClub(club),
        ),
      ],
    );
  }
}

String _valueOrDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '—' : trimmed;
}

String _admissionDefaultLabel(EventAdmissionDefaultPreset preset) {
  return switch (preset) {
    EventAdmissionDefaultPreset.openCapacity => 'Open capacity',
    EventAdmissionDefaultPreset.inviteOnly => 'Invite only',
    EventAdmissionDefaultPreset.balancedSingles => 'Balanced singles',
    EventAdmissionDefaultPreset.fixedCohortCaps => 'Fixed cohort caps',
  };
}

String _admissionDefaultDescription(EventAdmissionDefaultPreset preset) {
  return switch (preset) {
    EventAdmissionDefaultPreset.openCapacity =>
      'Anyone eligible can book until the event reaches capacity.',
    EventAdmissionDefaultPreset.inviteOnly =>
      'New invite-only events ask for an event-specific code.',
    EventAdmissionDefaultPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other.',
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      'Open booking with optional straight men and straight women caps.',
  };
}

ClubHostDefaults _hostDefaultsWithActivity(
  ClubHostDefaults defaults,
  ActivityKind activityKind,
) {
  final supported =
      defaults.effectiveSupportedActivityKinds.contains(activityKind)
      ? defaults.supportedActivityKinds
      : [...defaults.supportedActivityKinds, activityKind];
  return defaults.copyWith(
    primaryActivityKind: activityKind,
    supportedActivityKinds: supported,
  );
}

EventCancellationPolicy _cancellationPolicyFor(
  EventCancellationPolicyId policyId,
) {
  return switch (policyId) {
    EventCancellationPolicyId.flexible =>
      const EventCancellationPolicy.flexible(),
    EventCancellationPolicyId.standard =>
      const EventCancellationPolicy.standard(),
    EventCancellationPolicyId.strict => const EventCancellationPolicy.strict(),
  };
}

String _normalizeSingleLineInput(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _normalizeMultilineInput(String value) {
  return value
      .trim()
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
}

String? Function(String?) _requiredHostFieldValidator(String label) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  };
}

String? _optionalEmailValidator(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  return valid ? null : 'Enter a valid email.';
}

Object? _optionalStringFieldValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _optionalMinAgeText(int minAge) => minAge == 0 ? '' : '$minAge';

String _optionalMaxAgeText(int maxAge) => maxAge == 99 ? '' : '$maxAge';

_ParsedAgeRange _parseAgeRange({
  required String minText,
  required String maxText,
}) {
  final minRaw = minText.trim();
  final maxRaw = maxText.trim();
  final minAge = minRaw.isEmpty ? 0 : int.tryParse(minRaw);
  final maxAge = maxRaw.isEmpty ? 99 : int.tryParse(maxRaw);

  if (minAge == null || (minRaw.isNotEmpty && (minAge < 18 || minAge > 99))) {
    return const _ParsedAgeRange.error('Min age must be 18-99.');
  }
  if (maxAge == null || (maxRaw.isNotEmpty && (maxAge < 18 || maxAge > 99))) {
    return const _ParsedAgeRange.error('Max age must be 18-99.');
  }
  if (minAge > maxAge) {
    return const _ParsedAgeRange.error('Min age must be less than max age.');
  }
  return _ParsedAgeRange(minAge: minAge, maxAge: maxAge);
}

class _ParsedAgeRange {
  const _ParsedAgeRange({required this.minAge, required this.maxAge})
    : error = null;

  const _ParsedAgeRange.error(this.error) : minAge = null, maxAge = null;

  final int? minAge;
  final int? maxAge;
  final String? error;
}

class HostEventRow extends StatelessWidget {
  const HostEventRow({super.key, required this.row, required this.onTap});

  final HostHomeEventRowData row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CatchSettingsRow(
      label: row.title,
      value: row.timeRangeLabel,
      icon: CatchIcons.calendarTodayOutlined,
      divider: row.divider,
      onTap: onTap,
    );
  }
}

class _HostEmptyState extends StatelessWidget {
  const _HostEmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          gapH8,
          Text(body, style: CatchTextStyles.supporting(context, color: t.ink2)),
          gapH18,
          CatchButton(
            label: 'Create club',
            icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
            onPressed: () =>
                context.pushNamed(Routes.hostCreateClubScreen.name),
          ),
        ],
      ),
    );
  }
}

class _HostAuthRequiredScreen extends StatelessWidget {
  const _HostAuthRequiredScreen();

  @override
  Widget build(BuildContext context) {
    return CatchErrorScaffold(
      title: 'Sign in required',
      message: 'Sign in to manage host operations.',
      retryLabel: 'Sign in',
      onRetry: () => context.go(Routes.authScreen.path),
    );
  }
}

class _HostLoadingScreen extends StatelessWidget {
  const _HostLoadingScreen({required this.title, this.showTabRail = false});

  final String title;
  final bool showTabRail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: CatchTopBar(title: title, border: true),
      body: SafeArea(child: HostRouteLoadingBody(showTabRail: showTabRail)),
    );
  }
}

final _hostClubsForUserProvider = Provider.autoDispose
    .family<AsyncValue<List<Club>>, String>((ref, uid) {
      final hostedAsync = ref.watch(watchClubsHostedByProvider(uid));
      final ownedAsync = ref.watch(watchClubsOwnedByProvider(uid));

      final hosted = hostedAsync.asData?.value;
      final owned = ownedAsync.asData?.value;
      if (hostedAsync.hasError) {
        return AsyncError(
          hostedAsync.error!,
          hostedAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (ownedAsync.hasError) {
        return AsyncError(
          ownedAsync.error!,
          ownedAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (hosted == null || owned == null) return const AsyncLoading();

      final clubsById = <String, Club>{};
      for (final club in hosted) {
        clubsById[club.id] = club;
      }
      for (final club in owned) {
        clubsById[club.id] = club;
      }
      final clubs = clubsById.values.toList()
        ..sort((a, b) {
          final aOwned = a.isOwnedBy(uid);
          final bOwned = b.isOwnedBy(uid);
          if (aOwned != bOwned) return aOwned ? -1 : 1;
          return a.name.compareTo(b.name);
        });
      return AsyncData(List.unmodifiable(clubs));
    });
