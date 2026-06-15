#!/usr/bin/env python3
"""
Deterministic Dart definition extractor.

Walks every .dart file in lib/ (excluding generated files) and extracts every
named top-level definition: classes, extensions, mixins, typedefs, enums,
top-level functions, and top-level constants.

Outputs a JSON catalog to docs/audit_registry/definition_catalog.json.

Usage:
  python3 tool/audit/definition_catalog.py extract   # Extract definitions only
  python3 tool/audit/definition_catalog.py full      # Extract + cross-reference
"""

import json
import os
import re
import hashlib
import sys
from collections import defaultdict
from datetime import datetime, timezone

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LIB_DIR = os.path.join(REPO_ROOT, "lib")
OUT_DIR = os.path.join(REPO_ROOT, "docs", "audit_registry")
CATALOG_PATH = os.path.join(OUT_DIR, "definition_catalog.json")
CANDIDATES_PATH = os.path.join(OUT_DIR, "consolidation_candidates.json")

EXCLUDE_SUFFIXES = (".g.dart", ".freezed.dart")
EXCLUDE_PATHS = ("generated_plugin_registrant.dart",)


def find_dart_files():
    """Yield absolute paths to every non-generated .dart file under lib/."""
    files = []
    for root, _dirs, filenames in os.walk(LIB_DIR):
        for fn in filenames:
            if not fn.endswith(".dart"):
                continue
            if fn.endswith(EXCLUDE_SUFFIXES):
                continue
            fpath = os.path.join(root, fn)
            if any(fpath.endswith(p) for p in EXCLUDE_PATHS):
                continue
            files.append(fpath)
    files.sort()
    return files


# ---------------------------------------------------------------------------
# Brace‑depth scanner
# ---------------------------------------------------------------------------

def _is_comment_start(line, col):
    """Check if `//` starts at `col` (not inside a string)."""
    return line[col:col+2] == "//"


def _is_block_comment_start(line, col):
    return line[col:col+2] == "/*"


def _is_block_comment_end(line, col):
    return line[col:col+2] == "*/"


