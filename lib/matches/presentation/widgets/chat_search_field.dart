import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
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

    return CatchTextField(
      label: 'Search chats',
      showLabel: false,
      initialValue: query,
      onChanged: (q) => ref.read(chatSearchQueryProvider.notifier).setQuery(q),
      hintText: 'Search by name',
      size: CatchTextFieldSize.compact,
      shape: CatchTextFieldShape.pill,
      autofocus: autofocus,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      onFocusChanged: onFocusChanged,
      prefixIcon: Icon(CatchIcons.searchRounded, size: 18),
      showClearButton: true,
    );
  }
}
