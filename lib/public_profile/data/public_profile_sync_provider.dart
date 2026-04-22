import 'dart:async';

import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final publicProfileSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppUser?>>(appUserStreamProvider, (previous, next) {
    final user = next.asData?.value;
    if (user == null) return;

    unawaited(
      ref
          .read(publicProfileRepositoryProvider)
          .setPublicProfile(profile: publicProfileFromAppUser(user)),
    );
  }, fireImmediately: true);
});