class Scanner:
    """Line‑by‑line scanner that tracks brace depth, strings, and comments."""

    def __init__(self, filepath, lines):
        self.filepath = filepath
        self.lines = lines
        self.results = []  # list of dicts

    def scan(self):
        depth = 0
        in_single_string = False
        in_double_string = False
        in_triple_single = False
        in_triple_double = False
        in_block_comment = False
        # Raw string flag (r'...'  or  r"..."  or r"""...""" etc.)
        in_raw = False

        # Buffer for multi-line signatures
        buf_lines = []
        buf_start = 0
        buf_kind = None  # 'class','extension','mixin','enum','function','typedef'
        buf_name = None
        buf_col = 0

        i = 0
        while i < len(self.lines):
            line = self.lines[i]
            ln = i + 1  # 1‑based

            # --- strip trailing comment outside strings? we handle inline ---
            # We process character by character to track state accurately.

            col = 0
            n = len(line)

            # Shortcut: if we are NOT inside a string/comment and depth==0,
            # do a quick regex scan on the line.
            if (not in_single_string and not in_double_string
                    and not in_triple_single and not in_triple_double
                    and not in_block_comment and depth == 0
                    and not buf_lines):
                self._scan_top_level(line, ln)
                # Still need to count braces on this line for depth tracking.
                # Fall through to char-by-char for brace counting only.
                # Build a stripped version without string/comment content.
                stripped = self._strip_line_content(line)
                depth += stripped.count("{") - stripped.count("}")
                i += 1
                continue

            # Full char-by-char for lines inside strings/blocks or with buffer.
            while col < n:
                ch = line[col]

                # --- string tracking ---
                if in_triple_single:
                    if line[col:col+3] == "'''" and (not in_raw or True):
                        in_triple_single = False
                        in_raw = False
                        col += 3
                        continue
                    col += 1
                    continue

                if in_triple_double:
                    if line[col:col+3] == '"""' and (not in_raw or True):
                        in_triple_double = False
                        in_raw = False
                        col += 3
                        continue
                    col += 1
                    continue

                if in_single_string:
                    if ch == '\\':
                        col += 2  # skip escaped char
                        continue
                    if ch == "'":
                        in_single_string = False
                        in_raw = False
                    col += 1
                    continue

                if in_double_string:
                    if ch == '\\':
                        col += 2
                        continue
                    if ch == '"':
                        in_double_string = False
                        in_raw = False
                    col += 1
                    continue

                if in_block_comment:
                    if line[col:col+2] == "*/":
                        in_block_comment = False
                        col += 2
                        continue
                    col += 1
                    continue

                # --- check string/comment entry ---
                if line[col:col+2] == "//":
                    break  # rest of line is comment

                if line[col:col+2] == "/*":
                    in_block_comment = True
                    col += 2
                    continue

                if line[col:col+3] == "'''":
                    in_triple_single = True
                    in_raw = False
                    col += 3
                    continue

                if line[col:col+3] == '"""':
                    in_triple_double = True
                    in_raw = False
                    col += 3
                    continue

                if ch == "'":
                    in_single_string = True
                    in_raw = False
                    col += 1
                    continue

                if ch == '"':
                    in_double_string = True
                    in_raw = False
                    col += 1
                    continue

                # --- depth tracking ---
                if ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1

                col += 1

            i += 1

    def _strip_line_content(self, line):
        """Remove string literals and comments so brace counting is accurate."""
        result = []
        i = 0
        n = len(line)
        in_single = False
        in_double = False
        in_triple_single = False
        in_triple_double = False
        while i < n:
            if in_triple_single:
                if line[i:i+3] == "'''":
                    in_triple_single = False
                    i += 3
                    continue
                i += 1
                continue
            if in_triple_double:
                if line[i:i+3] == '"""':
                    in_triple_double = False
                    i += 3
                    continue
                i += 1
                continue
            if in_single:
                if line[i] == '\\':
                    i += 2
                    continue
                if line[i] == "'":
                    in_single = False
                i += 1
                continue
            if in_double:
                if line[i] == '\\':
                    i += 2
                    continue
                if line[i] == '"':
                    in_double = False
                i += 1
                continue
            if line[i:i+2] == "//":
                break
            if line[i:i+2] == "/*":
                # skip block comment
                i += 2
                while i < n - 1 and line[i:i+2] != "*/":
                    i += 1
                i += 2
                continue
            if line[i:i+3] == "'''":
                in_triple_single = True
                i += 3
                continue
            if line[i:i+3] == '"""':
                in_triple_double = True
                i += 3
                continue
            if line[i] == "'":
                in_single = True
                i += 1
                continue
            if line[i] == '"':
                in_double = True
                i += 1
                continue
            result.append(line[i])
            i += 1
        return "".join(result)

    # ------------------------------------------------------------------
    # Top‑level line scanner  (depth == 0, not in string/comment)
    # ------------------------------------------------------------------

    # Class modifiers that can appear before the `class` keyword.
    _CLASS_MODIFIER_RE = re.compile(
        r'^(?:abstract\s+|sealed\s+|base\s+|final\s+|mixin\s+|interface\s+)*class\s+(\w+)')

    _KEYWORDS = frozenset({
        "if", "for", "while", "switch", "catch", "return",
        "assert", "throw", "await", "yield", "break",
        "continue", "do", "new", "const", "var", "final",
        "abstract", "sealed", "base", "static", "operator",
        "get", "set", "factory", "super", "this",
        "else", "try", "finally", "default", "rethrow",
        "is", "as", "in", "late", "required", "void",
    })

    # Matches a type expression including nested generics like:
    #   Future<bool?>
    #   Map<String, List<int>>
    #   Provider<GoRouter>
    _TYPE_RE = re.compile(
        r'[A-Za-z_]\w*(?:\?|<\s*(?:[A-Za-z_]\w*(?:\?)?(?:\s*,\s*[A-Za-z_]\w*(?:\?)?)*)\s*>)?')

    # Matches a return-type portion: one or more _TYPE_RE tokens followed
    # by an identifier and an opening paren. Handles `Future<bool?> name(`.
    _FUNC_RE = re.compile(
        r'^((?:' + _TYPE_RE.pattern + r'\s+)+)?'  # optional return type
        r'([A-Za-z_]\w*)\s*\(')  # function name + (

    # Top‑level constant / final:  const [Type] name =   or  final [Type] name =
    _CONST_RE = re.compile(
        r'^(?:const|final)\s+'
        r'(?:' + _TYPE_RE.pattern + r'\s+)?'
        r'([A-Za-z_]\w*)\s*=')

    # Top‑level var:  var name [= ...]
    _VAR_RE = re.compile(r'^var\s+([A-Za-z_]\w*)')

    # Typed top-level variable without const/final/var:
    #   Type<...>? name =
    _TYPED_VAR_RE = re.compile(
        r'^' + _TYPE_RE.pattern + r'\s+'
        r'([a-z_]\w*)\s*=')

    def _scan_top_level(self, line, ln):
        stripped = line.strip()

        if not stripped:
            return
        # Skip annotations, imports, exports, parts, directives
        if stripped.startswith(("@", "import ", "export ", "part ", "library ")):
            return
        # Skip `//` and `/*` lines
        if stripped.startswith("//") or stripped.startswith("/*"):
            return

        # --- class (with optional modifiers) ---
        m = self._CLASS_MODIFIER_RE.match(stripped)
        if m:
            self._record(m.group(1), "class", line, ln,
                         self._class_superclass(stripped),
                         self._is_widget(stripped))
            return

        # --- extension ---
        m = re.match(r'^extension\s+(\w+)\s+on\s+', stripped)
        if m:
            self._record(m.group(1), "extension", line, ln)
            return

        # --- mixin (standalone, not class modifier) ---
        m = re.match(r'^mixin\s+(\w+)', stripped)
        if m:
            self._record(m.group(1), "mixin", line, ln)
            return

        # --- enum ---
        m = re.match(r'^enum\s+(\w+)', stripped)
        if m:
            self._record(m.group(1), "enum", line, ln)
            return

        # --- typedef ---
        m = re.match(r'^typedef\s+(\w[\w\s<>,\[\]?]*)', stripped)
        if m:
            name = m.group(1).split()[0].split("<")[0]
            self._record(name, "typedef", line, ln)
            return

        # --- top‑level constant / final / var / typed variable ---
        m = self._CONST_RE.match(stripped)
        if m:
            self._record(m.group(1), "constant", line, ln)
            return

        m = self._VAR_RE.match(stripped)
        if m:
            self._record(m.group(1), "variable", line, ln)
            return

        m = self._TYPED_VAR_RE.match(stripped)
        if m:
            self._record(m.group(1), "variable", line, ln)
            return

        # --- top‑level function (must be last — has the widest pattern) ---
        m = self._FUNC_RE.match(stripped)
        if m:
            name = m.group(2)
            if name in self._KEYWORDS:
                return
            ret = (m.group(1) or "").strip()
            # Filter: if the return type is just "return" it's control flow
            if ret == "return":
                return
            # A bare `foo(` line without a return type/body is usually a call
            # inside a top-level list/map literal, not a function declaration.
            if not ret and "{" not in stripped and "=>" not in stripped:
                return
            self._record(name, "function", line, ln, return_type=ret)
            return

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    def _record(self, name, kind, line_text, line_num,
                superclass=None, is_widget=None, return_type=None):
        sig = line_text.strip()
        # Truncate for readability
        if len(sig) > 200:
            sig = sig[:197] + "..."

        entry = {
            "name": name,
            "kind": kind,
            "file": os.path.relpath(self.filepath, REPO_ROOT),
            "line": line_num,
            "signature": sig,
        }
        if superclass is not None:
            entry["superclass"] = superclass
        if is_widget is not None:
            entry["is_widget"] = is_widget
        if return_type is not None:
            entry["return_type"] = return_type

        # Body content hash for structural fingerprinting
        entry["body_hash"] = self._body_hash(line_text)

        self.results.append(entry)

    def _class_superclass(self, line):
        m = re.search(
            r'(?:extends|implements|with)\s+(\w+(?:<\s*\w+\s*>)?)', line)
        if m:
            return m.group(1)
        return None

    def _is_widget(self, line):
        return bool(re.search(
            r'(?:extends|implements|with)\s+'
            r'(?:StatelessWidget|StatefulWidget|ConsumerWidget|'
            r'ConsumerStatefulWidget|HookWidget|HookConsumerWidget)',
            line))

    def _body_hash(self, sig):
        normalized = re.sub(r'\s+', ' ', sig.strip())
        return hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:16]


