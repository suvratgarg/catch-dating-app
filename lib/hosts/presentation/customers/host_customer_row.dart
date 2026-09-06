import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Domain adapter: formats CRM evidence; the person-row primitive owns identity,
/// avatar, hierarchy, adaptive status placement, and interaction geometry.
class HostCustomerRow extends StatelessWidget {
  const HostCustomerRow({
    super.key,
    required this.contact,
    required this.onTap,
  });

  final HostCustomerDirectoryContact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lifecycle = contact.hasAmbiguousIdentity
        ? (
            label: context.l10n.hostCustomersNeedsReview,
            tone: CatchBadgeTone.warning,
          )
        : contact.tags.contains(HostCustomerTag.atRisk)
        ? (
            label: context.l10n.hostCustomersFilterAtRisk,
            tone: CatchBadgeTone.warning,
          )
        : contact.tags.contains(HostCustomerTag.regular)
        ? (
            label: context.l10n.hostsOperationalRosterInsightRegular,
            tone: CatchBadgeTone.affinity,
          )
        : contact.tags.contains(HostCustomerTag.newToOrganizer)
        ? (
            label: context.l10n.hostsHostEventManageScreenStateLabelNew,
            tone: CatchBadgeTone.success,
          )
        : null;
    return CatchPersonRow.directory(
      data: CatchPersonRowData(name: contact.displayName),
      onTap: onTap,
      status: lifecycle == null
          ? null
          : CatchBadge.status(label: lifecycle.label, tone: lifecycle.tone),
      metadata: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: context.l10n.hostCustomersCompactEventCount(
                count: contact.attendedEventCount,
              ),
              style: CatchTextStyles.supportingStrong(context),
            ),
            if (contact.lastAttendedAt != null)
              TextSpan(
                text:
                    '  ·  ${context.l10n.hostsHostAudienceLastSeen(date: AppTimeFormatters.shortDate(contact.lastAttendedAt!))}',
              ),
          ],
        ),
        key: ValueKey('host-customer-activity-${contact.contactId}'),
      ),
      contextContent: contact.whatsappAdminSuppressed
          ? Text(
              context.l10n.hostsHostAudienceContactConsentPaused,
              style: CatchTextStyles.recordContext(context),
            )
          : null,
    );
  }
}
