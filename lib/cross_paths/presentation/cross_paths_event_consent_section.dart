import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/cross_paths/presentation/cross_paths_event_consent_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class CrossPathsEventConsentSection extends StatelessWidget {
  const CrossPathsEventConsentSection({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final CrossPathsEventConsentSectionState state;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (!state.visible) return const SizedBox.shrink();

    return CatchSection.fieldRows(
      title: context.l10n.crossPathsEventConsentSectionTitleCrossPaths,
      children: [
        CatchField.toggle(
          key: const ValueKey('cross_paths.event_consent.toggle'),
          contract: CatchContractConstraints
              .setCrossPathsEventConsentCallablePayloadEnabled,
          title: context
              .l10n
              .crossPathsEventConsentSectionTitleMeetPeopleAtThisEvent,
          body: context.l10n.crossPathsEventConsentSectionBodyConsentDisclosure,
          icon: CatchIcons.favoriteBorderRounded,
          value: state.enabled,
          status: state.pending
              ? CatchFieldStatus.saving
              : CatchFieldStatus.idle,
          helperText: state.unavailable
              ? context.l10n.crossPathsEventConsentSectionBodyConsentUnavailable
              : null,
          onChanged: state.canChange ? onChanged : null,
        ),
      ],
    );
  }
}