# ---------------------------------------------------------------------------
# Main extraction
# ---------------------------------------------------------------------------

def extract_all():
    """Visit every Dart file and extract definitions."""
    files = find_dart_files()
    all_defs = []
    file_manifest = []

    for fpath in files:
        rel = os.path.relpath(fpath, REPO_ROOT)
        try:
            with open(fpath, "r", encoding="utf-8") as fh:
                content = fh.read()
        except Exception as exc:
            print(f"  SKIP {rel}: {exc}", file=sys.stderr)
            continue

        lines = content.split("\n")
        scanner = Scanner(fpath, lines)
        scanner.scan()
        defs = scanner.results

        all_defs.extend(defs)
        file_manifest.append({
            "file": rel,
            "line_count": len(lines),
            "definition_count": len(defs),
        })

    return all_defs, file_manifest, files


# ---------------------------------------------------------------------------
# Body hash computation (second pass)
# ---------------------------------------------------------------------------

def compute_body_hashes(definitions):
    """For each definition, read its file and compute a normalized body hash.

    The hash captures the structural skeleton: keywords, braces, and
    significant identifiers, but ignores whitespace and comments. This
    makes it possible to detect near-duplicate implementations.
    """
    # Group by file for efficiency
    by_file = defaultdict(list)
    for d in definitions:
        by_file[d["file"]].append(d)

    for fpath_rel, defs in by_file.items():
        fpath = os.path.join(REPO_ROOT, fpath_rel)
        try:
            with open(fpath, "r") as fh:
                content = fh.read()
        except Exception:
            continue

        lines = content.split("\n")
        for d in defs:
            ln = d["line"] - 1  # 0‑based
            body = _extract_definition_text(lines, ln)

            # Normalize: collapse whitespace and strip line comments.
            normalized = re.sub(r'//[^\n]*', '', body)
            normalized = re.sub(r'\s+', ' ', normalized)
            normalized = re.sub(r'//[^\n]*', '', normalized)
            normalized = normalized.strip()

            d["body_hash"] = hashlib.sha256(
                normalized.encode("utf-8")
            ).hexdigest()[:16]


