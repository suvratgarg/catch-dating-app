import 'dart:convert';

class RunDraft {
  const RunDraft({
    required this.id,
    required this.runClubId,
    required this.savedAt,
    this.distance,
    this.capacity,
    this.price,
    this.description,
    this.paceName,
    this.meetingPoint,
    this.locationDetails,
    this.startingPointLat,
    this.startingPointLng,
    this.selectedDateMillis,
    this.selectedStartHour,
    this.selectedStartMinute,
    this.durationMinutes = 60,
    this.minAge,
    this.maxAge,
    this.maxMen,
    this.maxWomen,
  });

  final String id;
  final String runClubId;
  final DateTime savedAt;

  // Run Details step
  final String? distance;
  final String? capacity;
  final String? price;
  final String? description;
  final String? paceName;

  // Where step
  final String? meetingPoint;
  final String? locationDetails;
  final double? startingPointLat;
  final double? startingPointLng;

  // When step
  final int? selectedDateMillis;
  final int? selectedStartHour;
  final int? selectedStartMinute;
  final int durationMinutes;

  // Rules step
  final String? minAge;
  final String? maxAge;
  final String? maxMen;
  final String? maxWomen;

  bool get isEmpty =>
      distance == null &&
      capacity == null &&
      price == null &&
      description == null &&
      paceName == null &&
      meetingPoint == null &&
      locationDetails == null &&
      startingPointLat == null &&
      selectedDateMillis == null &&
      minAge == null &&
      maxAge == null &&
      maxMen == null &&
      maxWomen == null;

  String get summary {
    final parts = <String>[];
    if (distance != null) {
      var distPart = '${distance!}km';
      if (paceName != null) distPart += ' $paceName';
      parts.add(distPart);
    } else if (paceName != null) {
      parts.add(paceName!);
    }
    if (meetingPoint != null) parts.add(meetingPoint!);
    if (selectedDateMillis != null) {
      final d = DateTime.fromMillisecondsSinceEpoch(selectedDateMillis!);
      parts.add('${d.day}/${d.month}');
    }
    if (parts.isEmpty) return 'Empty draft';
    return parts.join(' · ');
  }

  factory RunDraft.fromJson(Map<String, dynamic> json) => RunDraft(
        id: json['id'] as String,
        runClubId: json['runClubId'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        distance: json['distance'] as String?,
        capacity: json['capacity'] as String?,
        price: json['price'] as String?,
        description: json['description'] as String?,
        paceName: json['paceName'] as String?,
        meetingPoint: json['meetingPoint'] as String?,
        locationDetails: json['locationDetails'] as String?,
        startingPointLat: (json['startingPointLat'] as num?)?.toDouble(),
        startingPointLng: (json['startingPointLng'] as num?)?.toDouble(),
        selectedDateMillis: json['selectedDateMillis'] as int?,
        selectedStartHour: json['selectedStartHour'] as int?,
        selectedStartMinute: json['selectedStartMinute'] as int?,
        durationMinutes: (json['durationMinutes'] as int?) ?? 60,
        minAge: json['minAge'] as String?,
        maxAge: json['maxAge'] as String?,
        maxMen: json['maxMen'] as String?,
        maxWomen: json['maxWomen'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'runClubId': runClubId,
        'savedAt': savedAt.toIso8601String(),
        if (distance != null) 'distance': distance,
        if (capacity != null) 'capacity': capacity,
        if (price != null) 'price': price,
        if (description != null) 'description': description,
        if (paceName != null) 'paceName': paceName,
        if (meetingPoint != null) 'meetingPoint': meetingPoint,
        if (locationDetails != null) 'locationDetails': locationDetails,
        if (startingPointLat != null) 'startingPointLat': startingPointLat,
        if (startingPointLng != null) 'startingPointLng': startingPointLng,
        if (selectedDateMillis != null) 'selectedDateMillis': selectedDateMillis,
        if (selectedStartHour != null) 'selectedStartHour': selectedStartHour,
        if (selectedStartMinute != null)
          'selectedStartMinute': selectedStartMinute,
        'durationMinutes': durationMinutes,
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
        if (maxMen != null) 'maxMen': maxMen,
        if (maxWomen != null) 'maxWomen': maxWomen,
      };

  static List<RunDraft> listFromJson(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => RunDraft.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<RunDraft> drafts) =>
      jsonEncode(drafts.map((d) => d.toJson()).toList());
}
