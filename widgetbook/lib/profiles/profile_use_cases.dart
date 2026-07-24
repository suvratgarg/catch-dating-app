import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/forms/catch_form_descriptors.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_controller.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen_state.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_edit_tab_state.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_screen_state.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_insights_tab.dart'
    show ProfileInsightsTabSliverBody;
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_sliver_header.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:go_router/go_router.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

final _viewer = ProfileSurfaceFixtures.viewer;
final _incompleteViewer = ProfileSurfaceFixtures.incompleteViewer;
final _longContentViewer = ProfileSurfaceFixtures.longContentViewer;
final _targetProfile = ProfileSurfaceFixtures.targetPublicProfile;
final _ownProfile = ProfileSurfaceFixtures.ownPublicProfile;

@widgetbook.UseCase(
  name: 'Self route states',
  type: ProfileScreen,
  path: '[P1 product surfaces]/Profiles',
)
Widget profileScreenSelfRouteStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileScreen',
    contractId: 'screen.profile.self',
    children: [
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _SelfProfileRouteScope(
            profileStream: ProfileSurfaceFixtures.loadingStream<UserProfile?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _SelfProfileRouteScope(
            profileStream: ProfileSurfaceFixtures.errorStream<UserProfile?>(
              'Profile failed',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'offline load error',
        child: _DeviceFrame(
          child: _SelfProfileRouteScope(
            profileStream: Stream<UserProfile?>.error(
              ProfileSurfaceFixtures.offlineException(action: 'load profile'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'profile unavailable',
        child: _DeviceFrame(
          child: _SelfProfileRouteScope(
            profileStream: Stream<UserProfile?>.value(null),
          ),
        ),
      ),
      _StateCard(
        label: 'edit tab default',
        child: const _DeviceFrame(child: _SelfProfileRouteScope()),
      ),
      _StateCard(
        label: 'upload pending in photo grid',
        child: const _DeviceFrame(
          child: _SelfProfileRouteScope(uploadLoadingIndices: {1}),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _SelfProfileRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _SelfProfileRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _SelfProfileRouteScope(themeMode: ThemeMode.dark),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Self tab body states',
  type: SelfProfileTabBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileScreenSelfTabBodyStates(BuildContext context) {
  final idleUploadState = (loadingIndices: <int>{}, uploadError: null);

  return _ProfileCatalog(
    title: 'SelfProfileTabBody',
    contractId: 'screen.profile.self.tab_body',
    children: [
      _StateCard(
        label: 'loading tab shell',
        child: _SectionFrame(
          height: 760,
          child: _SelfProfileTabBodyPreview(
            state: SelfProfileScreenState(
              status: SelfProfileRouteStatus.loading,
              uploadState: idleUploadState,
              mutationMode: SelfProfileMutationMode.idle,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'load error',
        child: _SectionFrame(
          height: 520,
          child: _SelfProfileTabBodyPreview(
            state: SelfProfileScreenState(
              status: SelfProfileRouteStatus.error,
              error: StateError('Profile failed'),
              uploadState: idleUploadState,
              mutationMode: SelfProfileMutationMode.idle,
              retryIntent: SelfProfileRetryIntent.reloadProfile,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'profile unavailable',
        child: _SectionFrame(
          height: 520,
          child: _SelfProfileTabBodyPreview(
            state: SelfProfileScreenState(
              status: SelfProfileRouteStatus.unavailable,
              uploadState: idleUploadState,
              mutationMode: SelfProfileMutationMode.idle,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'ready edit tab',
        child: _SectionFrame(
          height: 760,
          child: _SelfProfileTabBodyPreview(
            state: SelfProfileScreenState.fromAsync(
              profileState: CatchAsyncState.data(_viewer),
              today: ProfileSurfaceFixtures.now,
              uploadState: idleUploadState,
              uploadMutationPending: false,
              saveMutationPending: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Insights sliver body states',
  type: ProfileInsightsTabSliverBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileInsightsTabSliverBodyStates(BuildContext context) {
  return const _ProfileCatalog(
    title: 'ProfileInsightsTabSliverBody',
    contractId: 'screen.profile.insights_tab.sliver_body',
    children: [
      _StateCard(
        label: 'analytics body',
        child: _SectionFrame(
          height: 760,
          child: CustomScrollView(slivers: [ProfileInsightsTabSliverBody()]),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Self section states',
  type: ProfileScreen,
  path: '[P1 product surfaces]/Profiles',
)
Widget profileScreenSelfSectionStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'Profile sections',
    contractId: 'screen.profile.self sections',
    children: [
      _StateCard(
        label: 'header edit / preview selected',
        child: _SectionFrame(
          height: 360,
          child: Column(
            children: const [
              Expanded(child: _ProfileHeaderPreview(initialIndex: 0)),
              CatchDivider.section(),
              Expanded(child: _ProfileHeaderPreview(initialIndex: 1)),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'edit tab complete profile',
        child: _SectionFrame(
          height: 880,
          child: ProfileTab(
            user: _viewer,
            uploadState: (loadingIndices: <int>{}, uploadError: null),
          ),
        ),
      ),
      _StateCard(
        label: 'edit tab incomplete profile',
        child: _SectionFrame(
          height: 760,
          child: ProfileTab(
            user: _incompleteViewer,
            uploadState: (loadingIndices: <int>{}, uploadError: null),
          ),
        ),
      ),
      _StateCard(
        label: 'photo grid loading and delete disabled',
        child: _SectionFrame(
          height: 360,
          child: Padding(
            padding: CatchInsets.content,
            child: PhotoGrid(
              profilePhotos: _incompleteViewer.effectiveProfilePhotos,
              loadingIndices: const {1},
              canDeletePhotos: false,
              onSlotTapped: (_) {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'inline editor variants',
        child: const _SectionFrame(height: 760, child: _InlineEditorVariants()),
      ),
      _StateCard(
        label: 'preview tab default',
        child: _SectionFrame(
          height: 760,
          child: PreviewTab(profile: _ownProfile),
        ),
      ),
      _StateCard(
        label: 'long content and text scale',
        child: _SectionFrame(
          height: 820,
          child: _MediaOverride(
            textScaler: const TextScaler.linear(1.45),
            child: ProfileTab(
              user: _longContentViewer,
              uploadState: (loadingIndices: <int>{}, uploadError: null),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile title',
  type: CatchScreenHeaderTitle,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTitleStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchScreenHeaderTitle',
    contractId: 'section.profile.self.title',
    children: [
      _StateCard(
        label: 'title row',
        child: const _SectionFrame(
          height: 120,
          child: _ProfileHeaderRouterFrame(
            child: CatchScreenHeaderTitle.block(
              title: 'Your profile',
              actions: [ProfileSettingsButton()],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile tab bar',
  type: ProfileTabBar,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabBarStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileTabBar',
    contractId: 'section.profile.self.tab_bar',
    children: [
      _StateCard(
        label: 'edit selected',
        child: const _SectionFrame(
          height: 96,
          child: _ProfileTabBarPreview(initialIndex: 0),
        ),
      ),
      _StateCard(
        label: 'preview selected',
        child: const _SectionFrame(
          height: 96,
          child: _ProfileTabBarPreview(initialIndex: 1),
        ),
      ),
      _StateCard(
        label: 'insights selected',
        child: const _SectionFrame(
          height: 96,
          child: _ProfileTabBarPreview(initialIndex: 2),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile settings button',
  type: ProfileSettingsButton,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileSettingsButtonStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileSettingsButton',
    contractId: 'section.profile.self.settings_button',
    children: [
      _StateCard(
        label: 'settings action',
        child: const _SectionFrame(
          height: 96,
          child: _ProfileHeaderRouterFrame(
            child: Center(child: ProfileSettingsButton()),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Preview tab states',
  type: PreviewTab,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget previewTabStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'PreviewTab',
    contractId: 'screen.profile.preview_tab',
    children: [
      _StateCard(
        label: 'public profile preview',
        child: _SectionFrame(
          height: 760,
          child: PreviewTab(profile: _ownProfile),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab states',
  type: ProfileTab,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileTab',
    contractId: 'screen.profile.edit_tab',
    children: [
      _StateCard(
        label: 'complete profile',
        child: _SectionFrame(
          height: 880,
          child: ProfileTab(
            user: _viewer,
            uploadState: (loadingIndices: <int>{}, uploadError: null),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab content states',
  type: ProfileTabContent,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabContentStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileTabContent',
    contractId: 'screen.profile.edit_tab.content',
    children: [
      _StateCard(
        label: 'list body builder',
        child: _SectionFrame(
          height: 880,
          child: ProfileTabContent(
            user: _viewer,
            uploadState: (loadingIndices: <int>{}, uploadError: null),
            builder: (context, children) => ListView(
              padding: CatchInsets.formEditBodyRelaxed,
              children: children,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo section states',
  type: ProfilePhotosSection,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profilePhotosSectionStates(BuildContext context) {
  final completeState = SelfProfilePhotoGridState.fromProfile(
    user: _viewer,
    uploadState: (loadingIndices: <int>{}, uploadError: null),
  );
  final loadingState = SelfProfilePhotoGridState.fromProfile(
    user: _incompleteViewer,
    uploadState: (loadingIndices: <int>{1}, uploadError: null),
  );

  return _ProfileCatalog(
    title: 'ProfilePhotosSection',
    contractId: 'screen.profile.edit_tab.photos_section',
    children: [
      _StateCard(
        label: 'complete grid',
        child: _SectionFrame(
          height: 360,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfilePhotosSection(
              first: true,
              state: completeState,
              onSlotTapped: (_) {},
              onDeletePhoto: (_) {},
              onReorderPhoto: (_, _) {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'upload pending',
        child: _SectionFrame(
          height: 360,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfilePhotosSection(
              first: false,
              state: loadingState,
              onSlotTapped: (_) {},
              onDeletePhoto: (_) {},
              onReorderPhoto: (_, _) {},
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Field row states',
  type: ProfileFieldRow,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileFieldRowStates(BuildContext context) {
  final editState = SelfProfileEditTabState.fromProfile(
    l10n: context.l10n,
    user: _viewer,
    today: ProfileSurfaceFixtures.now,
    uploadState: (loadingIndices: <int>{}, uploadError: null),
  );
  final rows = [
    ...editState.runningRows.take(3),
    ...editState.lifestyleRows.take(3),
  ];

  return _ProfileCatalog(
    title: 'ProfileFieldRow',
    contractId: 'screen.profile.edit_tab.field_row',
    children: [
      _StateCard(
        label: 'descriptor rows',
        child: _SectionFrame(
          height: CatchLayout.maxContentWidth,
          child: _ProfileFieldRowCatalog(rows: rows),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Field row section states',
  type: CatchSection,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileFieldRowSectionStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchSection.fieldRows',
    contractId: 'screen.profile.edit_tab.field_row_section',
    children: [
      _StateCard(
        label: 'running section',
        child: _SectionFrame(
          height: 280,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CatchSection.fieldRows(
                title: 'Running',
                children: [
                  CatchField.nav(
                    icon: CatchIcons.speedOutlined,
                    title: 'Pace range',
                    body: '9:00-9:00/km',
                  ),
                  CatchField.nav(
                    icon: CatchIcons.straightenOutlined,
                    title: 'Preferred distances',
                    body: '5 km, 10 km, 21 km',
                  ),
                  CatchField.nav(
                    icon: CatchIcons.directionsRunOutlined,
                    title: 'Why I event',
                    body: 'Weight loss',
                  ),
                  CatchField.nav(
                    icon: CatchIcons.wbTwilightOutlined,
                    title: 'Favorite event times',
                    body: 'Early morning, Morning',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'count and first section',
        child: _SectionFrame(
          height: 260,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CatchSection.fieldRows(
                title: 'Prompts',
                count: '3 of 3 answered',
                first: true,
                children: [
                  CatchField.nav(
                    icon: CatchIcons.formatQuoteRounded,
                    title: 'A perfect event with me looks like...',
                    body: 'Catch me if you can',
                  ),
                  CatchField.nav(
                    icon: CatchIcons.formatQuoteRounded,
                    title: 'After an event, you can usually find me...',
                    body: 'ABCD',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'footer slot',
        child: _SectionFrame(
          height: 260,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CatchSection.fieldRows(
                title: 'Privacy & safety',
                footer: const Text(
                  'Footer content stays below the field-row section.',
                ),
                children: [
                  CatchField.read(
                    icon: CatchIcons.shieldOutlined,
                    title: 'Blocked users',
                    valueText: '0',
                  ),
                  CatchField.read(
                    icon: CatchIcons.visibilityOutlined,
                    title: 'Who can see you',
                    valueText: 'Runners on my events',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Single enum entry adapter states',
  type: ProfileSingleEnumEntry,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileSingleEnumEntryStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileSingleEnumEntry',
    contractId: 'screen.profile.edit_tab.single_enum_entry',
    children: [
      _StateCard(
        label: 'selected collapsed',
        child: _SectionFrame(
          height: CatchLayout.activityArtDefaultHeight,
          child: ProfileSingleEnumEntry<EducationLevel>(
            icon: CatchIcons.schoolOutlined,
            label: 'Education',
            contract: CatchContractConstraints.updateUserProfilePatchEducation,
            contractValue: (value) => value.name,
            values: EducationLevel.values,
            value: EducationLevel.masters,
            fieldName: 'education',
            patchForValue: (value) => UpdateUserProfilePatch(education: value),
            isExpanded: false,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'empty expanded',
        child: _SectionFrame(
          height: 300,
          child: ProfileSingleEnumEntry<EducationLevel>(
            icon: CatchIcons.schoolOutlined,
            label: 'Education',
            contract: CatchContractConstraints.updateUserProfilePatchEducation,
            contractValue: (value) => value.name,
            values: EducationLevel.values,
            value: null,
            fieldName: 'education',
            patchForValue: (value) => UpdateUserProfilePatch(education: value),
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Multi enum entry adapter states',
  type: ProfileMultiEnumEntry,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileMultiEnumEntryStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileMultiEnumEntry',
    contractId: 'screen.profile.edit_tab.multi_enum_entry',
    children: [
      _StateCard(
        label: 'selected collapsed',
        child: _SectionFrame(
          height: CatchLayout.activityArtDefaultHeight,
          child: ProfileMultiEnumEntry<Language>(
            icon: CatchIcons.languageOutlined,
            label: 'Languages',
            contract: CatchContractConstraints.updateUserProfilePatchLanguages,
            contractValue: (value) => value.name,
            values: Language.values,
            selected: const [Language.english, Language.hindi],
            fieldName: 'languages',
            patchForValues: (values) =>
                UpdateUserProfilePatch(languages: values),
            isExpanded: false,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'empty expanded',
        child: _SectionFrame(
          height: 300,
          child: ProfileMultiEnumEntry<Language>(
            icon: CatchIcons.languageOutlined,
            label: 'Languages',
            contract: CatchContractConstraints.updateUserProfilePatchLanguages,
            contractValue: (value) => value.name,
            values: Language.values,
            selected: const [],
            fieldName: 'languages',
            patchForValues: (values) =>
                UpdateUserProfilePatch(languages: values),
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt entry adapter states',
  type: ProfilePromptEntry,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profilePromptEntryStates(BuildContext context) {
  final editState = SelfProfileEditTabState.fromProfile(
    l10n: context.l10n,
    user: _viewer,
    today: ProfileSurfaceFixtures.now,
    uploadState: (loadingIndices: <int>{}, uploadError: null),
  );
  final slot = editState.promptSlots.first;

  return _ProfileCatalog(
    title: 'ProfilePromptEntry',
    contractId: 'screen.profile.edit_tab.prompt_entry',
    children: [
      _StateCard(
        label: 'collapsed prompt',
        child: _SectionFrame(
          height: CatchLayout.activityArtDefaultHeight,
          child: ProfilePromptEntry(
            user: _viewer,
            slot: slot,
            isExpanded: false,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'expanded prompt',
        child: _SectionFrame(
          height: CatchLayout.eventDetailHeroTicketWideHeight,
          child: ProfilePromptEntry(
            user: _viewer,
            slot: slot,
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab sliver body states',
  type: ProfileTabSliverBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabSliverBodyStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileTabSliverBody',
    contractId: 'screen.profile.edit_tab.sliver_body',
    children: [
      _StateCard(
        label: 'complete profile',
        child: _SectionFrame(
          height: 880,
          child: CustomScrollView(
            slivers: [
              ProfileTabSliverBody(
                user: _viewer,
                uploadState: (loadingIndices: <int>{}, uploadError: null),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab skeleton states',
  type: ProfileTabSkeletonSliverBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabSkeletonSliverBodyStates(BuildContext context) {
  return const _ProfileCatalog(
    title: 'ProfileTabSkeletonSliverBody',
    contractId: 'screen.profile.edit_tab.skeleton',
    children: [
      _StateCard(
        label: 'loading',
        child: _SectionFrame(
          height: 760,
          child: CustomScrollView(slivers: [ProfileTabSkeletonSliverBody()]),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo skeleton section states',
  type: ProfilePhotosSkeletonSection,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profilePhotosSkeletonSectionStates(BuildContext context) {
  return const _ProfileCatalog(
    title: 'ProfilePhotosSkeletonSection',
    contractId: 'screen.profile.edit_tab.skeleton.photos',
    children: [
      _StateCard(
        label: 'loading photo grid',
        child: _SectionFrame(
          height: 360,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfilePhotosSkeletonSection(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Info skeleton section states',
  type: ProfileInfoSkeletonSection,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileInfoSkeletonSectionStates(BuildContext context) {
  return const _ProfileCatalog(
    title: 'ProfileInfoSkeletonSection',
    contractId: 'screen.profile.edit_tab.skeleton.info_section',
    children: [
      _StateCard(
        label: 'single row',
        child: _SectionFrame(
          height: 176,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileInfoSkeletonSection(title: 'About you', rows: 1),
          ),
        ),
      ),
      _StateCard(
        label: 'divided rows',
        child: _SectionFrame(
          height: 320,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileInfoSkeletonSection(title: 'Lifestyle', rows: 4),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Info skeleton tile states',
  type: ProfileInfoSkeletonTile,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileInfoSkeletonTileStates(BuildContext context) {
  return const _ProfileCatalog(
    title: 'ProfileInfoSkeletonTile',
    contractId: 'screen.profile.edit_tab.skeleton.info_tile',
    children: [
      _StateCard(
        label: 'row placeholder',
        child: _SectionFrame(
          height: 120,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileInfoSkeletonTile(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Direct text entry states',
  type: ProfileDirectTextEntryField,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileDirectTextEntryFieldStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileDirectTextEntryField',
    contractId: 'screen.profile.inline.direct_text_entry',
    children: [
      _StateCard(
        label: 'editable and legal identity rows',
        child: _SectionFrame(
          height: 300,
          child: Column(
            children: [
              ProfileDirectTextEntryField(
                icon: CatchIcons.personOutlined,
                label: 'Display name',
                contract:
                    CatchContractConstraints.updateUserProfilePatchDisplayName,
                currentValue: 'Neha',
                currentFieldValue: 'Neha',
                fieldName: 'displayName',
                patchForValue: (value) =>
                    UpdateUserProfilePatch(displayName: value as String),
              ),
              CatchField.read(
                icon: CatchIcons.cakeOutlined,
                title: 'Date of birth',
                body: '16/07/1994 (31 years)',
              ),
              CatchField.read(
                icon: CatchIcons.groupOutlined,
                title: 'Gender',
                body: 'Woman',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline prompt editor states',
  type: ProfileInlinePromptEntryEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlinePromptEntryEditorStates(BuildContext context) {
  final prompt = _viewer.profilePrompts.first;
  Widget promptEditor({required bool expanded}) {
    return ProfileInlinePromptEntryEditor(
      icon: CatchIcons.formatQuoteRounded,
      label: profilePromptDefinition(prompt.promptId).title,
      currentAnswer: prompt.answer,
      currentPromptId: prompt.promptId,
      currentPrompts: _viewer.profilePrompts,
      promptIndex: 0,
      availablePromptIds: profilePromptCatalog
          .map((definition) => definition.id)
          .take(5)
          .toList(growable: false),
      fieldName: 'profilePrompt:0',
      isExpanded: expanded,
      onTap: () {},
      onSaved: () {},
      onCancel: () {},
    );
  }

  return _ProfileCatalog(
    title: 'ProfileInlinePromptEntryEditor',
    contractId: 'screen.profile.inline.prompt_entry',
    children: [
      _StateCard(
        label: 'collapsed question + separate answer',
        child: _SectionFrame(height: 180, child: promptEditor(expanded: false)),
      ),
      _StateCard(
        label: 'expanded inline question choices + separate answer',
        child: _SectionFrame(height: 560, child: promptEditor(expanded: true)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline height editor states',
  type: ProfileInlineHeightEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlineHeightEditorStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileInlineHeightEditor',
    contractId: 'screen.profile.inline.height',
    children: [
      _StateCard(
        label: 'expanded stepper',
        child: _SectionFrame(
          height: 180,
          child: ProfileInlineHeightEditor(
            icon: CatchIcons.heightOutlined,
            label: 'Height',
            value: '172 cm',
            currentValue: 172,
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
            patchForValue: (value) => UpdateUserProfilePatch(height: value),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Canonical height stepper states',
  type: CatchFieldStepper,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileHeightStepperControlsStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchFieldStepper',
    contractId: 'catch.field.stepper',
    children: [
      _StateCard(
        label: 'enabled',
        child: _SectionFrame(
          height: 120,
          child: Center(
            child: CatchFieldStepper(
              value: 172,
              min: 120,
              max: 220,
              unit: 'cm',
              enabled: true,
              decreaseSemanticLabel: 'Decrease height',
              increaseSemanticLabel: 'Increase height',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: _SectionFrame(
          height: 120,
          child: Center(
            child: CatchFieldStepper(
              value: 172,
              min: 120,
              max: 220,
              unit: 'cm',
              enabled: false,
              decreaseSemanticLabel: 'Decrease height',
              increaseSemanticLabel: 'Increase height',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Canonical height stepper bounds',
  type: CatchFieldStepper,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileHeightStepButtonStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchFieldStepper bounds',
    contractId: 'catch.field.stepper.bounds',
    children: [
      _StateCard(
        label: 'minimum and maximum endpoints',
        child: _SectionFrame(
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CatchFieldStepper(
                value: 120,
                min: 120,
                max: 220,
                unit: 'cm',
                decreaseSemanticLabel: 'Decrease height',
                increaseSemanticLabel: 'Increase height',
                onChanged: (_) {},
              ),
              gapH16,
              CatchFieldStepper(
                value: 220,
                min: 120,
                max: 220,
                unit: 'cm',
                decreaseSemanticLabel: 'Decrease height',
                increaseSemanticLabel: 'Increase height',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline single choice editor states',
  type: ProfileInlineSingleChoiceEntryEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlineSingleChoiceEntryEditorStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileInlineSingleChoiceEntryEditor',
    contractId: 'screen.profile.inline.single_choice',
    children: [
      _StateCard(
        label: 'expanded choice set',
        child: _SectionFrame(
          height: 260,
          child: const ProfileInlineRelationshipGoalChoiceEntryEditor(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline multi choice editor states',
  type: ProfileInlineMultiChoiceEntryEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlineMultiChoiceEntryEditorStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileInlineMultiChoiceEntryEditor',
    contractId: 'screen.profile.inline.multi_choice',
    children: [
      _StateCard(
        label: 'expanded choice set',
        child: _SectionFrame(
          height: 260,
          child: const ProfileInlineLanguageMultiChoiceEntryEditor(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Canonical single-choice chip states',
  type: CatchFieldChoiceChip,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileSingleChipValueStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchFieldChoiceChip',
    contractId: 'catch.field.choice_chip.single',
    children: [
      _StateCard(
        label: 'selected',
        child: _SectionFrame(
          height: 120,
          child: Center(
            child: CatchFieldChoiceChip(
              label: RelationshipGoal.relationship.label,
              selected: true,
              multi: false,
              enabled: true,
              onPressed: () {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'unselected',
        child: _SectionFrame(
          height: 120,
          child: Center(
            child: CatchFieldChoiceChip(
              label: RelationshipGoal.friendship.label,
              selected: false,
              multi: false,
              enabled: true,
              onPressed: () {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'selected disabled',
        child: _SectionFrame(
          height: 120,
          child: Center(
            child: CatchFieldChoiceChip(
              label: RelationshipGoal.relationship.label,
              selected: true,
              multi: false,
              enabled: false,
              onPressed: () {},
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Canonical wrapping choice control states',
  type: CatchFieldChoiceControl,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileMultiChipValueStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchFieldChoiceControl',
    contractId: 'catch.field.choice_control.multi',
    children: [
      _StateCard(
        label: 'selected and unselected wrap',
        child: _SectionFrame(
          height: 180,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchFieldChoiceControl<Language>(
              values: const [
                Language.english,
                Language.hindi,
                Language.marathi,
                Language.tamil,
                Language.gujarati,
              ],
              itemLabel: (value) => value.label,
              selected: const {Language.english, Language.hindi},
              multi: true,
              enabled: true,
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'disabled wrap',
        child: _SectionFrame(
          height: 180,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchFieldChoiceControl<Language>(
              values: const [
                Language.english,
                Language.hindi,
                Language.marathi,
                Language.tamil,
                Language.gujarati,
              ],
              itemLabel: (value) => value.label,
              selected: const {Language.english, Language.hindi},
              multi: true,
              enabled: false,
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Canonical collapsed choice states',
  type: CatchField,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileChipPlaceholderStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchField.choices collapsed',
    contractId: 'catch.field.choices.collapsed',
    children: [
      _StateCard(
        label: 'empty and selected values',
        child: _SectionFrame(
          height: 180,
          child: Column(
            children: [
              CatchField.choices<Language>(
                title: 'Languages',
                values: const [Language.english, Language.hindi],
                itemLabel: (value) => value.label,
                selected: const {},
                multi: true,
                onSelectionChanged: (_) {},
              ),
              CatchField.choices<Language>(
                title: 'Languages',
                values: const [Language.english, Language.hindi],
                itemLabel: (value) => value.label,
                selected: const {Language.english, Language.hindi},
                multi: true,
                onSelectionChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Canonical choice option states',
  type: CatchFieldChoiceControl,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileChipOptionsStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'CatchFieldChoiceControl options',
    contractId: 'catch.field.choice_control.options',
    children: [
      _StateCard(
        label: 'enabled selected',
        child: _SectionFrame(
          height: 140,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchFieldChoiceControl<Language>(
              values: const [
                Language.english,
                Language.hindi,
                Language.marathi,
              ],
              itemLabel: (value) => value.label,
              selected: const {Language.english},
              multi: true,
              enabled: true,
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: _SectionFrame(
          height: 140,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchFieldChoiceControl<Language>(
              values: const [
                Language.english,
                Language.hindi,
                Language.marathi,
              ],
              itemLabel: (value) => value.label,
              selected: const {Language.english, Language.hindi},
              multi: true,
              enabled: false,
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline range editor states',
  type: ProfileInlineRangeEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlineRangeEditorStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileInlineRangeEditor',
    contractId: 'screen.profile.inline.range',
    children: [
      _StateCard(
        label: 'expanded range',
        child: _SectionFrame(
          height: 220,
          child: ProfileInlineRangeEditor(
            icon: CatchIcons.directionsRunOutlined,
            title: 'Pace',
            minimumContract: CatchContractConstraints
                .updateUserProfilePatchActivityPreferencesRunningPaceMinSecsPerKm,
            maximumContract: CatchContractConstraints
                .updateUserProfilePatchActivityPreferencesRunningPaceMaxSecsPerKm,
            value: '5:15-6:30 min/km',
            currentMin: 315,
            currentMax: 390,
            sliderMin: 240,
            sliderMax: 540,
            divisions: 20,
            labelText: _paceLabel,
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
            patchForRange: (min, max) => UpdateUserProfilePatch(
              activityPreferences: ActivityPreferences(
                running: RunningPreferences(
                  paceMinSecsPerKm: min,
                  paceMaxSecsPerKm: max,
                  version: currentRunPreferencesVersion,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Typed descriptor prototype',
  type: CatchFormRowList,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget catchFormRowListStates(BuildContext context) {
  return _catchFormDescriptorPreview();
}

@widgetbook.UseCase(
  name: 'Typed descriptor prototype',
  type: CatchFormTextRowEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget catchFormTextRowEditorStates(BuildContext context) {
  return _catchFormDescriptorPreview();
}

@widgetbook.UseCase(
  name: 'Typed descriptor prototype',
  type: CatchFormSingleChoiceRowEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget catchFormSingleChoiceRowEditorStates(BuildContext context) {
  return _catchFormDescriptorPreview();
}

@widgetbook.UseCase(
  name: 'Typed descriptor prototype',
  type: CatchFormMultiChoiceRowEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget catchFormMultiChoiceRowEditorStates(BuildContext context) {
  return _catchFormDescriptorPreview();
}

@widgetbook.UseCase(
  name: 'Typed descriptor prototype',
  type: CatchFormRangeRowEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget catchFormRangeRowEditorStates(BuildContext context) {
  return _catchFormDescriptorPreview();
}

Widget _catchFormDescriptorPreview() {
  return _ProfileCatalog(
    title: 'CatchFormRowList',
    contractId: 'catch.form.descriptors.prototype',
    children: [
      _StateCard(
        label: 'read, text, choice, multi-choice, and range rows',
        child: _SectionFrame(
          height: 520,
          child: CatchFormRowList<_WidgetbookFormPatch>(
            title: 'About you',
            rows: [
              CatchFormReadRow<_WidgetbookFormPatch>(
                id: 'identity',
                icon: CatchIcons.personOutlined,
                label: 'Identity',
                body: 'Verified',
              ),
              CatchFormTextRow<_WidgetbookFormPatch>(
                id: 'name',
                icon: CatchIcons.personOutlined,
                label: 'Name',
                currentValue: 'Aarav',
                patchForValue: (value) => _WidgetbookFormPatch('name', value),
              ),
              CatchFormSingleChoiceRow<
                _WidgetbookFormPatch,
                _WidgetbookFormOption
              >(
                id: 'city',
                icon: CatchIcons.locationOnOutlined,
                label: 'City',
                values: _WidgetbookFormOption.values,
                value: _WidgetbookFormOption.mumbai,
                patchForValue: (value) => _WidgetbookFormPatch('city', value),
              ),
              CatchFormMultiChoiceRow<
                _WidgetbookFormPatch,
                _WidgetbookFormOption
              >(
                id: 'communities',
                icon: CatchIcons.groupsOutlined,
                label: 'Communities',
                values: _WidgetbookFormOption.values,
                selected: const [_WidgetbookFormOption.mumbai],
                patchForValues: (values) =>
                    _WidgetbookFormPatch('communities', values),
              ),
              CatchFormRangeRow<_WidgetbookFormPatch>(
                id: 'pace',
                icon: CatchIcons.directionsRunOutlined,
                label: 'Pace',
                value: '5:00 - 6:00 min/km',
                currentMin: 300,
                currentMax: 360,
                sliderMin: 240,
                sliderMax: 540,
                divisions: 20,
                labelText: (value) => '${value.round()} sec/km',
                patchForRange: (min, max) =>
                    _WidgetbookFormPatch('pace', (min, max)),
              ),
            ],
            savePatch: (_) async => true,
            errorText: (_, error) => error.toString(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route states',
  type: PublicProfileScreen,
  path: '[P1 product surfaces]/Profiles',
)
Widget publicProfileRouteStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'PublicProfileScreen',
    contractId: 'screen.profile.public',
    children: [
      _StateCard(
        label: 'cold loading',
        child: _DeviceFrame(
          child: _PublicProfileRouteScope(
            profileStream:
                ProfileSurfaceFixtures.loadingStream<PublicProfile?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'initial profile fallback while loading',
        child: _DeviceFrame(
          child: _PublicProfileRouteScope(
            initialProfile: _targetProfile,
            profileStream:
                ProfileSurfaceFixtures.loadingStream<PublicProfile?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'load error',
        child: _DeviceFrame(
          child: _PublicProfileRouteScope(
            profileStream: ProfileSurfaceFixtures.errorStream<PublicProfile?>(
              'Public profile failed',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'offline load error',
        child: _DeviceFrame(
          child: _PublicProfileRouteScope(
            profileStream: Stream<PublicProfile?>.error(
              ProfileSurfaceFixtures.offlineException(
                action: 'load public profile',
              ),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'profile unavailable',
        child: _DeviceFrame(
          child: _PublicProfileRouteScope(
            profileStream: Stream<PublicProfile?>.value(null),
          ),
        ),
      ),
      _StateCard(
        label: 'loaded with viewer context',
        child: const _DeviceFrame(child: _PublicProfileRouteScope()),
      ),
      _StateCard(
        label: 'own profile hides viewer context',
        child: _DeviceFrame(
          child: _PublicProfileRouteScope(
            uid: _ownProfile.uid,
            profile: _ownProfile,
          ),
        ),
      ),
      _StateCard(
        label: 'mutation pending overlay',
        child: const _DeviceFrame(
          child: _PublicProfileRouteScope(
            mutationMode: _PublicProfileMutationMode.blockPending,
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _PublicProfileRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _PublicProfileRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _PublicProfileRouteScope(themeMode: ThemeMode.dark),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Safety action states',
  type: PublicProfileScreen,
  path: '[P1 product surfaces]/Profiles',
)
Widget publicProfileSafetyActionStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'Public profile safety actions',
    contractId: 'screen.profile.public safety',
    children: [
      _StateCard(
        label: 'route overflow actions',
        child: const _DeviceFrame(child: _PublicProfileRouteScope()),
      ),
      _StateCard(
        label: 'report sheet',
        child: _SectionFrame(
          height: 430,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PublicProfileReportSheet(
              profileName: _targetProfile.name,
              onReasonSelected: (_) {},
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'block confirmation dialog',
        child: _SectionFrame(
          height: 430,
          child: _BlockDialogPreview(profile: _targetProfile),
        ),
      ),
      _StateCard(
        label: 'report mutation failure',
        child: const _DeviceFrame(
          child: _PublicProfileRouteScope(
            mutationMode: _PublicProfileMutationMode.reportError,
          ),
        ),
      ),
      _StateCard(
        label: 'block mutation failure',
        child: const _DeviceFrame(
          child: _PublicProfileRouteScope(
            mutationMode: _PublicProfileMutationMode.blockError,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route body states',
  type: PublicProfileScreenBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget publicProfileScreenBodyStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'PublicProfileScreenBody',
    contractId: 'screen.profile.public.route_body',
    children: [
      _StateCard(
        label: 'cold loading',
        child: _SectionFrame(
          height: 760,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: _targetProfile.uid,
              status: PublicProfileRouteStatus.loading,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: null,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'load error',
        child: _SectionFrame(
          height: 520,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: _targetProfile.uid,
              status: PublicProfileRouteStatus.error,
              error: StateError('Public profile failed'),
              retryIntent: PublicProfileRetryIntent.reloadProfile,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: null,
            ),
            onRetry: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'profile unavailable',
        child: _SectionFrame(
          height: 520,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: _targetProfile.uid,
              status: PublicProfileRouteStatus.unavailable,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: null,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'loaded with viewer context',
        child: _SectionFrame(
          height: 760,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: _targetProfile.uid,
              status: PublicProfileRouteStatus.ready,
              profile: _targetProfile,
              viewerProfile: _viewer,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: 'Morning miles',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body states',
  type: PublicProfileBody,
  path: '[P1 product surfaces]/Profiles',
)
Widget publicProfileBodyStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'PublicProfileBody',
    contractId: 'component.profile.public_body',
    children: [
      _StateCard(
        label: 'loaded public profile',
        child: _DeviceFrame(
          child: PublicProfileBody(
            profile: _targetProfile,
            viewerProfile: _viewer,
            sharedRunTitle: 'Morning miles',
            submitting: false,
          ),
        ),
      ),
      _StateCard(
        label: 'submitting overlay',
        child: _DeviceFrame(
          child: PublicProfileBody(
            profile: _targetProfile,
            viewerProfile: _viewer,
            submitting: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Report sheet',
  type: PublicProfileReportSheet,
  path: '[P1 product surfaces]/Profiles',
)
Widget publicProfileReportSheetStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'PublicProfileReportSheet',
    contractId: 'component.profile.public_report_sheet',
    children: [
      _StateCard(
        label: 'reason picker',
        child: _SectionFrame(
          height: 430,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PublicProfileReportSheet(
              profileName: _targetProfile.name,
              onReasonSelected: (_) {},
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Report reason row',
  type: PublicProfileReportReasonTile,
  path: '[P1 product surfaces]/Profiles',
)
Widget publicProfileReportReasonTileStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'PublicProfileReportReasonTile',
    contractId: 'component.profile.public_report_reason_tile',
    children: [
      _StateCard(
        label: 'action row',
        child: PublicProfileReportReasonTile(
          label: 'Fake or misleading profile',
          value: 'fake_or_misleading_profile',
          onSelected: (_) {},
        ),
      ),
    ],
  );
}

final class _WidgetbookFormPatch {
  const _WidgetbookFormPatch(this.field, this.value);

  final String field;
  final Object? value;
}

enum _WidgetbookFormOption implements Labelled {
  mumbai('Mumbai'),
  delhi('Delhi'),
  bengaluru('Bengaluru');

  const _WidgetbookFormOption(this.label);

  @override
  final String label;
}

class _ProfileFieldRowCatalog extends StatefulWidget {
  const _ProfileFieldRowCatalog({required this.rows});

  final List<SelfProfileFieldRowDescriptor> rows;

  @override
  State<_ProfileFieldRowCatalog> createState() =>
      _ProfileFieldRowCatalogState();
}

class _ProfileFieldRowCatalogState extends State<_ProfileFieldRowCatalog> {
  String? _expandedField;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in widget.rows)
          ProfileFieldRow(
            descriptor: row,
            isExpanded: (fieldId) => _expandedField == fieldId,
            onToggle: (fieldId) {
              setState(() {
                _expandedField = _expandedField == fieldId ? null : fieldId;
              });
            },
            onSaved: _collapse,
            onCancel: _collapse,
          ),
      ],
    );
  }

  void _collapse() {
    if (_expandedField == null) return;
    setState(() => _expandedField = null);
  }
}

class _SelfProfileRouteScope extends StatelessWidget {
  const _SelfProfileRouteScope({
    this.profileStream,
    this.uploadLoadingIndices = const {},
    this.themeMode = ThemeMode.light,
  });

  final Stream<UserProfile?>? profileStream;
  final Set<int> uploadLoadingIndices;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(_viewer.uid)),
        watchUserProfileProvider.overrideWith(
          (ref) => profileStream ?? Stream<UserProfile?>.value(_viewer),
        ),
        userProfileRepositoryProvider.overrideWithValue(
          ProfileFixtureUserProfileRepository(profile: _viewer),
        ),
        photoUploadControllerProvider.overrideWithValue((
          loadingIndices: uploadLoadingIndices,
          uploadError: null,
        )),
        userAnalyticsRepositoryProvider.overrideWithValue(
          ProfileFixtureUserAnalyticsRepository(
            report: ProfileSurfaceFixtures.analyticsReport,
          ),
        ),
      ],
      child: _ProfileRouter(themeMode: themeMode),
    );
  }
}

class _SelfProfileTabBodyPreview extends StatefulWidget {
  const _SelfProfileTabBodyPreview({required this.state});

  final SelfProfileScreenState state;

  @override
  State<_SelfProfileTabBodyPreview> createState() =>
      _SelfProfileTabBodyPreviewState();
}

class _SelfProfileTabBodyPreviewState extends State<_SelfProfileTabBodyPreview>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _previewScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _previewScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _previewScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        final headerSlivers = CatchSliverHeader(
          title: const CatchScreenHeaderTitle.block(
            title: 'Your profile',
            actions: [ProfileSettingsButton()],
          ),
          bottomHeight: CatchLayout.tabRailHeight,
          bottom: ProfileTabBar(controller: _tabController),
        ).buildSlivers(context);
        final collapsibleSlivers = headerSlivers.take(headerSlivers.length - 1);
        final pinnedSliver = headerSlivers.last;

        return [
          ...collapsibleSlivers,
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: pinnedSliver,
          ),
        ];
      },
      body: SelfProfileTabBody(
        state: widget.state,
        controller: _tabController,
        previewScrollController: _previewScrollController,
        onPreviewForwardScroll: (_) => 0,
        onPreviewLeadingOverscroll: (_) {},
        onRetry: () {},
      ),
    );
  }
}

class _PublicProfileRouteScope extends StatelessWidget {
  const _PublicProfileRouteScope({
    this.uid = ProfileSurfaceFixtures.targetUid,
    this.profile,
    this.initialProfile,
    this.profileStream,
    this.mutationMode,
    this.themeMode = ThemeMode.light,
  });

  final String uid;
  final PublicProfile? profile;
  final PublicProfile? initialProfile;
  final Stream<PublicProfile?>? profileStream;
  final _PublicProfileMutationMode? mutationMode;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final effectiveProfile = profile ?? _targetProfile;
    Widget child = PublicProfileScreen(
      uid: uid,
      initialProfile: initialProfile,
    );
    final mutationMode = this.mutationMode;
    if (mutationMode != null) {
      child = _PublicProfileMutationSeeder(mode: mutationMode, child: child);
    }

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(_viewer.uid)),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream<UserProfile?>.value(_viewer),
        ),
        watchPublicProfileProvider(uid).overrideWith(
          (ref) =>
              profileStream ?? Stream<PublicProfile?>.value(effectiveProfile),
        ),
        publicProfileRepositoryProvider.overrideWithValue(
          ProfileFixturePublicProfileRepository({
            uid: effectiveProfile,
            _targetProfile.uid: _targetProfile,
            _ownProfile.uid: _ownProfile,
          }),
        ),
        safetyRepositoryProvider.overrideWithValue(
          const ProfileFixtureSafetyRepository(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: child,
      ),
    );
  }
}

class _ProfileRouter extends StatelessWidget {
  const _ProfileRouter({required this.themeMode});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: Routes.profileScreen.path,
      routes: [
        GoRoute(
          path: Routes.profileScreen.path,
          name: Routes.profileScreen.name,
          builder: (_, _) => const ProfileScreen(),
        ),
        GoRoute(
          path: Routes.settingsScreen.path,
          name: Routes.settingsScreen.name,
          builder: (_, _) => const _SettingsPlaceholder(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class _ProfileHeaderPreview extends StatefulWidget {
  const _ProfileHeaderPreview({required this.initialIndex});

  final int initialIndex;

  @override
  State<_ProfileHeaderPreview> createState() => _ProfileHeaderPreviewState();
}

class _ProfileHeaderPreviewState extends State<_ProfileHeaderPreview>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 3,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ...CatchSliverHeader(
          title: const CatchScreenHeaderTitle.block(
            title: 'Your profile',
            actions: [ProfileSettingsButton()],
          ),
          bottomHeight: CatchLayout.tabRailHeight,
          bottom: ProfileTabBar(controller: _controller),
        ).buildSlivers(context),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Header review body')),
        ),
      ],
    );
  }
}

class _ProfileTabBarPreview extends StatefulWidget {
  const _ProfileTabBarPreview({required this.initialIndex});

  final int initialIndex;

  @override
  State<_ProfileTabBarPreview> createState() => _ProfileTabBarPreviewState();
}

class _ProfileTabBarPreviewState extends State<_ProfileTabBarPreview>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 3,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProfileTabBar(controller: _controller);
}

class _ProfileHeaderRouterFrame extends StatelessWidget {
  const _ProfileHeaderRouterFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => child),
        GoRoute(
          path: Routes.settingsScreen.path,
          name: Routes.settingsScreen.name,
          builder: (_, _) => const _SettingsPlaceholder(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

class _InlineEditorVariants extends StatefulWidget {
  const _InlineEditorVariants();

  @override
  State<_InlineEditorVariants> createState() => _InlineEditorVariantsState();
}

class ProfileInlineRelationshipGoalChoiceEntryEditor extends StatelessWidget {
  const ProfileInlineRelationshipGoalChoiceEntryEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileInlineSingleChoiceEntryEditor<RelationshipGoal>(
      icon: CatchIcons.favoriteOutline,
      label: 'Looking for',
      contract: CatchContractConstraints.updateUserProfilePatchRelationshipGoal,
      contractValue: (value) => value.name,
      values: RelationshipGoal.values,
      currentValue: RelationshipGoal.relationship,
      fieldName: 'relationshipGoal',
      isExpanded: true,
      onTap: () {},
      onSaved: () {},
      onCancel: () {},
      patchForValue: (value) => UpdateUserProfilePatch(relationshipGoal: value),
    );
  }
}

class ProfileInlineLanguageMultiChoiceEntryEditor extends StatelessWidget {
  const ProfileInlineLanguageMultiChoiceEntryEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileInlineMultiChoiceEntryEditor<Language>(
      icon: CatchIcons.languageOutlined,
      label: 'Languages',
      contract: CatchContractConstraints.updateUserProfilePatchLanguages,
      contractValue: (value) => value.name,
      values: Language.values,
      currentValues: const [Language.english, Language.hindi],
      fieldName: 'languages',
      isExpanded: true,
      onTap: () {},
      onSaved: () {},
      onCancel: () {},
      patchForValues: (values) => UpdateUserProfilePatch(languages: values),
    );
  }
}

class _InlineEditorVariantsState extends State<_InlineEditorVariants> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: CatchInsets.content,
      children: [
        ProfileDirectTextEntryField(
          icon: CatchIcons.personOutlined,
          label: 'Display name',
          contract: CatchContractConstraints.updateUserProfilePatchDisplayName,
          currentValue: 'Neha',
          currentFieldValue: 'Neha',
          fieldName: 'displayName',
          patchForValue: (value) =>
              UpdateUserProfilePatch(displayName: value as String),
        ),
        gapH12,
        ProfileDirectTextEntryField(
          icon: CatchIcons.workOutline,
          label: 'Job title',
          contract: CatchContractConstraints.updateUserProfilePatchOccupation,
          inputHint: 'e.g. Product designer',
          currentValue: '',
          currentFieldValue: null,
          fieldName: 'occupation',
          patchForValue: (value) =>
              UpdateUserProfilePatch(occupation: value as String),
        ),
        gapH12,
        const ProfileInlineRelationshipGoalChoiceEntryEditor(),
        gapH12,
        const ProfileInlineLanguageMultiChoiceEntryEditor(),
        gapH12,
        ProfileInlineRangeEditor(
          icon: CatchIcons.directionsRunOutlined,
          title: 'Pace',
          minimumContract: CatchContractConstraints
              .updateUserProfilePatchActivityPreferencesRunningPaceMinSecsPerKm,
          maximumContract: CatchContractConstraints
              .updateUserProfilePatchActivityPreferencesRunningPaceMaxSecsPerKm,
          value: '5:15-6:30 min/km',
          currentMin: 315,
          currentMax: 390,
          sliderMin: 240,
          sliderMax: 540,
          divisions: 20,
          labelText: _paceLabel,
          isExpanded: true,
          onTap: () {},
          onSaved: () {},
          onCancel: () {},
          patchForRange: (min, max) => UpdateUserProfilePatch(
            activityPreferences: ActivityPreferences(
              running: RunningPreferences(
                paceMinSecsPerKm: min,
                paceMaxSecsPerKm: max,
                version: currentRunPreferencesVersion,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicProfileMutationSeeder extends ConsumerStatefulWidget {
  const _PublicProfileMutationSeeder({required this.mode, required this.child});

  final _PublicProfileMutationMode mode;
  final Widget child;

  @override
  ConsumerState<_PublicProfileMutationSeeder> createState() =>
      _PublicProfileMutationSeederState();
}

class _PublicProfileMutationSeederState
    extends ConsumerState<_PublicProfileMutationSeeder> {
  Completer<void>? _pendingCompleter;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      _seed();
    });
  }

  @override
  void dispose() {
    final completer = _pendingCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    super.dispose();
  }

  void _seed() {
    switch (widget.mode) {
      case _PublicProfileMutationMode.blockPending:
        _runPending(PublicProfileController.blockUserMutation);
        break;
      case _PublicProfileMutationMode.blockError:
        _runError(PublicProfileController.blockUserMutation, 'Block failed');
        break;
      case _PublicProfileMutationMode.reportError:
        _runError(PublicProfileController.reportUserMutation, 'Report failed');
        break;
    }
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    _pendingCompleter = completer;
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, String message) {
    unawaited(
      mutation
          .run(ref, (_) async => throw StateError(message))
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _PublicProfileMutationMode { blockPending, blockError, reportError }

class _BlockDialogPreview extends StatelessWidget {
  const _BlockDialogPreview({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchConfirmDialog<bool>(
        title: 'Block ${profile.name}?',
        message:
            'You will stop seeing each other in chats, matches, Catches, and '
            'future event slots where the other person is already booked.',
        actions: const [
          CatchDialogAction(label: 'Cancel', value: false),
          CatchDialogAction(label: 'Block', value: true, isDestructive: true),
        ],
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      body: Center(
        child: Text(
          'Settings',
          style: CatchTextStyles.titleL(context, color: t.ink),
        ),
      ),
    );
  }
}

class _ProfileCatalog extends StatelessWidget {
  const _ProfileCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody,
          children: [
            Text(title, style: CatchTextStyles.titleL(context, color: t.ink)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH16,
            Wrap(
              spacing: CatchSpacing.s4,
              runSpacing: CatchSpacing.s4,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CatchTextStyles.labelL(context, color: t.ink)),
          gapH8,
          child,
        ],
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.line,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.micro6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.md),
          child: SizedBox(width: 390, height: 760, child: child),
        ),
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(_viewer.uid)),
        userProfileRepositoryProvider.overrideWithValue(
          ProfileFixtureUserProfileRepository(profile: _viewer),
        ),
        userAnalyticsRepositoryProvider.overrideWithValue(
          ProfileFixtureUserAnalyticsRepository(
            report: ProfileSurfaceFixtures.analyticsReport,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Scaffold(
          body: SafeArea(
            child: SizedBox(width: 390, height: height, child: child),
          ),
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: textScaler ?? media.textScaler,
        disableAnimations: disableAnimations || media.disableAnimations,
      ),
      child: child,
    );
  }
}

String _paceLabel(double value) {
  final seconds = value.round();
  final minutes = seconds ~/ 60;
  final remainder = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$remainder';
}
