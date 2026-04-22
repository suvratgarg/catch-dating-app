import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
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
    if (_formKey.currentState!.validate()) {
      AuthController.submitMutation.run(ref, (transaction) async {
        await transaction
            .get(authControllerProvider(authState: state).notifier)
            .submit(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      });
    }
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

    return Scaffold(
      body: AppFormLayout(
        formKey: _formKey,
        children: [
          Text(
            'Catch',
            style: CatchTextStyles.displayMd(context, color: t.primary),
            textAlign: TextAlign.center,
          ),
          gapH8,
          Text(
            switch (state) {
              AuthState.signIn => 'Welcome back',
              AuthState.signUp => 'Create your account',
            },
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
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.trim().contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          gapH16,
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
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
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(state),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          if (submitMutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: (submitMutation as MutationError).error.toString(),
            ),
          ],
          gapH24,
          FilledButton(
            onPressed: submitMutation.isPending ? null : () => _submit(state),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                switch (state) {
                  AuthState.signIn => const Text('Sign in'),
                  AuthState.signUp => const Text('Create account'),
                },
                if (submitMutation.isPending) ...[
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
            onPressed:
                submitMutation.isPending ? null : notifier.toggleAuthState,
            child: switch (state) {
              AuthState.signIn => const Text('Create account with email'),
              AuthState.signUp => const Text('Sign in instead'),
            },
          ),
          gapH24,
          const OrDivider(),
          gapH16,
          OutlinedButton.icon(
            onPressed: submitMutation.isPending
                ? null
                : () => context.go(Routes.onboardingScreen.path),
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Continue with phone'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          gapH48,
        ],
      ),
    );
  }
}
