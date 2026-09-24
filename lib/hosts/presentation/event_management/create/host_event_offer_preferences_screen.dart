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
    this.controllerForUser,
  });

  final String organizerId;
  final String eventId;
  final String? eventName;
  final VoidCallback onBack;
  /// Injectable so previews and focused rendering need no live Firebase call.
  final EventOfferPreferencesController? initialController;
  /// Allows the auth transition to be rendered without a live callable.
  final EventOfferPreferencesController Function(String uid)? controllerForUser;

  @override
  ConsumerState<HostEventOfferPreferencesScreen> createState() =>
      _HostEventOfferPreferencesScreenState();
}

class _HostEventOfferPreferencesScreenState
    extends ConsumerState<HostEventOfferPreferencesScreen> {
  EventOfferPreferencesController? _controller;
  String? _controllerUid;
  String? _controllerOrganizerId;
  String? _controllerEventId;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller = widget.initialController;
  }

  @override
  void didUpdateWidget(covariant HostEventOfferPreferencesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizerId == widget.organizerId &&
        oldWidget.eventId == widget.eventId &&
        identical(oldWidget.initialController, widget.initialController)) {
      return;
    }
    if (oldWidget.initialController == null) _controller?.dispose();
    _controller = widget.initialController;
    _controllerUid = null;
    _controllerOrganizerId = null;
    _controllerEventId = null;
    _error = null;
  }

  void _bindSignedInManager(String uid) {
    if (_controllerUid == uid &&
        _controllerOrganizerId == widget.organizerId &&
        _controllerEventId == widget.eventId &&
        _controller != null) {
      _error = null;
      return;
    }
    _controller?.dispose();
    _controller = null;
    _controllerUid = uid;
    _controllerOrganizerId = widget.organizerId;
    _controllerEventId = widget.eventId;
    _error = null;
    try {
      late final EventOfferPreferencesController controller;
      final factory = widget.controllerForUser;
      if (factory != null) {
        controller = factory(uid);
      } else {
        final functions = ref.read(firebaseFunctionsProvider);
        final offers = EventOfferPreferencesRepository(functions);
        final defaults = ManagerEventSetupDefaultsRepository(functions);
        controller = EventOfferPreferencesController(
          userId: uid,
          organizerId: widget.organizerId,
          eventId: widget.eventId,
          displayName: widget.eventName,
          readConfiguration: offers.get,
          readDefaults: defaults.get,
          write: offers.configure,
        );
      }
      _controller = controller;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && identical(_controller, controller)) {
          unawaited(controller.load());
        }
      });
    } catch (error) {
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
    if (widget.initialController == null) {
      final auth = ref.watch(uidProvider);
      if (auth.isLoading) {
        return const CatchScaffold.stepFlow(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (auth.hasError) {
        _error = auth.error;
      } else {
        final uid = auth.asData?.value;
        if (uid == null || uid.isEmpty) {
          _error = const SignInRequiredException('edit event offer settings');
        } else {
          _bindSignedInManager(uid);
        }
      }
    }
    final controller = _controller;
    if (controller != null && _error == null) {
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
        retryLabel: context.l10n.hostsPrivateEventRetryDefaultsRead,
        onRetry: () {
          _controller?.dispose();
          _controller = null;
          _controllerUid = null;
          _controllerOrganizerId = null;
          _controllerEventId = null;
          _error = null;
          ref.invalidate(uidProvider);
          setState(() {});
        },
        actions: [
          CatchErrorBackButton(onPressed: widget.onBack),
        ],
      ),
    );
  }
}
