import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_action_keys.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen_state.dart';
import 'package:catch_dating_app/events/presentation/event_joined_celebration_screen.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventBookingDock extends StatelessWidget {
  const EventBookingDock({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingContent,
    this.buttonKey,
    this.isLoading = false,
    this.backgroundColor,
    this.dividerColor,
    this.buttonAccentColor,
    this.catchLine,
    this.catchLineAccent,
    this.footnote,
    this.errorMessage,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingContent;
  final Key? buttonKey;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? dividerColor;
  final Color? buttonAccentColor;
  final String? catchLine;
  final Color? catchLineAccent;
  final String? footnote;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final error = errorMessage;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (error != null) CatchErrorBanner(message: error),
        CatchBottomDock.cta(
          label: label,
          onPressed: onPressed,
          leadingContent: leadingContent,
          buttonKey: buttonKey,
          isLoading: isLoading,
          backgroundColor: backgroundColor,
          dividerColor: dividerColor,
          buttonAccentColor: buttonAccentColor,
          catchLine: catchLine,
          catchLineAccent: catchLineAccent,
          footnote: footnote,
        ),
      ],
    );
  }
}

class EventDetailCta extends ConsumerWidget {
  const EventDetailCta({
    super.key,
    required this.event,
    required this.userProfile,
    required this.clubId,
    required this.participation,
    this.inviteCode,
    this.inviteLinkId,
    this.now,
    this.darkSurface = false,
  });

  final Event event;
  final UserProfile userProfile;
  final String clubId;
  final EventParticipation? participation;
  final String? inviteCode;
  final String? inviteLinkId;
  final DateTime? now;
  final bool darkSurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, event.activityKind);
    final bookingAccent = activity.accent;
    final referenceNow = now ?? DateTime.now();
    final ctaBackground = darkSurface ? t.ink : null;
    final ctaDivider = darkSurface
        ? CatchTokens.editorialLight.withValues(
            alpha: CatchOpacity.eventDetailCtaDarkDivider,
          )
        : null;

    final supportsPaid = ref
        .watch(paymentRepositoryProvider)
        .supportsPaidBookingsForCurrency(event.currency);

    final bookMutation = ref.watch(EventBookingController.bookMutation);
    final cancelMutation = ref.watch(EventBookingController.cancelMutation);
    final joinWMutation = ref.watch(
      EventBookingController.joinWaitlistMutation,
    );
    final leaveWMutation = ref.watch(
      EventBookingController.leaveWaitlistMutation,
    );
    final acceptOfferMutation = ref.watch(
      EventBookingController.acceptWaitlistOfferMutation,
    );
    final declineOfferMutation = ref.watch(
      EventBookingController.declineWaitlistOfferMutation,
    );

    final errorMutation = [
      bookMutation,
      cancelMutation,
      joinWMutation,
      leaveWMutation,
      acceptOfferMutation,
      declineOfferMutation,
    ].firstWhere((m) => m.hasError, orElse: () => bookMutation);
    final errorMessage = errorMutation.hasError
        ? appErrorMessage(
            (errorMutation as MutationError).error,
            context: AppErrorContext.event,
          )
        : null;
    final dockState = eventDetailBookingDockStateFrom(
      event: event,
      userProfile: userProfile,
      participation: participation,
      now: referenceNow,
      hasInviteCode: inviteCode?.trim().isNotEmpty ?? false,
      supportsPaidBookings: supportsPaid,
      mutationState: EventDetailBookingDockMutationState(
        bookPending: bookMutation.isPending,
        cancelPending: cancelMutation.isPending,
        joinWaitlistPending: joinWMutation.isPending,
        leaveWaitlistPending: leaveWMutation.isPending,
        acceptWaitlistOfferPending: acceptOfferMutation.isPending,
        declineWaitlistOfferPending: declineOfferMutation.isPending,
        errorMessage: errorMessage,
      ),
    );

    if (!dockState.visible) return const SizedBox.shrink();

    return EventBookingDock(
      buttonKey: _buttonKeyFor(dockState.buttonKey),
      label: dockState.label,
      onPressed: dockState.isPrimaryActionEnabled
          ? () => _runBookingDockAction(context, ref, dockState.primaryAction)
          : null,
      isLoading: dockState.isLoading,
      buttonAccentColor: dockState.useAccent ? bookingAccent : null,
      catchLine: dockState.catchLine,
      catchLineAccent: dockState.catchLine == null ? null : bookingAccent,
      leadingContent: _leadingContentFor(context, ref, dockState),
      backgroundColor: ctaBackground,
      dividerColor: ctaDivider,
      errorMessage: dockState.errorMessage,
    );
  }

  Key? _buttonKeyFor(EventDetailBookingDockButtonKey? buttonKey) {
    return switch (buttonKey) {
      EventDetailBookingDockButtonKey.book => EventActionKeys.bookButton,
      EventDetailBookingDockButtonKey.cancelBooking =>
        EventActionKeys.cancelBookingButton,
      EventDetailBookingDockButtonKey.joinWaitlist =>
        EventActionKeys.joinWaitlistButton,
      null => null,
    };
  }

  Widget? _leadingContentFor(
    BuildContext context,
    WidgetRef ref,
    EventDetailBookingDockState state,
  ) {
    return switch (state.leadingKind) {
      EventDetailBookingDockLeadingKind.none => null,
      EventDetailBookingDockLeadingKind.price => PriceLeading(
        price: state.price ?? '',
        note: state.priceNote,
        warn: state.priceWarn,
      ),
      EventDetailBookingDockLeadingKind.booked => const BookedLeading(),
      EventDetailBookingDockLeadingKind.waitlistOffer => WaitlistOfferLeading(
        expiresAt: state.waitlistOfferExpiresAt,
        isDeclining: state.isSecondaryLoading,
        onDecline: state.isSecondaryActionEnabled
            ? () => _runBookingDockAction(context, ref, state.secondaryAction)
            : null,
      ),
      EventDetailBookingDockLeadingKind.attended => const AttendedLeading(),
    };
  }

  void _runBookingDockAction(
    BuildContext context,
    WidgetRef ref,
    EventDetailBookingDockAction action,
  ) {
    switch (action) {
      case EventDetailBookingDockAction.none:
        return;
      case EventDetailBookingDockAction.openRunPreferences:
        _openRunPreferencesGate(context);
        return;
      case EventDetailBookingDockAction.book:
        _runBookAction(context, ref);
        return;
      case EventDetailBookingDockAction.cancelBooking:
        EventBookingController.cancelMutation.run(
          ref,
          (tx) async => tx
              .get(eventBookingControllerProvider.notifier)
              .cancelBooking(event: event),
        );
        return;
      case EventDetailBookingDockAction.joinWaitlist:
        EventBookingController.joinWaitlistMutation.run(
          ref,
          (tx) async => tx
              .get(eventBookingControllerProvider.notifier)
              .joinWaitlist(
                event: event,
                inviteCode: inviteCode,
                inviteLinkId: inviteLinkId,
              ),
        );
        return;
      case EventDetailBookingDockAction.leaveWaitlist:
        EventBookingController.leaveWaitlistMutation.run(
          ref,
          (tx) async => tx
              .get(eventBookingControllerProvider.notifier)
              .leaveWaitlist(event: event),
        );
        return;
      case EventDetailBookingDockAction.acceptWaitlistOffer:
        _runAcceptWaitlistOfferAction(context, ref);
        return;
      case EventDetailBookingDockAction.declineWaitlistOffer:
        EventBookingController.declineWaitlistOfferMutation.run(
          ref,
          (tx) async => tx
              .get(eventBookingControllerProvider.notifier)
              .declineWaitlistOffer(event: event),
        );
        return;
    }
  }

  void _runBookAction(BuildContext context, WidgetRef ref) {
    final router = GoRouter.maybeOf(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    EventBookingController.bookMutation.run(ref, (tx) async {
      final data = await tx
          .get(eventBookingControllerProvider.notifier)
          .book(
            event: event,
            user: userProfile,
            inviteCode: inviteCode,
            inviteLinkId: participation?.inviteLinkId ?? inviteLinkId,
          );
      _handleBookingCompletion(
        router: router,
        navigator: navigator,
        paymentData: data,
      );
    });
  }

  void _runAcceptWaitlistOfferAction(BuildContext context, WidgetRef ref) {
    final router = GoRouter.maybeOf(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    EventBookingController.acceptWaitlistOfferMutation.run(ref, (tx) async {
      final data = await tx
          .get(eventBookingControllerProvider.notifier)
          .acceptWaitlistOffer(
            event: event,
            user: userProfile,
            inviteCode: inviteCode,
            inviteLinkId: participation?.inviteLinkId ?? inviteLinkId,
          );
      _handleBookingCompletion(
        router: router,
        navigator: navigator,
        paymentData: data,
      );
    });
  }

  void _handleBookingCompletion({
    required GoRouter? router,
    required NavigatorState navigator,
    required Object? paymentData,
  }) {
    if (paymentData != null) {
      if (router == null) return;
      unawaited(
        router.pushNamed(
          Routes.paymentConfirmationScreen.name,
          extra: paymentData,
        ),
      );
      return;
    }

    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (routeContext) => EventJoinedCelebrationScreen(
            event: event,
            onViewEvent: () => Navigator.of(routeContext).pop(),
            onBackHome: () {
              Navigator.of(routeContext).pop();
              router?.goNamed(Routes.dashboardScreen.name);
            },
          ),
        ),
      ),
    );
  }
}

