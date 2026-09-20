import 'dart:collection';

import 'package:catch_ui/src/patterns/catch_form_dependency.dart';
import 'package:catch_ui/src/patterns/catch_form_dependency_mode.dart';

/// Validated, immutable applicability snapshot for one form state.
///
/// Logical dependencies have no small hard-coded depth limit. Each presented
/// region allows two ownership edges below its root. A deeper branch must
/// declare a continuation or step boundary, including when currently inactive.
///
/// This model owns neither values nor saving. An inactive value can remain in
/// a draft; the feature contract still owns validation and serialization.
/// Collapsing an applicable editor does not change its applicability.
final class CatchFormDependencies<K extends Object> {
  factory CatchFormDependencies(Iterable<CatchFormDependency<K>> entries) {
    final nodes = <K, CatchFormDependency<K>>{};
    for (final entry in entries) {
      if (nodes.containsKey(entry.id)) {
        throw ArgumentError('Duplicate form dependency: ${entry.id}.');
      }
      nodes[entry.id] = CatchFormDependency<K>(
        id: entry.id,
        parent: entry.parent,
        prerequisites: List.unmodifiable(entry.prerequisites),
        when: entry.when,
        boundary: entry.boundary,
      );
    }

    final requiredIds = <K, Set<K>>{};
    final dependents = <K, List<K>>{};
    final remaining = <K, int>{};
    for (final entry in nodes.values) {
      final requirements = <K>{?entry.parent, ...entry.prerequisites};
      for (final requirement in requirements) {
        if (!nodes.containsKey(requirement)) {
          throw ArgumentError(
            'Form dependency ${entry.id} references unknown prerequisite '
            '$requirement.',
          );
        }
        dependents.putIfAbsent(requirement, () => []).add(entry.id);
      }
      requiredIds[entry.id] = requirements;
      remaining[entry.id] = requirements.length;
    }

    // Iterative traversal avoids imposing the Dart call-stack depth on a
    // valid hierarchy. Declaration order breaks ties deterministically.
    final ready = Queue<K>.of(nodes.keys.where((id) => remaining[id] == 0));
    final applicability = <K, bool>{};
    final dependencyDepth = <K, int>{};
    final inlineDepth = <K, int>{};
    final regionRoot = <K, K>{};
    while (ready.isNotEmpty) {
      final id = ready.removeFirst();
      final entry = nodes[id]!;
      final requirements = requiredIds[id]!;
      applicability[id] =
          entry.when && requirements.every((id) => applicability[id]!);
      dependencyDepth[id] = requirements.fold(
        0,
        (depth, id) =>
            depth > dependencyDepth[id]! + 1 ? depth : dependencyDepth[id]! + 1,
      );
      final parent = entry.parent;
      final startsRegion =
          parent == null || entry.boundary != CatchFormDependencyMode.inline;
      inlineDepth[id] = startsRegion ? 0 : inlineDepth[parent]! + 1;
      regionRoot[id] = startsRegion ? id : regionRoot[parent]!;
      for (final dependent in dependents[id] ?? <K>[]) {
        final count = remaining[dependent]! - 1;
        remaining[dependent] = count;
        if (count == 0) ready.add(dependent);
      }
    }

    if (applicability.length != nodes.length) {
      final unresolved = nodes.keys.where(
        (id) => !applicability.containsKey(id),
      );
      throw ArgumentError(
        'Cyclic form dependencies prevent resolving: '
        '${unresolved.join(', ')}.',
      );
    }
    for (final id in nodes.keys) {
      if (inlineDepth[id]! > maxInlineDepth) {
        throw ArgumentError(
          'Form dependency $id exceeds $maxInlineDepth dependent levels '
          'in region ${regionRoot[id]}. Declare a continuation or step '
          'at a meaningful task boundary.',
        );
      }
    }

    return CatchFormDependencies._(
      Map.unmodifiable(nodes),
      Map.unmodifiable(applicability),
      Map.unmodifiable(dependencyDepth),
      Map.unmodifiable(inlineDepth),
      Map.unmodifiable(regionRoot),
    );
  }

  const CatchFormDependencies._(
    this._nodes,
    this._applicability,
    this._dependencyDepth,
    this._inlineDepth,
    this._regionRoot,
  );

  static const maxInlineDepth = 2;

  final Map<K, CatchFormDependency<K>> _nodes;
  final Map<K, bool> _applicability;
  final Map<K, int> _dependencyDepth;
  final Map<K, int> _inlineDepth;
  final Map<K, K> _regionRoot;

  /// IDs in authored presentation order, independent of evaluation order.
  Iterable<K> get ids => _nodes.keys;

  CatchFormDependency<K> node(K id) {
    final result = _nodes[id];
    if (result == null) {
      throw ArgumentError.value(id, 'id', 'Unknown form dependency');
    }
    return result;
  }

  bool isApplicable(K id) {
    node(id);
    return _applicability[id]!;
  }

  /// Longest prerequisite chain, including non-owning prerequisites.
  int dependencyDepthOf(K id) {
    node(id);
    return _dependencyDepth[id]!;
  }

  /// Ownership depth within the explicitly declared presentation region.
  int inlineDepthOf(K id) {
    node(id);
    return _inlineDepth[id]!;
  }

  K regionRootOf(K id) {
    node(id);
    return _regionRoot[id]!;
  }

  /// Full ownership path, root first and including [id].
  ///
  /// This remains available across continuation boundaries for ancestor
  /// summaries and error recovery. It does not omit inactive ancestors.
  List<K> pathTo(K id) {
    final reversed = <K>[];
    K? current = id;
    while (current != null) {
      final entry = node(current);
      reversed.add(entry.id);
      current = entry.parent;
    }
    return List.unmodifiable(reversed.reversed);
  }
}
