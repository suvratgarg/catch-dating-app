// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/provider_graph.dart';

void main() {
  test(
    'provider graph resolves providers, consumers, aliases, and mutations',
    () async {
      final root = await _fixtureRoot('''
import 'package:flutter_riverpod/experimental/mutation.dart';

@riverpod
int alpha(Ref ref) => 1;

@riverpod
int beta(Ref ref) => ref.watch(alphaProvider);

final manualProvider =
    FutureProvider.autoDispose.family<int, int>((ref, id) async => id);
final legacyProvider = manualProvider;

class Controller {
  static final saveMutation = Mutation<void>();
}

class Screen {
  void build(WidgetRef ref) {
    ref.watch(betaProvider);
    ref.watch(Controller.saveMutation);
  }
}
''');
      addTearDown(() => root.delete(recursive: true));

      final graph = await buildProviderGraph(root);

      expect(
        graph.providers.map((provider) => provider.name),
        containsAll([
          'alphaProvider',
          'betaProvider',
          'manualProvider',
          'legacyProvider',
        ]),
      );
      expect(graph.mutations.single.name, 'Controller.saveMutation');
      expect(
        graph.providerEdges,
        contains(
          isA<ProviderGraphEdge>()
              .having((edge) => edge.source, 'source', 'betaProvider')
              .having((edge) => edge.target, 'target', 'alphaProvider'),
        ),
      );
      expect(
        graph.consumerEdges,
        contains(
          isA<ProviderGraphEdge>()
              .having((edge) => edge.source, 'source', contains('Screen.build'))
              .having((edge) => edge.target, 'target', 'betaProvider'),
        ),
      );
      expect(graph.mutationEdges.single.target, 'Controller.saveMutation');
      expect(graph.unresolvedInsideProviders, isEmpty);
    },
  );

  test('provider graph detects cycles and unresolved provider refs', () async {
    final root = await _fixtureRoot('''
@riverpod
int first(Ref ref) => ref.watch(secondProvider);

@riverpod
int second(Ref ref) {
  ref.watch(firstProvider);
  ref.watch(dynamicDependency);
  return 2;
}
''');
    addTearDown(() => root.delete(recursive: true));

    final graph = await buildProviderGraph(root);

    expect(graph.reactiveCycles, [
      ['firstProvider', 'secondProvider'],
    ]);
    expect(graph.unresolvedInsideProviders, hasLength(1));
    expect(
      graph.unresolvedInsideProviders.single['reference'],
      'dynamicDependency',
    );
    expect(graph.isHealthy, isFalse);
  });

  test(
    'provider graph artifacts are deterministic and drift checked',
    () async {
      final root = await _fixtureRoot('''
@riverpod
int sample(Ref ref) => 1;
''');
      addTearDown(() => root.delete(recursive: true));

      final graph = await buildProviderGraph(root);
      final first = renderProviderGraphArtifacts(graph);
      final second = renderProviderGraphArtifacts(
        await buildProviderGraph(root),
      );
      expect(second, first);

      await writeProviderGraphArtifacts(root, graph);
      expect(await checkProviderGraphArtifacts(root, graph), isEmpty);

      final jsonFile = File(
        '${root.path}/$providerGraphOutputDirectory/provider_graph.json',
      );
      await jsonFile.writeAsString('{}\n');
      expect(
        await checkProviderGraphArtifacts(root, graph),
        contains('stale docs/generated/provider_graph/provider_graph.json'),
      );
    },
  );

  test(
    'provider graph requires current architecture review decisions',
    () async {
      final root = await _fixtureRoot('''
final lookupProvider =
    FutureProvider.autoDispose.family<int, int>((ref, id) async => id);
''');
      addTearDown(() => root.delete(recursive: true));

      final unreviewed = await buildProviderGraph(root);
      expect(unreviewed.unreviewedCandidateIds, [
        'manual-provider:lookupProvider',
      ]);

      final reviewFile = File('${root.path}/$providerGraphReviewPath');
      await reviewFile.parent.create(recursive: true);
      await reviewFile.writeAsString('''
{
  "decisions": [
    {
      "id": "manual-provider:lookupProvider",
      "status": "planned",
      "debtId": "TEST-DEBT-001",
      "rationale": "Known fixture debt."
    }
  ]
}
''');
      final reviewed = await buildProviderGraph(root);
      expect(reviewed.unreviewedCandidateIds, isEmpty);
      expect(reviewed.staleReviewIds, isEmpty);

      await reviewFile.writeAsString('''
{
  "decisions": [
    {
      "id": "stale:decision",
      "status": "accepted",
      "rationale": "No matching candidate."
    }
  ]
}
''');
      final stale = await buildProviderGraph(root);
      expect(stale.staleReviewIds, ['stale:decision']);
    },
  );
}

Future<Directory> _fixtureRoot(String source) async {
  final root = await Directory.systemTemp.createTemp('provider_graph_test_');
  final lib = Directory('${root.path}/lib/sample/data');
  await lib.create(recursive: true);
  await File('${lib.path}/fixture.dart').writeAsString(source);
  return root;
}
