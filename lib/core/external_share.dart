import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

typedef ExternalShareLauncher = Future<void> Function(ShareParams params);

final externalShareLauncherProvider = Provider<ExternalShareLauncher>((ref) {
  return (params) async {
    await SharePlus.instance.share(params);
  };
});

final externalShareControllerProvider = Provider<ExternalShareController>((
  ref,
) {
  return ExternalShareController(ref.watch(externalShareLauncherProvider));
});

class ExternalShareController {
  const ExternalShareController(this._share);

  final ExternalShareLauncher _share;

  Future<void> shareText({
    required String text,
    String? subject,
    Rect? origin,
  }) {
    return _share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
  }
}
