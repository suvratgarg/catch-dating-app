// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Regenerate with:
//   node tool/design/build_lint_enforcement_tables.mjs

// Source: design/components/catch.components.json

// This file is deliberately dependency-free so the analyzer plugin can load it
// in a fresh isolate without importing application code.

const catchRawControlConstructors = <String>{
  'ActionChip',
  'AppBar',
  'Badge',
  'Card',
  'Chip',
  'ChoiceChip',
  'CupertinoNavigationBar',
  'FilterChip',
  'InputChip',
  'RawChip',
  'SliverAppBar',
};

const catchRawControlReplacements = <String, String>{
  'ActionChip': 'CatchChip',
  'AppBar': 'CatchTopBar or CatchScreenTopBar',
  'Badge': 'CatchBadge',
  'Card': 'CatchSurface or CatchSectionCard',
  'Chip': 'CatchChip',
  'ChoiceChip': 'CatchChip',
  'CupertinoNavigationBar': 'CatchTopBar or CatchScreenTopBar',
  'FilterChip': 'CatchChip',
  'InputChip': 'CatchChip',
  'RawChip': 'CatchChip',
  'SliverAppBar': 'a registered media-hero sliver or CatchTopBar',
};

const catchRawButtonControlConstructors = <String>{
  'CupertinoButton',
  'DropdownButton',
  'ElevatedButton',
  'FilledButton',
  'FloatingActionButton',
  'OutlinedButton',
  'PopupMenuButton',
  'Radio',
  'RangeSlider',
  'SegmentedButton',
  'Slider',
  'Switch',
  'TextButton',
  'TextField',
  'TextFormField',
};
