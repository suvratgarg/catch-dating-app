import 'package:catch_dating_app/core/widgets/confirm_danger_dialog.dart';
import 'package:flutter/material.dart';

Future<bool?> showBlockUserDialog({
  required BuildContext context,
  required String name,
}) {
  return showConfirmDangerDialog(
    context: context,
    title: 'Block $name?',
    message:
        'You will stop seeing each other in chats, matches, swipes, and '
        'future event slots where the other person is already booked.',
    confirmLabel: 'Block',
  );
}
