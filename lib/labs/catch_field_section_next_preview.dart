// TEMPORARY REVIEW PREVIEW.
//
// This app renders the isolated field/section prototype against the exact
// profile-edit state supplied for review. It is intentionally not imported by
// production code or registered in the application router.

// Keep explicit design-token arguments even when they currently equal a
// Flutter constructor default; the lab is the executable token specification.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_dating_app/labs/catch_field_section_next_prototype.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const catchFieldSectionNextCaptureKey = ValueKey<String>(
  'catch-field-section-next-preview-capture',
);

abstract final class _CatchFieldSectionNextPreviewTokens {
  static const double maxWidth = 392;
  static const double frameStroke = 1;
  static const double topPadding = 22;
  static const double bottomPadding = 26;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(child: CatchFieldSectionNextPreviewApp()));
}

class CatchFieldSectionNextPreviewApp extends StatelessWidget {
  const CatchFieldSectionNextPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const CatchFieldSectionNextPreviewSurface(),
    );
  }
}

class CatchFieldSectionNextPreviewSurface extends StatefulWidget {
  const CatchFieldSectionNextPreviewSurface({super.key});

  @override
  State<CatchFieldSectionNextPreviewSurface> createState() =>
      _CatchFieldSectionNextPreviewSurfaceState();
}

