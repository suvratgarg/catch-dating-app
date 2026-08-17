import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_field_accordion.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Composes route operations independently from the event's broader format.
///
/// Runs, walks, crawls, rides, and custom moving events share these controls;
/// the selected activity only supplies a useful starting preset.
class RouteEventPlanEditor extends StatefulWidget {
  const RouteEventPlanEditor({
    super.key,
    required this.activityKind,
    required this.plan,
    required this.onChanged,
  });

  final ActivityKind activityKind;
  final RouteEventPlan? plan;
  final ValueChanged<RouteEventPlan?> onChanged;

  @override
  State<RouteEventPlanEditor> createState() => _RouteEventPlanEditorState();
}

class _RouteEventPlanEditorState extends State<RouteEventPlanEditor> {
  static const _movementField = 'route-movement';
  static const _shapeField = 'route-shape';
  static const _groupField = 'route-group';
  static const _cadenceField = 'route-cadence';
  static const _stopsField = 'route-stops';
  static const _rolesField = 'route-roles';

  final CatchFieldAccordion _accordion = CatchFieldAccordion();

  @override
  void initState() {
    super.initState();
    _accordion.addListener(_handleAccordionChanged);
  }

  @override
  void dispose() {
    _accordion
      ..removeListener(_handleAccordionChanged)
      ..dispose();
    super.dispose();
  }

  void _handleAccordionChanged() {
    if (mounted) setState(() {});
  }

