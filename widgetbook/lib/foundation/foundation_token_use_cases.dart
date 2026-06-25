import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Color roles',
  type: FoundationColorTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationColorRoles(BuildContext context) {
  return const FoundationColorTokens();
}

@widgetbook.UseCase(
  name: 'Spacing and layout',
  type: FoundationSpacingTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationSpacingAndLayout(BuildContext context) {
  return const FoundationSpacingTokens();
}

@widgetbook.UseCase(
  name: 'Radius elevation opacity',
  type: FoundationShapeTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationShapeTokens(BuildContext context) {
  return const FoundationShapeTokens();
}

@widgetbook.UseCase(
  name: 'Typography roles',
  type: FoundationTypographyTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationTypographyRoles(BuildContext context) {
  return const FoundationTypographyTokens();
}

@widgetbook.UseCase(
  name: 'Icons and media geometry',
  type: FoundationIconMediaTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationIconMediaTokens(BuildContext context) {
  return const FoundationIconMediaTokens();
}

@widgetbook.UseCase(
  name: 'Stroke and motion',
  type: FoundationStrokeMotionTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationStrokeMotionTokens(BuildContext context) {
  return const FoundationStrokeMotionTokens();
}

@widgetbook.UseCase(
  name: 'Data pairs and photo grade',
  type: FoundationDataPhotoTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationDataPhotoTokens(BuildContext context) {
  return const FoundationDataPhotoTokens();
}

@widgetbook.UseCase(
  name: 'Wordmark',
  type: FoundationBrandTokens,
  path: '[Foundation tokens]/Core',
)
Widget foundationBrandTokens(BuildContext context) {
  return const FoundationBrandTokens();
}

class FoundationColorTokens extends StatelessWidget {
  const FoundationColorTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Color roles',
      contractId: 'foundation.color',
      states: const ['light', 'dark', 'activity-pigments'],
      children: [
        _DualThemeSection(
          title: 'Semantic roles',
          builder: (context) {
            final t = CatchTokens.of(context);
            return _ColorGrid(
              colors: [
                _ColorSpec('bg', t.bg),
                _ColorSpec('surface', t.surface),
                _ColorSpec('raised', t.raised),
                _ColorSpec('overlay', t.overlay),
                _ColorSpec('ink', t.ink),
                _ColorSpec('ink2', t.ink2),
                _ColorSpec('ink3', t.ink3),
                _ColorSpec('line', t.line),
                _ColorSpec('line2', t.line2),
                _ColorSpec('primary', t.primary),
                _ColorSpec('primaryInk', t.primaryInk),
                _ColorSpec('primarySoft', t.primarySoft),
                _ColorSpec('success', t.success),
                _ColorSpec('warning', t.warning),
                _ColorSpec('danger', t.danger),
                _ColorSpec('gold', t.gold),
              ],
            );
          },
        ),
        _SpecSection(
          title: 'Activity pigments',
          child: _ActivityPigmentGrid(
            kinds: ActivityPalette.activityOrder,
            brightness: Theme.of(context).brightness,
          ),
        ),
      ],
    );
  }
}

class FoundationSpacingTokens extends StatelessWidget {
  const FoundationSpacingTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Spacing and layout',
      contractId: 'foundation.spacing',
      states: const ['scale', 'semantic-gaps', 'insets', 'layout-ratios'],
      children: [
        _SpecSection(
          title: 'Spacing scale',
          child: _MetricStack(
            rows: const [
              _MetricSpec('s0', CatchSpacing.s0),
              _MetricSpec('s1', CatchSpacing.s1),
              _MetricSpec('s2', CatchSpacing.s2),
              _MetricSpec('s3', CatchSpacing.s3),
              _MetricSpec('s4', CatchSpacing.s4),
              _MetricSpec('s5', CatchSpacing.s5),
              _MetricSpec('s6', CatchSpacing.s6),
              _MetricSpec('s7', CatchSpacing.s7),
              _MetricSpec('s8', CatchSpacing.s8),
              _MetricSpec('s9', CatchSpacing.s9),
              _MetricSpec('s10', CatchSpacing.s10),
              _MetricSpec('s11', CatchSpacing.s11),
              _MetricSpec('s12', CatchSpacing.s12),
              _MetricSpec('s16', CatchSpacing.s16),
              _MetricSpec('micro2', CatchSpacing.micro2),
              _MetricSpec('micro3', CatchSpacing.micro3),
              _MetricSpec('micro6', CatchSpacing.micro6),
              _MetricSpec('micro10', CatchSpacing.micro10),
              _MetricSpec('micro14', CatchSpacing.micro14),
              _MetricSpec('micro18', CatchSpacing.micro18),
            ],
          ),
        ),
        _SpecSection(
          title: 'Semantic gaps',
          child: _MetricStack(
            rows: const [
              _MetricSpec('inline', CatchGaps.inline),
              _MetricSpec(
                'headerTitleToSubtitle',
                CatchGaps.headerTitleToSubtitle,
              ),
              _MetricSpec('related', CatchGaps.related),
              _MetricSpec('formField', CatchGaps.formField),
              _MetricSpec('section', CatchGaps.section),
              _MetricSpec('majorSection', CatchGaps.majorSection),
            ],
          ),
        ),
        _SpecSection(
          title: 'Inset roles',
          child: _InsetGrid(
            rows: const [
              _InsetSpec('pageBody', CatchInsets.pageBody),
              _InsetSpec('pageBodyTight', CatchInsets.pageBodyTight),
              _InsetSpec(
                'pageBodyUnderHeader',
                CatchInsets.pageBodyUnderHeader,
              ),
              _InsetSpec('content', CatchInsets.content),
              _InsetSpec('contentDense', CatchInsets.contentDense),
              _InsetSpec('cardContent', CatchInsets.cardContent),
            ],
          ),
        ),
      ],
    );
  }
}

class FoundationShapeTokens extends StatelessWidget {
  const FoundationShapeTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Radius elevation opacity',
      contractId: 'foundation.shape',
      states: const ['radius', 'elevation', 'opacity'],
      children: [
        _SpecSection(
          title: 'Radius scale',
          child: _RadiusGrid(
            rows: const [
              _MetricSpec('none', CatchRadius.none),
              _MetricSpec('xs', CatchRadius.xs),
              _MetricSpec('sm', CatchRadius.sm),
              _MetricSpec('md', CatchRadius.md),
              _MetricSpec('lg', CatchRadius.lg),
              _MetricSpec('infoTile', CatchRadius.infoTile),
              _MetricSpec('interactiveTile', CatchRadius.interactiveTile),
              _MetricSpec('heroCard', CatchRadius.heroCard),
              _MetricSpec('profilePhotoBottom', CatchRadius.profilePhotoBottom),
              _MetricSpec('attendedEventTile', CatchRadius.attendedEventTile),
              _MetricSpec('pill', CatchRadius.pill),
            ],
          ),
        ),
        _SpecSection(title: 'Elevation shadows', child: const _ElevationGrid()),
        _SpecSection(
          title: 'Opacity roles',
          child: _MetricStack(
            maxBarWidth: 180,
            rows: const [
              _MetricSpec('visible', CatchOpacity.visible),
              _MetricSpec('disabledControl', CatchOpacity.disabledControl),
              _MetricSpec('subtleFill', CatchOpacity.subtleFill),
              _MetricSpec('subtleBorder', CatchOpacity.subtleBorder),
              _MetricSpec(
                'controlOverlayHover',
                CatchOpacity.controlOverlayHover,
              ),
              _MetricSpec(
                'controlOverlayPressed',
                CatchOpacity.controlOverlayPressed,
              ),
              _MetricSpec('scrimFill', CatchOpacity.scrimFill),
              _MetricSpec('onFillMuted', CatchOpacity.onFillMuted),
              _MetricSpec('hiddenInput', CatchOpacity.hiddenInput),
            ],
          ),
        ),
      ],
    );
  }
}

