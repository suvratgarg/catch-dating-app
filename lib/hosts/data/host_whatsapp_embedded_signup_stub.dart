import 'package:catch_dating_app/hosts/domain/crm/host_messaging_setup.dart';

bool get hostWhatsappEmbeddedSignupSupported => false;

Future<HostWhatsappSignupResult> startHostWhatsappEmbeddedSignup(
  HostWhatsappEmbeddedSignupConfig config,
) => Future.error(
  UnsupportedError(
    'WhatsApp Embedded Signup is available on the Host web app.',
  ),
);
