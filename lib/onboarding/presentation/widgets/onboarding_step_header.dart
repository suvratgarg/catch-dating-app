import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: CatchTextStyles.headline(context, color: t.ink)),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          gapH8,
          Text(
            subtitle!,
            style: CatchTextStyles.proseM(context, color: t.ink2),
          ),
        ],
      ],
    );
  }
}

class OnboardingStepFrame extends StatelessWidget {
  const OnboardingStepFrame({
    super.key,
    required this.children,
    this.footer,
    this.padding = const EdgeInsets.fromLTRB(
      CatchSpacing.s5,
      CatchSpacing.s5,
      CatchSpacing.s5,
      CatchSpacing.s0,
    ),
    this.footerPadding = const EdgeInsets.fromLTRB(
      CatchSpacing.s5,
      CatchSpacing.s3,
      CatchSpacing.s5,
      CatchSpacing.s6,
    ),
  });

  final List<Widget> children;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry footerPadding;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: CatchLayout.maxContentWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(padding: padding, child: content),
        ),
        if (footer != null)
          SafeArea(
            top: false,
            child: Padding(
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
}
