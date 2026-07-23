---
doc_id: fable_ui_issue_handoff
version: 0.1.0
updated: 2026-07-23
owner: design_parity_review
status: retirement_ready
---

# Fable UI Issue Handoff

> **RESOLVED.** Issue 001 (profile-edit field rows not reading end-to-end)
> shipped as the `CatchFieldInsetScope` flush contract — now the reference
> implementation for the containment/gutter doctrine. Retained as history.

## Meta Prompt

You are working in the Catch Flutter repo at:

`/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`

Use this as an issue brief, not as a replacement for source inspection. Your job is
to solve the UI issue at the root component/API level, not to spot-fix one
screen. Prefer improving the canonical primitive, layout contract, or feature
adapter seam that caused the issue. Preserve unrelated dirty work.

Required workflow:

1. Check `git status --short` and read `AGENTS.md`.
2. Inspect the issue screenshot and the files listed under the issue.
3. Identify the responsible widget(s), the root cause, and whether the lesson is
   generalizable.
4. If making edits, keep them narrowly scoped, update `docs/widget_catalog.md`
   if a widget contract/API/layout rule changes, and stamp audit proof in
   `docs/audit_registry/passes.jsonl`.
5. Run focused widget tests and `flutter analyze --no-fatal-infos` for the
   touched files. Run relevant scanners, usually `bash tool/widget_cleanup_scan.sh`
   and `bash tool/check_sizing.sh` for sizing/layout work.
6. If the app is running in debug/prod simulator mode, hot reload or hot restart
   after code changes so the visible app proves the fix. Product-debug command:
   `./tool/flutter_with_env.sh prod run -d "iPhone 17 Pro" --debug`.
7. Consider enforceability. Add a scanner/lint/test only when the issue can be
   detected without over-flagging valid local exceptions.

Do not solve by assigning matching magic numbers in several feature widgets.
If the issue is about repeated app chrome, form rows, empty states, or layout
gutters, look for the shared primitive or layout API that should own the
contract.

## Issue 001: Profile Edit Fields Do Not Read End-To-End

### Screenshot

Attachment from Codex thread:

`Simulator Appshot 2026-07-04T08-28-35.342Z.png`

Visible screen: iPhone 17 Pro simulator, Profile tab, Edit subtab, scrolled to
Prompts / About You field rows. The screenshot shows full-width horizontal
dividers inside the Profile Edit gutter, but row labels/values appear visually
compressed into an inner lane. Examples visible:

- Prompt rows: quote icon at left, prompt label/value in the middle, chevron not
  visually pinned to the section's far right.
- About You rows: icons and labels/values occupy a narrower interior column;
  divider lines span much farther right than the text/trailing affordances.
- User expectation: field rows should run end-to-end inside the fixed Profile
  Edit screen padding. Full-bleed is not desired; the screen gutter remains
  constant. The row content itself should use the available section width.

### User Framing

The user described this as:

> "catchfields or profile info text labels not being end to end"

This follows an earlier pass that made Profile Edit sections honor fixed screen
gutters rather than full-bleed rows. The remaining issue is not the outer page
padding; it is the field-row/content anatomy within that gutter.

### Expected Behavior

- Profile Edit uses one fixed left/right screen gutter.
- Within that gutter, each field row's visual content should use the full row
  width.
- Leading icons may occupy a reserved slot, but the label/value lane should grow
  naturally to the trailing affordance.
- Chevrons/trailing controls should feel aligned to the row's trailing edge,
  not floating near the middle.
- Dividers, labels, values, and trailing affordances should tell the same width
  story.
- Do not reintroduce full-bleed form rows as the default solution.

### Current Source Shape

Likely relevant files:

- `lib/user_profile/presentation/widgets/profile_info_section.dart`
  - `profileTabBodyPadding` defines fixed Profile Edit body padding.
  - `ProfileInfoSection` builds grouped sections and full-width dividers.
  - `ProfileInfoRowFrame.fullBleedRows` exists but Profile Edit currently does
    not opt into it.
- `lib/user_profile/presentation/widgets/profile_tab.dart`
  - `ProfileTab` and `ProfileTabSliverBody` wrap edit content in
    `profileTabBodyPadding` and `CatchLayout.maxContentWidth`.
  - `ProfileFieldRow` maps profile descriptors into `CatchField.nav`,
    `ProfileDirectTextEntry`, and inline editors.
- `lib/user_profile/presentation/widgets/inline_editor_text.dart`
  - `ProfileDirectTextEntryField` renders simple text fields through
    `CatchField.input`.
  - Prompt inline display/edit also routes through `CatchField.input` variants.
- `lib/core/widgets/catch_field.dart`
  - `CatchFieldRow.standard` owns the row anatomy.
  - Current row padding defaults to `EdgeInsets.fromLTRB(CatchSpacing.s4,
    CatchSpacing.micro14, CatchSpacing.s4, CatchSpacing.micro14)`.
  - The row uses optional leading slot, `Expanded(child: content)`, optional
    trailing slot, and `Flexible(child: trailing)`.
  - `CatchFieldTrailing.valueText` constrains value text to `maxWidth: 160`.
  - The root fix may belong in `CatchFieldRow`, `CatchFieldTrailing`, or a
    profile-specific field-row mode, but avoid feature-only duplicated layout
    math unless the core primitive cannot express the needed contract.
- `test/profile/profile_widgets_test.dart`
  - Existing tests cover Profile Edit rows and a prior gutter assertion.
- `test/core/catch_primitives_test.dart`
  - Existing tests cover `CatchField` primitive behavior.
- `docs/widget_catalog.md`
  - Current entries for `CatchField`, `ProfileTab`, `ProfileInfoSection`,
    `ProfileInfoRowFrame`, and `ProfileDirectTextEntryField`.

### Suspected Root Cause

The outer Profile Edit body appears to be correctly constrained to the standard
screen gutter. The mismatch is likely inside `CatchField` row anatomy:

- `CatchFieldRow.standard` adds its own horizontal padding inside every row.
- The leading icon slot plus leading gap further shifts label/value content.
- The trailing slot can be flexible and/or internally constrained.
- Some prompt/profile rows may use inline editor wrappers whose collapsed value
  display does not mirror the canonical row width contract.

Fable should confirm this against the rendered tree before changing anything.

### Acceptance Criteria

- On iPhone-width Profile Edit, prompt rows and About You rows visually use the
  same right edge as the section/divider gutter.
- Text labels/values wrap or truncate professionally without leaving arbitrary
  unused horizontal space.
- Trailing chevrons stay aligned to the row trailing edge.
- Outer Profile Edit screen gutter remains fixed; fields should not become
  full-bleed to the screen edge.
- The fix should be expressed through a reusable contract if possible.
- Add or update widget tests that assert row geometry at phone width. Prefer
  invariant-style assertions over exact pixels.

### Verification Suggestions

Run at least:

```sh
flutter test test/profile/profile_widgets_test.dart --plain-name "ProfileTab field rows honor fixed screen gutters"
flutter analyze --no-fatal-infos lib/core/widgets/catch_field.dart lib/user_profile/presentation/widgets/profile_info_section.dart lib/user_profile/presentation/widgets/profile_tab.dart lib/user_profile/presentation/widgets/inline_editor_text.dart test/profile/profile_widgets_test.dart
bash tool/widget_cleanup_scan.sh
bash tool/check_sizing.sh
node tool/agent/check_agent_readiness.mjs
```

If changing `CatchField`, also run focused primitive tests from
`test/core/catch_primitives_test.dart`.
