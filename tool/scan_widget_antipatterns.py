#!/usr/bin/env python3
"""Scan the codebase for widget-returning functions and private widget classes.

Identifies anti-patterns per Catch's widget architecture rules:
  1. Functions/methods that return Widget (not build() overrides)
  2. Private widget classes (class _Xxx extends ...Widget)

For each finding, checks if a canonical core primitive already handles the
pattern, and classifies it for mechanical migration vs. judgment-needed.
"""

import json
import os
import re
import sys
from collections import defaultdict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
LIB_DIR = REPO_ROOT / "lib"
CORE_WIDGETS_DIR = LIB_DIR / "core" / "widgets"

# ── Core primitive registry ───────────────────────────────────────────────────
# Maps pattern keywords → known canonical primitives.
# When a widget function's name or body matches a keyword, we check if the
# core primitive should replace it.

CORE_PRIMITIVES = {
    # Widget name → file
    "CatchField": "catch_field.dart",
    "CatchField.nav": "catch_field.dart",
    "CatchField.action": "catch_field.dart",
    "CatchField.read": "catch_field.dart",
    "CatchField.input": "catch_field.dart",
    "CatchField.inputActions": "catch_field.dart",
    "CatchField.control": "catch_field.dart",
    "CatchField.choices": "catch_field.dart",
    "CatchField.stepper": "catch_field.dart",
    "CatchField.actions": "catch_field.dart",
    "CatchField.select": "catch_field.dart",
    "CatchField.toggle": "catch_field.dart",
    "CatchField.add": "catch_field.dart",
    "CatchSection": "catch_section_layout.dart",
    "CatchSection.divided": "catch_section_layout.dart",
    "CatchSection.contained": "catch_section_layout.dart",
    "CatchSectionList": "catch_section_layout.dart",
    "CatchSurface": "catch_surface.dart",
    "CatchSkeleton": "catch_skeleton.dart",
    "CatchButton": "catch_button.dart",
    "CatchChip": "catch_chip.dart",
    "CatchChipField": "catch_chip_field.dart",
    "CatchTopBar": "catch_top_bar.dart",
    "CatchCoverStory": "catch_cover_story.dart",
    "CatchSearchField": "catch_search_field.dart",
    "CatchEmptyState": "catch_empty_state.dart",
    "CatchErrorState": "catch_error_state.dart",
    "CatchRangeSlider": "catch_range_slider.dart",
    "CatchPersonRow": "catch_person_row.dart",
    "CatchPolaroid": "catch_polaroid.dart",
}

# Pattern keywords → likely core primitive match.
# When a function name/body contains these keywords, we flag it as potentially
# duplicating the given core primitive.
PATTERN_MATCHERS = [
    # (name_regex, body_keywords, core_primitive, confidence)
    (r'nav|tile|row.*display|label.*row', ['CatchField.nav', 'CatchField.read'], 'CatchField.nav/CatchField.read', 'medium'),
    (r'input|text.*(field|entry|edit)', ['TextField', 'TextEditingController'], 'CatchField.input', 'high'),
    (r'expand|collapse|disclosure|drawer', ['AnimatedSize', 'AnimatedSwitcher'], 'CatchField.control/CatchField.inputActions', 'high'),
    (r'chip|select|choice|picker', ['CatchChip', 'Wrap', 'CatchSelectChip'], 'CatchChipField', 'medium'),
    (r'search.*morph|search.*animat', ['AnimationController', 'TweenAnimationBuilder'], 'CatchTopBar (search)', 'high'),
    (r'skeleton|loading.*placeholder|shimmer', ['CatchSkeleton'], 'CatchSkeleton', 'high'),
    (r'empty.*state|nothing.*found', ['CatchEmptyState'], 'CatchEmptyState', 'medium'),
    (r'error.*state|error.*view', ['CatchErrorState'], 'CatchErrorState', 'medium'),
    (r'surface|card.*surface', ['CatchSurface', 'DecoratedBox'], 'CatchSurface', 'low'),
    (r'cover.*(hero|header|story)', ['CustomPaint', 'RadialGradient'], 'CatchCoverStory', 'high'),
    (r'top.*(bar|row|band)|header.*bar', ['CatchTopBar'], 'CatchTopBar', 'medium'),
]

