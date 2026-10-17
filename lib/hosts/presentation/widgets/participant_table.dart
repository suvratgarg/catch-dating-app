import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// One count tile for host roster filters.
class ParticipantStat {
  const ParticipantStat({
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

/// The action cell of a [ParticipantRow] — button / decide pair / badge / text.
sealed class ParticipantAction {
  const ParticipantAction();
}

class ParticipantButtonAction extends ParticipantAction {
  const ParticipantButtonAction({
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

class ParticipantDecideAction extends ParticipantAction {
  const ParticipantDecideAction({
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

class ParticipantBadgeAction extends ParticipantAction {
  const ParticipantBadgeAction({required this.label, this.tone});

  final String label;
  final CatchBadgeTone? tone;
}

class ParticipantTextAction extends ParticipantAction {
  const ParticipantTextAction(this.value);

  final String value;
}

/// Design-system `RosterRow` (`components/hosting/RosterBoard`): one participant —
/// avatar, condensed name over a mono meta line, a signal [CatchBadge], and a
/// spec-driven [action] cell. Columns are fixed 5/3/3 to match [ParticipantTable].
class ParticipantRow extends StatelessWidget {
  const ParticipantRow({
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
  final ParticipantAction? action;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Padding(
        padding: CatchInsets.rosterRowContent,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  CatchAvatar(
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
                child: ParticipantRowAction(action: action),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantRowAction extends StatelessWidget {
  const ParticipantRowAction({super.key, required this.action});

  final ParticipantAction? action;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return switch (action) {
      null => const SizedBox.shrink(),
      ParticipantTextAction(:final value) => Text(
        value,
        style: CatchTextStyles.mono(
          context,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
      ParticipantBadgeAction(:final label, :final tone) => CatchBadge(
        label: label,
        tone: tone ?? CatchBadgeTone.neutral,
        size: CatchBadgeSize.action,
      ),
      ParticipantDecideAction(
        :final onApprove,
        :final onDecline,
        :final onProfile,
      ) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onProfile != null) ...[
              ParticipantDecisionButton(
                icon: CatchIcons.eye,
                color: t.ink2,
                onTap: onProfile,
                label: context.l10n.hostsCatchRosterBoardLabelOpenProfile,
              ),
              const SizedBox(width: CatchSpacing.micro6),
            ],
            ParticipantDecisionButton(
              icon: CatchIcons.check,
              color: t.success,
              onTap: onApprove,
              label: context.l10n.hostsCatchRosterBoardLabelApproveRequest,
            ),
            const SizedBox(width: CatchSpacing.micro6),
            ParticipantDecisionButton(
              icon: CatchIcons.close,
              color: t.danger,
              onTap: onDecline,
              label: context.l10n.hostsCatchRosterBoardLabelDeclineRequest,
            ),
          ],
        ),
      ParticipantButtonAction(
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
          leading: icon == null ? null : Icon(icon),
          onPressed: disabled ? null : onPressed,
        ),
    };
  }
}

class ParticipantDecisionButton extends StatelessWidget {
  const ParticipantDecisionButton({
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
    return CatchIconAction(
      onPressed: onTap,
      status: (onTap == null)
          ? CatchIconActionStatus.disabled
          : CatchIconActionStatus.enabled,
      variant: CatchIconActionVariant.plain,
      backgroundColor: t.surface,
      borderColor: color.withValues(alpha: CatchOpacity.mutedBorderUrgent),
      size: CatchLayout.rosterDecideTargetExtent,
      tooltip: label,
      child: Icon(icon, size: CatchIcon.sm, color: color),
    );
  }
}

/// Design-system `RosterTable` (`components/hosting/RosterBoard`): the hairline
/// table shell — three mono column headers (identity / signal / action) at fixed
/// 5/3/3 proportions, [ParticipantRow] children, and a built-in empty state.
class ParticipantTable extends StatelessWidget {
  const ParticipantTable({
    super.key,
    required this.columns,
    this.rows = const [],
    this.showEmpty = false,
    this.emptyTitle,
    this.emptyMessage,
  });

  final List<String> columns;
  final List<ParticipantRow> rows;
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

    return CatchViewport.atWidth(
      breakpoint: ComponentBreakpoints.hostRosterTableCompactBreakpoint,
      compactBuilder: (context) {
        if (showEmpty) {
          return CatchEmptyState(
            surface: true,
            variant: CatchEmptyStateVariant.inline,
            icon: CatchIcons.group,
            title: emptyTitle,
            message: emptyMessage,
            padding: CatchInsets.content,
          );
        }
        return CatchSection.containedRows(
          children: [
            for (final indexedRow in rows.indexed)
              CatchField.read(
                content: CatchPersonLayout(
                  name: indexedRow.$2.person,
                  imageUrl: indexedRow.$2.imageUrl,
                  supportingText: indexedRow.$2.meta,
                  context: switch (indexedRow.$2.action) {
                    ParticipantTextAction(:final value) => value,
                    _ => null,
                  },
                  badges: [
                    if (indexedRow.$2.signal case final signal?
                        when signal.isNotEmpty)
                      CatchRowBadge(label: signal, tone: indexedRow.$2.tone),
                    if (indexedRow.$2.action case ParticipantBadgeAction(
                      :final label,
                      :final tone,
                    ))
                      CatchRowBadge(
                        label: label,
                        tone: tone ?? CatchBadgeTone.neutral,
                      ),
                  ],
                ),
                secondaryAction: rosterFieldActions(
                  context,
                  indexedRow.$2.action,
                ),
              ),
          ],
        );
      },
      expandedBuilder: (context) => CatchSurface(
        radius: CatchRadius.md,
        backgroundColor: t.surface,
        borderColor: t.line2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: CatchInsets.rosterHeaderContent,
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
                  padding: CatchInsets.rosterEmptyContent,
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
                                style: CatchTextStyles.supporting(context),
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

CatchFieldSecondaryAction? rosterFieldActions(
  BuildContext context,
  ParticipantAction? action,
) => switch (action) {
  ParticipantButtonAction(
    :final label,
    :final buttonKey,
    :final disabled,
    :final onPressed,
  ) =>
    CatchFieldSecondaryAction.button(
      key: buttonKey,
      label: label,
      onActivate: disabled ? null : onPressed,
    ),
  ParticipantDecideAction(
    :final onApprove,
    :final onDecline,
    :final onProfile,
  ) =>
    CatchFieldSecondaryAction.group([
      if (onProfile != null)
        CatchFieldSecondaryAction.button(
          label: context.l10n.hostsCatchRosterBoardLabelOpenProfile,
          onActivate: onProfile,
        ),
      CatchFieldSecondaryAction.button(
        label: context.l10n.hostsCatchRosterBoardLabelApproveRequest,
        onActivate: onApprove,
      ),
      CatchFieldSecondaryAction.button(
        label: context.l10n.hostsCatchRosterBoardLabelDeclineRequest,
        onActivate: onDecline,
      ),
    ]),
  _ => null,
};
