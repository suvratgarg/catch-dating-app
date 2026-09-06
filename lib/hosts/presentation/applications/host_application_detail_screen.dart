part of 'host_applications_screen.dart';

class HostApplicationDetailScreen extends ConsumerStatefulWidget {
  const HostApplicationDetailScreen({
    super.key,
    required this.organizerId,
    required this.applicationId,
  });

  final String organizerId;
  final String applicationId;

  @override
  ConsumerState<HostApplicationDetailScreen> createState() =>
      _HostApplicationDetailScreenState();
}

class _HostApplicationDetailScreenState
    extends ConsumerState<HostApplicationDetailScreen> {
  final _reviewNoteController = TextEditingController();
  int? _loadedRevision;
  HostApplicationReviewStatus? _savingStatus;
  bool _activity = false;

  @override
  void dispose() {
    _reviewNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourcesProvider = hostSavedAudienceFilterOptionsProvider(
      widget.organizerId,
    );
    final sources = catchAsyncStateFromAsyncValue(ref.watch(sourcesProvider));
    final detail = ref.watch(
      hostApplicationDetailProvider(widget.organizerId, widget.applicationId),
    );
    final detailState = catchAsyncStateFromAsyncValue(detail);
    final loaded = detailState.value;
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostAudienceApplicationTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      bottomNavigationBar:
          loaded != null &&
              loaded.reviewStatus != HostApplicationReviewStatus.withdrawn &&
              loaded.dataAccessState != 'revokedParticipantGrant' &&
              (loaded.reviewStatus != HostApplicationReviewStatus.approved ||
                  loaded.contactId != null)
          ? CatchBottomAction(
              buttonKey: ValueKey(
                loaded.reviewStatus == HostApplicationReviewStatus.approved
                    ? 'host-application-open-person'
                    : 'host-application-primary-action',
              ),
              label:
                  loaded.reviewStatus == HostApplicationReviewStatus.approved &&
                      loaded.contactId != null
                  ? context.l10n.hostApplicationOpenPerson
                  : context.l10n.hostApplicationApprove,
              isLoading: _savingStatus == HostApplicationReviewStatus.approved,
              onPressed: _savingStatus != null
                  ? null
                  : () {
                      if (loaded.reviewStatus ==
                              HostApplicationReviewStatus.approved &&
                          loaded.contactId != null) {
                        context.pushNamed(
                          Routes.hostCustomerDetailScreen.name,
                          pathParameters: {'contactId': loaded.contactId!},
                          queryParameters: {'organizerId': widget.organizerId},
                        );
                      } else {
                        _review(loaded, HostApplicationReviewStatus.approved);
                      }
                    },
            )
          : null,
      body: CatchRouteBody.standardConstrained(
        child: CatchAsyncValueView<HostApplicationDetail>(
          value: detail,
          onRetry: _invalidateDetail,
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 6),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.applications,
            onRetry: _invalidateDetail,
          ),
          builder: (context, application) {
            if (_loadedRevision != application.revision) {
              _loadedRevision = application.revision;
              _reviewNoteController.text = application.reviewNote ?? '';
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchPersonRow.directory(
                  data: CatchPersonRowData(
                    name: application.applicantDisplayName,
                    seed: application.applicationId,
                  ),
                  metadata: Text(
                    hostApplicationContextLabel(
                      context,
                      formId: application.formId,
                      targetKind: application.targetKind,
                      targetId: application.targetId,
                      sources: sources.value,
                    ),
                    style: CatchTextStyles.supporting(context),
                  ),
                  contextContent: Text(
                    context.l10n.hostApplicationsSubmittedOn(
                      date: DateFormat.yMMMd().format(application.submittedAt),
                    ),
                    style: CatchTextStyles.recordContext(context),
                  ),
                  status: CatchBadge.status(
                    label: hostApplicationStatusLabel(
                      context,
                      application.reviewStatus,
                    ),
                    tone: _applicationStatusTone(application.reviewStatus),
                  ),
                ),
                if (sources.isTerminalError)
                  CatchButton.command(
                    label: context.l10n.hostAudienceRetrySourceNames,
                    onPressed: () => ref.invalidate(sourcesProvider),
                  ),
                gapH16,
                Text(
                  application.reviewStatus ==
                          HostApplicationReviewStatus.approved
                      ? application.contactId != null
                            ? context.l10n.hostAudienceApplicationAccepted
                            : context
                                  .l10n
                                  .hostAudienceApplicationApprovedUnlinked
                      : context.l10n.hostAudienceApplicationAdmission,
                  style: CatchTextStyles.supporting(context),
                ),
                gapH24,
                CatchTabRail<bool>(
                  options: [
                    CatchOption(
                      value: false,
                      label: context.l10n.hostApplicationAnswersTitle,
                    ),
                    CatchOption(
                      value: true,
                      label: context.l10n.hostAudienceApplicationActivity,
                    ),
                  ],
                  selected: _activity,
                  onChanged: (value) => setState(() => _activity = value),
                ),
                gapH16,
                if (_activity) ...[
                  CatchSection.fieldRows(
                    children: [
                      CatchField.read(
                        title: context.l10n.hostFormResponseSubmittedAt,
                        valueText: DateFormat.yMMMd().add_jm().format(
                          application.submittedAt,
                        ),
                      ),
                      if (application.reviewedAt case final date?)
                        CatchField.read(
                          title: hostApplicationStatusLabel(
                            context,
                            application.reviewStatus,
                          ),
                          valueText: DateFormat.yMMMd().add_jm().format(date),
                        ),
                    ],
                  ),
                ] else ...[
                  CatchSection.divided(
                    first: true,
                    children: [
                      for (final answer in application.answers)
                        Padding(
                          padding: CatchInsets.contentVerticalCompact,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                answer.questionLabel,
                                style: CatchTextStyles.recordTitle(context),
                              ),
                              gapH8,
                              Text(
                                _answerText(context, answer.value),
                                style: CatchTextStyles.recordBody(context),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                if (application.contactId != null ||
                    application.sourceResponseId != null) ...[
                  gapH24,
                  CatchSection.fieldRows(
                    children: [
                      if (application.contactId case final contactId?
                          when application.reviewStatus !=
                              HostApplicationReviewStatus.approved)
                        CatchField.nav(
                          key: const ValueKey('host-application-open-person'),
                          title: context.l10n.hostApplicationOpenPerson,
                          onTap: () => context.pushNamed(
                            Routes.hostCustomerDetailScreen.name,
                            pathParameters: {'contactId': contactId},
                            queryParameters: {
                              'organizerId': widget.organizerId,
                            },
                          ),
                        ),
                      if (application.sourceResponseId case final responseId?)
                        CatchField.nav(
                          title: context.l10n.hostApplicationOpenResponse,
                          onTap: () => context.pushNamed(
                            Routes.hostFormResponseDetailScreen.name,
                            pathParameters: {'responseId': responseId},
                            queryParameters: {
                              'organizerId': widget.organizerId,
                            },
                          ),
                        ),
                    ],
                  ),
                ],
                gapH24,
                _HostApplicationOutreachSection(
                  outreach: application.outreach,
                  onOpen: _openUri,
                ),
                gapH24,
                if (application.reviewStatus !=
                        HostApplicationReviewStatus.withdrawn &&
                    application.dataAccessState !=
                        'revokedParticipantGrant') ...[
                  gapH24,
                  CatchFieldLanes.single(
                    child: CatchField.control(
                      title: context.l10n.hostApplicationReviewTitle,
                      contractExemption:
                          'Disclosure for review actions; the nested note uses the generated review payload binding.',
                      initiallyOpen:
                          application.reviewStatus ==
                              HostApplicationReviewStatus.submitted ||
                          application.reviewStatus ==
                              HostApplicationReviewStatus.inReview,
                      control: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CatchField.input(
                            title: context.l10n.hostApplicationReviewNote,
                            inputHint:
                                context.l10n.hostApplicationReviewNoteHint,
                            controller: _reviewNoteController,
                            contract: CatchContractConstraints
                                .reviewOrganizerApplicationCallablePayloadReviewNote,
                            isOptional: true,
                            maxLines: 3,
                          ),
                          gapH12,
                          Wrap(
                            spacing: CatchSpacing.s2,
                            runSpacing: CatchSpacing.s2,
                            children: [
                              CatchButton(
                                label: context.l10n.hostApplicationMarkInReview,
                                variant: CatchButtonVariant.secondary,
                                size: CatchButtonSize.sm,
                                isLoading:
                                    _savingStatus ==
                                    HostApplicationReviewStatus.inReview,
                                onPressed: _savingStatus == null
                                    ? () => _review(
                                        application,
                                        HostApplicationReviewStatus.inReview,
                                      )
                                    : null,
                              ),
                              CatchButton(
                                label: context.l10n.hostApplicationWaitlist,
                                variant: CatchButtonVariant.secondary,
                                size: CatchButtonSize.sm,
                                isLoading:
                                    _savingStatus ==
                                    HostApplicationReviewStatus.waitlisted,
                                onPressed: _savingStatus == null
                                    ? () => _review(
                                        application,
                                        HostApplicationReviewStatus.waitlisted,
                                      )
                                    : null,
                              ),
                              CatchButton(
                                label: context.l10n.hostApplicationDecline,
                                variant: CatchButtonVariant.danger,
                                size: CatchButtonSize.sm,
                                isLoading:
                                    _savingStatus ==
                                    HostApplicationReviewStatus.declined,
                                onPressed: _savingStatus == null
                                    ? () => _review(
                                        application,
                                        HostApplicationReviewStatus.declined,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _invalidateDetail() => ref.invalidate(
    hostApplicationDetailProvider(widget.organizerId, widget.applicationId),
  );

  Future<void> _openUri(Uri uri) async {
    try {
      final opened = await ref.read(externalLinkControllerProvider).open(uri);
      if (!opened && mounted) {
        showCatchErrorSnackBar(
          context,
          StateError('Application destination could not be opened.'),
        );
      }
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }

  Future<void> _review(
    HostApplicationDetail application,
    HostApplicationReviewStatus status,
  ) async {
    setState(() => _savingStatus = status);
    try {
      await ref
          .read(hostApplicationsControllerProvider)
          .reviewApplication(
            organizerId: widget.organizerId,
            applicationId: widget.applicationId,
            expectedRevision: application.revision,
            reviewStatus: status,
            reviewNote: _reviewNoteController.text,
          );
      _invalidateDetail();
      ref.invalidate(hostApplicationsDirectoryControllerProvider);
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
      if (mounted) setState(() => _savingStatus = null);
    }
  }
}

class _HostApplicationOutreachSection extends StatelessWidget {
  const _HostApplicationOutreachSection({
    required this.outreach,
    required this.onOpen,
  });

  final HostApplicationOutreach outreach;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (outreach.phoneE164 case final phone?)
        CatchButton.command(
          label: context.l10n.hostApplicationCall,
          icon: Icon(CatchIcons.phoneOutlined, size: CatchIcon.sm),
          onPressed: () => onOpen(Uri(scheme: 'tel', path: phone)),
        ),
      if (outreach.email case final email?)
        CatchButton.command(
          label: context.l10n.hostApplicationEmail,
          icon: Icon(CatchIcons.emailOutlined, size: CatchIcon.sm),
          onPressed: () => onOpen(Uri(scheme: 'mailto', path: email)),
        ),
      if (outreach.instagramUrl case final url?)
        CatchButton.command(
          label: context.l10n.hostApplicationInstagram,
          icon: Icon(CatchIcons.openInNewRounded, size: CatchIcon.sm),
          onPressed: () => onOpen(Uri.parse(url)),
        ),
      if (outreach.linkedinUrl case final url?)
        CatchButton.command(
          label: context.l10n.hostApplicationLinkedin,
          icon: Icon(CatchIcons.openInNewRounded, size: CatchIcon.sm),
          onPressed: () => onOpen(Uri.parse(url)),
        ),
    ];
    return CatchSection.divided(
      title: context.l10n.hostApplicationOutreachTitle,
      child: actions.isEmpty
          ? Text(
              context.l10n.hostApplicationNoOutreach,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).ink2,
              ),
            )
          : Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: actions,
            ),
    );
  }
}
