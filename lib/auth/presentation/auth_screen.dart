import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_page_presentation.dart';
import 'package:catch_dating_app/auth/presentation/otp_page.dart';
import 'package:catch_dating_app/auth/presentation/phone_page.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({
    super.key,
    this.appRole,
    this.initialPhoneNumber = '',
    this.initialOtpCode = '',
    this.initialResendSeconds,
  });

  final AppRole? appRole;
  final String initialPhoneNumber;
  final String initialOtpCode;
  final int? initialResendSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(authControllerProvider.select((s) => s.step));
    final resolvedRole = appRole ?? AppConfig.appRole;

    if (resolvedRole == AppRole.host) {
      return HostAuthFlowFrame(
        child: AnimatedSwitcher(
          duration: _authMotionDuration(context, CatchMotion.pageStep),
          switchInCurve: CatchMotion.standardCurve,
          switchOutCurve: CatchMotion.standardCurve,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.bottomCenter,
            children: [...previousChildren, ?currentChild],
          ),
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: switch (step) {
            AuthStep.phone => PhonePage(
              key: const ValueKey<AuthStep>(AuthStep.phone),
              presentation: AuthPagePresentation.hostInline,
              initialPhoneNumber: initialPhoneNumber,
            ),
            AuthStep.otp => OtpPage(
              key: const ValueKey<AuthStep>(AuthStep.otp),
              presentation: AuthPagePresentation.hostInline,
              initialCode: initialOtpCode,
              initialSecondsUntilResend: initialResendSeconds,
            ),
          },
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: switch (step) {
          AuthStep.phone => const PhonePage(),
          AuthStep.otp => OtpPage(
            initialCode: initialOtpCode,
            initialSecondsUntilResend: initialResendSeconds,
          ),
        },
      ),
    );
  }
}

/// Host auth frame whose top brand stage is geometrically identical to the
/// Flutter startup surface. Only the lower content is animated.
class HostAuthFlowFrame extends StatelessWidget {
  const HostAuthFlowFrame({super.key, required this.child});

  static const contentKey = ValueKey<String>('host-auth-content');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const CatchStartupBrandStage(appRole: AppRole.host),
            Expanded(
              child: SingleChildScrollView(
                key: contentKey,
                reverse: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: CatchInsets.hostAuthStage,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: CatchLayout.maxContentWidth,
                    ),
                    child: _HostAuthContentEntrance(child: child),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostAuthContentEntrance extends StatelessWidget {
  const _HostAuthContentEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: _authMotionDuration(context, CatchMotion.authContentEntrance),
      curve: CatchMotion.easeOutCubicCurve,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              CatchLayout.authContentEntranceOffset * (1 - value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

Duration _authMotionDuration(BuildContext context, Duration duration) {
  return MediaQuery.maybeOf(context)?.disableAnimations == true
      ? CatchMotion.none
      : duration;
}
