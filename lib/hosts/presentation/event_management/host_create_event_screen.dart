import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
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
    if (initialClub != null) {
      return CreateEventScreen(club: initialClub!);
    }

    final clubAsync = ref.watch(fetchClubProvider(clubId));
    return CatchAsyncValueView<Club?>(
      value: clubAsync,
      loadingBuilder: (_) => const _HostCreateEventRouteLoadingScreen(),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchClubProvider(clubId)),
      ),
      builder: (context, club) => club == null
          ? const CatchErrorScaffold(
              title: 'Club not found',
              message: 'This club is no longer available.',
            )
          : CreateEventScreen(club: club),
    );
  }
}

class _HostCreateEventRouteLoadingScreen extends StatelessWidget {
  const _HostCreateEventRouteLoadingScreen();

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
            const Expanded(child: _CreateEventLoadingBody()),
            const _CreateEventLoadingFooter(),
          ],
        ),
      ),
    );
  }
}

class _CreateEventLoadingBody extends StatelessWidget {
  const _CreateEventLoadingBody();

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
          const _LoadingChipRow(widths: [168, 108]),
          gapH10,
          const _LoadingChipRow(widths: [212]),
          gapH18,
          CatchSkeleton.text(width: CatchLayout.skeletonTextBodyWidth),
          gapH12,
          CatchSkeleton.textBlock(),
        ],
      ),
    );
  }
}

class _LoadingChipRow extends StatelessWidget {
  const _LoadingChipRow({required this.widths});

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

class _CreateEventLoadingFooter extends StatelessWidget {
  const _CreateEventLoadingFooter();

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
