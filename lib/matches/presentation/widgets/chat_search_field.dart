import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSearchField extends ConsumerWidget {
  const ChatSearchField({
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
    final query = ref.watch(chatSearchQueryProvider);

    return CatchSearchField(
      value: query,
      onChanged: (q) => ref.read(chatSearchQueryProvider.notifier).setQuery(q),
      placeholder: 'Search by name',
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      onFocusChanged: onFocusChanged,
      semanticLabel: 'Search chats',
    );
  }
}
