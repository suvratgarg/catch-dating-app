import 'dart:async';

import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_controller.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_cta.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_hero_app_bar.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_overview_section.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_social_section.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef RunShareHandler = Future<void> Function(BuildContext context, Run run);

class RunDetailBody extends ConsumerWidget {
  const RunDetailBody({
    super.key,
    required this.run,
    required this.userProfile,
    required this.runClubId,
    required this.reviews,
    required this.isAuthenticated,
    required this.isHost,
    this.onShareRun,
    this.now,
  });

  final Run run;
  final UserProfile? userProfile;
  final String runClubId;
  final List<Review> reviews;
  final bool isAuthenticated;
  final bool isHost;
  final RunShareHandler? onShareRun;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final run = this.run;
    final userProfile = this.userProfile;
    final isSaved = userProfile?.savedRunIds.contains(run.id) ?? false;
    final saveMutation = ref.watch(RunDetailController.toggleSavedRunMutation);
    final share = ref.watch(externalShareControllerProvider);

    if (isAuthenticated) {
      ref.listen(RunBookingController.bookMutation, (prev, next) {
        if (prev?.isPending == true && next.isSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
        }
      });
      ref.listen(RunBookingController.cancelMutation, (prev, next) {
        if (prev?.isPending == true && next.isSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
        }
      });
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          RunDetailHeroAppBar(
            run: run,
            isSaved: isSaved,
            savePending: saveMutation.isPending,
            onBack: () => Navigator.of(context).pop(),
            onShare: (buttonContext) => unawaited(
              onShareRun != null
                  ? onShareRun!(buttonContext, run)
                  : _shareRun(buttonContext, run, share),
            ),
            onToggleSaved: () => _toggleSavedRun(
              context,
              ref,
              run: run,
              runClubId: runClubId,
              userProfile: userProfile,
              isAuthenticated: isAuthenticated,
              isSaved: isSaved,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              20,
              CatchSpacing.s5,
              32,
            ),
            sliver: SliverList.list(
              children: [
                RunDetailOverviewSection(run: run),
                const SizedBox(height: 24),
                Divider(color: t.line, height: 1),
                const SizedBox(height: 24),
                RunDetailSocialSection(
                  run: run,
                  runClubId: runClubId,
                  reviews: reviews,
                  userProfile: userProfile,
                  isAuthenticated: isAuthenticated,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isAuthenticated && userProfile != null
          ? RunDetailCta(
              run: run,
              userProfile: userProfile,
              runClubId: runClubId,
              isHost: isHost,
              now: now,
            )
          : _GuestBookCta(runClubId: runClubId, runId: run.id),
    );
  }
}

void _toggleSavedRun(
  BuildContext context,
  WidgetRef ref, {
  required Run run,
  required String runClubId,
  required UserProfile? userProfile,
  required bool isAuthenticated,
  required bool isSaved,
}) {
  if (!isAuthenticated || userProfile == null) {
    context.pushNamed(
      Routes.onboardingScreen.name,
      queryParameters: {'from': '/clubs/run-clubs/$runClubId/runs/${run.id}'},
    );
    return;
  }

  RunDetailController.toggleSavedRunMutation.run(ref, (tx) async {
    final nowSaved = await tx
        .get(runDetailControllerProvider.notifier)
        .toggleSavedRun(run: run, userProfile: userProfile, isSaved: isSaved);
    if (!context.mounted) return nowSaved;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(nowSaved ? 'Run saved.' : 'Run removed.')),
    );
    return nowSaved;
  });
}

Future<void> _shareRun(
  BuildContext context,
  Run run,
  ExternalShareController share,
) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final uri = AppDeepLinks.run(runClubId: run.runClubId, runId: run.id);

  try {
    await share.shareText(
      text:
          'Join me for ${run.title} at ${run.meetingPoint}: ${uri.toString()}',
      subject: run.title,
      origin: origin,
    );
  } on Object catch (error, stack) {
    debugPrint('[ERROR] RunDetailBody share failed: $error\n$stack');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open share sheet.')),
    );
  }
}

class _GuestBookCta extends StatelessWidget {
  const _GuestBookCta({required this.runClubId, required this.runId});

  final String runClubId;
  final String runId;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: CatchButton(
          label: 'Sign in to book this run',
          onPressed: () => context.pushNamed(
            Routes.onboardingScreen.name,
            queryParameters: {
              'from': '/clubs/run-clubs/$runClubId/runs/$runId',
            },
          ),
          icon: Icon(Icons.lock_outline_rounded, size: 18, color: t.primary),
          fullWidth: true,
        ),
      ),
    );
  }
}
