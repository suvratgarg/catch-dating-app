import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

import '../../tool/architecture/check_ui_composition_contracts.dart';

void main() {
  group('direct typed route-factory call-through', () {
    late Directory root;
    late AnalysisContextCollection collection;
    late ResolvedUnitResult resolved;

    setUpAll(() async {
      root = Directory.systemTemp.createTempSync('catch_route_factory_');
      void write(String path, String content) {
        final file = File('${root.path}/$path');
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(content);
      }

      write('packages/catch_ui/lib/src/patterns/catch_route_scaffold.dart', '''
class CatchRouteBody {
  const CatchRouteBody.standard({Object? child});
  const CatchRouteBody.standardViewport({Object? child});
  const CatchRouteBody.fullBleed({Object? child});
}
class CatchRouteScaffold {
  const CatchRouteScaffold({required CatchRouteBody body, Object? topBarBuilder});
}
''');
      write('lib/impostor.dart', '''
import '../packages/catch_ui/lib/src/patterns/catch_route_scaffold.dart' as canonical;
class CatchRouteBody extends canonical.CatchRouteBody {
  const CatchRouteBody() : super.standard();
}
canonical.CatchRouteScaffold route({required canonical.CatchRouteBody body}) =>
  canonical.CatchRouteScaffold(body: body);
canonical.CatchRouteScaffold _privateRoute({required canonical.CatchRouteBody body}) =>
  canonical.CatchRouteScaffold(body: body);
class CatchRouteScaffold {
  const CatchRouteScaffold({required canonical.CatchRouteBody body});
}
''');
      write('lib/fixture.dart', _directRouteFactoryFixture);
      collection = AnalysisContextCollection(
        includedPaths: [root.absolute.path],
        sdkPath: analysisDartSdkPath(),
      );
      final result = await collection
          .contextFor('${root.path}/lib/fixture.dart')
          .currentSession
          .getResolvedUnit('${root.path}/lib/fixture.dart');
      expect(result, isA<ResolvedUnitResult>());
      resolved = result as ResolvedUnitResult;
    });
    tearDownAll(() async {
      await collection.dispose();
      root.deleteSync(recursive: true);
    });

    List<String> check(String symbol) {
      final declaration = resolved.unit.declarations
          .whereType<ClassDeclaration>()
          .singleWhere((node) => node.namePart.typeName.lexeme == symbol);
      final source = expandDirectRouteFactoryCallsForOwner(
        root: root.absolute.path,
        result: resolved,
        declaration: declaration,
      );
      return evaluateLayoutOwnerContract(
        screenId: 'screen.factory.fixture',
        owner: <String, Object?>{
          'symbol': symbol,
          'family': 'pushed-route',
          'expression': 'CatchRouteScaffold',
          'bodyGeometry': 'standard',
          'topEdge': 'route-chrome',
        },
        declarationSource: source,
      );
    }

    for (final symbol in ['SameOwnerScreen', 'TopLevelScreen', 'AsyncScreen']) {
      test('proves direct caller bodies for $symbol', () {
        expect(check(symbol), isEmpty);
      });
    }
    for (final symbol in [
      'MixedCallsScreen',
      'ConditionalBodyScreen',
      'UnknownBodyScreen',
      'WrappedBodyScreen',
      'ForeignDescriptorScreen',
      'ForeignHelperScreen',
      'InaccessibleHelperScreen',
      'ForeignScaffoldScreen',
      'ShadowedHelperScreen',
      'InheritedHelperScreen',
      'ConditionalFactoryScreen',
      'IndirectFactoryScreen',
      'RecursiveFactoryScreen',
      'SubstitutedBodyScreen',
      'OptionalBodyScreen',
      'DeadHelperScreen',
      'BehaviorOnlyScreen',
      'NestedFactoryScreen',
    ]) {
      test('fails closed for $symbol', () {
        expect(check(symbol), isNotEmpty);
      });
    }
    for (final symbol in ['NestedPageBodyScreen', 'NestedInsetScreen']) {
      test('retains competing-geometry rejection for $symbol', () {
        expect(
          check(symbol),
          contains(contains('must not nest competing page geometry')),
        );
      });
    }
  });
}

