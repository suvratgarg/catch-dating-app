import 'dart:ui';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'external_share.g.dart';

typedef ExternalShareLauncher = Future<void> Function(ShareParams params);

@Riverpod(keepAlive: true)
ExternalShareLauncher externalShareLauncher(Ref ref) => (params) async {
  await SharePlus.instance.share(params);
};

@Riverpod(keepAlive: true)
ExternalShareController externalShareController(Ref ref) =>
    ExternalShareController(ref.watch(externalShareLauncherProvider));

class ExternalShareController {
  const ExternalShareController(this._share);

  final ExternalShareLauncher _share;

  Future<void> shareText({
    required String text,
    String? subject,
    Rect? origin,
  }) {
    return withBackendErrorContext(
      () => _share(
        ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
      ),
      context: const BackendErrorContext(
        service: BackendService.external,
        action: 'share text',
        resource: 'share_sheet',
      ),
    );
  }
}