class _CatchFieldSectionNextPreviewSurfaceState
    extends State<CatchFieldSectionNextPreviewSurface> {
  final _nameController = TextEditingController(text: 'Aanya');
  final _instagramController = TextEditingController(text: 'sundayseafacecrew');
  final _occupationController = TextEditingController(
    text: 'Designer at a studio',
  );
  final _educationController = TextEditingController(text: 'NID, Ahmedabad');

  final Map<String, CatchFieldNextStatus> _statuses =
      <String, CatchFieldNextStatus>{};
  final Map<String, String> _committedText = <String, String>{
    'name': 'Aanya',
    'instagram': 'sundayseafacecrew',
    'occupation': 'Designer at a studio',
    'education': 'NID, Ahmedabad',
  };
  String? _openField;

  int _height = 168;
  int _heightDraft = 168;
  Set<String> _languages = <String>{'English', 'Hindi', 'Marathi'};
  Set<String> _languageDraft = <String>{'English', 'Hindi', 'Marathi'};
  Set<String> _religion = <String>{};

  int _paceFrom = 320;
  int _paceTo = 360;
  int _paceFromDraft = 320;
  int _paceToDraft = 360;
  Set<String> _distances = <String>{'5K', '10K'};
  Set<String> _distanceDraft = <String>{'5K', '10K'};
  Set<String> _why = <String>{'Social miles', 'Headspace'};
  Set<String> _whyDraft = <String>{'Social miles', 'Headspace'};
  Set<String> _when = <String>{'Dawn', 'Weekends'};
  Set<String> _whenDraft = <String>{'Dawn', 'Weekends'};
  bool _showPace = true;

  Set<String> _drinking = <String>{'Socially'};
  Set<String> _smoking = <String>{'Never'};
  int _workout = 5;
  int _workoutDraft = 5;
  Set<String> _diet = <String>{'Mostly veg'};
  Set<String> _children = <String>{};

  @override
  void dispose() {
    _nameController.dispose();
    _instagramController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  CatchFieldNextStatus _status(String field) =>
      _statuses[field] ?? CatchFieldNextStatus.idle;

  void _saveTextIfChanged(String field, String value) {
    if (_committedText[field] == value) return;
    unawaited(_save(field, () => _committedText[field] = value));
  }

  void _setOpen(String field, bool open, {VoidCallback? prepare}) {
    setState(() {
      if (open) {
        prepare?.call();
        _openField = field;
      } else if (_openField == field) {
        _openField = null;
      }
    });
  }

  Future<void> _save(String field, VoidCallback commit) async {
    setState(() => _statuses[field] = CatchFieldNextStatus.saving);
    await Future<void>.delayed(CatchFieldNextTokens.simulatedSave);
    if (!mounted) return;
    setState(() {
      commit();
      _statuses[field] = CatchFieldNextStatus.saved;
      if (_openField == field) _openField = null;
    });
    await Future<void>.delayed(CatchFieldNextTokens.savedStatusHold);
    if (!mounted) return;
    setState(() => _statuses[field] = CatchFieldNextStatus.idle);
  }

  void _restoreHeight() => setState(() => _heightDraft = _height);

  void _restoreLanguages() =>
      setState(() => _languageDraft = Set<String>.from(_languages));

  void _restorePace() {
    setState(() {
      _paceFromDraft = _paceFrom;
      _paceToDraft = _paceTo;
    });
  }

  void _restoreDistances() =>
      setState(() => _distanceDraft = Set<String>.from(_distances));

  void _restoreWhy() => setState(() => _whyDraft = Set<String>.from(_why));

  void _restoreWhen() => setState(() => _whenDraft = Set<String>.from(_when));

  void _restoreWorkout() => setState(() => _workoutDraft = _workout);

  String _paceLabel(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth
              .clamp(0.0, _CatchFieldSectionNextPreviewTokens.maxWidth)
              .toDouble();
          return Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: catchFieldSectionNextCaptureKey,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.bg,
                    border: Border(
                      left: BorderSide(
                        color: tokens.line2,
                        width: _CatchFieldSectionNextPreviewTokens.frameStroke,
                      ),
                      right: BorderSide(
                        color: tokens.line2,
                        width: _CatchFieldSectionNextPreviewTokens.frameStroke,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    primary: false,
                    padding: const EdgeInsets.fromLTRB(
                      CatchSpacing.s5,
                      _CatchFieldSectionNextPreviewTokens.topPadding,
                      CatchSpacing.s5,
                      _CatchFieldSectionNextPreviewTokens.bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAboutYou(),
                        const SizedBox(height: CatchSpacing.s6),
                        _buildRunning(),
                        const SizedBox(height: CatchSpacing.s6),
                        _buildLifestyle(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutYou() {
    return CatchFieldSectionNext.divided(
      title: 'ABOUT YOU',
      children: [
        CatchFieldNext.input(
          key: const ValueKey<String>('field-name'),
          label: 'Name',
          controller: _nameController,
          clearable: true,
          status: _status('name'),
          icon: PhosphorIconsRegular.user,
          textCapitalization: TextCapitalization.words,
          onBlur: (value) => _saveTextIfChanged('name', value),
        ),
        CatchFieldNext.input(
          key: const ValueKey<String>('field-instagram'),
          label: 'Instagram',
          controller: _instagramController,
          clearable: true,
          status: _status('instagram'),
          icon: PhosphorIconsRegular.instagramLogo,
          leading: const Text('@'),
          textCapitalization: TextCapitalization.none,
          onBlur: (value) => _saveTextIfChanged('instagram', value),
        ),
        CatchFieldNext.read(
          label: 'Date of birth',
          value: '12 Aug 1998',
          helper: 'We never show your birth year.',
          mono: true,
          icon: PhosphorIconsRegular.cake,
        ),
        CatchFieldNext.stepper(
          key: const ValueKey<String>('field-height'),
          label: 'Height',
          value: _openField == 'height' ? _heightDraft : _height,
          min: 120,
          max: 220,
          unit: 'cm',
          icon: PhosphorIconsRegular.ruler,
          open: _openField == 'height',
          onOpenChanged: (open) =>
              _setOpen('height', open, prepare: () => _heightDraft = _height),
          onChanged: (value) => setState(() => _heightDraft = value.round()),
          onCancel: _restoreHeight,
          onSave: () => _save('height', () => _height = _heightDraft),
          status: _status('height'),
        ),
        CatchFieldNext.input(
          label: 'Occupation',
          controller: _occupationController,
          status: _status('occupation'),
          icon: PhosphorIconsRegular.briefcase,
          onBlur: (value) => _saveTextIfChanged('occupation', value),
        ),
        CatchFieldNext.input(
          label: 'Education',
          controller: _educationController,
          status: _status('education'),
          icon: PhosphorIconsRegular.graduationCap,
          textCapitalization: TextCapitalization.words,
          onBlur: (value) => _saveTextIfChanged('education', value),
        ),
        CatchFieldNext.chips<String>(
          key: const ValueKey<String>('field-languages'),
          label: 'Languages',
          options: const <String>[
            'English',
            'Hindi',
            'Marathi',
            'Tamil',
            'Gujarati',
          ],
          optionLabel: (option) => option,
          selected: _openField == 'languages' ? _languageDraft : _languages,
          onChanged: (value) => setState(() => _languageDraft = value),
          multi: true,
          icon: PhosphorIconsRegular.translate,
          open: _openField == 'languages',
          onOpenChanged: (open) => _setOpen(
            'languages',
            open,
            prepare: () => _languageDraft = Set<String>.from(_languages),
          ),
          onCancel: _restoreLanguages,
          onSave: () => _save(
            'languages',
            () => _languages = Set<String>.from(_languageDraft),
          ),
          status: _status('languages'),
        ),
        CatchFieldNext.chips<String>(
          key: const ValueKey<String>('field-religion'),
          label: 'Religion',
          options: const <String>[
            'Hindu',
            'Muslim',
            'Christian',
            'Sikh',
            'None',
          ],
          optionLabel: (option) => option,
          selected: _religion,
          onChanged: (value) => setState(() => _religion = value),
          allowEmptySingleSelection: true,
          optional: true,
          icon: PhosphorIconsRegular.moonStars,
          open: _openField == 'religion',
          onOpenChanged: (open) => _setOpen('religion', open),
          onImmediateCommit: () => _save('religion', () {}),
          status: _status('religion'),
        ),
      ],
    );
  }

  Widget _buildRunning() {
    return CatchFieldSectionNext.divided(
      title: 'RUNNING',
      children: [
        CatchFieldNext.control(
          key: const ValueKey<String>('field-pace'),
          label: 'Pace',
          value: '${_paceLabel(_paceFrom)}–${_paceLabel(_paceTo)} /km',
          mono: true,
          icon: PhosphorIconsRegular.gauge,
          open: _openField == 'pace',
          onOpenChanged: (open) => _setOpen(
            'pace',
            open,
            prepare: () {
              _paceFromDraft = _paceFrom;
              _paceToDraft = _paceTo;
            },
          ),
          onCancel: _restorePace,
          onSave: () => _save('pace', () {
            _paceFrom = _paceFromDraft;
            _paceTo = _paceToDraft;
          }),
          status: _status('pace'),
          control: _PaceRangeControl(
            from: _paceFromDraft,
            to: _paceToDraft,
            formatter: _paceLabel,
            onFromChanged: (value) => setState(() {
              _paceFromDraft = value.clamp(240, _paceToDraft - 10).toInt();
            }),
            onToChanged: (value) => setState(() {
              _paceToDraft = value.clamp(_paceFromDraft + 10, 540).toInt();
            }),
          ),
        ),
        _stagedMultiChoice(
          id: 'distances',
          label: 'Distances',
          options: const <String>['5K', '10K', 'Half', 'Full'],
          icon: PhosphorIconsRegular.path,
          selected: _distances,
          draft: _distanceDraft,
          onDraftChanged: (value) => setState(() => _distanceDraft = value),
          restore: _restoreDistances,
          commit: () => _distances = Set<String>.from(_distanceDraft),
        ),
        _stagedMultiChoice(
          id: 'why',
          label: 'Why you run',
          options: const <String>[
            'Social miles',
            'Headspace',
            'Training',
            'Race prep',
          ],
          icon: PhosphorIconsRegular.heart,
          selected: _why,
          draft: _whyDraft,
          onDraftChanged: (value) => setState(() => _whyDraft = value),
          restore: _restoreWhy,
          commit: () => _why = Set<String>.from(_whyDraft),
        ),
        _stagedMultiChoice(
          id: 'when',
          label: 'When you run',
          options: const <String>['Dawn', 'Morning', 'Evening', 'Weekends'],
          icon: PhosphorIconsRegular.sunHorizon,
          selected: _when,
          draft: _whenDraft,
          onDraftChanged: (value) => setState(() => _whenDraft = value),
          restore: _restoreWhen,
          commit: () => _when = Set<String>.from(_whenDraft),
        ),
        CatchFieldNext.toggle(
          label: 'Show my pace on my profile',
          value: _showPace,
          onChanged: (value) => setState(() => _showPace = value),
          icon: PhosphorIconsRegular.eye,
        ),
      ],
    );
  }

  CatchFieldNext _stagedMultiChoice({
    required String id,
    required String label,
    required List<String> options,
    required IconData icon,
    required Set<String> selected,
    required Set<String> draft,
    required ValueChanged<Set<String>> onDraftChanged,
    required VoidCallback restore,
    required VoidCallback commit,
  }) {
    return CatchFieldNext.chips<String>(
      key: ValueKey<String>('field-$id'),
      label: label,
      options: options,
      optionLabel: (option) => option,
      selected: _openField == id ? draft : selected,
      onChanged: onDraftChanged,
      multi: true,
      icon: icon,
      open: _openField == id,
      onOpenChanged: (open) => _setOpen(
        id,
        open,
        prepare: () {
          draft
            ..clear()
            ..addAll(selected);
        },
      ),
      onCancel: restore,
      onSave: () => _save(id, commit),
      status: _status(id),
    );
  }

  Widget _buildLifestyle() {
    return CatchFieldSectionNext.divided(
      title: 'LIFESTYLE',
      children: [
        _immediateChoice(
          id: 'drinking',
          label: 'Drinking',
          options: const <String>['Never', 'Socially', 'Often'],
          selected: _drinking,
          icon: PhosphorIconsRegular.wine,
          onChanged: (value) => setState(() => _drinking = value),
        ),
        _immediateChoice(
          id: 'smoking',
          label: 'Smoking',
          options: const <String>['Never', 'Socially', 'Regular'],
          selected: _smoking,
          icon: PhosphorIconsRegular.cigarette,
          onChanged: (value) => setState(() => _smoking = value),
        ),
        CatchFieldNext.stepper(
          key: const ValueKey<String>('field-workout'),
          label: 'Workout',
          value: _openField == 'workout' ? _workoutDraft : _workout,
          min: 0,
          max: 7,
          unit: '× / week',
          icon: PhosphorIconsRegular.barbell,
          open: _openField == 'workout',
          onOpenChanged: (open) => _setOpen(
            'workout',
            open,
            prepare: () => _workoutDraft = _workout,
          ),
          onChanged: (value) => setState(() => _workoutDraft = value.round()),
          onCancel: _restoreWorkout,
          onSave: () => _save('workout', () => _workout = _workoutDraft),
          status: _status('workout'),
        ),
        _immediateChoice(
          id: 'diet',
          label: 'Diet',
          options: const <String>[
            'Vegetarian',
            'Mostly veg',
            'Eggs',
            'Non-veg',
          ],
          selected: _diet,
          icon: PhosphorIconsRegular.leaf,
          onChanged: (value) => setState(() => _diet = value),
        ),
        CatchFieldNext.chips<String>(
          label: 'Children',
          options: const <String>['No kids', 'Kids, at home', 'Kids, grown'],
          optionLabel: (option) => option,
          selected: _children,
          onChanged: (value) => setState(() => _children = value),
          allowEmptySingleSelection: true,
          emptyValueText: 'Add children status',
          icon: PhosphorIconsRegular.baby,
          open: _openField == 'children',
          onOpenChanged: (open) => _setOpen('children', open),
          onImmediateCommit: () => _save('children', () {}),
          status: _status('children'),
        ),
      ],
    );
  }

  CatchFieldNext _immediateChoice({
    required String id,
    required String label,
    required List<String> options,
    required Set<String> selected,
    required IconData icon,
    required ValueChanged<Set<String>> onChanged,
  }) {
    return CatchFieldNext.chips<String>(
      key: ValueKey<String>('field-$id'),
      label: label,
      options: options,
      optionLabel: (option) => option,
      selected: selected,
      onChanged: onChanged,
      icon: icon,
      open: _openField == id,
      onOpenChanged: (open) => _setOpen(id, open),
      onImmediateCommit: () => _save(id, () {}),
      status: _status(id),
    );
  }
}

class _PaceRangeControl extends StatelessWidget {
  const _PaceRangeControl({
    required this.from,
    required this.to,
    required this.formatter,
    required this.onFromChanged,
    required this.onToChanged,
  });

  final int from;
  final int to;
  final String Function(int seconds) formatter;
  final ValueChanged<int> onFromChanged;
  final ValueChanged<int> onToChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return DecoratedBox(
      key: const ValueKey<String>('catch-field-next-pace-tile'),
      decoration: BoxDecoration(
        color: tokens.raised,
        border: Border.all(
          color: tokens.line,
          width: CatchFieldNextTokens.dividerHairline,
        ),
        borderRadius: BorderRadius.circular(CatchFieldNextTokens.tileRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchFieldNextTokens.customControlHorizontalPadding,
          vertical: CatchFieldNextTokens.customControlVerticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PaceStepper(
              label: 'FROM',
              value: from,
              minimum: 240,
              maximum: to - 10,
              formatter: formatter,
              onChanged: onFromChanged,
            ),
            const SizedBox(height: CatchFieldNextTokens.customControlRowGap),
            Divider(
              key: const ValueKey<String>('catch-field-next-pace-divider'),
              height: CatchFieldNextTokens.dividerHairline,
              thickness: CatchFieldNextTokens.dividerHairline,
              color: tokens.line,
            ),
            const SizedBox(height: CatchFieldNextTokens.customControlRowGap),
            _PaceStepper(
              label: 'TO',
              value: to,
              minimum: from + 10,
              maximum: 540,
              formatter: formatter,
              onChanged: onToChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaceStepper extends StatelessWidget {
  const _PaceStepper({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.formatter,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final String Function(int seconds) formatter;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return Row(
      children: [
        Text(
          label,
          style: CatchTextStyles.monoCapsLabel(context, color: tokens.ink3)
              // The shared role owns 0.13em tracking. Scale both values so
              // the ratio remains exact at the custom-control size.
              .apply(
                fontSizeFactor: CatchFieldNextTokens.customControlLabelScale,
                letterSpacingFactor:
                    CatchFieldNextTokens.customControlLabelScale,
              )
              .copyWith(
                fontWeight: CatchFieldNextTokens.customControlLabelFontWeight,
              ),
        ),
        const Spacer(),
        CatchFieldNextRepeatButton(
          icon: PhosphorIconsRegular.minus,
          semanticLabel: 'Decrease $label pace',
          enabled: value > minimum,
          onStep: () => onChanged(value - 10),
        ),
        const SizedBox(width: CatchFieldNextTokens.stepperCompactInlineGap),
        SizedBox(
          width: CatchFieldNextTokens.customControlValueWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                text: formatter(value),
                children: [
                  TextSpan(
                    text: ' /km',
                    style:
                        CatchTextStyles.fieldRowTitle(
                          context,
                          color: tokens.ink3,
                        ).copyWith(
                          fontSize: CatchFieldNextTokens.paceUnitFontSize,
                          fontWeight: CatchFieldNextTokens.paceUnitFontWeight,
                        ),
                  ),
                ],
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: CatchTextStyles.fieldRowTitle(context, color: tokens.ink)
                  .copyWith(
                    fontSize: CatchFieldNextTokens.customControlValueFontSize,
                    fontWeight:
                        CatchFieldNextTokens.customControlValueFontWeight,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
            ),
          ),
        ),
        const SizedBox(width: CatchFieldNextTokens.stepperCompactInlineGap),
        CatchFieldNextRepeatButton(
          icon: PhosphorIconsRegular.plus,
          semanticLabel: 'Increase $label pace',
          enabled: value < maximum,
          onStep: () => onChanged(value + 10),
        ),
      ],
    );
  }
}
