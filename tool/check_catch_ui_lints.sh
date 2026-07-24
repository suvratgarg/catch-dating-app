#!/usr/bin/env bash
set -euo pipefail

probe_root="tool/catch_ui_lints_probe"
probe_path="$probe_root/lib/events/presentation/widgets/event_detail_lint_probe.dart"
probe_output=""
probe_status=0
dart_bin="${DART_BIN:-dart}"
generated_probe_path="packages/catch_ui_lints/probes/catch_ui_lint_probes.dart"
generated_expectations_path="tool/design/generated/enforcement_expectations.json"

node tool/design/build_lint_enforcement_tables.mjs --check

cleanup() {
  rm -rf "$probe_root"
}
trap cleanup EXIT
trap 'cleanup; exit 130' HUP INT TERM

run_analyze_probe() {
  local name="$1"

  cleanup
  mkdir -p "$(dirname "$probe_path")"
  cat >"$probe_path"

  set +e
  probe_output="$("$dart_bin" analyze "$probe_path" 2>&1)"
  probe_status=$?
  set -e

  if [[ -z "$probe_output" ]]; then
    echo "Catch UI lint probe '$name' produced no analyzer output." >&2
    exit 1
  fi
  if [[ "$probe_output" == *"An error occurred while executing an analyzer plugin"* ]]; then
    echo "Catch UI lint probe '$name' could not load the analyzer plugin." >&2
    echo "$probe_output" >&2
    exit 1
  fi
}

count_code() {
  local code="$1"
  awk -v code="$code" '
    {
      line = $0
      while ((at = index(line, code)) > 0) {
        count += 1
        line = substr(line, at + length(code))
      }
    }
    END { print count + 0 }
  ' <<<"$probe_output"
}

expect_code_count() {
  local name="$1"
  local code="$2"
  local minimum="$3"
  local actual
  actual="$(count_code "$code")"

  if (( actual < minimum )); then
    echo "Catch UI lint probe '$name' emitted $actual $code diagnostics; expected at least $minimum." >&2
    echo "$probe_output" >&2
    exit 1
  fi
}

run_analyze_probe "seeded violation corpus" <<'DART'
import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart' as spacing;
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// sizing:allow: seeded allow debt

const double _probeCardHeight = 120;
const _probeScreenPadding = EdgeInsets.fromLTRB(
  CatchSpacing.screenPx,
  CatchSpacing.s4,
  CatchSpacing.screenPx,
  CatchSpacing.s6,
);

abstract final class Sizes {
  static const double p12 = 12;
}

final eventRepositoryProvider = Provider<int>((ref) => 1);
final eventAsyncProvider = FutureProvider<int>((ref) async => 1);

class CatchUiLintProbe extends StatelessWidget {
  const CatchUiLintProbe({super.key});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.getFont('Roboto');
    final rawVoice = CatchFonts.voice(fontSize: 16, height: 1.2);
    return Column(
      children: [
        const _ProbeSection(),
        const SizedBox(height: 12),
        const _ProbeSection(),
        const SizedBox(height: _probeCardHeight),
        const Icon(Icons.add, size: 24),
        const SizedBox(height: CatchSpacing.s3 + 2),
        const SizedBox(height: spacing.CatchSpacing.s3 + 2),
        const SizedBox(height: Sizes.p12),
        const Padding(
          padding: EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s6,
          ),
          child: SizedBox.shrink(),
        ),
        const Chip(label: Text('raw')),
        TextButton(onPressed: null, child: const Text('raw')),
        const IconButton(onPressed: null, icon: Icon(Icons.close)),
        EventActivityBackdrop(
          visual: eventActivityVisual(ActivityKind.running),
        ),
        Image.asset('assets/branding/catch_icon.png'),
        const CircularProgressIndicator(strokeWidth: 2),
        const ColoredBox(color: Color(0xFFFF0000), child: SizedBox.shrink()),
        const ColoredBox(
          color: Color.fromARGB(255, 255, 0, 0),
          child: SizedBox.shrink(),
        ),
        const ColoredBox(
          color: Color.fromRGBO(255, 0, 0, 1),
          child: SizedBox.shrink(),
        ),
        const ColoredBox(color: Colors.red, child: SizedBox.shrink()),
        const ColoredBox(
          color: CupertinoColors.systemBlue,
          child: SizedBox.shrink(),
        ),
        const Text(
          'raw',
          style: TextStyle(
            fontFamily: 'Archivo',
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        Text('raw', style: GoogleFonts.roboto(fontSize: 18)),
        Text('raw', style: style),
        Text('raw', style: rawVoice),
        Text('raw', style: CatchTextStyles.bodyM(context)),
        Image.network('https://example.com/probe.png'),
        const Padding(
          padding: _probeScreenPadding,
          child: SizedBox.shrink(),
        ),
        CatchTopBar(
          title: 'Probe',
          actions: const [Row(children: [SizedBox.shrink()])],
        ),
        const CatchSectionList(children: [SizedBox.shrink()]),
        const CatchField.read(title: 'Outside section'),
        const Center(child: Text('Failed to load')),
        Scaffold(
          bottomNavigationBar: const NavigationBar(destinations: []),
          body: const SizedBox.shrink(),
        ),
        Opacity(opacity: 0.5, child: const SizedBox.shrink()),
        AnimatedOpacity(
          opacity: 0.5,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeIn,
          child: const SizedBox.shrink(),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth > 640
                ? const SizedBox.shrink()
                : const SizedBox.shrink();
          },
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black, blurRadius: 12),
            ],
          ),
          child: const SizedBox.shrink(),
        ),
        const CatchSurface(
          child: CatchSurface(
            child: SizedBox.shrink(),
          ),
        ),
        const CatchSection(
          child: CatchField.read(title: 'Name'),
        ),
        const CatchField(title: 'Legacy field'),
        _buildHeader(),
        const _ProviderProbe(),
      ],
    );
  }

  Widget _buildHeader() => const SizedBox.shrink();
}

