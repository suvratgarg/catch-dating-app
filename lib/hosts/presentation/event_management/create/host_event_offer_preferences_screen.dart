import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/data/event_offer_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/event_offer_preferences_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manager settings for future offers on a published or legacy event.
/// Existing offers retain their recorded terms after changes here.
class HostEventOfferPreferencesScreen extends ConsumerStatefulWidget {
  const HostEventOfferPreferencesScreen({
    super.key,
    required this.organizerId,
    required this.eventId,
    required this.onBack,
    this.eventName,
    this.initialController,
  });

  final String organizerId;
  final String eventId;
  final String? eventName;
  final VoidCallback onBack;
  /// Injectable so previews and focused rendering need no live Firebase call.
  final EventOfferPreferencesController? initialController;

  @override
  ConsumerState<HostEventOfferPreferencesScreen> createState() =>
      _HostEventOfferPreferencesScreenState();
}

class _HostEventOfferPreferencesScreenState
    extends ConsumerState<HostEventOfferPreferencesScreen> {
  EventOfferPreferencesController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    try {
      final provided = widget.initialController;
      if (provided != null) {
        _controller = provided;
        return;
      }
      final uid = ref.read(uidProvider).asData?.value;
      if (uid == null || uid.isEmpty) {
        throw const SignInRequiredException('edit event offer settings');
      }
      final functions = ref.read(firebaseFunctionsProvider);
      final offers = EventOfferPreferencesRepository(functions);
      final defaults = ManagerEventSetupDefaultsRepository(functions);
      final controller = EventOfferPreferencesController(
        userId: uid,
        organizerId: widget.organizerId,
        eventId: widget.eventId,
        displayName: widget.eventName,
        readConfiguration: offers.get,
        readDefaults: defaults.get,
        write: offers.configure,
      );
      _controller = controller;
      unawaited(controller.load());
    } catch (error) {
      // The error state below remains visible until the Host leaves this route.
      _error = error;
    }
  }

  @override
  void dispose() {
    if (widget.initialController == null) _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      return PrivateEventPreferencesScreen(
        controller: controller,
        onBack: widget.onBack,
      );
    }
    return CatchScaffold.stepFlow(
      body: CatchErrorState(
        title: context.l10n.hostsEventPreferenceError,
        message: appErrorMessage(_error ??
            const FormatException('Offer settings unavailable'),
            l10n: context.l10n, context: AppErrorContext.event),
        actions: [
          CatchErrorBackButton(onPressed: widget.onBack),
        ],
      ),
    );
  }
}
