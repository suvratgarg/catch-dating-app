import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

Future<EventDraft?> showDraftPickerSheet({
  required BuildContext context,
  required List<EventDraft> drafts,
  required Future<void> Function(EventDraft draft) onDeleteDraft,
}) {
  final completer = Completer<EventDraft?>();
  showCatchBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(CatchRadius.lg)),
    ),
    builder: (sheetContext) => DraftPickerSheet(
      drafts: drafts,
      onSelectDraft: (draft) => completer.complete(draft),
      onStartFresh: () => completer.complete(null),
      onDeleteDraft: onDeleteDraft,
    ),
  ).then((_) {
    if (!completer.isCompleted) completer.complete(null);
  });
  return completer.future;
}

String draftDeleteConfirmationDialogTitle(AppLocalizations l10n) =>
    l10n.hostsDraftPickerSheetVisiblecopyDeleteDraft;
List<CatchDialogAction<bool>> draftDeleteConfirmationDialogActions(
  AppLocalizations l10n,
) => [
  CatchDialogAction(label: l10n.hostsDraftPickerSheetLabelCancel, value: false),
  CatchDialogAction(
    label: l10n.hostsDraftPickerSheetLabelDelete,
    value: true,
    isDestructive: true,
  ),
];

String draftDeleteConfirmationDialogMessage(
  AppLocalizations l10n,
  EventDraft draft,
) {
  return l10n.hostsDraftPickerSheetVisiblecopyThisWillPermanentlyDelete(
    summary: draft.summary,
  );
}

class DraftDeleteConfirmationDialog extends StatelessWidget {
  const DraftDeleteConfirmationDialog({super.key, required this.draft});

  final EventDraft draft;

  @override
  Widget build(BuildContext context) {
    return CatchConfirmDialog<bool>(
      title: draftDeleteConfirmationDialogTitle(context.l10n),
      message: draftDeleteConfirmationDialogMessage(context.l10n, draft),
      actions: draftDeleteConfirmationDialogActions(context.l10n),
    );
  }
}

Future<bool?> showDraftDeleteConfirmationDialog({
  required BuildContext context,
  required EventDraft draft,
}) {
  return showCatchAdaptiveDialog<bool>(
    context: context,
    title: draftDeleteConfirmationDialogTitle(context.l10n),
    message: draftDeleteConfirmationDialogMessage(context.l10n, draft),
    actions: draftDeleteConfirmationDialogActions(context.l10n),
  );
}

class DraftPickerSheet extends StatefulWidget {
  const DraftPickerSheet({
    super.key,
    required this.drafts,
    required this.onSelectDraft,
    required this.onStartFresh,
    required this.onDeleteDraft,
  });

  final List<EventDraft> drafts;
  final ValueChanged<EventDraft> onSelectDraft;
  final VoidCallback onStartFresh;
  final Future<void> Function(EventDraft draft) onDeleteDraft;

  @override
  State<DraftPickerSheet> createState() => _DraftPickerSheetState();
}

class _DraftPickerSheetState extends State<DraftPickerSheet> {
  late List<EventDraft> _drafts;
  String? _deletingDraftId;

  @override
  void initState() {
    super.initState();
    _drafts = List.of(widget.drafts);
  }

  void _onSelect(EventDraft draft) {
    widget.onSelectDraft(draft);
    Navigator.of(context).pop();
  }

  void _onStartFresh() {
    widget.onStartFresh();
    Navigator.of(context).pop();
  }

  Future<void> _onDelete(EventDraft draft) async {
    final confirmed = await showDraftDeleteConfirmationDialog(
      context: context,
      draft: draft,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingDraftId = draft.id);
    try {
      await widget.onDeleteDraft(draft);
      if (!mounted) return;
      setState(() => _drafts.removeWhere((d) => d.id == draft.id));
      if (_drafts.isEmpty) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsDraftPickerSheetVisiblecopyCouldNotDeleteDraft,
      );
    } finally {
      if (mounted) setState(() => _deletingDraftId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsDraftPickerSheetTitleResumeADraft,
      subtitle: context.l10n.hostsDraftPickerSheetSubtitlePickUpWhereYou,
      action: CatchButton(
        label: context.l10n.hostsDraftPickerSheetLabelStartAFreshEvent,
        onPressed: _onStartFresh,
        variant: CatchButtonVariant.secondary,
        fullWidth: true,
        icon: Icon(CatchIcons.addRounded),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_drafts.isEmpty)
            CatchEmptyState(
              icon: CatchIcons.editNoteRounded,
              title: context.l10n.hostsDraftPickerSheetTitleNoDraftsYet,
              message:
                  context.l10n.hostsDraftPickerSheetMessageSavedDraftsForThis,
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: CatchSection.containedFieldRows(
                  children: [
                    for (final draft in _drafts)
                      DraftCard(
                        draft: draft,
                        isDeleting: _deletingDraftId == draft.id,
                        onSelect: () => _onSelect(draft),
                        onDelete: () => _onDelete(draft),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DraftCard extends StatelessWidget {
  const DraftCard({
    super.key,
    required this.draft,
    required this.isDeleting,
    required this.onSelect,
    required this.onDelete,
  });

  final EventDraft draft;
  final bool isDeleting;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchField.nav(
      title: draft.summary,
      body: context.l10n.hostsDraftPickerSheetTextSavedTouppercase(
        toUpperCase: _formatRelative(draft.savedAt).toUpperCase(),
      ),
      icon: CatchIcons.descriptionOutlined,
      iconColor: t.ink3,
      onTap: isDeleting ? null : onSelect,
      action: Tooltip(
        message: context.l10n.hostsDraftPickerSheetMessageDeleteDraft,
        child: CatchIconButton(
          key: CreateEventFormKeys.deleteDraft(draft.id),
          onTap: isDeleting ? null : onDelete,
          size: 36,
          background: Colors.transparent,
          child: isDeleting
              ? const HostInlineSkeletonIcon()
              : Icon(CatchIcons.deleteOutlineRounded, size: 20, color: t.ink2),
        ),
      ),
    );
  }
}

String _formatRelative(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}
