import 'dart:async';
import 'dart:typed_data';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_draft.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_basics_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/stepper_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxClubPhotos = 6;

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({
    super.key,
    this.initialClub,
    this.initialDraft,
    this.initialStep = 0,
    this.restoreSavedDraft = true,
    this.formAutovalidateMode = AutovalidateMode.disabled,
    this.initialPickedClubPhotos = const <PickedClubPhoto>[],
    this.initialProfileImage,
  });

  final Club? initialClub;
  final ClubDraft? initialDraft;
  final int initialStep;
  final bool restoreSavedDraft;
  final AutovalidateMode formAutovalidateMode;
  final List<PickedClubPhoto> initialPickedClubPhotos;
  final PickedClubProfileImage? initialProfileImage;

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

enum HostClubCreatePrimaryIntent { nextStep, submit }

enum HostClubCreateSaveDraftIntent { saveDraft }

@immutable
class HostClubCreateFooterState {
  const HostClubCreateFooterState({
    required this.isLastStep,
    required this.isLoading,
    required this.primaryEnabled,
    required this.primaryLabel,
    required this.lastStepLabel,
    required this.primaryIntent,
    required this.saveDraftIntent,
  });

  final bool isLastStep;
  final bool isLoading;
  final bool primaryEnabled;
  final String primaryLabel;
  final String lastStepLabel;
  final HostClubCreatePrimaryIntent primaryIntent;
  final HostClubCreateSaveDraftIntent? saveDraftIntent;

  bool get canSaveDraft => saveDraftIntent != null;
}

@immutable
class HostClubEditScaffoldState {
  const HostClubEditScaffoldState({
    required this.mediaEnabled,
    required this.cityPickerEnabled,
    required this.footer,
  });

  final bool mediaEnabled;
  final bool cityPickerEnabled;
  final HostClubCreateFooterState footer;
}

@immutable
class HostClubCreateMediaState {
  const HostClubCreateMediaState({
    required this.enabled,
    required this.clubPhotoPreviews,
    required this.existingCoverImageUrl,
    required this.profileImageBytes,
    required this.existingProfileImageUrl,
  });

  factory HostClubCreateMediaState.resolve({
    required bool enabled,
    required Club? initialClub,
    required List<OrderedPhotoPreview> clubPhotoPreviews,
    required PickedClubProfileImage? profileImage,
  }) {
    return HostClubCreateMediaState(
      enabled: enabled,
      clubPhotoPreviews: List.unmodifiable(clubPhotoPreviews),
      existingCoverImageUrl: clubPhotoPreviews.isEmpty
          ? initialClub?.imageUrl
          : null,
      profileImageBytes: profileImage?.bytes,
      existingProfileImageUrl: initialClub?.profileImageUrl,
    );
  }

  final bool enabled;
  final List<OrderedPhotoPreview> clubPhotoPreviews;
  final String? existingCoverImageUrl;
  final Uint8List? profileImageBytes;
  final String? existingProfileImageUrl;
}

@immutable
class HostClubCreateFieldDisplayState {
  const HostClubCreateFieldDisplayState({
    required this.detailsEnabled,
    required this.selectedCity,
    required this.rawCityName,
    required this.currencyCode,
  });

  factory HostClubCreateFieldDisplayState.resolve({
    required bool mediaOnly,
    required String? selectedCityName,
  }) {
    return HostClubCreateFieldDisplayState(
      detailsEnabled: !mediaOnly,
      selectedCity: cityOptionByName(selectedCityName),
      rawCityName: selectedCityName,
      currencyCode: currencyCodeForCityName(selectedCityName),
    );
  }

  final bool detailsEnabled;
  final CityOption? selectedCity;
  final String? rawCityName;
  final String currencyCode;
}

@immutable
class HostClubEditValidationState {
  const HostClubEditValidationState({
    required this.shouldShowErrors,
    required this.autovalidateMode,
    required this.identityHasError,
  });

