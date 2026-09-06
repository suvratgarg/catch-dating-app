import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_controller.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostEventRehearsalStartScreen extends ConsumerStatefulWidget {
  const HostEventRehearsalStartScreen({
    super.key,
    required this.clubId,
    this.sourceEventId,
  });

  final String clubId;
  final String? sourceEventId;

  @override
  ConsumerState<HostEventRehearsalStartScreen> createState() =>
      _HostEventRehearsalStartScreenState();
}

class _HostEventRehearsalStartScreenState
    extends ConsumerState<HostEventRehearsalStartScreen> {
  EventRehearsalScenario _scenario = EventRehearsalScenario.smoothRun;
  late int _actorCount = _scenario.defaultActorCount;

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(EventRehearsalController.createMutation);
    return CatchMutationErrorListener(
      mutation: EventRehearsalController.createMutation,
      errorContext: AppErrorContext.event,
      child: CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostEventRehearsalTitle,
          showBackButton: true,
          divider: scrolledUnder,
        ),
        body: CatchRouteBody.standardSections(
          sections: [
            CatchResponsiveSectionItem(
              child: CatchSection.plain(
                padding: EdgeInsets.zero,
                child: CatchSurface.message(
                  title: context.l10n.hostEventRehearsalTitle,
                  message: context.l10n.hostEventRehearsalPracticeBanner,
                  messageIcon: CatchIcons.scienceOutlined,
                ),
              ),
            ),
            CatchResponsiveSectionItem(
              child: CatchSection.plain(
                padding: EdgeInsets.zero,
                child: Text(
                  context.l10n.hostEventRehearsalStartSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            CatchResponsiveSectionItem(
              child: CatchSection.fieldRows(
                first: true,
                children: [
                  CatchField.read(
                    title: widget.sourceEventId == null
                        ? context.l10n.hostEventRehearsalSourceSample
                        : context.l10n.hostEventRehearsalSourceEvent,
                    body: context.l10n.hostEventRehearsalExpiry,
                    icon: CatchIcons.eventAvailable,
                  ),
                  CatchMenuAnchor<EventRehearsalScenario>(
                    items: [
                      for (final scenario in EventRehearsalScenario.values)
                        CatchMenuItem<EventRehearsalScenario>(
                          value: scenario,
                          label: eventRehearsalScenarioTitle(
                            context.l10n,
                            scenario,
                          ),
                          sublabel: eventRehearsalScenarioBody(
                            context.l10n,
                            scenario,
                          ),
                          selected: scenario == _scenario,
                          role: CatchMenuItemRole.choice,
                        ),
                    ],
                    onSelected: (scenario, _) {
                      setState(() {
                        _scenario = scenario;
                        _actorCount = scenario.defaultActorCount;
                      });
                    },
                    builder: (context, controller, _) => CatchFieldLanes.single(
                      child: CatchField.nav(
                        title: context.l10n.hostEventRehearsalScenario,
                        valueText: eventRehearsalScenarioTitle(
                          context.l10n,
                          _scenario,
                        ),
                        body: eventRehearsalScenarioBody(
                          context.l10n,
                          _scenario,
                        ),
                        onTap: controller.isOpen
                            ? controller.close
                            : controller.open,
                      ),
                    ),
                  ),
                  CatchMenuAnchor<int>(
                    items: [
                      for (final count in const [
                        8,
                        12,
                        14,
                        15,
                        16,
                        18,
                        24,
                        32,
                        50,
                      ])
                        CatchMenuItem<int>(
                          value: count,
                          label: context.l10n.hostEventRehearsalActorCount(
                            count: count,
                          ),
                          selected: count == _actorCount,
                          role: CatchMenuItemRole.choice,
                        ),
                    ],
                    onSelected: (count, _) =>
                        setState(() => _actorCount = count),
                    builder: (context, controller, _) => CatchFieldLanes.single(
                      child: CatchField.nav(
                        title: context.l10n.hostEventRehearsalActorCount(
                          count: _actorCount,
                        ),
                        body: context.l10n.hostEventRehearsalActorCountBody,
                        onTap: controller.isOpen
                            ? controller.close
                            : controller.open,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CatchResponsiveSectionItem(
              child: CatchSection.plain(
                padding: EdgeInsets.zero,
                child: CatchButton(
                  label: context.l10n.hostEventRehearsalCreate,
                  fullWidth: true,
                  isLoading: mutation.isPending,
                  icon: Icon(CatchIcons.playArrowRounded),
                  onPressed: mutation.isPending ? null : _create,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    late final EventRehearsalCreated created;
    try {
      created = await EventRehearsalController.createMutation.run(
        ref,
        (tx) => tx
            .get(eventRehearsalControllerProvider.notifier)
            .create(
              organizerId: widget.clubId,
              sourceEventId: widget.sourceEventId,
              scenario: _scenario,
              actorCount: _actorCount,
            ),
      );
    } on Object {
      return;
    }
    if (!mounted) return;
    context.goNamed(
      Routes.hostEventRehearsalScreen.name,
      pathParameters: {'clubId': widget.clubId, 'sessionId': created.sessionId},
    );
  }
}
