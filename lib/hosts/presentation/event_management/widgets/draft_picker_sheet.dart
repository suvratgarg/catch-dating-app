import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:flutter/material.dart';

Future<EventDraft?> showDraftPickerSheet({
  required BuildContext context,
  required List<EventDraft> drafts,
  required Future<void> Function(EventDraft draft) onDeleteDraft,
}) {
  final completer = Completer<EventDraft?>();
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

  final List<EventDraft> drafts;
  final Completer<EventDraft?> completer;
  final Future<void> Function(EventDraft draft) onDeleteDraft;

  @override
  State<_DraftPickerSheet> createState() => _DraftPickerSheetState();
}

class _DraftPickerSheetState extends State<_DraftPickerSheet> {
  late List<EventDraft> _drafts;
  String? _deletingDraftId;

  @override
  void initState() {
    super.initState();
    _drafts = List.of(widget.drafts);
  }

  void _onSelect(EventDraft draft) {
    widget.completer.complete(draft);
    Navigator.of(context).pop();
  }

  void _onStartFresh() {
    widget.completer.complete(null);
    Navigator.of(context).pop();
  }

  Future<void> _onDelete(EventDraft draft) async {
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
      title: 'Resume a draft?',
      subtitle: 'Pick up where you left off, or start fresh.',
      action: CatchButton(
        label: 'Start a fresh event',
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
              title: 'No drafts yet',
              message: 'Saved drafts for this club will appear here.',
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: CatchSurface(
                  borderColor: CatchTokens.of(context).line2,
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var index = 0; index < _drafts.length; index++) ...[
                        if (index > 0)
                          Divider(
                            color: CatchTokens.of(context).line,
                            height: 1,
                            thickness: 1,
                          ),
                        _DraftCard(
                          draft: _drafts[index],
                          isDeleting: _deletingDraftId == _drafts[index].id,
                          onTap: () => _onSelect(_drafts[index]),
                          onDelete: () => _onDelete(_drafts[index]),
                        ),
                      ],
                    ],
                  ),
                ),
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

  final EventDraft draft;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      onTap: isDeleting ? null : onTap,
      tone: CatchSurfaceTone.transparent,
      borderWidth: 0,
      radius: CatchRadius.none,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        children: [
          Icon(CatchIcons.descriptionOutlined, size: 22, color: t.ink3),
          gapW12,
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
                gapH4,
                Text(
                  'SAVED ${_formatRelative(draft.savedAt).toUpperCase()}',
                  style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                ),
              ],
            ),
          ),
          gapW8,
          Tooltip(
            message: 'Delete draft',
            child: CatchIconButton(
              key: CreateEventFormKeys.deleteDraft(draft.id),
              onTap: isDeleting ? null : onDelete,
              size: 36,
              background: Colors.transparent,
              child: isDeleting
                  ? const SizedBox.square(
                      dimension: CatchIcon.md,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      CatchIcons.deleteOutlineRounded,
                      size: 20,
                      color: t.ink2,
                    ),
            ),
          ),
          gapW8,
          Icon(CatchIcons.chevronRightRounded, size: 16, color: t.ink3),
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
