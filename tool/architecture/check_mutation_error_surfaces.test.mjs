import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  scanFile,
  scanMutationErrorSurfaces,
} from "./check_mutation_error_surfaces.mjs";

test("scanFile flags build methods that read mutation pending without errors", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.toggleSavedEventMutation);",
      "    return Text(save.isPending ? 'Saving' : 'Saved');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].line, 4);
  assert.equal(findings[0].variableName, "save");
  assert.equal(
    findings[0].mutationExpression,
    "EventDetailController.toggleSavedEventMutation",
  );
});

test("scanFile allows pending mutations with an error surface", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.toggleSavedEventMutation);",
      "    if (save.hasError) return const Text('Failed');",
      "    return Text(save.isPending ? 'Saving' : 'Saved');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile flags a second pending mutation without its own error surface", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.saveMutation);",
      "    final Mutation<void> delete = ref.watch(EventDetailController.deleteMutation);",
      "    if (save.hasError) return const Text('Failed');",
      "    return Text(delete.isPending ? 'Deleting' : 'Ready');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].line, 6);
  assert.equal(findings[0].variableName, "delete");
});

test("scanFile reports one finding per uncovered pending mutation", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.saveMutation);",
      "    final Mutation<void> delete = ref.watch(EventDetailController.deleteMutation);",
      "    return Text(save.isPending || delete.isPending ? 'Working' : 'Ready');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.equal(findings.length, 2);
  assert.deepEqual(
    findings.map((finding) => finding.variableName),
    ["save", "delete"],
  );
  assert.deepEqual(
    findings.map((finding) => finding.mutationExpression),
    [
      "EventDetailController.saveMutation",
      "EventDetailController.deleteMutation",
    ],
  );
});

test("scanFile allows a listener for the matching pending mutation", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.saveMutation);",
      "    final Mutation<void> delete = ref.watch(EventDetailController.deleteMutation);",
      "    if (save.hasError) return const Text('Failed');",
      "    listenToCatchMutationErrors(context, ref, mutations: [EventDetailController.deleteMutation]);",
      "    return Text(delete.isPending ? 'Deleting' : 'Ready');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile allows mutation error helper lists for matching mutations", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.saveMutation);",
      "    final Mutation<void> delete = ref.watch(EventDetailController.deleteMutation);",
      "    final error = _firstMutationError([save, delete]);",
      "    return Text(save.isPending || delete.isPending ? 'Saving' : '$error');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile allows inline firstWhere hasError mutation lists", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.saveMutation);",
      "    final Mutation<void> delete = ref.watch(EventDetailController.deleteMutation);",
      "    final errorMutation = [save, delete].firstWhere((m) => m.hasError, orElse: () => save);",
      "    return Text(save.isPending || delete.isPending ? 'Saving' : '$errorMutation');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile normalizes multiline watch expressions with trailing commas", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(",
      "      EventDetailController.saveMutation,",
      "    );",
      "    listenToCatchMutationErrors(context, ref, mutations: [EventDetailController.saveMutation]);",
      "    return Text(save.isPending ? 'Saving' : 'Ready');",
      "  }",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile ignores direct pending guards outside build helpers", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.saveMutation);",
      "    if (save.hasError) return const Text('Failed');",
      "    return Text(save.isPending ? 'Saving' : 'Ready');",
      "  }",
      "}",
      "void runGuard(WidgetRef ref, Mutation<void> mutation) {",
      "  if (ref.read(mutation).isPending) return;",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile ignores non-build mutation pending reads", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_controller.dart",
    source: [
      "bool pending(EventDetailController controller) {",
      "  return controller.toggleSavedEventMutation.isPending;",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanMutationErrorSurfaces scans lib Dart files and ignores generated files", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-mutations-"));
  writeFile(
    root,
    "lib/events/presentation/event_detail_screen.dart",
    [
      "class EventDetailScreen extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.toggleSavedEventMutation);",
      "    return Text(save.isPending ? 'Saving' : 'Saved');",
      "  }",
      "}",
    ].join("\n"),
  );
  writeFile(
    root,
    "lib/events/presentation/event_detail_screen.g.dart",
    [
      "class Generated extends ConsumerWidget {",
      "  Widget build(BuildContext context, WidgetRef ref) {",
      "    final Mutation<void> save = ref.watch(EventDetailController.toggleSavedEventMutation);",
      "    return Text(save.isPending ? 'Saving' : 'Saved');",
      "  }",
      "}",
    ].join("\n"),
  );

  const result = scanMutationErrorSurfaces({root});

  assert.equal(result.checkedFiles, 1);
  assert.equal(result.findings.length, 1);
  assert.equal(
    result.findings[0].path,
    "lib/events/presentation/event_detail_screen.dart",
  );
});

function writeFile(root, relativePath, source) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}

for (const [surface, expected] of [
  ["CatchLocalizedErrorBanner.mutation(mutation: save)", 0],
  ["CatchLocalizedErrorBanner.mutation(mutation: other)", 1],
  ["CatchLocalizedErrorBanner(error)", 1],
  ["CatchLocalizedErrorBanner.mutation(mutation: EventController.saveMutation)", 0],
]) {
  test(`named mutation recipe covers only its matching input: ${surface}`, () => {
    const findings = scanFile({
      relativePath: "lib/events/presentation/event_editor.dart",
      source: `import 'package:flutter_riverpod/experimental/mutation.dart';
      class EventEditor extends ConsumerWidget {
        Widget build(BuildContext context, WidgetRef ref) {
          final save = ref.watch(EventController.saveMutation);
          return Column(children: [
            Text(save.isPending ? 'Saving' : 'Ready'),
            ${surface},
          ]);
        }
      }`,
    });
    assert.equal(findings.length, expected);
  });
}

for (const [handles, expected] of [
  ["handle", 0],
  ["other", 1],
  ["other, handle", 0],
  ["EventController.saveMutation('other')", 1],
]) {
  test(`subscription covers only its matching handle: ${handles}`, () => {
    const findings = scanFile({
      relativePath: "lib/events/presentation/event_editor.dart",
      source: `import 'package:flutter_riverpod/experimental/mutation.dart';
      class EventEditor extends ConsumerWidget {
        Widget build(BuildContext context, WidgetRef ref) {
          final handle = EventController.saveMutation('event');
          final MutationState<void> save = ref.watch(handle);
          listenToCatchMutationErrors(context, ref, mutations: [${handles}]);
          return Text(save.isPending ? 'Saving' : 'Ready');
        }
      }`,
    });
    assert.equal(findings.length, expected);
  });
}

test("subscription named argument order does not change matching", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_editor.dart",
    source: `import 'package:flutter_riverpod/experimental/mutation.dart';
    class EventEditor extends ConsumerWidget {
      Widget build(BuildContext context, WidgetRef ref) {
        final save = ref.watch(EventController.saveMutation);
        listenToCatchMutationErrors(context, ref,
          errorContext: AppErrorContext.event,
          mutations: [EventController.saveMutation]);
        return Text(save.isPending ? 'Saving' : 'Ready');
      }
    }`,
  });
  assert.deepEqual(findings, []);
});
