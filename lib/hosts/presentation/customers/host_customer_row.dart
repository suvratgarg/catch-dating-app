import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_palette.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_typography.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

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
    final t = CatchTokens.of(context);
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final lifecycle = contact.hasAmbiguousIdentity
        ? (label: context.l10n.hostCustomersNeedsReview, color: t.danger)
        : contact.tags.contains(HostCustomerTag.atRisk)
        ? (
            label: context.l10n.hostCustomersFilterAtRisk,
            color: HostCustomerPalette.atRisk(context),
          )
        : contact.tags.contains(HostCustomerTag.regular)
        ? (
            label: context.l10n.hostsOperationalRosterInsightRegular,
            color: HostCustomerPalette.regular(context),
          )
        : contact.tags.contains(HostCustomerTag.newToOrganizer)
        ? (
            label: context.l10n.hostsHostEventManageScreenStateLabelNew,
            color: HostCustomerPalette.newCustomer(context),
          )
        : null;
    final status = lifecycle == null
        ? null
        : DecoratedBox(
            decoration: BoxDecoration(
              color: lifecycle.color.withValues(alpha: CatchOpacity.subtleFill),
              borderRadius: BorderRadius.circular(CatchRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s2,
                vertical: CatchSpacing.micro2,
              ),
              child: Text(
                lifecycle.label,
                style: HostCustomerTypography.status(
                  context,
                  color: lifecycle.color,
                ),
              ),
            ),
          );
    return CatchRowPressSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.micro2),
              child: ExcludeSemantics(
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1,
                  child: CatchPersonAvatar(
                    size: CatchSpacing.s10,
                    name: contact.displayName,
                  ),
                ),
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.displayName,
                          style: HostCustomerTypography.name(context),
                        ),
                      ),
                      if (status != null && !usesLargeText) ...[gapW8, status],
                    ],
                  ),
                  gapH4,
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: context.l10n.hostCustomersCompactEventCount(
                            count: contact.attendedEventCount,
                          ),
                          style: HostCustomerTypography.metadataStrong(context),
                        ),
                        if (contact.lastAttendedAt != null)
                          TextSpan(
                            text:
                                '  ·  ${context.l10n.hostsHostAudienceLastSeen(date: AppTimeFormatters.shortDate(contact.lastAttendedAt!))}',
                            style: HostCustomerTypography.metadata(context),
                          ),
                      ],
                    ),
                    key: ValueKey(
                      'host-customer-activity-${contact.contactId}',
                    ),
                    maxLines: usesLargeText ? 4 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (contact.tags.contains(HostCustomerTag.newToOrganizer) ||
                      contact.tags.contains(HostCustomerTag.repeat)) ...[
                    gapH4,
                    Row(
                      children: [
                        Icon(
                          contact.tags.contains(HostCustomerTag.newToOrganizer)
                              ? CatchIcons.sparkle
                              : CatchIcons.eventRepeatOutlined,
                          size: CatchIcon.sm,
                          color: t.ink2,
                        ),
                        gapW6,
                        Expanded(
                          child: Text(
                            contact.tags.contains(
                                  HostCustomerTag.newToOrganizer,
                                )
                                ? context.l10n.hostsHostAudienceSegmentNew
                                : context
                                      .l10n
                                      .hostsOperationalRosterInsightReturning,
                            maxLines: usesLargeText ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: HostCustomerTypography.context(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (status != null && usesLargeText) ...[gapH8, status],
                  if (contact.whatsappAdminSuppressed) ...[
                    gapH4,
                    Text(
                      context.l10n.hostsHostAudienceContactConsentPaused,
                      style: HostCustomerTypography.secondary(context),
                    ),
                  ],
                ],
              ),
            ),
            gapW8,
            Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.micro3),
              child: Icon(
                CatchIcons.chevronRightRounded,
                size: CatchIcon.sm,
                color: t.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
