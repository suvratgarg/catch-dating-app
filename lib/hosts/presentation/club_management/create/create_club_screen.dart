import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_draft.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_basics_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_step_header.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen_state.dart';

const _maxClubPhotos = 6;

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({
    super.key,
    this.initialDraft,
    this.initialStep = 0,
    this.restoreSavedDraft = true,
    this.formAutovalidateMode = AutovalidateMode.disabled,
    this.initialPickedClubPhotos = const <PickedClubPhoto>[],
    this.initialProfileImage,
  });

  final ClubDraft? initialDraft;
  final int initialStep;
  final bool restoreSavedDraft;
  final AutovalidateMode formAutovalidateMode;
  final List<PickedClubPhoto> initialPickedClubPhotos;
  final PickedClubProfileImage? initialProfileImage;

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

sealed class HostClubCreateRouteIntent {
  const HostClubCreateRouteIntent();
}

final class HostClubCreateBackIntent extends HostClubCreateRouteIntent {
  const HostClubCreateBackIntent();
}

final class HostClubCreatePickProfileImageIntent
    extends HostClubCreateRouteIntent {
  const HostClubCreatePickProfileImageIntent();
}

final class HostClubCreatePickClubPhotosIntent
    extends HostClubCreateRouteIntent {
  const HostClubCreatePickClubPhotosIntent();
}

final class HostClubCreateRemoveClubPhotoIntent
    extends HostClubCreateRouteIntent {
  const HostClubCreateRemoveClubPhotoIntent(this.index);

  final int index;
}

final class HostClubCreateReorderClubPhotoIntent
    extends HostClubCreateRouteIntent {
  const HostClubCreateReorderClubPhotoIntent({
    required this.fromIndex,
    required this.toIndex,
  });

  final int fromIndex;
  final int toIndex;
}

final class HostClubCreateCityChangedIntent extends HostClubCreateRouteIntent {
  const HostClubCreateCityChangedIntent(this.city);

  final CityOption? city;
}

final class HostClubCreateOrganizerTypeChangedIntent
    extends HostClubCreateRouteIntent {
  const HostClubCreateOrganizerTypeChangedIntent(this.organizerType);

  final OrganizerType organizerType;
}

final class HostClubCreateDefaultsChangedIntent
    extends HostClubCreateRouteIntent {
  const HostClubCreateDefaultsChangedIntent(this.defaults);

  final ClubHostDefaults defaults;
}

