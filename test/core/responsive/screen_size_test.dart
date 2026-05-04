import 'package:catch_dating_app/core/responsive/breakpoints.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScreenSize', () {
    test('fromWidth returns compact below 600', () {
      expect(ScreenSize.fromWidth(0), ScreenSize.compact);
      expect(ScreenSize.fromWidth(375), ScreenSize.compact);
      expect(ScreenSize.fromWidth(599), ScreenSize.compact);
    });

    test('fromWidth returns medium between 600 and 839', () {
      expect(ScreenSize.fromWidth(600), ScreenSize.medium);
      expect(ScreenSize.fromWidth(768), ScreenSize.medium);
      expect(ScreenSize.fromWidth(839), ScreenSize.medium);
    });

    test('fromWidth returns expanded at 840 and above', () {
      expect(ScreenSize.fromWidth(840), ScreenSize.expanded);
      expect(ScreenSize.fromWidth(1024), ScreenSize.expanded);
      expect(ScreenSize.fromWidth(1920), ScreenSize.expanded);
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