  factory HostClubEditValidationState.resolve({
    required bool editSubmitAttempted,
    required AutovalidateMode formAutovalidateMode,
    required String name,
    required String? selectedCity,
    required String area,
    required String description,
  }) {
    final shouldShowErrors =
        editSubmitAttempted ||
        formAutovalidateMode != AutovalidateMode.disabled;
    return HostClubEditValidationState(
      shouldShowErrors: shouldShowErrors,
      autovalidateMode: editSubmitAttempted
          ? AutovalidateMode.always
          : formAutovalidateMode,
      identityHasError:
          shouldShowErrors &&
          (name.trim().isEmpty ||
              selectedCity == null ||
              selectedCity.trim().isEmpty ||
              area.trim().isEmpty ||
              description.trim().isEmpty),
    );
  }

  final bool shouldShowErrors;
  final AutovalidateMode autovalidateMode;
  final bool identityHasError;
}

@immutable
class HostClubCreateDraftRequest {
  const HostClubCreateDraftRequest({
    required this.name,
    required this.area,
    required this.description,
    required this.location,
    required this.instagramHandle,
    required this.phoneNumber,
    required this.email,
    required this.hostDefaults,
  });

  factory HostClubCreateDraftRequest.fromForm({
    required String name,
    required String area,
    required String description,
    required String? selectedCity,
    required String instagramHandle,
    required String phoneNumber,
    required String email,
    required ClubHostDefaults hostDefaults,
  }) {
    return HostClubCreateDraftRequest(
      name: _trimmedTextOrNull(name),
      area: _trimmedTextOrNull(area),
      description: _trimmedTextOrNull(description),
      location: selectedCity,
      instagramHandle: _trimmedTextOrNull(instagramHandle),
      phoneNumber: _trimmedTextOrNull(phoneNumber),
      email: _trimmedTextOrNull(email),
      hostDefaults: hostDefaults,
    );
  }

  final String? name;
  final String? area;
  final String? description;
  final String? location;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
  final ClubHostDefaults hostDefaults;

  ClubDraft toDraft({required DateTime savedAt}) {
    return ClubDraft(
      savedAt: savedAt,
      name: name,
      area: area,
      description: description,
      location: location,
      instagramHandle: instagramHandle,
      phoneNumber: phoneNumber,
      email: email,
      hostDefaults: hostDefaults,
    );
  }
}

@immutable
class HostClubCreateSubmitRequest {
  const HostClubCreateSubmitRequest({
    required this.name,
    required this.location,
    required this.area,
    required this.description,
    required this.existingClub,
    required this.clubPhotoInputs,
    required this.profileImage,
    required this.instagramHandle,
    required this.phoneNumber,
    required this.email,
    required this.hostDefaults,
  });

  factory HostClubCreateSubmitRequest.fromForm({
    required String name,
    required String? selectedCity,
    required String area,
    required String description,
    required Club? existingClub,
    required List<ClubPhotoInput>? clubPhotoInputs,
    required PickedClubProfileImage? profileImage,
    required String instagramHandle,
    required String phoneNumber,
    required String email,
    required ClubHostDefaults hostDefaults,
  }) {
    final location = selectedCity?.trim();
    if (location == null || location.isEmpty) {
      throw StateError('Missing selected city');
    }
    return HostClubCreateSubmitRequest(
      name: name.trim(),
      location: location,
      area: area.trim(),
      description: description.trim(),
      existingClub: existingClub,
      clubPhotoInputs: clubPhotoInputs,
      profileImage: profileImage,
      instagramHandle: _trimmedTextOrNull(instagramHandle),
      phoneNumber: _trimmedTextOrNull(phoneNumber),
      email: _trimmedTextOrNull(email),
      hostDefaults: hostDefaults,
    );
  }

  final String name;
  final String location;
  final String area;
  final String description;
  final Club? existingClub;
  final List<ClubPhotoInput>? clubPhotoInputs;
  final PickedClubProfileImage? profileImage;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
  final ClubHostDefaults hostDefaults;
}

String? _trimmedTextOrNull(String text) {
  final trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}

