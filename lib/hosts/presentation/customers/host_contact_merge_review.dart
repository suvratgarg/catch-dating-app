import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostContactMergeReviewSheet extends ConsumerStatefulWidget {
  const HostContactMergeReviewSheet({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostContactMergeReviewSheet> createState() =>
      _HostContactMergeReviewSheetState();
}

class _HostContactMergeReviewSheetState
    extends ConsumerState<HostContactMergeReviewSheet> {
  late Future<HostContactMergeCandidatePage> _page;
  var _active = const <HostContactMergeCandidate>[];
  var _dismissed = const <HostContactMergeCandidate>[];
  String? _nextCursor;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _page = _load(reset: true);
  }

  Future<HostContactMergeCandidatePage> _load({required bool reset}) async {
    final page = await ref
        .read(hostCustomersControllerProvider)
        .listMergeCandidates(
          organizerId: widget.organizerId,
          cursor: reset ? null : _nextCursor,
        );
    if (mounted) {
      setState(() {
        _active = reset
            ? page.candidates
            : _mergeById(_active, page.candidates);
        _dismissed = reset
            ? page.dismissedCandidates
            : _mergeById(_dismissed, page.dismissedCandidates);
        _nextCursor = page.nextCursor;
      });
    }
    return page;
  }

  void _reload() {
    setState(() => _page = _load(reset: true));
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostCustomersMergeReviewTitle,
    subtitle: context.l10n.hostCustomersMergeReviewHelp,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.68,
      ),
      child: FutureBuilder<HostContactMergeCandidatePage>(
        future: _page,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done &&
              _active.isEmpty &&
              _dismissed.isEmpty) {
            return const CatchSkeletonRows();
          }
          if (snapshot.hasError && _active.isEmpty && _dismissed.isEmpty) {
            return CatchErrorState.fromError(
              snapshot.error!,
              context: AppErrorContext.club,
              mode: CatchErrorStateMode.compact,
              onRetry: _reload,
            );
          }
          if (_active.isEmpty && _dismissed.isEmpty) {
            return CatchEmptyState(
              title: context.l10n.hostCustomersMergeReviewEmpty,
            );
          }
          return ListView(
            shrinkWrap: true,
            children: [
              for (final candidate in _active) ...[
                HostContactMergeCandidateCard(
                  organizerId: widget.organizerId,
                  candidate: candidate,
                  onChanged: _reload,
                  onMerged: () => Navigator.of(context).pop(true),
                ),
                gapH12,
              ],
              if (_dismissed.isNotEmpty) ...[
                gapH8,
                Text(
                  context.l10n.hostCustomersDismissedDuplicates,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH12,
                for (final candidate in _dismissed) ...[
                  _DismissedMergeCandidateCard(
                    organizerId: widget.organizerId,
                    candidate: candidate,
                    onChanged: _reload,
                  ),
                  gapH12,
                ],
              ],
              if (_nextCursor != null)
                CatchButton(
                  label: context.l10n.hostCustomersLoadMore,
                  variant: CatchButtonVariant.secondary,
                  isLoading: _loadingMore,
                  onPressed: _loadingMore ? null : _loadMore,
                ),
            ],
          );
        },
      ),
    ),
  );

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      await _load(reset: false);
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
}

class HostContactMergeCandidateCard extends ConsumerStatefulWidget {
  const HostContactMergeCandidateCard({
    super.key,
    required this.organizerId,
    required this.candidate,
    required this.onChanged,
    required this.onMerged,
  });

  final String organizerId;
  final HostContactMergeCandidate candidate;
  final VoidCallback onChanged;
  final VoidCallback onMerged;

  @override
  ConsumerState<HostContactMergeCandidateCard> createState() =>
      _HostContactMergeCandidateCardState();
}

