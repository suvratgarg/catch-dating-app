import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
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
      data: (clubs) => _HostOperationsScaffold(
        title: 'Host events',
        eyebrow: 'OPERATIONS',
        emptyTitle: 'Create your first club',
        emptyBody:
            'Create a club to publish events, manage attendees, and run Event Success.',
        clubs: clubs,
        showEvents: true,
      ),
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
      data: (clubs) => _HostOperationsScaffold(
        title: 'Clubs',
        eyebrow: 'HOST PROFILE',
        emptyTitle: 'No host clubs yet',
        emptyBody:
            'Create a club or accept a host invite to start managing events.',
        clubs: clubs,
        showEvents: false,
      ),
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
                    style: CatchTextStyles.bodyM(context, color: t.ink2),
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
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(Routes.startScreen.path);
  }
}

class _HostProfilePanel extends ConsumerWidget {
  const _HostProfilePanel({required this.uid, required this.profileAsync});

  final String? uid;
  final AsyncValue<HostProfile?> profileAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final profile = profileAsync.asData?.value;

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
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
              style: CatchTextStyles.bodyM(context, color: t.ink2),
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
              profile.isActive
                  ? 'Active professional profile'
                  : 'Profile pending review',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
        ],
      ),
    );
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

class _HostOperationsScaffold extends StatelessWidget {
  const _HostOperationsScaffold({
    required this.title,
    required this.eyebrow,
    required this.emptyTitle,
    required this.emptyBody,
    required this.clubs,
    required this.showEvents,
  });

  final String title;
  final String eyebrow;
  final String emptyTitle;
  final String emptyBody;
  final List<Club> clubs;
  final bool showEvents;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: CatchTextStyles.kicker(context, color: t.ink3),
                      ),
                      gapH6,
                      Text(title, style: CatchTextStyles.headlineS(context)),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Create club',
                  onPressed: () =>
                      context.pushNamed(Routes.hostCreateClubScreen.name),
                  icon: Icon(CatchIcons.addRounded),
                ),
              ],
            ),
            gapH18,
            if (clubs.isEmpty)
              _HostEmptyState(title: emptyTitle, body: emptyBody)
            else
              for (final club in clubs) ...[
                _HostClubCard(club: club, showEvents: showEvents),
                gapH14,
              ],
          ],
        ),
      ),
    );
  }
}

class _HostClubCard extends ConsumerWidget {
  const _HostClubCard({required this.club, required this.showEvents});

  final Club club;
  final bool showEvents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final eventsAsync = showEvents
        ? ref.watch(watchEventsForClubProvider(club.id))
        : const AsyncData(<Event>[]);
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
              IconButton(
                tooltip: 'Edit club',
                onPressed: () => context.pushNamed(
                  Routes.hostEditClubScreen.name,
                  pathParameters: {'clubId': club.id},
                  extra: club,
                ),
                icon: Icon(CatchIcons.editOutlined),
              ),
            ],
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchButton(
                label: 'Add event',
                icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                onPressed: () => context.pushNamed(
                  Routes.hostCreateEventScreen.name,
                  pathParameters: {'clubId': club.id},
                  extra: club,
                ),
              ),
              CatchButton(
                label: 'View club',
                icon: Icon(CatchIcons.groupsOutlined, size: CatchIcon.md),
                variant: CatchButtonVariant.secondary,
                onPressed: () => context.pushNamed(
                  Routes.hostClubDetailScreen.name,
                  pathParameters: {'clubId': club.id},
                  extra: club,
                ),
              ),
            ],
          ),
          if (showEvents) ...[
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

    return CatchSurface(
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
            onPressed: () => context.pushNamed(
              Routes.hostAppEventManageScreen.name,
              pathParameters: {'clubId': club.id, 'eventId': event.id},
              extra: event,
            ),
            icon: Icon(CatchIcons.adminPanelSettingsOutlined),
          ),
        ],
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
          Text(body, style: CatchTextStyles.bodyM(context, color: t.ink2)),
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
