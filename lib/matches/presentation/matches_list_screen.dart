import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/async_value_widget.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/matches/presentation/widgets/match_celebration_dialog.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MatchesListScreen extends ConsumerStatefulWidget {
  const MatchesListScreen({super.key});

  @override
  ConsumerState<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends ConsumerState<MatchesListScreen> {
  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(uidProvider);
    final t = CatchTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: AsyncValueWidget(
        value: uidAsync,
        data: (uid) {
          if (uid == null) return const SizedBox.shrink();

          ref.listen(matchesForUserProvider(uid), (previous, next) {
            if (!context.mounted) return;
            if (previous == null || !previous.hasValue || !next.hasValue) {
              return;
            }
            final prevIds = previous.value!.map((m) => m.id).toSet();
            final newMatches = next.value!
                .where((m) => !prevIds.contains(m.id))
                .toList();
            for (final match in newMatches) {
              showMatchCelebration(context, ref, match, uid);
            }
          });

          return AsyncValueWidget(
            value: ref.watch(matchesForUserProvider(uid)),
            data: (matches) => matches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: t.line2),
                        gapH16,
                        Text(
                          'No matches yet',
                          style: CatchTextStyles.displaySm(context),
                        ),
                        gapH8,
                        Text(
                          'Keep swiping to find your match!',
                          style: CatchTextStyles.bodyMd(context, color: t.ink2),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final match = matches[i];
                      final otherUid = match.otherId(uid);
                      final profileAsync = ref.watch(
                        publicProfileProvider(otherUid),
                      );
                      return ChatListTile(
                        match: match,
                        currentUid: uid,
                        onTap: () => context.goNamed(
                          Routes.chatScreen.name,
                          pathParameters: {'matchId': match.id},
                          extra: profileAsync.asData?.value,
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
