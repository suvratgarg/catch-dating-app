part of '../event_success_companion_screen.dart';

class _CompanionStageScaffold extends StatelessWidget {
  const _CompanionStageScaffold({
    required this.event,
    required this.plan,
    required this.presentation,
    required this.stageTheme,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
    required this.momentKey,
    required this.content,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final _CompanionStageTheme stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;
  final String momentKey;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('eventSuccessCompanionStage'),
      backgroundColor: stageTheme.background,
      body: AnimatedContainer(
        duration: CatchMotion.slow,
        curve: CatchMotion.standardCurve,
        decoration: BoxDecoration(gradient: stageTheme.gradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StageMotifPainter(
                    accent: stageTheme.accent,
                    foreground: stageTheme.foreground,
                    motif: stageTheme.motif,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          CatchSpacing.s4,
                          CatchSpacing.s3,
                          CatchSpacing.s4,
                          CatchSpacing.s5,
                        ),
                        child: _CompanionMomentStage(
                          event: event,
                          plan: plan,
                          presentation: presentation,
                          stageTheme: stageTheme,
                          attended: attended,
                          showSelfCheckIn: showSelfCheckIn,
                          eventEnded: eventEnded,
                          momentKey: momentKey,
                          content: content,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionMomentStage extends StatelessWidget {
  const _CompanionMomentStage({
    required this.event,
    required this.plan,
    required this.presentation,
    required this.stageTheme,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
    required this.momentKey,
    required this.content,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final _CompanionStageTheme stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;
  final String momentKey;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StageNav(foreground: stageTheme.foreground),
        gapH16,
        _CompanionHero(
          event: event,
          plan: plan,
          presentation: presentation,
          stageTheme: stageTheme,
          attended: attended,
          showSelfCheckIn: showSelfCheckIn,
          eventEnded: eventEnded,
        ),
        gapH32,
        _StageGlyph(stageTheme: stageTheme, icon: presentation.icon),
        gapH18,
        AnimatedSwitcher(
          duration: CatchMotion.slow,
          switchInCurve: CatchMotion.standardCurve,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: CatchMotion.standardCurve,
              reverseCurve: Curves.easeInCubic,
            );
            final offset = Tween<Offset>(
              begin: const Offset(0, 0.16),
              end: Offset.zero,
            ).animate(curved);
            final scale = Tween<double>(begin: 0.94, end: 1).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: offset,
                child: ScaleTransition(scale: scale, child: child),
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(momentKey),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  presentation.headline,
                  style: CatchTextStyles.displayL(
                    context,
                    color: stageTheme.foreground,
                  ).copyWith(height: 1.02, letterSpacing: 0),
                ),
                gapH10,
                Text(
                  presentation.body,
                  style: CatchTextStyles.bodyL(
                    context,
                    color: stageTheme.foreground.withValues(alpha: 0.82),
                  ),
                ),
                gapH16,
                _StagePrivacyLine(
                  text: presentation.privacyLine,
                  stageTheme: stageTheme,
                ),
                gapH20,
                content,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StageNav extends StatelessWidget {
  const _StageNav({required this.foreground});

  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final canPop = _companionCanPop(context);
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Back',
          color: canPop ? foreground : foreground.withValues(alpha: 0.36),
          style: IconButton.styleFrom(
            backgroundColor: foreground.withValues(alpha: 0.12),
          ),
          onPressed: canPop ? () => _popCompanion(context) : null,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        gapW8,
        Expanded(
          child: Text(
            'Event companion',
            textAlign: TextAlign.center,
            style: CatchTextStyles.labelL(
              context,
              color: foreground.withValues(alpha: 0.84),
            ),
          ),
        ),
        gapW8,
        SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.radio_button_checked_rounded,
            color: foreground.withValues(alpha: 0.34),
          ),
        ),
      ],
    );
  }
}

class _CompanionHero extends StatelessWidget {
  const _CompanionHero({
    required this.event,
    required this.plan,
    required this.presentation,
    required this.stageTheme,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final _CompanionStageTheme stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;

  @override
  Widget build(BuildContext context) {
    final fg = stageTheme.foreground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchBadge(
              label: _heroBadgeLabel(
                attended: attended,
                showSelfCheckIn: showSelfCheckIn,
                eventEnded: eventEnded,
              ),
              tone: attended ? CatchBadgeTone.success : CatchBadgeTone.live,
              icon: attended ? Icons.check_rounded : Icons.qr_code_2_rounded,
              backgroundColor: fg.withValues(alpha: 0.12),
              foregroundColor: fg,
              borderColor: fg.withValues(alpha: 0.18),
            ),
            CatchBadge(
              label: presentation.badgeLabel,
              tone: presentation.badgeTone,
              icon: presentation.icon,
              backgroundColor: fg.withValues(alpha: 0.12),
              foregroundColor: fg,
              borderColor: fg.withValues(alpha: 0.18),
            ),
          ],
        ),
        gapH14,
        Text(event.title, style: CatchTextStyles.titleL(context, color: fg)),
        gapH4,
        Text(
          '${plan.playbook.title} · ${event.locationName}',
          style: CatchTextStyles.bodyS(
            context,
            color: fg.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _StageGlyph extends StatelessWidget {
  const _StageGlyph({required this.stageTheme, required this.icon});

  final _CompanionStageTheme stageTheme;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: CatchMotion.slow,
      curve: CatchMotion.springCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.92 + (value * 0.08),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: stageTheme.foreground.withValues(alpha: 0.12),
              border: Border.all(
                color: stageTheme.foreground.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: stageTheme.accent.withValues(alpha: 0.24),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: stageTheme.foreground),
          ),
        );
      },
    );
  }
}

class _StagePrivacyLine extends StatelessWidget {
  const _StagePrivacyLine({required this.text, required this.stageTheme});

  final String text;
  final _CompanionStageTheme stageTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CatchSpacing.s3),
      decoration: BoxDecoration(
        color: stageTheme.foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(
          color: stageTheme.foreground.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: stageTheme.foreground.withValues(alpha: 0.82),
          ),
          gapW8,
          Expanded(
            child: Text(
              text,
              style: CatchTextStyles.bodyS(
                context,
                color: stageTheme.foreground.withValues(alpha: 0.82),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionMomentStageContent extends StatelessWidget {
  const _CompanionMomentStageContent({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) gapH12,
          children[index],
        ],
      ],
    );
  }
}

class _StagePanel extends StatelessWidget {
  const _StagePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(color: t.surface.withValues(alpha: 0.26)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: child,
      ),
    );
  }
}

class _StageActionDock extends StatelessWidget {
  const _StageActionDock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.ink.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(color: t.surface.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s2),
        child: child,
      ),
    );
  }
}

