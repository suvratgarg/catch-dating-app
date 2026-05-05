# Controller Patterns

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
