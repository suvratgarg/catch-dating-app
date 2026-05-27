import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_management_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/membership_button.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/stats_strip.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_club_tools.dart';
import 'package:catch_dating_app/payments/presentation/host_payment_account_card.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClubDetailBody extends StatelessWidget {
  const ClubDetailBody({
    super.key,
    required this.club,
    required this.upcoming,
    required this.reviews,
    required this.userProfile,
    required this.uid,
    required this.isHost,
    required this.isMember,
    required this.isMutating,
    required this.clubPushNotificationsEnabled,
    required this.isClubPushMutating,
    required this.isAuthenticated,
  });

  final Club club;
  final List<Event> upcoming;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final String? uid;
  final bool isHost;
  final bool isMember;
  final bool isMutating;
  final bool clubPushNotificationsEnabled;
  final bool isClubPushMutating;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final showMembershipControls = isAuthenticated && !isHost;
    final isOwner = club.isOwnedBy(uid);

    return CustomScrollView(
      slivers: [
        ClubHeroAppBar(club: club, isHost: isHost),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            20,
            CatchSpacing.s5,
            0,
          ),
          sliver: SliverList.list(
            children: [
              StatsStrip(club: club, upcomingCount: upcoming.length),
              gapH16,
              _ClubHostSection(
                club: club,
                canViewProfile: isAuthenticated,
                currentUid: uid,
              ),
              gapH16,
              if (isOwner) ...[
                HostPaymentAccountCard(club: club),
                gapH16,
                _ClubOwnerHostManagementSection(club: club, currentUid: uid!),
                gapH16,
              ],
              if (isHost) ...[
                HostClubManagementPanel(
                  club: club,
                  events: upcoming,
                  onEditClub: () => context.pushNamed(
                    Routes.editClubScreen.name,
                    pathParameters: {'clubId': club.id},
                    extra: club,
                  ),
                  onCreateEvent: () => context.pushNamed(
                    Routes.createEventScreen.name,
                    pathParameters: {'clubId': club.id},
                    extra: club,
                  ),
                ),
                gapH16,
              ],
              Text(
                club.description,
                style: CatchTextStyles.bodyLead(context, color: t.ink2),
              ),
              gapH20,
              if (club.instagramHandle != null ||
                  club.phoneNumber != null ||
                  club.email != null) ...[
                _ClubContactSection(club: club),
                gapH20,
              ],
              if (showMembershipControls)
                MembershipButton(
                  clubId: club.id,
                  isMember: isMember,
                  isMutating: isMutating,
                  pushNotificationsEnabled: clubPushNotificationsEnabled,
                  isPushMutating: isClubPushMutating,
                ),
              if (showMembershipControls) gapH24,
              if (!isAuthenticated) ...[_GuestPrompt(club: club), gapH24],
              gapH24,
            ],
          ),
        ),
        ClubScheduleSection(
          events: upcoming,
          isHost: isHost,
          onEventSelected: (event) => context.pushNamed(
            Routes.eventDetailScreen.name,
            pathParameters: {'clubId': club.id, 'eventId': event.id},
            extra: event,
          ),
        ),
        if (isAuthenticated)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              0,
              CatchSpacing.s5,
              CatchSpacing.s6,
            ),
            sliver: SliverToBoxAdapter(
              child: ClubReviewsSection(
                reviews: reviews,
                currentUid: uid,
                maxVisibleReviews: 3,
              ),
            ),
          ),
      ],
    );
  }
}

class _ClubHostSection extends ConsumerWidget {
  const _ClubHostSection({
    required this.club,
    required this.canViewProfile,
    required this.currentUid,
  });

  final Club club;
  final bool canViewProfile;
  final String? currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final hosts = club.displayHostProfiles;
    final messageMutation = ref.watch(
      ClubHostManagementController.startConversationMutation,
    );

    void openProfile(String uid) {
      context.pushNamed(
        Routes.publicProfileScreen.name,
        pathParameters: {'uid': uid},
      );
    }

