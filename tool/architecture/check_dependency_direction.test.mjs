import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {scanDependencyDirection, scanFile} from "./check_dependency_direction.mjs";

test("scanFile flags domain framework imports", () => {
  const findings = scanFile({
    relativePath: "lib/events/domain/event.dart",
    source: "import 'package:cloud_firestore/cloud_firestore.dart';\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "domainFrameworkImport",
  ]);
  assert.equal(findings[0].import, "package:cloud_firestore/cloud_firestore.dart");
});

test("scanFile flags newly introduced non-allowlisted domain packages", () => {
  const findings = scanFile({
    relativePath: "lib/events/domain/event.dart",
    source: "import 'package:url_launcher/url_launcher.dart';\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "domainFrameworkImport",
  ]);
});

test("scanFile allows domain pure Dart, annotation, collection, and app imports", () => {
  const findings = scanFile({
    relativePath: "lib/events/domain/event.dart",
    source: [
      "import 'dart:convert';",
      "import 'package:catch_dating_app/core/firestore_converters.dart';",
      "import 'package:collection/collection.dart';",
      "import 'package:freezed_annotation/freezed_annotation.dart';",
      "import 'package:json_annotation/json_annotation.dart';",
      "import 'package:meta/meta.dart';",
      "import 'package:pub_semver/pub_semver.dart';",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile flags domain DateTime.now access", () => {
  const findings = scanFile({
    relativePath: "lib/events/domain/event.dart",
    source: [
      "class Event {",
      "  bool get isPast => startTime.isBefore(DateTime.now());",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "domainClockAccess",
  ]);
});

test("scanFile allows domain predicates that receive an injected clock", () => {
  const findings = scanFile({
    relativePath: "lib/events/domain/event.dart",
    source: [
      "class Event {",
      "  bool isPast(DateTime now) => startTime.isBefore(now);",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile ignores DateTime.now outside domain files", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: "final now = DateTime.now();\n",
  });

  assert.deepEqual(findings, []);
});

test("scanFile flags data/domain imports of feature presentation", () => {
  const findings = scanFile({
    relativePath: "lib/events/data/event_repository.dart",
    source:
      "import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "dataDomainPresentationImport",
  ]);
});

test("scanFile flags sibling feature widget imports", () => {
  const findings = scanFile({
    relativePath: "lib/dashboard/presentation/widgets/dashboard_full.dart",
    source:
      "import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "crossFeaturePresentationImport",
  ]);
});

test("scanFile allows sanctioned cross-feature controller seams from screens and controllers", () => {
  const screenFindings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source:
      "import 'package:catch_dating_app/clubs/presentation/detail/club_host_contact_controller.dart';\n",
  });
  const controllerFindings = scanFile({
    relativePath: "lib/auth/presentation/auth_session_controller.dart",
    source:
      "import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';\n",
  });

  assert.deepEqual(screenFindings, []);
  assert.deepEqual(controllerFindings, []);
});

test("scanFile keeps widget and state imports of sibling controllers as debt", () => {
  const widgetFindings = scanFile({
    relativePath: "lib/dashboard/presentation/widgets/dashboard_full.dart",
    source:
      "import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';\n",
  });
  const stateFindings = scanFile({
    relativePath: "lib/user_profile/presentation/self_profile_screen_state.dart",
    source:
      "import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';\n",
  });

  assert.deepEqual(widgetFindings.map((finding) => finding.rule), [
    "crossFeaturePresentationImport",
  ]);
  assert.deepEqual(stateFindings.map((finding) => finding.rule), [
    "crossFeaturePresentationImport",
  ]);
});

test("scanFile allows same-feature and core presentation imports", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "import 'package:catch_dating_app/core/presentation/catch_async_state.dart';",
      "import 'package:catch_dating_app/events/presentation/event_detail_screen_state.dart';",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanFile flags data stream timeouts", () => {
  const findings = scanFile({
    relativePath: "lib/events/data/event_repository.dart",
    source: "final stream = snapshots().timeout(const Duration(seconds: 5));\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "dataStreamTimeout",
  ]);
});

test("scanFile allows data streams without timeouts", () => {
  const findings = scanFile({
    relativePath: "lib/events/data/event_repository.dart",
    source: "final stream = snapshots().map((snapshot) => snapshot.docs);\n",
  });

  assert.deepEqual(findings, []);
});

test("scanFile honors stream timeout override comments", () => {
  const previousLineFindings = scanFile({
    relativePath: "lib/events/data/event_repository.dart",
    source: [
      "// architecture:allow stream-timeout -- reason: non-Firestore socket deadline",
      "final stream = socketEvents.timeout(const Duration(seconds: 5));",
    ].join("\n"),
  });
  const sameLineFindings = scanFile({
    relativePath: "lib/events/data/event_repository.dart",
    source:
      "final stream = socketEvents.timeout(const Duration(seconds: 5)); // architecture:allow stream-timeout -- reason: protocol deadline\n",
  });

  assert.deepEqual(previousLineFindings, []);
  assert.deepEqual(sameLineFindings, []);
});

test("scanFile flags presentation plugin imports outside controllers and services", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/widgets/event_pins_map.dart",
    source:
      "import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "presentationPluginImport",
  ]);
  assert.equal(
    findings[0].import,
    "package:google_maps_flutter/google_maps_flutter.dart",
  );
});

