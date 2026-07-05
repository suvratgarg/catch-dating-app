import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_team_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostTeamManagementSection extends ConsumerWidget {
  const HostTeamManagementSection({
    super.key,
    required this.club,
    required this.currentUid,
  });

  final Club club;
  final String currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final hosts = club.displayHostProfiles;
    final addMutation = ref.watch(HostTeamManagementController.addHostMutation);
    final removeMutation = ref.watch(
      HostTeamManagementController.removeHostMutation,
    );
    final transferMutation = ref.watch(
      HostTeamManagementController.transferOwnershipMutation,
    );
    final addPending = addMutation.isPending;
    final removePending = removeMutation.isPending;
    final transferPending = transferMutation.isPending;
    final actionPending = addPending || removePending || transferPending;
    final actionError = _firstErrorMutation([
      addMutation,
      removeMutation,
      transferMutation,
    ]);

    Future<void> showAddHostSheet() async {
      final added = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => HostTeamAddHostSheet(
          clubId: club.id,
          actionState: HostTeamAddHostActionState(
            isSaving: addMutation.isPending,
            errorMessage: addMutation.hasError
                ? mutationErrorMessage(
                    addMutation,
                    context: AppErrorContext.club,
                  )
                : null,
          ),
          onAddHost: (phone) async {
            try {
              await HostTeamManagementController.addHostMutation.run(
                ref,
                (tx) => tx
                    .get(hostTeamManagementControllerProvider.notifier)
                    .addHostByPhone(clubId: club.id, phoneNumber: phone),
              );
            } catch (error, stackTrace) {
              ref
                  .read(errorLoggerProvider)
                  .logError(
                    error,
                    stackTrace,
                    reason:
                        'HostTeamManagementSection._showAddHostSheet failed',
                  );
              rethrow;
            }
          },
        ),
      );
      if (added == true && context.mounted) {
        showCatchSnackBar(context, 'Host added.');
      }
    }

    Future<void> confirmHostAction(
      HostTeamHostAction action,
      ClubHostProfile host,
    ) async {
      final confirmation = HostTeamHostActionConfirmation(
        action: action,
        host: host,
      );
      final confirmed = await showHostTeamHostActionDialog(
        context: context,
        confirmation: confirmation,
      );
      if (confirmed != true) return;

      try {
        switch (action) {
          case HostTeamHostAction.remove:
            await HostTeamManagementController.removeHostMutation.run(
              ref,
              (tx) => tx
                  .get(hostTeamManagementControllerProvider.notifier)
                  .removeHost(clubId: club.id, uid: host.uid),
            );
          case HostTeamHostAction.transferOwnership:
            await HostTeamManagementController.transferOwnershipMutation.run(
              ref,
              (tx) => tx
                  .get(hostTeamManagementControllerProvider.notifier)
                  .transferOwnership(clubId: club.id, uid: host.uid),
            );
        }
      } catch (error, stackTrace) {
        ref
            .read(errorLoggerProvider)
            .logError(
              error,
              stackTrace,
              reason: 'HostTeamManagementSection._confirmHostAction failed',
            );
        return;
      }
      if (!context.mounted) return;
      showCatchSnackBar(context, confirmation.successMessage);
    }

    return CatchSection.contained(
      title: 'Host team',
      borderColor: t.line,
      elevation: CatchSurfaceElevation.none,
      padding: CatchInsets.tileContentCompact,
      trailing: Tooltip(
        message: 'Add host',
        child: CatchIconButton(
          onTap: actionPending ? null : () => unawaited(showAddHostSheet()),
          child: Icon(
            CatchIcons.personAddAlt1Rounded,
            size: CatchIcon.md,
            color: actionPending ? t.ink3 : t.ink,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (actionError != null) ...[
            CatchErrorBanner(
              message: mutationErrorMessage(
                actionError,
                context: AppErrorContext.club,
              ),
            ),
            gapH12,
          ],
          for (final host in hosts) ...[
            HostTeamOwnerHostRow(
              host: host,
              canManage: host.uid != currentUid && !actionPending,
              onTransfer: () => unawaited(
                confirmHostAction(HostTeamHostAction.transferOwnership, host),
              ),
              onRemove: () =>
                  unawaited(confirmHostAction(HostTeamHostAction.remove, host)),
            ),
            if (host != hosts.last) gapH10,
          ],
        ],
      ),
    );
  }
}

enum HostTeamHostAction { remove, transferOwnership }

class HostTeamHostActionConfirmation {
  const HostTeamHostActionConfirmation({
    required this.action,
    required this.host,
  });

  final HostTeamHostAction action;
  final ClubHostProfile host;

  String get title {
    return switch (action) {
      HostTeamHostAction.remove => 'Remove host?',
      HostTeamHostAction.transferOwnership => 'Transfer ownership?',
    };
  }

