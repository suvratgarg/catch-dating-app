import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:flutter/material.dart';

class CatchStartupLoadingScreen extends StatelessWidget {
  const CatchStartupLoadingScreen({super.key});

  static const iconAsset = 'assets/branding/catch_icon.png';

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconAsset,
                width: CatchLayout.startupLogoExtent,
                height: CatchLayout.startupLogoExtent,
                semanticLabel: 'Catch',
              ),
              gapH28,
              const SizedBox.square(
                dimension: CatchLayout.startupIndicatorExtent,
                child: CatchLoadingIndicator(
                  strokeWidth: 2.6,
                  color: CatchTokens.editorialLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
