import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HostFormDefinition', () {
    test(
      'parses a versioned definition and preserves unknown contract fields',
      () {
        final definition = HostFormDefinition.fromMap(_definitionMap());

        expect(definition.title, 'Community application');
        expect(definition.purpose, HostFormPurpose.application);
        expect(
          definition.sections.single.questions.single.kind,
          HostFormQuestionKind.shortText,
        );

        final updated = definition.copyWith(title: 'Member application');
        expect(updated.title, 'Member application');
        expect(updated.toJson()['schemaVersion'], 1);
        expect(updated.toJson()['customFutureField'], 'preserved');
      },
    );

    test('section and question mutations are ordered and non-destructive', () {
      final definition = HostFormDefinition.fromMap(_definitionMap());
      final withSection = definition.addSection(
        HostFormSection.create(sectionId: 'section_2', title: 'Availability'),
      );
      final withQuestion = withSection.replaceSection(
        1,
        withSection.sections[1].addQuestion(
          HostFormQuestion.create(
            questionId: 'question_2',
            kind: HostFormQuestionKind.singleChoice,
          ),
        ),
      );

      expect(withQuestion.sections, hasLength(2));
      expect(withQuestion.sections[1].questions.single.options, hasLength(2));

      final moved = withQuestion.moveSection(1, 0);
      expect(moved.sections.first.sectionId, 'section_2');
      expect(definition.sections.single.sectionId, 'section_1');
    });
  });

  group('HostFormSummary', () {
    test('derives valid lifecycle actions from server state', () {
      final published = HostFormSummary.fromMap(
        _summaryMap(status: 'published', publishedVersion: 1),
      );
      final draft = HostFormSummary.fromMap(
        _summaryMap(status: 'draft', publishedVersion: 0),
      );

      expect(published.canPause, isTrue);
      expect(published.canResume, isFalse);
      expect(published.canDeleteDraft, isFalse);
      expect(draft.canDeleteDraft, isTrue);
    });
  });

  test(
    'HostFormListRequest equality includes filter sets independent of order',
    () {
      const first = HostFormListRequest(
        organizerId: 'org_1',
        statuses: {
          HostFormLifecycleStatus.draft,
          HostFormLifecycleStatus.published,
        },
      );
      const second = HostFormListRequest(
        organizerId: 'org_1',
        statuses: {
          HostFormLifecycleStatus.published,
          HostFormLifecycleStatus.draft,
        },
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    },
  );
}

Map<String, Object?> _definitionMap() => {
  'schemaVersion': 1,
  'title': 'Community application',
  'description': 'Tell us about yourself.',
  'purpose': 'application',
  'identityPolicy': 'emailOrPhoneVerified',
  'sections': [
    {
      'sectionId': 'section_1',
      'title': 'About you',
      'description': null,
      'pageBreak': false,
      'questions': [
        {
          'questionId': 'question_1',
          'key': 'full_name',
          'label': 'Full name',
          'helpText': null,
          'kind': 'shortText',
          'required': true,
          'options': <Object?>[],
          'canonicalFieldId': 'fullName',
          'privacyClass': 'contact',
          'prefillPolicy': 'verifiedOnly',
          'hostPresentation': 'directory',
          'validation': <String, Object?>{},
        },
      ],
    },
  ],
  'completion': {'title': 'Thanks', 'message': 'We will be in touch.'},
  'customFutureField': 'preserved',
};

Map<String, Object?> _summaryMap({
  required String status,
  required int publishedVersion,
}) => {
  'organizerId': 'org_1',
  'formId': 'form_1',
  'title': 'Community application',
  'description': null,
  'purpose': 'application',
  'status': status,
  'templateId': 'community_application',
  'publicFormId': 'public_1',
  'defaultTargetKind': 'organizer',
  'defaultTargetId': null,
  'activeVersionId': publishedVersion == 0 ? null : 'version_1',
  'draftRevision': 2,
  'publishedVersion': publishedVersion,
  'submittedResponseCount': 0,
  'updatedAtMillis': 1,
  'publishedAtMillis': publishedVersion == 0 ? null : 1,
  'lastResponseAtMillis': null,
};
