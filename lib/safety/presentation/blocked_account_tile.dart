part of 'settings_screen.dart';

class BlockedAccountTile extends StatelessWidget {
  const BlockedAccountTile({
    super.key,
    required this.row,
    required this.divider,
    required this.unblocking,
    this.enabled = true,
    required this.onUnblock,
  });

  final SettingsBlockedAccountRow row;
  final bool divider;
  final bool unblocking;
  final bool enabled;
  final ValueChanged<String> onUnblock;

  @override
  Widget build(BuildContext context) {
    return CatchPersonRow(
      copy: catchPersonRowCopy(context.l10n),
      data: CatchPersonRowData(
        name: row.name,
        imageUrl: row.imageUrl,
        metaLine: row.metaLine,
        seed: row.seed,
      ),
      divider: divider,
      trailing: CatchButton(
        key: SettingsKeys.unblockButton(row.uid),
        label: context.l10n.safetySettingsScreenLabelUnblock,
        status: (unblocking)
            ? CatchButtonStatus.loading
            : CatchButtonStatus.idle,
        onPressed: !enabled || unblocking ? null : () => onUnblock(row.uid),
        variant: CatchButtonVariant.ghost,
        size: CatchButtonSize.sm,
      ),
    );
  }
}
