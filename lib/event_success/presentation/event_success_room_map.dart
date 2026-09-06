import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_layout.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef EventSuccessSpatialPreview =
    Future<List<EventSuccessSpatialDestination>> Function(
      EventSuccessAssignment assignment,
    );
typedef EventSuccessSpatialReassign =
    Future<void> Function(
      EventSuccessAssignment assignment,
      String destinationUnitId,
      EventSuccessSpatialScope scope,
    );

/// Shared normalized room map used by Host and attendee runtimes.
///
/// When callbacks are omitted the map is read-only. Interactive Host mode owns
/// selection, destination explanations, explicit confirmation, and an additive
/// large-screen drag affordance; tap placement remains available everywhere.
class EventSuccessRoomMap extends StatefulWidget {
  const EventSuccessRoomMap({
    super.key,
    required this.layout,
    required this.assignments,
    this.profiles = const [],
    this.exclusionAlertUids = const {},
    this.activityKind,
    this.onPreview,
    this.onReassign,
    this.onConfirmPosition,
    this.onReleasePinned,
    this.initialSelectedUid,
    this.showHeader = true,
  });

  final EventSuccessLayout layout;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> profiles;
  final Set<String> exclusionAlertUids;
  final ActivityKind? activityKind;
  final EventSuccessSpatialPreview? onPreview;
  final EventSuccessSpatialReassign? onReassign;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onConfirmPosition;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onReleasePinned;
  final String? initialSelectedUid;
  final bool showHeader;

  bool get interactive => onPreview != null && onReassign != null;

  @override
  State<EventSuccessRoomMap> createState() => _EventSuccessRoomMapState();
}

class _EventSuccessRoomMapState extends State<EventSuccessRoomMap> {
  EventSuccessAssignment? _selected;
  var _destinations = const <EventSuccessSpatialDestination>[];
  String? _destinationUnitId;
  var _scope = EventSuccessSpatialScope.pinned;
  var _pending = false;
  Object? _error;
  String? _lastActionKey;
  DateTime? _lastActionAt;

  @override
  void initState() {
    super.initState();
    _scheduleInitialSelection();
  }

  @override
  void didUpdateWidget(covariant EventSuccessRoomMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = _selected;
    if (selected != null) {
      _selected = widget.assignments
          .where((candidate) => candidate.uid == selected.uid)
          .firstOrNull;
      if (_selected == null) {
        _destinations = const [];
        _destinationUnitId = null;
      }
    }
    if (oldWidget.initialSelectedUid != widget.initialSelectedUid) {
      _scheduleInitialSelection();
    }
  }