class FoundationTypographyTokens extends StatelessWidget {
  const FoundationTypographyTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Typography roles',
      contractId: 'foundation.typography',
      states: const ['voice', 'function', 'data', 'special'],
      children: [
        _SpecSection(
          title: 'Voice and display',
          child: _TypeStack(
            rows: [
              _TypeSpec(
                'display',
                'Host the room, not the chaos',
                CatchTextStyles.display(context),
              ),
              _TypeSpec(
                'headline',
                'Tonight around Bandra',
                CatchTextStyles.headline(context),
              ),
              _TypeSpec(
                'headlineS',
                'Build a better guest list',
                CatchTextStyles.headlineS(context),
              ),
              _TypeSpec(
                'titleL',
                'Professional profile',
                CatchTextStyles.titleL(context),
              ),
              _TypeSpec(
                'profileAnswer',
                'I like events with a clean plan and warm arrival.',
                CatchTextStyles.profileAnswer(context),
              ),
              _TypeSpec(
                'proseL',
                'Write the details hosts and guests need before they commit.',
                CatchTextStyles.proseL(context),
              ),
            ],
          ),
        ),
        _SpecSection(
          title: 'Function text',
          child: _TypeStack(
            rows: [
              _TypeSpec(
                'sectionTitle',
                'Profile',
                CatchTextStyles.sectionTitle(context),
              ),
              _TypeSpec(
                'bodyLead',
                'Review requests before spots are confirmed.',
                CatchTextStyles.bodyLead(context),
              ),
              _TypeSpec(
                'bodyM',
                'Clubs, profile rows, settings, and controls use this register.',
                CatchTextStyles.bodyM(context),
              ),
              _TypeSpec(
                'supporting',
                'Shown below field and row labels.',
                CatchTextStyles.supporting(context),
              ),
              _TypeSpec('labelL', 'CONTINUE', CatchTextStyles.labelL(context)),
              _TypeSpec(
                'buttonMd',
                'Save profile',
                CatchTextStyles.buttonMd(context),
              ),
            ],
          ),
        ),
        _SpecSection(
          title: 'Data and labels',
          child: _TypeStack(
            rows: [
              _TypeSpec('kicker', 'HOST MODE', CatchTextStyles.kicker(context)),
              _TypeSpec(
                'monoLabel',
                '8:30 PM - 24 SPOTS',
                CatchTextStyles.monoLabel(context),
              ),
              _TypeSpec(
                'numericLarge',
                '6/6',
                CatchTextStyles.numericLarge(context),
              ),
              _TypeSpec(
                'numericMeta',
                '7 km - 4 min walk',
                CatchTextStyles.numericMeta(context),
              ),
              _TypeSpec('badge', 'VERIFIED', CatchTextStyles.badge(context)),
              _TypeSpec('code', '4821', CatchTextStyles.code(context)),
            ],
          ),
        ),
      ],
    );
  }
}

