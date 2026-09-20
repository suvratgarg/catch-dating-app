import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets(
    'city filters remain available during loading and empty scan pages',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final requests = <HostFormResponseListRequest>[];
      final pending = Completer<HostFormResponsesState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hostFormResponsesControllerProvider.overrideWith2(
              (_) => _Responses(requests, pending),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(
                slivers: [
                  HostFormResponsesPanel(
                    organizerId: 'org',
                    formId: 'form',
                    showFormContext: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Event city: All'));
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Mumbai'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(requests.last.answerFilters, {'city': 'Mumbai'});
      expect(find.text('Event city: Mumbai'), findsOneWidget);
      pending.complete(_page);
      await pumpFeatureUi(tester);
      expect(find.text('Load more responses'), findsOneWidget);
      expect(find.text('No matching responses'), findsNothing);
      await tester.tap(find.text('Newest first'));
      await pumpFeatureUi(tester);
      expect(requests.last.oldestFirst, isTrue);
      expect(requests.last.answerFilters, {'city': 'Mumbai'});
      expect(tester.takeException(), isNull);
    },
  );
}

const _page = HostFormResponsesState(
  responses: [],
  nextCursor: 'continue-scan',
  answerFilterOptions: [
    HostFormResponseFilterOption(
      questionId: 'city',
      label: 'Event city',
      options: {'Mumbai': 'Mumbai', 'Dubai': 'Dubai'},
    ),
  ],
);

class _Responses extends HostFormResponsesController {
  _Responses(this.requests, this.pending);
  final List<HostFormResponseListRequest> requests;
  final Completer<HostFormResponsesState> pending;
  @override
  Future<HostFormResponsesState> build(
    HostFormResponseListRequest request,
  ) async {
    requests.add(request);
    return request.answerFilters.isEmpty ? _page : pending.future;
  }
}
