import 'dart:typed_data';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/events/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';

class CreateEventPhotoPicker extends StatelessWidget {
  const CreateEventPhotoPicker({
    super.key,
    required this.photoImageBytes,
    required this.onTap,
  });

  final Uint8List? photoImageBytes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasPhoto = photoImageBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Event photo', isOptional: true),
        gapH8,
        Semantics(
          button: true,
          label: hasPhoto ? 'Change event photo' : 'Add event photo',
          child: GestureDetector(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.md),
                child: hasPhoto
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(photoImageBytes!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: CatchIconTile(
                              icon: CatchIcons.editOutlined,
                              iconColor: t.ink,
                              backgroundColor: t.surface.withValues(
                                alpha: 0.85,
                              ),
                              borderColor: Colors.transparent,
                              size: 28,
                              iconSize: 16,
                              radius: CatchRadius.pill,
                            ),
                          ),
                        ],
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(color: t.raised),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CatchIcons.addPhotoAlternateOutlined,
                                size: 40,
                                color: t.ink2,
                              ),
                              gapH8,
                              Text(
                                'Add event photo',
                                style: CatchTextStyles.sectionTitle(
                                  context,
                                  color: t.ink2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
