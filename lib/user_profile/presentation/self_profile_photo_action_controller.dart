import 'package:catch_dating_app/image_uploads/presentation/profile_photo_editor_screen.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_edit_tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelfProfilePhotoActionController {
  const SelfProfilePhotoActionController();

  SelfProfilePhotoEditorRequest editorRequest({
    required SelfProfilePhotoGridState state,
    required int index,
  }) {
    return SelfProfilePhotoEditorRequest(
      index: index,
      photo: index < state.profilePhotos.length
          ? state.profilePhotos[index]
          : null,
      canDelete: state.canDeletePhotos,
    );
  }

  SelfProfilePhotoDeleteIntent deleteIntent(int index) {
    return SelfProfilePhotoDeleteIntent(index: index);
  }

  SelfProfilePhotoReorderIntent reorderIntent({
    required int fromIndex,
    required int toIndex,
  }) {
    return SelfProfilePhotoReorderIntent(
      fromIndex: fromIndex,
      toIndex: toIndex,
    );
  }

  Future<void> openEditor({
    required BuildContext context,
    required WidgetRef ref,
    required SelfProfilePhotoGridState state,
    required int index,
  }) {
    final request = editorRequest(state: state, index: index);
    return openProfilePhotoEditor(
      context: context,
      ref: ref,
      index: request.index,
      photo: request.photo,
      canDelete: request.canDelete,
    );
  }

  Future<void> deletePhoto({required WidgetRef ref, required int index}) {
    final intent = deleteIntent(index);
    return PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
      await tx
          .get(photoUploadControllerProvider.notifier)
          .deletePhoto(intent.index);
    });
  }

  Future<void> reorderPhoto({
    required WidgetRef ref,
    required int fromIndex,
    required int toIndex,
  }) {
    final intent = reorderIntent(fromIndex: fromIndex, toIndex: toIndex);
    return PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
      await tx
          .get(photoUploadControllerProvider.notifier)
          .reorderPhoto(fromIndex: intent.fromIndex, toIndex: intent.toIndex);
    });
  }
}

class SelfProfilePhotoEditorRequest {
  const SelfProfilePhotoEditorRequest({
    required this.index,
    required this.photo,
    required this.canDelete,
  });

  final int index;
  final ProfilePhoto? photo;
  final bool canDelete;
}

class SelfProfilePhotoDeleteIntent {
  const SelfProfilePhotoDeleteIntent({required this.index});

  final int index;
}

class SelfProfilePhotoReorderIntent {
  const SelfProfilePhotoReorderIntent({
    required this.fromIndex,
    required this.toIndex,
  });

  final int fromIndex;
  final int toIndex;
}
