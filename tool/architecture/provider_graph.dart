import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

const providerGraphSchemaVersion = 1;
const providerGraphOutputDirectory = 'docs/generated/provider_graph';
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
      'health': {
        'healthy': isHealthy,
        'duplicateProviderNames': duplicateProviderNames,
        'danglingProviderTargets': danglingProviderTargets,
        'unresolvedInsideProviders': unresolvedInsideProviders,
        'reactiveCycles': reactiveCycles,
        'allOperationCycles': allOperationCycles,
        'unreviewedArchitectureCandidateIds': unreviewedCandidateIds,
        'staleArchitectureReviewIds': staleReviewIds,
      },
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

Map<String, String> renderProviderGraphArtifacts(ProviderGraph graph) {
  final jsonText = const JsonEncoder.withIndent('  ').convert(graph.toJson());
  return {
    'provider_graph.json': '$jsonText\n',
    'provider_graph.mmd': _renderMermaid(graph),
    'README.md': _renderReadme(graph),
    'provider_graph.html': _renderHtml(jsonText),
  };
}

String _renderMermaid(ProviderGraph graph) {
  final featureGraph = graph.toJson()['features']! as Map<String, Object?>;
  final nodes = featureGraph['nodes']! as List<Object?>;
  final edges = featureGraph['edges']! as List<Object?>;
  final ids = <String, String>{};
  final buffer = StringBuffer()
    ..writeln('%% Generated by tool/architecture/provider_graph.dart')
    ..writeln('flowchart LR');
  for (var index = 0; index < nodes.length; index++) {
    final node = nodes[index]! as Map<String, Object?>;
    final feature = node['id']! as String;
    final id = 'f$index';
    ids[feature] = id;
    buffer.writeln('  $id["$feature<br/>${node['providers']} providers"]');
  }
  for (final rawEdge in edges) {
    final edge = rawEdge! as Map<String, Object?>;
    if (edge['source'] == edge['target']) continue;
    buffer.writeln(
      '  ${ids[edge['source']]} -->|"${edge['uniqueProviderPairs']}"| '
      '${ids[edge['target']]}',
    );
  }
  return '$buffer';
}

