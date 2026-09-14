import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/event_success/presentation/event_message_preferences_sheet.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Consumer event-detail entry. No identity or preference reads until opened.
class EventMessagePreferencesEntry extends StatelessWidget {
  const EventMessagePreferencesEntry({super.key, required this.eventId});
  final String eventId;
  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    children: [
      CatchField.nav(
        key: const ValueKey('event.messages.open'),
        copy: catchFieldCopy(context.l10n),
        title: context.l10n.eventMessagesTitle,
        emphasis: CatchFieldEmphasis.title,
        body: context.l10n.eventMessagesEntryBody,
        onTap: () => showCatchBottomSheet<void>(
          context: context,
          builder: (_) => EventMessagePreferencesSheet(eventId: eventId),
        ),
      ),
    ],
  );
}
