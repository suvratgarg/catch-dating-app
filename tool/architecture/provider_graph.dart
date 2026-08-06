import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

const providerGraphSchemaVersion = 1;
const providerGraphReviewPath = 'tool/architecture/provider_graph_reviews.json';

const _providerConstructors = <String>{
  'Provider',
  'FutureProvider',
  'StreamProvider',
  'StateProvider',
  'NotifierProvider',
  'AsyncNotifierProvider',
  'StreamNotifierProvider',
  'ChangeNotifierProvider',
  'StateNotifierProvider',
};
const _refOperations = <String>{
  'watch',
  'read',
  'listen',
  'listenManual',
  'invalidate',
  'refresh',
};
const _reactiveOperations = <String>{'watch', 'listen', 'listenManual'};
final _providerReferencePattern = RegExp(
  r'\b([A-Za-z_][A-Za-z0-9_]*Provider)\b',
);
final _mutationReferencePattern = RegExp(
  r'\b([A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*)\b',
);

final class ProviderGraphNode {
  const ProviderGraphNode({
    required this.name,
    required this.kind,
    required this.path,
    required this.line,
    required this.feature,
    required this.layer,
    required this.keepAlive,
    required this.isFamily,
    required this.returnType,
    required this.start,
    required this.end,
  });

  final String name;
  final String kind;
  final String path;
  final int line;
  final String feature;
  final String layer;
  final bool keepAlive;
  final bool isFamily;
  final String? returnType;
  final int start;
  final int end;

  String get id => 'provider:$name';

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'kind': kind,
    'path': path,
    'line': line,
    'feature': feature,
    'layer': layer,
    'keepAlive': keepAlive,
    'family': isFamily,
    if (returnType != null) 'returnType': returnType,
  };
}

final class MutationGraphNode {
  const MutationGraphNode({
    required this.name,
    required this.path,
    required this.line,
    required this.feature,
    required this.layer,
  });

  final String name;
  final String path;
  final int line;
  final String feature;
  final String layer;

  String get id => 'mutation:$name';

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'line': line,
    'feature': feature,
    'layer': layer,
  };
}

final class ConsumerGraphNode {
  const ConsumerGraphNode({
    required this.id,
    required this.owner,
    required this.path,
    required this.line,
    required this.feature,
    required this.layer,
  });

  final String id;
  final String owner;
  final String path;
  final int line;
  final String feature;
  final String layer;

  Map<String, Object?> toJson() => {
    'id': id,
    'owner': owner,
    'path': path,
    'line': line,
    'feature': feature,
    'layer': layer,
  };
}

final class ProviderGraphEdge {
  const ProviderGraphEdge({
    required this.source,
    required this.sourceKind,
    required this.target,
    required this.targetKind,
    required this.operation,
    required this.path,
    required this.line,
  });

  final String source;
  final String sourceKind;
  final String target;
  final String targetKind;
  final String operation;
  final String path;
  final int line;

  bool get isProviderEdge =>
      sourceKind == 'provider' && targetKind == 'provider';

  Map<String, Object?> toJson() => {
    'source': source,
    'sourceKind': sourceKind,
    'target': target,
    'targetKind': targetKind,
    'operation': operation,
    'path': path,
    'line': line,
  };
}

final class ArchitectureCandidate {
  const ArchitectureCandidate({
    required this.id,
    required this.kind,
    required this.severity,
    required this.subject,
    required this.reason,
    required this.recommendation,
    this.source,
    this.target,
    this.metric,
  });

  final String id;
  final String kind;
  final String severity;
  final String subject;
  final String reason;
  final String recommendation;
  final String? source;
  final String? target;
  final int? metric;

  Map<String, Object?> toJson(Map<String, Object?>? review) => {
    'id': id,
    'kind': kind,
    'severity': severity,
    'subject': subject,
    'reason': reason,
    'recommendation': recommendation,
    if (source != null) 'source': source,
    if (target != null) 'target': target,
    if (metric != null) 'metric': metric,
    'review': review,
  };
}

final class ProviderGraph {
  const ProviderGraph({
    required this.sourceFiles,
    required this.providers,
    required this.mutations,
    required this.consumers,
    required this.edges,
    required this.unresolvedReferences,
    required this.duplicateProviderNames,
    required this.danglingProviderTargets,
    required this.reactiveCycles,
    required this.allOperationCycles,
    required this.candidates,
    required this.reviewDecisions,
    required this.unreviewedCandidateIds,
    required this.staleReviewIds,
  });

  final int sourceFiles;
  final List<ProviderGraphNode> providers;
  final List<MutationGraphNode> mutations;
  final List<ConsumerGraphNode> consumers;
  final List<ProviderGraphEdge> edges;
  final List<Map<String, Object?>> unresolvedReferences;
  final List<String> duplicateProviderNames;
  final List<String> danglingProviderTargets;
  final List<List<String>> reactiveCycles;
  final List<List<String>> allOperationCycles;
  final List<ArchitectureCandidate> candidates;
  final Map<String, Map<String, Object?>> reviewDecisions;
  final List<String> unreviewedCandidateIds;
  final List<String> staleReviewIds;

