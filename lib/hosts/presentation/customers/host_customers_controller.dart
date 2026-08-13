import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_customers_controller.g.dart';

@riverpod
class HostCustomersDirectoryController
    extends _$HostCustomersDirectoryController {
  @override
  Future<HostCustomersDirectoryState> build(
    HostCustomersDirectoryRequest request,
  ) async {
    final page = await ref
        .read(hostCrmRepositoryProvider)
        .listContacts(request.organizerId, query: request.query);
    return HostCustomersDirectoryState.fromPage(page);
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.canLoadMore) return;
    state = AsyncData(
      current.copyWith(loadingMore: true, clearLoadMoreError: true),
    );
    try {
      final page = await ref
          .read(hostCrmRepositoryProvider)
          .listContacts(
            request.organizerId,
            query: request.query.copyWith(cursor: current.nextCursor),
          );
      final byId = <String, HostAudienceContact>{
        for (final contact in current.contacts) contact.contactId: contact,
        for (final contact in page.contacts) contact.contactId: contact,
      };
      state = AsyncData(
        HostCustomersDirectoryState(
          contacts: List.unmodifiable(byId.values),
          nextCursor: page.nextCursor,
          sourceCoverage: page.sourceCoverage,
          projectionVersion: page.projectionVersion,
        ),
      );
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreError: error),
      );
    }
  }
}

@riverpod
HostCustomersController hostCustomersController(Ref ref) =>
    HostCustomersController(ref.watch(hostCrmRepositoryProvider));

class HostCustomersController {
  const HostCustomersController(this._repository);

  final HostCrmRepository _repository;

  Future<HostCreatedCustomer> createCustomer({
    required String organizerId,
    required String displayName,
  }) => _repository.createContact(
    organizerId: organizerId,
    displayName: displayName,
  );

  Future<String> startConversation({
    required String organizerId,
    required String contactId,
  }) => _repository.startContactConversation(
    organizerId: organizerId,
    contactId: contactId,
  );
}
