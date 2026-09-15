import 'dart:async';

import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/event_success/domain/event_participant_context.dart';
import 'package:catch_dating_app/event_success/domain/event_sender_preference.dart';
import 'package:catch_dating_app/event_success/presentation/event_message_sender_section.dart';
import 'package:catch_dating_app/event_success/presentation/event_participant_context_provider.dart';
import 'package:catch_dating_app/event_success/presentation/event_sender_preference_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves only the signed-in attendee. Opening this sheet cannot enroll a
/// phone or choose an attendee, and refresh never carries an old identity.
class EventMessagePreferencesSheet extends ConsumerStatefulWidget {
  const EventMessagePreferencesSheet({super.key, required this.eventId});
  final String eventId;
  @override
  ConsumerState<EventMessagePreferencesSheet> createState() =>
      _EventMessagePreferencesSheetState();
}

class _EventMessagePreferencesSheetState
    extends ConsumerState<EventMessagePreferencesSheet>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final query = eventParticipantContextReaderProvider(widget.eventId);
    final review = ref.read(query).asData?.value;
    final identity = review?.isCurrent == true ? review!.view.identity : null;
    if (identity case EventParticipantLinked(:final scope)) {
      for (final channel in EventSenderChannel.values) {
        final sender = eventSenderPreferenceControllerProvider(
          EventSenderPreferenceScope(
            channel: channel,
            eventId: scope.eventId,
            attendeeId: scope.attendeeId,
          ),
        );
        if (ref.exists(sender)) unawaited(ref.read(sender.notifier).refresh());
      }
    }
    // Loading hides the old identity. Channel owners preserve uncertain writes
    // and refresh only when they do not have a request awaiting confirmation.
    ref.read(query.notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    final query = eventParticipantContextReaderProvider(widget.eventId);
    final page = ref.watch(query);
    final l = context.l10n;
    void reload() => ref.read(query.notifier).reload();
    return CatchSheet(
      title: l.eventMessagesTitle,
      mode: CatchSheetMode.scrollable,
      child: CatchAsyncBoundary<EventParticipantContextReview>(
        value: page,
        retainDataOn: const {},
        onRetry: reload,
        errorBuilder: (_, error, _, retry) =>
            CatchLocalizedErrorBanner(error, onRetry: retry),
        builder: (_, review) {
          final identity = review.view.identity;
          if (!review.isCurrent) return const CatchSkeleton.rows();
          return switch (identity) {
            EventParticipantUnlinked() => _IdentityUnavailable(
              message: l.eventMessagesUnlinked,
              onRetry: reload,
            ),
            EventParticipantAmbiguous() => _IdentityUnavailable(
              message: l.eventMessagesAmbiguous,
              onRetry: reload,
            ),
            EventParticipantLinked(:final scope) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.eventMessagesIntro,
                  style: CatchTextStyles.supporting(context),
                ),
                gapH16,
                CatchSection.fieldRows(
                  children: [
                    for (final channel in EventSenderChannel.values)
                      EventMessageSenderSection(
                        key: ValueKey('messages.${channel.name}'),
                        scope: EventSenderPreferenceScope(
                          channel: channel,
                          eventId: scope.eventId,
                          attendeeId: scope.attendeeId,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}

class _IdentityUnavailable extends StatelessWidget {
  const _IdentityUnavailable({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(message, style: CatchTextStyles.supporting(context)),
      gapH12,
      CatchButton(
        label: context.l10n.eventMessagesRefresh,
        variant: CatchButtonVariant.secondary,
        onPressed: onRetry,
      ),
    ],
  );
}
