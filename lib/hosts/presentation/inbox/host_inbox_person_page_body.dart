import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_catch_pages_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_people.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_whatsapp_pages_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_person_conversation_page_body.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_reply_drafts.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostInboxPersonPageBody extends ConsumerWidget {
  const HostInboxPersonPageBody({
    super.key,
    required this.organizerId,
    required this.selection,
    required this.scope,
    required this.now,
    required this.segment,
    required this.drafts,
    required this.onBack,
  });
  final String organizerId;
  final String selection;
  final HostInboxScope? scope;
  final DateTime now;
  final HostInboxAudienceSegment segment;
  final HostReplyDrafts drafts;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = catchAsyncStateFromAsyncValue(
      ref.watch(watchEventsForClubProvider(organizerId)),
    );
    final waitingForScope = this.scope == null && !events.hasData;
    final scope = events.value == null
        ? this.scope ?? const HostInboxScope.general()
        : resolveHostInboxScope(
            events: events.value!,
            now: now,
            requestedScope: this.scope,
          );
    final inbox = catchAsyncStateFromAsyncValue(
      ref.watch(hostInboxCatchViewModelProvider),
    );
    final whatsapp = catchAsyncStateFromAsyncValue(
      ref.watch(hostInboxWhatsappPagesProvider(organizerId)),
    );
    final participations = scope.eventId == null
        ? null
        : catchAsyncStateFromAsyncValue(
            ref.watch(watchEventParticipationsForEventProvider(scope.eventId!)),
          ).value;
    final people = composeHostInboxPeople(
      organizerId: organizerId,
      scope: scope,
      segment: segment,
      catchThreads: [
        ...?inbox.value?.newMatches,
        ...?inbox.value?.conversations,
      ],
      whatsappThreads: whatsapp.value?.threads ?? const [],
      participations: participations,
    );
    final person = people.people
        .where((p) => p.containsEndpoint(selection))
        .firstOrNull;
    if (person != null && !waitingForScope) {
      return HostPersonConversationPageBody(
        key: ValueKey('${person.key}/${scope.eventId ?? 'general'}'),
        person: person,
        scope: scope,
        scopeLabel: events.value
            ?.where((event) => event.id == scope.eventId)
            .firstOrNull
            ?.title,
        drafts: drafts,
        onBack: onBack,
      );
    }
    return Column(
      children: [
        CatchTopBar.route(
          title: context.l10n.hostInboxNewMessage,
          navigation: CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
            onPressed: onBack,
          ),
        ),
        Expanded(
          child: waitingForScope && events.hasError
              ? CatchLocalizedErrorState(
                  events.error!,
                  onRetry: () =>
                      ref.invalidate(watchEventsForClubProvider(organizerId)),
                )
              : waitingForScope || inbox.isLoading || whatsapp.isLoading
              ? const CatchStateViewport.loading()
              : CatchEmptyState(
                  icon: CatchIcons.chatBubbleOutlineRounded,
                  title: context.l10n.hostInboxSelectionUnavailable,
                ),
        ),
      ],
    );
  }
}
