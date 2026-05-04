import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_list.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart';
import 'package:flutter/material.dart';

class RunClubsListScreen extends StatelessWidget {
  const RunClubsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...RunClubsSliverHeader().buildSlivers(context),
            const RunClubsList(),
          ],
        ),
      ),
    );
  }
}
