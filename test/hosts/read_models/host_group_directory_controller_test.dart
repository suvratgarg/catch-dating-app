import 'dart:async';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/hosts/data/crm/host_saved_audience_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnusedFunctions extends Fake implements FirebaseFunctions {}

HostSavedAudienceSummary row(String id) => HostSavedAudienceSummary(
  organizerId: 'org',
  audienceId: id,
  name: id,
  status: 'active',
  isStatic: false,
  revision: 1,
  lastPreviewMatchCount: null,
  lastPreviewAt: null,
  updatedAt: DateTime(2026),
);

class _PagedGroups extends HostSavedAudienceRepository {
  _PagedGroups() : super(_UnusedFunctions());
  int calls = 0;
  final continuation = Completer<HostSavedAudienceSummaryPage>();
  @override
  Future<HostSavedAudienceSummaryPage> listGroupSummaries(
    String organizerId, {
    String? cursor,
    int limit = ReadLimitPolicy.historyPage,
    bool byName = true,
    bool? isStatic,
  }) async {
    calls++;
    if (cursor != null) return continuation.future;
    return HostSavedAudienceSummaryPage(
      audiences: [row('a')],
      nextCursor: 'next',
    );
  }
}

void main() {
  test('Groups publish the first page without awaiting later pages', () async {
    final repo = _PagedGroups();
    final container = ProviderContainer.test(
      overrides: [hostSavedAudienceRepositoryProvider.overrideWithValue(repo)],
    );
    final provider = hostGroupDirectoryControllerProvider('org');
    container.listen(provider, (_, _) {});
    final initial = await container.read(provider.future);
    expect(initial.page.audiences.map((item) => item.audienceId), ['a']);
    expect(repo.calls, 1);
    final pending = container.read(provider.notifier).loadMore();
    expect(container.read(provider).requireValue.loadingMore, isTrue);
    repo.continuation.complete(
      HostSavedAudienceSummaryPage(
        audiences: [row('a'), row('b')],
        nextCursor: null,
      ),
    );
    await pending;
    expect(
      container
          .read(provider)
          .requireValue
          .page
          .audiences
          .map((item) => item.audienceId),
      ['a', 'b'],
    );
    expect(container.read(provider).requireValue.page.nextCursor, isNull);
  });

  test(
    'Disposed Group continuations cannot update or restart the directory',
    () async {
      final repo = _PagedGroups();
      final container = ProviderContainer.test(
        overrides: [
          hostSavedAudienceRepositoryProvider.overrideWithValue(repo),
        ],
      );
      final provider = hostGroupDirectoryControllerProvider('org');
      final subscription = container.listen(provider, (_, _) {});
      await container.read(provider.future);
      final pending = container.read(provider.notifier).loadMore();
      subscription.close();
      await container.pump();
      repo.continuation.complete(
        HostSavedAudienceSummaryPage(
          audiences: [row('stale')],
          nextCursor: 'unused',
        ),
      );
      await pending;
      expect(repo.calls, 2);
    },
  );
}
