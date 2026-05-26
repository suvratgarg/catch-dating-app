import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/public_profile/domain/profile_insights.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/card_photo_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/name_overlay.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_attributes_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_bio_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_lifestyle_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_match_signals_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScrollableProfile extends ConsumerWidget {
  const ScrollableProfile({
    super.key,
    required this.profile,
    required this.surfaceHeight,
    this.scrollController,
    this.scrollPhysics,
    this.onLeadingOverscroll,
    this.bottomPadding = 24,
    this.onReact,
    this.viewerProfile,
    this.sharedRunTitle,
  });

  static const scrollViewKey = ValueKey('scrollable-profile-scroll-view');

  final PublicProfile profile;
  final double surfaceHeight;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<double>? onLeadingOverscroll;
  final double bottomPadding;
  final ProfileReactionCallback? onReact;
  final UserProfile? viewerProfile;
  final String? sharedRunTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ProfileCardContent.fromProfile(
      profile,
      viewerProfile: viewerProfile,
      sharedRunTitle: sharedRunTitle,
    );
    final palette = ProfileCardPalette.of(context);
    final primaryPhoto = content.primaryPhoto;
    final additionalPhotos = content.additionalPhotos;
    final running = profile.activityPreferences.running;
    final insightLabel = content.insights.compatibilityReasons.isEmpty
        ? 'Profile signals'
        : 'Why you might click';

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
          physics: scrollPhysics ?? const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                child: CardPhotoSection(
                  url: primaryPhoto?.url,
                  height: _heroHeight(surfaceHeight),
                  overlayChild: _HeroPhotoOverlay(
                    profile: profile,
                    prompt: primaryPhoto?.prompt,
                  ),
                  reactionTarget: primaryPhoto == null
                      ? null
                      : _reactionTarget(
                          id: 'hero-photo',
                          type: SwipeReactionTargetType.heroPhoto,
                          label: 'Main photo',
                          preview: _photoReactionPreview(
                            profile: profile,
                            ordinalLabel: 'main profile photo',
                            prompt: primaryPhoto.prompt,
                          ),
                        ),
                  onReact: onReact,
                ),
              ),
              ProfileMatchSignalsSection(
                confidenceSignals: content.insights.confidenceSignals,
                compatibilityReasons: content.insights.compatibilityReasons,
                reactionTarget:
                    content.insights.compatibilityReasons.isEmpty &&
                        content.insights.confidenceSignals.isEmpty
                    ? null
                    : _reactionTarget(
                        id: 'compatibility',
                        type: SwipeReactionTargetType.compatibility,
                        label: insightLabel,
                        preview: _insightReactionPreview(content),
                      ),
                onReact: onReact,
              ),
              for (final prompt in content.profilePrompts)
                ProfilePromptSection(
                  prompt: prompt.displayPrompt,
                  answer: prompt.answer,
                  reactionTarget: _reactionTarget(
                    id: 'profile-prompt-${prompt.promptId}',
                    type: SwipeReactionTargetType.profilePrompt,
                    label: prompt.displayPrompt,
                    preview: prompt.answer,
                  ),
                  onReact: onReact,
                ),
              if (running.hasCurrentRunPreferences)
                _RunningIdentityCard(
                  profile: profile,
                  running: running,
                  tags: content.insights.emotionalRunTags,
                  reactionTarget: _reactionTarget(
                    id: 'running',
                    type: SwipeReactionTargetType.running,
                    label: 'Running rhythm',
                    preview: _runningReactionPreview(profile),
                  ),
                  onReact: onReact,
                ),
              if (additionalPhotos.isNotEmpty)
                _InsetProfilePhoto(
                  photo: additionalPhotos.first,
                  height: _photoBlockHeight(surfaceHeight),
                  reactionTarget: _reactionTarget(
                    id: 'photo-2',
                    type: SwipeReactionTargetType.photo,
                    label: 'Photo 2',
                    preview: _photoReactionPreview(
                      profile: profile,
                      ordinalLabel: 'second profile photo',
                      prompt: additionalPhotos.first.prompt,
                    ),
                  ),
                  onReact: onReact,
                ),
              if (content.attributes.isNotEmpty)
                ProfileAttributesSection(
                  attrs: content.attributes,
                  reactionTarget: _reactionTarget(
                    id: 'details',
                    type: SwipeReactionTargetType.details,
                    label: 'Details',
                    preview: _factsPreview(content.attributes),
                  ),
                  onReact: onReact,
                ),
              if (content.lifestyle.isNotEmpty)
                ProfileLifestyleSection(
                  items: content.lifestyle,
                  reactionTarget: _reactionTarget(
                    id: 'lifestyle',
                    type: SwipeReactionTargetType.lifestyle,
                    label: 'Lifestyle',
                    preview: _factsPreview(content.lifestyle),
                  ),
                  onReact: onReact,
                ),
              for (final indexedPhoto in additionalPhotos.skip(1).indexed)
                _InsetProfilePhoto(
                  photo: indexedPhoto.$2,
                  height: _photoBlockHeight(surfaceHeight),
                  reactionTarget: _reactionTarget(
                    id: 'photo-${indexedPhoto.$1 + 3}',
                    type: SwipeReactionTargetType.photo,
                    label: 'Photo ${indexedPhoto.$1 + 3}',
                    preview: _photoReactionPreview(
                      profile: profile,
                      ordinalLabel: 'profile photo ${indexedPhoto.$1 + 3}',
                      prompt: indexedPhoto.$2.prompt,
                    ),
                  ),
                  onReact: onReact,
                ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}

