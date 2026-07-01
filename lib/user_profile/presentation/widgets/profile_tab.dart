import 'dart:async';

import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_edit_tab_state.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_photo_action_controller.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_section.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab_skeleton.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({
    super.key,
    required this.user,
    required this.uploadState,
    this.physics,
  });

  static const scrollViewKey = ValueKey('profile-tab-scroll-view');

  final UserProfile user;
  final PhotoUploadState uploadState;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileTabContent(
      user: user,
      uploadState: uploadState,
      builder: (context, children) => ListView(
        key: scrollViewKey,
        physics: physics,
        padding: profileTabBodyPadding,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTabSliverBody extends ConsumerWidget {
  const ProfileTabSliverBody({
    super.key,
    required this.user,
    required this.uploadState,
  });

  final UserProfile user;
  final PhotoUploadState uploadState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileTabContent(
      user: user,
      uploadState: uploadState,
      builder: (context, children) => SliverPadding(
        padding: profileTabBodyPadding,
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef ProfileTabContentBuilder =
    Widget Function(BuildContext context, List<Widget> children);

class ProfileTabContent extends ConsumerStatefulWidget {
  const ProfileTabContent({
    super.key,
    required this.user,
    required this.uploadState,
    required this.builder,
  });

  final UserProfile user;
  final PhotoUploadState uploadState;
  final ProfileTabContentBuilder builder;

  @override
  ConsumerState<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends ConsumerState<ProfileTabContent> {
  String? _expandedField;

  bool _isExpanded(String fieldName) => _expandedField == fieldName;

  void _toggleField(String fieldName) {
    setState(() {
      _expandedField = _expandedField == fieldName ? null : fieldName;
    });
  }

  void _collapseField() {
    if (_expandedField == null) return;
    setState(() => _expandedField = null);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final uploadState = widget.uploadState;
    final editState = SelfProfileEditTabState.fromProfile(
      user: user,
      uploadState: uploadState,
    );
    const photoActions = SelfProfilePhotoActionController();
    final prompts = [
      for (final slot in editState.promptSlots)
        _ProfilePromptEntry(
          user: user,
          slot: slot,
          isExpanded: _isExpanded(slot.fieldName),
          onTap: () => _toggleField(slot.fieldName),
          onSaved: _collapseField,
          onCancel: _collapseField,
        ),
    ];

    return widget.builder(context, [
      CatchSectionList(
        gap: 0,
        children: [
          ProfilePhotosSection(
            first: true,
            state: editState.photoGrid,
            onSlotTapped: (index) => unawaited(
              photoActions.openEditor(
                context: context,
                ref: ref,
                state: editState.photoGrid,
                index: index,
              ),
            ),
            onDeletePhoto: (index) =>
                unawaited(photoActions.deletePhoto(ref: ref, index: index)),
            onReorderPhoto: (fromIndex, toIndex) => unawaited(
              photoActions.reorderPhoto(
                ref: ref,
                fromIndex: fromIndex,
                toIndex: toIndex,
              ),
            ),
          ),
          profileInfoSection(
            context: context,
            title: 'Prompts',
            subtitle:
                '${editState.completedPromptCount} of $maxProfilePromptAnswers answered',
            children: prompts,
            grouped: true,
            fullBleedRows: true,
          ),
          profileInfoSection(
            context: context,
            title: 'About you',
            children: [
              for (final row in editState.aboutSectionRows)
                ProfileFieldRow(
                  descriptor: row,
                  isExpanded: _isExpanded,
                  onToggle: _toggleField,
                  onSaved: _collapseField,
                  onCancel: _collapseField,
                ),
            ],
            grouped: true,
            fullBleedRows: true,
          ),
          profileInfoSection(
            context: context,
            title: 'Running',
            children: [
              for (final row in editState.runningRows)
                ProfileFieldRow(
                  descriptor: row,
                  isExpanded: _isExpanded,
                  onToggle: _toggleField,
                  onSaved: _collapseField,
                  onCancel: _collapseField,
                ),
            ],
            grouped: true,
            fullBleedRows: true,
          ),
          profileInfoSection(
            context: context,
            title: 'Lifestyle',
            children: [
              for (final row in editState.lifestyleRows)
                ProfileFieldRow(
                  descriptor: row,
                  isExpanded: _isExpanded,
                  onToggle: _toggleField,
                  onSaved: _collapseField,
                  onCancel: _collapseField,
                ),
            ],
            grouped: true,
            fullBleedRows: true,
          ),
        ],
      ),
      gapH32,
    ]);
  }
}

class ProfileFieldRow extends StatelessWidget {
  const ProfileFieldRow({
    super.key,
    required this.descriptor,
    required this.isExpanded,
    required this.onToggle,
    required this.onSaved,
    required this.onCancel,
  });

  final SelfProfileFieldRowDescriptor descriptor;
  final bool Function(String fieldId) isExpanded;
  final ValueChanged<String> onToggle;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return descriptor.map(
      readOnly: (descriptor) => CatchField.nav(
        icon: descriptor.icon,
        title: descriptor.label,
        body: descriptor.body,
        bodyMaxLines: descriptor.bodyMaxLines,
      ),
      text: (descriptor) => _ProfileDirectTextEntry(
        icon: descriptor.icon,
        label: descriptor.label,
        value: descriptor.value,
        currentValue: descriptor.currentValue,
        currentFieldValue: descriptor.currentFieldValue,
        fieldName: descriptor.fieldName,
        patchForValue: descriptor.patchForValue,
        keyboardType: descriptor.keyboardType,
        textCapitalization: descriptor.textCapitalization,
        autofillHints: descriptor.autofillHints,
        validator: descriptor.validator,
        toFieldValue: descriptor.toFieldValue,
      ),
      height: (descriptor) => ProfileInlineHeightEditor(
        key: ValueKey('inline-${descriptor.id}-editor'),
        icon: descriptor.icon,
        label: descriptor.label,
        value: descriptor.value,
        currentValue: descriptor.currentValue,
        isExpanded: isExpanded(descriptor.id),
        isAddAffordance: descriptor.isAddAffordance,
        patchForValue: descriptor.patchForValue,
        onTap: () => onToggle(descriptor.id),
        onSaved: onSaved,
        onCancel: onCancel,
      ),
      singleChoice: <T extends Labelled>(descriptor) =>
          _ProfileSingleEnumEntry<T>(
            icon: descriptor.icon,
            label: descriptor.label,
            values: descriptor.values,
            value: descriptor.value,
            fieldName: descriptor.fieldName,
            patchForValue: descriptor.patchForValue,
            placeholder: descriptor.placeholder,
            isExpanded: isExpanded(descriptor.fieldName),
            onTap: () => onToggle(descriptor.fieldName),
            onSaved: onSaved,
            onCancel: onCancel,
          ),
      multiChoice: <T extends Labelled>(descriptor) =>
          _ProfileMultiEnumEntry<T>(
            icon: descriptor.icon,
            label: descriptor.label,
            values: descriptor.values,
            selected: descriptor.selected,
            fieldName: descriptor.fieldName,
            placeholder: descriptor.placeholder,
            patchForValues: descriptor.patchForValues,
            patchForLatestProfile: descriptor.patchForLatestProfile,
            isExpanded: isExpanded(descriptor.fieldName),
            onTap: () => onToggle(descriptor.fieldName),
            onSaved: onSaved,
            onCancel: onCancel,
            isAddAffordanceWhenEmpty: descriptor.isAddAffordanceWhenEmpty,
          ),
      range: (descriptor) => ProfileInlineRangeEditor(
        key: ValueKey('inline-${descriptor.id}-editor'),
        icon: descriptor.icon,
        title: descriptor.label,
        value: descriptor.value,
        currentMin: descriptor.currentMin,
        currentMax: descriptor.currentMax,
        isExpanded: isExpanded(descriptor.id),
        onTap: () => onToggle(descriptor.id),
        sliderMin: descriptor.sliderMin,
        sliderMax: descriptor.sliderMax,
        divisions: descriptor.divisions,
        labelText: descriptor.labelText,
        patchForRange: descriptor.patchForRange,
        patchForLatestProfile: descriptor.patchForLatestProfile,
        saveEndValue: descriptor.saveEndValue,
        savedCurrentMax: descriptor.savedCurrentMax,
        onSaved: onSaved,
        onCancel: onCancel,
      ),
    );
  }
}

class _ProfileDirectTextEntry extends StatelessWidget {
  const _ProfileDirectTextEntry({
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldName,
    this.currentValue,
    this.currentFieldValue,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
    required this.patchForValue,
  });

  final IconData icon;
  final String label;
  final String value;
  final String fieldName;
  final String? currentValue;
  final Object? currentFieldValue;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final UpdateUserProfilePatch Function(Object? value) patchForValue;

  @override
  Widget build(BuildContext context) {
    return ProfileDirectTextEntryField(
      icon: icon,
      label: label,
      value: value,
      currentValue: currentValue ?? value,
      currentFieldValue: currentFieldValue ?? currentValue ?? value,
      fieldName: fieldName,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      validator: validator,
      toFieldValue: toFieldValue,
      patchForValue: patchForValue,
    );
  }
}

class _ProfileSingleEnumEntry<T extends Labelled> extends StatelessWidget {
  const _ProfileSingleEnumEntry({
    required this.icon,
    required this.label,
    required this.values,
    required this.fieldName,
    required this.patchForValue,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.value,
    this.placeholder,
  });

  final IconData icon;
  final String label;
  final List<T> values;
  final T? value;
  final String fieldName;
  final UpdateUserProfilePatch Function(T? value) patchForValue;
  final String? placeholder;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.label ?? placeholder ?? label;
    return ProfileInlineSingleChoiceEntryEditor<T>(
      key: ValueKey('inline-$fieldName-entry-editor'),
      icon: icon,
      label: label,
      value: displayValue,
      values: values,
      currentValue: value,
      fieldName: fieldName,
      patchForValue: patchForValue,
      isExpanded: isExpanded,
      isAddAffordance: value == null,
      onTap: onTap,
      onSaved: onSaved,
      onCancel: onCancel,
    );
  }
}

class _ProfileMultiEnumEntry<T extends Labelled> extends StatelessWidget {
  const _ProfileMultiEnumEntry({
    required this.icon,
    required this.label,
    required this.values,
    required this.selected,
    required this.fieldName,
    required this.placeholder,
    required this.patchForValues,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.patchForLatestProfile,
    this.isAddAffordanceWhenEmpty = true,
  });

  final IconData icon;
  final String label;
  final List<T> values;
  final List<T> selected;
  final String fieldName;
  final String placeholder;
  final UpdateUserProfilePatch Function(List<T> values) patchForValues;
  final UpdateUserProfilePatch Function(UserProfile user, List<T> values)?
  patchForLatestProfile;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final bool isAddAffordanceWhenEmpty;

  @override
  Widget build(BuildContext context) {
    final isEmpty = selected.isEmpty;
    final displayValue = isEmpty
        ? placeholder
        : selected.map((v) => v.label).join(', ');
    return ProfileInlineMultiChoiceEntryEditor<T>(
      key: ValueKey('inline-$fieldName-entry-editor'),
      icon: icon,
      label: label,
      value: displayValue,
      values: values,
      currentValues: selected,
      fieldName: fieldName,
      patchForValues: patchForValues,
      patchForLatestProfile: patchForLatestProfile,
      isExpanded: isExpanded,
      isAddAffordance: isEmpty && isAddAffordanceWhenEmpty,
      onTap: onTap,
      onSaved: onSaved,
      onCancel: onCancel,
    );
  }
}

class _ProfilePromptEntry extends StatelessWidget {
  const _ProfilePromptEntry({
    required this.user,
    required this.slot,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
  });

  final UserProfile user;
  final SelfProfilePromptSlotState slot;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final text = slot.displayText;
    return ProfileInlinePromptEntryEditor(
      key: ValueKey('inline-${slot.fieldName}-entry-editor'),
      icon: CatchIcons.formatQuoteRounded,
      label: slot.definition.title,
      value: text.isNotEmpty ? text : slot.definition.placeholder,
      currentAnswer: text,
      currentPromptId: slot.currentPromptId,
      currentPrompts: user.profilePrompts,
      promptIndex: slot.index,
      availablePromptIds: slot.availablePromptIds,
      fieldName: slot.fieldName,
      isExpanded: isExpanded,
      isAddAffordance: slot.isAddAffordance,
      onTap: onTap,
      onSaved: onSaved,
      onCancel: onCancel,
    );
  }
}

class ProfilePhotosSection extends StatelessWidget {
  const ProfilePhotosSection({
    super.key,
    required this.first,
    required this.state,
    required this.onSlotTapped,
    required this.onDeletePhoto,
    required this.onReorderPhoto,
  });

  final bool first;
  final SelfProfilePhotoGridState state;
  final void Function(int index) onSlotTapped;
  final void Function(int index) onDeletePhoto;
  final void Function(int fromIndex, int toIndex) onReorderPhoto;

  @override
  Widget build(BuildContext context) {
    final completedCount = state.profilePhotos.length;

    return CatchSection.divided(
      title: 'Photos',
      count: '$completedCount of $maximumProfilePhotoCount added',
      first: first,
      child: PhotoGrid(
        profilePhotos: state.profilePhotos,
        loadingIndices: state.loadingIndices,
        onSlotTapped: onSlotTapped,
        canDeletePhotos: state.canDeletePhotos,
        onDeletePhoto: state.canDeletePhotos ? onDeletePhoto : null,
        onReorderPhoto: onReorderPhoto,
      ),
    );
  }
}
