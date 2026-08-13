import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_layout.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
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
    this.onPreview,
    this.onReassign,
    this.onConfirmPosition,
    this.onReleasePinned,
  });

  final EventSuccessLayout layout;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> profiles;
  final Set<String> exclusionAlertUids;
  final EventSuccessSpatialPreview? onPreview;
  final EventSuccessSpatialReassign? onReassign;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onConfirmPosition;
  final Future<void> Function(EventSuccessAssignment assignment)?
  onReleasePinned;

  bool get interactive => onPreview != null && onReassign != null;

  @override
  State<EventSuccessRoomMap> createState() => _EventSuccessRoomMapState();
}

class _EventSuccessRoomMapState extends State<EventSuccessRoomMap> {
  EventSuccessAssignment? _selected;
  var _destinations = const <EventSuccessSpatialDestination>[];
  var _scope = EventSuccessSpatialScope.pinned;
  var _pending = false;
  Object? _error;
  String? _lastActionKey;
  DateTime? _lastActionAt;

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
    final normalized = normalizeEventSuccessLayoutUnits(widget.layout.units);
    Widget content(bool canDrag) => CatchSectionList(
      emptyStateOmitted: true,
      gap: CatchSpacing.s3,
      children: [
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
              gapH10,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  CatchBadge(
                    label: context.l10n.eventSuccessRoomMapAssigned,
                    tone: CatchBadgeTone.brand,
                  ),
                  CatchBadge(
                    label: context.l10n.eventSuccessRoomMapConfirmed,
                    tone: CatchBadgeTone.success,
                  ),
                ],
              ),
            ],
          ),
        ),
        CatchSurface(
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
                      destination: destinationByUnit[positioned.id],
                      selected: _selected != null,
                      pending: _pending,
                      interactive: widget.interactive,
                      alertUids: widget.exclusionAlertUids,
                      onApplyDestination: _applyDestination,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.interactive) ...[
          if (_error != null)
            CatchErrorBanner.fromError(_error!, context: AppErrorContext.event),
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
                  onConfirm: widget.onConfirmPosition == null
                      ? null
                      : (assignment) => _run(
                          () => widget.onConfirmPosition!(assignment),
                          key: 'confirm:${assignment.uid}',
                        ),
                  onRelease: widget.onReleasePinned == null
                      ? null
                      : (assignment) => _run(
                          () => widget.onReleasePinned!(assignment),
                          key: 'release:${assignment.uid}',
                        ),
                ),
            ],
          ),
          if (_selected != null)
            CatchSection.fieldRows(
              children: [
                CatchField.select<EventSuccessSpatialScope>(
                  title: context.l10n.eventSuccessRoomMapAssigned,
                  contract: CatchContractConstraints
                      .eventSuccessSpatialActionCallablePayloadScope,
                  contractValue: (scope) => scope.name,
                  values: EventSuccessSpatialScope.values,
                  itemLabel: (scope) => switch (scope) {
                    EventSuccessSpatialScope.thisRound =>
                      context.l10n.eventSuccessRoomMapScopeThisRound,
                    EventSuccessSpatialScope.pinned =>
                      context.l10n.eventSuccessRoomMapScopePinned,
                  },
                  value: _scope,
                  enabled: !_pending,
                  onChanged: (scope) {
                    if (scope != null) setState(() => _scope = scope);
                  },
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
      setState(() {
        _destinations = destinations;
        _scope = recommendation ?? EventSuccessSpatialScope.pinned;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
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
    required this.destination,
    required this.selected,
    required this.pending,
    required this.interactive,
    required this.alertUids,
    required this.onApplyDestination,
  });

  final EventSuccessLayoutUnit unit;
  final List<EventSuccessAssignment> assignments;
  final EventSuccessSpatialDestination? destination;
  final bool selected;
  final bool pending;
  final bool interactive;
  final Set<String> alertUids;
  final Future<void> Function(String unitId) onApplyDestination;

  @override
  Widget build(BuildContext context) {
    final invalid = destination != null && !destination!.valid;
    final child = _EventSuccessMapUnit(
      unit: unit,
      assignments: assignments,
      invalid: invalid,
      selectedDestination: selected && destination?.valid == true,
      alert: assignments.any(
        (assignment) => alertUids.contains(assignment.uid),
      ),
      onTap: !interactive || pending || !selected || invalid
          ? null
          : () => unawaited(onApplyDestination(unit.id)),
      invalidReason: destination?.reason == null
          ? null
          : _reasonLabel(context, destination!.reason!),
    );
    if (!selected || !interactive) return child;
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !pending && destination?.valid == true,
      onAcceptWithDetails: (_) => unawaited(onApplyDestination(unit.id)),
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
    required this.onConfirm,
    required this.onRelease,
  });

  final EventSuccessAssignment assignment;
  final PublicProfile? profile;
  final bool selected;
  final bool pending;
  final bool canDrag;
  final Future<void> Function(EventSuccessAssignment assignment) onSelect;
  final Future<void> Function(EventSuccessAssignment assignment)? onConfirm;
  final Future<void> Function(EventSuccessAssignment assignment)? onRelease;

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
    final rowWithActions = Column(
      children: [
        row,
        if (selected)
          Padding(
            padding: CatchInsets.pageHorizontal.copyWith(
              bottom: CatchSpacing.s2,
            ),
            child: Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchButton(
                  label: context.l10n.eventSuccessRoomMapConfirmPosition,
                  variant: CatchButtonVariant.secondary,
                  isLoading: pending,
                  onPressed:
                      assignment.layoutUnitId == null ||
                          assignment.confirmedLayoutUnitId ==
                              assignment.layoutUnitId ||
                          onConfirm == null
                      ? null
                      : () => unawaited(onConfirm!(assignment)),
                ),
                CatchButton(
                  label: context.l10n.eventSuccessRoomMapReleasePinned,
                  variant: CatchButtonVariant.ghost,
                  isLoading: pending,
                  onPressed: onRelease == null
                      ? null
                      : () => unawaited(onRelease!(assignment)),
                ),
              ],
            ),
          ),
      ],
    );
    if (!canDrag || !selected) return rowWithActions;
    return Draggable<String>(
      data: assignment.uid,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: CatchLayout.maxContentWidth, child: row),
      ),
      childWhenDragging: Opacity(
        opacity: CatchOpacity.disabledControl,
        child: rowWithActions,
      ),
      child: rowWithActions,
    );
  }
}

