import 'package:catch_dating_app/core/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Public legal and support destinations shown by both app roles.
///
/// A null destination keeps its entry hidden instead of launching a dormant
/// route; [AppConfig] owns the configured, https-only values.
class LegalLinks {
  const LegalLinks({this.privacyPolicy, this.terms, this.help});

  final Uri? privacyPolicy;
  final Uri? terms;
  final Uri? help;
}

final legalLinksProvider = Provider<LegalLinks>(
  (ref) => LegalLinks(
    privacyPolicy: AppConfig.privacyPolicyUrl,
    terms: AppConfig.termsUrl,
    help: AppConfig.helpUrl,
  ),
);
