import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_draft.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
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
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_basics_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
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
    required this.canSaveDraft,
    required this.lastStepLabel,
    required this.isLoading,
  });

  final bool isEditing;
  final bool mediaOnly;
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final bool showEditScaffold;
  final bool canSaveDraft;
  final String lastStepLabel;
  final bool isLoading;

  factory HostClubCreateState.resolve({
    required bool isEditing,
    required bool mediaOnly,
    required int currentStep,
    required List<CatchFormStepSpec> activeSteps,
    required Club? initialClub,
    required bool submitPending,
    required bool saveDraftPending,
  }) {
    final clampedStep = currentStep.clamp(0, activeSteps.length - 1).toInt();
    return HostClubCreateState(
      isEditing: isEditing,
      mediaOnly: mediaOnly,
      currentStep: clampedStep,
      totalSteps: activeSteps.length,
      title: formTitleForStep(activeSteps, clampedStep),
      subtitle: isEditing ? initialClub!.name : null,
      showEditScaffold: isEditing && !mediaOnly,
      canSaveDraft: !isEditing && !mediaOnly,
      lastStepLabel: mediaOnly
          ? 'Save photos'
          : isEditing
          ? 'Save changes'
          : 'Create club',
      isLoading: submitPending || saveDraftPending,
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
  bool get _shouldShowEditSectionErrors =>
      _editSubmitAttempted ||
      widget.formAutovalidateMode != AutovalidateMode.disabled;
  bool get _editIdentityHasError =>
      _shouldShowEditSectionErrors &&
      (_nameController.text.trim().isEmpty ||
          (_selectedCity == null || _selectedCity!.trim().isEmpty) ||
          _areaController.text.trim().isEmpty ||
          _descriptionController.text.trim().isEmpty);

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

  void _next() {
    final steps = _activeSteps;
    final formKey = formKeyForStep(steps, _currentStep);
    if (!(formKey?.currentState?.validate() ?? true)) {
      return;
    }

    if (_currentStep < steps.length - 1) {
      _goToStep(_currentStep + 1);
      return;
    }

    _submit();
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
    if (_shouldShowEditSectionErrors) setState(() {});
  }

  Future<void> _saveDraft() async {
    if (_isEditing) return;

    final draft = ClubDraft(
      savedAt: DateTime.now(),
      name: _trimmedTextOrNull(_nameController),
      area: _trimmedTextOrNull(_areaController),
      description: _trimmedTextOrNull(_descriptionController),
      location: _selectedCity,
      instagramHandle: _trimmedTextOrNull(_instagramController),
      phoneNumber: _trimmedTextOrNull(_phoneController),
      email: _trimmedTextOrNull(_emailController),
      hostDefaults: _hostDefaults,
    );

    final savedDraft = await CreateClubDraftController.saveDraftMutation.run(
      ref,
      (tx) async =>
          tx.get(createClubDraftControllerProvider.notifier).saveDraft(draft),
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
            await transaction
                .get(createClubControllerProvider.notifier)
                .submit(
                  name: _nameController.text.trim(),
                  location: _selectedCity!,
                  area: _areaController.text.trim(),
                  description: _descriptionController.text.trim(),
                  existingClub: widget.initialClub,
                  clubPhotoInputs: _clubPhotoInputsForSubmit,
                  profileImage: _profileImage?.image,
                  instagramHandle: _trimmedTextOrNull(_instagramController),
                  phoneNumber: _trimmedTextOrNull(_phoneController),
                  email: _trimmedTextOrNull(_emailController),
                  hostDefaults: _hostDefaults,
                );

            if (!_isEditing) {
              await transaction
                  .get(createClubDraftControllerProvider.notifier)
                  .deleteDraft();
            }
          })
          .catchError((Object _) {}),
    );
  }

  static String? _trimmedTextOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
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
    final uid = ref.watch(uidProvider).asData?.value;
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
    );

    ref.listen(CreateClubController.submitMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    if (screenState.showEditScaffold) {
      return _buildEditClubScaffold(
        tokens: t,
        isSubmitting: submitMutation.isPending,
        mutationError: mutationError,
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
                    selectedCity: cityOptionByName(_selectedCity),
                    onCityChanged: (city) => setState(() {
                      _selectedCity = city?.effectiveMarketId;
                    }),
                    areaController: _areaController,
                    detailsEnabled: !mediaOnly,
                    clubPhotoPreviews: _clubPhotoPreviews,
                    existingImageUrl: _clubPhotos.isEmpty
                        ? widget.initialClub?.imageUrl
                        : null,
                    profileImageBytes: _profileImage?.bytes,
                    existingProfileImageUrl:
                        widget.initialClub?.profileImageUrl,
                    onPickClubPhotos: submitMutation.isPending
                        ? null
                        : _pickClubPhotos,
                    onRemoveClubPhoto: submitMutation.isPending
                        ? null
                        : _removeClubPhoto,
                    onReorderClubPhoto: submitMutation.isPending
                        ? null
                        : _reorderClubPhoto,
                    onPickProfileImage: submitMutation.isPending
                        ? null
                        : _pickProfileImage,
                  ),
                  if (!mediaOnly) ...[
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
                      currencyCode: currencyCodeForCityName(_selectedCity),
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
            if (mutationError != null) CatchErrorBanner(message: mutationError),
            _buildStepperFooter(
              isLastStep: screenState.currentStep == activeSteps.length - 1,
              isLoading: screenState.isLoading,
              onNext: _next,
              onSaveDraft: screenState.canSaveDraft ? _saveDraft : null,
              lastStepLabel: screenState.lastStepLabel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditClubScaffold({
    required CatchTokens tokens,
    required bool isSubmitting,
    required String? mutationError,
  }) {
    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: CatchTopBar(
        title: 'Edit club',
        leadingType: CatchTopBarLeading.back,
        onBack: _back,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchSpacing.s4,
                CatchSpacing.s5,
                CatchSpacing.s7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CreateClubProfileImagePicker(
                    imageBytes: _profileImage?.bytes,
                    existingImageUrl: widget.initialClub?.profileImageUrl,
                    onTap: isSubmitting ? null : _pickProfileImage,
                    variant: CreateClubProfileImagePickerVariant.editLogo,
                  ),
                  gapH20,
                  CreateClubPhotosPicker(
                    photos: _clubPhotoPreviews,
                    existingImageUrl: _clubPhotos.isEmpty
                        ? widget.initialClub?.imageUrl
                        : null,
                    onAddPhotos: isSubmitting ? null : _pickClubPhotos,
                    onRemovePhoto: isSubmitting ? null : _removeClubPhoto,
                    onReorderPhoto: isSubmitting ? null : _reorderClubPhoto,
                    variant: CreateClubPhotosPickerVariant.editStrip,
                  ),
                  Form(
                    key: _basicsFormKey,
                    autovalidateMode: _editSubmitAttempted
                        ? AutovalidateMode.always
                        : widget.formAutovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildEditClubSection(
                          context: context,
                          label: 'Identity',
                          child: CatchSection.contained(
                            hasError: _editIdentityHasError,
                            children: [
                              CatchField.input(
                                title: 'Club name',
                                controller: _nameController,
                                onChanged: _handleEditIdentityChanged,
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
                              _buildEditClubCityField(
                                city: cityOptionByName(_selectedCity),
                                rawCityName: _selectedCity,
                                enabled: !isSubmitting,
                                onPickCity: _pickCityForEdit,
                              ),
                              CatchField.input(
                                title: 'Area / neighbourhood',
                                controller: _areaController,
                                onChanged: _handleEditIdentityChanged,
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
                                controller: _descriptionController,
                                onChanged: _handleEditIdentityChanged,
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
                        _buildEditClubSection(
                          context: context,
                          label: 'Contact',
                          child: CatchSection.contained(
                            children: [
                              CatchField.input(
                                title: 'Instagram',
                                controller: _instagramController,
                                icon: CatchIcons.alternateEmailOutlined,
                                leadingUnit: '@',
                                textInputAction: TextInputAction.next,
                              ),
                              CatchField.input(
                                title: 'Phone',
                                controller: _phoneController,
                                icon: CatchIcons.phoneOutlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                              ),
                              CatchField.input(
                                title: 'Email',
                                controller: _emailController,
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
                  _buildEditClubSection(
                    context: context,
                    label: 'Event defaults',
                    subtitle: 'Prefill every new event this club creates.',
                    child: Column(
                      children: [
                        ClubHostDefaultsStep(
                          formKey: _defaultsFormKey,
                          defaults: _hostDefaults,
                          currencyCode: currencyCodeForCityName(_selectedCity),
                          onChanged: (defaults) =>
                              setState(() => _hostDefaults = defaults),
                          scrollable: false,
                          padding: EdgeInsets.zero,
                        ),
                        gapH16,
                        ClubEventSuccessDefaultsStep(
                          formKey: _eventSuccessFormKey,
                          defaults: _hostDefaults,
                          onChanged: (defaults) =>
                              setState(() => _hostDefaults = defaults),
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
          if (mutationError != null) CatchErrorBanner(message: mutationError),
          _buildEditClubFooter(isLoading: isSubmitting, onSave: _submitEdit),
        ],
      ),
    );
  }

  Widget _buildStepperFooter({
    required bool isLastStep,
    required bool isLoading,
    required VoidCallback onNext,
    required VoidCallback? onSaveDraft,
    required String lastStepLabel,
  }) {
    final t = CatchTokens.of(context);
    return CatchBottomDock(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s3,
      ),
      child: Row(
        children: [
          if (onSaveDraft != null) ...[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CatchButton(
                  label: 'Save Draft',
                  onPressed: isLoading ? null : onSaveDraft,
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.lg,
                  icon: Icon(CatchIcons.saveOutlined),
                  foregroundColor: t.primary,
                ),
              ),
            ),
            const SizedBox(width: CatchSpacing.s3),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CatchButton(
                label: isLastStep ? lastStepLabel : 'Next',
                onPressed: onNext,
                isLoading: isLoading,
                fullWidth: true,
                icon: isLastStep ? null : Icon(CatchIcons.arrowForwardRounded),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditClubSection({
    required BuildContext context,
    required String label,
    required Widget child,
    String? subtitle,
  }) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: CatchSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: t.line, height: 1, thickness: 1),
          gapH18,
          Text(label, style: CatchTextStyles.kicker(context, color: t.ink2)),
          if (subtitle != null) ...[
            gapH4,
            Text(
              subtitle,
              style: CatchTextStyles.supporting(context, color: t.ink3),
            ),
          ],
          gapH10,
          child,
        ],
      ),
    );
  }

  Widget _buildEditClubCityField({
    required CityOption? city,
    required String? rawCityName,
    required bool enabled,
    required Future<CityOption?> Function() onPickCity,
  }) {
    return FormField<CityOption>(
      initialValue: city,
      validator: (_) {
        final hasCity =
            city != null || (rawCityName != null && rawCityName.isNotEmpty);
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

  Widget _buildEditClubFooter({
    required bool isLoading,
    required VoidCallback onSave,
  }) {
    return CatchBottomDock(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s3,
        CatchSpacing.s5,
        CatchSpacing.micro18,
      ),
      child: CatchButton(
        label: 'Save changes',
        icon: Icon(CatchIcons.saveOutlined),
        isLoading: isLoading,
        fullWidth: true,
        onPressed: isLoading ? null : onSave,
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
