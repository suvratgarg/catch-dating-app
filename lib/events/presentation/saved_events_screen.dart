import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/saved_events_state.dart';
import 'package:catch_dating_app/events/shared/event_agenda_list.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SavedEventsScreen extends ConsumerWidget {
  const SavedEventsScreen({super.key, this.referenceNow});

  final DateTime? referenceNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final uidAsync = ref.watch(uidProvider);

    return CatchRouteScaffold(
      backgroundColor: t.bg,
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.eventsSavedEventsScreenTitleSavedEvents,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: CatchRouteBody.standardSlivers(
        slivers: [
          Consumer(
            builder: (context, ref, _) {
              if (uidAsync.isLoading) {
                return const EventAgendaSliverSkeleton(
                  padding: EdgeInsets.zero,
                );
              }
              if (uidAsync.hasError) {
                return CatchSliverErrorState.fromError(
                  uidAsync.error!,
                  context: AppErrorContext.auth,
                  onRetry: () => ref.invalidate(uidProvider),
                );
              }

              final userId = uidAsync.asData?.value;
              final savedEvents = userId == null
                  ? const AsyncData(<Event>[])
                  : ref.watch(watchSavedEventDetailsForUserProvider(userId));
              return CatchAsyncValueSliver<List<Event>>(
                value: savedEvents,
                onRetry: () {
                  ref.invalidate(uidProvider);
                  if (userId != null) {
                    ref.invalidate(
                      watchSavedEventDetailsForUserProvider(userId),
                    );
                  }
                },
                initialLoadTimeout: null,
                sliverLoadingBuilder: (_) =>
                    const EventAgendaSliverSkeleton(padding: EdgeInsets.zero),
                sliverErrorBuilder: (_, error, _) =>
                    SavedEventsClubNamesErrorSliver(
                      error: error,
                      onRetry: () {
                        if (userId != null) {
                          ref.invalidate(
                            watchSavedEventDetailsForUserProvider(userId),
                          );
                        }
                      },
                    ),
                builder: (context, events) {
                  if (events.isEmpty) {
                    return CatchSliverEmptyState(
                      icon: CatchIcons.bookmarkBorderRounded,
                      title: context
                          .l10n
                          .eventsSavedEventsScreenTitleNoSavedEventsYet,
                      message: context
                          .l10n
                          .eventsSavedEventsScreenMessageSaveEventsYouWant,
                      iconSize: CatchLayout.calendarEmptyIconSize,
                      padding: EdgeInsets.zero,
                      titleStyle: CatchTextStyles.titleL(context),
                      messageStyle: CatchTextStyles.proseM(
                        context,
                        color: CatchTokens.of(context).ink2,
                      ),
                    );
                  }

                  final state = SavedEventsListState.from(
                    events,
                    now: referenceNow ?? DateTime.now(),
                  );
                  final clubNames = ref.watch(
                    clubNameLookupProvider(ClubNameLookupQuery(state.clubIds)),
                  );
                  return CatchAsyncValueSliver<Map<String, String>>(
                    value: clubNames,
                    onRetry: () => ref.invalidate(clubNameLookupProvider),
                    sliverLoadingBuilder: (_) =>
                        const EventAgendaSliverSkeleton(
                          padding: EdgeInsets.zero,
                        ),
                    sliverErrorBuilder: (_, error, _) =>
                        SavedEventsClubNamesErrorSliver(
                          error: error,
                          onRetry: () => ref.invalidate(clubNameLookupProvider),
                        ),
                    builder: (context, names) => SavedEventsAgendaSliver(
                      state: state,
                      clubNames: names,
                      padding: EdgeInsets.zero,
                      onEventSelected: (event) =>
                          _openEventDetail(context, event),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _openEventDetail(BuildContext context, Event event) {
    context.pushNamed(
      Routes.savedEventDetailScreen.name,
      pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      extra: event,
    );
  }
}

class SavedEventsAgendaSliver extends StatelessWidget {
  const SavedEventsAgendaSliver({
    super.key,
    required this.state,
    required this.clubNames,
    required this.onEventSelected,
    this.padding,
  });

  final SavedEventsListState state;
  final Map<String, String> clubNames;
  final ValueChanged<Event> onEventSelected;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return EventAgendaSliverList(
      events: state.orderedEvents,
      showClubName: true,
      clubNameBuilder: (event) => clubNames[event.clubId],
      today: state.today,
      preserveInputOrder: true,
      badgeLabelBuilder: state.badgeLabelFor,
      statusBuilder: state.statusFor,
      onEventSelected: onEventSelected,
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            CatchLayout.detailScreenHorizontalPadding,
            CatchLayout.agendaListTopPadding,
            CatchLayout.detailScreenHorizontalPadding,
            CatchLayout.agendaListBottomPadding,
          ),
    );
  }
}

class SavedEventsLoading extends StatelessWidget {
  const SavedEventsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(slivers: [EventAgendaSliverSkeleton()]);
  }
}

class SavedEventsError extends StatelessWidget {
  const SavedEventsError({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return CatchErrorState.fromError(
      error,
      context: AppErrorContext.event,
      onRetry: onRetry,
    );
  }
}

class SavedEventsClubNamesErrorSliver extends StatelessWidget {
  const SavedEventsClubNamesErrorSliver({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CatchSliverErrorState.fromError(
      error,
      context: AppErrorContext.event,
      onRetry: onRetry,
    );
  }
}