# Files excluded from scanning
EXCLUDE_PATTERNS = [
    r'\.g\.dart$',           # generated code
    r'\.freezed\.dart$',     # generated freezed code
    r'\.config\.dart$',      # config
    r'/_test/',              # test directory
    r'/test/',               # test directory
]

def should_exclude(filepath: str) -> bool:
    for pat in EXCLUDE_PATTERNS:
        if re.search(pat, filepath):
            return True
    return False

def is_build_override(name: str) -> bool:
    """Check if a method is a Flutter build() override."""
    return name == 'build'

def is_test_or_fixture(filepath: str) -> bool:
    return '/test/' in filepath or '/labs/' in filepath

def extract_function_body(content: str, start_pos: int, max_lines: int = 80) -> str:
    """Extract the first max_lines of a function body for pattern matching."""
    lines = content[start_pos:].split('\n')
    return '\n'.join(lines[:max_lines])

def scan_file(filepath: Path) -> dict:
    """Scan a single Dart file and return findings."""
    relpath = str(filepath.relative_to(REPO_ROOT))
    content = filepath.read_text()
    lines = content.split('\n')

    findings = {
        'file': relpath,
        'widget_functions': [],
        'private_widget_classes': [],
        'builder_methods_on_state': [],
    }

    # ── Find top-level widget-returning functions ─────────────────────────
    # Pattern: ^Widget functionName(...)  or  ^Widget _functionName(...)
    for m in re.finditer(r'^Widget\s+(_?\w+)\s*\(', content, re.MULTILINE):
        name = m.group(1)
        if is_build_override(name):
            continue
        # Get line number
        line_no = content[:m.start()].count('\n') + 1
        # Extract function signature
        sig_start = m.start()
        brace_depth = 0
        sig_end = sig_start
        in_params = True
        for i in range(m.start(), min(len(content), m.start() + 2000)):
            c = content[i]
            if c == '{' and in_params:
                in_params = False
                brace_depth += 1
            elif c == '{' and not in_params:
                brace_depth += 1
            elif c == '}' and not in_params:
                brace_depth -= 1
                if brace_depth == 0:
                    sig_end = i
                    break
            elif c == ';' and not in_params:
                sig_end = i
                break

        body = content[m.start():sig_end + 1]
        has_widgetref = 'WidgetRef' in body
        body_sample = '\n'.join(body.split('\n')[:40])

        # Check against pattern matchers
        matches = []
        for name_re, keywords, primitive, confidence in PATTERN_MATCHERS:
            if re.search(name_re, name, re.IGNORECASE):
                match_score = 1
            else:
                match_score = 0
            for kw in keywords:
                if kw in body_sample:
                    match_score += 1
            if match_score >= 1:
                matches.append({
                    'primitive': primitive,
                    'confidence': confidence,
                    'score': match_score,
                })

        findings['widget_functions'].append({
            'name': name,
            'line': line_no,
            'has_widgetref': has_widgetref,
            'is_private': name.startswith('_'),
            'body_preview': body_sample[:500],
            'core_matches': sorted(matches, key=lambda x: -x['score']),
        })

    # ── Find private widget classes ───────────────────────────────────────
    for m in re.finditer(
        r'^class\s+(_\w+)\s+extends\s+(StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget)',
        content, re.MULTILINE
    ):
        name = m.group(1)
        line_no = content[:m.start()].count('\n') + 1
        parent = m.group(2)
        findings['private_widget_classes'].append({
            'name': name,
            'line': line_no,
            'parent': parent,
        })

    # ── Find State class methods that return Widget (not build()) ─────────
    # Look inside classes that extend State<...>
    for class_m in re.finditer(
        r'class\s+(\w+)\s+extends\s+State<',
        content
    ):
        class_name = class_m.group(1)
        # Find the class body
        brace_start = content.find('{', class_m.start())
        if brace_start == -1:
            continue
        depth = 0
        brace_end = brace_start
        for i in range(brace_start, len(content)):
            if content[i] == '{':
                depth += 1
            elif content[i] == '}':
                depth -= 1
                if depth == 0:
                    brace_end = i
                    break
        class_body = content[brace_start:brace_end]

        # Find methods returning Widget
        for m in re.finditer(r'^\s+Widget\s+(_?\w+)\s*\(', class_body, re.MULTILINE):
            name = m.group(1)
            if is_build_override(name):
                continue
            line_no = content[:brace_start + m.start()].count('\n') + 1
            findings['builder_methods_on_state'].append({
                'class': class_name,
                'name': name,
                'line': line_no,
                'is_private': name.startswith('_'),
            })

    return findings

