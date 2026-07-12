import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum CatchPrivacyBadgeKind { privateToYou, hostCanSee, catchPrivate }

class CatchPrivacyBadge extends StatelessWidget {
  const CatchPrivacyBadge({
    super.key,
    this.kind = CatchPrivacyBadgeKind.privateToYou,
  });

  final CatchPrivacyBadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final data = _PrivacyBadgeData.from(kind, context.l10n);

    return Semantics(
      label: data.label,
      child: CatchSurface(
        tone: CatchSurfaceTone.transparent,
        borderColor: t.line2,
        radius: CatchRadius.pill,
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.micro10,
          vertical: CatchSpacing.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, size: CatchIcon.micro, color: t.ink3),
            gapW4,
            Text(
              data.label.toUpperCase(),
              style: CatchTextStyles.badge(context, color: t.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyBadgeData {
  const _PrivacyBadgeData({required this.label, required this.icon});

  final String label;
  final IconData icon;

  static _PrivacyBadgeData from(
    CatchPrivacyBadgeKind kind,
    AppLocalizations l10n,
  ) {
    return switch (kind) {
      CatchPrivacyBadgeKind.privateToYou => _PrivacyBadgeData(
        label: l10n.coreCatchPrivacyBadgeLabelPrivateToYou,
        icon: CatchIcons.lockOutlineRounded,
      ),
      CatchPrivacyBadgeKind.hostCanSee => _PrivacyBadgeData(
        label: l10n.coreCatchPrivacyBadgeLabelHostCanSee,
        icon: CatchIcons.visibilityOutlined,
      ),
      CatchPrivacyBadgeKind.catchPrivate => _PrivacyBadgeData(
        label: l10n.coreCatchPrivacyBadgeLabelCatchPrivate,
        icon: CatchIcons.shieldOutlined,
      ),
    };
  }
}
