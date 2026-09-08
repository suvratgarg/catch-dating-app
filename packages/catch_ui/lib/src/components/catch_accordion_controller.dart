import 'package:flutter/foundation.dart';

/// Owns "at most one expanded inline editor" state for a field list.
class CatchAccordionController extends ChangeNotifier {
  CatchAccordionController({String? initialExpanded})
    : _expanded = initialExpanded;

  String? _expanded;

  String? get expanded => _expanded;

  bool isExpanded(String key) => _expanded == key;

  void toggle(String key) {
    final next = _expanded == key ? null : key;
    if (next == _expanded) return;
    _expanded = next;
    notifyListeners();
  }

  void collapse() {
    if (_expanded == null) return;
    _expanded = null;
    notifyListeners();
  }
}
