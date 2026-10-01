import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/data/host_tracking_settings_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_tracking_settings_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_tracking_settings_input_section.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings remain in the organiser Insights workspace; server owns eligibility.
class HostTrackingSettingsSection extends ConsumerWidget {
  const HostTrackingSettingsSection({super.key, required this.organizerId});
  final String organizerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = catchAsyncStateFromAsyncValue(ref.watch(uidProvider));
    final accountId = auth.isSettledData ? auth.value : null;
    if (accountId == null || accountId.isEmpty) {
      return CatchSection.content(
        title: context.l10n.hostsTrackingSettingsTitle,
        child: auth.isLoading
            ? const Center(child: CircularProgressIndicator())
            : CatchLocalizedErrorState(
                auth.error ??
                    const SignInRequiredException('read tracking settings'),
                context: AppErrorContext.club,
                onRetry: () => ref.invalidate(uidProvider),
              ),
      );
    }
    final scope = (
      accountId: accountId,
      organizerId: organizerId,
      session: ref.watch(hostTrackingSessionProvider),
    );
    final saveMutation = HostTrackingSettingsController.saveMutation(scope);
    ref.listen(hostTrackingSessionProvider, (previous, next) {
      if (!identical(scope.session, next)) saveMutation.reset(ref);
    });
    final settings = ref.watch(hostTrackingSettingsProvider(organizerId));
    final settingsState = catchAsyncStateFromAsyncValue(settings);
    // A refresh/error can retain the previous account's data. Private settings
    // never render stale data while the new authenticated read is unresolved.
    final privateSettings = settingsState.isSettledData
        ? settings
        : settingsState.error != null && !settingsState.isLoading
        ? AsyncError<HostTrackingSettings>(
            settingsState.error!,
            StackTrace.empty,
          )
        : const AsyncLoading<HostTrackingSettings>();
    final mutation = ref.watch(saveMutation);
    return CatchAsyncBoundary<HostTrackingSettings>(
      value: privateSettings,
      onRetry: () => ref.invalidate(hostTrackingSettingsProvider(organizerId)),
      loadingBuilder: (_) => CatchSection.content(
        title: context.l10n.hostsTrackingSettingsTitle,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorBuilder: (_, error, _, retry) => CatchSection.content(
        title: context.l10n.hostsTrackingSettingsTitle,
        child: CatchLocalizedErrorState(
          error,
          context: AppErrorContext.club,
          onRetry: retry,
        ),
      ),
      builder: (_, current) => HostTrackingSettingsInputSection(
        key: ValueKey((scope: scope, revision: current.revision)),
        current: current,
        pending: mutation.isPending,
        error: mutation.hasError ? (mutation as MutationError).error : null,
        onReload: () =>
            ref.invalidate(hostTrackingSettingsProvider(organizerId)),
        onSave:
            ({
              required metaPixelId,
              required googleMeasurementId,
              required enabled,
            }) async {
              if (mutation.isPending) return;
              try {
                await saveMutation.run(
                  ref,
                  (tx) => tx
                      .get(hostTrackingSettingsControllerProvider)
                      .save(
                        scope: scope,
                        current: current,
                        metaPixelId: metaPixelId,
                        googleMeasurementId: googleMeasurementId,
                        enabled: enabled,
                      ),
                );
                if (!ref.context.mounted ||
                    !identical(
                      ref.read(hostTrackingSessionProvider),
                      scope.session,
                    )) {
                  return;
                }
                ref.invalidate(hostTrackingSettingsProvider(organizerId));
              } catch (_) {
                // Mutation retains the error and unsaved draft for explicit recovery.
              }
            },
      ),
    );
  }
}