typedef HostClubCreateRouteIntentCallback =
    void Function(HostClubCreateRouteIntent intent);

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  late final PageController _pageController;
  final _basicsFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();
  final _defaultsFormKey = GlobalKey<FormState>();
  final _eventSuccessFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instagramController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  int _currentStep = 0;
  String? _selectedCity;
  OrganizerType _organizerType = OrganizerType.club;
  final _clubPhotos = <_ClubPhotoDraft>[];
  var _clubPhotosTouched = false;
  var _nextPickedClubPhotoId = 0;
  PickedClubProfileImage? _profileImage;
  bool _checkedDraft = false;
  bool _restoredDraft = false;
  ClubHostDefaults _hostDefaults = const ClubHostDefaults();

  List<CatchFormStepSpec> get _activeSteps {
    return [
      CatchFormStepSpec(
        title: context.l10n.hostsCreateClubScreenTitleClubBasics,
        formKey: _basicsFormKey,
      ),
      CatchFormStepSpec(
        title: context.l10n.hostsCreateClubScreenTitleClubDetails,
        formKey: _detailsFormKey,
      ),
      CatchFormStepSpec(
        title: context.l10n.hostsCreateClubScreenTitleHostDefaults,
        formKey: _defaultsFormKey,
      ),
      CatchFormStepSpec(
        title: context.l10n.hostsCreateClubScreenTitleEventSuccessDefaults,
        formKey: _eventSuccessFormKey,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    const stepCount = 4;
    _currentStep = widget.initialStep.clamp(0, stepCount - 1).toInt();
    _pageController = PageController(initialPage: _currentStep);
    _seedInitialMedia();

    final initialDraft = widget.initialDraft;
    if (initialDraft != null && !initialDraft.isEmpty) {
      _restoreFromDraft(initialDraft);
      _restoredDraft = true;
      return;
    }

    if (!widget.restoreSavedDraft) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_checkedDraft) {
        _checkedDraft = true;
        unawaited(_restoreSavedDraft());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _restoreSavedDraft() async {
    try {
      final draft = await CreateClubDraftController.loadDraftMutation.run(
        ref,
        (tx) => tx.get(createClubDraftControllerProvider.notifier).loadDraft(),
      );
      if (!mounted || draft == null || draft.isEmpty) {
        return;
      }
      final restoredDraft = draft;

      setState(() {
        _restoreFromDraft(restoredDraft);
        _restoredDraft = true;
      });

      showCatchSnackBar(
        context,
        context.l10n.hostsCreateClubScreenVisiblecopyRestoredYourClubDraft,
      );
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: context
                .l10n
                .hostsCreateClubScreenVisiblecopyCreateclubscreenRestoresaveddraftFailed,
          );
      return;
    }
  }

  void _seedInitialMedia() {
    _profileImage = widget.initialProfileImage;
    if (widget.initialPickedClubPhotos.isEmpty) return;
    _clubPhotos.addAll(
      widget.initialPickedClubPhotos.map(
        (photo) => _PickedClubPhotoDraft(_nextPickedClubPhotoId++, photo),
      ),
    );
    _clubPhotosTouched = true;
  }

  void _restoreFromDraft(ClubDraft draft) {
    if (draft.name != null) _nameController.text = draft.name!;
    if (draft.area != null) _areaController.text = draft.area!;
    if (draft.description != null) {
      _descriptionController.text = draft.description!;
    }
    if (draft.location != null) _selectedCity = draft.location;
    _organizerType = draft.organizerType;
    if (draft.instagramHandle != null) {
      _instagramController.text = draft.instagramHandle!;
    }
    if (draft.phoneNumber != null) _phoneController.text = draft.phoneNumber!;
    if (draft.email != null) _emailController.text = draft.email!;
    _hostDefaults = draft.hostDefaults;
  }

  Future<void> _pickClubPhotos() async {
    final remainingSlots = _maxClubPhotos - _clubPhotos.length;
    if (remainingSlots <= 0) return;
    final photos = await ref
        .read(createClubControllerProvider.notifier)
        .pickClubPhotos(limit: remainingSlots);
    if (!mounted || photos.isEmpty) {
      return;
    }
    setState(() {
      _clubPhotos.addAll(
        photos
            .take(remainingSlots)
            .map(
              (photo) => _PickedClubPhotoDraft(_nextPickedClubPhotoId++, photo),
            ),
      );
      _clubPhotosTouched = true;
    });
  }

  void _removeClubPhoto(int index) {
    if (index < 0 || index >= _clubPhotos.length) return;
    setState(() {
      _clubPhotos.removeAt(index);
      _clubPhotosTouched = true;
    });
  }

  void _reorderClubPhoto(int fromIndex, int toIndex) {
    if (fromIndex == toIndex ||
        fromIndex < 0 ||
        toIndex < 0 ||
        fromIndex >= _clubPhotos.length ||
        toIndex >= _clubPhotos.length) {
      return;
    }
    setState(() {
      final moved = _clubPhotos.removeAt(fromIndex);
      _clubPhotos.insert(toIndex, moved);
      _clubPhotosTouched = true;
    });
  }

  Future<void> _pickProfileImage() async {
    final image = await ref
        .read(createClubControllerProvider.notifier)
        .pickProfileImage();
    if (!mounted || image == null) {
      return;
    }
    setState(() {
      _profileImage = image;
    });
  }

  void _back() {
    if (_requestPending) return;
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handlePrimaryIntent(HostClubCreatePrimaryIntent intent) {
    if (_requestPending) return;
    final steps = _activeSteps;
    final formKey = formKeyForStep(steps, _currentStep);
    if (!(formKey?.currentState?.validate() ?? true)) {
      return;
    }

    switch (intent) {
      case HostClubCreatePrimaryIntent.nextStep:
        if (_currentStep < steps.length - 1) {
          _goToStep(_currentStep + 1);
          return;
        }
        _submit();
        return;
      case HostClubCreatePrimaryIntent.submit:
        _submit();
        return;
    }
  }

  Future<void> _handleSaveDraftIntent(
    HostClubCreateSaveDraftIntent intent,
  ) async {
    if (_requestPending) return;
    switch (intent) {
      case HostClubCreateSaveDraftIntent.saveDraft:
        await _saveDraft();
        return;
    }
  }

  Future<void> _handleDraftRestoreIntent(
    HostClubCreateDraftRestoreIntent intent,
  ) async {
    if (_requestPending) return;
    switch (intent) {
      case HostClubCreateDraftRestoreIntent.retry:
        await _restoreSavedDraft();
        return;
    }
  }

  void _goToStep(int step) {
    if (_requestPending) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: CatchMotion.pageStep,
      curve: CatchMotion.easeInOutCurve,
    );
  }

  void _handleRouteIntent(HostClubCreateRouteIntent intent) {
    if (_requestPending) return;
    switch (intent) {
      case HostClubCreateBackIntent():
        _back();
      case HostClubCreatePickProfileImageIntent():
        unawaited(_pickProfileImage());
      case HostClubCreatePickClubPhotosIntent():
        unawaited(_pickClubPhotos());
      case HostClubCreateRemoveClubPhotoIntent(:final index):
        _removeClubPhoto(index);
      case HostClubCreateReorderClubPhotoIntent(
        :final fromIndex,
        :final toIndex,
      ):
        _reorderClubPhoto(fromIndex, toIndex);
      case HostClubCreateCityChangedIntent(:final city):
        setState(() => _selectedCity = city?.effectiveMarketId);
      case HostClubCreateOrganizerTypeChangedIntent(:final organizerType):
        setState(() => _organizerType = organizerType);
      case HostClubCreateDefaultsChangedIntent(:final defaults):
        setState(() => _hostDefaults = defaults);
    }
  }

  Future<void> _saveDraft() async {
    if (_requestPending) return;
    final draftRequest = HostClubCreateDraftRequest.fromForm(
      name: _nameController.text,
      area: _areaController.text,
      description: _descriptionController.text,
      organizerType: _organizerType,
      selectedCity: _selectedCity,
      instagramHandle: _instagramController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      hostDefaults: _hostDefaults,
    );

    final savedDraft = await CreateClubDraftController.saveDraftMutation.run(
      ref,
      (tx) async => tx
          .get(createClubDraftControllerProvider.notifier)
          .saveDraft(draftRequest.toDraft(savedAt: DateTime.now())),
    );
    if (!mounted || savedDraft == null) return;

    showCatchSnackBar(
      context,
      _restoredDraft
          ? context.l10n.hostsCreateClubScreenVisiblecopyDraftUpdated
          : context.l10n.hostsCreateClubScreenVisiblecopyDraftSaved,
    );
    _restoredDraft = true;
  }

  void _submit() {
    if (_requestPending) return;
    final failureReason = context
        .l10n
        .hostsCreateClubScreenVisiblecopyCreateclubscreenSubmitFailed;
    unawaited(
      CreateClubController.submitMutation
          .run(ref, (transaction) async {
            final request = HostClubCreateSubmitRequest.fromForm(
              name: _nameController.text,
              selectedCity: _selectedCity,
              area: _areaController.text,
              description: _descriptionController.text,
              organizerType: _organizerType,
              clubPhotoInputs: _clubPhotoInputsForSubmit,
              profileImage: _profileImage,
              instagramHandle: _instagramController.text,
              phoneNumber: _phoneController.text,
              email: _emailController.text,
              hostDefaults: _hostDefaults,
            );
            await transaction
                .get(createClubControllerProvider.notifier)
                .submit(
                  name: request.name,
                  location: request.location,
                  area: request.area,
                  description: request.description,
                  organizerType: request.organizerType,
                  clubPhotoInputs: request.clubPhotoInputs,
                  profileImage: request.profileImage?.image,
                  instagramHandle: request.instagramHandle,
                  phoneNumber: request.phoneNumber,
                  email: request.email,
                  hostDefaults: request.hostDefaults,
                );

            await transaction
                .get(createClubDraftControllerProvider.notifier)
                .deleteDraft();
          })
          .catchError((error, stackTrace) {
            ref
                .read(errorLoggerProvider)
                .logError(error, stackTrace, reason: failureReason);
          }),
    );
  }

  List<OrderedPhotoPreview> get _clubPhotoPreviews => [
    for (final photo in _clubPhotos) photo.preview,
  ];

  List<ClubPhotoInput>? get _clubPhotoInputsForSubmit {
    if (!_clubPhotosTouched) return null;
    return [for (final photo in _clubPhotos) photo.input];
  }

  bool get _requestPending =>
      ref.read(CreateClubController.submitMutation).isPending ||
      ref.read(CreateClubDraftController.saveDraftMutation).isPending ||
      ref.read(CreateClubDraftController.loadDraftMutation).isPending;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activeSteps = _activeSteps;
    final submitMutation = ref.watch(CreateClubController.submitMutation);
    final saveDraftMutation = ref.watch(
      CreateClubDraftController.saveDraftMutation,
    );
    final loadDraftMutation = ref.watch(
      CreateClubDraftController.loadDraftMutation,
    );
    final mutationError = submitMutation.hasError
        ? mutationErrorMessage(submitMutation, l10n: context.l10n)
        : saveDraftMutation.hasError
        ? mutationErrorMessage(saveDraftMutation, l10n: context.l10n)
        : null;
    final draftLoadError = loadDraftMutation.hasError
        ? (loadDraftMutation as MutationError).error
        : null;
    final screenState = HostClubCreateState.resolve(
      currentStep: _currentStep,
      activeSteps: activeSteps,
      submitPending: submitMutation.isPending,
      saveDraftPending: saveDraftMutation.isPending,
      draftLoadPending: loadDraftMutation.isPending,
      draftLoadError: draftLoadError,
      draftRestoreEnabled: widget.restoreSavedDraft && !_restoredDraft,
      mutationError: mutationError,
      clubPhotoPreviews: _clubPhotoPreviews,
      profileImage: _profileImage,
      formAutovalidateMode: widget.formAutovalidateMode,
      name: _nameController.text,
      selectedCity: _selectedCity,
      area: _areaController.text,
      description: _descriptionController.text,
    );

    ref.listen(CreateClubController.submitMutation, (previous, current) {
      final submitOutcome = HostClubSubmitOutcomeState.fromTransition(
        wasPending: previous?.isPending == true,
        isSuccess: current.isSuccess,
      );
      if (submitOutcome.shouldCloseRoute) {
        Navigator.of(context).pop();
      }
    });

    return PopScope(
      canPop: screenState.requestControlsEnabled,
      child: Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Column(
            children: [
              CreateClubStepHeader(
                title: screenState.title,
                subtitle: screenState.subtitle,
                currentStep: screenState.currentStep,
                totalSteps: screenState.totalSteps,
                showBack: screenState.requestControlsEnabled,
                onBack: screenState.requestControlsEnabled
                    ? () => _handleRouteIntent(const HostClubCreateBackIntent())
                    : null,
              ),
              gapH4,
              Expanded(
                child: IgnorePointer(
                  ignoring: !screenState.requestControlsEnabled,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ClubBasicsStep(
                        formKey: _basicsFormKey,
                        autovalidateMode: widget.formAutovalidateMode,
                        nameController: _nameController,
                        selectedOrganizerType: _organizerType,
                        onOrganizerTypeChanged: (organizerType) =>
                            _handleRouteIntent(
                              HostClubCreateOrganizerTypeChangedIntent(
                                organizerType,
                              ),
                            ),
                        selectedCity: screenState.fields.selectedCity,
                        onCityChanged: (city) => _handleRouteIntent(
                          HostClubCreateCityChangedIntent(city),
                        ),
                        areaController: _areaController,
                        detailsEnabled: screenState.fields.detailsEnabled,
                        clubPhotoPreviews: screenState.media.clubPhotoPreviews,
                        existingImageUrl:
                            screenState.media.existingCoverImageUrl,
                        profileImageBytes: screenState.media.profileImageBytes,
                        existingProfileImageUrl:
                            screenState.media.existingProfileImageUrl,
                        onPickClubPhotos: screenState.media.enabled
                            ? () => _handleRouteIntent(
                                const HostClubCreatePickClubPhotosIntent(),
                              )
                            : null,
                        onRemoveClubPhoto: screenState.media.enabled
                            ? (index) => _handleRouteIntent(
                                HostClubCreateRemoveClubPhotoIntent(index),
                              )
                            : null,
                        onReorderClubPhoto: screenState.media.enabled
                            ? (fromIndex, toIndex) => _handleRouteIntent(
                                HostClubCreateReorderClubPhotoIntent(
                                  fromIndex: fromIndex,
                                  toIndex: toIndex,
                                ),
                              )
                            : null,
                        onPickProfileImage: screenState.media.enabled
                            ? () => _handleRouteIntent(
                                const HostClubCreatePickProfileImageIntent(),
                              )
                            : null,
                      ),
                      ClubDetailsStep(
                        formKey: _detailsFormKey,
                        descriptionController: _descriptionController,
                        instagramController: _instagramController,
                        phoneController: _phoneController,
                        emailController: _emailController,
                      ),
                      ClubHostDefaultsStep(
                        formKey: _defaultsFormKey,
                        defaults: _hostDefaults,
                        currencyCode: screenState.fields.currencyCode,
                        onChanged: (defaults) => _handleRouteIntent(
                          HostClubCreateDefaultsChangedIntent(defaults),
                        ),
                      ),
                      ClubEventSuccessDefaultsStep(
                        formKey: _eventSuccessFormKey,
                        defaults: _hostDefaults,
                        onChanged: (defaults) => _handleRouteIntent(
                          HostClubCreateDefaultsChangedIntent(defaults),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (screenState.mutationError != null)
                CatchErrorBanner(message: screenState.mutationError!),
              if (screenState.draftRestore.hasError)
                CatchErrorBanner.fromError(
                  screenState.draftRestore.error!,
                  context: AppErrorContext.club,
                  onRetry:
                      screenState.draftRestore.retryIntent == null ||
                          screenState.draftRestore.isLoading
                      ? null
                      : () => unawaited(
                          _handleDraftRestoreIntent(
                            screenState.draftRestore.retryIntent!,
                          ),
                        ),
                ),
              StepperFooter(
                isLastStep: screenState.footer.isLastStep,
                isLoading: screenState.footer.isLoading,
                primaryLabel: screenState.footer.primaryLabel,
                onPrimary: () =>
                    _handlePrimaryIntent(screenState.footer.primaryIntent),
                onSaveDraft: screenState.footer.saveDraftIntent == null
                    ? null
                    : () => _handleSaveDraftIntent(
                        screenState.footer.saveDraftIntent!,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

sealed class _ClubPhotoDraft {
  const _ClubPhotoDraft();

  OrderedPhotoPreview get preview;
  ClubPhotoInput get input;
}

final class _PickedClubPhotoDraft extends _ClubPhotoDraft {
  const _PickedClubPhotoDraft(this.id, this.photo);

  final int id;
  final PickedClubPhoto photo;

  @override
  OrderedPhotoPreview get preview =>
      OrderedPhotoPreview(id: 'picked_$id', bytes: photo.bytes);

  @override
  ClubPhotoInput get input => NewClubPhotoInput(photo.image);
}
