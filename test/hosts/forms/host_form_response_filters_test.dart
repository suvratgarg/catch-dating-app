import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:catch_ui/catch_ui.dart';
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
  testWidgets(
    'all promoted questions are available with at most five active filters',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final requests = <HostFormResponseListRequest>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hostFormResponsesControllerProvider.overrideWith2(
              (_) => _ManyFilters(requests),
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
      for (final number in [6, 1, 2, 3, 4]) {
        await tester.tap(find.text('Filter $number: All'));
        await pumpFeatureUi(tester);
        await tester.tap(find.text('Selected'));
        await pumpFeatureUi(tester);
      }
      expect(requests.last.answerFilters.length, 5);
      expect(requests.last.answerFilters['q6'], 'selected');
      expect(
        tester
            .widget<CatchButton>(
              find.widgetWithText(CatchButton, 'Filter 5: All'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Filter 6: Selected'));
      await pumpFeatureUi(tester);
      await tester.tap(find.text('All').last);
      await pumpFeatureUi(tester);
      expect(requests.last.answerFilters.length, 4);
      expect(
        tester
            .widget<CatchButton>(
              find.widgetWithText(CatchButton, 'Filter 5: All'),
            )
            .onPressed,
        isNotNull,
      );
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

class _ManyFilters extends HostFormResponsesController {
  _ManyFilters(this.requests);
  final List<HostFormResponseListRequest> requests;
  @override
  Future<HostFormResponsesState> build(
    HostFormResponseListRequest request,
  ) async {
    requests.add(request);
    return HostFormResponsesState(
      responses: const [],
      nextCursor: null,
      answerFilterOptions: [
        for (var i = 1; i <= 6; i++)
          HostFormResponseFilterOption(
            questionId: 'q$i',
            label: 'Filter $i',
            options: const {'selected': 'Selected'},
          ),
      ],
    );
  }
}
