import 'dart:async';

import 'package:catch_dating_app/chats/domain/suvbot_action_item.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SuvbotActionCallback = Future<void> Function(SuvbotActionItem action);
typedef SuvbotTextActionCallback =
    Future<void> Function(SuvbotActionItem action, String text);

const EdgeInsets _demoActionSheetPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s3,
  0,
  CatchSpacing.s3,
  CatchSpacing.s4,
);

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
        data: (items) {
          final t = CatchTokens.of(context);
          final colors = Theme.of(context).colorScheme;
          final byId = {for (final action in items) action.id: action};
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
                          style: CatchTextStyles.sectionTitle(
                            context,
                            color: t.ink,
                          ),
                        ),
                        gapH2,
                        Text(
                          'No typing needed',
                          style: CatchTextStyles.statusLabel(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (helpAction != null)
                    Semantics(
                      label: helpAction.label,
                      button: true,
                      child: Tooltip(
                        message: helpAction.label,
                        child: CatchIconButton(
                          size: CatchLayout.suvbotCircleActionExtent,
                          background: t.surface,
                          disabled: pending,
                          onTap: pending
                              ? null
                              : () => unawaited(onAction(helpAction)),
                          child: Icon(
                            CatchIcons.helpOutlineRounded,
                            size: CatchIcon.md,
                            color: pending ? t.ink3 : t.ink2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: CatchSpacing.s2),
              Row(
                children: [
                  if (checkAction != null)
                    Expanded(
                      child: CatchButton(
                        label: checkAction.label,
                        onPressed: pending
                            ? null
                            : () => unawaited(onAction(checkAction)),
                        variant: CatchButtonVariant.secondary,
                        size: CatchButtonSize.sm,
                        fullWidth: true,
                        isLoading: pending,
                        icon: Icon(_iconFor(checkAction.icon)),
                        foregroundColor: t.accent,
                        backgroundColor: t.accent.withValues(
                          alpha: CatchOpacity.subtleFill,
                        ),
                        borderColor: t.line,
                      ),
                    ),
                  if (checkAction != null && refreshAction != null)
                    const SizedBox(width: CatchSpacing.s2),
                  if (refreshAction != null)
                    Expanded(
                      child: CatchButton(
                        label: 'Refresh all',
                        onPressed: pending
                            ? null
                            : () => unawaited(onAction(refreshAction)),
                        variant: CatchButtonVariant.danger,
                        size: CatchButtonSize.sm,
                        fullWidth: true,
                        isLoading: pending,
                        icon: Icon(_iconFor(refreshAction.icon)),
                        foregroundColor: colors.error,
                        backgroundColor: colors.errorContainer.withValues(
                          alpha: CatchOpacity.suvbotDestructiveFill,
                        ),
                        borderColor: t.line,
                      ),
                    ),
                ],
              ),
              if (warmActions.isNotEmpty) ...[
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  'Create a test state',
                  style: CatchTextStyles.kicker(context),
                ),
                const SizedBox(height: CatchSpacing.s1),
                Row(
                  children: [
                    for (final (index, action) in warmActions.indexed) ...[
                      if (index > 0) const SizedBox(width: CatchSpacing.s1),
                      Expanded(
                        child: CatchButton(
                          label: _shortWarmLabel(action),
                          onPressed: pending
                              ? null
                              : () => unawaited(onAction(action)),
                          variant: CatchButtonVariant.secondary,
                          size: CatchButtonSize.sm,
                          fullWidth: true,
                          icon: Icon(_iconFor(action.icon)),
                          foregroundColor: t.ink,
                          backgroundColor: t.surface,
                          borderColor: t.line,
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
                      child: CatchButton(
                        label: matchAction.label,
                        onPressed: pending
                            ? null
                            : () => _showMatchTesterSheet(
                                context,
                                action: matchAction,
                                pending: pending,
                                onTextAction: onTextAction,
                              ),
                        variant: CatchButtonVariant.secondary,
                        size: CatchButtonSize.sm,
                        fullWidth: true,
                        isLoading: pending,
                        icon: Icon(_iconFor(matchAction.icon)),
                        foregroundColor: t.ink,
                        backgroundColor: t.surface,
                        borderColor: t.line,
                      ),
                    ),
                  if (matchAction != null && resetActions.isNotEmpty)
                    const SizedBox(width: CatchSpacing.s2),
                  if (resetActions.isNotEmpty)
                    Expanded(
                      child: CatchButton(
                        label: 'Reset...',
                        onPressed: pending
                            ? null
                            : () => _showResetSheet(
                                context,
                                actions: resetActions,
                                pending: pending,
                                onAction: onAction,
                              ),
                        variant: CatchButtonVariant.danger,
                        size: CatchButtonSize.sm,
                        fullWidth: true,
                        isLoading: pending,
                        icon: Icon(CatchIcons.cleaningServicesRounded),
                        foregroundColor: colors.error,
                        backgroundColor: colors.errorContainer.withValues(
                          alpha: CatchOpacity.suvbotDestructiveFill,
                        ),
                        borderColor: t.line,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: CatchLayout.suvbotLoadingControlsHeight,
          child: Center(child: CatchLoadingIndicator(strokeWidth: 2)),
        ),
        error: (_, _) {
          final t = CatchTokens.of(context);
          return CatchButton(
            label: 'Reload controls',
            onPressed: onRetry,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
            fullWidth: true,
            icon: Icon(CatchIcons.syncRounded),
            foregroundColor: t.ink,
            backgroundColor: t.surface,
            borderColor: t.line,
          );
        },
      ),
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
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: CatchBottomSheetScaffold(
          title: 'Reset demo state',
          subtitle: 'These actions only touch demo-owned data.',
          child: Builder(
            builder: (context) {
              final t = CatchTokens.of(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, action) in actions.indexed) ...[
                    SuvbotResetActionRow(
                      action: action,
                      pending: pending,
                      onTap: () {
                        Navigator.of(context).pop();
                        unawaited(onAction(action));
                      },
                    ),
                    if (index != actions.length - 1)
                      Divider(height: 1, color: t.line),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

// Public for Widgetbook.
class SuvbotResetActionRow extends StatelessWidget {
  const SuvbotResetActionRow({
    super.key,
    required this.action,
    required this.pending,
    required this.onTap,
  });

  final SuvbotActionItem action;
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final tone = action.destructive ? t.danger : t.ink;
    return AnimatedOpacity(
      opacity: pending ? CatchOpacity.disabledControl : 1,
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      child: CatchSurface(
        tone: CatchSurfaceTone.transparent,
        radius: 0,
        borderWidth: 0,
        onTap: pending ? null : onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s1,
          vertical: CatchSpacing.s3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.micro2),
              child: Icon(
                _iconFor(action.icon),
                color: tone,
                size: CatchIcon.row,
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action.label,
                    style: CatchTextStyles.fieldRowTitle(context, color: tone),
                  ),
                  gapH4,
                  Text(
                    action.description,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
              ),
            ),
            gapW12,
            Icon(
              CatchIcons.chevronRightRounded,
              color: action.destructive ? t.danger : t.ink3,
              size: CatchIcon.sm,
            ),
          ],
        ),
      ),
    );
  }
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
    builder: (context) => MatchTesterSheet(
      action: action,
      pending: pending,
      onTextAction: onTextAction,
    ),
  );
}

// Public for Widgetbook.
class MatchTesterSheet extends StatefulWidget {
  const MatchTesterSheet({
    super.key,
    required this.action,
    required this.pending,
    required this.onTextAction,
  });

  final SuvbotActionItem action;
  final bool pending;
  final SuvbotTextActionCallback onTextAction;

  @override
  State<MatchTesterSheet> createState() => _MatchTesterSheetState();
}

class _MatchTesterSheetState extends State<MatchTesterSheet> {
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
      padding: _demoActionSheetPadding.copyWith(
        bottom: MediaQuery.viewInsetsOf(context).bottom + CatchSpacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Match tester', style: CatchTextStyles.titleL(context)),
          const SizedBox(height: CatchSpacing.s1),
          Text(
            'Enter an allowlisted beta tester phone number.',
            style: CatchTextStyles.supporting(context),
          ),
          const SizedBox(height: CatchSpacing.s3),
          CatchField.input(
            title: 'Phone number',
            controller: _controller,
            keyboardType: TextInputType.phone,
            autofocus: true,
            placeholder: '+919999999999',
          ),
          const SizedBox(height: CatchSpacing.s3),
          CatchButton(
            onPressed: widget.pending ? null : _submit,
            icon: Icon(CatchIcons.personAddAlt1Rounded),
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
  'refresh' => CatchIcons.refreshRounded,
  'clean' => CatchIcons.cleaningServicesRounded,
  'event' => CatchIcons.eventAvailableRounded,
  'flag' => CatchIcons.flagRounded,
  'chat' => CatchIcons.forumRounded,
  'payment' => CatchIcons.paymentsRounded,
  'chatReset' => CatchIcons.forumOutlined,
  'eventReset' => CatchIcons.eventBusyRounded,
  'notifications' => CatchIcons.notificationsOffRounded,
  'personAdd' => CatchIcons.personAddAlt1Rounded,
  'check' => CatchIcons.factCheckOutlined,
  'help' => CatchIcons.helpOutlineRounded,
  _ => CatchIcons.autoAwesomeRounded,
};
