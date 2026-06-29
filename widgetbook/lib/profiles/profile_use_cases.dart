import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_controller.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
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
              Divider(height: 1),
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
            builder: (context, children) =>
                ListView(padding: profileTabBodyPadding, children: children),
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
  name: 'Inline text value states',
  type: ProfileInlineTextValue,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlineTextValueStates(BuildContext context) {
  return const _ProfileCatalog(
    title: 'ProfileInlineTextValue',
    contractId: 'screen.profile.inline.text_value',
    children: [
      _StateCard(
        label: 'display and editing',
        child: _SectionFrame(height: 220, child: _InlineTextValueCatalog()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline text editor states',
  type: ProfileInlineTextEntryEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlineTextEntryEditorStates(BuildContext context) {
  return _ProfileCatalog(
    title: 'ProfileInlineTextEntryEditor',
    contractId: 'screen.profile.inline.text_entry',
    children: [
      _StateCard(
        label: 'expanded text entry',
        child: _SectionFrame(
          height: 240,
          child: ProfileInlineTextEntryEditor(
            icon: CatchIcons.personOutlined,
            label: 'Display name',
            value: 'Neha',
            currentValue: 'Neha',
            fieldName: 'displayName',
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
            patchForValue: (value) =>
                UpdateUserProfilePatch(displayName: value as String),
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

  return _ProfileCatalog(
    title: 'ProfileInlinePromptEntryEditor',
    contractId: 'screen.profile.inline.prompt_entry',
    children: [
      _StateCard(
        label: 'expanded prompt entry',
        child: _SectionFrame(
          height: 360,
          child: ProfileInlinePromptEntryEditor(
            icon: CatchIcons.formatQuoteRounded,
            label: profilePromptDefinition(prompt.promptId).title,
            value: prompt.answer,
            currentAnswer: prompt.answer,
            currentPromptId: prompt.promptId,
            currentPrompts: _viewer.profilePrompts,
            promptIndex: 0,
            availablePromptIds: profilePromptCatalog
                .map((definition) => definition.id)
                .take(4)
                .toList(growable: false),
            fieldName: 'profilePrompt:0',
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
          child: ProfileInlineSingleChoiceEntryEditor<RelationshipGoal>(
            icon: CatchIcons.favoriteOutline,
            label: 'Looking for',
            value: RelationshipGoal.relationship.label,
            values: RelationshipGoal.values,
            currentValue: RelationshipGoal.relationship,
            fieldName: 'relationshipGoal',
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
            patchForValue: (value) =>
                UpdateUserProfilePatch(relationshipGoal: value),
          ),
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
          child: ProfileInlineMultiChoiceEntryEditor<Language>(
            icon: CatchIcons.languageOutlined,
            label: 'Languages',
            value: 'English, Hindi',
            values: Language.values,
            currentValues: const [Language.english, Language.hindi],
            fieldName: 'languages',
            isExpanded: true,
            onTap: () {},
            onSaved: () {},
            onCancel: () {},
            patchForValues: (values) =>
                UpdateUserProfilePatch(languages: values),
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
            value: '5:15-6:30 min/km',
            currentMin: 315,
            currentMax: 390,
            sliderMin: 240,
            sliderMax: 540,
            divisions: 20,
            labelText: _paceLabel,
            minFieldName: 'paceMinSecsPerKm',
            maxFieldName: 'paceMaxSecsPerKm',
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
      length: 2,
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
        ...ProfileSliverHeader(controller: _controller).buildSlivers(context),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Header review body')),
        ),
      ],
    );
  }
}

class _InlineEditorVariants extends StatefulWidget {
  const _InlineEditorVariants();

  @override
  State<_InlineEditorVariants> createState() => _InlineEditorVariantsState();
}

class _InlineTextValueCatalog extends StatefulWidget {
  const _InlineTextValueCatalog();

  @override
  State<_InlineTextValueCatalog> createState() =>
      _InlineTextValueCatalogState();
}

class _InlineTextValueCatalogState extends State<_InlineTextValueCatalog> {
  late final TextEditingController _displayController;
  late final TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: 'Neha');
    _editingController = TextEditingController(text: 'Product lead');
  }

  @override
  void dispose() {
    _displayController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: CatchInsets.content,
      children: [
        ProfileInlineTextValue(
          label: 'Display name',
          displayValue: 'Neha',
          controller: _displayController,
          isEditing: false,
          enabled: true,
        ),
        gapH20,
        ProfileInlineTextValue(
          label: 'Job title',
          displayValue: 'Product lead',
          controller: _editingController,
          isEditing: true,
          enabled: true,
        ),
      ],
    );
  }
}

class _InlineEditorVariantsState extends State<_InlineEditorVariants> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: CatchInsets.content,
      children: [
        ProfileInlineTextEntryEditor(
          icon: CatchIcons.personOutlined,
          label: 'Display name',
          value: 'Neha',
          currentValue: 'Neha',
          fieldName: 'displayName',
          isExpanded: true,
          onTap: () {},
          onSaved: () {},
          onCancel: () {},
          patchForValue: (value) =>
              UpdateUserProfilePatch(displayName: value as String),
        ),
        gapH12,
        ProfileInlineTextEntryEditor(
          icon: CatchIcons.workOutline,
          label: 'Job title',
          value: 'Job title',
          currentValue: '',
          fieldName: 'occupation',
          isExpanded: false,
          isAddAffordance: true,
          onTap: () {},
          onSaved: () {},
          onCancel: () {},
          patchForValue: (value) =>
              UpdateUserProfilePatch(occupation: value as String),
        ),
        gapH12,
        ProfileInlineSingleChoiceEntryEditor<RelationshipGoal>(
          icon: CatchIcons.favoriteOutline,
          label: 'Looking for',
          value: RelationshipGoal.relationship.label,
          values: RelationshipGoal.values,
          currentValue: RelationshipGoal.relationship,
          fieldName: 'relationshipGoal',
          isExpanded: true,
          onTap: () {},
          onSaved: () {},
          onCancel: () {},
          patchForValue: (value) =>
              UpdateUserProfilePatch(relationshipGoal: value),
        ),
        gapH12,
        ProfileInlineMultiChoiceEntryEditor<Language>(
          icon: CatchIcons.languageOutlined,
          label: 'Languages',
          value: 'English, Hindi',
          values: Language.values,
          currentValues: const [Language.english, Language.hindi],
          fieldName: 'languages',
          isExpanded: true,
          onTap: () {},
          onSaved: () {},
          onCancel: () {},
          patchForValues: (values) => UpdateUserProfilePatch(languages: values),
        ),
        gapH12,
        ProfileInlineRangeEditor(
          icon: CatchIcons.directionsRunOutlined,
          title: 'Pace',
          value: '5:15-6:30 min/km',
          currentMin: 315,
          currentMax: 390,
          sliderMin: 240,
          sliderMax: 540,
          divisions: 20,
          labelText: _paceLabel,
          minFieldName: 'paceMinSecsPerKm',
          maxFieldName: 'paceMaxSecsPerKm',
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
