// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_constraints.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunConstraints _$RunConstraintsFromJson(Map<String, dynamic> json) =>
    _RunConstraints(
      minAge: (json['minAge'] as num?)?.toInt() ?? 0,
      maxAge: (json['maxAge'] as num?)?.toInt() ?? 99,
      maxMen: (json['maxMen'] as num?)?.toInt(),
      maxWomen: (json['maxWomen'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RunConstraintsToJson(_RunConstraints instance) =>
    <String, dynamic>{
      'minAge': instance.minAge,
      'maxAge': instance.maxAge,
      'maxMen': instance.maxMen,
      'maxWomen': instance.maxWomen,
    };
