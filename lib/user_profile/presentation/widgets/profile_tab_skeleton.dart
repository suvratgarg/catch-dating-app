import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchInsets, CatchLayout, CatchRadius, CatchStroke;
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldRow;
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_grid.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:flutter/material.dart';

class ProfileTabSkeletonSliverBody extends StatelessWidget {
  const ProfileTabSkeletonSliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: CatchInsets.formEditBodyRelaxed.copyWith(bottom: 0),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CatchLayout.maxContentWidth,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchSectionList(
                    gap: 0,
                    children: [
                      const ProfilePhotosSkeletonSection(),
                      ProfileInfoSkeletonSection(
                        title: context
                            .l10n
                            .userProfileProfileTabSkeletonTitlePrompts,
                        rows: maxProfilePromptAnswers,
                      ),
                      ProfileInfoSkeletonSection(
                        title: context
                            .l10n
                            .userProfileProfileTabSkeletonTitleAboutYou,
                        rows: 5,
                      ),
                      ProfileInfoSkeletonSection(
                        title: context
                            .l10n
                            .userProfileProfileTabSkeletonTitleRunning,
                        rows: 4,
                      ),
                      ProfileInfoSkeletonSection(
                        title: context
                            .l10n
                            .userProfileProfileTabSkeletonTitleLifestyle,
                        rows: 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePhotosSkeletonSection extends StatelessWidget {
  const ProfilePhotosSkeletonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.fieldRows(
      title: context.l10n.userProfileProfileTabSkeletonTitlePhotos,
      count: context.l10n.userProfileProfileTabSkeletonVisiblecopyLoading,
      first: true,
      child: Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s3),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: ProfilePhotoGridLayout.padding,
          gridDelegate: ProfilePhotoGridLayout.delegate,
          itemCount: maximumProfilePhotoCount,
          itemBuilder: (context, index) => CatchSkeleton.box(
            width: double.infinity,
            height: double.infinity,
            radius: CatchRadius.lg,
          ),
        ),
      ),
    );
  }
}

class ProfileInfoSkeletonSection extends StatelessWidget {
  const ProfileInfoSkeletonSection({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return CatchSection.fieldRows(
      title: title,
      children: [
        for (var index = 0; index < rows; index++)
          const ProfileInfoSkeletonTile(),
      ],
    );
  }
}

class ProfileInfoSkeletonTile extends StatelessWidget {
  const ProfileInfoSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.micro14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: CatchStroke.hairline),
            child: CatchSkeleton.box(
              width: CatchFieldRow.leadingSlotIconSize,
              height: CatchFieldRow.leadingSlotIconSize,
              radius: CatchRadius.pill,
            ),
          ),
          const SizedBox(width: CatchFieldRow.leadingSlotGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
                gapH4,
                CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
              ],
            ),
          ),
          CatchSkeleton.box(
            width: CatchSpacing.s10,
            height: CatchSpacing.s10,
            radius: CatchRadius.pill,
          ),
        ],
      ),
    );
  }
}
