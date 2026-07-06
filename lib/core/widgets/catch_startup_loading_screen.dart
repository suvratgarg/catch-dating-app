import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:flutter/material.dart';

class CatchStartupLoadingScreen extends StatefulWidget {
  const CatchStartupLoadingScreen({super.key});

  static const iconAsset = 'assets/branding/catch_icon.png';

  @override
  State<CatchStartupLoadingScreen> createState() =>
      _CatchStartupLoadingScreenState();
}

class _CatchStartupLoadingScreenState extends State<CatchStartupLoadingScreen> {
  Timer? _indicatorDelay;
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    _indicatorDelay = Timer(CatchMotion.startupIndicatorDelay, () {
      if (!mounted) return;
      setState(() {
        _showIndicator = true;
      });
    });
  }

  @override
  void dispose() {
    _indicatorDelay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.asset(
                CatchStartupLoadingScreen.iconAsset,
                width: CatchLayout.startupLogoExtent,
                height: CatchLayout.startupLogoExtent,
                semanticLabel: 'Catch',
              ),
            ),
            Center(
              child: Transform.translate(
                offset: const Offset(0, CatchLayout.startupIndicatorOffsetY),
                child: AnimatedSwitcher(
                  duration: CatchMotion.fast,
                  switchInCurve: CatchMotion.standardCurve,
                  child: _showIndicator
                      ? SizedBox.square(
                          key: const ValueKey<String>(
                            'startup-loading-indicator',
                          ),
                          dimension: CatchLayout.startupIndicatorExtent,
                          child: CatchLoadingIndicator(
                            strokeWidth: 2.6,
                            color: t.ink,
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey<String>('startup-loading-delay'),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
