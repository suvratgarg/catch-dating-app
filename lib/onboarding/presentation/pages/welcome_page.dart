import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const d = CatchTokens.sunsetDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: d.bg,
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: CatchInsets.welcomeHero,
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catch.',
                                style: CatchTextStyles.headlineS(
                                  context,
                                  color: d.ink,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'RUN CLUB DATING',
                                style: CatchTextStyles.kicker(
                                  context,
                                  color: d.ink3,
                                ),
                              ),
                              gapH16,
                              Text(
                                'Love arrives\nat mile\nthree.',
                                style: CatchTextStyles.display(
                                  context,
                                  color: d.ink,
                                ),
                              ),
                              gapH16,
                              Text(
                                'Join a group run. Match only with people you '
                                'actually ran with - never strangers 30 miles away.',
                                style: CatchTextStyles.proseL(
                                  context,
                                  color: d.ink.withValues(
                                    alpha: CatchOpacity.welcomeHeroBody,
                                  ),
                                ),
                              ),
                              gapH24,
                              CatchButton(
                                label: 'Continue with phone',
                                onPressed: () =>
                                    context.go(_authLocation(context)),
                                variant: CatchButtonVariant.light,
                                size: CatchButtonSize.lg,
                                fullWidth: true,
                              ),
                              gapH10,
                              CatchButton(
                                label: 'Explore events',
                                onPressed: () => context.go('/clubs'),
                                variant: CatchButtonVariant.secondary,
                                size: CatchButtonSize.lg,
                                fullWidth: true,
                                backgroundColor: d.ink.withValues(
                                  alpha:
                                      CatchOpacity.welcomeSecondaryButtonFill,
                                ),
                                foregroundColor: d.ink,
                                borderColor: d.ink.withValues(
                                  alpha:
                                      CatchOpacity.welcomeSecondaryButtonBorder,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _authLocation(BuildContext context) {
  final from = _safeFrom(GoRouterState.of(context).uri.queryParameters['from']);
  if (from == null) return '/auth';

  return Uri(path: '/auth', queryParameters: {'from': from}).toString();
}

String? _safeFrom(String? from) {
  if (from == null || from.isEmpty || !from.startsWith('/')) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return uri.toString();
}
