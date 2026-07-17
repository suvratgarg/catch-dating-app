import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
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
    final data = _PrivacyBadgeData.from(kind, context.l10n);

    return Semantics(
      label: data.label,
      child: ExcludeSemantics(
        child: CatchBadge.privacy(label: data.label, icon: data.icon),
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
