import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/events/presentation/create_event_form_keys.dart';
import 'package:catch_dating_app/events/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EligibilityStep extends StatelessWidget {
  const EligibilityStep({
    super.key,
    required this.formKey,
    required this.minAgeController,
    required this.maxAgeController,
    required this.maxMenController,
    required this.maxWomenController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController minAgeController;
  final TextEditingController maxAgeController;
  final TextEditingController maxMenController;
  final TextEditingController maxWomenController;

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

    if (isMinimum && parsedValue > siblingValue) {
      return '<= max';
    }
    if (!isMinimum && parsedValue < siblingValue) {
      return '>= min';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Form(
      key: formKey,
      child: ListView(
        padding: CatchInsets.formStepBody,
        children: [
          CatchSurface(
            padding: CatchInsets.contentDense,
            tone: CatchSurfaceTone.primarySoft,
            radius: CatchRadius.md,
            borderWidth: 0,
            child: Text(
              'Leave fields empty to apply no restriction. These filters help curate a safe, balanced event.',
              style: CatchTextStyles.supporting(context, color: t.primary),
            ),
          ),
          gapH20,
          const FieldLabel('Age range'),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.minAge,
                  label: 'Min age',
                  isOptional: true,
                  controller: minAgeController,
                  hintText: 'Min (e.g. 18)',
                  prefixIcon: Icon(CatchIcons.cakeOutlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateAge(
                    value,
                    siblingController: maxAgeController,
                    isMinimum: true,
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.maxAge,
                  label: 'Max age',
                  isOptional: true,
                  controller: maxAgeController,
                  hintText: 'Max (e.g. 35)',
                  prefixIcon: Icon(CatchIcons.cakeOutlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateAge(
                    value,
                    siblingController: minAgeController,
                    isMinimum: false,
                  ),
                ),
              ),
            ],
          ),
          gapH20,
          const FieldLabel('Gender caps'),
          gapH8,
          Row(
            children: [
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.maxMen,
                  label: 'Max men',
                  isOptional: true,
                  controller: maxMenController,
                  hintText: 'Max men',
                  prefixIcon: Icon(CatchIcons.maleOutlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1) return 'Min 1';
                    return null;
                  },
                ),
              ),
              gapW12,
              Expanded(
                child: CatchTextField(
                  key: CreateEventFormKeys.maxWomen,
                  label: 'Max women',
                  isOptional: true,
                  controller: maxWomenController,
                  hintText: 'Max women',
                  prefixIcon: Icon(CatchIcons.femaleOutlined),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1) return 'Min 1';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
