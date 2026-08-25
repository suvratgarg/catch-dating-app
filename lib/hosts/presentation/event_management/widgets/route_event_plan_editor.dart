import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_field_accordion.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/route_path_builder_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';

enum _PacePreset { social, steady, fast }

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
    required this.initialCenter,
    this.loadMapTiles = true,
  });

  final ActivityKind activityKind;
  final RouteEventPlan? plan;
  final ValueChanged<RouteEventPlan?> onChanged;
  final LocationCoordinate initialCenter;
  final bool loadMapTiles;

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
  static const _paceGroupsField = 'route-pace-groups';
  static const _trackingField = 'route-live-tracking';

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
                CatchField.action(
                  key: CreateEventFormKeys.routePath,
                  title: context.l10n.hostsRouteEventPlanPathTitle,
                  body: plan.path.length >= 2
                      ? context.l10n.hostsRouteEventPlanPathCount(
                          count: plan.path.length,
                        )
                      : context.l10n.hostsRouteEventPlanPathEmpty,
                  valueText: context.l10n.hostsRouteEventPlanPathAction,
                  icon: CatchIcons.mapOutlined,
                  iconColor: accent,
                  onTap: () => _editPath(plan),
                ),
                CatchField.choices<_PacePreset>(
                  key: CreateEventFormKeys.routePaceGroups,
                  title: context.l10n.hostsRouteEventPlanPaceGroupsTitle,
                  body: context.l10n.hostsRouteEventPlanPaceGroupsBody,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanPaceGroups,
                  contractValue: (value) => value.name,
                  values: _PacePreset.values,
                  itemLabel: (value) => _pacePresetLabel(context, value),
                  selected: _selectedPacePresets(plan),
                  multi: true,
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(paceGroups: _paceGroupsFor(selection)),
                  ),
                  open: _accordion.isExpanded(_paceGroupsField),
                  onOpenChanged: (open) => _setOpen(_paceGroupsField, open),
                  icon: CatchIcons.speedOutlined,
                  iconColor: accent,
                ),
                CatchField.choices<RouteLiveTrackingMode>(
                  key: CreateEventFormKeys.routeLiveTracking,
                  title: context.l10n.hostsRouteEventPlanTrackingTitle,
                  body: context.l10n.hostsRouteEventPlanTrackingBody,
                  contract: CatchContractConstraints
                      .createEventCallablePayloadEventFormatActivityDetailsRoutePlanLiveTrackingPolicyMode,
                  contractValue: (value) => value.name,
                  values: RouteLiveTrackingMode.values,
                  itemLabel: (value) => _trackingLabel(context, value),
                  selected: {plan.liveTrackingPolicy.mode},
                  onSelectionChanged: (selection) => widget.onChanged(
                    plan.copyWith(
                      liveTrackingPolicy: RouteLiveTrackingPolicy(
                        mode: selection.single,
                        staleAfterSeconds: 120,
                        retentionMinutes: 60,
                      ),
                    ),
                  ),
                  open: _accordion.isExpanded(_trackingField),
                  onOpenChanged: (open) => _setOpen(_trackingField, open),
                  icon: CatchIcons.locationOnOutlined,
                  iconColor: accent,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _editPath(RouteEventPlan plan) async {
    final path = await Navigator.of(context).push<List<RoutePoint>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RoutePathBuilderScreen(
          initialCenter: widget.initialCenter,
          initialPath: plan.path,
          enableNetworkTiles: widget.loadMapTiles,
        ),
      ),
    );
    if (path != null) widget.onChanged(plan.copyWith(path: path));
  }

  Set<_PacePreset> _selectedPacePresets(RouteEventPlan plan) => plan.paceGroups
      .map(
        (group) => _PacePreset.values.where((value) => value.name == group.id),
      )
      .expand((values) => values)
      .toSet();

  List<RoutePaceGroup> _paceGroupsFor(Set<_PacePreset> selection) {
    return _PacePreset.values
        .where(selection.contains)
        .map(
          (value) => RoutePaceGroup(
            id: value.name,
            label: _pacePresetLabel(context, value),
            sortOrder: value.index,
            targetPaceSecondsPerKm: switch (value) {
              _PacePreset.social => 450,
              _PacePreset.steady => 360,
              _PacePreset.fast => 300,
            },
          ),
        )
        .toList(growable: false);
  }

  String _pacePresetLabel(BuildContext context, _PacePreset value) =>
      switch (value) {
        _PacePreset.social => context.l10n.hostsRouteEventPlanPaceSocial,
        _PacePreset.steady => context.l10n.hostsRouteEventPlanPaceSteady,
        _PacePreset.fast => context.l10n.hostsRouteEventPlanPaceFast,
      };

  String _trackingLabel(BuildContext context, RouteLiveTrackingMode value) =>
      switch (value) {
        RouteLiveTrackingMode.disabled =>
          context.l10n.hostsRouteEventPlanTrackingDisabled,
        RouteLiveTrackingMode.hostOnly =>
          context.l10n.hostsRouteEventPlanTrackingHostOnly,
        RouteLiveTrackingMode.authorizedOperators =>
          context.l10n.hostsRouteEventPlanTrackingOperators,
      };

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