  Iterable<ProviderGraphEdge> get providerEdges =>
      edges.where((edge) => edge.isProviderEdge);
  Iterable<ProviderGraphEdge> get consumerEdges =>
      edges.where((edge) => edge.sourceKind == 'consumer');
  Iterable<ProviderGraphEdge> get mutationEdges =>
      edges.where((edge) => edge.targetKind == 'mutation');
  List<Map<String, Object?>> get unresolvedInsideProviders =>
      unresolvedReferences
          .where((reference) => reference['sourceKind'] == 'provider')
          .toList(growable: false);

  Map<String, Object?> get summary {
    final uniquePairs = <String>{};
    final crossFeaturePairs = <String>{};
    final byName = {for (final provider in providers) provider.name: provider};
    for (final edge in providerEdges) {
      final key = '${edge.source}\u0000${edge.target}';
      if (!uniquePairs.add(key)) continue;
      final source = byName[edge.source];
      final target = byName[edge.target];
      if (source != null &&
          target != null &&
          source.feature != target.feature) {
        crossFeaturePairs.add(key);
      }
    }
    return {
      'dartSourceFiles': sourceFiles,
      'providerNodes': providers.length,
      'generatedProviderNodes': providers
          .where((provider) => provider.kind.startsWith('generated'))
          .length,
      'manualProviderNodes': providers
          .where((provider) => provider.kind == 'manual')
          .length,
      'aliasProviderNodes': providers
          .where((provider) => provider.kind == 'alias')
          .length,
      'keepAliveNodes': providers
          .where((provider) => provider.keepAlive)
          .length,
      'familyNodes': providers.where((provider) => provider.isFamily).length,
      'mutationNodes': mutations.length,
      'consumerNodes': consumers.length,
      'providerToProviderCallsites': providerEdges.length,
      'uniqueProviderToProviderPairs': uniquePairs.length,
      'uniqueCrossFeatureProviderPairs': crossFeaturePairs.length,
      'consumerToStateCallsites': consumerEdges.length,
      'mutationReferenceCallsites': mutationEdges.length,
      'unresolvedRefOperations': unresolvedReferences.length,
      'unresolvedInsideProviders': unresolvedInsideProviders.length,
      'duplicateProviderNames': duplicateProviderNames.length,
      'danglingProviderTargets': danglingProviderTargets.length,
      'reactiveCycles': reactiveCycles.length,
      'allOperationCycles': allOperationCycles.length,
      'architectureCandidates': candidates.length,
      'unreviewedArchitectureCandidates': unreviewedCandidateIds.length,
      'staleArchitectureReviews': staleReviewIds.length,
    };
  }

  bool get isHealthy =>
      duplicateProviderNames.isEmpty &&
      danglingProviderTargets.isEmpty &&
      unresolvedInsideProviders.isEmpty &&
      reactiveCycles.isEmpty &&
      unreviewedCandidateIds.isEmpty &&
      staleReviewIds.isEmpty;

  Map<String, Object?> get health => {
    'healthy': isHealthy,
    'duplicateProviderNames': duplicateProviderNames,
    'danglingProviderTargets': danglingProviderTargets,
    'unresolvedInsideProviders': unresolvedInsideProviders,
    'reactiveCycles': reactiveCycles,
    'allOperationCycles': allOperationCycles,
    'unreviewedArchitectureCandidateIds': unreviewedCandidateIds,
    'staleArchitectureReviewIds': staleReviewIds,
  };

  Map<String, Object?> toJson() {
    final byName = {for (final provider in providers) provider.name: provider};
    final providerEdgeList = providerEdges.toList(growable: false);
    final featurePairs = <String, int>{};
    final layerPairs = <String, int>{};
    final uniquePairs = <String>{};
    for (final edge in providerEdgeList) {
      if (!uniquePairs.add('${edge.source}\u0000${edge.target}')) continue;
      final source = byName[edge.source];
      final target = byName[edge.target];
      if (source == null || target == null) continue;
      _increment(featurePairs, '${source.feature} -> ${target.feature}');
      _increment(layerPairs, '${source.layer} -> ${target.layer}');
    }
    return {
      'schemaVersion': providerGraphSchemaVersion,
      'sourceRoots': ['lib'],
      'summary': summary,
      'health': health,
      'providersByFeature': _countsBy(
        providers.map((provider) => provider.feature),
      ),
      'providersByLayer': _countsBy(
        providers.map((provider) => provider.layer),
      ),
      'providerEdgesByOperation': _countsBy(
        providerEdgeList.map((edge) => edge.operation),
      ),
      'consumerEdgesByOperation': _countsBy(
        consumerEdges.map((edge) => edge.operation),
      ),
      'featurePairCounts': _sortedCounts(featurePairs),
      'layerPairCounts': _sortedCounts(layerPairs),
      'topUniqueFanOut': _topDegrees(
        providerEdgeList,
        field: 'source',
        uniqueNeighbors: true,
      ),
      'topUniqueFanIn': _topDegrees(
        providerEdgeList,
        field: 'target',
        uniqueNeighbors: true,
      ),
      'features': _featureGraph(providerEdgeList),
      'architectureReview': {
        'reviewPath': providerGraphReviewPath,
        'candidates': [
          for (final candidate in candidates)
            candidate.toJson(reviewDecisions[candidate.id]),
        ],
      },
      'providers': providers.map((provider) => provider.toJson()).toList(),
      'mutations': mutations.map((mutation) => mutation.toJson()).toList(),
      'consumers': consumers.map((consumer) => consumer.toJson()).toList(),
      'providerEdges': providerEdgeList.map((edge) => edge.toJson()).toList(),
      'consumerEdges': consumerEdges.map((edge) => edge.toJson()).toList(),
      'mutationEdges': mutationEdges.map((edge) => edge.toJson()).toList(),
      'unresolvedReferences': unresolvedReferences,
    };
  }

