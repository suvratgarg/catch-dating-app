import 'dart:async';

import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

/// Opens a deep-link [route] through go_router, catching navigation failures
/// and surfacing them as branded Catch error snackbars.
///
/// Extracted from [ActivityScreen] and [ActivitySection]/[NotificationDayGroups]
/// to avoid duplicating the error-handling boilerplate.
void openNotificationRoute(BuildContext context, String route) {
  try {
    unawaited(
      context.push(route).catchError((Object error, StackTrace stackTrace) {
        if (!context.mounted) return null;
        showNotificationRouteError(context, error, stackTrace);
        return null;
      }),
    );
  } on Object catch (error, stackTrace) {
    showNotificationRouteError(context, error, stackTrace);
  }
}

/// Displays a branded Catch snackbar for notification navigation failures.
void showNotificationRouteError(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
) {
  showCatchErrorSnackBar(
    context,
    ExternalActionException(
      context.l10n.dashboardNotificationRouteUtilVisiblecopyCouldNotOpenThis,
      cause: error,
      stackTrace: stackTrace,
    ),
  );
}
