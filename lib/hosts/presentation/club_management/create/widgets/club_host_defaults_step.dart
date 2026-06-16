import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClubHostDefaultsStep extends StatelessWidget {
  const ClubHostDefaultsStep({
    super.key,
    required this.formKey,
    required this.defaults,
    required this.currencyCode,
    required this.onChanged,
    this.scrollable = true,
    this.padding,
  });

  final GlobalKey<FormState> formKey;
  final ClubHostDefaults defaults;
  final String currencyCode;
  final ValueChanged<ClubHostDefaults> onChanged;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final children = [
      _PolicyDefaultsCard(
        defaults: defaults.eventPolicy,
        currencyCode: currencyCode,
        onChanged: (eventPolicy) =>
            onChanged(defaults.copyWith(eventPolicy: eventPolicy)),
      ),
      gapH20,
      _DefaultActivityCard(
        selectedActivityKind: defaults.primaryActivityKind,
        onChanged: (activityKind) => onChanged(
          defaults.copyWith(
            primaryActivityKind: activityKind,
            supportedActivityKinds:
                defaults.effectiveSupportedActivityKinds.contains(activityKind)
                ? defaults.supportedActivityKinds
                : [...defaults.supportedActivityKinds, activityKind],
          ),
        ),
      ),
    ];

    return Form(
      key: formKey,
      child: scrollable
          ? ListView(
              padding: padding ?? CatchInsets.formStepBody,
              children: children,
            )
          : Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
    );
  }
}

class _DefaultActivityCard extends StatelessWidget {
  const _DefaultActivityCard({
    required this.selectedActivityKind,
    required this.onChanged,
  });

