import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostClubEditorLoadingScreen extends StatelessWidget {
  const HostClubEditorLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchScreenScaffold.stepFlow(
      backgroundColor: t.bg,
      body: Column(
        children: [
          CatchStepHeader(
            stepLabelBuilder: catchStepHeaderLabelBuilder(context.l10n),
            compactStepLabelBuilder: catchStepHeaderCompactLabelBuilder(
              context.l10n,
            ),
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
                  CatchSkeleton.boxes(
                    height: CatchLayout.clubEditorPhotoSkeletonHeight,
                  ),
                  gapH20,
                  CatchSkeleton.iconRows(
                    count: 4,
                    titleWidth: CatchLayout.skeletonTextCardTitleWidth,
                    divided: true,
                  ),
                  gapH20,
                  CatchSkeleton.iconRows(
                    titleWidth: CatchLayout.skeletonTextInlineTitleWidth,
                    divided: true,
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: CatchInsets.hostClubEditorLoadingAction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchSkeleton.boxes(
                  height: CatchLayout.buttonLgHeight,
                  radius: CatchRadius.pill,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
