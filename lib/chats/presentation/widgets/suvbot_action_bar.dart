import 'dart:async';

import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SuvbotActionCallback = Future<void> Function(SuvbotActionItem action);
typedef SuvbotTextActionCallback =
    Future<void> Function(SuvbotActionItem action, String text);

class SuvbotActionBar extends StatelessWidget {
  const SuvbotActionBar({
    super.key,
    required this.actions,
    required this.pending,
    required this.onAction,
    required this.onTextAction,
    required this.onRetry,
  });

  final AsyncValue<List<SuvbotActionItem>> actions;
  final bool pending;
  final SuvbotActionCallback onAction;
  final SuvbotTextActionCallback onTextAction;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CatchBottomDock(
      child: actions.when(
        data: (items) => _SuvbotControls(
          actions: items,
          pending: pending,
          onAction: onAction,
          onTextAction: onTextAction,
        ),
        loading: () => const _SuvbotLoadingControls(),
        error: (_, _) => _SuvbotLoadError(onRetry: onRetry),
      ),
    );
  }
}

class _SuvbotControls extends StatelessWidget {
  const _SuvbotControls({
    required this.actions,
    required this.pending,
    required this.onAction,
    required this.onTextAction,
  });

  final List<SuvbotActionItem> actions;
  final bool pending;
  final SuvbotActionCallback onAction;
  final SuvbotTextActionCallback onTextAction;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final byId = {for (final action in actions) action.id: action};
    final warmActions = [
      byId['warmSignupState'],
      byId['warmPostEventState'],
      byId['warmChatState'],
      byId['warmPaymentState'],
    ].whereType<SuvbotActionItem>().toList(growable: false);
    final resetActions = [
      byId['resetChats'],
      byId['resetBookings'],
      byId['resetNotifications'],
      byId['clearDemoState'],
    ].whereType<SuvbotActionItem>().toList(growable: false);
    final checkAction = byId['checkDemoState'];
    final refreshAction = byId['refreshDemoState'];
    final helpAction = byId['help'];
    final matchAction = byId['matchTesterByPhone'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suvbot controls',
                    style: CatchTextStyles.sectionTitle(context, color: t.ink),
                  ),
                  gapH2,
                  Text(
                    'No typing needed',
                    style: CatchTextStyles.statusLabel(context, color: t.ink2),
                  ),
                ],
              ),
            ),
            if (helpAction != null)
              _CircleActionButton(
                icon: Icons.help_outline_rounded,
                label: helpAction.label,
                pending: pending,
                onPressed: () => unawaited(onAction(helpAction)),
              ),
          ],
        ),
        const SizedBox(height: CatchSpacing.s2),
        Row(
          children: [
            if (checkAction != null)
              Expanded(
                child: _SuvbotButton(
                  label: checkAction.label,
                  icon: _iconFor(checkAction.icon),
                  pending: pending,
                  prominent: true,
                  onPressed: () => unawaited(onAction(checkAction)),
                ),
              ),
            if (checkAction != null && refreshAction != null)
              const SizedBox(width: CatchSpacing.s2),
            if (refreshAction != null)
              Expanded(
                child: _SuvbotButton(
                  label: 'Refresh all',
                  icon: _iconFor(refreshAction.icon),
                  pending: pending,
                  destructive: true,
                  onPressed: () => unawaited(onAction(refreshAction)),
                ),
              ),
          ],
        ),
        if (warmActions.isNotEmpty) ...[
          const SizedBox(height: CatchSpacing.s3),
          const _SuvbotGroupLabel('Create a test state'),
          const SizedBox(height: CatchSpacing.s1),
          Row(
            children: [
              for (final (index, action) in warmActions.indexed) ...[
                if (index > 0) const SizedBox(width: CatchSpacing.s1),
                Expanded(
                  child: _SuvbotPresetButton(
                    label: _shortWarmLabel(action),
                    icon: _iconFor(action.icon),
                    pending: pending,
                    onPressed: () => unawaited(onAction(action)),
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: CatchSpacing.s2),
        Row(
          children: [
            if (matchAction != null)
              Expanded(
                child: _SuvbotButton(
                  label: matchAction.label,
                  icon: _iconFor(matchAction.icon),
                  pending: pending,
                  onPressed: () => _showMatchTesterSheet(
                    context,
                    action: matchAction,
                    pending: pending,
                    onTextAction: onTextAction,
                  ),
                ),
              ),
            if (matchAction != null && resetActions.isNotEmpty)
              const SizedBox(width: CatchSpacing.s2),
            if (resetActions.isNotEmpty)
              Expanded(
                child: _SuvbotButton(
                  label: 'Reset...',
                  icon: Icons.cleaning_services_rounded,
                  pending: pending,
                  destructive: true,
                  onPressed: () => _showResetSheet(
                    context,
                    actions: resetActions,
                    pending: pending,
                    onAction: onAction,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SuvbotButton extends StatelessWidget {
  const _SuvbotButton({
    required this.label,
    required this.icon,
    required this.pending,
    required this.onPressed,
    this.prominent = false,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final bool pending;
  final VoidCallback onPressed;
  final bool prominent;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final colors = Theme.of(context).colorScheme;
    final foreground = destructive
        ? colors.error
        : prominent
        ? t.accent
        : t.ink;
    final background = destructive
        ? colors.errorContainer.withValues(alpha: 0.24)
        : prominent
        ? t.accent.withValues(alpha: 0.12)
        : t.surface;

    return CatchButton(
      label: label,
      onPressed: pending ? null : onPressed,
      variant: destructive
          ? CatchButtonVariant.danger
          : CatchButtonVariant.secondary,
      size: CatchButtonSize.sm,
      fullWidth: true,
      isLoading: pending,
      icon: Icon(icon),
      foregroundColor: foreground,
      backgroundColor: background,
      borderColor: t.line,
    );
  }
}

class _SuvbotPresetButton extends StatelessWidget {
  const _SuvbotPresetButton({
    required this.label,
    required this.icon,
    required this.pending,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool pending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchButton(
      label: label,
      onPressed: pending ? null : onPressed,
      variant: CatchButtonVariant.secondary,
      size: CatchButtonSize.sm,
      fullWidth: true,
      icon: Icon(icon),
      foregroundColor: t.ink,
      backgroundColor: t.surface,
      borderColor: t.line,
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.label,
    required this.pending,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool pending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: label,
      child: SizedBox.square(
        dimension: 34,
        child: IconButton(
          onPressed: pending ? null : onPressed,
          icon: Icon(icon, size: 18),
          color: t.ink2,
          style: IconButton.styleFrom(
            backgroundColor: t.surface,
            side: BorderSide(color: t.line),
          ),
        ),
      ),
    );
  }
}

class _SuvbotGroupLabel extends StatelessWidget {
  const _SuvbotGroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: CatchTextStyles.kicker(context));
  }
}

class _SuvbotLoadingControls extends StatelessWidget {
  const _SuvbotLoadingControls();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 84,
      child: Center(child: CatchLoadingIndicator(strokeWidth: 2)),
    );
  }
}

class _SuvbotLoadError extends StatelessWidget {
  const _SuvbotLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SuvbotButton(
      label: 'Reload controls',
      icon: Icons.sync_rounded,
      pending: false,
      onPressed: onRetry,
    );
  }
}

Future<void> _showResetSheet(
  BuildContext context, {
  required List<SuvbotActionItem> actions,
  required bool pending,
  required SuvbotActionCallback onAction,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s3,
            0,
            CatchSpacing.s3,
            CatchSpacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset demo state',
                style: CatchTextStyles.cardTitle(context),
              ),
              const SizedBox(height: CatchSpacing.s1),
              Text(
                'These actions only touch demo-owned data.',
                style: CatchTextStyles.supporting(context),
              ),
              const SizedBox(height: CatchSpacing.s3),
              for (final action in actions) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_iconFor(action.icon)),
                  title: Text(
                    action.label,
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                  subtitle: Text(
                    action.description,
                    style: CatchTextStyles.supporting(context),
                  ),
                  enabled: !pending,
                  onTap: pending
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          unawaited(onAction(action));
                        },
                ),
                if (action != actions.last) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _showMatchTesterSheet(
  BuildContext context, {
  required SuvbotActionItem action,
  required bool pending,
  required SuvbotTextActionCallback onTextAction,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _MatchTesterSheet(
      action: action,
      pending: pending,
      onTextAction: onTextAction,
    ),
  );
}

class _MatchTesterSheet extends StatefulWidget {
  const _MatchTesterSheet({
    required this.action,
    required this.pending,
    required this.onTextAction,
  });

  final SuvbotActionItem action;
  final bool pending;
  final SuvbotTextActionCallback onTextAction;

  @override
  State<_MatchTesterSheet> createState() => _MatchTesterSheetState();
}

class _MatchTesterSheetState extends State<_MatchTesterSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        CatchSpacing.s3,
        0,
        CatchSpacing.s3,
        MediaQuery.viewInsetsOf(context).bottom + CatchSpacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Match tester', style: CatchTextStyles.cardTitle(context)),
          const SizedBox(height: CatchSpacing.s1),
          Text(
            'Enter an allowlisted beta tester phone number.',
            style: CatchTextStyles.supporting(context),
          ),
          const SizedBox(height: CatchSpacing.s3),
          CatchTextField(
            label: 'Phone number',
            controller: _controller,
            keyboardType: TextInputType.phone,
            autofocus: true,
            hintText: '+919999999999',
          ),
          const SizedBox(height: CatchSpacing.s3),
          CatchButton(
            onPressed: widget.pending ? null : _submit,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: 'Create match',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop();
    unawaited(widget.onTextAction(widget.action, value));
  }
}

String _shortWarmLabel(SuvbotActionItem action) => switch (action.id) {
  'warmSignupState' => 'Signups',
  'warmPostEventState' => 'Post-event',
  'warmChatState' => 'Chats',
  'warmPaymentState' => 'Payments',
  _ => action.label,
};

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