class _StageSoftBand extends StatelessWidget {
  const _StageSoftBand({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.primarySoft,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: child,
      ),
    );
  }
}

class _CompanionStageTheme {
  const _CompanionStageTheme({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.gradient,
    required this.motif,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final Gradient gradient;
  final _StageMotif motif;

  static _CompanionStageTheme forMoment(
    BuildContext context, {
    required EventSuccessAttendeeMoment moment,
    required EventSuccessPlan plan,
  }) {
    final t = CatchTokens.of(context);
    final palette = switch (moment.kind) {
      EventSuccessAttendeeMomentKind.preArrival => (
        bg: const Color(0xFF123B46),
        mid: const Color(0xFF2F6E64),
        accent: const Color(0xFFF5B85B),
        motif: _StageMotif.path,
      ),
      EventSuccessAttendeeMomentKind.selfCheckIn => (
        bg: const Color(0xFF173A59),
        mid: const Color(0xFF2D7A89),
        accent: const Color(0xFFFFC85A),
        motif: _StageMotif.gate,
      ),
      EventSuccessAttendeeMomentKind.firstHelloCheckIn => (
        bg: const Color(0xFF3C2A58),
        mid: const Color(0xFFAF5F7E),
        accent: const Color(0xFFFFD166),
        motif: _StageMotif.signal,
      ),
      EventSuccessAttendeeMomentKind.compatibilityQuestionnaire => (
        bg: const Color(0xFF4B244A),
        mid: const Color(0xFFB9486E),
        accent: const Color(0xFFFFD166),
        motif: _StageMotif.spark,
      ),
      EventSuccessAttendeeMomentKind.liveStepContext ||
      EventSuccessAttendeeMomentKind.socialPrompt ||
      EventSuccessAttendeeMomentKind.conversationCues => (
        bg: const Color(0xFF183A37),
        mid: const Color(0xFF4C8D74),
        accent: const Color(0xFFFFB36B),
        motif: _StageMotif.rhythm,
      ),
      EventSuccessAttendeeMomentKind.assignment => (
        bg: const Color(0xFF23345E),
        mid: const Color(0xFF5D5FEF),
        accent: const Color(0xFF72E0C3),
        motif: _StageMotif.orbit,
      ),
      EventSuccessAttendeeMomentKind.liveReveal => (
        bg: plan.revealStatus == EventSuccessRevealStatus.revealed
            ? const Color(0xFF2A245F)
            : const Color(0xFF251B37),
        mid: plan.revealStatus == EventSuccessRevealStatus.revealed
            ? const Color(0xFFAF4D98)
            : const Color(0xFF6B3EA3),
        accent: plan.revealStatus == EventSuccessRevealStatus.revealed
            ? const Color(0xFFFFD166)
            : const Color(0xFF7AE7C7),
        motif: _StageMotif.reveal,
      ),
      EventSuccessAttendeeMomentKind.wingmanRequest => (
        bg: const Color(0xFF26364F),
        mid: const Color(0xFF8A5C8F),
        accent: const Color(0xFFFFC0A4),
        motif: _StageMotif.signal,
      ),
      EventSuccessAttendeeMomentKind.postEvent => (
        bg: const Color(0xFF202A44),
        mid: const Color(0xFF5F5B9E),
        accent: const Color(0xFFFFD166),
        motif: _StageMotif.afterglow,
      ),
      EventSuccessAttendeeMomentKind.none => (
        bg: t.ink,
        mid: Color.lerp(t.ink, t.primary, 0.46)!,
        accent: t.gold,
        motif: _StageMotif.path,
      ),
    };

    return _CompanionStageTheme(
      background: palette.bg,
      foreground: Colors.white,
      accent: palette.accent,
      motif: palette.motif,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          palette.bg,
          Color.lerp(palette.bg, palette.mid, 0.72)!,
          palette.mid,
        ],
      ),
    );
  }
}

