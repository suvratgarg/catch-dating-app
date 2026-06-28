import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostCreateClubScreen extends StatelessWidget {
  const HostCreateClubScreen({super.key});

  @override
  Widget build(BuildContext context) => const CreateClubScreen();
}

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
      return _buildHostClubEditor(ref, initialClub!);
    }

    final clubAsync = ref.watch(fetchClubProvider(clubId));
    return CatchAsyncValueView<Club?>(
      value: clubAsync,
      loadingBuilder: (_) => const CatchStartupLoadingScreen(),
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
          : _buildHostClubEditor(ref, club),
    );
  }

  Widget _buildHostClubEditor(WidgetRef ref, Club club) {
    final state = HostClubEditState.resolve(
      club: club,
      uid: ref.watch(uidProvider),
    );

    return switch (state.mode) {
      HostClubEditMode.loadingIdentity => const CatchStartupLoadingScreen(),
      HostClubEditMode.forbidden => const CatchErrorScaffold(
        title: 'Host access required',
        message: "Only this club's host team can edit this club.",
      ),
      HostClubEditMode.ownerFull || HostClubEditMode.cohostMediaOnly =>
        CreateClubScreen(initialClub: state.club),
    };
  }
}

enum HostClubEditMode { loadingIdentity, ownerFull, cohostMediaOnly, forbidden }

@immutable
class HostClubEditState {
  const HostClubEditState({
    required this.mode,
    required this.club,
    required this.uid,
  });

  final HostClubEditMode mode;
  final Club club;
  final String? uid;

  bool get canEdit =>
      mode == HostClubEditMode.ownerFull ||
      mode == HostClubEditMode.cohostMediaOnly;

  bool get mediaOnly => mode == HostClubEditMode.cohostMediaOnly;

  factory HostClubEditState.resolve({
    required Club club,
    required AsyncValue<String?> uid,
  }) {
    if (uid.isLoading) {
      return HostClubEditState(
        mode: HostClubEditMode.loadingIdentity,
        club: club,
        uid: null,
      );
    }

    final value = uid.asData?.value;
    if (value != null && club.isOwnedBy(value)) {
      return HostClubEditState(
        mode: HostClubEditMode.ownerFull,
        club: club,
        uid: value,
      );
    }
    if (value != null && club.isHostedBy(value)) {
      return HostClubEditState(
        mode: HostClubEditMode.cohostMediaOnly,
        club: club,
        uid: value,
      );
    }
    return HostClubEditState(
      mode: HostClubEditMode.forbidden,
      club: club,
      uid: value,
    );
  }
}
