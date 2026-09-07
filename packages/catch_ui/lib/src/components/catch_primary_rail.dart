import 'package:flutter/material.dart';

/// Marker contract for the one pinned peer-control rail owned by a root screen.
///
/// Root composition accepts this type instead of any [PreferredSizeWidget], so
/// an arbitrary app bar, wrapper, or hand-rolled tab bar cannot enter the
/// pinned rail slot merely by reporting the expected height.
abstract interface class CatchPrimaryRail implements PreferredSizeWidget {}
