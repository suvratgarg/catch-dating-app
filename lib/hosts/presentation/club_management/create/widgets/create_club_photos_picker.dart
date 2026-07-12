import 'dart:typed_data';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum CreateClubPhotosPickerVariant { standard, editStrip }

class CreateClubPhotosPicker extends StatelessWidget {
  const CreateClubPhotosPicker({
    super.key,
    required this.photos,
    this.existingImageUrl,
    required this.onAddPhotos,
    required this.onRemovePhoto,
    required this.onReorderPhoto,
    this.variant = CreateClubPhotosPickerVariant.standard,
  });

  final List<OrderedPhotoPreview> photos;
  final String? existingImageUrl;
  final VoidCallback? onAddPhotos;
  final ValueChanged<int>? onRemovePhoto;
  final void Function(int fromIndex, int toIndex)? onReorderPhoto;
  final CreateClubPhotosPickerVariant variant;

  @override
  Widget build(BuildContext context) {
    final visiblePhotos = photos.isNotEmpty
        ? photos
        : [
            if (existingImageUrl != null)
              OrderedPhotoPreview(
                id: 'existing_legacy_club_cover',
                imageUrl: existingImageUrl,
              ),
          ];
    final hasEditablePhotos = photos.isNotEmpty;
    final editStrip = variant == CreateClubPhotosPickerVariant.editStrip;
    final picker = OrderedPhotoPicker(
      label: editStrip
          ? EditClubPhotosLabel(count: visiblePhotos.length)
          : CatchFormFieldLabel(
              label: context.l10n.hostsCreateClubPhotosPickerLabelClubPhotos,
              isOptional: true,
            ),
      photos: visiblePhotos,
      onAddPhotos: onAddPhotos,
      onRemovePhoto: hasEditablePhotos ? onRemovePhoto : null,
      onReorderPhoto: hasEditablePhotos ? onReorderPhoto : null,
      emptyActionLabel: editStrip
          ? context.l10n.hostsCreateClubPhotosPickerVisiblecopyAddPhotos
          : context.l10n.hostsCreateClubPhotosPickerVisiblecopyAddClubPhotos,
      addActionLabel:
          context.l10n.hostsCreateClubPhotosPickerVisiblecopyAddPhotos,
      maxPhotos: editStrip ? 4 : 6,
      crossAxisCount: editStrip ? 4 : 2,
      childAspectRatio: editStrip ? 1 : CatchAspectRatio.wide16x9,
      showCoverBadge: editStrip,
      showReorderHandle: !editStrip,
    );

    if (!editStrip) return picker;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        picker,
        gapH12,
        Text(
          context.l10n.hostsCreateClubPhotosPickerTextDragToReorderThe,
          style: CatchTextStyles.supporting(
            context,
            color: CatchTokens.of(context).ink3,
          ),
        ),
      ],
    );
  }
}

enum CreateClubProfileImagePickerVariant { standard, editLogo }

class CreateClubProfileImagePicker extends StatelessWidget {
  const CreateClubProfileImagePicker({
    super.key,
    required this.imageBytes,
    this.existingImageUrl,
    required this.onTap,
    this.variant = CreateClubProfileImagePickerVariant.standard,
  });

  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final VoidCallback? onTap;
  final CreateClubProfileImagePickerVariant variant;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    if (variant == CreateClubProfileImagePickerVariant.editLogo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.hostsCreateClubPhotosPickerTextClubLogo,
            style: CatchTextStyles.kicker(context),
          ),
          gapH8,
          Row(
            children: [
              ClubProfileImageTile(
                imageBytes: imageBytes,
                existingImageUrl: existingImageUrl,
                onTap: onTap,
                size: 64,
              ),
              gapW16,
              Expanded(
                child: Text(
                  context.l10n.hostsCreateClubPhotosPickerTextASquareLogoShown,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchFormFieldLabel(
          label: context.l10n.hostsCreateClubPhotosPickerLabelClubProfileImage,
          isOptional: true,
        ),
        gapH8,
        ClubProfileImageTile(
          imageBytes: imageBytes,
          existingImageUrl: existingImageUrl,
          onTap: onTap,
          size: CatchLayout.clubProfileImagePickerExtent,
          showEmptyLabel: true,
        ),
      ],
    );
  }
}

class EditClubPhotosLabel extends StatelessWidget {
  const EditClubPhotosLabel({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Text(
          context.l10n.hostsCreateClubPhotosPickerTextPhotos,
          style: CatchTextStyles.kicker(context),
        ),
        const Spacer(),
        Text(
          context.l10n.hostsCreateClubPhotosPickerTextCount(count: count),
          style: CatchTextStyles.monoLabel(context, color: t.ink3),
        ),
      ],
    );
  }
}

class ClubProfileImageTile extends StatelessWidget {
  const ClubProfileImageTile({
    super.key,
    required this.imageBytes,
    required this.existingImageUrl,
    required this.onTap,
    required this.size,
    this.showEmptyLabel = false,
  });

  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final VoidCallback? onTap;
  final double size;
  final bool showEmptyLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasImage = imageBytes != null || existingImageUrl != null;

    return Semantics(
      button: true,
      label: hasImage
          ? context.l10n.hostsCreateClubPhotosPickerLabelChangeClubProfileImage
          : context.l10n.hostsCreateClubPhotosPickerLabelAddClubProfileImage,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: CatchSurface(
            tone: CatchSurfaceTone.raised,
            radius: CatchRadius.md,
            borderColor: t.line2,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  if (imageBytes case final bytes?)
                    Image.memory(bytes, fit: BoxFit.cover)
                  else
                    CatchNetworkImage(
                      existingImageUrl!,
                      errorBuilder: (_, _, _) => Container(color: t.raised),
                    )
                else
                  ColoredBox(
                    color: t.raised,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale = MediaQuery.textScalerOf(
                          context,
                        ).scale(1);
                        final showLabel =
                            showEmptyLabel &&
                            constraints.maxHeight >= 112 &&
                            textScale < 1.6;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CatchIcons.addPhotoAlternateOutlined,
                              size: CatchIcon.hero,
                              color: t.ink2,
                            ),
                            if (showLabel) ...[
                              gapH8,
                              Padding(
                                padding: CatchInsets.inlineHorizontal,
                                child: Text(
                                  context
                                      .l10n
                                      .hostsCreateClubPhotosPickerTextAddImage,
                                  style: CatchTextStyles.supporting(
                                    context,
                                    color: t.ink2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: CatchIconTile(
                    icon: hasImage
                        ? CatchIcons.editOutlined
                        : CatchIcons.addPhotoAlternateOutlined,
                    iconColor: t.ink,
                    backgroundColor: t.surface.withValues(
                      alpha: CatchOpacity.imageEditControlFill,
                    ),
                    borderColor: Colors.transparent,
                    size: 28,
                    iconSize: CatchIcon.xs,
                    radius: CatchRadius.pill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
