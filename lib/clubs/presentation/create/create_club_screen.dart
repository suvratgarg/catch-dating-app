import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_draft.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/presentation/create/create_club_controller.dart';
import 'package:catch_dating_app/clubs/presentation/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/clubs/presentation/create/widgets/club_basics_step.dart';
import 'package:catch_dating_app/clubs/presentation/create/widgets/club_details_step.dart';
import 'package:catch_dating_app/clubs/presentation/create/widgets/club_event_success_defaults_step.dart';
import 'package:catch_dating_app/clubs/presentation/create/widgets/club_host_defaults_step.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/events/presentation/widgets/stepper_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  PickedClubCover? _coverImage;
  PickedClubProfileImage? _profileImage;
  bool _checkedDraft = false;
  bool _restoredDraft = false;
  ClubHostDefaults _hostDefaults = const ClubHostDefaults();

  bool get _isEditing => widget.initialClub != null;

  List<FormStepSpec> get _activeSteps {
    final uid = ref.read(uidProvider).asData?.value;
    if (_isMediaOnlyForUid(uid)) {
      return [FormStepSpec(title: 'Club photos', formKey: _basicsFormKey)];
    }
    return [
      FormStepSpec(title: 'Club basics', formKey: _basicsFormKey),
      FormStepSpec(title: 'Club details', formKey: _detailsFormKey),
      FormStepSpec(title: 'Host defaults', formKey: _defaultsFormKey),
      FormStepSpec(
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

  Future<void> _pickCoverImage() async {
    final image = await ref
        .read(createClubControllerProvider.notifier)
        .pickCoverImage();
    if (!mounted || image == null) {
      return;
    }
    setState(() {
      _coverImage = image;
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

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
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
        duration: const Duration(seconds: 2),
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
                  coverImage: _coverImage?.image,
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
                    coverImageBytes: _coverImage?.bytes,
                    existingImageUrl: widget.initialClub?.imageUrl,
                    profileImageBytes: _profileImage?.bytes,
                    existingProfileImageUrl:
                        widget.initialClub?.profileImageUrl,
                    onPickCover: submitMutation.isPending
                        ? null
                        : _pickCoverImage,
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
            if (mutationError != null) ErrorBanner(message: mutationError),
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
}
