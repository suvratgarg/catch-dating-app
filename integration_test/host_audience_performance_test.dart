import 'dart:convert';
import 'dart:developer' as developer;

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/crm/host_contacts_repository.dart';
import 'package:catch_dating_app/hosts/data/crm/host_saved_audience_repository.dart';
import 'package:catch_dating_app/hosts/data/crm/host_whatsapp_repository.dart';
import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_contact.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_query.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_crm_summary.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_messaging_setup.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_definition.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
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
import '../test/test_pump_helpers.dart';

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
      final contacts = _Contacts(meter);
      final club = buildClub(id: 'perf-organizer', ownerUserId: 'perf-host');
      final overrides = [
        firebaseAuthProvider.overrideWithValue(_Auth()),
        uidProvider.overrideWithValue(const AsyncData<String?>('perf-host')),
        hostOperableClubsProvider(
          'perf-host',
        ).overrideWithValue(AsyncData([club])),
        hostFormsRepositoryProvider.overrideWithValue(forms),
        hostSavedAudienceRepositoryProvider.overrideWithValue(groups),
        hostContactsRepositoryProvider.overrideWithValue(contacts),
        hostWhatsappRepositoryProvider.overrideWithValue(_Whatsapp(meter)),
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
          await pumpFeatureUiFor(tester, const Duration(milliseconds: 16));
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
        await pumpFeatureUi(tester);
        await tester.tap(find.text('Responses'));
        await pumpFeatureUi(tester);
        expect(find.text('No responses yet'), findsWidgets);
      });
      await trace('responses_revisit', () async {
        meter.phase = 'responses_revisit';
        root.currentState!.show(const SizedBox());
        await tester.pump();
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 64));
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
          verticalScroll(
            const PageStorageKey<String>('host-customers-audiences'),
          ),
          const Offset(0, -500),
        );
        await pumpFeatureUi(tester);
      });
      root.currentState!.show(const SizedBox());
      await tester.pump();
      await pumpFeatureUiFor(tester, const Duration(milliseconds: 64));
      await trace('groups_cancel', () async {
        meter.phase = 'groups_cancel';
        root.currentState!.show(
          const HostCustomersScreen(initialView: HostAudienceView.audiences),
        );
        await tester.pump();
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 64));
        root.currentState!.show(const SizedBox());
        await tester.pump();
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 1600));
      });
      await trace('people_cold', () async {
        meter.phase = 'people_cold';
        root.currentState!.show(const HostCustomersScreen());
        await tester.pump();
        await ready(find.text('Person 0000'));
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 700));
      });
      await trace('people_groups_people', () async {
        meter.phase = 'people_groups_people';
        await tester.tap(find.text('Groups'));
        await tester.pump();
        await ready(find.text('Group 0000'));
        await tester.tap(find.text('People'));
        await tester.pump();
        await ready(find.text('Person 0000'));
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 700));
      });
      await trace('people_revisit', () async {
        meter.phase = 'people_revisit';
        root.currentState!.show(const SizedBox());
        await tester.pump();
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 64));
        root.currentState!.show(const HostCustomersScreen());
        await tester.pump();
        await ready(find.text('Person 0000'));
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 700));
      });
      final container = ProviderScope.containerOf(
        root.currentContext!,
        listen: false,
      );
      const peopleRequest = HostCustomersDirectoryRequest(
        organizerId: 'perf-organizer',
      );
      await trace('people_2500', () async {
        meter.phase = 'people_2500';
        final provider = hostCustomersDirectoryControllerProvider(
          peopleRequest,
        );
        final watch = Stopwatch()..start();
        while (container.read(provider).requireValue.canLoadMore) {
          await container.read(provider.notifier).loadMore();
          await tester.pump();
        }
        expect(container.read(provider).requireValue.contacts.length, 2500);
        meter.mark('allRowsLoaded', watch.elapsedMicroseconds / 1000);
        await tester.drag(
          verticalScroll(const PageStorageKey<String>('host-customers-people')),
          const Offset(0, -1000),
        );
        await pumpFeatureUi(tester);
      });
      await trace('responses_2500', () async {
        meter.phase = 'responses_2500';
        forms.responseCount = 2500;
        forms.responseDelayMs = 20;
        root.currentState!.show(const SizedBox());
        await tester.pump();
        await pumpFeatureUiFor(tester, const Duration(milliseconds: 64));
        root.currentState!.show(const HostFormsScreen(initialResponses: true));
        await tester.pump();
        await ready(find.text('Response 0000'));
        const request = HostFormResponseListRequest(
          organizerId: 'perf-organizer',
          includeApplications: true,
        );
        final provider = hostFormResponsesControllerProvider(request);
        final watch = Stopwatch()..start();
        while (container.read(provider).requireValue.canLoadMore) {
          await container.read(provider.notifier).loadMore();
          await tester.pump();
        }
        expect(container.read(provider).requireValue.responses.length, 2500);
        meter.mark('allRowsLoaded', watch.elapsedMicroseconds / 1000);
        await tester.drag(
          verticalScroll(const PageStorageKey<String>('host-forms-responses')),
          const Offset(0, -1000),
        );
        await pumpFeatureUi(tester);
      });
      binding.reportData!['fixture'] = {
        'profileMode': kProfileMode,
        'platform': defaultTargetPlatform.name,
        'formsDelayMs': 600,
        'responsesDelayMs': 200,
        'groupPageDelayMs': 20,
        'groupDefinitions': 2500,
        'peopleRows': 2500,
        'peopleFirstPageMs': 200,
        'summaryMs': 600,
        'messagingMs': 500,
        'largeListPageMs': 20,
        'events': meter.events,
      };
      expect(tester.takeException(), isNull);
    },
    // This manual benchmark needs a real profile VM; ordinary CI tests use
    // the focused deterministic regressions instead of connecting to DDS.
    skip: !kProfileMode,
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
  int responseCount = 0;
  int responseDelayMs = 200;
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
    await meter.request('responses', responseDelayMs);
    final offset = int.tryParse(request.cursor ?? '') ?? 0;
    final end = (offset + request.limit).clamp(0, responseCount);
    final payload = jsonEncode({
      'organizerId': request.organizerId,
      'nextCursor': end < responseCount ? '$end' : null,
      'items': [
        for (var i = offset; i < end; i++)
          {
            'responseId': 'response-$i',
            'formId': 'fixture-form',
            'formTitle': 'Fixture form',
            'versionId': 'fixture-v1',
            'version': 1,
            'status': 'submitted',
            'identityKind': 'anonymous',
            'identity': {
              'displayName': 'Response ${i.toString().padLeft(4, '0')}',
              'email': null,
              'phoneE164': null,
              'origin': 'anonymous',
            },
            'sourceLinkId': null,
            'sourceLabel': null,
            'submittedAtMillis': DateTime(2026).millisecondsSinceEpoch,
            'withdrawnAtMillis': null,
            'highlights': [],
            'conversionKinds': [],
          },
      ],
    });
    meter.mark(
      'responses.payloadBytes',
      utf8.encode(payload).length.toDouble(),
    );
    final decode = Stopwatch()..start();
    final page = developer.Timeline.timeSync(
      'fixture.responses.decode',
      () => HostFormResponsePage.fromCallableData(jsonDecode(payload)),
    );
    meter.mark('responses.decodeMs', decode.elapsedMicroseconds / 1000);
    return page;
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

