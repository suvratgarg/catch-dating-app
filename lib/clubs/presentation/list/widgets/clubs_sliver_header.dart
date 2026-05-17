import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/city_picker.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_search_field.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClubsSliverHeader extends CatchSliverHeader {
  ClubsSliverHeader({bool showSearchField = true})
    : super(
        title: const _TitleRow(),
        bottom: _SearchRow(showSearchField: showSearchField),
        bottomHeight:
            CatchTextField.compactControlHeight +
            (showSearchField ? CatchSpacing.s4 : CatchSpacing.s2),
      );
}

class _TitleRow extends ConsumerWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final canCreate = ref.watch(canCreateClubProvider).asData?.value ?? false;

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
                Text('Clubs', style: CatchTextStyles.displayL(context)),
                gapH4,
                Text(
                  'Find your people. Catch your person.',
                  style: CatchTextStyles.bodyS(context),
                ),
              ],
            ),
          ),
          if (canCreate)
            IconBtn(
              onTap: () => context.pushNamed(Routes.createClubScreen.name),
              child: Icon(Icons.add_rounded, size: 20, color: t.ink),
            ),
        ],
      ),
    );
  }
}

class _SearchRow extends ConsumerWidget {
  const _SearchRow({required this.showSearchField});

  final bool showSearchField;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.bg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          showSearchField ? CatchSpacing.s2 : CatchSpacing.s1,
          CatchSpacing.s5,
          showSearchField ? CatchSpacing.s2 : CatchSpacing.s1,
        ),
        child: Row(
          children: [
            const CityPicker(),
            if (showSearchField) ...[
              gapW8,
              const Expanded(child: ClubsSearchField()),
            ],
          ],
        ),
      ),
    );
  }
}
