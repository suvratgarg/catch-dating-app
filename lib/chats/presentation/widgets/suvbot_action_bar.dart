import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuvbotActionBar extends StatelessWidget {
  const SuvbotActionBar({
    super.key,
    required this.actions,
    required this.pending,
    required this.onAction,
    required this.onRetry,
  });

  final AsyncValue<List<SuvbotActionItem>> actions;
  final bool pending;
  final ValueChanged<SuvbotActionItem> onAction;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final chips = actions.when(
      data: (items) => items
          .map(
            (action) => _SuvbotChip(
              label: action.label,
              icon: _iconFor(action.icon),
              pending: pending,
              destructive: action.destructive,
              onPressed: () => onAction(action),
            ),
          )
          .toList(growable: false),
      loading: () => const [_SuvbotStatusChip(label: 'Loading controls...')],
      error: (_, _) => [
        _SuvbotChip(
          label: 'Reload controls',
          icon: Icons.sync_rounded,
          pending: pending,
          onPressed: onRetry,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s3,
        CatchSpacing.s2,
        CatchSpacing.s3,
        CatchSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 112),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: chips,
          ),
        ),
      ),
    );
  }
}

class _SuvbotChip extends StatelessWidget {
  const _SuvbotChip({
    required this.label,
    required this.icon,
    required this.pending,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final bool pending;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      avatar: pending
          ? const SizedBox.square(
              dimension: 18,
              child: CatchLoadingIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 18, color: destructive ? colorScheme.error : null),
      label: Text(label),
      onPressed: pending ? null : onPressed,
    );
  }
}

class _SuvbotStatusChip extends StatelessWidget {
  const _SuvbotStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const SizedBox.square(
        dimension: 18,
        child: CatchLoadingIndicator(strokeWidth: 2),
      ),
      label: Text(label),
      onPressed: null,
    );
  }
}

IconData _iconFor(String icon) => switch (icon) {
  'refresh' => Icons.refresh_rounded,
  'clean' => Icons.cleaning_services_rounded,
  'event' => Icons.event_available_rounded,
  'flag' => Icons.flag_rounded,
  'chat' => Icons.forum_rounded,
  'payment' => Icons.payments_rounded,
  'chatReset' => Icons.forum_outlined,
  'eventReset' => Icons.event_busy_rounded,
  'notifications' => Icons.notifications_off_rounded,
  'personAdd' => Icons.person_add_alt_1_rounded,
  'check' => Icons.fact_check_outlined,
  'help' => Icons.help_outline_rounded,
  _ => Icons.auto_awesome_rounded,
};
