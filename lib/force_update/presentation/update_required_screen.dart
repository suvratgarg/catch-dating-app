import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/force_update/data/app_version_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Blocking screen shown when the running app version is below [minVersion].
///
/// The user cannot dismiss this screen — the only action is to go to the store.
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(watchAppVersionConfigProvider).asData?.value;
    final t = CatchTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.system_update_outlined, size: 72, color: t.primary),
              gapH32,
              Text(
                'Update required',
                style: CatchTextStyles.displayLg(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              gapH12,
              Text(
                'A new version of Catch is available. '
                'Please update to continue.',
                style: CatchTextStyles.bodyMd(context, color: t.ink2),
                textAlign: TextAlign.center,
              ),
              gapH48,
              FilledButton.icon(
                onPressed: config != null
                    ? () => _openStore(
                        context,
                        config.storeUrlAndroid,
                        config.storeUrlIos,
                      )
                    : null,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Update now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(
    BuildContext context,
    String androidUrl,
    String iosUrl,
  ) async {
    final url = Theme.of(context).platform == TargetPlatform.iOS
        ? iosUrl
        : androidUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // ignore: use_build_context_synchronously
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open store')));
      }
    }
  }
}
