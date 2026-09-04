import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_analytics_kit.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostFormAnalyticsScreen extends ConsumerStatefulWidget {
  const HostFormAnalyticsScreen({
    super.key,
    required this.organizerId,
    required this.formId,
  });

  final String organizerId;
  final String formId;

  @override
  ConsumerState<HostFormAnalyticsScreen> createState() =>
      _HostFormAnalyticsScreenState();
}

class _HostFormAnalyticsScreenState
    extends ConsumerState<HostFormAnalyticsScreen> {
  HostFormExportFormat? _exporting;

  @override
  Widget build(BuildContext context) {
    final provider = hostFormAnalyticsProvider(
      organizerId: widget.organizerId,
      formId: widget.formId,
    );
    final analytics = ref.watch(provider);
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostFormAnalyticsTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: CatchRouteBody.standardConstrained(
        child: CatchAsyncValueView<HostFormAnalytics>(
          value: analytics,
          onRetry: () => ref.invalidate(provider),
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 8),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.forms,
            onRetry: () => ref.invalidate(provider),
          ),
          builder: (context, value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.hostFormAnalyticsFunnel,
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH12,
              CatchAnalyticsMetricGrid(
                metrics: [
                  CatchMetricCardData(
                    icon: CatchIcons.visibilityOutlined,
                    value: '${value.opens}',
                    label: context.l10n.hostFormAnalyticsOpens,
                  ),
                  CatchMetricCardData(
                    icon: CatchIcons.playCircleOutlineRounded,
                    value: '${value.starts}',
                    label: context.l10n.hostFormAnalyticsStarts,
                  ),
                  CatchMetricCardData(
                    icon: CatchIcons.checkCircleOutlineRounded,
                    value: '${value.submissions}',
                    label: context.l10n.hostFormAnalyticsSubmissions,
                  ),
                  CatchMetricCardData(
                    icon: CatchIcons.insightsOutlined,
                    value: '${(value.completionRate * 100).round()}%',
                    label: context.l10n.hostFormAnalyticsCompletionRate,
                  ),
                  CatchMetricCardData(
                    icon: CatchIcons.accessTimeRounded,
                    value: value.medianCompletionMillis == null
                        ? '—'
                        : _duration(value.medianCompletionMillis!),
                    label: context.l10n.hostFormAnalyticsMedianTime,
                  ),
                ],
              ),
              gapH24,
              Wrap(
                spacing: CatchSpacing.s3,
                runSpacing: CatchSpacing.s3,
                children: [
                  CatchButton(
                    label: context.l10n.hostFormExportCsv,
                    icon: Icon(CatchIcons.downloadRounded),
                    variant: CatchButtonVariant.secondary,
                    isLoading: _exporting == HostFormExportFormat.csv,
                    onPressed: _exporting == null
                        ? () => _export(HostFormExportFormat.csv)
                        : null,
                  ),
                  CatchButton(
                    label: context.l10n.hostFormExportXlsx,
                    icon: Icon(CatchIcons.downloadRounded),
                    variant: CatchButtonVariant.secondary,
                    isLoading: _exporting == HostFormExportFormat.xlsx,
                    onPressed: _exporting == null
                        ? () => _export(HostFormExportFormat.xlsx)
                        : null,
                  ),
                ],
              ),
              if (value.sources.isNotEmpty) ...[
                gapH24,
                CatchSection.fieldRows(
                  title: context.l10n.hostFormAnalyticsSources,
                  children: [
                    for (final source in value.sources)
                      CatchField.read(
                        title: source.label,
                        body: context.l10n.hostFormAnalyticsSourceSummary(
                          opens: source.opens,
                          starts: source.starts,
                          submissions: source.submissions,
                        ),
                      ),
                  ],
                ),
              ],
              gapH24,
              Text(
                context.l10n.hostFormAnalyticsPrivacyNotice,
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
              if (value.questions.isNotEmpty) ...[
                gapH12,
                CatchSection.fieldRows(
                  title: context.l10n.hostFormAnalyticsQuestions,
                  children: [
                    for (final question in value.questions) ...[
                      CatchField.read(
                        title: question.label,
                        body: context.l10n.hostFormAnalyticsQuestionSummary(
                          count: question.responseCount,
                        ),
                      ),
                      for (final choice in question.choiceCounts)
                        CatchField.read(
                          title: choice.label,
                          valueText: context.l10n.hostFormAnalyticsChoiceCount(
                            count: choice.count,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export(HostFormExportFormat format) async {
    setState(() => _exporting = format);
    final controller = ref.read(hostFormsControllerProvider);
    final requestId = 'export_${DateTime.now().microsecondsSinceEpoch}';
    try {
      var receipt = await controller.requestExport(
        organizerId: widget.organizerId,
        formId: widget.formId,
        requestId: requestId,
        format: format,
        statuses: HostFormResponseStatus.values.toSet(),
      );
      for (
        var attempt = 0;
        mounted &&
            attempt < 12 &&
            (receipt.status == HostFormExportStatus.pending ||
                receipt.status == HostFormExportStatus.running);
        attempt++
      ) {
        await Future<void>.delayed(CatchMotion.formExportPoll);
        receipt = await controller.requestExport(
          organizerId: widget.organizerId,
          formId: widget.formId,
          requestId: requestId,
          format: format,
          statuses: HostFormResponseStatus.values.toSet(),
        );
      }
      if (!mounted) return;
      if (receipt.status == HostFormExportStatus.completed &&
          receipt.downloadUrl != null) {
        final opened = await ref
            .read(externalLinkControllerProvider)
            .open(Uri.parse(receipt.downloadUrl!));
        if (!mounted) return;
        showCatchSnackBar(
          context,
          opened
              ? context.l10n.hostFormExportReady
              : context.l10n.hostFormExportFailed,
        );
      } else if (receipt.status == HostFormExportStatus.pending ||
          receipt.status == HostFormExportStatus.running) {
        showCatchSnackBar(context, context.l10n.hostFormExportStillPreparing);
      } else {
        throw StateError(
          receipt.errorMessage ?? context.l10n.hostFormExportFailed,
        );
      }
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _exporting = null);
    }
  }
}

String _duration(int milliseconds) {
  final seconds = (milliseconds / 1000).round();
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return remainder == 0 ? '${minutes}m' : '${minutes}m ${remainder}s';
}