class _Contacts extends HostContactsRepository {
  _Contacts(this.meter) : super(_Functions());
  final _Meter meter;
  @override
  Future<HostCrmSummary> getSummary(String organizerId) async {
    await meter.request('summary', 600);
    return HostCrmSummary(
      organizerId: organizerId,
      contactCount: 2500,
      pastAttendeeCount: 0,
      repeatAttendeeCount: 0,
      linkedAccountCount: 0,
      importedContactCount: 0,
      whatsappOptInCount: 0,
      smsOptInCount: 0,
      truncated: false,
      inAppReadiness: HostCrmChannelReadiness.currentEventOnly,
      whatsappReadiness: HostCrmChannelReadiness.providerSetupRequired,
      smsReadiness: HostCrmChannelReadiness.providerAndDltSetupRequired,
    );
  }

  @override
  Future<HostAudiencePage> listContacts(
    String organizerId, {
    HostAudienceQuery query = const HostAudienceQuery(),
    int limit = 30,
  }) async {
    await meter.request(
      limit == 1 ? 'segmentCount' : 'contacts',
      query.cursor == null ? 200 : 20,
    );
    final offset = int.tryParse(query.cursor ?? '') ?? 0;
    final end = (offset + limit).clamp(0, 2500);
    final payload = jsonEncode({
      'organizerId': organizerId,
      'nextCursor': end < 2500 ? '$end' : null,
      'matchCount': 2500,
      'matchCountCoverage': 'exact',
      'sourceCoverage': 'exact',
      'projectionVersion': 1,
      'contacts': [
        for (var i = offset; i < end; i++)
          {
            'contactId': 'person-$i',
            'displayName': 'Person ${i.toString().padLeft(4, '0')}',
            'phoneE164': null,
            'email': null,
            'identityState': 'unlinked',
            'identityConfidence': 'synthetic',
            'ambiguousCandidateCount': 0,
            'attendedEventCount': 0,
            'expectedEventCount': 0,
            'lastAttendedAtMillis': null,
            'segmentIds': [],
            'whatsappStatus': 'unknown',
            'whatsappAdminSuppressed': false,
            'smsStatus': 'unknown',
            'sourceCoverage': 'exact',
            'revision': 1,
          },
      ],
    });
    meter.mark('contacts.payloadBytes', utf8.encode(payload).length.toDouble());
    final decode = Stopwatch()..start();
    final page = developer.Timeline.timeSync(
      'fixture.contacts.decode',
      () => HostAudiencePage.fromCallableData(jsonDecode(payload)),
    );
    meter.mark('contacts.decodeMs', decode.elapsedMicroseconds / 1000);
    return page;
  }
}

class _Whatsapp extends HostWhatsappRepository {
  _Whatsapp(this.meter) : super(_Functions());
  final _Meter meter;
  @override
  Future<HostMessagingSetup> getMessagingSetup(
    String organizerId, {
    String? connectionId,
  }) async {
    await meter.request('messaging', 500);
    return HostMessagingSetup(
      organizerId: organizerId,
      providerConfigured: false,
      embeddedSignup: const HostWhatsappEmbeddedSignupConfig(
        appId: null,
        configId: null,
        graphVersion: null,
      ),
      connection: null,
      templates: const [],
    );
  }
}
