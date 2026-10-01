import 'dart:async';

import 'package:catch_dating_app/hosts/audience/phone_import/data/phone_contact_picker.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/domain/phone_contact.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/domain/phone_import_draft.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_controller.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_review_screen.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/widgets/phone_import_guest_fields.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/page_preview.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Local demo · empty and selected guests',
  type: PhoneImportReviewScreen,
  path: '[P1 product surfaces]/Host/Audience/Phone import demo',
)
Widget hostPhoneImportReviewStates(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'PhoneImportReviewScreen · unconnected demo',
      catalogId: 'host.phone_import_demo',
      children: [
        for (final selected in [false, true])
          WidgetbookPageStateCard(
            label: selected ? 'Guests need review' : 'Choose contacts',
            description: 'Synthetic contacts only. No save or CRM transport.',
            child: WidgetbookViewportFrame.constrainedDevice(
              size: const Size(390, 812),
              child: _PhoneImportDemo(selected: selected),
            ),
          ),
      ],
    );

@widgetbook.UseCase(
  name: 'Multiple numbers, no number, and household member',
  type: PhoneImportGuestFields,
  path: '[P1 product surfaces]/Host/Audience/Phone import demo',
)
Widget hostPhoneImportGuestStates(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'PhoneImportGuestFields',
      catalogId: 'host.phone_import_guest_demo',
      children: [
        for (final (index, entry) in _guestEntries.indexed)
          WidgetbookPageStateCard(
            label: switch (index) {
              0 => 'Choose a number and enter a name',
              1 => 'No-number contact stays invalid',
              _ => 'Household member without a phone',
            },
            child: WidgetbookContentFrame(
              child: PhoneImportGuestFields(
                entry: entry,
                guestNumber: index + 1,
                busy: false,
                sharedPhone: false,
                onRename: (_) {},
                onChoosePhone: (_) {},
                onFamilySideChanged: (_) {},
                onHouseholdChanged: (_) {},
                onRemove: () {},
              ),
            ),
          ),
      ],
    );

class _PhoneImportDemo extends StatefulWidget {
  const _PhoneImportDemo({required this.selected});
  final bool selected;

  @override
  State<_PhoneImportDemo> createState() => _PhoneImportDemoState();
}

class _PhoneImportDemoState extends State<_PhoneImportDemo> {
  late final _controller = PhoneImportController(picker: _SyntheticPicker());

  @override
  void initState() {
    super.initState();
    if (widget.selected) unawaited(_controller.pickContacts());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PhoneImportReviewScreen(
    controller: _controller,
    weddingName: 'Asha & Ravi · sample wedding',
    plannerName: 'Sample wedding planner',
  );
}

class _SyntheticPicker implements PhoneContactPicker {
  @override
  Future<PhoneContactPickerResult> pickContacts() async =>
      PhoneContactPickerResult(PhoneContactPickerStatus.selected, [
        PhoneContact(
          localId: 'sample-asha',
          displayName: 'Asha Shah',
          numbers: const [
            PhoneContactNumber(value: '+1 202 555 0106', label: 'Mobile'),
            PhoneContactNumber(value: '+1 202 555 0107', label: 'Home'),
          ],
        ),
        PhoneContact(
          localId: 'sample-nameless',
          displayName: '',
          numbers: const [PhoneContactNumber(value: '+1 202 555 0108')],
        ),
      ]);
}

final _guestEntries = [
  PhoneImportEntry(
    id: 'preview-multiple',
    displayName: '',
    numbers: const [
      PhoneContactNumber(value: '+1 202 555 0106', label: 'Mobile'),
      PhoneContactNumber(value: '+1 202 555 0107', label: 'Home'),
    ],
  ),
  PhoneImportEntry(
    id: 'preview-no-number',
    displayName: 'Ravi Rao',
    numbers: const [],
  ),
  PhoneImportEntry(
    id: 'preview-manual',
    displayName: 'Mira Rao',
    household: 'Rao household',
    familySide: PhoneImportFamilySide.partnerTwo,
    source: PhoneImportEntrySource.manualHouseholdMember,
    numbers: const [],
  ),
];
