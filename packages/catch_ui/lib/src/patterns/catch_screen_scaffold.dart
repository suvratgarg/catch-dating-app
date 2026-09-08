import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_status_strip.dart';
import 'package:catch_ui/src/components/catch_status_strip_scope.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Safe-area ownership for canonical full-screen composition families.
enum CatchScreenSafeArea { all, top, none }

/// Canonical surface owner for full-screen compositions.
///
/// Named constructors make the route role explicit while this widget keeps
/// background, keyboard resize, and safe-area mechanics out of features.
/// Root-title, primary-rail, and pushed-route shells use [workspace] because their
/// nested owner already applies the appropriate insets.
class CatchScreenScaffold extends StatelessWidget {
  const CatchScreenScaffold.standalone({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.safeArea = CatchScreenSafeArea.all,
    this.extendBody = false,
  }) : appBar = null,
       bottomNavigationBar = null;

  const CatchScreenScaffold.stepFlow({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.safeArea = CatchScreenSafeArea.all,
    this.extendBody = false,
  }) : appBar = null,
       bottomNavigationBar = null;

  const CatchScreenScaffold.workspace({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.appBar,
    this.bottomNavigationBar,
    this.extendBody = false,
  }) : safeArea = CatchScreenSafeArea.none;

  final Key? scaffoldKey;
  final Widget body;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final CatchScreenSafeArea safeArea;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final statuses = CatchStatusStripScope.of(context);
    // Keep this ancestry stable when connectivity changes: inserting a new
    // wrapper only while offline would recreate focused editors and state.
    final content = safeArea == CatchScreenSafeArea.none
        ? body
        : CatchStatusStripScope(
            statuses: const [],
            child: Column(
              children: [
                CatchStatusStrip(statuses: statuses),
                Expanded(child: body),
              ],
            ),
          );
    final child = switch (safeArea) {
      CatchScreenSafeArea.all => SafeArea(child: content),
      CatchScreenSafeArea.top => SafeArea(bottom: false, child: content),
      CatchScreenSafeArea.none => content,
    };
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor ?? CatchTokens.of(context).bg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      appBar: switch (appBar) {
        final CatchScaledPreferredSize scaled => PreferredSize(
          preferredSize: scaled.preferredSizeFor(context),
          child: scaled,
        ),
        final bar => bar,
      },
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }
}
