import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubsSearchField extends ConsumerWidget {
  const ClubsSearchField({
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
    final query = ref.watch(clubSearchQueryProvider);

    return CatchSearchField(
      value: query,
      onChanged: (q) => ref.read(clubSearchQueryProvider.notifier).setQuery(q),
      placeholder: 'Search events or clubs',
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      onFocusChanged: onFocusChanged,
      semanticLabel: 'Search events or clubs',
    );
  }
}
