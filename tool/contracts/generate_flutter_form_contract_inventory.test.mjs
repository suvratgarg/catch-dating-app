import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  buildFormContractInventory,
  scanCatchFieldCalls,
} from "./generate_flutter_form_contract_inventory.mjs";

test("known-bad missing binding is detected", () => {
  const results = scanCatchFieldCalls({
    source: `
      CatchField.input(
        title: 'Name',
        controller: controller,
      );
    `,
  });

  assert.equal(results.length, 1);
  assert.equal(results[0].contract, null);
});

test("records top-level generated bindings without accepting nested arguments", () => {
  const results = scanCatchFieldCalls({
    source: `
      CatchField.control(
        title: 'Range',
        contract: CatchContractConstraints.userProfileDocumentAgeRange,
        control: Builder(
          builder: (_) => CatchField.input(
            title: 'Nested',
            contract: nestedContract,
          ),
        ),
      );
    `,
  });

  assert.deepEqual(
    results.map((entry) => entry.contract),
    ["CatchContractConstraints.userProfileDocumentAgeRange"],
  );
});

test("range sliders require both generated endpoint bindings", () => {
  const results = scanCatchFieldCalls({
    source: `
      CatchRangeSlider(
        minimumContract: minimumContract,
        values: values,
        onChanged: onChanged,
      );
    `,
  });

  assert.equal(results.length, 1);
  assert.equal(results[0].minimumContract, "minimumContract");
  assert.equal(results[0].maximumContract, null);
});

test("inventory includes bound and unbound product callsites", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-form-contracts-"));
  write(
    root,
    "lib/feature/form.dart",
    `
      final bound = CatchField.toggle(
        title: 'Enabled',
        contract: enabledContract,
        value: true,
        onChanged: null,
      );
      final unbound = CatchField.input(title: 'Name');
      final chips = CatchChipField<String>(
        label: 'Kinds',
        contract: kindsContract,
      );
      final option = CatchOptionGroup<String>(
        contract: optionContract,
        options: options,
        selected: selected,
      );
      final search = CatchSearchField(
        contract: searchContract,
        value: query,
      );
      final topBarSearch = CatchTopBarSearch(
        contract: queryContract,
        placeholder: 'Search',
        tooltip: 'Search',
      );
      final otp = CatchOtpCodeField(
        contract: otpContract,
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
      final range = CatchRangeSlider(
        minimumContract: minContract,
        maximumContract: maxContract,
        values: values,
        onChanged: onChanged,
      );
      final missingRange = CatchRangeSlider(
        minimumContract: minContract,
        values: values,
        onChanged: onChanged,
      );
    `,
  );
  write(
    root,
    "lib/core/widgets/catch_field.dart",
    "final ignored = CatchField.input(title: 'Definition');",
  );

  const inventory = buildFormContractInventory({repoRoot: root});

  assert.equal(inventory.summary.editableCallsites, 9);
  assert.equal(inventory.summary.boundCallsites, 7);
  assert.equal(inventory.summary.unboundCallsites, 2);
});

function write(root, relative, source) {
  const file = path.join(root, relative);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}
