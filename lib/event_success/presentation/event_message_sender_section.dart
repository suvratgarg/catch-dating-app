import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/event_success/domain/event_sender_preference.dart';
import 'package:catch_dating_app/event_success/presentation/event_message_channel_disclosure.dart';
import 'package:catch_dating_app/event_success/presentation/event_message_preference_section.dart';
import 'package:catch_dating_app/event_success/presentation/event_sender_preference_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventMessageSenderSection extends ConsumerWidget {
  const EventMessageSenderSection({super.key, required this.scope});
  final EventSenderPreferenceScope scope;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = eventSenderPreferenceControllerProvider(scope);
    final state = ref.watch(provider);
    final owner = ref.read(provider.notifier);
    final l = context.l10n;
    final channel = switch (scope.channel) {
      EventSenderChannel.whatsapp => EventMessageChannel.whatsapp,
      EventSenderChannel.rcs => EventMessageChannel.rcs,
    };
    void run(Future<Object?> Function() action) =>
        runEventMessageAction(context, action);
    final Widget child;
    final String summary;
    var pending = false;
    switch (state) {
      case EventSenderPreferenceLoading():
        summary = l.eventMessagesLoading;
        child = const CatchSkeleton.rows();
      case EventSenderPreferenceHidden():
        summary = l.eventMessagesUnavailable;
        child = CatchButton(
          label: l.eventMessagesRefresh,
          variant: CatchButtonVariant.ghost,
          onPressed: () => run(owner.refresh),
        );
      case EventSenderPreferenceFailure(:final error):
        summary = l.eventMessagesLoadFailed;
        child = CatchLocalizedErrorBanner(
          error,
          onRetry: () => run(owner.refresh),
        );
      case EventSenderPreferenceReady():
        final review = state.review;
        final navigation = _SenderNavigation(state: state, owner: owner);
        if (review == null) {
          summary = l.eventMessagesMorePermissions;
          child = navigation;
          break;
        }
        final view = review.view;
        final permission = switch (view.preference) {
          EventSenderPreference.notSet => EventMessagePermission.notSet,
          EventSenderPreference.enabled => EventMessagePermission.enabled,
          EventSenderPreference.disabled => EventMessagePermission.disabled,
          EventSenderPreference.expired => EventMessagePermission.expired,
        };
        pending =
            state.phase == EventSenderPreferencePhase.saving ||
            state.phase == EventSenderPreferencePhase.uncertain;
        summary = pending
            ? l.eventMessagesPending
            : eventMessagePermissionLabel(context, permission);
        child = EventMessagePreferenceSection(
          channel: channel,
          permission: permission,
          availability: switch (view.availability) {
            EventSenderAvailability.ready => EventMessageAvailability.ready,
            EventSenderAvailability.verifyPhone =>
              EventMessageAvailability.verifyPhone,
            EventSenderAvailability.notAdmitted =>
              EventMessageAvailability.notAdmitted,
            EventSenderAvailability.eventClosed =>
              EventMessageAvailability.eventClosed,
            EventSenderAvailability.senderUnavailable =>
              EventMessageAvailability.senderUnavailable,
            EventSenderAvailability.subscriptionUnavailable =>
              EventMessageAvailability.subscriptionUnavailable,
          },
          phase: switch (state.phase) {
            EventSenderPreferencePhase.ready => EventMessageSavePhase.ready,
            EventSenderPreferencePhase.saving => EventMessageSavePhase.saving,
            EventSenderPreferencePhase.uncertain =>
              EventMessageSavePhase.uncertain,
            EventSenderPreferencePhase.refreshRequired =>
              EventMessageSavePhase.refreshRequired,
          },
          notice: switch (state.notice) {
            EventSenderPreferenceNotice.none => EventMessageSaveNotice.none,
            EventSenderPreferenceNotice.saved => EventMessageSaveNotice.saved,
            EventSenderPreferenceNotice.changed =>
              EventMessageSaveNotice.changed,
          },
          consentText: view.consentText,
          senderName: view.senderDisplayName,
          senderPhone: switch (view) {
            EventWhatsappPreferenceView(:final sender) =>
              sender?.displayPhoneNumber,
            EventRcsPreferenceView() => null,
          },
          phoneLastFour: view.phoneLastFour,
          expiresAt: view.expiresAt,
          earlierSender: state.navigation.isEarlier,
          error: state.error,
          navigation: navigation,
          onEnable: state.canEnable
              ? () => run(() => owner.enable(review))
              : null,
          onDisable: state.canDisable
              ? () => run(() => owner.disable(review))
              : null,
          onRetry: state.canRetry ? () => run(() => owner.retry(review)) : null,
          onRefresh: state.canRefresh ? () => run(owner.refresh) : null,
        );
    }
    return EventMessageChannelDisclosure(
      channel: channel,
      summary: summary,
      pending: pending,
      child: child,
    );
  }
}

/// Visits server-selected permissions without treating opaque IDs as names or
/// claiming their stable cursor order is chronological.
class _SenderNavigation extends StatelessWidget {
  const _SenderNavigation({required this.state, required this.owner});
  final EventSenderPreferenceReady state;
  final EventSenderPreferenceController owner;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final nav = state.navigation;
    final ids = nav.previousSenderIds;
    final index = ids.indexOf(nav.selectedSenderId ?? '');
    void choose(String id) =>
        runEventMessageAction(context, () => owner.choose(nav, id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (nav.isEarlier && nav.configuredSenderId != null)
          CatchButton(
            label: l.eventMessagesCurrentSender,
            variant: CatchButtonVariant.secondary,
            onPressed: state.canNavigate
                ? () => choose(nav.configuredSenderId!)
                : null,
          ),
        if (ids.isNotEmpty && !nav.isEarlier)
          CatchButton(
            label: l.eventMessagesOtherSenders,
            variant: CatchButtonVariant.secondary,
            onPressed: state.canNavigate ? () => choose(ids.first) : null,
          ),
        if (nav.isEarlier)
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              if (index > 0)
                CatchButton(
                  label: l.eventMessagesPreviousPermission,
                  variant: CatchButtonVariant.secondary,
                  onPressed: state.canNavigate
                      ? () => choose(ids[index - 1])
                      : null,
                ),
              if (index >= 0 && index + 1 < ids.length)
                CatchButton(
                  label: l.eventMessagesNextPermission,
                  variant: CatchButtonVariant.secondary,
                  onPressed: state.canNavigate
                      ? () => choose(ids[index + 1])
                      : null,
                ),
            ],
          ),
        if (nav.canLoadMore)
          CatchButton(
            label: l.eventMessagesMorePermissions,
            variant: CatchButtonVariant.ghost,
            onPressed: state.canNavigate
                ? () =>
                      runEventMessageAction(context, () => owner.loadMore(nav))
                : null,
          ),
      ],
    );
  }
}
