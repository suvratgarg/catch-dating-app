import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('connectivityResultsAreOffline', () {
    test('treats empty and none-only results as offline', () {
      expect(connectivityResultsAreOffline(const []), isTrue);
      expect(
        connectivityResultsAreOffline(const [ConnectivityResult.none]),
        isTrue,
      );
    });

    test('treats any real transport as online', () {
      expect(
        connectivityResultsAreOffline(const [
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ]),
        isFalse,
      );
    });
  });

  testWidgets('chat navigation badge stays inside its icon box', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Center(
          child: AppShellNavigationBadge(
            count: 3,
            child: Icon(Icons.chat_bubble_outline_rounded),
          ),
        ),
      ),
    );

    final badgeBox = find.byWidgetPredicate(
      (widget) =>
          widget is SizedBox && widget.width == 38 && widget.height == 30,
    );
    final boxRect = tester.getRect(badgeBox);
    final labelRect = tester.getRect(find.text('3'));

    expect(labelRect.top, greaterThanOrEqualTo(boxRect.top));
    expect(labelRect.right, lessThanOrEqualTo(boxRect.right));
  });
}
