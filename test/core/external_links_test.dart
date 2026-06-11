import 'package:catch_dating_app/core/external_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  test('openExternal uses external application launch mode', () async {
    Uri? launchedUri;
    LaunchMode? launchMode;
    final controller = ExternalLinkController((
      uri, {
      mode = LaunchMode.platformDefault,
    }) async {
      launchedUri = uri;
      launchMode = mode;
      return true;
    });

    final opened = await controller.openExternal(
      Uri.parse('https://catchdates.com/help'),
    );

    expect(opened, isTrue);
    expect(launchedUri, Uri.parse('https://catchdates.com/help'));
    expect(launchMode, LaunchMode.externalApplication);
  });

  test('rejects relative URIs before launching', () async {
    var launchCallCount = 0;
    final controller = ExternalLinkController((
      uri, {
      mode = LaunchMode.platformDefault,
    }) async {
      launchCallCount += 1;
      return true;
    });

    final opened = await controller.openExternal(Uri.parse('/help'));

    expect(opened, isFalse);
    expect(launchCallCount, 0);
  });

  test('openHostApp uses the configured host app handoff URL', () async {
    Uri? launchedUri;
    LaunchMode? launchMode;
    final controller = ExternalLinkController((
      uri, {
      mode = LaunchMode.platformDefault,
    }) async {
      launchedUri = uri;
      launchMode = mode;
      return true;
    });

    final opened = await controller.openHostApp();

    expect(opened, isTrue);
    expect(launchedUri, Uri.parse('https://catchdates.com/host'));
    expect(launchMode, LaunchMode.externalApplication);
  });
}
