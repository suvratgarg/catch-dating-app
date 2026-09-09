import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostMessagingSetupScreen extends ConsumerWidget {
  const HostMessagingSetupScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = ref.watch(watchClubProvider(clubId));
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostSendsSettings,
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
      ),
      body: CatchRouteBody.standardSections(
        sections: [
          CatchSectionListItem(
            child: club.when(
              loading: () => const CatchSkeleton.rows(),
              error: (error, _) => CatchLocalizedErrorState(
                error,
                context: AppErrorContext.club,
                onRetry: () => ref.invalidate(watchClubProvider(clubId)),
              ),
              data: (value) => value == null
                  ? CatchLocalizedErrorState(
                      StateError('Organizer not found.'),
                      context: AppErrorContext.club,
                      onRetry: () => ref.invalidate(watchClubProvider(clubId)),
                    )
                  : HostWhatsappSetupPane(club: value),
            ),
          ),
        ],
      ),
    );
  }
}
