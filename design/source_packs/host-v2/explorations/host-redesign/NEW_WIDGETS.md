# New widgets — Catch for Organizers (redesign prototype)

Catalogue candidates introduced in `explorations/host-redesign/CatchForOrganizers.html`.
These are the higher-quality representations built where an existing primitive
didn't exist or didn't fit the re-cut IA (event-lifecycle spine, "organizer" as
the durable entity). Format mirrors `docs/widget_catalog.md` so these can be
folded in once approved.

> **Reuse note.** The prototype composes existing primitives where they already
> fit — `Badge` (tones), `Button`/pill actions, `ActivityChip`, the activity
> **pigment tokens** (`--act-*-accent/-soft/-deep`), `Section` rhythm, mono
> labels, and `FieldGroup`/`Field` (forms, unchanged). Everything below is *new*
> or a deliberate upgrade.

| Widget | Purpose | Key props | Why it's better than today |
|---|---|---|---|
| **NextUpHero** | The time-aware marquee on **Today** — the next/live event in the dark "wow" register, pigment-glowed by activity, with a state chip (`LIVE NOW` / `STARTS IN 3H` / `NEXT UP`), key facts, a face-pile, and a **stateful primary CTA** (`Set up & run` → `Open run-of-show`). | `ev`, `live`, `onRun`, `onShare` | Today there is no ops home; the live console is 4 taps deep. This makes the highest-stakes moment the first thing you see, and uses the design system's reserved **dark spotlight** register (previously unused on host surfaces). |
| **ActionQueue** (`NeedsYou`) | A **cross-event triage list** — approvals, waitlist offers, unanswered guest questions, unfinished drafts — each a one-tap card with a count chip and a tinted glyph by urgency. | `items[]`, `onItem` | No equivalent exists; today a host must visit each event to discover what needs them. This collapses "what needs me, across everything" into one glanceable queue. |
| **EventLifecycleRow** | The **event-first** list row: activity pigment spine, big date, title, when + lifecycle tag, a **fill bar**, and a state-aware trailing (new-request badge vs chevron). | `ev`, `onOpen` | Replaces the current club→event "manage rows" that are nested under a club. Event-first, lifecycle-aware (upcoming/live/past), and legible at a glance. |
| **RepeatLastEvent** | A create affordance pairing **New event** with **Repeat last** (clone the previous run with a fresh date). | (action) | Table-stakes in the segment (Luma/RSVPify) that Catch lacks. For a weekly organizer this is the single most-repeated act. |
| **RosterPeek** + **RosterSheet** | The roster **tucked behind a peek** — a corner "instant" deck (folded corner, overlapping faces, live counts) that raises a humanist roster sheet grouped by presence (Here now / Expected / Requests / Waitlist), with warm inline Approve/Offer actions. | peek: counts, `onOpen`; sheet: `open`, `onClose` | The current Manage screen leads with a full roster board that buries summary + actions under a long scroll. This frees the overview while keeping the roster always one tap away. (Iterated from `explorations/manage-roster`.) |
| **RosterInline** | The same grouped-by-presence roster, rendered **inline** for the Manage **Guests** tab (no overlay). | — | Gives the roster a real home (Guests) while the peek serves the other modes. |
| **FacePile** | Overlapping avatar stack with a `+N` chip; light **and** dark variants (correct ring color per surface). | `list`, `n`, `onDark` | Recurs across hero, peek, rows; encodes "the people" as the primary content of a roster, the humanist move the brand calls for. |
| **HostAvatar** (`Av`) | Photo-or-**warm-tinted-initials** circle (low-chroma per-person hues), sizes parameterized. | `p`, `size`, `border` | One avatar primitive that degrades gracefully without a photo and stays warm/humanist rather than grey initials. |
| **OrganizerHeader** | The **brand** surface that merges the org identity (logo, name, verified, formats, member/event/rating stats, "how guests see you") with **you as host** — the durable "organizer" entity, format-agnostic. | `org` | Encodes the **club → organizer** reframe and pulls the host profile out of Settings into the brand it represents. Replaces the run-club-shaped Clubs tab + the profile-as-setting Account tab. |
| **TrendStrip** | Compact cross-event KPIs (bookings / fill / repeat) over a 12-week sparkline. | `data`, KPIs | Consolidates club-level analytics into the organizer brand (one home for "how are we doing"), instead of a buried Insights sub-tab. |
| **SegPill** | Segmented control (pill track, raised selected) for ranges, modes, lifecycle filters. | `options`, `value`, `onChange` | Replaces the stacked underline OptionGroups that read as junk for filters; intentional, glanceable. |
| **OrganizerTabBar** | The re-cut bottom nav: **Today · Events · Inbox · Organizer** (filled/outline glyph pairs, unread dot). | `tab`, `setTab` | The IA change itself — lifecycle-shaped, not two club-shaped tabs + settings. |
| **BlastEntry** | "Message all N booked" affordance heading each event's threads in **Inbox**. | `ev`, `onOpen` | Today's inbox is the generic consumer chat list; this makes messaging **event-scoped** with a broadcast, mirroring Luma/Partiful blasts. |
| **Toast** | Lightweight bottom confirmation for stubbed actions. | `msg` | Prototype affordance; a real `CatchToast` is worth standardizing. |

## Notes for productionizing
- **NextUpHero** uses the dark register via the existing `.catch-dark` token scope — no new color work; the only addition is an activity-accent glow.
- **RosterPeek/Sheet** open-state transform is set **inline** (`translateY(0)`) so it can't be lost to stylesheet specificity — keep that if porting to Flutter's sheet equivalent it's moot, but note it for any web port.
- The **"organizer" rename** is vocabulary + a merged brand surface; the data model already treats `clubs/{clubId}` as the canonical organizer document, so this is a presentation-layer reframe, not a schema change.
- Frequencies/priorities behind the IA are in `explorations/host-ia-review/HostIAReview.html`.
