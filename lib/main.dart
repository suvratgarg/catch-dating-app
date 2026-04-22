import 'dart:async';

import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Dev bypass fixtures ───────────────────────────────────────────────────────

const _dummyUid = 'dev-user-001';

final _dummyUser = AppUser(
  uid: _dummyUid,
  name: 'Dev User',
  dateOfBirth: DateTime(1995, 6, 15),
  gender: Gender.man,
  sexualOrientation: SexualOrientation.straight,
  phoneNumber: '+10000000000',
  profileComplete: true,
  email: 'dev@catch.app',
  bio: 'Just here for the runs.',
  photoUrls: const [],
  followedRunClubIds: const [],
  interestedInGenders: const [Gender.woman],
);

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (AppConfig.useFirebaseEmulators) {
    final host = AppConfig.firebaseEmulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }

  final errorLogger = ErrorLogger();

  final container = ProviderContainer(
    overrides: AppConfig.bypassAuth
        ? [
            uidProvider.overrideWith((ref) => Stream.value(_dummyUid)),
            appUserStreamProvider.overrideWith(
              (ref) => Stream.value(_dummyUser),
            ),
          ]
        : const [],
    observers: [AsyncErrorLogger(errorLogger)],
  );

  _registerErrorHandlers(errorLogger);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

// ── Global error handlers ─────────────────────────────────────────────────────

/// Hooks into Flutter's error reporting pipeline so uncaught errors are
/// logged (and eventually sent to a crash-reporting service).
void _registerErrorHandlers(ErrorLogger errorLogger) {
  // Flutter framework errors (widget build failures, layout overflow, etc.)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorLogger.logError(details.exception, details.stack);
  };

  // Errors from the underlying platform / Dart isolate
  PlatformDispatcher.instance.onError = (error, stack) {
    errorLogger.logError(error, stack);
    return true;
  };

  // Widget build failures — show a readable error screen instead of a
  // blank red widget in debug mode
  ErrorWidget.builder = (details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('An error occurred'),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
