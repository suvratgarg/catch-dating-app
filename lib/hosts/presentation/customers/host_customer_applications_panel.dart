import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/hosts/data/host_application_repository.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_controller.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_typography.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads organizer-scoped submissions only when the Details tab is mounted.
class HostCustomerApplicationsPanel extends ConsumerWidget {
  const HostCustomerApplicationsPanel({
    super.key,
    required this.organizerId,
    required this.contactId,
    required this.onOpenApplication,
    required this.onOpenContact,
  });

  final String organizerId;
  final String contactId;
  final ValueChanged<String> onOpenApplication;
  final ValueChanged<Uri> onOpenContact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = HostApplicationListRequest(
      organizerId: organizerId,
      contactId: contactId,
    );
    final provider = hostApplicationsDirectoryControllerProvider(request);
    return CatchAsyncValueView<HostApplicationsDirectoryState>(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      loadingBuilder: (_) => const CatchSkeletonRows(count: 2),
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSection.fieldRows(
            key: const ValueKey('host-customer-applications'),
            title: context.l10n.hostApplicationsTitle,
            children: [
              if (state.applications.isEmpty)
                CatchField.read(body: context.l10n.hostCustomersNoApplications),
              for (final application in state.applications)
                CatchField.nav(
                  key: ValueKey(
                    'host-customer-application-${application.applicationId}',
                  ),
                  title: AppTimeFormatters.shortDate(application.submittedAt),
                  body: hostApplicationStatusLabel(
                    context,
                    application.reviewStatus,
                  ),
                  icon: CatchIcons.tabForms,
                  onTap: () => onOpenApplication(application.applicationId),
                ),
            ],
          ),
          if (state.loadMoreError case final error?)
            CatchErrorState.fromError(
              error,
              onRetry: () => ref.read(provider.notifier).loadMore(),
            ),
          if (state.nextCursor != null)
            CatchButton(
              label: context.l10n.hostCustomersLoadMore,
              isLoading: state.loadingMore,
              variant: CatchButtonVariant.ghost,
              onPressed: state.canLoadMore
                  ? () => ref.read(provider.notifier).loadMore()
                  : null,
            ),
          if (state.applications.isNotEmpty) ...[
            gapH24,
            HostCustomerApplicationSnapshot(
              organizerId: organizerId,
              applicationId: state.applications.first.applicationId,
              onOpen: () =>
                  onOpenApplication(state.applications.first.applicationId),
              onOpenContact: onOpenContact,
            ),
          ],
        ],
      ),
    );
  }
}

/// Displays the same grant-filtered answers as the application detail route.
/// These remain a dated submission rather than becoming editable CRM fields.
class HostCustomerApplicationSnapshot extends ConsumerWidget {
  const HostCustomerApplicationSnapshot({
    super.key,
    required this.organizerId,
    required this.applicationId,
    required this.onOpen,
    required this.onOpenContact,
  });

  final String organizerId;
  final String applicationId;
  final VoidCallback onOpen;
  final ValueChanged<Uri> onOpenContact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = hostApplicationDetailProvider(organizerId, applicationId);
    return CatchAsyncValueView<HostApplicationDetail>(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      loadingBuilder: (_) => const CatchSkeletonRows(count: 2),
      builder: (context, detail) => CatchSection.fieldRows(
        key: const ValueKey('host-customer-submitted-fields'),
        title: context.l10n.hostCustomersLatestSubmittedDetails,
        footer: Text(
          context.l10n.hostCustomersSubmittedOn(
            date: AppTimeFormatters.shortDate(detail.submittedAt),
          ),
          style: HostCustomerTypography.context(context),
        ),
        children: [
          if (detail.answers.isEmpty)
            CatchField.read(
              body: context.l10n.hostCustomersSubmittedAnswersUnavailable,
            ),
          if (detail.outreach.instagramUrl case final url?)
            CatchField.action(
              title: context.l10n.hostApplicationInstagram,
              body: Uri.parse(url).path.replaceAll('/', ''),
              icon: CatchIcons.openInNewRounded,
              onTap: () => onOpenContact(Uri.parse(url)),
            ),
          if (detail.outreach.linkedinUrl case final url?)
            CatchField.action(
              title: context.l10n.hostApplicationLinkedin,
              body: url,
              bodyMaxLines: 4,
              icon: CatchIcons.openInNewRounded,
              onTap: () => onOpenContact(Uri.parse(url)),
            ),
          for (final answer
              in detail.answers
                  .where(
                    (answer) =>
                        answer.canonicalFieldId != 'instagramHandle' &&
                        answer.canonicalFieldId != 'linkedinUrl',
                  )
                  .take(8))
            CatchField.read(
              title: answer.questionLabel,
              body: hostCustomerApplicationAnswerText(context, answer.value),
              titleMaxLines: 4,
              bodyMaxLines: 8,
            ),
          CatchField.nav(
            title: context.l10n.hostCustomersOpenApplication,
            body: hostApplicationStatusLabel(context, detail.reviewStatus),
            onTap: onOpen,
          ),
        ],
      ),
    );
  }
}

String hostCustomerApplicationAnswerText(
  BuildContext context,
  HostApplicationAnswerValue value,
) {
  if (value.textValue != null) return value.textValue!;
  if (value.numberValue != null) return value.numberValue.toString();
  if (value.booleanValue != null) {
    return value.booleanValue!
        ? context.l10n.hostFormRuleTrue
        : context.l10n.hostFormRuleFalse;
  }
  if (value.dateValue != null) return value.dateValue!;
  if (value.optionValues.isNotEmpty) return value.optionValues.join(', ');
  if (value.assetIds.isNotEmpty) {
    return context.l10n.hostCustomersOpenApplication;
  }
  return context.l10n.hostFormResponseNoAnswer;
}
