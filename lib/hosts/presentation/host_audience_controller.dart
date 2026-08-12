import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_audience_controller.g.dart';

@riverpod
HostAudienceController hostAudienceController(Ref ref) =>
    HostAudienceController(ref.watch(hostCrmRepositoryProvider));

class HostAudienceController {
  const HostAudienceController(this._repository);

  final HostCrmRepository _repository;

  Future<HostAudienceContactDetail> getContactDetail({
    required String organizerId,
    required String contactId,
  }) => _repository.getContactDetail(organizerId, contactId);

  Future<void> mutateContact({
    required String organizerId,
    required String contactId,
    required int expectedRevision,
    String? displayNameOverride,
    bool clearDisplayNameOverride = false,
    bool? whatsappAdminSuppressed,
    bool? hidden,
  }) => _repository.mutateContact(
    organizerId: organizerId,
    contactId: contactId,
    expectedRevision: expectedRevision,
    displayNameOverride: displayNameOverride,
    clearDisplayNameOverride: clearDisplayNameOverride,
    whatsappAdminSuppressed: whatsappAdminSuppressed,
    hidden: hidden,
  );

  Future<HostAudienceExport> exportContacts({
    required String organizerId,
    HostAudienceSegment? segment,
  }) => _repository.exportContacts(organizerId, segment: segment);
}
