import 'package:catch_dating_app/auth/data/auth_repository.dart'
    show uidProvider;
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_person_polaroid.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/cross_paths/data/cross_paths_repository.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_invitation.dart';
import 'package:catch_dating_app/cross_paths/presentation/cross_paths_invitation_controller.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CrossPathsInvitationScreen extends ConsumerWidget {
  const CrossPathsInvitationScreen({super.key, required this.invitationId});

  final String invitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationAsync = ref.watch(
      watchCrossPathsInvitationProvider(invitationId),
    );
    return Scaffold(
      appBar: CatchTopBar(
        title: context.l10n.crossPathsInvitationScreenTitle,
        leadingType: CatchTopBarLeading.back,
      ),
      body: invitationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => CatchErrorState.fromError(
          error,
          context: AppErrorContext.explore,
          onRetry: () =>
              ref.invalidate(watchCrossPathsInvitationProvider(invitationId)),
        ),
        data: (invitation) => invitation == null
            ? CatchErrorState(
                title: context.l10n.crossPathsInvitationScreenUnavailableTitle,
                message: context.l10n.crossPathsInvitationScreenUnavailableBody,
                secondaryAction: const CatchErrorBackAction(),
              )
            : _InvitationDetail(invitation: invitation),
      ),
    );
  }
}

class _InvitationDetail extends ConsumerWidget {
  const _InvitationDetail({required this.invitation});

  final CrossPathsInvitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null || !invitation.participantIds.contains(uid)) {
      return CatchErrorState(
        title: context.l10n.crossPathsInvitationScreenUnavailableTitle,
        message: context.l10n.crossPathsInvitationScreenUnavailableBody,
        secondaryAction: const CatchErrorBackAction(),
      );
    }
    final otherUid = invitation.senderUid == uid
        ? invitation.recipientUid
        : invitation.senderUid;
    final profileAsync = ref.watch(watchPublicProfileProvider(otherUid));
    final eventAsync = ref.watch(watchEventProvider(invitation.eventId));
    if (profileAsync.isLoading || eventAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profileAsync.hasError || eventAsync.hasError) {
      return CatchErrorState.fromError(
        profileAsync.error ?? eventAsync.error!,
        context: AppErrorContext.explore,
        onRetry: () {
          ref.invalidate(watchPublicProfileProvider(otherUid));
          ref.invalidate(watchEventProvider(invitation.eventId));
        },
      );
    }
    final profile = profileAsync.value;
    final event = eventAsync.value;
    if (profile == null || event == null) {
      return CatchErrorState(
        title: context.l10n.crossPathsInvitationScreenUnavailableTitle,
        message: context.l10n.crossPathsInvitationScreenUnavailableBody,
        secondaryAction: const CatchErrorBackAction(),
      );
    }
    return _InvitationDetailBody(
      invitation: invitation,
      profile: profile,
      event: event,
      currentUid: uid,
    );
  }
}

class _InvitationDetailBody extends ConsumerWidget {
  const _InvitationDetailBody({
    required this.invitation,
    required this.profile,
    required this.event,
    required this.currentUid,
  });

  final CrossPathsInvitation invitation;
  final PublicProfile profile;
  final Event event;
  final String currentUid;

  bool get isRecipient => invitation.recipientUid == currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final mutation = ref.watch(crossPathsInvitationControllerProvider);
    final photo = profile.primaryPhotoThumbnailUrl;
    return ListView(
      padding: CatchInsets.pageBody,
      children: [
        CatchPersonPolaroid(
          media: photo == null
              ? CatchNetworkImageFallback(icon: CatchIcons.personOutlined)
              : CatchNetworkImage(photo),
          kicker: context.l10n.crossPathsExploreCardLabelCrossPaths,
          name: '${profile.name}, ${profile.age}',
          meta: _statusCopy(context),
          showArrow: true,
          onTap: () => context.pushNamed(
            Routes.publicProfileScreen.name,
            pathParameters: {'uid': profile.uid},
            extra: profile,
          ),
        ),
        gapH16,
        CatchSurface.card(
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: CatchTextStyles.sectionTitle(context)),
              gapH4,
              Text(
                '${EventFormatters.shortDate(event.startTime)} · '
                '${EventFormatters.time(event.startTime)} · '
                '${event.meetingPoint}',
                style: CatchTextStyles.bodyM(context, color: t.ink2),
              ),
            ],
          ),
        ),
        gapH16,
        ..._actions(context, ref, mutation.isLoading),
      ],
    );
  }

  String _statusCopy(BuildContext context) => switch (invitation.status) {
    CrossPathsInvitationStatus.pending =>
      isRecipient
          ? context.l10n.crossPathsInvitationScreenIncomingBody
          : context.l10n.crossPathsInvitationScreenOutgoingBody,
    CrossPathsInvitationStatus.accepted =>
      context.l10n.crossPathsInvitationScreenAcceptedBody,
    _ => context.l10n.crossPathsInvitationStatusClosed,
  };

  List<Widget> _actions(BuildContext context, WidgetRef ref, bool loading) {
    if (invitation.status == CrossPathsInvitationStatus.pending &&
        isRecipient) {
      return [
        CatchButton(
          label: context.l10n.crossPathsInvitationScreenActionAccept,
          fullWidth: true,
          isLoading: loading,
          onPressed: () => _respond(context, ref, accept: true),
        ),
        gapH10,
        CatchButton(
          label: context.l10n.crossPathsInvitationScreenActionDecline,
          fullWidth: true,
          variant: CatchButtonVariant.secondary,
          onPressed: loading
              ? null
              : () => _respond(context, ref, accept: false),
        ),
      ];
    }
    if (invitation.status == CrossPathsInvitationStatus.pending) {
      return [
        CatchButton(
          label: context.l10n.crossPathsInvitationActionCancel,
          fullWidth: true,
          isLoading: loading,
          variant: CatchButtonVariant.secondary,
          onPressed: () => _cancel(context, ref),
        ),
      ];
    }
    if (invitation.status == CrossPathsInvitationStatus.accepted) {
      return [
        CatchButton(
          label: context.l10n.crossPathsInvitationActionOpenPlan,
          fullWidth: true,
          onPressed: invitation.conversationId == null
              ? null
              : () => context.pushNamed(
                  Routes.chatScreen.name,
                  pathParameters: {'matchId': invitation.conversationId!},
                ),
        ),
        gapH10,
        CatchButton(
          label: context.l10n.crossPathsInvitationScreenActionCancelPlan,
          fullWidth: true,
          variant: CatchButtonVariant.secondary,
          isLoading: loading,
          onPressed: () => _cancel(context, ref),
        ),
      ];
    }
    return const [];
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref, {
    required bool accept,
  }) async {
    try {
      final receipt = await ref
          .read(crossPathsInvitationControllerProvider.notifier)
          .respond(invitationId: invitation.id, accept: accept);
      ref
          .read(appAnalyticsProvider)
          .logEvent(
            accept
                ? AnalyticsEvents.crossPathsInvitationAccepted
                : AnalyticsEvents.crossPathsInvitationDeclined,
            parameters: {AnalyticsParameters.eventId: invitation.eventId},
          );
      if (context.mounted && accept && receipt.conversationId != null) {
        context.goNamed(
          Routes.chatScreen.name,
          pathParameters: {'matchId': receipt.conversationId!},
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

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(crossPathsInvitationControllerProvider.notifier)
          .cancel(invitation.id);
      ref
          .read(appAnalyticsProvider)
          .logEvent(
            AnalyticsEvents.crossPathsInvitationCancelled,
            parameters: {AnalyticsParameters.eventId: invitation.eventId},
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
