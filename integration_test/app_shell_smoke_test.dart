import 'dart:ui' as ui;

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/location_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/run_focus_rail.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/force_update/data/force_update_provider.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/onboarding/data/onboarding_draft_repository.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_keys.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_draft_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_draft.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/runs/data/run_draft_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/create_run_form_keys.dart';
import 'package:catch_dating_app/runs/presentation/run_check_in_location_service.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_keys.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart' show Icons, TextButton, TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';

import '../test/onboarding/onboarding_test_helpers.dart' as onboarding_helpers;
import '../test/run_clubs/run_clubs_test_helpers.dart' as club_helpers;
import '../test/runs/runs_test_helpers.dart' as run_helpers;
import '../test/test_pump_helpers.dart';

const _mumbai = CityData(
  name: 'mumbai',
  label: 'Mumbai',
  latitude: 19.076,
  longitude: 72.8777,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unauthenticated launch opens public club discovery', (
    tester,
  ) async {
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(uid: null, user: null, clubs: [club]),
    );

    expect(find.text('Run clubs'), findsOneWidget);
    expect(find.text('Stride Social'), findsWidgets);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets(
    'public club discovery opens club details through the real route',
    (tester) async {
      final club = club_helpers.buildRunClub(
        id: 'club-1',
        name: 'Stride Social',
        description: 'Morning runners who like easy city loops.',
      );

      await _pumpCatchApp(
        tester,
        overrides: _appOverrides(uid: null, user: null, clubs: [club]),
      );

      await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
      await pumpFeatureUi(tester);

      expect(find.text('Stride Social'), findsWidgets);
      expect(
        find.text('Morning runners who like easy city loops.'),
        findsOneWidget,
      );
      expect(find.text('Sign in to join'), findsOneWidget);
    },
  );

  testWidgets('phone auth route sends and verifies an OTP', (tester) async {
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final authRepository = onboarding_helpers.FakeAuthRepository()
      ..onVerifyPhoneNumber =
          ({
            required codeSent,
            required verificationCompleted,
            required verificationFailed,
            required codeAutoRetrievalTimeout,
          }) {
            codeSent('verification-id', null);
          };

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: null,
        user: null,
        clubs: [club],
        authRepository: authRepository,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await _tapCatchButton(tester, 'Sign in to join');
    await _tapCatchButton(tester, 'Continue with phone');

    await tester.enterText(find.byKey(AuthFormKeys.phoneField), '9876543210');
    await tester.tap(find.byKey(AuthFormKeys.sendCode));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(authRepository.verifyPhoneNumberCallCount, 1);
    expect(authRepository.verifiedPhoneNumber, '+919876543210');
    expect(find.text('Enter the code'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '123456');
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(authRepository.otpVerificationId, 'verification-id');
    expect(authRepository.otpSmsCode, '123456');
  });

  testWidgets('club detail joins through the membership action', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final runClubsRepository = club_helpers.FakeRunClubsRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        runClubsRepository: runClubsRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Join club'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runClubsRepository.joinedClubId, club.id);
  });

  testWidgets('club detail leaves through the membership action', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final runClubsRepository = club_helpers.FakeRunClubsRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        runClubsRepository: runClubsRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Leave club'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runClubsRepository.leftClubId, club.id);
  });

  testWidgets('run clubs tab creates a new club', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final runClubsRepository = club_helpers.FakeRunClubsRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        canCreateRunClub: true,
        runClubsRepository: runClubsRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await pumpFeatureUi(tester);

    await _enterRunClubText('Club name', 'Sunset Striders', tester);
    await _enterRunClubText('Area / neighbourhood', 'Bandra', tester);
    await _selectRunClubCity(tester, 'Mumbai');
    await _tapCatchButton(tester, 'Next');

    await _enterRunClubText('Description', 'Easy social club', tester);
    await _tapCatchButton(tester, 'Create club');
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runClubsRepository.lastCreateCall, isNotNull);
    expect(runClubsRepository.lastCreateCall?.name, 'Sunset Striders');
    expect(runClubsRepository.lastCreateCall?.location, 'mumbai');
    expect(runClubsRepository.lastCreateCall?.area, 'Bandra');
    expect(runClubsRepository.lastCreateCall?.description, 'Easy social club');
  });

  testWidgets('run clubs tab uploads a picked cover while creating a club', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final runClubsRepository = club_helpers.FakeRunClubsRepository();
    final pickedCover = await _generatedPngXFile('run-club-cover.png');
    final imageUploadRepository = club_helpers.FakeImageUploadRepository(
      pickedImage: pickedCover,
      uploadResult: 'https://example.com/uploaded-cover.jpg',
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        canCreateRunClub: true,
        runClubsRepository: runClubsRepository,
        imageUploadRepository: imageUploadRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Add cover photo'));
    await pumpFeatureUi(tester);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

    await _enterRunClubText('Club name', 'Sunset Striders', tester);
    await _enterRunClubText('Area / neighbourhood', 'Bandra', tester);
    await _selectRunClubCity(tester, 'Mumbai');
    await _tapCatchButton(tester, 'Next');

    await _enterRunClubText('Description', 'Easy social club', tester);
    await _tapCatchButton(tester, 'Create club');
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(imageUploadRepository.lastUploadClubId, isNotNull);
    expect(
      await imageUploadRepository.lastUploadedImage?.readAsBytes(),
      isNotEmpty,
    );
    expect(
      runClubsRepository.lastCreateCall?.imageUrl,
      imageUploadRepository.uploadResult,
    );
  });

  testWidgets('host edits a run club from club detail', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(
      id: 'club-1',
      name: 'Stride Social',
      hostUserId: user.uid,
      hostName: user.name,
    );
    final runClubsRepository = club_helpers.FakeRunClubsRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        runClubsRepository: runClubsRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.scrollUntilVisible(find.text('Edit club'), 240);
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Edit club'));
    await pumpFeatureUi(tester);

    await _tapCatchButton(tester, 'Next');
    await _enterRunClubText(
      'Description',
      'Updated host-led city loops.',
      tester,
    );
    await _tapCatchButton(tester, 'Save changes');
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runClubsRepository.lastUpdatedClubId, club.id);
    expect(
      runClubsRepository.lastUpdatedFields?['description'],
      'Updated host-led city loops.',
    );
  });

  testWidgets('club schedule opens a run detail route with booking CTA', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 2,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Carter Road Amphitheatre'));
    await pumpFeatureUi(tester);

    expect(find.text('Carter Road Amphitheatre'), findsWidgets);
    expect(find.text('Join run — 18 spots left'), findsOneWidget);
  });

  testWidgets('run detail books a free run and shows confirmation', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final paymentRepository = run_helpers.FakePaymentRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
        paymentRepository: paymentRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Carter Road Amphitheatre'));
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Join run — 19 spots left'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(paymentRepository.bookFreeRunCalled, isTrue);
    expect(paymentRepository.bookedFreeRunId, run.id);
    expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
    expect(find.text("You're in."), findsOneWidget);
  });

  testWidgets('run detail books a paid run and opens payment confirmation', (
    tester,
  ) async {
    final user = run_helpers.buildUser(
      uid: 'runner-1',
      name: 'Suvrat Garg',
      email: 'suvrat@example.com',
      phoneNumber: '+919876543210',
    );
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'paid-run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
      priceInPaise: 29900,
    );
    final paymentRepository = run_helpers.FakePaymentRepository()
      ..processPaymentResult = PaymentConfirmationData(
        paymentId: 'pay_integration_123',
        orderId: 'order_integration_123',
        amountInPaise: run.priceInPaise,
        runId: run.id,
      );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
        paymentRepository: paymentRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Carter Road Amphitheatre'));
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Book run'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(paymentRepository.processPaymentCalled, isTrue);
    expect(paymentRepository.lastProcessPaymentCall?.runId, run.id);
    expect(paymentRepository.lastProcessPaymentCall?.userName, user.name);
    expect(paymentRepository.lastProcessPaymentCall?.userEmail, user.email);
    expect(
      paymentRepository.lastProcessPaymentCall?.userContact,
      user.phoneNumber,
    );
    expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
    expect(find.text('Payment ID'), findsOneWidget);
    expect(find.text('pay_integration_123'), findsOneWidget);
    expect(find.byKey(PaymentConfirmationKeys.backHome), findsOneWidget);
  });

  testWidgets('run detail cancels an existing booking', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final runRepository = run_helpers.FakeRunRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpRuns: [run],
        runRepository: runRepository,
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(RunFocusRail.railKey),
        matching: find.text('View run'),
      ),
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Cancel booking'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runRepository.cancelledRunId, run.id);
    expect(find.text('Booking cancelled.'), findsOneWidget);
  });

  testWidgets('run detail joins a waitlist for a full run', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      capacityLimit: 20,
      bookedCount: 20,
    );
    final runRepository = run_helpers.FakeRunRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
        runRepository: runRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Carter Road Amphitheatre'));
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Join waitlist'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runRepository.joinedWaitlistRunId, run.id);
  });

  testWidgets('host creates a run from club detail', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(
      id: 'club-1',
      name: 'Stride Social',
      hostUserId: user.uid,
      hostName: user.name,
    );
    final runRepository = run_helpers.FakeRunRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        runClubsRepository: club_helpers.FakeRunClubsRepository(),
        runRepository: runRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.scrollUntilVisible(find.text('Add run'), 240);
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Add run'));
    await pumpFeatureUi(tester);

    await _submitValidRun(tester);

    expect(runRepository.createdRun, isNotNull);
    expect(runRepository.createdRun?.runClubId, club.id);
    expect(runRepository.createdRun?.meetingPoint, 'Bandra Fort');
    expect(runRepository.createdRun?.startingPointLat, 19.12345);
    expect(runRepository.createdRun?.startingPointLng, 72.98765);
    expect(runRepository.createdRun?.distanceKm, 7.5);
    expect(runRepository.createdRun?.capacityLimit, 18);
    expect(runRepository.createdRun?.priceInPaise, 24950);
    expect(find.text('RUN CREATED'), findsOneWidget);
    expect(find.text('Your run is live.'), findsOneWidget);
  });

  testWidgets('matches list opens chat and resets unread state', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final match = Match(
      id: 'match-1',
      user1Id: user.uid,
      user2Id: 'runner-2',
      runIds: const ['run-1'],
      createdAt: DateTime(2026, 4, 23, 9),
      lastMessageAt: DateTime(2026, 4, 23, 10),
      lastMessagePreview: 'See you at the run',
      lastMessageSenderId: 'runner-2',
      unreadCounts: const {'runner-1': 1},
    );
    final profile = run_helpers.buildPublicProfile(
      uid: 'runner-2',
      name: 'Taylor',
    );
    final conversationRepository = _FakeConversationRepository();
    final safetyRepository = _FakeSafetyRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        matches: [match],
        publicProfiles: [profile],
        conversationRepository: conversationRepository,
        safetyRepository: safetyRepository,
      ),
    );

    await _openTab(tester, 'Chats');
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('See you at the run'), findsOneWidget);

    await tester.tap(find.text('Taylor'));
    await pumpFeatureUi(tester);

    expect(find.text('Say hi to Taylor!'), findsOneWidget);
    expect(
      conversationRepository.markReadCalls,
      contains(('match-1', user.uid)),
    );

    await tester.enterText(find.byType(TextField), '  See you there  ');
    await tester.tap(find.byTooltip('Send message'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(
      conversationRepository.sentTextMessages,
      contains(
        _SentTextMessage(
          conversationId: match.id,
          senderId: user.uid,
          text: 'See you there',
        ),
      ),
    );

    await tester.tap(find.byTooltip('Chat actions'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Report'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(safetyRepository.reportedUserId, profile.uid);
    expect(safetyRepository.reportContextId, match.id);
    expect(find.text('Report submitted for Taylor.'), findsOneWidget);

    await tester.tap(find.byTooltip('Chat actions'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Block'));
    await pumpFeatureUi(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Block'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(safetyRepository.blockedUserId, profile.uid);
  });

  testWidgets('dashboard next-run card opens run detail', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpRuns: [run],
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(RunFocusRail.railKey),
        matching: find.text('View run'),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Carter Road Amphitheatre'), findsWidgets);
    expect(find.text('Cancel booking'), findsOneWidget);
  });

  testWidgets('dashboard self check-in records attendance', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'check-in-run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(minutes: 5)),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final runRepository = run_helpers.FakeRunRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpRuns: [run],
        runRepository: runRepository,
      ),
    );

    expect(find.text('CHECK-IN OPEN'), findsOneWidget);
    await tester.tap(find.text('Check in'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runRepository.selfCheckedInRunId, run.id);
    expect(find.text('CHECKED IN'), findsOneWidget);
    expect(find.text('Checked in.'), findsOneWidget);
  });

  testWidgets('dashboard host attendance toggles an attendee', (tester) async {
    final host = run_helpers.buildUser(uid: 'host-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(
      id: 'club-1',
      name: 'Stride Social',
      hostUserId: host.uid,
      hostName: host.name,
    );
    final run = run_helpers.buildRun(
      id: 'attendance-run-1',
      runClubId: club.id,
      startTime: DateTime.now().subtract(const Duration(minutes: 5)),
      endTime: DateTime.now().add(const Duration(minutes: 55)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final attendeeProfile = run_helpers.buildPublicProfile(
      uid: 'runner-2',
      name: 'Taylor',
    );
    final runRepository = run_helpers.FakeRunRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: host.uid,
        user: host,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
        runParticipations: {
          run.id: [
            run_helpers.buildRunParticipation(run: run, uid: 'runner-2'),
          ],
        },
        publicProfiles: [attendeeProfile],
        runRepository: runRepository,
      ),
    );

    expect(find.text('HOST TOOLS'), findsOneWidget);
    await tester.tap(find.text('Take Attendance'));
    await pumpFeatureUi(tester);

    expect(find.text('Take Attendance'), findsOneWidget);
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('Not checked in'), findsOneWidget);

    await tester.tap(find.text('Taylor'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(runRepository.markedAttendanceRunId, run.id);
    expect(runRepository.markedAttendanceUserId, 'runner-2');
  });

  testWidgets('dashboard recommended run opens run detail', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final nextRun = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      bookedCount: 1,
    );
    final recommendedRun = run_helpers.buildRun(
      id: 'recommended-run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      meetingPoint: 'Joggers Park Gate',
      bookedCount: 3,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpRuns: [nextRun],
        recommendedRuns: [recommendedRun],
      ),
    );

    final recommendedTitle = find.text(recommendedRun.title);
    for (var i = 0; i < 5; i += 1) {
      if (recommendedTitle.hitTestable().evaluate().isNotEmpty) break;
      await tester.dragFrom(const Offset(200, 700), const Offset(0, -240));
      await pumpFeatureUi(tester);
    }
    await tester.tap(recommendedTitle.hitTestable());
    await pumpFeatureUi(tester);

    expect(find.text('Joggers Park Gate'), findsWidgets);
    expect(find.text('Join run — 17 spots left'), findsOneWidget);
  });

  testWidgets('catches tab opens the swipe deck for an attended run', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final attendedRun = run_helpers.buildRun(
      id: 'attended-run-1',
      runClubId: club.id,
      startTime: DateTime.now().subtract(const Duration(hours: 11)),
      endTime: DateTime.now().subtract(const Duration(hours: 10)),
      meetingPoint: 'Bandstand Steps',
      checkedInCount: 2,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        attendedRuns: [attendedRun],
      ),
    );

    await _openTab(tester, 'Catches');
    await tester.tap(find.text('Start catching'));
    await pumpFeatureUi(tester);

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('No more runners'), findsOneWidget);
    expect(find.text('Join more runs to meet new people'), findsOneWidget);
  });

  testWidgets('catches deck records like and pass decisions', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final attendedRun = run_helpers.buildRun(
      id: 'attended-run-1',
      runClubId: club.id,
      startTime: DateTime.now().subtract(const Duration(hours: 11)),
      endTime: DateTime.now().subtract(const Duration(hours: 10)),
      meetingPoint: 'Bandstand Steps',
      checkedInCount: 3,
    );
    final firstCandidate = run_helpers.buildPublicProfile(
      uid: 'runner-2',
      name: 'Taylor',
      gender: Gender.woman,
    );
    final secondCandidate = run_helpers.buildPublicProfile(
      uid: 'runner-3',
      name: 'Riya',
      gender: Gender.woman,
    );
    final swipeRepository = _FakeSwipeRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        attendedRuns: [attendedRun],
        swipeCandidates: [firstCandidate, secondCandidate],
        swipeRepository: swipeRepository,
      ),
    );

    await _openTab(tester, 'Catches');
    await tester.tap(find.text('Start catching'));
    await pumpFeatureUi(tester);

    expect(find.text('Taylor'), findsOneWidget);

    await tester.tap(find.byKey(SwipeKeys.likeButton));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(swipeRepository.recordedSwipes, hasLength(1));
    expect(swipeRepository.recordedSwipes.single.swiperId, user.uid);
    expect(swipeRepository.recordedSwipes.single.targetId, firstCandidate.uid);
    expect(swipeRepository.recordedSwipes.single.runId, attendedRun.id);
    expect(
      swipeRepository.recordedSwipes.single.direction,
      SwipeDirection.like,
    );
    expect(find.text('Riya'), findsOneWidget);

    await tester.tap(find.byKey(SwipeKeys.passButton));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(swipeRepository.recordedSwipes, hasLength(2));
    expect(swipeRepository.recordedSwipes.last.targetId, secondCandidate.uid);
    expect(swipeRepository.recordedSwipes.last.direction, SwipeDirection.pass);
    expect(find.text('No more runners'), findsOneWidget);
  });

  testWidgets('settings opens payment history from profile', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(uid: user.uid, user: user),
    );

    await _openTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('NOTIFICATIONS'), findsOneWidget);

    await tester.tap(find.byKey(SettingsKeys.paymentHistoryRow));
    await pumpFeatureUi(tester);
    expect(find.text('Payment history'), findsOneWidget);
    expect(find.text('No payments yet'), findsOneWidget);
  });

  testWidgets('settings opens review history from profile', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(uid: user.uid, user: user),
    );

    await _openTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);

    await tester.tap(find.byKey(SettingsKeys.reviewHistoryRow));
    await pumpFeatureUi(tester);
    expect(find.text('Review history'), findsOneWidget);
    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('attended run detail submits a review', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'review-run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final reviewsRepository = _FakeReviewsRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
        attendedRuns: [run],
        reviewsRepository: reviewsRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Carter Road Amphitheatre'));
    await pumpFeatureUi(tester);
    await tester.scrollUntilVisible(
      find.byKey(ReviewKeys.writeReviewButton),
      300,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ReviewKeys.writeReviewButton));
    await pumpFeatureUi(tester);

    await tester.tap(find.byKey(ReviewKeys.ratingStar(4)));
    await tester.enterText(find.byType(TextField), '  Friendly crew.  ');
    await tester.tap(find.byKey(ReviewKeys.submitReviewButton));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(reviewsRepository.addedReview?.runClubId, club.id);
    expect(reviewsRepository.addedReview?.runId, run.id);
    expect(reviewsRepository.addedReview?.reviewerUserId, user.uid);
    expect(reviewsRepository.addedReview?.reviewerName, user.name);
    expect(reviewsRepository.addedReview?.rating, 4);
    expect(reviewsRepository.addedReview?.comment, 'Friendly crew.');
  });

  testWidgets('review history edits and deletes an existing review', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final run = run_helpers.buildRun(
      id: 'review-run-1',
      runClubId: 'club-1',
      meetingPoint: 'Carter Road Amphitheatre',
    );
    final review = run_helpers.buildReview(
      id: '${run.id}~${user.uid}',
      runClubId: run.runClubId,
      runId: run.id,
      reviewerUserId: user.uid,
      reviewerName: user.name,
      rating: 3,
      comment: 'Good route.',
    );
    final reviewsRepository = _FakeReviewsRepository(reviewsByUser: [review]);

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        signedUpRuns: [run],
        reviewsByUser: [review],
        reviewsRepository: reviewsRepository,
      ),
    );

    await _openTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(SettingsKeys.reviewHistoryRow));
    await pumpFeatureUi(tester);

    expect(find.text('Good route.'), findsOneWidget);

    await tester.tap(find.byKey(ReviewKeys.editReviewButton(review.id)));
    await pumpFeatureUi(tester);
    await tester.enterText(find.byType(TextField), '  Even better now.  ');
    await tester.tap(find.byKey(ReviewKeys.ratingStar(5)));
    await tester.tap(find.byKey(ReviewKeys.submitReviewButton));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(reviewsRepository.updatedReview?.id, review.id);
    expect(reviewsRepository.updatedReview?.rating, 5);
    expect(reviewsRepository.updatedReview?.comment, 'Even better now.');

    await tester.tap(find.byKey(ReviewKeys.editReviewButton(review.id)));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ReviewKeys.deleteReviewButton));
    await pumpFeatureUi(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(reviewsRepository.deletedReviewId, review.id);
  });

  testWidgets('settings signs out through auth controller', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final authRepository = _FakeAuthRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        authRepository: authRepository,
      ),
    );

    await _openTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('NOTIFICATIONS'), findsOneWidget);
    await tester.tap(find.byKey(SettingsKeys.signOutRow));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(authRepository.signOutCallCount, 1);
  });

  testWidgets(
    'settings updates notification preferences and unblocks account',
    (tester) async {
      final user = run_helpers
          .buildUser(uid: 'runner-1', name: 'Suvrat Garg')
          .copyWith(prefsWeeklyDigest: false);
      final userProfileRepository = _FakeUserProfileRepository();
      final safetyRepository = _FakeSafetyRepository(
        blockedUsers: [
          BlockedUser(
            uid: 'blocked-1',
            source: 'chat',
            createdAt: DateTime(2026, 5, 1),
          ),
        ],
      );
      final blockedProfile = run_helpers.buildPublicProfile(
        uid: 'blocked-1',
        name: 'Riya',
      );

      await _pumpCatchApp(
        tester,
        overrides: _appOverrides(
          uid: user.uid,
          user: user,
          userProfileRepository: userProfileRepository,
          safetyRepository: safetyRepository,
          publicProfiles: [blockedProfile],
        ),
      );

      await _openTab(tester, 'Profile');
      await tester.tap(find.byTooltip('Settings'));
      await pumpFeatureUi(tester);
      await tester.scrollUntilVisible(
        find.byKey(SettingsKeys.weeklyDigestSwitch),
        240,
      );
      await pumpFeatureUi(tester);
      await tester.tap(find.byKey(SettingsKeys.weeklyDigestSwitch));
      await flushTestEventQueue();
      await pumpFeatureUi(tester);

      expect(userProfileRepository.updatedUid, user.uid);
      expect(userProfileRepository.updatedFields, {'prefsWeeklyDigest': true});

      await tester.scrollUntilVisible(find.text('Riya'), 240);
      await pumpFeatureUi(tester);
      await tester.tap(find.byKey(SettingsKeys.unblockButton('blocked-1')));
      await flushTestEventQueue();
      await pumpFeatureUi(tester);

      expect(safetyRepository.unblockedUserId, 'blocked-1');
      expect(find.text('Account unblocked.'), findsOneWidget);
    },
  );

  testWidgets('settings requests account deletion after confirmation', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final safetyRepository = _FakeSafetyRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        safetyRepository: safetyRepository,
      ),
    );

    await _openTab(tester, 'Profile');
    await tester.tap(find.byTooltip('Settings'));
    await pumpFeatureUi(tester);
    await tester.scrollUntilVisible(
      find.byKey(SettingsKeys.deleteAccountRow),
      320,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(SettingsKeys.deleteAccountRow));
    await pumpFeatureUi(tester);

    expect(find.text('Delete account?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(safetyRepository.requestDeletionCallCount, 1);
  });

  testWidgets(
    'authenticated shell initializes push messaging and crash context',
    (tester) async {
      final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
      final fcmService = _RecordingFcmService();
      final crashReporter = _RecordingCrashReporter();
      final errorLogger = ErrorLogger(
        crashReporter: crashReporter,
        shouldReportErrors: true,
      );

      await _pumpCatchApp(
        tester,
        overrides: _appOverrides(
          uid: user.uid,
          user: user,
          errorLogger: errorLogger,
          fcmService: fcmService,
          initializeFcm: true,
        ),
      );
      await flushTestEventQueue();
      await pumpFeatureUi(tester);

      expect(fcmService.initializedUids, [user.uid]);
      expect(crashReporter.customKeys['user_id'], user.uid);
    },
  );

  testWidgets('app router reports screen views to analytics', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final reporter = _RecordingAnalyticsReporter();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        analytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      ),
    );
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await flushTestEventQueue();
    await pumpFeatureUi(tester);

    expect(reporter.screenViews, contains(Routes.runClubDetailScreen.name));
  });

  testWidgets('incomplete profiles resume onboarding before app shell', (
    tester,
  ) async {
    final user = run_helpers
        .buildUser(uid: 'runner-1', name: 'Suvrat Garg')
        .copyWith(profileComplete: false, photoUrls: const []);

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(uid: user.uid, user: user),
    );

    expect(find.text('Show yourself'), findsOneWidget);
    expect(find.text('Add 2 more photos to continue.'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('authenticated shell loads the five primary feature tabs', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final joinedClub = club_helpers.buildRunClub(
      id: 'club-1',
      name: 'Stride Social',
      nextRunLabel: 'Sat 6:30 AM',
    );
    final nextRun = run_helpers.buildRun(
      id: 'run-1',
      runClubId: joinedClub.id,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      bookedCount: 1,
    );
    final attendedRun = run_helpers.buildRun(
      id: 'attended-run-1',
      runClubId: joinedClub.id,
      startTime: DateTime.now().subtract(const Duration(hours: 11)),
      endTime: DateTime.now().subtract(const Duration(hours: 10)),
      checkedInCount: 2,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [joinedClub],
        joinedClubIds: {joinedClub.id},
        signedUpRuns: [nextRun],
        attendedRuns: [attendedRun],
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.textContaining('NEXT RUN'), findsOneWidget);

    await _openTab(tester, 'Clubs');
    expect(find.text('Run clubs'), findsOneWidget);
    expect(find.text('Stride Social'), findsWidgets);

    await _openTab(tester, 'Catches');
    expect(find.text('After the run'), findsOneWidget);
    expect(find.text('Start catching'), findsOneWidget);

    await _openTab(tester, 'Chats');
    expect(find.text('Chats'), findsWidgets);
    expect(find.text('No catches yet'), findsOneWidget);

    await _openTab(tester, 'Profile');
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Display name'), findsOneWidget);
  });
}

Future<void> _pumpCatchApp(
  WidgetTester tester, {
  required List<Object> overrides,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(overrides: overrides.cast(), child: const MyApp()),
  );
  await pumpFeatureUi(tester);
}

Future<void> _submitValidRun(WidgetTester tester) async {
  await _fillCreateRunBasicsStep(tester);
  await _tapCatchButton(tester, 'Next');

  await _enterCreateRunText(
    tester,
    CreateRunFormKeys.meetingPoint,
    'Bandra Fort',
  );
  await _pickCreateRunMapPoint(tester);
  await _enterCreateRunText(
    tester,
    CreateRunFormKeys.locationDetails,
    'Meet at the gate',
  );
  await _tapCatchButton(tester, 'Next');

  await _pickFutureRunDate(tester);
  await _acceptInitialRunTime(tester);
  await _tapCatchButton(tester, 'Next');

  await _enterCreateRunText(tester, CreateRunFormKeys.minAge, '21');
  await _enterCreateRunText(tester, CreateRunFormKeys.maxAge, '35');
  await _enterCreateRunText(tester, CreateRunFormKeys.maxMen, '9');
  await _enterCreateRunText(tester, CreateRunFormKeys.maxWomen, '9');
  await _tapCatchButton(tester, 'Schedule run');
}

Future<void> _enterRunClubText(
  String label,
  String text,
  WidgetTester tester,
) async {
  await tester.enterText(find.widgetWithText(CatchTextField, label), text);
}

Future<void> _selectRunClubCity(WidgetTester tester, String label) async {
  tester.binding.focusManager.primaryFocus?.unfocus();
  await tester.pump();
  final cityDropdownIcon = find.byIcon(Icons.expand_more_rounded);
  await tester.ensureVisible(cityDropdownIcon);
  await tester.tap(cityDropdownIcon);
  await pumpFeatureUi(tester);
  await tester.tap(find.text(label).hitTestable());
  await pumpFeatureUi(tester);
}

Future<void> _fillCreateRunBasicsStep(WidgetTester tester) async {
  await _enterCreateRunText(tester, CreateRunFormKeys.distance, '7.5');
  await _enterCreateRunText(tester, CreateRunFormKeys.capacity, '18');
  await _enterCreateRunText(tester, CreateRunFormKeys.price, '249.5');
  await tester.tap(find.text('MODERATE'));
  await _enterCreateRunText(
    tester,
    CreateRunFormKeys.description,
    'Social pacing with a coffee stop.',
  );
  await pumpFeatureUi(tester);
}

Future<void> _pickCreateRunMapPoint(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateRunFormKeys.mapPicker));
  await pumpFeatureUi(tester);

  final googleMap = tester.widget<gmaps.GoogleMap>(
    find.byType(gmaps.GoogleMap),
  );
  const selectedPoint = LocationCoordinate(19.12345, 72.98765);
  googleMap.onTap?.call(
    gmaps.LatLng(selectedPoint.latitude, selectedPoint.longitude),
  );
  await tester.pump();
  await tester.tap(find.text('Confirm'));
  await pumpFeatureUi(tester);
}

