import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'external_links.g.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri, {LaunchMode mode});

@Riverpod(keepAlive: true)
ExternalUrlLauncher externalUrlLauncher(Ref ref) =>
    (uri, {mode = LaunchMode.platformDefault}) => launchUrl(uri, mode: mode);

@Riverpod(keepAlive: true)
ExternalLinkController externalLinkController(Ref ref) =>
    ExternalLinkController(ref.watch(externalUrlLauncherProvider));

class ExternalLinkController {
  const ExternalLinkController(this._launchUrl);

  final ExternalUrlLauncher _launchUrl;

  Future<bool> openExternal(Uri uri) {
    if (!uri.hasScheme) return Future.value(false);
    return withBackendErrorContext(
      () => _launchUrl(uri, mode: LaunchMode.externalApplication),
      context: const BackendErrorContext(
        service: BackendService.external,
        action: 'open external link',
        resource: 'url_launcher',
      ),
    );
  }

  Future<bool> openHostApp() => openExternal(AppConfig.hostAppUrl);

  Future<bool> open(Uri uri) {
    if (!uri.hasScheme) return Future.value(false);
    return withBackendErrorContext(
      () => _launchUrl(uri),
      context: const BackendErrorContext(
        service: BackendService.external,
        action: 'open link',
        resource: 'url_launcher',
      ),
    );
  }
}
