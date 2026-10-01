import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

import 'phone_import_controller.dart';
import 'widgets/phone_import_guest_fields.dart';
import '../domain/phone_contact.dart';

/// Local phone-contact review seam. No route, workspace authority or save action
/// is mounted until the canonical CRM import/member contract is available.
class PhoneImportReviewScreen extends StatelessWidget {
  const PhoneImportReviewScreen({
    super.key,
    required this.controller,
    required this.weddingName,
    required this.plannerName,
  });

  final PhoneImportController controller;
  final String weddingName;
  final String plannerName;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final entries = controller.entries;
      final tokens = CatchTokens.of(context);
      final sharedPhones = controller.sharedPhones;
      return CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.screen(
          title: 'Review phone contacts',
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
        ),
        body: CatchRouteBody.standardConstrained(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchBanner(
                title: 'Phone import demo · sharing unavailable',
                message:
                    'This review stays on this device. Nothing is saved or '
                    'shared with a wedding or planner in this demo.',
                icon: CatchIcons.info,
                tone: CatchBannerTone.warning,
              ),
              gapH24,
              CatchSection.contained(
                title: weddingName,
                subtitle: 'Selected planner: $plannerName',
                child: Text(
                  'Choose only the guests you want to include. Review their '
                  'names and phone numbers before sharing with this wedding.',
                  style: CatchTextStyles.bodyM(context),
                ),
              ),
              gapH24,
              CatchSection.plain(
                title: 'Select guests',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CatchButton(
                      key: const ValueKey('phone-import-pick'),
                      label: entries.isEmpty
                          ? 'Choose phone contacts'
                          : 'Add phone contacts',
                      onPressed: controller.picking
                          ? null
                          : controller.pickContacts,
                      status: controller.picking
                          ? CatchButtonStatus.loading
                          : CatchButtonStatus.idle,
                      fullWidth: true,
                    ),
                    gapH12,
                    Text(
                      'Contact selection opens in the native Catch Host app. '
                      'On older Android phones, add contacts one at a time '
                      'and repeat this action.',
                      style: CatchTextStyles.supporting(
                        context,
                        color: tokens.ink2,
                      ),
                    ),
                    if (controller.notice case final notice?) ...[
                      gapH12,
                      Semantics(
                        liveRegion: true,
                        child: CatchBanner(
                          key: const ValueKey('phone-import-notice'),
                          message: notice,
                          icon: CatchIcons.info,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              gapH24,
              if (entries.isEmpty)
                CatchEmptyState(
                  icon: CatchIcons.peopleOutline,
                  title: 'No guests selected',
                  message:
                      'Choose phone contacts or add a household member '
                      'who does not have a phone contact.',
                )
              else ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    '${entries.length} ${entries.length == 1 ? 'guest' : 'guests'} in this local review',
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                ),
                if (sharedPhones.isNotEmpty) ...[
                  gapH12,
                  CatchBanner(
                    key: ValueKey('phone-import-shared-phones'),
                    message:
                        'A chosen number is shared by several guests. '
                        'They stay separate; check their household assignments.',
                    icon: CatchIcons.info,
                    tone: CatchBannerTone.warning,
                  ),
                ],
                gapH16,
                for (final (index, entry) in entries.indexed) ...[
                  PhoneImportGuestFields(
                    key: ValueKey(entry.id),
                    entry: entry,
                    guestNumber: index + 1,
                    busy: controller.picking,
                    sharedPhone:
                        entry.selectedPhone != null &&
                        sharedPhones.contains(
                          phoneSelectionKey(entry.selectedPhone!),
                        ),
                    onRename: (value) => controller.rename(entry.id, value),
                    onChoosePhone: (value) =>
                        controller.choosePhone(entry.id, value),
                    onFamilySideChanged: (value) =>
                        controller.assignFamilySide(entry.id, value),
                    onHouseholdChanged: (value) =>
                        controller.assignHousehold(entry.id, value),
                    onRemove: () => controller.remove(entry.id),
                  ),
                  gapH24,
                ],
              ],
              CatchButton(
                key: const ValueKey('phone-import-add-member'),
                label: 'Add household member without a phone',
                variant: CatchButtonVariant.secondary,
                onPressed: controller.picking || entries.length >= 100
                    ? null
                    : () => controller.addHouseholdMember(name: ''),
                fullWidth: true,
              ),
              gapH24,
              CatchSection.contained(
                title: 'Review sharing',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckboxListTile.adaptive(
                      key: const ValueKey('phone-import-sharing'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: controller.sharingConfirmed,
                      onChanged: entries.isEmpty || controller.picking
                          ? null
                          : (value) =>
                                controller.confirmSharing(value ?? false),
                      title: Text(
                        'I want to share only these reviewed guests with '
                        '$weddingName and $plannerName.',
                        style: CatchTextStyles.bodyM(context),
                      ),
                    ),
                    gapH12,
                    Text(
                      'A phone number does not prove ownership or verification '
                      'and does not give permission to send messages. '
                      'These contacts are not used for Catch discovery or marketing.',
                      style: CatchTextStyles.supporting(
                        context,
                        color: tokens.ink2,
                      ),
                    ),
                    if (entries.isNotEmpty &&
                        entries.any((entry) => !entry.valid)) ...[
                      gapH12,
                      CatchBanner(
                        key: ValueKey('phone-import-needs-review'),
                        message:
                            'Enter every guest name and choose a phone '
                            'number for each selected contact. Remove contacts '
                            'without a number, or add them as household members.',
                        icon: CatchIcons.info,
                        tone: CatchBannerTone.warning,
                      ),
                    ],
                    gapH16,
                    const CatchButton(
                      key: ValueKey('phone-import-share'),
                      label: 'Share reviewed guests',
                      onPressed: null,
                      fullWidth: true,
                    ),
                    gapH8,
                    Text(
                      'Sharing is unavailable until wedding member access '
                      'and the workspace import service are connected.',
                      style: CatchTextStyles.supporting(
                        context,
                        color: tokens.ink2,
                      ),
                    ),
                  ],
                ),
              ),
              if (entries.isNotEmpty) ...[
                gapH16,
                CatchButton(
                  key: const ValueKey('phone-import-discard'),
                  label: 'Discard local review',
                  variant: CatchButtonVariant.ghost,
                  onPressed: controller.picking ? null : controller.discard,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
