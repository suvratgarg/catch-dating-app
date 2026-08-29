import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Interactive production transition reference.
///
/// This page intentionally owns no interaction painter or animation timeline.
/// Every frame comes from CatchField/CatchSection, so a regression here is the
/// same regression users receive in the app.
@widgetbook.UseCase(
  name: 'Production interaction transitions',
  type: CatchSection,
  path: '[Geometry system]',
)
Widget fieldTransitionPrototype(BuildContext context) {
  return const _ProductionInteractionTransitionPage();
}

class _ProductionInteractionTransitionPage extends StatefulWidget {
  const _ProductionInteractionTransitionPage();

  @override
  State<_ProductionInteractionTransitionPage> createState() =>
      _ProductionInteractionTransitionPageState();
}

class _ProductionInteractionTransitionPageState
    extends State<_ProductionInteractionTransitionPage> {
  bool _containedOpen = false;
  bool _dividedOpen = false;
  Set<String> _containedSelection = const {'Catch Hosts'};
  Set<String> _dividedSelection = const {'Two hours before'};

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchScreenBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Production field transitions',
            style: CatchTextStyles.headline(context, color: t.ink),
          ),
          const SizedBox(height: CatchSpacing.s2),
          Text(
            'Press, hold, release, select, and close each real field. There is no prototype timeline: the two samples execute the production motion and geometry directly.',
            style: CatchTextStyles.proseM(context, color: t.ink2),
          ),
          const SizedBox(height: CatchSpacing.s6),
          CatchResponsiveSectionLayout(
            composition: CatchResponsiveSectionComposition.adaptiveTwoColumn,
            sections: [
              CatchResponsiveSectionItem(
                child: _labelledSection(
                  context,
                  title: 'Contained section',
                  description:
                      'One rounded section perimeter clips rectangular active bands.',
                  section: CatchSection.containedFieldRows(
                    title: 'Event settings',
                    headerPlacement: CatchSectionHeaderPlacement.inside,
                    children: [
                      CatchField.choices<String>(
                        title: 'Host',
                        icon: CatchIcons.hosted,
                        values: const [
                          'Catch Hosts',
                          'Sunday Social',
                          'Bandra Runs',
                        ],
                        itemLabel: _identity,
                        selected: _containedSelection,
                        onSelectionChanged: (selection) => setState(
                          () =>
                              _containedSelection = Set.unmodifiable(selection),
                        ),
                        open: _containedOpen,
                        onOpenChanged: (open) =>
                            setState(() => _containedOpen = open),
                      ),
                      CatchField.nav(
                        title: 'Location',
                        body: 'Carter Road promenade',
                        icon: CatchIcons.pinOutlined,
                        onTap: _noop,
                      ),
                    ],
                  ),
                ),
              ),
              CatchResponsiveSectionItem(
                lane: CatchResponsiveSectionLane.secondary,
                child: _labelledSection(
                  context,
                  title: 'Divided section',
                  description:
                      'Compact pages use a full-bleed band; split panes automatically choose the bounded rounded tile.',
                  section: CatchSection.fieldRows(
                    title: 'Notifications',
                    first: true,
                    children: [
                      CatchField.choices<String>(
                        title: 'Reminder timing',
                        icon: CatchIcons.clock,
                        values: const [
                          'Two hours before',
                          'One day before',
                          'Off',
                        ],
                        itemLabel: _identity,
                        selected: _dividedSelection,
                        onSelectionChanged: (selection) => setState(
                          () => _dividedSelection = Set.unmodifiable(selection),
                        ),
                        open: _dividedOpen,
                        onOpenChanged: (open) =>
                            setState(() => _dividedOpen = open),
                      ),
                      CatchField.nav(
                        title: 'Delivery',
                        body: 'Push and email',
                        icon: CatchIcons.notificationsOutlined,
                        onTap: _noop,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _labelledSection(
  BuildContext context, {
  required String title,
  required String description,
  required Widget section,
}) {
  final t = CatchTokens.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: CatchTextStyles.labelL(context, color: t.ink)),
      const SizedBox(height: CatchSpacing.s1),
      Text(
        description,
        style: CatchTextStyles.supporting(context, color: t.ink2),
      ),
      const SizedBox(height: CatchSpacing.s3),
      section,
    ],
  );
}

String _identity(String value) => value;
void _noop() {}
