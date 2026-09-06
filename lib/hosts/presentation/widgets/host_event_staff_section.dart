import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/clipboard.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/hosts/data/host_event_staff_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_staff_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostEventStaffSection extends ConsumerStatefulWidget {
  const HostEventStaffSection({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<HostEventStaffSection> createState() =>
      _HostEventStaffSectionState();
}

class _HostEventStaffSectionState extends ConsumerState<HostEventStaffSection> {
  AsyncValue<HostEventStaffList> _staff = const AsyncLoading();
  var _loaded = false;
  var _mutationPending = false;
  Object? _mutationError;

  @override
  Widget build(BuildContext context) {
    return CatchFieldLanes.single(
      child: CatchField.control(
        key: const ValueKey<String>('host_event_staff_access_field'),
        title: context.l10n.hostsEventStaffTitle,
        body: context.l10n.hostsEventStaffSubtitle,
        icon: CatchIcons.adminPanelSettingsOutlined,
        contractExemption:
            'Disclosure and mutation surface for server-owned temporary event '
            'access; the field itself does not persist a scalar value.',
        onOpenChanged: (open) {
          if (open && !_loaded) unawaited(_load());
        },
        control: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchButton(
                  label: context.l10n.hostsEventStaffAdd,
                  icon: Icon(CatchIcons.personAddAlt1Outlined),
                  variant: CatchButtonVariant.secondary,
                  onPressed: _mutationPending
                      ? null
                      : () => unawaited(_grant()),
                ),
                CatchButton(
                  label: context.l10n.hostsEventStaffCopyLink,
                  icon: Icon(CatchIcons.linkRounded),
                  variant: CatchButtonVariant.ghost,
                  onPressed: () => unawaited(_copyLink()),
                ),
              ],
            ),
            gapH12,
            if (_mutationError case final error?) ...[
              CatchErrorBanner.fromError(error, context: AppErrorContext.event),
              gapH12,
            ],
            if (_loaded)
              CatchAsyncValueView<HostEventStaffList>(
                value: _staff,
                errorContext: AppErrorContext.event,
                onRetry: _load,
                builder: (context, list) {
                  if (list.members.isEmpty) {
                    return CatchEmptyState(
                      layout: CatchEmptyStateLayout.inline,
                      icon: CatchIcons.groupsOutlined,
                      title: context.l10n.hostsEventStaffEmptyTitle,
                      message: context.l10n.hostsEventStaffEmptyMessage,
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final indexed in list.members.indexed)
                        CatchPersonRow(
                          key: ValueKey(indexed.$2.uid),
                          divider: indexed.$1 > 0,
                          data: CatchPersonRowData(
                            name: indexed.$2.displayName,
                            seed: indexed.$2.uid,
                            metaLine: context.l10n.hostsEventStaffPhoneEnding(
                              digits: indexed.$2.phoneLastFour,
                            ),
                            contextLine: context.l10n.hostsEventStaffExpires(
                              date: AppTimeFormatters.dateTime(
                                indexed.$2.expiresAt,
                              ),
                            ),
                          ),
                          trailing:
                              indexed.$2.status == HostEventStaffStatus.active
                              ? CatchButton(
                                  label: context.l10n.hostsEventStaffRevoke,
                                  variant: CatchButtonVariant.ghost,
                                  onPressed: _mutationPending
                                      ? null
                                      : () => unawaited(_revoke(indexed.$2)),
                                )
                              : CatchBadge.functional(
                                  label: _statusLabel(
                                    context,
                                    indexed.$2.status,
                                  ),
                                  tone:
                                      indexed.$2.status ==
                                          HostEventStaffStatus.expired
                                      ? CatchBadgeTone.warning
                                      : CatchBadgeTone.neutral,
                                ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loaded = true;
        _staff = const AsyncLoading();
      });
    }
    try {
      final list = await ref
          .read(hostEventStaffControllerProvider)
          .list(widget.eventId);
      if (mounted) setState(() => _staff = AsyncData(list));
    } catch (error, stackTrace) {
      if (mounted) setState(() => _staff = AsyncError(error, stackTrace));
    }
  }

  Future<void> _grant() async {
    final request = await showCatchBottomSheet<_StaffGrantInput>(
      context: context,
      builder: (context) => const _HostEventStaffGrantSheet(),
    );
    if (request == null || !mounted) return;
    setState(() {
      _mutationPending = true;
      _mutationError = null;
    });
    try {
      final list = await ref
          .read(hostEventStaffControllerProvider)
          .grant(
            eventId: widget.eventId,
            phoneNumber: request.phoneNumber,
            window: request.window,
          );
      if (!mounted) return;
      setState(() => _staff = AsyncData(list));
      await _copyLink();
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _mutationPending = false);
    }
  }

  Future<void> _revoke(HostEventStaffMember member) async {
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostsEventStaffRevokeTitle,
      message: context.l10n.hostsEventStaffRevokeMessage(
        name: member.displayName,
      ),
      confirmLabel: context.l10n.hostsEventStaffRevoke,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _mutationPending = true;
      _mutationError = null;
    });
    try {
      final list = await ref
          .read(hostEventStaffControllerProvider)
          .revoke(eventId: widget.eventId, member: member);
      if (mounted) setState(() => _staff = AsyncData(list));
    } catch (error) {
      if (mounted) setState(() => _mutationError = error);
    } finally {
      if (mounted) setState(() => _mutationPending = false);
    }
  }

  Future<void> _copyLink() async {
    try {
      await ref
          .read(clipboardControllerProvider)
          .copyText(AppDeepLinks.hostOperatorEvent(widget.eventId).toString());
      if (mounted) {
        showCatchSnackBar(context, context.l10n.hostsEventStaffLinkCopied);
      }
    } catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }
}

class _StaffGrantInput {
  const _StaffGrantInput({required this.phoneNumber, required this.window});

  final String phoneNumber;
  final HostEventStaffGrantWindow window;
}

class _HostEventStaffGrantSheet extends StatefulWidget {
  const _HostEventStaffGrantSheet();

  @override
  State<_HostEventStaffGrantSheet> createState() =>
      _HostEventStaffGrantSheetState();
}

class _HostEventStaffGrantSheetState extends State<_HostEventStaffGrantSheet> {
  final _phoneController = TextEditingController();
  var _window = HostEventStaffGrantWindow.twelveHours;
  var _showPhoneError = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsEventStaffGrantTitle,
      subtitle: context.l10n.hostsEventStaffGrantSubtitle,
      keyboardSafe: true,
      action: CatchButton(
        label: context.l10n.hostsEventStaffGrantAction,
        fullWidth: true,
        onPressed: _submit,
      ),
      child: CatchFieldLanes.divided(
        children: [
          CatchField.input(
            title: context.l10n.hostsEventStaffPhone,
            contract: CatchContractConstraints
                .grantEventStaffCallablePayloadPhoneNumber,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            errorText: _showPhoneError
                ? context.l10n.hostsEventStaffPhoneRequired
                : null,
          ),
          CatchMenuAnchor<HostEventStaffGrantWindow>(
            items: [
              for (final window in HostEventStaffGrantWindow.values)
                CatchMenuItem<HostEventStaffGrantWindow>(
                  value: window,
                  label: _windowLabel(context, window),
                  selected: window == _window,
                  role: CatchMenuItemRole.choice,
                ),
            ],
            onSelected: (window, _) => setState(() => _window = window),
            builder: (context, controller, _) => CatchFieldLanes.single(
              child: CatchField.nav(
                title: context.l10n.hostsEventStaffAccessDuration,
                valueText: _windowLabel(context, _window),
                onTap: controller.isOpen ? controller.close : controller.open,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) {
      setState(() => _showPhoneError = true);
      return;
    }
    Navigator.of(
      context,
    ).pop(_StaffGrantInput(phoneNumber: phone, window: _window));
  }
}

String _windowLabel(BuildContext context, HostEventStaffGrantWindow window) =>
    switch (window) {
      HostEventStaffGrantWindow.fourHours =>
        context.l10n.hostsEventStaffDurationFourHours,
      HostEventStaffGrantWindow.twelveHours =>
        context.l10n.hostsEventStaffDurationTwelveHours,
      HostEventStaffGrantWindow.oneDay =>
        context.l10n.hostsEventStaffDurationOneDay,
      HostEventStaffGrantWindow.sevenDays =>
        context.l10n.hostsEventStaffDurationSevenDays,
    };

String _statusLabel(BuildContext context, HostEventStaffStatus status) =>
    switch (status) {
      HostEventStaffStatus.active => context.l10n.hostsEventStaffStatusActive,
      HostEventStaffStatus.revoked => context.l10n.hostsEventStaffStatusRevoked,
      HostEventStaffStatus.expired => context.l10n.hostsEventStaffStatusExpired,
    };
