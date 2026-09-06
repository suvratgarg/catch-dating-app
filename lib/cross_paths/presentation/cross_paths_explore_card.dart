import 'package:catch_dating_app/auth/data/auth_repository.dart'
    show uidProvider;
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_person_polaroid.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/cross_paths/data/cross_paths_repository.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_invitation.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_suggestion.dart';
import 'package:catch_dating_app/cross_paths/presentation/cross_paths_invitation_controller.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CrossPathsExploreCard extends StatefulWidget {
  const CrossPathsExploreCard({
    super.key,
    required this.suggestion,
    required this.event,
    this.onProfileSelected,
    this.onEventSelected,
    this.onImpression,
  });

  final CrossPathsSuggestion suggestion;
  final Event event;
  final VoidCallback? onProfileSelected;
  final VoidCallback? onEventSelected;
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
          event: widget.event,
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
    required this.event,
    this.onEventSelected,
    this.compact = false,
  });

  final CrossPathsSuggestion suggestion;
  final Event event;
  final VoidCallback? onEventSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
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
            onPressed: onEventSelected,
          ),
        ],
      ),
    );
  }
}

Future<void> showCrossPathsProfilePreview({
  required BuildContext context,
  required CrossPathsSuggestion suggestion,
  required Event event,
  required VoidCallback onEventSelected,
  ValueChanged<String>? onPlanSelected,
}) {
  return showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => CrossPathsProfilePreviewSheet(
      suggestion: suggestion,
      event: event,
      onEventSelected: () {
        Navigator.of(sheetContext).pop();
        onEventSelected();
      },
      onPlanSelected: onPlanSelected,
    ),
  );
}

class CrossPathsProfilePreviewSheet extends ConsumerWidget {
  const CrossPathsProfilePreviewSheet({
    super.key,
    required this.suggestion,
    required this.event,
    required this.onEventSelected,
    this.onPlanSelected,
  });

  final CrossPathsSuggestion suggestion;
  final Event event;
  final VoidCallback onEventSelected;
  final ValueChanged<String>? onPlanSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    final invitationAsync = uid == null
        ? const AsyncValue<CrossPathsInvitation?>.data(null)
        : ref.watch(
            watchOutgoingCrossPathsInvitationProvider(
              uid,
              suggestion.event.eventId,
            ),
          );
    final invitation = invitationAsync.asData?.value;
    final mutation = ref.watch(crossPathsInvitationControllerProvider);
    final invitationController = ref.read(
      crossPathsInvitationControllerProvider.notifier,
    );
    final analytics = ref.read(appAnalyticsProvider);
    final pairInvitationEnabled = suggestion.event.pairHoldAvailable;
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (invitation?.status ==
                        CrossPathsInvitationStatus.pending) ...[
                      Text(
                        context.l10n.crossPathsInvitationStatusPending,
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      gapH8,
                    ],
                    CatchButton(
                      key: const ValueKey('cross-paths-invitation-action'),
                      label: _invitationActionLabel(
                        context,
                        invitation,
                        pairInvitationEnabled: pairInvitationEnabled,
                      ),
                      icon: Icon(
                        invitation?.status ==
                                CrossPathsInvitationStatus.accepted
                            ? CatchIcons.chatBubbleOutlineRounded
                            : CatchIcons.favoriteOutline,
                        size: CatchIcon.sm,
                      ),
                      fullWidth: true,
                      isLoading: mutation.isLoading,
                      variant:
                          invitation?.status ==
                              CrossPathsInvitationStatus.pending
                          ? CatchButtonVariant.secondary
                          : CatchButtonVariant.primary,
                      onPressed: _invitationAction(
                        context,
                        invitationController,
                        analytics,
                        invitationAsync,
                        invitation,
                        pairInvitationEnabled: pairInvitationEnabled,
                      ),
                    ),
                    gapH10,
                    CrossPathsEventContextCard(
                      suggestion: suggestion,
                      event: event,
                      onEventSelected: onEventSelected,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _invitationActionLabel(
    BuildContext context,
    CrossPathsInvitation? invitation, {
    required bool pairInvitationEnabled,
  }) {
    if (!suggestion.viewerIsBooked && !pairInvitationEnabled) {
      return context.l10n.crossPathsInvitationActionJoinFirst;
    }
    if (!suggestion.viewerIsBooked && invitation == null) {
      return context.l10n.crossPathsPairInventoryActionAskTogether;
    }
    return switch (invitation?.status) {
      null => context.l10n.crossPathsInvitationActionSend,
      CrossPathsInvitationStatus.pending =>
        context.l10n.crossPathsInvitationActionCancel,
      CrossPathsInvitationStatus.accepted =>
        context.l10n.crossPathsInvitationActionOpenPlan,
      _ => context.l10n.crossPathsInvitationStatusClosed,
    };
  }

  VoidCallback? _invitationAction(
    BuildContext context,
    CrossPathsInvitationController invitationController,
    AppAnalytics analytics,
    AsyncValue<CrossPathsInvitation?> invitationAsync,
    CrossPathsInvitation? invitation, {
    required bool pairInvitationEnabled,
  }) {
    if (!suggestion.viewerIsBooked && !pairInvitationEnabled) {
      return onEventSelected;
    }
    if (!invitationAsync.hasValue) return null;
    return switch (invitation?.status) {
      null => () => _sendInvitation(context, invitationController, analytics),
      CrossPathsInvitationStatus.pending => () => _cancelInvitation(
        context,
        invitationController,
        analytics,
        invitation!.id,
      ),
      CrossPathsInvitationStatus.accepted =>
        invitation?.conversationId != null && onPlanSelected != null
            ? () => onPlanSelected!(invitation!.conversationId!)
            : invitation?.pairHoldId != null
            ? () => context.pushNamed(
                Routes.crossPathsInvitationScreen.name,
                pathParameters: {'invitationId': invitation!.id},
              )
            : null,
      _ => null,
    };
  }

  Future<void> _sendInvitation(
    BuildContext context,
    CrossPathsInvitationController invitationController,
    AppAnalytics analytics,
  ) async {
    final firstName = crossPathsFirstName(suggestion.profile.name);
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.crossPathsInvitationConfirmTitle(
        firstName: firstName,
      ),
      message: context.l10n.crossPathsInvitationConfirmBody,
      confirmLabel: context.l10n.crossPathsInvitationConfirmAction,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await invitationController.send(
        eventId: suggestion.event.eventId,
        recipientUid: suggestion.profile.uid,
        suggestionToken: suggestion.suggestionToken,
      );
      analytics.logEvent(
        AnalyticsEvents.crossPathsInvitationSent,
        parameters: {
          AnalyticsParameters.eventId: suggestion.event.eventId,
          AnalyticsParameters.surface: 'explore_profile',
        },
      );
      if (context.mounted) {
        showCatchSnackBar(
          context,
          context.l10n.crossPathsInvitationSentMessage,
        );
      }
    } catch (error) {
      if (context.mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.explore,
        );
      }
    }
  }

  Future<void> _cancelInvitation(
    BuildContext context,
    CrossPathsInvitationController invitationController,
    AppAnalytics analytics,
    String invitationId,
  ) async {
    try {
      await invitationController.cancel(invitationId);
      analytics.logEvent(
        AnalyticsEvents.crossPathsInvitationCancelled,
        parameters: {
          AnalyticsParameters.eventId: suggestion.event.eventId,
          AnalyticsParameters.surface: 'explore_profile',
        },
      );
    } catch (error) {
      if (context.mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.explore,
        );
      }
    }
  }
}

String crossPathsFirstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return name;
  return trimmed.split(RegExp(r'\s+')).first;
}
