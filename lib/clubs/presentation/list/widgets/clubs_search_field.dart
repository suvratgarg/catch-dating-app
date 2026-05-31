import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
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

    return CatchTextField(
      label: 'Search events or clubs',
      showLabel: false,
      initialValue: query,
      onChanged: (q) => ref.read(clubSearchQueryProvider.notifier).setQuery(q),
      hintText: 'Search events or clubs',
      size: CatchTextFieldSize.compact,
      shape: CatchTextFieldShape.pill,
      autofocus: autofocus,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      onFocusChanged: onFocusChanged,
      prefixIcon: Icon(CatchIcons.searchRounded, size: CatchIcon.md),
      showClearButton: true,
    );
  }
}
