import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/force_update/data/app_version_config_provider.dart';
import 'package:catch_dating_app/force_update/presentation/update_required_controller.dart';
import 'package:catch_dating_app/force_update/presentation/update_required_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Blocking screen shown when the running app version is below [minVersion].
///
/// The user cannot dismiss this screen — the only action is to go to the store.
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appVersionConfigProvider);
    final t = CatchTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CatchSpacing.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                CatchIcons.systemUpdateOutlined,
                size: CatchIcon.forceUpdate,
                color: t.primary,
              ),
              gapH32,
              Text(
                'Update required',
                style: CatchTextStyles.headline(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              gapH12,
              Text(
                'A new version of Catch is available. '
                'Please update to continue.',
                style: CatchTextStyles.bodyLead(context, color: t.ink2),
                textAlign: TextAlign.center,
              ),
              gapH48,
              CatchButton(
                key: UpdateRequiredKeys.updateNowButton,
                label: 'Update now',
                onPressed: () async {
                  final opened = await ref
                      .read(updateRequiredControllerProvider)
                      .openStore(
                        platform: Theme.of(context).platform,
                        config: config,
                      );
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open store')),
                    );
                  }
                },
                icon: Icon(CatchIcons.openInNew),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
