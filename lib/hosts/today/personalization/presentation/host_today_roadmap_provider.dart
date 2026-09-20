import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_today_roadmap_provider.g.dart';

@riverpod
HostTodayRoadmapEvidence hostTodayRoadmap(
  Ref ref,
  HostTodayPreferenceScope scope,
) {
  final uid = ref.watch(uidProvider).asData?.value;
  if (uid != scope.accountId) return const HostTodayRoadmapEvidence();
  final organizer = ref
      .watch(hostOperableClubsProvider(scope.accountId))
      .asData
      ?.value
      .where((club) => club.id == scope.organizerId)
      .firstOrNull;
  if (organizer == null) return const HostTodayRoadmapEvidence();
  final audience = ref.watch(hostCrmSummaryProvider(scope.organizerId));
  final accounts = organizer.isOwnedBy(scope.accountId)
      ? ref.watch(watchHostPaymentAccountsProvider(scope.accountId))
      : const AsyncValue<List<HostPaymentAccount>>.data([]);
  return buildHostTodayRoadmapEvidence(
    organizer: organizer,
    accountId: scope.accountId,
    audience: audience.asData?.value,
    paymentAccounts: accounts.asData?.value,
  );
}

HostTodayRoadmapEvidence buildHostTodayRoadmapEvidence({
  required Club organizer,
  required String accountId,
  required HostCrmSummary? audience,
  required List<HostPaymentAccount>? paymentAccounts,
  bool? hasCompletedRehearsal,
}) {
  final matchingAudience = audience?.organizerId == organizer.id
      ? audience
      : null;
  final hasContacts = matchingAudience == null
      ? null
      : matchingAudience.contactCount > 0
      ? true
      : matchingAudience.truncated
      ? null
      : false;
  final isOwner = organizer.isOwnedBy(accountId);
  final accounts = paymentAccounts
      ?.where((account) => account.userId == accountId)
      .toList();
  return HostTodayRoadmapEvidence(
    audience: _progress(hasContacts),
    rehearsal: _progress(hasCompletedRehearsal),
    organizerPage: _progress(
      organizer.publicPage?.isPublicWebsiteEnabled ?? false,
    ),
    payouts: _progress(
      !isOwner || accounts == null
          ? null
          : accounts.any((account) => account.canAcceptPayments),
    ),
    canManagePayouts: isOwner,
  );
}

HostTodayMilestoneProgress _progress(bool? complete) => switch (complete) {
  true => HostTodayMilestoneProgress.complete,
  false => HostTodayMilestoneProgress.incomplete,
  null => HostTodayMilestoneProgress.unknown,
};
