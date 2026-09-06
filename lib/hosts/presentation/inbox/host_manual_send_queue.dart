import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostManualSendQueue extends ConsumerStatefulWidget {
  const HostManualSendQueue({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostManualSendQueue> createState() =>
      _HostManualSendQueueState();
}

class _HostManualSendQueueState extends ConsumerState<HostManualSendQueue> {
  List<HostManualSendTask> _additionalTasks = const [];
  String? _additionalNextCursor;
  bool _loadingMore = false;
  bool _replanning = false;
  Map<String, HostManualSendTaskReplanResult> _replanResults = const {};

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(hostManualSendTasksProvider(widget.organizerId));
    return tasks.when(
      loading: () => CatchSection.fieldRows(
        key: const ValueKey('host-manual-send-queue-loading'),
        title: context.l10n.hostManualSendQueueTitle,
        children: [
          CatchField.read(
            title: context.l10n.hostManualSendQueueLoading,
            body: context.l10n.hostManualSendQueueDisclosure,
          ),
        ],
      ),
      error: (error, _) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.club,
        mode: CatchErrorStateMode.compact,
        onRetry: _resetAndReload,
      ),
      data: (page) => _HostManualSendQueueContent(
        page: page,
        additionalTasks: _additionalTasks,
        additionalNextCursor: _additionalNextCursor,
        loadingMore: _loadingMore,
        replanning: _replanning,
        onOpenTask: _openTask,
        onLoadMore: _loadMore,
        onReplan: _replan,
      ),
    );
  }

  Future<void> _openTask(HostManualSendTask task) async {
    final changed = await showCatchBottomSheet<bool>(
      context: context,
      builder: (_) => _HostManualSendTaskSheet(task: task),
    );
    if (!mounted || changed != true) return;
    _resetAndReload();
  }

  Future<void> _loadMore(String cursor) async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await ref
          .read(hostAudienceControllerProvider)
          .listManualSendTasks(organizerId: widget.organizerId, cursor: cursor);
      if (!mounted) return;
      setState(() {
        _additionalTasks = [..._additionalTasks, ...page.tasks];
        _additionalNextCursor = page.nextCursor;
      });
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _replan(List<HostManualSendTask> tasks) async {
    if (_replanning) return;
    setState(() => _replanning = true);
    try {
      final result = await ref
          .read(hostAudienceControllerProvider)
          .replanManualSendTasks(
            organizerId: widget.organizerId,
            taskIds: tasks.map((task) => task.taskId).take(50).toList(),
          );
      if (!mounted) return;
      setState(() {
        _replanResults = {for (final item in result.results) item.taskId: item};
      });
      await showCatchBottomSheet<void>(
        context: context,
        builder: (_) =>
            _HostManualSendReplanSheet(tasks: tasks, results: _replanResults),
      );
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _replanning = false);
    }
  }

  void _resetAndReload() {
    if (mounted) {
      setState(() {
        _additionalTasks = const [];
        _additionalNextCursor = null;
        _replanResults = const {};
      });
    }
    ref.invalidate(hostManualSendTasksProvider(widget.organizerId));
  }
}

class _HostManualSendQueueContent extends StatelessWidget {
  const _HostManualSendQueueContent({
    required this.page,
    required this.additionalTasks,
    required this.additionalNextCursor,
    required this.loadingMore,
    required this.replanning,
    required this.onOpenTask,
    required this.onLoadMore,
    required this.onReplan,
  });

  final HostManualSendTaskPage page;
  final List<HostManualSendTask> additionalTasks;
  final String? additionalNextCursor;
  final bool loadingMore;
  final bool replanning;
  final ValueChanged<HostManualSendTask> onOpenTask;
  final ValueChanged<String> onLoadMore;
  final ValueChanged<List<HostManualSendTask>> onReplan;

  @override
  Widget build(BuildContext context) {
    final seen = <String>{};
    final tasks = [...page.tasks, ...additionalTasks]
        .where((task) => task.active && seen.add(task.taskId))
        .toList(growable: false);
    if (tasks.isEmpty) return const SizedBox.shrink();
    final nextCursor = additionalTasks.isEmpty
        ? page.nextCursor
        : additionalNextCursor;
    return CatchSection.fieldRows(
      key: const ValueKey('host-manual-send-queue'),
      title: context.l10n.hostManualSendQueueTitle,
      count: tasks.length,
      trailing: CatchButton(
        key: const ValueKey('host-manual-send-replan'),
        label: context.l10n.hostManualSendQueueReplan,
        size: CatchButtonSize.sm,
        variant: CatchButtonVariant.secondary,
        isLoading: replanning,
        onPressed: replanning ? null : () => onReplan(tasks),
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.hostManualSendQueueDisclosure,
            style: CatchTextStyles.proseM(context),
          ),
          if (nextCursor != null) ...[
            gapH12,
            CatchButton(
              label: context.l10n.hostSendsLoadMore,
              variant: CatchButtonVariant.secondary,
              isLoading: loadingMore,
              onPressed: loadingMore ? null : () => onLoadMore(nextCursor),
            ),
          ],
        ],
      ),
      children: [
        for (final task in tasks)
          CatchField.nav(
            key: ValueKey('host-manual-send-${task.taskId}'),
            title: task.displayName,
            body: _manualTaskBody(context, task),
            valueText: _manualTaskStatus(context, task),
            onTap: () => onOpenTask(task),
          ),
      ],
    );
  }
}

