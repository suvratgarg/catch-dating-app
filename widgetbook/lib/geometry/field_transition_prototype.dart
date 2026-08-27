import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Widgetbook-only interaction study for the proposed unified field surface.
///
/// This deliberately does not change [CatchField]. It is the review boundary
/// for approving the complete press -> active -> closing transition before the
/// same state resolver is moved into the production primitive.
@widgetbook.UseCase(
  name: 'Unified interaction transition prototype',
  type: CatchSection,
  path: '[Geometry system]',
)
Widget fieldTransitionPrototype(BuildContext context) {
  return const _FieldTransitionPrototypePage();
}

class _FieldTransitionPrototypePage extends StatefulWidget {
  const _FieldTransitionPrototypePage();

  @override
  State<_FieldTransitionPrototypePage> createState() =>
      _FieldTransitionPrototypePageState();
}

class _FieldTransitionPrototypePageState
    extends State<_FieldTransitionPrototypePage>
    with SingleTickerProviderStateMixin {
  static const _playbackDuration = Duration(milliseconds: 700);
  static const _replayLeadIn = Duration(milliseconds: 120);

  late final AnimationController _timeline;
  int _replayRun = 0;

  @override
  void initState() {
    super.initState();
    _timeline = AnimationController(vsync: this, duration: _playbackDuration);
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  Future<void> _replay({required bool opening}) async {
    final run = ++_replayRun;
    _timeline.stop();
    _timeline.value = opening ? 0 : 1;
    await Future<void>.delayed(_replayLeadIn);
    if (!mounted || run != _replayRun) return;
    await _timeline.animateTo(
      opening ? 1 : 0,
      duration: _playbackDuration,
      curve: Curves.linear,
    );
  }

  Future<void> _animateTo(double target) async {
    _replayRun++;
    final distance = (target - _timeline.value).abs();
    if (distance == 0) return;
    final duration = Duration(
      milliseconds: math.max(
        140,
        (_playbackDuration.inMilliseconds * distance).round(),
      ),
    );
    await _timeline.animateTo(target, duration: duration, curve: Curves.linear);
  }

  void _setProgress(double progress) {
    _replayRun++;
    _timeline.stop();
    _timeline.value = progress.clamp(0, 1).toDouble();
  }

  void _toggleFromField() {
    unawaited(_animateTo(_timeline.value >= 0.5 ? 0 : 1));
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SingleChildScrollView(
      padding: CatchInsets.pageBody,
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unified field transition',
                style: CatchTextStyles.headline(context, color: t.ink),
              ),
              const SizedBox(height: CatchSpacing.s2),
              Text(
                'Prototype only — production CatchField is unchanged. Replay at normal speed, drag the timeline to inspect any frame, or jump to a named geometry state.',
                style: CatchTextStyles.proseM(context, color: t.ink2),
              ),
              const SizedBox(height: CatchSpacing.s4),
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CatchButton(
                    label: 'Replay opening',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    onPressed: () => unawaited(_replay(opening: true)),
                  ),
                  CatchButton(
                    label: 'Replay closing',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.ghost,
                    onPressed: () => unawaited(_replay(opening: false)),
                  ),
                ],
              ),
              const SizedBox(height: CatchSpacing.s4),
              AnimatedBuilder(
                animation: _timeline,
                builder: (context, _) {
                  final progress = _timeline.value;
                  final nearest = _TransitionStop.nearest(progress);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Timeline · ${nearest.label} · ${(progress * 100).round()}%',
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: t.ink,
                          inactiveTrackColor: t.line,
                          thumbColor: t.ink,
                          overlayColor: t.ink.withValues(alpha: 0.08),
                          trackHeight: CatchStroke.hairline,
                        ),
                        child: Semantics(
                          label: 'Field transition timeline',
                          value:
                              '${nearest.label}, ${(progress * 100).round()}%',
                          child: Slider(
                            value: progress,
                            divisions: 100,
                            onChanged: _setProgress,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: CatchSpacing.s2,
                        runSpacing: CatchSpacing.s2,
                        children: [
                          for (final stop in _TransitionStop.values)
                            CatchChip.selectable(
                              label: stop.label,
                              selected: (progress - stop.progress).abs() < 0.01,
                              onChanged: (_) => _setProgress(stop.progress),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: CatchSpacing.s6),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth >= 900
                      ? (constraints.maxWidth - CatchSpacing.s5) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: CatchSpacing.s5,
                    runSpacing: CatchSpacing.s6,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _TransitionVariant(
                          contained: true,
                          timeline: _timeline,
                          onToggle: _toggleFromField,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _TransitionVariant(
                          contained: false,
                          timeline: _timeline,
                          onToggle: _toggleFromField,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: CatchSpacing.s5),
              Text(
                'The divider remains section-owned and stationary. One opaque interaction surface passes directly from pressed tint to active tint, so the line stays visually consumed throughout the handoff.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TransitionStop {
  resting('Resting', 0),
  pressed('Pressed', 0.24),
  handoff('Handoff', 0.52),
  selected('Selected', 1);

  const _TransitionStop(this.label, this.progress);

  final String label;
  final double progress;

  static _TransitionStop nearest(double progress) {
    return values.reduce(
      (best, candidate) =>
          (candidate.progress - progress).abs() <
              (best.progress - progress).abs()
          ? candidate
          : best,
    );
  }
}

class _TransitionVariant extends StatelessWidget {
  const _TransitionVariant({
    required this.contained,
    required this.timeline,
    required this.onToggle,
  });

  final bool contained;
  final Animation<double> timeline;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final prototypeField = _UnifiedInteractionField(
      contained: contained,
      timeline: timeline,
      onToggle: onToggle,
    );
    final fields = [
      prototypeField,
      _PrototypeStaticField(
        title: 'Location',
        body: 'Carter Road promenade',
        icon: CatchIcons.pinOutlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          contained ? 'Contained section' : 'Divided section',
          style: CatchTextStyles.labelL(context, color: t.ink),
        ),
        const SizedBox(height: CatchSpacing.s1),
        Text(
          contained
              ? 'The section owns the rounded perimeter; the field surface remains rectangular inside its clip.'
              : 'The field owns one rounded surface that covers the adjacent section dividers while engaged.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        const SizedBox(height: CatchSpacing.s3),
        if (contained)
          CatchSection.containedFieldRows(
            title: 'Event settings',
            headerPlacement: CatchSectionFieldHeaderPlacement.internal,
            children: fields,
          )
        else
          CatchSection.fieldRows(
            title: 'Event settings',
            first: true,
            children: fields,
          ),
      ],
    );
  }
}

class _UnifiedInteractionField extends StatefulWidget {
  const _UnifiedInteractionField({
    required this.contained,
    required this.timeline,
    required this.onToggle,
  });

  final bool contained;
  final Animation<double> timeline;
  final VoidCallback onToggle;

  @override
  State<_UnifiedInteractionField> createState() =>
      _UnifiedInteractionFieldState();
}

class _UnifiedInteractionFieldState extends State<_UnifiedInteractionField> {
  Set<String> _selected = const {'Catch Hosts'};

  double _interval(double value, double start, double end) {
    return ((value - start) / (end - start)).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.timeline,
      builder: (context, _) => _buildAtProgress(
        context,
        widget.timeline.value.clamp(0, 1).toDouble(),
      ),
    );
  }

  Widget _buildAtProgress(BuildContext context, double progress) {
    final t = CatchTokens.of(context);
    final containerOwnsGutter =
        CatchFieldGeometryScope.gutterOwnershipOf(context) ==
        CatchFieldGutterOwnership.container;
    final pressIn = Curves.easeOutCubic.transform(
      _interval(progress, 0, _TransitionStop.pressed.progress),
    );
    final pressOut =
        1 -
        Curves.easeInOutCubic.transform(
          _interval(progress, _TransitionStop.handoff.progress, 0.86),
        );
    final pressedAmount = math.min(pressIn, pressOut);
    final activeAmount = CatchFieldTokens.curve.transform(
      _interval(progress, 0.44, 1),
    );
    final reveal = CatchMotion.standardCurve.transform(
      _interval(progress, _TransitionStop.handoff.progress, 1),
    );
    final shadowAmount = CatchFieldTokens.curve.transform(
      _interval(progress, 0.68, 1),
    );
    final engagedAmount = math.max(pressedAmount, activeAmount);
    final rowHorizontalPadding = containerOwnsGutter
        ? 0.0
        : CatchFieldTokens.rowHorizontalPadding;
    final rowPadding = EdgeInsets.fromLTRB(
      rowHorizontalPadding,
      CatchFieldTokens.rowVerticalPadding,
      rowHorizontalPadding,
      CatchFieldTokens.rowVerticalPadding * (1 - reveal),
    );
    final pressedColor = Color.lerp(
      Colors.transparent,
      CatchFieldTokens.pressedSurface(t),
      pressedAmount,
    )!;
    final interactionColor = Color.lerp(
      pressedColor,
      CatchFieldTokens.activeSurface(t),
      activeAmount,
    )!;
    final borderAmount = widget.contained ? activeAmount : engagedAmount;
    final borderColor = Color.lerp(Colors.transparent, t.line, borderAmount)!;
    final shadows = BoxShadow.lerpList(
      CatchElevation.none,
      CatchElevation.fieldActive(Theme.of(context).brightness),
      shadowAmount,
    );
    final overlayBleed = widget.contained
        ? CatchStroke.hairline
        : CatchFieldTokens.dividedRowBleed;
    final active = engagedAmount > 0.04;

    final header = CatchFieldRow.standard(
      padding: rowPadding,
      leading: Icon(
        CatchIcons.hosted,
        size: CatchFieldRow.leadingSlotIconSize,
        color: Color.lerp(t.ink2, t.ink, engagedAmount),
      ),
      trailing: CatchFieldTrailing.custom(
        child: Transform.rotate(
          angle: math.pi * reveal,
          child: Icon(
            CatchIcons.expandMoreRounded,
            size: CatchFieldTokens.disclosureGlyphExtent,
          ),
        ),
      ),
      content: _PrototypeFieldCopy(
        title: 'Host',
        body: 'Catch Hosts',
        active: active,
      ),
    );
    final choices = Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final value in const [
          'Catch Hosts',
          'Sunday Social',
          'Bandra Runs',
        ])
          CatchChip.selectable(
            label: value,
            selected: _selected.contains(value),
            onChanged: (selected) {
              setState(() {
                _selected = selected ? {value} : <String>{};
              });
            },
          ),
      ],
    );

    return Semantics(
      button: true,
      expanded: reveal >= 0.5,
      onTap: widget.onToggle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggle,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PositionedDirectional(
                start: -overlayBleed,
                end: -overlayBleed,
                top: -CatchStroke.hairline,
                bottom: -CatchStroke.hairline,
                child: IgnorePointer(
                  child: DecoratedBox(
                    key: ValueKey(
                      widget.contained
                          ? 'prototype-contained-interaction-surface'
                          : 'prototype-divided-interaction-surface',
                    ),
                    decoration: BoxDecoration(
                      color: engagedAmount > 0.001 ? interactionColor : null,
                      borderRadius: widget.contained
                          ? BorderRadius.zero
                          : BorderRadius.circular(CatchFieldTokens.tileRadius),
                      border: borderAmount > 0.001
                          ? Border.all(color: borderColor)
                          : null,
                      boxShadow: shadowAmount > 0.001
                          ? shadows
                          : CatchElevation.none,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  header,
                  ExcludeSemantics(
                    excluding: reveal < 0.5,
                    child: IgnorePointer(
                      ignoring: reveal < 0.98,
                      child: ClipRect(
                        child: Opacity(
                          opacity: reveal,
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: reveal,
                            child: Transform.translate(
                              offset: Offset(0, CatchSpacing.s2 * (1 - reveal)),
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start:
                                      rowPadding.left +
                                      CatchFieldRow.textLaneInset,
                                  end: rowPadding.right,
                                  top: CatchFieldTokens.controlTopGap,
                                  bottom: CatchFieldTokens.rowVerticalPadding,
                                ),
                                child: choices,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrototypeStaticField extends StatelessWidget {
  const _PrototypeStaticField({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final containerOwnsGutter =
        CatchFieldGeometryScope.gutterOwnershipOf(context) ==
        CatchFieldGutterOwnership.container;
    return CatchFieldRow.standard(
      padding: EdgeInsets.symmetric(
        horizontal: containerOwnsGutter
            ? 0
            : CatchFieldTokens.rowHorizontalPadding,
        vertical: CatchFieldTokens.rowVerticalPadding,
      ),
      leading: Icon(
        icon,
        size: CatchFieldRow.leadingSlotIconSize,
        color: t.ink2,
      ),
      trailing: CatchFieldTrailing.fixedChevron(),
      content: _PrototypeFieldCopy(title: title, body: body, active: false),
    );
  }
}

class _PrototypeFieldCopy extends StatelessWidget {
  const _PrototypeFieldCopy({
    required this.title,
    required this.body,
    required this.active,
  });

  final String title;
  final String body;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style:
              CatchTextStyles.fieldLabel(
                context,
                color: active ? t.ink : t.ink3,
              ).copyWith(
                fontSize: CatchFieldTokens.captionFontSize,
                fontWeight: FontWeight.w500,
                height: CatchFieldTokens.supportLineHeight,
              ),
        ),
        Text(
          body,
          style: CatchTextStyles.fieldRowTitle(context, color: t.ink).copyWith(
            fontSize: CatchFieldTokens.valueFontSize,
            fontWeight: FontWeight.w700,
            height: CatchFieldTokens.valueLineHeight,
          ),
        ),
      ],
    );
  }
}
