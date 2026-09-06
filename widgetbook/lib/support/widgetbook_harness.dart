import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:widgetbook/widgetbook.dart';

const widgetbookCatalogScrollKey = ValueKey<String>(
  'widgetbook-catalog-scroll',
);
const widgetbookCatalogContentKey = ValueKey<String>(
  'widgetbook-catalog-content',
);

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
        key: widgetbookCatalogScrollKey,
        child: Padding(
          key: widgetbookCatalogContentKey,
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
      ),
    );
  }
}

/// Shared review viewport for device-sized and bottom-aligned sheet cases.
///
/// The production widget still owns its responsive geometry. This frame owns
/// only the bounded catalog canvas, review border and clipping.
class WidgetbookViewportFrame extends StatelessWidget {
  const WidgetbookViewportFrame.device({
    super.key,
    required this.size,
    required this.child,
  }) : _sheet = false;

  const WidgetbookViewportFrame.sheet({
    super.key,
    required this.size,
    required this.child,
  }) : _sheet = true;

  final Size size;
  final Widget child;
  final bool _sheet;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    final radius = BorderRadius.circular(CatchRadius.lg);
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _sheet ? tokens.bg : tokens.surface,
          border: Border.all(color: tokens.line),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: _sheet
                ? Align(alignment: Alignment.bottomCenter, child: child)
                : child,
          ),
        ),
      ),
    );
  }
}

/// Shared provider boundary for catalog fixtures.
///
/// Feature-owned repositories, clocks, routers and fakes remain authored by
/// each case; this utility only removes the repeated ProviderScope shell.
class WidgetbookFixtureScope extends StatelessWidget {
  const WidgetbookFixtureScope({
    super.key,
    required this.overrides,
    required this.child,
  });

  final List<Override> overrides;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(overrides: overrides, child: child);
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

/// Owns the lifetime of a text controller used by a catalog case.
class WidgetbookTextControllerScope extends StatefulWidget {
  const WidgetbookTextControllerScope({
    super.key,
    required this.initialText,
    required this.builder,
  });

  final String initialText;
  final Widget Function(BuildContext, TextEditingController) builder;

  @override
  State<WidgetbookTextControllerScope> createState() =>
      _WidgetbookTextControllerScopeState();
}

class _WidgetbookTextControllerScopeState
    extends State<WidgetbookTextControllerScope> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void didUpdateWidget(covariant WidgetbookTextControllerScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
