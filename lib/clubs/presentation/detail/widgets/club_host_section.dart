import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

typedef ClubHostProfileHandler = void Function(String hostUid);
typedef ClubHostMessageHandler =
    Future<void> Function(BuildContext context, ClubHostProfile host);

class ClubHostSection extends StatelessWidget {
  const ClubHostSection({
    super.key,
    required this.club,
    required this.canViewProfile,
    required this.isMessageHostPending,
    required this.messageableHostUids,
    required this.onViewProfile,
    required this.onMessageHost,
  });

  final Club club;
  final bool canViewProfile;
  final bool isMessageHostPending;
  final Set<String> messageableHostUids;
  final ClubHostProfileHandler? onViewProfile;
  final ClubHostMessageHandler? onMessageHost;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hosts = club.displayHostProfiles;

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final host in hosts) ...[
            Semantics(
              button: canViewProfile,
              label: canViewProfile ? 'View ${host.displayName} profile' : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canViewProfile
                    ? () => onViewProfile?.call(host.uid)
                    : null,
                child: ClubHostRow(
                  host: host,
                  borderColor: t.primarySoft,
                  showChevron: canViewProfile,
                  onMessage:
                      messageableHostUids.contains(host.uid) &&
                          !isMessageHostPending &&
                          onMessageHost != null
                      ? () => unawaited(onMessageHost!(context, host))
                      : null,
                ),
              ),
            ),
            if (host != hosts.last) gapH12,
          ],
        ],
      ),
    );
  }
}

class ClubHostRow extends StatelessWidget {
  const ClubHostRow({
    super.key,
    required this.host,
    required this.borderColor,
    required this.showChevron,
    required this.onMessage,
  });

  final ClubHostProfile host;
  final Color borderColor;
  final bool showChevron;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final isOwner = host.role == ClubHostRole.owner;
    final meta =
        '${isOwner ? 'OWNER' : 'HOST'} · '
        '${showChevron ? 'VIEW PROFILE' : 'PUBLIC PROFILE'}';

    return Row(
      children: [
        ClubHostAvatar(
          name: host.displayName,
          imageUrl: host.avatarUrl,
          size: CatchSpacing.s10,
          borderWidth: 2,
          borderColor: borderColor,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      host.displayName,
                      style: CatchTextStyles.name(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(width: CatchSpacing.micro6),
                    Icon(
                      CatchIcons.sealCheck,
                      size: CatchIcon.sm,
                      color: t.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: CatchSpacing.s1),
              Text(
                meta,
                style: CatchTextStyles.monoLabel(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onMessage != null) ...[
          gapW8,
          Tooltip(
            message: 'Message host',
            child: CatchIconButton(
              onTap: onMessage,
              child: Icon(
                CatchIcons.chatBubbleOutlineRounded,
                size: CatchIcon.control,
                color: t.primary,
              ),
            ),
          ),
        ],
        if (showChevron) ...[
          gapW8,
          Icon(
            CatchIcons.chevronRightRounded,
            size: CatchIcon.lg,
            color: t.ink3,
          ),
        ],
      ],
    );
  }
}