class FoundationIconMediaTokens extends StatelessWidget {
  const FoundationIconMediaTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Icons and media geometry',
      contractId: 'foundation.media',
      states: const ['icon-scale', 'aspect-ratio', 'activity-glyphs'],
      children: [
        _SpecSection(
          title: 'Icon scale',
          child: _IconSizeGrid(
            rows: const [
              _MetricSpec('badge', CatchIcon.badge),
              _MetricSpec('micro', CatchIcon.micro),
              _MetricSpec('sm', CatchIcon.sm),
              _MetricSpec('xs', CatchIcon.xs),
              _MetricSpec('md', CatchIcon.md),
              _MetricSpec('control', CatchIcon.control),
              _MetricSpec('row', CatchIcon.row),
              _MetricSpec('tile', CatchIcon.tile),
              _MetricSpec('hero', CatchIcon.hero),
              _MetricSpec('emptyState', CatchIcon.emptyState),
              _MetricSpec('avatarLg', CatchIcon.avatarLg),
              _MetricSpec('lg', CatchIcon.lg),
            ],
          ),
        ),
        _SpecSection(
          title: 'Media aspect ratios',
          child: _AspectRatioGrid(
            rows: const [
              _MetricSpec('square', CatchAspectRatio.square),
              _MetricSpec('wide16x9', CatchAspectRatio.wide16x9),
              _MetricSpec('activityCard', CatchAspectRatio.activityCard),
              _MetricSpec('standardPhoto', CatchAspectRatio.standardPhoto),
              _MetricSpec('portrait4x5', CatchAspectRatio.portrait4x5),
              _MetricSpec('portrait3x4', CatchAspectRatio.portrait3x4),
              _MetricSpec(
                'profileSlotFeedback',
                CatchAspectRatio.profileSlotFeedback,
              ),
              _MetricSpec(
                'eventRecapVibeTile',
                CatchAspectRatio.eventRecapVibeTile,
              ),
            ],
          ),
        ),
        _SpecSection(
          title: 'Activity glyphs',
          child: _ActivityGlyphGrid(kinds: ActivityPalette.activityOrder),
        ),
      ],
    );
  }
}

