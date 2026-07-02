import 'dart:typed_data';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

class OrderedPhotoPreview {
  const OrderedPhotoPreview({required this.id, this.bytes, this.imageUrl});

  final String id;
  final Uint8List? bytes;
  final String? imageUrl;

  bool get hasImage => bytes != null || imageUrl != null;
}

abstract final class OrderedPhotoPickerKeys {
  static ValueKey<String> addAction(String label) =>
      ValueKey('ordered_photo_add_$label');

  static ValueKey<String> removeAction(int index) =>
      ValueKey('ordered_photo_remove_$index');
}

class OrderedPhotoPicker extends StatefulWidget {
  const OrderedPhotoPicker({
    super.key,
    required this.label,
    required this.photos,
    required this.onAddPhotos,
    required this.onRemovePhoto,
    required this.onReorderPhoto,
    required this.emptyActionLabel,
    required this.addActionLabel,
    this.maxPhotos = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = CatchAspectRatio.wide16x9,
    this.showCoverBadge = false,
    this.showReorderHandle = true,
  });

  final Widget label;
  final List<OrderedPhotoPreview> photos;
  final VoidCallback? onAddPhotos;
  final ValueChanged<int>? onRemovePhoto;
  final void Function(int fromIndex, int toIndex)? onReorderPhoto;
  final String emptyActionLabel;
  final String addActionLabel;
  final int maxPhotos;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool showCoverBadge;
  final bool showReorderHandle;

  @override
  State<OrderedPhotoPicker> createState() => _OrderedPhotoPickerState();
}

class _OrderedPhotoPickerState extends State<OrderedPhotoPicker> {
  int? _draggedIndex;

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos.where((photo) => photo.hasImage).toList();
    final canAdd =
        widget.onAddPhotos != null && photos.length < widget.maxPhotos;
    final canReorder = widget.onReorderPhoto != null && photos.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.label,
        gapH8,
        if (photos.isEmpty)
          AspectRatio(
            aspectRatio: CatchAspectRatio.wide16x9,
            child: OrderedPhotoAddTile(
              label: widget.emptyActionLabel,
              onTap: widget.onAddPhotos,
            ),
          )
        else
          ReorderableBuilder<int>.builder(
            itemCount: photos.length,
            animationConfig: const ReorderableAnimationConfig(
              enableAnimations: false,
            ),
            enableDraggable: canReorder,
            onDragStarted: (index) => _draggedIndex = index,
            onReorder: canReorder
                ? (reorderedListFunction) {
                    final originalOrder = List<int>.generate(
                      photos.length,
                      (index) => index,
                    );
                    final reorderedOrder = reorderedListFunction(originalOrder);
                    final fromIndex = _draggedIndex;
                    _draggedIndex = null;
                    if (fromIndex == null) return;
                    final toIndex = reorderedOrder.indexOf(fromIndex);
                    if (toIndex == -1 || toIndex == fromIndex) return;
                    widget.onReorderPhoto!(fromIndex, toIndex);
                  }
                : null,
            childBuilder: (itemBuilder) {
              final itemCount = photos.length + (canAdd ? 1 : 0);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisSpacing: CatchSpacing.s2,
                  crossAxisSpacing: CatchSpacing.s2,
                  childAspectRatio: widget.childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  if (index >= photos.length) {
                    return OrderedPhotoAddTile(
                      label: widget.addActionLabel,
                      onTap: widget.onAddPhotos,
                    );
                  }
                  final photo = photos[index];
                  return itemBuilder(
                    OrderedPhotoTile(
                      key: ValueKey(photo.id),
                      photo: photo,
                      index: index,
                      canReorder: canReorder,
                      showCoverBadge: widget.showCoverBadge && index == 0,
                      showReorderHandle: widget.showReorderHandle,
                      onRemove: widget.onRemovePhoto == null
                          ? null
                          : () => widget.onRemovePhoto!(index),
                    ),
                    index,
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class OrderedPhotoTile extends StatelessWidget {
  const OrderedPhotoTile({
    super.key,
    required this.photo,
    required this.index,
    required this.canReorder,
    required this.showCoverBadge,
    required this.showReorderHandle,
    this.onRemove,
  });

  final OrderedPhotoPreview photo;
  final int index;
  final bool canReorder;
  final bool showCoverBadge;
  final bool showReorderHandle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      image: true,
      label: 'Photo ${index + 1}',
      child: Tooltip(
        message: 'Photo ${index + 1}',
        excludeFromSemantics: true,
        child: CatchSurface(
          tone: CatchSurfaceTone.raised,
          radius: CatchRadius.md,
          borderWidth: 0,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (photo.bytes != null)
                Image.memory(photo.bytes!, fit: BoxFit.cover)
              else
                CatchNetworkImage(
                  photo.imageUrl!,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: t.raised,
                    child: Center(
                      child: Icon(
                        CatchIcons.brokenImageOutlined,
                        size: CatchIcon.tile,
                        color: t.ink2,
                      ),
                    ),
                  ),
                ),
              if (onRemove != null)
                Positioned(
                  top: CatchSpacing.s1,
                  right: CatchSpacing.s1,
                  child: Tooltip(
                    message: 'Remove photo ${index + 1}',
                    child: Material(
                      color: t.surface.withValues(
                        alpha: CatchOpacity.photoSlotDeleteChrome,
                      ),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: OrderedPhotoPickerKeys.removeAction(index),
                        customBorder: const CircleBorder(),
                        onTap: onRemove,
                        child: SizedBox.square(
                          dimension: CatchLayout.photoSlotDeleteExtent,
                          child: Icon(
                            CatchIcons.closeRounded,
                            size: CatchIcon.sm,
                            color: t.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (showCoverBadge)
                Positioned(
                  top: CatchSpacing.s1,
                  left: CatchSpacing.s1,
                  child: CatchSurface(
                    radius: CatchRadius.pill,
                    borderWidth: 0,
                    backgroundColor: t.ink.withValues(
                      alpha: CatchOpacity.photoSlotDeleteChrome,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: CatchSpacing.micro6,
                      vertical: CatchSpacing.micro3,
                    ),
                    child: Text(
                      'COVER',
                      style: CatchTextStyles.monoLabel(
                        context,
                        color: t.surface,
                      ),
                    ),
                  ),
                ),
              if (canReorder && showReorderHandle)
                Positioned(
                  bottom: CatchSpacing.s1,
                  right: CatchSpacing.s1,
                  child: CatchIconTile(
                    icon: CatchIcons.dragIndicatorRounded,
                    iconColor: t.ink,
                    backgroundColor: t.surface.withValues(
                      alpha: CatchOpacity.imageEditControlFill,
                    ),
                    borderColor: Colors.transparent,
                    size: CatchIcon.row,
                    iconSize: CatchIcon.sm,
                    radius: CatchRadius.pill,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderedPhotoAddTile extends StatelessWidget {
  const OrderedPhotoAddTile({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: CatchSurface(
          key: OrderedPhotoPickerKeys.addAction(label),
          tone: CatchSurfaceTone.raised,
          radius: CatchRadius.md,
          borderWidth: 0,
          clipBehavior: Clip.antiAlias,
          onTap: onTap,
          padding: CatchInsets.contentDense,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final showLabel = constraints.maxHeight >= 96 && textScale < 1.4;
              return ExcludeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CatchIcons.addPhotoAlternateOutlined,
                      size: CatchIcon.hero,
                      color: t.ink2,
                    ),
                    if (showLabel) ...[
                      gapH8,
                      Text(
                        label,
                        style: CatchTextStyles.bodyLead(context, color: t.ink2),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
