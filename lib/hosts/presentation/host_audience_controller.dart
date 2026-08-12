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

  Future<HostMessagingSetup> completeWhatsappConnection({
    required String organizerId,
    required HostWhatsappSignupResult result,
  }) => _repository.completeWhatsappConnection(organizerId, result);

  Future<HostMessagingSetup> syncWhatsappTemplates({
    required String organizerId,
    required String connectionId,
  }) => _repository.syncWhatsappTemplates(organizerId, connectionId);

  Future<HostMessagingSetup> disconnectWhatsapp({
    required String organizerId,
    required String connectionId,
  }) => _repository.disconnectWhatsapp(organizerId, connectionId);

  Future<HostMessagingSetup> sendWhatsappTest({
    required String organizerId,
    required String connectionId,
    required String templateId,
    required String toE164,
    required Map<String, String> templateVariables,
  }) => _repository.sendWhatsappTest(
    organizerId: organizerId,
    connectionId: connectionId,
    templateId: templateId,
    toE164: toE164,
    templateVariables: templateVariables,
  );

  Future<HostCampaign> saveAndPreviewCampaign({
    required String organizerId,
    required HostCampaignDraft draft,
  }) async {
    final saved = await _repository.upsertCampaign(organizerId, draft);
    return _repository.previewCampaign(organizerId, saved);
  }

  Future<HostCampaign> approveCampaign({
    required String organizerId,
    required HostCampaign campaign,
  }) => _repository.approveCampaign(organizerId, campaign);

  Future<HostCampaign> dispatchCampaign({
    required String organizerId,
    required HostCampaign campaign,
  }) => _repository.dispatchCampaign(organizerId, campaign);

  Future<HostCampaign> cancelCampaign({
    required String organizerId,
    required HostCampaign campaign,
  }) => _repository.cancelCampaign(organizerId, campaign);

  Future<HostCampaign> getCampaignReport({
    required String organizerId,
    required String campaignId,
  }) => _repository.getCampaignReport(organizerId, campaignId);
}
