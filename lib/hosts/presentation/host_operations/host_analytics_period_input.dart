part of '../host_operations_screen.dart';

class HostAnalyticsPeriodInput extends StatelessWidget {
  const HostAnalyticsPeriodInput({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final HostClubInsightsRangePreset selected;
  final ValueChanged<HostClubInsightsRangePreset> onChanged;
  @override
  Widget build(BuildContext context) => CatchSection.content(
    title: context.l10n.hostsHostAnalyticsLabelPerformancePeriod,
    child: CatchChoiceInput<HostClubInsightsRangePreset>.segmented(
      contract:
          CatchContractConstraints.hostAnalyticsQueryCallablePayloadRangePreset,
      contractValueBuilder: (preset) => switch (preset) {
        HostClubInsightsRangePreset.thirtyDays => '30d',
        HostClubInsightsRangePreset.ninetyDays => '90d',
        HostClubInsightsRangePreset.twelveMonths => '12m',
      },
      selected: selected,
      onChanged: onChanged,
      options: [
        CatchOption(
          value: HostClubInsightsRangePreset.thirtyDays,
          label: context.l10n.hostsHostAnalyticsLabel30Days,
        ),
        CatchOption(
          value: HostClubInsightsRangePreset.ninetyDays,
          label: context.l10n.hostsHostAnalyticsLabel90Days,
        ),
        CatchOption(
          value: HostClubInsightsRangePreset.twelveMonths,
          label: context.l10n.hostsHostAnalyticsLabel12Months,
        ),
      ],
    ),
  );
}
