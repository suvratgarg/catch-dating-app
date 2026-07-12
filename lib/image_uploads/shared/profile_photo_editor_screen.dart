import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/confirm_danger_dialog.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePhotoEditorScreen extends ConsumerStatefulWidget {
  const ProfilePhotoEditorScreen({
    super.key,
    required this.index,
    this.photo,
    this.initialImageBytes,
    this.canDelete = false,
  });

  final int index;
  final ProfilePhoto? photo;
  final Uint8List? initialImageBytes;
  final bool canDelete;

  @override
  ConsumerState<ProfilePhotoEditorScreen> createState() =>
      _ProfilePhotoEditorScreenState();
}

Future<bool?> openProfilePhotoEditor({
  required BuildContext context,
  required WidgetRef ref,
  required int index,
  ProfilePhoto? photo,
  bool canDelete = false,
}) async {
  Uint8List? initialImageBytes;
  if (photo == null) {
    final initialImage = await ref
        .read(photoUploadControllerProvider.notifier)
        .pickPhoto();
    if (initialImage == null || !context.mounted) return false;
    initialImageBytes = await initialImage.readAsBytes();
  }

  if (!context.mounted) return false;
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => ProfilePhotoEditorScreen(
        index: index,
        photo: photo,
        initialImageBytes: initialImageBytes,
        canDelete: canDelete,
      ),
    ),
  );
}

