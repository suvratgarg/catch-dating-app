import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
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
    final detailState = catchAsyncStateFromAsyncValue(detail);
    final loadedDetail = detailState.value;
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        leadingType: CatchTopBarLeading.back,
        leadingActionVariant: CatchIconButtonVariant.plain,
        divider: scrolledUnder,
      ),
      bottomNavigationBar:
          loadedDetail?.response.status == HostFormResponseStatus.submitted
          ? _ResponseConversionDock(
              detail: loadedDetail!,
              converting: _converting,
              onConvert: (kind) => _reviewConversion(loadedDetail, kind),
            )
          : null,
      body: CatchRouteBody.standard(
        constrainToContentWidth: true,
        child: CatchAsyncValueView<HostFormResponseDetail>(
          value: detail,
          onRetry: () => ref.invalidate(provider),
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 8),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.formResponses,
            onRetry: () => ref.invalidate(provider),
          ),
          builder: (context, value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResponseIdentityHeader(detail: value),
              gapH8,
              Text(
                value.response.formTitle,
                style: CatchTextStyles.bodyLead(context),
              ),
              gapH20,
              const CatchDivider.section(),
              gapH16,
              _ResponseSubmissionSummary(detail: value),
              if (value.response.identity.phoneE164 != null ||
                  value.response.identity.email != null) ...[
                gapH20,
                _ResponseContactActions(
                  identity: value.response.identity,
                  onOpen: _openContact,
                ),
              ],
              gapH32,
              CatchSection.divided(
                title: context.l10n.hostFormResponseAnswersSection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final answer in value.answers) ...[
                      _ResponseAnswerBlock(
                        label: answer.label,
                        answer: _answerText(context, answer.answer),
                        origin: _originLabel(context, answer.origin),
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
              ),
              gapH24,
              _ResponseTechnicalDetails(detail: value),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openContact(Uri uri) async {
    try {
      final opened = await ref.read(externalLinkControllerProvider).open(uri);
      if (!opened && mounted) {
        showCatchErrorSnackBar(
          context,
          StateError(context.l10n.hostFormResponseNotProvided),
        );
      }
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
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

class _ResponseIdentityHeader extends StatelessWidget {
  const _ResponseIdentityHeader({required this.detail});

  final HostFormResponseDetail detail;

  @override
  Widget build(BuildContext context) {
    final accessibleStack = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final name = Text(
      detail.response.identity.primaryLabel ??
          context.l10n.hostFormResponsesAnonymous,
      key: const ValueKey('host-form-response-name'),
      style: CatchTextStyles.eventTitle(context),
    );
    final status = CatchChip.tag(
      key: const ValueKey('host-form-response-status'),
      label: detail.response.status == HostFormResponseStatus.submitted
          ? context.l10n.hostFormResponsesSubmitted
          : context.l10n.hostFormResponsesWithdrawn,
    );
    if (accessibleStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [name, gapH8, status],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: name),
        gapW12,
        status,
      ],
    );
  }
}

class _ResponseSubmissionSummary extends StatelessWidget {
  const _ResponseSubmissionSummary({required this.detail});

  final HostFormResponseDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final response = detail.response;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CatchIcons.verifiedUserOutlined, size: CatchIcon.lg, color: t.ink),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.hostFormResponseSubmittedAt} · '
                '${_identityKindLabel(context, response.identityKind)}',
                style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
              ),
              gapH4,
              Text(
                AppTimeFormatters.dateTime(response.submittedAt),
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResponseContactActions extends StatelessWidget {
  const _ResponseContactActions({required this.identity, required this.onOpen});

  final HostFormResponseIdentity identity;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (identity.phoneE164 case final phone?)
        CatchButton(
          key: const ValueKey('host-form-response-call'),
          label: context.l10n.hostApplicationCall,
          icon: Icon(CatchIcons.phoneOutlined, size: CatchIcon.sm),
          shape: CatchButtonShape.rounded,
          fullWidth: true,
          onPressed: () => onOpen(Uri(scheme: 'tel', path: phone)),
        ),
      if (identity.phoneE164 != null && identity.email != null) gapH12,
      if (identity.email case final email?)
        CatchButton(
          key: const ValueKey('host-form-response-email'),
          label: context.l10n.hostApplicationEmail,
          icon: Icon(CatchIcons.emailOutlined, size: CatchIcon.sm),
          shape: CatchButtonShape.rounded,
          variant: CatchButtonVariant.secondary,
          fullWidth: true,
          onPressed: () => onOpen(Uri(scheme: 'mailto', path: email)),
        ),
    ],
  );
}

