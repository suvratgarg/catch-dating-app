import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chats_list_view_model.freezed.dart';
part 'chats_list_view_model.g.dart';

@freezed
abstract class ChatsListViewModel with _$ChatsListViewModel {
  const ChatsListViewModel._();

  const factory ChatsListViewModel({
    required List<ChatThreadPreview> newMatches,
    required List<ChatThreadPreview> conversations,
    required int totalThreadCount,
  }) = _ChatsListViewModel;

  bool get isEmpty => newMatches.isEmpty && conversations.isEmpty;
  int get visibleThreadCount => newMatches.length + conversations.length;
}

class ChatThreadPreview {
  const ChatThreadPreview({
    required this.match,
    required this.matchId,
    required this.otherUid,
    required this.displayName,
    required this.photoUrl,
    required this.previewText,
    required this.timestamp,
    required this.unreadCount,
    required this.hasConversation,
    required this.runIds,
  });

  final Match match;
  final String matchId;
  final String otherUid;
  final String displayName;
  final String? photoUrl;
  final String previewText;
  final DateTime timestamp;
  final int unreadCount;
  final bool hasConversation;
  final List<String> runIds;

  String? get latestRunId => runIds.isEmpty ? null : runIds.last;
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
    final matchesByPerson = collapseMatchesByOtherUser(matches, uid);
    final previews = matchesByPerson
        .map((match) => _previewForMatch(ref, match, uid))
        .toList();

    final newMatches = <ChatThreadPreview>[];
    final conversations = <ChatThreadPreview>[];

    for (final preview in previews) {
      if (preview.hasConversation) {
        conversations.add(preview);
      } else {
        newMatches.add(preview);
      }
    }

    newMatches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isNotEmpty) {
      conversations.removeWhere(
        (preview) =>
            !preview.displayName.toLowerCase().contains(normalizedQuery),
      );
      newMatches.removeWhere(
        (preview) =>
            !preview.displayName.toLowerCase().contains(normalizedQuery),
      );
    }

    return ChatsListViewModel(
      newMatches: List.unmodifiable(newMatches),
      conversations: List.unmodifiable(conversations),
      totalThreadCount: matchesByPerson.length,
    );
  });
}

ChatThreadPreview _previewForMatch(Ref ref, Match match, String uid) {
  final otherUid = match.otherId(uid);
  final profile = ref.watch(watchPublicProfileProvider(otherUid)).asData?.value;
  final displayName = profile?.name ?? 'Unknown';
  final photoUrl = profile?.primaryPhotoThumbnailUrl;
  final hasConversation = match.lastMessagePreview != null;
  final String previewText;
  if (!hasConversation) {
    previewText = 'You matched!';
  } else if (match.lastMessageSenderId == uid) {
    previewText = 'You: ${match.lastMessagePreview}';
  } else {
    previewText = match.lastMessagePreview!;
  }

  return ChatThreadPreview(
    match: match,
    matchId: match.id,
    otherUid: otherUid,
    displayName: displayName,
    photoUrl: photoUrl,
    previewText: previewText,
    timestamp: match.lastMessageAt ?? match.createdAt,
    unreadCount: match.unreadCounts[uid] ?? 0,
    hasConversation: hasConversation,
    runIds: match.runIds,
  );
}