def _extract_definition_text(lines, start_line):
    """Extract a single definition body starting at `start_line`.

    This stays intentionally lightweight, but avoids the previous
    surrounding-window hash that made identical private widgets look different
    whenever their neighboring code differed.
    """
    collected = []
    depth = 0
    seen_body = False

    for line in lines[start_line:]:
        collected.append(line)
        stripped = _strip_strings_and_line_comments(line)

        if not seen_body and "=>" in stripped and ";" in stripped:
            break

        if "{" in stripped:
            seen_body = True

        depth += stripped.count("{") - stripped.count("}")

        if seen_body and depth <= 0:
            break

        if not seen_body and ";" in stripped:
            break

    return "\n".join(collected)


def _strip_strings_and_line_comments(line):
    result = []
    i = 0
    in_single = False
    in_double = False

    while i < len(line):
        ch = line[i]
        if in_single:
            if ch == "\\":
                i += 2
                continue
            if ch == "'":
                in_single = False
            i += 1
            continue
        if in_double:
            if ch == "\\":
                i += 2
                continue
            if ch == '"':
                in_double = False
            i += 1
            continue
        if line[i:i + 2] == "//":
            break
        if ch == "'":
            in_single = True
            i += 1
            continue
        if ch == '"':
            in_double = True
            i += 1
            continue
        result.append(ch)
        i += 1

    return "".join(result)


# ---------------------------------------------------------------------------
# Cross‑reference / consolidation candidate pass
# ---------------------------------------------------------------------------

# Built-in names that aren't user-defined duplication (e.g. `Function` in typedefs)
_BUILTIN_NAMES = frozenset({
    "Function", "String", "int", "double", "bool", "num", "void",
    "dynamic", "Object", "Null", "Future", "Stream", "List", "Map",
    "Set", "Iterable", "BuildContext", "Widget", "StatelessWidget",
    "StatefulWidget", "State", "Key",
})

_IGNORED_COLLISION_NAMES = frozenset({
    # Multiple entrypoints are intentional in this app split.
    "main",
})


def _site_key(site):
    return (site["file"], site["line"])


def _site_files(candidate):
    """Return a frozenset of (file, line) tuples for dedup."""
    return frozenset(_site_key(s) for s in candidate["sites"])


def _is_conditional_platform_factory_collision(sites):
    """Recognize factory/stub/mobile split functions used by conditional imports."""
    basenames = {os.path.basename(s["file"]) for s in sites}
    return (
        any(name.endswith("_factory.dart") for name in basenames)
        and any(name.endswith("_stub.dart") for name in basenames)
        and any(name.endswith("_mobile.dart") for name in basenames)
    )