class _ProfilePhotoEditorScreenState
    extends ConsumerState<ProfilePhotoEditorScreen> {
  final _cropKey = GlobalKey();
  String? _promptId;
  Uint8List? _imageBytes;
  bool _loadingImage = false;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final existingPrompt = widget.photo?.prompt;
    _promptId = existingPrompt?.promptId;
    final initialImageBytes = widget.initialImageBytes;
    if (initialImageBytes != null) {
      _imageBytes = initialImageBytes;
    }
  }

  Future<void> _pickReplacementImage() async {
    setState(() => _loadingImage = true);
    try {
      final image = await ref
          .read(photoUploadControllerProvider.notifier)
          .pickPhoto();
      final bytes = await image?.readAsBytes();
      if (!mounted) return;
      if (bytes != null) setState(() => _imageBytes = bytes);
    } finally {
      if (mounted) setState(() => _loadingImage = false);
    }
  }

  Future<void> _replaceImage() async {
    await _pickReplacementImage();
  }

  Future<Uint8List?> _croppedImageBytes() async {
    if (_imageBytes == null) return null;
    final boundary =
        _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  Future<void> _save() async {
    if (_saving || _deleting || _loadingImage) return;
    final hasExistingPhoto = widget.photo != null;
    if (!hasExistingPhoto && _imageBytes == null) return;

    setState(() => _saving = true);
    try {
      final selectedDefinition = _selectedDefinition;
      final prompt = selectedDefinition == null
          ? null
          : photoPromptAnswerFor(
              photoIndex: widget.index,
              definition: selectedDefinition,
            );
      final croppedImageBytes = await _croppedImageBytes();
      await PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
        await tx
            .get(photoUploadControllerProvider.notifier)
            .savePhoto(
              index: widget.index,
              imageBytes: croppedImageBytes,
              prompt: prompt,
            );
      });
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deletePhoto() async {
    if (!widget.canDelete || widget.photo == null || _saving || _deleting) {
      return;
    }
    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: context.l10n.imageUploadsProfilePhotoEditorScreenTitleDeletePhoto,
      message: context
          .l10n
          .imageUploadsProfilePhotoEditorScreenMessageThisRemovesThePhoto,
      confirmLabel:
          context.l10n.imageUploadsProfilePhotoEditorScreenVisiblecopyDelete,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
        await tx
            .get(photoUploadControllerProvider.notifier)
            .deletePhoto(widget.index);
      });
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasEditableImage = _imageBytes != null;
    final profilePhotos =
        ref
            .watch(watchUserProfileProvider)
            .asData
            ?.value
            ?.effectiveProfilePhotos ??
        const <ProfilePhoto>[];
    final usedPromptIds = {
      for (final photo in profilePhotos)
        if (photo.position != widget.index && photo.prompt != null)
          photo.prompt!.promptId,
    };
    final canSave =
        !_saving &&
        !_deleting &&
        !_loadingImage &&
        (widget.photo != null || hasEditableImage);
    final promptChoices = _PhotoPromptChoice.values(
      l10n: context.l10n,
      usedPromptIds: usedPromptIds,
      currentPromptId: _promptId,
    );
    final selectedPromptChoice = promptChoices.firstWhere(
      (choice) => choice.id == _promptId,
      orElse: () => promptChoices.first,
    );
    final canDelete = widget.photo != null && widget.canDelete;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: widget.photo == null
            ? context.l10n.imageUploadsProfilePhotoEditorScreenTitleAddPhoto
            : context.l10n.imageUploadsProfilePhotoEditorScreenTitleEditPhoto,
      ),
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBodyTight,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CatchLayout.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CatchSurface(
                      backgroundColor: t.raised,
                      borderColor: t.line,
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: profilePhotoAspectRatio,
                        child: ProfilePhotoEditorPreview(
                          cropKey: _cropKey,
                          bytes: _imageBytes,
                          url: widget.photo?.url,
                          loading: _loadingImage,
                        ),
                      ),
                    ),
                    gapH16,
                    CatchField.select<_PhotoPromptChoice>(
                      title: context
                          .l10n
                          .imageUploadsProfilePhotoEditorScreenTitlePhotoPrompt,
                      values: promptChoices,
                      value: selectedPromptChoice,
                      itemLabel: (choice) => choice.label,
                      prefixIcon: Icon(CatchIcons.autoAwesomeOutlined),
                      onChanged: _saving || _deleting
                          ? null
                          : (choice) => setState(() => _promptId = choice?.id),
                    ),
                    gapH20,
                    CatchButton(
                      label: _saving
                          ? context
                                .l10n
                                .imageUploadsProfilePhotoEditorScreenLabelSaving
                          : context
                                .l10n
                                .imageUploadsProfilePhotoEditorScreenLabelSaveChanges,
                      onPressed: canSave ? _save : null,
                      isLoading: _saving,
                      fullWidth: true,
                    ),
                    gapH12,
                    CatchButton(
                      label: widget.photo == null
                          ? context
                                .l10n
                                .imageUploadsProfilePhotoEditorScreenLabelChoosePhoto
                          : context
                                .l10n
                                .imageUploadsProfilePhotoEditorScreenLabelChangePhoto,
                      onPressed: _saving || _deleting ? null : _replaceImage,
                      icon: Icon(CatchIcons.photoLibraryOutlined),
                      variant: CatchButtonVariant.secondary,
                      fullWidth: true,
                    ),
                    if (widget.photo != null) ...[
                      gapH12,
                      CatchButton(
                        label: _deleting
                            ? context
                                  .l10n
                                  .imageUploadsProfilePhotoEditorScreenLabelDeleting
                            : context
                                  .l10n
                                  .imageUploadsProfilePhotoEditorScreenLabelDeletePhoto,
                        onPressed: canDelete ? _deletePhoto : null,
                        isLoading: _deleting,
                        icon: Icon(CatchIcons.deleteOutlineRounded),
                        variant: CatchButtonVariant.danger,
                        fullWidth: true,
                        semanticsLabel: canDelete
                            ? context.l10n
                                  .imageUploadsProfilePhotoEditorScreenCatchbuttonDeletePhotoValue1(
                                    value1: widget.index + 1,
                                  )
                            : context
                                  .l10n
                                  .imageUploadsProfilePhotoEditorScreenCatchbuttonDeletePhotoUnavailable,
                      ),
                      if (!widget.canDelete) ...[
                        gapH8,
                        Text(
                          context.l10n
                              .imageUploadsProfilePhotoEditorScreenTextKeepAtLeastMinimumprofilephotocount(
                                minimumProfilePhotoCount:
                                    minimumProfilePhotoCount,
                              ),
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PhotoPromptDefinition? get _selectedDefinition {
    final id = _promptId;
    if (id == null) return null;
    return photoPromptDefinition(id);
  }
}

class ProfilePhotoEditorPreview extends StatelessWidget {
  const ProfilePhotoEditorPreview({
    super.key,
    required this.cropKey,
    required this.loading,
    this.bytes,
    this.url,
  });

  final GlobalKey cropKey;
  final bool loading;
  final Uint8List? bytes;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final imageBytes = bytes;
    final existingUrl = url;

    if (loading) {
      return CatchSkeleton.custom(
        child: const ColoredBox(
          color: CatchTokens.editorialWhite,
          child: SizedBox.expand(),
        ),
      );
    }
    if (imageBytes != null) {
      return RepaintBoundary(
        key: cropKey,
        child: ClipRect(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            boundaryMargin: const EdgeInsets.all(
              CatchLayout.profilePhotoEditorBoundaryMargin,
            ),
            child: SizedBox.expand(
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }
    if (existingUrl != null) {
      return CatchNetworkImage(existingUrl);
    }
    return ColoredBox(
      color: t.primarySoft,
      child: Center(
        child: Icon(CatchIcons.addPhotoAlternateOutlined, color: t.primary),
      ),
    );
  }
}

final class _PhotoPromptChoice {
  const _PhotoPromptChoice({required this.id, required this.label});

  final String? id;
  final String label;

  static List<_PhotoPromptChoice> values({
    required AppLocalizations l10n,
    Set<String> usedPromptIds = const {},
    String? currentPromptId,
  }) => [
    _PhotoPromptChoice(
      id: null,
      label: l10n.imageUploadsProfilePhotoEditorScreenLabelNoPrompt,
    ),
    for (final definition in photoPromptCatalog)
      if (!usedPromptIds.contains(definition.id) ||
          definition.id == currentPromptId)
        _PhotoPromptChoice(id: definition.id, label: definition.title),
  ];
}
