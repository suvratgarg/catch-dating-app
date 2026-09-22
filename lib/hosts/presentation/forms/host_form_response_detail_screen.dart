import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/crm/host_saved_audience_repository.dart';
import 'package:catch_dating_app/hosts/data/host_application_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_conversion.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_application_context.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_application_copy.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_review_detail.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
part 'host_response_answer_section.dart';
part 'host_response_detail_section.dart';

/// One detail surface for submitted forms and imported application records.
class HostFormResponseDetailScreen extends ConsumerStatefulWidget {
  const HostFormResponseDetailScreen({
    super.key,
    required this.organizerId,
    required String this.responseId,
  }) : applicationId = null;
  const HostFormResponseDetailScreen.application({
    super.key,
    required this.organizerId,
    required String this.applicationId,
  }) : responseId = null;
  final String organizerId;
  final String? responseId;
  final String? applicationId;
  @override
  ConsumerState<HostFormResponseDetailScreen> createState() =>
      _HostFormResponseDetailScreenState();
}

class _HostFormResponseDetailScreenState
    extends ConsumerState<HostFormResponseDetailScreen> {
  final _note = TextEditingController();
  HostFormConversionKind? _converting;
  bool _saving = false;
  int? _noteRevision;
  bool get _busy => _saving || _converting != null;
  HostResponseReviewKey get _key => (
    organizerId: widget.organizerId,
    responseId: widget.responseId,
    applicationId: widget.applicationId,
  );
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _reload() {
    final loaded = ref
        .read(hostResponseReviewDetailProvider(_key))
        .asData
        ?.value;
    final responseId =
        widget.responseId ??
        loaded?.response?.response.responseId ??
        (widget.applicationId == null
            ? null
            : ref
                  .read(
                    hostApplicationDetailProvider(
                      widget.organizerId,
                      widget.applicationId!,
                    ),
                  )
                  .asData
                  ?.value
                  .sourceResponseId);
    final applicationId =
        widget.applicationId ??
        loaded?.application?.applicationId ??
        (responseId == null
            ? null
            : ref
                  .read(
                    hostFormResponseDetailProvider(
                      organizerId: widget.organizerId,
                      responseId: responseId,
                    ),
                  )
                  .asData
                  ?.value
                  .applicationId);
    if (responseId != null) {
      ref.invalidate(
        hostFormResponseDetailProvider(
          organizerId: widget.organizerId,
          responseId: responseId,
        ),
      );
    }
    if (applicationId != null) {
      ref.invalidate(
        hostApplicationDetailProvider(widget.organizerId, applicationId),
      );
    }
    ref.invalidate(hostResponseReviewDetailProvider(_key));
    ref.invalidate(hostFormResponsesControllerProvider);
    ref.invalidate(hostApplicationsDirectoryControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(hostResponseReviewDetailProvider(_key));
    final loaded = catchAsyncStateFromAsyncValue(detail).value;
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
        title: loaded?.displayName ?? context.l10n.hostAudienceResponseTitle,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
      ),
      footer: loaded == null
          ? null
          : HostResponsePrimaryAction(
              value: loaded,
              busy: _busy,
              saving: _saving,
              converting: _converting != null,
              onReview: _review,
              onOpenPerson: _openPerson,
              onConvert: _reviewConversion,
            ),
      body: CatchRouteBody.fullBleed(
        child: CatchAsyncBoundary<HostResponseReviewDetail>(
          value: detail,
          onRetry: _reload,
          initialLoadTimeout: null,
          errorContext: AppErrorContext.formResponses,
          builder: (context, value) {
            final application = value.application;
            if (application != null && _noteRevision != application.revision) {
              _noteRevision = application.revision;
              _note.text = application.reviewNote ?? '';
            }
            return CatchPageBody.screen(
              child: HostResponseDetailSection(
                value: value,
                organizerId: widget.organizerId,
                note: _note,
                busy: _busy,
                saving: _saving,
                onReview: _review,
                onOpenPerson: _openPerson,
                onConvert: _reviewConversion,
                onOpenAsset: _openAsset,
                onContact: _openContact,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openPerson(String id) => context.pushNamed(
    Routes.hostCustomerDetailScreen.name,
    pathParameters: {'contactId': id},
    queryParameters: {'organizerId': widget.organizerId},
  );

  Future<void> _review(
    HostApplicationDetail application,
    HostApplicationReviewStatus status,
  ) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(hostApplicationsControllerProvider)
          .reviewApplication(
            organizerId: widget.organizerId,
            applicationId: application.applicationId,
            expectedRevision: application.revision,
            reviewStatus: status,
            reviewNote: _note.text,
          );
      _reload();
      if (mounted) {
        showCatchSnackBar(context, context.l10n.hostApplicationReviewUpdated);
      }
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.applications,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    Event? selectedEvent;
    String? eventId;
    if (kind == HostFormConversionKind.eventAttendeeProposal) {
      final event = await _selectEvent();
      if (event == null || !mounted) return;
      eventId = event.id;
      selectedEvent = event;
    }
    setState(() => _converting = kind);
    try {
      final controller = ref.read(hostFormsControllerProvider);
      final preview = await controller.previewConversion(
        organizerId: widget.organizerId,
        responseId: detail.response.responseId,
        kind: kind,
        eventId: eventId,
      );
      if (!mounted) return;
      final confirmed = await _showConversionPreview(
        preview,
        event: selectedEvent,
      );
      if (confirmed != true || !mounted) return;
      await controller.convertResponse(
        organizerId: widget.organizerId,
        responseId: detail.response.responseId,
        kind: kind,
        eventId: eventId,
        requestId: 'conversion_${DateTime.now().microsecondsSinceEpoch}',
      );
      if (!mounted) return;
      _reload();
      showCatchSnackBar(context, context.l10n.hostFormConversionComplete);
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _converting = null);
    }
  }

  Future<bool?> _showConversionPreview(
    HostFormConversionPreview preview, {
    Event? event,
  }) => showDialog<bool>(
    context: context,
    builder: (dialogContext) => CatchDialog(
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
                      copy: catchFieldCopy(context.l10n),
                      title: field.label,
                      titleMaxLines: 2,
                      valueMaxLines: 4,
                      valueText:
                          field.destinationField == 'eventId' &&
                              event != null &&
                              field.value == event.id
                          ? event.name
                          : field.value?.toString() ??
                                context.l10n.hostFormResponseNotProvided,
                      body: field.conflict,
                      bodyMaxLines: 4,
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
        builder: (dialogContext) => CatchDialog(
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
                            copy: catchFieldCopy(context.l10n),
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