def cross_reference(definitions, file_manifest):
    """Group definitions and flag consolidation candidates."""
    raw_candidates = []

    # ---- 1. Exact name collisions (same kind, different files) ----
    by_name_kind = defaultdict(list)
    for d in definitions:
        if d["name"] in _BUILTIN_NAMES:
            continue
        if d["name"] in _IGNORED_COLLISION_NAMES:
            continue
        # Private non-class names (_foo) are file-scoped by convention; skip
        if d["name"].startswith("_") and d["kind"] != "class":
            continue
        by_name_kind[(d["kind"], d["name"])].append(d)

    for (kind, name), sites in by_name_kind.items():
        files = sorted(set(s["file"] for s in sites))
        if len(files) < 2:
            continue
        if kind == "function" and _is_conditional_platform_factory_collision(sites):
            continue
        body_hashes = sorted(set(s.get("body_hash") for s in sites))
        has_identical_body = len(body_hashes) == 1 and body_hashes[0]
        # Classes that are widgets get a stronger severity + tailored message
        is_widget = all(s.get("is_widget") for s in sites if s.get("is_widget")
                        is not None) and any(s.get("is_widget") for s in sites)
        match_type = (
            "duplicate_implementation"
            if has_identical_body else
            "name_collision_needs_triage"
        )
        if has_identical_body:
            severity = "high" if is_widget or name.startswith("_") else "medium"
            suggestion = (
                f"Class '{name}' has the same implementation in "
                f"{len(files)} files. Extract a single shared implementation "
                "and import it."
                if is_widget else
                f"Same {kind} '{name}' has the same implementation in "
                f"{len(files)} places. Consolidate into one location and "
                "import it."
            )
        else:
            severity = "low" if name.startswith("_") else "medium"
            suggestion = (
                f"Private class '{name}' appears in {len(files)} files but "
                "the implementations differ. Treat as a naming collision: "
                "rename for local clarity or extract only after confirming a "
                "shared concept."
                if name.startswith("_") else
                f"Same {kind} '{name}' appears in {len(files)} files with "
                "different implementations. Triage before consolidation."
            )
        raw_candidates.append({
            "match_type": match_type,
            "severity": severity,
            "name": name,
            "kind": kind,
            "is_widget": is_widget,
            "sites": [{"file": s["file"], "line": s["line"],
                       "signature": s["signature"],
                       "body_hash": s.get("body_hash")} for s in sites],
            "suggestion": suggestion,
        })

    # ---- 2. Same‑name constants / variables in different files ----
    consts_vars = [d for d in definitions
                   if d["kind"] in ("constant", "variable")
                   and not d["name"].startswith("_")]
    by_const_name = defaultdict(list)
    for cv in consts_vars:
        by_const_name[cv["name"]].append(cv)

    for name, sites in by_const_name.items():
        files = sorted(set(s["file"] for s in sites))
        if len(files) < 2:
            continue
        raw_candidates.append({
            "match_type": "duplicate_constant_name",
            "severity": "medium",
            "name": name,
            "kind": "constant",
            "sites": [{"file": s["file"], "line": s["line"],
                       "signature": s["signature"]} for s in sites],
            "suggestion": (
                f"Constant '{name}' is defined in {len(files)} files. "
                f"Move to a shared location and import it."
            ),
        })

    # ---- 3. Deduplicate overlapping candidates ----
    # If two candidates share identical sites, keep only the most specific one
    # (prefer "exact_name_collision" over other types).

    # Group by site‑set
    by_sites = defaultdict(list)
    for c in raw_candidates:
        by_sites[_site_files(c)].append(c)

    type_priority = {
        "duplicate_implementation": 0,
        "name_collision_needs_triage": 1,
        "duplicate_constant_name": 5,
        "duplicate_date_format": 10,
        "inline_color_literals": 10,
    }
    candidates = []
    for site_set, group in by_sites.items():
        # Pick the best match type
        group.sort(key=lambda c: type_priority.get(c["match_type"], 99))
        candidates.append(group[0])

    # Assign IDs and sort by severity then name
    sev_order = {"high": 0, "medium": 1, "low": 2}
    candidates.sort(key=lambda c: (sev_order.get(c["severity"], 9), c["name"]))
    for i, c in enumerate(candidates):
        c["id"] = f"C-{i + 1:03d}"

    return candidates


# ---------------------------------------------------------------------------
# Hardcoded color / token scan (quick grep‑based)
# ---------------------------------------------------------------------------

def scan_inline_tokens(files):
    """Find hardcoded Color(0x...) literals outside core/theme files."""
    entries = []
    for fpath in files:
        rel = os.path.relpath(fpath, REPO_ROOT)
        # Skip theme files
        if "core/theme/" in rel or "core/widgets/catch_" in rel:
            continue
        try:
            with open(fpath, "r") as fh:
                for ln, line in enumerate(fh, 1):
                    m = re.search(r'Color\((0x[0-9a-fA-F]{8})\)', line)
                    if m:
                        entries.append({
                            "file": rel,
                            "line": ln,
                            "color": m.group(1),
                            "context": line.strip()[:120],
                        })
        except Exception:
            continue
    return entries


