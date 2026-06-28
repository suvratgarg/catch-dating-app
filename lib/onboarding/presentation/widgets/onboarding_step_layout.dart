import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';

Widget onboardingStepLayout({
  Key? key,
  required List<Widget> children,
  Widget? footer,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.s5,
    CatchSpacing.s5,
    CatchSpacing.s0,
  ),
  EdgeInsetsGeometry footerPadding = const EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.s3,
    CatchSpacing.s5,
    CatchSpacing.s6,
  ),
}) {
  return Column(
    key: key,
    children: [
      Expanded(
        child: CatchScreenBody(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
      if (footer != null)
        SafeArea(
          top: false,
          child: CatchBottomDock(
            includeSafeArea: false,
            padding: footerPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CatchLayout.maxContentWidth,
                ),
                child: footer,
              ),
            ),
          ),
        ),
    ],
  );
}
