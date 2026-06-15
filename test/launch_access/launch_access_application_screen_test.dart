import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/launch_access/data/launch_access_config_provider.dart';
import 'package:catch_dating_app/launch_access/data/launch_access_repository.dart';
import 'package:catch_dating_app/launch_access/domain/launch_access_config.dart';
import 'package:catch_dating_app/launch_access/presentation/launch_access_application_screen.dart';
import 'package:catch_dating_app/launch_access/presentation/launch_access_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launch access form uses CatchToggle for host interest', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        launchAccessConfigProvider.overrideWith(
          (ref) => const LaunchAccessConfig(gateEnabled: true),
        ),
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        watchLaunchAccessApplicationProvider(
          'runner-1',
        ).overrideWith((ref) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const LaunchAccessApplicationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Join the next city drop'), findsOneWidget);
    expect(_toggle('I might host'), findsOneWidget);
    expect(container.read(launchAccessControllerProvider).wantsToHost, isFalse);

    await tester.ensureVisible(_toggle('I might host'));
    await tester.pump();
    await tester.tap(_toggle('I might host'));
    await tester.pump();

    expect(container.read(launchAccessControllerProvider).wantsToHost, isTrue);
  });
}

Finder _toggle(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchToggle && widget.semanticLabel == label,
  );
}