def scan_date_formatters(files):
    """Find DateFormat(...) calls and group by format string."""
    formats = defaultdict(list)
    pattern = re.compile(r"DateFormat\('([^']*)'\)")
    for fpath in files:
        rel = os.path.relpath(fpath, REPO_ROOT)
        try:
            with open(fpath, "r") as fh:
                for ln, line in enumerate(fh, 1):
                    for m in pattern.finditer(line):
                        formats[m.group(1)].append({
                            "file": rel,
                            "line": ln,
                            "context": line.strip()[:120],
                        })
        except Exception:
            continue
    return dict(formats)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def cmd_extract():
    print("Extracting definitions from lib/ ...")
    definitions, manifest, files = extract_all()
    print(f"  Scanned {len(manifest)} files")
    print(f"  Found {len(definitions)} definitions")

    print("Computing body hashes ...")
    compute_body_hashes(definitions)

    catalog = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "repo_root": REPO_ROOT,
        "total_files_scanned": len(manifest),
        "total_definitions": len(definitions),
        "file_manifest": manifest,
        "definitions": definitions,
    }

    os.makedirs(OUT_DIR, exist_ok=True)
    with open(CATALOG_PATH, "w") as fh:
        json.dump(catalog, fh, indent=2)
    print(f"  Wrote {CATALOG_PATH}")

    # Quick summary by kind
    by_kind = defaultdict(int)
    for d in definitions:
        by_kind[d["kind"]] += 1
    print("  By kind:")
    for kind in sorted(by_kind):
        print(f"    {kind}: {by_kind[kind]}")

    return catalog


def cmd_full():
    catalog = cmd_extract()
    definitions = catalog["definitions"]
    files = find_dart_files()

    print("\nCross‑referencing for consolidation candidates ...")
    candidates = cross_reference(definitions, catalog["file_manifest"])

    # Inline token scan
    print("  Scanning for hardcoded colors ...")
    color_entries = scan_inline_tokens(files)
    print(f"    Found {len(color_entries)} hardcoded Color(...) instances")

    # Date format scan
    print("  Scanning for DateFormat calls ...")
    date_formats = scan_date_formatters(files)
    print(f"    Found {len(date_formats)} distinct date format strings")

    # Add inline-token candidates
    cid = len(candidates)
    if color_entries:
        cid += 1
        candidates.append({
            "id": f"C-{cid:03d}",
            "match_type": "inline_color_literals",
            "severity": "medium",
            "name": "Hardcoded Color(0x...) literals",
            "kind": "token",
            "sites": color_entries,
            "suggestion": (
                "Move these hardcoded colors into CatchTokens or a theme file "
                "so they can be managed centrally."
            ),
        })

    if date_formats:
        cid += 1
        # Only flag format strings used in multiple files as candidates
        for fmt, sites in date_formats.items():
            files_using = set(s["file"] for s in sites)
            if len(files_using) > 1:
                cid += 1
                candidates.append({
                    "id": f"C-{cid:03d}",
                    "match_type": "duplicate_date_format",
                    "severity": "low",
                    "name": f"DateFormat('{fmt}')",
                    "kind": "function",
                    "sites": sites,
                    "suggestion": (
                        f"DateFormat('{fmt}') used in {len(files_using)} files. "
                        f"Consider a shared formatRunDate() utility."
                    ),
                })

    output = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "total_candidates": len(candidates),
        "candidates": candidates,
    }

    with open(CANDIDATES_PATH, "w") as fh:
        json.dump(output, fh, indent=2)
    print(f"\n  Wrote {CANDIDATES_PATH}")
    print(f"  Total consolidation candidates: {len(candidates)}")

    # Summary by severity
    by_sev = defaultdict(int)
    for c in candidates:
        by_sev[c["severity"]] += 1
    print("  By severity:")
    for s in ("high", "medium", "low"):
        print(f"    {s}: {by_sev.get(s, 0)}")

    return output


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 tool/audit/definition_catalog.py [extract|full]",
              file=sys.stderr)
        sys.exit(1)

    mode = sys.argv[1]
    if mode == "extract":
        cmd_extract()
    elif mode == "full":
        cmd_full()
    else:
        print(f"Unknown mode: {mode}", file=sys.stderr)
        sys.exit(1)
