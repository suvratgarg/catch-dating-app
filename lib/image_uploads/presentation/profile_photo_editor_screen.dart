import 'dart:async';
import 'dart:ui' as ui;

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoEditorScreen extends ConsumerStatefulWidget {
  const ProfilePhotoEditorScreen({
    super.key,
    required this.index,
    this.photo,
    this.initialImage,
  });

  final int index;
  final ProfilePhoto? photo;
  final XFile? initialImage;

  @override
  ConsumerState<ProfilePhotoEditorScreen> createState() =>
      _ProfilePhotoEditorScreenState();
}

Future<bool?> openProfilePhotoEditor({
  required BuildContext context,
  required WidgetRef ref,
  required int index,
  ProfilePhoto? photo,
}) async {
  XFile? initialImage;
  if (photo == null) {
    initialImage = await ref
        .read(photoUploadControllerProvider.notifier)
        .pickPhoto();
    if (initialImage == null || !context.mounted) return false;
  }

  if (!context.mounted) return false;
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => ProfilePhotoEditorScreen(
        index: index,
        photo: photo,
        initialImage: initialImage,
      ),
    ),
  );
}

class _ProfilePhotoEditorScreenState
    extends ConsumerState<ProfilePhotoEditorScreen> {
  final _cropKey = GlobalKey();
  late final TextEditingController _captionController;
  late PhotoPromptDefinition _definition;
  Uint8List? _imageBytes;
  bool _loadingImage = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existingPrompt = widget.photo?.prompt;
    _definition = existingPrompt == null
        ? defaultPhotoPromptForIndex(widget.index)
        : photoPromptDefinition(existingPrompt.promptId);
    _captionController = TextEditingController(
      text: existingPrompt?.caption ?? '',
    );
    final initialImage = widget.initialImage;
    if (initialImage != null) {
      unawaited(_setImage(initialImage));
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _setImage(XFile image) async {
    setState(() => _loadingImage = true);
    try {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } finally {
      if (mounted) setState(() => _loadingImage = false);
    }
  }

  Future<void> _replaceImage() async {
    final image = await ref
        .read(photoUploadControllerProvider.notifier)
        .pickPhoto();
    if (image == null) return;
    await _setImage(image);
  }

  Future<XFile?> _croppedImageFile() async {
    if (_imageBytes == null) return null;
    final boundary =
        _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();
    return XFile.fromData(
      bytes,
      name:
          'profile_photo_${widget.index}_${DateTime.now().millisecondsSinceEpoch}.png',
      mimeType: 'image/png',
    );
  }

  Future<void> _save() async {
    if (_saving || _loadingImage) return;
    final hasExistingPhoto = widget.photo != null;
    if (!hasExistingPhoto && _imageBytes == null) return;

    setState(() => _saving = true);
    try {
      final caption = normalizePhotoPromptCaption(_captionController.text);
      final prompt = caption.isEmpty
          ? null
          : photoPromptAnswerFor(
              photoIndex: widget.index,
              definition: _definition,
              caption: caption,
            );
      final croppedImage = await _croppedImageFile();
      await PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
        await tx
            .get(photoUploadControllerProvider.notifier)
            .savePhoto(
              index: widget.index,
              image: croppedImage,
              prompt: prompt,
            );
      });
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasEditableImage = _imageBytes != null;
    final canSave =
        !_saving &&
        !_loadingImage &&
        (widget.photo != null || hasEditableImage);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(widget.photo == null ? 'Add photo' : 'Edit photo'),
        actions: [
          CatchTextButton(
            label: _saving ? 'Saving' : 'Save',
            onPressed: canSave ? _save : null,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s3,
            CatchSpacing.s5,
            CatchSpacing.s6,
          ),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: t.raised,
                borderRadius: BorderRadius.circular(CatchRadius.lg),
                border: Border.all(color: t.line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.lg),
                child: AspectRatio(
                  aspectRatio: profilePhotoAspectRatio,
                  child: _PhotoEditorPreview(
                    cropKey: _cropKey,
                    bytes: _imageBytes,
                    url: widget.photo?.url,
                    loading: _loadingImage,
                  ),
                ),
              ),
            ),
            gapH16,
            CatchButton(
              label: widget.photo == null ? 'Choose photo' : 'Replace photo',
              onPressed: _saving ? null : _replaceImage,
              icon: const Icon(Icons.photo_library_outlined),
              fullWidth: true,
            ),
            gapH20,
            DropdownButtonFormField<PhotoPromptDefinition>(
              initialValue: _definition,
              decoration: const InputDecoration(labelText: 'Photo prompt'),
              items: [
                for (final definition in photoPromptCatalog)
                  DropdownMenuItem(
                    value: definition,
                    child: Text(definition.title),
                  ),
              ],
              onChanged: _saving
                  ? null
                  : (definition) {
                      if (definition == null) return;
                      setState(() => _definition = definition);
                    },
            ),
            gapH16,
            CatchTextField(
              label: 'Caption',
              controller: _captionController,
              enabled: !_saving,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              hintText: _definition.placeholder,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  maximumPhotoPromptCaptionLength,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoEditorPreview extends StatelessWidget {
  const _PhotoEditorPreview({
    required this.cropKey,
    required this.bytes,
    required this.url,
    required this.loading,
  });

  final GlobalKey cropKey;
  final Uint8List? bytes;
  final String? url;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final imageBytes = bytes;
    final existingUrl = url;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (imageBytes != null) {
      return RepaintBoundary(
        key: cropKey,
        child: ClipRect(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            boundaryMargin: const EdgeInsets.all(160),
            child: SizedBox.expand(
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }
    if (existingUrl != null) {
      return Image.network(existingUrl, fit: BoxFit.cover);
    }
    return ColoredBox(
      color: t.primarySoft,
      child: Center(
        child: Icon(Icons.add_photo_alternate_outlined, color: t.primary),
      ),
    );
  }
}
