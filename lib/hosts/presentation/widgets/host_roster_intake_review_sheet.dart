import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/data/host_roster_intake_repository.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

Future<HostRosterIntakeReview?> showHostRosterIntakeReview(
  BuildContext context, {
  required HostRosterIntakeReview review,
  required Future<HostRosterIntakeReview> Function(
    HostRosterIntakeReview review,
    Iterable<String> rowIds,
  )
  onExclude,
  required Future<HostRosterIntakeReview> Function(
    HostRosterIntakeReview review,
  )
  onApply,
}) => showCatchBottomSheet<HostRosterIntakeReview>(
  context: context,
  builder: (context) => HostRosterIntakeReviewSheet(
    review: review,
    onExclude: onExclude,
    onApply: onApply,
  ),
);

class HostRosterIntakeReviewSheet extends StatefulWidget {
  const HostRosterIntakeReviewSheet({
    super.key,
    required this.review,
    required this.onExclude,
    required this.onApply,
  });

  final HostRosterIntakeReview review;
  final Future<HostRosterIntakeReview> Function(
    HostRosterIntakeReview review,
    Iterable<String> rowIds,
  )
  onExclude;
  final Future<HostRosterIntakeReview> Function(HostRosterIntakeReview review)
  onApply;

  @override
  State<HostRosterIntakeReviewSheet> createState() =>
      _HostRosterIntakeReviewSheetState();
}

class _HostRosterIntakeReviewSheetState
    extends State<HostRosterIntakeReviewSheet> {
  late HostRosterIntakeReview _review = widget.review;
  var _pending = false;
  Object? _error;

  Future<void> _excludeUnresolved() async {
    final ids = _review.unresolvedRowIds.toList(growable: false);
    if (_pending || ids.isEmpty) return;
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      final review = await widget.onExclude(_review, ids);
      if (mounted) setState(() => _review = review);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  Future<void> _apply() async {
    if (_pending || !_review.eligibleForApply) return;
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      final applied = await widget.onApply(_review);
      if (mounted) Navigator.of(context).pop(applied);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unresolved = _review.unresolvedRowIds.length;
    return CatchSheet.standard(
      title: context.l10n.hostsOperationalRosterIntakeReviewTitle,
      subtitle: context.l10n.hostsOperationalRosterIntakeReviewSubtitle(
        fileName: _review.fileName,
      ),
      footer: CatchButton.sheet(
        key: const ValueKey('host-roster-intake-apply'),
        role: CatchButtonEmphasis.commit,
        label: context.l10n.hostsOperationalRosterIntakeApply,
        status: _pending ? CatchButtonStatus.loading : CatchButtonStatus.idle,
        onPressed: _review.eligibleForApply && !_pending ? _apply : null,
      ),
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                _countBadge(context, 'add'),
                _countBadge(context, 'update'),
                _countBadge(context, 'unchanged'),
                _countBadge(context, 'excluded'),
                _countBadge(context, 'needsReview'),
                _countBadge(context, 'identityConflict'),
              ],
            ),
            if (unresolved > 0) ...[
              gapH12,
              CatchBanner.error(
                message: context.l10n.hostsOperationalRosterIntakeExceptions(
                  count: unresolved,
                ),
              ),
              gapH8,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CatchButton(
                  key: const ValueKey('host-roster-intake-exclude'),
                  label: context.l10n.hostsOperationalRosterIntakeExclude(
                    count: unresolved,
                  ),
                  onPressed: _pending ? null : _excludeUnresolved,
                  variant: CatchButtonVariant.secondary,
                ),
              ),
            ],
            if (_error != null) ...[
              gapH12,
              CatchBanner.error(
                message: context.l10n.hostsOperationalRosterIntakeRetry,
              ),
            ],
            gapH12,
            CatchFieldLanes.divided(
              children: [
                for (final row in _review.rows)
                  CatchField.read(
                    copy: catchFieldCopy(context.l10n),
                    title: context.l10n.hostsOperationalRosterIntakeRow(
                      row: row.sourceRowNumber,
                    ),
                    body: _kindLabel(context, row.kind, row.issueCode),
                    bodyMaxLines: 3,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countBadge(BuildContext context, String kind) => CatchBadge(
    label: context.l10n.hostsOperationalRosterIntakeCount(
      kind: _kindLabel(context, kind, null),
      count: _review.counts[kind] ?? 0,
    ),
    tone: {'needsReview', 'identityConflict'}.contains(kind)
        ? CatchBadgeTone.warning
        : CatchBadgeTone.neutral,
  );
}

String _kindLabel(BuildContext context, String kind, String? issue) =>
    switch (kind) {
      'add' => context.l10n.hostsOperationalRosterIntakeKindAdd,
      'update' => context.l10n.hostsOperationalRosterIntakeKindUpdate,
      'unchanged' => context.l10n.hostsOperationalRosterIntakeKindUnchanged,
      'excluded' => context.l10n.hostsOperationalRosterIntakeKindExcluded,
      'needsReview' =>
        issue ?? context.l10n.hostsOperationalRosterIntakeKindNeedsReview,
      'identityConflict' =>
        issue ?? context.l10n.hostsOperationalRosterIntakeKindIdentityConflict,
      _ => kind,
    };
