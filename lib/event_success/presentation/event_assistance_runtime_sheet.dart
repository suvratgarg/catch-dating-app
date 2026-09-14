import 'dart:async';

import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_scope.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_setting.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_runtime_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_runtime_provider.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_runtime_section.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_runtime_senders.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The live settings boundary keeps an unresolved command across sheet closure.
class EventAssistanceRuntimeSheet extends ConsumerWidget {
  const EventAssistanceRuntimeSheet({super.key, required this.scope});
  final EventAssistanceRuntimeScope scope;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageProvider = eventAssistanceRuntimeProvider(scope);
    final page = ref.watch(pageProvider);
    final owner = eventAssistanceRuntimeEditorProvider(scope);
    final state = ref.watch(owner);
    final controller = ref.read(owner.notifier);
    final form = state is AssistanceRuntimeForm ? state : null;
    final denied =
        page.error is PermissionException ||
        page.error is SignInRequiredException ||
        page.error is AppException &&
            {
              'permission-denied',
              'unauthenticated',
              'sign-in-required',
            }.contains((page.error! as AppException).code);
    void run(Future<Object?> Function() action) {
      unawaited(() async {
        try {
          await action();
        } on Object catch (error) {
          if (context.mounted) showCatchErrorSnackBar(context, error);
        }
      }());
    }

    void reload() {
      if (form?.canReload ?? false) {
        controller.reload();
      } else {
        ref.read(pageProvider.notifier).reload();
      }
    }

    return PopScope(
      canPop: state.canDismiss,
      child: CatchSheet(
        title: context.l10n.eventAssistanceRuntimeTitle,
        mode: CatchSheetMode.scrollable,
        child: state is AssistanceRuntimeFormUnavailable
            ? CatchLocalizedErrorBanner(state.error)
            : CatchAsyncBoundary<AssistanceRuntimeSession>(
                value: form == null || denied ? page : AsyncData(form.review),
                initialLoadTimeout: null,
                onRetry: reload,
                loadingBuilder: (_) => const CatchSkeleton.rows(),
                errorBuilder: (_, error, _, retry) =>
                    CatchLocalizedErrorBanner(error, onRetry: retry),
                builder: (_, session) => _RuntimeReview(
                  session: session,
                  form: form,
                  page: page,
                  onRun: run,
                  onReload: reload,
                ),
              ),
      ),
    );
  }
}

class _RuntimeReview extends ConsumerWidget {
  const _RuntimeReview({
    required this.session,
    required this.form,
    required this.page,
    required this.onRun,
    required this.onReload,
  });
  final AssistanceRuntimeSession session;
  final AssistanceRuntimeForm? form;
  final AsyncValue<AssistanceRuntimeSession> page;
  final void Function(Future<Object?> Function()) onRun;
  final VoidCallback onReload;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fresh = !page.isLoading && !page.hasError ? page.asData?.value : null;
    final review =
        form == null || form!.phase == AssistanceRuntimeEditorPhase.choosing
        ? fresh ?? session
        : form!.review;
    final sendersProvider = eventAssistanceRuntimeSendersProvider(review);
    final directory = ref.watch(sendersProvider);
    final controller = ref.read(
      eventAssistanceRuntimeEditorProvider(review.view.scope).notifier,
    );
    final base = form?.result?.view ?? review.view;
    final saved = form?.phase == AssistanceRuntimeEditorPhase.saved;
    final view =
        saved &&
            fresh != null &&
            fresh.view.serverTime >= base.serverTime &&
            fresh.view.revision >= base.revision
        ? fresh.view
        : base;
    final phase = form == null
        ? (review.isCurrent
              ? EventAssistanceRuntimePhase.ready
              : EventAssistanceRuntimePhase.refreshRequired)
        : switch (form!.phase) {
            AssistanceRuntimeEditorPhase.choosing =>
              review.isCurrent
                  ? EventAssistanceRuntimePhase.ready
                  : EventAssistanceRuntimePhase.refreshRequired,
            AssistanceRuntimeEditorPhase.submitting =>
              EventAssistanceRuntimePhase.submitting,
            AssistanceRuntimeEditorPhase.retryRequired =>
              EventAssistanceRuntimePhase.retryRequired,
            AssistanceRuntimeEditorPhase.refreshRequired =>
              EventAssistanceRuntimePhase.refreshRequired,
            AssistanceRuntimeEditorPhase.saved =>
              EventAssistanceRuntimePhase.saved,
          };
    final pending =
        phase == EventAssistanceRuntimePhase.submitting ||
        phase == EventAssistanceRuntimePhase.retryRequired;
    return EventAssistanceRuntimeSection(
      reviewIdentity: review,
      view: view,
      choices: saved
          ? fresh?.view.senderSetup?.choices ??
                form?.change?.senderReviews ??
                review.view.senderSetup?.choices ??
                []
          : pending
          ? form?.change?.senderReviews ??
                review.view.senderSetup?.choices ??
                []
          : directory.choices,
      moreRoutes: directory.cursors.keys.toSet(),
      loadingRoute: directory.loadingRoute,
      phase: phase,
      canChooseSenders: directory.isCurrent,
      submitted: form?.phase == AssistanceRuntimeEditorPhase.choosing
          ? null
          : form?.decision,
      error: page.error ?? form?.error ?? directory.error,
      onConfigure: (draft) => onRun(() {
        final choices = directory.requireReview(review);
        controller.open(review);
        controller.select(
          AssistanceRuntimeConfigure(
            draft.configurationFor(review.view, choices),
          ),
          senders: directory,
        );
        return controller.submit();
      }),
      onPause: () => onRun(() {
        controller.open(review);
        controller.select(const AssistanceRuntimePause());
        return controller.submit();
      }),
      onMore: (route) =>
          onRun(() => ref.read(sendersProvider.notifier).loadMore(route)),
      onRetry: () => onRun(controller.retry),
      onReload: onReload,
      onDone: () => Navigator.of(context).pop(),
    );
  }
}