  void _scheduleInitialSelection() {
    final initialSelectedUid = widget.initialSelectedUid;
    if (initialSelectedUid == null || !widget.interactive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selected?.uid == initialSelectedUid) return;
      final assignment = widget.assignments
          .where((candidate) => candidate.uid == initialSelectedUid)
          .firstOrNull;
      if (assignment != null) unawaited(_selectAssignment(assignment));
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileByUid = {
      for (final profile in widget.profiles) profile.uid: profile,
    };
    final assignmentsByUnit = <String, List<EventSuccessAssignment>>{};
    for (final assignment in widget.assignments) {
      final unitId = assignment.layoutUnitId;
      if (unitId == null) continue;
      assignmentsByUnit.putIfAbsent(unitId, () => []).add(assignment);
    }
    final destinationByUnit = {
      for (final destination in _destinations) destination.unitId: destination,
    };
    EventSuccessLayoutUnit? unitById(String? unitId) => unitId == null
        ? null
        : widget.layout.units.where((unit) => unit.id == unitId).firstOrNull;
    final normalized = normalizeEventSuccessLayoutUnits(widget.layout.units);
    Widget content(bool canDrag) => CatchSectionList(
      emptyStateOmitted: true,
      gap: CatchSpacing.s3,
      children: [
        if (widget.showHeader)
          CatchSection.plain(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.eventSuccessRoomMapTitle,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH4,
                Text(
                  context.l10n.eventSuccessRoomMapSubtitle,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.of(context).ink2,
                  ),
                ),
              ],
            ),
          ),
        if (widget.interactive && _error != null)
          CatchLocalizedErrorBanner(_error!, context: AppErrorContext.event),
        if (widget.interactive && _selected != null)
          _EventSuccessSelectedPlacementCard(
            assignment: _selected!,
            profile: profileByUid[_selected!.uid],
            currentUnit: unitById(_selected!.layoutUnitId),
            destinationUnit: unitById(_destinationUnitId),
            scope: _scope,
            pending: _pending,
            needsAttention: widget.exclusionAlertUids.contains(_selected!.uid),
            onScopeChanged: (scope) => setState(() => _scope = scope),
            onMove: _destinationUnitId == null
                ? null
                : () => unawaited(_applyDestination(_destinationUnitId!)),
            onConfirm: widget.onConfirmPosition == null
                ? null
                : () => _run(
                    () => widget.onConfirmPosition!(_selected!),
                    key: 'confirm:${_selected!.uid}',
                  ),
            onRelease: widget.onReleasePinned == null
                ? null
                : () => _run(
                    () => widget.onReleasePinned!(_selected!),
                    key: 'release:${_selected!.uid}',
                  ),
          ),
        CatchSurface(
          backgroundColor: CatchTokens.of(context).raised,
          borderColor: CatchTokens.of(context).line,
          padding: CatchInsets.content,
          child: AspectRatio(
            aspectRatio: CatchAspectRatio.roomMap,
            child: CustomMultiChildLayout(
              delegate: _EventSuccessRoomMapLayoutDelegate(normalized),
              children: [
                for (final positioned in normalized)
                  LayoutId(
                    id: positioned.id,
                    child: _EventSuccessPositionedMapUnit(
                      unit: widget.layout.units.firstWhere(
                        (unit) => unit.id == positioned.id,
                      ),
                      assignments: assignmentsByUnit[positioned.id] ?? const [],
                      profileByUid: profileByUid,
                      destination: destinationByUnit[positioned.id],
                      attendeeSelected: _selected != null,
                      selectedDestination: _destinationUnitId == positioned.id,
                      pending: _pending,
                      interactive: widget.interactive,
                      alertUids: widget.exclusionAlertUids,
                      activityKind: widget.activityKind,
                      onChooseDestination: _chooseDestination,
                      onApplyDraggedDestination: _applyDestination,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const _EventSuccessRoomLegend(),
        if (widget.interactive) ...[
          CatchSection.fieldRows(
            title: context.l10n.eventSuccessRoomMapSelectAttendee,
            children: [
              for (final assignment in widget.assignments)
                _EventSuccessAttendeeSpatialRow(
                  assignment: assignment,
                  profile: profileByUid[assignment.uid],
                  selected: _selected?.uid == assignment.uid,
                  pending: _pending,
                  canDrag: canDrag,
                  onSelect: _selectAssignment,
                ),
            ],
          ),
          if (canDrag)
            Text(
              context.l10n.eventSuccessRoomMapDragHint,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).ink2,
              ),
            ),
        ],
      ],
    );

    return ComponentResponsiveBuilder(
      breakpoint: ComponentBreakpoints.eventSuccessSpatialDragBreakpoint,
      compact: (_) => content(false),
      expanded: (_) => content(true),
    );
  }

  Future<void> _selectAssignment(EventSuccessAssignment assignment) async {
    if (_pending || _isDebounced('preview:${assignment.uid}')) return;
    setState(() {
      _selected = assignment;
      _destinations = const [];
      _destinationUnitId = null;
      _scope = EventSuccessSpatialScope.pinned;
      _pending = true;
      _error = null;
    });
    try {
      final destinations = await widget.onPreview!(assignment);
      if (!mounted || _selected?.uid != assignment.uid) return;
      final recommendation = destinations
          .where((destination) => destination.valid)
          .map((destination) => destination.recommendedScope)
          .whereType<EventSuccessSpatialScope>()
          .firstOrNull;
      final recommendedDestination = destinations
          .where((destination) => destination.valid)
          .firstOrNull;
      setState(() {
        _destinations = destinations;
        _destinationUnitId = recommendedDestination?.unitId;
        _scope = recommendation ?? EventSuccessSpatialScope.pinned;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  void _chooseDestination(String unitId) {
    if (_pending || _selected == null) return;
    setState(() => _destinationUnitId = unitId);
  }

  Future<void> _applyDestination(String unitId) async {
    final assignment = _selected;
    if (assignment == null) return;
    await _run(
      () => widget.onReassign!(assignment, unitId, _scope),
      key: 'reassign:${assignment.uid}:$unitId:${_scope.name}',
      clearSelection: true,
    );
  }

  Future<void> _run(
    Future<void> Function() action, {
    required String key,
    bool clearSelection = false,
  }) async {
    if (_pending || _isDebounced(key)) return;
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      await action();
      if (mounted && clearSelection) {
        setState(() {
          _selected = null;
          _destinations = const [];
          _destinationUnitId = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  bool _isDebounced(String key) {
    final now = DateTime.now();
    final lastAt = _lastActionAt;
    if (_lastActionKey == key &&
        lastAt != null &&
        now.difference(lastAt) < CatchMotion.eventSuccessActionDebounce) {
      return true;
    }
    _lastActionKey = key;
    _lastActionAt = now;
    return false;
  }
}

class _EventSuccessRoomMapLayoutDelegate extends MultiChildLayoutDelegate {
  _EventSuccessRoomMapLayoutDelegate(this.units);

  final List<NormalizedEventSuccessLayoutUnit> units;

  @override
  void performLayout(Size size) {
    for (final unit in units) {
      if (!hasChild(unit.id)) continue;
      final inset = CatchSpacing.s1;
      final childSize = Size(
        (unit.width * size.width - (inset * 2)).clamp(0, size.width),
        (unit.height * size.height - (inset * 2)).clamp(0, size.height),
      );
      layoutChild(
        unit.id,
        BoxConstraints(
          minWidth: childSize.width,
          maxWidth: childSize.width,
          minHeight: childSize.height,
          maxHeight: childSize.height,
        ),
      );
      positionChild(
        unit.id,
        Offset(unit.left * size.width + inset, unit.top * size.height + inset),
      );
    }
  }

  @override
  bool shouldRelayout(
    covariant _EventSuccessRoomMapLayoutDelegate oldDelegate,
  ) => !listEquals(oldDelegate.units, units);
}

class _EventSuccessPositionedMapUnit extends StatelessWidget {
  const _EventSuccessPositionedMapUnit({
    required this.unit,
    required this.assignments,
    required this.profileByUid,
    required this.destination,
    required this.attendeeSelected,
    required this.selectedDestination,
    required this.pending,
    required this.interactive,
    required this.alertUids,
    required this.activityKind,
    required this.onChooseDestination,
    required this.onApplyDraggedDestination,
  });

  final EventSuccessLayoutUnit unit;
  final List<EventSuccessAssignment> assignments;
  final Map<String, PublicProfile> profileByUid;
  final EventSuccessSpatialDestination? destination;
  final bool attendeeSelected;
  final bool selectedDestination;
  final bool pending;
  final bool interactive;
  final Set<String> alertUids;
  final ActivityKind? activityKind;
  final ValueChanged<String> onChooseDestination;
  final Future<void> Function(String unitId) onApplyDraggedDestination;

  @override
  Widget build(BuildContext context) {
    final invalid = destination != null && !destination!.valid;
    final child = _EventSuccessMapUnit(
      unit: unit,
      assignments: assignments,
      profileByUid: profileByUid,
      invalid: invalid,
      selectedDestination: selectedDestination,
      alert: assignments.any(
        (assignment) => alertUids.contains(assignment.uid),
      ),
      alertUids: alertUids,
      activityKind: activityKind,
      onTap: !interactive || pending || !attendeeSelected || invalid
          ? null
          : () => onChooseDestination(unit.id),
      invalidReason: destination?.reason == null
          ? null
          : _reasonLabel(context, destination!.reason!),
    );
    if (!attendeeSelected || !interactive) return child;
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !pending && destination?.valid == true,
      onAcceptWithDetails: (_) => unawaited(onApplyDraggedDestination(unit.id)),
      builder: (context, candidateData, rejectedData) => child,
    );
  }
}

class _EventSuccessAttendeeSpatialRow extends StatelessWidget {
  const _EventSuccessAttendeeSpatialRow({
    required this.assignment,
    required this.profile,
    required this.selected,
    required this.pending,
    required this.canDrag,
    required this.onSelect,
  });

  final EventSuccessAssignment assignment;
  final PublicProfile? profile;
  final bool selected;
  final bool pending;
  final bool canDrag;
  final Future<void> Function(EventSuccessAssignment assignment) onSelect;

  @override
  Widget build(BuildContext context) {
    final row = CatchPersonRow(
      data: CatchPersonRowData(
        name: profile?.name ?? assignment.displayTitle,
        imageUrl: profile?.primaryPhotoThumbnailUrl,
        seed: assignment.uid,
        metaLine: assignment.layoutUnitId,
        isFresh: selected,
      ),
      onTap: pending ? null : () => unawaited(onSelect(assignment)),
      trailing: assignment.layoutUnitId == null
          ? null
          : CatchBadge(
              label: assignment.confirmedLayoutUnitId == assignment.layoutUnitId
                  ? context.l10n.eventSuccessRoomMapConfirmed
                  : context.l10n.eventSuccessRoomMapAssigned,
              tone: assignment.confirmedLayoutUnitId == assignment.layoutUnitId
                  ? CatchBadgeTone.success
                  : CatchBadgeTone.brand,
            ),
    );
    if (!canDrag || !selected) return row;
    return Draggable<String>(
      data: assignment.uid,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: CatchLayout.maxContentWidth, child: row),
      ),
      childWhenDragging: Opacity(
        opacity: CatchOpacity.disabledControl,
        child: row,
      ),
      child: row,
    );
  }
}

class _EventSuccessSelectedPlacementCard extends StatelessWidget {
  const _EventSuccessSelectedPlacementCard({
    required this.assignment,
    required this.profile,
    required this.currentUnit,
    required this.destinationUnit,
    required this.scope,
    required this.pending,
    required this.needsAttention,
    required this.onScopeChanged,
    required this.onMove,
    required this.onConfirm,
    required this.onRelease,
  });

  final EventSuccessAssignment assignment;
  final PublicProfile? profile;
  final EventSuccessLayoutUnit? currentUnit;
  final EventSuccessLayoutUnit? destinationUnit;
  final EventSuccessSpatialScope scope;
  final bool pending;
  final bool needsAttention;
  final ValueChanged<EventSuccessSpatialScope> onScopeChanged;
  final VoidCallback? onMove;
  final Future<void> Function()? onConfirm;
  final Future<void> Function()? onRelease;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final confirmed =
        assignment.layoutUnitId != null &&
        assignment.confirmedLayoutUnitId == assignment.layoutUnitId;
    final currentLabel =
        currentUnit?.label ?? context.l10n.eventSuccessRoomMapNotPlaced;
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final secondaryActions = <CatchActionMenuItem<_PlacementSecondaryAction>>[
      if (assignment.layoutUnitId != null && !confirmed && onConfirm != null)
        CatchActionMenuItem(
          value: _PlacementSecondaryAction.confirm,
          label: context.l10n.eventSuccessRoomMapConfirmPosition,
          icon: CatchIcons.checkCircleOutlineRounded,
        ),
      if (onRelease != null)
        CatchActionMenuItem(
          value: _PlacementSecondaryAction.release,
          label: context.l10n.eventSuccessRoomMapReleasePinned,
          icon: CatchIcons.lockOpenRounded,
        ),
    ];
    final identity = Row(
      children: [
        CatchPersonAvatar(
          size: CatchLayout.avatarIdentityExtent,
          name: profile?.name ?? assignment.displayTitle,
          imageUrl: profile?.primaryPhotoThumbnailUrl,
          borderWidth: CatchStroke.hairline,
          borderColor: needsAttention ? t.warning : t.line2,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.name ?? assignment.displayTitle,
                style: CatchTextStyles.titleL(context, color: t.ink),
              ),
              gapH4,
              CatchBadge(
                label: needsAttention
                    ? context.l10n.eventSuccessRoomMapNeedsAttention
                    : confirmed
                    ? context.l10n.eventSuccessRoomMapConfirmedShort
                    : context.l10n.eventSuccessRoomMapAssigned,
                tone: needsAttention
                    ? CatchBadgeTone.warning
                    : confirmed
                    ? CatchBadgeTone.success
                    : CatchBadgeTone.brand,
              ),
              gapH4,
              Text(
                context.l10n.eventSuccessRoomMapCurrentPosition(
                  unitLabel: currentLabel,
                ),
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
    final move = CatchButton(
      label: destinationUnit == null
          ? context.l10n.eventSuccessRoomMapChooseDestinationShort
          : context.l10n.eventSuccessRoomMapMoveToUnit(
              unitLabel: destinationUnit!.label,
            ),
      isLoading: pending,
      onPressed: pending ? null : onMove,
      fullWidth: true,
    );
    final stackedHeader = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [identity, gapH12, move],
    );
    return CatchSurface(
      padding: CatchInsets.contentDense,
      borderColor: needsAttention ? t.warning : t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ComponentResponsiveBuilder(
            breakpoint: ComponentBreakpoints
                .eventSuccessSelectedPlacementInlineBreakpoint,
            compact: (_) => stackedHeader,
            expanded: (_) => largeText
                ? stackedHeader
                : Row(
                    children: [
                      Expanded(flex: 4, child: identity),
                      gapW12,
                      Expanded(flex: 3, child: move),
                    ],
                  ),
          ),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchOptionGroup<EventSuccessSpatialScope>(
                  options: [
                    CatchOption(
                      value: EventSuccessSpatialScope.thisRound,
                      label:
                          context.l10n.eventSuccessRoomMapScopeThisRoundShort,
                    ),
                    CatchOption(
                      value: EventSuccessSpatialScope.pinned,
                      label: context.l10n.eventSuccessRoomMapScopePinnedShort,
                    ),
                  ],
                  selected: scope,
                  contract: CatchContractConstraints
                      .eventSuccessSpatialActionCallablePayloadScope,
                  contractValue: (value) => value.name,
                  onChanged: pending ? null : onScopeChanged,
                  showDivider: false,
                ),
              ),
              if (secondaryActions.isNotEmpty) ...[
                gapW8,
                CatchActionMenu<_PlacementSecondaryAction>(
                  items: secondaryActions,
                  tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                  onSelected: (action) {
                    switch (action) {
                      case _PlacementSecondaryAction.confirm:
                        unawaited(onConfirm!());
                      case _PlacementSecondaryAction.release:
                        unawaited(onRelease!());
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

enum _PlacementSecondaryAction { confirm, release }

class _EventSuccessRoomLegend extends StatelessWidget {
  const _EventSuccessRoomLegend();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        _EventSuccessRoomLegendItem(
          color: t.primary,
          label: context.l10n.eventSuccessRoomMapAssigned,
        ),
        _EventSuccessRoomLegendItem(
          color: t.success,
          label: context.l10n.eventSuccessRoomMapConfirmedShort,
        ),
        _EventSuccessRoomLegendItem(
          color: t.line2,
          label: context.l10n.eventSuccessRoomMapOpen,
        ),
        _EventSuccessRoomLegendItem(
          color: t.ink3,
          label: context.l10n.eventSuccessRoomMapUnavailable,
          icon: CatchIcons.blockRounded,
        ),
      ],
    );
  }
}

class _EventSuccessRoomLegendItem extends StatelessWidget {
  const _EventSuccessRoomLegendItem({
    required this.color,
    required this.label,
    this.icon,
  });

  final Color color;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchSurface(
          width: CatchIcon.md,
          height: CatchIcon.md,
          radius: CatchRadius.pill,
          backgroundColor: t.surface,
          borderColor: color,
          borderWidth: CatchStroke.underline,
          child: icon == null
              ? const SizedBox.shrink()
              : Icon(icon, size: CatchIcon.micro, color: color),
        ),
        gapW4,
        Text(label, style: CatchTextStyles.labelS(context, color: t.ink2)),
      ],
    );
  }
}

class _EventSuccessMapUnit extends StatelessWidget {
  const _EventSuccessMapUnit({
    required this.unit,
    required this.assignments,
    required this.profileByUid,
    required this.invalid,
    required this.selectedDestination,
    required this.alert,
    required this.alertUids,
    required this.activityKind,
    required this.onTap,
    required this.invalidReason,
  });

  final EventSuccessLayoutUnit unit;
  final List<EventSuccessAssignment> assignments;
  final Map<String, PublicProfile> profileByUid;
  final bool invalid;
  final bool selectedDestination;
  final bool alert;
  final Set<String> alertUids;
  final ActivityKind? activityKind;
  final VoidCallback? onTap;
  final String? invalidReason;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final orderedAssignments = [...assignments]
      ..sort((left, right) => left.uid.compareTo(right.uid));
    final isTable =
        unit.shape == EventSuccessLayoutShape.round ||
        unit.shape == EventSuccessLayoutShape.rect;
    final borderColor = alert
        ? t.warning
        : invalid
        ? t.ink3
        : selectedDestination
        ? t.success
        : t.line2;
    final statusLabel =
        invalidReason ??
        (selectedDestination
            ? context.l10n.eventSuccessRoomMapSelectedDestination
            : alert
            ? context.l10n.eventSuccessRoomMapNeedsAttention
            : context.l10n.eventSuccessRoomMapAvailable);
    final surface = Semantics(
      button: onTap != null,
      label: context.l10n.eventSuccessRoomMapUnitSemantics(
        unitLabel: unit.label,
        occupied: assignments.length,
        capacity: unit.capacity,
        status: statusLabel,
      ),
      child: CatchSurface(
        key: ValueKey<String>('event_success.room.unit.${unit.id}'),
        radius: CatchRadius.md,
        borderColor: isTable && !selectedDestination && !alert && !invalid
            ? Colors.transparent
            : borderColor,
        borderWidth: selectedDestination || alert
            ? CatchStroke.underline
            : CatchStroke.hairline,
        backgroundColor: selectedDestination
            ? t.success.withValues(alpha: CatchOpacity.subtleFill)
            : alert
            ? t.warning.withValues(alpha: CatchOpacity.subtleFill)
            : invalid
            ? t.surface.withValues(alpha: CatchOpacity.disabledControl)
            : isTable
            ? Colors.transparent
            : t.surface,
        onTap: onTap,
        child: Padding(
          padding: CatchInsets.compactControlContent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      unit.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: CatchTextStyles.labelM(
                        context,
                        color: selectedDestination ? t.success : t.ink,
                      ),
                    ),
                  ),
                  if (invalid || alert)
                    Icon(
                      invalid
                          ? CatchIcons.blockRounded
                          : CatchIcons.warningAmberRounded,
                      size: CatchIcon.sm,
                      color: invalid ? t.ink3 : t.warning,
                    ),
                ],
              ),
              gapH4,
              Expanded(
                child: ExcludeSemantics(
                  child: Stack(
                    children: [
                      Align(
                        child: FractionallySizedBox(
                          widthFactor: CatchLayout.roomMapUnitWidthFactor,
                          heightFactor: CatchLayout.roomMapUnitHeightFactor,
                          child: _EventSuccessUnitShape(
                            shape: unit.shape,
                            invalid: invalid,
                          ),
                        ),
                      ),
                      for (final indexed in _roomPositionAlignments(
                        math.min(
                          unit.capacity,
                          CatchLayout.roomMapMaxVisiblePositions,
                        ),
                        unit.shape,
                      ).indexed)
                        Align(
                          alignment: indexed.$2,
                          child: _EventSuccessCapacityPosition(
                            extent: CatchLayout.roomMapPositionExtent,
                            assignment: indexed.$1 < orderedAssignments.length
                                ? orderedAssignments[indexed.$1]
                                : null,
                            profile: indexed.$1 < orderedAssignments.length
                                ? profileByUid[orderedAssignments[indexed.$1]
                                      .uid]
                                : null,
                            confirmed:
                                indexed.$1 < orderedAssignments.length &&
                                orderedAssignments[indexed.$1]
                                        .confirmedLayoutUnitId ==
                                    unit.id,
                            needsAttention:
                                indexed.$1 < orderedAssignments.length &&
                                alertUids.contains(
                                  orderedAssignments[indexed.$1].uid,
                                ),
                            unavailable: invalid,
                            activityKind: activityKind,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (invalidReason == null) return surface;
    return Tooltip(message: invalidReason!, child: surface);
  }
}

class _EventSuccessUnitShape extends StatelessWidget {
  const _EventSuccessUnitShape({required this.shape, required this.invalid});

  final EventSuccessLayoutShape shape;
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final radius = switch (shape) {
      EventSuccessLayoutShape.round => CatchRadius.pill,
      EventSuccessLayoutShape.rect => CatchRadius.sm,
      EventSuccessLayoutShape.row => CatchRadius.xs,
      EventSuccessLayoutShape.court => CatchRadius.md,
      EventSuccessLayoutShape.zone => CatchRadius.lg,
    };
    final surface = CatchSurface(
      radius: radius,
      backgroundColor: invalid
          ? t.raised.withValues(alpha: CatchOpacity.disabledControl)
          : t.surface,
      borderColor: invalid ? t.ink3 : t.line2,
      child: const SizedBox.expand(),
    );
    if (shape != EventSuccessLayoutShape.round) return surface;
    return Center(
      child: AspectRatio(aspectRatio: CatchAspectRatio.square, child: surface),
    );
  }
}

class _EventSuccessCapacityPosition extends StatelessWidget {
  const _EventSuccessCapacityPosition({
    required this.extent,
    required this.assignment,
    required this.profile,
    required this.confirmed,
    required this.needsAttention,
    required this.unavailable,
    required this.activityKind,
  });

  final double extent;
  final EventSuccessAssignment? assignment;
  final PublicProfile? profile;
  final bool confirmed;
  final bool needsAttention;
  final bool unavailable;
  final ActivityKind? activityKind;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final assignment = this.assignment;
    if (assignment == null) {
      return CatchSurface(
        width: extent,
        height: extent,
        radius: CatchRadius.pill,
        backgroundColor: t.surface,
        borderColor: unavailable ? t.ink3 : t.line2,
        borderWidth: CatchStroke.underline,
        child: unavailable
            ? Icon(
                CatchIcons.blockRounded,
                size: CatchIcon.micro,
                color: t.ink3,
              )
            : const SizedBox.shrink(),
      );
    }
    final ringColor = needsAttention
        ? t.warning
        : confirmed
        ? t.success
        : t.primary;
    return CatchPersonAvatar(
      size: extent,
      name: profile?.name ?? assignment.displayTitle,
      imageUrl: profile?.primaryPhotoThumbnailUrl,
      activityKind: activityKind,
      borderWidth: CatchStroke.underline,
      borderColor: ringColor,
    );
  }
}

List<Alignment> _roomPositionAlignments(
  int count,
  EventSuccessLayoutShape shape,
) {
  if (shape == EventSuccessLayoutShape.round) {
    return switch (count) {
      <= 0 => const [],
      1 => const [Alignment.topCenter],
      2 => const [Alignment.centerLeft, Alignment.centerRight],
      3 => const [
        Alignment.topCenter,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      4 => const [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      5 => const [
        Alignment.topCenter,
        Alignment.topRight,
        Alignment.bottomRight,
        Alignment.bottomLeft,
        Alignment.topLeft,
      ],
      6 => const [
        Alignment(-0.62, -0.78),
        Alignment(0.62, -0.78),
        Alignment.centerRight,
        Alignment(0.62, 0.78),
        Alignment(-0.62, 0.78),
        Alignment.centerLeft,
      ],
      _ => _roomGridPositionAlignments(count),
    };
  }
  return _roomGridPositionAlignments(count);
}

List<Alignment> _roomGridPositionAlignments(int count) => switch (count) {
  <= 0 => const [],
  1 => const [Alignment.topCenter],
  2 => const [Alignment.topLeft, Alignment.topRight],
  3 => const [Alignment.topCenter, Alignment.bottomLeft, Alignment.bottomRight],
  4 => const [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ],
  5 => const [
    Alignment.topCenter,
    Alignment.centerLeft,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ],
  6 => const [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ],
  7 => const [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ],
  _ => const [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ],
};

String _reasonLabel(
  BuildContext context,
  EventSuccessSpatialDestinationReason reason,
) => switch (reason) {
  EventSuccessSpatialDestinationReason.capacity =>
    context.l10n.eventSuccessRoomMapReasonCapacity,
  EventSuccessSpatialDestinationReason.safetyKeepApart =>
    context.l10n.eventSuccessRoomMapReasonSafety,
  EventSuccessSpatialDestinationReason.declaredConstraint =>
    context.l10n.eventSuccessRoomMapReasonConstraint,
};
