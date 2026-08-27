import 'dart:async';

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
    extends State<_FieldTransitionPrototypePage> {
  final _containedKey = GlobalKey<_TransitionVariantState>();
  final _dividedKey = GlobalKey<_TransitionVariantState>();
  bool _slowMotion = true;

  double get _speedFactor => _slowMotion ? 4 : 1;

  Future<void> _replayBoth({required bool opening}) async {
    final futures = [
      if (_containedKey.currentState case final state?)
        state.replay(opening: opening),
      if (_dividedKey.currentState case final state?)
        state.replay(opening: opening),
    ];
    await Future.wait(futures);
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
                'Prototype only — production CatchField is unchanged. Press and hold either Host row, release to open it, or replay both variants in slow motion.',
                style: CatchTextStyles.proseM(context, color: t.ink2),
              ),
              const SizedBox(height: CatchSpacing.s4),
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CatchChip.selectable(
                    label: '4× slow motion',
                    selected: _slowMotion,
                    onChanged: (selected) =>
                        setState(() => _slowMotion = selected),
                  ),
                  CatchButton(
                    label: 'Replay opening',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    onPressed: () => _replayBoth(opening: true),
                  ),
                  CatchButton(
                    label: 'Replay closing',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.ghost,
                    onPressed: () => _replayBoth(opening: false),
                  ),
                ],
              ),
              const SizedBox(height: CatchSpacing.s6),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth >= 760
                      ? (constraints.maxWidth - CatchSpacing.s5) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: CatchSpacing.s5,
                    runSpacing: CatchSpacing.s6,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _TransitionVariant(
                          key: _containedKey,
                          contained: true,
                          speedFactor: _speedFactor,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _TransitionVariant(
                          key: _dividedKey,
                          contained: false,
                          speedFactor: _speedFactor,
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

class _TransitionVariant extends StatefulWidget {
  const _TransitionVariant({
    super.key,
    required this.contained,
    required this.speedFactor,
  });

  final bool contained;
  final double speedFactor;

  @override
  State<_TransitionVariant> createState() => _TransitionVariantState();
}

class _TransitionVariantState extends State<_TransitionVariant> {
  final _fieldKey = GlobalKey<_UnifiedInteractionFieldState>();

  Future<void> replay({required bool opening}) async {
    await _fieldKey.currentState?.replay(opening: opening);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final prototypeField = _UnifiedInteractionField(
      key: _fieldKey,
      contained: widget.contained,
      speedFactor: widget.speedFactor,
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
          widget.contained ? 'Contained section' : 'Divided section',
          style: CatchTextStyles.labelL(context, color: t.ink),
        ),
        const SizedBox(height: CatchSpacing.s1),
        Text(
          widget.contained
              ? 'The section owns the rounded perimeter; the field surface remains rectangular inside its clip.'
              : 'The field owns one rounded surface that covers the adjacent section dividers while engaged.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        const SizedBox(height: CatchSpacing.s3),
        if (widget.contained)
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
    super.key,
    required this.contained,
    required this.speedFactor,
  });

  final bool contained;
  final double speedFactor;

  @override
  State<_UnifiedInteractionField> createState() =>
      _UnifiedInteractionFieldState();
}

class _UnifiedInteractionFieldState extends State<_UnifiedInteractionField> {
  bool _pressed = false;
  bool _open = false;
  int _replayRun = 0;
  Set<String> _selected = const {'Catch Hosts'};

  Duration _duration(Duration value) {
    // This review surface must always expose the transition, even when the
    // surrounding Widgetbook preview has reduced motion enabled. Production
    // CatchField continues to respect the user's accessibility preference.
    return Duration(
      microseconds: (value.inMicroseconds * widget.speedFactor).round(),
    );
  }

  Future<void> _wait(Duration value) async {
    await Future<void>.delayed(
      Duration(
        microseconds: (value.inMicroseconds * widget.speedFactor).round(),
      ),
    );
  }

  Future<void> replay({required bool opening}) async {
    final run = ++_replayRun;
    setState(() {
      _pressed = false;
      _open = !opening;
    });
    await _wait(CatchFieldTokens.reveal);
    if (!mounted || run != _replayRun) return;
    setState(() => _pressed = true);
    await _wait(const Duration(milliseconds: 180));
    if (!mounted || run != _replayRun) return;
    setState(() {
      _open = opening;
    });
    await _wait(CatchFieldTokens.pressIn);
    if (!mounted || run != _replayRun) return;
    setState(() => _pressed = false);
  }

  void _toggleOpen() {
    _replayRun++;
    setState(() => _open = !_open);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _replayRun++;
    if (!_pressed) setState(() => _pressed = true);
  }

  void _handlePointerEnd(PointerEvent event) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pressed) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final containerOwnsGutter =
        CatchFieldGeometryScope.gutterOwnershipOf(context) ==
        CatchFieldGutterOwnership.container;
    final rowPadding = EdgeInsets.fromLTRB(
      containerOwnsGutter ? 0 : CatchFieldTokens.rowHorizontalPadding,
      CatchFieldTokens.rowVerticalPadding,
      containerOwnsGutter ? 0 : CatchFieldTokens.rowHorizontalPadding,
      _open ? 0 : CatchFieldTokens.rowVerticalPadding,
    );
    final radius = widget.contained
        ? BorderRadius.zero
        : BorderRadius.circular(CatchFieldTokens.tileRadius);
    final engaged = _pressed || _open;
    final interactionColor = _pressed
        ? CatchFieldTokens.pressedSurface(t)
        : _open
        ? CatchFieldTokens.activeSurface(t)
        : Colors.transparent;
    final border = switch ((widget.contained, _pressed, _open)) {
      (false, true, _) || (false, false, true) => Border.all(color: t.line),
      (true, false, true) => Border.all(color: t.line),
      _ => null,
    };
    final overlayBleed = widget.contained
        ? CatchStroke.hairline
        : CatchFieldTokens.dividedRowBleed;

    final header = CatchFieldRow.standard(
      padding: rowPadding,
      leading: Icon(
        CatchIcons.hosted,
        size: CatchFieldRow.leadingSlotIconSize,
        color: engaged ? t.ink : t.ink2,
      ),
      trailing: CatchFieldTrailing.rotatingChevron(open: _open),
      content: _PrototypeFieldCopy(
        title: 'Host',
        body: 'Catch Hosts',
        active: engaged,
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
      expanded: _open,
      onTap: _toggleOpen,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onExit: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _handlePointerDown,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleOpen,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                PositionedDirectional(
                  start: -overlayBleed,
                  end: -overlayBleed,
                  top: -CatchStroke.hairline,
                  bottom: -CatchStroke.hairline,
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      key: ValueKey(
                        widget.contained
                            ? 'prototype-contained-interaction-surface'
                            : 'prototype-divided-interaction-surface',
                      ),
                      duration: _duration(
                        _pressed
                            ? CatchFieldTokens.pressIn
                            : _open
                            ? CatchFieldTokens.standard
                            : CatchFieldTokens.pressOut,
                      ),
                      curve: CatchFieldTokens.curve,
                      decoration: BoxDecoration(
                        color: interactionColor,
                        borderRadius: radius,
                        border: border,
                        boxShadow: _open && !_pressed
                            ? CatchElevation.fieldActive(
                                Theme.of(context).brightness,
                              )
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
                      excluding: !_open,
                      child: IgnorePointer(
                        ignoring: !_open,
                        child: TweenAnimationBuilder<double>(
                          duration: _duration(CatchFieldTokens.reveal),
                          curve: CatchMotion.standardCurve,
                          tween: Tween<double>(end: _open ? 1 : 0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              start:
                                  rowPadding.left + CatchFieldRow.textLaneInset,
                              end: rowPadding.right,
                              top: CatchFieldTokens.controlTopGap,
                              bottom: CatchFieldTokens.rowVerticalPadding,
                            ),
                            child: choices,
                          ),
                          builder: (context, reveal, child) => ClipRect(
                            child: Opacity(
                              opacity: reveal,
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: reveal,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    CatchSpacing.s2 * (1 - reveal),
                                  ),
                                  child: child,
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
