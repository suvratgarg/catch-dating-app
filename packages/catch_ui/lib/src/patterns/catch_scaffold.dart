import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_banner.dart';
import 'package:catch_ui/src/components/catch_banner_status_scope.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Safe-area placement owned by CatchScaffold; workspace parents supply insets.
enum CatchScaffoldPlacement { all, top, none }

/// Canonical surface owner for full-screen compositions.
///
/// Named constructors make the route role explicit while this widget keeps
/// background, keyboard resize, and safe-area mechanics out of features.
/// Root-title, primary-rail, and pushed-route shells use [workspace] because their
/// nested owner already applies the appropriate insets.
class CatchScaffold extends StatelessWidget {
  const CatchScaffold.standalone({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.safeArea = CatchScaffoldPlacement.all,
    this.extendBody = false,
  }) : title = null,
       footer = null;

  const CatchScaffold.stepFlow({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.safeArea = CatchScaffoldPlacement.all,
    this.extendBody = false,
  }) : title = null,
       footer = null;

  const CatchScaffold.workspace({
    super.key,
    this.scaffoldKey,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.title,
    this.footer,
    this.extendBody = false,
  }) : safeArea = CatchScaffoldPlacement.none;

  final Key? scaffoldKey;
  final Widget body;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final CatchScaffoldPlacement safeArea;
  final PreferredSizeWidget? title;
  final Widget? footer;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final statuses = CatchBannerStatusScope.of(context);
    // Keep this ancestry stable when connectivity changes: inserting a new
    // wrapper only while offline would recreate focused editors and state.
    final content = safeArea == CatchScaffoldPlacement.none
        ? body
        : CatchBannerStatusScope(
            statuses: const [],
            child: Column(
              children: [
                CatchBanner.statuses(statuses: statuses),
                Expanded(child: body),
              ],
            ),
          );
    final child = switch (safeArea) {
      CatchScaffoldPlacement.all => SafeArea(child: content),
      CatchScaffoldPlacement.top => SafeArea(bottom: false, child: content),
      CatchScaffoldPlacement.none => content,
    };
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor ?? CatchTokens.of(context).bg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      appBar: switch (title) {
        final CatchScaledPreferredSize scaled => PreferredSize(
          preferredSize: scaled.preferredSizeFor(context),
          child: scaled,
        ),
        final bar => bar,
      },
      bottomNavigationBar: footer,
      body: child,
    );
  }
}
