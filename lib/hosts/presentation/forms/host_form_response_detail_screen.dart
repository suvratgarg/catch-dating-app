import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostFormResponseDetailScreen extends ConsumerStatefulWidget {
  const HostFormResponseDetailScreen({
    super.key,
    required this.organizerId,
    required this.responseId,
  });

  final String organizerId;
  final String responseId;

  @override
  ConsumerState<HostFormResponseDetailScreen> createState() =>
      _HostFormResponseDetailScreenState();
}

class _HostFormResponseDetailScreenState
    extends ConsumerState<HostFormResponseDetailScreen> {
  HostFormConversionKind? _converting;

  @override
  Widget build(BuildContext context) {
    final provider = hostFormResponseDetailProvider(
      organizerId: widget.organizerId,
      responseId: widget.responseId,
    );
    final detail = ref.watch(provider);
    final title = detail.asData?.value.response.identity.primaryLabel;
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: title ?? context.l10n.hostFormResponseTitle,
        subtitle: detail.asData?.value.response.formTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CatchAsyncValueView<HostFormResponseDetail>(
          value: detail,
          onRetry: () => ref.invalidate(provider),
          initialLoadTimeout: null,
          loadingBuilder: (_) =>
              const CatchPageBody(child: CatchSkeletonRows(count: 8)),
          errorBuilder: (_, error, _) => CatchPageBody(
            child: CatchErrorState.fromError(
              error,
              context: AppErrorContext.customer,
              onRetry: () => ref.invalidate(provider),
            ),
          ),
          builder: (context, value) => ListView(
            padding: CatchInsets.pageBody.copyWith(bottom: 0),
            children: [
              CatchSection.fieldRows(
                title: context.l10n.hostFormResponseIdentitySection,
                first: true,
                children: [
                  CatchField.read(
                    title: context.l10n.hostFormResponseName,
                    valueText:
                        value.response.identity.displayName ??
                        context.l10n.hostFormResponseNotProvided,
                  ),
                  CatchField.read(
                    title: context.l10n.hostFormResponseEmail,
                    valueText:
                        value.response.identity.email ??
                        context.l10n.hostFormResponseNotProvided,
                  ),
                  CatchField.read(
                    title: context.l10n.hostFormResponsePhone,
                    valueText:
                        value.response.identity.phoneE164 ??
                        context.l10n.hostFormResponseNotProvided,
                  ),
                  CatchField.read(
                    title: context.l10n.hostFormResponseSource,
                    valueText:
                        value.response.sourceLabel ??
                        context.l10n.hostFormResponseDirectSource,
                  ),
                  CatchField.read(
                    title: context.l10n.hostFormResponseSubmittedAt,
                    valueText: AppTimeFormatters.dateTime(
                      value.response.submittedAt,
                    ),
                  ),
                  CatchField.read(
                    title: context.l10n.hostFormResponseConsent,
                    valueText: value.consentVersion,
                  ),
                  CatchField.read(
                    title: context.l10n.hostFormResponseCompletionTime,
                    valueText: _duration(value.completionMillis),
                  ),
                ],
              ),
              gapH24,
              CatchSection.fieldRows(
                title: context.l10n.hostFormResponseAnswersSection,
                children: [
                  for (final answer in value.answers) ...[
                    CatchField.content(
                      title: answer.label,
                      body: _answerText(context, answer.answer),
                      valueText: _originLabel(context, answer.origin),
                    ),
                    for (final asset in answer.assetDownloads)
                      CatchField.nav(
                        title: context.l10n.hostFormResponseDownloadFile(
                          fileName: asset.fileName,
                        ),
                        body: asset.contentType,
                        icon: CatchIcons.downloadRounded,
                        onTap: () => _openAsset(asset),
                      ),
                  ],
                ],
              ),
              if (value.response.status ==
                  HostFormResponseStatus.submitted) ...[
                gapH24,
                CatchSection.fieldRows(
                  title: context.l10n.hostFormResponseOperationsSection,
                  children: [
                    _ConversionFormSchemaField(
                      detail: value,
                      kind: HostFormConversionKind.crmContact,
                      label: context.l10n.hostFormConvertCrm,
                      icon: CatchIcons.peopleOutlineRounded,
                      converting: _converting,
                      onTap: () => _reviewConversion(
                        value,
                        HostFormConversionKind.crmContact,
                      ),
                    ),
                    _ConversionFormSchemaField(
                      detail: value,
                      kind: HostFormConversionKind.application,
                      label: context.l10n.hostFormConvertApplication,
                      icon: CatchIcons.assignmentTurnedInOutlined,
                      converting: _converting,
                      onTap: () => _reviewConversion(
                        value,
                        HostFormConversionKind.application,
                      ),
                    ),
                    _ConversionFormSchemaField(
                      detail: value,
                      kind: HostFormConversionKind.eventAttendeeProposal,
                      label: context.l10n.hostFormConvertAttendee,
                      icon: CatchIcons.eventAvailableOutlined,
                      converting: _converting,
                      onTap: () => _reviewConversion(
                        value,
                        HostFormConversionKind.eventAttendeeProposal,
                      ),
                    ),
                    _ConversionFormSchemaField(
                      detail: value,
                      kind: HostFormConversionKind.followUp,
                      label: context.l10n.hostFormConvertFollowUp,
                      icon: CatchIcons.chatOutlined,
                      converting: _converting,
                      onTap: () => _reviewConversion(
                        value,
                        HostFormConversionKind.followUp,
                      ),
                    ),
                  ],
                ),
              ],
              const CatchScrollTerminalPadding(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAsset(HostFormAssetDownload asset) async {
    try {
      final opened = await ref
          .read(externalLinkControllerProvider)
          .open(Uri.parse(asset.downloadUrl));
      if (!opened && mounted) {
        showCatchErrorSnackBar(
          context,
          StateError(
            context.l10n.hostFormResponseDownloadFile(fileName: asset.fileName),
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }

  Future<void> _reviewConversion(
    HostFormResponseDetail detail,
    HostFormConversionKind kind,
  ) async {
    String? eventId;
    if (kind == HostFormConversionKind.eventAttendeeProposal) {
      final event = await _selectEvent();
      if (event == null || !mounted) return;
      eventId = event.id;
    }
    setState(() => _converting = kind);
    try {
      final controller = ref.read(hostFormsControllerProvider);
      final preview = await controller.previewConversion(
        organizerId: widget.organizerId,
        responseId: widget.responseId,
        kind: kind,
        eventId: eventId,
      );
      if (!mounted) return;
      final confirmed = await _showConversionPreview(preview);
      if (confirmed != true || !mounted) return;
      await controller.convertResponse(
        organizerId: widget.organizerId,
        responseId: widget.responseId,
        kind: kind,
        eventId: eventId,
        requestId: 'conversion_${DateTime.now().microsecondsSinceEpoch}',
      );
      if (!mounted) return;
      ref.invalidate(
        hostFormResponseDetailProvider(
          organizerId: widget.organizerId,
          responseId: widget.responseId,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.hostFormConversionComplete)),
      );
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _converting = null);
    }
  }

  Future<bool?> _showConversionPreview(HostFormConversionPreview preview) =>
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => CatchFormDialog(
          title: context.l10n.hostFormConversionReviewTitle,
          actions: [
            CatchButton(
              label: context.l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
              variant: CatchButtonVariant.ghost,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            CatchButton(
              label: preview.allowed
                  ? context.l10n.hostFormConversionConfirm
                  : context.l10n.hostFormConversionUnavailable,
              onPressed: preview.allowed
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
            ),
          ],
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.hostFormConversionReviewBody,
                    style: CatchTextStyles.supporting(
                      context,
                      color: CatchTokens.of(context).ink2,
                    ),
                  ),
                  if (preview.existingResultId != null) ...[
                    gapH12,
                    Text(
                      context.l10n.hostFormConversionExisting,
                      style: CatchTextStyles.supporting(
                        context,
                        color: CatchTokens.of(context).warning,
                      ),
                    ),
                  ],
                  if (preview.warnings.isNotEmpty) ...[
                    gapH12,
                    for (final warning in preview.warnings)
                      Padding(
                        padding: CatchInsets.detailInlineRowBottomGap,
                        child: Text(
                          warning,
                          style: CatchTextStyles.supporting(
                            context,
                            color: CatchTokens.of(context).warning,
                          ),
                        ),
                      ),
                  ],
                  gapH16,
                  CatchSection.containedFieldRows(
                    children: [
                      for (final field in preview.fields)
                        CatchField.read(
                          title: field.label,
                          valueText:
                              field.value?.toString() ??
                              context.l10n.hostFormResponseNotProvided,
                          body: field.conflict,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<Event?> _selectEvent() async {
    try {
      final events = await ref
          .read(hostFormsControllerProvider)
          .activeEvents(organizerId: widget.organizerId);
      if (!mounted) return null;
      return showDialog<Event>(
        context: context,
        builder: (dialogContext) => CatchFormDialog(
          title: context.l10n.hostFormSelectEventTitle,
          actions: [
            CatchButton(
              label: context.l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
              variant: CatchButtonVariant.ghost,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: events.isEmpty
                ? Text(
                    context.l10n.hostFormSelectEventEmpty,
                    style: CatchTextStyles.supporting(context),
                  )
                : SingleChildScrollView(
                    child: CatchSection.containedFieldRows(
                      children: [
                        for (final event in events)
                          CatchField.nav(
                            title: event.title,
                            body: AppTimeFormatters.dateTime(event.startTime),
                            onTap: () => Navigator.of(dialogContext).pop(event),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      );
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
      return null;
    }
  }
}

class _ConversionFormSchemaField extends StatelessWidget {
  const _ConversionFormSchemaField({
    required this.detail,
    required this.kind,
    required this.label,
    required this.icon,
    required this.converting,
    required this.onTap,
  });

  final HostFormResponseDetail detail;
  final HostFormConversionKind kind;
  final String label;
  final IconData icon;
  final HostFormConversionKind? converting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final complete = detail.response.conversionKinds.contains(kind);
    return _ResponseFormSchemaBoundary(
      child: CatchField.action(
        title: label,
        body: complete ? context.l10n.hostFormConversionComplete : null,
        icon: icon,
        status: converting == kind
            ? CatchFieldStatus.saving
            : complete
            ? CatchFieldStatus.saved
            : CatchFieldStatus.idle,
        onTap: complete || converting != null ? null : onTap,
      ),
    );
  }
}

class _ResponseFormSchemaBoundary extends StatelessWidget {
  const _ResponseFormSchemaBoundary({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

String _originLabel(BuildContext context, HostFormDataOrigin origin) =>
    switch (origin) {
      HostFormDataOrigin.anonymous =>
        context.l10n.hostFormResponseOriginAnonymous,
      HostFormDataOrigin.respondentGranted =>
        context.l10n.hostFormResponseOriginGranted,
      HostFormDataOrigin.organizerAcquired =>
        context.l10n.hostFormResponseOriginAcquired,
      HostFormDataOrigin.revoked => context.l10n.hostFormResponseOriginRevoked,
    };

String _answerText(BuildContext context, Object? answer) {
  if (answer == null || answer == '') {
    return context.l10n.hostFormResponseNoAnswer;
  }
  if (answer is bool) {
    return answer
        ? context.l10n.hostFormRuleTrue
        : context.l10n.hostFormRuleFalse;
  }
  if (answer is List<Object?>) {
    if (answer.isEmpty) return context.l10n.hostFormResponseNoAnswer;
    return answer.map((item) => item?.toString() ?? '').join(', ');
  }
  return answer.toString();
}

String _duration(int milliseconds) {
  final seconds = (milliseconds / 1000).round();
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return remainder == 0 ? '${minutes}m' : '${minutes}m ${remainder}s';
}
