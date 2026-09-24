import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/data/forms/host_offer_event_targets_gateway.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_workspace_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_review_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostEventOfferWorkspaceCopy {
  const HostEventOfferWorkspaceCopy({
    required this.create,
    required this.selectEvent,
    required this.emptyEvents,
    required this.untitledEvent,
    required this.loadMoreEvents,
    required this.needsContact,
    required this.convertContact,
    required this.selectionChanged,
    required this.loadFailed,
    required this.issued,
    required this.refresh,
    required this.existing,
    required this.noOffers,
    required this.configurePayment,
    required this.openSettings,
    required this.statusDraft,
    required this.statusOffered,
    required this.statusWithdrawn,
    required this.statusExpired,
    required this.personalPaymentLink,
    required this.openExisting,
    required this.handoffPrepare,
    required this.handoffBlocked,
    required this.handoffDisclosure,
    required this.openWhatsapp,
    required this.copyMessage,
    required this.messageCopied,
    required this.handoffOpenFailed,
    required this.review,
  });

  final String create;
  final String selectEvent;
  final String emptyEvents;
  final String untitledEvent;
  final String loadMoreEvents;
  final String needsContact;
  final String convertContact;
  final String selectionChanged;
  final String loadFailed;
  final String issued;
  final String refresh;
  final String existing;
  final String noOffers;
  final String configurePayment;
  final String openSettings;
  final String statusDraft;
  final String statusOffered;
  final String statusWithdrawn;
  final String statusExpired;
  final String Function(String name) personalPaymentLink;
  final String openExisting;
  final String handoffPrepare;
  final String handoffBlocked;
  final String handoffDisclosure;
  final String openWhatsapp;
  final String copyMessage;
  final String messageCopied;
  final String handoffOpenFailed;
  final HostEventOfferReviewCopy review;
}

/// One manager's reviewed query selection. No offer is prepared from a list
/// label alone: every selected response is read again and the materialized
/// query hash is rechecked after the event choice and an inline return.
class HostEventOfferWorkspaceSection extends StatefulWidget {
  const HostEventOfferWorkspaceSection({
    super.key,
    required this.organizerId,
    required this.accountId,
    required this.queryController,
    required this.offerController,
    required this.listOffers,
    required this.getOffer,
    required this.prepareHandoff,
    required this.copyMessage,
    required this.openHandoff,
    required this.targets,
    required this.getResponseDetail,
    required this.openResponseForConversion,
    required this.openEventSettings,
    required this.copy,
    required this.now,
    this.initiallyReviewSelection = false,
    this.initialEventId,
  });

  final String organizerId;
  final String? accountId;
  final HostResponseQueryController queryController;
  final HostEventOfferController offerController;
  final Future<Map<String, Object?>> Function({
    required String organizerId,
    required String eventId,
    String? afterOfferId,
  }) listOffers;
  final Future<HostEventOffer> Function({required String organizerId,
    required String eventId, required String contactId}) getOffer;
  final Future<HostOfferHandoff> Function({required HostEventOffer offer})
      prepareHandoff;
  final Future<void> Function(String text) copyMessage;
  final Future<bool> Function(Uri uri) openHandoff;
  final HostOfferEventTargetsGateway targets;
  final Future<HostFormResponseDetail> Function(String responseId)
      getResponseDetail;
  final Future<void> Function(String responseId) openResponseForConversion;
  final Future<void> Function(String eventId) openEventSettings;
  final HostEventOfferWorkspaceCopy copy;
  final DateTime Function() now;
  final bool initiallyReviewSelection;
  final String? initialEventId;

  @override
  State<HostEventOfferWorkspaceSection> createState() =>
      _HostEventOfferWorkspaceSectionState();
}