  Map<String, Object?> _featureGraph(List<ProviderGraphEdge> providerEdgeList) {
    final byName = {for (final provider in providers) provider.name: provider};
    final names = <String>{
      ...providers.map((provider) => provider.feature),
      ...mutations.map((mutation) => mutation.feature),
      ...consumers.map((consumer) => consumer.feature),
    }.toList()..sort();
    final uniquePairs = <String>{};
    final aggregated = <String, Map<String, Object?>>{};
    for (final edge in providerEdgeList) {
      if (!uniquePairs.add('${edge.source}\u0000${edge.target}')) continue;
      final source = byName[edge.source];
      final target = byName[edge.target];
      if (source == null || target == null) continue;
      final key = '${source.feature}\u0000${target.feature}';
      final item = aggregated.putIfAbsent(
        key,
        () => {
          'source': source.feature,
          'target': target.feature,
          'uniqueProviderPairs': 0,
        },
      );
      item['uniqueProviderPairs'] = (item['uniqueProviderPairs'] as int) + 1;
    }
    final graphEdges = aggregated.values.toList()
      ..sort((a, b) {
        final source = (a['source'] as String).compareTo(b['source'] as String);
        if (source != 0) return source;
        return (a['target'] as String).compareTo(b['target'] as String);
      });
    return {
      'nodes': [
        for (final name in names)
          {
            'id': name,
            'providers': providers
                .where((provider) => provider.feature == name)
                .length,
            'mutations': mutations
                .where((mutation) => mutation.feature == name)
                .length,
            'consumers': consumers
                .where((consumer) => consumer.feature == name)
                .length,
          },
      ],
      'edges': graphEdges,
    };
  }
}

final class _ScannedFile {
  const _ScannedFile({
    required this.path,
    required this.unit,
    required this.lineFor,
    required this.providers,
  });

  final String path;
  final CompilationUnit unit;
  final int Function(int offset) lineFor;
  final List<ProviderGraphNode> providers;
}

