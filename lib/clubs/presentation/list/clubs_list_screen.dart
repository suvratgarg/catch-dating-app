import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_sliver_header.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubsListScreen extends ConsumerWidget {
  const ClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);

    final city = ref.watch(selectedClubCityProvider);
    final query = ref.watch(clubSearchQueryProvider).trim();
    final sourceClubCount =
        ref
            .watch(watchClubsByLocationProvider(city.name))
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
            ...ClubsSliverHeader(
              showSearchField: showSearchField,
            ).buildSlivers(context),
            const ClubsList(),
          ],
        ),
      ),
    );
  }
}