class FoundationStrokeMotionTokens extends StatelessWidget {
  const FoundationStrokeMotionTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Stroke and motion',
      contractId: 'foundation.motion',
      states: const ['stroke', 'duration', 'curve'],
      children: const [
        _SpecSection(
          title: 'Stroke widths',
          child: _StrokeStack(
            rows: [
              _MetricSpec('hairline', CatchStroke.hairline),
              _MetricSpec('underline', CatchStroke.underline),
              _MetricSpec('clubMemberSeal', CatchStroke.clubMemberSeal),
              _MetricSpec('selection', CatchStroke.selection),
            ],
          ),
        ),
        _SpecSection(
          title: 'Motion durations',
          child: _DurationStack(
            rows: [
              _DurationSpec('fast', CatchMotion.fast),
              _DurationSpec('micro', CatchMotion.micro),
              _DurationSpec('chatScroll', CatchMotion.chatScroll),
              _DurationSpec('base', CatchMotion.base),
              _DurationSpec('pageStep', CatchMotion.pageStep),
              _DurationSpec('calendarScroll', CatchMotion.calendarScroll),
              _DurationSpec('slow', CatchMotion.slow),
              _DurationSpec('pulse', CatchMotion.pulse),
              _DurationSpec('skeletonShimmer', CatchMotion.skeletonShimmer),
            ],
          ),
        ),
        _SpecSection(
          title: 'Motion curves',
          child: _CurveGrid(
            rows: [
              _CurveSpec('standardCurve', CatchMotion.standardCurve),
              _CurveSpec('easeInOutCurve', CatchMotion.easeInOutCurve),
              _CurveSpec('easeOutCubicCurve', CatchMotion.easeOutCubicCurve),
              _CurveSpec('easeOutBackCurve', CatchMotion.easeOutBackCurve),
              _CurveSpec('elasticOutCurve', CatchMotion.elasticOutCurve),
              _CurveSpec('welcomeRevealCurve', CatchMotion.welcomeRevealCurve),
            ],
          ),
        ),
      ],
    );
  }
}

class FoundationDataPhotoTokens extends StatelessWidget {
  const FoundationDataPhotoTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Data pairs and photo grade',
      contractId: 'foundation.photo-data',
      states: const ['data-pair', 'photo-grade', 'light-dark'],
      children: [
        const _SpecSection(
          title: 'Data pair examples',
          child: _DataPairExamples(),
        ),
        _DualThemeSection(
          title: 'Photo grade',
          builder: (context) => _PhotoGradePanel(grade: CatchGrade.of(context)),
        ),
      ],
    );
  }
}

class FoundationBrandTokens extends StatelessWidget {
  const FoundationBrandTokens({super.key});

  @override
  Widget build(BuildContext context) {
    return _FoundationScreen(
      title: 'Wordmark',
      contractId: 'foundation.brand',
      states: const ['typographic', 'light', 'dark'],
      children: const [
        _SpecSection(title: 'Typographic wordmark', child: _WordmarkGrid()),
      ],
    );
  }
}

class _FoundationScreen extends StatelessWidget {
  const _FoundationScreen({
    required this.title,
    required this.contractId,
    required this.states,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<String> states;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.bg,
      child: SingleChildScrollView(
        padding: CatchInsets.pageBodyRelaxed,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge(label: contractId, uppercase: true),
                gapH12,
                Text(title, style: CatchTextStyles.headlineS(context)),
                gapH12,
                Wrap(
                  spacing: CatchSpacing.s3,
                  runSpacing: CatchSpacing.s3,
                  children: [
                    for (final state in states)
                      CatchBadge(
                        label: state,
                        size: CatchBadgeSize.md,
                        tone: CatchBadgeTone.neutral,
                      ),
                  ],
                ),
                gapH24,
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: CatchSpacing.s4),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecSection extends StatelessWidget {
  const _SpecSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      radius: CatchRadius.lg,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          gapH16,
          child,
        ],
      ),
    );
  }
}

class _DualThemeSection extends StatelessWidget {
  const _DualThemeSection({required this.title, required this.builder});

