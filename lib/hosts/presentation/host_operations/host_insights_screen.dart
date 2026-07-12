part of '../host_operations_screen.dart';

/// Dedicated Host-v2 analytics destination.
///
/// Unlike the legacy Clubs tab, this route requires an exact hosted club match
/// and never falls back to the first organizer in the account.
class HostInsightsScreen extends ConsumerWidget {
  const HostInsightsScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    if (uidAsync.isLoading) {
      return HostLoadingScreen(
        title: context.l10n.hostsHostInsightsScreenTitleInsights,
      );
    }
    if (uidAsync.hasError) {
      return CatchErrorScaffold.fromError(
        uidAsync.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }

    final uid = uidAsync.asData?.value;
    if (uid == null) return const HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return CatchAsyncValueView<List<Club>>(
      value: clubsAsync,
      loadingBuilder: (_) => HostLoadingScreen(
        title: context.l10n.hostsHostInsightsScreenTitleInsights,
      ),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      builder: (context, clubs) {
        final club = clubs
            .where((candidate) => candidate.id == clubId)
            .firstOrNull;
        if (club == null) {
          return HostInsightsUnavailableScreen(onBack: () => _goBack(context));
        }
        return HostInsightsScaffold(
          club: club,
          currentUid: uid,
          onBack: () => _goBack(context),
        );
      },
    );
  }

  void _goBack(BuildContext context) {
    context.goNamed(Routes.hostOrganizerScreen.name);
  }
}

class HostInsightsScaffold extends StatelessWidget {
  const HostInsightsScaffold({
    super.key,
    required this.club,
    required this.currentUid,
    required this.onBack,
  });

  final Club club;
  final String currentUid;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody.copyWith(top: CatchSpacing.s2),
          children: [
            HostInsightsHeader(clubName: club.name, onBack: onBack),
            gapH12,
            HostClubInsightsPane(
              club: club,
              isOwner: club.isOwnedBy(currentUid),
              dedicated: true,
              onOpenEventReport: (eventId) => context.pushNamed(
                Routes.hostAppEventManageScreen.name,
                pathParameters: {
                  context.l10n.hostsHostInsightsScreenBodyClubid: club.id,
                  context.l10n.hostsHostInsightsScreenBodyEventid: eventId,
                },
                queryParameters: {
                  context.l10n.hostsHostInsightsScreenBodySection:
                      context.l10n.hostsHostInsightsScreenBodyReport,
                },
              ),
            ),
            gapH24,
          ],
        ),
      ),
    );
  }
}

class HostInsightsHeader extends StatelessWidget {
  const HostInsightsHeader({
    super.key,
    required this.clubName,
    required this.onBack,
  });

  final String clubName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        CatchIconButton.icon(
          icon: CatchIcons.arrowBackRounded,
          onTap: onBack,
          size: CatchIconButton.navSize,
          tooltip: context.l10n.hostsHostInsightsScreenTooltipBackToOrganizer,
        ),
        const SizedBox(width: CatchSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hostsHostInsightsScreenTextClubnameAllEvents(
                  clubName: clubName,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.kicker(context, color: t.ink3),
              ),
              gapH2,
              Text(
                context.l10n.hostsHostInsightsScreenTextInsights,
                style: CatchTextStyles.titleL(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HostInsightsUnavailableScreen extends StatelessWidget {
  const HostInsightsUnavailableScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: CatchInsets.pageBody,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatchIconButton.icon(
                icon: CatchIcons.arrowBackRounded,
                onTap: onBack,
                size: CatchIconButton.navSize,
                tooltip:
                    context.l10n.hostsHostInsightsScreenTooltipBackToOrganizer,
              ),
              const Spacer(),
              CatchEmptyState(
                icon: CatchIcons.insightsOutlined,
                title: context
                    .l10n
                    .hostsHostInsightsScreenTitleInsightsUnavailable,
                message: context
                    .l10n
                    .hostsHostInsightsScreenMessageThisOrganizerIsNot,
                action: CatchButton(
                  label:
                      context.l10n.hostsHostInsightsScreenLabelBackToOrganizer,
                  onPressed: onBack,
                  variant: CatchButtonVariant.secondary,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
