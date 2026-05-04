/// Generates `functions/src/shared/firestore.ts` from Dart freezed models.
///
/// Usage: dart tool/generate_firestore_types.dart
///
/// Reads the Dart freezed model files listed in [_modelConfigs], parses their
/// enums and factory constructors, maps them to TypeScript, merges in TS-only
/// additions from [firestore_ts_overlay.json], and writes the result to
/// functions/src/shared/firestore.ts.
///
/// CI enforces that the committed file matches the generated output — if you
/// change a Dart model, run this script and commit the result.

import 'dart:convert';
import 'dart:io';

final _projectRoot = Directory.current.path;

/// Models to generate TS interfaces for.
final _modelConfigs = <_ModelConfig>[
  _ModelConfig(
    dartPath: 'lib/user_profile/domain/user_profile.dart',
    tsName: 'UserProfileDoc',
    collectionPath: '/users/{uid}',
    idField: 'uid',
  ),
  _ModelConfig(
    dartPath: 'lib/public_profile/domain/public_profile.dart',
    tsName: 'PublicProfileDoc',
    collectionPath: '/publicProfiles/{uid}',
    idField: 'uid',
  ),
  _ModelConfig(
    dartPath: 'lib/run_clubs/domain/run_club.dart',
    tsName: 'RunClubDoc',
    collectionPath: '/runClubs/{clubId}',
    idField: 'id',
  ),
  _ModelConfig(
    dartPath: 'lib/runs/domain/run_constraints.dart',
    tsName: 'RunConstraints',
    collectionPath: null, // embedded in RunDoc, not a top-level collection
  ),
  _ModelConfig(
    dartPath: 'lib/runs/domain/run.dart',
    tsName: 'RunDoc',
    collectionPath: '/runs/{runId}',
    idField: 'id',
  ),
  _ModelConfig(
    dartPath: 'lib/payments/domain/payment.dart',
    tsName: 'PaymentDoc',
    collectionPath: '/payments/{paymentId}',
    idField: 'id',
  ),
  _ModelConfig(
    dartPath: 'lib/swipes/domain/swipe.dart',
    tsName: 'SwipeDoc',
    collectionPath: '/swipes/{userId}/outgoing/{targetId}',
  ),
  _ModelConfig(
    dartPath: 'lib/matches/domain/match.dart',
    tsName: 'MatchDoc',
    collectionPath: '/matches/{matchId}',
    idField: 'id',
  ),
  _ModelConfig(
    dartPath: 'lib/chats/domain/chat_message.dart',
    tsName: 'ChatMessageDoc',
    collectionPath: '/chats/{matchId}/messages/{messageId}',
    idField: 'id',
  ),
  _ModelConfig(
    dartPath: 'lib/reviews/domain/review.dart',
    tsName: 'ReviewDoc',
    collectionPath: '/reviews/{reviewId}',
    idField: 'id',
  ),
];

/// Extra Dart files that define enums used across models but don't have a
/// corresponding top-level TS interface.
final _extraEnumSources = <String>[
  'lib/core/indian_city.dart',
];

void main() {
  final allEnums = <String, List<String>>{};
  final allInterfaces = <_InterfaceInfo>[];

  // Phase 1: parse all Dart models.
  for (final config in _modelConfigs) {
    final source = File('$_projectRoot/${config.dartPath}').readAsStringSync();
    _parseEnums(source).forEach((name, values) {
      allEnums[name] = values;
    });
    allInterfaces.add(_parseInterface(source, config));
  }

  // Phase 2: parse extra enum sources.
  for (final path in _extraEnumSources) {
    final source = File('$_projectRoot/$path').readAsStringSync();
    _parseEnums(source).forEach((name, values) {
      allEnums[name] = values;
    });
  }

  // Phase 3: read overlay.
  final overlay = _readOverlay();

  // Phase 4: generate output.
  final buf = StringBuffer();
  _writeHeader(buf);
  _writeEnumTypes(buf, allEnums, overlay);
  _writeInterfaces(buf, allInterfaces, allEnums, overlay);
  _writeExtraInterfaces(buf, overlay);

  final outputPath = '$_projectRoot/functions/src/shared/firestore.ts';
  File(outputPath).writeAsStringSync(buf.toString());
  print('Generated $outputPath');
}

