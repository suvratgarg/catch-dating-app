import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../clubs/clubs_test_helpers.dart';

void main() {
  setUp(() => AppConfig.configureEntrypointRole(AppRole.host));
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  for (final formsFail in [false, true]) {
    testWidgets(
      'Responses renders independently when Forms ${formsFail ? 'fails' : 'is pending'}',
      (tester) async {
        final repository = _Forms();
        await tester.pumpWidget(_app(repository));
        await tester.pump();
        await tester.pump();
        // The responses read must begin without resolving the unrelated forms
        // read. Both still use their canonical manager-authorized repositories.
        expect(repository.responseRequests, greaterThan(0));
        if (formsFail) {
          repository.forms.completeError(StateError('Forms unavailable'));
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('No responses yet'), findsWidgets);
        expect(tester.takeException(), isNull);
        if (!formsFail) {
          repository.forms.complete(
            const HostFormPage(
              organizerId: 'forms-club',
              items: [],
              nextCursor: null,
            ),
          );
        }
        await tester.pump();
      },
    );
  }

  testWidgets('Forms error retry repeats the account-authorized read', (
    tester,
  ) async {
    final repository = _Forms();
    await tester.pumpWidget(_app(repository));
    await tester.pump();
    await tester.pump();
    repository.forms.completeError(StateError('Forms unavailable'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Forms'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Try again'), findsWidgets);
    final beforeRetry = repository.formRequests;
    repository.forms = Completer<HostFormPage>();
    await tester.tap(find.text('Try again').first);
    await tester.pump();
    expect(repository.formRequests, greaterThan(beforeRetry));
    repository.forms.complete(
      const HostFormPage(
        organizerId: 'forms-club',
        items: [],
        nextCursor: null,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Try again'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _Auth extends Fake implements FirebaseAuth {
  @override
  User get currentUser => _User();
}

class _User extends Fake implements User {
  @override
  String get uid => 'host-1';
}

class _Functions extends Fake implements FirebaseFunctions {}

class _Forms extends HostFormsRepository {
  _Forms() : super(_Functions());
  var forms = Completer<HostFormPage>();
  int formRequests = 0;
  int responseRequests = 0;
  @override
  Future<HostFormPage> listForms(HostFormListRequest request) {
    formRequests++;
    return forms.future;
  }

  @override
  Future<HostFormResponsePage> listResponses(
    HostFormResponseListRequest request,
  ) async {
    responseRequests++;
    return const HostFormResponsePage(
      organizerId: 'forms-club',
      items: [],
      nextCursor: null,
    );
  }
}

Widget _app(_Forms repository) => ProviderScope(
  overrides: [
    firebaseAuthProvider.overrideWithValue(_Auth()),
    uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
    hostOperableClubsProvider('host-1').overrideWithValue(
      AsyncData([buildClub(id: 'forms-club', ownerUserId: 'host-1')]),
    ),
    hostFormsRepositoryProvider.overrideWithValue(repository),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    home: const HostFormsScreen(initialResponses: true),
  ),
);
