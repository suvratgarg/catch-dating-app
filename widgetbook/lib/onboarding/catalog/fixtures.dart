import 'package:catch_dating_app/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/image_uploads/domain/image_upload_job.dart';
import 'package:catch_dating_app/image_uploads/domain/photo_upload_state.dart';

final widgetbookOnboardingProfileNoPhotos = ProfileSurfaceFixtures.viewer
    .copyWith(profileComplete: false, profilePhotos: const []);

final widgetbookOnboardingProfileOnePhoto = ProfileSurfaceFixtures.viewer
    .copyWith(
      profileComplete: false,
      profilePhotos: ProfileSurfaceFixtures.viewer.profilePhotos
          .take(1)
          .toList(growable: false),
    );

const PhotoUploadState widgetbookOnboardingSecondPhotoUploadingState =
    PhotoUploadState(
      jobs: {1: ImageUploadJobState(stage: ImageUploadJobStage.uploading)},
    );
