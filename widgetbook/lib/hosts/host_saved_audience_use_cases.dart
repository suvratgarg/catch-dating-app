import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_saved_audience_members_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

final _audience = HostSavedAudience(
  organizerId: 'preview-organizer',
  audienceId: 'preview-audience',
  name: 'Sunday regulars',
  status: 'active',
  definition: const HostSavedAudienceDefinition(
    join: HostSavedAudienceJoin.all,
    predicates: [HostSavedAudienceAttendedEvent('sunday-social')],
  ),
  definitionHash: 'preview-definition',
  definitionVersion: 2,
  revision: 1,
  lastPreviewMatchCount: 1,
  lastPreviewReachSummary: _reach,
  lastPreviewAt: DateTime(2026, 9, 3, 12),
  createdAt: DateTime(2026, 9, 3),
  updatedAt: DateTime(2026, 9, 3),
);
const _reach = HostAudienceReachSummary(
  inCatch: 0,
  automatic: 0,
  byHand: 1,
  unavailable: 0,
);
const _options = HostSavedAudienceFilterOptions(
  forms: [
    HostAudienceSourceOption(id: 'application', title: 'Club application'),
  ],
  questions: [
    HostAudienceQuestionOption(
      formId: 'application',
      versionId: 'application-v1',
      version: 1,
      formTitle: 'Club application',
      questionId: 'drink',
      label: 'Favorite drink',
      options: [HostAudienceAnswerOption(label: 'Coffee', value: 'coffee')],
    ),
  ],
  events: [
    HostAudienceSourceOption(id: 'sunday-social', title: 'Sunday social'),
  ],
  tags: [],
);

@widgetbook.UseCase(
  name: 'Overview and explicit editing',
  type: HostSavedAudienceWorkspace,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostSavedAudienceOverviewState(BuildContext context) => ProviderScope(
  overrides: [
    hostSavedAudienceFilterOptionsProvider(
      _audience.organizerId,
    ).overrideWith((_) async => _options),
    hostSavedAudienceMembersControllerProvider(
      _audience,
    ).overrideWith(_PreviewAudienceMembers.new),
  ],
  child: SizedBox(
    width: 420,
    height: 820,
    child: HostSavedAudienceWorkspace(audience: _audience),
  ),
);

class _PreviewAudienceMembers extends HostSavedAudienceMembersController {
  @override
  Future<HostSavedAudienceMembersState> build(
    HostSavedAudience audience,
  ) async {
    const members = [
      HostSavedAudiencePreviewContact(
        contactId: 'preview-ada',
        displayName: 'Ada',
      ),
    ];
    return HostSavedAudienceMembersState(
      members: members,
      preview: HostSavedAudiencePreview(
        audience: audience,
        matchCount: 1,
        reachSummary: _reach,
        sample: members,
        evaluatedAt: DateTime(2026, 9, 3, 12),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Published source filters',
  type: HostAudienceSourceRuleFields,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostAudienceSourceRuleStates(BuildContext context) => SizedBox(
  width: 420,
  child: SingleChildScrollView(
    child: Column(
      children: [
        for (final kind in HostAudienceSourceRuleKind.values)
          HostAudienceSourceRuleFields(
            kind: kind,
            options: _options,
            enabled: true,
            predicate: switch (kind) {
              HostAudienceSourceRuleKind.attendedEvent =>
                const HostSavedAudienceAttendedEvent('sunday-social'),
              HostAudienceSourceRuleKind.applicationStatus =>
                const HostSavedAudienceApplicationStatusRule(
                  formId: 'application',
                  reviewStatus: HostSavedAudienceApplicationStatus.approved,
                ),
              HostAudienceSourceRuleKind.formAnswer =>
                const HostSavedAudienceFormAnswer(
                  formId: 'application',
                  versionId: 'application-v1',
                  questionId: 'drink',
                  value: 'coffee',
                ),
            },
            onChanged: (_) {},
          ),
      ],
    ),
  ),
);

@widgetbook.UseCase(
  name: 'Members, rules and evaluated reach',
  type: HostSavedAudienceOverview,
  path: '[P1 product surfaces]/Host operations/Customers',
)
Widget hostSavedAudienceOverviewOnlyState(BuildContext context) =>
    hostSavedAudienceOverviewState(context);
