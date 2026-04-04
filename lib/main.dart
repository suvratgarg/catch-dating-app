import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/firebase_options.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const bool _useEmulator = true;
const bool _bypassAuth = true;

const _dummyUid = 'dev-user-001';

final _dummyUser = AppUser(
  uid: _dummyUid,
  email: 'dev@catch.app',
  name: 'Dev User',
  dateOfBirth: DateTime(1995, 6, 15),
  bio: 'Just here for the runs.',
  gender: Gender.man,
  sexualOrientation: SexualOrientation.straight,
  phoneNumber: '+10000000000',
  profileComplete: true,
  photoUrls: [],
  followedRunClubIds: [],
  interestedInGenders: [Gender.woman],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_useEmulator) {
    // Android emulator reaches the host via 10.0.2.2 instead of localhost.
    final host = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }

  runApp(
    ProviderScope(
      overrides: _bypassAuth
          ? [
              uidProvider.overrideWith((ref) => Stream.value(_dummyUid)),
              appUserStreamProvider.overrideWith(
                  (ref) => Stream.value(_dummyUser)),
            ]
          : const [],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Catch Dating App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: goRouter,
    );
  }
}
