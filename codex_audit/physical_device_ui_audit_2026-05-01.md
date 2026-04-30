# Physical Device UI Audit - 2026-05-01

Scope:
- Run Catch on Suvrat's physical iPhone via Flutter.
- Use iPhone Mirroring / desktop control to exercise real app flows.
- Compare rendered iPhone UI against `design_handoff_catch_dating_app/`.
- Record functionality failures, console/runtime symptoms, likely code causes, and fixes.
- Patch high-confidence UI/UX or bug issues iteratively, preserving unrelated dirty worktree changes.

References:
- `PROJECT_CONTEXT.md`
- `codex_audit/design_handoff_ui_fidelity_audit.md`
- `design_handoff_catch_dating_app/README.md`
- `design_handoff_catch_dating_app/index.html`

Device/build status:
- Flutter sees `Suvrat's iPhone` as device `00008120-001A152E3EEB401E`, iOS 26.0.1.
- App run command to use first: `./tool/flutter_with_env.sh dev run -d 00008120-001A152E3EEB401E`.

Initial plan:
- [x] Confirm repo context and prior design-fidelity audit.
- [x] Confirm physical iPhone is visible to Flutter.
- [ ] Start the app on the iPhone with the repo environment wrapper.
- [ ] Confirm iPhone Mirroring is available through Computer Use.
- [ ] Capture first-launch state and any runtime errors.
- [ ] Walk onboarding and unauthenticated flows.
- [ ] Walk authenticated tab shell: Home, Clubs, Catches, Chats, You.
- [ ] Walk supporting routes: run detail, club detail, create run, calendar, activity, filters, settings, edit profile, payment history, safety/account actions.
- [ ] Compare each reachable screen against the 37 handoff screens.
- [ ] Implement high-confidence fixes and re-run focused verification.

Open notes:
- The worktree was dirty before this pass. Do not revert existing changes unless explicitly asked.
- Some handoff screens depend on backend data/roles. If the current signed-in user cannot reach a route, record the gating reason and inspect code/sample harnesses before deciding whether to seed data or patch UI.