Future<void> _pickFutureRunDate(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateRunFormKeys.datePicker));
  await pumpFeatureUi(tester);
  await tester.tap(find.byTooltip('Next month'));
  await pumpFeatureUi(tester);
  await tester.tap(find.text('1').hitTestable());
  await pumpFeatureUi(tester);
  await tester.tap(find.text('OK'));
  await pumpFeatureUi(tester);
}

Future<void> _acceptInitialRunTime(WidgetTester tester) async {
  await tester.tap(find.byKey(CreateRunFormKeys.timePicker));
  await pumpFeatureUi(tester);
  await tester.tap(find.text('OK'));
  await pumpFeatureUi(tester);
}

Future<void> _enterCreateRunText(
  WidgetTester tester,
  Key fieldKey,
  String text,
) async {
  await tester.enterText(
    find.descendant(of: find.byKey(fieldKey), matching: find.byType(TextField)),
    text,
  );
}

Future<void> _tapCatchButton(WidgetTester tester, String label) async {
  tester.binding.focusManager.primaryFocus?.unfocus();
  await tester.pump();
  final buttonFinder = find.widgetWithText(CatchButton, label);
  await tester.ensureVisible(buttonFinder);
  await tester.tap(buttonFinder);
  await pumpFeatureUi(tester);
}

