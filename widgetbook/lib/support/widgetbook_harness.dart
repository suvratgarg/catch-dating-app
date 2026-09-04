import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Shared catalog canvas. The reference cases retain their production widgets
/// and state cards; only their repeated outer frame moves here.
class WidgetbookCatalogFrame extends StatelessWidget {
  const WidgetbookCatalogFrame({
    super.key,
    required this.title,
    required this.catalogId,
    required this.children,
  });

  final String title;
  final String catalogId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return ColoredBox(
      color: tokens.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: CatchTextStyles.headline(context)),
                gapH4,
                CatchMonoLabel(catalogId, color: tokens.ink3),
                gapH20,
                for (final child in children) ...[
                  child,
                  if (child != children.last) gapH16,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Provides real Widgetbook knob state below the test's existing Catch theme.
/// App, locale, media-query and provider ownership stay with the caller.
class WidgetbookCaseScope extends StatefulWidget {
  const WidgetbookCaseScope({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  State<WidgetbookCaseScope> createState() => _WidgetbookCaseScopeState();
}

class _WidgetbookCaseScopeState extends State<WidgetbookCaseScope> {
  final _state = WidgetbookState(
    root: WidgetbookRoot(children: []),
    previewMode: true,
  );

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WidgetbookScope(
    state: _state,
    child: Builder(builder: widget.builder),
  );
}
