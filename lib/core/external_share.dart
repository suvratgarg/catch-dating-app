import 'dart:convert';
import 'dart:typed_data';
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

  Future<void> shareCsvFile({
    required String csv,
    required String fileName,
    String? subject,
    String? text,
    Rect? origin,
  }) {
    final bytes = Uint8List.fromList(utf8.encode(csv));
    final file = XFile.fromData(
      bytes,
      name: fileName,
      mimeType: 'text/csv',
      length: bytes.length,
    );
    return withBackendErrorContext(
      () => _share(
        ShareParams(
          text: text,
          subject: subject,
          title: fileName,
          files: [file],
          fileNameOverrides: [fileName],
          sharePositionOrigin: origin,
        ),
      ),
      context: const BackendErrorContext(
        service: BackendService.external,
        action: 'share csv file',
        resource: 'share_sheet',
      ),
    );
  }

  Future<void> sharePngFile({
    required Uint8List pngBytes,
    required String fileName,
    String? subject,
    String? text,
    Rect? origin,
  }) {
    final file = XFile.fromData(
      pngBytes,
      name: fileName,
      mimeType: 'image/png',
      length: pngBytes.length,
    );
    return withBackendErrorContext(
      () => _share(
        ShareParams(
          text: text,
          subject: subject,
          title: fileName,
          files: [file],
          fileNameOverrides: [fileName],
          sharePositionOrigin: origin,
        ),
      ),
      context: const BackendErrorContext(
        service: BackendService.external,
        action: 'share png file',
        resource: 'share_sheet',
      ),
    );
  }
}
