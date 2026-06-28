import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:flutter/material.dart';

/// Maps a [CatchBadgeTone] to its functional colour for roster tiles.
Color _rosterToneColor(CatchTokens t, CatchBadgeTone tone) => switch (tone) {
  CatchBadgeTone.success => t.success,
  CatchBadgeTone.warning => t.warning,
  CatchBadgeTone.danger => t.danger,
  CatchBadgeTone.gold => t.gold,
  CatchBadgeTone.solid => t.ink,
  CatchBadgeTone.neutral ||
  CatchBadgeTone.brand ||
  CatchBadgeTone.live => t.ink2,
};

/// One count tile in a [CatchRosterTiles] row.
class CatchRosterTile {
  const CatchRosterTile({
    required this.id,
    required this.value,
    required this.label,
    this.tone = CatchBadgeTone.neutral,
  });

  final String id;
  final String value;
  final String label;
  final CatchBadgeTone tone;
}

/// Design-system `RosterTiles` (`components/hosting/RosterTiles`): the selectable
/// count-tile row that filters a roster board. Each tile is a labelled count in a
/// functional tone; the selected tile flips to the ink fill.
class CatchRosterTiles extends StatelessWidget {
  const CatchRosterTiles({
    super.key,
    required this.items,
    this.selected,
    this.onSelect,
  });

  final List<CatchRosterTile> items;
  final String? selected;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: CatchSpacing.micro6),
          Expanded(
            child: CatchRosterTileCell(
              tile: items[i],
              selected: items[i].id == selected,
              onTap: onSelect == null ? null : () => onSelect!(items[i].id),
              toneColor: _rosterToneColor(t, items[i].tone),
            ),
          ),
        ],
      ],
    );
  }
}

class CatchRosterTileCell extends StatelessWidget {
  const CatchRosterTileCell({
    super.key,
    required this.tile,
    required this.selected,
    required this.onTap,
    required this.toneColor,
  });

  final CatchRosterTile tile;
  final bool selected;
  final VoidCallback? onTap;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final fill = selected
        ? t.ink
        : Color.alphaBlend(
            toneColor.withValues(alpha: CatchOpacity.calloutFill),
            t.surface,
          );
    final border = selected
        ? t.ink
        : toneColor.withValues(alpha: CatchOpacity.subtleBorder);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: CatchLayout.rosterFilterTileMinHeight,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(CatchRadius.md),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tile.value,
                style: CatchTextStyles.numericLarge(
                  context,
                  color: selected ? t.primaryInk : toneColor,
                ).copyWith(height: 1),
              ),
              const SizedBox(height: CatchSpacing.micro6),
              Text(
                tile.label.toUpperCase(),
                style: CatchTextStyles.monoLabel(
                  context,
                  color: selected
                      ? t.primaryInk.withValues(alpha: CatchOpacity.onFillMuted)
                      : t.ink2,
                ).copyWith(fontSize: 8.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The action cell of a [CatchRosterRow] — button / decide pair / badge / text.
sealed class CatchRosterAction {
  const CatchRosterAction();
}

class CatchRosterButtonAction extends CatchRosterAction {
  const CatchRosterButtonAction({
    required this.label,
    this.primary = false,
    this.icon,
    this.onPressed,
    this.disabled = false,
    this.buttonKey,
  });

  final String label;
  final bool primary;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool disabled;

  /// Optional [Key] forwarded to the inner button — lets callers keep stable
  /// test/automation handles (e.g. a per-attendee check-in button).
  final Key? buttonKey;
}

class CatchRosterDecideAction extends CatchRosterAction {
  const CatchRosterDecideAction({
    this.onApprove,
    this.onDecline,
    this.onProfile,
  });

  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  /// Optional leading peek target — the request-approval flow lets a host open
  /// the requester's profile before deciding. Omit for the pure two-target
  /// approve/decline pair. A `null` [onApprove]/[onDecline] dims that target
  /// (e.g. while a decision is pending) without hiding it.
  final VoidCallback? onProfile;
}

class CatchRosterBadgeAction extends CatchRosterAction {
  const CatchRosterBadgeAction({required this.label, this.tone});

  final String label;
  final CatchBadgeTone? tone;
}

class CatchRosterTextAction extends CatchRosterAction {
  const CatchRosterTextAction(this.value);

  final String value;
}

/// Design-system `RosterRow` (`components/hosting/RosterBoard`): one participant —
/// avatar, condensed name over a mono meta line, a signal [CatchBadge], and a
/// spec-driven [action] cell. Columns are fixed 5/3/3 to match [CatchRosterTable].
class CatchRosterRow extends StatelessWidget {
  const CatchRosterRow({
    super.key,
    required this.person,
    this.imageUrl,
    this.meta,
    this.signal,
    this.tone = CatchBadgeTone.neutral,
    this.action,
  });

  final String person;
  final String? imageUrl;
  final String? meta;
  final String? signal;
  final CatchBadgeTone tone;
  final CatchRosterAction? action;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.micro14,
          vertical: CatchSpacing.micro10,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  CatchPersonAvatar(
                    size: CatchLayout.rosterRowAvatarExtent,
                    name: person,
                    imageUrl: imageUrl,
                  ),
                  const SizedBox(width: CatchSpacing.micro10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          person,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.name(context),
                        ),
                        if (meta != null && meta!.isNotEmpty) ...[
                          const SizedBox(height: CatchSpacing.micro3),
                          Text(
                            meta!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.monoLabel(
                              context,
                              color: t.ink3,
                            ).copyWith(fontSize: 8),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: CatchSpacing.s2),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: signal == null
                    ? const SizedBox.shrink()
                    : CatchBadge(label: signal!, tone: tone),
              ),
            ),
            const SizedBox(width: CatchSpacing.s2),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: CatchRosterActionCell(action: action),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatchRosterActionCell extends StatelessWidget {
  const CatchRosterActionCell({super.key, required this.action});

  final CatchRosterAction? action;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return switch (action) {
      null => const SizedBox.shrink(),
      CatchRosterTextAction(:final value) => Text(
        value,
        style: CatchTextStyles.mono(
          context,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
      CatchRosterBadgeAction(:final label, :final tone) => CatchBadge(
        label: label,
        tone: tone ?? CatchBadgeTone.neutral,
        size: CatchBadgeSize.action,
      ),
      CatchRosterDecideAction(
        :final onApprove,
        :final onDecline,
        :final onProfile,
      ) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onProfile != null) ...[
              CatchRosterDecideTarget(
                icon: CatchIcons.eye,
                color: t.ink2,
                onTap: onProfile,
                label: 'Open profile',
              ),
              const SizedBox(width: CatchSpacing.micro6),
            ],
            CatchRosterDecideTarget(
              icon: CatchIcons.check,
              color: t.success,
              onTap: onApprove,
              label: 'Approve request',
            ),
            const SizedBox(width: CatchSpacing.micro6),
            CatchRosterDecideTarget(
              icon: CatchIcons.close,
              color: t.danger,
              onTap: onDecline,
              label: 'Decline request',
            ),
          ],
        ),
      CatchRosterButtonAction(
        :final label,
        :final primary,
        :final icon,
        :final onPressed,
        :final disabled,
        :final buttonKey,
      ) =>
        CatchButton(
          key: buttonKey,
          label: label,
          size: CatchButtonSize.sm,
          variant: primary
              ? CatchButtonVariant.primary
              : CatchButtonVariant.secondary,
          icon: icon == null ? null : Icon(icon),
          onPressed: disabled ? null : onPressed,
        ),
    };
  }
}