class _HostEventOfferWorkspaceSectionState
    extends State<HostEventOfferWorkspaceSection> {
  late HostEventOfferWorkspaceController _controller;

  HostEventOfferWorkspaceController _createController() =>
      HostEventOfferWorkspaceController(
        organizerId: widget.organizerId,
        accountId: widget.accountId,
        queryController: widget.queryController,
        offerController: widget.offerController,
        listOffers: widget.listOffers,
        getOffer: widget.getOffer,
        prepareHandoff: widget.prepareHandoff,
        copyMessage: widget.copyMessage,
        openHandoff: widget.openHandoff,
        targets: widget.targets,
        getResponseDetail: widget.getResponseDetail,
        openResponseForConversion: widget.openResponseForConversion,
        openEventSettings: widget.openEventSettings,
        now: widget.now,
        initialEventId: widget.initialEventId,
      );

  void _changed() {
    if (mounted) setState(() {});
  }

  void _initializeController() {
    _controller = _createController()..addListener(_changed);
    if (widget.initiallyReviewSelection) {
      final controller = _controller;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && identical(controller, _controller)) controller.start();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant HostEventOfferWorkspaceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizerId != widget.organizerId ||
        oldWidget.accountId != widget.accountId ||
        oldWidget.queryController != widget.queryController ||
        oldWidget.offerController != widget.offerController ||
        oldWidget.initialEventId != widget.initialEventId) {
      _controller.removeListener(_changed);
      _controller.dispose();
      _initializeController();
    } else {
      _controller.updateDependencies(
        listOffers: widget.listOffers,
        getOffer: widget.getOffer,
        prepareHandoff: widget.prepareHandoff,
        copyMessage: widget.copyMessage,
        openHandoff: widget.openHandoff,
        targets: widget.targets,
        getResponseDetail: widget.getResponseDetail,
        openResponseForConversion: widget.openResponseForConversion,
        openEventSettings: widget.openEventSettings,
        now: widget.now,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  String _offerLabel(Map<String, Object?> offer) =>
      _controller.details.where((detail) =>
          detail.contactId == offer['contactId']).firstOrNull
          ?.response.identity.primaryLabel ?? widget.copy.existing;

  String _offerStatus(Object? status) => switch (status) {
    'draft' => widget.copy.statusDraft,
    'offered' => widget.copy.statusOffered,
    'withdrawn' => widget.copy.statusWithdrawn,
    'expired' => widget.copy.statusExpired,
    _ => widget.copy.loadFailed,
  };

  String _eventTimeLabel(HostOfferEventTarget event) {
    final local = event.startTime.toLocal();
    final displayed = '${AppTimeFormatters.dateTime(local)} '
        '${local.timeZoneName}';
    final eventZone = event.timezone?.trim();
    return eventZone == null || eventZone.isEmpty ||
        eventZone == local.timeZoneName
        ? displayed : '$displayed · $eventZone';
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final intent = widget.queryController.selectionIntent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (intent != null && widget.accountId != null)
          CatchSection.content(child: CatchButton(
            label: copy.create,
            onPressed: _controller.loading ? null : _controller.start,
          )),
        if (_controller.ids.isNotEmpty) ...[
          CatchSection.content(child: Text(copy.selectEvent,
            style: CatchTextStyles.sectionTitle(context))),
          if (_controller.events.isEmpty && !_controller.loading)
            CatchSection.content(child: Text(copy.emptyEvents,
              style: CatchTextStyles.supporting(context))),
          if (_controller.events.isNotEmpty)
            CatchSection.fieldRows(children: [
              for (final event in _controller.events)
                CatchField.nav(
                  key: ValueKey('offer-target-${event.eventId}'),
                  copy: catchFieldCopy(context.l10n),
                  title: event.name?.trim().isNotEmpty == true
                      ? event.name! : copy.untitledEvent,
                  body: _eventTimeLabel(event),
                  onTap: _controller.loading ? null : () => _controller.choose(event),
                ),
            ]),
          if (_controller.nextEventCursor != null)
            CatchSection.content(child: CatchButton(
              label: copy.loadMoreEvents,
              variant: CatchButtonVariant.secondary,
              onPressed: _controller.loading ? null : _controller.loadEvents,
            )),
          if (_controller.event != null) ...[
            if (_controller.missingContacts.isNotEmpty) ...[
              CatchSection.content(child: Text(copy.needsContact,
                style: CatchTextStyles.supporting(context))),
              CatchSection.fieldRows(children: [
                for (final detail in _controller.missingContacts)
                  CatchField.nav(
                    key: ValueKey('offer-convert-${detail.response.responseId}'),
                    copy: catchFieldCopy(context.l10n),
                    title: detail.response.identity.primaryLabel ??
                        context.l10n.hostFormResponsesAnonymous,
                    body: copy.convertContact,
                    onTap: _controller.loading ? null : () => _controller.returnForConversion(
                      detail.response.responseId),
                  ),
              ]),
            ] else if (_controller.configuration?.suggestedExpiresAt == null)
              CatchSection.content(child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(copy.configurePayment,
                    style: CatchTextStyles.supporting(context)),
                  CatchButton(label: copy.openSettings,
                    onPressed: _controller.loading ? null : _controller.openSettings),
                ],
              ))
            else if (_controller.draft case final draft?)
              HostEventOfferReviewSection(
                controller: widget.offerController,
                draft: draft,
                eventTitle: _controller.event!.name?.trim().isNotEmpty == true
                    ? _controller.event!.name! : copy.untitledEvent,
                contactLabel: (id) => _controller.details
                    .where((detail) => detail.contactId == id)
                    .firstOrNull?.response.identity.primaryLabel ??
                    context.l10n.hostFormResponsesAnonymous,
                eventStartsAt: _controller.configuration!.startsAt,
                now: widget.now,
                commitRequestId: _controller.commitRequestId!,
                copy: copy.review,
              ),
            if (_controller.draft == null && _controller.personalMode &&
                _controller.missingContacts.isEmpty &&
                _controller.configuration?.suggestedExpiresAt != null) ...[
              CatchSection.fieldRows(children: [
                for (final detail in _controller.details)
                  CatchField.input(
                    key: ValueKey('offer-link-${detail.response.responseId}'),
                    copy: catchFieldCopy(context.l10n),
                    title: copy.personalPaymentLink(
                      detail.response.identity.primaryLabel ??
                      context.l10n.hostFormResponsesAnonymous),
                    contractExemption: 'Explicit organizer-owned HTTPS link '
                      'for this recipient; no provider charge is initiated.',
                    onChanged: (value) =>
                      _controller.setPersonalLink(detail.contactId!, value),
                  ),
              ]),
              CatchSection.content(child: CatchButton(
                label: copy.review.preview,
                onPressed: _controller.loading ? null : _controller.previewPersonal,
              )),
            ],
            CatchSection.content(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.offerController.view.status ==
                    HostOfferFlowStatus.committed)
                  Text(copy.issued, style: CatchTextStyles.supporting(context)),
                Text(copy.existing,
                  style: CatchTextStyles.sectionTitle(context)),
                if (_controller.offers.isEmpty)
                  Text(copy.noOffers,
                    style: CatchTextStyles.supporting(context)),
                CatchButton(label: copy.refresh,
                  variant: CatchButtonVariant.secondary,
                  onPressed: _controller.loading ? null : _controller.refreshOffers),
                if (_controller.nextOfferCursor != null)
                  CatchButton(label: context.l10n.hostFormResponsesLoadMore,
                    variant: CatchButtonVariant.secondary,
                    onPressed: _controller.loading ? null : () => _controller.fetchMoreOffers()),
              ],
            )),
            if (_controller.offers.isNotEmpty)
              CatchSection.fieldRows(children: [
                for (final offer in _controller.offers)
                  CatchField.nav(
                    key: ValueKey('offer-existing-${offer['offerId']}'),
                    copy: catchFieldCopy(context.l10n),
                    title: _offerLabel(offer),
                    body: '${_offerStatus(offer['effectiveStatus'])} · '
                        '${copy.openExisting}',
                    onTap: _controller.loading ? null : () => _controller.selectExisting(offer),
                  ),
              ]),
            if (_controller.selectedOffer case final selected?) ...[
              if (selected.effectiveStatus == HostOfferStatus.offered)
                HostManualPaymentReviewSection(
                  key: ValueKey('offer-manual-${selected.offerId}-'
                    '${selected.generation}-${selected.revision}'),
                  controller: widget.offerController,
                  offer: selected,
                  copy: copy.review,
                  referenceRequestId: _controller.referenceRequestId!,
                  reviewRequestId: _controller.reviewRequestId!,
                  onUpdated: _controller.manualUpdated,
                ),
              CatchSection.content(child: CatchButton(
                label: copy.handoffPrepare,
                variant: CatchButtonVariant.secondary,
                onPressed: _controller.loading ? null : _controller.prepareSelectedHandoff,
              )),
              if (_controller.handoff?.kind == 'blocked')
                CatchSection.content(child: Text(copy.handoffBlocked,
                  style: CatchTextStyles.supporting(context))),
              if (_controller.handoff?.kind == 'prepared')
                CatchSection.content(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(copy.handoffDisclosure,
                      style: CatchTextStyles.supporting(context)),
                    Text(_controller.handoff!.editableText!,
                      style: CatchTextStyles.supporting(context)),
                    Wrap(children: [
                      CatchButton(label: copy.openWhatsapp,
                        onPressed: _controller.loading || _controller.handoff!.whatsappUrl == null
                            ? null : _controller.openPreparedWhatsapp),
                      CatchButton(label: copy.copyMessage,
                        variant: CatchButtonVariant.secondary,
                        onPressed: _controller.loading ? null : _controller.copyPreparedHandoff),
                    ]),
                    if (_controller.messageCopied)
                      Text(copy.messageCopied,
                        style: CatchTextStyles.supporting(context)),
                    if (_controller.handoffOpenFailed)
                      Text(copy.handoffOpenFailed,
                        style: CatchTextStyles.supporting(context)),
                  ],
                )),
            ],
          ],
        ],
        if (_controller.loading)
          CatchSection.content(child: Text(copy.review.previewing,
            style: CatchTextStyles.supporting(context))),
        if (_controller.error != null || _controller.selectionStale)
          CatchSection.content(child: Text(
            _controller.selectionStale ? copy.selectionChanged : copy.loadFailed,
            style: CatchTextStyles.supporting(context))),
      ],
    );
  }
}