  final String title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return _SpecSection(
      title: title,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final panels = [
            _ThemePanel(name: 'Light', theme: AppTheme.light, builder: builder),
            _ThemePanel(name: 'Dark', theme: AppTheme.dark, builder: builder),
          ];
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final panel in panels) ...[panel, gapH16],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final panel in panels)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: CatchSpacing.s4),
                    child: panel,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemePanel extends StatelessWidget {
  const _ThemePanel({
    required this.name,
    required this.theme,
    required this.builder,
  });

  final String name;
  final ThemeData theme;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: t.bg,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(CatchRadius.md),
            ),
            child: Padding(
              padding: CatchInsets.content,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: CatchTextStyles.kicker(context)),
                  gapH12,
                  builder(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({required this.colors});

  final List<_ColorSpec> colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      children: [for (final color in colors) _ColorTile(spec: color)],
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.spec});

  final _ColorSpec spec;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 132,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(CatchSpacing.s2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: spec.color,
                  border: Border.all(color: t.line2),
                  borderRadius: BorderRadius.circular(CatchRadius.xs),
                ),
              ),
              gapH8,
              Text(spec.name, style: CatchTextStyles.labelM(context)),
              gapH2,
              Text(
                _colorHex(spec.color),
                style: CatchTextStyles.monoLabelS(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityPigmentGrid extends StatelessWidget {
  const _ActivityPigmentGrid({required this.kinds, required this.brightness});

  final List<ActivityKind> kinds;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final palette = ActivityPalette.forBrightness(brightness);
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      children: [
        for (final kind in kinds)
          _ActivityColorTile(activity: palette.getActivity(kind)),
      ],
    );
  }
}

class _ActivityColorTile extends StatelessWidget {
  const _ActivityColorTile({required this.activity});

  final CatchActivity activity;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 170,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: activity.soft,
          border: Border.all(color: activity.deep.withValues(alpha: 0.22)),
          borderRadius: BorderRadius.circular(CatchRadius.md),
        ),
        child: Padding(
          padding: CatchInsets.contentDense,
          child: Row(
            children: [
              Icon(activity.glyph, color: activity.deep, size: CatchIcon.md),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.label,
                      style: CatchTextStyles.labelM(context),
                    ),
                    gapH2,
                    Text(
                      _colorHex(activity.accent),
                      style: CatchTextStyles.monoLabelS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricStack extends StatelessWidget {
  const _MetricStack({required this.rows, this.maxBarWidth = 240});

  final List<_MetricSpec> rows;
  final double maxBarWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
            child: _MetricRow(row: row, maxBarWidth: maxBarWidth),
          ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.row, required this.maxBarWidth});

  final _MetricSpec row;
  final double maxBarWidth;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final barWidth = row.value.clamp(1, maxBarWidth).toDouble();
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(row.name, style: CatchTextStyles.monoLabel(context)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: barWidth,
              height: 12,
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 72,
          child: Text(
            _number(row.value),
            textAlign: TextAlign.end,
            style: CatchTextStyles.numericMeta(context),
          ),
        ),
      ],
    );
  }
}

class _InsetGrid extends StatelessWidget {
  const _InsetGrid({required this.rows});

  final List<_InsetSpec> rows;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      children: [for (final row in rows) _InsetTile(row: row)],
    );
  }
}

class _InsetTile extends StatelessWidget {
  const _InsetTile({required this.row});