    Future<void> messageHost(ClubHostProfile host) async {
      final matchId = await ClubHostManagementController
          .startConversationMutation
          .run(
            ref,
            (tx) => tx
                .get(clubHostManagementControllerProvider.notifier)
                .startConversation(clubId: club.id, hostUid: host.uid),
          );
      if (!context.mounted) return;
      unawaited(
        context.pushNamed(
          Routes.chatScreen.name,
          pathParameters: {'matchId': matchId},
        ),
      );
    }

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final host in hosts) ...[
            Semantics(
              button: canViewProfile,
              label: canViewProfile ? 'View ${host.displayName} profile' : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canViewProfile ? () => openProfile(host.uid) : null,
                child: _ClubHostRow(
                  host: host,
                  borderColor: t.primarySoft,
                  showChevron: canViewProfile,
                  onMessage:
                      canViewProfile &&
                          currentUid != null &&
                          currentUid != host.uid &&
                          !messageMutation.isPending
                      ? () => unawaited(messageHost(host))
                      : null,
                ),
              ),
            ),
            if (host != hosts.last) gapH12,
          ],
        ],
      ),
    );
  }
}

class _ClubHostRow extends StatelessWidget {
  const _ClubHostRow({
    required this.host,
    required this.borderColor,
    required this.showChevron,
    required this.onMessage,
  });

  final ClubHostProfile host;
  final Color borderColor;
  final bool showChevron;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        ClubHostAvatar(
          name: host.displayName,
          imageUrl: host.avatarUrl,
          size: 54,
          borderWidth: 2,
          borderColor: borderColor,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hosted by ${host.displayName}',
                style: CatchTextStyles.titleM(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              gapH6,
              Row(
                children: [
                  ClubHostRoleBadge(role: host.role),
                  gapW8,
                  Expanded(
                    child: Text(
                      showChevron ? 'View profile' : 'Public profile',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onMessage != null) ...[
          gapW8,
          IconButton.filledTonal(
            tooltip: 'Message host',
            onPressed: onMessage,
            icon: Icon(CatchIcons.chatBubbleOutlineRounded, size: 20),
          ),
        ],
        if (showChevron) ...[
          gapW8,
          Icon(CatchIcons.chevronRightRounded, size: 24, color: t.ink3),
        ],
      ],
    );
  }
}

class _ClubOwnerHostManagementSection extends ConsumerWidget {
  const _ClubOwnerHostManagementSection({
    required this.club,
    required this.currentUid,
  });

  final Club club;
  final String currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final hosts = club.displayHostProfiles;
    final addPending = ref
        .watch(ClubHostManagementController.addHostMutation)
        .isPending;
    final removePending = ref
        .watch(ClubHostManagementController.removeHostMutation)
        .isPending;
    final transferPending = ref
        .watch(ClubHostManagementController.transferOwnershipMutation)
        .isPending;
    final actionPending = addPending || removePending || transferPending;

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionHeader(title: 'Host team')),
              IconButton.filledTonal(
                tooltip: 'Add host',
                onPressed: actionPending
                    ? null
                    : () => unawaited(_showAddHostSheet(context)),
                icon: Icon(CatchIcons.personAddAlt1Rounded),
              ),
            ],
          ),
          gapH12,
          for (final host in hosts) ...[
            _OwnerHostRow(
              host: host,
              canManage: host.uid != currentUid && !actionPending,
              onTransfer: () => unawaited(_confirmTransfer(context, ref, host)),
              onRemove: () => unawaited(_confirmRemove(context, ref, host)),
            ),
            if (host != hosts.last) gapH10,
          ],
        ],
      ),
    );
  }

  Future<void> _showAddHostSheet(BuildContext context) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddHostSheet(clubId: club.id),
    );
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Host added.')));
    }
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    ClubHostProfile host,
  ) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Remove host?',
      message:
          '${host.displayName} will stay a club member but will lose host tools.',
      actions: const [
        CatchDialogAction(label: 'Cancel', value: false),
        CatchDialogAction(label: 'Remove', value: true, isDestructive: true),
      ],
    );
    if (confirmed != true) return;

    await ClubHostManagementController.removeHostMutation.run(
      ref,
      (tx) => tx
          .get(clubHostManagementControllerProvider.notifier)
          .removeHost(clubId: club.id, uid: host.uid),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${host.displayName} removed.')));
  }

  Future<void> _confirmTransfer(
    BuildContext context,
    WidgetRef ref,
    ClubHostProfile host,
  ) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Transfer ownership?',
      message:
          '${host.displayName} will become the club owner. You will remain a host.',
      actions: const [
        CatchDialogAction(label: 'Cancel', value: false),
        CatchDialogAction(label: 'Transfer', value: true, isDefault: true),
      ],
    );
    if (confirmed != true) return;

    await ClubHostManagementController.transferOwnershipMutation.run(
      ref,
      (tx) => tx
          .get(clubHostManagementControllerProvider.notifier)
          .transferOwnership(clubId: club.id, uid: host.uid),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ownership transferred to ${host.displayName}.')),
    );
  }
}

