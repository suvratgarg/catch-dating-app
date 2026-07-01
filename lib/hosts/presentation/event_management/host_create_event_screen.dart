import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostCreateEventRouteScreen extends ConsumerWidget {
  const HostCreateEventRouteScreen({
    super.key,
    required this.clubId,
    this.initialClub,
  });

  final String clubId;
  final Club? initialClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialClub = this.initialClub;
    final routeState = HostCreateEventRouteState.resolve(
      initialClub: initialClub,
      fetchedClub: initialClub == null
          ? _catchAsyncState(ref.watch(fetchClubProvider(clubId)))
          : null,
      uid: _catchAsyncState(ref.watch(uidProvider)),
    );
    return HostCreateEventRouteStateView(clubId: clubId, state: routeState);
  }
}

class HostCreateEventRouteStateView extends ConsumerWidget {
  const HostCreateEventRouteStateView({
    super.key,
    required this.clubId,
    required this.state,
  });

  final String clubId;
  final HostCreateEventRouteState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.status) {
      HostCreateEventRouteStatus.loading =>
        const HostCreateEventRouteLoadingScreen(),
      HostCreateEventRouteStatus.error => CatchErrorScaffold.fromError(
        state.error!,
        context: AppErrorContext.club,
        onRetry: () => _handleRetry(ref, state.retryIntent),
      ),
      HostCreateEventRouteStatus.notFound => const CatchErrorScaffold(
        title: 'Club not found',
        message: 'This club is no longer available.',
      ),
      HostCreateEventRouteStatus.forbidden => const CatchErrorScaffold(
        title: 'Host access required',
        message: "Only this club's host team can create events for this club.",
      ),
      HostCreateEventRouteStatus.ready => CreateEventScreen(club: state.club!),
    };
  }

  void _handleRetry(WidgetRef ref, HostCreateEventRouteRetryIntent? intent) {
    switch (intent) {
      case HostCreateEventRouteRetryIntent.reloadClub:
        ref.invalidate(fetchClubProvider(clubId));
      case null:
        break;
    }
  }
}

class HostCreateEventRouteLoadingScreen extends StatelessWidget {
  const HostCreateEventRouteLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            CreateEventStepHeader(
              title: 'Event basics',
              clubName: 'Loading club',
              currentStep: 0,
              totalSteps: 5,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            gapH4,
            const Expanded(child: CreateEventLoadingBody()),
            const CreateEventLoadingFooter(),
          ],
        ),
      ),
    );
  }
}

class CreateEventLoadingBody extends StatelessWidget {
  const CreateEventLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s4,
        CatchSpacing.s4,
        CatchSpacing.s6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextInlineTitleWidth),
          gapH12,
          CatchSkeleton.card(
            height: CatchLayout.hostCreateEventRouteFormSkeletonHeight,
          ),
          gapH24,
          CatchSkeleton.text(width: CatchLayout.skeletonTextPageTitleWidth),
          gapH12,
          const LoadingChipRow(widths: [168, 108]),
          gapH10,
          const LoadingChipRow(widths: [212]),
          gapH18,
          CatchSkeleton.text(width: CatchLayout.skeletonTextBodyWidth),
          gapH12,
          CatchSkeleton.textBlock(),
        ],
      ),
    );
  }
}

class LoadingChipRow extends StatelessWidget {
  const LoadingChipRow({super.key, required this.widths});

  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final width in widths)
          CatchSkeleton.box(
            width: width,
            height: CatchLayout.controlMdMinHeight,
            radius: CatchRadius.pill,
          ),
      ],
    );
  }
}

class CreateEventLoadingFooter extends StatelessWidget {
  const CreateEventLoadingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: t.bg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          CatchSpacing.s3,
          CatchSpacing.s4,
          CatchSpacing.s3 + bottomPadding,
        ),
        child: Row(
          children: [
            CatchSkeleton.box(
              width: CatchLayout.skeletonTextBodyWidth,
              height: CatchLayout.buttonLgHeight,
              radius: CatchRadius.pill,
            ),
            gapW12,
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: CatchSkeleton.box(
                  width: CatchLayout.skeletonTextInlineTitleWidth,
                  height: CatchLayout.buttonLgHeight,
                  radius: CatchRadius.pill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}