const _directRouteFactoryFixture = r'''
import '../packages/catch_ui/lib/src/patterns/catch_route_scaffold.dart';
import 'impostor.dart' as impostor;

CatchRouteScaffold _sharedRoute({String? title, required CatchRouteBody body}) =>
  CatchRouteScaffold(body: body, topBarBuilder: () => title);
CatchRouteBody wrapBody(CatchRouteBody body) => body;
class CatchAsyncBoundary<T> {
  CatchAsyncBoundary({required Object Function() loadingBuilder,
    required Object Function() errorBuilder, required Object Function() builder});
}
class CatchPageBody { const CatchPageBody.screen({required Object child}); }
class CatchInsets { static const pageBody = Object(); }
class Padding { const Padding({required Object padding, required Object child}); }
class Button { const Button({required Object Function() onTap}); }

class SameOwnerScreen {
  Object build(bool loading) => loading
    ? _route(body: const CatchRouteBody.standardViewport())
    : _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class TopLevelScreen {
  Object build() => _sharedRoute(title: 'Title', body: const CatchRouteBody.standard());
}
class AsyncScreen {
  Object build() => CatchAsyncBoundary<Object>(
    loadingBuilder: () => _sharedRoute(body: const CatchRouteBody.standardViewport()),
    errorBuilder: () => _sharedRoute(body: const CatchRouteBody.standardViewport()),
    builder: () => _sharedRoute(body: const CatchRouteBody.standard()),
  );
}
class MixedCallsScreen {
  Object build(bool loading) => loading
    ? _route(body: const CatchRouteBody.standardViewport())
    : _route(body: const CatchRouteBody.fullBleed());
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class ConditionalBodyScreen {
  Object build(bool loading) => _sharedRoute(body: loading
    ? const CatchRouteBody.standard() : const CatchRouteBody.fullBleed());
}
class UnknownBodyScreen {
  Object build(CatchRouteBody body) => _sharedRoute(body: body);
}
class WrappedBodyScreen {
  Object build() => _sharedRoute(body: wrapBody(const CatchRouteBody.standard()));
}
class ForeignDescriptorScreen {
  Object build() => _sharedRoute(body: const impostor.CatchRouteBody());
}
class ForeignHelperScreen {
  Object build() => impostor.route(body: const CatchRouteBody.standard());
}
class InaccessibleHelperScreen {
  // Intentionally unresolved cross-library private target must fail closed.
  Object build() => impostor._privateRoute(body: const CatchRouteBody.standard());
}
class ForeignScaffoldScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  impostor.CatchRouteScaffold _route({required CatchRouteBody body}) =>
    impostor.CatchRouteScaffold(body: body);
}
class ShadowedHelperScreen {
  Object build() {
    CatchRouteScaffold _sharedRoute({required CatchRouteBody body}) =>
      CatchRouteScaffold(body: const CatchRouteBody.fullBleed());
    return _sharedRoute(body: const CatchRouteBody.standard());
  }
}
class ParentFactory {
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class InheritedHelperScreen extends ParentFactory {
  Object build() => _route(body: const CatchRouteBody.standard());
}
class ConditionalFactoryScreen {
  bool alternate = false;
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) => alternate
    ? CatchRouteScaffold(body: body) : CatchRouteScaffold(body: const CatchRouteBody.fullBleed());
}
class IndirectFactoryScreen {
  Object build() => _indirect(body: const CatchRouteBody.standard());
  CatchRouteScaffold _indirect({required CatchRouteBody body}) => _route(body: body);
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class RecursiveFactoryScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) => _route(body: body);
}
class SubstitutedBodyScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({required CatchRouteBody body}) =>
    CatchRouteScaffold(body: const CatchRouteBody.fullBleed());
}
class OptionalBodyScreen {
  Object build() => _route(body: const CatchRouteBody.standard());
  CatchRouteScaffold _route({CatchRouteBody? body}) =>
    CatchRouteScaffold(body: body ?? const CatchRouteBody.fullBleed());
}
class DeadHelperScreen {
  Object build() => Object();
  CatchRouteScaffold _route({required CatchRouteBody body}) => CatchRouteScaffold(body: body);
}
class BehaviorOnlyScreen {
  Object build() => Button(onTap: () => _sharedRoute(body: const CatchRouteBody.standard()));
}
class NestedFactoryScreen {
  Object build() => _sharedRoute(body: CatchRouteBody.standard(
    child: _sharedRoute(body: const CatchRouteBody.standard())));
}
class NestedPageBodyScreen {
  Object build() => _sharedRoute(body: const CatchRouteBody.standard(
    child: CatchPageBody.screen(child: Object())));
}
class NestedInsetScreen {
  Object build() => _sharedRoute(body: const CatchRouteBody.standard(
    child: Padding(padding: CatchInsets.pageBody, child: Object())));
}
''';
