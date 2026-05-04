import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chats_list_view_model.freezed.dart';
part 'chats_list_view_model.g.dart';

@freezed
abstract class ChatsListViewModel with _$ChatsListViewModel {
  const ChatsListViewModel._();

  const factory ChatsListViewModel({
    required List<Match> newMatches,
    required List<Match> conversations,
  }) = _ChatsListViewModel;

  bool get isEmpty => newMatches.isEmpty && conversations.isEmpty;
}

@Riverpod(keepAlive: true)
class ChatSearchQuery extends _$ChatSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    final normalizedQuery = query.trimLeft();
    if (state != normalizedQuery) {
      state = normalizedQuery;
    }
  }

  void clear() => state = '';
}

@riverpod
AsyncValue<ChatsListViewModel> chatsListViewModel(Ref ref) {
  final uidAsync = ref.watch(uidProvider);
  final uid = uidAsync.asData?.value;
  if (uid == null) return const AsyncLoading();

  final matchesAsync = ref.watch(watchMatchesForUserProvider(uid));
  final query = ref.watch(chatSearchQueryProvider);

  return matchesAsync.whenData((matches) {
    final newMatches = <Match>[];
    final conversations = <Match>[];

    for (final match in matches) {
      if (match.lastMessagePreview == null) {
        newMatches.add(match);
      } else {
        conversations.add(match);
      }
    }

    newMatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    conversations.sort(
      (a, b) =>
          (b.lastMessageAt ?? b.createdAt)
              .compareTo(a.lastMessageAt ?? a.createdAt),
    );

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isNotEmpty) {
      conversations.removeWhere((match) {
        final otherUid = match.otherId(uid);
        final profile =
            ref.watch(watchPublicProfileProvider(otherUid)).asData?.value;
        final name = profile?.name ?? '';
        return !name.toLowerCase().contains(normalizedQuery);
      });
      newMatches.removeWhere((match) {
        final otherUid = match.otherId(uid);
        final profile =
            ref.watch(watchPublicProfileProvider(otherUid)).asData?.value;
        final name = profile?.name ?? '';
        return !name.toLowerCase().contains(normalizedQuery);
      });
    }

    return ChatsListViewModel(
      newMatches: List.unmodifiable(newMatches),
      conversations: List.unmodifiable(conversations),
    );
  });
}