  String get message {
    return switch (action) {
      HostTeamHostAction.remove =>
        '${host.displayName} will stay a club member but will lose host tools.',
      HostTeamHostAction.transferOwnership =>
        '${host.displayName} will become the club owner. You will remain a host.',
    };
  }

  List<CatchDialogAction<bool>> get actions {
    return [
      const CatchDialogAction(label: 'Cancel', value: false),
      switch (action) {
        HostTeamHostAction.remove => const CatchDialogAction(
          label: 'Remove',
          value: true,
          isDestructive: true,
        ),
        HostTeamHostAction.transferOwnership => const CatchDialogAction(
          label: 'Transfer',
          value: true,
          isDefault: true,
        ),
      },
    ];
  }

  String get successMessage {
    return switch (action) {
      HostTeamHostAction.remove => '${host.displayName} removed.',
      HostTeamHostAction.transferOwnership =>
        'Ownership transferred to ${host.displayName}.',
    };
  }
}

Future<bool?> showHostTeamHostActionDialog({
  required BuildContext context,
  required HostTeamHostActionConfirmation confirmation,
}) {
  return showCatchAdaptiveDialog<bool>(
    context: context,
    title: confirmation.title,
    message: confirmation.message,
    actions: confirmation.actions,
  );
}

class HostTeamHostActionDialog extends StatelessWidget {
  const HostTeamHostActionDialog({super.key, required this.confirmation});

  final HostTeamHostActionConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    return CatchConfirmDialog<bool>(
      title: confirmation.title,
      message: confirmation.message,
      actions: confirmation.actions,
    );
  }
}

class HostTeamOwnerHostRow extends StatelessWidget {
  const HostTeamOwnerHostRow({
    super.key,
    required this.host,
    required this.canManage,
    required this.onTransfer,
    required this.onRemove,
  });

  final ClubHostProfile host;
  final bool canManage;
  final VoidCallback onTransfer;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CatchPersonAvatar(
          name: host.displayName,
          imageUrl: host.avatarUrl,
          size: 42,
        ),
        gapW10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                host.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH4,
              ClubHostRoleBadge(role: host.role),
            ],
          ),
        ),
        CatchActionMenu<String>(
          key: ValueKey('host-team-actions-${host.uid}'),
          tooltip: 'Host actions',
          enabled: canManage,
          icon: CatchIcons.moreHorizRounded,
          onSelected: (value) {
            if (value == 'transfer') onTransfer();
            if (value == 'remove') onRemove();
          },
          items: [
            CatchActionMenuItem(
              value: 'transfer',
              label: 'Transfer ownership',
              icon: CatchIcons.adminPanelSettingsOutlined,
            ),
            CatchActionMenuItem(
              value: 'remove',
              label: 'Remove host',
              icon: CatchIcons.personOffOutlined,
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }
}

@immutable
class HostTeamAddHostActionState {
  const HostTeamAddHostActionState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;
}

Future<void> _noopAddHost(String phoneNumber) async {}

class HostTeamAddHostSheet extends StatefulWidget {
  const HostTeamAddHostSheet({
    super.key,
    required this.clubId,
    this.actionState = const HostTeamAddHostActionState(),
    this.onAddHost,
  });

  final String clubId;
  final HostTeamAddHostActionState actionState;
  final Future<void> Function(String phoneNumber)? onAddHost;

  @override
  State<HostTeamAddHostSheet> createState() => _HostTeamAddHostSheetState();
}

class _HostTeamAddHostSheetState extends State<HostTeamAddHostSheet> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    var added = false;
    try {
      await (widget.onAddHost ?? _noopAddHost)(phone);
      added = true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = appErrorMessage(error, context: AppErrorContext.club);
        });
      }
      return;
    } finally {
      if (mounted && !added) {
        setState(() {
          _saving = false;
        });
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.actionState.isSaving || _saving;
    final errorMessage = _errorMessage ?? widget.actionState.errorMessage;

    return CatchBottomSheetScaffold(
      title: 'Add host',
      subtitle: 'Enter the phone number on their Catch profile.',
      keyboardSafe: true,
      action: CatchButton(
        label: 'Add host',
        onPressed: isSaving ? null : () => unawaited(_submit()),
        isLoading: isSaving,
        fullWidth: true,
        icon: Icon(CatchIcons.personAddAlt1Rounded),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchField.input(
            title: 'Phone number',
            controller: _controller,
            prefixIcon: Icon(CatchIcons.phoneOutlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => unawaited(_submit()),
          ),
          if (errorMessage != null) ...[
            gapH12,
            CatchErrorBanner(message: errorMessage),
          ],
        ],
      ),
    );
  }
}

MutationState? _firstErrorMutation(Iterable<MutationState> mutations) {
  for (final mutation in mutations) {
    if (mutation.hasError) return mutation;
  }
  return null;
}