  final _InsetSpec row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.raised,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.md),
        ),
        child: Padding(
          padding: CatchInsets.contentDense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.name, style: CatchTextStyles.labelM(context)),
              gapH10,
              Container(
                height: 84,
                padding: row.insets,
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border.all(color: t.line2),
                  borderRadius: BorderRadius.circular(CatchRadius.sm),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.primarySoft,
                    borderRadius: BorderRadius.circular(CatchRadius.xs),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              gapH8,
              Text(
                _edgeInsetsLabel(row.insets),
                style: CatchTextStyles.monoLabelS(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadiusGrid extends StatelessWidget {
  const _RadiusGrid({required this.rows});

  final List<_MetricSpec> rows;

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.where((row) => row.value < 100).toList();
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      children: [for (final row in visibleRows) _RadiusTile(row: row)],
    );
  }
}

class _RadiusTile extends StatelessWidget {
  const _RadiusTile({required this.row});

  final _MetricSpec row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 136,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112,
            height: 72,
            decoration: BoxDecoration(
              color: t.primarySoft,
              border: Border.all(color: t.line2),
              borderRadius: BorderRadius.circular(row.value),
            ),
          ),
          gapH8,
          Text(row.name, style: CatchTextStyles.labelM(context)),
          Text(
            '${_number(row.value)} px',
            style: CatchTextStyles.monoLabelS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _ElevationGrid extends StatelessWidget {
  const _ElevationGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s4,
      runSpacing: CatchSpacing.s4,
      children: const [
        _ElevationTile(name: 'none', shadows: CatchElevation.none),
        _ElevationTile(name: 'card', shadows: CatchElevation.card),
        _ElevationTile(name: 'raised', shadows: CatchElevation.raised),
        _ElevationTile(name: 'overlay', shadows: CatchElevation.overlay),
        _ElevationTile(
          name: 'iconButtonFloat',
          shadows: CatchElevation.iconButtonFloat,
        ),
        _ElevationTile(name: 'toggleKnob', shadows: CatchElevation.toggleKnob),
      ],
    );
  }
}

class _ElevationTile extends StatelessWidget {
  const _ElevationTile({required this.name, required this.shadows});

  final String name;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 64,
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(CatchRadius.md),
              boxShadow: shadows,
            ),
          ),
          gapH10,
          Text(name, style: CatchTextStyles.labelM(context)),
          Text(
            '${shadows.length} shadow${shadows.length == 1 ? '' : 's'}',
            style: CatchTextStyles.monoLabelS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _TypeStack extends StatelessWidget {
  const _TypeStack({required this.rows});

  final List<_TypeSpec> rows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: t.line)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 132,
                      child: Text(
                        row.name,
                        style: CatchTextStyles.monoLabel(context),
                      ),
                    ),
                    Expanded(child: Text(row.sample, style: row.style)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _IconSizeGrid extends StatelessWidget {
  const _IconSizeGrid({required this.rows});

  final List<_MetricSpec> rows;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s4,
      runSpacing: CatchSpacing.s4,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final row in rows)
          SizedBox(
            width: 96,
            child: Column(
              children: [
                Icon(CatchIcons.sparkle, size: row.value),
                gapH8,
                Text(row.name, style: CatchTextStyles.labelM(context)),
                Text(
                  _number(row.value),
                  style: CatchTextStyles.monoLabelS(context),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AspectRatioGrid extends StatelessWidget {
  const _AspectRatioGrid({required this.rows});

  final List<_MetricSpec> rows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Wrap(
      spacing: CatchSpacing.s4,
      runSpacing: CatchSpacing.s4,
      children: [
        for (final row in rows)
          SizedBox(
            width: 148,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: row.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.primarySoft,
                      border: Border.all(color: t.line2),
                      borderRadius: BorderRadius.circular(CatchRadius.sm),
                    ),
                  ),
                ),
                gapH8,
                Text(row.name, style: CatchTextStyles.labelM(context)),
                Text(
                  _number(row.value),
                  style: CatchTextStyles.monoLabelS(context, color: t.ink2),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActivityGlyphGrid extends StatelessWidget {
  const _ActivityGlyphGrid({required this.kinds});

  final List<ActivityKind> kinds;

  @override
  Widget build(BuildContext context) {
    final palette = ActivityPalette.of(context);
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      children: [
        for (final kind in kinds)
          _ActivityGlyphTile(activity: palette.getActivity(kind)),
      ],
    );
  }
}

class _ActivityGlyphTile extends StatelessWidget {
  const _ActivityGlyphTile({required this.activity});

  final CatchActivity activity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: activity.soft,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.all(CatchSpacing.s3),
              child: Icon(
                activity.glyph,
                color: activity.deep,
                size: CatchIcon.lg,
              ),
            ),
          ),
          gapH8,
          Text(
            activity.label,
            textAlign: TextAlign.center,
            style: CatchTextStyles.labelM(context),
          ),
        ],
      ),
    );
  }
}

class _StrokeStack extends StatelessWidget {
  const _StrokeStack({required this.rows});

  final List<_MetricSpec> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
            child: _StrokeRow(row: row),
          ),
      ],
    );
  }
}