// ── Parsing ──────────────────────────────────────────────────────────────────

final _enumRegex = RegExp(r'enum\s+(\w+)\s*(?:implements\s+\w+\s*)?\{([^}]+)\}');

/// Enum names that are client-side only and should not appear in the TS output.
const _clientOnlyEnums = {'RunSignUpStatus', 'RunEligibility'};

Map<String, List<String>> _parseEnums(String source) {
  final enums = <String, List<String>>{};
  for (final match in _enumRegex.allMatches(source)) {
    final name = match.group(1)!;
    if (_clientOnlyEnums.contains(name)) continue;

    var body = match.group(2)!;

    // Only parse member declarations — strip class body after `;`.
    final semicolonIdx = body.indexOf(';');
    if (semicolonIdx >= 0) {
      body = body.substring(0, semicolonIdx);
    }

    // Remove doc-comment lines (///) and regular comment lines (//).
    body = body.replaceAll(RegExp(r'^\s*///.*$', multiLine: true), '');
    body = body.replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

    // Process line by line. Each non-empty line is an enum member.
    // If a member has constructor args (contains '('), extract the
    // identifier before '('. Otherwise, split by comma to handle
    // simple single-line enums like `{ active, blocked }`.
    final members = <String>[];
    for (final line in body.split('\n')) {
      var trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Strip trailing inline comments.
      final commentIdx = trimmed.indexOf('//');
      if (commentIdx >= 0) {
        trimmed = trimmed.substring(0, commentIdx).trim();
        if (trimmed.isEmpty) continue;
      }

      if (trimmed.contains('(')) {
        // Member with constructor args — extract name before '('.
        final wordMatch = RegExp(r'^(\w+)').firstMatch(trimmed);
        if (wordMatch != null) {
          members.add(wordMatch.group(1)!);
        }
      } else {
        // No constructor args — safe to split by comma.
        for (final part in trimmed.split(',')) {
          final p = part.trim();
          if (p.isEmpty) continue;
          final wordMatch = RegExp(r'^(\w+)').firstMatch(p);
          if (wordMatch != null) {
            members.add(wordMatch.group(1)!);
          }
        }
      }
    }
    if (members.isNotEmpty) {
      enums[name] = members;
    }
  }
  return enums;
}

final _annotationStripRegex = RegExp(
  r"@\w+(?:\([^)]*(?:\([^)]*\)[^)]*)*\))?\s*",
);

/// Strips leading Dart annotations from [line]. Handles nested parens
/// (e.g. `@Default(RunConstraints())`) by counting parenthesis depth.
String _stripAnnotations(String line) {
  while (line.startsWith('@')) {
    final afterAt = line.substring(1);
    // Find end of annotation name.
    final parenIdx = afterAt.indexOf('(');
    final spaceIdx = afterAt.indexOf(' ');

    if (parenIdx >= 0 && (spaceIdx < 0 || parenIdx < spaceIdx)) {
      // Annotation has arguments — count parens to find the matching ')'.
      var depth = 0;
      var i = parenIdx;
      while (i < afterAt.length) {
        if (afterAt[i] == '(') depth++;
        if (afterAt[i] == ')') depth--;
        i++;
        if (depth == 0) break;
      }
      line = afterAt.substring(i).trim();
    } else if (spaceIdx >= 0) {
      // Simple annotation without parens (e.g. @override).
      line = afterAt.substring(spaceIdx + 1).trim();
    } else {
      // Annotation-only line.
      return '';
    }
  }
  return line;
}

/// Extracts the body of `const factory ClassName({...})` using brace counting
/// so that `@Default({})` nested inside the body doesn't break parsing.
String _extractFactoryBody(String source) {
  final startPattern = RegExp(r'const factory \w+\(\{');
  final startMatch = startPattern.firstMatch(source);
  if (startMatch == null) {
    throw StateError('Could not find factory constructor');
  }

  final start = startMatch.end;
  var depth = 1;
  var i = start;
  while (i < source.length && depth > 0) {
    if (source[i] == '{') depth++;
    if (source[i] == '}') depth--;
    i++;
  }
  return source.substring(start, i - 1);
}