double _heroHeight(double surfaceHeight) {
  if (surfaceHeight.isInfinite || surfaceHeight <= 0) return 560;
  return (surfaceHeight * 0.82).clamp(500.0, 680.0).toDouble();
}

double _photoBlockHeight(double surfaceHeight) {
  if (surfaceHeight.isInfinite || surfaceHeight <= 0) return 480;
  return (surfaceHeight * 0.68).clamp(420.0, 560.0).toDouble();
}

class _HeroPhotoOverlay extends StatelessWidget {
  const _HeroPhotoOverlay({required this.profile, this.prompt});

  final PublicProfile profile;
  final PhotoPromptAnswer? prompt;

  @override
  Widget build(BuildContext context) {
    final photoPrompt = prompt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (photoPrompt != null) ...[
          _PhotoPromptOverlay(prompt: photoPrompt),
          gapH18,
        ],
        NameOverlay(profile: profile),
      ],
    );
  }
}

class _InsetProfilePhoto extends StatelessWidget {
  const _InsetProfilePhoto({
    required this.photo,
    required this.height,
    this.reactionTarget,
    this.onReact,
  });

  final ProfileCardPhoto photo;
  final double height;
  final ProfileReactionTarget? reactionTarget;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s4,
        CatchSpacing.s4,
        CatchSpacing.s2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        child: CardPhotoSection(
          url: photo.url,
          height: height,
          overlayChild: photo.prompt == null
              ? null
              : _PhotoPromptOverlay(prompt: photo.prompt!),
          reactionTarget: reactionTarget,
          onReact: onReact,
        ),
      ),
    );
  }
}

class _PhotoPromptOverlay extends StatelessWidget {
  const _PhotoPromptOverlay({required this.prompt});

  final PhotoPromptAnswer prompt;