  void _setOpen(String field, bool open) {
    if (open && !_accordion.isExpanded(field)) {
      _accordion.toggle(field);
    } else if (!open && _accordion.isExpanded(field)) {
      _accordion.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final accent = ActivityPalette.resolve(context, widget.activityKind).accent;
    return CatchSection.fieldRows(
      title: context.l10n.hostsRouteEventPlanSectionTitle,
      activityKind: widget.activityKind,
      children: [
        if (widget.activityKind == ActivityKind.openActivity)
          CatchField.toggle(
            key: CreateEventFormKeys.routePlanEnabled,
            title: context.l10n.hostsRouteEventPlanOptInTitle,
            body: context.l10n.hostsRouteEventPlanOptInBody,
            contractExemption:
                'Controls optional routePlan presence; nested fields use generated bindings.',
            value: plan != null,
            onChanged: (enabled) =>
                widget.onChanged(enabled ? RouteEventPlan.customWalk : null),
            icon: CatchIcons.routeOutlined,
            iconColor: accent,
          ),
        if (plan != null)
          CatchField.control(
            key: CreateEventFormKeys.routePlanSummary,
            title: context.l10n.hostsRouteEventPlanSummaryTitle,
            body: [
              _movementLabel(context, plan.movementMode),
              _groupLabel(context, plan.groupStrategy),
              _cadenceLabel(context, plan.stopCadence),
            ].join(' · '),
            contractExemption:
                'Disclosure for nested routePlan fields with generated bindings.',
            icon: CatchIcons.routeOutlined,
            iconColor: accent,
            control: CatchSection.containedFieldRows(
              children: [
                CatchField.choices<RouteMovementMode>(
                  key: CreateEventFormKeys.routeMovement,
                  title: context.l10n.hostsRouteEventPlanMovementTitle,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanMovementMode,
                  contractValue: (value) => value.name,
                  values: RouteMovementMode.values,
                  itemLabel: (value) => _movementLabel(context, value),
                  selected: {plan.movementMode},
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(movementMode: selection.single),
                  ),
                  open: _accordion.isExpanded(_movementField),
                  onOpenChanged: (open) => _setOpen(_movementField, open),
                  icon: CatchIcons.syncAltRounded,
                  iconColor: accent,
                ),
                CatchField.choices<RouteShape>(
                  key: CreateEventFormKeys.routeShape,
                  title: context.l10n.hostsRouteEventPlanShapeTitle,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanRouteShape,
                  contractValue: (value) => value.name,
                  values: RouteShape.values,
                  itemLabel: (value) => _shapeLabel(context, value),
                  selected: {plan.routeShape},
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(routeShape: selection.single),
                  ),
                  open: _accordion.isExpanded(_shapeField),
                  onOpenChanged: (open) => _setOpen(_shapeField, open),
                  icon: CatchIcons.mapOutlined,
                  iconColor: accent,
                ),
                CatchField.choices<RouteGroupStrategy>(
                  key: CreateEventFormKeys.routeGroupStrategy,
                  title: context.l10n.hostsRouteEventPlanGroupTitle,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanGroupStrategy,
                  contractValue: (value) => value.name,
                  values: RouteGroupStrategy.values,
                  itemLabel: (value) => _groupLabel(context, value),
                  selected: {plan.groupStrategy},
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(groupStrategy: selection.single),
                  ),
                  open: _accordion.isExpanded(_groupField),
                  onOpenChanged: (open) => _setOpen(_groupField, open),
                  icon: CatchIcons.groups2Outlined,
                  iconColor: accent,
                ),
                CatchField.choices<RouteStopCadence>(
                  key: CreateEventFormKeys.routeStopCadence,
                  title: context.l10n.hostsRouteEventPlanCadenceTitle,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanStopCadence,
                  contractValue: (value) => value.name,
                  values: RouteStopCadence.values,
                  itemLabel: (value) => _cadenceLabel(context, value),
                  selected: {plan.stopCadence},
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(stopCadence: selection.single),
                  ),
                  open: _accordion.isExpanded(_cadenceField),
                  onOpenChanged: (open) => _setOpen(_cadenceField, open),
                  icon: CatchIcons.ruleFolderOutlined,
                  iconColor: accent,
                ),
                CatchField.choices<RouteStopKind>(
                  key: CreateEventFormKeys.routeStopKinds,
                  title: context.l10n.hostsRouteEventPlanStopsTitle,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanStopKinds,
                  contractValue: (value) => value.name,
                  values: RouteStopKind.values,
                  itemLabel: (value) => _stopLabel(context, value),
                  selected: plan.stopKinds.toSet(),
                  multi: true,
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(
                      stopKinds: RouteStopKind.values
                          .where(selection.contains)
                          .toList(growable: false),
                    ),
                  ),
                  open: _accordion.isExpanded(_stopsField),
                  onOpenChanged: (open) => _setOpen(_stopsField, open),
                  icon: CatchIcons.tableRestaurantOutlined,
                  iconColor: accent,
                ),
                CatchField.choices<RouteRoleKind>(
                  key: CreateEventFormKeys.routeRoleKinds,
                  title: context.l10n.hostsRouteEventPlanRolesTitle,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanRoleKinds,
                  contractValue: (value) => value.name,
                  values: RouteRoleKind.values,
                  itemLabel: (value) => _roleLabel(context, value),
                  selected: plan.roleKinds.toSet(),
                  multi: true,
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(
                      roleKinds: RouteRoleKind.values
                          .where(selection.contains)
                          .toList(growable: false),
                    ),
                  ),
                  open: _accordion.isExpanded(_rolesField),
                  onOpenChanged: (open) => _setOpen(_rolesField, open),
                  icon: CatchIcons.peopleOutline,
                  iconColor: accent,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _movementLabel(BuildContext context, RouteMovementMode value) =>
      switch (value) {
        RouteMovementMode.run => context.l10n.hostsRouteEventPlanMovementRun,
        RouteMovementMode.walk => context.l10n.hostsRouteEventPlanMovementWalk,
        RouteMovementMode.ride => context.l10n.hostsRouteEventPlanMovementRide,
        RouteMovementMode.mixed =>
          context.l10n.hostsRouteEventPlanMovementMixed,
      };

  String _shapeLabel(BuildContext context, RouteShape value) => switch (value) {
    RouteShape.loop => context.l10n.hostsRouteEventPlanShapeLoop,
    RouteShape.outAndBack => context.l10n.hostsRouteEventPlanShapeOutAndBack,
    RouteShape.pointToPoint =>
      context.l10n.hostsRouteEventPlanShapePointToPoint,
  };

  String _groupLabel(BuildContext context, RouteGroupStrategy value) =>
      switch (value) {
        RouteGroupStrategy.together =>
          context.l10n.hostsRouteEventPlanGroupTogether,
        RouteGroupStrategy.paceGroups =>
          context.l10n.hostsRouteEventPlanGroupPaceGroups,
        RouteGroupStrategy.selfDirected =>
          context.l10n.hostsRouteEventPlanGroupSelfDirected,
      };

  String _cadenceLabel(BuildContext context, RouteStopCadence value) =>
      switch (value) {
        RouteStopCadence.continuous =>
          context.l10n.hostsRouteEventPlanCadenceContinuous,
        RouteStopCadence.flexibleStops =>
          context.l10n.hostsRouteEventPlanCadenceFlexible,
        RouteStopCadence.hostedStops =>
          context.l10n.hostsRouteEventPlanCadenceHosted,
      };

  String _stopLabel(
    BuildContext context,
    RouteStopKind value,
  ) => switch (value) {
    RouteStopKind.water => context.l10n.hostsRouteEventPlanStopWater,
    RouteStopKind.regroup => context.l10n.hostsRouteEventPlanStopRegroup,
    RouteStopKind.venue => context.l10n.hostsRouteEventPlanStopVenue,
    RouteStopKind.photoSpot => context.l10n.hostsRouteEventPlanStopPhoto,
    RouteStopKind.viewpoint => context.l10n.hostsRouteEventPlanStopViewpoint,
    RouteStopKind.hazard => context.l10n.hostsRouteEventPlanStopHazard,
    RouteStopKind.turnaround => context.l10n.hostsRouteEventPlanStopTurnaround,
  };

  String _roleLabel(BuildContext context, RouteRoleKind value) =>
      switch (value) {
        RouteRoleKind.routeLead => context.l10n.hostsRouteEventPlanRoleLead,
        RouteRoleKind.sweep => context.l10n.hostsRouteEventPlanRoleSweep,
        RouteRoleKind.pacer => context.l10n.hostsRouteEventPlanRolePacer,
        RouteRoleKind.stopHost => context.l10n.hostsRouteEventPlanRoleStopHost,
        RouteRoleKind.marshal => context.l10n.hostsRouteEventPlanRoleMarshal,
        RouteRoleKind.photographer =>
          context.l10n.hostsRouteEventPlanRolePhotographer,
      };
}