enum _StageMotif { path, gate, spark, rhythm, orbit, reveal, signal, afterglow }

class _StageMotifPainter extends CustomPainter {
  const _StageMotifPainter({
    required this.accent,
    required this.foreground,
    required this.motif,
  });

  final Color accent;
  final Color foreground;
  final _StageMotif motif;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = foreground.withValues(alpha: 0.12);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = accent.withValues(alpha: 0.34);

    switch (motif) {
      case _StageMotif.path:
      case _StageMotif.gate:
        for (var i = 0; i < 5; i++) {
          final top = size.height * (0.18 + i * 0.12);
          canvas.drawLine(
            Offset(size.width * -0.08, top),
            Offset(size.width * 1.06, top + size.height * 0.18),
            i == 1 ? accentPaint : paint,
          );
        }
      case _StageMotif.spark:
      case _StageMotif.signal:
        for (var i = 0; i < 18; i++) {
          final x = size.width * (((i * 37) % 100) / 100);
          final y = size.height * (((i * 61) % 100) / 100);
          canvas.drawCircle(
            Offset(x, y),
            i.isEven ? 2.5 : 1.4,
            Paint()
              ..color = (i.isEven ? accent : foreground).withValues(
                alpha: 0.16,
              ),
          );
        }
      case _StageMotif.rhythm:
        final path = Path();
        for (var i = 0; i < 4; i++) {
          final y = size.height * (0.28 + i * 0.14);
          path
            ..moveTo(0, y)
            ..cubicTo(
              size.width * 0.24,
              y - 54,
              size.width * 0.56,
              y + 54,
              size.width,
              y,
            );
        }
        canvas.drawPath(path, paint);
      case _StageMotif.orbit:
      case _StageMotif.reveal:
      case _StageMotif.afterglow:
        final center = Offset(size.width * 0.72, size.height * 0.28);
        for (var i = 0; i < 5; i++) {
          canvas.drawCircle(center, 72 + i * 46, i == 2 ? accentPaint : paint);
        }
        if (motif == _StageMotif.reveal) {
          for (var i = 0; i < 10; i++) {
            final angle = (math.pi * 2 / 10) * i;
            final start = Offset(
              center.dx + math.cos(angle) * 48,
              center.dy + math.sin(angle) * 48,
            );
            final end = Offset(
              center.dx + math.cos(angle) * 180,
              center.dy + math.sin(angle) * 180,
            );
            canvas.drawLine(start, end, accentPaint);
          }
        }
    }
  }

  @override
  bool shouldRepaint(covariant _StageMotifPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.foreground != foreground ||
      oldDelegate.motif != motif;
}

class EventSuccessMomentPresentation {
  const EventSuccessMomentPresentation({
    required this.badgeLabel,
    required this.headline,
    required this.body,
    required this.privacyLine,
    required this.icon,
    required this.badgeTone,
    this.effectKind,
  });

  final String badgeLabel;
  final String headline;
  final String body;
  final String privacyLine;
  final IconData icon;
  final CatchBadgeTone badgeTone;
  final EventSuccessLiveEffectKind? effectKind;

