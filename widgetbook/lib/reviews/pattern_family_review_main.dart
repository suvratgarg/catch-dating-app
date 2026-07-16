import 'package:catch_dating_app/clubs/domain/club.dart' show ClubHostRole;
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart'
    show ClubHostRoleBadge;
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_inline_status.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart'
    show CatchPersonNewMatchDot, CatchPersonUnreadCountPill;
import 'package:catch_dating_app/core/widgets/catch_privacy_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_progress_cue.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart'
    show EventSuccessMetricPill, LiveStepRow;
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart'
    show CountdownBeatRail;
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart'
    show HostTodayClubPill;
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_dating_app/labs/design_fixtures/host_operations_fixtures.dart';
import 'package:flutter/material.dart';

void main() => runApp(const PatternFamilyReviewApp());

class PatternFamilyReviewApp extends StatefulWidget {
  const PatternFamilyReviewApp({super.key});

  @override
  State<PatternFamilyReviewApp> createState() => _PatternFamilyReviewAppState();
}

class _PatternFamilyReviewAppState extends State<PatternFamilyReviewApp> {
  late ThemeMode _themeMode;
  late double _textScale;

  @override
  void initState() {
    super.initState();
    _themeMode = Uri.base.queryParameters['theme'] == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    _textScale = switch (Uri.base.queryParameters['scale']) {
      '1.5' => 1.5,
      '2' => 2,
      _ => 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catch pattern family review',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mediaQuery =
            MediaQuery.maybeOf(context) ?? const MediaQueryData();
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(_textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: PatternFamilyReviewHome(
        themeMode: _themeMode,
        textScale: _textScale,
        onThemeModeChanged: (value) => setState(() => _themeMode = value),
        onTextScaleChanged: (value) => setState(() => _textScale = value),
      ),
    );
  }
}

class PatternFamilyReviewHome extends StatelessWidget {
  const PatternFamilyReviewHome({
    super.key,
    required this.themeMode,
    required this.textScale,
    required this.onThemeModeChanged,
    required this.onTextScaleChanged,
  });

  final ThemeMode themeMode;
  final double textScale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<double> onTextScaleChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final requestedFamily = Uri.base.queryParameters['family'];
    final families = <String, Widget>{
      'badge': _BadgeStatusFamily(tokens: t),
      'controls': const _CompactControlFamily(),
      'identity': const _IdentitySwitcherFamily(),
      'progress': const _ProgressCueFamily(),
    };
    final focusedFamily = families[requestedFamily];
    final visibleFamilies = focusedFamily == null
        ? families.values.toList(growable: false)
        : [focusedFamily];
    final familyList = <Widget>[];
    for (var index = 0; index < visibleFamilies.length; index++) {
      if (index > 0) familyList.add(const SizedBox(height: 32));
      familyList.add(visibleFamilies[index]);
    }
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: focusedFamily == null
                    ? _ReviewHeader(
                        themeMode: themeMode,
                        textScale: textScale,
                        onThemeModeChanged: onThemeModeChanged,
                        onTextScaleChanged: onTextScaleChanged,
                      )
                    : _FocusedReviewHeader(
                        family: requestedFamily!,
                        themeMode: themeMode,
                        textScale: textScale,
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 64),
              sliver: SliverList.list(children: familyList),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusedReviewHeader extends StatelessWidget {
  const _FocusedReviewHeader({
    required this.family,
    required this.themeMode,
    required this.textScale,
  });

  final String family;
  final ThemeMode themeMode;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(
      'FOCUSED REVIEW · ${family.toUpperCase()} · '
      '${themeMode == ThemeMode.dark ? 'DARK' : 'LIGHT'} · $textScale×',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: t.ink3,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.themeMode,
    required this.textScale,
    required this.onThemeModeChanged,
    required this.onTextScaleChanged,
  });

  final ThemeMode themeMode;
  final double textScale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<double> onTextScaleChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WIDGET PATTERN REVIEW',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: t.ink3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'One wall for the remaining consolidation decisions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: t.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'These are production widgets rendered without changing their contracts. '
                'Use the compare page question IDs to approve the strongest pattern, '
                'repair it, or keep a semantic boundary.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: t.ink2),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) => onThemeModeChanged(value.first),
            ),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1×')),
                ButtonSegment(value: 1.5, label: Text('1.5×')),
                ButtonSegment(value: 2, label: Text('2×')),
              ],
              selected: {textScale},
              onSelectionChanged: (value) => onTextScaleChanged(value.first),
            ),
          ],
        ),
      ],
    );
  }
}

