import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostCustomerMemorySection extends StatelessWidget {
  const HostCustomerMemorySection({
    super.key,
    required this.customer,
    required this.currentUid,
    required this.onEditTags,
    required this.onAddNote,
    required this.onEditNote,
  });

  final HostAudienceContactDetail customer;
  final String? currentUid;
  final VoidCallback onEditTags;
  final VoidCallback onAddNote;
  final ValueChanged<HostCustomerNote> onEditNote;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSection.divided(
      title: context.l10n.hostCustomersMemory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.hostCustomersMemoryHelp,
            style: CatchTextStyles.supporting(context),
          ),
          gapH16,
          _MemorySubsectionHeader(
            title: context.l10n.hostCustomersManualTags,
            actionLabel: context.l10n.hostCustomersEditTags,
            actionKey: const ValueKey('host-customer-edit-tags'),
            onAction: onEditTags,
          ),
          gapH8,
          if (customer.manualTags.isEmpty)
            Text(
              context.l10n.hostCustomersNoManualTags,
              style: CatchTextStyles.supporting(context),
            )
          else
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final tag in customer.manualTags)
                  CatchChip.tag(
                    key: ValueKey('host-customer-manual-tag-${tag.tagId}'),
                    label: tag.label,
                    leading: Icon(CatchIcons.editNoteOutlined),
                    tintColor: t.raised,
                    inkColor: t.ink,
                    semanticsLabel: context.l10n.hostCustomersManualTags,
                  ),
              ],
            ),
          gapH20,
          Divider(height: 1, color: t.line),
          gapH16,
          _MemorySubsectionHeader(
            title: context.l10n.hostCustomersNotes,
            actionLabel: context.l10n.hostCustomersAddNote,
            actionKey: const ValueKey('host-customer-add-note'),
            onAction: onAddNote,
          ),
          gapH8,
          if (customer.notes.isEmpty)
            Text(
              context.l10n.hostCustomersNoNotes,
              style: CatchTextStyles.supporting(context),
            )
          else
            CatchFieldLanes.single(
              child: Column(
                children: [
                  for (final (index, note) in customer.notes.indexed)
                    CatchField.content(
                      key: ValueKey('host-customer-note-${note.noteId}'),
                      title: note.body,
                      body: _noteAttribution(context, note, currentUid),
                      titleMaxLines: 6,
                      bodyMaxLines: 2,
                      action: IconButton(
                        tooltip: context.l10n.hostCustomersEditNote,
                        icon: Icon(CatchIcons.edit),
                        onPressed: () => onEditNote(note),
                      ),
                      divider: index < customer.notes.length - 1,
                    ),
                ],
              ),
            ),
          if (customer.notesTruncated) ...[
            gapH12,
            CatchNotice(
              notice: CatchNoticeData(
                id: 'host.customers.notes.truncated',
                title: context.l10n.hostCustomersNotes,
                message: context.l10n.hostCustomersNotesTruncated,
                tone: CatchNoticeTone.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemorySubsectionHeader extends StatelessWidget {
  const _MemorySubsectionHeader({
    required this.title,
    required this.actionLabel,
    required this.actionKey,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final Key actionKey;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: CatchTextStyles.fieldRowTitle(context)),
      ),
      CatchButton(
        key: actionKey,
        label: actionLabel,
        variant: CatchButtonVariant.ghost,
        size: CatchButtonSize.sm,
        onPressed: onAction,
      ),
    ],
  );
}

class HostCustomerSendHistory extends StatelessWidget {
  const HostCustomerSendHistory({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  Widget build(BuildContext context) => CatchSection.divided(
    title: context.l10n.hostCustomersSendHistory,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (customer.sends.isEmpty)
          Text(
            context.l10n.hostCustomersNoSends,
            style: CatchTextStyles.supporting(context),
          )
        else
          CatchFieldLanes.single(
            child: Column(
              children: [
                for (final (index, send) in customer.sends.indexed)
                  CatchField.read(
                    key: ValueKey(
                      'host-customer-${send.kind.name}-send-${send.campaignId}',
                    ),
                    title: send.name,
                    body: AppTimeFormatters.shortDate(
                      send.sentAt ?? send.createdAt,
                    ),
                    valueText: [
                      send.kind == HostCustomerSendKind.announcement
                          ? context.l10n.hostSendsAnnouncementType
                          : context.l10n.hostSendsCampaignType,
                      context.l10n.hostCustomersSendStatus(
                        status: send.deliveryStatus.name,
                      ),
                    ].join(' · '),
                    divider: index < customer.sends.length - 1,
                  ),
              ],
            ),
          ),
        if (customer.sendsTruncated) ...[
          gapH12,
          CatchNotice(
            notice: CatchNoticeData(
              id: 'host.customers.sends.truncated',
              title: context.l10n.hostCustomersSendHistory,
              message: context.l10n.hostCustomersSendsTruncated,
              tone: CatchNoticeTone.warning,
            ),
          ),
        ],
      ],
    ),
  );
}

class HostCustomerNoteSheet extends ConsumerStatefulWidget {
  const HostCustomerNoteSheet({super.key, required this.customer, this.note});

  final HostAudienceContactDetail customer;
  final HostCustomerNote? note;

  @override
  ConsumerState<HostCustomerNoteSheet> createState() =>
      _HostCustomerNoteSheetState();
}

class _HostCustomerNoteSheetState extends ConsumerState<HostCustomerNoteSheet> {
  late final TextEditingController _bodyController = TextEditingController(
    text: widget.note?.body,
  );
  bool _saving = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: widget.note == null
        ? context.l10n.hostCustomersAddNote
        : context.l10n.hostCustomersEditNote,
    subtitle: context.l10n.hostCustomersMemoryHelp,
    child: CatchFieldLanes.custom(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchField.input(
            key: const ValueKey('host-customer-note-body'),
            title: context.l10n.hostCustomersNoteBody,
            contract: widget.note == null
                ? CatchContractConstraints
                      .createOrganizerContactNoteCallablePayloadBody
                : CatchContractConstraints
                      .mutateOrganizerContactNoteCallablePayloadBody,
            controller: _bodyController,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          gapH12,
          CatchButton(
            key: const ValueKey('host-customer-save-note'),
            label: context.l10n.hostCustomersSaveNote,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    final body = _bodyController.text.trim();
    if (_saving || body.isEmpty) return;
    setState(() => _saving = true);
    try {
      final controller = ref.read(hostCustomersControllerProvider);
      final note = widget.note;
      if (note == null) {
        await controller.createNote(
          organizerId: widget.customer.organizerId,
          contactId: widget.customer.contactId,
          body: body,
        );
      } else {
        await controller.editNote(
          organizerId: widget.customer.organizerId,
          contactId: widget.customer.contactId,
          note: note,
          body: body,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class HostCustomerTagsSheet extends ConsumerStatefulWidget {
  const HostCustomerTagsSheet({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  ConsumerState<HostCustomerTagsSheet> createState() =>
      _HostCustomerTagsSheetState();
}

class _HostCustomerTagsSheetState extends ConsumerState<HostCustomerTagsSheet> {
  static const _contactTagCap = 5;
  static const _vocabularyTagCap = 20;

  late final Set<String> _selectedIds = widget.customer.manualTags
      .map((tag) => tag.tagId)
      .toSet();
  final List<String> _newLabels = [];
  final TextEditingController _newTagController = TextEditingController();
  String? _error;
  bool _saving = false;

  List<HostManualTag> get _vocabulary {
    final byId = <String, HostManualTag>{
      for (final tag in widget.customer.manualTagVocabulary) tag.tagId: tag,
      for (final tag in widget.customer.manualTags) tag.tagId: tag,
    };
    final result = byId.values.toList(growable: false);
    result.sort((a, b) => a.label.compareTo(b.label));
    return result;
  }

  int get _selectionCount => _selectedIds.length + _newLabels.length;

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostCustomersTagSheetTitle,
    subtitle: context.l10n.hostCustomersTagSheetSubtitle,
    child: SingleChildScrollView(
      child: CatchFieldLanes.custom(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_vocabulary.isNotEmpty)
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final tag in _vocabulary)
                    CatchChip.selectable(
                      key: ValueKey('host-customer-tag-choice-${tag.tagId}'),
                      label: tag.label,
                      leading: Icon(CatchIcons.editNoteOutlined),
                      selected: _selectedIds.contains(tag.tagId),
                      enabled:
                          _selectedIds.contains(tag.tagId) ||
                          _selectionCount < _contactTagCap,
                      accent: CatchTokens.of(context).ink2,
                      contractExemption:
                          'Manual tags are organizer-owned CRM vocabulary.',
                      onChanged: (selected) => _toggle(tag.tagId, selected),
                    ),
                ],
              ),
            if (_vocabulary.isNotEmpty) gapH16,
            CatchField.input(
              key: const ValueKey('host-customer-new-tag'),
              title: context.l10n.hostCustomersNewTag,
              contract: CatchContractConstraints
                  .mutateOrganizerContactCallablePayloadManualTagsItems,
              controller: _newTagController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              errorText: _error,
              onSubmitted: (_) => _addTag(),
            ),
            gapH8,
            CatchButton(
              label: context.l10n.hostCustomersAddTag,
              variant: CatchButtonVariant.secondary,
              size: CatchButtonSize.sm,
              onPressed: _selectionCount >= _contactTagCap ? null : _addTag,
            ),
            if (_newLabels.isNotEmpty) ...[
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final label in _newLabels)
                    CatchChip.removable(
                      label: label,
                      tintColor: CatchTokens.of(context).raised,
                      inkColor: CatchTokens.of(context).ink,
                      onRemove: () => setState(() => _newLabels.remove(label)),
                    ),
                ],
              ),
            ],
            gapH16,
            CatchButton(
              key: const ValueKey('host-customer-save-tags'),
              label: context.l10n.hostCustomersSaveTags,
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    ),
  );

  void _toggle(String tagId, bool selected) {
    if (selected && _selectionCount >= _contactTagCap) {
      setState(() => _error = context.l10n.hostCustomersTagContactLimit);
      return;
    }
    setState(() {
      _error = null;
      if (selected) {
        _selectedIds.add(tagId);
      } else {
        _selectedIds.remove(tagId);
      }
    });
  }

  void _addTag() {
    final label = _newTagController.text.trim();
    if (label.isEmpty) return;
    if (_selectionCount >= _contactTagCap) {
      setState(() => _error = context.l10n.hostCustomersTagContactLimit);
      return;
    }
    final normalized = label.toLowerCase();
    for (final tag in _vocabulary) {
      if (tag.label.toLowerCase() == normalized) {
        setState(() {
          _selectedIds.add(tag.tagId);
          _newTagController.clear();
          _error = null;
        });
        return;
      }
    }
    if (_newLabels.any((value) => value.toLowerCase() == normalized)) {
      _newTagController.clear();
      return;
    }
    if (_vocabulary.length + _newLabels.length >= _vocabularyTagCap) {
      setState(() => _error = context.l10n.hostCustomersTagVocabularyLimit);
      return;
    }
    setState(() {
      _newLabels.add(label);
      _newTagController.clear();
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final labels = [
        for (final tag in _vocabulary)
          if (_selectedIds.contains(tag.tagId)) tag.label,
        ..._newLabels,
      ];
      await ref
          .read(hostCustomersControllerProvider)
          .mutateCustomer(
            organizerId: widget.customer.organizerId,
            contactId: widget.customer.contactId,
            expectedRevision: widget.customer.revision,
            manualTags: labels,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

String _noteAttribution(
  BuildContext context,
  HostCustomerNote note,
  String? currentUid,
) {
  final date = AppTimeFormatters.shortDate(note.updatedAt);
  final attribution = currentUid != null && currentUid == note.authorUid
      ? context.l10n.hostCustomersNoteByYou(date: date)
      : context.l10n.hostCustomersNoteByTeam(date: date);
  return note.wasEdited
      ? '$attribution · ${context.l10n.hostCustomersNoteEdited}'
      : attribution;
}
