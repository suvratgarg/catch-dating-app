import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/domain/phone_import_draft.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// One guest's local review fields. Controller commands own all draft changes;
/// text-controller lifetime and focus remain Flutter mechanics here.
class PhoneImportGuestFields extends StatefulWidget {
  const PhoneImportGuestFields({
    super.key,
    required this.entry,
    required this.guestNumber,
    required this.busy,
    required this.sharedPhone,
    required this.onRename,
    required this.onChoosePhone,
    required this.onFamilySideChanged,
    required this.onHouseholdChanged,
    required this.onRemove,
  });

  final PhoneImportEntry entry;
  final int guestNumber;
  final bool busy;
  final bool sharedPhone;
  final ValueChanged<String> onRename;
  final ValueChanged<String?> onChoosePhone;
  final ValueChanged<PhoneImportFamilySide> onFamilySideChanged;
  final ValueChanged<String> onHouseholdChanged;
  final VoidCallback onRemove;

  @override
  State<PhoneImportGuestFields> createState() => _PhoneImportGuestFieldsState();
}

class _PhoneImportGuestFieldsState extends State<PhoneImportGuestFields> {
  late final _name = TextEditingController(text: widget.entry.displayName);
  late final _household = TextEditingController(text: widget.entry.household);

  @override
  void didUpdateWidget(covariant PhoneImportGuestFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_name.text != widget.entry.displayName) {
      _name.text = widget.entry.displayName;
    }
    if (_household.text != widget.entry.household) {
      _household.text = widget.entry.household;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _household.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final manual = entry.source == PhoneImportEntrySource.manualHouseholdMember;
    final copy = catchFieldCopy(context.l10n);
    final states = widget.busy ? {WidgetState.disabled} : <WidgetState>{};
    return CatchSection.containedFieldRows(
      title: 'Guest ${widget.guestNumber}',
      children: [
        CatchField.read(
          copy: copy,
          title: 'Source',
          body: manual
              ? 'Household member · no phone contact'
              : entry.nameEdited
              ? 'Selected phone contact · name edited for this review'
              : 'Selected phone contact',
          bodyMaxLines: 3,
        ),
        CatchField.input(
          key: ValueKey('phone-import-name-${entry.id}'),
          copy: copy,
          title: 'Guest name',
          controller: _name,
          contractExemption:
              'Disposable local review; canonical CRM import contract is not connected.',
          textCapitalization: TextCapitalization.words,
          states: states,
          errorText: entry.displayName.trim().isEmpty
              ? 'Enter a guest name.'
              : null,
          onChanged: widget.onRename,
        ),
        if (manual)
          CatchField.read(
            copy: copy,
            title: 'Phone number',
            body: 'No phone needed for this household member.',
            bodyMaxLines: 3,
          )
        else if (entry.numbers.isEmpty)
          CatchBanner(
            message:
                'This contact has no phone number. Remove it and add '
                'a household member without a phone instead.',
            icon: CatchIcons.info,
            tone: CatchBannerTone.warning,
          )
        else
          CatchField<String>.select(
            key: ValueKey('phone-import-phone-${entry.id}'),
            copy: copy,
            title: 'Chosen phone number',
            contractExemption:
                'Only user-selected local phone values are reviewed; no ownership or verification is asserted.',
            values: [for (final number in entry.numbers) number.value],
            itemLabelBuilder: (value) {
              final number = entry.numbers.firstWhere(
                (number) => number.value == value,
              );
              return number.label.trim().isEmpty
                  ? value
                  : '${number.label} · $value';
            },
            value: entry.selectedPhone,
            hintText: 'Choose one phone number',
            states: states,
            onChanged: widget.busy ? null : widget.onChoosePhone,
            helperText: widget.sharedPhone
                ? 'Also chosen for another guest. Keep guests separate.'
                : entry.selectedPhone == null
                ? 'Choose the number you want to share for this guest.'
                : 'Review this number before sharing.',
            helperTone: widget.sharedPhone
                ? CatchFieldSupportRowTone.brand
                : CatchFieldSupportRowTone.neutral,
          ),
        CatchField<PhoneImportFamilySide>.select(
          key: ValueKey('phone-import-family-${entry.id}'),
          copy: copy,
          title: 'Family side / cohort',
          contractExemption:
              'Optional local wedding review grouping; no workspace assignment is saved.',
          values: PhoneImportFamilySide.values,
          itemLabelBuilder: (side) => switch (side) {
            PhoneImportFamilySide.unassigned => 'Unassigned',
            PhoneImportFamilySide.partnerOne => 'Partner one’s side',
            PhoneImportFamilySide.partnerTwo => 'Partner two’s side',
            PhoneImportFamilySide.both => 'Both sides',
          },
          value: entry.familySide,
          states: states,
          onChanged: widget.busy
              ? null
              : (value) {
                  if (value != null) widget.onFamilySideChanged(value);
                },
        ),
        CatchField.input(
          key: ValueKey('phone-import-household-${entry.id}'),
          copy: copy,
          title: 'Household',
          controller: _household,
          contractExemption:
              'Optional local household label; canonical household authority is not connected.',
          labelMode: CatchFieldLabelTextMode.optional,
          helperText: 'Use the same label for guests grouped together.',
          states: states,
          onChanged: widget.onHouseholdChanged,
        ),
        CatchButton(
          key: ValueKey('phone-import-remove-${entry.id}'),
          label: 'Remove guest ${widget.guestNumber}',
          semanticsLabel: entry.displayName.trim().isEmpty
              ? 'Remove guest ${widget.guestNumber}'
              : 'Remove ${entry.displayName} from this review',
          variant: CatchButtonVariant.ghost,
          onPressed: widget.busy ? null : widget.onRemove,
        ),
      ],
    );
  }
}
