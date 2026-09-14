import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_basics_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Form states',
  type: ClubBasicsStep,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubBasicsStepCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'ClubBasicsStep',
    contractId: 'component.host.club.basics_step',
    children: [
      WidgetbookHostStateCard(
        label: 'prefilled',
        child: WidgetbookHostDeviceFrame(child: _ClubBasicsStepFrame()),
      ),
      WidgetbookHostStateCard(
        label: 'validation',
        child: WidgetbookHostDeviceFrame(
          child: _ClubBasicsStepFrame(validate: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Form states',
  type: ClubDetailsStep,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubDetailsStepCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'ClubDetailsStep',
    contractId: 'component.host.club.details_step',
    children: [
      WidgetbookHostStateCard(
        label: 'prefilled',
        child: WidgetbookHostDeviceFrame(child: _ClubDetailsStepFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contact states',
  type: CreateClubContactFields,
  path: '[P1 product surfaces]/Host create club',
)
Widget createClubContactFieldsCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'CreateClubContactFields',
    contractId: 'component.host.club.contact_fields',
    children: [
      WidgetbookHostStateCard(
        label: 'filled',
        child: WidgetbookHostDeviceFrame(
          child: _CreateClubContactFieldsFrame(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Media states',
  type: CreateClubPhotosPicker,
  path: '[P1 product surfaces]/Host create club',
)
Widget createClubPhotosPickerCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'CreateClubPhotosPicker',
    contractId: 'component.host.club.photos_picker',
    children: [
      WidgetbookHostStateCard(
        label: 'empty',
        child: WidgetbookHostDeviceFrame(
          child: CreateClubPhotosPicker(
            photos: const [],
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'edit strip',
        child: WidgetbookHostDeviceFrame(
          child: CreateClubPhotosPicker(
            photos: widgetbookOrderedPhotoPreviews('club-photo', 3),
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
            variant: CreateClubPhotosPickerVariant.editStrip,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: '24-photo scalable gallery',
        child: WidgetbookHostDeviceFrame(
          child: CreateClubPhotosPicker(
            photos: widgetbookOrderedPhotoPreviews('large-club-photo', 24),
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
            variant: CreateClubPhotosPickerVariant.editStrip,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'failed upload',
        child: WidgetbookHostDeviceFrame(
          child: CreateClubPhotosPicker(
            photos: widgetbookOrderedPhotoPreviews(
              'failed-club-photo',
              3,
              failedIndex: 0,
            ),
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
            onRetryPhoto: (_) {},
            variant: CreateClubPhotosPickerVariant.editStrip,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Scalable gallery manager',
  type: OrderedPhotoManagerScreen,
  path: '[P1 product surfaces]/Host create club',
)
Widget orderedPhotoManagerCatalogState(BuildContext context) {
  return WidgetbookHostDeviceFrame(
    child: OrderedPhotoManagerScreen(
      photos: widgetbookOrderedPhotoPreviews('manager-photo', 24),
      onAddPhotos: () {},
      onRemovePhoto: (_) {},
      onReorderPhoto: (_, _) {},
      onRetryPhoto: (_) {},
      canAdd: true,
      header: CreateClubProfileImagePicker(
        imageBytes: widgetbookCreateClubPngBytes(),
        onTap: () {},
        onRemove: () {},
        variant: CreateClubProfileImagePickerVariant.editLogo,
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Role-sized summary states',
  type: HostClubMediaSummary,
  path: '[P1 product surfaces]/Host organizer',
)
Widget hostClubMediaSummaryCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'HostClubMediaSummary',
    contractId: 'component.host.club.photos_picker',
    children: [
      WidgetbookHostStateCard(
        label: 'logo, cover, and gallery',
        child: WidgetbookHostDeviceFrame(
          child: HostClubMediaSummary(
            logoImageBytes: widgetbookCreateClubPngBytes(),
            logoImageUrl: null,
            photos: widgetbookOrderedPhotoPreviews('summary-photo', 3),
            logoBadgeLabel: 'LOGO',
            addPhotosLabel: 'Add photos',
            onManageMedia: () {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'compact empty',
        child: WidgetbookHostDeviceFrame(
          child: HostClubMediaSummary(
            logoImageBytes: null,
            logoImageUrl: null,
            photos: const [],
            logoBadgeLabel: 'LOGO',
            addPhotosLabel: 'Add photos',
            onManageMedia: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Image states',
  type: CreateClubProfileImagePicker,
  path: '[P1 product surfaces]/Host create club',
)
Widget createClubProfileImagePickerCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'CreateClubProfileImagePicker',
    contractId: 'component.host.club.profile_image_picker',
    children: [
      WidgetbookHostStateCard(
        label: 'standard',
        child: WidgetbookHostDeviceFrame(
          child: CreateClubProfileImagePicker(
            imageBytes: widgetbookCreateClubPngBytes(),
            onTap: () {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'edit logo',
        child: WidgetbookHostDeviceFrame(
          child: CreateClubProfileImagePicker(
            imageBytes: widgetbookCreateClubPngBytes(),
            onTap: () {},
            onRemove: () {},
            variant: CreateClubProfileImagePickerVariant.editLogo,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile image tile states',
  type: ClubProfileImageTile,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubProfileImageTileCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'ClubProfileImageTile',
    contractId: 'component.host.club.profile_image_tile',
    children: [
      WidgetbookHostStateCard(
        label: 'empty large',
        child: ClubProfileImageTile(
          imageBytes: null,
          existingImageUrl: null,
          onTap: () {},
          size: CatchLayout.clubProfileImagePickerExtent,
          showEmptyLabel: true,
        ),
      ),
      WidgetbookHostStateCard(
        label: 'logo filled',
        child: ClubProfileImageTile(
          imageBytes: widgetbookCreateClubPngBytes(),
          existingImageUrl: null,
          onTap: () {},
          size: 64,
        ),
      ),
    ],
  );
}

class _ClubBasicsStepFrame extends StatefulWidget {
  const _ClubBasicsStepFrame({this.validate = false});

  final bool validate;

  @override
  State<_ClubBasicsStepFrame> createState() => _ClubBasicsStepFrameState();
}

class _ClubBasicsStepFrameState extends State<_ClubBasicsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  CityOption? _selectedCity;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.validate ? '' : 'Sea Face Social Run Club',
    );
    _areaController = TextEditingController(
      text: widget.validate ? '' : 'Bandra West',
    );
    _selectedCity = widget.validate
        ? null
        : cityOptionByName(widgetbookClub.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClubBasicsStep(
      formKey: _formKey,
      autovalidateMode: widget.validate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      nameController: _nameController,
      selectedCity: _selectedCity,
      onCityChanged: (city) => setState(() => _selectedCity = city),
      areaController: _areaController,
      clubPhotoPreviews: widget.validate
          ? const []
          : widgetbookOrderedPhotoPreviews('club-basics-photo', 2),
      existingImageUrl: null,
      profileImageBytes: widget.validate
          ? null
          : widgetbookCreateClubPngBytes(),
      existingProfileImageUrl: null,
      onPickClubPhotos: () {},
      onRemoveClubPhoto: (_) {},
      onReorderClubPhoto: (_, _) {},
      onPickProfileImage: () {},
      onRemoveProfileImage: () {},
    );
  }
}

class _ClubDetailsStepFrame extends StatefulWidget {
  const _ClubDetailsStepFrame();

  @override
  State<_ClubDetailsStepFrame> createState() => _ClubDetailsStepFrameState();
}

class _ClubDetailsStepFrameState extends State<_ClubDetailsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _instagramController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text:
          'Structured social runs with warm arrivals, conversational pacing, and a post-run cafe table.',
    );
    _instagramController = TextEditingController(text: 'seafaceruns');
    _phoneController = TextEditingController(text: '9876543210');
    _emailController = TextEditingController(text: 'hosts@seaface.example');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _instagramController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClubDetailsStep(
      formKey: _formKey,
      descriptionController: _descriptionController,
      instagramController: _instagramController,
      phoneController: _phoneController,
      emailController: _emailController,
    );
  }
}

class _CreateClubContactFieldsFrame extends StatefulWidget {
  const _CreateClubContactFieldsFrame();

  @override
  State<_CreateClubContactFieldsFrame> createState() =>
      _CreateClubContactFieldsFrameState();
}

class _CreateClubContactFieldsFrameState
    extends State<_CreateClubContactFieldsFrame> {
  late final TextEditingController _instagramController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _instagramController = TextEditingController(text: 'seafaceruns');
    _phoneController = TextEditingController(text: '9876543210');
    _emailController = TextEditingController(text: 'hosts@seaface.example');
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.content,
      child: CreateClubContactFields(
        instagramController: _instagramController,
        phoneController: _phoneController,
        emailController: _emailController,
      ),
    );
  }
}
