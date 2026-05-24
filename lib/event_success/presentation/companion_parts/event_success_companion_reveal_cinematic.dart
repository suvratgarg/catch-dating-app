part of '../event_success_companion_screen.dart';

/// Three-phase cinematic for the marquee reveal moment.
///
///  1. Anticipation (3s) — vignette darkens, gold spokes accelerate around a
///     central glyph, particle field drifts inward, ambient bed silenced so
///     `countdown_rise` audio carries the build.
///  2. Climax (1.5s) — white flash, particle field bursts outward with
///     stagger, `reveal_climax` audio fires.
///  3. Settle (0.7s) — vignette releases, particles fade, sunrise palette
///     takes over via the moment-keyed vibe pack on the next build.
///
/// The overlay paints above the motif background but below the content
/// scroll so the hero copy stays legible through the cinematic. It is
/// pointer-transparent the entire time.
class _RevealCinematicOverlay extends StatefulWidget {
  const _RevealCinematicOverlay({
    required this.plan,
    required this.referenceNow,
    required this.momentKind,
    required this.stageTheme,
    required this.checkedInCount,
  });

  final EventSuccessPlan plan;
  final DateTime referenceNow;
  final EventSuccessAttendeeMomentKind momentKind;
  final _CompanionStageTheme stageTheme;

  /// Drives the shared anonymous-dot ring during anticipation. Reinforces
  /// that everyone in the room is watching the same countdown.
  final int checkedInCount;

  @override
  State<_RevealCinematicOverlay> createState() =>
      _RevealCinematicOverlayState();
}

enum _RevealCinematicPhase { idle, anticipation, climax, settle }

