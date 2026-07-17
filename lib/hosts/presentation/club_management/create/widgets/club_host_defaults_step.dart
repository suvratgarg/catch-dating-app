import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/hosts/presentation/validators.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef EventPolicyDefaultsUpdate =
    EventPolicyDefaults Function(EventPolicyDefaults current);

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
    final content = CatchSectionList(
      gap: 0,
      children: [
        ClubPolicyDefaultsCard(
          defaults: defaults.eventPolicy,
          currencyCode: currencyCode,
          activityKind: defaults.primaryActivityKind,
          onActivityChanged: (activityKind) => onChanged(
            defaults.copyWith(
              primaryActivityKind: activityKind,
              supportedActivityKinds:
                  defaults.effectiveSupportedActivityKinds.contains(
                    activityKind,
                  )
                  ? defaults.supportedActivityKinds
                  : [...defaults.supportedActivityKinds, activityKind],
            ),
          ),
          onChanged: (update) => onChanged(
            defaults.copyWith(eventPolicy: update(defaults.eventPolicy)),
          ),
        ),
      ],
    );

    return Form(
      key: formKey,
      child: scrollable
          ? ListView(
              padding: padding ?? CatchInsets.formStepBody,
              children: [content],
            )
          : Padding(padding: padding ?? EdgeInsets.zero, child: content),
    );
  }
}

class ClubPolicyDefaultsCard extends StatefulWidget {
  const ClubPolicyDefaultsCard({
    super.key,
    required this.defaults,
    required this.currencyCode,
    required this.onChanged,
    this.activityKind,
    this.onActivityChanged,
    this.advancedOnly = false,
  }) : assert(
         (activityKind == null) == (onActivityChanged == null),
         'activityKind and onActivityChanged must be provided together',
       );

  final EventPolicyDefaults defaults;
  final String currencyCode;
  final ValueChanged<EventPolicyDefaultsUpdate> onChanged;
  final ActivityKind? activityKind;
  final ValueChanged<ActivityKind>? onActivityChanged;
  final bool advancedOnly;

  @override
  State<ClubPolicyDefaultsCard> createState() => _PolicyDefaultsCardState();
}