class _BadgeStatusFamily extends StatelessWidget {
  const _BadgeStatusFamily({required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return _FamilySection(
      id: 'badge-status · B1–B5',
      title: 'Badge and compact status',
      description:
          'Compare inline status grammar, typed count overlays, dot ingredients, '
          'semantic adapters, and the stronger on-dark treatment.',
      cards: [
        _PreviewCard(
          title: 'CatchBadge grammar',
          note: 'Functional uppercase versus sentence-case metadata.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              CatchBadge.functional(
                label: 'Ready',
                tone: CatchBadgeTone.success,
              ),
              CatchBadge(label: 'Draft'),
              CatchBadge.live(label: 'Live now'),
              CatchBadge.solid(label: '412 members'),
            ],
          ),
        ),
        _PreviewCard(
          title: 'Semantic adapters',
          note: 'Keep domain meaning; converge the underlying chrome.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchPrivacyBadge(),
              ClubHostRoleBadge(role: ClubHostRole.owner),
              EventSuccessMetricPill(label: 'Pacing', value: .78),
              CatchInlineStatus(
                label: 'Unsaved changes',
                tone: CatchInlineStatusTone.warning,
              ),
            ],
          ),
        ),
        _PreviewCard(
          title: 'Numeric overlays',
          note: 'One integer contract hides zero and clamps overflow to 99+.',
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchCountBadge(
                count: 7,
                child: Icon(CatchIcons.notificationsOutlined),
              ),
              CatchCountBadge(
                count: 124,
                child: Icon(CatchIcons.notificationsOutlined),
              ),
              CatchPersonUnreadCountPill(count: 12),
            ],
          ),
        ),
        _PreviewCard(
          title: 'Dot ingredients',
          note: 'One rendering primitive can support feature semantics.',
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const CatchStatusDot(),
              CatchStatusDot(color: tokens.warning),
              const CatchPersonNewMatchDot(),
            ],
          ),
        ),
        _PreviewCard(
          title: 'Retired edge cases',
          note: 'Unused public APIs are removed instead of kept speculatively.',
          child: const Text(
            'The unused rating pill and card-edge sash were removed.',
          ),
        ),
        _PreviewCard(
          title: 'On-dark status',
          note: 'A single shared recipe should absorb feature-owned variants.',
          onDark: true,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge.onDark(label: 'Starts in 2 hours'),
              CatchBadge.onDarkStatus(
                label: 'Preview only',
                icon: CatchIcons.visibilityOutlined,
              ),
              CatchBadge.live(label: 'Live now'),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactControlFamily extends StatelessWidget {
  const _CompactControlFamily();

  @override
  Widget build(BuildContext context) {
    return _FamilySection(
      id: 'floating-compact-controls · C1–C4',
      title: 'Floating compact controls',
      description:
          'The key ergonomic comparison is semantic role plus target size: '
          'labelled and icon-only actions share a 44px default, with a 40px '
          'app-bar navigation exception.',
      cards: [
        _PreviewCard(
          title: 'Labelled floating action',
          note: 'CountPill stays labelled, interactive, and typed for counts.',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchCountPill.label(
                icon: CatchIcons.mapOutlined,
                label: 'Map',
                semanticLabel: 'Show map',
                onPressed: _noop,
              ),
              CatchCountPill.label(
                icon: CatchIcons.tuneRounded,
                label: 'Filters',
                count: 3,
                onPressed: _noop,
              ),
            ],
          ),
        ),
        _PreviewCard(
          title: 'Hit-target comparison',
          note:
              '40px is reserved for app-bar navigation; compact actions default to 44px.',
          child: Wrap(
            spacing: 20,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _MeasuredControl(
                label: '44 label',
                child: CatchCountPill.label(
                  icon: CatchIcons.mapOutlined,
                  label: 'Map',
                  onPressed: _noop,
                ),
              ),
              _MeasuredControl(
                label: '40',
                child: CatchIconButton.icon(
                  icon: CatchIcons.tuneRounded,
                  size: CatchIconButton.navSize,
                  onTap: _noop,
                ),
              ),
              _MeasuredControl(
                label: '44',
                child: CatchIconButton.icon(
                  icon: CatchIcons.tuneRounded,
                  onTap: _noop,
                ),
              ),
            ],
          ),
        ),
        _PreviewCard(
          title: 'Icon-button treatments',
          note: 'One icon-only contract; treatment varies by placement.',
          child: Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              CatchIconButton.icon(icon: CatchIcons.tuneRounded, onTap: _noop),
              CatchIconButton.icon(
                icon: CatchIcons.tuneRounded,
                variant: CatchIconButtonVariant.float,
                onTap: _noop,
              ),
              CatchIconButton.icon(
                icon: CatchIcons.tuneRounded,
                variant: CatchIconButtonVariant.plain,
                onTap: _noop,
              ),
            ],
          ),
        ),
        _PreviewCard(
          title: 'Counted icon action',
          note: 'The canonical icon action owns its typed count badge.',
          child: CatchIconButton.counted(
            icon: CatchIcons.tuneRounded,
            count: 3,
            variant: CatchIconButtonVariant.plain,
            tooltip: '3 active filters',
            onTap: _noop,
          ),
        ),
      ],
    );
  }
}

