import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/saved_events_state.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_agenda_list.dart';
import 'package:catch_dating_app/routing/go_router.dart';
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

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Saved events'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (uidAsync.isLoading) return const SavedEventsLoading();
            if (uidAsync.hasError) {
              return CatchErrorState.fromError(
                uidAsync.error!,
                context: AppErrorContext.auth,
                onRetry: () => ref.invalidate(uidProvider),
              );
            }

            final uid = uidAsync.asData?.value;
            final savedEventsAsync = uid == null
                ? const AsyncData(<Event>[])
                : ref.watch(watchSavedEventDetailsForUserProvider(uid));

            return CatchAsyncValueView<List<Event>>(
              value: savedEventsAsync,
              loadingBuilder: (_) => const SavedEventsLoading(),
              errorBuilder: (_, error, _) => SavedEventsError(
                error: error,
                onRetry: uid == null
                    ? null
                    : () => ref.invalidate(
                        watchSavedEventDetailsForUserProvider(uid),
                      ),
              ),
              builder: (context, events) {
                if (events.isEmpty) {
                  return const SavedEventsMessage(
                    title: 'No saved events yet',
                    message: 'Save events you want to revisit before booking.',
                  );
                }

                final now = referenceNow ?? DateTime.now();
                final savedEventsState = SavedEventsListState.from(
                  events,
                  now: now,
                );
                final clubNamesAsync = ref.watch(
                  clubNameLookupProvider(
                    ClubNameLookupQuery(savedEventsState.clubIds),
                  ),
                );

                return CustomScrollView(
                  slivers: [
                    const SavedEventsHeaderSliver(),
                    CatchAsyncValueSliver<Map<String, String>>(
                      value: clubNamesAsync,
                      sliverLoadingBuilder: (_) =>
                          const EventAgendaSliverSkeleton(),
                      sliverErrorBuilder: (_, error, _) =>
                          SavedEventsClubNamesErrorSliver(
                            error: error,
                            onRetry: () =>
                                ref.invalidate(clubNameLookupProvider),
                          ),
                      builder: (context, clubNames) => SavedEventsAgendaSliver(
                        state: savedEventsState,
                        clubNames: clubNames,
                        onEventSelected: (event) =>
                            _openEventDetail(context, event),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
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

class SavedEventsHeaderSliver extends StatelessWidget {
  const SavedEventsHeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: CatchInsets.pageHeaderCompact,
      sliver: SliverToBoxAdapter(
        child: Text(
          'Events you saved',
          style: CatchTextStyles.headlineS(context),
        ),
      ),
    );
  }
}

class SavedEventsAgendaSliver extends StatelessWidget {
  const SavedEventsAgendaSliver({
    super.key,
    required this.state,
    required this.clubNames,
    required this.onEventSelected,
  });

  final SavedEventsListState state;
  final Map<String, String> clubNames;
  final ValueChanged<Event> onEventSelected;

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
    );
  }
}

class SavedEventsLoading extends StatelessWidget {
  const SavedEventsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: CatchInsets.pageHeaderCompact,
          sliver: SliverToBoxAdapter(
            child: CatchSkeleton.text(
              width: CatchLayout.skeletonTextHeadlineWidth,
            ),
          ),
        ),
        const EventAgendaSliverSkeleton(),
      ],
    );
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

class SavedEventsMessage extends StatelessWidget {
  const SavedEventsMessage({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: CatchIcons.bookmarkBorderRounded,
        title: title,
        message: message,
        iconSize: CatchLayout.eventInfoTileExtent,
        padding: CatchInsets.contentSpacious,
        titleStyle: CatchTextStyles.titleL(context),
      ),
    );
  }
}