class _PolicyDefaultsCardState extends State<ClubPolicyDefaultsCard> {
  String? _openNumericField;
  final Map<String, String?> _numericErrors = {};
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
  void didUpdateWidget(covariant ClubPolicyDefaultsCard oldWidget) {
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

  void _setNumericFieldOpen(String field, bool open) {
    setState(() {
      _openNumericField = open ? field : null;
      _numericErrors[field] = null;
    });
  }

  void _cancelNumericField(
    String field,
    TextEditingController controller,
    String confirmedText,
  ) {
    _setText(controller, confirmedText);
    setState(() {
      _openNumericField = null;
      _numericErrors[field] = null;
    });
  }

  void _submitNumericField({
    required String field,
    required String? Function() validate,
    required EventPolicyDefaultsUpdate update,
  }) {
    final error = validate();
    if (error != null) {
      setState(() => _numericErrors[field] = error);
      return;
    }
    widget.onChanged(update);
    setState(() {
      _openNumericField = null;
      _numericErrors[field] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaults = widget.defaults;
    final selectedAdmissionPreset =
        defaults.admissionPreset == EventAdmissionDefaultPreset.fixedCohortCaps
        ? EventAdmissionDefaultPreset.openCapacity
        : defaults.admissionPreset;
    final cohortCapsEnabled =
        defaults.admissionPreset == EventAdmissionDefaultPreset.fixedCohortCaps;
    final visibleAdmissionPresets = EventAdmissionDefaultPreset.values
        .where(
          (preset) => preset != EventAdmissionDefaultPreset.fixedCohortCaps,
        )
        .toList(growable: false);
    return CatchSection.fieldRows(
      first: true,
      title: context.l10n.hostsClubHostDefaultsStepTextDefaultEventPolicy,
      footer: Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s3),
        child: Text(
          context.l10n.hostsClubHostDefaultsStepTextTheseDefaultsPrefillNew,
        ),
      ),
      children: [
        if (widget.activityKind case final activityKind?)
          CatchField.choices<ActivityKind>(
            title: context.l10n.hostsClubHostDefaultsStepTextDefaultActivity,
            body: context.l10n.hostsClubHostDefaultsStepTextNewEventsStartFrom,
            values: ActivityKind.eventCreationDefaults,
            itemLabel: (value) => value.label,
            selected: {activityKind},
            onSelectionChanged: (selection) =>
                widget.onActivityChanged!(selection.single),
            icon: CatchIcons.eventOutlined,
            iconColor: ActivityPalette.resolve(context, activityKind).accent,
          ),
        if (!widget.advancedOnly)
          CatchField.choices<EventAdmissionDefaultPreset>(
            title: context.l10n.hostsClubHostDefaultsStepLabelAdmissionFormat,
            body: cohortCapsEnabled
                ? context
                      .l10n
                      .hostsClubHostDefaultsStepTextAnyoneEligibleCanBook
                : selectedAdmissionPreset.description(context.l10n),
            values: visibleAdmissionPresets,
            itemLabel: (preset) => preset.label(context.l10n),
            selected: {selectedAdmissionPreset},
            onSelectionChanged: (selection) {
              final preset = selection.single;
              _emit(
                (current) => current.copyWith(
                  admissionPreset: preset,
                  dynamicPricingEnabled:
                      preset == EventAdmissionDefaultPreset.balancedSingles
                      ? current.dynamicPricingEnabled
                      : false,
                ),
              );
            },
            initiallyOpen: true,
            icon: CatchIcons.howToRegOutlined,
          ),
        if (selectedAdmissionPreset == EventAdmissionDefaultPreset.openCapacity)
          CatchField.toggle(
            title: context.l10n.hostsClubHostDefaultsStepTitleCohortCaps,
            body: context
                .l10n
                .hostsClubHostDefaultsStepBodyOptionallyPrefillStraightMen,
            value: cohortCapsEnabled,
            onChanged: (value) => _emit(
              (current) => current.copyWith(
                admissionPreset: value
                    ? EventAdmissionDefaultPreset.fixedCohortCaps
                    : EventAdmissionDefaultPreset.openCapacity,
              ),
            ),
          ),
        if (cohortCapsEnabled)
          CatchSection.containedFieldRows(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CatchField.inputActions(
                      title: context
                          .l10n
                          .hostsClubHostDefaultsStepTitleMaxStraightMen,
                      controller: _maxMenController,
                      open: _openNumericField == 'maxMen',
                      onOpenChanged: (open) =>
                          _setNumericFieldOpen('maxMen', open),
                      onCancel: () => _cancelNumericField(
                        'maxMen',
                        _maxMenController,
                        _optionalIntText(defaults.maxMen),
                      ),
                      onSubmit: () => _submitNumericField(
                        field: 'maxMen',
                        validate: () =>
                            positiveOptionalValidator(_maxMenController.text),
                        update: (current) => current.copyWith(
                          maxMen: _parseOptionalInt(_maxMenController),
                        ),
                      ),
                      icon: CatchIcons.maleOutlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      error: _numericErrors['maxMen'],
                      onChanged: (_) =>
                          setState(() => _numericErrors['maxMen'] = null),
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: CatchField.inputActions(
                      title: context
                          .l10n
                          .hostsClubHostDefaultsStepTitleMaxStraightWomen,
                      controller: _maxWomenController,
                      open: _openNumericField == 'maxWomen',
                      onOpenChanged: (open) =>
                          _setNumericFieldOpen('maxWomen', open),
                      onCancel: () => _cancelNumericField(
                        'maxWomen',
                        _maxWomenController,
                        _optionalIntText(defaults.maxWomen),
                      ),
                      onSubmit: () => _submitNumericField(
                        field: 'maxWomen',
                        validate: () =>
                            positiveOptionalValidator(_maxWomenController.text),
                        update: (current) => current.copyWith(
                          maxWomen: _parseOptionalInt(_maxWomenController),
                        ),
                      ),
                      icon: CatchIcons.femaleOutlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      error: _numericErrors['maxWomen'],
                      onChanged: (_) =>
                          setState(() => _numericErrors['maxWomen'] = null),
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (selectedAdmissionPreset ==
            EventAdmissionDefaultPreset.balancedSingles) ...[
          CatchField.toggle(
            title: context.l10n.hostsClubHostDefaultsStepTitleDemandPricing,
            body: context
                .l10n
                .hostsClubHostDefaultsStepBodyPrefillDynamicPricingControls,
            value: defaults.dynamicPricingEnabled,
            onChanged: (value) => _emit(
              (current) => current.copyWith(
                dynamicPricingEnabled: value,
                dynamicPricingStepInPaise: value
                    ? current.dynamicPricingStepInPaise ?? 25000
                    : null,
                dynamicPricingMaxInPaise: value
                    ? current.dynamicPricingMaxInPaise ?? 150000
                    : null,
              ),
            ),
          ),
          if (defaults.dynamicPricingEnabled)
            CatchSection.containedFieldRows(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CatchField.inputActions(
                        title: context.l10n.hostsClubHostDefaultsStepTitleStep,
                        controller: _pricingStepController,
                        open: _openNumericField == 'pricingStep',
                        onOpenChanged: (open) =>
                            _setNumericFieldOpen('pricingStep', open),
                        onCancel: () => _cancelNumericField(
                          'pricingStep',
                          _pricingStepController,
                          _minorUnitsText(
                            defaults.dynamicPricingStepInPaise,
                            currencyCode: widget.currencyCode,
                          ),
                        ),
                        onSubmit: () => _submitNumericField(
                          field: 'pricingStep',
                          validate: () => positiveRequiredValidator(
                            _pricingStepController.text,
                          ),
                          update: (current) => current.copyWith(
                            dynamicPricingStepInPaise: _parseMajorUnitsToMinor(
                              _pricingStepController,
                              currencyCode: widget.currencyCode,
                            ),
                          ),
                        ),
                        icon: CatchIcons.trendingUpRounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        error: _numericErrors['pricingStep'],
                        onChanged: (_) => setState(
                          () => _numericErrors['pricingStep'] = null,
                        ),
                      ),
                    ),
                    gapW12,
                    Expanded(
                      child: CatchField.inputActions(
                        title: context.l10n.hostsClubHostDefaultsStepTitleMax,
                        controller: _pricingMaxController,
                        open: _openNumericField == 'pricingMax',
                        onOpenChanged: (open) =>
                            _setNumericFieldOpen('pricingMax', open),
                        onCancel: () => _cancelNumericField(
                          'pricingMax',
                          _pricingMaxController,
                          _minorUnitsText(
                            defaults.dynamicPricingMaxInPaise,
                            currencyCode: widget.currencyCode,
                          ),
                        ),
                        onSubmit: () => _submitNumericField(
                          field: 'pricingMax',
                          validate: () => positiveRequiredValidator(
                            _pricingMaxController.text,
                          ),
                          update: (current) => current.copyWith(
                            dynamicPricingMaxInPaise: _parseMajorUnitsToMinor(
                              _pricingMaxController,
                              currencyCode: widget.currencyCode,
                            ),
                          ),
                        ),
                        icon: CatchIcons.priceChangeOutlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        error: _numericErrors['pricingMax'],
                        onChanged: (_) =>
                            setState(() => _numericErrors['pricingMax'] = null),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
        if (!widget.advancedOnly) ...[
          Row(
            children: [
              Expanded(
                child: CatchField.inputActions(
                  title: context.l10n.hostsClubHostDefaultsStepTitleMinAge,
                  controller: _minAgeController,
                  open: _openNumericField == 'minAge',
                  onOpenChanged: (open) => _setNumericFieldOpen('minAge', open),
                  onCancel: () => _cancelNumericField(
                    'minAge',
                    _minAgeController,
                    _optionalIntText(
                      defaults.minAge == 0 ? null : defaults.minAge,
                    ),
                  ),
                  onSubmit: () => _submitNumericField(
                    field: 'minAge',
                    validate: () => validateAge(
                      _minAgeController.text,
                      siblingController: _maxAgeController,
                      isMinimum: true,
                    ),
                    update: (current) => current.copyWith(
                      minAge: int.tryParse(_minAgeController.text.trim()) ?? 0,
                    ),
                  ),
                  icon: CatchIcons.cakeOutlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  error: _numericErrors['minAge'],
                  onChanged: (_) =>
                      setState(() => _numericErrors['minAge'] = null),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchField.inputActions(
                  title: context.l10n.hostsClubHostDefaultsStepTitleMaxAge,
                  controller: _maxAgeController,
                  open: _openNumericField == 'maxAge',
                  onOpenChanged: (open) => _setNumericFieldOpen('maxAge', open),
                  onCancel: () => _cancelNumericField(
                    'maxAge',
                    _maxAgeController,
                    _optionalIntText(
                      defaults.maxAge == 99 ? null : defaults.maxAge,
                    ),
                  ),
                  onSubmit: () => _submitNumericField(
                    field: 'maxAge',
                    validate: () => validateAge(
                      _maxAgeController.text,
                      siblingController: _minAgeController,
                      isMinimum: false,
                    ),
                    update: (current) => current.copyWith(
                      maxAge: int.tryParse(_maxAgeController.text.trim()) ?? 99,
                    ),
                  ),
                  icon: CatchIcons.cakeOutlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  error: _numericErrors['maxAge'],
                  onChanged: (_) =>
                      setState(() => _numericErrors['maxAge'] = null),
                ),
              ),
            ],
          ),
          CatchField.choices<EventCancellationPolicyId>(
            title:
                context.l10n.hostsClubHostDefaultsStepLabelCancellationPolicy,
            body: policyFor(defaults.cancellationPolicyId).attendeeSummary,
            values: EventCancellationPolicyId.values,
            itemLabel: (policyId) => policyFor(policyId).title.toUpperCase(),
            selected: {defaults.cancellationPolicyId},
            onSelectionChanged: (selection) => _emit(
              (current) =>
                  current.copyWith(cancellationPolicyId: selection.single),
            ),
            initiallyOpen: true,
            icon: CatchIcons.ruleOutlined,
          ),
        ],
      ],
    );
  }

  void _emit(EventPolicyDefaultsUpdate update) => widget.onChanged(update);
}

extension on EventAdmissionDefaultPreset {
  String label(AppLocalizations l10n) => switch (this) {
    EventAdmissionDefaultPreset.openCapacity =>
      l10n.hostsClubHostDefaultsStepLabelOpen,
    EventAdmissionDefaultPreset.inviteOnly =>
      l10n.hostsClubHostDefaultsStepLabelInvite,
    EventAdmissionDefaultPreset.balancedSingles =>
      l10n.hostsClubHostDefaultsStepLabelBalanced,
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      l10n.hostsClubHostDefaultsStepLabelOpen,
  };

  String description(AppLocalizations l10n) => switch (this) {
    EventAdmissionDefaultPreset.openCapacity =>
      l10n.hostsClubHostDefaultsStepDescriptionAnyoneEligibleCanBook,
    EventAdmissionDefaultPreset.inviteOnly =>
      l10n.hostsClubHostDefaultsStepDescriptionNewInviteOnlyEvents,
    EventAdmissionDefaultPreset.balancedSingles =>
      l10n.hostsClubHostDefaultsStepDescriptionStraightMenAndWomen,
    EventAdmissionDefaultPreset.fixedCohortCaps =>
      l10n.hostsClubHostDefaultsStepDescriptionNewEventsStartOpen,
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
