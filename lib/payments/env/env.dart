import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'RAZORPAY_KEY_ID')
  static final String razorpayKeyId = _Env.razorpayKeyId;
}