_InterfaceInfo _parseInterface(String source, _ModelConfig config) {
  final body = _extractFactoryBody(source);
  final fields = <_FieldInfo>[];
  var pendingAnnotation = '';

  for (final rawLine in body.split('\n')) {
    var line = rawLine.trim();

    // Skip blank lines and standalone comment lines.
    if (line.isEmpty || (line.startsWith('//') && !line.contains('@'))) {
      continue;
    }

    // If the line is a comment with trailing content, strip the comment.
    final commentIdx = line.indexOf('//');
    if (commentIdx >= 0) {
      line = line.substring(0, commentIdx).trim();
      if (line.isEmpty) continue;
    }

    // If this line has only annotations (no field content), save them
    // for the next line. Otherwise the annotations decorate this line's field.
    final withoutAnnotations = _stripAnnotations(line);
    if (withoutAnnotations.isEmpty) {
      pendingAnnotation = '$pendingAnnotation$line ';
      continue;
    }

    // Line has field content — prepend any pending annotation from previous line.
    line = '$pendingAnnotation$line';
    pendingAnnotation = '';

    // Skip doc-ID fields.
    if (line.contains('includeToJson: false')) continue;

    final field = _parseField(line);
    if (field != null) {
      fields.add(field);
    }
  }

  return _InterfaceInfo(
    config: config,
    fields: fields,
  );
}

_FieldInfo? _parseField(String line) {
  // Remove trailing comma and semicolon.
  line = line.replaceAll(RegExp(r'[,;]\s*$'), '').trim();
  if (line.isEmpty) return null;

  final hasRequired = line.contains(RegExp(r'\brequired\b'));
  final hasDefault = line.contains('@Default(');
  final isTimestamp = line.contains('@TimestampConverter()');
  final isNullableTimestamp = line.contains('@NullableTimestampConverter()');

  // Strip annotations.
  var stripped = _stripAnnotations(line);
  // Strip 'required' keyword.
  stripped = stripped.replaceFirst(RegExp(r'\brequired\s+'), '');
  stripped = stripped.trim();

  // Split into type and name.
  final parts = stripped.split(RegExp(r'\s+'));
  if (parts.length < 2) return null;
  final name = parts.last;
  final dartType = parts.sublist(0, parts.length - 1).join(' ');

  final isNullable = dartType.endsWith('?');
  final baseType = isNullable ? dartType.substring(0, dartType.length - 1) : dartType;
  // Optional in TS if the field isn't `required` and has no `@Default`.
  // @Default guarantees a value is always written to Firestore.
  final isOptional = isNullable && !hasRequired && !hasDefault;

  return _FieldInfo(
    name: name,
    dartType: baseType,
    isOptional: isOptional,
    isTimestamp: isTimestamp || isNullableTimestamp,
  );
}

// ── Overlay ──────────────────────────────────────────────────────────────────

Map<String, dynamic> _readOverlay() {
  final path = '$_projectRoot/tool/firestore_ts_overlay.json';
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json;
}

// ── Type mapping ─────────────────────────────────────────────────────────────

String _mapDartTypeToTs(String dartType) {
  // Handle generics: List<T> → T[], Map<K,V> → Record<K,V>
  final listMatch = RegExp(r'^List<(.+)>$').firstMatch(dartType);
  if (listMatch != null) {
    return '${_mapDartTypeToTs(listMatch.group(1)!)}[]';
  }

  final mapMatch = RegExp(r'^Map<String,\s*(.+)>$').firstMatch(dartType);
  if (mapMatch != null) {
    return 'Record<string, ${_mapDartTypeToTs(mapMatch.group(1)!)}>';
  }

  // Primitives.
  switch (dartType) {
    case 'String':
      return 'string';
    case 'int':
    case 'double':
      return 'number';
    case 'bool':
      return 'boolean';
    case 'DateTime':
      return 'FirebaseFirestore.Timestamp';
  }

  // Everything else is a custom type (enum, nested freezed type, etc.).
  // Pass through as-is — it must match a generated TS type alias or interface.
  return dartType;
}