class CatchRosterDecideTarget extends StatelessWidget {
  const CatchRosterDecideTarget({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : CatchOpacity.disabledControl,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: CatchLayout.rosterDecideTargetExtent,
            height: CatchLayout.rosterDecideTargetExtent,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.surface,
              border: Border.all(
                color: color.withValues(alpha: CatchOpacity.mutedBorderUrgent),
              ),
            ),
            child: Icon(icon, size: CatchIcon.sm, color: color),
          ),
        ),
      ),
    );
  }
}

/// Design-system `RosterTable` (`components/hosting/RosterBoard`): the hairline
/// table shell — three mono column headers (identity / signal / action) at fixed
/// 5/3/3 proportions, [CatchRosterRow] children, and a built-in empty state.
class CatchRosterTable extends StatelessWidget {
  const CatchRosterTable({
    super.key,
    required this.columns,
    this.rows = const [],
    this.showEmpty = false,
    this.emptyTitle,
    this.emptyMessage,
  });

  final List<String> columns;
  final List<CatchRosterRow> rows;
  final bool showEmpty;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final headerStyle = CatchTextStyles.monoLabel(
      context,
      color: t.ink3,
    ).copyWith(fontSize: 8.5);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        border: Border.all(color: t.line2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.micro14,
                CatchSpacing.s3,
                CatchSpacing.micro14,
                CatchSpacing.micro10,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: CatchLayout.rosterHeaderIdentityInset,
                      ),
                      child: Text(
                        columns.isNotEmpty ? columns[0].toUpperCase() : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: headerStyle,
                      ),
                    ),
                  ),
                  const SizedBox(width: CatchSpacing.s2),
                  Expanded(
                    flex: 3,
                    child: Text(
                      columns.length > 1 ? columns[1].toUpperCase() : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: headerStyle,
                    ),
                  ),
                  const SizedBox(width: CatchSpacing.s2),
                  Expanded(
                    flex: 3,
                    child: Text(
                      columns.length > 2 ? columns[2].toUpperCase() : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: headerStyle,
                    ),
                  ),
                ],
              ),
            ),
            if (showEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: t.line)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.micro14,
                    CatchSpacing.s4,
                    CatchSpacing.micro14,
                    CatchSpacing.s5,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(CatchIcons.group, size: CatchIcon.md, color: t.ink3),
                      const SizedBox(width: CatchSpacing.micro10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emptyTitle ?? '',
                              style: CatchTextStyles.name(context),
                            ),
                            if (emptyMessage != null) ...[
                              const SizedBox(height: CatchSpacing.s1),
                              Text(
                                emptyMessage!,
                                style: CatchTextStyles.bodyS(context),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...rows,
          ],
        ),
      ),
    );
  }
}
