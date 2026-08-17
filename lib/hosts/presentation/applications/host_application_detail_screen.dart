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

  @override
  void dispose() {
    _reviewNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(
      hostApplicationDetailProvider(widget.organizerId, widget.applicationId),
    );
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title:
            detail.asData?.value.applicantDisplayName ??
            context.l10n.hostApplicationsTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CatchAsyncValueView<HostApplicationDetail>(
          value: detail,
          onRetry: _invalidateDetail,
          initialLoadTimeout: null,
          loadingBuilder: (_) =>
              const CatchPageBody(child: CatchSkeletonRows(count: 6)),
          errorBuilder: (_, error, _) => CatchPageBody(
            child: CatchErrorState.fromError(
              error,
              context: AppErrorContext.customer,
              onRetry: _invalidateDetail,
            ),
          ),
          builder: (context, application) {
            if (_loadedRevision != application.revision) {
              _loadedRevision = application.revision;
              _reviewNoteController.text = application.reviewNote ?? '';
            }
            return ListView(
              padding: CatchInsets.pageBody.copyWith(bottom: 0),
              children: [
                Row(
                  children: [
                    CatchChip.tag(
                      label: hostApplicationStatusLabel(
                        context,
                        application.reviewStatus,
                      ),
                    ),
                    gapW8,
                    Expanded(
                      child: Text(
                        context.l10n.hostApplicationsSubmittedOn(
                          date: DateFormat.yMMMd().format(
                            application.submittedAt,
                          ),
                        ),
                        textAlign: TextAlign.end,
                        style: CatchTextStyles.supporting(
                          context,
                          color: CatchTokens.of(context).ink2,
                        ),
                      ),
                    ),
                  ],
                ),
                gapH24,
                _HostApplicationOutreachSection(
                  outreach: application.outreach,
                  onOpen: _openUri,
                ),
                gapH24,
                CatchSection.fieldRows(
                  title: context.l10n.hostApplicationAnswersTitle,
                  children: [
                    for (final answer in application.answers)
                      CatchField.read(
                        title: answer.questionLabel,
                        body: _answerText(context, answer.value),
                      ),
                  ],
                ),
                if (application.reviewStatus !=
                    HostApplicationReviewStatus.withdrawn) ...[
                  gapH24,
                  CatchSection.divided(
                    title: context.l10n.hostApplicationReviewTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CatchField.input(
                          title: context.l10n.hostApplicationReviewNote,
                          inputHint: context.l10n.hostApplicationReviewNoteHint,
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
                              label: context.l10n.hostApplicationApprove,
                              size: CatchButtonSize.sm,
                              isLoading:
                                  _savingStatus ==
                                  HostApplicationReviewStatus.approved,
                              onPressed: _savingStatus == null
                                  ? () => _review(
                                      application,
                                      HostApplicationReviewStatus.approved,
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
                ],
                const CatchScrollTerminalPadding(),
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
          errorContext: AppErrorContext.customer,
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
        CatchButton(
          label: context.l10n.hostApplicationCall,
          icon: Icon(CatchIcons.phoneOutlined, size: CatchIcon.sm),
          size: CatchButtonSize.sm,
          variant: CatchButtonVariant.secondary,
          onPressed: () => onOpen(Uri(scheme: 'tel', path: phone)),
        ),
      if (outreach.email case final email?)
        CatchButton(
          label: context.l10n.hostApplicationEmail,
          icon: Icon(CatchIcons.emailOutlined, size: CatchIcon.sm),
          size: CatchButtonSize.sm,
          variant: CatchButtonVariant.secondary,
          onPressed: () => onOpen(Uri(scheme: 'mailto', path: email)),
        ),
      if (outreach.instagramUrl case final url?)
        CatchButton(
          label: context.l10n.hostApplicationInstagram,
          icon: Icon(CatchIcons.openInNewRounded, size: CatchIcon.sm),
          size: CatchButtonSize.sm,
          variant: CatchButtonVariant.secondary,
          onPressed: () => onOpen(Uri.parse(url)),
        ),
      if (outreach.linkedinUrl case final url?)
        CatchButton(
          label: context.l10n.hostApplicationLinkedin,
          icon: Icon(CatchIcons.openInNewRounded, size: CatchIcon.sm),
          size: CatchButtonSize.sm,
          variant: CatchButtonVariant.secondary,
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
