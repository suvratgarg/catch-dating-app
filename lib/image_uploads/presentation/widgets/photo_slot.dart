import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid_keys.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:flutter/material.dart';

class PhotoSlot extends StatelessWidget {
  const PhotoSlot({
    super.key,
    required this.index,
    required this.url,
    required this.isLoading,
    required this.isActive,
    required this.onTap,
    this.prompt,
    this.onDelete,
    this.isReorderTarget = false,
  });

  final int index;
  final String? url;
  final bool isLoading;
  final bool isActive;
  final VoidCallback onTap;
  final PhotoPromptAnswer? prompt;
  final VoidCallback? onDelete;
  final bool isReorderTarget;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final borderRadius = BorderRadius.circular(CatchRadius.lg);

    final hasPhoto = url != null;
    final promptLabel = prompt?.displayPrompt.trim();
    final label = switch ((hasPhoto, isLoading, isActive)) {
      (true, true, _) => 'Photo ${index + 1} uploading',
      (true, false, _) => 'Edit photo ${index + 1}',
      (false, true, _) => 'Photo ${index + 1} uploading',
      (false, false, true) => 'Add photo ${index + 1}',
      _ => 'Photo slot ${index + 1} unavailable',
    };

    final Widget content;
    if (url != null) {
      content = Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: t.raised,
          child: Center(
            child: Icon(
              CatchIcons.brokenImageOutlined,
              size: CatchIcon.tile,
              color: t.ink2,
            ),
          ),
        ),
      );
    } else if (isActive) {
      content = ColoredBox(
        color: t.primarySoft,
        child: Center(
          child: Icon(
            CatchIcons.addRounded,
            size: CatchIcon.hero,
            color: t.primary,
          ),
        ),
      );
    } else {
      content = ColoredBox(color: t.raised);
    }

    return Semantics(
      label: label,
      button: isActive && !isLoading,
      enabled: isActive && !isLoading,
      image: hasPhoto,
      child: Tooltip(
        message: label,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.raised,
            borderRadius: borderRadius,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: borderRadius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    content,
                    if (isLoading)
                      ColoredBox(
                        color: CatchTokens.editorialDark.withValues(
                          alpha: CatchOpacity.photoUploadLoadingScrim,
                        ),
                        child: const Center(
                          child: CatchLoadingIndicator(
                            color: CatchTokens.editorialLight,
                          ),
                        ),
                      ),
                    if (!isLoading && url != null)
                      Positioned(
                        bottom: CatchSpacing.micro6,
                        right: CatchSpacing.micro6,
                        child: CatchIconTile(
                          icon: CatchIcons.editOutlined,
                          iconColor: t.ink,
                          backgroundColor: t.surface.withValues(
                            alpha: CatchOpacity.photoSlotEditChrome,
                          ),
                          borderColor: t.surface.withValues(
                            alpha: CatchOpacity.photoSlotEditChrome,
                          ),
                          size: CatchIcon.row,
                          iconSize: CatchIcon.sm,
                          radius: CatchRadius.pill,
                        ),
                      ),
                    if (!isLoading &&
                        hasPhoto &&
                        promptLabel != null &&
                        promptLabel.isNotEmpty)
                      Positioned(
                        left: CatchSpacing.micro6,
                        right: CatchLayout.photoSlotDeleteControlInset,
                        bottom: CatchSpacing.micro6,
                        child: CatchSurface(
                          radius: CatchRadius.sm,
                          backgroundColor: CatchTokens.editorialDark.withValues(
                            alpha: CatchOpacity.photoPromptScrim,
                          ),
                          borderWidth: 0,
                          padding: CatchInsets.infoTileContent,
                          child: Text(
                            prompt!.displayPrompt,
                            style: CatchTextStyles.labelS(
                              context,
                              color: CatchTokens.editorialLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Material(
                type: MaterialType.transparency,
                borderRadius: borderRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: isActive && !isLoading ? onTap : null,
                  borderRadius: borderRadius,
                ),
              ),
              if (!isLoading && onDelete != null)
                Positioned(
                  top: CatchSpacing.s1,
                  right: CatchSpacing.s1,
                  child: Tooltip(
                    message: 'Delete photo ${index + 1}',
                    child: Material(
                      color: t.surface.withValues(
                        alpha: CatchOpacity.photoSlotDeleteChrome,
                      ),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: PhotoGridKeys.delete(index),
                        customBorder: const CircleBorder(),
                        onTap: onDelete,
                        child: SizedBox.square(
                          dimension: CatchLayout.photoSlotDeleteExtent,
                          child: Icon(
                            CatchIcons.closeRounded,
                            size: 18,
                            color: t.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              IgnorePointer(
                child: CatchSurface(
                  borderRadius: borderRadius,
                  tone: CatchSurfaceTone.transparent,
                  borderColor: isReorderTarget ? t.primary : t.line,
                  borderWidth: isReorderTarget ? 2 : 1,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
