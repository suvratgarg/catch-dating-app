import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/publicProfile/domain/public_profile.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    this.horizontalOffsetPercentage = 0,
  });

  final PublicProfile profile;

  /// Horizontal drag progress from CardSwiper (-100 to 100).
  /// Positive = dragging right (like), negative = dragging left (nope).
  final int horizontalOffsetPercentage;

  @override
  Widget build(BuildContext context) {
    final likeOpacity =
        (horizontalOffsetPercentage / 40.0).clamp(0.0, 1.0);
    final nopeOpacity =
        (-horizontalOffsetPercentage / 40.0).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            _ScrollableProfile(
              profile: profile,
              cardHeight: constraints.maxHeight,
            ),
            Positioned(
              top: 48,
              left: 20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: likeOpacity,
                  child: const _SwipeStamp(label: 'LIKE', color: Colors.green),
                ),
              ),
            ),
            Positioned(
              top: 48,
              right: 20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: nopeOpacity,
                  child: const _SwipeStamp(label: 'NOPE', color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ScrollableProfile extends StatelessWidget {
  const _ScrollableProfile({
    required this.profile,
    required this.cardHeight,
  });

  final PublicProfile profile;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final photos = profile.photoUrls;
    final attrs = _buildAttributes(profile);
    final lifestyle = _buildLifestyle(profile);

    return ColoredBox(
      color: const Color(0xFF111111),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First photo: full card height with name + relationship goal overlay
            _PhotoSection(
              url: photos.isNotEmpty ? photos[0] : null,
              height: cardHeight,
              overlayChild: _NameOverlay(profile: profile),
            ),

            // Attribute chips (height, job, education, religion, languages)
            if (attrs.isNotEmpty) _AttributesSection(attrs: attrs),

            // Bio
            if (profile.bio.isNotEmpty) _BioSection(bio: profile.bio),

            // Second photo
            if (photos.length > 1)
              _PhotoSection(url: photos[1], height: cardHeight * 0.75),

            // Lifestyle section
            if (lifestyle.isNotEmpty) _LifestyleSection(items: lifestyle),

            // Third photo onwards
            for (var i = 2; i < photos.length; i++)
              _PhotoSection(url: photos[i], height: cardHeight * 0.75),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

List<({IconData icon, String text})> _buildAttributes(PublicProfile p) {
  final attrs = <({IconData icon, String text})>[];
  if (p.height != null) {
    attrs.add((icon: Icons.straighten_rounded, text: '${p.height} cm'));
  }
  if (p.occupation != null && p.occupation!.isNotEmpty) {
    final label = (p.company != null && p.company!.isNotEmpty)
        ? '${p.occupation} at ${p.company}'
        : p.occupation!;
    attrs.add((icon: Icons.work_outline_rounded, text: label));
  }
  if (p.education != null) {
    attrs.add((icon: Icons.school_outlined, text: p.education!.label));
  }
  if (p.religion != null) {
    attrs.add((icon: Icons.brightness_3_outlined, text: p.religion!.label));
  }
  if (p.languages.isNotEmpty) {
    attrs.add((
      icon: Icons.translate_rounded,
      text: p.languages.map((l) => l.label).join(', '),
    ));
  }
  return attrs;
}

List<({IconData icon, String text})> _buildLifestyle(PublicProfile p) {
  final items = <({IconData icon, String text})>[];
  if (p.drinking != null) {
    items.add((icon: Icons.local_bar_outlined, text: p.drinking!.label));
  }
  if (p.smoking != null) {
    items.add((icon: Icons.smoke_free_rounded, text: p.smoking!.label));
  }
  if (p.workout != null) {
    items.add((icon: Icons.fitness_center_rounded, text: p.workout!.label));
  }
  if (p.diet != null) {
    items.add((icon: Icons.eco_outlined, text: p.diet!.label));
  }
  if (p.children != null) {
    items.add((
      icon: Icons.child_friendly_outlined,
      text: p.children!.label,
    ));
  }
  return items;
}

// ─────────────────────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.url,
    required this.height,
    this.overlayChild,
  });

  final String? url;
  final double height;
  final Widget? overlayChild;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null)
            Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFF2A2A2A)),
            )
          else
            const ColoredBox(color: Color(0xFF2A2A2A)),

          if (overlayChild != null) ...[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1.0],
                  colors: [Colors.transparent, Color(0xD8000000)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 28,
              child: overlayChild!,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NameOverlay extends StatelessWidget {
  const _NameOverlay({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                profile.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '${profile.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        if (profile.relationshipGoal != null) ...[
          const SizedBox(height: 10),
          _GoalPill(goal: profile.relationshipGoal!),
        ],
      ],
    );
  }
}

class _GoalPill extends StatelessWidget {
  const _GoalPill({required this.goal});

  final RelationshipGoal goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8445A).withAlpha(220),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            goal.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AttributesSection extends StatelessWidget {
  const _AttributesSection({required this.attrs});

  final List<({IconData icon, String text})> attrs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final a in attrs) _InfoChip(icon: a.icon, text: a.text),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BioSection extends StatelessWidget {
  const _BioSection({required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ABOUT ME',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LifestyleSection extends StatelessWidget {
  const _LifestyleSection({required this.items});

  final List<({IconData icon, String text})> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIFESTYLE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in items) _InfoChip(icon: i.icon, text: i.text),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: label == 'LIKE' ? -0.3 : 0.3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