class _ProviderProbe extends ConsumerWidget {
  const _ProviderProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CatchTokens tokens = CatchTokens.of(context);
    final repositoryValue = ref.watch(eventRepositoryProvider);
    final asyncValue = ref.watch(eventAsyncProvider);
    return Column(
      children: [
        Text(
          '${asyncValue.when(data: (value) => value, loading: () => 0)}'
          '$repositoryValue',
          style: CatchTextStyles.supporting(context, color: tokens.ink),
        ),
        CatchAsyncValueView<int>(
          value: asyncValue,
          builder: (_, value) => Text('$value'),
        ),
        const CatchErrorState(title: 'Unavailable', message: 'Try elsewhere.'),
      ],
    );
  }
}

class _ProbeSection extends StatelessWidget {
  const _ProbeSection();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
DART

if [[ $probe_status -eq 0 ]]; then
  echo "Catch UI lint violation probe unexpectedly passed for warning-stage rules." >&2
  echo "$probe_output" >&2
  exit 1
fi

expect_code_count "seeded violation corpus" "catch_no_raw_ui_spacing" 1
expect_code_count "seeded violation corpus" "catch_use_section_list" 1
expect_code_count "seeded violation corpus" "catch_no_token_arithmetic" 1
expect_code_count "seeded violation corpus" "catch_prefer_semantic_insets" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_event_detail_prefers_photo_thumbnail" \
  1
expect_code_count "seeded violation corpus" "catch_no_raw_material_control" 1
expect_code_count "seeded violation corpus" "catch_no_raw_button_control" 1
expect_code_count "seeded violation corpus" "catch_no_widget_returning_method" 1
expect_code_count "seeded violation corpus" "catch_no_raw_color" 5
expect_code_count "seeded violation corpus" "catch_no_raw_text_style" 1
expect_code_count "seeded violation corpus" "catch_no_raw_font_drift" 3
expect_code_count "seeded violation corpus" "catch_no_direct_font_builder" 1
expect_code_count "seeded violation corpus" "catch_no_raw_letter_spacing" 1
expect_code_count "seeded violation corpus" "catch_no_raw_radius" 1
expect_code_count "seeded violation corpus" "catch_no_raw_content_dimension" 1
expect_code_count "seeded violation corpus" "catch_no_local_design_constant" 1
expect_code_count "seeded violation corpus" "catch_no_raw_icon_source" 1
expect_code_count "seeded violation corpus" "catch_no_raw_icon_size" 1
expect_code_count "seeded violation corpus" "catch_no_raw_alpha" 1
expect_code_count "seeded violation corpus" "catch_no_raw_shadow" 1
expect_code_count "seeded violation corpus" "catch_no_raw_motion" 1
expect_code_count "seeded violation corpus" "catch_no_raw_breakpoint" 1
expect_code_count "seeded violation corpus" "catch_no_raw_surface_shell" 1
expect_code_count "seeded violation corpus" "catch_no_raw_stroke_width" 2
expect_code_count "seeded violation corpus" "catch_no_raw_asset_path" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_no_nested_rounded_rectangles" \
  1
expect_code_count \
  "seeded violation corpus" \
  "catch_icon_button_requires_tooltip" \
  1
expect_code_count "seeded violation corpus" "catch_no_allow_debt" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_use_named_catch_field_constructor" \
  1
expect_code_count \
  "seeded violation corpus" \
  "catch_use_named_catch_section_constructor" \
  1
expect_code_count "seeded violation corpus" "catch_no_raw_network_image" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_no_presentation_platform_import" \
  1
expect_code_count "seeded violation corpus" "catch_no_tokens_prop_drilling" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_no_presentation_repository_reach" \
  1
expect_code_count "seeded violation corpus" "catch_no_legacy_spacing_token" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_no_low_level_typography_role" \
  1
expect_code_count \
  "seeded violation corpus" \
  "catch_screen_gutter_uses_semantic_insets" \
  1
expect_code_count "seeded violation corpus" "catch_text_requires_style" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_top_bar_requires_action_group" \
  1
expect_code_count "seeded violation corpus" "catch_shell_owns_tab_scaffold" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_field_requires_section_context" \
  1
expect_code_count \
  "seeded violation corpus" \
  "catch_section_list_requires_empty_policy" \
  1
expect_code_count \
  "seeded violation corpus" \
  "catch_async_requires_state_surface" \
  1
expect_code_count \
  "seeded violation corpus" \
  "catch_async_requires_retry" \
  1
expect_code_count \
  "seeded violation corpus" \
  "catch_error_state_requires_action" \
  1
expect_code_count "seeded violation corpus" "catch_no_raw_error_surface" 1
expect_code_count \
  "seeded violation corpus" \
  "catch_no_shell_local_measurement" \
  1

run_analyze_probe "generated steering corpus" <"$generated_probe_path"
while IFS=$'\t' read -r code minimum; do
  expect_code_count "generated steering corpus" "$code" "$minimum"
done < <(
  node -e '
    const expectations = require(`./tool/design/generated/enforcement_expectations.json`);
    for (const [code, minimum] of Object.entries(expectations.generatedProbeMinimums)) {
      process.stdout.write(`${code}\t${minimum}\n`);
    }
  '
)

run_analyze_probe "transparent and token-backed clean cases" <<'DART'
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchUiLintProbe extends StatelessWidget {
  const CatchUiLintProbe({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ColoredBox(color: Colors.transparent, child: SizedBox.shrink()),
        ColoredBox(color: Color(0x00000000), child: SizedBox.shrink()),
        Padding(
          padding: CatchInsets.pageBody,
          child: SizedBox.shrink(),
        ),
        CatchSurface.tinted(child: SizedBox.shrink()),
      ],
    );
  }
}
DART

