import 'dart:convert';
import 'dart:math';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_profile/domain/form_profile.dart';
import 'package:catch_dating_app/user_profile/domain/form_profile_draft.dart';
import 'package:catch_dating_app/user_profile/presentation/form_profile_photo_field.dart';
import 'package:catch_dating_app/user_profile/presentation/form_profiles_controller.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormProfileReviewScreen extends ConsumerWidget {
  const FormProfileReviewScreen({super.key, required this.responseId});
  final String responseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(FormProfileClaimController.saveMutation);
    final uid = ref.watch(uidProvider).asData?.value;
    listenToCatchMutationErrors(
      context,
      ref,
      mutations: [FormProfileClaimController.saveMutation],
      errorContext: AppErrorContext.profile,
    );
    return PopScope(
      canPop: !mutation.isPending,
      child: AbsorbPointer(
        absorbing: mutation.isPending,
        child: CatchRouteScaffold(
          topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
            title: context.l10n.formProfileReviewTitle,
            navigation: const CatchTopBarNavigation(
              mode: CatchTopBarNavigationMode.back,
            ),
            emphasis: scrolledUnder
                ? CatchTopBarEmphasis.divided
                : CatchTopBarEmphasis.plain,
          ),
          body: CatchRouteBody.standardConstrained(
            child: CatchAsyncBoundary<FormProfileReview>(
              value: ref.watch(formProfileReviewProvider(responseId)),
              retainDataOn: const {},
              errorContext: AppErrorContext.profile,
              onRetry: () =>
                  ref.invalidate(formProfileReviewProvider(responseId)),
              builder: (context, review) => FormProfileReviewBody(
                key: ValueKey(
                  '$uid:${review.responseId}:${review.profileRevision}:${review.intakeRevision}',
                ),
                review: review,
                busy: mutation.isPending,
                onReload: () =>
                    ref.invalidate(formProfileReviewProvider(responseId)),
                onSave: (request) {
                  if (uid == null) return;
                  FormProfileClaimController.saveMutation.run(ref, (tx) async {
                    await tx
                        .get(formProfileClaimControllerProvider.notifier)
                        .save(uid, request);
                    if (context.mounted &&
                        ref.read(uidProvider).asData?.value == uid) {
                      showCatchSnackBar(context, context.l10n.formProfileSaved);
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormProfileReviewBody extends StatefulWidget {
  const FormProfileReviewBody({
    super.key,
    required this.review,
    required this.onSave,
    required this.onReload,
    this.busy = false,
  });
  final FormProfileReview review;
  final ValueChanged<ClaimParticipantFormProfileCallableRequest> onSave;
  final VoidCallback onReload;
  final bool busy;
  @override
  State<FormProfileReviewBody> createState() => _FormProfileReviewBodyState();
}

class _FormProfileReviewBodyState extends State<FormProfileReviewBody> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  late final FormProfileDraft _draft;
  String? _requestId;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _draft = FormProfileDraft(widget.review);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changed(VoidCallback change) => setState(() {
    change();
    _requestId = null;
    _draft.confirmed = false;
  });

  void _select(FormProfileField field, bool keep) => _changed(() {
    _draft.select(field, keep);
    final key = field.definition?.privateProfilePath ?? field.canonicalFieldId;
    if (_controllers[key] case final controller?) {
      controller.text =
          '${key == 'linkedinUrl' ? _draft.linkedinUrl ?? '' : _draft.profile[key] ?? ''}';
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final core = widget.review.fields.where(
      (f) => f.destination == FormProfileDestination.catchProfile,
    );
    final card = widget.review.fields.where(
      (f) => f.destination == FormProfileDestination.organizerCard,
    );
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.review.organizerName ?? l10n.formProfilesOrganizerFallback,
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH8,
          Text(widget.review.formTitle, style: CatchTextStyles.bodyM(context)),
          gapH16,
          Text(
            l10n.formProfileReviewDescription,
            style: CatchTextStyles.supporting(context),
          ),
          if (core.isNotEmpty) ...[
            gapH24,
            CatchSection.fieldRows(
              title: l10n.formProfileCoreTitle,
              children: [
                for (final field in core) ...[
                  if (field.isProfilePhoto && _draft.canUse(field))
                    FormProfilePhotoField(
                      responseId: widget.review.responseId,
                      field: field,
                      selected: _draft.selected.contains(field.questionId),
                      busy: widget.busy,
                      onChanged: (value) => _select(field, value),
                    )
                  else if (_draft.canUse(field)) ...[
                    CatchField.toggle(
                      copy: catchFieldCopy(l10n),
                      key: ValueKey('use-${field.questionId}'),
                      title: field.label,
                      body: _answer(field),
                      helperText: l10n.formProfileUseAnswer,
                      titleMaxLines: 3,
                      bodyMaxLines: 12,
                      contractExemption:
                          'Explicit selection is validated against the owned immutable form proposal.',
                      value: _draft.selected.contains(field.questionId),
                      onChanged: widget.busy
                          ? null
                          : (value) => _select(field, value),
                    ),
                    if (_draft.selected.contains(field.questionId) &&
                        !FormProfileDraft.requiredKeys.contains(
                          field.definition?.privateProfilePath,
                        ))
                      _editor(
                        field.definition?.privateProfilePath ??
                            field.canonicalFieldId!,
                        field.label,
                      ),
                  ] else
                    Text(
                      field.isVerifiedPhone
                          ? l10n.formProfilePhoneAuthority
                          : l10n.formProfileUnsupported,
                      style: CatchTextStyles.supporting(context),
                    ),
                ],
              ],
            ),
          ],
          gapH24,
          CatchSection.fieldRows(
            title: l10n.formProfileBasicsTitle,
            children: [
              Text(
                l10n.formProfileBasicsDescription,
                style: CatchTextStyles.supporting(context),
              ),
              _editor('displayName', l10n.formProfileDisplayName),
              _editor('dateOfBirth', l10n.formProfileBirthDate),
              _editor('gender', l10n.formProfileGender),
            ],
          ),
          if (card.isNotEmpty) ...[
            gapH24,
            CatchSection.fieldRows(
              title: l10n.formProfileCardTitle,
              children: [
                Text(
                  l10n.formProfileCardDescription,
                  style: CatchTextStyles.supporting(context),
                ),
                for (final field in card) ...[
                  CatchField.toggle(
                    copy: catchFieldCopy(l10n),
                    key: ValueKey('keep-${field.questionId}'),
                    title: field.label,
                    body: _answer(field),
                    helperText: l10n.formProfileKeepAnswer,
                    titleMaxLines: 3,
                    bodyMaxLines: 16,
                    contractExemption:
                        'Card selection is constrained by the source proposal on the server.',
                    value: _draft.selected.contains(field.questionId),
                    onChanged: widget.busy
                        ? null
                        : (value) => _select(field, value),
                  ),
                ],
              ],
            ),
          ],
          gapH24,
          Text(
            l10n.formProfileConfirmationBody,
            style: CatchTextStyles.supporting(context),
          ),
          gapH12,
          CatchField.toggle(
            copy: catchFieldCopy(l10n),
            key: const ValueKey('confirm-form-profile'),
            title: l10n.formProfileConfirmation,
            titleMaxLines: 3,
            bodyMaxLines: 12,
            contractExemption:
                'Review acknowledgement gates an explicit participant claim; not messaging consent.',
            value: _draft.confirmed,
            onChanged: widget.busy
                ? null
                : (value) => setState(() => _draft.confirmed = value),
          ),
          if (_showErrors) ...[
            gapH12,
            Text(
              l10n.formProfileInvalid,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).danger,
              ),
            ),
          ],
          gapH24,
          CatchButton(
            label: l10n.formProfileSave,
            fullWidth: true,
            status: widget.busy
                ? CatchButtonStatus.loading
                : CatchButtonStatus.idle,
            onPressed: !_draft.confirmed || widget.busy
                ? null
                : () {
                    final valid = _form.currentState!.validate();
                    setState(() => _showErrors = !valid);
                    if (!valid) return;
                    // Retain the key on retry. Any edit starts a new payload-bound request.
                    _requestId ??= base64Url.encode(
                      List.generate(24, (_) => Random.secure().nextInt(256)),
                    );
                    widget.onSave(_draft.request(_requestId!));
                  },
          ),
          gapH12,
          CatchButton(
            label: l10n.formProfileReload,
            variant: CatchButtonVariant.ghost,
            onPressed: widget.busy ? null : widget.onReload,
          ),
        ],
      ),
    );
  }

  String _answer(FormProfileField field) => field.answerText(
    yes: context.l10n.formProfileYes,
    no: context.l10n.formProfileNo,
    empty: context.l10n.formProfileEmptyAnswer,
    attachment: context.l10n.formProfileAttachment,
  );

  bool _selectedKey(String key) => widget.review.fields.any(
    (field) =>
        _draft.selected.contains(field.questionId) &&
        (field.definition?.privateProfilePath ?? field.canonicalFieldId) == key,
  );

  Widget _editor(String key, String label) {
    final l10n = context.l10n;
    final contract =
        CatchContractConstraints.all[key == 'linkedinUrl'
            ? 'claimParticipantFormProfileCallablePayload.reviewedLinkedinUrl'
            : 'claimParticipantFormProfileCallablePayload.profile.$key'];
    final values = FormProfileDraft.choices(key);
    final value = _draft.profile[key];
    if (key == 'languages' || key == 'interestedInGenders') {
      return CatchField<String>.choices(
        copy: catchFieldCopy(l10n),
        key: ValueKey('edit-$key'),
        title: label,
        contract: contract,
        contractValueBuilder: (v) => v,
        values: values.keys.toList(),
        itemLabelBuilder: (v) => values[v]!,
        selected: value is List ? value.cast<String>().toSet() : <String>{},
        mode: CatchChipMode.multiple,
        allowEmptySelection: true,
        onSelectionChanged: (values) =>
            _changed(() => _draft.edit(key, values.toList())),
      );
    }
    if (values.isNotEmpty) {
      return CatchField<String>.select(
        copy: catchFieldCopy(l10n),
        key: ValueKey('edit-$key'),
        title: label,
        contract: contract,
        contractValueBuilder: (v) => v,
        values: values.keys.toList(),
        itemLabelBuilder: (v) => values[v]!,
        value: values.containsKey(value) ? value as String : null,
        onValidate: (v) =>
            (FormProfileDraft.requiredKeys.contains(key) ||
                    _selectedKey(key)) &&
                v == null
            ? l10n.formProfileRequired
            : null,
        onChanged: (v) => _changed(() => _draft.edit(key, v)),
      );
    }
    if (key == 'city') {
      final cities = {
        for (final city in defaultCityOptions)
          city.effectiveMarketId: city.label,
      };
      return CatchField<String>.select(
        copy: catchFieldCopy(l10n),
        key: ValueKey('edit-$key'),
        title: label,
        contract: contract,
        contractValueBuilder: (v) => v,
        values: cities.keys.toList(),
        itemLabelBuilder: (v) => cities[v]!,
        value: cities.containsKey(value) ? value as String : null,
        onChanged: (v) => _changed(() => _draft.edit(key, v)),
      );
    }
    final isBirthDate = key == 'dateOfBirth';
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(
        text:
            '${key == 'linkedinUrl' ? _draft.linkedinUrl ?? '' : value ?? ''}',
      ),
    );
    return CatchField.input(
      copy: catchFieldCopy(l10n),
      key: ValueKey('edit-$key'),
      title: label,
      contract: contract,
      controller: controller,
      helperText: isBirthDate ? l10n.formProfileDateHint : null,
      keyboardType: switch (key) {
        'height' => TextInputType.number,
        'email' => TextInputType.emailAddress,
        'linkedinUrl' => TextInputType.url,
        'dateOfBirth' => TextInputType.datetime,
        _ => TextInputType.text,
      },
      onValidate: (value) {
        final text = value?.trim() ?? '';
        if ((FormProfileDraft.requiredKeys.contains(key) ||
                _selectedKey(key)) &&
            text.isEmpty) {
          return l10n.formProfileRequired;
        }
        if (isBirthDate) {
          final date = DateTime.tryParse(text);
          final now = DateTime.now();
          if (date == null ||
              date.toIso8601String().split('T').first != text ||
              date.isAfter(DateTime(now.year - 18, now.month, now.day))) {
            return l10n.formProfileDateHint;
          }
        }
        return null;
      },
      onChanged: (value) => _changed(() {
        if (key == 'linkedinUrl') {
          _draft.linkedinUrl = value.trim();
        } else {
          _draft.edit(
            key,
            key == 'height' ? int.tryParse(value) : value.trim(),
          );
        }
      }),
    );
  }
}