Future<XFile> _generatedPngXFile(String name) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(const ui.Color(0xFFFF6B4A), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 2);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return XFile.fromData(
    byteData!.buffer.asUint8List(),
    name: name,
    mimeType: 'image/png',
  );
}

List<Object> _appOverrides({
  required String? uid,
  required UserProfile? user,
  List<RunClub> clubs = const [],
  Set<String> joinedClubIds = const {},
  List<Run> signedUpRuns = const [],
  List<Run> attendedRuns = const [],
  List<Run> recommendedRuns = const [],
  Map<String, List<Run>> clubRuns = const {},
  Map<String, List<RunParticipation>> runParticipations = const {},
  Map<String, List<Review>> clubReviews = const {},
  Map<String, List<Review>> runReviews = const {},
  List<Review> reviewsByUser = const [],
  bool canCreateRunClub = false,
  List<PublicProfile> swipeCandidates = const [],
  List<Match> matches = const [],
  List<PublicProfile> publicProfiles = const [],
  ConversationRepository? conversationRepository,
  PaymentRepository? paymentRepository,
  RunRepository? runRepository,
  RunClubsRepository? runClubsRepository,
  AuthRepository? authRepository,
  SafetyRepository? safetyRepository,
  UserProfileRepository? userProfileRepository,
  ReviewsRepository? reviewsRepository,
  SwipeRepository? swipeRepository,
  ImageUploadRepository? imageUploadRepository,
  AppAnalytics? analytics,
  ErrorLogger? errorLogger,
  FcmService? fcmService,
  bool initializeFcm = false,
}) {
  final joinedClubs = clubs
      .where((club) => joinedClubIds.contains(club.id))
      .toList(growable: false);
  final knownRunsById = <String, Run>{
    for (final run in signedUpRuns) run.id: run,
    for (final run in attendedRuns) run.id: run,
    for (final run in recommendedRuns) run.id: run,
    for (final run in clubRuns.values.expand((runs) => runs)) run.id: run,
  };
  final clubsById = {for (final club in clubs) club.id: club};
  final knownRunClubIds = knownRunsById.values
      .map((run) => run.runClubId)
      .toSet();
  final participationsByRunId = <String, RunParticipation>{
    if (uid != null)
      for (final run in signedUpRuns)
        run.id: run_helpers.buildRunParticipation(run: run, uid: uid),
    if (uid != null)
      for (final run in attendedRuns)
        run.id: run_helpers.buildRunParticipation(
          run: run,
          uid: uid,
          status: RunParticipationStatus.attended,
        ),
  };

  return [
    forceUpdateRequiredProvider.overrideWithValue(const AsyncData(false)),
    forceUpdateRefreshProvider.overrideWithValue(
      (ref, {required invalidatePackageInfo, shouldInvalidate}) async {},
    ),
    locationInitializerProvider.overrideWith(_NoopLocationInitializer.new),
    appAnalyticsProvider.overrideWithValue(
      analytics ??
          AppAnalytics(
            reporter: const _NoopAnalyticsReporter(),
            shouldCollect: false,
          ),
    ),
    errorLoggerProvider.overrideWithValue(
      errorLogger ?? ErrorLogger(shouldReportErrors: false),
    ),
    appConnectivityProvider.overrideWith(
      (ref) => Stream.value(const [ConnectivityResult.wifi]),
    ),
    deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
    cityListProvider.overrideWith((ref) async => const [_mumbai]),
    onboardingDraftRepositoryProvider.overrideWithValue(
      onboarding_helpers.FakeOnboardingDraftRepository(),
    ),
    authRepositoryProvider.overrideWithValue(
      authRepository ?? _FakeAuthRepository(),
    ),
    userProfileRepositoryProvider.overrideWithValue(
      userProfileRepository ?? _FakeUserProfileRepository(),
    ),
    uidProvider.overrideWith((ref) => Stream.value(uid)),
    watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
    watchRunClubsByLocationProvider(
      _mumbai.name,
    ).overrideWith((ref) => Stream.value(clubs)),
    reviewsRepositoryProvider.overrideWithValue(
      reviewsRepository ??
          _FakeReviewsRepository(
            clubReviews: clubReviews,
            runReviews: runReviews,
            reviewsByUser: reviewsByUser,
          ),
    ),
    runClubsRepositoryProvider.overrideWithValue(
      runClubsRepository ?? club_helpers.FakeRunClubsRepository(),
    ),
    runClubDraftRepositoryProvider.overrideWithValue(
      _FakeRunClubDraftRepository(),
    ),
    swipeCandidateRepositoryProvider.overrideWithValue(
      _FakeSwipeCandidateRepository(candidates: swipeCandidates),
    ),
    swipeRepositoryProvider.overrideWithValue(
      swipeRepository ?? _FakeSwipeRepository(),
    ),
    safetyRepositoryProvider.overrideWithValue(
      safetyRepository ?? _FakeSafetyRepository(),
    ),
    publicProfileRepositoryProvider.overrideWithValue(
      _FakePublicProfileRepository(publicProfiles),
    ),
    if (imageUploadRepository != null)
      imageUploadRepositoryProvider.overrideWithValue(imageUploadRepository),
    if (fcmService != null) fcmServiceProvider.overrideWithValue(fcmService),
    for (final club in clubs) ...[
      watchRunClubProvider(club.id).overrideWith((ref) => Stream.value(club)),
      watchRunsForClubProvider(
        club.id,
      ).overrideWithValue(AsyncData<List<Run>>(clubRuns[club.id] ?? const [])),
      watchReviewsForClubProvider(club.id).overrideWithValue(
        AsyncData<List<Review>>(clubReviews[club.id] ?? const []),
      ),
      if (uid != null)
        watchRunClubMembershipProvider(club.id, uid).overrideWith(
          (ref) => Stream.value(
            joinedClubIds.contains(club.id)
                ? RunClubMembership(
                    id: runClubMembershipId(clubId: club.id, uid: uid),
                    clubId: club.id,
                    uid: uid,
                    role: RunClubMembershipRole.member,
                    status: RunClubMembershipStatus.active,
                    joinedAt: DateTime(2026, 1, 1),
                  )
                : null,
          ),
        ),
    ],
    for (final runClubId in knownRunClubIds)
      fetchRunClubProvider(
        runClubId,
      ).overrideWith((ref) async => _clubById(clubs, runClubId)),
    for (final run in knownRunsById.values) ...[
      watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
      watchReviewsForRunProvider(run.id).overrideWithValue(
        AsyncData<List<Review>>(runReviews[run.id] ?? const []),
      ),
      watchRunParticipationsForRunProvider(run.id).overrideWithValue(
        AsyncData<List<RunParticipation>>(
          runParticipations[run.id] ?? const [],
        ),
      ),
      if (uid != null) ...[
        watchSavedRunProvider(
          uid,
          run.id,
        ).overrideWithValue(const AsyncData(null)),
        watchRunParticipationProvider(
          run.id,
          uid,
        ).overrideWithValue(AsyncData(participationsByRunId[run.id])),
      ],
    ],
    runClubsListViewModelProvider.overrideWithValue(
      AsyncData(
        RunClubsListViewModel(
          joinedClubs: joinedClubs,
          allClubs: clubs,
          joinedClubIds: joinedClubIds,
        ),
      ),
    ),
    canCreateRunClubProvider.overrideWithValue(AsyncData(canCreateRunClub)),
    runRepositoryProvider.overrideWithValue(
      runRepository ?? run_helpers.FakeRunRepository(),
    ),
    runDraftRepositoryProvider.overrideWithValue(_FakeRunDraftRepository()),
    paymentRepositoryProvider.overrideWithValue(
      paymentRepository ?? run_helpers.FakePaymentRepository(),
    ),
    celebrationEffectsControllerProvider.overrideWithValue(
      const _NoopCelebrationEffectsController(),
    ),
    runCheckInLocationServiceProvider.overrideWithValue(
      const _FakeRunCheckInLocationService(),
    ),
    if (uid != null) ...[
      if (!initializeFcm)
        appShellFcmInitializationProvider(uid).overrideWith((ref) async {}),
      watchSignedUpRunsProvider(
        uid,
      ).overrideWithValue(AsyncData<List<Run>>(signedUpRuns)),
      watchAttendedRunsProvider(
        uid,
      ).overrideWithValue(AsyncData<List<Run>>(attendedRuns)),
      dashboardRecommendedRunsProvider(
        DashboardRecommendationsQuery(
          userId: uid,
          followedClubIds: joinedClubIds.toList(growable: false),
        ),
      ).overrideWithValue(
        AsyncData<List<DashboardRunRecommendationCandidate>>([
          for (final run in recommendedRuns)
            DashboardRunRecommendationCandidate(
              run: run,
              clubName: clubsById[run.runClubId]?.name ?? 'Run club',
              clubLocation: clubsById[run.runClubId]?.location,
            ),
        ]),
      ),
      watchActivityNotificationsProvider(
        uid,
      ).overrideWithValue(const AsyncData([])),
      watchPaymentsForUserProvider(
        uid,
      ).overrideWith((ref) => Stream.value(const [])),
      watchReviewsByUserProvider(
        uid,
      ).overrideWith((ref) => Stream.value(reviewsByUser)),
      watchActiveRunClubMembershipsForUserProvider(uid).overrideWith(
        (ref) => Stream.value([
          for (final clubId in joinedClubIds)
            RunClubMembership(
              id: runClubMembershipId(clubId: clubId, uid: uid),
              clubId: clubId,
              uid: uid,
              role: RunClubMembershipRole.member,
              status: RunClubMembershipStatus.active,
              joinedAt: DateTime(2026, 1, 1),
            ),
        ]),
      ),
      watchRunClubsHostedByProvider(uid).overrideWithValue(
        AsyncData<List<RunClub>>(
          clubs.where((club) => club.hostUserId == uid).toList(growable: false),
        ),
      ),
      watchMatchesForUserProvider(
        uid,
      ).overrideWith((ref) => Stream.value(matches)),
      totalUnreadCountProvider(uid).overrideWithValue(0),
      conversationRepositoryProvider.overrideWithValue(
        conversationRepository ?? _FakeConversationRepository(),
      ),
      for (final match in matches) ...[
        matchStreamProvider(
          match.id,
        ).overrideWith((ref) => Stream.value(match)),
        watchConversationMessagesProvider(
          match.id,
        ).overrideWith((ref) => Stream.value(const <ChatMessage>[])),
      ],
      for (final profile in publicProfiles)
        watchPublicProfileProvider(
          profile.uid,
        ).overrideWith((ref) => Stream.value(profile)),
      if (matches.isEmpty)
        chatsListViewModelProvider.overrideWithValue(
          const AsyncData(
            ChatsListViewModel(
              newMatches: [],
              conversations: [],
              totalThreadCount: 0,
            ),
          ),
        ),
    ],
  ];
}

