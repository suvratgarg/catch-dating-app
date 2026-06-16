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
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_basics_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxClubPhotos = 6;

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key, this.initialClub});

  final Club? initialClub;

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _pageController = PageController();
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
  ClubHostDefaults _hostDefaults = const ClubHostDefaults();

  bool get _isEditing => widget.initialClub != null;

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
      _clubPhotos.addAll(
        ([...club.clubPhotos]..sort((a, b) => a.position.compareTo(b.position)))
            .map(_ExistingClubPhotoDraft.new),
      );
      return;
    }

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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Restored your club draft')));
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _restoredDraft ? 'Draft updated' : 'Draft saved',
          style: CatchTextStyles.labelL(
            context,
            color: CatchTokens.of(context).bg,
          ),
        ),
        duration: CatchMotion.snackbar,
      ),
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

  String get _title => formTitleForStep(_activeSteps, _currentStep);

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

    ref.listen(CreateClubController.submitMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    if (_isEditing && !mediaOnly) {
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
            CatchStepFlowHeader(
              title: _title,
              subtitle: _isEditing ? widget.initialClub!.name : null,
              currentStep: _currentStep,
              totalSteps: activeSteps.length,
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
                    nameController: _nameController,
                    selectedCity: cityOptionByName(_selectedCity),
                    onCityChanged: (city) => setState(() {
                      _selectedCity = city?.name;
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
            StepperFooter(
              isLastStep: _currentStep == activeSteps.length - 1,
              isLoading:
                  submitMutation.isPending || saveDraftMutation.isPending,
              onNext: _next,
              onSaveDraft: _isEditing || mediaOnly ? null : _saveDraft,
              lastStepLabel: mediaOnly
                  ? 'Save photos'
                  : _isEditing
                  ? 'Save changes'
                  : 'Create club',
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
      appBar: const CatchTopBar(title: 'Edit club', border: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchSpacing.micro18,
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
                  ),
                  gapH16,
                  CreateClubPhotosPicker(
                    photos: _clubPhotoPreviews,
                    existingImageUrl: _clubPhotos.isEmpty
                        ? widget.initialClub?.imageUrl
                        : null,
                    onAddPhotos: isSubmitting ? null : _pickClubPhotos,
                    onRemovePhoto: isSubmitting ? null : _removeClubPhoto,
                    onReorderPhoto: isSubmitting ? null : _reorderClubPhoto,
                  ),
                  Form(
                    key: _basicsFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _EditClubSection(
                          label: 'Identity',
                          child: Column(
                            children: [
                              CatchTextField(
                                label: 'Club name',
                                controller: _nameController,
                                prefixIcon: Icon(CatchIcons.groupOutlined),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a club name';
                                  }
                                  return null;
                                },
                              ),
                              gapH16,
                              CatchDropdownField<CityOption>(
                                values: defaultCityOptions,
                                label: 'City',
                                prefixIcon: Icon(
                                  CatchIcons.locationCityOutlined,
                                ),
                                value: cityOptionByName(_selectedCity),
                                onChanged: (city) => setState(() {
                                  _selectedCity = city?.name;
                                }),
                                validator: (_) => _selectedCity == null
                                    ? 'Please select a city'
                                    : null,
                              ),
                              gapH16,
                              CatchTextField(
                                label: 'Area / neighbourhood',
                                controller: _areaController,
                                prefixIcon: Icon(CatchIcons.locationOnOutlined),
                                hintText: 'e.g. Bandra, Koramangala',
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an area';
                                  }
                                  return null;
                                },
                              ),
                              gapH16,
                              CatchTextField(
                                label: 'Description',
                                controller: _descriptionController,
                                prefixIcon: Icon(CatchIcons.editNoteOutlined),
                                maxLines: 4,
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
                        _EditClubSection(
                          label: 'Contact',
                          child: CreateClubContactFields(
                            instagramController: _instagramController,
                            phoneController: _phoneController,
                            emailController: _emailController,
                            showLabel: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _EditClubSection(
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
          _EditClubFooter(isLoading: isSubmitting, onSave: _submitEdit),
        ],
      ),
    );
  }
}

class _EditClubSection extends StatelessWidget {
  const _EditClubSection({
    required this.label,
    required this.child,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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

class _EditClubFooter extends StatelessWidget {
  const _EditClubFooter({required this.isLoading, required this.onSave});

  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.bg,
          border: Border(top: BorderSide(color: t.line)),
        ),
        child: Padding(
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
