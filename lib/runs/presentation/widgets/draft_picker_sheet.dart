import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:catch_dating_app/runs/presentation/create_run_form_keys.dart';
import 'package:flutter/material.dart';

Future<RunDraft?> showDraftPickerSheet({
  required BuildContext context,
  required List<RunDraft> drafts,
  required Future<void> Function(RunDraft draft) onDeleteDraft,
}) {
  final completer = Completer<RunDraft?>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(CatchRadius.lg)),
    ),
    builder: (sheetContext) => _DraftPickerSheet(
      drafts: drafts,
      completer: completer,
      onDeleteDraft: onDeleteDraft,
    ),
  ).then((_) {
    if (!completer.isCompleted) completer.complete(null);
  });
  return completer.future;
}

class _DraftPickerSheet extends StatefulWidget {
  const _DraftPickerSheet({
    required this.drafts,
    required this.completer,
    required this.onDeleteDraft,
  });

  final List<RunDraft> drafts;
  final Completer<RunDraft?> completer;
  final Future<void> Function(RunDraft draft) onDeleteDraft;

  @override
  State<_DraftPickerSheet> createState() => _DraftPickerSheetState();
}

class _DraftPickerSheetState extends State<_DraftPickerSheet> {
  late List<RunDraft> _drafts;
  String? _deletingDraftId;

  @override
  void initState() {
    super.initState();
    _drafts = List.of(widget.drafts);
  }

  void _onSelect(RunDraft draft) {
    widget.completer.complete(draft);
    Navigator.of(context).pop();
  }

  void _onStartFresh() {
    widget.completer.complete(null);
    Navigator.of(context).pop();
  }

  Future<void> _onDelete(RunDraft draft) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Delete draft?',
      message: 'This will permanently delete "${draft.summary}".',
      actions: const [
        CatchDialogAction(label: 'Cancel', value: false),
        CatchDialogAction(label: 'Delete', value: true, isDestructive: true),
      ],
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not delete draft.')));
    } finally {
      if (mounted) setState(() => _deletingDraftId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: 'Your drafts',
      subtitle: 'Pick up where you left off or start a new run.',
      action: CatchButton(
        label: 'Start fresh',
        onPressed: _onStartFresh,
        variant: CatchButtonVariant.secondary,
        fullWidth: true,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_drafts.isEmpty)
            const CatchEmptyState(
              icon: Icons.edit_note_rounded,
              title: 'No drafts yet',
              message: 'Saved drafts for this run club will appear here.',
              surface: false,
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  4,
                  CatchSpacing.s5,
                  12,
                ),
                itemCount: _drafts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final draft = _drafts[index];
                  return _DraftCard(
                    draft: draft,
                    isDeleting: _deletingDraftId == draft.id,
                    onTap: () => _onSelect(draft),
                    onDelete: () => _onDelete(draft),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
  });

  final RunDraft draft;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      onTap: isDeleting ? null : onTap,
      padding: const EdgeInsets.all(14),
      borderColor: CatchTokens.of(context).line,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.summary,
                  style: CatchTextStyles.labelL(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRelative(draft.savedAt),
                  style: CatchTextStyles.bodyS(
                    context,
                    color: CatchTokens.of(context).ink2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: CreateRunFormKeys.deleteDraft(draft.id),
            onPressed: isDeleting ? null : onDelete,
            icon: isDeleting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: CatchTokens.of(context).ink2,
                  ),
            visualDensity: VisualDensity.compact,
            tooltip: 'Delete draft',
          ),
        ],
      ),
    );
  }

  static String _formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
