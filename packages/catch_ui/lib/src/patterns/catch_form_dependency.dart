import 'package:catch_ui/src/patterns/catch_form_dependency_mode.dart';

/// One field or meaningful group in a form's dependency model.
///
/// [parent] is the single presentation owner. [prerequisites] can name other
/// decisions whose applicability is required without nesting the field under
/// each of them. [when] is evaluated by the feature from its typed state.
final class CatchFormDependency<K extends Object> {
  const CatchFormDependency({
    required this.id,
    this.parent,
    this.prerequisites = const [],
    this.when = true,
    this.boundary = CatchFormDependencyMode.inline,
  });

  final K id;
  final K? parent;
  final List<K> prerequisites;
  final bool when;
  final CatchFormDependencyMode boundary;
}
