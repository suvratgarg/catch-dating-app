import 'package:catch_ui/src/components/catch_contract_field_constraints.dart';
import 'package:catch_ui/src/components/catch_toggle.dart';
import 'package:flutter/material.dart';

/// Exact 44x26 switch used by `CatchField.toggle`.
class CatchFieldToggle extends StatelessWidget {
  const CatchFieldToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.contract,
    this.contractExemption,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final CatchContractFieldConstraints? contract;
  final String? contractExemption;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CatchToggle.field(
      value: value,
      onChanged: onChanged,
      contract: contract,
      contractExemption: contractExemption,
      semanticLabel: semanticLabel,
    );
  }
}
