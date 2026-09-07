import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HostWhatsappThreadRow extends StatelessWidget {
  const HostWhatsappThreadRow({
    super.key,
    required this.thread,
    required this.onTap,
  });

  final HostWhatsappThreadSummary thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CatchSurface.card(
    key: ValueKey('host-whatsapp-thread-${thread.threadId}'),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          thread.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.name(context),
        ),
        gapH4,
        Text(
          context.l10n.hostInboxWhatsappChannel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.statusLabel(context),
        ),
        gapH4,
        Text(
          thread.lastMessageBody,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.supporting(context),
        ),
      ],
    ),
  );
}

class HostWhatsappThreadSheet extends ConsumerStatefulWidget {
  const HostWhatsappThreadSheet({
    super.key,
    required this.organizerId,
    required this.threadId,
  });

  final String organizerId;
  final String threadId;

  @override
  ConsumerState<HostWhatsappThreadSheet> createState() =>
      _HostWhatsappThreadSheetState();
}

class _HostWhatsappThreadSheetState
    extends ConsumerState<HostWhatsappThreadSheet> {
  final _replyController = TextEditingController();
  late Future<HostWhatsappThreadDetail> _thread;
  bool _sending = false;
  String? _replyIdempotencyKey;
  String? _replyIdempotencyBody;

  @override
  void initState() {
    super.initState();
    _thread = _load();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<HostWhatsappThreadDetail> _load() => ref
      .read(hostAudienceControllerProvider)
      .getWhatsappThread(
        organizerId: widget.organizerId,
        threadId: widget.threadId,
      );

  void _reload() => setState(() => _thread = _load());

  @override
  Widget build(BuildContext context) => FutureBuilder<HostWhatsappThreadDetail>(
    future: _thread,
    builder: (context, snapshot) => CatchBottomSheetScaffold(
      title:
          snapshot.data?.displayName ?? context.l10n.hostInboxWhatsappChannel,
      subtitle: context.l10n.hostInboxWhatsappChannel,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: switch (snapshot.connectionState) {
          ConnectionState.none || ConnectionState.waiting
              when snapshot.data == null =>
            const CatchSkeletonRows(),
          _ when snapshot.hasError => CatchErrorState.fromError(
            snapshot.error!,
            context: AppErrorContext.chat,
            onRetry: _reload,
          ),
          _ => _HostWhatsappThreadBody(
            thread: snapshot.requireData,
            replyController: _replyController,
            sending: _sending,
            onSend: () => unawaited(_send(snapshot.requireData)),
          ),
        },
      ),
    ),
  );

  Future<void> _send(HostWhatsappThreadDetail thread) async {
    final body = _replyController.text.trim();
    if (body.isEmpty || _sending) return;
    if (_replyIdempotencyBody != body || _replyIdempotencyKey == null) {
      _replyIdempotencyBody = body;
      _replyIdempotencyKey =
          'reply-${widget.threadId}-'
          '${DateTime.now().microsecondsSinceEpoch}';
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(hostAudienceControllerProvider)
          .sendWhatsappReply(
            organizerId: widget.organizerId,
            thread: thread,
            body: body,
            idempotencyKey: _replyIdempotencyKey!,
          );
      _replyController.clear();
      _replyIdempotencyKey = null;
      _replyIdempotencyBody = null;
      ref.invalidate(hostWhatsappThreadsProvider(widget.organizerId));
      _reload();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.chat,
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _HostWhatsappThreadBody extends StatelessWidget {
  const _HostWhatsappThreadBody({
    required this.thread,
    required this.replyController,
    required this.sending,
    required this.onSend,
  });

  final HostWhatsappThreadDetail thread;
  final TextEditingController replyController;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: ListView(
          children: [
            if (thread.messagesTruncated) ...[
              Text(
                context.l10n.hostInboxWhatsappHistoryTruncated,
                style: CatchTextStyles.supporting(context),
              ),
              gapH12,
            ],
            for (final message in thread.messages) ...[
              Align(
                alignment:
                    message.direction == HostWhatsappMessageDirection.outbound
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: CatchSurface(
                  width: MediaQuery.sizeOf(context).width * 0.72,
                  padding: CatchInsets.cardContent,
                  child: Text(
                    message.body,
                    style: CatchTextStyles.proseM(context),
                  ),
                ),
              ),
              gapH8,
            ],
          ],
        ),
      ),
      Text(
        thread.serviceWindowOpen
            ? context.l10n.hostInboxWhatsappWindowOpen(
                time: DateFormat.jm().format(thread.serviceWindowExpiresAt),
              )
            : context.l10n.hostInboxWhatsappWindowClosed,
        style: CatchTextStyles.supporting(context),
      ),
      gapH8,
      CatchFieldLanes.single(
        child: CatchField.input(
          title: context.l10n.hostInboxWhatsappReplyHint,
          contract: CatchContractConstraints
              .sendOrganizerWhatsappReplyCallablePayloadBody,
          controller: replyController,
          maxLines: 4,
          minLines: 2,
          enabled: thread.serviceWindowOpen && !sending,
          showLabel: false,
          inputHint: context.l10n.hostInboxWhatsappReplyHint,
        ),
      ),
      gapH8,
      CatchButton(
        label: context.l10n.hostInboxWhatsappReply,
        isLoading: sending,
        onPressed: !thread.serviceWindowOpen || sending ? null : onSend,
      ),
    ],
  );
}