  static EventSuccessMomentPresentation forMoment({
    required Event event,
    required EventSuccessPlan plan,
    required EventSuccessAttendeeMoment moment,
    required bool attended,
    required bool showSelfCheckIn,
    required bool eventEnded,
  }) {
    final step = moment.activeStep;
    return switch (moment.kind) {
      EventSuccessAttendeeMomentKind.preArrival => EventSuccessMomentPresentation(
        badgeLabel: 'Before arrival',
        headline: 'Your event guide is warming up.',
        body:
            'When check-in opens, this screen turns into the live guide for ${event.locationName}.',
        privacyLine:
            'Pre-event details stay informational until the host starts the room.',
        icon: Icons.event_available_outlined,
        badgeTone: CatchBadgeTone.live,
        effectKind: EventSuccessLiveEffectKind.liveEntry,
      ),
      EventSuccessAttendeeMomentKind.selfCheckIn =>
        EventSuccessMomentPresentation(
          badgeLabel: 'Arrival cue',
          headline: 'Check in when you reach the venue.',
          body:
              'One tap tells the host you are in the room and ready for the live flow.',
          privacyLine:
              'Check-in only updates attendance and the event companion flow.',
          icon: Icons.qr_code_2_rounded,
          badgeTone: CatchBadgeTone.warning,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.firstHelloCheckIn =>
        const EventSuccessMomentPresentation(
          badgeLabel: 'First Hello',
          headline: 'Your first arrival mission is live.',
          body:
              'Find one person, ask one tiny question, and let the room start with permission instead of pressure.',
          privacyLine:
              'This checks you in. Hosts do not see the individual answer.',
          icon: Icons.waving_hand_outlined,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.compatibilityQuestionnaire =>
        const EventSuccessMomentPresentation(
          badgeLabel: 'Match clues',
          headline: 'Add a few clues before the room moves.',
          body:
              'Quick answers help Catch shape prompts without turning the event into a form.',
          privacyLine: 'Hosts do not see individual match clue answers.',
          icon: Icons.tune_rounded,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.liveStepContext =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Live now',
          headline: step?.title ?? 'Follow the host for the next beat.',
          body:
              step?.attendeeExperience ??
              'The host is pacing the room from live mode.',
          privacyLine:
              'Everyone sees the same room cue; personal details stay scoped to you.',
          icon: Icons.location_on_outlined,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
        ),
      EventSuccessAttendeeMomentKind.socialPrompt =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Live prompt',
          headline: 'A fresh prompt just dropped.',
          body:
              step?.attendeeExperience ??
              'Use it if the room needs an easy next line.',
          privacyLine:
              'Prompts are shared guidance, not a public record of what you say.',
          icon: Icons.chat_bubble_outline_rounded,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
        ),
      EventSuccessAttendeeMomentKind.conversationCues =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Conversation cues',
          headline: 'Pick a cue and keep the room moving.',
          body:
              step?.attendeeExperience ??
              'These are light nudges for the current event moment.',
          privacyLine:
              'Conversation cues are suggestions only; nothing is sent for you.',
          icon: Icons.forum_outlined,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
        ),
      EventSuccessAttendeeMomentKind.assignment => EventSuccessMomentPresentation(
        badgeLabel: 'Your next group',
        headline: 'Your assignment is ready.',
        body:
            'Use it as a nudge into the next interaction, then let the room breathe.',
        privacyLine: 'Only your own assignment details appear on this screen.',
        icon: Icons.groups_2_outlined,
        badgeTone: CatchBadgeTone.success,
        effectKind: EventSuccessLiveEffectKind.stepChange,
      ),
      EventSuccessAttendeeMomentKind.liveReveal => EventSuccessMomentPresentation(
        badgeLabel: 'Shared reveal',
        headline: _revealHeroHeadline(moment, plan),
        body:
            'The host controls the timing so the room unlocks together instead of leaking awkwardly.',
        privacyLine:
            'Your details stay hidden on this screen until the shared reveal moment.',
        icon: Icons.bolt_rounded,
        badgeTone: CatchBadgeTone.live,
        effectKind: _revealHeroEffect(plan),
      ),
      EventSuccessAttendeeMomentKind.wingmanRequest =>
        const EventSuccessMomentPresentation(
          badgeLabel: 'Host help',
          headline: 'Ask for one specific intro.',
          body:
              'Choose someone you want help meeting and the host can use that as live facilitation context.',
          privacyLine:
              'Only the host sees this request; the other attendee is not notified.',
          icon: Icons.volunteer_activism_outlined,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.stepChange,
        ),
      EventSuccessAttendeeMomentKind.postEvent =>
        const EventSuccessMomentPresentation(
          badgeLabel: 'Afterglow',
          headline: 'Your afterglow is ready.',
          body:
              'Keep the useful parts of the room, send private feedback, and use event-specific openers when a match appears.',
          privacyLine:
              'This recap is private to you. Hosts only see safe aggregate coaching.',
          icon: Icons.nightlight_round,
          badgeTone: CatchBadgeTone.success,
          effectKind: EventSuccessLiveEffectKind.guideComplete,
        ),
      EventSuccessAttendeeMomentKind.none => EventSuccessMomentPresentation(
        badgeLabel: eventEnded
            ? 'Wrapped'
            : attended
            ? 'Live now'
            : 'Booked',
        headline: _heroOrientationLine(
          event: event,
          attended: attended,
          showSelfCheckIn: showSelfCheckIn,
          eventEnded: eventEnded,
        ),
        body:
            'The host is running the room. Your next prompt or reveal appears here when it is time.',
        privacyLine:
            'Catch only shows the live details that are relevant to this event moment.',
        icon: Icons.event_outlined,
        badgeTone: CatchBadgeTone.neutral,
        effectKind: attended ? EventSuccessLiveEffectKind.liveEntry : null,
      ),
    };
  }
}

