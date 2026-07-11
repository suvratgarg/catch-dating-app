import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
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

  ChatsListViewModel filterByQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return this;
    bool matches(ChatThreadPreview preview) =>
        preview.displayName.toLowerCase().contains(normalized);
    return copyWith(
      newMatches: List.unmodifiable(newMatches.where(matches)),
      conversations: List.unmodifiable(conversations.where(matches)),
    );
  }
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
    required this.eventIds,
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
  final List<String> eventIds;

  String? get latestEventId => eventIds.isEmpty ? null : eventIds.last;
}

// keepalive: preserve inbox search text across tab switches and route re-entry.
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
  final String? uid;
  switch (uidAsync) {
    case AsyncData(:final value):
      uid = value;
    case AsyncError(:final error, :final stackTrace):
      return AsyncError<ChatsListViewModel>(error, stackTrace);
    default:
      return const AsyncLoading();
  }
  if (uid == null) return const AsyncLoading();
  final currentUid = uid;

  final matchesAsync = ref.watch(watchMatchesForUserProvider(currentUid));
  return matchesAsync.whenData((matches) {
    final roleMatches = AppConfig.appRole.isHost
        ? matches.where((match) => match.isClubHostInquiry)
        : matches;
    final displayMatches = AppConfig.appRole.isHost
        ? roleMatches.toList(growable: false)
        : collapseMatchesByOtherUser(
            roleMatches.toList(growable: false),
            currentUid,
          );
    final hostInquiryClubIds = {
      for (final match in displayMatches)
        if (match.isClubHostInquiry && match.clubId != null) match.clubId!,
    };
    final clubsById = hostInquiryClubIds.isEmpty
        ? const <String, Club>{}
        : {
            for (final club
                in ref
                        .watch(
                          watchClubsForMessagingByIdsProvider(
                            ClubsByIdQuery(hostInquiryClubIds),
                          ),
                        )
                        .asData
                        ?.value ??
                    const <Club>[])
              club.id: club,
          };
    final publicProfileUids = <String>{};
    for (final match in displayMatches) {
      final otherUid = match.otherId(currentUid);
      final club = match.isClubHostInquiry && match.clubId != null
          ? clubsById[match.clubId!]
          : null;
      final hostProfile = _hostProfileFor(club, otherUid);
      final otherParticipantIsHost = hostProfile != null;
      final shouldReadPublicProfile =
          !match.isClubHostInquiry || (club != null && !otherParticipantIsHost);
      if (shouldReadPublicProfile) publicProfileUids.add(otherUid);
    }
    final profilesByUid = publicProfileUids.isEmpty
        ? const <String, PublicProfile>{}
        : ref
                  .watch(
                    publicProfilesByIdsProvider(
                      PublicProfilesQuery(publicProfileUids),
                    ),
                  )
                  .asData
                  ?.value ??
              const <String, PublicProfile>{};
    final previews = displayMatches
        .map(
          (match) => _previewForMatch(
            match,
            currentUid,
            clubsById: clubsById,
            profilesByUid: profilesByUid,
          ),
        )
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

    return ChatsListViewModel(
      newMatches: List.unmodifiable(newMatches),
      conversations: List.unmodifiable(conversations),
      totalThreadCount: displayMatches.length,
    );
  });
}

ChatThreadPreview _previewForMatch(
  Match match,
  String uid, {
  required Map<String, Club> clubsById,
  required Map<String, PublicProfile> profilesByUid,
}) {
  final otherUid = match.otherId(uid);
  final club = match.isClubHostInquiry && match.clubId != null
      ? clubsById[match.clubId!]
      : null;
  final hostProfile = _hostProfileFor(club, otherUid);
  final otherParticipantIsHost = hostProfile != null;
  final shouldReadPublicProfile =
      !match.isClubHostInquiry || (club != null && !otherParticipantIsHost);
  final profile = shouldReadPublicProfile ? profilesByUid[otherUid] : null;
  final displayName =
      hostProfile?.displayName ??
      profile?.name ??
      (match.isClubHostInquiry ? 'Host conversation' : 'Unknown');
  final photoUrl = hostProfile?.avatarUrl ?? profile?.primaryPhotoThumbnailUrl;
  final hasConversation = match.lastMessagePreview != null;
  final String previewText;
  if (!hasConversation) {
    previewText = match.isClubHostInquiry ? 'Ask the host' : 'You matched!';
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
    unreadCount: match.unreadConversationCountFor(uid),
    hasConversation: hasConversation,
    eventIds: match.eventIds,
  );
}

ClubHostProfile? _hostProfileFor(Club? club, String uid) {
  if (club == null) return null;
  for (final host in club.displayHostProfiles) {
    if (host.uid == uid) return host;
  }
  return null;
}
