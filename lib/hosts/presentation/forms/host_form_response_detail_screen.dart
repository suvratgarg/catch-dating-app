import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        title: context.l10n.hostAudienceResponseTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      bottomNavigationBar:
          loadedDetail?.response.status == HostFormResponseStatus.submitted
          ? HostFormResponsePrimaryAction(
              detail: loadedDetail!,
              organizerId: widget.organizerId,
              converting: _converting,
              onConvert: (kind) => _reviewConversion(loadedDetail, kind),
            )
          : null,
      body: CatchRouteBody.standardConstrained(
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
              CatchFieldLanes.single(
                child: CatchField.control(
                  title: context.l10n.hostAudienceSubmissionDetails,
                  contractExemption:
                      'Read-only disclosure of server-owned response metadata; no scalar value is persisted.',
                  control: _ResponseTechnicalDetails(detail: value),
                ),
              ),
              if (value.response.status == HostFormResponseStatus.submitted ||
                  value.contactId != null ||
                  value.applicationId != null) ...[
                gapH24,
                HostFormResponseRelatedActions(
                  detail: value,
                  organizerId: widget.organizerId,
                  converting: _converting,
                  onConvert: (kind) => _reviewConversion(value, kind),
                ),
              ],
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
      showCatchSnackBar(context, context.l10n.hostFormConversionComplete);
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
  Widget build(BuildContext context) => CatchPersonRow.directory(
    key: const ValueKey('host-form-response-name'),
    data: CatchPersonRowData(
      name:
          detail.response.identity.primaryLabel ??
          context.l10n.hostFormResponsesAnonymous,
      seed: detail.response.responseId,
    ),
    metadata: Text(
      detail.response.formTitle,
      style: CatchTextStyles.supporting(context),
    ),
    contextContent: Text(
      '${context.l10n.hostAudienceResultsVersion(version: detail.response.version)} · ${AppTimeFormatters.dateTime(detail.response.submittedAt)}',
      style: CatchTextStyles.recordContext(context),
    ),
    status: CatchBadge.status(
      key: const ValueKey('host-form-response-status'),
      label: detail.response.status == HostFormResponseStatus.submitted
          ? context.l10n.hostFormResponsesSubmitted
          : context.l10n.hostFormResponsesWithdrawn,
    ),
  );
}

class _ResponseContactActions extends StatelessWidget {
  const _ResponseContactActions({required this.identity, required this.onOpen});
  final HostFormResponseIdentity identity;
  final ValueChanged<Uri> onOpen;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: CatchSpacing.s4,
    runSpacing: CatchSpacing.s2,
    children: [
      if (identity.phoneE164 case final phone?)
        CatchButton.command(
          key: const ValueKey('host-form-response-call'),
          label: context.l10n.hostApplicationCall,
          icon: Icon(CatchIcons.phoneOutlined),
          onPressed: () => onOpen(Uri(scheme: 'tel', path: phone)),
        ),
      if (identity.email case final email?)
        CatchButton.command(
          key: const ValueKey('host-form-response-email'),
          label: context.l10n.hostApplicationEmail,
          icon: Icon(CatchIcons.emailOutlined),
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
    return Padding(
      padding: CatchInsets.contentVerticalCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CatchTextStyles.recordTitle(context)),
          gapH8,
          Text(answer, style: CatchTextStyles.recordBody(context)),
          gapH8,
          Text(origin, style: CatchTextStyles.recordContext(context)),
        ],
      ),
    );
  }
}

class _ResponseTechnicalDetails extends StatelessWidget {
  const _ResponseTechnicalDetails({required this.detail});

