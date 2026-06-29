#!/usr/bin/env python3
"""Architecture-level audit scanner for the Catch codebase.

Detects:
  1. async_state handling — classifies every .when() / switch into:
     a) should-use-wrapper (same Scaffold in all states → use CatchAsyncValueView)
     b) legitimate-when (different structure per state — slivers, etc.)
     c) missing-error-handling (loading+data but no error callback)
  2. Repository method consistency (withBackendErrorContext usage)
  3. Controller/mutation patterns
  4. Widget structural overlap (hashed by core primitives to avoid O(n²))
"""

import json
import re
from collections import defaultdict, Counter
from pathlib import Path
from typing import Optional

REPO_ROOT = Path(__file__).resolve().parent.parent
LIB_DIR = REPO_ROOT / "lib"

EXCLUDE = [
    r'\.g\.dart$', r'\.freezed\.dart$', r'\.config\.dart$',
    r'/test/', r'/labs/',
]

def should_exclude(filepath: str) -> bool:
    return any(re.search(p, filepath) for p in EXCLUDE)

def extract_braced(content: str, start: int) -> str:
    """Extract content between matching braces from start position."""
    depth = 1
    for i in range(start + 1, len(content)):
        if content[i] == '{': depth += 1
        elif content[i] == '}':
            depth -= 1
            if depth == 0:
                return content[start:i+1]

def extract_class_body(content: str, class_name: str) -> Optional[str]:
    m = re.search(rf'class\s+{re.escape(class_name)}\s+extends', content)
    if not m: return None
    brace = content.find('{', m.start())
    if brace == -1: return None
    return extract_braced(content, brace)

def classify_async_handling(body: str) -> dict:
    """Classify how this widget handles async state."""
    result = {
        'uses_when': False,
        'uses_switch': False,
        'uses_catch_async_value_view': False,
        'has_loading': False,
        'has_error': False,
        'has_data': False,
        'classification': 'no-async',  # no-async, should-use-wrapper, legitimate-when, missing-error
    }

    # Check for CatchAsyncValueView usage (correct pattern)
    if re.search(r'CatchAsyncValue(View|Sliver)', body):
        result['uses_catch_async_value_view'] = True
        result['classification'] = 'uses-wrapper'
        return result

    # Find .when() calls
    when_match = re.search(r'\.when\s*\(', body)
    # Match switch on async values: switch(x) where body contains Async cases
    switch_match = re.search(
        r'switch\s*\(\s*(\w+)\s*\)\s*{', body
    )
    is_async_switch = switch_match and (
        'AsyncLoading' in body or 'AsyncData' in body or 'AsyncError' in body
    )

    if not when_match and not is_async_switch:
        return result

    if when_match:
        result['uses_when'] = True
        when_body = extract_braced(body, body.index('(', when_match.start()))
    elif is_async_switch:
        result['uses_switch'] = True
        when_body = extract_braced(body, body.index('{', switch_match.end()))

    if not when_body:
        return result

    # Check which callbacks/branches exist (.when syntax: "loading:", switch syntax: "AsyncLoading()")
    result['has_loading'] = bool(re.search(r'(loading\s*:|AsyncLoading\s*\()', when_body))
    result['has_error'] = bool(re.search(r'(error\s*:|AsyncError\s*\()', when_body))
    result['has_data'] = bool(re.search(r'(data\s*:|AsyncData\s*\()', when_body))

    # Classify
    if result['has_data'] and not result['has_error']:
        result['classification'] = 'missing-error'
    elif result['has_loading'] and result['has_data']:
        # Check if states share same outer shell or are structurally different
        has_scaffold_outside = 'Scaffold(' in body and body.index('Scaffold(') < when_match.start()
        has_same_shell = has_scaffold_outside
        if has_same_shell:
            result['classification'] = 'should-use-wrapper'
        else:
            result['classification'] = 'legitimate-when'
    elif result['has_error']:
        result['classification'] = 'legitimate-when'

    return result

def structural_hash(body: str) -> str:
    used = sorted(w for w in {
        'CatchField', 'CatchSection', 'CatchSectionList', 'CatchSurface',
        'CatchButton', 'CatchChip', 'CatchChipField', 'CatchSkeleton',
        'CatchTopBar', 'CatchCoverStory', 'CatchSearchField', 'CatchEmptyState',
        'CatchErrorState', 'CatchSliverErrorState', 'CatchInlineErrorState',
        'CatchRangeSlider', 'CatchPersonRow', 'CatchPolaroid', 'CatchToggle',
        'CatchBadge', 'CatchCountPill', 'CatchNetworkImage', 'CatchGradedImage',
        'CatchNotice', 'CatchBottomSheet', 'CatchIconButton', 'CatchTextButton',
        'CatchOptionGroup', 'CatchPageBody', 'CatchScreenBody', 'CatchTabDock',
    } if w in body)
    return '|'.join(used)

