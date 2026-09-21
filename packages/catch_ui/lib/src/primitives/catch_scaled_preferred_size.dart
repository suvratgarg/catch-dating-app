import 'package:flutter/widgets.dart';

/// A header whose laid-out height follows the current text scale.
///
/// [preferredSize] remains its unscaled minimum for composition contracts;
/// the screen owner requests [preferredSizeFor] when reserving its live slot.
/// [preferredSizeFor] accepts the actual available width for wrapping headers;
/// width-independent rails may ignore it.
abstract interface class CatchScaledPreferredSize
    implements PreferredSizeWidget {
  Size preferredSizeFor(BuildContext context, {double? width});
}
