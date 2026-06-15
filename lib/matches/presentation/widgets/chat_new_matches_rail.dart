import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatNewMatchesRail extends StatelessWidget {
  const ChatNewMatchesRail({super.key, required this.matches});

  final List<ChatThreadPreview> matches;

  @override
  Widget build(BuildContext context) {
    final isHostApp = AppConfig.appRole.isHost;
    return CatchHorizontalRail(
      title: isHostApp ? 'New attendee queries' : 'New matches',
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final preview = matches[index];
        final routeName = AppConfig.appRole.isHost
            ? Routes.hostChatScreen.name
            : Routes.chatScreen.name;
        return _NewMatchAvatar(
          preview: preview,
          onTap: () => context.goNamed(
            routeName,
            pathParameters: {'matchId': preview.matchId},
          ),
        );
      },
    );
  }
}

class _NewMatchAvatar extends StatelessWidget {
  const _NewMatchAvatar({required this.preview, required this.onTap});

  final ChatThreadPreview preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Open chat with ${preview.displayName}',
      child: Semantics(
        button: true,
        label: 'Open chat with ${preview.displayName}',
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: CatchLayout.chatNewMatchTileWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchPersonAvatar(
                  size: 64,
                  name: preview.displayName,
                  imageUrl: preview.photoUrl,
                  borderWidth: 2,
                  borderColor: CatchTokens.of(context).primary,
                ),
                gapH6,
                Text(
                  preview.displayName,
                  style: CatchTextStyles.labelS(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
