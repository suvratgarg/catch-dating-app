import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_focus_body.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_preference_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostTodayFocusScreen extends ConsumerStatefulWidget {
  const HostTodayFocusScreen({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostTodayFocusScreen> createState() =>
      _HostTodayFocusScreenState();
}

class _HostTodayFocusScreenState extends ConsumerState<HostTodayFocusScreen> {
  HostTodayFocus? _selected;
  HostTodayPreferenceScope? _selectionScope;
  bool _allowRoutePop = false;

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    final accountId = uid.asData?.value;
    final organizers = accountId == null
        ? null
        : ref.watch(hostOperableClubsProvider(accountId));
    final organizer = organizers?.asData?.value
        .where((club) => club.id == widget.organizerId)
        .firstOrNull;
    final scope = organizer == null || accountId == null
        ? null
        : HostTodayPreferenceScope(
            accountId: accountId,
            organizerId: organizer.id,
          );
    final preference = scope == null
        ? null
        : ref.watch(hostTodayPreferenceProvider(scope));
    final pending =
        scope != null &&
        ref.watch(HostTodayPreferenceController.saveMutation(scope)).isPending;
    final saved = preference?.asData?.value;
    final selected = _selectionScope == scope ? _selected : saved?.focus;

    Widget content;
    if (uid.hasError ||
        organizers?.hasError == true ||
        preference?.hasError == true) {
      content = CatchErrorState.fromError(
        uid.error ?? organizers?.error ?? preference!.error!,
        context: AppErrorContext.generic,
        onRetry: () {
          if (uid.hasError) {
            ref.invalidate(uidProvider);
          } else if (organizers?.hasError == true) {
            ref.invalidate(hostOperableClubsProvider(accountId!));
          } else if (scope != null) {
            ref.invalidate(hostTodayPreferenceProvider(scope));
          }
        },
      );
    } else if (uid.isLoading ||
        organizers?.isLoading == true ||
        preference?.isLoading == true) {
      content = const HostRouteLoadingBody(padding: EdgeInsets.zero);
    } else if (accountId == null) {
      content = CatchErrorBody(
        title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
        message: context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
        retryLabel: context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
        onRetry: () => context.goNamed(Routes.authScreen.name),
      );
    } else if (scope == null || saved == null) {
      content = CatchErrorBody(
        title: context.l10n.hostTodayFocusUnavailable,
        message: context.l10n.hostTodayFocusUnavailableBody,
        retryLabel: context.l10n.hostTodayFocusBackToToday,
        onRetry: _exit,
      );
    } else {
      content = HostTodayFocusBody(
        selected: selected,
        pending: pending,
        onSelect: (focus) => setState(() {
          _selectionScope = scope;
          _selected = focus;
        }),
        onContinue: () => unawaited(_save(scope, selected)),
        onSkip: () => unawaited(_save(scope, null)),
      );
    }

    return PopScope(
      canPop: _allowRoutePop || (!pending && saved?.answered != false),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !pending && scope != null && saved?.answered == false) {
          unawaited(_save(scope, null));
        }
      },
      child: CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostTodayFocusScreenTitle,
          subtitle: organizer?.name,
          leadingType: pending
              ? CatchTopBarLeading.none
              : CatchTopBarLeading.close,
          onBack: () {
            if (scope != null && saved?.answered == false) {
              unawaited(_save(scope, null));
            } else {
              _exit();
            }
          },
          divider: scrolledUnder,
        ),
        body: CatchRouteBody.standardConstrained(child: content),
      ),
    );
  }

  Future<void> _save(
    HostTodayPreferenceScope scope,
    HostTodayFocus? focus,
  ) async {
    try {
      await HostTodayPreferenceController.saveMutation(scope).run(ref, (tx) {
        final controller = tx.get(
          hostTodayPreferenceControllerProvider(scope).notifier,
        );
        return focus == null ? controller.skip() : controller.select(focus);
      });
      if (!mounted || ref.read(uidProvider).asData?.value != scope.accountId)
        return;
      _exit();
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }

  void _exit() {
    if (_allowRoutePop) return;
    setState(() => _allowRoutePop = true);
    if (context.canPop()) {
      // Rebuild PopScope before the programmatic pop. First-run system Back
      // follows the same persisted skip path as the visible close control.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    } else {
      context.goNamed(
        Routes.hostTodayScreen.name,
        queryParameters: {'organizerId': widget.organizerId},
      );
    }
  }
}
