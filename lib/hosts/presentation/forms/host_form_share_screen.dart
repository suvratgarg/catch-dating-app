import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/clipboard.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HostFormShareScreen extends ConsumerStatefulWidget {
  const HostFormShareScreen({
    super.key,
    required this.organizerId,
    required this.formId,
  });
  final String organizerId;
  final String formId;
  @override
  ConsumerState<HostFormShareScreen> createState() =>
      _HostFormShareScreenState();
}

class _HostFormShareScreenState extends ConsumerState<HostFormShareScreen> {
  HostFormShareLink? _trackedLink;
  bool _creatingLink = false;

  @override
  Widget build(BuildContext context) {
    final provider = hostFormShareAssetsControllerProvider(
      organizerId: widget.organizerId,
      formId: widget.formId,
    );
    final editorProvider = hostFormEditorControllerProvider(
      widget.organizerId,
      widget.formId,
    );
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostFormShare,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: CatchRouteBody.standardConstrained(
        child: CatchAsyncValueView<HostFormShareAssets>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 5),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.forms,
            onRetry: () => ref.invalidate(provider),
          ),
          builder: (context, assets) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchAsyncValueView<HostFormEditorState>(
                value: ref.watch(editorProvider),
                onRetry: () => ref.read(editorProvider.notifier).reload(),
                loadingBuilder: (_) => const CatchSkeletonRows(count: 1),
                errorBuilder: (_, error, _) => CatchErrorState.fromError(
                  error,
                  context: AppErrorContext.forms,
                  mode: CatchErrorStateMode.compact,
                  onRetry: () => ref.read(editorProvider.notifier).reload(),
                ),
                builder: (context, editor) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      editor.editor.definition.title,
                      style: CatchTextStyles.headline(context),
                    ),
                    gapH8,
                    CatchBadge.status(
                      label: hostFormStatusLabel(
                        context,
                        editor.editor.form.status,
                      ),
                      tone:
                          editor.editor.form.status ==
                              HostFormLifecycleStatus.published
                          ? CatchBadgeTone.success
                          : CatchBadgeTone.neutral,
                    ),
                  ],
                ),
              ),
              gapH32,
              CatchSection.divided(
                title: context.l10n.hostFormCanonicalLink,
                first: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SelectableText(
                      assets.canonicalUrl,
                      style: CatchTextStyles.recordBody(context),
                    ),
                    gapH16,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (originContext) => CatchButton(
                              label: context.l10n.hostFormShareLink,
                              shape: CatchButtonShape.rounded,
                              fullWidth: true,
                              onPressed: () =>
                                  _share(originContext, assets.canonicalUrl),
                            ),
                          ),
                        ),
                        gapW12,
                        Expanded(
                          child: CatchButton(
                            label: context.l10n.hostFormCopyLink,
                            shape: CatchButtonShape.rounded,
                            fullWidth: true,
                            variant: CatchButtonVariant.secondary,
                            onPressed: () => _copy(
                              assets.canonicalUrl,
                              context.l10n.hostFormLinkCopied,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              gapH32,
              CatchSection.fieldRows(
                children: [
                  CatchField.nav(
                    title: context.l10n.hostAudienceShowQr,
                    icon: CatchIcons.qrCode2Outlined,
                    emphasis: CatchFieldEmphasis.title,
                    onTap: () => _showQr(assets),
                  ),
                  CatchField.nav(
                    title: _creatingLink
                        ? context.l10n.hostAudienceCreatingLink
                        : context.l10n.hostFormCreateTrackedLink,
                    icon: CatchIcons.linkOutlined,
                    emphasis: CatchFieldEmphasis.title,
                    onTap: _creatingLink ? null : _createTrackedLink,
                  ),
                  CatchField.nav(
                    title: context.l10n.hostFormEmbed,
                    icon: CatchIcons.languageOutlined,
                    emphasis: CatchFieldEmphasis.title,
                    onTap: () => _showEmbed(assets),
                  ),
                ],
              ),
              if (_trackedLink case final link?) ...[
                gapH24,
                CatchSection.divided(
                  title: link.label,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        link.url,
                        style: CatchTextStyles.recordBody(context),
                      ),
                      gapH8,
                      Wrap(
                        spacing: CatchSpacing.s4,
                        runSpacing: CatchSpacing.s2,
                        children: [
                          CatchButton.command(
                            label: context.l10n.hostFormCopyLink,
                            onPressed: () => _copy(
                              link.url,
                              context.l10n.hostFormLinkCopied,
                            ),
                          ),
                          Builder(
                            builder: (originContext) => CatchButton.command(
                              label: context.l10n.hostFormShareLink,
                              onPressed: () => _share(originContext, link.url),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              gapH24,
              Text(
                context.l10n.hostFormCanonicalLinkHelp,
                style: CatchTextStyles.supporting(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQr(HostFormShareAssets assets) =>
      showCatchBottomSheet<void>(
        context: context,
        builder: (context) => CatchBottomSheetScaffold(
          title: context.l10n.hostAudienceShowQr,
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Semantics(
                  label: assets.canonicalUrl,
                  image: true,
                  child: CatchSurface(
                    backgroundColor: CatchTokens.editorialWhite,
                    borderWidth: 0,
                    padding: CatchInsets.iconChipContent,
                    radius: CatchRadius.sm,
                    child: QrImageView(
                      data: assets.canonicalUrl,
                      size: CatchLayout.eventSuccessVenueQrExtent,
                      padding: EdgeInsets.zero,
                      backgroundColor: CatchTokens.editorialWhite,
                    ),
                  ),
                ),
              ),
              gapH16,
              SelectableText(
                assets.canonicalUrl,
                style: CatchTextStyles.recordBody(context),
              ),
            ],
          ),
        ),
      );

  Future<void> _showEmbed(HostFormShareAssets assets) =>
      showCatchBottomSheet<void>(
        context: context,
        builder: (context) => CatchBottomSheetScaffold(
          title: context.l10n.hostFormEmbed,
          subtitle: context.l10n.hostFormEmbedHelp,
          scrollable: true,
          action: CatchButton(
            label: context.l10n.hostFormCopyEmbed,
            fullWidth: true,
            onPressed: () =>
                _copy(assets.embedSnippet, context.l10n.hostFormEmbedCopied),
          ),
          child: SelectableText(
            assets.embedSnippet,
            style: CatchTextStyles.recordBody(context),
          ),
        ),
      );

  Future<void> _copy(String value, String confirmation) async {
    try {
      await ref.read(clipboardControllerProvider).copyText(value);
      if (!mounted) return;
      showCatchSnackBar(context, confirmation);
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }

  Future<void> _share(BuildContext originContext, String url) async {
    try {
      await ref
          .read(externalShareControllerProvider)
          .shareText(
            text: url,
            subject: context.l10n.hostFormShare,
            origin: _shareOrigin(originContext),
          );
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }

  Future<void> _createTrackedLink() async {
    final input = await _showTrackedLinkDialog(context);
    if (input == null || !mounted) return;
    setState(() => _creatingLink = true);
    try {
      final link = await ref
          .read(hostFormsControllerProvider)
          .createShareLink(
            organizerId: widget.organizerId,
            formId: widget.formId,
            label: input.label,
            source: input.source,
            requestId: 'share_${DateTime.now().microsecondsSinceEpoch}',
          );
      if (!mounted) return;
      setState(() {
        _trackedLink = link;
        _creatingLink = false;
      });
      showCatchSnackBar(context, context.l10n.hostFormTrackedLinkReady);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _creatingLink = false);
      showCatchErrorSnackBar(context, error);
    }
  }
}

class _TrackedLinkInput {
  const _TrackedLinkInput({required this.label, required this.source});

  final String label;
  final String? source;
}

Future<_TrackedLinkInput?> _showTrackedLinkDialog(BuildContext context) async {
  final label = TextEditingController();
  final source = TextEditingController();
  final result = await showDialog<_TrackedLinkInput>(
    context: context,
    builder: (dialogContext) => CatchFormDialog(
      title: context.l10n.hostFormTrackedLinkTitle,
      actions: [
        CatchButton(
          label: context.l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
          onPressed: () => Navigator.of(dialogContext).pop(),
          variant: CatchButtonVariant.secondary,
        ),
        CatchButton(
          label: context.l10n.hostFormCreate,
          onPressed: () {
            final value = label.text.trim();
            if (value.isEmpty) return;
            Navigator.of(dialogContext).pop(
              _TrackedLinkInput(
                label: value,
                source: source.text.trim().isEmpty ? null : source.text.trim(),
              ),
            );
          },
        ),
      ],
      child: CatchSection.containedFieldRows(
        children: [
          CatchField.input(
            title: context.l10n.hostFormTrackedLinkLabel,
            controller: label,
            contract: CatchContractConstraints
                .createOrganizerFormShareLinkCallablePayloadLabel,
            inputHint: context.l10n.hostFormTrackedLinkLabelHint,
            textInputAction: TextInputAction.next,
          ),
          CatchField.input(
            title: context.l10n.hostFormTrackedLinkSource,
            controller: source,
            contract: CatchContractConstraints
                .createOrganizerFormShareLinkCallablePayloadSource,
            inputHint: context.l10n.hostFormTrackedLinkSourceHint,
            textInputAction: TextInputAction.done,
            isOptional: true,
          ),
        ],
      ),
    ),
  );
  label.dispose();
  source.dispose();
  return result;
}

Rect? _shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
}
