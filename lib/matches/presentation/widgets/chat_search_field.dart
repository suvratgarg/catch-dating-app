import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSearchField extends ConsumerWidget {
  const ChatSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatchTextField(
      label: 'Search chats',
      showLabel: false,
      initialValue: ref.read(chatSearchQueryProvider),
      onChanged: (q) =>
          ref.read(chatSearchQueryProvider.notifier).setQuery(q),
      hintText: 'Search by name',
      size: CatchTextFieldSize.compact,
      shape: CatchTextFieldShape.pill,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(Icons.search_rounded, size: 18),
      showClearButton: true,
    );
  }
}
