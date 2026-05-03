import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';

Future<bool?> showBlockUserDialog({
  required BuildContext context,
  required String name,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Block $name?'),
      content: const Text(
        'You will stop seeing each other in chats, matches, swipes, and '
        'future run slots where the other person is already booked.',
      ),
      actions: [
        CatchButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          variant: CatchButtonVariant.ghost,
          size: CatchButtonSize.sm,
        ),
        CatchButton(
          label: 'Block',
          onPressed: () => Navigator.of(context).pop(true),
          variant: CatchButtonVariant.danger,
          size: CatchButtonSize.sm,
        ),
      ],
    ),
  );
}
