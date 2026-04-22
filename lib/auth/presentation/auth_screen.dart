import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_validators.dart';
import 'package:catch_dating_app/auth/presentation/widgets/or_divider.dart';
import 'package:catch_dating_app/common_widgets/app_form_layout.dart';
import 'package:catch_dating_app/common_widgets/error_banner.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.authState});

  final AuthState authState;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthState state) {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    FocusScope.of(context).unfocus();

    AuthController.submitMutation.run(ref, (transaction) async {
      await transaction
          .get(authControllerProvider(authState: state).notifier)
          .submit(
            email: _emailController.text,
            password: _passwordController.text,
          );
    });
  }

  void _toggleAuthState(AuthController notifier) {
    AuthController.submitMutation.reset(ref);
    notifier.toggleAuthState();
  }

  void _goToPhoneOnboarding() {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    context.go(
      Uri(
        path: Routes.onboardingScreen.path,
        queryParameters: {if (from != null && from.isNotEmpty) 'from': from},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      authControllerProvider(authState: widget.authState),
    );
    final notifier = ref.read(
      authControllerProvider(authState: widget.authState).notifier,
    );
    final submitMutation = ref.watch(AuthController.submitMutation);
    final t = CatchTokens.of(context);
    final isSigningIn = state == AuthState.signIn;
    final isSubmitting = submitMutation.isPending;
    final errorMessage = submitMutation.hasError
        ? authErrorMessage((submitMutation as MutationError).error)
        : null;

    return Scaffold(
      body: AutofillGroup(
        child: AppFormLayout(
          formKey: _formKey,
          children: [
            Text(
              'Catch',
              style: CatchTextStyles.displayMd(context, color: t.primary),
              textAlign: TextAlign.center,
            ),
            gapH8,
            Text(
              isSigningIn ? 'Welcome back' : 'Create your account',
              style: CatchTextStyles.labelLg(context, color: t.ink2),
              textAlign: TextAlign.center,
            ),
            gapH48,
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              validator: AuthFormValidators.email,
            ),
            gapH16,
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: [
                if (isSigningIn) AutofillHints.password,
                if (!isSigningIn) AutofillHints.newPassword,
              ],
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onFieldSubmitted: (_) => _submit(state),
              validator: (value) =>
                  AuthFormValidators.password(value, isSignUp: !isSigningIn),
            ),
            if (errorMessage != null) ...[
              gapH16,
              ErrorBanner(message: errorMessage),
            ],
            gapH24,
            FilledButton(
              onPressed: isSubmitting ? null : () => _submit(state),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isSigningIn ? 'Sign in' : 'Create account'),
                  if (isSubmitting) ...[
                    gapW8,
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
            gapH16,
            TextButton(
              onPressed: isSubmitting ? null : () => _toggleAuthState(notifier),
              child: Text(
                isSigningIn ? 'Create account with email' : 'Sign in instead',
              ),
            ),
            gapH24,
            const OrDivider(),
            gapH16,
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : _goToPhoneOnboarding,
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Continue with phone'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            gapH48,
          ],
        ),
      ),
    );
  }
}
