import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/force_update/domain/app_version_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateRequiredControllerProvider = Provider<UpdateRequiredController>((
  ref,
) {
  return UpdateRequiredController(ref.watch(externalLinkControllerProvider));
});

class UpdateRequiredController {
  const UpdateRequiredController(this._links);

  final ExternalLinkController _links;

  Future<bool> openStore({
    required TargetPlatform platform,
    required AppVersionConfig config,
  }) async {
    final url = switch (platform) {
      TargetPlatform.iOS => config.storeUrlIos,
      _ => config.storeUrlAndroid,
    };

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;

    return _links.openExternal(uri);
  }
}
