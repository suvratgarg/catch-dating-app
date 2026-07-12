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
import 'package:catch_dating_app/l10n/l10n.dart';
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
      final added = await showCatchBottomSheet<bool>(
        context: context,
        builder: (_) => HostTeamAddHostSheet(
          clubId: club.id,
          actionState: HostTeamAddHostActionState(
            isSaving: addMutation.isPending,
            errorMessage: addMutation.hasError
                ? mutationErrorMessage(
                    addMutation,
                    l10n: context.l10n,
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
                    reason: context
                        .l10n
                        .hostsHostTeamManagementSectionVisiblecopyHostteammanagementsectionShowaddhostsheetFailed,
                  );
              rethrow;
            }
          },
        ),
      );
      if (added == true && context.mounted) {
        showCatchSnackBar(
          context,
          context.l10n.hostsHostTeamManagementSectionVisiblecopyHostAdded,
        );
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
              reason: context
                  .l10n
                  .hostsHostTeamManagementSectionVisiblecopyHostteammanagementsectionConfirmhostactionFailed,
            );
        return;
      }
      if (!context.mounted) return;
      showCatchSnackBar(context, confirmation.successMessage(context.l10n));
    }

    return CatchSection.contained(
      title: context.l10n.hostsHostTeamManagementSectionTitleHostTeam,
      borderColor: t.line,
      elevation: CatchSurfaceElevation.none,
      padding: CatchInsets.tileContentCompact,
      trailing: Tooltip(
        message: context.l10n.hostsHostTeamManagementSectionMessageAddHost,
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
                l10n: context.l10n,
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

  String title(AppLocalizations l10n) {
    return switch (action) {
      HostTeamHostAction.remove =>
        l10n.hostsHostTeamManagementSectionTitleRemoveHost,
      HostTeamHostAction.transferOwnership =>
        l10n.hostsHostTeamManagementSectionTitleTransferOwnership,
    };
  }

  String message(AppLocalizations l10n) {
    return switch (action) {
      HostTeamHostAction.remove =>
        l10n.hostsHostTeamManagementSectionMessageDisplaynameWillStayA(
          displayName: host.displayName,
        ),
      HostTeamHostAction.transferOwnership =>
        l10n.hostsHostTeamManagementSectionMessageDisplaynameWillBecomeThe(
          displayName: host.displayName,
        ),
    };
  }

  List<CatchDialogAction<bool>> actions(AppLocalizations l10n) {
    return [
      CatchDialogAction(
        label: l10n.hostsHostTeamManagementSectionLabelCancel,
        value: false,
      ),
      switch (action) {
        HostTeamHostAction.remove => CatchDialogAction(
          label: l10n.hostsHostTeamManagementSectionLabelRemove,
          value: true,
          isDestructive: true,
        ),
        HostTeamHostAction.transferOwnership => CatchDialogAction(
          label: l10n.hostsHostTeamManagementSectionLabelTransfer,
          value: true,
          isDefault: true,
        ),
      },
    ];
  }

  String successMessage(AppLocalizations l10n) {
    return switch (action) {
      HostTeamHostAction.remove =>
        l10n.hostsHostTeamManagementSectionSuccessmessageDisplaynameRemoved(
          displayName: host.displayName,
        ),
      HostTeamHostAction.transferOwnership =>
        l10n.hostsHostTeamManagementSectionSuccessmessageOwnershipTransferredToDisplayname(
          displayName: host.displayName,
        ),
    };
  }
}

Future<bool?> showHostTeamHostActionDialog({
  required BuildContext context,
  required HostTeamHostActionConfirmation confirmation,
}) {
  return showCatchAdaptiveDialog<bool>(
    context: context,
    title: confirmation.title(context.l10n),
    message: confirmation.message(context.l10n),
    actions: confirmation.actions(context.l10n),
  );
}

class HostTeamHostActionDialog extends StatelessWidget {
  const HostTeamHostActionDialog({super.key, required this.confirmation});

  final HostTeamHostActionConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    return CatchConfirmDialog<bool>(
      title: confirmation.title(context.l10n),
      message: confirmation.message(context.l10n),
      actions: confirmation.actions(context.l10n),
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
          tooltip:
              context.l10n.hostsHostTeamManagementSectionTooltipHostActions,
          enabled: canManage,
          icon: CatchIcons.moreHorizRounded,
          onSelected: (value) {
            if (value ==
                context.l10n.hostsHostTeamManagementSectionVisiblecopyTransfer)
              onTransfer();
            if (value ==
                context.l10n.hostsHostTeamManagementSectionVisiblecopyRemove)
              onRemove();
          },
          items: [
            CatchActionMenuItem(
              value: context
                  .l10n
                  .hostsHostTeamManagementSectionVisiblecopyTransfer,
              label: context
                  .l10n
                  .hostsHostTeamManagementSectionLabelTransferOwnership,
              icon: CatchIcons.adminPanelSettingsOutlined,
            ),
            CatchActionMenuItem(
              value:
                  context.l10n.hostsHostTeamManagementSectionVisiblecopyRemove,
              label: context.l10n.hostsHostTeamManagementSectionLabelRemoveHost,
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
          _errorMessage = appErrorMessage(
            error,
            l10n: context.l10n,
            context: AppErrorContext.club,
          );
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
      title: context.l10n.hostsHostTeamManagementSectionTitleAddHost,
      subtitle: context
          .l10n
          .hostsHostTeamManagementSectionSubtitleEnterThePhoneNumber,
      keyboardSafe: true,
      action: CatchButton(
        label: context.l10n.hostsHostTeamManagementSectionLabelAddHost,
        onPressed: isSaving ? null : () => unawaited(_submit()),
        isLoading: isSaving,
        fullWidth: true,
        icon: Icon(CatchIcons.personAddAlt1Rounded),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchField.input(
            title: context.l10n.hostsHostTeamManagementSectionTitlePhoneNumber,
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
