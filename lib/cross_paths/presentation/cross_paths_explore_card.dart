import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_person_polaroid.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_suggestion.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:flutter/material.dart';

typedef CrossPathsEventSelected = void Function(ExploreEventItem item);
typedef CrossPathsProfileSelected =
    void Function(CrossPathsSuggestion suggestion, ExploreEventItem eventItem);
typedef CrossPathsImpression =
    void Function(
      CrossPathsSuggestion suggestion,
      ExploreEventItem eventItem,
      int position,
    );

class CrossPathsExploreCard extends StatefulWidget {
  const CrossPathsExploreCard({
    super.key,
    required this.suggestion,
    required this.eventItem,
    this.onProfileSelected,
    this.onEventSelected,
    this.onImpression,
  });

  final CrossPathsSuggestion suggestion;
  final ExploreEventItem eventItem;
  final VoidCallback? onProfileSelected;
  final CrossPathsEventSelected? onEventSelected;
  final VoidCallback? onImpression;

  @override
  State<CrossPathsExploreCard> createState() => _CrossPathsExploreCardState();
}

class _CrossPathsExploreCardState extends State<CrossPathsExploreCard> {
  String? _reportedImpressionKey;

  @override
  void initState() {
    super.initState();
    _scheduleImpression();
  }

  @override
  void didUpdateWidget(covariant CrossPathsExploreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestion.suggestionToken !=
            widget.suggestion.suggestionToken ||
        oldWidget.onImpression != widget.onImpression) {
      _scheduleImpression();
    }
  }

  void _scheduleImpression() {
    final impressionKey = widget.suggestion.suggestionToken;
    if (widget.onImpression == null ||
        _reportedImpressionKey == impressionKey) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.onImpression == null ||
          _reportedImpressionKey == widget.suggestion.suggestionToken) {
        return;
      }
      _reportedImpressionKey = widget.suggestion.suggestionToken;
      widget.onImpression!();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final suggestion = widget.suggestion;
    final profile = suggestion.profile;
    final firstName = crossPathsFirstName(profile.name);
    final profileSemantics = context.l10n
        .crossPathsExploreCardSemanticsViewProfile(firstName: firstName);
    final primaryPhotoUrl = profile.primaryPhotoThumbnailUrl;

    return Column(
      key: ValueKey('cross-paths-card-${profile.uid}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchMonoLabel(
          context.l10n.crossPathsExploreCardLabelPeopleYouCouldMeet,
          color: t.ink3,
          uppercase: true,
        ),
        gapH8,
        Semantics(
          button: widget.onProfileSelected != null,
          label: profileSemantics,
          onTap: widget.onProfileSelected,
          child: ExcludeSemantics(
            child: CatchPersonPolaroid(
              onTap: widget.onProfileSelected,
              showArrow: true,
              media: primaryPhotoUrl == null
                  ? CatchNetworkImageFallback(icon: CatchIcons.personOutlined)
                  : CatchNetworkImage(primaryPhotoUrl),
              kicker: context.l10n.crossPathsExploreCardLabelCrossPaths,
              name: '$firstName, ${profile.age}',
              meta:
                  context.l10n.crossPathsExploreCardReasonCompatibleAtThisEvent,
            ),
          ),
        ),
        gapH10,
        CrossPathsEventContextCard(
          suggestion: suggestion,
          eventItem: widget.eventItem,
          onEventSelected: widget.onEventSelected,
        ),
      ],
    );
  }
}

class CrossPathsEventContextCard extends StatelessWidget {
  const CrossPathsEventContextCard({
    super.key,
    required this.suggestion,
    required this.eventItem,
    this.onEventSelected,
    this.compact = false,
  });

  final CrossPathsSuggestion suggestion;
  final ExploreEventItem eventItem;
  final CrossPathsEventSelected? onEventSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final event = eventItem.event;
    final firstName = crossPathsFirstName(suggestion.profile.name);
    final visual = eventActivityVisual(event.activityKind, context: context);
    final dateTimeLabel = context.l10n.crossPathsExploreCardEventDateTime(
      date: EventFormatters.shortDate(event.startTime),
      time: EventFormatters.time(event.startTime),
    );
    return CatchSurface.card(
      borderColor: t.line2,
      padding: compact ? CatchInsets.tileContentCompact : CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventActivityStamp(
                visual: visual,
                size: compact ? 30 : 38,
                iconSize: CatchIcon.sm,
              ),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n
                          .crossPathsExploreCardContextPersonGoingToEvent(
                            firstName: firstName,
                            eventTitle: event.title,
                          ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: t.ink,
                      ),
                    ),
                    gapH4,
                    Text(
                      dateTimeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.mono(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapH10,
          CatchButton(
            label: context.l10n.crossPathsExploreCardActionSeeEvent,
            icon: Icon(CatchIcons.forwardArrow, size: CatchIcon.sm),
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
            fullWidth: true,
            onPressed: onEventSelected == null
                ? null
                : () => onEventSelected!(eventItem),
          ),
        ],
      ),
    );
  }
}

Future<void> showCrossPathsProfilePreview({
  required BuildContext context,
  required CrossPathsSuggestion suggestion,
  required ExploreEventItem eventItem,
  required CrossPathsEventSelected onEventSelected,
}) {
  return showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => CrossPathsProfilePreviewSheet(
      suggestion: suggestion,
      eventItem: eventItem,
      onEventSelected: (item) {
        Navigator.of(sheetContext).pop();
        onEventSelected(item);
      },
    ),
  );
}

class CrossPathsProfilePreviewSheet extends StatelessWidget {
  const CrossPathsProfilePreviewSheet({
    super.key,
    required this.suggestion,
    required this.eventItem,
    required this.onEventSelected,
  });

  final CrossPathsSuggestion suggestion;
  final ExploreEventItem eventItem;
  final CrossPathsEventSelected onEventSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return FractionallySizedBox(
      heightFactor: 0.94,
      child: CatchSurface(
        backgroundColor: t.bg,
        borderWidth: 0,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(CatchLayout.sheetTopRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Padding(
              padding: CatchInsets.pageHorizontal.copyWith(
                top: CatchSpacing.s2,
                bottom: CatchSpacing.s2,
              ),
              child: Column(
                children: [
                  const CatchBottomSheetGrabber(),
                  gapH8,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.crossPathsProfilePreviewTitle,
                          style: CatchTextStyles.titleL(context),
                        ),
                      ),
                      CatchIconButton.icon(
                        icon: CatchIcons.closeRounded,
                        variant: CatchIconButtonVariant.plain,
                        tooltip:
                            context.l10n.crossPathsProfilePreviewTooltipClose,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ProfileSurface(
                profile: suggestion.profile,
                mode: ProfileSurfaceMode.publicProfile,
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: CatchInsets.pageBody.copyWith(top: CatchSpacing.s2),
                child: CrossPathsEventContextCard(
                  suggestion: suggestion,
                  eventItem: eventItem,
                  onEventSelected: onEventSelected,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String crossPathsFirstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return name;
  return trimmed.split(RegExp(r'\s+')).first;
}
