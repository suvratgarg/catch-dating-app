enum HostPaymentOnboardingStatus { notStarted, pending, complete, restricted }

class HostPaymentAccount {
  const HostPaymentAccount({
    required this.userId,
    required this.country,
    required this.defaultCurrency,
    required this.stripeAccountId,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.detailsSubmitted,
    required this.onboardingStatus,
    this.disabledReason,
    this.requirementsCurrentlyDue = const [],
    this.requirementsPastDue = const [],
    this.requirementsPendingVerification = const [],
  });

  factory HostPaymentAccount.fromJson(Map<String, dynamic> json) {
    return HostPaymentAccount(
      userId: json['userId'] as String? ?? '',
      country: json['country'] as String? ?? '',
      defaultCurrency: json['defaultCurrency'] as String? ?? '',
      stripeAccountId: json['stripeAccountId'] as String? ?? '',
      chargesEnabled: json['chargesEnabled'] as bool? ?? false,
      payoutsEnabled: json['payoutsEnabled'] as bool? ?? false,
      detailsSubmitted: json['detailsSubmitted'] as bool? ?? false,
      onboardingStatus: _statusFromName(json['onboardingStatus'] as String?),
      disabledReason: json['disabledReason'] as String?,
      requirementsCurrentlyDue: _stringList(json['requirementsCurrentlyDue']),
      requirementsPastDue: _stringList(json['requirementsPastDue']),
      requirementsPendingVerification: _stringList(
        json['requirementsPendingVerification'],
      ),
    );
  }

  final String userId;
  final String country;
  final String defaultCurrency;
  final String stripeAccountId;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;
  final HostPaymentOnboardingStatus onboardingStatus;
  final String? disabledReason;
  final List<String> requirementsCurrentlyDue;
  final List<String> requirementsPastDue;
  final List<String> requirementsPendingVerification;

  bool get canAcceptInternationalPayments =>
      chargesEnabled &&
      payoutsEnabled &&
      onboardingStatus == HostPaymentOnboardingStatus.complete;
}

HostPaymentOnboardingStatus _statusFromName(String? value) {
  for (final status in HostPaymentOnboardingStatus.values) {
    if (status.name == value) return status;
  }
  return HostPaymentOnboardingStatus.notStarted;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}
