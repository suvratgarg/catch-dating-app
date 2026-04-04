import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_eligibility.dart';
import 'package:catch_dating_app/runClubs/domain/run_club.dart';
import 'package:catch_dating_app/runClubs/presentation/run_club_detail_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_schedule_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RunClubDetailScreen extends ConsumerStatefulWidget {
  const RunClubDetailScreen({super.key, required this.runClub});

  final RunClub runClub;

  @override
  ConsumerState<RunClubDetailScreen> createState() =>
      _RunClubDetailScreenState();
}

class _RunClubDetailScreenState extends ConsumerState<RunClubDetailScreen> {
  // Track selected run by ID so the panel always reflects live Firestore data.
  String? _selectedRunId;

  RunClub get _club => widget.runClub;

  @override
  Widget build(BuildContext context) {
    final runsAsync = ref.watch(runsForClubProvider(_club.id));
    final reviewsAsync = ref.watch(watchReviewsForClubProvider(_club.id));
    final appUser = ref.watch(appUserStreamProvider).asData?.value;
    final uid = ref.watch(uidProvider).asData?.value;
    final isHost = uid != null && uid == _club.hostUserId;
    final isMember = uid != null && _club.memberUserIds.contains(uid);
    final joinMutation = ref.watch(RunClubDetailController.joinMutation);
    final leaveMutation = ref.watch(RunClubDetailController.leaveMutation);
    final isMutating = joinMutation.isPending || leaveMutation.isPending;
    final reviews = reviewsAsync.asData?.value ?? <Review>[];

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: runsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (runs) {
          final selectedRun = _selectedRunId != null
              ? runs.where((r) => r.id == _selectedRunId).firstOrNull
              : null;

          final upcomingCount = runs
              .where((r) => r.startTime.isAfter(DateTime.now()))
              .length;

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    _ClubHeroAppBar(
                      club: _club,
                      isHost: isHost,
                      onScheduleRun: () => context.pushNamed(
                        Routes.createRunScreen.name,
                        pathParameters: {'runClubId': _club.id},
                        extra: _club,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatsStrip(
                              club: _club,
                              upcomingCount: upcomingCount,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _club.description,
                              style: textTheme.bodyLarge,
                            ),
                            if (!isHost) ...[
                              const SizedBox(height: 20),
                              _MembershipButton(
                                clubId: _club.id,
                                isMember: isMember,
                                isMutating: isMutating,
                              ),
                            ],
                            const SizedBox(height: 24),
                            _ReviewsSection(
                              clubId: _club.id,
                              reviews: reviews,
                              currentUid: uid,
                              appUser: appUser,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Schedule',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: RunScheduleGrid(
                        runs: runs,
                        selectedRunId: _selectedRunId,
                        onRunSelected: (run) => setState(
                          () => _selectedRunId =
                              _selectedRunId == run.id ? null : run.id,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: selectedRun == null || appUser == null
                    ? const SizedBox.shrink()
                    : _RunDetailPanel(
                        run: selectedRun,
                        appUser: appUser,
                        onDismiss: () =>
                            setState(() => _selectedRunId = null),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Hero app bar ─────────────────────────────────────────────────────────────

class _ClubHeroAppBar extends StatelessWidget {
  const _ClubHeroAppBar({
    required this.club,
    required this.isHost,
    required this.onScheduleRun,
  });

  final RunClub club;
  final bool isHost;
  final VoidCallback onScheduleRun;

  static const _expandedHeight = 220.0;

  String get _initials => club.name
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: _expandedHeight,
      pinned: true,
      actions: [
        if (isHost)
          IconButton(
            tooltip: 'Schedule a run',
            icon: const Icon(Icons.add),
            onPressed: onScheduleRun,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          club.name,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        background: club.imageUrl != null
            ? Image.network(club.imageUrl!, fit: BoxFit.cover)
            : Container(
                color: colorScheme.primaryContainer,
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.club, required this.upcomingCount});

  final RunClub club;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.location_on_outlined,
            value: club.location.label,
            label: 'City',
          ),
          _StatDivider(),
          _StatItem(
            icon: Icons.people_outline,
            value: '${club.memberUserIds.length}',
            label: 'Members',
          ),
          _StatDivider(),
          _StatItem(
            icon: Icons.directions_run,
            value: '$upcomingCount',
            label: 'Upcoming',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: VerticalDivider(
        color: colorScheme.outlineVariant,
        thickness: 1,
        width: 1,
      ),
    );
  }
}

// ── Membership button ─────────────────────────────────────────────────────────

class _MembershipButton extends ConsumerWidget {
  const _MembershipButton({
    required this.clubId,
    required this.isMember,
    required this.isMutating,
  });

  final String clubId;
  final bool isMember;
  final bool isMutating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMember) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isMutating
              ? null
              : () => RunClubDetailController.leaveMutation.run(
                    ref,
                    (tx) async => tx
                        .get(runClubDetailControllerProvider.notifier)
                        .leave(clubId),
                  ),
          child: isMutating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Leave Club'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isMutating
            ? null
            : () => RunClubDetailController.joinMutation.run(
                  ref,
                  (tx) async => tx
                      .get(runClubDetailControllerProvider.notifier)
                      .join(clubId),
                ),
        child: isMutating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Join Club'),
      ),
    );
  }
}

// ── Run detail panel ──────────────────────────────────────────────────────────

class _RunDetailPanel extends StatelessWidget {
  const _RunDetailPanel({
    required this.run,
    required this.appUser,
    required this.onDismiss,
  });

  final Run run;
  final AppUser appUser;
  final VoidCallback onDismiss;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static String _formatDate(DateTime dt) =>
      '${_weekdays[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]}';

  static String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String _formatDistance(double km) => km == km.roundToDouble()
      ? '${km.round()}km'
      : '${km.toStringAsFixed(1)}km';

  static String _formatPrice(int paise) {
    final rupees = paise / 100;
    return rupees == rupees.roundToDouble()
        ? '₹${rupees.round()}'
        : '₹${rupees.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(run.title, style: textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(run.startTime),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatPrice(run.priceInPaise),
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  text:
                      '${_formatTime(run.startTime)} – ${_formatTime(run.endTime)}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.straighten_outlined,
                  text: '${_formatDistance(run.distanceKm)} · ${run.pace.label}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: run.meetingPoint,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.people_outline,
                  text: run.isFull
                      ? '${run.capacityLimit}/${run.capacityLimit} · Full'
                      : '${run.signedUpCount}/${run.capacityLimit} spots taken',
                ),
                if (run.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.info_outline,
                    text: run.description,
                  ),
                ],
                const SizedBox(height: 20),
                _RunBookingSection(run: run, appUser: appUser),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reviews section ───────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({
    required this.clubId,
    required this.reviews,
    required this.currentUid,
    required this.appUser,
  });

  final String clubId;
  final List<Review> reviews;
  final String? currentUid;
  final AppUser? appUser;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final existingReview = currentUid != null
        ? reviews.where((r) => r.reviewerUserId == currentUid).firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (reviews.isNotEmpty) ...[
              const SizedBox(width: 8),
              StarRating(
                  rating:
                      (reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                              reviews.length)
                          .round(),
                  size: 16),
              const SizedBox(width: 4),
              Text(
                '${(reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length).toStringAsFixed(1)} · ${reviews.length}',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          Text(
            'No reviews yet. Be the first!',
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          )
        else
          ...reviews.take(5).map((r) => _ReviewCard(
                review: r,
                isOwn: r.reviewerUserId == currentUid,
                onEdit: appUser != null
                    ? () => showWriteReviewSheet(
                          context: context,
                          runClubId: clubId,
                          reviewer: appUser!,
                          existingReview: r,
                        )
                    : null,
              )),
        if (appUser != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => showWriteReviewSheet(
                context: context,
                runClubId: clubId,
                reviewer: appUser!,
                existingReview: existingReview,
              ),
              child: Text(
                  existingReview != null ? 'Edit Your Review' : 'Write a Review'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isOwn,
    this.onEdit,
  });

  final Review review;
  final bool isOwn;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRating(rating: review.rating, size: 14),
              const Spacer(),
              if (isOwn && onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(Icons.edit_outlined,
                      size: 16, color: colorScheme.primary),
                )
              else
                Text(
                  review.reviewerName,
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.comment, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 8),
          Divider(height: 1, color: colorScheme.outlineVariant),
        ],
      ),
    );
  }
}