Future<ProviderGraph> buildProviderGraph(
  Directory root, {
  String reviewPath = providerGraphReviewPath,
}) async {
  final absoluteRoot = root.absolute;
  final lib = Directory('${absoluteRoot.path}/lib');
  if (!lib.existsSync()) {
    throw StateError('Expected a lib directory under ${absoluteRoot.path}.');
  }
  final files = await lib
      .list(recursive: true, followLinks: false)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .where(
        (file) =>
            !file.path.endsWith('.g.dart') &&
            !file.path.endsWith('.freezed.dart'),
      )
      .toList();
  files.sort((a, b) => a.path.compareTo(b.path));

  final providers = <ProviderGraphNode>[];
  final mutations = <MutationGraphNode>[];
  final scannedFiles = <_ScannedFile>[];
  final aliasEdges = <ProviderGraphEdge>[];

  for (final file in files) {
    final relativePath = _relativePath(absoluteRoot.path, file.path);
    final content = await file.readAsString();
    final parseResult = parseString(
      content: content,
      path: file.path,
      throwIfDiagnostics: false,
    );
    int lineFor(int offset) =>
        parseResult.lineInfo.getLocation(offset).lineNumber;
    final fileProviders = <ProviderGraphNode>[];

    for (final declaration in parseResult.unit.declarations) {
      if (declaration is FunctionDeclaration &&
          _hasRiverpodAnnotation(declaration.metadata)) {
        final parameterCount =
            declaration.functionExpression.parameters?.parameters.length ?? 0;
        fileProviders.add(
          ProviderGraphNode(
            name: '${declaration.name.lexeme}Provider',
            kind: 'generated-function',
            path: relativePath,
            line: lineFor(declaration.offset),
            feature: _featureFor(relativePath),
            layer: _layerFor(relativePath),
            keepAlive: _isKeepAlive(declaration.metadata),
            isFamily: parameterCount > 1,
            returnType: declaration.returnType?.toSource(),
            start: declaration.offset,
            end: declaration.end,
          ),
        );
      } else if (declaration is ClassDeclaration &&
          _hasRiverpodAnnotation(declaration.metadata)) {
        final className = declaration.namePart.typeName.lexeme;
        final buildMethod = declaration.body.members
            .whereType<MethodDeclaration>()
            .where((method) => method.name.lexeme == 'build')
            .firstOrNull;
        fileProviders.add(
          ProviderGraphNode(
            name: '${_lowerCamelClassName(className)}Provider',
            kind: 'generated-class',
            path: relativePath,
            line: lineFor(declaration.offset),
            feature: _featureFor(relativePath),
            layer: _layerFor(relativePath),
            keepAlive: _isKeepAlive(declaration.metadata),
            isFamily: (buildMethod?.parameters?.parameters.length ?? 0) > 0,
            returnType: buildMethod?.returnType?.toSource(),
            start: declaration.offset,
            end: declaration.end,
          ),
        );
      } else if (declaration is TopLevelVariableDeclaration) {
        for (final variable in declaration.variables.variables) {
          final name = variable.name.lexeme;
          final initializer = variable.initializer;
          if (initializer == null || !name.endsWith('Provider')) continue;
          final source = initializer.toSource().trim();
          final constructor = RegExp(
            r'^([A-Za-z_][A-Za-z0-9_]*)',
          ).firstMatch(source)?.group(1);
          final isManual =
              constructor != null &&
              _providerConstructors.contains(constructor);
          final isAlias = RegExp(
            r'^[A-Za-z_][A-Za-z0-9_]*Provider$',
          ).hasMatch(source);
          if (!isManual && !isAlias) continue;
          fileProviders.add(
            ProviderGraphNode(
              name: name,
              kind: isAlias ? 'alias' : 'manual',
              path: relativePath,
              line: lineFor(declaration.offset),
              feature: _featureFor(relativePath),
              layer: _layerFor(relativePath),
              keepAlive: isManual && !source.contains('autoDispose'),
              isFamily: source.contains('.family'),
              returnType: declaration.variables.type?.toSource(),
              start: declaration.offset,
              end: declaration.end,
            ),
          );
          if (isAlias) {
            aliasEdges.add(
              ProviderGraphEdge(
                source: name,
                sourceKind: 'provider',
                target: source,
                targetKind: 'provider',
                operation: 'alias',
                path: relativePath,
                line: lineFor(declaration.offset),
              ),
            );
          }
        }
      }
    }

    for (final declaration
        in parseResult.unit.declarations.whereType<ClassDeclaration>()) {
      final owner = declaration.namePart.typeName.lexeme;
      for (final field
          in declaration.body.members.whereType<FieldDeclaration>()) {
        for (final variable in field.fields.variables) {
          final initializer = variable.initializer?.toSource() ?? '';
          if (!RegExp(r'^Mutation(?:<|\()').hasMatch(initializer)) continue;
          mutations.add(
            MutationGraphNode(
              name: '$owner.${variable.name.lexeme}',
              path: relativePath,
              line: lineFor(variable.offset),
              feature: _featureFor(relativePath),
              layer: _layerFor(relativePath),
            ),
          );
        }
      }
    }
    providers.addAll(fileProviders);
    scannedFiles.add(
      _ScannedFile(
        path: relativePath,
        unit: parseResult.unit,
        lineFor: lineFor,
        providers: fileProviders,
      ),
    );
  }

  providers.sort(_compareProviderNodes);
  mutations.sort((a, b) => a.name.compareTo(b.name));
  final providerNames = providers.map((provider) => provider.name).toSet();
  final mutationNames = mutations.map((mutation) => mutation.name).toSet();
  final consumers = <String, ConsumerGraphNode>{};
  final edges = <ProviderGraphEdge>[...aliasEdges];
  final unresolved = <Map<String, Object?>>[];
  for (final scanned in scannedFiles) {
    scanned.unit.accept(
      _ReferenceVisitor(
        path: scanned.path,
        lineFor: scanned.lineFor,
        fileProviders: scanned.providers,
        mutationNames: mutationNames,
        consumers: consumers,
        edges: edges,
        unresolved: unresolved,
      ),
    );
  }
  edges.sort(_compareEdges);
  final consumerList = consumers.values.toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  unresolved.sort((a, b) {
    final path = (a['path'] as String).compareTo(b['path'] as String);
    return path != 0 ? path : (a['line'] as int).compareTo(b['line'] as int);
  });
  final duplicateCounts = <String, int>{};
  for (final provider in providers) {
    _increment(duplicateCounts, provider.name);
  }
  final duplicates =
      duplicateCounts.entries
          .where((entry) => entry.value > 1)
          .map((entry) => entry.key)
          .toList()
        ..sort();
  final danglingTargets =
      edges
          .where((edge) => edge.isProviderEdge)
          .where((edge) => !providerNames.contains(edge.target))
          .map((edge) => edge.target)
          .toSet()
          .toList()
        ..sort();
  final providerEdges = edges
      .where((edge) => edge.isProviderEdge)
      .toList(growable: false);
  final reactiveCycles = _stronglyConnectedComponents(
    providerEdges.where((edge) => _reactiveOperations.contains(edge.operation)),
  );
  final allCycles = _stronglyConnectedComponents(providerEdges);
  final candidates = _architectureCandidates(providers, providerEdges);
  final decisions = _readReviewDecisions(
    File('${absoluteRoot.path}/$reviewPath'),
  );
  final candidateIds = candidates.map((candidate) => candidate.id).toSet();
  final unreviewed =
      candidateIds.where((id) => !decisions.containsKey(id)).toList()..sort();
  final stale =
      decisions.keys.where((id) => !candidateIds.contains(id)).toList()..sort();
  return ProviderGraph(
    sourceFiles: files.length,
    providers: providers,
    mutations: mutations,
    consumers: consumerList,
    edges: edges,
    unresolvedReferences: unresolved,
    duplicateProviderNames: duplicates,
    danglingProviderTargets: danglingTargets,
    reactiveCycles: reactiveCycles,
    allOperationCycles: allCycles,
    candidates: candidates,
    reviewDecisions: decisions,
    unreviewedCandidateIds: unreviewed,
    staleReviewIds: stale,
  );
}

