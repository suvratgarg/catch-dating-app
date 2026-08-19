import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_controller.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_link_and_run.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_setup_section.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_simulator.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostEventRehearsalScreen extends ConsumerStatefulWidget {
  const HostEventRehearsalScreen({
    super.key,
    required this.clubId,
    required this.sessionId,
  });

  final String clubId;
  final String sessionId;

  @override
  ConsumerState<HostEventRehearsalScreen> createState() =>
      _HostEventRehearsalScreenState();
}

class _HostEventRehearsalScreenState
    extends ConsumerState<HostEventRehearsalScreen> {
  @override
  Widget build(BuildContext context) {
    final rehearsalAsync = ref.watch(eventRehearsalProvider(widget.sessionId));
    final setupMutation = ref.watch(EventRehearsalController.setupMutation);
    final controlMutation = ref.watch(EventRehearsalController.controlMutation);
    final behaviorMutation = ref.watch(
      EventRehearsalController.behaviorMutation,
    );
    final resetMutation = ref.watch(EventRehearsalController.resetMutation);
    final forkMutation = ref.watch(EventRehearsalController.forkMutation);
    final guestLinkMutation = ref.watch(
      EventRehearsalController.guestLinkMutation,
    );
    final exportMutation = ref.watch(EventRehearsalController.exportMutation);
    final shareMutation = ref.watch(EventRehearsalController.shareMutation);
    final busy =
        setupMutation.isPending ||
        controlMutation.isPending ||
        behaviorMutation.isPending ||
        resetMutation.isPending ||
        forkMutation.isPending ||
        guestLinkMutation.isPending ||
        exportMutation.isPending ||
        shareMutation.isPending;
    return CatchMutationErrorListeners(
      mutations: [
        EventRehearsalController.setupMutation,
        EventRehearsalController.controlMutation,
        EventRehearsalController.behaviorMutation,
        EventRehearsalController.resetMutation,
        EventRehearsalController.forkMutation,
        EventRehearsalController.guestLinkMutation,
        EventRehearsalController.exportMutation,
        EventRehearsalController.shareMutation,
      ],
      errorContext: AppErrorContext.event,
      child: CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostEventRehearsalTitle,
          leadingType: CatchTopBarLeading.back,
          divider: scrolledUnder,
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: CatchAsyncValueView<EventRehearsalBootstrap>(
            value: rehearsalAsync,
            onRetry: () =>
                ref.invalidate(eventRehearsalProvider(widget.sessionId)),
            initialLoadTimeout: null,
            loadingBuilder: (_) =>
                const CatchPageBody(child: CatchSkeletonRows(count: 9)),
            errorBuilder: (_, error, _) => CatchPageBody(
              child: CatchErrorState.fromError(
                error,
                context: AppErrorContext.event,
                onRetry: () =>
                    ref.invalidate(eventRehearsalProvider(widget.sessionId)),
              ),
            ),
            builder: (context, rehearsal) => ListView(
              padding: CatchInsets.pageBody,
              children: [
                CatchSurface.message(
                  title: context.l10n.hostEventRehearsalTitle,
                  message: context.l10n.hostEventRehearsalPracticeBanner,
                  messageIcon: CatchIcons.scienceOutlined,
                ),
                gapH20,
                EventRehearsalSetupSection(
                  session: rehearsal.session,
                  isLoading: busy,
                  onSave: (setup, scenario, actorCount) => _saveSetup(
                    rehearsal.session,
                    setup,
                    scenario,
                    actorCount,
                  ),
                ),
                gapH20,
                EventRehearsalGuestLinkSection(
                  guestUrl: rehearsal.guestUrl,
                  isLoading: busy,
                  onCopy: () => _copyGuestLink(rehearsal.guestUrl),
                  onShare: () => _shareGuestLink(rehearsal.guestUrl),
                  onRotate: _rotateGuestLink,
                ),
                gapH20,
                EventRehearsalRunSection(
                  session: rehearsal.session,
                  isLoading: busy,
                  onControl: (action, minutes) =>
                      _control(rehearsal.session, action, minutes),
                ),
                gapH20,
                EventRehearsalSimulator(
                  rehearsal: rehearsal,
                  isLoading: busy,
                  onBehavior: (actorId, behavior) =>
                      _injectBehavior(rehearsal.session, actorId, behavior),
                  onFault: (fault) => _injectFault(rehearsal.session, fault),
                ),
                gapH20,
                EventRehearsalRosterSection(rehearsal: rehearsal),
                gapH20,
                EventRehearsalRecapSection(
                  rehearsal: rehearsal,
                  isLoading: busy,
                  onReset: _reset,
                  onFork: _fork,
                  onExport: _export,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSetup(
    EventRehearsalSession session,
    EventRehearsalSetup setup,
    EventRehearsalScenario scenario,
    int actorCount,
  ) async {
    try {
      await EventRehearsalController.setupMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .updateSetup(
              session: session,
              setup: setup,
              scenario: scenario,
              actorCount: actorCount,
            ),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _control(
    EventRehearsalSession session,
    EventRehearsalControlAction action,
    int? minutes,
  ) async {
    try {
      await EventRehearsalController.controlMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .control(session: session, action: action, minutes: minutes),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _injectBehavior(
    EventRehearsalSession session,
    String actorId,
    EventRehearsalBehavior behavior,
  ) async {
    try {
      await EventRehearsalController.behaviorMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .inject(
              session: session,
              actorId: actorId,
              behavior: behavior,
              fault: session.fault,
            ),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _injectFault(
    EventRehearsalSession session,
    EventRehearsalFault fault,
  ) async {
    try {
      await EventRehearsalController.behaviorMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .inject(session: session, fault: fault),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _copyGuestLink(String guestUrl) async {
    try {
      await EventRehearsalController.shareMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .copyGuestLink(guestUrl),
      );
      if (mounted) {
        showCatchSnackBar(context, context.l10n.hostEventRehearsalLinkCopied);
      }
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _shareGuestLink(String guestUrl) async {
    try {
      await EventRehearsalController.shareMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .shareGuestLink(guestUrl),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _rotateGuestLink() async {
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostEventRehearsalRotateLink,
      message: context.l10n.hostEventRehearsalRotateLinkBody,
      confirmLabel: context.l10n.hostEventRehearsalRotateLink,
    );
    if (confirmed != true || !mounted) return;
    try {
      await EventRehearsalController.guestLinkMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .rotateGuestLink(widget.sessionId),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _reset() async {
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostEventRehearsalReset,
      message: context.l10n.hostEventRehearsalResetBody,
      confirmLabel: context.l10n.hostEventRehearsalReset,
    );
    if (confirmed != true || !mounted) return;
    try {
      await EventRehearsalController.resetMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .reset(widget.sessionId),
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _fork() async {
    try {
      final created = await EventRehearsalController.forkMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .fork(widget.sessionId),
      );
      if (!mounted) return;
      context.goNamed(
        Routes.hostEventRehearsalScreen.name,
        pathParameters: {
          'clubId': widget.clubId,
          'sessionId': created.sessionId,
        },
      );
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }

  Future<void> _export() async {
    try {
      await EventRehearsalController.exportMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .exportReproduction(widget.sessionId),
      );
      if (mounted) {
        showCatchSnackBar(
          context,
          context.l10n.hostEventRehearsalReproductionCopied,
        );
      }
    } on Object {
      // The mutation listener owns user-visible action failure.
    }
  }
}
