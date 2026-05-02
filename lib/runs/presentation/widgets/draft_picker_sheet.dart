import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:flutter/material.dart';

Future<RunDraft?> showDraftPickerSheet({
  required BuildContext context,
  required List<RunDraft> drafts,
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
  });

  final List<RunDraft> drafts;
  final Completer<RunDraft?> completer;

  @override
  State<_DraftPickerSheet> createState() => _DraftPickerSheetState();
}

class _DraftPickerSheetState extends State<_DraftPickerSheet> {
  late List<RunDraft> _drafts;

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete draft?'),
        content: Text('This will permanently delete "${draft.summary}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _drafts.removeWhere((d) => d.id == draft.id));
      widget.completer.complete(null);
      if (_drafts.isEmpty) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: t.ink3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              16,
              CatchSpacing.s5,
              4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Your Drafts',
                    style: CatchTextStyles.titleL(context),
                  ),
                ),
                IconButton(
                  onPressed: _onStartFresh,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Draft list
          if (_drafts.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                8,
                CatchSpacing.s5,
                24,
              ),
              child: Text(
                'No drafts yet',
                style: CatchTextStyles.bodyM(context, color: t.ink2),
              ),
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
                    onTap: () => _onSelect(draft),
                    onDelete: () => _onDelete(draft),
                  );
                },
              ),
            ),
          // Start fresh button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              8,
              CatchSpacing.s5,
              16,
            ),
            child: OutlinedButton(
              onPressed: _onStartFresh,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: t.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CatchRadius.lg),
                ),
              ),
              child: Text(
                'Start fresh',
                style: CatchTextStyles.labelL(context),
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
    required this.onTap,
    required this.onDelete,
  });

  final RunDraft draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(CatchRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            border: Border.all(color: t.line),
          ),
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
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, size: 20, color: t.ink2),
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete draft',
              ),
            ],
          ),
        ),
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
