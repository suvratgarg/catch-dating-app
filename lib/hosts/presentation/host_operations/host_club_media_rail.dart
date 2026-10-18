part of '../host_operations_screen.dart';

class HostClubMediaRail extends StatelessWidget {
  const HostClubMediaRail({
    super.key,
    required this.logoImageBytes,
    required this.logoImageUrl,
    required this.photos,
    required this.logoBadgeLabel,
    required this.addPhotosLabel,
    required this.onManageMedia,
  });

  final Uint8List? logoImageBytes;
  final String? logoImageUrl;
  final List<OrderedPhotoPreview> photos;
  final String logoBadgeLabel;
  final String addPhotosLabel;
  final VoidCallback? onManageMedia;

  @override
  Widget build(BuildContext context) {
    const extent = CatchLayout.hostMediaThumbnailExtent;

    return SizedBox(
      key: HostClubMediaKeys.summaryStrip,
      height: extent,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length + 2,
        separatorBuilder: (_, _) => gapW8,
        itemBuilder: (_, index) {
          if (index == 0) {
            return SizedBox.square(
              dimension: extent,
              child: Stack(
                key: HostClubMediaKeys.logoTile,
                fit: StackFit.expand,
                children: [
                  ClubProfileImageTile(
                    imageBytes: logoImageBytes,
                    existingImageUrl: logoImageUrl,
                    onTap: onManageMedia,
                    size: extent,
                  ),
                  Positioned(
                    top: CatchSpacing.s1,
                    left: CatchSpacing.s1,
                    child: IgnorePointer(
                      child: CatchSurface.tinted(
                        radius: CatchRadius.pill,
                        backgroundColor: CatchTokens.of(context).ink.withValues(
                          alpha: CatchOpacity.photoSlotDeleteChrome,
                        ),
                        padding: CatchInsets.mediaRoleBadgeContent,
                        child: Text(
                          logoBadgeLabel,
                          style: CatchTextStyles.monoLabel(
                            context,
                            color: CatchTokens.of(context).surface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (index == photos.length + 1) {
            return SizedBox.square(
              dimension: extent,
              child: OrderedPhotoAddTile(
                label: addPhotosLabel,
                onTap: onManageMedia,
              ),
            );
          }

          final photoIndex = index - 1;
          final photo = photos[photoIndex];
          final isCover = photoIndex == 0;
          return SizedBox(
            width:
                extent *
                (isCover
                    ? CatchAspectRatio.organizerCover
                    : CatchAspectRatio.organizerGallery),
            height: extent,
            child: OrderedPhotoTile(
              key: ValueKey('host-media-summary-photo-${photo.id}'),
              photo: photo,
              index: photoIndex,
              canReorder: false,
              showCoverBadge: isCover,
              showReorderHandle: false,
              statusActionKey: isCover
                  ? OrderedPhotoPickerKeys.coverRetryAction
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// The media manager's logo picker header.
class HostClubLogoManagerHeader extends StatefulWidget {
  const HostClubLogoManagerHeader({
    super.key,
    required this.imageBytes,
    required this.existingImageUrl,
    required this.onPickLogo,
    required this.onRemoveLogo,
  });

  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final Future<HostPickedClubLogo?> Function() onPickLogo;
  final Future<void> Function() onRemoveLogo;

  @override
  State<HostClubLogoManagerHeader> createState() =>
      _HostClubLogoManagerHeaderState();
}

class _HostClubLogoManagerHeaderState extends State<HostClubLogoManagerHeader> {
  late Uint8List? _imageBytes;
  late String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageBytes;
    _existingImageUrl = widget.existingImageUrl;
  }

  Future<void> _pickLogo() async {
    final logo = await widget.onPickLogo();
    if (!mounted || logo == null) return;
    setState(() {
      _imageBytes = logo.bytes;
      _existingImageUrl = null;
    });
  }

  Future<void> _removeLogo() async {
    await widget.onRemoveLogo();
    if (!mounted) return;
    setState(() {
      _imageBytes = null;
      _existingImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CreateClubProfileImagePicker(
      imageBytes: _imageBytes,
      existingImageUrl: _existingImageUrl,
      onTap: () => unawaited(_pickLogo()),
      onRemove: _imageBytes != null || _existingImageUrl != null
          ? () => unawaited(_removeLogo())
          : null,
      variant: CreateClubProfileImagePickerVariant.editLogo,
    );
  }
}

/// The media manager's save action and error line.
class HostClubMediaManagerDock extends StatefulWidget {
  const HostClubMediaManagerDock({
    super.key,
    required this.onSave,
    required this.errorText,
  });

  final Future<bool> Function() onSave;
  final String? Function(BuildContext context) errorText;

  @override
  State<HostClubMediaManagerDock> createState() =>
      _HostClubMediaManagerDockState();
}

class _HostClubMediaManagerDockState extends State<HostClubMediaManagerDock> {
  bool _saving = false;
  bool _showError = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _showError = false;
    });
    final saved = await widget.onSave();
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _showError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = _showError ? widget.errorText(context) : null;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CatchTokens.of(context).bg,
          border: Border(top: BorderSide(color: CatchTokens.of(context).line)),
        ),
        child: Padding(
          padding: CatchInsets.pageHorizontal.copyWith(
            top: CatchSpacing.s2,
            bottom: CatchSpacing.s2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                key: const ValueKey('host-media-action-bar'),
                children: [
                  Expanded(
                    child: CatchButton(
                      key: const ValueKey('host-media-discard'),
                      label:
                          context.l10n.hostsHostClubEditTabActionDiscardMedia,
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      variant: CatchButtonVariant.secondary,
                      fullWidth: true,
                    ),
                  ),
                  gapW8,
                  Expanded(
                    child: CatchButton(
                      key: const ValueKey('host-media-save'),
                      label: context.l10n.hostsHostClubEditTabActionSaveMedia,
                      onPressed: _saving ? null : () => unawaited(_save()),
                      status: (_saving)
                          ? CatchButtonStatus.loading
                          : CatchButtonStatus.idle,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
              if (error != null) ...[
                gapH8,
                CatchFieldSupportRow(
                  text: error,
                  color: CatchTokens.of(context).danger,
                  showErrorIcon: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

sealed class _HostClubMediaDraft {
  const _HostClubMediaDraft();

  String get id;
  OrderedPhotoPreview get preview;
  HostClubMediaInput get input;
}

final class _HostExistingClubMediaDraft extends _HostClubMediaDraft {
  const _HostExistingClubMediaDraft(this.photo);

  final UploadedPhoto photo;

  @override
  String get id => photo.id;

  @override
  OrderedPhotoPreview get preview => OrderedPhotoPreview(
    id: 'existing-${photo.id}',
    imageUrl: photo.thumbnailOrUrl,
  );

  @override
  HostClubMediaInput get input => HostExistingClubPhotoInput(photo);
}

final class _HostPickedClubMediaDraft extends _HostClubMediaDraft {
  const _HostPickedClubMediaDraft(
    this.photo, {
    this.uploadedPhoto,
    this.job = const ImageUploadJobState.queued(),
  });

  final HostPickedClubPhoto photo;
  final UploadedPhoto? uploadedPhoto;
  final ImageUploadJobState job;

  @override
  String get id => photo.id;

  _HostPickedClubMediaDraft withJob(ImageUploadJobState job) =>
      _HostPickedClubMediaDraft(photo, uploadedPhoto: uploadedPhoto, job: job);

  _HostPickedClubMediaDraft withResolvedInput(
    HostClubMediaInput? resolved, {
    Object? error,
  }) {
    final uploaded = switch (resolved) {
      HostNewClubPhotoInput(:final uploadedPhoto) => uploadedPhoto,
      _ => uploadedPhoto,
    };
    return _HostPickedClubMediaDraft(
      photo,
      uploadedPhoto: uploaded,
      job: error == null
          ? const ImageUploadJobState(stage: ImageUploadJobStage.complete)
          : ImageUploadJobState(
              stage: ImageUploadJobStage.failed,
              error: error,
            ),
    );
  }

  _HostPickedClubMediaDraft clearUpload(Object error) =>
      _HostPickedClubMediaDraft(
        photo,
        job: ImageUploadJobState(
          stage: ImageUploadJobStage.failed,
          error: error,
        ),
      );

  @override
  OrderedPhotoPreview get preview => OrderedPhotoPreview(
    id: id,
    bytes: photo.bytes,
    status: switch (job.stage) {
      ImageUploadJobStage.failed => OrderedPhotoStatus.failed,
      ImageUploadJobStage.preparing ||
      ImageUploadJobStage.uploading ||
      ImageUploadJobStage.attaching => OrderedPhotoStatus.uploading,
      ImageUploadJobStage.queued ||
      ImageUploadJobStage.picking => OrderedPhotoStatus.queued,
      _ => OrderedPhotoStatus.ready,
    },
    progress: job.progress,
    error: job.error,
  );

  @override
  HostNewClubPhotoInput get input => HostNewClubPhotoInput(
    id: id,
    image: photo.image,
    uploadedPhoto: uploadedPhoto,
  );
}
