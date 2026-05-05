import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/otp_page.dart';
import 'package:catch_dating_app/auth/presentation/phone_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(authControllerProvider.select((s) => s.step));

    return Scaffold(
      body: SafeArea(
        child: switch (step) {
          AuthStep.phone => const PhonePage(),
          AuthStep.otp => const OtpPage(),
        },
      ),
    );
  }
}
