import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_dating_app/user_profile/presentation/form_profiles_controller.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FormProfilesScreen extends ConsumerWidget {
  const FormProfilesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => CatchRouteScaffold(
    topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
      title: context.l10n.formProfilesTitle,
      navigation: const CatchTopBarNavigation(
        mode: CatchTopBarNavigationMode.back,
      ),
      emphasis: scrolledUnder
          ? CatchTopBarEmphasis.divided
          : CatchTopBarEmphasis.plain,
    ),
    body: CatchRouteBody.standardConstrained(
      child: CatchAsyncBoundary<FormProfilesState>(
        value: ref.watch(formProfilesControllerProvider),
        retainDataOn: const {},
        errorContext: AppErrorContext.profile,
        onRetry: () => ref.invalidate(formProfilesControllerProvider),
        builder: (context, state) => FormProfilesList(
          state: state,
          onOpen: (id) => context.pushNamed(
            Routes.formProfileReviewScreen.name,
            pathParameters: {'responseId': id},
          ),
          onLoadMore: () =>
              ref.read(formProfilesControllerProvider.notifier).loadMore(),
        ),
      ),
    ),
  );
}

class FormProfilesList extends StatelessWidget {
  const FormProfilesList({
    super.key,
    required this.state,
    required this.onOpen,
    required this.onLoadMore,
  });
  final FormProfilesState state;
  final ValueChanged<String> onOpen;
  final VoidCallback onLoadMore;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.formProfilesDescription,
          style: CatchTextStyles.bodyM(context),
        ),
        gapH24,
        if (state.page.items.isEmpty && state.page.nextCursor == null)
          CatchEmptyState(
            icon: CatchIcons.personOutlineRounded,
            title: l10n.formProfilesEmptyTitle,
            message: l10n.formProfilesEmptyBody,
          ),
        if (state.page.items.isNotEmpty)
          CatchSection.fieldRows(
            first: true,
            children: [
              for (final row in state.page.items)
                CatchField.nav(
                  key: ValueKey('form-profile-${row.responseId}'),
                  copy: catchFieldCopy(l10n),
                  title:
                      row.organizerName ?? l10n.formProfilesOrganizerFallback,
                  body:
                      '${row.formTitle}\n${AppTimeFormatters.dateTime(row.submittedAt)}\n${row.claimedAt == null ? l10n.formProfilesReview : l10n.formProfilesManage}',
                  titleMaxLines: 2,
                  bodyMaxLines: 6,
                  onTap: () => onOpen(row.responseId),
                ),
            ],
          ),
        if (state.error case final error?)
          CatchLocalizedErrorState(
            error,
            context: AppErrorContext.profile,
            onRetry: onLoadMore,
          ),
        if (state.page.nextCursor != null) ...[
          gapH24,
          CatchButton(
            label: l10n.formProfilesLoadMore,
            status: state.loadingMore
                ? CatchButtonStatus.loading
                : CatchButtonStatus.idle,
            onPressed: state.loadingMore ? null : onLoadMore,
            variant: CatchButtonVariant.secondary,
          ),
        ],
      ],
    );
  }
}
