import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HostCustomerRow extends StatelessWidget {
  const HostCustomerRow({
    super.key,
    required this.contact,
    required this.divider,
    required this.onTap,
  });

  final HostCustomerDirectoryContact contact;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final metadata = <String>[
      context.l10n.hostsHostAudienceEventsAttended(
        count: contact.attendedEventCount,
      ),
      if (contact.lastAttendedAt != null)
        context.l10n.hostsHostAudienceLastSeen(
          date: AppTimeFormatters.shortDate(contact.lastAttendedAt!),
        ),
      if (contact.whatsappOptedIn)
        context.l10n.hostsHostAudienceWhatsappOptedIn,
      if (contact.whatsappAdminSuppressed)
        context.l10n.hostsHostAudienceContactConsentPaused,
    ];
    final lifecycleLabel = contact.hasAmbiguousIdentity
        ? null
        : _preferredCustomerTag(context, contact.tags);
    return CatchRowPressSurface(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: CatchInsets.listBodyDense,
            child: Row(
              children: [
                CatchPersonAvatar(
                  size: CatchSpacing.s7,
                  name: contact.displayName,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        contact.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.fieldRowTitle(
                          context,
                          color: t.ink,
                        ),
                      ),
                      gapH3,
                      Text(
                        metadata.join(' · '),
                        maxLines: usesLargeText ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                      if (lifecycleLabel != null) ...[
                        gapH3,
                        Text(
                          lifecycleLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.badgeCaps(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (contact.hasAmbiguousIdentity) ...[
                  gapW10,
                  CatchBadge.functional(
                    label: context.l10n.hostCustomersNeedsReview,
                    tone: CatchBadgeTone.warning,
                    icon: CatchIcons.fieldWarning,
                  ),
                ],
                gapW4,
                Icon(
                  CatchIcons.chevronRightRounded,
                  size: CatchIcon.sm,
                  color: t.ink3,
                ),
              ],
            ),
          ),
          if (divider) const CatchDivider.fieldRow(),
        ],
      ),
    );
  }
}

String? _preferredCustomerTag(BuildContext context, Set<HostCustomerTag> tags) {
  if (tags.contains(HostCustomerTag.highImpactAdvocate)) {
    return context.l10n.hostsHostAudienceSegmentHighImpact;
  }
  if (tags.contains(HostCustomerTag.atRisk)) {
    return context.l10n.hostCustomersFilterAtRisk;
  }
  if (tags.contains(HostCustomerTag.needsConfirmation)) {
    return context.l10n.hostsHostAudienceSegmentNeedsConfirmation;
  }
  if (tags.contains(HostCustomerTag.regular)) {
    return context.l10n.hostsHostAudienceSegmentRegular;
  }
  if (tags.contains(HostCustomerTag.reliable)) {
    return context.l10n.hostsHostAudienceSegmentReliable;
  }
  if (tags.contains(HostCustomerTag.repeat)) {
    return context.l10n.hostsHostAudienceSegmentRepeat;
  }
  if (tags.contains(HostCustomerTag.firstTime)) {
    return context.l10n.hostsHostAudienceSegmentFirstTime;
  }
  if (tags.contains(HostCustomerTag.newToOrganizer)) {
    return context.l10n.hostsHostAudienceSegmentNew;
  }
  if (tags.contains(HostCustomerTag.advocate)) {
    return context.l10n.hostsHostAudienceSegmentAdvocate;
  }
  if (tags.contains(HostCustomerTag.whatsappReachable)) {
    return context.l10n.hostsHostAudienceSegmentWhatsapp;
  }
  if (tags.contains(HostCustomerTag.smsReachable)) {
    return context.l10n.hostsHostAudienceSegmentSms;
  }
  return null;
}