final class _ReferenceVisitor extends RecursiveAstVisitor<void> {
  _ReferenceVisitor({
    required this.path,
    required this.lineFor,
    required this.fileProviders,
    required this.mutationNames,
    required this.consumers,
    required this.edges,
    required this.unresolved,
  });

  final String path;
  final int Function(int offset) lineFor;
  final List<ProviderGraphNode> fileProviders;
  final Set<String> mutationNames;
  final Map<String, ConsumerGraphNode> consumers;
  final List<ProviderGraphEdge> edges;
  final List<Map<String, Object?>> unresolved;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final operation = node.methodName.name;
    final targetSource = node.realTarget?.toSource();
    if (_refOperations.contains(operation) && targetSource == 'ref') {
      final arguments = node.argumentList.arguments;
      _record(
        node,
        operation,
        arguments.isEmpty ? '' : arguments.first.toSource(),
      );
    } else if (operation.startsWith('overrideWith') &&
        targetSource != null &&
        _providerReferencePattern.hasMatch(targetSource)) {
      _record(node, 'override', targetSource);
    } else if (operation == 'run' &&
        targetSource != null &&
        mutationNames.contains(targetSource)) {
      _record(node, 'mutation-run', targetSource);
    }
    super.visitMethodInvocation(node);
  }

  void _record(MethodInvocation node, String operation, String reference) {
    final provider = _providerAt(node.offset, node.end);
    final sourceKind = provider == null ? 'consumer' : 'provider';
    final source = provider?.name ?? _consumerFor(node).id;
    final providerMatch = _providerReferencePattern.firstMatch(reference);
    final mutationMatch = _mutationReferencePattern.firstMatch(reference);
    if (providerMatch != null) {
      edges.add(
        ProviderGraphEdge(
          source: source,
          sourceKind: sourceKind,
          target: providerMatch.group(1)!,
          targetKind: 'provider',
          operation: operation,
          path: path,
          line: lineFor(node.offset),
        ),
      );
      return;
    }
    final mutationName = mutationMatch?.group(1);
    if (mutationName != null && mutationNames.contains(mutationName)) {
      edges.add(
        ProviderGraphEdge(
          source: source,
          sourceKind: sourceKind,
          target: mutationName,
          targetKind: 'mutation',
          operation: operation,
          path: path,
          line: lineFor(node.offset),
        ),
      );
      return;
    }
    unresolved.add({
      'source': source,
      'sourceKind': sourceKind,
      'operation': operation,
      'reference': reference,
      'path': path,
      'line': lineFor(node.offset),
    });
  }

  ProviderGraphNode? _providerAt(int start, int end) {
    ProviderGraphNode? result;
    for (final candidate in fileProviders) {
      if (candidate.start > start || end > candidate.end) continue;
      if (result == null ||
          candidate.end - candidate.start < result.end - result.start) {
        result = candidate;
      }
    }
    return result;
  }

  ConsumerGraphNode _consumerFor(AstNode node) {
    AstNode? cursor = node;
    var owner = '<top-level>';
    var ownerLine = lineFor(node.offset);
    while (cursor != null) {
      if (cursor is MethodDeclaration) {
        owner =
            '${_enclosingClassName(cursor) ?? '<extension>'}.${cursor.name.lexeme}';
        ownerLine = lineFor(cursor.offset);
        break;
      }
      if (cursor is ConstructorDeclaration) {
        final className = _enclosingClassName(cursor) ?? '<class>';
        final constructorName = cursor.name?.lexeme;
        owner = constructorName == null
            ? '$className.new'
            : '$className.$constructorName';
        ownerLine = lineFor(cursor.offset);
        break;
      }
      if (cursor is FunctionDeclaration) {
        owner = cursor.name.lexeme;
        ownerLine = lineFor(cursor.offset);
        break;
      }
      if (cursor is VariableDeclaration) {
        owner = cursor.name.lexeme;
        ownerLine = lineFor(cursor.offset);
      }
      cursor = cursor.parent;
    }
    final id = 'consumer:$path#$owner';
    return consumers.putIfAbsent(
      id,
      () => ConsumerGraphNode(
        id: id,
        owner: owner,
        path: path,
        line: ownerLine,
        feature: _featureFor(path),
        layer: _layerFor(path),
      ),
    );
  }
}