def scan_file(filepath: Path, content: str = None) -> dict:
    relpath = str(filepath.relative_to(REPO_ROOT))
    if content is None:
        content = filepath.read_text()

    result = {'file': relpath, 'screens': [], 'repositories': [], 'controllers': []}

    for m in re.finditer(r'class\s+(\w+)\s+extends\s+(ConsumerWidget|ConsumerStatefulWidget|StatefulWidget)', content):
        name = m.group(1)
        widget_type = m.group(2)
        body = extract_class_body(content, name)
        if not body: continue

        async_info = classify_async_handling(body)

        # Check if this is a route-level screen (imports go_router or is in a screen file)
        is_route_screen = '_screen' in relpath.lower() or 'Routes.' in body or 'GoRoute' in body

        result['screens'].append({
            'name': name,
            'type': widget_type,
            'is_route_screen': is_route_screen,
            'async': async_info,
            'structural_hash': structural_hash(body),
        })

    # Repositories
    for m in re.finditer(r'class\s+(\w+Repository)\s', content):
        name = m.group(1)
        body = extract_class_body(content, name)
        if not body: continue
        result['repositories'].append({
            'name': name,
            'uses_backend_error': 'withBackendError' in body,
            'uses_raw_try_catch': bool(re.search(r'try\s*{', body)),
            'method_count': len(re.findall(r'(Future|Stream)<\w+>\s+(\w+)\(', body)),
        })

    # Controllers
    for m in re.finditer(r'class\s+(\w+Controller|\w+Notifier)\s', content):
        name = m.group(1)
        body = extract_class_body(content, name)
        if not body: continue
        result['controllers'].append({
            'name': name,
            'uses_mutation': 'Mutation' in body,
            'uses_try_catch': bool(re.search(r'try\s*{', body)),
            'uses_catch_error': '.catchError(' in body,
        })

    return result

def main():
    all_results = []
    classifications = Counter()
    missing_error = []
    should_use_wrapper = []
    legit_when = []
    repos_no_error = []
    controllers_raw_trycatch = []

    for f in sorted(LIB_DIR.rglob('*.dart')):
        if should_exclude(str(f)): continue
        r = scan_file(f)
        if not (r['screens'] or r['repositories'] or r['controllers']): continue
        all_results.append(r)

        for s in r['screens']:
            cls = s['async']['classification']
            classifications[cls] += 1
            if cls == 'missing-error':
                missing_error.append({'file': r['file'], 'name': s['name']})
            elif cls == 'should-use-wrapper':
                should_use_wrapper.append({'file': r['file'], 'name': s['name']})

        for repo in r['repositories']:
            if not repo['uses_backend_error']:
                repos_no_error.append({'file': r['file'], 'name': repo['name']})

        for ctrl in r['controllers']:
            if ctrl['uses_try_catch']:
                controllers_raw_trycatch.append({'file': r['file'], 'name': ctrl['name']})

    report = {
        'summary': {
            'total_screens': sum(classifications.values()),
            'classification': dict(classifications.most_common()),
            'missing_error_handling': len(missing_error),
            'should_use_wrapper': len(should_use_wrapper),
            'legitimate_when_or_switch': classifications.get('legitimate-when', 0),
            'repos_missing_backend_error': len(repos_no_error),
            'controllers_with_raw_try_catch': len(controllers_raw_trycatch),
        },
        'should_use_wrapper': should_use_wrapper,
        'missing_error_handling': missing_error,
        'repos_missing_backend_error': repos_no_error,
        'controllers_raw_try_catch': controllers_raw_trycatch,
    }

    out = REPO_ROOT / 'docs' / 'audit_registry' / 'architecture_scan.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, 'w') as fp:
        json.dump(report, fp, indent=2)

    print(f"Screens: {report['summary']['total_screens']}")
    print(f"  no-async: {classifications.get('no-async', 0)}")
    print(f"  uses-wrapper (correct): {classifications.get('uses-wrapper', 0)}")
    print(f"  legitimate-when: {report['summary']['legitimate_when_or_switch']}")
    print(f"  should-use-wrapper: {report['summary']['should_use_wrapper']}")
    print(f"  missing-error: {report['summary']['missing_error_handling']}")
    print(f"Repos missing backend error: {report['summary']['repos_missing_backend_error']}")
    print(f"Controllers with raw try/catch: {report['summary']['controllers_with_raw_try_catch']}")
    print(f"Report: {out}")

if __name__ == '__main__':
    main()
