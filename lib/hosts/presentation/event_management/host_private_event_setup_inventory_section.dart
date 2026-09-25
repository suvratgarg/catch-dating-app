import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

typedef ReadPrivateEventSetupInventory = Future<PrivateEventSetupInventoryPage>
    Function({required String organizerId, required int limit, String? cursor});

/// Upcoming private events are read from the manager API, never from the
/// public rich Event feed or this device's local draft store.
class HostPrivateEventSetupInventorySection extends StatefulWidget {
  const HostPrivateEventSetupInventorySection({
    super.key,
    required this.organizerId,
    required this.read,
    required this.openSaved,
  });

  final String organizerId;
  final ReadPrivateEventSetupInventory read;
  /// Open the existing create route with initialSavedEventId, then return.
  final Future<void> Function(String eventId) openSaved;

  @override
  State<HostPrivateEventSetupInventorySection> createState() =>
      _HostPrivateEventSetupInventorySectionState();
}

class _HostPrivateEventSetupInventorySectionState
    extends State<HostPrivateEventSetupInventorySection> {
  List<PrivateEventSetupInventoryItem> _events = const [];
  String? _nextCursor;
  Object? _error;
  bool _loaded = false;
  bool _loading = false;
  bool _opening = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_load(reset: true));
    });
  }

  @override
  void didUpdateWidget(covariant HostPrivateEventSetupInventorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizerId != widget.organizerId) {
      _generation++;
      _events = const [];
      _nextCursor = null;
      _loaded = false;
      _loading = false;
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_load(reset: true));
      });
    }
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    final generation = _generation;
    final organizerId = widget.organizerId;
    final cursor = reset ? null : _nextCursor;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _events = const [];
        _nextCursor = null;
      }
    });
    try {
      final page = await widget.read(
        organizerId: organizerId,
        limit: 20,
        cursor: cursor,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        final known = _events.map((event) => event.eventId).toSet();
        _events = [
          ..._events,
          ...page.events.where((event) => known.add(event.eventId)),
        ];
        _nextCursor = page.nextCursor;
        _loaded = true;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _open(String eventId) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await widget.openSaved(eventId);
      if (mounted) await _load(reset: true);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final copy = catchFieldCopy(l10n);
    return CatchSection.fieldRows(
      title: l10n.hostsPrivateEventInventoryTitle,
      children: [
        if (_loading && !_loaded)
          CatchField.read(
            copy: copy,
            title: l10n.hostsPrivateEventInventoryLoading,
            icon: CatchIcons.scheduleOutlined,
          ),
        if (_loaded && _events.isEmpty)
          CatchField.read(
            copy: copy,
            title: l10n.hostsPrivateEventInventoryEmpty,
            icon: CatchIcons.eventAvailableOutlined,
          ),
        for (final event in _events)
          CatchField.action(
            copy: copy,
            title: event.name,
            body: _summary(context, event),
            icon: CatchIcons.eventAvailableOutlined,
            onTap: _opening ? null : () => unawaited(_open(event.eventId)),
          ),
        if (_nextCursor != null)
          CatchField.action(
            copy: copy,
            title: l10n.hostsPrivateEventInventoryLoadMore,
            onTap: _loading ? null : () => unawaited(_load(reset: false)),
          ),
        if (_error != null) ...[
          CatchField.read(
            copy: copy,
            title: l10n.hostsPrivateEventInventoryError,
            body: appErrorMessage(_error!, l10n: l10n,
                context: AppErrorContext.event),
            icon: CatchIcons.errorOutlineRounded,
          ),
          CatchField.action(
            copy: copy,
            title: l10n.hostsPrivateEventRetryDefaultsRead,
            onTap: _loading ? null : () => unawaited(_load(reset: !_loaded)),
          ),
        ],
      ],
    );
  }

  String _summary(BuildContext context, PrivateEventSetupInventoryItem event) {
    final city = defaultCityOptions.where((option) =>
        option.effectiveCityId == event.city.cityId &&
        option.effectiveMarketId == event.city.marketId).firstOrNull;
    final date = DateTime.tryParse(event.localDate);
    final dateText = date == null ? event.localDate :
        MaterialLocalizations.of(context).formatMediumDate(date);
    return '$dateText · ${event.localStartTime} · '
        '${city?.label ?? event.city.cityId}';
  }
}
