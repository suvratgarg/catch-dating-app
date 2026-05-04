import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/city_picker.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RunClubsSliverHeader extends CatchSliverHeader {
  RunClubsSliverHeader()
    : super(
        title: const _TitleRow(),
        bottom: const _SearchRow(),
        titleHeight: 82,
        bottomHeight: 52,
      );
}

class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s4,
        CatchSpacing.s5,
        CatchSpacing.s2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Run clubs', style: CatchTextStyles.displayL(context)),
                gapH4,
                Text(
                  'Find your people. Catch your person.',
                  style: CatchTextStyles.bodyS(context),
                ),
              ],
            ),
          ),
          IconBtn(
            onTap: () => context.pushNamed(Routes.createRunClubScreen.name),
            child: Icon(Icons.add_rounded, size: 20, color: t.ink),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends ConsumerWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        0,
        CatchSpacing.s5,
        CatchSpacing.s3,
      ),
      child: Row(
        children: [
          const CityPicker(),
          gapW8,
          const Expanded(child: RunClubsSearchField()),
        ],
      ),
    );
  }
}
