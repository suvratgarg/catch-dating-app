import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubsSearchField extends ConsumerWidget {
  const RunClubsSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedRunClubCityProvider);

    return CatchTextField(
      key: ValueKey('search-${city.name}'),
      label: 'Search clubs',
      showLabel: false,
      initialValue: ref.read(runClubSearchQueryProvider),
      onChanged: (q) =>
          ref.read(runClubSearchQueryProvider.notifier).setQuery(q),
      hintText: 'Search clubs',
      size: CatchTextFieldSize.compact,
      shape: CatchTextFieldShape.pill,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(Icons.search_rounded, size: 18),
      showClearButton: true,
    );
  }
}
