import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/clipboard.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/data/event_runtime_claim_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_runtime_claim_request.dart';
import 'package:catch_dating_app/hosts/data/host_roster_file_parser.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/host_operational_roster_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostOperationalRosterPanel extends ConsumerStatefulWidget {
  const HostOperationalRosterPanel({
    super.key,
    required this.eventId,
    this.allowRosterChanges = true,
    this.bookingProvider,
  });

  final String eventId;
  final bool allowRosterChanges;
  final ExternalBookingProvider? bookingProvider;

  @override
  ConsumerState<HostOperationalRosterPanel> createState() =>
      _HostOperationalRosterPanelState();
}

class _HostOperationalRosterPanelState
    extends ConsumerState<HostOperationalRosterPanel> {
  var _importing = false;
  var _creatingHandoff = false;
  String? _pendingAttendanceId;
  String? _pendingClaimUid;
  Object? _mutationError;

  @override
  Widget build(BuildContext context) {
    final attendeesAsync = ref.watch(
      watchEventAttendeesProvider(widget.eventId),
    );
    final claimsAsync = ref.watch(
      watchPendingEventRuntimeClaimsProvider(widget.eventId),
    );
    return CatchSection.contained(
      title: context.l10n.hostsOperationalRosterTitle,
      subtitle: context.l10n.hostsOperationalRosterSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.allowRosterChanges) ...[
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchButton(
                  label: context.l10n.hostsOperationalRosterImport,
                  onPressed: _importing ? null : () => unawaited(_pickRoster()),
                  isLoading: _importing,
                  variant: CatchButtonVariant.secondary,
                  icon: Icon(CatchIcons.cloudUploadOutlined),
                ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterAddGuest,
                  onPressed: _importing
                      ? null
                      : () => unawaited(_showManualGuest()),
                  variant: CatchButtonVariant.ghost,
                  icon: Icon(CatchIcons.personAddAlt1Outlined),
                ),
                CatchButton(
                  label: context.l10n.hostsOperationalRosterForwardCsv,
                  onPressed: _importing || _creatingHandoff
                      ? null
                      : () => unawaited(_showRosterHandoff()),
                  isLoading: _creatingHandoff,
                  variant: CatchButtonVariant.ghost,
                  icon: Icon(CatchIcons.alternateEmailOutlined),
                ),
              ],
            ),
            gapH12,
          ],
          if (_mutationError case final error?) ...[
            CatchErrorBanner.fromError(error, context: AppErrorContext.event),
            gapH12,
          ],
          CatchAsyncValueView<List<EventRuntimeClaimRequest>>(
            value: claimsAsync,
            onRetry: () => ref.invalidate(
              watchPendingEventRuntimeClaimsProvider(widget.eventId),
            ),
            loadingBuilder: (_) => const SizedBox.shrink(),
            errorBuilder: (_, error, _) => CatchErrorBanner.fromError(
              error,
              context: AppErrorContext.event,
              onRetry: () => ref.invalidate(
                watchPendingEventRuntimeClaimsProvider(widget.eventId),
              ),
            ),
            builder: (context, claims) {
              if (claims.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: CatchInsets.sectionItemBottomGap,
                child: _HostRuntimeClaimQueue(
                  claims: claims,
                  attendees: attendeesAsync.asData?.value ?? const [],
                  pendingUid: _pendingClaimUid,
                  onApprove: (claim, attendeeId) => unawaited(
                    _reviewClaim(
                      claim,
                      EventRuntimeClaimDecision.approve,
                      attendeeId: attendeeId,
                    ),
                  ),
                  onReject: (claim) => unawaited(
                    _reviewClaim(claim, EventRuntimeClaimDecision.reject),
                  ),
                ),
              );
            },
          ),
          CatchAsyncValueView<List<EventAttendee>>(
            value: attendeesAsync,
            errorContext: AppErrorContext.event,
            onRetry: () =>
                ref.invalidate(watchEventAttendeesProvider(widget.eventId)),
            builder: (context, attendees) {
              if (attendees.isEmpty) {
                return CatchEmptyState(
                  layout: CatchEmptyStateLayout.inline,
                  icon: CatchIcons.groupsOutlined,
                  title: context.l10n.hostsOperationalRosterEmptyTitle,
                  message: context.l10n.hostsOperationalRosterEmptyMessage,
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final indexed in attendees.indexed)
                    CatchPersonRow(
                      key: ValueKey(indexed.$2.id),
                      data: CatchPersonRowData(
                        name: indexed.$2.displayName,
                        seed: indexed.$2.id,
                        metaLine: _attendeeMeta(context, indexed.$2),
                        contextLine: indexed.$2.hasEventIdentity
                            ? context.l10n.hostsOperationalRosterIdentityLinked
                            : null,
                      ),
                      divider: indexed.$1 > 0,
                      trailing: _RosterAttendanceAction(
                        attendee: indexed.$2,
                        pending: _pendingAttendanceId == indexed.$2.id,
                        enabled: widget.allowRosterChanges,
                        onPressed: () =>
                            unawaited(_toggleAttendance(indexed.$2)),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickRoster() async {
    setState(() {
      _importing = true;
      _mutationError = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'xlsx'],
        withData: true,
      );
      if (result == null || !mounted) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw const HostRosterImportException(
          HostRosterImportIssue.unreadableXlsx,
        );
      }
      final table = parseHostRosterFile(
        fileName: file.name,
        bytes: bytes,
        providerHint: widget.bookingProvider,
      );
      final selection = await _showRosterMapping(context, table);
      if (selection == null || !mounted) return;
      await _importRows(
        fileName: table.fileName,
        format: table.format,
        rows: selection.rows,
      );
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(context, _importIssueCopy(context, error.issue));
      }
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showManualGuest() async {
    final row = await showCatchBottomSheet<EventAttendeeImportRow>(
      context: context,
      builder: (context) => const _HostManualAttendeeSheet(),
    );
    if (row == null || !mounted) return;
    setState(() {
      _importing = true;
      _mutationError = null;
    });
    try {
      await _importRows(
        fileName: 'manual-entry',
        format: EventAttendeeImportFormat.manual,
        rows: [row],
      );
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showRosterHandoff() async {
    setState(() {
      _creatingHandoff = true;
      _mutationError = null;
    });
    try {
      final instructions = await ref
          .read(hostOperationalRosterControllerProvider)
          .createRosterHandoff(eventId: widget.eventId);
      if (!mounted) return;
      await showCatchBottomSheet<void>(
        context: context,
        builder: (context) => _HostRosterHandoffSheet(
          instructions: instructions,
          onCopy: (value) =>
              ref.read(clipboardControllerProvider).copyText(value),
        ),
      );
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _creatingHandoff = false);
    }
  }

  Future<void> _reviewClaim(
    EventRuntimeClaimRequest claim,
    EventRuntimeClaimDecision decision, {
    String? attendeeId,
  }) async {
    if (_pendingClaimUid != null) return;
    setState(() {
      _pendingClaimUid = claim.uid;
      _mutationError = null;
    });
    try {
      await ref
          .read(hostOperationalRosterControllerProvider)
          .reviewRuntimeClaim(
            eventId: widget.eventId,
            uid: claim.uid,
            decision: decision,
            attendeeId: attendeeId,
          );
      if (!mounted) return;
      showCatchSnackBar(
        context,
        decision == EventRuntimeClaimDecision.approve
            ? context.l10n.hostsOperationalRosterClaimApproved
            : context.l10n.hostsOperationalRosterClaimRejected,
      );
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _pendingClaimUid = null);
    }
  }

  Future<void> _importRows({
    required String fileName,
    required EventAttendeeImportFormat format,
    required List<EventAttendeeImportRow> rows,
  }) async {
    final importKey = format == EventAttendeeImportFormat.manual
        ? _newImportKey()
        : hostRosterImportKey(fileName: fileName, format: format, rows: rows);
    try {
      final result = await ref
          .read(hostOperationalRosterControllerProvider)
          .importAttendees(
            eventId: widget.eventId,
            importKey: importKey,
            fileName: fileName,
            format: format,
            rows: rows,
          );
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsOperationalRosterImportSuccess(
          created: result.createdCount,
          updated: result.updatedCount,
          skipped: result.skippedCount,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
      rethrow;
    }
  }

  Future<void> _toggleAttendance(EventAttendee attendee) async {
    if (_pendingAttendanceId != null) return;
    setState(() {
      _pendingAttendanceId = attendee.id;
      _mutationError = null;
    });
    try {
      await ref
          .read(hostOperationalRosterControllerProvider)
          .markAttendance(eventId: widget.eventId, attendeeId: attendee.id);
      ref.invalidate(watchEventAttendeesProvider(widget.eventId));
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _pendingAttendanceId = null);
    }
  }
}

class _HostRosterHandoffSheet extends StatelessWidget {
  const _HostRosterHandoffSheet({
    required this.instructions,
    required this.onCopy,
  });

  final EventRosterHandoffInstructions instructions;
  final Future<void> Function(String value) onCopy;

  @override
  Widget build(BuildContext context) {
    final emailAlias = instructions.emailAlias;
    final whatsappNumber = instructions.whatsappNumber;
    final whatsappMessage = instructions.whatsappMessage;
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterForwardTitle,
      subtitle: context.l10n.hostsOperationalRosterForwardSubtitle,
      glyph: CatchIcons.alternateEmailOutlined,
      action: CatchButton(
        label: context.l10n.hostsOperationalRosterForwardDone,
        onPressed: () => Navigator.of(context).pop(),
        fullWidth: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!instructions.hasAvailableChannel) ...[
            CatchErrorBanner(
              message: context.l10n.hostsOperationalRosterForwardProviderSetup,
            ),
            gapH12,
          ],
          CatchSection.fieldRows(
            children: [
              CatchField.read(
                title: context.l10n.hostsOperationalRosterForwardEmail,
                body:
                    emailAlias ??
                    context.l10n.hostsOperationalRosterForwardNotAvailable,
                icon: CatchIcons.emailOutlined,
                action: emailAlias == null
                    ? null
                    : CatchButton(
                        label: context.l10n.hostsOperationalRosterForwardCopy,
                        onPressed: () => unawaited(onCopy(emailAlias)),
                        size: CatchButtonSize.sm,
                        variant: CatchButtonVariant.ghost,
                      ),
              ),
              CatchField.read(
                title: context.l10n.hostsOperationalRosterForwardWhatsapp,
                body: whatsappNumber == null || whatsappMessage == null
                    ? context.l10n.hostsOperationalRosterForwardNotAvailable
                    : context.l10n.hostsOperationalRosterForwardWhatsappBody(
                        whatsappNumber: whatsappNumber,
                        whatsappMessage: whatsappMessage,
                      ),
                icon: CatchIcons.sendRounded,
                action: whatsappNumber == null || whatsappMessage == null
                    ? null
                    : CatchButton(
                        label: context.l10n.hostsOperationalRosterForwardCopy,
                        onPressed: () => unawaited(
                          onCopy('$whatsappNumber\n$whatsappMessage'),
                        ),
                        size: CatchButtonSize.sm,
                        variant: CatchButtonVariant.ghost,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HostRuntimeClaimQueue extends StatelessWidget {
  const _HostRuntimeClaimQueue({
    required this.claims,
    required this.attendees,
    required this.pendingUid,
    required this.onApprove,
    required this.onReject,
  });

  final List<EventRuntimeClaimRequest> claims;
  final List<EventAttendee> attendees;
  final String? pendingUid;
  final void Function(EventRuntimeClaimRequest claim, String attendeeId)
  onApprove;
  final ValueChanged<EventRuntimeClaimRequest> onReject;

  @override
  Widget build(BuildContext context) {
    final attendeesById = <String, EventAttendee>{
      for (final attendee in attendees) attendee.id: attendee,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchBadge.functional(
          label: context.l10n.hostsOperationalRosterClaimsPending(
            count: claims.length,
          ),
          tone: CatchBadgeTone.warning,
        ),
        gapH8,
        for (final indexed in claims.indexed)
          CatchPersonRow(
            key: ValueKey('runtime-claim-${indexed.$2.uid}'),
            data: CatchPersonRowData(
              name: indexed.$2.displayName,
              seed: indexed.$2.uid,
              metaLine: context.l10n.hostsOperationalRosterClaimPhone(
                phoneLastFour: indexed.$2.phoneLastFour,
              ),
              contextLine: context.l10n.hostsOperationalRosterClaimContext,
            ),
            divider: indexed.$1 > 0,
            trailing: _HostRuntimeClaimActions(
              claim: indexed.$2,
              attendeesById: attendeesById,
              pending: pendingUid == indexed.$2.uid,
              enabled: pendingUid == null,
              onApprove: (attendeeId) => onApprove(indexed.$2, attendeeId),
              onReject: () => onReject(indexed.$2),
            ),
          ),
      ],
    );
  }
}

class _HostRuntimeClaimActions extends StatelessWidget {
  const _HostRuntimeClaimActions({
    required this.claim,
    required this.attendeesById,
    required this.pending,
    required this.enabled,
    required this.onApprove,
    required this.onReject,
  });

  final EventRuntimeClaimRequest claim;
  final Map<String, EventAttendee> attendeesById;
  final bool pending;
  final bool enabled;
  final ValueChanged<String> onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final candidateIds = claim.candidateAttendeeIds;
    final approve = candidateIds.length == 1
        ? CatchButton(
            label: context.l10n.hostsOperationalRosterClaimApprove,
            onPressed: enabled ? () => onApprove(candidateIds.single) : null,
            isLoading: pending,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
          )
        : CatchMenuAnchor<String>(
            items: [
              for (final attendeeId in candidateIds)
                CatchMenuItem<String>(
                  value: attendeeId,
                  label: attendeesById[attendeeId]?.displayName ?? attendeeId,
                  sublabel: attendeesById[attendeeId]?.phoneE164,
                ),
            ],
            onSelected: (attendeeId, _) => onApprove(attendeeId),
            builder: (context, controller, child) => CatchButton(
              label: context.l10n.hostsOperationalRosterClaimChooseGuest,
              onPressed: enabled && candidateIds.isNotEmpty
                  ? controller.open
                  : null,
              isLoading: pending,
              variant: CatchButtonVariant.secondary,
              size: CatchButtonSize.sm,
            ),
          );
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: CatchSpacing.s1,
      runSpacing: CatchSpacing.s1,
      children: [
        approve,
        CatchButton(
          label: context.l10n.hostsOperationalRosterClaimReject,
          onPressed: enabled ? onReject : null,
          variant: CatchButtonVariant.ghost,
          size: CatchButtonSize.sm,
        ),
      ],
    );
  }
}

class _RosterAttendanceAction extends StatelessWidget {
  const _RosterAttendanceAction({
    required this.attendee,
    required this.pending,
    required this.enabled,
    required this.onPressed,
  });

  final EventAttendee attendee;
  final bool pending;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final checkedIn = attendee.isCheckedIn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CatchBadge.functional(
          label: _statusCopy(context, attendee.status),
          tone: checkedIn ? CatchBadgeTone.success : CatchBadgeTone.neutral,
        ),
        if (enabled) ...[
          gapH4,
          CatchButton(
            label: checkedIn
                ? context.l10n.hostsOperationalRosterUndoCheckIn
                : context.l10n.hostsOperationalRosterCheckIn,
            onPressed: pending ? null : onPressed,
            isLoading: pending,
            variant: CatchButtonVariant.ghost,
            size: CatchButtonSize.sm,
          ),
        ],
      ],
    );
  }
}

class _HostRosterImportSelection {
  const _HostRosterImportSelection(this.rows);

  final List<EventAttendeeImportRow> rows;
}

Future<_HostRosterImportSelection?> _showRosterMapping(
  BuildContext context,
  HostRosterTable table,
) => showCatchBottomSheet<_HostRosterImportSelection>(
  context: context,
  builder: (context) => _HostRosterImportSheet(table: table),
);

class _HostRosterImportSheet extends StatefulWidget {
  const _HostRosterImportSheet({required this.table});

  final HostRosterTable table;

  @override
  State<_HostRosterImportSheet> createState() => _HostRosterImportSheetState();
}

class _HostRosterImportSheetState extends State<_HostRosterImportSheet> {
  late final Map<HostRosterField, int?> _mapping = {
    ...widget.table.suggestedMapping,
  };

  @override
  Widget build(BuildContext context) {
    final mapped = widget.table.mapRows(_mapping);
    final canImport =
        mapped.rows.isNotEmpty &&
        !mapped.issues.any(
          (issue) => issue.type == HostRosterRowIssueType.missingNameColumn,
        );
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterImportTitle,
      subtitle: context.l10n.hostsOperationalRosterImportSubtitle,
      action: CatchButton(
        label: context.l10n.hostsOperationalRosterImportAction(
          count: mapped.rows.length,
        ),
        onPressed: canImport
            ? () => Navigator.of(
                context,
              ).pop(_HostRosterImportSelection(mapped.rows))
            : null,
        fullWidth: true,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.58,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchBadge.functional(
                label: widget.table.adapter.adapterId.label,
                tone:
                    widget.table.adapter.support ==
                        HostRosterAdapterSupport.sampleRequired
                    ? CatchBadgeTone.warning
                    : CatchBadgeTone.brand,
              ),
              if (widget.table.adapter.support ==
                  HostRosterAdapterSupport.sampleRequired) ...[
                gapH8,
                CatchErrorBanner(
                  message:
                      context.l10n.hostsOperationalRosterAdapterSampleRequired,
                ),
              ],
              gapH12,
              CatchFieldLanes.divided(
                children: [
                  for (final field in HostRosterField.values)
                    _RosterMappingField(
                      field: field,
                      headers: widget.table.headers,
                      value: _mapping[field],
                      onChanged: (value) => setState(() {
                        _mapping[field] = value;
                      }),
                    ),
                ],
              ),
              gapH12,
              CatchBadge(
                label: context.l10n.hostsOperationalRosterPreviewCount(
                  count: mapped.rows.length,
                ),
                tone: CatchBadgeTone.brand,
              ),
              if (mapped.truncatedCount > 0) ...[
                gapH8,
                CatchErrorBanner(
                  message: context.l10n.hostsOperationalRosterLimit(
                    count: mapped.truncatedCount,
                  ),
                ),
              ],
              for (final issue in mapped.issues.take(5)) ...[
                gapH8,
                CatchErrorBanner(message: _rowIssueCopy(context, issue)),
              ],
              if (mapped.rows.isNotEmpty) ...[
                gapH12,
                for (final row in mapped.rows.take(3).indexed)
                  CatchPersonRow(
                    data: CatchPersonRowData(
                      name: row.$2.displayName,
                      metaLine: [
                        row.$2.phone,
                        row.$2.email,
                      ].whereType<String>().join(' · '),
                    ),
                    divider: row.$1 > 0,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RosterMappingField extends StatelessWidget {
  const _RosterMappingField({
    required this.field,
    required this.headers,
    required this.value,
    required this.onChanged,
  });

  final HostRosterField field;
  final List<String> headers;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = value ?? -1;
    final options = [-1, ...List.generate(headers.length, (index) => index)];
    return CatchMenuAnchor<int>(
      items: [
        for (final option in options)
          CatchMenuItem<int>(
            value: option,
            label: option == -1
                ? context.l10n.hostsOperationalRosterDoNotImport
                : headers[option],
            selected: option == selectedValue,
          ),
      ],
      onSelected: (option, _) => onChanged(option == -1 ? null : option),
      builder: (context, controller, _) => CatchFieldLanes.single(
        child: CatchField.nav(
          title: _fieldCopy(context, field),
          valueText: selectedValue == -1
              ? context.l10n.hostsOperationalRosterDoNotImport
              : headers[selectedValue],
          onTap: controller.isOpen ? controller.close : controller.open,
        ),
      ),
    );
  }
}

class _HostManualAttendeeSheet extends StatefulWidget {
  const _HostManualAttendeeSheet();

  @override
  State<_HostManualAttendeeSheet> createState() =>
      _HostManualAttendeeSheetState();
}

class _HostManualAttendeeSheetState extends State<_HostManualAttendeeSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  var _showNameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsOperationalRosterManualTitle,
      subtitle: context.l10n.hostsOperationalRosterManualSubtitle,
      keyboardSafe: true,
      action: CatchButton(
        label: context.l10n.hostsOperationalRosterManualSave,
        onPressed: _submit,
        fullWidth: true,
      ),
      child: CatchFieldLanes.divided(
        children: [
          CatchField.input(
            title: context.l10n.hostsOperationalRosterFieldName,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsDisplayName,
            controller: _nameController,
            errorText: _showNameError
                ? context.l10n.hostsOperationalRosterManualNameRequired
                : null,
          ),
          CatchField.input(
            title: context.l10n.hostsOperationalRosterFieldPhone,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsPhone,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          CatchField.input(
            title: context.l10n.hostsOperationalRosterFieldEmail,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    Navigator.of(context).pop(
      EventAttendeeImportRow(
        rowId: 'manual',
        displayName: name,
        phone: _nullableText(_phoneController.text),
        email: _nullableText(_emailController.text),
        status: EventAttendeeStatus.registered,
      ),
    );
  }
}

String? _nullableText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String _newImportKey() =>
    'host-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

String _attendeeMeta(BuildContext context, EventAttendee attendee) => [
  _sourceCopy(context, attendee.source),
  attendee.phoneE164,
  attendee.email,
].whereType<String>().join(' · ');

String _sourceCopy(BuildContext context, EventAttendeeSource source) =>
    switch (source) {
      EventAttendeeSource.catchBooking =>
        context.l10n.hostsOperationalRosterSourceCatchBooking,
      EventAttendeeSource.hostImport =>
        context.l10n.hostsOperationalRosterSourceHostImport,
      EventAttendeeSource.hostManual =>
        context.l10n.hostsOperationalRosterSourceHostManual,
      EventAttendeeSource.webOtp =>
        context.l10n.hostsOperationalRosterSourceWebOtp,
    };

String _statusCopy(BuildContext context, EventAttendeeStatus status) =>
    switch (status) {
      EventAttendeeStatus.invited =>
        context.l10n.hostsOperationalRosterStatusInvited,
      EventAttendeeStatus.registered =>
        context.l10n.hostsOperationalRosterStatusRegistered,
      EventAttendeeStatus.waitlisted =>
        context.l10n.hostsOperationalRosterStatusWaitlisted,
      EventAttendeeStatus.checkedIn =>
        context.l10n.hostsOperationalRosterStatusCheckedIn,
      EventAttendeeStatus.cancelled =>
        context.l10n.hostsOperationalRosterStatusRegistered,
    };

String _fieldCopy(
  BuildContext context,
  HostRosterField field,
) => switch (field) {
  HostRosterField.displayName => context.l10n.hostsOperationalRosterFieldName,
  HostRosterField.phone => context.l10n.hostsOperationalRosterFieldPhone,
  HostRosterField.email => context.l10n.hostsOperationalRosterFieldEmail,
  HostRosterField.externalReference =>
    context.l10n.hostsOperationalRosterFieldReference,
  HostRosterField.ticketType => context.l10n.hostsOperationalRosterFieldTicket,
  HostRosterField.status => context.l10n.hostsOperationalRosterFieldStatus,
};

String _importIssueCopy(BuildContext context, HostRosterImportIssue issue) =>
    switch (issue) {
      HostRosterImportIssue.unsupportedFile =>
        context.l10n.hostsOperationalRosterIssueUnsupported,
      HostRosterImportIssue.missingRows =>
        context.l10n.hostsOperationalRosterIssueMissingRows,
      HostRosterImportIssue.tooManyColumns =>
        context.l10n.hostsOperationalRosterIssueTooManyColumns,
      HostRosterImportIssue.malformedCsv =>
        context.l10n.hostsOperationalRosterIssueMalformedCsv,
      HostRosterImportIssue.unreadableXlsx ||
      HostRosterImportIssue.missingWorksheet =>
        context.l10n.hostsOperationalRosterIssueUnreadableXlsx,
    };

String _rowIssueCopy(BuildContext context, HostRosterRowIssue issue) =>
    switch (issue.type) {
      HostRosterRowIssueType.missingNameColumn =>
        context.l10n.hostsOperationalRosterIssueMissingNameColumn,
      HostRosterRowIssueType.missingName =>
        context.l10n.hostsOperationalRosterIssueMissingName(
          row: issue.rowNumber ?? 0,
        ),
    };