test("scanFile allows presentation plugin imports in controllers and services", () => {
  const controllerFindings = scanFile({
    relativePath: "lib/hosts/presentation/create_event_controller.dart",
    source: "import 'package:image_picker/image_picker.dart';\n",
  });
  const serviceFindings = scanFile({
    relativePath: "lib/events/presentation/location_service.dart",
    source: "import 'package:geolocator/geolocator.dart';\n",
  });

  assert.deepEqual(controllerFindings, []);
  assert.deepEqual(serviceFindings, []);
});

test("scanFile allows non-plugin presentation imports", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: "import 'package:intl/intl.dart';\n",
  });

  assert.deepEqual(findings, []);
});

test("scanFile flags WidgetRef parameters below route build methods", () => {
  const findings = scanFile({
    relativePath: "lib/explore/presentation/widgets/explore_body.dart",
    source: "List<Widget> buildRows(BuildContext context, WidgetRef ref) => [];\n",
  });
  const buildFindings = scanFile({
    relativePath: "lib/explore/presentation/explore_screen.dart",
    source:
      "class ExploreScreen extends ConsumerWidget { Widget build(BuildContext context, WidgetRef ref) => const SizedBox(); }\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "widgetRefParameter",
  ]);
  assert.deepEqual(buildFindings, []);
});

test("scanFile flags repository provider reads from presentation widgets", () => {
  const widgetFindings = scanFile({
    relativePath: "lib/explore/presentation/widgets/explore_city_picker.dart",
    source: "final cities = ref.watch(cityRepositoryProvider);\n",
  });
  const viewModelFindings = scanFile({
    relativePath: "lib/explore/presentation/explore_view_model.dart",
    source: "final repository = ref.watch(exploreRepositoryProvider);\n",
  });

  assert.deepEqual(widgetFindings.map((finding) => finding.rule), [
    "widgetRepositoryProviderRead",
  ]);
  assert.deepEqual(viewModelFindings, []);
});

test("scanFile flags unannotated feature-root presentation barrel exports", () => {
  const missingFindings = scanFile({
    relativePath: "lib/events/events.dart",
    source: "export 'presentation/event_detail_screen.dart';\n",
  });
  const sameLineFindings = scanFile({
    relativePath: "lib/events/events.dart",
    source:
      "export 'presentation/event_detail_screen.dart'; // public-api: route entry point\n",
  });
  const previousLineFindings = scanFile({
    relativePath: "lib/events/events.dart",
    source:
      "// public-api: route entry point\nexport 'presentation/event_detail_screen.dart';\n",
  });
  const nestedBarrelFindings = scanFile({
    relativePath: "lib/events/presentation/widgets/event_tiles.dart",
    source: "export 'presentation/event_detail_screen.dart';\n",
  });

  assert.deepEqual(missingFindings.map((finding) => finding.rule), [
    "barrelPresentationExport",
  ]);
  assert.deepEqual(sameLineFindings, []);
  assert.deepEqual(previousLineFindings, []);
  assert.deepEqual(nestedBarrelFindings, []);
});

test("scanFile flags provider-coupled presentation state files", () => {
  const importFindings = scanFile({
    relativePath: "lib/chats/presentation/chat_route_state.dart",
    source: "import 'package:flutter_riverpod/flutter_riverpod.dart';\n",
  });
  const providerFindings = scanFile({
    relativePath: "lib/chats/presentation/chat_route_state.dart",
    source: "final value = Provider<int>((ref) => 1);\n",
  });
  const pureFindings = scanFile({
    relativePath: "lib/chats/presentation/chat_route_state.dart",
    source: "class ChatRouteState { const ChatRouteState(); }\n",
  });

  assert.deepEqual(importFindings.map((finding) => finding.rule), [
    "stateFileProviderImport",
  ]);
  assert.deepEqual(providerFindings.map((finding) => finding.rule), [
    "stateFileProviderImport",
    "manualProviderDeclaration",
  ]);
  assert.deepEqual(pureFindings, []);
});

test("scanFile flags undocumented keepAlive providers", () => {
  const missingFindings = scanFile({
    relativePath: "lib/chats/presentation/inbox/chats_list_view_model.dart",
    source: "@Riverpod(keepAlive: true)\nString chatSearchQuery(Ref ref) => '';\n",
  });
  const documentedFindings = scanFile({
    relativePath: "lib/chats/presentation/inbox/chats_list_view_model.dart",
    source:
      "// keepalive: preserve search text across tab switches\n@Riverpod(keepAlive: true)\nString chatSearchQuery(Ref ref) => '';\n",
  });

  assert.deepEqual(missingFindings.map((finding) => finding.rule), [
    "undocumentedKeepAlive",
  ]);
  assert.deepEqual(documentedFindings, []);
});