def main():
    all_findings = []
    stats = defaultdict(int)

    for dart_file in sorted(LIB_DIR.rglob('*.dart')):
        if should_exclude(str(dart_file)):
            continue
        findings = scan_file(dart_file)
        if findings['widget_functions'] or findings['private_widget_classes'] or findings['builder_methods_on_state']:
            all_findings.append(findings)
            stats['files_scanned'] += 1
            stats['widget_functions'] += len(findings['widget_functions'])
            stats['private_widget_classes'] += len(findings['private_widget_classes'])
            stats['builder_methods_on_state'] += len(findings['builder_methods_on_state'])

    # ── Output report ─────────────────────────────────────────────────────
    report = {
        'summary': dict(stats),
        'findings': all_findings,
        'migration_ready': [],    # can be mechanically converted
        'needs_judgment': [],     # needs feature-level context
    }

    # Classify each finding
    for file_finding in all_findings:
        for func in file_finding['widget_functions']:
            entry = {
                'file': file_finding['file'],
                'name': func['name'],
                'line': func['line'],
                'has_widgetref': func['has_widgetref'],
            }
            if func['core_matches']:
                best = func['core_matches'][0]
                entry['suggested_primitive'] = best['primitive']
                entry['confidence'] = best['confidence']
                if best['confidence'] in ('high',):
                    entry['action'] = 'replace-with-primitive'
                else:
                    entry['action'] = 'needs-judgment'
            elif func['is_private']:
                entry['action'] = 'convert-to-class'
            else:
                entry['action'] = 'needs-judgment'

            if entry.get('action') == 'needs-judgment':
                report['needs_judgment'].append(entry)
            else:
                report['migration_ready'].append(entry)

        for cls in file_finding['private_widget_classes']:
            entry = {
                'file': file_finding['file'],
                'name': cls['name'],
                'line': cls['line'],
                'parent': cls['parent'],
                'action': 'make-public',
            }
            report['migration_ready'].append(entry)

        for method in file_finding['builder_methods_on_state']:
            entry = {
                'file': file_finding['file'],
                'class': method['class'],
                'name': method['name'],
                'line': method['line'],
                'action': 'extract-to-widget-class',
            }
            report['migration_ready'].append(entry)

    # Write JSON report
    output_path = REPO_ROOT / 'docs' / 'audit_registry' / 'widget_antipattern_scan.json'
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        json.dump(report, f, indent=2)

    # Print summary
    print(f"Scanned {stats['files_scanned']} files")
    print(f"  Widget-returning functions: {stats['widget_functions']}")
    print(f"  Private widget classes: {stats['private_widget_classes']}")
    print(f"  Builder methods on State: {stats['builder_methods_on_state']}")
    print(f"  Migration-ready: {len(report['migration_ready'])}")
    print(f"  Needs judgment: {len(report['needs_judgment'])}")
    print(f"Report written to: {output_path}")

if __name__ == '__main__':
    main()
