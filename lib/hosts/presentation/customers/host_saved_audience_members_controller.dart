import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_saved_audience_members_controller.g.dart';

class HostSavedAudienceMembersState {
  const HostSavedAudienceMembersState({
    required this.preview,
    required this.members,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final HostSavedAudiencePreview preview;
  final List<HostSavedAudiencePreviewContact> members;
  final bool loadingMore;
  final Object? loadMoreError;
}

@riverpod
class HostSavedAudienceMembersController
    extends _$HostSavedAudienceMembersController {
  @override
  Future<HostSavedAudienceMembersState> build(
    HostSavedAudience audience,
  ) async {
    final preview = await ref
        .read(hostCrmRepositoryProvider)
        .previewSavedAudience(
          organizerId: audience.organizerId,
          audience: audience,
          sampleLimit: 25,
        );
    return HostSavedAudienceMembersState(
      preview: preview,
      members: preview.sample,
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null ||
        current.loadingMore ||
        current.preview.nextCursor == null) {
      return;
    }
    state = AsyncData(
      HostSavedAudienceMembersState(
        preview: current.preview,
        members: current.members,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref
          .read(hostCrmRepositoryProvider)
          .previewSavedAudience(
            organizerId: audience.organizerId,
            audience: audience,
            sampleLimit: 25,
            cursor: current.preview.nextCursor,
          );
      if (!ref.mounted) return;
      state = AsyncData(
        HostSavedAudienceMembersState(
          preview: page,
          members: [...current.members, ...page.sample],
        ),
      );
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = AsyncData(
        HostSavedAudienceMembersState(
          preview: current.preview,
          members: current.members,
          loadMoreError: error,
        ),
      );
    }
  }
}
