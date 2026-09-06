import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_panel.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_preference_controller.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_roadmap_provider.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_body.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Owns quiet-day personalization only. The existing Today projection retains
/// its complete loading, error, event and attention presentation unchanged.
class HostTodayPersonalizedView extends ConsumerStatefulWidget {
  const HostTodayPersonalizedView({
    super.key,
    required this.scope,
    required this.today,
    required this.now,
    required this.operationalSurface,
  });

  final HostTodayPreferenceScope scope;
  final HostTodayState today;
  final DateTime now;
  final Widget operationalSurface;

  @override
  ConsumerState<HostTodayPersonalizedView> createState() =>
      _HostTodayPersonalizedViewState();
}

class _HostTodayPersonalizedViewState
    extends ConsumerState<HostTodayPersonalizedView> {
  final _offeredScopes = <HostTodayPreferenceScope>{};
  GoRouter? _router;
  bool _wasTodayRoute = false;
  bool _orientationScheduled = false;
  bool _focusRouteOpen = false;

  bool get _isTodayRoute =>
      _router?.routeInformationProvider.value.uri.path ==
      Routes.hostTodayScreen.path;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (identical(router, _router)) return;
    _router?.routeInformationProvider.removeListener(_onRouteChanged);
    _router = router;
    _wasTodayRoute = _isTodayRoute;
    router.routeInformationProvider.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _router?.routeInformationProvider.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final isToday = _isTodayRoute;
    if (isToday && !_wasTodayRoute && _hasCurrentAccount) {
      // CRM summaries are callable snapshots; unlike organizer and payment
      // streams they need a refresh after work in another feature.
      ref.invalidate(hostCrmSummaryProvider(widget.scope.organizerId));
    }
    _wasTodayRoute = isToday;
    setState(() {});
  }

  bool get _hasCurrentAccount =>
      ref.read(uidProvider).asData?.value == widget.scope.accountId;

  @override
  Widget build(BuildContext context) {
    final accountId = ref.watch(uidProvider).asData?.value;
    if (accountId != widget.scope.accountId ||
        !isHostTodayQuiet(widget.today)) {
      return widget.operationalSurface;
    }

    final preference = ref.watch(hostTodayPreferenceProvider(widget.scope));
    final evidence = ref.watch(hostTodayRoadmapProvider(widget.scope));
    final saved = preference.asData?.value;
    final state = saved == null
        ? null
        : buildHostTodayPersonalizationState(
            today: widget.today,
            preference: saved,
            evidence: evidence,
          );
    if (state?.showOrientation == true) _scheduleOrientation();

    return CatchRootScreenScaffold.standard(
      scrollKey: const ValueKey('host-today-personalized-scroll-view'),
      header: HostTodayHeader(now: widget.now),
      maxContentExtent: CatchLayout.hostTodayWorkspacePageMaxExtent,
      slivers: [
        SliverToBoxAdapter(
          child: preference.hasError
              ? CatchErrorState.fromError(
                  preference.error!,
                  onRetry: () =>
                      ref.invalidate(hostTodayPreferenceProvider(widget.scope)),
                )
              : state == null
              ? const HostRouteLoadingBody(padding: EdgeInsets.zero)
              : HostTodayPersonalizationPanel(
                  state: state,
                  onChangeFocus: () => unawaited(_openFocus()),
                  onAction: (action) => unawaited(_openAction(action)),
                ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: CatchSpacing.s6),
            child: CatchButton(
              key: const ValueKey('host-today-view-events'),
              label: context.l10n.hostTodayViewAllEvents,
              variant: CatchButtonVariant.secondary,
              onPressed: () => context.goNamed(Routes.hostEventsScreen.name),
            ),
          ),
        ),
      ],
    );
  }

  void _scheduleOrientation() {
    final scope = widget.scope;
    if (!_isTodayRoute ||
        _orientationScheduled ||
        _offeredScopes.contains(scope)) {
      return;
    }
    _orientationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orientationScheduled = false;
      if (!mounted ||
          widget.scope != scope ||
          !_hasCurrentAccount ||
          !_isTodayRoute ||
          !isHostTodayQuiet(widget.today)) {
        return;
      }
      final preference = ref
          .read(hostTodayPreferenceProvider(scope))
          .asData
          ?.value;
      if (preference == null || preference.answered) return;
      _offeredScopes.add(scope);
      unawaited(_openFocus());
    });
  }

  Future<void> _openFocus() async {
    if (!_hasCurrentAccount || _focusRouteOpen) return;
    _focusRouteOpen = true;
    try {
      await context.pushNamed<void>(
        Routes.hostTodayFocusScreen.name,
        queryParameters: {'organizerId': widget.scope.organizerId},
      );
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      _focusRouteOpen = false;
    }
  }

  Future<void> _openAction(HostTodaySuggestedAction action) async {
    if (!_hasCurrentAccount) return;
    final organizerId = widget.scope.organizerId;
    try {
      switch (action) {
        case HostTodaySuggestedAction.addCustomer:
          await context.pushNamed<void>(
            Routes.hostAddCustomerScreen.name,
            queryParameters: {'organizerId': organizerId},
          );
          if (mounted &&
              _hasCurrentAccount &&
              widget.scope.organizerId == organizerId) {
            ref.invalidate(hostCrmSummaryProvider(organizerId));
          }
        case HostTodaySuggestedAction.openAudience:
          context.goNamed(
            Routes.hostAudienceScreen.name,
            queryParameters: {'organizerId': organizerId, 'view': 'people'},
          );
        case HostTodaySuggestedAction.startDressRehearsal:
          await context.pushNamed<void>(
            Routes.hostEventRehearsalStartScreen.name,
            pathParameters: {'clubId': organizerId},
          );
        case HostTodaySuggestedAction.openOrganizerPage:
          context.goNamed(
            Routes.hostOrganizerScreen.name,
            queryParameters: {'organizerId': organizerId},
          );
        case HostTodaySuggestedAction.managePayouts:
          if (!ref
              .read(hostTodayRoadmapProvider(widget.scope))
              .canManagePayouts) {
            return;
          }
          await context.pushNamed<void>(
            Routes.hostClubPaymentsScreen.name,
            queryParameters: {'clubId': organizerId},
          );
      }
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }
}
