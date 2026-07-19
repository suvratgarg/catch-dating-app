// GENERATED CODE - DO NOT MODIFY BY HAND.
// Copied into tool/catch_ui_lints_probe by check_catch_ui_lints.sh.
import 'package:flutter/material.dart';

class GeneratedCatchUiLintProbe extends StatelessWidget {
  const GeneratedCatchUiLintProbe({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // catch.badge: catch_no_raw_material_control
        Badge(label: const Text('1')),
        // catch.button: catch_no_raw_button_control
        ElevatedButton(onPressed: null, child: const Text('x')),
        // catch.chip: catch_no_raw_material_control
        Chip(label: const Text('x')),
        // catch.field: catch_no_raw_button_control
        TextField(),
        // catch.menu: catch_no_raw_button_control
        PopupMenuButton<void>(itemBuilder: (_) => const []),
        // catch.surface: catch_no_raw_material_control
        Card(child: const SizedBox()),
        // catch.top_bar: catch_no_raw_material_control
        AppBar(),
        // catch.range_slider: catch_no_raw_button_control
        Slider(value: 0.5, onChanged: (_) {}),
        // catch.toggle: catch_no_raw_button_control
        Switch(value: false, onChanged: (_) {}),
      ],
    );
  }
}
