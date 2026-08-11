import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class CreateEventPhotoPicker extends StatelessWidget {
  const CreateEventPhotoPicker({
    super.key,
    required this.photos,
    required this.onAddPhotos,
    required this.onRemovePhoto,
    required this.onReorderPhoto,
    required this.organizerName,
    this.organizerLogoUrl,
  });

  final List<OrderedPhotoPreview> photos;
  final VoidCallback? onAddPhotos;
  final ValueChanged<int>? onRemovePhoto;
  final void Function(int fromIndex, int toIndex)? onReorderPhoto;
  final String organizerName;
  final String? organizerLogoUrl;

  @override
  Widget build(BuildContext context) {
    return CatchSection.fieldRows(
      title: context.l10n.hostsCreateEventPhotoPickerTitleCoverAndGallery,
      count: context.l10n.coreCatchFormFieldLabelTextOptional,
      first: true,
      showInternalDividers: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InheritedOrganizerLogo(
            organizerName: organizerName,
            organizerLogoUrl: organizerLogoUrl,
          ),
          gapH12,
          Text(
            context.l10n.hostsCreateEventPhotoPickerBodyUnlimitedGallery,
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).ink3,
            ),
          ),
          gapH16,
          OrderedPhotoPicker(
            photos: photos,
            onAddPhotos: onAddPhotos,
            onRemovePhoto: onRemovePhoto,
            onReorderPhoto: onReorderPhoto,
            emptyActionLabel: context
                .l10n
                .hostsCreateEventPhotoPickerVisiblecopyAddEventPhotos,
            addActionLabel:
                context.l10n.hostsCreateEventPhotoPickerVisiblecopyAddPhotos,
          ),
        ],
      ),
    );
  }
}

class _InheritedOrganizerLogo extends StatelessWidget {
  const _InheritedOrganizerLogo({
    required this.organizerName,
    required this.organizerLogoUrl,
  });

  final String organizerName;
  final String? organizerLogoUrl;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        SizedBox.square(
          dimension: CatchLayout.hostMediaInheritedLogoExtent,
          child: CatchSurface(
            tone: CatchSurfaceTone.raised,
            radius: CatchRadius.md,
            borderColor: t.line2,
            clipBehavior: Clip.antiAlias,
            child: organizerLogoUrl == null
                ? Icon(CatchIcons.groupsOutlined, color: t.ink2)
                : CatchNetworkImage(
                    organizerLogoUrl!,
                    errorBuilder: (_, _, _) =>
                        Icon(CatchIcons.groupsOutlined, color: t.ink2),
                  ),
          ),
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organizerName,
                style: CatchTextStyles.labelL(context, color: t.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              gapH2,
              Text(
                context.l10n.hostsCreateEventPhotoPickerBodyInheritedLogo,
                style: CatchTextStyles.supporting(context, color: t.ink3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
