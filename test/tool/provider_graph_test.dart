// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
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

  test(
    'provider graph check failures match cycles and unresolved provider refs',
    () async {
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
      final failures = providerGraphCheckFailures(graph);

      expect(graph.reactiveCycles, [
        ['firstProvider', 'secondProvider'],
      ]);
      expect(graph.unresolvedInsideProviders, hasLength(1));
      expect(
        graph.unresolvedInsideProviders.single['reference'],
        'dynamicDependency',
      );
      expect(
        failures,
        contains('reactive cycle firstProvider -> secondProvider'),
      );
      expect(
        failures,
        contains(contains('unresolved provider ref secondProvider')),
      );
      expect(graph.isHealthy, isFalse);
      expect(failures, isNotEmpty);
    },
  );

  test('provider graph JSON and summary are deterministic', () async {
    final root = await _fixtureRoot('''
@riverpod
int sample(Ref ref) => 1;
''');
    addTearDown(() => root.delete(recursive: true));

    final graph = await buildProviderGraph(root);
    final first = renderProviderGraphJson(graph.toJson());
    final second = renderProviderGraphJson(
      (await buildProviderGraph(root)).toJson(),
    );
    final summary = renderProviderGraphJson(providerGraphSummaryPayload(graph));

    expect(second, first);
    expect(first.endsWith('\n'), isTrue);
    expect(summary.endsWith('\n'), isTrue);
    expect(jsonDecode(first), isA<Map<String, Object?>>());
    expect(
      (jsonDecode(first) as Map<String, Object?>)['schemaVersion'],
      providerGraphSchemaVersion,
    );
    expect(
      (jsonDecode(summary) as Map<String, Object?>)['health'],
      graph.health,
    );
  });

  test('provider graph CLI rejects retired and conflicting output flags', () {
    expect(
      () => parseProviderGraphCliOptions(['--write']),
      throwsFormatException,
    );
    expect(
      () => parseProviderGraphCliOptions(['--json', '--summary']),
      throwsFormatException,
    );
    expect(() => parseProviderGraphCliOptions([]), throwsFormatException);
    expect(
      () => parseProviderGraphCliOptions(['--root']),
      throwsFormatException,
    );

    final options = parseProviderGraphCliOptions([
      '--check',
      '--summary',
      '--root',
      '/tmp/provider-root',
    ]);
    expect(options.check, isTrue);
    expect(options.summary, isTrue);
    expect(options.json, isFalse);
    expect(options.root.path, '/tmp/provider-root');
  });

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
      expect(
        providerGraphCheckFailures(unreviewed),
        contains(
          'unreviewed architecture candidate manual-provider:lookupProvider',
        ),
      );

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
      expect(providerGraphCheckFailures(reviewed), isEmpty);

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
      expect(
        providerGraphCheckFailures(stale),
        contains('stale architecture review stale:decision'),
      );
    },
  );

  test(
    'provider graph rejects planned reviews without stable debt ids',
    () async {
      final root = await _fixtureRoot('''
final lookupProvider =
    FutureProvider.autoDispose.family<int, int>((ref, id) async => id);
''');
      addTearDown(() => root.delete(recursive: true));

      final reviewFile = File('${root.path}/$providerGraphReviewPath');
      await reviewFile.parent.create(recursive: true);
      await reviewFile.writeAsString('''
{
  "decisions": [
    {
      "id": "manual-provider:lookupProvider",
      "status": "planned",
      "rationale": "Missing debt id."
    }
  ]
}
''');

      await expectLater(
        buildProviderGraph(root),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('needs a stable debtId'),
          ),
        ),
      );
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