RunClub? _clubById(List<RunClub> clubs, String id) {
  for (final club in clubs) {
    if (club.id == id) return club;
  }
  return null;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await pumpFeatureUi(tester);
}

class _NoopLocationInitializer extends LocationInitializer {
  @override
  Future<void> build() async {}
}

class _NoDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

class _FakeRunCheckInLocationService implements RunCheckInLocationService {
  const _FakeRunCheckInLocationService();

  @override
  Future<RunCheckInLocation> getCurrentLocation() async {
    return const RunCheckInLocation(latitude: 19.07, longitude: 72.87);
  }
}

class _RecordingFcmService extends FcmService {
  _RecordingFcmService()
    : super(FakeFirebaseFirestore(), ErrorLogger(shouldReportErrors: false));

  final initializedUids = <String>[];

  @override
  bool get isSupportedPlatform => true;

  @override
  Future<void> initialize({
    required String uid,
    required GoRouter router,
  }) async {
    initializedUids.add(uid);
  }
}

class _RecordingCrashReporter implements CrashReporter {
  final customKeys = <String, Object>{};
  final recordedErrors = <Object>[];
  bool? collectionEnabled;

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value;
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {
    recordedErrors.add(error);
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    recordedErrors.add(details.exception);
  }
}

class _RecordingAnalyticsReporter implements AnalyticsReporter {
  final screenViews = <String>[];
  final events = <String>[];
  bool? collectionEnabled;
  String? userId;

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add(name);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    screenViews.add(screenName);
  }

  @override
  Future<void> setUserId(String? userId) async {
    this.userId = userId;
  }
}

