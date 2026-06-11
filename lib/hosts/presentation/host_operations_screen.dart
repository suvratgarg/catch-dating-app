import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostOperationsHomeScreen extends ConsumerWidget {
  const HostOperationsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null) return const _HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return clubsAsync.when(
      loading: () => const _HostLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      data: (clubs) => _HostEventsScaffold(clubs: clubs),
    );
  }
}

class HostClubsScreen extends ConsumerWidget {
  const HostClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null) return const _HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return clubsAsync.when(
      loading: () => const _HostLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      data: (clubs) => _HostClubsScaffold(clubs: clubs, currentUid: uid),
    );
  }
}

class HostAccountScreen extends ConsumerWidget {
  const HostAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    final hostProfileAsync = uid == null
        ? const AsyncData<HostProfile?>(null)
        : ref.watch(watchHostProfileProvider(uid));

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody,
          children: [
            Text(
              'ACCOUNT',
              style: CatchTextStyles.kicker(context, color: t.ink3),
            ),
            gapH6,
            Text('Host settings', style: CatchTextStyles.headlineS(context)),
            gapH18,
            _HostProfilePanel(uid: uid, profileAsync: hostProfileAsync),
            gapH18,
            CatchSurface(
              padding: CatchInsets.content,
              borderColor: t.line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Professional host account',
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                  gapH8,
                  Text(
                    'Host identity and club management are separate from your dating profile.',
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                  gapH18,
                  CatchButton(
                    label: 'Sign out',
                    icon: Icon(CatchIcons.logoutRounded, size: CatchIcon.md),
                    variant: CatchButtonVariant.secondary,
                    onPressed: () => unawaited(_signOut(context, ref)),
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final mutation = ref.read(AuthSessionController.signOutMutation);
    if (mutation.isPending) return;
    try {
      await AuthSessionController.signOutMutation.run(
        ref,
        (tx) async => tx.get(authSessionControllerProvider.notifier).signOut(),
      );
    } catch (error) {
      if (!context.mounted) return;
      showCatchErrorSnackBar(context, error);
      return;
    }
    if (context.mounted) context.go(Routes.startScreen.path);
  }
}

class HostProfileScreen extends ConsumerStatefulWidget {
  const HostProfileScreen({super.key});

  @override
  ConsumerState<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends ConsumerState<HostProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _bioController = TextEditingController();
  String? _loadedProfileKey;
  bool _saving = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    if (uid == null) return const _HostAuthRequiredScreen();

    final profileAsync = ref.watch(watchHostProfileProvider(uid));
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const CatchLoadingIndicator(),
          error: (error, _) => CatchErrorState.fromError(
            error,
            onRetry: () => ref.invalidate(watchHostProfileProvider(uid)),
          ),
          data: (profile) {
            if (profile == null) {
              return _HostProfileMissingState(uid: uid);
            }
            _syncControllers(profile);
            return Form(
              key: _formKey,
              child: ListView(
                padding: CatchInsets.pageBody,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => context.pop(),
                        icon: Icon(CatchIcons.arrowBackRounded),
                      ),
                      gapW8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOST PROFILE',
                              style: CatchTextStyles.kicker(
                                context,
                                color: t.ink3,
                              ),
                            ),
                            gapH6,
                            Text(
                              'Professional profile',
                              style: CatchTextStyles.headlineS(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  gapH18,
                  CatchSurface(
                    padding: CatchInsets.content,
                    borderColor: t.line,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hostProfileStatusLabel(profile.status),
                          style: CatchTextStyles.supporting(
                            context,
                            color: profile.isActive ? t.success : t.ink2,
                          ),
                        ),
                        gapH14,
                        CatchTextField(
                          label: 'Display name',
                          controller: _displayNameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: _requiredDisplayName,
                        ),
                        gapH14,
                        CatchTextField(
                          label: 'Role title',
                          isOptional: true,
                          controller: _roleTitleController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                        ),
                        gapH14,
                        CatchTextField(
                          label: 'Bio',
                          isOptional: true,
                          controller: _bioController,
                          minLines: 4,
                          maxLines: 6,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        gapH18,
                        CatchButton(
                          label: 'Save profile',
                          icon: Icon(
                            CatchIcons.checkRounded,
                            size: CatchIcon.md,
                          ),
                          isLoading: _saving,
                          fullWidth: true,
                          onPressed: _saving
                              ? null
                              : () => unawaited(_saveProfile(uid)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _syncControllers(HostProfile profile) {
    final key = [
      profile.uid,
      profile.displayName,
      profile.roleTitle,
      profile.bio,
      profile.updatedAt?.microsecondsSinceEpoch,
    ].join('|');
    if (_loadedProfileKey == key) return;
    _loadedProfileKey = key;
    _displayNameController.text = profile.displayName;
    _roleTitleController.text = profile.roleTitle ?? '';
    _bioController.text = profile.bio ?? '';
  }

  Future<void> _saveProfile(String uid) async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(hostProfileRepositoryProvider)
          .saveHostProfile(
            uid: uid,
            displayName: _displayNameController.text,
            roleTitle: _roleTitleController.text,
            bio: _bioController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Host profile saved.')));
    } catch (error) {
      if (!mounted) return;
      showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _HostProfileMissingState extends ConsumerWidget {
  const _HostProfileMissingState({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    return ListView(
      padding: CatchInsets.pageBody,
      children: [
        Text(
          'HOST PROFILE',
          style: CatchTextStyles.kicker(context, color: t.ink3),
        ),
        gapH6,
        Text('Professional profile', style: CatchTextStyles.headlineS(context)),
        gapH18,
        CatchSurface(
          padding: CatchInsets.content,
          borderColor: t.line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No host profile yet',
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH8,
              Text(
                'Create a professional host identity before editing profile details.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              gapH18,
              CatchButton(
                label: 'Create host profile',
                icon: Icon(CatchIcons.businessOutlined, size: CatchIcon.md),
                onPressed: () => unawaited(
                  ref
                      .read(hostProfileRepositoryProvider)
                      .ensureHostProfile(uid: uid, displayName: 'Catch Host'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String? _requiredDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a display name.';
  }
  return null;
}

String _hostProfileStatusLabel(HostProfileStatus status) {
  return switch (status) {
    HostProfileStatus.active => 'Active professional profile',
    HostProfileStatus.pending => 'Profile pending review',
    HostProfileStatus.suspended => 'Profile suspended',
  };
}

class _HostProfilePanel extends ConsumerWidget {
  const _HostProfilePanel({required this.uid, required this.profileAsync});

  final String? uid;
  final AsyncValue<HostProfile?> profileAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final profile = profileAsync.asData?.value;
    void openProfileEditor() {
      unawaited(context.pushNamed(Routes.hostProfileScreen.name));
    }

    final surface = CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      onTap: profile == null ? null : openProfileEditor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Host profile', style: CatchTextStyles.sectionTitle(context)),
          gapH8,
          if (profileAsync.isLoading)
            const CatchLoadingIndicator()
          else if (profile == null) ...[
            Text(
              'Create a professional host identity for events, clubs, and message-host conversations.',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH14,
            CatchButton(
              label: 'Create host profile',
              icon: Icon(CatchIcons.businessOutlined, size: CatchIcon.md),
              onPressed: uid == null
                  ? null
                  : () => unawaited(_createHostProfile(context, ref, uid!)),
            ),
          ] else ...[
            Text(
              profile.displayName,
              style: CatchTextStyles.bodyLead(context, color: t.ink),
            ),
            if (profile.roleTitle != null) ...[
              gapH4,
              Text(
                profile.roleTitle!,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
            gapH8,
            Text(
              _hostProfileStatusLabel(profile.status),
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH14,
            CatchButton(
              label: 'View / edit profile',
              icon: Icon(CatchIcons.editOutlined, size: CatchIcon.md),
              variant: CatchButtonVariant.secondary,
              onPressed: openProfileEditor,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
    return surface;
  }

  Future<void> _createHostProfile(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    await ref
        .read(hostProfileRepositoryProvider)
        .ensureHostProfile(uid: uid, displayName: 'Catch Host');
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Host profile created.')));
  }
}

class _HostEventsScaffold extends StatelessWidget {
  const _HostEventsScaffold({required this.clubs});

  final List<Club> clubs;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody,
          children: [
            const _HostScreenHeader(
              eyebrow: 'OPERATIONS',
              title: 'Host events',
            ),
            gapH18,
            if (clubs.isEmpty)
              const _HostEmptyState(
                title: 'Create your first club',
                body:
                    'Create a club to publish events, manage attendees, and run Event Success.',
              )
            else
              for (final club in clubs) ...[
                _HostEventsClubCard(club: club),
                gapH14,
              ],
          ],
        ),
      ),
    );
  }
}

class _HostClubsScaffold extends StatelessWidget {
  const _HostClubsScaffold({required this.clubs, required this.currentUid});

  final List<Club> clubs;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final ownedClubs = clubs
        .where((club) => club.isOwnedBy(currentUid))
        .toList(growable: false);
    final hostedClubs = clubs
        .where((club) => !club.isOwnedBy(currentUid))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody,
          children: [
            const _HostScreenHeader(eyebrow: 'HOST PROFILE', title: 'Clubs'),
            gapH18,
            if (clubs.isEmpty)
              const _HostEmptyState(
                title: 'No host clubs yet',
                body:
                    'Create a club or accept a host invite to start managing events.',
              )
            else ...[
              if (ownedClubs.isNotEmpty) ...[
                _HostSectionLabel(
                  label: ownedClubs.length == 1 ? 'Owned club' : 'Owned clubs',
                ),
                gapH10,
                for (final club in ownedClubs) ...[
                  _HostClubProfileCard(
                    club: club,
                    currentUid: currentUid,
                    isOwner: true,
                  ),
                  gapH14,
                ],
              ],
              if (hostedClubs.isNotEmpty) ...[
                const _HostSectionLabel(label: 'Host teams'),
                gapH10,
                for (final club in hostedClubs) ...[
                  _HostClubProfileCard(
                    club: club,
                    currentUid: currentUid,
                    isOwner: false,
                  ),
                  gapH14,
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _HostScreenHeader extends StatelessWidget {
  const _HostScreenHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: CatchTextStyles.kicker(context, color: t.ink3)),
        gapH6,
        Text(title, style: CatchTextStyles.headlineS(context)),
      ],
    );
  }
}

class _HostSectionLabel extends StatelessWidget {
  const _HostSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(label, style: CatchTextStyles.kicker(context, color: t.ink3));
  }
}

class _HostEventsClubCard extends ConsumerWidget {
  const _HostEventsClubCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final events = [...?eventsAsync.asData?.value]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final upcoming = events
        .where((event) => !event.isCancelled)
        .take(3)
        .toList(growable: false);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      '${club.area} · ${club.location}',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapH12,
          CatchButton(
            label: 'Add event',
            icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
            onPressed: () => context.pushNamed(
              Routes.hostCreateEventScreen.name,
              pathParameters: {'clubId': club.id},
              extra: club,
            ),
          ),
          gapH14,
          if (eventsAsync.isLoading)
            const CatchLoadingIndicator()
          else if (upcoming.isEmpty)
            Text(
              'No active events yet.',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            )
          else
            for (final event in upcoming) ...[
              _HostEventRow(club: club, event: event),
              if (event != upcoming.last) gapH8,
            ],
        ],
      ),
    );
  }
}

class _HostClubProfileCard extends StatelessWidget {
  const _HostClubProfileCard({
    required this.club,
    required this.currentUid,
    required this.isOwner,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      '${club.area} · ${club.location}',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                    gapH4,
                    Text(
                      isOwner ? 'Owner profile' : 'Host team',
                      style: CatchTextStyles.supporting(context, color: t.ink3),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View public profile',
                onPressed: () => context.pushNamed(
                  Routes.hostClubDetailScreen.name,
                  pathParameters: {'clubId': club.id},
                  extra: club,
                ),
                icon: Icon(CatchIcons.visibilityOutlined),
              ),
            ],
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              if (isOwner)
                CatchButton(
                  label: 'Edit club profile',
                  icon: Icon(CatchIcons.editOutlined, size: CatchIcon.md),
                  onPressed: () => context.pushNamed(
                    Routes.hostEditClubScreen.name,
                    pathParameters: {'clubId': club.id},
                    extra: club,
                  ),
                ),
              CatchButton(
                label: 'View public profile',
                icon: Icon(CatchIcons.visibilityOutlined, size: CatchIcon.md),
                variant: CatchButtonVariant.secondary,
                onPressed: () => context.pushNamed(
                  Routes.hostClubDetailScreen.name,
                  pathParameters: {'clubId': club.id},
                  extra: club,
                ),
              ),
            ],
          ),
          if (isOwner) ...[
            gapH16,
            HostPaymentAccountCard(club: club),
            gapH16,
            HostTeamManagementSection(club: club, currentUid: currentUid),
          ],
        ],
      ),
    );
  }
}

class _HostEventRow extends StatelessWidget {
  const _HostEventRow({required this.club, required this.event});

  final Club club;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    void openManageEvent() {
      context.pushNamed(
        Routes.hostAppEventManageScreen.name,
        pathParameters: {'clubId': club.id, 'eventId': event.id},
        extra: event,
      );
    }

    return Semantics(
      button: true,
      label: 'Manage ${event.title}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: openManageEvent,
        child: CatchSurface(
          padding: CatchInsets.tileContentCompact,
          backgroundColor: t.raised,
          borderColor: t.line,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: CatchTextStyles.labelL(context)),
                    gapH2,
                    Text(
                      event.timeRangeLabel,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Manage event',
                onPressed: openManageEvent,
                icon: Icon(CatchIcons.adminPanelSettingsOutlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostEmptyState extends StatelessWidget {
  const _HostEmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          gapH8,
          Text(body, style: CatchTextStyles.supporting(context, color: t.ink2)),
          gapH18,
          CatchButton(
            label: 'Create club',
            icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
            onPressed: () =>
                context.pushNamed(Routes.hostCreateClubScreen.name),
          ),
        ],
      ),
    );
  }
}

class _HostAuthRequiredScreen extends StatelessWidget {
  const _HostAuthRequiredScreen();

  @override
  Widget build(BuildContext context) {
    return CatchErrorScaffold(
      title: 'Sign in required',
      message: 'Sign in to manage host operations.',
      retryLabel: 'Sign in',
      onRetry: () => context.go(Routes.authScreen.path),
    );
  }
}

class _HostLoadingScreen extends StatelessWidget {
  const _HostLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CatchLoadingIndicator());
  }
}

final _hostClubsForUserProvider = Provider.autoDispose
    .family<AsyncValue<List<Club>>, String>((ref, uid) {
      final hostedAsync = ref.watch(watchClubsHostedByProvider(uid));
      final ownedAsync = ref.watch(watchClubsOwnedByProvider(uid));

      final hosted = hostedAsync.asData?.value;
      final owned = ownedAsync.asData?.value;
      if (hostedAsync.hasError) {
        return AsyncError(
          hostedAsync.error!,
          hostedAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (ownedAsync.hasError) {
        return AsyncError(
          ownedAsync.error!,
          ownedAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (hosted == null || owned == null) return const AsyncLoading();

      final clubsById = <String, Club>{};
      for (final club in hosted) {
        clubsById[club.id] = club;
      }
      for (final club in owned) {
        clubsById[club.id] = club;
      }
      final clubs = clubsById.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return AsyncData(List.unmodifiable(clubs));
    });