@immutable
class HostClubCreateState {
  const HostClubCreateState({
    required this.isEditing,
    required this.mediaOnly,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.showEditScaffold,
    required this.isLastStep,
    required this.canPickMedia,
    required this.footer,
    required this.editScaffold,
    required this.media,
    required this.fields,
    required this.editValidation,
    required this.mutationError,
  });

  final bool isEditing;
  final bool mediaOnly;
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final bool showEditScaffold;
  final bool isLastStep;
  final bool canPickMedia;
  final HostClubCreateFooterState footer;
  final HostClubEditScaffoldState? editScaffold;
  final HostClubCreateMediaState media;
  final HostClubCreateFieldDisplayState fields;
  final HostClubEditValidationState editValidation;
  final String? mutationError;

  bool get canSaveDraft => footer.canSaveDraft;
  String get lastStepLabel => footer.lastStepLabel;
  bool get isLoading => footer.isLoading;

  factory HostClubCreateState.resolve({
    required bool isEditing,
    required bool mediaOnly,
    required int currentStep,
    required List<CatchFormStepSpec> activeSteps,
    required Club? initialClub,
    required bool submitPending,
    required bool saveDraftPending,
    required String? mutationError,
    List<OrderedPhotoPreview> clubPhotoPreviews = const [],
    PickedClubProfileImage? profileImage,
    bool editSubmitAttempted = false,
    AutovalidateMode formAutovalidateMode = AutovalidateMode.disabled,
    String name = '',
    String? selectedCity,
    String area = '',
    String description = '',
  }) {
    final totalSteps = activeSteps.length;
    final clampedStep = totalSteps == 0
        ? 0
        : currentStep.clamp(0, totalSteps - 1).toInt();
    final showEditScaffold = isEditing && !mediaOnly;
    final isLastStep =
        showEditScaffold || totalSteps == 0 || clampedStep == totalSteps - 1;
    final isLoading = showEditScaffold
        ? submitPending
        : submitPending || saveDraftPending;
    final canPickMedia = !submitPending;
    final lastStepLabel = mediaOnly
        ? 'Save photos'
        : isEditing
        ? 'Save changes'
        : 'Create club';
    final footer = HostClubCreateFooterState(
      isLastStep: isLastStep,
      isLoading: isLoading,
      primaryEnabled: !isLoading,
      primaryLabel: isLastStep ? lastStepLabel : 'Next',
      lastStepLabel: lastStepLabel,
      primaryIntent: isLastStep
          ? HostClubCreatePrimaryIntent.submit
          : HostClubCreatePrimaryIntent.nextStep,
      saveDraftIntent: !isEditing && !mediaOnly
          ? HostClubCreateSaveDraftIntent.saveDraft
          : null,
    );
    final media = HostClubCreateMediaState.resolve(
      enabled: canPickMedia,
      initialClub: initialClub,
      clubPhotoPreviews: clubPhotoPreviews,
      profileImage: profileImage,
    );
    final fields = HostClubCreateFieldDisplayState.resolve(
      mediaOnly: mediaOnly,
      selectedCityName: selectedCity,
    );
    final editValidation = HostClubEditValidationState.resolve(
      editSubmitAttempted: editSubmitAttempted,
      formAutovalidateMode: formAutovalidateMode,
      name: name,
      selectedCity: selectedCity,
      area: area,
      description: description,
    );
    return HostClubCreateState(
      isEditing: isEditing,
      mediaOnly: mediaOnly,
      currentStep: clampedStep,
      totalSteps: totalSteps,
      title: totalSteps == 0 ? '' : formTitleForStep(activeSteps, clampedStep),
      subtitle: isEditing ? initialClub!.name : null,
      showEditScaffold: showEditScaffold,
      isLastStep: isLastStep,
      canPickMedia: canPickMedia,
      footer: footer,
      editScaffold: showEditScaffold
          ? HostClubEditScaffoldState(
              mediaEnabled: canPickMedia,
              cityPickerEnabled: canPickMedia,
              footer: footer,
            )
          : null,
      media: media,
      fields: fields,
      editValidation: editValidation,
      mutationError: mutationError,
    );
  }
}

