part of 'host_form_response_detail_screen.dart';

class _ResponseDetailContent extends ConsumerWidget {
  const _ResponseDetailContent({
    required this.value,
    required this.organizerId,
    required this.note,
    required this.busy,
    required this.saving,
    required this.onReview,
    required this.onOpenPerson,
    required this.onConvert,
    required this.onOpenAsset,
    required this.onContact,
  });
  final HostResponseReviewDetail value;
  final String organizerId;
  final TextEditingController note;
  final bool busy;
  final bool saving;
  final Future<void> Function(
    HostApplicationDetail,
    HostApplicationReviewStatus,
  )
  onReview;
  final ValueChanged<String> onOpenPerson;
  final Future<void> Function(HostFormResponseDetail, HostFormConversionKind)
  onConvert;
  final Future<void> Function(HostFormAssetDownload) onOpenAsset;
  final Future<void> Function(Uri) onContact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final response = value.response;
    final application = value.application;
    final sources = response == null
        ? catchAsyncStateFromAsyncValue(
            ref.watch(hostSavedAudienceFilterOptionsProvider(organizerId)),
          )
        : null;
    final formTitle =
        response?.response.formTitle ??
        (application == null
            ? ''
            : hostApplicationContextLabel(
                context,
                formId: application.formId,
                targetKind: application.targetKind,
                targetId: application.targetId,
                sources: sources?.value,
              ));
    final submitted =
        response?.response.submittedAt ?? application!.submittedAt;
    final origins =
        response?.answers.map((answer) => answer.origin).toSet() ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(formTitle, style: CatchTextStyles.recordTitle(context)),
        gapH8,
        Text(
          AppTimeFormatters.dateTime(submitted),
          style: CatchTextStyles.supporting(context),
        ),
        gapH8,
        Align(
          alignment: Alignment.centerLeft,
          child: CatchBadge(
            label: application == null
                ? value.withdrawn
                      ? context.l10n.hostFormResponsesWithdrawn
                      : context.l10n.hostFormResponsesSubmitted
                : hostApplicationStatusLabel(context, application.reviewStatus),
            tone: application == null
                ? CatchBadgeTone.neutral
                : hostApplicationStatusTone(application.reviewStatus),
          ),
        ),
        if (sources?.isTerminalError == true && response == null)
          CatchButton.command(
            label: context.l10n.hostAudienceRetrySourceNames,
            onPressed: () => ref.invalidate(
              hostSavedAudienceFilterOptionsProvider(organizerId),
            ),
          ),
        if (!value.revoked) ...[
          gapH24,
          _ResponseContactActions(value: value, onContact: onContact),
        ],
        if (value.canReview) ...[
          gapH24,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final (status, label) in [
                (
                  HostApplicationReviewStatus.inReview,
                  context.l10n.hostApplicationMarkInReview,
                ),
                (
                  HostApplicationReviewStatus.waitlisted,
                  context.l10n.hostApplicationWaitlist,
                ),
                (
                  HostApplicationReviewStatus.declined,
                  context.l10n.hostApplicationDecline,
                ),
              ])
                CatchButton(
                  label: label,
                  variant: status == HostApplicationReviewStatus.declined
                      ? CatchButtonVariant.dangerSecondary
                      : CatchButtonVariant.secondary,
                  onPressed: busy || application!.reviewStatus == status
                      ? null
                      : () => onReview(application, status),
                ),
            ],
          ),
        ],
        gapH24,
        CatchSection.divided(
          title: context.l10n.hostFormResponseAnswersSection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (value.revoked)
                Text(
                  context.l10n.hostFormResponseOriginRevoked,
                  style: CatchTextStyles.supporting(context),
                )
              else if (response != null) ...[
                if (origins.length == 1)
                  Text(
                    _originLabel(context, origins.single),
                    style: CatchTextStyles.supporting(context),
                  ),
                for (final answer in response.answers) ...[
                  _ResponseAnswerBlock(
                    label: answer.label,
                    answer: _answerText(context, answer.answer),
                    origin: origins.length == 1
                        ? null
                        : _originLabel(context, answer.origin),
                  ),
                  for (final asset in answer.assetDownloads)
                    CatchField.nav(
                      copy: catchFieldCopy(context.l10n),
                      title: context.l10n.hostFormResponseDownloadFile(
                        fileName: asset.fileName,
                      ),
                      body: asset.contentType,
                      icon: CatchIcons.downloadRounded,
                      onTap: () => onOpenAsset(asset),
                    ),
                ],
              ] else if (application != null)
                for (final answer in application.answers)
                  _ResponseAnswerBlock(
                    label: answer.questionLabel,
                    answer: hostApplicationAnswerText(context, answer.value),
                  ),
            ],
          ),
        ),
        if (value.canReview) ...[
          gapH24,
          CatchSection.divided(
            title: context.l10n.hostApplicationReviewNote,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchField.input(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostApplicationReviewNote,
                  controller: note,
                  inputHint: context.l10n.hostApplicationReviewNoteHint,
                  contract: CatchContractConstraints
                      .reviewOrganizerApplicationCallablePayloadReviewNote,
                  labelMode: CatchFieldLabelTextMode.optional,
                  maxLines: 3,
                ),
                gapH12,
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: note,
                  builder: (context, text, _) => CatchButton(
                    label: context.l10n.hostResponseSaveReviewNote,
                    variant: CatchButtonVariant.secondary,
                    status: saving
                        ? CatchButtonStatus.loading
                        : CatchButtonStatus.idle,
                    onPressed:
                        busy ||
                            text.text.trim() ==
                                (application!.reviewNote ?? '').trim()
                        ? null
                        : () => onReview(application, application.reviewStatus),
                  ),
                ),
              ],
            ),
          ),
        ] else if (application?.reviewNote case final String note
            when !value.revoked) ...[
          gapH24,
          CatchSection.divided(
            title: context.l10n.hostApplicationReviewNote,
            child: Text(note, style: CatchTextStyles.recordBody(context)),
          ),
        ],
        gapH24,
        CatchFieldLanes.single(
          child: CatchField.control(
            copy: catchFieldCopy(context.l10n),
            title: context.l10n.hostAudienceSubmissionDetails,
            contractExemption:
                'Read-only disclosure of authorized submission and review metadata.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchField.read(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostFormResponseSubmittedAt,
                  valueText: AppTimeFormatters.dateTime(submitted),
                ),
                if (response != null && !value.revoked) ...[
                  CatchField.read(
                    copy: catchFieldCopy(context.l10n),
                    title: context.l10n.hostAudienceResultsVersion(
                      version: response.response.version,
                    ),
                    valueText: AppTimeFormatters.dateTime(
                      response.response.submittedAt,
                    ),
                  ),
                  _ResponseTechnicalDetails(detail: response),
                ],
                if (application?.reviewedAt case final DateTime date)
                  CatchField.read(
                    copy: catchFieldCopy(context.l10n),
                    title: hostApplicationStatusLabel(
                      context,
                      application!.reviewStatus,
                    ),
                    valueText: AppTimeFormatters.dateTime(date),
                  ),
              ],
            ),
          ),
        ),
        if (value.canConvert) ...[
          gapH24,
          CatchSection.fieldRows(
            children: [
              if (application != null &&
                  value.contactId != null &&
                  application.reviewStatus !=
                      HostApplicationReviewStatus.approved)
                CatchField.nav(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostApplicationOpenPerson,
                  onTap: busy ? null : () => onOpenPerson(value.contactId!),
                )
              else if (application != null &&
                  value.contactId == null &&
                  !response!.response.conversionKinds.contains(
                    HostFormConversionKind.crmContact,
                  ))
                CatchField.nav(
                  key: const ValueKey('host-form-response-convert-crm'),
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostFormConvertCrm,
                  onTap: busy
                      ? null
                      : () => onConvert(
                          response,
                          HostFormConversionKind.crmContact,
                        ),
                ),
              CatchField.nav(
                copy: catchFieldCopy(context.l10n),
                title: context.l10n.hostFormConvertAttendee,
                onTap: busy
                    ? null
                    : () => onConvert(
                        response!,
                        HostFormConversionKind.eventAttendeeProposal,
                      ),
              ),
            ],
          ),
          if (application == null)
            _ResponseStartReview(
              organizerId: organizerId,
              response: response!,
              busy: busy,
              onConvert: onConvert,
            ),
        ],
        if (value.canReview) ...[
          gapH16,
          Text(
            application!.reviewStatus == HostApplicationReviewStatus.approved
                ? value.contactId != null
                      ? context.l10n.hostAudienceApplicationAccepted
                      : context.l10n.hostAudienceApplicationApprovedUnlinked
                : context.l10n.hostAudienceApplicationAdmission,
            style: CatchTextStyles.supporting(context),
          ),
        ],
        gapH32,
      ],
    );
  }
}