String _fieldTsType(_FieldInfo field) {
  final base = field.isTimestamp ? 'FirebaseFirestore.Timestamp' : _mapDartTypeToTs(field.dartType);
  return field.isOptional ? '$base | null' : base;
}

// ── Output generation ────────────────────────────────────────────────────────

void _writeHeader(StringBuffer buf) {
  buf.writeln('/**');
  buf.writeln(' * Firestore document interfaces for Cloud Functions.');
  buf.writeln(' *');
  buf.writeln(' * AUTO-GENERATED by tool/generate_firestore_types.dart');
  buf.writeln(' * DO NOT EDIT DIRECTLY.');
  buf.writeln(' *');
  buf.writeln(' * To update: dart tool/generate_firestore_types.dart');
  buf.writeln(' *');
  buf.writeln(' * These mirror the Dart freezed models in lib/<feature>/domain/<Model>.dart.');
  buf.writeln(' * Enum values match what Dart\'s json_serializable serialises by default');
  buf.writeln(' * (enum member name, camelCase — e.g. DrinkingHabit.socially → "socially").');
  buf.writeln(' *');
  buf.writeln(' * Fields marked with @JsonKey(includeToJson: false) in Dart are the');
  buf.writeln(' * document ID and are NOT stored inside the document data.');
  buf.writeln(' *');
  buf.writeln(' * Timestamps are stored as Firestore timestamps in the DB. In admin SDK');
  buf.writeln(' * code, use FirebaseFirestore.Timestamp and FieldValue.serverTimestamp()');
  buf.writeln(' * to write.');
  buf.writeln(' */');
  buf.writeln();
  buf.writeln('// FirebaseFirestore.Timestamp is available globally via');
  buf.writeln('// @google-cloud/firestore, a transitive dependency of firebase-admin.');
  buf.writeln();
}

