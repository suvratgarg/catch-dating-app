#!/usr/bin/env bash
set -euo pipefail

probe_root="tool/catch_ui_lints_probe"
probe_path="$probe_root/lib/events/presentation/widgets/event_detail_lint_probe.dart"
probe_output=""
probe_status=0

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
  probe_output="$(dart analyze "$probe_path" 2>&1)"
  probe_status=$?
  set -e

  if [[ -z "$probe_output" ]]; then
    echo "Catch UI lint probe '$name' produced no analyzer output." >&2
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
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// sizing:allow: seeded allow debt

const double _probeCardHeight = 120;

class CatchUiLintProbe extends StatelessWidget {
  const CatchUiLintProbe({super.key});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.getFont('Roboto');
    return Column(
      children: [
        const _ProbeSection(),
        const SizedBox(height: 12),
        const _ProbeSection(),
        const SizedBox(height: _probeCardHeight),
        const Icon(Icons.add, size: 24),
        const SizedBox(height: CatchSpacing.s3 + 2),
        const SizedBox(height: spacing.CatchSpacing.s3 + 2),
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
          style: TextStyle(fontFamily: 'Archivo', fontSize: 18),
        ),
        Text('raw', style: GoogleFonts.roboto(fontSize: 18)),
        Text('raw', style: style),
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
      ],
    );
  }

  Widget _buildHeader() => const SizedBox.shrink();
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

run_analyze_probe "transparent and token-backed clean cases" <<'DART'
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

const _probeSemanticBodyPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s4,
  CatchSpacing.s5,
  CatchSpacing.s6,
);

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
        Padding(
          padding: _probeSemanticBodyPadding,
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
    if (saveMutation.hasError) return const Text('Failed');
    return CatchMutationErrorListener(
      mutation: EventDetailMutationProbeController.deleteMutation,
      child: Text(deleteMutation.isPending ? 'Deleting' : 'Ready'),
    );
  }
}
DART

if [[ $probe_status -ne 0 || "$probe_output" == *"catch_"* ]]; then
  echo "Catch UI lint mutation per-mutation clean probe emitted an unexpected diagnostic." >&2
  echo "$probe_output" >&2
  exit 1
fi