String? _enclosingClassName(AstNode node) {
  AstNode? cursor = node.parent;
  while (cursor != null) {
    if (cursor is ClassDeclaration) {
      return cursor.namePart.typeName.lexeme;
    }
    cursor = cursor.parent;
  }
  return null;
}

List<ArchitectureCandidate> _architectureCandidates(
  List<ProviderGraphNode> providers,
  List<ProviderGraphEdge> providerEdges,
) {
  final byName = {for (final provider in providers) provider.name: provider};
  final uniquePairs = <String, ProviderGraphEdge>{};
  final outgoing = <String, Set<String>>{};
  for (final edge in providerEdges) {
    uniquePairs.putIfAbsent('${edge.source}\u0000${edge.target}', () => edge);
    outgoing.putIfAbsent(edge.source, () => <String>{}).add(edge.target);
  }
  final candidates = <ArchitectureCandidate>[];
  for (final entry in outgoing.entries.where(
    (entry) => entry.value.length >= 8,
  )) {
    candidates.add(
      ArchitectureCandidate(
        id: 'high-fan-out:${entry.key}',
        kind: 'high-fan-out',
        severity: entry.value.length >= 15 ? 'review' : 'watch',
        subject: entry.key,
        metric: entry.value.length,
        reason:
            'This provider coordinates ${entry.value.length} unique provider dependencies.',
        recommendation:
            'Confirm it is a cohesive route/read-model aggregate; otherwise split independent provider waves behind named seams.',
      ),
    );
  }
  for (final provider in providers.where(
    (provider) => provider.kind == 'manual' && provider.feature != 'core',
  )) {
    candidates.add(
      ArchitectureCandidate(
        id: 'manual-provider:${provider.name}',
        kind: 'manual-provider',
        severity: 'watch',
        subject: provider.name,
        reason:
            'A handwritten provider outside core bypasses Riverpod code generation and the uniform declaration contract.',
        recommendation:
            'Migrate when the owning feature is next edited, unless the manual family API has a documented compatibility reason.',
      ),
    );
  }
  for (final provider in providers.where(
    (provider) => provider.kind == 'alias',
  )) {
    candidates.add(
      ArchitectureCandidate(
        id: 'provider-alias:${provider.name}',
        kind: 'provider-alias',
        severity: 'review',
        subject: provider.name,
        reason:
            'A provider alias adds a second name to one state source and obscures the owning feature.',
        recommendation:
            'Remove the compatibility alias if callers can import the canonical provider directly.',
      ),
    );
  }
  for (final edge in uniquePairs.values) {
    final source = byName[edge.source];
    final target = byName[edge.target];
    if (source == null || target == null) continue;
    if (source.feature == 'core' &&
        target.feature != 'core' &&
        target.layer == 'data') {
      candidates.add(
        ArchitectureCandidate(
          id: 'core-to-feature-data:${edge.source}->${edge.target}',
          kind: 'core-to-feature-data',
          severity: 'action',
          subject: '${edge.source} -> ${edge.target}',
          source: edge.source,
          target: edge.target,
          reason:
              'A core-owned provider depends on feature data, reversing the intended ownership direction.',
          recommendation:
              'Move the orchestration provider to the owning feature or invert the dependency through a feature-neutral contract.',
        ),
      );
    }
    if (source.feature != target.feature &&
        source.layer == 'presentation' &&
        target.layer == 'presentation') {
      candidates.add(
        ArchitectureCandidate(
          id: 'cross-feature-presentation:${edge.source}->${edge.target}',
          kind: 'cross-feature-presentation',
          severity: 'review',
          subject: '${edge.source} -> ${edge.target}',
          source: edge.source,
          target: edge.target,
          reason:
              'A presentation provider reaches another feature presentation provider.',
          recommendation:
              'Keep only sanctioned public controller/read-model seams; otherwise move the contract below presentation.',
        ),
      );
    }
    if (source.feature == 'routing' && target.layer == 'presentation') {
      candidates.add(
        ArchitectureCandidate(
          id: 'routing-to-presentation:${edge.source}->${edge.target}',
          kind: 'routing-to-presentation',
          severity: 'review',
          subject: '${edge.source} -> ${edge.target}',
          source: edge.source,
          target: edge.target,
          reason:
              'The router observes presentation state and therefore participates in that feature lifecycle.',
          recommendation:
              'Keep only app-gate state at this integration root and document why redirect refresh needs it.',
        ),
      );
    }
  }
  candidates.sort((a, b) => a.id.compareTo(b.id));
  return candidates;
}

