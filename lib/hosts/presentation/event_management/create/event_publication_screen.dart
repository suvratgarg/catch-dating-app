import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/event_publication_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventPublicationScreen extends StatelessWidget {
  const EventPublicationScreen({
    super.key,
    required this.controller,
    required this.onBack,
    this.onEditDetails,
  });
  final EventPublicationController controller;
  final VoidCallback onBack;
  final VoidCallback? onEditDetails;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final l10n = context.l10n;
      final copy = catchFieldCopy(l10n);
      final event = controller.event;
      final published = event?.publicationState == 'published';
      String requirement(String value) => switch (value) {
        'futureActive' => l10n.hostsPublicationNeedsFuture,
        'organizerVisibility' => l10n.hostsPublicationNeedsOrganizer,
        'duration' => l10n.hostsEventDefaultsUsualDuration,
        'venue' => l10n.hostsPrivateEventDetailPickLocation,
        'format' => l10n.hostsPrivateEventDetailFormat,
        'description' => l10n.hostsEventDetailsStepTitleDescription,
        'admissionTerms' => l10n.hostsPrivateEventAdmissionTerms,
        'distancePace' => l10n.hostsPublicationNeedsDistance,
        _ => l10n.hostsPublicationNeedsReview,
      };
      return CatchScaffold.stepFlow(
        body: Column(
          children: [
            CatchStepHeader(
              title: l10n.hostsPrivateEventPublicListing,
              subtitle: event?.name ?? l10n.hostsPrivateEventSavedTitle,
              stepLabelBuilder: catchStepHeaderLabelBuilder(l10n),
              compactStepLabelBuilder: catchStepHeaderCompactLabelBuilder(l10n),
              onBack: onBack,
              leadingType: CatchTopBarNavigationMode.back,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.hostCreateEventFormLaneMaxWidth,
                  ),
                  child: ListView(
                    padding: CatchInsets.formStepBodyWithBottomActions,
                    children: [
                      CatchSectionList(
                        emptyStateOmitted: true,
                        children: [
                          CatchSection.fieldRows(
                            first: true,
                            children: [
                              if (event != null)
                                CatchField.read(
                                  copy: copy,
                                  title: published
                                      ? l10n.hostsEditHostedEventScreenTitlePublishedEvent
                                      : l10n.hostsPrivateEventPrivateTitle,
                                  body: published
                                      ? l10n.hostsPublicationUnpublishExplanation
                                      : l10n.hostsPublicationPublishExplanation,
                                ),
                              if (controller.loading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              if (controller.pending != null)
                                CatchField.read(
                                  copy: copy,
                                  title: l10n.hostsPublicationPending,
                                  body: l10n.hostsPublicationPendingBody,
                                ),
                              if (controller.error != null)
                                CatchField.read(
                                  copy: copy,
                                  title: l10n.hostsEventPreferenceError,
                                  body: appErrorMessage(
                                    controller.error!,
                                    l10n: l10n,
                                    context: AppErrorContext.event,
                                  ),
                                ),
                              if (controller.receipt != null &&
                                  controller.pending == null)
                                CatchField.read(
                                  copy: copy,
                                  title: l10n.hostsPublicationSaved,
                                  body:
                                      l10n.hostsPublicationRegistrationSeparate,
                                ),
                              if (!published && event != null)
                                for (final item
                                    in event.publicationReadiness?.missing ??
                                        const ['contract'])
                                  CatchField.read(
                                    copy: copy,
                                    title: requirement(item),
                                    icon: CatchIcons.errorOutlineRounded,
                                  ),
                              if (!published &&
                                  onEditDetails != null &&
                                  !controller.saving &&
                                  controller.pending == null)
                                CatchField.action(
                                  copy: copy,
                                  title: l10n.hostsPrivateEventDetails,
                                  onTap: onEditDetails,
                                ),
                              if (!controller.loading &&
                                  !controller.saving &&
                                  controller.pending == null)
                                CatchField.action(
                                  copy: copy,
                                  title: l10n.hostsPublicationRefresh,
                                  onTap: () => unawaited(controller.load()),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: CatchInsets.pageBody,
                child: CatchButton(
                  label: controller.pending != null
                      ? l10n.hostsPublicationRetry
                      : published
                      ? l10n.hostsPublicationUnpublish
                      : l10n.hostsPublicationPublish,
                  onPressed:
                      controller.actorAvailable &&
                          !controller.saving &&
                          !controller.loading &&
                          (controller.pending != null ||
                              controller.canPublish ||
                              controller.canUnpublish)
                      ? () => unawaited(
                          controller.pending != null
                              ? controller.retry()
                              : controller.changeTo(
                                  published ? 'private' : 'published',
                                ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
