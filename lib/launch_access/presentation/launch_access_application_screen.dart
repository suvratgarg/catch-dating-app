import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_select_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/launch_access/data/launch_access_config_provider.dart';
import 'package:catch_dating_app/launch_access/data/launch_access_repository.dart';
import 'package:catch_dating_app/launch_access/domain/launch_access_application.dart';
import 'package:catch_dating_app/launch_access/presentation/launch_access_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LaunchAccessApplicationScreen extends ConsumerWidget {
  const LaunchAccessApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(launchAccessConfigProvider);
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: const CatchTopBar(title: 'Apply for access'),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: CatchInsets.contentHorizontal,
          child: !config.gateEnabled
              ? const _LaunchAccessDisabledView()
              : uidAsync.when(
                  loading: () => const Center(child: CatchLoadingIndicator()),
                  error: (error, _) =>
                      Center(child: ErrorBanner.fromError(error)),
                  data: (uid) {
                    if (uid == null || uid.isEmpty) {
                      return const _LaunchAccessSignedOutView();
                    }
                    final applicationAsync = ref.watch(
                      watchLaunchAccessApplicationProvider(uid),
                    );
                    return applicationAsync.when(
                      loading: () =>
                          const Center(child: CatchLoadingIndicator()),
                      error: (error, _) =>
                          Center(child: ErrorBanner.fromError(error)),
                      data: (application) {
                        if (application != null &&
                            !application.status.canEditApplication) {
                          return _LaunchAccessStatusView(
                            application: application,
                          );
                        }
                        return _LaunchAccessApplicationForm(
                          application: application,
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _LaunchAccessApplicationForm extends ConsumerStatefulWidget {
  const _LaunchAccessApplicationForm({this.application});

  final LaunchAccessApplication? application;

  @override
  ConsumerState<_LaunchAccessApplicationForm> createState() =>
      _LaunchAccessApplicationFormState();
}

class _LaunchAccessApplicationFormState
    extends ConsumerState<_LaunchAccessApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _instagramController = TextEditingController();
  final _referralController = TextEditingController();
  final _whyController = TextEditingController();
  bool _seededFromApplication = false;

  @override
  void initState() {
    super.initState();
    _seedFromApplication();
  }

  @override
  void didUpdateWidget(covariant _LaunchAccessApplicationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.application?.uid != widget.application?.uid) {
      _seededFromApplication = false;
      _seedFromApplication();
    }
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _instagramController.dispose();
    _referralController.dispose();
    _whyController.dispose();
    super.dispose();
  }

  void _seedFromApplication() {
    final application = widget.application;
    if (_seededFromApplication || application == null) return;
    ref
        .read(launchAccessControllerProvider.notifier)
        .seedFromApplication(application);
    _inviteCodeController.text = application.inviteCode ?? '';
    _instagramController.text = application.instagramHandle ?? '';
    _referralController.text = application.referralSource ?? '';
    _whyController.text = application.whyCatch ?? '';
    _seededFromApplication = true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    LaunchAccessController.submitMutation.run(ref, (tx) async {
      await tx.get(launchAccessControllerProvider.notifier).submit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(launchAccessControllerProvider);
    final mutation = ref.watch(LaunchAccessController.submitMutation);
    final t = CatchTokens.of(context);
    final selectedCity = defaultCityOptions
        .where((city) => city.name == draft.city)
        .firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: CatchSpacing.s4),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Join the next city drop',
              style: CatchTextStyles.headlineS(context, color: t.ink),
            ),
            gapH8,
            Text(
              'Tell us where you fit so we can open access around real events.',
              style: CatchTextStyles.bodyLead(context, color: t.ink2),
            ),
            gapH24,
            FormField<CityOption>(
              initialValue: selectedCity,
              validator: (_) =>
                  draft.city.trim().isEmpty ? 'Please choose your city' : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CatchFormFieldLabel(label: 'City', hasError: field.hasError),
                  gapH8,
                  CatchSelectMenu<CityOption>(
                    values: defaultCityOptions,
                    value: selectedCity,
                    itemLabel: (city) => city.label,
                    hintText: 'Select city',
                    semanticLabel: 'City',
                    hasError: field.hasError,
                    prefixIcon: Icon(CatchIcons.locationCityOutlined),
                    onChanged: (city) {
                      final next = city?.name ?? '';
                      field.didChange(city);
                      LaunchAccessController.submitMutation.reset(ref);
                      ref
                          .read(launchAccessControllerProvider.notifier)
                          .setCity(next);
                    },
                  ),
                  if (field.hasError) ...[
                    gapH8,
                    Text(
                      field.errorText!,
                      style: CatchTextStyles.supporting(
                        context,
                        color: t.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            gapH24,
            ChipField<LaunchAccessRole>(
              label: 'Joining as',
              values: LaunchAccessRole.values,
              selected: {draft.role},
              multiSelect: false,
              onChanged: (next) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setRole(next.firstOrNull ?? LaunchAccessRole.member);
              },
            ),
            gapH24,
            ChipField<LaunchAccessEventType>(
              label: 'Events you would show up for',
              values: LaunchAccessEventType.values,
              selected: draft.eventTypes,
              multiSelect: true,
              validator: (_) => draft.eventTypes.isEmpty
                  ? 'Choose at least one event type'
                  : null,
              onChanged: (next) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setEventTypes(next);
              },
            ),
            gapH24,
            ChipField<LaunchAccessAvailabilityWindow>(
              label: 'Best times',
              values: LaunchAccessAvailabilityWindow.values,
              selected: draft.availabilityWindows,
              multiSelect: true,
              validator: (_) => draft.availabilityWindows.isEmpty
                  ? 'Choose at least one time'
                  : null,
              onChanged: (next) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setAvailabilityWindows(next);
              },
            ),
            gapH24,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I might host',
                        style: CatchTextStyles.sectionTitle(
                          context,
                          color: t.ink,
                        ),
                      ),
                      gapH4,
                      Text(
                        'Useful if you already run a club, venue, or social format.',
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                gapW12,
                CatchToggle(
                  value: draft.wantsToHost,
                  semanticLabel: 'I might host',
                  onChanged: (value) {
                    LaunchAccessController.submitMutation.reset(ref);
                    ref
                        .read(launchAccessControllerProvider.notifier)
                        .setWantsToHost(value);
                  },
                ),
              ],
            ),
            gapH24,
            CatchTextField(
              label: 'Invite code',
              isOptional: true,
              controller: _inviteCodeController,
              textCapitalization: TextCapitalization.characters,
              prefixIcon: Icon(CatchIcons.confirmationNumberOutlined),
              onChanged: (value) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setInviteCode(value);
              },
            ),
            gapH16,
            CatchTextField(
              label: 'Instagram',
              isOptional: true,
              controller: _instagramController,
              prefixText: '@',
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setInstagramHandle(value);
              },
            ),
            gapH16,
            CatchTextField(
              label: 'Who referred you?',
              isOptional: true,
              controller: _referralController,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setReferralSource(value);
              },
            ),
            gapH16,
            CatchTextField(
              label: 'Why do you want to join?',
              controller: _whyController,
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.length < 12) {
                  return 'Tell us a little more.';
                }
                return null;
              },
              onChanged: (value) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setWhyCatch(value);
              },
            ),
            if (mutation.hasError) ...[
              gapH16,
              ErrorBanner(message: mutationErrorMessage(mutation)),
            ],
            gapH32,
            CatchButton(
              label: widget.application == null
                  ? 'Submit application'
                  : 'Update application',
              onPressed: mutation.isPending ? null : _submit,
              isLoading: mutation.isPending,
              fullWidth: true,
              size: CatchButtonSize.lg,
            ),
            gapH32,
          ],
        ),
      ),
    );
  }
}

class _LaunchAccessStatusView extends StatelessWidget {
  const _LaunchAccessStatusView({required this.application});

  final LaunchAccessApplication application;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: application.status.unlocksProfileCreation
            ? CatchIcons.checkCircleOutlineRounded
            : CatchIcons.hourglassTopRounded,
        title: application.status.label,
        message: application.status.unlocksProfileCreation
            ? 'Access is approved. Profile creation can be unlocked once the router uses this gate.'
            : 'Your application is saved for the next launch cohort.',
      ),
    );
  }
}

class _LaunchAccessDisabledView extends StatelessWidget {
  const _LaunchAccessDisabledView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: CatchIcons.lockOpenRounded,
        title: 'Access gate is off',
        message: 'Remote Config has not enabled launch access for this build.',
      ),
    );
  }
}

class _LaunchAccessSignedOutView extends StatelessWidget {
  const _LaunchAccessSignedOutView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: CatchIcons.phoneAndroidRounded,
        title: 'Verify your phone',
        message: 'Phone verification is required before applying for access.',
      ),
    );
  }
}
