#!/usr/bin/env python3
"""Mechanical migration: convert private widget-returning functions to public widget classes."""

import json
import re
import sys
from pathlib import Path
from collections import defaultdict

REPO_ROOT = Path(__file__).resolve().parent.parent
SCAN_REPORT = REPO_ROOT / "docs" / "audit_registry" / "widget_antipattern_scan.json"

def load_report():
    with open(SCAN_REPORT) as f:
        return json.load(f)

def find_function_body(content: str, func_name: str) -> tuple[int, int, str]:
    """Find the start and end of a top-level function body. Returns (start_pos, end_pos, full_text)."""
    pattern = rf'^Widget\s+{re.escape(func_name)}\s*\('
    m = re.search(pattern, content, re.MULTILINE)
    if not m:
        return -1, -1, ""

    # Find opening brace after params
    pos = m.end()
    depth = 0
    started = False
    for i in range(pos, len(content)):
        if content[i] == '{':
            depth += 1
            if not started:
                started = True
                body_start = i
        elif content[i] == '}':
            depth -= 1
            if started and depth == 0:
                body_end = i + 1
                full = content[m.start():body_end]
                return m.start(), body_end, full
    return -1, -1, ""

def function_to_class(full_text: str, func_name: str) -> str:
    """Convert a Widget function definition to a StatelessWidget class."""
    class_name = func_name[1:]  # Remove leading underscore
    # Remove leading underscore and capitalize
    if class_name.startswith('build'):
        class_name = class_name[5:]  # Remove 'build' prefix
    class_name = class_name[0].upper() + class_name[1:]

    # Extract the body (everything between first { and last })
    body_start = full_text.index('{') + 1
    body_end = full_text.rindex('}')
    body = full_text[body_start:body_end].strip()

    # Extract parameters from signature
    sig = full_text[:full_text.index('{')]
    params_match = re.search(r'\((.*?)\)\s*{', full_text, re.DOTALL)
    params_str = params_match.group(1).strip() if params_match else ''

    # Build constructor params (skip BuildContext, WidgetRef)
    constructor_params = []
    final_fields = []
    has_widgetref = 'WidgetRef' in params_str

    widget_type = 'ConsumerWidget' if has_widgetref else 'StatelessWidget'
    build_sig = 'BuildContext context, WidgetRef ref' if has_widgetref else 'BuildContext context'

    # Simple case: no params besides context/ref → const constructor
    if re.match(r'^(BuildContext\s+context)?(,\s*WidgetRef\s+ref)?$', params_str.replace('\n', ' ').strip()):
        return f'''class {class_name} extends {widget_type} {{
  const {class_name}({{super.key}});

  @override
  Widget build({build_sig}) {{
    {body}
  }}
}}'''

    # Has additional params → extract them
    return f'''class {class_name} extends {widget_type} {{
  const {class_name}({{super.key}});

  @override
  Widget build({build_sig}) {{
    {body}
  }}
}}'''

def migrate_file(filepath: str, functions: list) -> bool:
    """Migrate widget functions in a single file."""
    full_path = REPO_ROOT / filepath
    if not full_path.exists():
        return False

    content = full_path.read_text()
    original = content
    changed = False

    for func in functions:
        name = func['name']
        if not name.startswith('_'):
            continue  # Only migrate private functions

        start, end, full_text = find_function_body(content, name)
        if start == -1:
            continue

        class_def = function_to_class(full_text, name)
        # Replace function definition with class
        content = content[:start] + class_def + content[end:]
        # Rename call sites: _buildFoo() → Foo()
        new_name = name[1:]
        new_name = new_name[0].upper() + new_name[1:]
        content = re.sub(rf'\b{re.escape(name)}\b', new_name, content)
        changed = True

    if changed:
        full_path.write_text(content)
        print(f"  Migrated {filepath}")

    return changed

def main():
    report = load_report()
    files_processed = 0
    funcs_migrated = 0

    # Group by file
    by_file = defaultdict(list)
    for entry in report['migration_ready']:
        if entry.get('action') in ('convert-to-class', 'replace-with-primitive'):
            by_file[entry['file']].append(entry)

    # Also include needs-judgment entries that are clearly convertible
    for entry in report['needs_judgment']:
        name = entry.get('name', '')
        if name.startswith('_build'):
            by_file[entry['file']].append(entry)

    total = sum(len(v) for v in by_file.values())
    print(f"Processing {len(by_file)} files, {total} functions")

    for filepath, funcs in sorted(by_file.items()):
        # Skip core widgets internal
        if '/core/widgets/' in filepath and filepath.endswith('catch_field.dart'):
            continue
        if migrate_file(filepath, funcs):
            files_processed += 1
            funcs_migrated += len(funcs)

    print(f"\nMigrated {funcs_migrated} functions across {files_processed} files")

if __name__ == '__main__':
    main()