// ── Booking section ───────────────────────────────────────────────────────────

class _RunBookingSection extends ConsumerWidget {
  const _RunBookingSection({required this.run, required this.appUser});

  final Run run;
  final AppUser appUser;

  static String _formatPrice(int paise) {
    final rupees = paise / 100;
    return rupees == rupees.roundToDouble()
        ? '₹${rupees.round()}'
        : '₹${rupees.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = run.statusFor(appUser);
    final bookMutation = ref.watch(RunBookingController.bookMutation);
    final cancelMutation = ref.watch(RunBookingController.cancelMutation);
    final joinWaitlistMutation =
        ref.watch(RunBookingController.joinWaitlistMutation);
    final leaveWaitlistMutation =
        ref.watch(RunBookingController.leaveWaitlistMutation);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Error banner — shows the first active error across all mutations.
    final errorMutation = [
      bookMutation,
      cancelMutation,
      joinWaitlistMutation,
      leaveWaitlistMutation,
    ].firstWhere((m) => m.hasError, orElse: () => bookMutation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMutation.hasError) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: colorScheme.onErrorContainer, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (errorMutation as MutationError).error.toString(),
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        switch (status) {
          RunSignUpStatus.eligible => FilledButton(
              onPressed: bookMutation.isPending
                  ? null
                  : () => RunBookingController.bookMutation.run(
                        ref,
                        (tx) async => tx
                            .get(runBookingControllerProvider.notifier)
                            .book(run: run, user: appUser),
                      ),
              child: _ButtonContent(
                label: run.isFree
                    ? 'Join Free'
                    : 'Book Run  ${_formatPrice(run.priceInPaise)}',
                loading: bookMutation.isPending,
              ),
            ),
          RunSignUpStatus.signedUp => Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: null,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18),
                        SizedBox(width: 6),
                        Text("You're booked"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: cancelMutation.isPending
                      ? null
                      : () => RunBookingController.cancelMutation.run(
                            ref,
                            (tx) async => tx
                                .get(runBookingControllerProvider.notifier)
                                .cancelBooking(run: run, user: appUser),
                          ),
                  child: _ButtonContent(
                    label: 'Cancel',
                    loading: cancelMutation.isPending,
                  ),
                ),
              ],
            ),
          RunSignUpStatus.full => FilledButton(
              onPressed: joinWaitlistMutation.isPending
                  ? null
                  : () => RunBookingController.joinWaitlistMutation.run(
                        ref,
                        (tx) async => tx
                            .get(runBookingControllerProvider.notifier)
                            .joinWaitlist(run: run),
                      ),
              child: _ButtonContent(
                label: 'Join Waitlist',
                loading: joinWaitlistMutation.isPending,
              ),
            ),
          RunSignUpStatus.waitlisted => OutlinedButton(
              onPressed: leaveWaitlistMutation.isPending
                  ? null
                  : () => RunBookingController.leaveWaitlistMutation.run(
                        ref,
                        (tx) async => tx
                            .get(runBookingControllerProvider.notifier)
                            .leaveWaitlist(run: run),
                      ),
              child: _ButtonContent(
                label: 'Leave Waitlist',
                loading: leaveWaitlistMutation.isPending,
              ),
            ),
          RunSignUpStatus.attended => FilledButton.tonal(
              onPressed: null,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_run, size: 18),
                  SizedBox(width: 6),
                  Text('You attended this run'),
                ],
              ),
            ),
          RunSignUpStatus.past => OutlinedButton(
              onPressed: null,
              child: const Text('This run has ended'),
            ),
          RunSignUpStatus.ineligible => OutlinedButton(
              onPressed: null,
              child: Text(
                switch (run.eligibilityFor(appUser)) {
                  AgeTooYoung(:final minAge) =>
                    'Must be at least $minAge to join',
                  AgeTooOld(:final maxAge) => 'Must be $maxAge or younger',
                  GenderCapacityReached() => 'Spots for your gender are full',
                  _ => 'You are not eligible for this run',
                },
              ),
            ),
        },
      ],
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, required this.loading});

  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (loading) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: textTheme.bodyMedium)),
      ],
    );
  }
}