Map<String, Map<String, Object?>> _readReviewDecisions(File file) {
  if (!file.existsSync()) return {};
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  final decisions = decoded['decisions'] as List<Object?>? ?? const [];
  final result = <String, Map<String, Object?>>{};
  for (final item in decisions) {
    final decision = Map<String, Object?>.from(item! as Map);
    final id = decision['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException(
        'Every provider graph review decision needs a non-empty id.',
      );
    }
    if (result.containsKey(id)) {
      throw FormatException('Duplicate provider graph review id: $id');
    }
    const allowedStatuses = {
      'accepted',
      'accepted-exception',
      'watch',
      'planned',
    };
    final status = decision['status'];
    final rationale = decision['rationale'];
    if (!allowedStatuses.contains(status)) {
      throw FormatException(
        'Provider graph review $id has unsupported status: $status',
      );
    }
    if (rationale is! String || rationale.trim().isEmpty) {
      throw FormatException(
        'Provider graph review $id needs a non-empty rationale.',
      );
    }
    if (status == 'planned' &&
        (decision['debtId'] is! String ||
            (decision['debtId']! as String).trim().isEmpty)) {
      throw FormatException(
        'Planned provider graph review $id needs a stable debtId.',
      );
    }
    result[id] = decision;
  }
  return result;
}

Map<String, Object?> providerGraphSummaryPayload(ProviderGraph graph) => {
  'summary': graph.summary,
  'health': graph.health,
  'architectureCandidates': [
    for (final candidate in graph.candidates)
      candidate.toJson(graph.reviewDecisions[candidate.id]),
  ],
};

String renderProviderGraphJson(Object? payload) =>
    '${const JsonEncoder.withIndent('  ').convert(payload)}\n';

List<String> providerGraphCheckFailures(ProviderGraph graph) => [
  ...graph.duplicateProviderNames.map((name) => 'duplicate provider $name'),
  ...graph.danglingProviderTargets.map((name) => 'dangling target $name'),
  ...graph.unresolvedInsideProviders.map(
    (item) =>
        'unresolved provider ref ${item['source']} at '
        '${item['path']}:${item['line']} (${item['reference']})',
  ),
  ...graph.reactiveCycles.map(
    (cycle) => 'reactive cycle ${cycle.join(' -> ')}',
  ),
  ...graph.unreviewedCandidateIds.map(
    (id) => 'unreviewed architecture candidate $id',
  ),
  ...graph.staleReviewIds.map((id) => 'stale architecture review $id'),
];

const providerGraphUsage =
    'Usage: dart run tool/architecture/provider_graph.dart '
    '[--check] [--json|--summary] [--root PATH]';

final class ProviderGraphCliOptions {
  const ProviderGraphCliOptions({
    required this.root,
    required this.check,
    required this.json,
    required this.summary,
  });

  final Directory root;
  final bool check;
  final bool json;
  final bool summary;
}

ProviderGraphCliOptions parseProviderGraphCliOptions(
  List<String> args, {
  String? currentDirectory,
}) {
  var rootPath = currentDirectory ?? Directory.current.path;
  var rootSeen = false;
  var check = false;
  var json = false;
  var summary = false;

  for (var index = 0; index < args.length; index++) {
    switch (args[index]) {
      case '--check':
        check = true;
      case '--json':
        json = true;
      case '--summary':
        summary = true;
      case '--root':
        if (rootSeen) {
          throw const FormatException('--root may only be specified once.');
        }
        if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
          throw const FormatException('--root requires a value.');
        }
        rootPath = args[++index];
        rootSeen = true;
      default:
        throw FormatException('Unknown option: ${args[index]}');
    }
  }

  if (json && summary) {
    throw const FormatException('Choose either --json or --summary.');
  }
  if (!check && !json && !summary) {
    throw const FormatException(
      'Choose --check, --json, --summary, or a compatible combination.',
    );
  }

  return ProviderGraphCliOptions(
    root: Directory(rootPath),
    check: check,
    json: json,
    summary: summary,
  );
}

