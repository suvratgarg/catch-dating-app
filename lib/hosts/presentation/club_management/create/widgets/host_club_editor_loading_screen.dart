import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HostClubEditorLoadingScreen extends StatelessWidget {
  const HostClubEditorLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            CatchStepHeader(
              title: context.l10n.hostsCreateClubScreenTitleClubBasics,
              step: 1,
              total: 4,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: CatchInsets.formStepBody,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CatchSkeletonBoxRow(
                      height: CatchLayout.clubEditorPhotoSkeletonHeight,
                    ),
                    gapH20,
                    CatchSkeletonRows(
                      leading: CatchSkeletonRowLeading.icon,
                      count: 4,
                      titleWidth: CatchLayout.skeletonTextCardTitleWidth,
                      divided: true,
                    ),
                    gapH20,
                    CatchSkeletonRows(
                      leading: CatchSkeletonRowLeading.icon,
                      titleWidth: CatchLayout.skeletonTextInlineTitleWidth,
                      divided: true,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                CatchSpacing.s3,
                CatchSpacing.s2,
                CatchSpacing.s3,
                CatchSpacing.s3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatchSkeletonBoxRow(
                    height: CatchLayout.buttonLgHeight,
                    radius: CatchRadius.pill,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
