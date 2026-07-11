# Catch — Apps map (feature → screen → widget)

> The two products built on this design system, broken down **app → feature → screen → widget**. Both apps are **Flutter** (phone-only); the `templates/<slug>/` blueprints here are the React/HTML reference each screen is ported from. Templates can't physically nest, so the hierarchy lives in this doc + the slug convention.

**Slug convention** (in `templates/`): `catch-*` = the consumer app · `hosts-*` = the host app · `social-*` = social/marketing media. **Widgets** are catalogue components in `components/<group>/<Name>/` (exposed on `window.CatchDesignSystem_3a44f2`). Exhaustive component-level composition lives in **`COMPOSITION.md`**; this doc is the screen→widget index.

- **App:** Catch (consumer) · Catch Hosts
- **Design system referenced by both:** `styles.css` / `colors_and_type.css` (tokens + type) · `components/` (widgets) · `fonts/` · `assets/`. See **`SYSTEM.md`**.
- **Other surfaces:** marketing site → **`WEBSITE.md`** · social drops → **`SOCIAL.md`** · prototypes → `event-companion/`, `splash-welcome-handoff/`.

---

## 1 · Catch (consumer app)

The supply-side dating app: discover real events & clubs, book, show up, match with people who were actually there. Flutter · `lib/`.

### Feature: Onboarding
| Screen | Template | Composes (widgets) |
|---|---|---|
| Sign-up flow (Welcome → Phone → OTP → Name/DOB → Gender → Instagram → Photos → Prompts → Running prefs) | `templates/catch-onboarding/` | `StepHeader` · `TextField` · `CodeInput` · `PhotoGrid` · `Chip` · `Button` · `StatusBar` |

### Feature: Discover
| Screen | Template | Composes |
|---|---|---|
| Explore (supply-side shop window) | `templates/catch-explore/` | `CoverStory` · `ClubPolaroid` · `CrossPathsCard` · `DateTicket` · `CountPill` · `OptionGroup` · `TabDock` |
| Home dashboard (event focus, stride, quick actions) | `templates/catch-dashboard/` | `AppBar` · `CoverStory` · `DashboardEventCard` · `EventTicket` · `JourneySteps` · `QuickActions` · `StrideCard` · `StatusBar` · `TabDock` |

### Feature: Events
| Screen | Template | Composes |
|---|---|---|
| Event detail (the canonical event screen) | `templates/catch-event-detail/` | `EventHero` · `TicketStub` · `Itinerary` · `HostCard` · `AvatarStack` · `MapCard` · `HintList` · `MechanismList` · `PhotoStrip` · `BookingDock` · `Section` · `SectionStack` |
| Booking moments (conflict · checkout · "you're in") | `templates/catch-booking/` | `ConflictSheet` · `CheckoutSheet` · `Celebration` · `StatusBar` |

### Feature: Clubs
| Screen | Template | Composes |
|---|---|---|
| Club detail (domain-complete) | `templates/catch-club-detail/` | `ClubHero` · `ClubDock` · `HostRow` · `ReviewRow` · `ContactRow` · `PhotoStrip` · `DateTicket` · `ActivityChip` · `StatStrip` · `Section` · `SectionStack` · `Chip` |

### Feature: Profiles
| Screen | Template | Composes |
|---|---|---|
| Profile (flagship dark hero + sectioned body; preview / public / catches) | `templates/catch-profile/` | `ProfileHero` · `ProfilePhoto` · `ProfilePrompt` · `CompatibilityList` · `RunningRhythm` · `FactList` · `InfoRow` · `OptionGroup` · `PhotoGrid` · `AppBar` |

### Feature: Messaging
| Screen | Template | Composes |
|---|---|---|
| Inbox + chat thread (matches folded in) | `templates/catch-messaging/` | `ConversationTopBar` · `ChatThreadHeader` · `ChatBubble` · `ChatComposer` · `ChatListTile` · `AppBar` · `StatusBar` |

### Feature: Activity
| Screen | Template | Composes |
|---|---|---|
| Notifications (day-grouped activity feed) | `templates/catch-notifications/` | `NotificationRow` · `AppBar` · `StatusBar` |

### Feature: Settings
| Screen | Template | Composes |
|---|---|---|
| Settings & filters | `templates/catch-settings/` | `InfoRow` · `RangeSlider` · `Chip` · `Button` · `AppBar` · `StatusBar` |

---

## 2 · Catch Hosts (host app)

"Catch for Organizers" — the lifecycle-shaped host app. Four tabs (**Today · Events · Inbox · Organizer**) + two destinations (**Manage · Insights**). The IA decision, re-homing map, and regression audit live in **`Host App Decisions.html`** (renders `host-app-manifest.json`); the gallery is **`Host App.html`**; the rationale is `explorations/host-ia-review/` + `explorations/host-redesign/`.

