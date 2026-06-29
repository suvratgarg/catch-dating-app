import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchAspectRatio, CatchIcon, CatchLayout, CatchRadius, CatchSpacing, CatchStroke;
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_section.dart';
import 'package:flutter/material.dart';

class ProfileTabSkeletonSliverBody extends StatelessWidget {
  const ProfileTabSkeletonSliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: profileTabBodyPadding,
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
                      const ProfileInfoSkeletonSection(
                        title: 'Prompts',
                        rows: maxProfilePromptAnswers,
                      ),
                      const ProfileInfoSkeletonSection(title: 'About you', rows: 5),
                      const ProfileInfoSkeletonSection(title: 'Running', rows: 4),
                      const ProfileInfoSkeletonSection(title: 'Lifestyle', rows: 4),
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
    return CatchSection.divided(
      title: title,
      bodyGap: CatchSpacing.micro10,
      child: Column(
        children: [
          for (var index = 0; index < rows; index++) ...[
            const ProfileInfoSkeletonTile(),
            if (index < rows - 1) Builder(builder: profileSectionDivider),
          ],
        ],
      ),
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
              width: CatchIcon.control,
              height: CatchIcon.control,
              radius: CatchRadius.pill,
            ),
          ),
          gapW12,
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
