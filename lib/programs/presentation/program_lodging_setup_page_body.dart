import 'dart:math';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/domain/program_lodging_setup.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Staged, provider-free form mechanics. Persistence and authority lifetime
/// remain with the routed controller. No household creates sharing choices.
class ProgramLodgingSetupPageBody extends StatefulWidget {
  const ProgramLodgingSetupPageBody({
    super.key,
    required this.initial,
    required this.resolveDates,
    required this.onSave,
    required this.onCancel,
    this.busy = false,
    this.error,
  });
  final ProgramLodgingDraft initial;
  final Future<({int startsAtMillis, int endsAtMillis})> Function(
    String arrival,
    String departure,
  )
  resolveDates;
  final Future<void> Function(
    ProgramLodgingDraft draft,
    List<Map<String, Object?>> adoptions,
  )
  onSave;
  final VoidCallback onCancel;
  final bool busy;
  final Object? error;

  @override
  State<ProgramLodgingSetupPageBody> createState() =>
      _ProgramLodgingSetupPageBodyState();
}

class _ProgramLodgingSetupPageBodyState
    extends State<ProgramLodgingSetupPageBody> {
  late ProgramLodgingDraft _draft;
  late final Map<String, String> _calendarDates;
  final _arrival = TextEditingController();
  final _departure = TextEditingController();
  final _beds = TextEditingController(text: '1');
  final _features = TextEditingController();
  final _demandBeds = TextEditingController(text: '1');
  final _demandFeatures = TextEditingController();
  final _partyType = TextEditingController();
  final _priority = TextEditingController(text: '0');
  final _type = TextEditingController();
  final _zone = TextEditingController();
  final _building = TextEditingController();
  final _floor = TextEditingController();
  final _wing = TextEditingController();
  final _label = TextEditingController();
  final _occupants = TextEditingController(text: '1');
  final _inventoryArrival = TextEditingController();
  final _inventoryDeparture = TextEditingController();
  String? _physicalRoom;
  Set<String> _components = {};
  Map<String, Object?>? _position;
  final _pinZone = TextEditingController();
  String? _guest;
  String? _party;
  String? _unit;
  String? _contract;
  String? _group;
  String? _stay;
  String? _adoptParty;
  String? _adoptUnit;
  String? _pinHotel;
  String? _pinRoom;
  Set<String> _sharing = {};
  Set<String> _parents = {};
  bool _confirmed = false;
  bool _pending = false;
  Object? _error;
  final _adoptions = <String, Map<String, Object?>>{};

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _calendarDates = Map<String, String>.from(
      requiredMap(_draft.catalog.json['calendarDates'], 'calendar dates'),
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _arrival,
      _departure,
      _beds,
      _features,
      _priority,
      _partyType,
      _demandBeds,
      _demandFeatures,
      _type,
      _zone,
      _building,
      _floor,
      _wing,
      _label,
      _occupants,
      _inventoryArrival,
      _inventoryDeparture,
      _pinZone,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String _id() =>
      'lodging_${List.generate(4, (_) => Random.secure().nextInt(1 << 32).toRadixString(16).padLeft(8, '0')).join()}';
  String? _text(TextEditingController value) =>
      value.text.trim().isEmpty ? null : value.text.trim();
  List<String> _list(TextEditingController value) => value.text
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();
  bool get _busy => widget.busy || _pending;

  void _change(ProgramLodgingDraft Function() action) {
    try {
      final result = action();
      setState(() {
        _draft = result;
        _adoptions.clear();
        _error = null;
        final partyIds = _draft.rows('parties').map((p) => p['id']).toSet();
        final unitIds = _draft.rows('inventory').map((u) => u['id']).toSet();
        if (!partyIds.contains(_party)) _party = null;
        if (!partyIds.contains(_adoptParty)) _adoptParty = null;
        if (!unitIds.contains(_unit)) _unit = null;
        if (!unitIds.contains(_adoptUnit)) _adoptUnit = null;
        final guests = _draft.rows('demand').map((d) => d['guestId']).toSet();
        _sharing = _sharing.where(guests.contains).toSet();
      });
    } catch (error) {
      setState(() => _error = error);
    }
  }

  Future<void> _demand() async {
    final guest = _guest;
    if (guest == null || _busy) return;
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      // Preserve exact existing stay times for verification. Custom dates use
      // the program's civil calendar resolver, never device-local DateTime.
      final old = _draft.catalog
          .rows('activeStays')
          .where((row) => row['guestId'] == guest);
      final existing = old.length == 1 ? old.single : null;
      final oldDemand = _draft
          .rows('demand')
          .where((d) => d['guestId'] == guest);
      final original = oldDemand.isNotEmpty ? oldDemand.single : existing;
      final unchanged =
          original?['startsAtMillis'] != null &&
          original?['endsAtMillis'] != null &&
          _arrival.text.trim() ==
              _date(requiredInt(original!, 'startsAtMillis')) &&
          _departure.text.trim() ==
              _date(requiredInt(original, 'endsAtMillis'));
      final dates = unchanged
          ? (
              startsAtMillis: requiredInt(original, 'startsAtMillis'),
              endsAtMillis: requiredInt(original, 'endsAtMillis'),
            )
          : await widget.resolveDates(
              _arrival.text.trim(),
              _departure.text.trim(),
            );
      if (!mounted) return;
      if (!unchanged) {
        _calendarDates[dates.startsAtMillis.toString()] = _arrival.text.trim();
        _calendarDates[dates.endsAtMillis.toString()] = _departure.text.trim();
      }
      _change(
        () => _draft.withDemand(
          guestId: guest,
          startsAtMillis: dates.startsAtMillis,
          endsAtMillis: dates.endsAtMillis,
          beds: int.parse(_demandBeds.text),
          requiredFeatures: _list(_demandFeatures),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  bool get _ready {
    final demand = _draft.rows('demand');
    final parties = _draft.rows('parties');
    return demand.isNotEmpty &&
        _draft.rows('inventory').isNotEmpty &&
        parties.isNotEmpty &&
        parties.every((p) => p['confirmed'] == true) &&
        demand.every(
          (d) => parties.any(
            (p) => stringList(p['guestIds']).contains(d['guestId']),
          ),
        ) &&
        _draft.catalog
            .rows('activeStays')
            .every(
              (stay) =>
                  (stay['lodgingPartyId'] != null &&
                      stay['lodgingInventoryId'] != null) ||
                  _adoptions.containsKey(stay['id']),
            );
  }

  Future<void> _save() async {
    if (!_ready || _busy) return;
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      await widget.onSave(_draft, _adoptions.values.toList(growable: false));
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final copy = catchFieldCopy(l10n);
    final catalog = _draft.catalog;
    String label(String key, String id) =>
        catalog.row(key, id)['label']! as String;
    return AbsorbPointer(
      absorbing: _busy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error ?? widget.error case final error?)
            CatchLocalizedErrorBanner(error, context: AppErrorContext.event),
          Text(
            l10n.programsLodgingSharingHint,
            style: CatchTextStyles.supporting(context),
          ),
          Text(catalog.timezone, style: CatchTextStyles.supporting(context)),
          CatchSection.containedFieldRows(
            title: l10n.programsLodgingDemand,
            children: [
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsGuestsNameLabel,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentDemandItemsGuestId,
                contractValueBuilder: (v) => v,
                values: catalog
                    .rows('guests')
                    .map((g) => requiredString(g, 'id'))
                    .toList(),
                itemLabelBuilder: (id) => label('guests', id),
                selected: {?_guest},
                onSelectionChanged: (v) =>
                    setState(() => _selectGuest(v.firstOrNull)),
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingArrival,
                controller: _arrival,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentInventoryItemsAvailabilityItemsArrival,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingDeparture,
                controller: _departure,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentInventoryItemsAvailabilityItemsDeparture,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingBeds,
                controller: _demandBeds,
                keyboardType: TextInputType.number,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentDemandItemsBeds,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingFeatures,
                controller: _demandFeatures,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentDemandItemsRequiredFeaturesItems,
              ),
              CatchButton(
                label: l10n.programsLodgingAddDemand,
                onPressed: _demand,
              ),
              for (final row in _draft.rows('demand'))
                Text(
                  label('guests', requiredString(row, 'guestId')),
                  style: CatchTextStyles.supporting(context),
                ),
              CatchButton(
                label: l10n.programsLodgingRemove,
                variant: CatchButtonVariant.ghost,
                onPressed: _guest == null
                    ? null
                    : () => _change(() => _draft.withoutDemand(_guest!)),
              ),
            ],
          ),
          CatchSection.containedFieldRows(
            title: l10n.programsLodgingParties,
            children: [
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingParty,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsId,
                contractValueBuilder: (v) => v,
                values: _draft
                    .rows('parties')
                    .map((p) => requiredString(p, 'id'))
                    .toList(),
                selected: {?_party},
                allowEmptySelection: true,
                emptyValueText: l10n.programsLodgingAdd,
                itemLabelBuilder: (id) => stringList(
                  _draft
                      .rows('parties')
                      .singleWhere((p) => p['id'] == id)['guestIds'],
                ).map((g) => label('guests', g)).join(', '),
                onSelectionChanged: (v) => setState(() {
                  _party = v.firstOrNull;
                  final selected = _draft
                      .rows('parties')
                      .where((p) => p['id'] == _party);
                  _sharing = selected.isEmpty
                      ? {}
                      : stringList(selected.single['guestIds']).toSet();
                  _confirmed =
                      selected.isNotEmpty &&
                      selected.single['confirmed'] == true;
                  _priority.text = selected.isEmpty
                      ? '0'
                      : selected.single['priority'].toString();
                  _partyType.text = selected.isEmpty
                      ? ''
                      : selected.single['requiredRoomType'] as String? ?? '';
                  final pin = selected.isEmpty ? null : selected.single['pin'];
                  _pinHotel = pin is Map ? pin['hotelId'] as String? : null;
                  _pinRoom = pin is Map ? pin['inventoryId'] as String? : null;
                  _pinZone.text = pin is Map
                      ? pin['zoneId'] as String? ?? ''
                      : '';
                }),
              ),
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingDemand,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsGuestIds,
                contractValueBuilder: (v) => v,
                mode: CatchChipMode.multiple,
                values: _draft
                    .rows('demand')
                    .map((d) => requiredString(d, 'guestId'))
                    .toList(),
                selected: _sharing,
                itemLabelBuilder: (id) => label('guests', id),
                onSelectionChanged: (v) => setState(() => _sharing = v),
              ),
              CatchField.toggle(
                copy: copy,
                title: l10n.programsLodgingConfirmed,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsConfirmed,
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v),
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingPriority,
                controller: _priority,
                keyboardType: TextInputType.number,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsPriority,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingRoomType,
                controller: _partyType,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsRequiredRoomType,
              ),
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingPinHotel,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsPinHotelId,
                contractValueBuilder: (v) => v,
                allowEmptySelection: true,
                values: catalog
                    .rows('hotels')
                    .map((h) => requiredString(h, 'id'))
                    .toList(),
                selected: {?_pinHotel},
                itemLabelBuilder: (id) => label('hotels', id),
                onSelectionChanged: (v) =>
                    setState(() => _pinHotel = v.firstOrNull),
              ),
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingPinRoom,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsPinInventoryId,
                contractValueBuilder: (v) => v,
                allowEmptySelection: true,
                values: _draft
                    .rows('inventory')
                    .map((u) => requiredString(u, 'id'))
                    .toList(),
                selected: {?_pinRoom},
                itemLabelBuilder: (id) =>
                    _draft
                            .rows('labels')
                            .singleWhere(
                              (l) => l['inventoryId'] == id,
                            )['roomLabel']
                        as String? ??
                    id,
                onSelectionChanged: (v) =>
                    setState(() => _pinRoom = v.firstOrNull),
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingPinZone,
                controller: _pinZone,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentPartiesItemsPinZoneId,
              ),
              CatchButton(
                label: l10n.programsLodgingAddParty,
                onPressed: () => _change(() {
                  final pin = <String, Object?>{
                    if (_pinHotel != null) 'hotelId': _pinHotel,
                    if (_pinRoom != null) 'inventoryId': _pinRoom,
                    if (_text(_pinZone) != null) 'zoneId': _text(_pinZone),
                  };
                  return _draft.withParty(
                    id: _party ?? _id(),
                    guestIds: _sharing.toList(),
                    confirmed: _confirmed,
                    priority: int.parse(_priority.text),
                    requiredRoomType: _text(_partyType),
                    pin: pin.isEmpty ? null : pin,
                  );
                }),
              ),
              CatchButton(
                label: l10n.programsLodgingRemove,
                variant: CatchButtonVariant.ghost,
                onPressed: _party == null
                    ? null
                    : () => _change(() => _draft.withoutParty(_party!)),
              ),
            ],
          ),
          CatchSection.containedFieldRows(
            title: l10n.programsLodgingInventory,
            children: [
              Text(
                l10n.programsLodgingInventoryHint,
                style: CatchTextStyles.supporting(context),
              ),
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingInventory,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentInventoryItemsId,
                contractValueBuilder: (v) => v,
                allowEmptySelection: true,
                values: _draft
                    .rows('inventory')
                    .map((u) => requiredString(u, 'id'))
                    .toList(),
                selected: {?_unit},
                emptyValueText: l10n.programsLodgingAdd,
                itemLabelBuilder: (id) =>
                    _draft
                            .rows('labels')
                            .singleWhere(
                              (l) => l['inventoryId'] == id,
                            )['roomLabel']
                        as String? ??
                    id,
                onSelectionChanged: (v) =>
                    setState(() => _selectUnit(v.firstOrNull)),
              ),
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingContract,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentInventoryItemsContractId,
                contractValueBuilder: (v) => v,
                values: catalog
                    .rows('contracts')
                    .map((c) => requiredString(c, 'id'))
                    .toList(),
                selected: {?_contract},
                itemLabelBuilder: (id) => label('contracts', id),
                onSelectionChanged: (v) => setState(() {
                  _contract = v.firstOrNull;
                  if (_contract != null && _unit == null) {
                    final block = catalog.row('contracts', _contract!);
                    _inventoryArrival.text = catalog.calendarDate(
                      requiredInt(block, 'startsAtMillis'),
                    );
                    _inventoryDeparture.text = catalog.calendarDate(
                      requiredInt(block, 'endsAtMillis'),
                    );
                  }
                }),
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingZone,
                controller: _zone,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsZoneId,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingBuilding,
                controller: _building,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsBuilding,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingFloor,
                controller: _floor,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsFloor,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingWing,
                controller: _wing,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsWing,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingRoomLabel,
                controller: _label,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentLabelsItemsRoomLabel,
              ),
              CatchField.input(
                copy: copy,
                key: const ValueKey('lodging-inventory-room-type'),
                title: l10n.programsLodgingRoomType,
                controller: _type,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsRoomType,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingBeds,
                controller: _beds,
                keyboardType: TextInputType.number,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsBeds,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingOccupants,
                controller: _occupants,
                keyboardType: TextInputType.number,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsMaxOccupants,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingFeatures,
                controller: _features,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsVerifiedFeaturesItems,
              ),
              Text(
                l10n.programsLodgingResourcesHint,
                style: CatchTextStyles.supporting(context),
              ),
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingResources,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentRoomsItemsResourceIds,
                contractValueBuilder: (v) => v,
                mode: CatchChipMode.multiple,
                allowEmptySelection: true,
                values: _draft
                    .rows('rooms')
                    .map((r) => requiredString(r, 'id'))
                    .toList(),
                selected: _components,
                itemLabelBuilder: _roomLabel,
                onSelectionChanged: (v) => setState(() => _components = v),
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingArrival,
                controller: _inventoryArrival,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentInventoryItemsAvailabilityItemsArrival,
              ),
              CatchField.input(
                copy: copy,
                title: l10n.programsLodgingDeparture,
                controller: _inventoryDeparture,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentInventoryItemsAvailabilityItemsDeparture,
              ),
              CatchButton(
                label: l10n.programsLodgingAddInventory,
                onPressed: _contract == null
                    ? null
                    : () => _change(
                        () => _draft.withInventory(
                          id: _unit ?? _id(),
                          contractId: _contract!,
                          physicalRoomId: _text(_label) == null
                              ? null
                              : (_physicalRoom ?? _id()),
                          roomLabel: _text(_label),
                          zoneId: _zone.text.trim(),
                          roomType: _type.text.trim(),
                          beds: int.parse(_beds.text),
                          maxOccupants: int.parse(_occupants.text),
                          building: _text(_building),
                          floor: _text(_floor),
                          wing: _text(_wing),
                          verifiedFeatures: _list(_features),
                          resourceIds: _components.toList(),
                          position: _position,
                          availability: [
                            {
                              'arrival': _inventoryArrival.text.trim(),
                              'departure': _inventoryDeparture.text.trim(),
                            },
                            if (_unit != null)
                              ...mapList(
                                    _draft
                                        .rows('inventory')
                                        .singleWhere(
                                          (u) => u['id'] == _unit,
                                        )['availability'],
                                    'availability',
                                  )
                                  .skip(1)
                                  .map((v) => Map<String, Object?>.from(v)),
                          ],
                        ),
                      ),
              ),
              CatchButton(
                label: l10n.programsLodgingRemove,
                variant: CatchButtonVariant.ghost,
                onPressed: _unit == null
                    ? null
                    : () => _change(() => _draft.withoutInventory(_unit!)),
              ),
            ],
          ),
          CatchSection.containedFieldRows(
            title: l10n.programsLodgingNesting,
            children: [
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsGuestsGroupLabel,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentGroupParentsItemsId,
                contractValueBuilder: (v) => v,
                values: catalog
                    .rows('groups')
                    .map((g) => requiredString(g, 'id'))
                    .toList(),
                selected: {?_group},
                itemLabelBuilder: (id) => label('groups', id),
                onSelectionChanged: (v) => setState(() {
                  _group = v.firstOrNull;
                  final existing = _draft
                      .rows('groupParents')
                      .where((g) => g['id'] == _group);
                  _parents = existing.isEmpty
                      ? {}
                      : stringList(existing.single['parentIds']).toSet();
                }),
              ),
              CatchField<String>.choices(
                copy: copy,
                title: l10n.programsLodgingParents,
                contract: CatchContractConstraints
                    .programLodgingConfigDocumentGroupParentsItemsParentIds,
                contractValueBuilder: (v) => v,
                mode: CatchChipMode.multiple,
                allowEmptySelection: true,
                values: catalog
                    .rows('groups')
                    .map((g) => requiredString(g, 'id'))
                    .where((id) => id != _group)
                    .toList(),
                selected: _parents,
                itemLabelBuilder: (id) => label('groups', id),
                onSelectionChanged: (v) => setState(() => _parents = v),
              ),
              CatchButton(
                label: l10n.programsLodgingAddNesting,
                onPressed: _group == null
                    ? null
                    : () => _change(
                        () =>
                            _draft.withGroupParents(_group!, _parents.toList()),
                      ),
              ),
            ],
          ),
          if (catalog.rows('activeStays').isNotEmpty)
            CatchSection.containedFieldRows(
              title: l10n.programsLodgingAdoptions,
              children: [
                CatchField<String>.choices(
                  copy: copy,
                  title: l10n.programsLodgingAdoptions,
                  contract: CatchContractConstraints
                      .programLodgingConfigDocumentDemandItemsGuestId,
                  contractValueBuilder: (id) =>
                      requiredString(catalog.row('activeStays', id), 'guestId'),
                  values: catalog
                      .rows('activeStays')
                      .map((s) => requiredString(s, 'id'))
                      .toList(),
                  selected: {?_stay},
                  itemLabelBuilder: (id) {
                    final stay = catalog.row('activeStays', id);
                    return '${label('guests', requiredString(stay, 'guestId'))} · ${stay['roomLabel'] ?? ''}';
                  },
                  onSelectionChanged: (v) =>
                      setState(() => _stay = v.firstOrNull),
                ),
                CatchField<String>.choices(
                  copy: copy,
                  title: l10n.programsLodgingParty,
                  contract: CatchContractConstraints
                      .programLodgingConfigDocumentPartiesItemsId,
                  contractValueBuilder: (v) => v,
                  values: _draft
                      .rows('parties')
                      .map((p) => requiredString(p, 'id'))
                      .toList(),
                  selected: {?_adoptParty},
                  itemLabelBuilder: (id) => stringList(
                    _draft
                        .rows('parties')
                        .singleWhere((p) => p['id'] == id)['guestIds'],
                  ).map((g) => label('guests', g)).join(', '),
                  onSelectionChanged: (v) =>
                      setState(() => _adoptParty = v.firstOrNull),
                ),
                CatchField<String>.choices(
                  copy: copy,
                  title: l10n.programsLodgingInventory,
                  contract: CatchContractConstraints
                      .programLodgingConfigDocumentInventoryItemsId,
                  contractValueBuilder: (v) => v,
                  values: _draft
                      .rows('inventory')
                      .map((u) => requiredString(u, 'id'))
                      .toList(),
                  selected: {?_adoptUnit},
                  itemLabelBuilder: (id) =>
                      _draft
                              .rows('labels')
                              .singleWhere(
                                (l) => l['inventoryId'] == id,
                              )['roomLabel']
                          as String? ??
                      id,
                  onSelectionChanged: (v) =>
                      setState(() => _adoptUnit = v.firstOrNull),
                ),
                CatchButton(
                  label: l10n.programsLodgingAdopt,
                  onPressed:
                      _stay == null || _adoptParty == null || _adoptUnit == null
                      ? null
                      : () {
                          try {
                            final adoption = _draft.adoption(
                              stayId: _stay!,
                              partyId: _adoptParty!,
                              inventoryId: _adoptUnit!,
                            );
                            setState(() {
                              _adoptions[_stay!] = adoption;
                              _error = null;
                            });
                          } catch (error) {
                            setState(() => _error = error);
                          }
                        },
                ),
                for (final adoption in _adoptions.values)
                  Text(
                    '${l10n.programsLodgingVerified} · ${label('guests', requiredString(catalog.row('activeStays', adoption['stayId']! as String), 'guestId'))}',
                    style: CatchTextStyles.supporting(context),
                  ),
              ],
            ),
          Text(
            l10n.programsLodgingSaveHint,
            style: CatchTextStyles.supporting(context),
          ),
          CatchButton(
            label: l10n.programsLodgingSaveSetup,
            onPressed: _ready && !_busy ? _save : null,
          ),
          CatchButton(
            label: l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
            variant: CatchButtonVariant.secondary,
            onPressed: _busy ? null : widget.onCancel,
          ),
        ],
      ),
    );
  }

  String _date(int millis) =>
      _calendarDates[millis.toString()] ??
      (throw const FormatException('Refresh the program calendar dates.'));

  void _selectGuest(String? id) {
    _guest = id;
    _arrival.clear();
    _departure.clear();
    _demandBeds.text = '1';
    _demandFeatures.clear();
    if (id == null) return;
    final demand = _draft.rows('demand').where((d) => d['guestId'] == id);
    final stays = _draft.catalog
        .rows('activeStays')
        .where((s) => s['guestId'] == id);
    final row = demand.isNotEmpty
        ? demand.single
        : stays.length == 1
        ? stays.single
        : null;
    if (row == null) return;
    if (row['startsAtMillis'] != null) {
      _arrival.text = _date(requiredInt(row, 'startsAtMillis'));
    }
    if (row['endsAtMillis'] != null) {
      _departure.text = _date(requiredInt(row, 'endsAtMillis'));
    }
    if (demand.isNotEmpty) {
      _demandBeds.text = requiredInt(row, 'beds').toString();
      _demandFeatures.text = stringList(row['requiredFeatures']).join(', ');
    }
  }

  String _roomLabel(String roomId) {
    final units = _draft
        .rows('inventory')
        .where((u) => u['physicalRoomId'] == roomId);
    if (units.isEmpty) return roomId;
    return _draft
                .rows('labels')
                .singleWhere(
                  (l) => l['inventoryId'] == units.first['id'],
                )['roomLabel']
            as String? ??
        roomId;
  }

  void _selectUnit(String? id) {
    _unit = id;
    _physicalRoom = null;
    _components = {};
    _position = null;
    if (id == null) return;
    final unit = _draft.rows('inventory').singleWhere((u) => u['id'] == id);
    _contract = requiredString(unit, 'contractId');
    _physicalRoom = requiredNullableString(unit, 'physicalRoomId');
    final facts = _physicalRoom == null
        ? requiredMap(unit['provisional'], 'provisional room')
        : _draft.rows('rooms').singleWhere((r) => r['id'] == _physicalRoom);
    _zone.text = requiredString(facts, 'zoneId');
    _building.text = facts['building'] as String? ?? '';
    _floor.text = facts['floor'] as String? ?? '';
    _wing.text = facts['wing'] as String? ?? '';
    _type.text = requiredString(facts, 'roomType');
    _beds.text = requiredInt(facts, 'beds').toString();
    _occupants.text = requiredInt(facts, 'maxOccupants').toString();
    _features.text = stringList(facts['verifiedFeatures']).join(', ');
    _label.text =
        _draft
                .rows('labels')
                .singleWhere((l) => l['inventoryId'] == id)['roomLabel']
            as String? ??
        '';
    if (_physicalRoom != null) {
      _components = stringList(
        facts['resourceIds'],
      ).where((r) => r != _physicalRoom).toSet();
      _position = facts['position'] == null
          ? null
          : Map<String, Object?>.from(facts['position']! as Map);
    }
    final availability = mapList(unit['availability'], 'availability');
    _inventoryArrival.text = requiredString(availability.first, 'arrival');
    _inventoryDeparture.text = requiredString(availability.first, 'departure');
  }
}
