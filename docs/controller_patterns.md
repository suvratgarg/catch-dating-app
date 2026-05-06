---
doc_id: controller_patterns
version: 2.1.1
updated: 2026-05-06
owner: recursive_audit_loop
status: active
---

# Controller Patterns

## Read Policy

Read this before architecture, state-management, controller, or repository/UI
boundary work. Stamp applied version `controller_patterns@2.1.1` in
`docs/audit_registry/files.jsonl` when a file is reviewed against these rules.

## Rule Changelog

### 2.1.1

- Clarified retained-tab stream ownership. A `StatefulShellRoute.indexedStack`
  keeps branch widgets mounted, so tab-root streams must be explicitly gated
  when inactive unless they serve shell-wide UI. Do not prewarm feature-owned
  tab streams from `AppShell` without a measured UX reason and documented read
  cost.

### 2.1.0

- Added realtime stream lifecycle guidance after the dashboard booked-runs
  stream regression. Firestore listeners must not use idle `Stream.timeout`;
  lifecycle should be controlled by provider auto-dispose, explicit keepAlive
  rationale, route/tab visibility, and test coverage that advances fake time
  past any previous timeout threshold.

### 2.0.0

- Controller/view-model boundary rules are now versioned for recursive audits.
- UI files reviewed under older versions should be rechecked for repository
  writes, mutation ergonomics, and testability seams.

Use controllers when UI code would otherwise own product behavior, persistence
rules, validation, or repository calls. Widgets should stay focused on rendering,
input mechanics, navigation, and transient Flutter concerns such as focus,
scrolling, timers, and animations.

## Pattern A: Action controller

Use a stateless generated notifier for one-shot user actions.

```dart
@riverpod
class ExampleController extends _$ExampleController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit() async {
    // Validate and delegate to repositories.
  }
}
```

Use for: book/cancel/join/leave/submit/delete/block/report/sign-out actions.

UI should call `Mutation.run(ref, (tx) => tx.get(provider.notifier).method())`
so Riverpod keeps provider dependencies alive while the side effect is running.

## Pattern B: Flow controller

Use a generated notifier with immutable state for multi-step flows or screens
whose state is more than a single local input.

```dart
@Riverpod(keepAlive: true)
class ExampleFlowController extends _$ExampleFlowController {
  static final completeMutation = Mutation<void>();

  @override
  ExampleFlowState build() => const ExampleFlowState();
}
```

Use for: auth, onboarding, or any future wizard where state must survive
navigation inside the flow. Prefer auto-dispose unless the flow must survive
route/tab changes. If keepAlive is used, reset or invalidate state on completion,
sign-out, or cancellation.

## Pattern C: Async state controller

Use `AsyncNotifier<T>` when state is loaded asynchronously and then mutated by
user actions.

Use for: queues, async local caches, or paged lists where the controller owns
the loaded state and exposes mutation methods.

## Pattern D: View-model provider

Use a pure generated function provider to combine repository streams/futures
into a read-only view model.

Use for: screens that need one `.when(loading:error:data:)` value from several
async dependencies. Keep these providers side-effect free.

## Boundary Rule

Screens and widgets may read view-model providers, watch mutation state, and
call controller methods through mutations. They should not call repositories
directly for product behavior unless the operation is purely local UI plumbing
or the surrounding feature has an explicit reason to keep it there.

## Realtime Stream Lifecycle

Firestore snapshot streams are long-lived realtime listeners. Silence after the
initial emission is normal and must not be treated as failure. Do not wrap these
streams in `Stream.timeout` to detect stalled initial loads; that converts a
healthy listener into an error if no document changes arrive before the timeout.

Use these lifecycle rules instead:

- Prefer generated `@riverpod` auto-dispose stream providers for route-owned
  reads. Let the provider close when the route is popped or when the screen
  stops watching it.
- Use `@Riverpod(keepAlive: true)` only when the stream is deliberately global
  or prewarmed. Document the reason at the call site or provider.
- For bottom-tab branches retained by `StatefulShellRoute.indexedStack`, decide
  whether the stream should remain active while its tab is inactive. If it
  should not, gate the screen/view model on `AppShellActiveTab` before watching
  feature-owned providers. If the active screen already has data and should
  force a fresh listener later, invalidate the specific stream provider when the
  tab becomes inactive.
- Avoid shell-level prewarming for feature-owned tab streams unless the user
  experience benefit is explicit, the read cost is acceptable, and the provider
  ownership is documented.
- Keep small global streams alive when they support shell-wide behavior, such as
  auth state, current user profile, connectivity, or unread-count badges.
- Add regression tests for lifecycle-sensitive streams. A good test opens the
  stream, emits data, advances fake time beyond any historical timeout window,
  and asserts the provider still holds data rather than `AsyncError`.

Apply this pattern carefully. Reopening a listener can cost a fresh query read,
while leaving it open can incur reads when matching documents change in the
background. The right owner is the surface that needs the data: shell-wide data
belongs in the shell; first-viewport tab data should usually pause when the tab
is inactive; pushed detail-route data should usually auto-dispose when popped.
