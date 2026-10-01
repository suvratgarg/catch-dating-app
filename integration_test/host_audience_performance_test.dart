import 'dart:async';
import 'dart:developer' as developer;

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/crm/host_saved_audience_repository.dart';
import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_definition.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/clubs/clubs_test_helpers.dart';

/// Runs exclusively against local synthetic repository overrides. No Firebase
/// app, production writes, network load, tokens, or persistent cache is used.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Audience profile: cold, warm, switch, revisit and cancellation',
    (tester) async {
      AppConfig.configureEntrypointRole(AppRole.host);
      addTearDown(AppConfig.resetEntrypointRoleOverrideForTesting);
      final meter = _Meter();
      final forms = _Forms(meter);
      final groups = _Groups(meter);
      final club = buildClub(id: 'perf-organizer', ownerUserId: 'perf-host');
      final overrides = [
        firebaseAuthProvider.overrideWithValue(_Auth()),
        uidProvider.overrideWithValue(const AsyncData<String?>('perf-host')),
        hostOperableClubsProvider(
          'perf-host',
        ).overrideWithValue(AsyncData([club])),
        hostFormsRepositoryProvider.overrideWithValue(forms),
        hostSavedAudienceRepositoryProvider.overrideWithValue(groups),
      ];
      final root = GlobalKey<_FixtureState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: AppTheme.light,
            home: _Fixture(key: root),
          ),
        ),
      );
      await tester.pump();

      Future<void> trace(String name, Future<void> Function() action) async {
        debugPrint('PROFILE_PHASE $name starting');
        // Flutter's integration-test VM connection can conflict with DDS.
        // Launch this harness with `flutter drive --profile --no-dds`.
        await binding
            .traceAction(
              () =>
                  binding.watchPerformance(action, reportKey: '${name}_frames'),
              reportKey: '${name}_timeline',
            )
            .timeout(const Duration(seconds: 30));
        debugPrint('PROFILE_PHASE $name complete');
      }

      Future<void> ready(Finder finder) async {
        final watch = Stopwatch()..start();
        while (finder.evaluate().isEmpty && watch.elapsedMilliseconds < 8000) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(finder, findsWidgets);
        meter.mark('visible', watch.elapsedMicroseconds / 1000);
      }

      await trace('responses_cold', () async {
        meter.phase = 'responses_cold';
        root.currentState!.show(const HostFormsScreen(initialResponses: true));
        await tester.pump();
        await ready(find.text('No responses yet'));
      });
      await trace('forms_switch_and_warm_responses', () async {
        meter.phase = 'forms_switch_and_warm_responses';
        await tester.tap(find.text('Forms'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Responses'));
        await tester.pumpAndSettle();
        expect(find.text('No responses yet'), findsWidgets);
      });
      await trace('responses_revisit', () async {
        meter.phase = 'responses_revisit';
        root.currentState!.show(const SizedBox());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 64));
        root.currentState!.show(const HostFormsScreen(initialResponses: true));
        await tester.pump();
        await ready(find.text('No responses yet'));
      });
      await trace('groups_2500', () async {
        meter.phase = 'groups_2500';
        root.currentState!.show(
          const HostCustomersScreen(initialView: HostAudienceView.audiences),
        );
        await tester.pump();
        await ready(find.text('Group 0000'));
        await tester.drag(
          find.byType(CustomScrollView).first,
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
      });
      root.currentState!.show(const SizedBox());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 64));
      await trace('groups_cancel', () async {
        meter.phase = 'groups_cancel';
        root.currentState!.show(
          const HostCustomersScreen(initialView: HostAudienceView.audiences),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 64));
        root.currentState!.show(const SizedBox());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1600));
      });
      binding.reportData!['fixture'] = {
        'profileMode': kProfileMode,
        'platform': defaultTargetPlatform.name,
        'formsDelayMs': 600,
        'responsesDelayMs': 200,
        'groupPageDelayMs': 20,
        'groupDefinitions': 2500,
        'events': meter.events,
      };
      expect(tester.takeException(), isNull);
    },
  );
}

class _Meter {
  final clock = Stopwatch()..start();
  String phase = 'setup';
  final events = <Map<String, Object?>>[];
  void mark(String event, [double? elapsedMs]) => events.add({
    'phase': phase,
    'event': event,
    'atMs': clock.elapsedMicroseconds / 1000,
    'elapsedMs': ?elapsedMs,
  });
  Future<void> request(String name, int delayMs) async {
    mark('$name.start');
    final task = developer.TimelineTask()..start('fixture.$name');
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    task.finish();
    mark('$name.end');
  }
}

class _Fixture extends StatefulWidget {
  const _Fixture({super.key});
  @override
  State<_Fixture> createState() => _FixtureState();
}

class _FixtureState extends State<_Fixture> {
  Widget child = const SizedBox();
  void show(Widget value) => setState(() => child = value);
  @override
  Widget build(BuildContext context) => child;
}

class _Functions extends Fake implements FirebaseFunctions {}

class _Auth extends Fake implements FirebaseAuth {
  @override
  User get currentUser => _User();
}

class _User extends Fake implements User {
  @override
  String get uid => 'perf-host';
}

class _Forms extends HostFormsRepository {
  _Forms(this.meter) : super(_Functions());
  final _Meter meter;
  @override
  Future<HostFormPage> listForms(HostFormListRequest request) async {
    await meter.request('forms', 600);
    return HostFormPage(
      organizerId: request.organizerId,
      items: const [],
      nextCursor: null,
    );
  }

  @override
  Future<HostFormResponsePage> listResponses(
    HostFormResponseListRequest request,
  ) async {
    await meter.request('responses', 200);
    return HostFormResponsePage(
      organizerId: request.organizerId,
      items: const [],
      nextCursor: null,
    );
  }
}

class _Groups extends HostSavedAudienceRepository {
  _Groups(this.meter) : super(_Functions());
  final _Meter meter;
  @override
  Future<HostSavedAudiencePage> listSavedAudiences(
    String organizerId, {
    String status = 'active',
    String? cursor,
    int limit = 25,
  }) async {
    await meter.request('groups', 20);
    final offset = int.tryParse(cursor ?? '') ?? 0;
    final end = (offset + limit).clamp(0, 2500);
    return HostSavedAudiencePage(
      audiences: [
        for (var index = offset; index < end; index++)
          HostSavedAudience(
            organizerId: organizerId,
            audienceId: 'group-$index',
            name: 'Group ${index.toString().padLeft(4, '0')}',
            status: 'active',
            definition: const HostSavedAudienceDefinition(
              join: HostSavedAudienceJoin.all,
              predicates: [],
            ),
            definitionHash:
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            definitionVersion: 1,
            revision: 1,
            lastPreviewMatchCount: null,
            lastPreviewAt: null,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
      ],
      nextCursor: end < 2500 ? '$end' : null,
    );
  }
}
