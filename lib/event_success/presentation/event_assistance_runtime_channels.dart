import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_configuration.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_draft.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_sender.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_runtime_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Explicit channel order with named, server-reviewed sender choices.
class EventAssistanceRuntimeChannels extends StatelessWidget {
  const EventAssistanceRuntimeChannels({
    super.key,
    required this.draft,
    required this.choices,
    required this.moreRoutes,
    required this.enabled,
    required this.onChanged,
    required this.onMore,
    this.loadingRoute,
  });
  final AssistanceRuntimeDraft draft;
  final List<AssistanceRuntimeSenderChoice> choices;
  final Set<AssistanceMessageRoute> moreRoutes;
  final AssistanceMessageRoute? loadingRoute;
  final bool enabled;
  final ValueChanged<AssistanceRuntimeDraft> onChanged;
  final ValueChanged<AssistanceMessageRoute> onMore;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.eventAssistanceRuntimeChannels,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        gapH8,
        Text(
          l.eventAssistanceRuntimeChannelBody,
          style: CatchTextStyles.supporting(context),
        ),
        CatchSection.fieldRows(
          first: true,
          children: [
            for (var i = 0; i < 3 && i <= draft.routes.length; i++)
              _EventAssistanceRuntimeChannel(
                index: i,
                draft: draft,
                choices: choices,
                enabled: enabled,
                onChanged: onChanged,
              ),
          ],
        ),
        if (choices.every((c) => !c.canSelect)) ...[
          gapH12,
          Text(
            l.eventAssistanceRuntimeNoSenders,
            style: CatchTextStyles.supporting(context),
          ),
        ],
        for (final c in choices.where((c) => !c.canSelect)) ...[
          gapH8,
          Text(
            '${runtimeSenderLabel(l, c)}\n${runtimeSenderIssue(l, c.availability)}',
            style: CatchTextStyles.supporting(context),
          ),
        ],
        for (final route in moreRoutes)
          CatchButton(
            key: ValueKey('runtime.more.${route.name}'),
            label: switch (route) {
              AssistanceMessageRoute.catchEventSms =>
                l.eventAssistanceRuntimeMoreSms,
              AssistanceMessageRoute.catchEventRcs =>
                l.eventAssistanceRuntimeMoreRcs,
              AssistanceMessageRoute.organizerEventWhatsapp =>
                l.eventAssistanceRuntimeMoreWhatsapp,
            },
            variant: CatchButtonVariant.ghost,
            onPressed: enabled && loadingRoute == null
                ? () => onMore(route)
                : null,
          ),
        if (loadingRoute != null) const CatchSkeleton.rows(count: 1),
      ],
    );
  }
}

class _EventAssistanceRuntimeChannel extends StatelessWidget {
  const _EventAssistanceRuntimeChannel({
    required this.index,
    required this.draft,
    required this.choices,
    required this.enabled,
    required this.onChanged,
  });

  final int index;
  final AssistanceRuntimeDraft draft;
  final List<AssistanceRuntimeSenderChoice> choices;
  final bool enabled;
  final ValueChanged<AssistanceRuntimeDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final saved = index < draft.routes.length ? draft.routes[index] : null;
    final selected = saved == null
        ? null
        : choices
              .where(
                (c) => c.route == saved.route && c.senderId == saved.senderId,
              )
              .firstOrNull;
    final options = <String, AssistanceRuntimeSenderChoice>{
      for (final c in choices)
        if (c.canSelect &&
            !draft.routes.indexed.any(
              (r) => r.$1 != index && r.$2.route == c.route,
            ))
          '${c.route.name}:${c.senderId}': c,
    };
    final id = selected == null
        ? null
        : '${selected.route.name}:${selected.senderId}';
    return CatchFieldLanes.single(
      child: CatchField<String>.select(
        copy: catchFieldCopy(l),
        key: ValueKey('runtime.channel.$index'),
        title: [
          l.eventAssistanceRuntimeFirst,
          l.eventAssistanceRuntimeSecond,
          l.eventAssistanceRuntimeThird,
        ][index],
        contractExemption:
            'Maps reviewed eligible sender identities to a unique ordered runtime route list; labels never become sender IDs.',
        values: ['off', ...options.keys],
        value: saved == null
            ? 'off'
            : options.containsKey(id)
            ? id
            : null,
        itemLabelBuilder: (v) => v == 'off'
            ? l.eventAssistanceRuntimeNone
            : runtimeSenderLabel(l, options[v]!),
        helperText: saved == null
            ? null
            : selected == null || !selected.canSelect
            ? l.eventAssistanceRuntimeSenderMissing
            : selected.displayAddress,
        onChanged: enabled
            ? (v) {
                if (v != null) {
                  onChanged(
                    draft.withRoute(index, v == 'off' ? null : options[v]!),
                  );
                }
              }
            : null,
        states: {if (!enabled) WidgetState.disabled},
      ),
    );
  }
}