class _HostManualSendTaskSheet extends ConsumerStatefulWidget {
  const _HostManualSendTaskSheet({required this.task});

  final HostManualSendTask task;

  @override
  ConsumerState<_HostManualSendTaskSheet> createState() =>
      _HostManualSendTaskSheetState();
}

class _HostManualSendTaskSheetState
    extends ConsumerState<_HostManualSendTaskSheet> {
  late HostManualSendTask _task = widget.task;
  bool _busy = false;

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostManualSendTaskTitle(name: _task.displayName),
    subtitle: context.l10n.hostManualSendTaskSubtitle,
    action: CatchButton(
      key: const ValueKey('host-manual-send-mark-sent'),
      label: context.l10n.hostManualSendTaskMarkSent,
      isLoading: _busy,
      onPressed: _busy || _task.status != HostManualSendTaskStatus.handoffOpened
          ? null
          : () => unawaited(_mark(HostManualSendTaskAction.hostMarkedSent)),
      fullWidth: true,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchNotice(
          notice: CatchNoticeData(
            id: 'host.manual-send.${_task.taskId}',
            title: _manualTaskStatus(context, _task),
            message: context.l10n.hostManualSendTaskDisclosure,
          ),
        ),
        gapH16,
        CatchSection.fieldRows(
          children: [
            CatchField.action(
              key: const ValueKey('host-manual-send-open-whatsapp'),
              title: context.l10n.hostManualSendTaskOpenWhatsapp,
              body: _task.phoneE164,
              onTap: _busy ? null : () => unawaited(_openWhatsapp()),
            ),
            CatchField.action(
              key: const ValueKey('host-manual-send-skip'),
              title: context.l10n.hostManualSendTaskSkip,
              body: context.l10n.hostManualSendTaskSkipBody,
              tone: CatchFieldTone.danger,
              onTap: _busy
                  ? null
                  : () => unawaited(_mark(HostManualSendTaskAction.skipped)),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _openWhatsapp() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final validated = await ref
          .read(hostAudienceControllerProvider)
          .validateManualSendTaskLaunch(_task);
      final opened = await ref
          .read(externalLinkControllerProvider)
          .openWhatsappHandoff(
            phoneE164: validated.phoneE164,
            message: validated.prefillText,
          );
      if (!opened) {
        if (!mounted) return;
        throw ExternalActionException(
          context.l10n.hostCustomersWhatsappOpenFailed,
        );
      }
      final updated = await ref
          .read(hostAudienceControllerProvider)
          .recordManualHandoffOpened(validated);
      if (mounted) setState(() => _task = updated);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customer,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _mark(HostManualSendTaskAction action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(hostAudienceControllerProvider)
          .markManualSendTask(_task, action);
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customer,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _HostManualSendReplanSheet extends StatelessWidget {
  const _HostManualSendReplanSheet({
    required this.tasks,
    required this.results,
  });

  final List<HostManualSendTask> tasks;
  final Map<String, HostManualSendTaskReplanResult> results;

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostManualSendReplanTitle,
    subtitle: context.l10n.hostManualSendReplanSubtitle,
    child: CatchSection.fieldRows(
      children: [
        for (final task in tasks.take(50))
          CatchField.read(
            title: task.displayName,
            body: _manualTaskReplanBody(context, results[task.taskId]),
          ),
      ],
    ),
  );
}

String _manualTaskBody(BuildContext context, HostManualSendTask task) =>
    task.status == HostManualSendTaskStatus.handoffOpened
    ? context.l10n.hostManualSendTaskOpenedBody
    : context.l10n.hostManualSendTaskQueuedBody;

String _manualTaskStatus(
  BuildContext context,
  HostManualSendTask task,
) => switch (task.status) {
  HostManualSendTaskStatus.queued => context.l10n.hostManualSendTaskQueued,
  HostManualSendTaskStatus.handoffOpened =>
    context.l10n.hostManualSendTaskOpened,
  HostManualSendTaskStatus.hostMarkedSent =>
    context.l10n.hostManualSendTaskHostMarkedSent,
  HostManualSendTaskStatus.skipped => context.l10n.hostManualSendTaskSkipped,
  HostManualSendTaskStatus.cancelled =>
    context.l10n.hostManualSendTaskCancelled,
  HostManualSendTaskStatus.superseded =>
    context.l10n.hostManualSendTaskSuperseded,
  HostManualSendTaskStatus.expired => context.l10n.hostManualSendTaskExpired,
};

String _manualTaskReplanBody(
  BuildContext context,
  HostManualSendTaskReplanResult? result,
) => result?.blocker == HostCommunicationRouteBlocker.endpointChanged
    ? context.l10n.hostManualSendReplanEndpointChanged
    : switch (result?.disposition) {
        HostManualSendTaskDisposition.managedRouteAvailable =>
          context.l10n.hostManualSendReplanManagedAvailable,
        HostManualSendTaskDisposition.keepByHand =>
          context.l10n.hostManualSendReplanKeepByHand,
        HostManualSendTaskDisposition.unavailable =>
          context.l10n.hostManualSendReplanUnavailable,
        HostManualSendTaskDisposition.taskInactive =>
          context.l10n.hostManualSendReplanInactive,
        null => context.l10n.hostManualSendReplanUnavailable,
      };
