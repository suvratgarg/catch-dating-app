import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
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
    final borderRadius = BorderRadius.circular(CatchRadius.md);

    final hasPhoto = url != null;
    final promptLabel = prompt?.caption.trim();
    final label = switch ((hasPhoto, isLoading, isActive)) {
      (true, true, _) => 'Photo ${index + 1} uploading',
      (true, false, _) => 'Replace photo ${index + 1}',
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
            child: Icon(Icons.broken_image_outlined, size: 28, color: t.ink2),
          ),
        ),
      );
    } else if (isActive) {
      content = Container(
        color: t.primarySoft,
        child: Center(
          child: Icon(Icons.add_rounded, size: 36, color: t.primary),
        ),
      );
    } else {
      content = Container(color: t.raised);
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
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    content,
                    if (isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CatchLoadingIndicator(color: Colors.white),
                        ),
                      ),
                    if (!isLoading && url != null)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: t.surface.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: t.ink,
                          ),
                        ),
                      ),
                    if (!isLoading &&
                        hasPhoto &&
                        promptLabel != null &&
                        promptLabel.isNotEmpty)
                      Positioned(
                        left: 6,
                        right: 34,
                        bottom: 6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(CatchRadius.sm),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              prompt!.displayPrompt,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: borderRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: isActive && !isLoading ? onTap : null,
                  borderRadius: borderRadius,
                ),
              ),
              if (!isLoading && onDelete != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Tooltip(
                    message: 'Delete photo ${index + 1}',
                    child: Material(
                      color: t.surface.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: PhotoGridKeys.delete(index),
                        customBorder: const CircleBorder(),
                        onTap: onDelete,
                        child: SizedBox.square(
                          dimension: 28,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: t.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: isReorderTarget ? t.primary : t.line,
                      width: isReorderTarget ? 2 : 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