  @override
  Widget build(BuildContext context) {
    return Text(
      prompt.displayPrompt,
      style: CatchTextStyles.cardTitle(context, color: Colors.white),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _RunningIdentityCard extends StatelessWidget {
  const _RunningIdentityCard({
    required this.profile,
    required this.running,
    required this.tags,
    this.reactionTarget,
    this.onReact,
  });

  final PublicProfile profile;
  final RunningPreferences running;
  final List<EmotionalRunTag> tags;
  final ProfileReactionTarget? reactionTarget;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return ProfileSectionCard(
      title: 'Running rhythm',
      reactionTarget: reactionTarget,
      onReact: onReact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_firstName(profile.name)} likes ${_formatRunMood(profile)}',
            style: CatchTextStyles.cardTitle(
              context,
              color: palette.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          gapH12,
          Row(
            children: [
              _RunStatPill(
                icon: Icons.speed_rounded,
                label: 'Pace',
                value: formatPaceRange(
                  running.paceMinSecsPerKm,
                  running.paceMaxSecsPerKm,
                ),
              ),
              gapW8,
              _RunStatPill(
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: _formatDistanceSummary(running),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            gapH12,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final tag in tags) _EventIdentityTagPill(tag: tag),
              ],
            ),
          ],
          if (running.runningReasons.isNotEmpty) ...[
            gapH12,
            Text(
              running.runningReasons.map((r) => r.label).join(' · '),
              style: CatchTextStyles.bodyLead(
                context,
                color: palette.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _EventIdentityTagPill extends StatelessWidget {
  const _EventIdentityTagPill({required this.tag});

  final EmotionalRunTag tag;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: palette.chipFill,
      borderColor: palette.chipBorder,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_runTagIcon(tag.kind), size: 14, color: palette.textSecondary),
          gapW6,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              tag.label,
              style: CatchTextStyles.labelL(
                context,
                color: palette.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunStatPill extends StatelessWidget {
  const _RunStatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return Expanded(
      child: CatchSurface(
        radius: CatchRadius.md,
        backgroundColor: palette.surfaceRaised,
        borderColor: palette.chipBorder,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: palette.textSecondary),
            gapH8,
            Text(
              label,
              style: CatchTextStyles.statusLabel(
                context,
                color: palette.textMuted,
              ),
            ),
            gapH2,
            Text(
              value,
              style: CatchTextStyles.statCompact(
                context,
                color: palette.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDistanceSummary(RunningPreferences running) {
  if (running.preferredDistances.isEmpty) return 'Any event';
  return running.preferredDistances.map((d) => d.label).take(2).join(', ');
}

String _formatRunMood(PublicProfile profile) {
  final running = profile.activityPreferences.running;
  if (running.runningReasons.isEmpty) return 'easy miles';
  final firstReason = running.runningReasons.first.label.toLowerCase();
  if (firstReason.startsWith('stay')) return 'feel-good miles';
  return firstReason;
}

ProfileReactionTarget _reactionTarget({
  required String id,
  required SwipeReactionTargetType type,
  required String label,
  required String preview,
}) {
  return ProfileReactionTarget(
    id: id,
    type: type,
    label: label,
    preview: _truncateReactionPreview(preview),
  );
}

String _runningReactionPreview(PublicProfile profile) {
  final running = profile.activityPreferences.running;
  final pace = formatPaceRange(
    running.paceMinSecsPerKm,
    running.paceMaxSecsPerKm,
  );
  final distance = _formatDistanceSummary(running);
  final reasons = running.runningReasons.map((r) => r.label).join(' · ');
  final runTimes = running.preferredRunTimes.map((t) => t.label).join(' · ');
  return [
    'Pace $pace',
    'Distance $distance',
    if (reasons.isNotEmpty) reasons,
    if (runTimes.isNotEmpty) runTimes,
  ].join(' · ');
}

String _photoReactionPreview({
  required PublicProfile profile,
  required String ordinalLabel,
  required PhotoPromptAnswer? prompt,
}) {
  final photoPrompt = prompt?.displayPrompt.trim();
  if (photoPrompt != null && photoPrompt.isNotEmpty) return photoPrompt;
  return '${profile.name}\'s $ordinalLabel';
}

String _insightReactionPreview(ProfileCardContent content) {
  final signals = content.insights.confidenceSignals.map(
    (signal) => signal.label,
  );
  final reasons = content.insights.compatibilityReasons.map(
    (reason) => reason.label,
  );
  return [...signals, ...reasons].join(' · ');
}

String _factsPreview(List<ProfileCardFact> facts) {
  return facts.map((fact) => fact.text).join(' · ');
}

IconData _runTagIcon(EmotionalRunTagKind kind) {
  return switch (kind) {
    EmotionalRunTagKind.morningRegular => Icons.wb_sunny_outlined,
    EmotionalRunTagKind.eveningRunner => Icons.nights_stay_outlined,
    EmotionalRunTagKind.middayMiles => Icons.light_mode_outlined,
    EmotionalRunTagKind.easyMiles => Icons.self_improvement_rounded,
    EmotionalRunTagKind.tempoEnergy => Icons.bolt_rounded,
    EmotionalRunTagKind.flexiblePace => Icons.swap_horiz_rounded,
    EmotionalRunTagKind.fiveKRegular => Icons.looks_5_rounded,
    EmotionalRunTagKind.tenKReady => Icons.filter_9_plus_rounded,
    EmotionalRunTagKind.longRunPerson => Icons.route_rounded,
    EmotionalRunTagKind.socialMiles => Icons.groups_2_outlined,
    EmotionalRunTagKind.headspaceRunner => Icons.spa_outlined,
    EmotionalRunTagKind.trainingEnergy => Icons.flag_outlined,
    EmotionalRunTagKind.feelGoodMiles => Icons.favorite_border_rounded,
  };
}

String _truncateReactionPreview(String value) {
  const maxPreviewLength = 180;
  final trimmed = value.trim();
  if (trimmed.length <= maxPreviewLength) return trimmed;
  return '${trimmed.substring(0, maxPreviewLength - 1)}…';
}

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'They';
  return trimmed.split(RegExp(r'\s+')).first;
}