test("scanFile flags manual provider declarations outside core", () => {
  const featureFindings = scanFile({
    relativePath: "lib/chats/presentation/chat_route_view_model.dart",
    source: "final stateProvider = Provider.family<ChatRouteState, Args>((ref, args) {});\n",
  });
  const coreFindings = scanFile({
    relativePath: "lib/core/firebase_providers.dart",
    source: "final appProvider = Provider<FirebaseApp>((ref) => throw UnimplementedError());\n",
  });

  assert.deepEqual(featureFindings.map((finding) => finding.rule), [
    "manualProviderDeclaration",
  ]);
  assert.deepEqual(coreFindings, []);
});

test("scanFile flags display state classes misplaced outside state files", () => {
  const findings = scanFile({
    relativePath: "lib/hosts/presentation/host_operations_screen.dart",
    source: [
      "class HostClubsScreenState {",
      "  const HostClubsScreenState();",
      "  factory HostClubsScreenState.from(Object source) => const HostClubsScreenState();",
      "}",
    ].join("\n"),
  });
  const stateFileFindings = scanFile({
    relativePath: "lib/hosts/presentation/host_clubs_screen_state.dart",
    source: [
      "class HostClubsScreenState {",
      "  const HostClubsScreenState();",
      "  factory HostClubsScreenState.from(Object source) => const HostClubsScreenState();",
      "}",
    ].join("\n"),
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "misplacedStateClass",
  ]);
  assert.deepEqual(stateFileFindings, []);
});

test("scanFile flags presentation files with multiple route screens", () => {
  const findings = scanFile({
    relativePath: "lib/hosts/presentation/host_operations_screen.dart",
    source: [
      "class HostOperationsHomeScreen extends StatelessWidget {}",
      "class HostClubsScreen extends ConsumerWidget {}",
    ].join("\n"),
  });
  const singleFindings = scanFile({
    relativePath: "lib/hosts/presentation/host_clubs_screen.dart",
    source: "class HostClubsScreen extends StatelessWidget {}\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "multiRouteScreenFile",
  ]);
  assert.deepEqual(singleFindings, []);
});

test("scanDependencyDirection flags untracked state adapters as a hard gate", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-dependency-"));
  writeFile(
    root,
    "lib/events/presentation/event_detail_screen_state.dart",
    "class EventDetailScreenState { const EventDetailScreenState(); }\n",
  );
  writeJson(root, "docs/audit_registry/architecture_pattern_adoption.json", {
    patterns: [],
  });

  const result = scanDependencyDirection({
    root,
    baseline: {
      allowedFindings: [
        {
          rule: "untrackedStateAdapter",
          path: "lib/events/presentation/event_detail_screen_state.dart",
        },
      ],
    },
  });

  assert.equal(result.findings.length, 1);
  assert.equal(result.findings[0].rule, "untrackedStateAdapter");
});

test("scanDependencyDirection allows registered state adapters", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-dependency-"));
  writeFile(
    root,
    "lib/events/presentation/event_detail_screen_state.dart",
    "class EventDetailScreenState { const EventDetailScreenState(); }\n",
  );
  writeJson(root, "docs/audit_registry/architecture_pattern_adoption.json", {
    patterns: [
      {
        adopters: [
          {path: "lib/events/presentation/event_detail_screen_state.dart"},
        ],
      },
    ],
  });

  const result = scanDependencyDirection({root, baseline: {allowedFindings: []}});

  assert.deepEqual(result.findings, []);
});

test("scanDependencyDirection ratchets baseline findings", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-dependency-"));
  writeFile(
    root,
    "lib/events/domain/event.dart",
    "import 'package:cloud_firestore/cloud_firestore.dart';\n",
  );
  writeFile(
    root,
    "lib/hosts/presentation/host_event_manage_screen.dart",
    "import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';\n",
  );
  writeFile(
    root,
    "lib/events/domain/event_time_policy.dart",
    "bool isPast(DateTime startTime) => startTime.isBefore(DateTime.now());\n",
  );

  const baseline = {
    allowedFindings: [
      {
        rule: "domainFrameworkImport",
        path: "lib/events/domain/event.dart",
        import: "package:cloud_firestore/cloud_firestore.dart",
      },
      {
        rule: "domainClockAccess",
        path: "lib/events/domain/event_time_policy.dart",
      },
    ],
  };

  const result = scanDependencyDirection({root, baseline});

  assert.equal(result.baselineFindings.length, 2);
  assert.equal(result.findings.length, 1);
  assert.equal(result.findings[0].rule, "crossFeaturePresentationImport");
});

function writeFile(root, relativePath, source) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}

function writeJson(root, relativePath, value) {
  writeFile(root, relativePath, `${JSON.stringify(value, null, 2)}\n`);
}
