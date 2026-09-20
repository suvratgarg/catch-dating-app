import 'package:catch_ui/catch_ui.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Field {
  catchBooking,
  admission,
  demandPricing,
  amounts,
  cohortCaps,
  capacity,
}

CatchFormDependencies<_Field> _policy({
  bool catchBooking = true,
  bool balanced = true,
  bool pricing = true,
  bool caps = true,
}) => CatchFormDependencies([
  CatchFormDependency(id: _Field.catchBooking, when: catchBooking),
  const CatchFormDependency(
    id: _Field.admission,
    prerequisites: [_Field.catchBooking],
  ),
  CatchFormDependency(
    id: _Field.demandPricing,
    parent: _Field.admission,
    when: balanced,
  ),
  CatchFormDependency(
    id: _Field.amounts,
    parent: _Field.demandPricing,
    when: pricing,
  ),
  CatchFormDependency(
    id: _Field.cohortCaps,
    parent: _Field.admission,
    when: !balanced,
  ),
  CatchFormDependency(
    id: _Field.capacity,
    parent: _Field.cohortCaps,
    when: caps,
  ),
]);

void main() {
  test(
    'ancestor changes deactivate descendants with retained local choices',
    () {
      final initial = _policy();
      expect(initial.isApplicable(_Field.amounts), isTrue);
      expect(initial.isApplicable(_Field.capacity), isFalse);

      final switched = _policy(balanced: false);
      expect(switched.node(_Field.amounts).when, isTrue);
      expect(switched.isApplicable(_Field.demandPricing), isFalse);
      expect(switched.isApplicable(_Field.amounts), isFalse);
      expect(switched.isApplicable(_Field.capacity), isTrue);

      final restored = _policy();
      expect(restored.isApplicable(_Field.amounts), isTrue);
      expect(restored.isApplicable(_Field.capacity), isFalse);
      expect(initial.isApplicable(_Field.amounts), isTrue);
    },
  );

  test(
    'other prerequisites affect applicability without adding visual depth',
    () {
      final active = _policy();
      expect(active.dependencyDepthOf(_Field.amounts), 3);
      expect(active.inlineDepthOf(_Field.amounts), 2);
      expect(active.pathTo(_Field.amounts), [
        _Field.admission,
        _Field.demandPricing,
        _Field.amounts,
      ]);
      expect(active.regionRootOf(_Field.amounts), _Field.admission);

      final externalBooking = _policy(catchBooking: false);
      expect(
        externalBooking.ids.every((id) => !externalBooking.isApplicable(id)),
        isTrue,
      );
    },
  );

  test('local disabling affects only that dependent branch', () {
    final form = _policy(pricing: false);
    expect(form.isApplicable(_Field.admission), isTrue);
    expect(form.isApplicable(_Field.demandPricing), isTrue);
    expect(form.isApplicable(_Field.amounts), isFalse);
    expect(form.isApplicable(_Field.catchBooking), isTrue);
  });

  test('rejects a third inline level even in an inactive branch', () {
    expect(
      () => CatchFormDependencies<int>([
        const CatchFormDependency(id: 0, when: false),
        const CatchFormDependency(id: 1, parent: 0),
        const CatchFormDependency(id: 2, parent: 1),
        const CatchFormDependency(id: 3, parent: 2),
      ]),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'diagnostic',
          contains('Declare a continuation or step'),
        ),
      ),
    );
  });

  for (final boundary in [
    CatchFormDependencyMode.continuation,
    CatchFormDependencyMode.step,
  ]) {
    test('$boundary starts a new region while retaining the full path', () {
      final form = CatchFormDependencies<int>([
        const CatchFormDependency(id: 0),
        const CatchFormDependency(id: 1, parent: 0),
        const CatchFormDependency(id: 2, parent: 1),
        CatchFormDependency(id: 3, parent: 2, boundary: boundary),
        const CatchFormDependency(id: 4, parent: 3),
      ]);
      expect(form.inlineDepthOf(2), 2);
      expect(form.inlineDepthOf(3), 0);
      expect(form.inlineDepthOf(4), 1);
      expect(form.regionRootOf(4), 3);
      expect(form.dependencyDepthOf(4), 4);
      expect(form.pathTo(4), [0, 1, 2, 3, 4]);
    });
  }

  test('deep graphs resolve iteratively with forward references', () {
    const count = 2048;
    final entries = List.generate(
      count,
      (id) => CatchFormDependency(
        id: id,
        parent: id == 0 ? null : id - 1,
        boundary: id > 0 && id % 3 == 0
            ? CatchFormDependencyMode.continuation
            : CatchFormDependencyMode.inline,
      ),
    );
    final form = CatchFormDependencies(entries.reversed);
    expect(form.ids.first, count - 1);
    expect(form.dependencyDepthOf(count - 1), count - 1);
    expect(form.inlineDepthOf(count - 1), (count - 1) % 3);
    expect(form.isApplicable(count - 1), isTrue);
    expect(form.pathTo(count - 1), List.generate(count, (id) => id));
  });

  test('requires every prerequisite but renders through one owner', () {
    final form = CatchFormDependencies([
      const CatchFormDependency(id: 0),
      const CatchFormDependency(id: 1, when: false),
      const CatchFormDependency(id: 2, parent: 0, prerequisites: [1]),
    ]);
    expect(form.isApplicable(0), isTrue);
    expect(form.isApplicable(2), isFalse);
    expect(form.pathTo(2), [0, 2]);
    expect(form.inlineDepthOf(2), 1);
  });

  test(
    'snapshots input collections and deduplicates repeated prerequisites',
    () {
      final prerequisites = <int>[0, 0];
      final entries = [
        const CatchFormDependency(id: 0),
        CatchFormDependency(id: 1, parent: 0, prerequisites: prerequisites),
      ];
      final form = CatchFormDependencies(entries);
      prerequisites.add(99);
      entries.clear();
      expect(form.isApplicable(1), isTrue);
      expect(form.node(1).prerequisites, [0, 0]);
      expect(() => form.node(1).prerequisites.add(2), throwsUnsupportedError);
      expect(() => form.pathTo(1).add(2), throwsUnsupportedError);
    },
  );

  test(
    'rejects duplicate IDs and missing ownership or prerequisite references',
    () {
      expect(
        () => CatchFormDependencies([
          const CatchFormDependency(id: 0),
          const CatchFormDependency(id: 0),
        ]),
        throwsArgumentError,
      );
      expect(
        () => CatchFormDependencies([
          const CatchFormDependency(id: 0, parent: 99),
        ]),
        throwsArgumentError,
      );
      expect(
        () => CatchFormDependencies([
          const CatchFormDependency(id: 0, prerequisites: [99]),
        ]),
        throwsArgumentError,
      );
    },
  );

  test(
    'rejects cycles through ownership, prerequisites, or their combination',
    () {
      for (final entries in [
        [const CatchFormDependency(id: 0, parent: 0)],
        [
          const CatchFormDependency(id: 0, parent: 1),
          const CatchFormDependency(id: 1, parent: 0),
        ],
        [
          const CatchFormDependency(id: 0, prerequisites: [1], when: false),
          const CatchFormDependency(id: 1, parent: 0),
        ],
      ]) {
        expect(
          () => CatchFormDependencies(entries),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'diagnostic',
              contains('Cyclic form dependencies'),
            ),
          ),
        );
      }
    },
  );

  test('unknown lookups fail closed and an empty form is valid', () {
    final form = CatchFormDependencies<int>([]);
    expect(form.ids, isEmpty);
    expect(() => form.isApplicable(1), throwsArgumentError);
    expect(() => form.inlineDepthOf(1), throwsArgumentError);
    expect(() => form.dependencyDepthOf(1), throwsArgumentError);
    expect(() => form.regionRootOf(1), throwsArgumentError);
    expect(() => form.pathTo(1), throwsArgumentError);
  });
}