void _writeEnumTypes(
  StringBuffer buf,
  Map<String, List<String>> allEnums,
  Map<String, dynamic> overlay,
) {
  buf.writeln('// ── Shared enum types ────────────────────────────────────────────────────');
  buf.writeln();

  final extraEnums =
      (overlay['extraEnumTypes'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

  // Collect all enum type names for output.
  final names = <String>[...allEnums.keys];
  for (final extra in extraEnums) {
    names.add(extra['name'] as String);
  }
  names.sort();

  for (final name in names) {
    if (allEnums.containsKey(name)) {
      final values = allEnums[name]!;
      if (values.length <= 4) {
        buf.writeln('export type $name = ${values.map((v) => '"$v"').join(' | ')};');
      } else {
        buf.writeln('export type $name =');
        for (var i = 0; i < values.length; i++) {
          final delim = i == values.length - 1 ? ';' : '';
          buf.writeln('  | "${values[i]}"$delim');
        }
      }
    } else {
      // Extra enum from overlay — write its values directly.
      final extra = extraEnums.firstWhere((e) => e['name'] == name);
      final values = (extra['values'] as List<dynamic>).cast<String>();
      if (values.length <= 4) {
        buf.writeln('export type $name = ${values.map((v) => '"$v"').join(' | ')};');
      } else {
        buf.writeln('export type $name =');
        for (var i = 0; i < values.length; i++) {
          final delim = i == values.length - 1 ? ';' : '';
          buf.writeln('  | "${values[i]}"$delim');
        }
      }
    }
    buf.writeln();
  }
}

void _writeInterfaces(
  StringBuffer buf,
  List<_InterfaceInfo> interfaces,
  Map<String, List<String>> allEnums,
  Map<String, dynamic> overlay,
) {
  buf.writeln('// ── Document interfaces ──────────────────────────────────────────────────');
  buf.writeln();

  final extraFields =
      (overlay['extraFields'] as Map<String, dynamic>? ?? {});
  final fieldOverrides =
      (overlay['fieldOverrides'] as Map<String, dynamic>? ?? {});
  final interfaceComments =
      (overlay['interfaceComments'] as Map<String, dynamic>? ?? {});
  final fieldComments =
      (overlay['fieldComments'] as Map<String, dynamic>? ?? {});

  for (final iface in interfaces) {
    final config = iface.config;
    final extra =
        (extraFields[config.tsName] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final overrides = <String>{
      ...?(fieldOverrides[config.tsName] as List<dynamic>?)?.cast<String>(),
    };
    final ifaceComment = interfaceComments[config.tsName] as String?;
    final fieldCommentMap =
        (fieldComments[config.tsName] as Map<String, dynamic>? ?? {});

    // JSDoc.
    buf.writeln('/**');
    if (config.collectionPath != null) {
      buf.writeln(' * ${config.collectionPath}');
    }
    buf.writeln(' * Dart: ${config.dartPath} — ${config.dartName}');
    if (config.idField != null) {
      buf.writeln(' * Note: "${config.idField}" is the document ID, not stored'
          ' in the document data.');
    }
    if (ifaceComment != null) {
      buf.writeln(' * $ifaceComment');
    }
    buf.writeln(' */');

    buf.writeln('export interface ${config.tsName} {');

    // Write Dart-derived fields.
    for (final field in iface.fields) {
      final comment = fieldCommentMap[field.name] as String?;

      // Skip id fields and fields overridden by the overlay.
      if (field.name == config.idField) continue;
      if (overrides.contains(field.name)) continue;

      if (comment != null) {
        buf.writeln('  /** $comment */');
      }
      final tsType = _fieldTsType(field);
      final optional = field.isOptional ? '?' : '';
      buf.writeln('  ${field.name}$optional: $tsType;');
    }

    // Write extra fields from overlay.
    for (final extraField in extra) {
      final comment = extraField['comment'] as String?;
      if (comment != null) {
        buf.writeln('  /** $comment */');
      }
      final optional = extraField['optional'] == true ? '?' : '';
      buf.writeln('  ${extraField['name']}$optional: ${extraField['tsType']};');
    }

    buf.writeln('}');
    buf.writeln();
  }
}

void _writeExtraInterfaces(
  StringBuffer buf,
  Map<String, dynamic> overlay,
) {
  final extraInterfaces =
      (overlay['extraInterfaces'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

  if (extraInterfaces.isEmpty) return;

  buf.writeln('// ── Server-only interfaces (no Dart model) ────────────────────────────────');
  buf.writeln();

  for (final iface in extraInterfaces) {
    final fields = (iface['fields'] as List<dynamic>).cast<Map<String, dynamic>>();

    buf.writeln('/**');
    buf.writeln(' * ${iface['collectionPath']}');
    if (iface['comment'] != null) {
      buf.writeln(' * ${iface['comment']}');
    }
    buf.writeln(' */');
    buf.writeln('export interface ${iface['name']} {');
    for (final field in fields) {
      final optional = field['optional'] == true ? '?' : '';
      buf.writeln('  ${field['name']}$optional: ${field['tsType']};');
    }
    buf.writeln('}');
    buf.writeln();
  }
}

// ── Data types ───────────────────────────────────────────────────────────────

class _ModelConfig {
  final String dartPath;
  final String tsName;
  final String? collectionPath;
  final String? idField;

  const _ModelConfig({
    required this.dartPath,
    required this.tsName,
    this.collectionPath,
    this.idField,
  });

  /// The Dart class name (last segment of dartPath without extension).
  String get dartName {
    final file = dartPath.split('/').last;
    // Convert snake_case file name to PascalCase class name.
    return file
        .replaceAll('.dart', '')
        .split('_')
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join();
  }
}

class _FieldInfo {
  final String name;
  final String dartType; // base type without ?
  final bool isOptional;
  final bool isTimestamp;

  const _FieldInfo({
    required this.name,
    required this.dartType,
    required this.isOptional,
    required this.isTimestamp,
  });
}

class _InterfaceInfo {
  final _ModelConfig config;
  final List<_FieldInfo> fields;

  const _InterfaceInfo({required this.config, required this.fields});
}
