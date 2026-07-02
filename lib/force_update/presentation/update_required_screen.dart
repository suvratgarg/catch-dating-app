import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
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

    return UpdateRequiredContent(
      onUpdateNow: () async {
        final platform = Theme.of(context).platform;
        final controller = ref.read(updateRequiredControllerProvider);

        try {
          final opened = await controller.openStore(
            platform: platform,
            config: config,
          );
          if (!context.mounted) {
            return;
          }
          if (!opened) {
            showCatchErrorSnackBar(
              context,
              const ExternalActionException(
                'Could not open the app store. Please update Catch '
                'from your device\'s app store.',
              ),
            );
          }
        } catch (error) {
          if (context.mounted) {
            showCatchErrorSnackBar(context, error);
          }
        }
      },
    );
  }
}

/// Provider-free full-screen update prompt rendered by [UpdateRequiredScreen].
class UpdateRequiredContent extends StatelessWidget {
  const UpdateRequiredContent({super.key, required this.onUpdateNow});

  final VoidCallback onUpdateNow;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: CatchInsets.emptyStateContent,
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
                onPressed: onUpdateNow,
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
