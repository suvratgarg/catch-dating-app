import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Direct text entry states',
  type: ProfileDirectTextEntryField,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileDirectTextEntryFieldStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfileDirectTextEntryField',
    contractId: 'screen.profile.inline.direct_text_entry',
    children: [
      WidgetbookProfileStateCard(
        label: 'editable and legal identity rows',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileMediumPreviewHeight,
          child: Column(
            children: [
              ProfileDirectTextEntryField(
                icon: CatchIcons.personOutlined,
                label: 'Display name',
                contract:
                    CatchContractConstraints.updateUserProfilePatchDisplayName,
                currentValue: 'Neha',
                currentFieldValue: 'Neha',
                fieldName: 'displayName',
                patchForValue: (value) =>
                    UpdateUserProfilePatch(displayName: value as String),
              ),
              CatchField.read(
                copy: catchFieldCopy(context.l10n),
                icon: CatchIcons.cakeOutlined,
                title: 'Date of birth',
                body: '16/07/1994 (31 years)',
              ),
              CatchField.read(
                copy: catchFieldCopy(context.l10n),
                icon: CatchIcons.groupOutlined,
                title: 'Gender',
                body: 'Woman',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline prompt editor states',
  type: ProfileInlinePromptEntryEditor,
  path: '[P1 product surfaces]/Profiles/Inline Editors',
)
Widget profileInlinePromptEntryEditorStates(BuildContext context) {
  final prompt = widgetbookProfileViewer.profilePrompts.first;
  Widget promptEditor({required bool expanded}) {
    return ProfileInlinePromptEntryEditor(
      icon: CatchIcons.formatQuoteRounded,
      label: profilePromptDefinition(prompt.promptId).title,
      currentAnswer: prompt.answer,
      currentPromptId: prompt.promptId,
      currentPrompts: widgetbookProfileViewer.profilePrompts,
      promptIndex: 0,
      availablePromptIds: profilePromptCatalog
          .map((definition) => definition.id)
          .take(5)
          .toList(growable: false),
      fieldName: 'profilePrompt:0',
      isExpanded: expanded,
      onTap: () {},
      onSaved: () {},
      onCancel: () {},
    );
  }

  return WidgetbookProfileProfileCatalog(
    title: 'ProfileInlinePromptEntryEditor',
    contractId: 'screen.profile.inline.prompt_entry',
    children: [
      WidgetbookProfileStateCard(
        label: 'collapsed question + separate answer',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileInlinePreviewHeight,
          child: promptEditor(expanded: false),
        ),
      ),
      WidgetbookProfileStateCard(
        label: 'expanded inline question choices + separate answer',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileExpandedEditorHeight,
          child: promptEditor(expanded: true),
        ),
      ),
    ],
  );
}