class _HostContactMergeCandidateCardState
    extends ConsumerState<HostContactMergeCandidateCard> {
  String? _survivorContactId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    return CatchSurface(
      key: ValueKey('host-contact-merge-${candidate.candidateId}'),
      padding: CatchInsets.cardContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final contact in candidate.contacts) ...[
            Text(contact.displayName, style: CatchTextStyles.name(context)),
            if (contact.phoneE164 != null)
              Text(
                contact.phoneE164!,
                style: CatchTextStyles.supporting(context),
              ),
            if (contact.email != null)
              Text(contact.email!, style: CatchTextStyles.supporting(context)),
            Text(
              _sourceLabel(context, contact.primarySource),
              style: CatchTextStyles.supporting(context),
            ),
            gapH12,
          ],
          Text(
            candidate.matchKinds
                .map((kind) => _matchKindLabel(context, kind))
                .join(' · '),
            style: CatchTextStyles.supporting(context),
          ),
          gapH4,
          Text(
            context.l10n.hostCustomersMergeSharedEvents(
              count: candidate.sharedEventCount,
            ),
            style: CatchTextStyles.supporting(context),
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final contact in candidate.contacts)
                CatchButton(
                  label: context.l10n.hostCustomersMergeKeep(
                    name: contact.displayName,
                  ),
                  size: CatchButtonSize.sm,
                  variant: _survivorContactId == contact.contactId
                      ? CatchButtonVariant.primary
                      : CatchButtonVariant.secondary,
                  onPressed: _saving
                      ? null
                      : () => setState(
                          () => _survivorContactId = contact.contactId,
                        ),
                ),
            ],
          ),
          gapH12,
          CatchButton(
            label: context.l10n.hostCustomersMergeAction,
            isLoading: _saving,
            onPressed: _saving || _survivorContactId == null ? null : _merge,
          ),
          gapH8,
          CatchButton(
            label: context.l10n.hostCustomersDifferentPeople,
            variant: CatchButtonVariant.ghost,
            onPressed: _saving ? null : _markDifferentPeople,
          ),
        ],
      ),
    );
  }

  Future<void> _merge() async {
    final survivor = widget.candidate.contacts.singleWhere(
      (contact) => contact.contactId == _survivorContactId,
    );
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostCustomersMergeConfirmTitle,
      message: context.l10n.hostCustomersMergeConfirmBody(
        survivor: survivor.displayName,
      ),
      confirmLabel: context.l10n.hostCustomersMergeAction,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    final succeeded = await _run(
      () => ref
          .read(hostCustomersControllerProvider)
          .mergeCustomers(
            organizerId: widget.organizerId,
            candidate: widget.candidate,
            survivorContactId: survivor.contactId,
            confirmConflicts: true,
          ),
    );
    if (mounted && succeeded) widget.onMerged();
  }

  Future<void> _markDifferentPeople() async {
    final succeeded = await _run(
      () => ref
          .read(hostCustomersControllerProvider)
          .markDifferentPeople(
            organizerId: widget.organizerId,
            candidate: widget.candidate,
          ),
    );
    if (mounted && succeeded) widget.onChanged();
  }

  Future<bool> _run(Future<void> Function() action) async {
    setState(() => _saving = true);
    try {
      await action();
      return true;
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DismissedMergeCandidateCard extends ConsumerStatefulWidget {
  const _DismissedMergeCandidateCard({
    required this.organizerId,
    required this.candidate,
    required this.onChanged,
  });

  final String organizerId;
  final HostContactMergeCandidate candidate;
  final VoidCallback onChanged;

  @override
  ConsumerState<_DismissedMergeCandidateCard> createState() =>
      _DismissedMergeCandidateCardState();
}

class _DismissedMergeCandidateCardState
    extends ConsumerState<_DismissedMergeCandidateCard> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) => CatchSurface(
    padding: CatchInsets.cardContent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.candidate.contacts
              .map((contact) => contact.displayName)
              .join(' · '),
          style: CatchTextStyles.name(context),
        ),
        if (!widget.candidate.canReopen) ...[
          gapH4,
          Text(
            context.l10n.hostCustomersReopenOwnerOnly,
            style: CatchTextStyles.supporting(context),
          ),
        ],
        gapH12,
        CatchButton(
          label: context.l10n.hostCustomersReopenDuplicate,
          variant: CatchButtonVariant.secondary,
          isLoading: _saving,
          onPressed: _saving || !widget.candidate.canReopen ? null : _reopen,
        ),
      ],
    ),
  );

  Future<void> _reopen() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(hostCustomersControllerProvider)
          .reopenMergeCandidate(
            organizerId: widget.organizerId,
            candidate: widget.candidate,
          );
      if (mounted) widget.onChanged();
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

List<HostContactMergeCandidate> _mergeById(
  List<HostContactMergeCandidate> existing,
  List<HostContactMergeCandidate> incoming,
) => [
  ...{
    for (final candidate in existing) candidate.candidateId: candidate,
    for (final candidate in incoming) candidate.candidateId: candidate,
  }.values,
];

String _matchKindLabel(BuildContext context, HostContactMergeMatchKind kind) =>
    switch (kind) {
      HostContactMergeMatchKind.sameVerifiedUid =>
        context.l10n.hostCustomersMergeEvidenceVerifiedUid,
      HostContactMergeMatchKind.sameVerifiedPhone =>
        context.l10n.hostCustomersMergeEvidenceVerifiedPhone,
      HostContactMergeMatchKind.sameImportedPhone =>
        context.l10n.hostCustomersMergeEvidenceImportedPhone,
      HostContactMergeMatchKind.sameEmail =>
        context.l10n.hostCustomersMergeEvidenceEmail,
    };

String _sourceLabel(BuildContext context, String source) => switch (source) {
  'catchBooking' => context.l10n.hostsOperationalRosterSourceCatchBooking,
  'hostImport' => context.l10n.hostsOperationalRosterSourceHostImport,
  'hostManual' => context.l10n.hostsOperationalRosterSourceHostManual,
  'webOtp' => context.l10n.hostsOperationalRosterSourceWebOtp,
  'providerSync' => context.l10n.hostsOperationalRosterSourceProviderSync,
  _ => throw const FormatException('Unsupported contact source.'),
};