class _RevealCinematicOverlayState extends State<_RevealCinematicOverlay>
    with TickerProviderStateMixin {
  // Eager initialization (not `late final`) so the Tickers are created
  // while the State is still mounted. `late final` would defer construction
  // until first access — and dispose() touches them on tear-down, which
  // would re-enter TickerMode lookup against a deactivated element.
  AnimationController? _tick;
  AnimationController? _climax;
  AnimationController? _settle;

  _RevealCinematicPhase _phase = _RevealCinematicPhase.idle;
  late final List<_RevealParticle> _particles = _seedParticles();

  bool _wasCountingDown = false;
  EventSuccessRevealStatus _lastStatus = EventSuccessRevealStatus.idle;

  @override
  void initState() {
    super.initState();
    _tick = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _climax = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _settle = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    if (_kStageAnimationsEnabled) _tick!.repeat();
    _lastStatus = widget.plan.revealStatus;
    _wasCountingDown = _isAnticipationActive();
    _phase = _wasCountingDown
        ? _RevealCinematicPhase.anticipation
        : _RevealCinematicPhase.idle;
  }

  @override
  void didUpdateWidget(covariant _RevealCinematicOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nowCounting = _isAnticipationActive();
    final status = widget.plan.revealStatus;

    // Anticipation engages when the countdown begins.
    if (!_wasCountingDown && nowCounting) {
      setState(() => _phase = _RevealCinematicPhase.anticipation);
    }

    // Climax triggers when the countdown ends with a successful reveal.
    final justRevealed =
        _lastStatus != EventSuccessRevealStatus.revealed &&
        status == EventSuccessRevealStatus.revealed;
    if (justRevealed && _phase != _RevealCinematicPhase.climax) {
      _runClimaxThenSettle();
    }

    // Anticipation can also be aborted (host reset). Drop back to idle
    // without a climax.
    if (_wasCountingDown &&
        !nowCounting &&
        status != EventSuccessRevealStatus.revealed) {
      setState(() => _phase = _RevealCinematicPhase.idle);
    }

    _wasCountingDown = nowCounting;
    _lastStatus = status;
  }

  Future<void> _runClimaxThenSettle() async {
    setState(() => _phase = _RevealCinematicPhase.climax);
    final climax = _climax!;
    final settle = _settle!;
    if (_kStageAnimationsEnabled) {
      await climax.forward(from: 0);
    } else {
      climax.value = 1;
    }
    if (!mounted) return;
    setState(() => _phase = _RevealCinematicPhase.settle);
    if (_kStageAnimationsEnabled) {
      await settle.forward(from: 0);
    } else {
      settle.value = 1;
    }
    if (!mounted) return;
    setState(() => _phase = _RevealCinematicPhase.idle);
  }

  bool _isAnticipationActive() {
    if (widget.momentKind != EventSuccessAttendeeMomentKind.liveReveal) {
      return false;
    }
    return widget.plan.isRevealCountdownRunning(widget.referenceNow);
  }

  /// Anticipation progress 0→1 based on the elapsed countdown window. Used
  /// to accelerate spokes, deepen vignette, and tug particles inward.
  double _anticipationProgress() {
    final started = widget.plan.revealStartedAt;
    final ends = widget.plan.revealEndsAt;
    if (started == null || ends == null) return 0;
    final totalMs = ends.difference(started).inMilliseconds;
    if (totalMs <= 0) return 0;
    final elapsedMs = widget.referenceNow.difference(started).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _tick?.dispose();
    _climax?.dispose();
    _settle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _RevealCinematicPhase.idle) {
      return const SizedBox.shrink();
    }
    final tick = _tick!;
    final climax = _climax!;
    final settle = _settle!;
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([tick, climax, settle]),
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _RevealCinematicPainter(
                phase: _phase,
                anticipation: _anticipationProgress(),
                climaxProgress: climax.value,
                settleProgress: settle.value,
                tickPhase: tick.value,
                accent: widget.stageTheme.accent,
                foreground: widget.stageTheme.foreground,
                particles: _particles,
                checkedInCount: widget.checkedInCount,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Deterministic seed so the field is identical for every viewer of the
  /// same reveal moment — small alignment with co-presence.
  List<_RevealParticle> _seedParticles() {
    final rng = math.Random(424242);
    return List.generate(
      72,
      (index) => _RevealParticle(
        angle: rng.nextDouble() * math.pi * 2,
        distance: 0.32 + rng.nextDouble() * 0.68,
        spinPhase: rng.nextDouble(),
        size: 1.4 + rng.nextDouble() * 2.6,
        chroma: rng.nextDouble(),
        burstAngle: rng.nextDouble() * math.pi * 2,
        burstReach: 0.6 + rng.nextDouble() * 0.6,
      ),
    );
  }
}

class _RevealParticle {
  const _RevealParticle({
    required this.angle,
    required this.distance,
    required this.spinPhase,
    required this.size,
    required this.chroma,
    required this.burstAngle,
    required this.burstReach,
  });

  /// Resting angle around the center, radians.
  final double angle;

  /// Resting distance as fraction of half-width (0 = center, 1 = corner).
  final double distance;

  /// Drift phase 0→1, used to give each particle independent micro-motion.
  final double spinPhase;

  /// Pixel radius of the particle.
  final double size;

  /// 0 = foreground tinted, 1 = accent tinted.
  final double chroma;

  /// Direction of climax burst — slightly randomized from `angle` to keep
  /// the explosion organic.
  final double burstAngle;

  /// How far the particle travels during climax (fraction of half-width).
  final double burstReach;
}

class _RevealCinematicPainter extends CustomPainter {
  const _RevealCinematicPainter({
    required this.phase,
    required this.anticipation,
    required this.climaxProgress,
    required this.settleProgress,
    required this.tickPhase,
    required this.accent,
    required this.foreground,
    required this.particles,
    required this.checkedInCount,
  });

  final _RevealCinematicPhase phase;
  final double anticipation;
  final double climaxProgress;
  final double settleProgress;
  final double tickPhase;
  final Color accent;
  final Color foreground;
  final List<_RevealParticle> particles;
  final int checkedInCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = math.min(size.width, size.height) * 0.62;

    switch (phase) {
      case _RevealCinematicPhase.idle:
        return;
      case _RevealCinematicPhase.anticipation:
        _paintVignette(canvas, size, center, _anticipationVignetteAlpha());
        // Co-presence ring sits BEHIND spokes so the spokes carry the
        // anticipation energy and the room-presence reads as ambient.
        _paintCoPresenceRing(canvas, center, radius);
        _paintSpokes(canvas, center, radius, _anticipationSpokeRotation(),
            _anticipationSpokeAlpha());
        _paintParticles(canvas, size, center, radius);
      case _RevealCinematicPhase.climax:
        // Flash quickly, then ride the burst.
        final flash = math.max(0.0, 1.0 - climaxProgress * 5);
        if (flash > 0) {
          canvas.drawRect(
            Offset.zero & size,
            Paint()..color = Colors.white.withValues(alpha: flash * 0.62),
          );
        }
        _paintVignette(canvas, size, center,
            0.55 * (1 - climaxProgress * 0.6));
        _paintSpokes(canvas, center, radius,
            _anticipationSpokeRotation() + climaxProgress * 1.4,
            (1 - climaxProgress).clamp(0.0, 1.0) * 0.5);
        _paintParticles(canvas, size, center, radius);
      case _RevealCinematicPhase.settle:
        final fade = 1 - settleProgress;
        _paintVignette(canvas, size, center, 0.22 * fade);
        _paintParticles(canvas, size, center, radius);
    }
  }

  double _anticipationVignetteAlpha() => 0.18 + anticipation * 0.42;

  double _anticipationSpokeRotation() {
    // Acceleration curve — spokes start slow, accelerate as anticipation
    // climbs, so the eye feels the build.
    final base = tickPhase * math.pi * 2 * 0.35;
    final accel = math.pow(anticipation, 1.4) * math.pi * 2 * 1.8;
    return base + accel.toDouble();
  }

  double _anticipationSpokeAlpha() => 0.32 + anticipation * 0.48;

  void _paintVignette(
    Canvas canvas,
    Size size,
    Offset center,
    double strength,
  ) {
    if (strength <= 0) return;
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: Alignment(
        (center.dx / size.width) * 2 - 1,
        (center.dy / size.height) * 2 - 1,
      ),
      radius: 0.92,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: strength.clamp(0.0, 1.0)),
      ],
      stops: const [0.34, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  /// Faint ring of anonymous dots representing each checked-in attendee.
  /// All dots pulse on the same `tickPhase` clock, which is itself derived
  /// from a real Ticker — so every attendee's screen pulses on the same
  /// shared rhythm during the countdown.
  void _paintCoPresenceRing(Canvas canvas, Offset center, double radius) {
    if (checkedInCount <= 0) return;
    // Cap visual density. Above 28 we visually stop adding dots but
    // intensity climbs a touch so a large room still reads as "crowded".
    final dotCount = math.min(checkedInCount, 28);
    final ringRadius = radius * 0.66;
    final crowdScale = (checkedInCount / 28).clamp(0.6, 1.4);
    for (var i = 0; i < dotCount; i++) {
      final angle = (math.pi * 2 / dotCount) * i - math.pi / 2;
      final localBeat = math.sin(
        (tickPhase + i / dotCount * 0.5) * math.pi * 2,
      );
      // Soft co-presence breathing: alpha rises with anticipation so the
      // ring intensifies as the countdown closes.
      final alpha =
          (0.18 + 0.16 * anticipation + 0.08 * localBeat) * crowdScale;
      final size = 2.6 + 0.6 * localBeat;
      final position = Offset(
        center.dx + math.cos(angle) * ringRadius,
        center.dy + math.sin(angle) * ringRadius,
      );
      final color = i % 5 == 0 ? accent : foreground;
      canvas.drawCircle(
        position,
        size,
        Paint()..color = color.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }
  }

  void _paintSpokes(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    double alpha,
  ) {
    if (alpha <= 0) return;
    final paint = Paint()
      ..color = accent.withValues(alpha: alpha.clamp(0.0, 1.0))
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    const count = 14;
    for (var i = 0; i < count; i++) {
      final angle = (math.pi * 2 / count) * i;
      final innerR = radius * (0.18 + 0.04 * math.sin(angle * 3 + tickPhase * 8));
      final outerR = radius * (0.92 - 0.05 * math.sin(angle * 2 + tickPhase * 6));
      canvas.drawLine(
        Offset(math.cos(angle) * innerR, math.sin(angle) * innerR),
        Offset(math.cos(angle) * outerR, math.sin(angle) * outerR),
        paint,
      );
    }
    canvas.restore();
  }

  void _paintParticles(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
  ) {
    for (final particle in particles) {
      _paintParticle(canvas, size, center, radius, particle);
    }
  }

  void _paintParticle(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    _RevealParticle particle,
  ) {
    final tickShift = math.sin(
      (tickPhase + particle.spinPhase) * math.pi * 2,
    );

    double progressToCenter;
    double burstOffset;
    double alphaScale;
    switch (phase) {
      case _RevealCinematicPhase.idle:
        return;
      case _RevealCinematicPhase.anticipation:
        // Drift INWARD as anticipation climbs.
        progressToCenter = anticipation;
        burstOffset = 0;
        alphaScale = 0.55 + anticipation * 0.4;
      case _RevealCinematicPhase.climax:
        progressToCenter = 1 - climaxProgress;
        // Quick burst outward — clamped to a sane reach.
        burstOffset = climaxProgress * particle.burstReach * radius * 1.6;
        alphaScale = (1 - climaxProgress).clamp(0.0, 1.0) * 0.95 + 0.18;
      case _RevealCinematicPhase.settle:
        progressToCenter = 0;
        burstOffset = particle.burstReach * radius * 1.6;
        alphaScale = (1 - settleProgress) * 0.4;
    }

    // Resting position interpolated by progressToCenter toward 0.
    final restingDistance = radius * particle.distance;
    final liveDistance = restingDistance * (1 - progressToCenter * 0.78);

    final dx =
        math.cos(particle.angle) * liveDistance +
        math.cos(particle.burstAngle) * burstOffset;
    final dy =
        math.sin(particle.angle) * liveDistance +
        math.sin(particle.burstAngle) * burstOffset +
        tickShift * 3;

    final point = Offset(center.dx + dx, center.dy + dy);
    final color = Color.lerp(foreground, accent, particle.chroma)!;
    canvas.drawCircle(
      point,
      particle.size * (1 + 0.18 * tickShift),
      Paint()..color = color.withValues(alpha: 0.7 * alphaScale.clamp(0.0, 1.0)),
    );
  }

  @override
  bool shouldRepaint(covariant _RevealCinematicPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.anticipation != anticipation ||
        oldDelegate.climaxProgress != climaxProgress ||
        oldDelegate.settleProgress != settleProgress ||
        oldDelegate.tickPhase != tickPhase ||
        oldDelegate.accent != accent ||
        oldDelegate.foreground != foreground ||
        oldDelegate.checkedInCount != checkedInCount;
  }
}
