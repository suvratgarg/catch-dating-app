import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_roadmap_provider.dart';
import 'package:catch_dating_app/organizers/domain/organizer_authority.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../clubs/clubs_test_helpers.dart' show buildClub;

void main() {
  final club = buildClub().copyWith(ownerUserId: 'owner');

  test('unknown dependencies are not treated as completed or empty', () {
    final evidence = buildHostTodayRoadmapEvidence(
      organizer: club,
      accountId: 'owner',
      audience: null,
      paymentAccounts: null,
    );
    expect(evidence.audience, HostTodayMilestoneProgress.unknown);
    expect(evidence.rehearsal, HostTodayMilestoneProgress.unknown);
    expect(evidence.payouts, HostTodayMilestoneProgress.unknown);
    expect(evidence.canManagePayouts, isTrue);
  });

  test('only authoritative customer counts establish audience completion', () {
    for (final data in [
      (
        summary: _summary(club.id, count: 0),
        expected: HostTodayMilestoneProgress.incomplete,
      ),
      (
        summary: _summary(club.id, count: 1),
        expected: HostTodayMilestoneProgress.complete,
      ),
      (
        summary: _summary(club.id, count: 0, truncated: true),
        expected: HostTodayMilestoneProgress.unknown,
      ),
      (
        summary: _summary('other-organizer', count: 1),
        expected: HostTodayMilestoneProgress.unknown,
      ),
    ]) {
      final evidence = buildHostTodayRoadmapEvidence(
        organizer: club,
        accountId: 'owner',
        audience: data.summary,
        paymentAccounts: null,
      );
      expect(evidence.audience, data.expected);
    }
  });

  test('public website requires both publication and a canonical route', () {
    for (final data in [
      (status: 'draft', path: '/organizers/test', expected: false),
      (status: 'published', path: null, expected: false),
      (status: 'published', path: '/organizers/test', expected: true),
      (status: 'suppressed', path: '/organizers/test', expected: false),
    ]) {
      final evidence = buildHostTodayRoadmapEvidence(
        organizer: club.copyWith(
          publicPage: OrganizerPublicPage.fromJson({
            'publishStatus': data.status,
            'canonicalPath': data.path,
          }),
        ),
        accountId: 'owner',
        audience: null,
        paymentAccounts: null,
      );
      expect(
        evidence.organizerPage,
        data.expected
            ? HostTodayMilestoneProgress.complete
            : HostTodayMilestoneProgress.incomplete,
      );
    }
  });

  test(
    'cohost payment capability is not confused with organizer owner readiness',
    () {
      final evidence = buildHostTodayRoadmapEvidence(
        organizer: club,
        accountId: 'cohost',
        audience: null,
        paymentAccounts: [_account('cohost', ready: true)],
      );
      expect(evidence.canManagePayouts, isFalse);
      expect(evidence.payouts, HostTodayMilestoneProgress.unknown);
    },
  );

  test('payout completion needs this owner to be ready to accept payments', () {
    for (final data in [
      (accounts: <HostPaymentAccount>[], expected: false),
      (accounts: [_account('someone-else', ready: true)], expected: false),
      (accounts: [_account('owner', ready: false)], expected: false),
      (accounts: [_account('owner', ready: true)], expected: true),
    ]) {
      final evidence = buildHostTodayRoadmapEvidence(
        organizer: club,
        accountId: 'owner',
        audience: null,
        paymentAccounts: data.accounts,
        hasCompletedRehearsal: true,
      );
      expect(
        evidence.payouts,
        data.expected
            ? HostTodayMilestoneProgress.complete
            : HostTodayMilestoneProgress.incomplete,
      );
      expect(evidence.rehearsal, HostTodayMilestoneProgress.complete);
    }
  });
}

HostCrmSummary _summary(
  String organizerId, {
  required int count,
  bool truncated = false,
}) => HostCrmSummary(
  organizerId: organizerId,
  contactCount: count,
  pastAttendeeCount: 0,
  repeatAttendeeCount: 0,
  linkedAccountCount: 0,
  importedContactCount: 0,
  whatsappOptInCount: 0,
  smsOptInCount: 0,
  truncated: truncated,
  inAppReadiness: HostCrmChannelReadiness.currentEventOnly,
  whatsappReadiness: HostCrmChannelReadiness.providerSetupRequired,
  smsReadiness: HostCrmChannelReadiness.providerAndDltSetupRequired,
);

HostPaymentAccount _account(String userId, {required bool ready}) =>
    HostPaymentAccount(
      userId: userId,
      country: 'IN',
      defaultCurrency: 'INR',
      chargesEnabled: ready,
      payoutsEnabled: ready,
      detailsSubmitted: ready,
      onboardingStatus: ready
          ? HostPaymentOnboardingStatus.complete
          : HostPaymentOnboardingStatus.pending,
    );
