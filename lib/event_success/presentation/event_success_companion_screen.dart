import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventSuccessCompanionRouteScreen extends ConsumerWidget {
  const EventSuccessCompanionRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final event = eventAsync.asData?.value ?? initialEvent;
    final profileAsync = ref.watch(watchUserProfileProvider);
    final participationAsync = uid == null
        ? const AsyncData<EventParticipation?>(null)
        : ref.watch(watchEventParticipationProvider(eventId, uid));
    final planAsync = ref.watch(watchEventSuccessPlanProvider(eventId));
    if (eventAsync.isLoading && event == null) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (eventAsync.hasError) {
      return CatchErrorScaffold.fromError(
        eventAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventProvider(eventId)),
      );
    }
    if (event == null) {
      return const CatchErrorScaffold(
        title: 'Event not found',
        message: 'This event is no longer available.',
      );
    }
    if (uid == null) {
      return const CatchErrorScaffold(
        title: 'Sign in required',
        message: 'Sign in to open your event companion.',
      );
    }
    if (profileAsync.isLoading ||
        participationAsync.isLoading ||
        planAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (profileAsync.hasError) {
      return CatchErrorScaffold.fromError(
        profileAsync.error!,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(watchUserProfileProvider),
      );
    }
    if (participationAsync.hasError) {
      return CatchErrorScaffold.fromError(
        participationAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventParticipationProvider(eventId, uid)),
      );
    }
    if (planAsync.hasError) {
      return CatchErrorScaffold.fromError(
        planAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventSuccessPlanProvider(eventId)),
      );
    }

    final profile = profileAsync.asData?.value;
    final participation = participationAsync.asData?.value;
    if (profile == null || participation == null) {
      return const CatchErrorScaffold(
        title: 'No booking found',
        message: 'Book this event before opening the companion.',
      );
    }

    final plan = planAsync.asData?.value;
    if (plan == null) {
      return const CatchErrorScaffold(
        title: 'Companion not available',
        message:
            'The host has not enabled event companion tools for this event yet.',
      );
    }

    final feedbackAsync = ref.watch(
      watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
    );
    final candidatesAsync = ref.watch(
      privateCrushCandidatesProvider(eventId: eventId, currentUid: uid),
    );

    if (feedbackAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }
    if (feedbackAsync.hasError) {
      return CatchErrorScaffold.fromError(
        feedbackAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchUserEventSuccessFeedbackProvider(eventId: eventId, uid: uid),
        ),
      );
    }

    final candidates = candidatesAsync.asData?.value ?? const <PublicProfile>[];
    final feedback = feedbackAsync.asData?.value;

    return EventSuccessCompanionScreen(
      event: event,
      plan: plan,
      userProfile: profile,
      participation: participation,
      privateCrushCandidates: candidates,
      existingFeedback: feedback,
    );
  }
}

class EventSuccessCompanionScreen extends StatefulWidget {
  const EventSuccessCompanionScreen({
    super.key,
    required this.event,
    required this.plan,
    required this.userProfile,
    required this.participation,
    required this.privateCrushCandidates,
    this.existingFeedback,
    this.now,
  });

  final Event event;
  final EventSuccessPlan plan;
  final UserProfile userProfile;
  final EventParticipation participation;
  final List<PublicProfile> privateCrushCandidates;
  final EventSuccessFeedback? existingFeedback;
  final DateTime? now;

  @override
  State<EventSuccessCompanionScreen> createState() =>
      _EventSuccessCompanionScreenState();
}

