import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class ProfilePhoto {
  const ProfilePhoto({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.storagePath,
    required this.thumbnailStoragePath,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.prompt,
    this.moderation,
  });

  factory ProfilePhoto.fromJson(Map<String, dynamic> json) => ProfilePhoto(
    id: json['id'] as String,
    url: json['url'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String,
    storagePath: json['storagePath'] as String,
    thumbnailStoragePath: json['thumbnailStoragePath'] as String,
    prompt: _readPrompt(json['prompt']),
    moderation: _readModeration(json['moderation']),
    position: (json['position'] as num).toInt(),
    createdAt: _readDateTime(json['createdAt']),
    updatedAt: _readDateTime(json['updatedAt']),
  );

  factory ProfilePhoto.uploaded({
    required int position,
    required String url,
    required String storagePath,
    DateTime? now,
    PhotoPromptAnswer? prompt,
  }) {
    final timestamp = now ?? DateTime.now();
    return ProfilePhoto(
      id: profilePhotoIdForStoragePath(storagePath, position),
      url: url,
      thumbnailUrl: url,
      storagePath: storagePath,
      thumbnailStoragePath: thumbnailStoragePathForStoragePath(storagePath),
      prompt: prompt,
      moderation: const ProfilePhotoModeration(status: 'pending'),
      position: position,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  final String id;
  final String url;
  final String thumbnailUrl;
  final String storagePath;
  final String thumbnailStoragePath;
  final PhotoPromptAnswer? prompt;
  final ProfilePhotoModeration? moderation;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'url': url,
    'thumbnailUrl': thumbnailUrl,
    'storagePath': storagePath,
    'thumbnailStoragePath': thumbnailStoragePath,
    if (prompt != null) 'prompt': prompt!.toJson(),
    if (moderation != null) 'moderation': moderation!.toJson(),
    'position': position,
    'createdAt': const TimestampConverter().toJson(createdAt),
    'updatedAt': const TimestampConverter().toJson(updatedAt),
  };

  ProfilePhoto copyWith({
    String? id,
    String? url,
    String? thumbnailUrl,
    String? storagePath,
    String? thumbnailStoragePath,
    Object? prompt = _sentinel,
    Object? moderation = _sentinel,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfilePhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      storagePath: storagePath ?? this.storagePath,
      thumbnailStoragePath: thumbnailStoragePath ?? this.thumbnailStoragePath,
      prompt: identical(prompt, _sentinel)
          ? this.prompt
          : prompt as PhotoPromptAnswer?,
      moderation: identical(moderation, _sentinel)
          ? this.moderation
          : moderation as ProfilePhotoModeration?,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfilePhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          thumbnailUrl == other.thumbnailUrl &&
          storagePath == other.storagePath &&
          thumbnailStoragePath == other.thumbnailStoragePath &&
          prompt == other.prompt &&
          moderation == other.moderation &&
          position == other.position &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    url,
    thumbnailUrl,
    storagePath,
    thumbnailStoragePath,
    prompt,
    moderation,
    position,
    createdAt,
    updatedAt,
  );
}

@immutable
class ProfilePhotoModeration {
  const ProfilePhotoModeration({
    required this.status,
    this.reason,
    this.reviewedAt,
  });

  factory ProfilePhotoModeration.fromJson(Map<String, dynamic> json) =>
      ProfilePhotoModeration(
        status: json['status'] as String,
        reason: json['reason'] as String?,
        reviewedAt: json['reviewedAt'] == null
            ? null
            : _readDateTime(json['reviewedAt']),
      );

  final String status;
  final String? reason;
  final DateTime? reviewedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'status': status,
    if (reason != null) 'reason': reason,
    if (reviewedAt != null)
      'reviewedAt': const TimestampConverter().toJson(reviewedAt!),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfilePhotoModeration &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          reason == other.reason &&
          reviewedAt == other.reviewedAt;

  @override
  int get hashCode => Object.hash(status, reason, reviewedAt);
}

List<ProfilePhoto> normalizeProfilePhotos(Iterable<ProfilePhoto> photos) {
  final byId = <String, ProfilePhoto>{};
  for (final photo in photos) {
    final url = photo.url.trim();
    if (url.isEmpty) continue;
    final thumbnailUrl = photo.thumbnailUrl.trim().isNotEmpty
        ? photo.thumbnailUrl.trim()
        : url;
    final storagePath = photo.storagePath.trim();
    final thumbnailStoragePath = photo.thumbnailStoragePath.trim().isNotEmpty
        ? photo.thumbnailStoragePath.trim()
        : thumbnailStoragePathForStoragePath(storagePath);
    if (storagePath.isEmpty || thumbnailStoragePath.isEmpty) continue;

    final normalized = photo.copyWith(
      id: photo.id.trim().isNotEmpty
          ? photo.id.trim()
          : profilePhotoIdForStoragePath(storagePath, photo.position),
      url: url,
      thumbnailUrl: thumbnailUrl,
      storagePath: storagePath,
      thumbnailStoragePath: thumbnailStoragePath,
      position: photo.position.clamp(0, 11),
    );
    byId[normalized.id] = normalized;
  }

  final ordered = byId.values.toList(growable: false)
    ..sort((a, b) => a.position.compareTo(b.position));
  return ordered.take(maxPhotoPromptCaptions).toList(growable: false);
}

List<ProfilePhoto> profilePhotosFromLegacyArrays({
  required String uid,
  required List<String> photoUrls,
  required List<String> photoThumbnailUrls,
  required List<PhotoPromptAnswer> photoPrompts,
}) {
  final promptsByIndex = {
    for (final prompt in normalizePhotoPromptAnswers(photoPrompts))
      prompt.photoIndex: prompt,
  };
  final legacyEpoch = DateTime.fromMillisecondsSinceEpoch(0);
  final photos = <ProfilePhoto>[];
  for (final indexedUrl in photoUrls.indexed) {
    final index = indexedUrl.$1;
    final url = indexedUrl.$2.trim();
    if (url.isEmpty) continue;
    final thumbnailUrl =
        index < photoThumbnailUrls.length &&
            photoThumbnailUrls[index].trim().isNotEmpty
        ? photoThumbnailUrls[index].trim()
        : url;
    final storagePath =
        storagePathFromFirebaseDownloadUrl(url) ??
        'users/$uid/photos/legacy_$index.jpg';
    final thumbnailStoragePath =
        storagePathFromFirebaseDownloadUrl(thumbnailUrl) ??
        thumbnailStoragePathForStoragePath(storagePath);
    photos.add(
      ProfilePhoto(
        id: profilePhotoIdForStoragePath(storagePath, index),
        url: url,
        thumbnailUrl: thumbnailUrl,
        storagePath: storagePath,
        thumbnailStoragePath: thumbnailStoragePath,
        prompt: promptsByIndex[index],
        moderation: null,
        position: index,
        createdAt: legacyEpoch,
        updatedAt: legacyEpoch,
      ),
    );
  }
  return normalizeProfilePhotos(photos);
}

List<Map<String, dynamic>> profilePhotosToJson(Iterable<ProfilePhoto> photos) =>
    normalizeProfilePhotos(
      photos,
    ).map((photo) => photo.toJson()).toList(growable: false);

List<String> profilePhotoUrls(Iterable<ProfilePhoto> photos) =>
    normalizeProfilePhotos(
      photos,
    ).map((photo) => photo.url).toList(growable: false);

List<String> profilePhotoThumbnailUrls(Iterable<ProfilePhoto> photos) =>
    normalizeProfilePhotos(
      photos,
    ).map((photo) => photo.thumbnailUrl).toList(growable: false);

List<Map<String, dynamic>> profilePhotoPromptsToJson(
  Iterable<ProfilePhoto> photos,
) => normalizeProfilePhotos(photos)
    .where((photo) => photo.prompt != null)
    .map((photo) => photo.prompt!.copyWith(photoIndex: photo.position).toJson())
    .toList(growable: false);

ProfilePhoto replaceProfilePhotoPrompt({
  required ProfilePhoto photo,
  required PhotoPromptDefinition definition,
  required String caption,
}) {
  final normalizedCaption = normalizePhotoPromptCaption(caption);
  return photo.copyWith(
    prompt: normalizedCaption.isEmpty
        ? null
        : photoPromptAnswerFor(
            photoIndex: photo.position,
            definition: definition,
            caption: normalizedCaption,
          ),
    updatedAt: DateTime.now(),
  );
}

String? storagePathFromFirebaseDownloadUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final segments = uri.pathSegments;
  final objectMarkerIndex = segments.indexOf('o');
  if (objectMarkerIndex == -1 || objectMarkerIndex + 1 >= segments.length) {
    return null;
  }
  final objectPath = segments[objectMarkerIndex + 1];
  return objectPath.trim().isEmpty ? null : objectPath;
}

String thumbnailStoragePathForStoragePath(String storagePath) {
  final parts = storagePath.split('/');
  if (parts.length >= 4 && parts[0] == 'users' && parts[2] == 'photos') {
    final uid = parts[1];
    final sourceName = _stripExtension(parts.last);
    return 'users/$uid/photoThumbnails/$sourceName.jpg';
  }
  return '$storagePath.thumbnail.jpg';
}

String profilePhotoIdForStoragePath(String storagePath, int position) {
  final sourceName = _stripExtension(storagePath.split('/').last);
  final normalized = sourceName
      .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return normalized.isNotEmpty ? normalized : 'photo_$position';
}

PhotoPromptAnswer? _readPrompt(Object? value) {
  if (value is Map<String, dynamic>) return PhotoPromptAnswer.fromJson(value);
  if (value is Map) {
    return PhotoPromptAnswer.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

ProfilePhotoModeration? _readModeration(Object? value) {
  if (value is Map<String, dynamic>) {
    return ProfilePhotoModeration.fromJson(value);
  }
  if (value is Map) {
    return ProfilePhotoModeration.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

DateTime _readDateTime(Object? value) {
  if (value is Timestamp) return const TimestampConverter().fromJson(value);
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is Map) {
    final seconds = value['_seconds'];
    final nanos = value['_nanoseconds'];
    if (seconds is num && nanos is num) {
      return Timestamp(seconds.toInt(), nanos.toInt()).toDate();
    }
  }
  throw FormatException('Invalid profile photo timestamp: $value');
}

String _stripExtension(String fileName) {
  final dot = fileName.lastIndexOf('.');
  return dot <= 0 ? fileName : fileName.substring(0, dot);
}

const Object _sentinel = Object();
