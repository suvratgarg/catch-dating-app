import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/event_success/domain/event_sms_preference.dart';
import 'package:catch_dating_app/event_success/presentation/event_message_channel_disclosure.dart';
import 'package:catch_dating_app/event_success/presentation/event_message_preference_section.dart';
import 'package:catch_dating_app/event_success/presentation/event_sms_preference_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventMessageSmsSection extends ConsumerWidget {
  const EventMessageSmsSection({super.key, required this.scope});
  final EventSmsPreferenceScope scope;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = eventSmsPreferenceControllerProvider(scope);
    final state = ref.watch(provider);
    final owner = ref.read(provider.notifier);
    final l = context.l10n;
    void run(Future<Object?> Function() action) =>
        runEventMessageAction(context, action);
    final Widget child;
    final String summary;
    var pending = false;
    switch (state) {
      case EventSmsPreferenceLoading():
        summary = l.eventMessagesLoading;
        child = const CatchSkeleton.rows();
      case EventSmsPreferenceHidden():
        summary = l.eventMessagesUnavailable;
        child = CatchButton(
          label: l.eventMessagesRefresh,
          variant: CatchButtonVariant.ghost,
          onPressed: () => run(owner.refresh),
        );
      case EventSmsPreferenceFailure(:final error):
        summary = l.eventMessagesLoadFailed;
        child = CatchLocalizedErrorBanner(
          error,
          onRetry: () => run(owner.refresh),
        );
      case EventSmsPreferenceReady():
        final view = state.review.view;
        final permission = switch (view.preference) {
          EventSmsPreference.notSet => EventMessagePermission.notSet,
          EventSmsPreference.enabled => EventMessagePermission.enabled,
          EventSmsPreference.disabled => EventMessagePermission.disabled,
          EventSmsPreference.expired => EventMessagePermission.expired,
        };
        final phase = switch (state.phase) {
          EventSmsPreferencePhase.ready => EventMessageSavePhase.ready,
          EventSmsPreferencePhase.saving => EventMessageSavePhase.saving,
          EventSmsPreferencePhase.uncertain => EventMessageSavePhase.uncertain,
          EventSmsPreferencePhase.refreshRequired =>
            EventMessageSavePhase.refreshRequired,
        };
        pending =
            state.phase == EventSmsPreferencePhase.saving ||
            state.phase == EventSmsPreferencePhase.uncertain;
        summary = pending
            ? l.eventMessagesPending
            : eventMessagePermissionLabel(context, permission);
        child = EventMessagePreferenceSection(
          channel: EventMessageChannel.sms,
          permission: permission,
          availability: switch (view.availability) {
            EventSmsAvailability.ready => EventMessageAvailability.ready,
            EventSmsAvailability.verifyPhone =>
              EventMessageAvailability.verifyPhone,
            EventSmsAvailability.notAdmitted =>
              EventMessageAvailability.notAdmitted,
            EventSmsAvailability.eventClosed =>
              EventMessageAvailability.eventClosed,
            EventSmsAvailability.senderUnavailable =>
              EventMessageAvailability.senderUnavailable,
          },
          phase: phase,
          notice: switch (state.notice) {
            EventSmsPreferenceNotice.none => EventMessageSaveNotice.none,
            EventSmsPreferenceNotice.saved => EventMessageSaveNotice.saved,
            EventSmsPreferenceNotice.changed => EventMessageSaveNotice.changed,
          },
          consentText: view.consentText,
          phoneLastFour: view.phoneLastFour,
          expiresAt: view.expiresAt,
          error: state.error,
          onEnable: state.canEnable
              ? () => run(() => owner.enable(state.review))
              : null,
          onDisable: state.canDisable
              ? () => run(() => owner.disable(state.review))
              : null,
          onRetry: state.canRetry
              ? () => run(() => owner.retry(state.review))
              : null,
          onRefresh: state.canRefresh ? () => run(owner.refresh) : null,
        );
    }
    return EventMessageChannelDisclosure(
      channel: EventMessageChannel.sms,
      summary: summary,
      pending: pending,
      child: child,
    );
  }
}