Future<void> main(List<String> args) async {
  late final ProviderGraphCliOptions options;
  try {
    options = parseProviderGraphCliOptions(args);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(providerGraphUsage);
    exitCode = 64;
    return;
  }

  final graph = await buildProviderGraph(options.root);
  if (options.json) {
    stdout.write(renderProviderGraphJson(graph.toJson()));
  } else if (options.summary) {
    stdout.write(renderProviderGraphJson(providerGraphSummaryPayload(graph)));
  }

  if (!options.check) return;

  final failures = providerGraphCheckFailures(graph);
  if (failures.isNotEmpty) {
    stderr.writeln('Provider graph check failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }

  if (!options.json && !options.summary) {
    stdout.writeln(
      'Provider graph is healthy '
      '(${graph.providers.length} providers, '
      '${graph.providerEdges.length} provider callsites, '
      'no reactive cycles).',
    );
  }
}

bool _hasRiverpodAnnotation(List<Annotation> metadata) => metadata.any(
  (annotation) =>
      annotation.name.name == 'riverpod' || annotation.name.name == 'Riverpod',
);

bool _isKeepAlive(List<Annotation> metadata) => metadata.any(
  (annotation) =>
      annotation.name.name == 'Riverpod' &&
      (annotation.arguments?.toSource().contains('keepAlive: true') ?? false),
);

String _featureFor(String relativePath) {
  final parts = relativePath.split('/');
  if (parts.length < 2) return 'root';
  final value = parts[1];
  return value.endsWith('.dart') ? 'app' : value;
}

String _layerFor(String relativePath) {
  final parts = relativePath.split('/');
  for (final candidate in const ['domain', 'data', 'presentation', 'shared']) {
    if (parts.contains(candidate)) return candidate;
  }
  return _featureFor(relativePath);
}

String _lowerCamelClassName(String value) {
  if (value.isEmpty) return value;
  var index = 0;
  while (index < value.length && value[index] == '_') {
    index++;
  }
  if (index == value.length) return value;
  return '${value.substring(0, index)}'
      '${value[index].toLowerCase()}'
      '${value.substring(index + 1)}';
}

String _relativePath(String rootPath, String path) {
  final normalizedRoot = rootPath.endsWith(Platform.pathSeparator)
      ? rootPath
      : '$rootPath${Platform.pathSeparator}';
  return path.startsWith(normalizedRoot)
      ? path.substring(normalizedRoot.length)
      : path;
}

void _increment(Map<String, int> counts, String value) {
  counts.update(value, (count) => count + 1, ifAbsent: () => 1);
}

Map<String, int> _countsBy(Iterable<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    _increment(counts, value);
  }
  return _sortedCounts(counts);
}

Map<String, int> _sortedCounts(Map<String, int> counts) => Map.fromEntries(
  counts.entries.toList()..sort(
    (a, b) => b.value != a.value
        ? b.value.compareTo(a.value)
        : a.key.compareTo(b.key),
  ),
);

List<Map<String, Object>> _topDegrees(
  Iterable<ProviderGraphEdge> edges, {
  required String field,
  required bool uniqueNeighbors,
}) {
  final counts = <String, int>{};
  if (uniqueNeighbors) {
    final neighbors = <String, Set<String>>{};
    for (final edge in edges) {
      final key = field == 'source' ? edge.source : edge.target;
      final neighbor = field == 'source' ? edge.target : edge.source;
      neighbors.putIfAbsent(key, () => <String>{}).add(neighbor);
    }
    for (final entry in neighbors.entries) {
      counts[entry.key] = entry.value.length;
    }
  } else {
    for (final edge in edges) {
      _increment(counts, field == 'source' ? edge.source : edge.target);
    }
  }
  final entries = counts.entries.toList()
    ..sort(
      (a, b) => b.value != a.value
          ? b.value.compareTo(a.value)
          : a.key.compareTo(b.key),
    );
  return entries
      .take(20)
      .map((entry) => {'name': entry.key, 'degree': entry.value})
      .toList();
}

List<List<String>> _stronglyConnectedComponents(
  Iterable<ProviderGraphEdge> edges,
) {
  final adjacency = <String, Set<String>>{};
  for (final edge in edges) {
    adjacency.putIfAbsent(edge.source, () => <String>{}).add(edge.target);
    adjacency.putIfAbsent(edge.target, () => <String>{});
  }
  var index = 0;
  final indices = <String, int>{};
  final lowLinks = <String, int>{};
  final stack = <String>[];
  final onStack = <String>{};
  final components = <List<String>>[];

  void connect(String node) {
    indices[node] = index;
    lowLinks[node] = index;
    index++;
    stack.add(node);
    onStack.add(node);
    for (final neighbor in adjacency[node] ?? const <String>{}) {
      if (!indices.containsKey(neighbor)) {
        connect(neighbor);
        lowLinks[node] = lowLinks[node]!.compareTo(lowLinks[neighbor]!) <= 0
            ? lowLinks[node]!
            : lowLinks[neighbor]!;
      } else if (onStack.contains(neighbor)) {
        lowLinks[node] = lowLinks[node]!.compareTo(indices[neighbor]!) <= 0
            ? lowLinks[node]!
            : indices[neighbor]!;
      }
    }
    if (lowLinks[node] != indices[node]) return;
    final component = <String>[];
    while (true) {
      final member = stack.removeLast();
      onStack.remove(member);
      component.add(member);
      if (member == node) break;
    }
    final selfLoop =
        component.length == 1 &&
        (adjacency[component.single]?.contains(component.single) ?? false);
    if (component.length > 1 || selfLoop) {
      component.sort();
      components.add(component);
    }
  }

  for (final node in adjacency.keys.toList()..sort()) {
    if (!indices.containsKey(node)) connect(node);
  }
  components.sort((a, b) => a.join().compareTo(b.join()));
  return components;
}

int _compareProviderNodes(ProviderGraphNode a, ProviderGraphNode b) {
  final name = a.name.compareTo(b.name);
  if (name != 0) return name;
  final path = a.path.compareTo(b.path);
  return path != 0 ? path : a.line.compareTo(b.line);
}

int _compareEdges(ProviderGraphEdge a, ProviderGraphEdge b) {
  for (final comparison in [
    a.source.compareTo(b.source),
    a.target.compareTo(b.target),
    a.operation.compareTo(b.operation),
    a.path.compareTo(b.path),
    a.line.compareTo(b.line),
  ]) {
    if (comparison != 0) return comparison;
  }
  return 0;
}
