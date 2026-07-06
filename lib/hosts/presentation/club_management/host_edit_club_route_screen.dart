import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/host_club_editor_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_create_club_screen_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostEditClubRouteScreen extends ConsumerWidget {
  const HostEditClubRouteScreen({
    super.key,
    required this.clubId,
    this.initialClub,
  });

  final String clubId;
  final Club? initialClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialClub != null) {
      return HostClubEditorStateView(club: initialClub!);
    }

    final clubAsync = ref.watch(fetchClubProvider(clubId));
    return CatchAsyncValueView<Club?>(
      value: clubAsync,
      loadingBuilder: (_) => const HostClubEditorLoadingScreen(),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchClubProvider(clubId)),
      ),
      builder: (context, club) => club == null
          ? const CatchErrorScaffold(
              title: 'Club not found',
              message: 'This club is no longer available.',
            )
          : HostClubEditorStateView(club: club),
    );
  }
}

class HostClubEditorStateView extends ConsumerWidget {
  const HostClubEditorStateView({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider);
    final state = HostClubEditState.resolve(
      club: club,
      uidLoading: uid.isLoading,
      uid: uid.asData?.value,
    );

    return switch (state.mode) {
      HostClubEditMode.loadingIdentity => const HostClubEditorLoadingScreen(),
      HostClubEditMode.forbidden => const CatchErrorScaffold(
        title: 'Host access required',
        message: "Only this club's host team can edit this club.",
      ),
      HostClubEditMode.ownerFull || HostClubEditMode.cohostMediaOnly =>
        CreateClubScreen(initialClub: state.club),
    };
  }
}