class _StrokeRow extends StatelessWidget {
  const _StrokeRow({required this.row});

  final _MetricSpec row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(row.name, style: CatchTextStyles.monoLabel(context)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 32,
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                ),
                child: SizedBox(width: 220, height: row.value),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 72,
          child: Text(
            '${_number(row.value)} px',
            textAlign: TextAlign.end,
            style: CatchTextStyles.numericMeta(context),
          ),
        ),
      ],
    );
  }
}

class _DurationStack extends StatelessWidget {
  const _DurationStack({required this.rows});

  final List<_DurationSpec> rows;

  @override
  Widget build(BuildContext context) {
    final maxMs = rows
        .map((row) => row.duration.inMilliseconds)
        .reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
            child: _DurationRow(row: row, maxMs: maxMs),
          ),
      ],
    );
  }
}

class _DurationRow extends StatelessWidget {
  const _DurationRow({required this.row, required this.maxMs});

  final _DurationSpec row;
  final int maxMs;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final width = (row.duration.inMilliseconds / maxMs * 240).clamp(1, 240);
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(row.name, style: CatchTextStyles.monoLabel(context)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width.toDouble(),
              height: 12,
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 72,
          child: Text(
            '${row.duration.inMilliseconds} ms',
            textAlign: TextAlign.end,
            style: CatchTextStyles.numericMeta(context),
          ),
        ),
      ],
    );
  }
}

class _CurveGrid extends StatelessWidget {
  const _CurveGrid({required this.rows});

  final List<_CurveSpec> rows;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s4,
      runSpacing: CatchSpacing.s4,
      children: [for (final row in rows) _CurveTile(row: row)],
    );
  }
}

class _CurveTile extends StatelessWidget {
  const _CurveTile({required this.row});

  final _CurveSpec row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.raised,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.md),
        ),
        child: Padding(
          padding: CatchInsets.contentDense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 84,
                child: CustomPaint(
                  painter: _CurvePainter(curve: row.curve, tokens: t),
                  child: const SizedBox.expand(),
                ),
              ),
              gapH10,
              Text(row.name, style: CatchTextStyles.labelM(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  const _CurvePainter({required this.curve, required this.tokens});

  final Curve curve;
  final CatchTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = tokens.line
      ..strokeWidth = CatchStroke.hairline;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      gridPaint,
    );
    canvas.drawLine(Offset.zero, Offset(0, size.height), gridPaint);

    final path = Path();
    for (var i = 0; i <= 24; i++) {
      final x = i / 24;
      final y = curve.transform(x.clamp(0, 1));
      final point = Offset(x * size.width, (1 - y) * size.height);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    final curvePaint = Paint()
      ..color = tokens.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = CatchStroke.selection;
    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(_CurvePainter oldDelegate) =>
      oldDelegate.curve != curve || oldDelegate.tokens != tokens;
}

class _DataPairExamples extends StatelessWidget {
  const _DataPairExamples();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        CatchStatStrip(
          items: [
            CatchStatStripItem(value: '24', label: 'Spots'),
            CatchStatStripItem(value: '8:30', label: 'Starts'),
            CatchStatStripItem(value: '6 km', label: 'Away'),
          ],
        ),
        gapH16,
        CatchStatStrip(
          items: [
            CatchStatStripItem(value: '4.8', label: 'Rating'),
            CatchStatStripItem(value: '126', label: 'Guests'),
            CatchStatStripItem(value: '12', label: 'Hosts'),
            CatchStatStripItem(value: '3', label: 'Rooms'),
          ],
        ),
      ],
    );
  }
}

class _PhotoGradePanel extends StatelessWidget {
  const _PhotoGradePanel({required this.grade});

  final CatchGrade grade;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CatchSpacing.s4,
          runSpacing: CatchSpacing.s4,
          children: const [
            _PhotoGradeTile(label: 'Raw sample', enabled: false),
            _PhotoGradeTile(label: 'Catch grade', enabled: true),
          ],
        ),
        gapH16,
        _MetricStack(
          maxBarWidth: 160,
          rows: [
            _MetricSpec('saturation', grade.saturation),
            _MetricSpec('contrast', grade.contrast),
            _MetricSpec('brightness', grade.brightness),
            _MetricSpec('grainOpacity', grade.grainOpacity),
          ],
        ),
        gapH12,
        _ColorGrid(
          colors: [
            _ColorSpec('warmShadow', grade.warmShadow),
            _ColorSpec('warmHighlight', grade.warmHighlight),
          ],
        ),
      ],
    );
  }
}

