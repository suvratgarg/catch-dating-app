part of 'host_customers_screen.dart';

// Directory dialogs own navigation results and refresh only their source data.
extension _HostCustomersDirectoryActions on _HostCustomersScreenState {
  Future<void> _reviewDuplicates(String organizerId) async {
    final changed = await showCatchBottomSheet<bool>(
      context: context,
      builder: (_) => HostContactMergeReviewSheet(organizerId: organizerId),
    );
    if (!mounted || changed != true) return;
    ref.invalidate(hostCustomersDirectoryControllerProvider);
    ref.invalidate(hostCrmSummaryProvider(organizerId));
  }

  Future<void> _openAudienceEditor(
    Club club, {
    HostSavedAudience? audience,
  }) async {
    final saved = await context.pushNamed<HostSavedAudience>(
      audience == null
          ? Routes.hostCreateSavedAudienceScreen.name
          : Routes.hostSavedAudienceDetailScreen.name,
      pathParameters: audience == null
          ? const {}
          : {'audienceId': audience.audienceId},
      queryParameters: {'organizerId': club.id},
      extra: audience,
    );
    if (!mounted || saved == null) return;
    ref.invalidate(hostSavedAudiencesProvider(club.id));
    ref.invalidate(hostAllSavedAudiencesProvider(club.id));
  }
}