class _EventSuccessCompanionScreenState
    extends State<EventSuccessCompanionScreen> {
  late bool _markedPrivateCrush =
      widget.existingFeedback?.markedPrivateCrush ?? false;

  @override
  void didUpdateWidget(covariant EventSuccessCompanionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingFeedback?.markedPrivateCrush == true) {
      _markedPrivateCrush = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final plan = widget.plan;
    final referenceNow = widget.now ?? DateTime.now();
    final attended =
        widget.participation.status == EventParticipationStatus.attended;
    final eventEnded = !widget.event.endTime.isAfter(referenceNow);
    final checkInOpen = isSelfCheckInOpenForParticipationStatus(
      event: widget.event,
      status: widget.participation.status,
      now: referenceNow,
    );

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: AppBar(
        title: const Text('Event companion'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        children: [
          _CompanionHero(
            event: event,
            plan: plan,
            attended: attended,
            checkInOpen: checkInOpen,
          ),
          gapH16,
          EventSuccessPromptCard(
            title: 'Social prompt',
            prompt: plan.attendeePromptFor(event),
          ),
          if (checkInOpen) ...[gapH16, _SelfCheckInCard(event: event)],
          if (attended && eventEnded && plan.privateCrushEnabled) ...[
            gapH16,
            _PrivateCrushSection(
              eventId: event.id,
              candidates: widget.privateCrushCandidates,
              onMarked: () => setState(() => _markedPrivateCrush = true),
            ),
          ],
          if (attended && eventEnded) ...[
            gapH16,
            EventSuccessFeedbackForm(
              event: event,
              userProfile: widget.userProfile,
              existingFeedback: widget.existingFeedback,
              markedPrivateCrush: _markedPrivateCrush,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanionHero extends StatelessWidget {
  const _CompanionHero({
    required this.event,
    required this.plan,
    required this.attended,
    required this.checkInOpen,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool attended;
  final bool checkInOpen;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      backgroundColor: t.ink,
      borderWidth: 0,
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge(
            label: attended
                ? 'Checked in'
                : checkInOpen
                ? 'Check in open'
                : 'Booked',
            tone: attended ? CatchBadgeTone.success : CatchBadgeTone.live,
            icon: attended ? Icons.check_rounded : Icons.qr_code_2_rounded,
          ),
          gapH12,
          Text(
            event.title,
            style: CatchTextStyles.displayM(context, color: t.surface),
          ),
          gapH6,
          Text(
            '${plan.playbook.title} · ${event.meetingPoint}',
            style: CatchTextStyles.bodyS(
              context,
              color: t.surface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelfCheckInCard extends ConsumerWidget {
  const _SelfCheckInCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(EventBookingController.selfCheckInMutation);
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arrival check-in', style: CatchTextStyles.titleM(context)),
          gapH6,
          Text(
            'Confirm you are at the event so post-event follow-up only includes actual attendees.',
            style: CatchTextStyles.bodyS(context),
          ),
          gapH12,
          CatchButton(
            label: 'Check in',
            isLoading: mutation.isPending,
            onPressed: mutation.isPending
                ? null
                : () => EventBookingController.selfCheckInMutation.run(
                    ref,
                    (tx) => tx
                        .get(eventBookingControllerProvider.notifier)
                        .selfCheckIn(eventId: event.id),
                  ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _PrivateCrushSection extends StatelessWidget {
  const _PrivateCrushSection({
    required this.eventId,
    required this.candidates,
    required this.onMarked,
  });

  final String eventId;
  final List<PublicProfile> candidates;
  final VoidCallback onMarked;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Private follow-up', style: CatchTextStyles.titleM(context)),
          gapH4,
          Text(
            'Mark interest privately. Nothing is shown unless interest is mutual.',
            style: CatchTextStyles.bodyS(context),
          ),
          gapH12,
          if (candidates.isEmpty)
            Text(
              'No checked-in attendees available yet.',
              style: CatchTextStyles.bodyS(context),
            )
          else
            for (final candidate in candidates)
              _PrivateCrushRow(
                eventId: eventId,
                candidate: candidate,
                onMarked: onMarked,
              ),
        ],
      ),
    );
  }
}

class _PrivateCrushRow extends ConsumerStatefulWidget {
  const _PrivateCrushRow({
    required this.eventId,
    required this.candidate,
    required this.onMarked,
  });

  final String eventId;
  final PublicProfile candidate;
  final VoidCallback onMarked;

  @override
  ConsumerState<_PrivateCrushRow> createState() => _PrivateCrushRowState();
}

class _PrivateCrushRowState extends ConsumerState<_PrivateCrushRow> {
  bool _marked = false;

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(EventSuccessController.privateCrushMutation);
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: Row(
        children: [
          CircleAvatar(child: Text(_avatarInitial(widget.candidate.name))),
          gapW10,
          Expanded(
            child: Text(
              widget.candidate.name,
              style: CatchTextStyles.titleS(context),
            ),
          ),
          CatchButton(
            label: _marked ? 'Marked' : 'Mark',
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
            isLoading: !_marked && mutation.isPending,
            onPressed: _marked || mutation.isPending
                ? null
                : () => EventSuccessController.privateCrushMutation.run(ref, (
                    tx,
                  ) async {
                    await tx
                        .get(eventSuccessControllerProvider.notifier)
                        .markPrivateCrush(
                          eventId: widget.eventId,
                          target: widget.candidate,
                        );
                    if (!mounted) return;
                    setState(() => _marked = true);
                    widget.onMarked();
                  }),
          ),
        ],
      ),
    );
  }
}

String _avatarInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, 1).toUpperCase();
}

class EventSuccessFeedbackForm extends StatefulWidget {
  const EventSuccessFeedbackForm({
    super.key,
    required this.event,
    required this.userProfile,
    this.existingFeedback,
    this.markedPrivateCrush = false,
  });

  final Event event;
  final UserProfile userProfile;
  final EventSuccessFeedback? existingFeedback;
  final bool markedPrivateCrush;

  @override
  State<EventSuccessFeedbackForm> createState() =>
      _EventSuccessFeedbackFormState();
}

class _EventSuccessFeedbackFormState extends State<EventSuccessFeedbackForm> {
  late int _welcome = widget.existingFeedback?.welcomeRating ?? 4;
  late int _structure = widget.existingFeedback?.structureRating ?? 4;
  late int _metPeople = widget.existingFeedback?.metNewPeopleCount ?? 2;
  late bool _safetyConcern = widget.existingFeedback?.safetyConcern ?? false;
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existingFeedback?.privateNote ?? '',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final mutation = ref.watch(EventSuccessController.feedbackMutation);
        return CatchSurface(
          borderColor: CatchTokens.of(context).line,
          padding: const EdgeInsets.all(CatchSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event feedback', style: CatchTextStyles.titleM(context)),
              gapH4,
              Text(
                'This helps the host improve the next event.',
                style: CatchTextStyles.bodyS(context),
              ),
              gapH12,
              _RatingRow(
                label: 'Welcome',
                value: _welcome,
                onChanged: (value) => setState(() => _welcome = value),
              ),
              gapH8,
              _RatingRow(
                label: 'Structure',
                value: _structure,
                onChanged: (value) => setState(() => _structure = value),
              ),
              gapH8,
              _CounterRow(
                value: _metPeople,
                onChanged: (value) => setState(() => _metPeople = value),
              ),
              gapH8,
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _safetyConcern,
                onChanged: (value) =>
                    setState(() => _safetyConcern = value ?? false),
                title: const Text('I had a safety or comfort concern'),
              ),
              CatchTextField(
                label: 'Private note to host',
                controller: _noteController,
                maxLines: 3,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
              ),
              gapH12,
              CatchButton(
                label: widget.existingFeedback == null
                    ? 'Submit feedback'
                    : 'Update feedback',
                isLoading: mutation.isPending,
                onPressed: mutation.isPending ? null : () => _submit(ref),
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(WidgetRef ref) {
    final now = DateTime.now();
    final existing = widget.existingFeedback;
    final feedback = EventSuccessFeedback(
      id:
          existing?.id ??
          eventSuccessFeedbackId(
            eventId: widget.event.id,
            uid: widget.userProfile.uid,
          ),
      eventId: widget.event.id,
      clubId: widget.event.clubId,
      uid: widget.userProfile.uid,
      welcomeRating: _welcome,
      structureRating: _structure,
      metNewPeopleCount: _metPeople,
      safetyConcern: _safetyConcern,
      privateNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      markedPrivateCrush:
          widget.markedPrivateCrush || (existing?.markedPrivateCrush ?? false),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    EventSuccessController.feedbackMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .submitFeedback(feedback),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: CatchTextStyles.titleS(context))),
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$label $i',
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_border_rounded,
            ),
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('People I met', style: CatchTextStyles.titleS(context)),
        ),
        IconButton(
          tooltip: 'Decrease people met',
          icon: const Icon(Icons.remove_circle_outline_rounded),
          onPressed: value <= 0 ? null : () => onChanged(value - 1),
        ),
        Text('$value', style: CatchTextStyles.titleM(context)),
        IconButton(
          tooltip: 'Increase people met',
          icon: const Icon(Icons.add_circle_outline_rounded),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}
