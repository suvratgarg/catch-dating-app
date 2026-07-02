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
  assert.equal(findings[0].pendingLines.length, 1);
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