String _revealHeroHeadline(
  EventSuccessAttendeeMoment moment,
  EventSuccessPlan plan,
) {
  if (plan.revealStatus == EventSuccessRevealStatus.revealed) {
    if (moment.assignmentModuleId ==
        EventSuccessModuleCatalog.guidedRotations.id) {
      return 'Your rotation just unlocked.';
    }
    return 'Your group just unlocked.';
  }
  if (moment.assignmentModuleId ==
      EventSuccessModuleCatalog.guidedRotations.id) {
    return 'A rotation reveal is in motion.';
  }
  return 'A group reveal is in motion.';
}

EventSuccessLiveEffectKind _revealHeroEffect(EventSuccessPlan plan) {
  if (plan.revealStatus == EventSuccessRevealStatus.revealed) {
    return EventSuccessLiveEffectKind.assignmentRevealed;
  }
  return EventSuccessLiveEffectKind.countdownStart;
}

String _heroBadgeLabel({
  required bool attended,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (attended && eventEnded) return 'Event done';
  if (attended) return 'Checked in';
  if (showSelfCheckIn) return 'Check in open';
  return 'Booked';
}

String _heroOrientationLine({
  required Event event,
  required bool attended,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (attended && eventEnded) {
    return 'Thanks for coming. A quick feedback prompt is below.';
  }
  if (attended) {
    return 'You\'re in. Watch this screen for prompts and partner reveals.';
  }
  if (showSelfCheckIn) {
    return 'Glad you\'re coming. Check in when you arrive at ${event.locationName}.';
  }
  return 'Glad you\'re coming. We\'ll guide you here once check-in opens.';
}

class _CompanionStageContentTransition extends StatelessWidget {
  const _CompanionStageContentTransition({
    required this.momentKey,
    required this.child,
  });

  final String momentKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CatchMotion.slow,
      switchInCurve: CatchMotion.standardCurve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: CatchMotion.standardCurve,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(fade);
        final scale = Tween<double>(begin: 0.96, end: 1).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: offset,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(momentKey), child: child),
    );
  }
}

/// Who else can see this card's data. Surfaces a consistent badge across
/// questionnaire, wingman, and feedback so the attendee can tell at a glance
/// what they're putting on the record.
enum _PrivacyAudience { privateToYou, hostCanSee, catchPrivate }

class _PrivacyBadge extends StatelessWidget {
  const _PrivacyBadge(this.audience);

  final _PrivacyAudience audience;

  @override
  Widget build(BuildContext context) {
    return switch (audience) {
      _PrivacyAudience.privateToYou => const CatchBadge(
        label: 'Private to you',
        tone: CatchBadgeTone.neutral,
        icon: Icons.lock_outline_rounded,
      ),
      _PrivacyAudience.hostCanSee => const CatchBadge(
        label: 'Host can see',
        tone: CatchBadgeTone.neutral,
        icon: Icons.visibility_outlined,
      ),
      _PrivacyAudience.catchPrivate => const CatchBadge(
        label: 'Catch private',
        tone: CatchBadgeTone.neutral,
        icon: Icons.shield_outlined,
      ),
    };
  }
}

class _NoCompanionActionsCard extends StatelessWidget {
  const _NoCompanionActionsCard();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return _StagePanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The host is running the room',
                  style: CatchTextStyles.titleS(context),
                ),
                gapH4,
                Text(
                  'Your next prompt or partner reveal will show up here.',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