class _ResponseStartReview extends ConsumerWidget {
  const _ResponseStartReview({
    required this.organizerId,
    required this.response,
    required this.busy,
    required this.onConvert,
  });
  final String organizerId;
  final HostFormResponseDetail response;
  final bool busy;
  final Future<void> Function(HostFormResponseDetail, HostFormConversionKind)
  onConvert;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = hostFormResponseCanApplyProvider(
      organizerId: organizerId,
      responseId: response.response.responseId,
    );
    return CatchAsyncBoundary<bool>(
      value: ref.watch(provider),
      initialLoadTimeout: null,
      onRetry: () => ref.invalidate(provider),
      loadingBuilder: (_) => const SizedBox.shrink(),
      builder: (context, canApply) => !canApply
          ? const SizedBox.shrink()
          : CatchButton(
              label: context.l10n.hostResponseStartReview,
              variant: CatchButtonVariant.secondary,
              onPressed: busy
                  ? null
                  : () =>
                        onConvert(response, HostFormConversionKind.application),
            ),
    );
  }
}

class _ResponseContactActions extends StatelessWidget {
  const _ResponseContactActions({required this.value, required this.onContact});
  final HostResponseReviewDetail value;
  final Future<void> Function(Uri) onContact;
  @override
  Widget build(BuildContext context) {
    final outreach = value.application?.outreach;
    final identity = value.response?.response.identity;
    final actions = <({String label, IconData icon, Uri uri})>[
      if (outreach?.phoneE164 ?? identity?.phoneE164 case final String phone)
        (
          label: context.l10n.hostApplicationCall,
          icon: CatchIcons.phoneOutlined,
          uri: Uri(scheme: 'tel', path: phone),
        ),
      if (outreach?.email ?? identity?.email case final String email)
        (
          label: context.l10n.hostApplicationEmail,
          icon: CatchIcons.emailOutlined,
          uri: Uri(scheme: 'mailto', path: email),
        ),
      if (outreach?.instagramUrl case final String url)
        (
          label: context.l10n.hostApplicationInstagram,
          icon: CatchIcons.openInNewRounded,
          uri: Uri.parse(url),
        ),
      if (outreach?.linkedinUrl case final String url)
        (
          label: context.l10n.hostApplicationLinkedin,
          icon: CatchIcons.openInNewRounded,
          uri: Uri.parse(url),
        ),
    ];
    final singleColumn = MediaQuery.textScalerOf(context).scale(16) > 24;
    final buttons = [
      for (final action in actions)
        CatchButton(
          key: ValueKey(
            'response-contact-${action.uri.scheme}-${action.label}',
          ),
          label: action.label,
          leading: Icon(action.icon),
          fullWidth: true,
          variant: CatchButtonVariant.secondary,
          onPressed: () => onContact(action.uri),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (
          var index = 0;
          index < buttons.length;
          index += singleColumn ? 1 : 2
        ) ...[
          if (index > 0) gapH12,
          if (singleColumn)
            buttons[index]
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buttons[index]),
                gapW12,
                Expanded(
                  child: index + 1 < buttons.length
                      ? buttons[index + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ],
    );
  }
}

class _ResponsePrimaryAction extends StatelessWidget {
  const _ResponsePrimaryAction({
    required this.value,
    required this.busy,
    required this.saving,
    required this.converting,
    required this.onReview,
    required this.onOpenPerson,
    required this.onConvert,
  });
  final HostResponseReviewDetail value;
  final bool busy;
  final bool saving;
  final bool converting;
  final Future<void> Function(
    HostApplicationDetail,
    HostApplicationReviewStatus,
  )
  onReview;
  final ValueChanged<String> onOpenPerson;
  final Future<void> Function(HostFormResponseDetail, HostFormConversionKind)
  onConvert;
  @override
  Widget build(BuildContext context) {
    final application = value.application;
    final response = value.response;
    final contactId = value.contactId;
    if (value.revoked) return const SizedBox.shrink();
    if (application != null &&
        value.canReview &&
        application.reviewStatus != HostApplicationReviewStatus.approved) {
      return CatchDockSurface.pageAction(
        buttonKey: const ValueKey('host-application-primary-action'),
        label: context.l10n.hostApplicationApprove,
        isLoading: saving,
        onPressed: busy
            ? null
            : () => onReview(application, HostApplicationReviewStatus.approved),
      );
    }
    if (contactId != null) {
      return CatchDockSurface.pageAction(
        buttonKey: const ValueKey('host-application-open-person'),
        label: context.l10n.hostApplicationOpenPerson,
        onPressed: busy ? null : () => onOpenPerson(contactId),
      );
    }
    if (application == null &&
        response != null &&
        value.canConvert &&
        !response.response.conversionKinds.contains(
          HostFormConversionKind.crmContact,
        )) {
      return CatchDockSurface.pageAction(
        buttonKey: const ValueKey('host-form-response-convert-crm-primary'),
        label: context.l10n.hostFormConvertCrm,
        isLoading: converting,
        onPressed: busy
            ? null
            : () => onConvert(response, HostFormConversionKind.crmContact),
      );
    }
    return const SizedBox.shrink();
  }
}
