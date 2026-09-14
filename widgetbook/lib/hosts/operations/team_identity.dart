import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_view_model.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'fixtures.dart';
import 'preview.dart';
import 'role_theme.dart';
import 'shell_fixture.dart';

HostProfile _hostProfileVariant(HostProfileStatus status) {
  final suffix = switch (status) {
    HostProfileStatus.active => 'Active',
    HostProfileStatus.pending => 'Pending',
    HostProfileStatus.suspended => 'Suspended',
  };
  return HostProfile(
    uid: widgetbookHostUid,
    displayName: 'Mira Shah',
    roleTitle: '$suffix host profile',
    bio:
        'Runs hosted event formats with clear arrival cues, structured prompts, and visible safety follow-through.',
    status: status,
    verified: status == HostProfileStatus.active,
    linkedClubIds: [HostOperationsFixtures.primaryClub.id],
    createdAt: HostOperationsFixtures.now.subtract(const Duration(days: 400)),
    updatedAt: HostOperationsFixtures.now.subtract(const Duration(days: 2)),
  );
}

@widgetbook.UseCase(
  name: 'Covered by host team route states',
  type: HostTeamProfileRows,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Route states',
  type: HostClubTeamScreen,
  path: '[P2 host surfaces]/Host team',
)
Widget hostTeamRouteStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'HostClubTeamScreen',
    contractId: 'screen.host.clubs',
    children: [
      WidgetbookHostStateCard(
        label: 'auth required',
        child: const WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            uid: null,
            child: HostClubTeamScreen(clubId: 'design-host-sea-face'),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'fallback profile from club',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            hostProfileStream:
                HostOperationsFixtures.loadingStream<HostProfile?>(),
            child: const HostClubTeamScreen(clubId: 'design-host-sea-face'),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'active profile and clubs',
        child: const WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            child: HostClubTeamScreen(clubId: 'design-host-sea-face'),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'clubs loading',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            hostedClubsStream:
                HostOperationsFixtures.loadingStream<List<Club>>(),
            child: const HostClubTeamScreen(clubId: 'design-host-sea-face'),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'clubs error',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            ownedClubsStream: HostOperationsFixtures.errorStream<List<Club>>(
              'Hosted clubs failed',
            ),
            child: const HostClubTeamScreen(clubId: 'design-host-sea-face'),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'text scale 2.0',
        child: const WidgetbookHostDeviceFrame(
          child: WidgetbookMediaOverride(
            textScaler: TextScaler.linear(2),
            child: WidgetbookHostShellScope(
              child: HostClubTeamScreen(clubId: 'design-host-sea-face'),
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'reduced motion',
        child: const WidgetbookHostDeviceFrame(
          child: WidgetbookMediaOverride(
            disableAnimations: true,
            child: WidgetbookHostShellScope(
              child: HostClubTeamScreen(clubId: 'design-host-sea-face'),
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'dark theme',
        child: const WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            themeMode: ThemeMode.dark,
            child: HostClubTeamScreen(clubId: 'design-host-sea-face'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile summary states',
  type: HostTeamProfileSection,
  path: '[P2 host surfaces]/Host team',
)
Widget hostTeamProfileSummaryStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'HostTeamProfileSection',
    contractId: 'section.host.team.profile',
    children: [
      WidgetbookHostStateCard(
        label: 'profile loading',
        child: const WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(state: HostTeamProfileLoading()),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'profile error',
        child: WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(
            state: HostTeamProfileError(
              error: StateError('Host profile failed'),
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'no profile',
        child: const WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(state: HostTeamProfileMissing()),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'create pending',
        child: const WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(
            state: HostTeamProfileMissing(),
            creatingProfile: true,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'club fallback profile',
        child: WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(
            state: HostTeamProfileContent(
              profile: _hostProfileVariant(HostProfileStatus.active),
              isFallback: true,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'active edit rows',
        child: WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'active preview rows',
        child: WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
            editMode: false,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'pending status',
        child: WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.pending),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'suspended status',
        child: WidgetbookHostDeviceFrame(
          child: _HostTeamProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.suspended),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'text scale 2.0',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookMediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostTeamProfileFrame(
              profile: _hostProfileVariant(HostProfileStatus.active),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Clubs states',
  type: HostTeamHostedClubsSection,
  path: '[P2 host surfaces]/Host team',
)
Widget hostTeamHostedClubsStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'HostTeamHostedClubsSection',
    contractId: 'section.host.team.hosted_clubs',
    children: [
      WidgetbookHostStateCard(
        label: 'clubs loading',
        child: const WidgetbookHostDeviceFrame(
          child: _HostTeamHostedClubsFrame(loading: true),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'clubs error',
        child: WidgetbookHostDeviceFrame(
          child: _HostTeamHostedClubsFrame(
            error: StateError('Hosted clubs failed'),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'empty clubs',
        child: const WidgetbookHostDeviceFrame(
          child: _HostTeamHostedClubsFrame(clubs: []),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'owner and host-team rows',
        child: const WidgetbookHostDeviceFrame(
          child: _HostTeamHostedClubsFrame(),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'preview mode rows',
        child: const WidgetbookHostDeviceFrame(
          child: _HostTeamHostedClubsFrame(editMode: false),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'text scale 2.0',
        child: const WidgetbookHostDeviceFrame(
          child: WidgetbookMediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostTeamHostedClubsFrame(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubTeamScreen,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubTeamScreenCatalogStates(BuildContext context) =>
    hostTeamRouteStates(context);

class _HostTeamProfileFrame extends StatefulWidget {
  const _HostTeamProfileFrame({
    this.profile,
    this.state,
    this.editMode = true,
    this.creatingProfile = false,
  });

  final HostProfile? profile;
  final HostTeamProfileState? state;
  final bool editMode;
  final bool creatingProfile;

  @override
  State<_HostTeamProfileFrame> createState() => _HostTeamProfileFrameState();
}

class _HostTeamProfileFrameState extends State<_HostTeamProfileFrame> {
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    if (profile == null) return;
    _displayNameController.text = profile.displayName;
    _roleTitleController.text = profile.roleTitle ?? '';
    _bioController.text = profile.bio ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetbookThemedHostPreview(
      themeMode: ThemeMode.light,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: ListView(
              padding: CatchInsets.pageBodyUnderHeader,
              children: [
                HostTeamProfileSection(
                  state:
                      widget.state ??
                      HostTeamProfileContent(profile: widget.profile!),
                  editMode: widget.editMode,
                  creatingProfile: widget.creatingProfile,
                  onRetry: () {},
                  onCreateProfile: () {},
                  displayNameController: _displayNameController,
                  roleTitleController: _roleTitleController,
                  bioController: _bioController,
                  savingProfile: false,
                  onSaveProfile: () async => true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HostTeamHostedClubsFrame extends StatelessWidget {
  const _HostTeamHostedClubsFrame({
    this.clubs,
    this.loading = false,
    this.error,
    this.editMode = true,
  });

  final List<Club>? clubs;
  final bool loading;
  final Object? error;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return WidgetbookThemedHostPreview(
      themeMode: ThemeMode.light,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: ListView(
              padding: CatchInsets.pageBodyUnderHeader,
              children: [
                HostTeamHostedClubsSection(
                  actions: HostTeamWorkspaceActionState.from(
                    uid: widgetbookHostUid,
                    editMode: editMode,
                    creatingProfile: false,
                    profile: HostTeamProfileContent(
                      profile: HostOperationsFixtures.hostProfile,
                    ),
                  ),
                  state: error != null
                      ? HostTeamHostedClubsError(error: error!)
                      : loading
                      ? const HostTeamHostedClubsLoading()
                      : buildHostTeamHostedClubsState(
                          CatchAsyncState<List<Club>>.data(
                            clubs ?? HostOperationsFixtures.clubs,
                          ),
                        ),
                  onRetry: error == null ? null : () {},
                  onOpenClub: (_) {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
