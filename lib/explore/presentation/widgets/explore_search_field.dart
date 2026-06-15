import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreSearchField extends ConsumerWidget {
  const ExploreSearchField({
    super.key,
    this.autofocus = false,
    this.onSubmitted,
    this.onFocusChanged,
  });

  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(exploreSearchQueryProvider);

    return CatchSearchField(
      value: query,
      onChanged: (q) =>
          ref.read(exploreSearchQueryProvider.notifier).setQuery(q),
      placeholder: 'Search events or clubs',
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      onFocusChanged: onFocusChanged,
      semanticLabel: 'Search events or clubs',
    );
  }
}