class _NoopAnalyticsReporter implements AnalyticsReporter {
  const _NoopAnalyticsReporter();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}

class _FakeAuthRepository implements AuthRepository {
  int signOutCallCount = 0;

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserProfileRepository implements UserProfileRepository {
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> fields,
    String action = 'update profile',
  }) async {
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(fields);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReviewsRepository implements ReviewsRepository {
  _FakeReviewsRepository({
    this.clubReviews = const {},
    this.runReviews = const {},
    this.reviewsByUser = const [],
  });

  final Map<String, List<Review>> clubReviews;
  final Map<String, List<Review>> runReviews;
  final List<Review> reviewsByUser;
  Review? addedReview;
  Review? updatedReview;
  String? deletedReviewId;

  @override
  Stream<List<Review>> watchReviewsForClub(String runClubId) {
    return Stream.value(clubReviews[runClubId] ?? const []);
  }

  @override
  Stream<List<Review>> watchReviewsForRun(String runId) {
    return Stream.value(runReviews[runId] ?? const []);
  }

  @override
  Stream<List<Review>> watchReviewsByUser(String reviewerUserId) {
    return Stream.value(reviewsByUser);
  }

  @override
  Stream<Review?> watchUserReviewForRun({
    required String runId,
    required String reviewerUserId,
  }) {
    for (final review in runReviews[runId] ?? const <Review>[]) {
      if (review.reviewerUserId == reviewerUserId) {
        return Stream.value(review);
      }
    }
    return Stream.value(null);
  }

  @override
  Future<void> addReview(Review review) async {
    addedReview = review;
  }

  @override
  Future<void> updateReview(Review review) async {
    updatedReview = review;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    deletedReviewId = reviewId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePublicProfileRepository implements PublicProfileRepository {
  const _FakePublicProfileRepository(this.profiles);

  final List<PublicProfile> profiles;

  @override
  Future<List<PublicProfile>> fetchPublicProfiles(List<String> uids) async {
    final requested = uids.toSet();
    return profiles
        .where((profile) => requested.contains(profile.uid))
        .toList(growable: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRunDraftRepository implements RunDraftRepository {
  @override
  Future<List<RunDraft>> loadDrafts({
    required String runClubId,
    required String userId,
  }) async {
    return const [];
  }

  @override
  Future<void> saveDraft({
    required String userId,
    required RunDraft draft,
  }) async {}

  @override
  Future<void> deleteDraft({
    required String runClubId,
    required String userId,
    required String draftId,
  }) async {}

  @override
  Future<void> deleteAllDrafts({
    required String runClubId,
    required String userId,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRunClubDraftRepository implements RunClubDraftRepository {
  @override
  Future<RunClubDraft?> loadDraft({required String userId}) async => null;

  @override
  Future<void> saveDraft({
    required String userId,
    required RunClubDraft draft,
  }) async {}

  @override
  Future<void> deleteDraft({required String userId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopCelebrationEffectsController extends CelebrationEffectsController {
  const _NoopCelebrationEffectsController();

  @override
  Future<void> play(CelebrationMomentKind kind) async {}
}

class _FakeConversationRepository implements ConversationRepository {
  final List<(String conversationId, String uid)> markReadCalls = [];
  final List<_SentTextMessage> sentTextMessages = [];

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) =>
      Stream.value(const []);

  @override
  String createMessageId({required String conversationId}) => 'message-1';

  @override
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    sentTextMessages.add(
      _SentTextMessage(
        conversationId: conversationId,
        senderId: senderId,
        text: text,
      ),
    );
  }

  @override
  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  }) async {}

  @override
  Future<void> markRead({
    required String conversationId,
    required String uid,
  }) async {
    markReadCalls.add((conversationId, uid));
  }
}

class _FakeSwipeCandidateRepository implements SwipeCandidateRepository {
  const _FakeSwipeCandidateRepository({this.candidates = const []});

  final List<PublicProfile> candidates;

  @override
  Future<List<PublicProfile>> fetchCandidates({
    required String runId,
    required UserProfile currentUser,
  }) async {
    return candidates;
  }
}

class _FakeSwipeRepository implements SwipeRepository {
  final List<Swipe> recordedSwipes = [];

  @override
  Future<void> recordSwipe({required Swipe swipe}) async {
    recordedSwipes.add(swipe);
  }

  @override
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async {
    return recordedSwipes
        .where((swipe) => swipe.swiperId == uid)
        .map((swipe) => swipe.targetId)
        .toSet();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSafetyRepository implements SafetyRepository {
  _FakeSafetyRepository({this.blockedUsers = const []});

  final List<BlockedUser> blockedUsers;
  String? blockedUserId;
  String? blockSource;
  String? unblockedUserId;
  String? reportedUserId;
  String? reportSource;
  String? reportContextId;
  String? reportReasonCode;
  int requestDeletionCallCount = 0;

  @override
  Stream<List<BlockedUser>> watchBlockedUsers({required String uid}) {
    return Stream.value(blockedUsers);
  }

  @override
  Future<Set<String>> fetchBlockedUserIds({required String uid}) async {
    return const {};
  }

  @override
  Future<void> blockUser({
    required String targetUserId,
    String source = 'profile',
  }) async {
    blockedUserId = targetUserId;
    blockSource = source;
  }

  @override
  Future<void> unblockUser({required String targetUserId}) async {
    unblockedUserId = targetUserId;
  }

  @override
  Future<void> reportUser({
    required String targetUserId,
    String source = 'profile',
    String? reasonCode,
    String? contextId,
    String? notes,
  }) async {
    reportedUserId = targetUserId;
    reportSource = source;
    reportContextId = contextId;
    reportReasonCode = reasonCode;
  }

  @override
  Future<void> requestAccountDeletion() async {
    requestDeletionCallCount += 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SentTextMessage {
  const _SentTextMessage({
    required this.conversationId,
    required this.senderId,
    required this.text,
  });

  final String conversationId;
  final String senderId;
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SentTextMessage &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId &&
          senderId == other.senderId &&
          text == other.text;

  @override
  int get hashCode => Object.hash(conversationId, senderId, text);
}
