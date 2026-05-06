import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/card_photo_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/name_overlay.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_attributes_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_bio_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_lifestyle_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_running_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScrollableProfile extends ConsumerWidget {
  const ScrollableProfile({
    super.key,
    required this.profile,
    required this.cardHeight,
    this.scrollController,
    this.onLeadingOverscroll,
  });

  static const scrollViewKey = ValueKey('scrollable-profile-scroll-view');

  final PublicProfile profile;
  final double cardHeight;
  final ScrollController? scrollController;
  final ValueChanged<double>? onLeadingOverscroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = ref.watch(deviceLocationProvider).asData?.value;
    final content = ProfileCardContent.fromProfile(
      profile,
      currentUserLocation: currentLocation,
    );
    final palette = ProfileCardPalette.of(context);
    final firstAdditionalPhotoUrl = content.additionalPhotoUrls.firstOrNull;
    final remainingPhotoUrls = content.additionalPhotoUrls.skip(1);

    return ColoredBox(
      color: palette.background,
      child: NotificationListener<OverscrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.overscroll < 0 &&
              notification.metrics.pixels <=
                  notification.metrics.minScrollExtent) {
            onLeadingOverscroll?.call(notification.overscroll);
          }
          return false;
        },
        child: SingleChildScrollView(
          key: scrollViewKey,
          controller: scrollController,
          primary: false,
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardPhotoSection(
                url: content.primaryPhotoUrl,
                height: cardHeight,
                overlayChild: NameOverlay(profile: profile),
              ),
              if (content.hasBio) ProfileBioSection(bio: content.bio),
              _RunningIdentityCard(profile: profile),
              if (content.attributes.isNotEmpty)
                ProfileAttributesSection(attrs: content.attributes),
              if (content.hasRunning)
                ProfileRunningSection(items: content.running),
              if (firstAdditionalPhotoUrl != null)
                CardPhotoSection(
                  url: firstAdditionalPhotoUrl,
                  height: cardHeight * 0.75,
                ),
              if (content.lifestyle.isNotEmpty)
                ProfileLifestyleSection(items: content.lifestyle),
              for (final photoUrl in remainingPhotoUrls)
                CardPhotoSection(url: photoUrl, height: cardHeight * 0.75),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunningIdentityCard extends StatelessWidget {
  const _RunningIdentityCard({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: Container(
        padding: const EdgeInsets.all(Sizes.p18),
        decoration: BoxDecoration(
          color: palette.surfaceRaised,
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RUN PROFILE',
              style: CatchTextStyles.labelM(
                context,
                color: palette.textMuted,
              ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            gapH8,
            Text(
              '${profile.name.split(' ').first} runs ${formatPaceRange(profile.paceMinSecsPerKm, profile.paceMaxSecsPerKm)}',
              style: CatchTextStyles.displayS(
                context,
                color: palette.textPrimary,
              ),
            ),
            gapH14,
            Row(
              children: [
                _RunStatPill(
                  label: 'Pace',
                  value: formatPaceRange(
                    profile.paceMinSecsPerKm,
                    profile.paceMaxSecsPerKm,
                  ),
                ),
                gapW8,
                _RunStatPill(
                  label: 'Distance',
                  value: _formatDistanceSummary(profile),
                ),
              ],
            ),
            if (profile.runningReasons.isNotEmpty) ...[
              gapH12,
              Text(
                profile.runningReasons.map((r) => r.label).join(' · '),
                style: CatchTextStyles.bodyS(
                  context,
                  color: palette.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RunStatPill extends StatelessWidget {
  const _RunStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: palette.chipFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.chipBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CatchTextStyles.bodyS(context, color: palette.textMuted),
            ),
            gapH2,
            Text(
              value,
              style: CatchTextStyles.mono(context, color: palette.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDistanceSummary(PublicProfile profile) {
  if (profile.preferredDistances.isEmpty) return 'Any run';
  return profile.preferredDistances.map((d) => d.label).take(2).join(', ');
}
