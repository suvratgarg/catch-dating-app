// ignore_for_file: prefer_initializing_formals

part of 'catch_root_screen_scroll_view.dart';

enum _CatchRootScreenHeaderKind { custom, title }

/// Closed header specification for a root screen with a pinned primary rail.
///
/// Most destinations use [title], which preserves the shared compact
/// title-to-rail handoff. Edge-to-edge destinations such as Explore use
/// [custom] while retaining the same root scroll and pinning owner.
final class CatchRootScreenHeader {
  const CatchRootScreenHeader.custom(Widget header)
    : _kind = _CatchRootScreenHeaderKind.custom,
      _header = header,
      _title = null,
      _eyebrow = null,
      _subtitle = null,
      _leading = null,
      _actions = const <Widget>[],
      _search = null,
      _titleMaxLines = 1,
      _rowCrossAxisAlignment = CrossAxisAlignment.center;

  const CatchRootScreenHeader.title({
    required String title,
    String? eyebrow,
    String? subtitle,
    Widget? leading,
    List<Widget> actions = const <Widget>[],
    CatchTopBarSearch? search,
    int titleMaxLines = 1,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.center,
  }) : _kind = _CatchRootScreenHeaderKind.title,
       _header = null,
       _title = title,
       _eyebrow = eyebrow,
       _subtitle = subtitle,
       _leading = leading,
       _actions = actions,
       _search = search,
       _titleMaxLines = titleMaxLines,
       _rowCrossAxisAlignment = rowCrossAxisAlignment;

  final _CatchRootScreenHeaderKind _kind;
  final Widget? _header;
  final String? _title;
  final String? _eyebrow;
  final String? _subtitle;
  final Widget? _leading;
  final List<Widget> _actions;
  final CatchTopBarSearch? _search;
  final int _titleMaxLines;
  final CrossAxisAlignment _rowCrossAxisAlignment;

  Widget _build(BuildContext context) {
    if (_kind == _CatchRootScreenHeaderKind.custom) return _header!;
    if (_search == null) {
      return CatchScreenHeader.block(
        kicker: _eyebrow,
        title: _title!,
        subtitle: _subtitle,
        leading: _leading,
        actions: _actions,
        titleMaxLines: _titleMaxLines,
        rowCrossAxisAlignment: _rowCrossAxisAlignment,
        padding: CatchInsets.primaryRailTitleBlock,
      );
    }
    return CatchTopBar.primaryRail(
      context: context,
      eyebrow: _eyebrow,
      title: _title!,
      subtitle: _subtitle,
      leading: _leading,
      actions: _actions,
      titleMaxLines: _titleMaxLines,
      rowCrossAxisAlignment: _rowCrossAxisAlignment,
      search: _search,
    );
  }
}
