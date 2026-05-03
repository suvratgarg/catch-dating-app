import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/async_value_widget.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/matches/presentation/widgets/match_celebration_dialog.dart';
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
    final uid = uidAsync.asData?.value;
    final t = CatchTokens.of(context);

    if (uid != null) {
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
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: AsyncValueWidget(
        value: uidAsync,
        data: (resolvedUid) {
          if (resolvedUid == null) return const SizedBox.shrink();

          return AsyncValueWidget(
            value: ref.watch(matchesForUserProvider(resolvedUid)),
            data: (matches) => matches.isEmpty
                ? _MatchesEmptyState(tokens: t)
                : SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        CatchSpacing.s5,
                        Sizes.p8,
                        CatchSpacing.s5,
                        Sizes.p24,
                      ),
                      children: [
                        _MatchesHeader(tokens: t, count: matches.length),
                        gapH16,
                        for (final match in matches) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: t.surface,
                              border: Border.all(color: t.line),
                              borderRadius: BorderRadius.circular(
                                CatchRadius.lg,
                              ),
                            ),
                            child: ChatListTile(
                              match: match,
                              currentUid: resolvedUid,
                              onTap: () => context.goNamed(
                                Routes.chatScreen.name,
                                pathParameters: {'matchId': match.id},
                              ),
                            ),
                          ),
                          if (match != matches.last) gapH10,
                        ],
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _MatchesHeader extends StatelessWidget {
  const _MatchesHeader({required this.tokens, required this.count});

  final CatchTokens tokens;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'CHATS', heavy: true),
              gapH2,
              Text('Your catches', style: CatchTextStyles.displayL(context)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: t.primarySoft,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
          ),
          child: Text(
            '$count active',
            style: CatchTextStyles.labelL(context, color: t.primary),
          ),
        ),
      ],
    );
  }
}

class _MatchesEmptyState extends StatelessWidget {
  const _MatchesEmptyState({required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          Sizes.p8,
          CatchSpacing.s5,
          Sizes.p24,
        ),
        children: [
          _MatchesHeader(tokens: t, count: 0),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.14),
          Container(
            padding: const EdgeInsets.all(Sizes.p20),
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: t.heroGrad,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 34,
                    color: t.primaryInk,
                  ),
                ),
                gapH18,
                Text(
                  'No catches yet',
                  style: CatchTextStyles.displayM(context),
                  textAlign: TextAlign.center,
                ),
                gapH8,
                Text(
                  'When someone catches you back after a shared run, the conversation opens here with that run as context.',
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
