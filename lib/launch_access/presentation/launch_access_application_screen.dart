import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
      appBar: CatchTopBar(
        title: context
            .l10n
            .launchAccessLaunchAccessApplicationScreenTitleApplyForAccess,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: CatchInsets.contentHorizontal,
          child: !config.gateEnabled
              ? Center(
                  child: CatchEmptyState(
                    icon: CatchIcons.lockOpenRounded,
                    title: context
                        .l10n
                        .launchAccessLaunchAccessApplicationScreenTitleAccessGateIsOff,
                    message: context
                        .l10n
                        .launchAccessLaunchAccessApplicationScreenMessageRemoteConfigHasNot,
                  ),
                )
              : CatchAsyncValueView<String?>(
                  value: uidAsync,
                  data: (uid) {
                    if (uid == null || uid.isEmpty) {
                      return Center(
                        child: CatchEmptyState(
                          icon: CatchIcons.phoneAndroidRounded,
                          title: context
                              .l10n
                              .launchAccessLaunchAccessApplicationScreenTitleVerifyYourPhone,
                          message: context
                              .l10n
                              .launchAccessLaunchAccessApplicationScreenMessagePhoneVerificationIsRequired,
                        ),
                      );
                    }
                    final applicationAsync = ref.watch(
                      watchLaunchAccessApplicationProvider(uid),
                    );
                    return applicationAsync.when(
                      loading: () => const LaunchAccessLoadingBody(),
                      error: (error, _) =>
                          Center(child: CatchErrorBanner.fromError(error)),
                      data: (application) {
                        if (application != null &&
                            !application.status.canEditApplication) {
                          return Center(
                            child: CatchEmptyState(
                              icon: application.status.unlocksProfileCreation
                                  ? CatchIcons.checkCircleOutlineRounded
                                  : CatchIcons.hourglassTopRounded,
                              title: application.status.label,
                              message: application.status.unlocksProfileCreation
                                  ? context
                                        .l10n
                                        .launchAccessLaunchAccessApplicationScreenMessageAccessIsApprovedProfile
                                  : context
                                        .l10n
                                        .launchAccessLaunchAccessApplicationScreenMessageYourApplicationIsSaved,
                            ),
                          );
                        }
                        return LaunchAccessApplicationForm(
                          application: application,
                        );
                      },
                    );
                  },
                  onRetry: () => ref.invalidate(uidProvider),
                ),
        ),
      ),
    );
  }
}

class LaunchAccessLoadingBody extends StatelessWidget {
  const LaunchAccessLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH8,
          CatchSkeleton.textBlock(lines: 2),
          gapH24,
          CatchSkeleton.card(height: CatchLayout.controlMdMinHeight),
          gapH24,
          const LaunchAccessChoiceSkeleton(rows: 1),
          gapH24,
          const LaunchAccessChoiceSkeleton(rows: 2),
          gapH24,
          const LaunchAccessChoiceSkeleton(rows: 2),
          gapH24,
          Row(
            children: [
              Expanded(child: CatchSkeleton.textBlock(lines: 2)),
              gapW12,
              CatchSkeleton.box(
                width: CatchSpacing.s12,
                height: CatchSpacing.s8,
                radius: CatchRadius.pill,
              ),
            ],
          ),
          gapH24,
          for (var index = 0; index < 3; index++) ...[
            CatchSkeleton.card(height: CatchLayout.controlMdMinHeight),
            gapH16,
          ],
          CatchSkeleton.card(height: CatchSpacing.s16),
          gapH32,
          CatchSkeleton.card(height: CatchLayout.buttonLgHeight),
          gapH32,
        ],
      ),
    );
  }
}

class LaunchAccessChoiceSkeleton extends StatelessWidget {
  const LaunchAccessChoiceSkeleton({super.key, required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
        gapH10,
        for (var row = 0; row < rows; row++) ...[
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (var index = 0; index < 3; index++)
                CatchSkeleton.box(
                  width: index == 1
                      ? CatchLayout.skeletonTextTitleWidth
                      : CatchLayout.skeletonTextShortWidth,
                  height: CatchSpacing.s8,
                  radius: CatchRadius.pill,
                ),
            ],
          ),
          if (row < rows - 1) gapH8,
        ],
      ],
    );
  }
}

class LaunchAccessApplicationForm extends ConsumerStatefulWidget {
  const LaunchAccessApplicationForm({super.key, this.application});

  final LaunchAccessApplication? application;

  @override
  ConsumerState<LaunchAccessApplicationForm> createState() =>
      _LaunchAccessApplicationFormState();
}

class _LaunchAccessApplicationFormState
    extends ConsumerState<LaunchAccessApplicationForm> {
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
  void didUpdateWidget(covariant LaunchAccessApplicationForm oldWidget) {
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
    final selectableCities = defaultCityOptions
        .where((city) => city.profileSelectable)
        .toList(growable: false);
    final selectedCity = selectableCities
        .where((city) => city.effectiveMarketId == draft.city)
        .firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: CatchSpacing.s4),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTextJoinTheNextCity,
              style: CatchTextStyles.headlineS(context, color: t.ink),
            ),
            gapH8,
            Text(
              context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTextTellUsWhereYou,
              style: CatchTextStyles.bodyLead(context, color: t.ink2),
            ),
            gapH24,
            CatchField.select<CityOption>(
              title: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTitleCity,
              values: selectableCities,
              value: selectedCity,
              itemLabel: (city) => city.label,
              hintText: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenHinttextSelectCity,
              prefixIcon: Icon(CatchIcons.locationCityOutlined),
              validator: (_) =>
                  draft.city.trim().isEmpty ? 'Please choose your city' : null,
              onChanged: (city) {
                final next = city?.effectiveMarketId ?? '';
                LaunchAccessController.submitMutation.reset(ref);
                ref.read(launchAccessControllerProvider.notifier).setCity(next);
              },
            ),
            gapH24,
            CatchChipField<LaunchAccessRole>(
              label: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenLabelJoiningAs,
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
            CatchChipField<LaunchAccessEventType>(
              label: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenLabelEventsYouWouldShow,
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
            CatchChipField<LaunchAccessAvailabilityWindow>(
              label: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenLabelBestTimes,
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
            CatchField.toggle(
              title: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTitleIMightHost,
              body: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenBodyUsefulIfYouAlready,
              value: draft.wantsToHost,
              onChanged: (value) {
                LaunchAccessController.submitMutation.reset(ref);
                ref
                    .read(launchAccessControllerProvider.notifier)
                    .setWantsToHost(value);
              },
            ),
            gapH24,
            CatchField.input(
              title: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTitleInviteCode,
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
            CatchField.input(
              title: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTitleInstagram,
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
            CatchField.input(
              title: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTitleWhoReferredYou,
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
            CatchField.input(
              title: context
                  .l10n
                  .launchAccessLaunchAccessApplicationScreenTitleWhyDoYouWant,
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
              CatchErrorBanner(
                message: mutationErrorMessage(mutation, l10n: context.l10n),
              ),
            ],
            gapH32,
            CatchButton(
              label: widget.application == null
                  ? context
                        .l10n
                        .launchAccessLaunchAccessApplicationScreenLabelSubmitApplication
                  : context
                        .l10n
                        .launchAccessLaunchAccessApplicationScreenLabelUpdateApplication,
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
