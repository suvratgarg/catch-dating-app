import 'package:catch_dating_app/commonWidgets/app_form_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_dating_app/auth/presentation/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.authState});

  final AuthState authState;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  static const _fieldSpacing = 16.0;
  static const _buttonTopSpacing = 24.0;

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AppFormLayout(
        formKey: _formKey,
        children: [
          Text(
            'Catch',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            switch (state) {
              AuthState.signIn => 'Welcome back',
              AuthState.signUp => 'Create your account',
            },
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
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
          const SizedBox(height: _fieldSpacing),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (submitMutation as MutationError).error.toString(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: _buttonTopSpacing),
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
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: submitMutation.isPending
                ? null
                : notifier.toggleAuthState,
            child: switch (state) {
              AuthState.signIn => const Text('Create account'),
              AuthState.signUp => const Text('Sign in'),
            },
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'STYLE SAMPLES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 32),
          const _StyleShowcase(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ─── Style Showcase ──────────────────────────────────────────────────────────

enum _MockState { idle, loading, error }

class _StyleShowcase extends StatefulWidget {
  const _StyleShowcase();

  @override
  State<_StyleShowcase> createState() => _StyleShowcaseState();
}

class _StyleShowcaseState extends State<_StyleShowcase> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _states = List<_MockState>.filled(4, _MockState.idle, growable: false);
  final _tapCounts = List<int>.filled(4, 0, growable: false);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _simulate(int i) async {
    if (_states[i] == _MockState.loading) return;
    setState(() => _states[i] = _MockState.loading);
    await Future.delayed(const Duration(milliseconds: 1500));
    _tapCounts[i]++;
    setState(
      () =>
          _states[i] = _tapCounts[i].isOdd ? _MockState.error : _MockState.idle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('A — Soft Pill'),
        const SizedBox(height: 16),
        _buildSoftPill(context),
        const SizedBox(height: 40),
        _sectionLabel('B — Minimal'),
        const SizedBox(height: 16),
        _buildMinimal(context),
        const SizedBox(height: 40),
        _sectionLabel('C — Sharp'),
        const SizedBox(height: 16),
        _buildSharp(context),
        const SizedBox(height: 40),
        _sectionLabel('D — Elevated'),
        const SizedBox(height: 16),
        _buildElevated(context),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: Colors.grey.shade400,
    ),
  );

  // ── A: Soft Pill ────────────────────────────────────────────────────────────

  Widget _buildSoftPill(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = _states[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controllers[0],
          decoration: InputDecoration(
            hintText: 'Email address',
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
        if (s == _MockState.error) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 13, color: cs.error),
                const SizedBox(width: 5),
                Text(
                  'This email isn\'t linked to an account.',
                  style: tt.labelSmall?.copyWith(color: cs.error),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: s == _MockState.loading ? null : () => _simulate(0),
          style: FilledButton.styleFrom(
            shape: const StadiumBorder(),
            minimumSize: const Size(double.infinity, 52),
          ),
          child: s == _MockState.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Continue'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: s == _MockState.loading ? null : () {},
          style: FilledButton.styleFrom(
            shape: const StadiumBorder(),
            minimumSize: const Size(double.infinity, 52),
          ),
          child: const Text('Create account'),
        ),
      ],
    );
  }

  // ── B: Minimal ──────────────────────────────────────────────────────────────

  Widget _buildMinimal(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = _states[1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controllers[1],
          decoration: InputDecoration(
            hintText: 'your@email.com',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: s == _MockState.error ? cs.error : Colors.grey.shade300,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          style: tt.bodyLarge,
        ),
        if (s == _MockState.error) ...[
          const SizedBox(height: 6),
          Text(
            'We couldn\'t find that account.',
            style: tt.bodySmall?.copyWith(
              color: cs.error,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 24),
        GestureDetector(
          onTap: s == _MockState.loading ? null : () => _simulate(1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s == _MockState.loading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Signing in...',
                  style: tt.bodyLarge?.copyWith(color: cs.primary),
                ),
              ] else ...[
                Text(
                  'Sign in',
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: s == _MockState.loading ? null : () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            foregroundColor: Colors.grey.shade500,
          ),
          child: const Text('Create account instead'),
        ),
      ],
    );
  }

  // ── C: Sharp ────────────────────────────────────────────────────────────────

  Widget _buildSharp(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = _states[2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controllers[2],
          decoration: InputDecoration(
            hintText: 'EMAIL ADDRESS',
            hintStyle: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              color: Colors.grey.shade400,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: s == _MockState.error ? cs.error : Colors.black,
                width: 1.5,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.black, width: 2.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(letterSpacing: 0.5, fontSize: 14),
        ),
        if (s == _MockState.error) ...[
          Container(
            color: cs.error.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'INVALID CREDENTIALS — TRY AGAIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.error,
              ),
            ),
          ),
        ],
        const SizedBox(height: 2),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: s == _MockState.loading ? null : () => _simulate(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade800,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 0,
            ),
            child: s == _MockState.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'SIGN IN',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: s == _MockState.loading ? null : () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: const BorderSide(color: Colors.black, width: 1.5),
            ),
            child: const Text(
              'CREATE ACCOUNT',
              style: TextStyle(
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── D: Elevated ─────────────────────────────────────────────────────────────

  Widget _buildElevated(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = _states[3];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controllers[3],
            decoration: InputDecoration(
              hintText: 'Email address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: s == _MockState.loading
                ? cs.primary.withValues(alpha: 0.7)
                : cs.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: s == _MockState.loading
                ? []
                : [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: s == _MockState.loading ? null : () => _simulate(3),
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: s == _MockState.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: s == _MockState.loading ? null : () {},
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  'Create account',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        if (s == _MockState.error) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: cs.error, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unable to sign in. Please check your credentials.',
                    style: tt.labelSmall?.copyWith(color: cs.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
