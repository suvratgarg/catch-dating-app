import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_team_management_controller.dart';
import 'package:flutter/material.dart';
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
    final addPending = ref
        .watch(HostTeamManagementController.addHostMutation)
        .isPending;
    final removePending = ref
        .watch(HostTeamManagementController.removeHostMutation)
        .isPending;
    final transferPending = ref
        .watch(HostTeamManagementController.transferOwnershipMutation)
        .isPending;
    final actionPending = addPending || removePending || transferPending;

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionHeader(title: 'Host team')),
              IconButton.filledTonal(
                tooltip: 'Add host',
                onPressed: actionPending
                    ? null
                    : () => unawaited(_showAddHostSheet(context)),
                icon: Icon(CatchIcons.personAddAlt1Rounded),
              ),
            ],
          ),
          gapH12,
          for (final host in hosts) ...[
            _OwnerHostRow(
              host: host,
              canManage: host.uid != currentUid && !actionPending,
              onTransfer: () => unawaited(_confirmTransfer(context, ref, host)),
              onRemove: () => unawaited(_confirmRemove(context, ref, host)),
            ),
            if (host != hosts.last) gapH10,
          ],
        ],
      ),
    );
  }

  Future<void> _showAddHostSheet(BuildContext context) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddHostSheet(clubId: club.id),
    );
    if (added == true && context.mounted) {
      showCatchSuccessSnackBar(context, 'Host added.');
    }
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    ClubHostProfile host,
  ) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Remove host?',
      message:
          '${host.displayName} will stay a club member but will lose host tools.',
      actions: const [
        CatchDialogAction(label: 'Cancel', value: false),
        CatchDialogAction(label: 'Remove', value: true, isDestructive: true),
      ],
    );
    if (confirmed != true) return;

    await HostTeamManagementController.removeHostMutation.run(
      ref,
      (tx) => tx
          .get(hostTeamManagementControllerProvider.notifier)
          .removeHost(clubId: club.id, uid: host.uid),
    );
    if (!context.mounted) return;
    showCatchSuccessSnackBar(context, '${host.displayName} removed.');
  }

  Future<void> _confirmTransfer(
    BuildContext context,
    WidgetRef ref,
    ClubHostProfile host,
  ) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Transfer ownership?',
      message:
          '${host.displayName} will become the club owner. You will remain a host.',
      actions: const [
        CatchDialogAction(label: 'Cancel', value: false),
        CatchDialogAction(label: 'Transfer', value: true, isDefault: true),
      ],
    );
    if (confirmed != true) return;

    await HostTeamManagementController.transferOwnershipMutation.run(
      ref,
      (tx) => tx
          .get(hostTeamManagementControllerProvider.notifier)
          .transferOwnership(clubId: club.id, uid: host.uid),
    );
    if (!context.mounted) return;
    showCatchSuccessSnackBar(
      context,
      'Ownership transferred to ${host.displayName}.',
    );
  }
}

class _OwnerHostRow extends StatelessWidget {
  const _OwnerHostRow({
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
        ClubHostAvatar(
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

class _AddHostSheet extends ConsumerStatefulWidget {
  const _AddHostSheet({required this.clubId});

  final String clubId;

  @override
  ConsumerState<_AddHostSheet> createState() => _AddHostSheetState();
}

class _AddHostSheetState extends ConsumerState<_AddHostSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty) return;
    await HostTeamManagementController.addHostMutation.run(
      ref,
      (tx) => tx
          .get(hostTeamManagementControllerProvider.notifier)
          .addHostByPhone(clubId: widget.clubId, phoneNumber: phone),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(HostTeamManagementController.addHostMutation);

    return CatchBottomSheetScaffold(
      title: 'Add host',
      subtitle: 'Enter the phone number on their Catch profile.',
      keyboardSafe: true,
      action: CatchButton(
        label: 'Add host',
        onPressed: mutation.isPending ? null : () => unawaited(_submit()),
        isLoading: mutation.isPending,
        fullWidth: true,
        icon: Icon(CatchIcons.personAddAlt1Rounded),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchTextField(
            label: 'Phone number',
            controller: _controller,
            prefixIcon: Icon(CatchIcons.phoneOutlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => unawaited(_submit()),
          ),
          if (mutation.hasError) ...[
            gapH12,
            ErrorBanner(message: mutationErrorMessage(mutation)),
          ],
        ],
      ),
    );
  }
}
