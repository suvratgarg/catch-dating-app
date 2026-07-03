// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter_test/flutter_test.dart';

import '../../tool/lib/audit_registry_gap_classifier.dart';

void main() {
  group('classifyScreenGapAction', () {
    test('treats visual parity-only copy work as reference-only', () {
      expect(
        classifyScreenGapAction(
          'Deterministic captures now cover loading and failures. '
          'Focused widget tests now prove feedback. '
          'Advisory comparison is wired and currently above threshold; '
          'remaining work is visual parity for top chrome/insight copy/profile '
          'sections.',
        ),
        'reference-only',
      );
    });

    test('keeps reference tasks with concrete implementation work mixed', () {
      expect(
        classifyScreenGapAction(
          'Continue reference-specific variants and the fuller route-state '
          'adapter.',
        ),
        'mixed',
      );
    });

    test('treats conditional route capture work as reference-only', () {
      expect(
        classifyScreenGapAction(
          'Deterministic route captures now cover loading, edit tab, preview '
          'tab, upload pending, upload failure, text scale, reduced motion, '
          'and paired light/dark. Remaining work is delete/reorder route '
          'captures if visually distinct and advisory pixel comparison.',
        ),
        'reference-only',
      );
    });

    test('treats state-specific design references as reference-only', () {
      expect(
        classifyScreenGapAction(
          'Auth Widgetbook and deterministic captures now cover phone entry, '
          'OTP cooldown, validation error, country picker, send/verify/resend '
          'pending and failure, text scale, reduced motion, and light/dark. '
          'Remaining work is state-specific design references.',
        ),
        'reference-only',
      );
    });

    test('keeps copy decisions without reference signals engineering', () {
      expect(
        classifyScreenGapAction(
          'Define whether offline-specific copy should diverge from the '
          'generic branded event error surface.',
        ),
        'engineering',
      );
    });

    test('treats canonical-source-blocked interaction variants as reference-only', () {
      expect(
        classifyScreenGapAction(
          'Primary onboarding step references are exported and manifest-registered. '
          'Continue only interaction-specific references and masks for keyboard, '
          'date picker, photo picker/upload, prompt picker/copy variants, mutation '
          'feedback, accessibility, and theme variants when canonical sources exist.',
        ),
        'reference-only',
      );
    });

    test('treats explicit blocked reference-only gaps as reference-only', () {
      expect(
        classifyScreenGapAction(
          'Blocked/reference-only until a canonical interaction source exists: '
          'primary onboarding step references are exported and manifest-registered. '
          'Remaining references and masks are interaction-specific keyboard, date '
          'picker, photo picker/upload, prompt picker/copy variants, mutation '
          'feedback, accessibility, and theme variants.',
        ),
        'reference-only',
      );
    });
  });
}