class _ResponseAnswerBlock extends StatelessWidget {
  const _ResponseAnswerBlock({
    required this.label,
    required this.answer,
    required this.origin,
  });

  final String label;
  final String answer;
  final String origin;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Padding(
        padding: CatchInsets.contentVerticalMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH6,
            Text(answer, style: CatchTextStyles.bodyL(context, color: t.ink)),
            gapH6,
            Text(
              origin,
              style: CatchTextStyles.monoLabelS(context, color: t.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseTechnicalDetails extends StatelessWidget {
  const _ResponseTechnicalDetails({required this.detail});

  final HostFormResponseDetail detail;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    title: context.l10n.hostFormResponseIdentitySection,
    children: [
      CatchField.read(
        title: context.l10n.hostFormResponseSource,
        valueText:
            detail.response.sourceLabel ??
            context.l10n.hostFormResponseDirectSource,
      ),
      CatchField.read(
        title: context.l10n.hostFormResponseConsent,
        valueText: detail.consentVersion,
      ),
      CatchField.read(
        title: context.l10n.hostFormResponseCompletionTime,
        valueText: _duration(detail.completionMillis),
      ),
    ],
  );
}

class _ResponseConversionDock extends StatelessWidget {
  const _ResponseConversionDock({
    required this.detail,
    required this.converting,
    required this.onConvert,
  });

  final HostFormResponseDetail detail;
  final HostFormConversionKind? converting;
  final ValueChanged<HostFormConversionKind> onConvert;

  @override
  Widget build(BuildContext context) {
    final conversions = detail.response.conversionKinds;
    final applicationComplete = conversions.contains(
      HostFormConversionKind.application,
    );
    final crmComplete = conversions.contains(HostFormConversionKind.crmContact);
    final attendeeComplete = conversions.contains(
      HostFormConversionKind.eventAttendeeProposal,
    );
    final busy = converting != null;
    final accessibleStack = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final applicationAction = CatchButton(
      key: const ValueKey('host-form-response-convert-application'),
      label: context.l10n.hostFormConvertApplication,
      shape: CatchButtonShape.rounded,
      fullWidth: true,
      isLoading: converting == HostFormConversionKind.application,
      onPressed: applicationComplete || busy
          ? null
          : () => onConvert(HostFormConversionKind.application),
    );
    final crmAction = CatchButton(
      key: const ValueKey('host-form-response-convert-crm'),
      label: context.l10n.hostFormConvertCrm,
      shape: CatchButtonShape.rounded,
      variant: CatchButtonVariant.secondary,
      fullWidth: true,
      isLoading: converting == HostFormConversionKind.crmContact,
      onPressed: crmComplete || busy
          ? null
          : () => onConvert(HostFormConversionKind.crmContact),
    );
    final attendeeAction = CatchActionMenu<HostFormConversionKind>(
      tooltip: context.l10n.hostFormResponseOperationsSection,
      enabled: !busy,
      items: [
        CatchActionMenuItem(
          value: HostFormConversionKind.eventAttendeeProposal,
          label: context.l10n.hostFormConvertAttendee,
          icon: CatchIcons.eventAvailableOutlined,
          enabled: !attendeeComplete,
          sublabel: attendeeComplete
              ? context.l10n.hostFormConversionComplete
              : null,
        ),
      ],
      onSelected: onConvert,
    );
    return CatchBottomDock(
      child: accessibleStack
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                applicationAction,
                gapH8,
                Row(
                  children: [
                    Expanded(child: crmAction),
                    gapW8,
                    attendeeAction,
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: applicationAction),
                gapW8,
                Expanded(child: crmAction),
                gapW8,
                attendeeAction,
              ],
            ),
    );
  }
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

String _identityKindLabel(
  BuildContext context,
  HostFormResponseIdentityKind kind,
) => switch (kind) {
  HostFormResponseIdentityKind.anonymous =>
    context.l10n.hostFormResponseOriginAnonymous,
  HostFormResponseIdentityKind.emailVerified =>
    context.l10n.hostFormResponseEmail,
  HostFormResponseIdentityKind.phoneVerified =>
    context.l10n.hostFormResponsePhone,
  HostFormResponseIdentityKind.catchAccount =>
    context.l10n.hostFormIdentityCatchAccount,
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
