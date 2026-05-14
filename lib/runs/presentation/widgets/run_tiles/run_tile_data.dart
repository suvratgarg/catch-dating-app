import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';

enum RunTileStatus {
  open,
  joined,
  saved,
  recommended,
  hosted,
  waitlisted,
  attended,
  past,
  full,
  ineligible,
  cancelled,
}

class RunTileData {
  const RunTileData({
    required this.run,
    required this.status,
    this.clubName,
    this.reasonLabel,
    this.positionLabel,
  });

  factory RunTileData.fromRun({
    required Run run,
    RunTileStatus status = RunTileStatus.open,
    String? clubName,
    String? reasonLabel,
    String? positionLabel,
  }) {
    return RunTileData(
      run: run,
      status: status,
      clubName: clubName,
      reasonLabel: reasonLabel,
      positionLabel: positionLabel,
    );
  }

  final Run run;
  final RunTileStatus status;
  final String? clubName;
  final String? reasonLabel;
  final String? positionLabel;

  String get runClubId => run.runClubId;
  String get runId => run.id;
  String get title => run.title;
  String get meetingPoint => run.meetingPoint;
  String get dateLabel => run.shortDateLabel;
  String get longDateLabel => run.longDateLabel;
  String get timeLabel => RunFormatters.time(run.startTime);
  String get timeRangeLabel => run.timeRangeLabel;
  String get compactTimeRangeLabel => run.compactTimeRangeLabel;
  String get distanceLabel => run.distanceLabel;
  String get paceLabel => run.pace.label;
  String get signupLabel =>
      '${run.signedUpCount}/${run.capacityLimit} signed up';
  String get spotsLabel => '${run.signedUpCount}/${run.capacityLimit} spots';
  String get priceLabel => run.priceInPaise <= 0
      ? 'Free'
      : RunFormatters.priceInPaise(run.priceInPaise);
  bool get hasExactStartingPoint => run.hasExactStartingPoint;
}
