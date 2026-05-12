import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_list.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubsListScreen extends ConsumerWidget {
  const RunClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    if (!isAppShellTabActive(context, appShellClubsTabIndex)) {
      return Scaffold(backgroundColor: t.bg);
    }

    final city = ref.watch(selectedRunClubCityProvider);
    final query = ref.watch(runClubSearchQueryProvider).trim();
    final sourceClubCount =
        ref
            .watch(watchRunClubsByLocationProvider(city.name))
            .asData
            ?.value
            .length ??
        0;
    final showSearchField = sourceClubCount > 0 || query.isNotEmpty;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...RunClubsSliverHeader(
              showSearchField: showSearchField,
            ).buildSlivers(context),
            const RunClubsList(),
          ],
        ),
      ),
    );
  }
}
