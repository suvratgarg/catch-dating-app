# Host redesign — consolidated ✓

This folder is the **research archive** for the host-app re-cut ("Catch for Organizers").
It is retained in full (no net loss) and indexed from `host-app-manifest.json` → `research_index`.

The direction here is now **shipped** as the canonical host app:

- **New app screens** (composed of catalogue widgets): `templates/host-app/` — Today · Events · Inbox · Organizer · Manage · Insights
- **Promoted widgets**: `components/` — NextUpHero · NeedsYouQueue · EventLifecycleRow · FacePile · OrganizerHeader · TrendStrip · SegPill · MetricGrid/StatCard · BlastComposer · DateRangePicker
- **Gallery**: `Host App.html`
- **Decisions + re-homing map + regression audit**: `Host App Decisions.html` (renders `host-app-manifest.json`)

### What's here (kept for reference)
| File | What it is |
|---|---|
| `CatchForOrganizers-v2.html` | Canonical interactive prototype (baked-in fixes + optioned alternatives). |
| `CatchForOrganizers.html` | v1 prototype. |
| `UX_AUDIT.html` | 74-item UI/UX punch list, tagged altitude × priority. |
| `NEW_WIDGETS.md` | Original catalogue-candidate rationale (now promoted). |
| `Flows.html` | Onboarding + create-event wizard flows. |
| `CalendarPrimitive.html` | The date-range calendar → promoted as core `DateRangePicker`. |
| `../host-ia-review/HostIAReview.html` | The first-principles IA re-cut (thesis, frequency × stakes, competitor scan). |
