import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/domain/program_operations.dart';
import 'package:catch_dating_app/programs/presentation/program_operations_controller.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgramOperationsNotice extends ConsumerWidget {
  const ProgramOperationsNotice({
    super.key,
    required this.programId,
    required this.pickupPointId,
  });
  final String programId;
  final String? pickupPointId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidState = catchAsyncStateFromAsyncValue(ref.watch(uidProvider));
    final accountId = uidState.isSettledData ? uidState.value : null;
    final value = catchAsyncStateFromAsyncValue(
      ref.watch(programOperationsStateProvider(programId)),
    );
    final current = value.value;
    final error = value.error ?? current?.error;
    final controller = accountId == null
        ? null
        : programOperationsControllerProvider(programId, accountId);
    return Column(
      children: [
        if (current != null && current.outbox.entries.isNotEmpty)
          ProgramArrivalsOutboxBanner(
            outbox: current.outbox,
            busy: current.busy,
            onFlush: () {
              if (controller != null) ref.read(controller.notifier).sync();
            },
            onClearReview: () {
              if (controller != null) {
                showCatchBottomSheet<void>(
                  context: context,
                  builder: (_) => ProgramOperationReviewSheet(
                    programId: programId,
                    accountId: accountId!,
                    pickupPointId: pickupPointId,
                  ),
                );
              }
            },
          ),
        if (error != null)
          CatchBanner(
            message: appErrorMessage(error, l10n: context.l10n),
            tone: CatchBannerTone.danger,
            actions: [
              CatchButton(
                label: context.l10n.programsArrivalsOutboxSync,
                onPressed: current?.busy == true
                    ? null
                    : () {
                        if (controller == null) return;
                        if (current == null) {
                          ref.invalidate(controller);
                        } else {
                          ref.read(controller.notifier).sync();
                        }
                      },
              ),
            ],
          ),
      ],
    );
  }
}

class ProgramArrivalsOutboxBanner extends StatelessWidget {
  const ProgramArrivalsOutboxBanner({
    super.key,
    required this.outbox,
    required this.busy,
    required this.onFlush,
    required this.onClearReview,
  });

  final ProgramOperationOutboxSummary outbox;
  final bool busy;
  final VoidCallback onFlush;
  final VoidCallback onClearReview;

  @override
  Widget build(BuildContext context) {
    final pending = outbox.pendingCount;
    final review = outbox.needsReviewCount;
    final message = review > 0
        ? context.l10n.programsArrivalsOutboxReview(
            pending: pending,
            review: review,
          )
        : context.l10n.programsArrivalsOutboxPending(count: pending);
    return CatchBanner(
      title: context.l10n.programsArrivalsOutboxTitle,
      message: message,
      icon: CatchIcons.wifiOffRounded,
      tone: review > 0 ? CatchBannerTone.danger : CatchBannerTone.warning,
      actions: [
        CatchButton(
          label: context.l10n.programsArrivalsOutboxSync,
          size: CatchButtonSize.sm,
          status: busy ? CatchButtonStatus.loading : CatchButtonStatus.idle,
          onPressed: busy ? null : onFlush,
        ),
        if (review > 0)
          CatchButton(
            label: context.l10n.programsArrivalsOutboxClear,
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
            onPressed: busy ? null : onClearReview,
          ),
      ],
    );
  }
}

class ProgramOperationReviewSheet extends ConsumerWidget {
  const ProgramOperationReviewSheet({
    super.key,
    required this.programId,
    required this.accountId,
    required this.pickupPointId,
  });
  final String programId;
  final String accountId;
  final String? pickupPointId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidState = catchAsyncStateFromAsyncValue(ref.watch(uidProvider));
    final accountMatches =
        uidState.isSettledData && uidState.value == accountId;
    final operations = catchAsyncStateFromAsyncValue(
      ref.watch(programOperationsStateProvider(programId)),
    ).value;
    final roster = catchAsyncStateFromAsyncValue(
      ref.watch(programArrivalsRosterViewProvider(programId, pickupPointId)),
    ).value?.value;
    final names = {
      for (final row in roster?.rows ?? const <ArrivalsRosterRow>[])
        row.legId: row.guestDisplayName,
    };
    final entries = accountMatches
        ? operations?.outbox.entries
                  .where(
                    (entry) =>
                        entry.status ==
                        ProgramOperationOutboxStatus.needsReview,
                  )
                  .toList() ??
              <ProgramOperationOutboxEntry>[]
        : <ProgramOperationOutboxEntry>[];
    return CatchSheet(
      title: context.l10n.programsOperationsReviewTitle,
      subtitle: context.l10n.programsOperationsReviewBody,
      mode: CatchSheetMode.scrollable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (entries.isEmpty)
            Text(
              context.l10n.programsOperationsReviewEmpty,
              style: CatchTextStyles.recordBody(context),
            ),
          for (final entry in entries) ...[
            CatchSurface.card(
              padding: CatchInsets.contentDense,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _operationLabel(context, entry),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    AppTimeFormatters.dateTime(entry.createdAt),
                    style: CatchTextStyles.supporting(context),
                  ),
                  Text(
                    (entry.kind == ProgramOperationKind.dispatch
                            ? (entry.payload['legIds']! as List).map(
                                (id) =>
                                    names[id] ??
                                    context
                                        .l10n
                                        .programsOperationsGuestUnavailable,
                              )
                            : [
                                names[entry.payload['legId']] ??
                                    context
                                        .l10n
                                        .programsOperationsGuestUnavailable,
                              ])
                        .join(', '),
                    style: CatchTextStyles.recordBody(context),
                  ),
                  gapH8,
                  CatchButton(
                    label: context.l10n.programsOperationsDismiss,
                    variant: CatchButtonVariant.secondary,
                    onPressed: operations?.busy != false
                        ? null
                        : () => ref
                              .read(
                                programOperationsControllerProvider(
                                  programId,
                                  accountId,
                                ).notifier,
                              )
                              .dismissReview(entry.clientOperationId),
                  ),
                ],
              ),
            ),
            gapH12,
          ],
          if (operations?.error case final error?)
            CatchBanner.error(
              message: appErrorMessage(error, l10n: context.l10n),
            ),
        ],
      ),
    );
  }
}

String _operationLabel(
  BuildContext context,
  ProgramOperationOutboxEntry entry,
) => entry.kind == ProgramOperationKind.dispatch
    ? context.l10n.programsOperationsDeparture(
        plate: entry.payload['plateDisplay']! as String,
      )
    : switch (entry.payload['action']) {
        'claim' => context.l10n.programsOperationsClaim,
        'unclaim' => context.l10n.programsOperationsUnclaim,
        'markReady' => context.l10n.programsOperationsReady,
        _ => context.l10n.programsOperationsDisrupted,
      };
