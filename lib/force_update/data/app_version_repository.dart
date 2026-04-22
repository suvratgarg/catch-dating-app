import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/force_update/domain/app_version_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version_repository.g.dart';

/// Reads the remote version config from `config/app_config` in Firestore.
///
/// Returns [AppVersionConfig.new] (all defaults) if the document doesn't exist
/// yet — this means no force-update gate until the document is explicitly
/// created in the Firebase Console.
class AppVersionRepository {
  const AppVersionRepository(this._db);

  final FirebaseFirestore _db;

  static const _collection = 'config';
  static const _document = 'app_config';

  Stream<AppVersionConfig> watchConfig() {
    return _db.collection(_collection).doc(_document).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return const AppVersionConfig();
      }
      return AppVersionConfig.fromJson(snap.data()!);
    });
  }
}

@Riverpod(keepAlive: true)
AppVersionRepository appVersionRepository(Ref ref) =>
    AppVersionRepository(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
Stream<AppVersionConfig> watchAppVersionConfig(Ref ref) =>
    ref.watch(appVersionRepositoryProvider).watchConfig();
