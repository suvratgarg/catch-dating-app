import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
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
    final lifecycleLabel = contact.hasAmbiguousIdentity
        ? context.l10n.hostCustomersNeedsReview
        : contact.tags.contains(HostCustomerTag.newToOrganizer)
        ? context.l10n.hostsHostEventManageScreenStateLabelNew
        : contact.tags.contains(HostCustomerTag.regular)
        ? context.l10n.hostsOperationalRosterInsightRegular
        : contact.tags.contains(HostCustomerTag.atRisk)
        ? context.l10n.hostCustomersFilterAtRisk
        : null;
    final status = lifecycleLabel == null
        ? null
        : DecoratedBox(
            decoration: BoxDecoration(
              color: t.ink.withValues(alpha: CatchOpacity.controlOverlayHover),
              borderRadius: BorderRadius.circular(CatchRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s2,
                vertical: CatchSpacing.s1,
              ),
              child: Text(
                lifecycleLabel,
                style: HostCustomerTypography.status(context),
              ),
            ),
          );
    return CatchRowPressSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
        child: Row(
          children: [
            CatchPersonAvatar(
              size: CatchSpacing.s10,
              name: contact.displayName,
            ),
            gapW16,
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
                  Text(
                    context.l10n.hostsHostAudienceEventsAttended(
                      count: contact.attendedEventCount,
                    ),
                    style: HostCustomerTypography.secondary(context),
                  ),
                  if (contact.lastAttendedAt != null) ...[
                    gapH2,
                    Text(
                      context.l10n.hostsHostAudienceLastSeen(
                        date: AppTimeFormatters.shortDate(
                          contact.lastAttendedAt!,
                        ),
                      ),
                      style: HostCustomerTypography.secondary(context),
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
            Icon(
              CatchIcons.chevronRightRounded,
              size: CatchIcon.sm,
              color: t.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
