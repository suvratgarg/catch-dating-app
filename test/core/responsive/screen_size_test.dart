import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatchWindowSize', () {
    test('fromWidth returns compact below 600', () {
      expect(CatchWindowSize.fromWidth(0), CatchWindowSize.compact);
      expect(CatchWindowSize.fromWidth(375), CatchWindowSize.compact);
      expect(CatchWindowSize.fromWidth(599), CatchWindowSize.compact);
    });

    test('fromWidth returns medium between 600 and 839', () {
      expect(CatchWindowSize.fromWidth(600), CatchWindowSize.medium);
      expect(CatchWindowSize.fromWidth(768), CatchWindowSize.medium);
      expect(CatchWindowSize.fromWidth(839), CatchWindowSize.medium);
    });

    test('fromWidth returns expanded at 840 and above', () {
      expect(CatchWindowSize.fromWidth(840), CatchWindowSize.expanded);
      expect(CatchWindowSize.fromWidth(1024), CatchWindowSize.expanded);
      expect(CatchWindowSize.fromWidth(1920), CatchWindowSize.expanded);
    });
  });

  group('responsiveGridCount', () {
    test('returns 2 for compact, 3 for medium, 4 for expanded', () {
      expect(responsiveGridCount(375), 2);
      expect(responsiveGridCount(768), 3);
      expect(responsiveGridCount(1024), 4);
    });
  });
}
