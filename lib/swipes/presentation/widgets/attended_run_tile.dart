import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AttendedRunTile extends StatelessWidget {
  const AttendedRunTile({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final dateStr = DateFormat('EEE, d MMM · h:mm a').format(run.startTime);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p8,
      ),
      leading: CircleAvatar(
        backgroundColor: t.primarySoft,
        child: Icon(Icons.directions_run, color: t.primary),
      ),
      title: Text(
        run.title,
        style: CatchTextStyles.labelLg(context),
      ),
      subtitle: Text(
        '$dateStr · ${run.attendedUserIds.length} attendees',
        style: CatchTextStyles.bodySm(context, color: t.ink2),
      ),
      trailing: FilledButton.tonal(
        onPressed: () => context.pushNamed(
          Routes.swipeRunScreen.name,
          pathParameters: {'runId': run.id},
        ),
        child: const Text('Swipe'),
      ),
    );
  }
}
