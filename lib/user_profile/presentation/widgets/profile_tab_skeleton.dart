import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchAspectRatio, CatchInsets, CatchLayout, CatchRadius, CatchStroke;
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchFieldRow;
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:flutter/material.dart';

class ProfileTabSkeletonSliverBody extends StatelessWidget {
  const ProfileTabSkeletonSliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: CatchInsets.formEditBodyRelaxed,
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CatchLayout.maxContentWidth,
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchSectionList(
                    gap: 0,
                    children: [
                      ProfilePhotosSkeletonSection(),
                      ProfileInfoSkeletonSection(
                        title: 'Prompts',
                        rows: maxProfilePromptAnswers,
                      ),
                      ProfileInfoSkeletonSection(title: 'About you', rows: 5),
                      ProfileInfoSkeletonSection(title: 'Running', rows: 4),
                      ProfileInfoSkeletonSection(title: 'Lifestyle', rows: 4),
                    ],
                  ),
                  gapH32,
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
    return CatchSection.divided(
      title: 'Photos',
      count: 'loading',
      first: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: CatchSpacing.s2,
          crossAxisSpacing: CatchSpacing.s2,
          childAspectRatio: CatchAspectRatio.portrait3x4,
        ),
        itemCount: maximumProfilePhotoCount,
        itemBuilder: (context, index) => CatchSkeleton.box(
          width: double.infinity,
          height: double.infinity,
          radius: CatchRadius.lg,
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
