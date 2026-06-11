import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostCreateEventRouteScreen extends ConsumerWidget {
  const HostCreateEventRouteScreen({
    super.key,
    required this.clubId,
    this.initialClub,
  });

  final String clubId;
  final Club? initialClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialClub != null) {
      return CreateEventScreen(club: initialClub!);
    }

    final clubAsync = ref.watch(fetchClubProvider(clubId));
    return clubAsync.when(
      loading: () => const CatchStartupLoadingScreen(),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(fetchClubProvider(clubId)),
      ),
      data: (club) => club == null
          ? const CatchErrorScaffold(
              title: 'Club not found',
              message: 'This club is no longer available.',
            )
          : CreateEventScreen(club: club),
    );
  }
}