class _EventSuccessMapUnit extends StatelessWidget {
  const _EventSuccessMapUnit({
    required this.unit,
    required this.assignments,
    required this.invalid,
    required this.selectedDestination,
    required this.alert,
    required this.onTap,
    required this.invalidReason,
  });

  final EventSuccessLayoutUnit unit;
  final List<EventSuccessAssignment> assignments;
  final bool invalid;
  final bool selectedDestination;
  final bool alert;
  final VoidCallback? onTap;
  final String? invalidReason;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final confirmed = assignments
        .where((assignment) => assignment.confirmedLayoutUnitId == unit.id)
        .length;
    final borderColor = alert
        ? t.warning
        : invalid
        ? t.ink3
        : selectedDestination
        ? t.primary
        : confirmed > 0
        ? t.success
        : t.line2;
    final radius = switch (unit.shape) {
      EventSuccessLayoutShape.round => CatchRadius.pill,
      EventSuccessLayoutShape.rect => CatchRadius.sm,
      EventSuccessLayoutShape.row => CatchRadius.xs,
      EventSuccessLayoutShape.court => CatchRadius.md,
      EventSuccessLayoutShape.zone => CatchRadius.lg,
    };
    final surface = CatchSurface(
      radius: radius,
      borderColor: borderColor,
      borderWidth: selectedDestination || alert ? 2 : 1,
      backgroundColor: confirmed > 0
          ? t.success.withValues(alpha: CatchOpacity.subtleFill)
          : selectedDestination
          ? t.primarySoft
          : invalid
          ? t.surface.withValues(alpha: CatchOpacity.disabledControl)
          : t.surface,
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: CatchInsets.compactControlContent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                unit.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.labelM(context, color: t.ink),
              ),
              gapH4,
              Text(
                context.l10n.eventSuccessRoomMapPeopleCount(
                  count: assignments.length,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              if (alert)
                Icon(
                  CatchIcons.warningAmberRounded,
                  size: CatchIcon.sm,
                  color: t.warning,
                ),
            ],
          ),
        ),
      ),
    );
    final shaped = unit.shape == EventSuccessLayoutShape.row
        ? Align(child: FractionallySizedBox(heightFactor: 0.58, child: surface))
        : surface;
    if (invalidReason == null) return shaped;
    return Tooltip(message: invalidReason!, child: shaped);
  }
}

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
