import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.uid,
    this.initialProfile,
  });

  final String uid;
  final PublicProfile? initialProfile;

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  bool _submitting = false;

  Future<void> _confirmBlock(PublicProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block ${profile.name}?'),
        content: const Text(
          'You will stop seeing each other in chats, matches, swipes, and '
          'future run slots where the other person is already booked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(safetyRepositoryProvider)
          .blockUser(targetUserId: profile.uid, source: 'profile');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${profile.name} has been blocked.')),
      );
      await Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _report(PublicProfile profile) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Sizes.p16,
            0,
            Sizes.p16,
            Sizes.p16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report ${profile.name}',
                style: CatchTextStyles.displaySm(context),
              ),
              gapH12,
              _ReportReasonTile(
                label: 'Harassment or abuse',
                value: 'harassment_or_abuse',
              ),
              _ReportReasonTile(
                label: 'Fake or misleading profile',
                value: 'fake_or_misleading_profile',
              ),
              _ReportReasonTile(
                label: 'Inappropriate content',
                value: 'inappropriate_content',
              ),
              _ReportReasonTile(label: 'Other safety concern', value: 'other'),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(safetyRepositoryProvider)
          .reportUser(
            targetUserId: profile.uid,
            source: 'profile',
            reasonCode: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(publicProfileProvider(widget.uid));
    final profile = profileAsync.asData?.value ?? widget.initialProfile;
    final t = CatchTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(profile?.name ?? 'Profile'),
        actions: [
          if (profile != null)
            PopupMenuButton<String>(
              enabled: !_submitting,
              onSelected: (value) {
                if (value == 'report') {
                  _report(profile);
                } else if (value == 'block') {
                  _confirmBlock(profile);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'report', child: Text('Report')),
                PopupMenuItem(value: 'block', child: Text('Block')),
              ],
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => profile == null
            ? const Center(child: CircularProgressIndicator())
            : _ProfileBody(profile: profile, submitting: _submitting),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p24),
            child: Text(
              'Unable to load this profile.',
              style: CatchTextStyles.bodyMd(context, color: t.ink2),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (loadedProfile) {
          if (loadedProfile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p24),
                child: Text(
                  'This profile is unavailable.',
                  style: CatchTextStyles.bodyMd(context, color: t.ink2),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _ProfileBody(profile: loadedProfile, submitting: _submitting);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile, required this.submitting});

  final PublicProfile profile;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: ProfileCard(profile: profile),
        ),
        if (submitting)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _ReportReasonTile extends StatelessWidget {
  const _ReportReasonTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}
