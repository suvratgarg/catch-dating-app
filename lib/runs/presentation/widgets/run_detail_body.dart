import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_cta.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_photo_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_stats_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_where_card.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunDetailBody extends ConsumerStatefulWidget {
  const RunDetailBody({
    super.key,
    required this.run,
    required this.appUser,
    required this.runClubId,
    required this.reviews,
  });

  final Run run;
  final AppUser appUser;
  final String runClubId;
  final List<Review> reviews;

  @override
  ConsumerState<RunDetailBody> createState() => _RunDetailBodyState();
}

class _RunDetailBodyState extends ConsumerState<RunDetailBody> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String _fmtDate(DateTime dt) =>
      '${_weekdays[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]}';

  bool _hasConstraints(Run run) =>
      run.constraints.minAge > 0 ||
      run.constraints.maxAge < 99 ||
      run.constraints.maxMen != null ||
      run.constraints.maxWomen != null;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final run = widget.run;
    final appUser = widget.appUser;

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

    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: t.surface,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: IconBtn(
                background: t.surface,
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: t.ink,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: IconBtn(
                  background: t.surface,
                  // TODO: implement share. Use share_plus to share a deep-link
                  // like https://catch.app/runs/${run.id}
                  onTap: () {},
                  child: Icon(Icons.ios_share_rounded, size: 18, color: t.ink),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                child: IconBtn(
                  background: t.surface,
                  // TODO: implement bookmark/save. Decide whether this persists
                  // to Firestore (savedRunIds on AppUser) or local prefs, then
                  // wire a toggle mutation and swap the icon to filled when saved.
                  onTap: () {},
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: t.ink,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: RunPhotoHeader(run: run),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.screenH,
              20,
              CatchSpacing.screenH,
              32,
            ),
            sliver: SliverList.list(
              children: [
                Text(run.title, style: CatchTextStyles.displayLg(context)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    VibeTag(label: run.pace.label, active: true),
                    const SizedBox(width: 6),
                    Text(
                      _fmtDate(run.startTime),
                      style: CatchTextStyles.bodySm(context, color: t.ink2),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RunStatsGrid(run: run),
                const SizedBox(height: 20),
                WhenWhereCard(run: run),
                if (run.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    run.description,
                    style: CatchTextStyles.bodyMd(context, color: t.ink2),
                  ),
                ],
                if (_hasConstraints(run)) ...[
                  const SizedBox(height: 20),
                  RequirementsRow(run: run),
                ],
                const SizedBox(height: 24),
                Divider(color: t.line, height: 1),
                const SizedBox(height: 24),
                WhoIsRunning(run: run, appUser: appUser),
                const SizedBox(height: 24),
                Divider(color: t.line, height: 1),
                const SizedBox(height: 24),
                ReviewsSection(
                  runClubId: widget.runClubId,
                  runId: run.id,
                  reviews: widget.reviews,
                  currentUid: appUser.uid,
                  appUser: appUser,
                  hasAttended: run.hasAttended(appUser.uid),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RunDetailCta(run: run, appUser: appUser),
    );
  }
}