if [[ $probe_status -ne 0 || "$probe_output" == *"catch_"* ]]; then
  echo "Catch UI lint clean probe emitted an unexpected diagnostic." >&2
  echo "$probe_output" >&2
  exit 1
fi

run_analyze_probe "mutation pending per-mutation violation" <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailMutationProbeController {
  static final saveMutation = Mutation<void>();
  static final deleteMutation = Mutation<void>();
}

class CatchUiMutationProbe extends ConsumerWidget {
  const CatchUiMutationProbe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveMutation = ref.watch(
      EventDetailMutationProbeController.saveMutation,
    );
    final deleteMutation = ref.watch(
      EventDetailMutationProbeController.deleteMutation,
    );
    final saveFailed = saveMutation.hasError;
    return Text(deleteMutation.isPending || saveFailed ? 'Busy' : 'Ready');
  }
}
DART

expect_code_count \
  "mutation pending per-mutation violation" \
  "catch_mutation_pending_requires_error" \
  1

run_analyze_probe "mutation pending per-mutation clean case" <<'DART'
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailMutationProbeController {
  static final saveMutation = Mutation<void>();
  static final deleteMutation = Mutation<void>();
}

class CatchUiMutationProbe extends ConsumerWidget {
  const CatchUiMutationProbe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveMutation = ref.watch(
      EventDetailMutationProbeController.saveMutation,
    );
    final deleteMutation = ref.watch(
      EventDetailMutationProbeController.deleteMutation,
    );
    if (saveMutation.hasError) {
      return Text('Failed', style: CatchTextStyles.supporting(context));
    }
    return CatchMutationErrorListener(
      mutation: EventDetailMutationProbeController.deleteMutation,
      child: Text(
        deleteMutation.isPending ? 'Deleting' : 'Ready',
        style: CatchTextStyles.supporting(context),
      ),
    );
  }
}
DART

if [[ $probe_status -ne 0 || "$probe_output" == *"catch_"* ]]; then
  echo "Catch UI lint mutation per-mutation clean probe emitted an unexpected diagnostic." >&2
  echo "$probe_output" >&2
  exit 1
fi

probe_path="$probe_root/test/catch_ui_test_lint_probe_test.dart"
run_analyze_probe "test reliability seeded violations" <<'DART'
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  testWidgets('seed test reliability diagnostics', (tester) async {
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Save'), warnIfMissed: false);
    find.text('Save').first;
    await Future<void>.delayed(Duration.zero);
  });
}
DART

expect_code_count \
  "test reliability seeded violations" \
  "catch_no_brittle_pump_timing" \
  3
expect_code_count \
  "test reliability seeded violations" \
  "catch_no_positional_widget_finder" \
  1
expect_code_count \
  "test reliability seeded violations" \
  "catch_no_async_flush_hack" \
  1
