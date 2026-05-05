import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri, {LaunchMode mode});

final externalUrlLauncherProvider = Provider<ExternalUrlLauncher>((ref) {
  return (uri, {mode = LaunchMode.platformDefault}) =>
      launchUrl(uri, mode: mode);
});

final externalLinkControllerProvider = Provider<ExternalLinkController>((ref) {
  return ExternalLinkController(ref.watch(externalUrlLauncherProvider));
});

class ExternalLinkController {
  const ExternalLinkController(this._launchUrl);

  final ExternalUrlLauncher _launchUrl;

  Future<bool> openExternal(Uri uri) {
    if (!uri.hasScheme) return Future.value(false);
    return _launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> open(Uri uri) {
    if (!uri.hasScheme) return Future.value(false);
    return _launchUrl(uri);
  }
}