@immutable
class HostClubSubmitOutcomeState {
  const HostClubSubmitOutcomeState({required this.shouldCloseRoute});

  final bool shouldCloseRoute;

  factory HostClubSubmitOutcomeState.fromTransition({
    required bool wasPending,
    required bool isSuccess,
  }) {
    return HostClubSubmitOutcomeState(
      shouldCloseRoute: wasPending && isSuccess,
    );
  }
}

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
  final _clubPhotos = <_ClubPhotoDraft>[];
  var _clubPhotosTouched = false;
  var _nextPickedClubPhotoId = 0;
  PickedClubProfileImage? _profileImage;
  bool _checkedDraft = false;
  bool _restoredDraft = false;
  bool _editSubmitAttempted = false;
  ClubHostDefaults _hostDefaults = const ClubHostDefaults();

  bool get _isEditing => widget.initialClub != null;
  HostClubEditValidationState get _editValidationState =>
      HostClubEditValidationState.resolve(
        editSubmitAttempted: _editSubmitAttempted,
        formAutovalidateMode: widget.formAutovalidateMode,
        name: _nameController.text,
        selectedCity: _selectedCity,
        area: _areaController.text,
        description: _descriptionController.text,
      );

  List<CatchFormStepSpec> get _activeSteps {
    final uid = ref.read(uidProvider).asData?.value;
    if (_isMediaOnlyForUid(uid)) {
      return [CatchFormStepSpec(title: 'Club photos', formKey: _basicsFormKey)];
    }
    return [
      CatchFormStepSpec(title: 'Club basics', formKey: _basicsFormKey),
      CatchFormStepSpec(title: 'Club details', formKey: _detailsFormKey),
      CatchFormStepSpec(title: 'Host defaults', formKey: _defaultsFormKey),
      CatchFormStepSpec(
        title: 'Event success defaults',
        formKey: _eventSuccessFormKey,
      ),
    ];
  }

  bool _isMediaOnlyForUid(String? uid) {
    final club = widget.initialClub;
    return club != null && club.isHostedBy(uid) && !club.isOwnedBy(uid);
  }

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, _activeSteps.length - 1).toInt();
    _pageController = PageController(initialPage: _currentStep);
    _seedInitialMedia();

    final club = widget.initialClub;
    if (club != null) {
      _nameController.text = club.name;
      _areaController.text = club.area;
      _descriptionController.text = club.description;
      _selectedCity = club.location;
      _instagramController.text = club.instagramHandle ?? '';
      _phoneController.text = club.phoneNumber ?? '';
      _emailController.text = club.email ?? '';
      _hostDefaults = club.hostDefaults;
      if (_clubPhotos.isEmpty) {
        _clubPhotos.addAll(
          ([...club.clubPhotos]
                ..sort((a, b) => a.position.compareTo(b.position)))
              .map(_ExistingClubPhotoDraft.new),
        );
      }
      return;
    }

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
    final ClubDraft? draft;
    try {
      draft = await ref
          .read(createClubDraftControllerProvider.notifier)
          .loadDraft();
    } catch (_) {
      return;
    }
    if (!mounted || draft == null || draft.isEmpty) {
      return;
    }
    final restoredDraft = draft;

    setState(() {
      _restoreFromDraft(restoredDraft);
      _restoredDraft = true;
    });

    showCatchSnackBar(context, 'Restored your club draft');
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

  Future<CityOption?> _pickCityForEdit() async {
    final picked = await showModalBottomSheet<CityOption>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.6;
        return CatchBottomSheetScaffold(
          title: 'City',
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: CatchSection.contained(
                children: [
                  for (final city in defaultCityOptions.where(
                    (city) => city.hostCreatable,
                  ))
                    CatchField.nav(
                      title: city.label,
                      body: city.countryIsoCode,
                      icon: CatchIcons.locationCityOutlined,
                      valid: city.effectiveMarketId == _selectedCity,
                      showChevron: true,
                      onTap: () => Navigator.of(context).pop(city),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (!mounted || picked == null) return null;
    setState(() => _selectedCity = picked.effectiveMarketId);
    return picked;
  }

  void _back() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handlePrimaryIntent(HostClubCreatePrimaryIntent intent) {
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
    switch (intent) {
      case HostClubCreateSaveDraftIntent.saveDraft:
        await _saveDraft();
        return;
    }
  }

  void _submitEdit() {
    setState(() => _editSubmitAttempted = true);
    final basicsValid = _basicsFormKey.currentState?.validate() ?? true;
    final defaultsValid = _defaultsFormKey.currentState?.validate() ?? true;
    final eventSuccessValid =
        _eventSuccessFormKey.currentState?.validate() ?? true;
    if (!basicsValid || !defaultsValid || !eventSuccessValid) return;
    _submit();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: CatchMotion.pageStep,
      curve: CatchMotion.easeInOutCurve,
    );
  }

  void _handleEditIdentityChanged(String _) {
    if (_editValidationState.shouldShowErrors) setState(() {});
  }

  Future<void> _saveDraft() async {
    if (_isEditing) return;

    final draftRequest = HostClubCreateDraftRequest.fromForm(
      name: _nameController.text,
      area: _areaController.text,
      description: _descriptionController.text,
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
      _restoredDraft ? 'Draft updated' : 'Draft saved',
    );
    _restoredDraft = true;
  }

  void _submit() {
    unawaited(
      CreateClubController.submitMutation
          .run(ref, (transaction) async {
            final request = HostClubCreateSubmitRequest.fromForm(
              name: _nameController.text,
              selectedCity: _selectedCity,
              area: _areaController.text,
              description: _descriptionController.text,
              existingClub: widget.initialClub,
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
                  existingClub: request.existingClub,
                  clubPhotoInputs: request.clubPhotoInputs,
                  profileImage: request.profileImage?.image,
                  instagramHandle: request.instagramHandle,
                  phoneNumber: request.phoneNumber,
                  email: request.email,
                  hostDefaults: request.hostDefaults,
                );

            if (!_isEditing) {
              await transaction
                  .get(createClubDraftControllerProvider.notifier)
                  .deleteDraft();
            }
          })
          .catchError((error, stackTrace) {
            ref
                .read(errorLoggerProvider)
                .logError(
                  error,
                  stackTrace,
                  reason: 'CreateClubScreen._submit failed',
                );
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

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uidAsync = ref.watch(uidProvider);
    if (_isEditing && uidAsync.isLoading) {
      return const CatchStartupLoadingScreen();
    }
    if (_isEditing && uidAsync.hasError) {
      return CatchErrorScaffold.fromError(
        uidAsync.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }
    final uid = uidAsync.asData?.value;
    final mediaOnly = _isMediaOnlyForUid(uid);
    final activeSteps = _activeSteps;
    final submitMutation = ref.watch(CreateClubController.submitMutation);
    final saveDraftMutation = ref.watch(
      CreateClubDraftController.saveDraftMutation,
    );
    final mutationError = submitMutation.hasError
        ? mutationErrorMessage(submitMutation)
        : saveDraftMutation.hasError
        ? mutationErrorMessage(saveDraftMutation)
        : null;
    final screenState = HostClubCreateState.resolve(
      isEditing: _isEditing,
      mediaOnly: mediaOnly,
      currentStep: _currentStep,
      activeSteps: activeSteps,
      initialClub: widget.initialClub,
      submitPending: submitMutation.isPending,
      saveDraftPending: saveDraftMutation.isPending,
      mutationError: mutationError,
      clubPhotoPreviews: _clubPhotoPreviews,
      profileImage: _profileImage,
      editSubmitAttempted: _editSubmitAttempted,
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

    final editScaffold = screenState.editScaffold;
    if (editScaffold != null) {
      return HostClubEditScaffold(
        scaffoldState: editScaffold,
        media: screenState.media,
        mutationError: screenState.mutationError,
        basicsFormKey: _basicsFormKey,
        defaultsFormKey: _defaultsFormKey,
        eventSuccessFormKey: _eventSuccessFormKey,
        autovalidateMode: screenState.editValidation.autovalidateMode,
        editIdentityHasError: screenState.editValidation.identityHasError,
        nameController: _nameController,
        selectedCity: screenState.fields.selectedCity,
        rawCityName: screenState.fields.rawCityName,
        areaController: _areaController,
        descriptionController: _descriptionController,
        instagramController: _instagramController,
        phoneController: _phoneController,
        emailController: _emailController,
        hostDefaults: _hostDefaults,
        currencyCode: screenState.fields.currencyCode,
        onBack: _back,
        onPickProfileImage: _pickProfileImage,
        onPickClubPhotos: _pickClubPhotos,
        onRemoveClubPhoto: _removeClubPhoto,
        onReorderClubPhoto: _reorderClubPhoto,
        onPickCity: _pickCityForEdit,
        onIdentityChanged: _handleEditIdentityChanged,
        onDefaultsChanged: (defaults) =>
            setState(() => _hostDefaults = defaults),
        onSave: _submitEdit,
      );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            CatchStepHeader(
              title: screenState.title,
              subtitle: screenState.subtitle,
              step: screenState.currentStep + 1,
              total: screenState.totalSteps,
              onBack: _back,
            ),
            gapH4,
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ClubBasicsStep(
                    formKey: _basicsFormKey,
                    autovalidateMode: widget.formAutovalidateMode,
                    nameController: _nameController,
                    selectedCity: screenState.fields.selectedCity,
                    onCityChanged: (city) => setState(() {
                      _selectedCity = city?.effectiveMarketId;
                    }),
                    areaController: _areaController,
                    detailsEnabled: screenState.fields.detailsEnabled,
                    clubPhotoPreviews: screenState.media.clubPhotoPreviews,
                    existingImageUrl: screenState.media.existingCoverImageUrl,
                    profileImageBytes: screenState.media.profileImageBytes,
                    existingProfileImageUrl:
                        screenState.media.existingProfileImageUrl,
                    onPickClubPhotos: screenState.media.enabled
                        ? _pickClubPhotos
                        : null,
                    onRemoveClubPhoto: screenState.media.enabled
                        ? _removeClubPhoto
                        : null,
                    onReorderClubPhoto: screenState.media.enabled
                        ? _reorderClubPhoto
                        : null,
                    onPickProfileImage: screenState.media.enabled
                        ? _pickProfileImage
                        : null,
                  ),
                  if (!screenState.mediaOnly) ...[
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
                      onChanged: (defaults) =>
                          setState(() => _hostDefaults = defaults),
                    ),
                    ClubEventSuccessDefaultsStep(
                      formKey: _eventSuccessFormKey,
                      defaults: _hostDefaults,
                      onChanged: (defaults) =>
                          setState(() => _hostDefaults = defaults),
                    ),
                  ],
                ],
              ),
            ),
            if (screenState.mutationError != null)
              CatchErrorBanner(message: screenState.mutationError!),
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
    );
  }
}

class HostClubEditScaffold extends StatelessWidget {
  const HostClubEditScaffold({
    super.key,
    required this.scaffoldState,
    required this.media,
    required this.mutationError,
    required this.basicsFormKey,
    required this.defaultsFormKey,
    required this.eventSuccessFormKey,
    required this.autovalidateMode,
    required this.editIdentityHasError,
    required this.nameController,
    required this.selectedCity,
    required this.rawCityName,
    required this.areaController,
    required this.descriptionController,
    required this.instagramController,
    required this.phoneController,
    required this.emailController,
    required this.hostDefaults,
    required this.currencyCode,
    required this.onBack,
    required this.onPickProfileImage,
    required this.onPickClubPhotos,
    required this.onRemoveClubPhoto,
    required this.onReorderClubPhoto,
    required this.onPickCity,
    required this.onIdentityChanged,
    required this.onDefaultsChanged,
    required this.onSave,
  });

  final HostClubEditScaffoldState scaffoldState;
  final HostClubCreateMediaState media;
  final String? mutationError;
  final GlobalKey<FormState> basicsFormKey;
  final GlobalKey<FormState> defaultsFormKey;
  final GlobalKey<FormState> eventSuccessFormKey;
  final AutovalidateMode autovalidateMode;
  final bool editIdentityHasError;
  final TextEditingController nameController;
  final CityOption? selectedCity;
  final String? rawCityName;
  final TextEditingController areaController;
  final TextEditingController descriptionController;
  final TextEditingController instagramController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final ClubHostDefaults hostDefaults;
  final String currencyCode;
  final VoidCallback onBack;
  final VoidCallback onPickProfileImage;
  final VoidCallback onPickClubPhotos;
  final ValueChanged<int> onRemoveClubPhoto;
  final void Function(int fromIndex, int toIndex) onReorderClubPhoto;
  final Future<CityOption?> Function() onPickCity;
  final ValueChanged<String> onIdentityChanged;
  final ValueChanged<ClubHostDefaults> onDefaultsChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: 'Edit club',
        leadingType: CatchTopBarLeading.back,
        onBack: onBack,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: CatchInsets.formEditBodyRelaxed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CreateClubProfileImagePicker(
                    imageBytes: media.profileImageBytes,
                    existingImageUrl: media.existingProfileImageUrl,
                    onTap: scaffoldState.mediaEnabled
                        ? onPickProfileImage
                        : null,
                    variant: CreateClubProfileImagePickerVariant.editLogo,
                  ),
                  gapH20,
                  CreateClubPhotosPicker(
                    photos: media.clubPhotoPreviews,
                    existingImageUrl: media.existingCoverImageUrl,
                    onAddPhotos: scaffoldState.mediaEnabled
                        ? onPickClubPhotos
                        : null,
                    onRemovePhoto: scaffoldState.mediaEnabled
                        ? onRemoveClubPhoto
                        : null,
                    onReorderPhoto: scaffoldState.mediaEnabled
                        ? onReorderClubPhoto
                        : null,
                    variant: CreateClubPhotosPickerVariant.editStrip,
                  ),
                  Form(
                    key: basicsFormKey,
                    autovalidateMode: autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HostClubEditSection(
                          label: 'Identity',
                          child: CatchSection.contained(
                            hasError: editIdentityHasError,
                            children: [
                              CatchField.input(
                                title: 'Club name',
                                controller: nameController,
                                onChanged: onIdentityChanged,
                                icon: CatchIcons.groupOutlined,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a club name';
                                  }
                                  return null;
                                },
                              ),
                              HostClubEditCityField(
                                city: selectedCity,
                                rawCityName: rawCityName,
                                enabled: scaffoldState.cityPickerEnabled,
                                onPickCity: onPickCity,
                              ),
                              CatchField.input(
                                title: 'Area / neighbourhood',
                                controller: areaController,
                                onChanged: onIdentityChanged,
                                icon: CatchIcons.locationOnOutlined,
                                placeholder: 'e.g. Bandra, Koramangala',
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an area';
                                  }
                                  return null;
                                },
                              ),
                              CatchField.input(
                                title: 'Description',
                                controller: descriptionController,
                                onChanged: onIdentityChanged,
                                icon: CatchIcons.editNoteOutlined,
                                maxLines: 4,
                                minLines: 2,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.newline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please add a description';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        HostClubEditSection(
                          label: 'Contact',
                          child: CatchSection.contained(
                            children: [
                              CatchField.input(
                                title: 'Instagram',
                                controller: instagramController,
                                icon: CatchIcons.alternateEmailOutlined,
                                leadingUnit: '@',
                                textInputAction: TextInputAction.next,
                              ),
                              CatchField.input(
                                title: 'Phone',
                                controller: phoneController,
                                icon: CatchIcons.phoneOutlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                              ),
                              CatchField.input(
                                title: 'Email',
                                controller: emailController,
                                icon: CatchIcons.emailOutlined,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  HostClubEditSection(
                    label: 'Event defaults',
                    subtitle: 'Prefill every new event this club creates.',
                    child: Column(
                      children: [
                        ClubHostDefaultsStep(
                          formKey: defaultsFormKey,
                          defaults: hostDefaults,
                          currencyCode: currencyCode,
                          onChanged: onDefaultsChanged,
                          scrollable: false,
                          padding: EdgeInsets.zero,
                        ),
                        gapH16,
                        ClubEventSuccessDefaultsStep(
                          formKey: eventSuccessFormKey,
                          defaults: hostDefaults,
                          onChanged: onDefaultsChanged,
                          scrollable: false,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (mutationError != null) CatchErrorBanner(message: mutationError!),
          HostClubEditFooter(footer: scaffoldState.footer, onSave: onSave),
        ],
      ),
    );
  }
}

class HostClubEditSection extends StatelessWidget {
  const HostClubEditSection({
    super.key,
    required this.label,
    required this.child,
    this.subtitle,
  });

  final String label;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: CatchInsets.formSectionTop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: t.line, height: 1, thickness: 1),
          gapH18,
          Text(label, style: CatchTextStyles.kicker(context, color: t.ink2)),
          if (subtitle != null) ...[
            gapH4,
            Text(
              subtitle!,
              style: CatchTextStyles.supporting(context, color: t.ink3),
            ),
          ],
          gapH10,
          child,
        ],
      ),
    );
  }
}

class HostClubEditCityField extends StatelessWidget {
  const HostClubEditCityField({
    super.key,
    required this.city,
    required this.rawCityName,
    required this.enabled,
    required this.onPickCity,
  });

  final CityOption? city;
  final String? rawCityName;
  final bool enabled;
  final Future<CityOption?> Function() onPickCity;

  @override
  Widget build(BuildContext context) {
    return FormField<CityOption>(
      initialValue: city,
      validator: (_) {
        final raw = rawCityName;
        final hasCity = city != null || (raw != null && raw.isNotEmpty);
        return hasCity ? null : 'Please select a city';
      },
      builder: (field) {
        final raw = rawCityName;
        final value = city?.label ?? (raw == null || raw.isEmpty ? '' : raw);
        return CatchField.nav(
          title: 'City',
          body: value,
          placeholder: 'Select city',
          icon: CatchIcons.locationCityOutlined,
          showChevron: enabled,
          error: field.errorText,
          onTap: enabled
              ? () async {
                  final picked = await onPickCity();
                  if (picked != null) field.didChange(picked);
                }
              : null,
        );
      },
    );
  }
}

class HostClubEditFooter extends StatelessWidget {
  const HostClubEditFooter({
    super.key,
    required this.footer,
    required this.onSave,
  });

  final HostClubCreateFooterState footer;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return CatchBottomDock(
      padding: CatchInsets.formActionDock,
      child: CatchButton(
        label: footer.primaryLabel,
        icon: Icon(CatchIcons.saveOutlined),
        isLoading: footer.isLoading,
        fullWidth: true,
        onPressed: footer.primaryEnabled ? onSave : null,
      ),
    );
  }
}

sealed class _ClubPhotoDraft {
  const _ClubPhotoDraft();

  OrderedPhotoPreview get preview;
  ClubPhotoInput get input;
}

final class _ExistingClubPhotoDraft extends _ClubPhotoDraft {
  const _ExistingClubPhotoDraft(this.photo);

  final UploadedPhoto photo;

  @override
  OrderedPhotoPreview get preview => OrderedPhotoPreview(
    id: 'existing_${photo.id}',
    imageUrl: photo.thumbnailOrUrl,
  );

  @override
  ClubPhotoInput get input => ExistingClubPhotoInput(photo);
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
