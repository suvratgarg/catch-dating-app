import 'dart:math';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/event_success/data/event_assignment_feature_choice_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assignment_feature_choice.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The backend discovers only this verified respondent's answers. A separate
/// matching decision is required for each answer; prior grants stay visible.
class EventAssignmentFeatureSheet extends ConsumerWidget {
  const EventAssignmentFeatureSheet({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider);
    return CatchSheet(
      title: context.l10n.eventMatchingTitle,
      mode: CatchSheetMode.scrollable,
      child: switch (uid) {
        AsyncData(:final value) when value != null =>
          _MatchingChoices(key: ValueKey(value), eventId: eventId),
        AsyncError(:final error) => CatchLocalizedErrorBanner(error),
        AsyncLoading() => const CatchLoadingIndicator(),
        _ => Text(
          context.l10n.eventMatchingUnavailable,
          style: CatchTextStyles.supporting(context),
        ),
      },
    );
  }
}

class _MatchingChoices extends ConsumerStatefulWidget {
  const _MatchingChoices({super.key, required this.eventId});
  final String eventId;
  @override
  ConsumerState<_MatchingChoices> createState() => _MatchingChoicesState();
}

class _MatchingChoicesState extends ConsumerState<_MatchingChoices>
    with WidgetsBindingObserver {
  EventAssignmentFeatureChoices? _review;
  Object? _error;
  bool _loading = true;
  String? _savingFeatureId;
  int _generation = 0;

  EventAssignmentFeatureChoiceRepository get _repository =>
      EventAssignmentFeatureChoiceRepository(
        ref.read(firebaseFunctionsProvider),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _savingFeatureId == null) {
      _reload();
    }
  }

  Future<void> _reload() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _review = null;
      _error = null;
    });
    try {
      final review = await _repository.list(widget.eventId);
      if (!mounted || generation != _generation) return;
      setState(() {
        _review = review;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _decide(EventAssignmentFeatureChoice choice) async {
    if (_savingFeatureId != null) return;
    final grant = !choice.isGranted;
    if (grant && !choice.canGrant) return;
    final random = Random.secure();
    final requestId = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    setState(() {
      _savingFeatureId = choice.featureId;
      _error = null;
    });
    try {
      await _repository.decide(
        eventId: widget.eventId,
        choice: choice,
        grant: grant,
        requestId: requestId,
      );
      if (!mounted) return;
      await _reload();
    } catch (error) {
      if (!mounted) return;
      // A timed-out write is uncertain; never show a local optimistic grant.
      setState(() => _error = error);
      await _reload();
    } finally {
      if (mounted) setState(() => _savingFeatureId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (_loading) return const CatchLoadingIndicator();
    if (_error case final error?) {
      return CatchLocalizedErrorBanner(error, onRetry: _reload);
    }
    final choices = _review?.choices ?? const <EventAssignmentFeatureChoice>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.eventMatchingDisclosure,
            style: CatchTextStyles.supporting(context)),
        gapH12,
        if (choices.isEmpty)
          Text(l.eventMatchingNoChoices,
              style: CatchTextStyles.supporting(context)),
        for (final choice in choices) ...[
          Text(choice.questionLabel ?? l.eventMatchingUnavailable,
              style: CatchTextStyles.supportingStrong(context)),
          if (choice.answerLabel case final answer?)
            Text('${l.eventMatchingAnswerLabel}: $answer',
                style: CatchTextStyles.supporting(context)),
          gapH8,
          CatchButton(
            label: choice.isGranted
                ? l.eventMatchingWithdraw
                : l.eventMatchingAllow,
            variant: choice.isGranted
                ? CatchButtonVariant.secondary
                : CatchButtonVariant.primary,
            onPressed: (_savingFeatureId == null &&
                    (choice.isGranted || choice.canGrant))
                ? () => _decide(choice)
                : null,
          ),
          gapH16,
        ],
      ],
    );
  }
}
