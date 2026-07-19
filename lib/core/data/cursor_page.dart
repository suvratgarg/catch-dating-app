import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// One bounded page plus the opaque cursor required to fetch its successor.
@immutable
class CursorPage<T, C> {
  const CursorPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  }) : assert(hasMore == false || nextCursor != null);

  final List<T> items;
  final C? nextCursor;
  final bool hasMore;

  static CursorPage<T, C> empty<T, C>() =>
      CursorPage(items: List<T>.empty(), hasMore: false);
}

/// Provider-friendly page accumulation state.
///
/// Repositories own cursor acquisition. Notifiers own this immutable state and
/// call [append] after each successful page, which de-duplicates records by
/// stable identity and preserves server order.
@immutable
class CursorPageAccumulator<T, C> {
  const CursorPageAccumulator({
    this.items = const [],
    this.nextCursor,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<T> items;
  final C? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  CursorPageAccumulator<T, C> copyWith({
    List<T>? items,
    C? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CursorPageAccumulator(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  CursorPageAccumulator<T, C> append(
    CursorPage<T, C> page, {
    required Object Function(T item) idOf,
  }) {
    final seen = <Object>{};
    final merged = <T>[];
    for (final item in [...items, ...page.items]) {
      if (seen.add(idOf(item))) merged.add(item);
    }
    return CursorPageAccumulator(
      items: List.unmodifiable(merged),
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }
}

/// Shared Firestore `startAfterDocument` window fetch.
///
/// Fetching `limit + 1` makes [CursorPage.hasMore] truthful without an extra
/// count query. The cursor points at the final *returned* document so the
/// look-ahead document appears at the start of the next page rather than being
/// skipped.
extension FirestoreCursorQuery<T> on Query<T> {
  Future<CursorPage<QueryDocumentSnapshot<T>, DocumentSnapshot<T>>>
  fetchDocumentCursorPage({
    required int limit,
    DocumentSnapshot<T>? startAfter,
    required BackendErrorContext errorContext,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be greater than zero.');
    }

    return withBackendErrorContext(() async {
      final windowed = startAfter == null
          ? this
          : startAfterDocument(startAfter);
      final snapshot = await windowed.limit(limit + 1).get();
      final hasMore = snapshot.docs.length > limit;
      final visibleDocs = snapshot.docs.take(limit).toList();
      return CursorPage(
        items: List.unmodifiable(visibleDocs),
        nextCursor: hasMore && visibleDocs.isNotEmpty ? visibleDocs.last : null,
        hasMore: hasMore,
      );
    }, context: errorContext);
  }
}
