import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({
    super.key,
    required this.runClubId,
    required this.runId,
    required this.title,
    required this.clubName,
    required this.whenLabel,
    required this.locationLabel,
    required this.distanceLabel,
    required this.priceLabel,
    required this.signupLabel,
    required this.paceLabel,
    required this.reasonLabel,
    this.width,
  });

  factory RecommendCard.fromRecommendation({
    Key? key,
    required DashboardRunRecommendation recommendation,
    double? width,
  }) {
    final run = recommendation.run;
    return RecommendCard(
      key: key,
      runClubId: run.runClubId,
      runId: run.id,
      title: run.title,
      clubName: recommendation.clubName,
      whenLabel: DateFormat('EEE d MMM · h:mm a').format(run.startTime),
      locationLabel: run.meetingPoint,
      distanceLabel: _formatDistance(run.distanceKm),
      priceLabel: _formatPrice(run.priceInPaise),
      signupLabel: '${run.signedUpCount}/${run.capacityLimit} signed up',
      paceLabel: run.pace.label,
      reasonLabel: recommendation.reasonLabel,
      width: width,
    );
  }

  factory RecommendCard.fromRun({Key? key, required Run run, double? width}) =>
      RecommendCard(
        key: key,
        runClubId: run.runClubId,
        runId: run.id,
        title: run.title,
        clubName: 'Your run club',
        whenLabel: DateFormat('EEE d MMM · h:mm a').format(run.startTime),
        locationLabel: run.meetingPoint,
        distanceLabel: _formatDistance(run.distanceKm),
        priceLabel: _formatPrice(run.priceInPaise),
        signupLabel: '${run.signedUpCount}/${run.capacityLimit} signed up',
        paceLabel: run.pace.label,
        reasonLabel: 'From your clubs',
        width: width,
      );

  final String runClubId;
  final String runId;
  final String title;
  final String clubName;
  final String whenLabel;
  final String locationLabel;
  final String distanceLabel;
  final String priceLabel;
  final String signupLabel;
  final String paceLabel;
  final String reasonLabel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      onTap: () => context.pushNamed(
        Routes.dashboardRunDetailScreen.name,
        pathParameters: {'runClubId': runClubId, 'runId': runId},
      ),
      width: width,
      radius: CatchRadius.md,
      borderColor: t.line,
      backgroundColor: t.surface,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: Sizes.p6,
              runSpacing: Sizes.p6,
              children: [
                CatchBadge(label: distanceLabel, tone: CatchBadgeTone.brand),
                CatchBadge(label: priceLabel, tone: CatchBadgeTone.neutral),
                CatchBadge(label: paceLabel, tone: CatchBadgeTone.neutral),
              ],
            ),
            gapH12,
            Text(
              title,
              style: CatchTextStyles.titleM(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            gapH8,
            _RecommendMetaRow(
              icon: Icons.groups_2_outlined,
              label: clubName,
              emphasize: true,
            ),
            gapH6,
            _RecommendMetaRow(icon: Icons.schedule, label: whenLabel),
            gapH6,
            _RecommendMetaRow(
              icon: Icons.location_on_outlined,
              label: locationLabel,
              maxLines: 2,
            ),
            gapH14,
            _RecommendMetaRow(
              icon: Icons.person_add_alt_1_outlined,
              label: signupLabel,
              emphasize: true,
            ),
            gapH10,
            CatchBadge(label: reasonLabel, tone: CatchBadgeTone.success),
          ],
        ),
      ),
    );
  }
}

class _RecommendMetaRow extends StatelessWidget {
  const _RecommendMetaRow({
    required this.icon,
    required this.label,
    this.maxLines = 1,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final int maxLines;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final style = emphasize
        ? CatchTextStyles.labelM(context, color: t.ink)
        : CatchTextStyles.bodyS(context, color: t.ink2);

    return Row(
      crossAxisAlignment: maxLines == 1
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: t.ink3),
        gapW6,
        Expanded(
          child: Text(
            label,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _formatDistance(double distanceKm) {
  final rounded = distanceKm.roundToDouble();
  if ((distanceKm - rounded).abs() < 0.05) {
    return '${rounded.toInt()} km';
  }
  return '${distanceKm.toStringAsFixed(1)} km';
}

String _formatPrice(int priceInPaise) {
  if (priceInPaise <= 0) return 'Free';
  final rupees = priceInPaise / 100;
  if (rupees == rupees.roundToDouble()) {
    return '₹${rupees.toInt()}';
  }
  return '₹${rupees.toStringAsFixed(2)}';
}