### Feature: Today (time-aware ops)
| Screen | Template | Composes |
|---|---|---|
| Today — live hero + cross-event triage | `templates/hosts-today/` | `NextUpHero` · `NeedsYouQueue` · `EventLifecycleRow` · `FacePile` · `StatusBar` · `TabDock` |

### Feature: Events lifecycle (create → fill)
| Screen | Template | Composes |
|---|---|---|
| Events list (Upcoming / Live / Past + create) | `templates/hosts-events/` | `SegPill` · `EventLifecycleRow` · `Button` · `EmptyState` · `StatusBar` · `TabDock` |
| Create event (5-step wizard) | `templates/hosts-create-event/` | `StepHeader` · `TextField` · `PhotoGrid` · `Toggle` · `Chip` · `Badge` · `Button` · `IconButton` · `Celebration` |
| Event-created confirmation | `templates/hosts-create-event-success/` | `Celebration` · `ScreenBody` · `StatusBar` |
| Edit event (locks once booked) | `templates/hosts-edit-event/` | `AppBar` · `InfoGroup` · `InfoRow` · `TextField` · `Chip` · `Badge` · `Button` |

### Feature: Run the event
| Screen | Template | Composes |
|---|---|---|
| Manage (Setup · Guests · Live · Report) | `templates/hosts-manage/` | `SegPill` · `MetricGrid`/`StatCard` · `InfoGroup`/`InfoRow` · `RosterTable`/`RosterRow` · `LiveConsole` · `StatusBar` |

### Feature: Guests & messaging
| Screen | Template | Composes |
|---|---|---|
| Inbox (Booked / Prospective + blast) | `templates/hosts-inbox/` | `SegPill` · `ChatListTile` · `Sheet` · `BlastComposer` · `StatusBar` · `TabDock` |

### Feature: Organizer (brand)
| Screen | Template | Composes |
|---|---|---|
| Organizer — brand, team, payouts, trends | `templates/hosts-organizer/` | `OrganizerHeader` · `Callout` · `MetricGrid`/`StatCard` · `TrendStrip` · `InfoGroup`/`InfoRow` · `PersonAvatar` · `Badge` · `TabDock` |
| Create organizer/club (4-step wizard) | `templates/hosts-create-club/` | `StepHeader` · `TextField` · `ClubPhotos` · `Toggle` · `Chip` · `Button` |
| Edit organizer/club | `templates/hosts-edit-club/` | `AppBar` · `ClubPhotos` · `InfoRow` · `Button` |
| Add co-host (sheet) | `templates/hosts-add-host/` | `Sheet` · `TextField` · `Button` |

### Feature: Analytics
| Screen | Template | Composes |
|---|---|---|
| Insights (range-scoped, deltas, trend, by-format) | `templates/hosts-insights/` | `DateRangePicker` · `Sheet` · `MetricGrid`/`StatCard` · `SegPill` · `EventLifecycleRow` · `Callout` · `Button` |

### Feature: Money
| Screen | Template | Composes |
|---|---|---|
| Payouts hand-off (Stripe) | `templates/hosts-payouts-handoff/` | `Sheet` · `Button` · `StatusBar` |

### Feature: Drafts & confirmations
| Screen | Template | Composes |
|---|---|---|
| Draft picker (sheet) | `templates/hosts-draft-picker/` | `Sheet` · `IconButton` · `Button` |
| Confirm dialogs (cancel · remove host · transfer) | `templates/hosts-dialogs/` | `ConfirmDialog` · `StatusBar` |

---

## 3 · Widgets unique to the host app

Promoted from the "Catch for Organizers" redesign (see README §5.5 provenance + `host-app-manifest.json` → `widgets`):

`NextUpHero` · `NeedsYouQueue`/`NeedsYouCard` · `EventLifecycleRow` · `MetricGrid`/`StatCard` · `TrendStrip` (`components/dashboard/`) · `OrganizerHeader` (`components/hosting/`) · `BlastComposer` (`components/messaging/`) · `FacePile` · `SegPill` · `DateRangePicker` (`components/core/`).

The host run-of-show + roster widgets — `LiveConsole`, `RosterTable`/`RosterRow`, `RosterTiles`, `RotationCard` — live in `components/hosting/` and are shared with the Manage screen.

---

## 4 · Archived / superseded (kept as research)
- Old club-shaped host tabs (`host-events`, `host-clubs`, `host-account`, `host-inbox`, `host-event-manage`) → `explorations/archived-templates/` — the faithful on-system rebuild of the **prior** host IA, superseded by `hosts-*`.
- Earlier consumer versions (`club-detail`, `onboarding`) + `explore-redesign` + the host create-wizard redesign studies (`host-create-*-v2`) → `explorations/archived-templates/`.
- Why each: see `REORG_TRACKER.md` §5 + `explorations/archived-templates/` siblings.
