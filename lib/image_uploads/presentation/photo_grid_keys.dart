import 'package:flutter/foundation.dart';

abstract final class PhotoGridKeys {
  static ValueKey<String> slot(int index) => ValueKey('photo_grid.slot.$index');
}