void _openRunPreferencesGate(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  router.push(
    runPreferencesCompletionLocation(
      from: GoRouterState.of(context).uri.toString(),
    ),
  );
}

class PriceLeading extends StatelessWidget {
  const PriceLeading({
    super.key,
    required this.price,
    this.note,
    this.warn = false,
  });

  final String price;

  /// Secondary line under the price. Defaults to "per person"; when [warn] is
  /// true it renders as a warning-toned tracked-mono scarcity note.
  final String? note;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(price, style: CatchTextStyles.numericLarge(context)),
        warn
            ? Text(
                (note ?? '').toUpperCase(),
                style: CatchTextStyles.monoLabel(context, color: t.warning),
              )
            : Text(
                note ?? 'per person',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
      ],
    );
  }
}

class WaitlistOfferLeading extends StatelessWidget {
  const WaitlistOfferLeading({
    super.key,
    required this.expiresAt,
    required this.isDeclining,
    required this.onDecline,
  });

  final DateTime? expiresAt;
  final bool isDeclining;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final expiresLabel = expiresAt == null
        ? 'Offer active'
        : 'Until ${EventFormatters.time(expiresAt!)}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          expiresLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        CatchTextButton(
          label: isDeclining ? 'Declining' : 'Decline',
          onPressed: onDecline,
          tone: CatchTextButtonTone.neutral,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class BookedLeading extends StatelessWidget {
  const BookedLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CatchIcons.checkCircleRounded,
          color: t.primary,
          size: CatchIcon.md,
        ),
        gapW6,
        Text("You're in!", style: CatchTextStyles.labelL(context)),
      ],
    );
  }
}

class AttendedLeading extends StatelessWidget {
  const AttendedLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CatchIcons.directionsRunRounded,
          color: t.primary,
          size: CatchIcon.md,
        ),
        gapW6,
        Text('Completed', style: CatchTextStyles.labelL(context)),
      ],
    );
  }
}