class _OwnerHostRow extends StatelessWidget {
  const _OwnerHostRow({
    required this.host,
    required this.canManage,
    required this.onTransfer,
    required this.onRemove,
  });

  final ClubHostProfile host;
  final bool canManage;
  final VoidCallback onTransfer;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        ClubHostAvatar(
          name: host.displayName,
          imageUrl: host.avatarUrl,
          size: 42,
        ),
        gapW10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                host.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH4,
              ClubHostRoleBadge(role: host.role),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Host actions',
          enabled: canManage,
          icon: Icon(CatchIcons.moreHorizRounded, color: t.ink2),
          onSelected: (value) {
            if (value == 'transfer') onTransfer();
            if (value == 'remove') onRemove();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'transfer', child: Text('Transfer ownership')),
            PopupMenuItem(value: 'remove', child: Text('Remove host')),
          ],
        ),
      ],
    );
  }
}

class _AddHostSheet extends ConsumerStatefulWidget {
  const _AddHostSheet({required this.clubId});

  final String clubId;

  @override
  ConsumerState<_AddHostSheet> createState() => _AddHostSheetState();
}

class _AddHostSheetState extends ConsumerState<_AddHostSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty) return;
    await ClubHostManagementController.addHostMutation.run(
      ref,
      (tx) => tx
          .get(clubHostManagementControllerProvider.notifier)
          .addHostByPhone(clubId: widget.clubId, phoneNumber: phone),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(ClubHostManagementController.addHostMutation);

    return CatchBottomSheetScaffold(
      title: 'Add host',
      subtitle: 'Enter the phone number on their Catch profile.',
      keyboardSafe: true,
      action: CatchButton(
        label: 'Add host',
        onPressed: mutation.isPending ? null : () => unawaited(_submit()),
        isLoading: mutation.isPending,
        fullWidth: true,
        icon: Icon(CatchIcons.personAddAlt1Rounded),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchTextField(
            label: 'Phone number',
            controller: _controller,
            prefixIcon: Icon(CatchIcons.phoneOutlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => unawaited(_submit()),
          ),
          if (mutation.hasError) ...[
            gapH12,
            ErrorBanner(message: mutationErrorMessage(mutation)),
          ],
        ],
      ),
    );
  }
}

class _ClubContactSection extends ConsumerWidget {
  const _ClubContactSection({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final links = ref.watch(externalLinkControllerProvider);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Contact', heavy: true),
          gapH12,
          if (club.instagramHandle != null)
            _ContactRow(
              icon: CatchIcons.alternateEmailRounded,
              label: club.instagramHandle!,
              onTap: () => unawaited(
                links.openExternal(_instagramUri(club.instagramHandle!)),
              ),
            ),
          if (club.phoneNumber != null)
            _ContactRow(
              icon: CatchIcons.callOutlined,
              label: club.phoneNumber!,
              onTap: () => unawaited(links.open(_phoneUri(club.phoneNumber!))),
            ),
          if (club.email != null)
            _ContactRow(
              icon: CatchIcons.emailOutlined,
              label: club.email!,
              onTap: () => unawaited(links.open(_emailUri(club.email!))),
            ),
        ],
      ),
    );
  }

  static Uri _instagramUri(String handle) =>
      Uri.parse('https://instagram.com/${handle.replaceFirst('@', '')}');

  static Uri _phoneUri(String phoneNumber) =>
      Uri(scheme: 'tel', path: phoneNumber);

  static Uri _emailUri(String email) => Uri(scheme: 'mailto', path: email);
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: t.primary),
                gapW10,
                Expanded(
                  child: Text(
                    label,
                    style: CatchTextStyles.bodyLead(context, color: t.ink),
                  ),
                ),
                Icon(CatchIcons.openInNewRounded, size: 14, color: t.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  const _GuestPrompt({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            'Sign in to join this club, see member reviews, and connect with the community.',
            style: CatchTextStyles.bodyLead(context, color: t.ink2),
            textAlign: TextAlign.center,
          ),
          gapH12,
          CatchButton(
            label: 'Sign in to join',
            onPressed: () => context.go(
              Uri(
                path: Routes.authScreen.path,
                queryParameters: {'from': '/clubs/${club.id}'},
              ).toString(),
            ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