  final HostFormResponseDetail detail;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    children: [
      CatchField.read(
        title: context.l10n.hostFormResponseIdentitySection,
        valueText: _identityKindLabel(context, detail.response.identityKind),
      ),
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

class HostFormResponsePrimaryAction extends ConsumerWidget {
  const HostFormResponsePrimaryAction({
    super.key,
    required this.detail,
    required this.organizerId,
    required this.converting,
    required this.onConvert,
  });
  final HostFormResponseDetail detail;
  final String organizerId;
  final HostFormConversionKind? converting;
  final ValueChanged<HostFormConversionKind> onConvert;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (detail.applicationId case final id?) {
      return CatchBottomAction(
        buttonKey: const ValueKey('host-form-response-convert-application'),
        label: context.l10n.hostAudienceReviewApplication,
        onPressed: converting != null
            ? null
            : () => context.pushNamed(
                Routes.hostApplicationDetailScreen.name,
                pathParameters: {'applicationId': id},
                queryParameters: {'organizerId': organizerId},
              ),
      );
    }
    final provider = hostFormResponseCanApplyProvider(
      organizerId: organizerId,
      responseId: detail.response.responseId,
    );
    return CatchAsyncValueView<bool>(
      value: ref.watch(provider),
      initialLoadTimeout: null,
      onRetry: () => ref.invalidate(provider),
      loadingBuilder: (_) => const SizedBox.shrink(),
      errorBuilder: (_, error, _) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.formResponses,
        mode: CatchErrorStateMode.compact,
        onRetry: () => ref.invalidate(provider),
      ),
      builder: (context, canApply) {
        if (canApply) {
          return CatchBottomAction(
            buttonKey: const ValueKey('host-form-response-convert-application'),
            label: context.l10n.hostAudienceReviewApplication,
            isLoading: converting == HostFormConversionKind.application,
            onPressed: converting != null
                ? null
                : () => onConvert(HostFormConversionKind.application),
          );
        }
        if (detail.contactId case final id?) {
          return CatchBottomAction(
            label: context.l10n.hostApplicationOpenPerson,
            onPressed: converting != null
                ? null
                : () => context.pushNamed(
                    Routes.hostCustomerDetailScreen.name,
                    pathParameters: {'contactId': id},
                    queryParameters: {'organizerId': organizerId},
                  ),
          );
        }
        if (detail.response.conversionKinds.contains(
          HostFormConversionKind.crmContact,
        )) {
          return const SizedBox.shrink();
        }
        return CatchBottomAction(
          buttonKey: const ValueKey('host-form-response-convert-crm-primary'),
          label: context.l10n.hostFormConvertCrm,
          isLoading: converting == HostFormConversionKind.crmContact,
          onPressed: converting != null
              ? null
              : () => onConvert(HostFormConversionKind.crmContact),
        );
      },
    );
  }
}

class HostFormResponseRelatedActions extends ConsumerWidget {
  const HostFormResponseRelatedActions({
    super.key,
    required this.detail,
    required this.organizerId,
    required this.converting,
    required this.onConvert,
  });
  final HostFormResponseDetail detail;
  final String organizerId;
  final HostFormConversionKind? converting;
  final ValueChanged<HostFormConversionKind> onConvert;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitted =
        detail.response.status == HostFormResponseStatus.submitted;
    final applicationPrimary =
        detail.applicationId != null ||
        (submitted &&
            catchAsyncStateFromAsyncValue(
                  ref.watch(
                    hostFormResponseCanApplyProvider(
                      organizerId: organizerId,
                      responseId: detail.response.responseId,
                    ),
                  ),
                ).value !=
                false);
    final children = <Widget>[
      if (detail.applicationId case final id? when !submitted)
        CatchFieldLanes.single(
          child: CatchField.nav(
            title: context.l10n.hostAudienceReviewApplication,
            onTap: () => context.pushNamed(
              Routes.hostApplicationDetailScreen.name,
              pathParameters: {'applicationId': id},
              queryParameters: {'organizerId': organizerId},
            ),
          ),
        ),
      if (!submitted || applicationPrimary) ...[
        if (detail.contactId case final id?)
          CatchFieldLanes.single(
            child: CatchField.nav(
              title: context.l10n.hostApplicationOpenPerson,
              onTap: () => context.pushNamed(
                Routes.hostCustomerDetailScreen.name,
                pathParameters: {'contactId': id},
                queryParameters: {'organizerId': organizerId},
              ),
            ),
          )
        else if (submitted &&
            !detail.response.conversionKinds.contains(
              HostFormConversionKind.crmContact,
            ))
          CatchFieldLanes.single(
            child: CatchField.nav(
              key: const ValueKey('host-form-response-convert-crm'),
              title: context.l10n.hostFormConvertCrm,
              onTap: converting != null
                  ? null
                  : () => onConvert(HostFormConversionKind.crmContact),
            ),
          ),
      ],
      if (submitted &&
          !detail.response.conversionKinds.contains(
            HostFormConversionKind.eventAttendeeProposal,
          ))
        CatchFieldLanes.single(
          child: CatchField.nav(
            title: context.l10n.hostFormConvertAttendee,
            onTap: converting != null
                ? null
                : () => onConvert(HostFormConversionKind.eventAttendeeProposal),
          ),
        ),
    ];
    return children.isEmpty
        ? const SizedBox.shrink()
        : CatchSection.fieldRows(children: children);
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
