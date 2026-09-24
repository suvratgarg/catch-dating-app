/// Manager-only suggestions for future events. This object must come from an
/// authorized setup-preferences read, never from the public organizer document.
/// It is not a payment capability or an event-specific amount.
enum EventCollectionPreference {
  manualInstructions,
  reusablePage,
  personalRequest,
  catchCheckout,
}

class ReusableOrganizerPaymentPage {
  const ReusableOrganizerPaymentPage(
    this.url, {
    required this.reusableForEvents,
  });

  final String url;
  /// Explicit Host attestation; a pasted personal request is never reusable.
  final bool reusableForEvents;
}

/// Accept only canonical, public HTTPS URLs before asking the Host to attest
/// that the page can be reused across guests and events.
bool isCanonicalPublicPaymentPageUrl(String value) {
  if (value.isEmpty || value.length > 2048 || value.trim() != value) {
    return false;
  }
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasFragment ||
      uri.hasPort ||
      uri.toString() != value) {
    return false;
  }
  final host = uri.host.toLowerCase();
  if (host == 'localhost' ||
      host.endsWith('.localhost') ||
      host.endsWith('.local') ||
      host.contains(':') ||
      RegExp(r'^[0-9.]+$').hasMatch(host)) {
    return false;
  }
  final labels = host.split('.');
  if (labels.length < 2 ||
      labels.any((label) =>
          label.isEmpty ||
          label.length > 63 ||
          !RegExp(r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$').hasMatch(label))) {
    return false;
  }
  return RegExp(r'^[a-z]{2,}$').hasMatch(labels.last);
}

const _unchangedPreference = Object();

class ManagerEventSetupPreferences {
  const ManagerEventSetupPreferences({
    this.usualDurationMinutes,
    this.preferredVenueId,
    this.offerValidityMinutes,
    this.collectionPreference,
    this.currency,
    this.offerMessageTemplate,
    this.paymentInstructions,
    this.reusablePaymentPage,
  });

  final int? usualDurationMinutes;
  final String? preferredVenueId;
  final int? offerValidityMinutes;
  final EventCollectionPreference? collectionPreference;
  final String? currency;
  final String? offerMessageTemplate;
  final String? paymentInstructions;
  final ReusableOrganizerPaymentPage? reusablePaymentPage;

  ManagerEventSetupPreferences copyWith({
    Object? usualDurationMinutes = _unchangedPreference,
    Object? preferredVenueId = _unchangedPreference,
    Object? offerValidityMinutes = _unchangedPreference,
    Object? collectionPreference = _unchangedPreference,
    Object? currency = _unchangedPreference,
    Object? offerMessageTemplate = _unchangedPreference,
    Object? paymentInstructions = _unchangedPreference,
    Object? reusablePaymentPage = _unchangedPreference,
  }) => ManagerEventSetupPreferences(
    usualDurationMinutes: identical(usualDurationMinutes, _unchangedPreference)
        ? this.usualDurationMinutes
        : usualDurationMinutes as int?,
    preferredVenueId: identical(preferredVenueId, _unchangedPreference)
        ? this.preferredVenueId
        : preferredVenueId as String?,
    offerValidityMinutes: identical(offerValidityMinutes, _unchangedPreference)
        ? this.offerValidityMinutes
        : offerValidityMinutes as int?,
    collectionPreference: identical(collectionPreference, _unchangedPreference)
        ? this.collectionPreference
        : collectionPreference as EventCollectionPreference?,
    currency: identical(currency, _unchangedPreference)
        ? this.currency
        : currency as String?,
    offerMessageTemplate: identical(offerMessageTemplate, _unchangedPreference)
        ? this.offerMessageTemplate
        : offerMessageTemplate as String?,
    paymentInstructions: identical(paymentInstructions, _unchangedPreference)
        ? this.paymentInstructions
        : paymentInstructions as String?,
    reusablePaymentPage: identical(reusablePaymentPage, _unchangedPreference)
        ? this.reusablePaymentPage
        : reusablePaymentPage as ReusableOrganizerPaymentPage?,
  );
}
