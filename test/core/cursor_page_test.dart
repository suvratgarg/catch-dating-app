import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CursorPageAccumulator', () {
    test('appends pages in order and de-duplicates stable identities', () {
      const first = CursorPage<_Item, String>(
        items: [_Item('a'), _Item('b')],
        nextCursor: 'page-2',
        hasMore: true,
      );
      const second = CursorPage<_Item, String>(
        items: [_Item('b'), _Item('c')],
        hasMore: false,
      );

      final accumulated = const CursorPageAccumulator<_Item, String>()
          .append(first, idOf: (item) => item.id)
          .append(second, idOf: (item) => item.id);

      expect(accumulated.items.map((item) => item.id), ['a', 'b', 'c']);
      expect(accumulated.hasMore, false);
      expect(accumulated.nextCursor, isNull);
      expect(accumulated.isLoadingMore, false);
    });

    test('copyWith can clear an exhausted cursor for a fresh session', () {
      const state = CursorPageAccumulator<_Item, String>(
        items: [_Item('a')],
        nextCursor: 'stale',
      );

      final reset = state.copyWith(
        items: const [],
        clearCursor: true,
        hasMore: true,
      );

      expect(reset.items, isEmpty);
      expect(reset.nextCursor, isNull);
      expect(reset.hasMore, true);
    });
  });
}

class _Item {
  const _Item(this.id);

  final String id;
}