String _renderReadme(ProviderGraph graph) {
  final summary = graph.summary;
  final buffer = StringBuffer()
    ..writeln('# Riverpod provider graph')
    ..writeln()
    ..writeln(
      'Generated from handwritten Dart ASTs under lib/ by '
      'dart run tool/architecture/provider_graph.dart --write.',
    )
    ..writeln()
    ..writeln(
      'Open [provider_graph.html](provider_graph.html) for the interactive '
      'feature/provider view. [provider_graph.json](provider_graph.json) is '
      'the complete machine-readable graph; '
      '[provider_graph.mmd](provider_graph.mmd) is the aggregated feature map.',
    )
    ..writeln()
    ..writeln('## Current inventory')
    ..writeln()
    ..writeln('| Measure | Count |')
    ..writeln('|---|---:|')
    ..writeln('| Handwritten Dart files | ${summary['dartSourceFiles']} |')
    ..writeln('| Providers | ${summary['providerNodes']} |')
    ..writeln('| Mutations | ${summary['mutationNodes']} |')
    ..writeln(
      '| Unique provider relationships | '
      '${summary['uniqueProviderToProviderPairs']} |',
    )
    ..writeln(
      '| Cross-feature relationships | '
      '${summary['uniqueCrossFeatureProviderPairs']} |',
    )
    ..writeln('| Consumer callsites | ${summary['consumerToStateCallsites']} |')
    ..writeln('| Reactive cycles | ${summary['reactiveCycles']} |')
    ..writeln()
    ..writeln('## Architecture review')
    ..writeln()
    ..writeln('| Candidate | Decision | Rationale |')
    ..writeln('|---|---|---|');
  for (final candidate in graph.candidates) {
    final review = graph.reviewDecisions[candidate.id];
    buffer.writeln(
      '| ${_escapeMarkdown(candidate.id)} | '
      '${_escapeMarkdown(review?['status']?.toString() ?? 'unreviewed')} | '
      '${_escapeMarkdown(review?['rationale']?.toString() ?? candidate.reason)} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('## Refresh and check')
    ..writeln()
    ..writeln('    dart run tool/architecture/provider_graph.dart --write')
    ..writeln('    dart run tool/architecture/provider_graph.dart --check')
    ..writeln()
    ..writeln(
      'The check fails on stale artifacts, duplicate or dangling provider '
      'nodes, unresolved provider-internal refs, reactive cycles, unreviewed '
      'architecture candidates, or stale review decisions.',
    );
  return '$buffer';
}

String _renderHtml(String jsonText) {
  final escapedJson = jsonText.replaceAll('</script>', r'<\/script>');
  return '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Catch Riverpod provider graph</title>
<style>
:root { color-scheme: light dark; --bg: #f5f7fb; --fg: #172033; --muted: #60708b; --panel: #fff; --border: #d9e0eb; --accent: #3157d5; --edge: #93a1b8; --action: #b8472d; }
@media (prefers-color-scheme: dark) { :root { --bg: #10141d; --fg: #eef2fb; --muted: #a8b4c8; --panel: #181e2a; --border: #303a4c; --accent: #8ca7ff; --edge: #66748b; --action: #ff9c86; } }
* { box-sizing: border-box; }
body { margin: 0; padding: 24px; background: var(--bg); color: var(--fg); font: 15px/1.45 system-ui, sans-serif; }
main { max-width: 1480px; margin: 0 auto; }
h1 { margin: 0 0 6px; font-size: clamp(24px, 4vw, 38px); }
p { color: var(--muted); }
.summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(145px, 1fr)); gap: 10px; margin: 18px 0; }
.stat { padding: 14px; border: 1px solid var(--border); border-radius: 12px; background: var(--panel); }
.stat strong { display: block; font-size: 24px; }
.stat span { color: var(--muted); }
.controls { display: flex; flex-wrap: wrap; gap: 12px; align-items: end; margin: 18px 0; }
label { display: grid; gap: 5px; color: var(--muted); }
select, input, button { min-height: 40px; border: 1px solid var(--border); border-radius: 8px; background: var(--panel); color: var(--fg); padding: 8px 10px; font: inherit; }
input { min-width: min(320px, 80vw); }
button { cursor: pointer; color: var(--accent); }
.canvas { width: 100%; overflow: auto; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); }
svg { display: block; min-width: 760px; width: 100%; color: var(--fg); }
.edge { stroke: var(--edge); stroke-width: 1.2; fill: none; opacity: .66; }
.edge.cross { stroke: var(--accent); opacity: .52; }
.node rect { fill: var(--panel); stroke: var(--border); stroke-width: 1; rx: 9; }
.node:hover rect, .node:focus rect { stroke: var(--accent); stroke-width: 2; }
.node text { fill: var(--fg); pointer-events: none; }
.node .sub { fill: var(--muted); font-size: 11px; }
.node.action rect { stroke: var(--action); }
.detail { min-height: 42px; padding: 12px 0; color: var(--muted); }
.review { width: 100%; border-collapse: collapse; margin-top: 22px; }
.review th, .review td { padding: 9px; border-bottom: 1px solid var(--border); text-align: left; vertical-align: top; }
.review th { color: var(--muted); font-weight: 600; }
code { color: var(--fg); }
@media (max-width: 620px) { body { padding: 14px; } .review th:nth-child(2), .review td:nth-child(2) { display: none; } }
</style>
</head>
<body>
<main>
<h1>Catch Riverpod provider graph</h1>
<p>Static source topology with Riverpod Mutations modeled separately. Select a feature or search a provider to inspect its immediate relationships.</p>
<section class="summary" id="summary" aria-label="Provider graph summary"></section>
<section class="controls" aria-label="Graph controls">
  <label>View
    <select id="view"><option value="features">Feature topology</option><option value="providers">Provider topology</option></select>
  </label>
  <label>Feature
    <select id="feature"></select>
  </label>
  <label>Provider search
    <input id="search" type="search" list="provider-names" placeholder="e.g. exploreFeedViewModelProvider">
    <datalist id="provider-names"></datalist>
  </label>
  <button id="reset" type="button">Reset</button>
</section>
<div class="canvas"><svg id="graph" role="img" aria-label="Riverpod dependency graph"></svg></div>
<output class="detail" id="detail" aria-live="polite">Select a node for source and relationship details.</output>
<table class="review">
<thead><tr><th>Architecture candidate</th><th>Status</th><th>Review</th></tr></thead>
<tbody id="reviews"></tbody>
</table>
</main>
<script id="provider-graph-data" type="application/json">$escapedJson</script>
<script>
const data = JSON.parse(document.getElementById('provider-graph-data').textContent);
const svg = document.getElementById('graph');
const view = document.getElementById('view');
const feature = document.getElementById('feature');
const search = document.getElementById('search');
const detail = document.getElementById('detail');
const ns = 'http://www.w3.org/2000/svg';
const providerByName = new Map(data.providers.map(item => [item.name, item]));
const providerEdges = data.providerEdges;
const featureGraph = data.features;
const featureCounts = [...featureGraph.nodes].sort((a, b) => b.providers - a.providers || a.id.localeCompare(b.id));

function element(name, attributes = {}) {
  const node = document.createElementNS(ns, name);
  Object.entries(attributes).forEach(([key, value]) => node.setAttribute(key, String(value)));
  return node;
}

function clearGraph(height) {
  svg.replaceChildren();
  svg.setAttribute('viewBox', '0 0 1200 ' + height);
  svg.setAttribute('height', String(height));
  const defs = element('defs');
  const marker = element('marker', { id: 'arrow', viewBox: '0 0 10 10', refX: 8, refY: 5, markerWidth: 5, markerHeight: 5, orient: 'auto-start-reverse' });
  marker.append(element('path', { d: 'M 0 0 L 10 5 L 0 10 z', fill: 'var(--edge)' }));
  defs.append(marker);
  svg.append(defs);
}

function nodeGroup(x, y, width, height, title, subtitle, onSelect, action = false) {
  const group = element('g', { class: 'node' + (action ? ' action' : ''), role: 'button', 'aria-label': title + ', ' + subtitle });
  group.append(element('rect', { x, y, width, height }));
  const primary = element('text', { x: x + 10, y: y + 23 });
  primary.textContent = title.length > 30 ? title.slice(0, 29) + '…' : title;
  const secondary = element('text', { x: x + 10, y: y + 42, class: 'sub' });
  secondary.textContent = subtitle;
  group.append(primary, secondary);
  group.addEventListener('click', onSelect);
  svg.append(group);
}

function edgePath(x1, y1, x2, y2, cross) {
  const curve = Math.max(30, Math.abs(x2 - x1) * .36);
  const path = element('path', {
    d: 'M ' + x1 + ' ' + y1 + ' C ' + (x1 + curve) + ' ' + y1 + ', ' + (x2 - curve) + ' ' + y2 + ', ' + x2 + ' ' + y2,
    class: 'edge' + (cross ? ' cross' : ''),
    'marker-end': 'url(#arrow)'
  });
  svg.insertBefore(path, svg.children[1] || null);
}

function drawFeatures() {
  const nodes = featureGraph.nodes;
  const rows = Math.ceil(nodes.length / 5);
  clearGraph(Math.max(420, rows * 116 + 80));
  const positions = new Map();
  nodes.forEach((item, index) => {
    const position = { x: 28 + (index % 5) * 232, y: 38 + Math.floor(index / 5) * 116, width: 194, height: 58 };
    positions.set(item.id, position);
  });
  featureGraph.edges.filter(item => item.source !== item.target).forEach(item => {
    const source = positions.get(item.source);
    const target = positions.get(item.target);
    if (source && target) edgePath(source.x + source.width, source.y + 29, target.x, target.y + 29, true);
  });
  nodes.forEach(item => {
    const position = positions.get(item.id);
    nodeGroup(position.x, position.y, position.width, position.height, item.id, item.providers + ' providers · ' + item.mutations + ' mutations', () => {
      view.value = 'providers';
      feature.value = item.id;
      search.value = '';
      draw();
    });
  });
  detail.textContent = nodes.length + ' features; arrows aggregate unique provider relationships.';
}

function drawProviders() {
  const query = search.value.trim().toLowerCase();
  const exact = data.providers.find(item => item.name.toLowerCase() === query);
  let nodes;
  if (exact) {
    const names = new Set([exact.name]);
    providerEdges.forEach(edge => {
      if (edge.source === exact.name) names.add(edge.target);
      if (edge.target === exact.name) names.add(edge.source);
    });
    nodes = data.providers.filter(item => names.has(item.name));
  } else {
    nodes = data.providers.filter(item => item.feature === feature.value && (!query || item.name.toLowerCase().includes(query)));
  }
  nodes.sort((a, b) => a.layer.localeCompare(b.layer) || a.name.localeCompare(b.name));
  const names = new Set(nodes.map(item => item.name));
  const visibleEdges = providerEdges.filter(edge => names.has(edge.source) && names.has(edge.target));
  const columns = 4;
  const rows = Math.ceil(Math.max(nodes.length, 1) / columns);
  clearGraph(Math.max(360, rows * 82 + 80));
  const positions = new Map();
  nodes.forEach((item, index) => {
    positions.set(item.name, { x: 24 + (index % columns) * 294, y: 34 + Math.floor(index / columns) * 82, width: 252, height: 58 });
  });
  visibleEdges.forEach(edge => {
    const source = positions.get(edge.source);
    const target = positions.get(edge.target);
    edgePath(source.x + source.width, source.y + 29, target.x, target.y + 29, providerByName.get(edge.source).feature !== providerByName.get(edge.target).feature);
  });
  nodes.forEach(item => {
    const position = positions.get(item.name);
    const candidate = data.architectureReview.candidates.find(candidate => candidate.subject === item.name || candidate.source === item.name);
    nodeGroup(position.x, position.y, position.width, position.height, item.name, item.feature + ' · ' + item.layer + ' · ' + item.kind, () => {
      const outgoing = providerEdges.filter(edge => edge.source === item.name).length;
      const incoming = providerEdges.filter(edge => edge.target === item.name).length;
      detail.textContent = item.path + ':' + item.line + ' · ' + outgoing + ' outgoing callsites · ' + incoming + ' incoming callsites' + (item.keepAlive ? ' · keepAlive' : '');
    }, candidate && candidate.severity === 'action');
  });
  detail.textContent = nodes.length === 0
    ? 'No providers match the current feature and search.'
    : nodes.length + ' providers and ' + visibleEdges.length + ' visible dependency callsites.';
}

function draw() {
  if (view.value === 'features') drawFeatures();
  else drawProviders();
}

const summaryItems = [
  ['Providers', data.summary.providerNodes],
  ['Mutations', data.summary.mutationNodes],
  ['Unique relationships', data.summary.uniqueProviderToProviderPairs],
  ['Cross-feature', data.summary.uniqueCrossFeatureProviderPairs],
  ['Reactive cycles', data.summary.reactiveCycles],
  ['Review candidates', data.summary.architectureCandidates]
];
document.getElementById('summary').replaceChildren(...summaryItems.map(([label, value]) => {
  const item = document.createElement('div');
  item.className = 'stat';
  const strong = document.createElement('strong');
  strong.textContent = value;
  const span = document.createElement('span');
  span.textContent = label;
  item.append(strong, span);
  return item;
}));
feature.replaceChildren(...featureCounts.map(item => {
  const option = document.createElement('option');
  option.value = item.id;
  option.textContent = item.id + ' (' + item.providers + ')';
  return option;
}));
document.getElementById('provider-names').replaceChildren(...data.providers.map(item => {
  const option = document.createElement('option');
  option.value = item.name;
  return option;
}));
document.getElementById('reviews').replaceChildren(...data.architectureReview.candidates.map(candidate => {
  const row = document.createElement('tr');
  const name = document.createElement('td');
  const code = document.createElement('code');
  code.textContent = candidate.id;
  name.append(code);
  const status = document.createElement('td');
  status.textContent = candidate.review ? candidate.review.status : 'unreviewed';
  const rationale = document.createElement('td');
  rationale.textContent = candidate.review ? candidate.review.rationale : candidate.reason;
  row.append(name, status, rationale);
  return row;
}));
view.addEventListener('change', draw);
feature.addEventListener('change', () => { view.value = 'providers'; search.value = ''; draw(); });
search.addEventListener('input', () => { view.value = 'providers'; draw(); });
document.getElementById('reset').addEventListener('click', () => { view.value = 'features'; search.value = ''; draw(); });
draw();
</script>
</body>
</html>
''';
}

Future<List<String>> checkProviderGraphArtifacts(
  Directory root,
  ProviderGraph graph,
) async {
  final expected = renderProviderGraphArtifacts(graph);
  final drift = <String>[];
  for (final entry in expected.entries) {
    final file = File(
      '${root.absolute.path}/$providerGraphOutputDirectory/${entry.key}',
    );
    if (!file.existsSync()) {
      drift.add('missing ${_relativePath(root.absolute.path, file.path)}');
      continue;
    }
    if (await file.readAsString() != entry.value) {
      drift.add('stale ${_relativePath(root.absolute.path, file.path)}');
    }
  }
  return drift;
}

Future<void> writeProviderGraphArtifacts(
  Directory root,
  ProviderGraph graph,
) async {
  final output = Directory(
    '${root.absolute.path}/$providerGraphOutputDirectory',
  );
  await output.create(recursive: true);
  for (final entry in renderProviderGraphArtifacts(graph).entries) {
    await File('${output.path}/${entry.key}').writeAsString(entry.value);
  }
}

Future<void> main(List<String> args) async {
  final root = Directory(_option(args, '--root') ?? Directory.current.path);
  final write = args.contains('--write');
  final check = args.contains('--check');
  final summaryOnly = args.contains('--summary');
  if (write && check) {
    stderr.writeln('Choose either --write or --check.');
    exitCode = 64;
    return;
  }
  final graph = await buildProviderGraph(root);
  if (summaryOnly) {
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'summary': graph.summary,
        'health': graph.toJson()['health'],
        'architectureCandidates': [
          for (final candidate in graph.candidates)
            candidate.toJson(graph.reviewDecisions[candidate.id]),
        ],
      }),
    );
    return;
  }
  if (write) {
    await writeProviderGraphArtifacts(root, graph);
    stdout.writeln(
      'Wrote $providerGraphOutputDirectory '
      '(${graph.providers.length} providers, '
      '${graph.mutations.length} mutations).',
    );
    if (graph.unreviewedCandidateIds.isNotEmpty) {
      stdout.writeln(
        'Unreviewed candidates: ${graph.unreviewedCandidateIds.join(', ')}',
      );
    }
    return;
  }
  if (check) {
    final drift = await checkProviderGraphArtifacts(root, graph);
    final failures = <String>[
      ...drift,
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
    if (failures.isNotEmpty) {
      stderr.writeln('Provider graph check failed:');
      for (final failure in failures) {
        stderr.writeln('- $failure');
      }
      exitCode = 1;
      return;
    }
    stdout.writeln(
      'Provider graph is current and healthy '
      '(${graph.providers.length} providers, '
      '${graph.providerEdges.length} provider callsites, no reactive cycles).',
    );
    return;
  }
  stdout.writeln(
    'Usage: dart run tool/architecture/provider_graph.dart '
    '[--write|--check|--summary] [--root PATH]',
  );
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

String? _option(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1) return null;
  if (index + 1 >= args.length) {
    throw FormatException('$name requires a value.');
  }
  return args[index + 1];
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

String _escapeMarkdown(String value) => value.replaceAll('|', r'\|');