class _PhotoGradeTile extends StatelessWidget {
  const _PhotoGradeTile({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.md),
            child: CatchGradedImage(
              enabled: enabled,
              child: const AspectRatio(
                aspectRatio: CatchAspectRatio.portrait4x5,
                child: _PhotoGradeSample(),
              ),
            ),
          ),
          gapH8,
          Text(label, style: CatchTextStyles.labelM(context)),
          Text(
            enabled ? 'display-time grade' : 'ungraded source',
            style: CatchTextStyles.monoLabelS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _PhotoGradeSample extends StatelessWidget {
  const _PhotoGradeSample();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7BC6A4),
            Color(0xFFFFD166),
            Color(0xFFE76F51),
            Color(0xFF213547),
          ],
          stops: [0, 0.38, 0.68, 1],
        ),
      ),
      child: CustomPaint(painter: const _PhotoGradeSamplePainter()),
    );
  }
}

class _PhotoGradeSamplePainter extends CustomPainter {
  const _PhotoGradeSamplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x99FFF7ED);
    canvas.drawCircle(
      Offset(size.width * 0.70, size.height * 0.22),
      size.shortestSide * 0.18,
      paint,
    );
    paint.color = const Color(0x661A140F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.56,
          size.width * 0.76,
          size.height * 0.26,
        ),
        const Radius.circular(CatchRadius.md),
      ),
      paint,
    );
    paint.color = const Color(0x55FFFFFF);
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.18 + i * 0.15);
      canvas.drawCircle(Offset(x, size.height * 0.42), 3, paint);
    }
  }

  @override
  bool shouldRepaint(_PhotoGradeSamplePainter oldDelegate) => false;
}

class _WordmarkGrid extends StatelessWidget {
  const _WordmarkGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s4,
      runSpacing: CatchSpacing.s4,
      children: const [
        _WordmarkTile(label: 'Plain', child: _CatchWordmark()),
        _WordmarkTile(label: 'Dotted', child: _CatchWordmark(showDot: true)),
        _WordmarkTile(label: 'Dark', dark: true, child: _CatchWordmark()),
      ],
    );
  }
}

class _WordmarkTile extends StatelessWidget {
  const _WordmarkTile({
    required this.label,
    required this.child,
    this.dark = false,
  });

  final String label;
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final theme = dark ? AppTheme.dark : Theme.of(context);
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return SizedBox(
            width: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: dark ? t.bg : t.surface,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(CatchRadius.md),
              ),
              child: Padding(
                padding: CatchInsets.content,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 76, child: Align(child: child)),
                    gapH10,
                    Text(label, style: CatchTextStyles.labelM(context)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatchWordmark extends StatelessWidget {
  const _CatchWordmark({this.showDot = false});

  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final style = CatchTextStyles.display(context, color: t.ink);
    if (!showDot) return Text('Catch', style: style);
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'Catch'),
          TextSpan(
            text: '.',
            style: style.copyWith(color: t.primary),
          ),
        ],
      ),
    );
  }
}

class _ColorSpec {
  const _ColorSpec(this.name, this.color);

  final String name;
  final Color color;
}

class _MetricSpec {
  const _MetricSpec(this.name, this.value);

  final String name;
  final double value;
}

class _DurationSpec {
  const _DurationSpec(this.name, this.duration);

  final String name;
  final Duration duration;
}

class _CurveSpec {
  const _CurveSpec(this.name, this.curve);

  final String name;
  final Curve curve;
}

class _InsetSpec {
  const _InsetSpec(this.name, this.insets);

  final String name;
  final EdgeInsets insets;
}

class _TypeSpec {
  const _TypeSpec(this.name, this.sample, this.style);

  final String name;
  final String sample;
  final TextStyle style;
}

String _colorHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

String _number(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

String _edgeInsetsLabel(EdgeInsets insets) {
  return 'L${_number(insets.left)} T${_number(insets.top)} '
      'R${_number(insets.right)} B${_number(insets.bottom)}';
}