class _IdentitySwitcherFamily extends StatelessWidget {
  const _IdentitySwitcherFamily();

  @override
  Widget build(BuildContext context) {
    final club = HostOperationsFixtures.primaryClub;
    final logoClub = club.copyWith(
      profileImageUrl:
          'packages/catch_dating_app/assets/fixtures/club_hero_portrait.jpg',
    );
    final clubs = [logoClub, ...HostOperationsFixtures.clubs.skip(1)];
    final longClub = logoClub.copyWith(
      name: 'Sea Face Social With A Deliberately Long Club Name',
    );
    return _FamilySection(
      id: 'identity-switchers · I1–I3',
      title: 'Compact identity switchers',
      description:
          'Compare passive identity, switchable identity, and constrained names. '
          'The semantic question is whether the whole surface becomes one control.',
      cards: [
        _PreviewCard(
          title: 'Single context',
          note: 'Real club art in a stable, intentionally passive surface.',
          child: HostTodayClubPill(
            club: logoClub,
            currentUid: HostOperationsFixtures.hostUid,
            clubs: clubs,
            showClubPicker: false,
            onSwitchClubIndex: (_) {},
          ),
        ),
        _PreviewCard(
          title: 'Switchable context',
          note: 'The whole bounded identity surface opens the club menu.',
          child: HostTodayClubPill(
            club: logoClub,
            currentUid: HostOperationsFixtures.hostUid,
            clubs: clubs,
            showClubPicker: true,
            onSwitchClubIndex: (_) {},
          ),
        ),
        _PreviewCard(
          title: 'Long identity',
          note:
              'Tests whether the 104px label constraint loses too much context.',
          child: HostTodayClubPill(
            club: longClub,
            currentUid: HostOperationsFixtures.hostUid,
            clubs: [longClub, ...clubs.skip(1)],
            showClubPicker: true,
            onSwitchClubIndex: (_) {},
          ),
        ),
      ],
    );
  }
}

class _ProgressCueFamily extends StatelessWidget {
  const _ProgressCueFamily();

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Hold', icon: CatchIcons.panToolAltOutlined),
      (label: 'Watch', icon: CatchIcons.visibilityOutlined),
      (label: 'Move', icon: CatchIcons.boltRounded),
    ];
    final steps = EventSuccessPlaybookLibrary.socialRun.runOfShow
        .take(3)
        .toList();
    return _FamilySection(
      id: 'progress-cues · P1–P3',
      title: 'Compact progress cues',
      description:
          'Compact rails and expanded rows share one future/current/complete '
          'state model while retaining distinct layouts.',
      cards: [
        _PreviewCard(
          title: 'Sequence · upcoming',
          note: 'Early progress keeps the first step current.',
          child: SizedBox(
            width: 360,
            child: CountdownBeatRail(items: items, currentIndex: 0),
          ),
        ),
        _PreviewCard(
          title: 'Sequence · current',
          note: 'Middle progress should distinguish complete from current.',
          child: SizedBox(
            width: 360,
            child: CountdownBeatRail(items: items, currentIndex: 1),
          ),
        ),
        _PreviewCard(
          title: 'Sequence · complete',
          note: 'Completed items use success checks; current alone stays gold.',
          child: SizedBox(
            width: 360,
            child: CountdownBeatRail(items: items, currentIndex: 2),
          ),
        ),
        _PreviewCard(
          title: 'Expanded sibling',
          note:
              'Rows consume the same typed state without sharing rail layout.',
          child: Column(
            children: [
              for (final entry in steps.indexed)
                LiveStepRow(
                  step: entry.$2,
                  state: CatchProgressCueState.fromPosition(
                    index: entry.$1,
                    currentIndex: 1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FamilySection extends StatelessWidget {
  const _FamilySection({
    required this.id,
    required this.title,
    required this.description,
    required this.cards,
  });

  final String id;
  final String title;
  final String description;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          id.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: t.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: t.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.ink2),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                cards[index],
                if (index < cards.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.note,
    required this.child,
    this.onDark = false,
  });

  final String title;
  final String note;
  final Widget child;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final background = onDark ? CatchTokens.editorialBlack : t.surface;
    final foreground = onDark ? CatchTokens.editorialWhite : t.ink;
    final supporting = onDark
        ? CatchTokens.editorialWhite.withValues(alpha: .72)
        : t.ink2;
    return Container(
      width: 400,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: onDark ? CatchTokens.editorialBlack : t.line),
        boxShadow: onDark ? const [] : CatchElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            note,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: supporting),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _MeasuredControl extends StatelessWidget {
  const _MeasuredControl({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          '$label px',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: t.ink3),
        ),
      ],
    );
  }
}

void _noop() {}