  final ActivityKind selectedActivityKind;
  final ValueChanged<ActivityKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default activity',
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH4,
          Text(
            'New events start from this activity. Hosts can still change the activity and override the event-specific setup.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final activityKind in ActivityKind.eventCreationDefaults)
                CatchSelectChip(
                  label: activityKind.label,
                  active: selectedActivityKind == activityKind,
                  accentColor: ActivityPalette.resolve(
                    context,
                    activityKind,
                  ).accent,
                  semanticsLabel: 'Use ${activityKind.label} by default',
                  onTap: () => onChanged(activityKind),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicyDefaultsCard extends StatefulWidget {
  const _PolicyDefaultsCard({
    required this.defaults,
    required this.currencyCode,
    required this.onChanged,
  });

  final EventPolicyDefaults defaults;
  final String currencyCode;
  final ValueChanged<EventPolicyDefaults> onChanged;

  @override
  State<_PolicyDefaultsCard> createState() => _PolicyDefaultsCardState();
}

class _PolicyDefaultsCardState extends State<_PolicyDefaultsCard> {
  late final TextEditingController _minAgeController = TextEditingController(
    text: _optionalIntText(
      widget.defaults.minAge == 0 ? null : widget.defaults.minAge,
    ),
  );
  late final TextEditingController _maxAgeController = TextEditingController(
    text: _optionalIntText(
      widget.defaults.maxAge == 99 ? null : widget.defaults.maxAge,
    ),
  );
  late final TextEditingController _maxMenController = TextEditingController(
    text: _optionalIntText(widget.defaults.maxMen),
  );
  late final TextEditingController _maxWomenController = TextEditingController(
    text: _optionalIntText(widget.defaults.maxWomen),
  );
  late final TextEditingController _pricingStepController =
      TextEditingController(
        text: _minorUnitsText(
          widget.defaults.dynamicPricingStepInPaise,
          currencyCode: widget.currencyCode,
        ),
      );
  late final TextEditingController _pricingMaxController =
      TextEditingController(
        text: _minorUnitsText(
          widget.defaults.dynamicPricingMaxInPaise,
          currencyCode: widget.currencyCode,
        ),
      );

  @override
  void didUpdateWidget(covariant _PolicyDefaultsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final defaults = widget.defaults;
    if (oldWidget.defaults.minAge != defaults.minAge) {
      _setText(
        _minAgeController,
        _optionalIntText(defaults.minAge == 0 ? null : defaults.minAge),
      );
    }
    if (oldWidget.defaults.maxAge != defaults.maxAge) {
      _setText(
        _maxAgeController,
        _optionalIntText(defaults.maxAge == 99 ? null : defaults.maxAge),
      );
    }
    if (oldWidget.defaults.maxMen != defaults.maxMen) {
      _setText(_maxMenController, _optionalIntText(defaults.maxMen));
    }
    if (oldWidget.defaults.maxWomen != defaults.maxWomen) {
      _setText(_maxWomenController, _optionalIntText(defaults.maxWomen));
    }
    if (oldWidget.defaults.dynamicPricingStepInPaise !=
            defaults.dynamicPricingStepInPaise ||
        oldWidget.currencyCode != widget.currencyCode) {
      _setText(
        _pricingStepController,
        _minorUnitsText(
          defaults.dynamicPricingStepInPaise,
          currencyCode: widget.currencyCode,
        ),
      );
    }
    if (oldWidget.defaults.dynamicPricingMaxInPaise !=
            defaults.dynamicPricingMaxInPaise ||
        oldWidget.currencyCode != widget.currencyCode) {
      _setText(
        _pricingMaxController,
        _minorUnitsText(
          defaults.dynamicPricingMaxInPaise,
          currencyCode: widget.currencyCode,
        ),
      );
    }
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    _pricingStepController.dispose();
    _pricingMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final defaults = widget.defaults;
    final selectedAdmissionPreset =
        defaults.admissionPreset == EventAdmissionDefaultPreset.fixedCohortCaps
        ? EventAdmissionDefaultPreset.openCapacity
        : defaults.admissionPreset;
    final cohortCapsEnabled =
        defaults.admissionPreset == EventAdmissionDefaultPreset.fixedCohortCaps;
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default event policy',
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH4,
          Text(
            'These defaults prefill new events. Hosts can override them per event before anyone books or joins the waitlist.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH18,
          const FieldLabel('Admission format'),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final preset in EventAdmissionDefaultPreset.values)
                if (preset != EventAdmissionDefaultPreset.fixedCohortCaps)
                  CatchSelectChip(
                    label: preset.label,
                    active: selectedAdmissionPreset == preset,
                    semanticsLabel: preset.label,
                    onTap: () => _emit(
                      defaults.copyWith(
                        admissionPreset: preset,
                        dynamicPricingEnabled:
                            preset ==
                                EventAdmissionDefaultPreset.balancedSingles
                            ? defaults.dynamicPricingEnabled
                            : false,
                      ),
                    ),
                  ),
            ],
          ),
          gapH8,
          Text(
            cohortCapsEnabled
                ? 'Anyone eligible can book until capacity, with optional straight men and straight women caps prefilled.'
                : selectedAdmissionPreset.description,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (selectedAdmissionPreset ==
              EventAdmissionDefaultPreset.openCapacity) ...[
            gapH12,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cohort caps',
                        style: CatchTextStyles.labelL(context),
                      ),
                      gapH4,
                      Text(
                        'Optionally prefill straight men and straight women caps for open events.',
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                gapW12,
                CatchToggle(
                  value: cohortCapsEnabled,
                  onChanged: (value) => _emit(
                    defaults.copyWith(
                      admissionPreset: value
                          ? EventAdmissionDefaultPreset.fixedCohortCaps
                          : EventAdmissionDefaultPreset.openCapacity,
                    ),
                  ),
                  semanticLabel: 'Cohort caps',
                ),
              ],
            ),
          ],
          if (cohortCapsEnabled) ...[
            gapH18,
            Row(
              children: [
                Expanded(
                  child: CatchTextField(
                    label: 'Max straight men',
                    isOptional: true,
                    controller: _maxMenController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _positiveOptionalValidator,
                    onChanged: (_) => _emitFromControllers(),
                  ),
                ),
                gapW12,
                Expanded(
                  child: CatchTextField(
                    label: 'Max straight women',
                    isOptional: true,
                    controller: _maxWomenController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _positiveOptionalValidator,
                    onChanged: (_) => _emitFromControllers(),
                  ),
                ),
              ],
            ),
          ],
          if (selectedAdmissionPreset ==
              EventAdmissionDefaultPreset.balancedSingles) ...[
            gapH12,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demand pricing',
                        style: CatchTextStyles.labelL(context),
                      ),
                      gapH4,
                      Text(
                        'Prefill dynamic pricing controls for balanced singles events.',
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                gapW12,
                CatchToggle(
                  value: defaults.dynamicPricingEnabled,
                  onChanged: (value) => _emit(
                    defaults.copyWith(
                      dynamicPricingEnabled: value,
                      dynamicPricingStepInPaise: value
                          ? defaults.dynamicPricingStepInPaise ?? 25000
                          : null,
                      dynamicPricingMaxInPaise: value
                          ? defaults.dynamicPricingMaxInPaise ?? 150000
                          : null,
                    ),
                  ),
                  semanticLabel: 'Demand pricing',
                ),
              ],
            ),
            if (defaults.dynamicPricingEnabled) ...[
              gapH12,
              Row(
                children: [
                  Expanded(
                    child: CatchTextField(
                      label: 'Step',
                      controller: _pricingStepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _positiveRequiredValidator,
                      onChanged: (_) => _emitFromControllers(),
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: CatchTextField(
                      label: 'Max',
                      controller: _pricingMaxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _positiveRequiredValidator,
                      onChanged: (_) => _emitFromControllers(),
                    ),
                  ),
                ],
              ),
            ],
          ],
          gapH18,
          const FieldLabel('Age range'),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  label: 'Min age',
                  isOptional: true,
                  controller: _minAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateAge(
                    value,
                    siblingController: _maxAgeController,
                    isMinimum: true,
                  ),
                  onChanged: (_) => _emitFromControllers(),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchTextField(
                  label: 'Max age',
                  isOptional: true,
                  controller: _maxAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateAge(
                    value,
                    siblingController: _minAgeController,
                    isMinimum: false,
                  ),
                  onChanged: (_) => _emitFromControllers(),
                ),
              ),
            ],
          ),
          gapH18,
          const FieldLabel('Cancellation policy'),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final policyId in EventCancellationPolicyId.values)
                CatchSelectChip(
                  label: _policyFor(policyId).title.toUpperCase(),
                  active: defaults.cancellationPolicyId == policyId,
                  semanticsLabel: _policyFor(policyId).title,
                  onTap: () =>
                      _emit(defaults.copyWith(cancellationPolicyId: policyId)),
                ),
            ],
          ),
          gapH8,
          Text(
            _policyFor(defaults.cancellationPolicyId).attendeeSummary,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }

  void _emitFromControllers() {
    _emit(
      widget.defaults.copyWith(
        minAge: int.tryParse(_minAgeController.text.trim()) ?? 0,
        maxAge: int.tryParse(_maxAgeController.text.trim()) ?? 99,
        maxMen: _parseOptionalInt(_maxMenController),
        maxWomen: _parseOptionalInt(_maxWomenController),
        dynamicPricingStepInPaise: _parseMajorUnitsToMinor(
          _pricingStepController,
          currencyCode: widget.currencyCode,
        ),
        dynamicPricingMaxInPaise: _parseMajorUnitsToMinor(
          _pricingMaxController,
          currencyCode: widget.currencyCode,
        ),
      ),
    );
  }

  void _emit(EventPolicyDefaults defaults) => widget.onChanged(defaults);
}

extension on EventAdmissionDefaultPreset {
  String get label => switch (this) {
    EventAdmissionDefaultPreset.openCapacity => 'OPEN',
    EventAdmissionDefaultPreset.inviteOnly => 'INVITE',
    EventAdmissionDefaultPreset.balancedSingles => 'BALANCED',
    EventAdmissionDefaultPreset.fixedCohortCaps => 'OPEN',
  };

  String get description => switch (this) {
    EventAdmissionDefaultPreset.openCapacity =>
      'Anyone eligible can book until the event reaches capacity.',
    EventAdmissionDefaultPreset.inviteOnly =>
      'New invite-only events will ask for an event-specific code.',
    EventAdmissionDefaultPreset.balancedSingles =>
      'Straight men and women are kept within one spot of each other.',
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      'New events start open with optional straight men and straight women caps.',
  };
}

String? _validateAge(
  String? value, {
  required TextEditingController siblingController,
  required bool isMinimum,
}) {
  if (value == null || value.trim().isEmpty) return null;
  final parsedValue = int.tryParse(value.trim());
  if (parsedValue == null || parsedValue < 18 || parsedValue > 99) {
    return '18-99';
  }
  final siblingValue = int.tryParse(siblingController.text.trim());
  if (siblingValue == null) return null;
  if (isMinimum && parsedValue > siblingValue) return '<= max';
  if (!isMinimum && parsedValue < siblingValue) return '>= min';
  return null;
}

String? _positiveOptionalValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
  return null;
}

String? _positiveRequiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final n = int.tryParse(value.trim());
  if (n == null || n < 1) return 'Min 1';
  return null;
}

EventCancellationPolicy _policyFor(EventCancellationPolicyId id) {
  return switch (id) {
    EventCancellationPolicyId.flexible =>
      const EventCancellationPolicy.flexible(),
    EventCancellationPolicyId.standard =>
      const EventCancellationPolicy.standard(),
    EventCancellationPolicyId.strict => const EventCancellationPolicy.strict(),
  };
}

String _optionalIntText(int? value) => value == null ? '' : value.toString();

String _minorUnitsText(int? value, {required String currencyCode}) =>
    minorCurrencyAmountInputText(value, currencyCode: currencyCode);

int? _parseOptionalInt(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return null;
  return int.tryParse(text);
}

int? _parseMajorUnitsToMinor(
  TextEditingController controller, {
  required String currencyCode,
}) => parseMajorCurrencyAmountToMinorUnits(
  controller.text,
  currencyCode: currencyCode,
);

void _setText(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
