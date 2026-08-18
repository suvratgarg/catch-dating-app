import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/clipboard.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    final assets = ref.watch(
      hostFormShareAssetsProvider(
        organizerId: widget.organizerId,
        formId: widget.formId,
      ),
    );
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostFormShare,
        subtitle: context.l10n.hostFormShareSubtitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CatchAsyncValueView<HostFormShareAssets>(
          value: assets,
          onRetry: () => ref.invalidate(
            hostFormShareAssetsProvider(
              organizerId: widget.organizerId,
              formId: widget.formId,
            ),
          ),
          initialLoadTimeout: null,
          loadingBuilder: (_) =>
              const CatchPageBody(child: CatchSkeletonRows(count: 7)),
          errorBuilder: (_, error, _) => CatchPageBody(
            child: CatchErrorState.fromError(
              error,
              context: AppErrorContext.club,
              onRetry: () => ref.invalidate(
                hostFormShareAssetsProvider(
                  organizerId: widget.organizerId,
                  formId: widget.formId,
                ),
              ),
            ),
          ),
          builder: (context, value) => CatchScreenBody(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: CatchLayout.maxContentWidth,
                ),
                child: CatchSectionList(
                  emptyStateOmitted: true,
                  children: [
                    _CanonicalLinkCard(
                      assets: value,
                      onCopy: () => _copy(
                        value.canonicalUrl,
                        context.l10n.hostFormLinkCopied,
                      ),
                      onShare: () => _share(context, value.canonicalUrl),
                    ),
                    _TrackedLinkCard(
                      link: _trackedLink,
                      creating: _creatingLink,
                      onCreate: _createTrackedLink,
                      onCopy: _trackedLink == null
                          ? null
                          : () => _copy(
                              _trackedLink!.url,
                              context.l10n.hostFormLinkCopied,
                            ),
                      onShare: _trackedLink == null
                          ? null
                          : () => _share(context, _trackedLink!.url),
                    ),
                    _EmbedCard(
                      assets: value,
                      onCopy: () => _copy(
                        value.embedSnippet,
                        context.l10n.hostFormEmbedCopied,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copy(String value, String confirmation) async {
    try {
      await ref.read(clipboardControllerProvider).copyText(value);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(confirmation)));
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
          .read(hostFormsRepositoryProvider)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.hostFormTrackedLinkReady)),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _creatingLink = false);
      showCatchErrorSnackBar(context, error);
    }
  }
}

class _CanonicalLinkCard extends StatelessWidget {
  const _CanonicalLinkCard({
    required this.assets,
    required this.onCopy,
    required this.onShare,
  });

  final HostFormShareAssets assets;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => _ShareSection(
    kicker: context.l10n.hostFormCanonicalLink,
    body: context.l10n.hostFormCanonicalLinkHelp,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
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
        gapH16,
        CatchField.read(
          title: context.l10n.hostFormCanonicalLink,
          body: assets.canonicalUrl,
          bodyMaxLines: 3,
        ),
        gapH12,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              label: context.l10n.hostFormCopyLink,
              onPressed: onCopy,
              variant: CatchButtonVariant.secondary,
            ),
            Builder(
              builder: (context) => CatchButton(
                label: context.l10n.hostFormShareLink,
                onPressed: onShare,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TrackedLinkCard extends StatelessWidget {
  const _TrackedLinkCard({
    required this.link,
    required this.creating,
    required this.onCreate,
    required this.onCopy,
    required this.onShare,
  });

  final HostFormShareLink? link;
  final bool creating;
  final VoidCallback onCreate;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) => _ShareSection(
    kicker: context.l10n.hostFormTrackedLinks,
    body: context.l10n.hostFormTrackedLinksHelp,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (link != null) ...[
          CatchField.read(title: link!.label, body: link!.url, bodyMaxLines: 3),
          gapH12,
        ],
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              label: context.l10n.hostFormCreateTrackedLink,
              isLoading: creating,
              onPressed: creating ? null : onCreate,
            ),
            if (link != null) ...[
              CatchButton(
                label: context.l10n.hostFormCopyLink,
                onPressed: onCopy,
                variant: CatchButtonVariant.secondary,
              ),
              CatchButton(
                label: context.l10n.hostFormShareLink,
                onPressed: onShare,
                variant: CatchButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

class _EmbedCard extends StatelessWidget {
  const _EmbedCard({required this.assets, required this.onCopy});

  final HostFormShareAssets assets;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => _ShareSection(
    kicker: context.l10n.hostFormEmbed,
    body: context.l10n.hostFormEmbedHelp,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchField.read(
          title: context.l10n.hostFormEmbed,
          body: assets.embedSnippet,
          bodyMaxLines: 6,
        ),
        gapH12,
        Align(
          alignment: Alignment.centerLeft,
          child: CatchButton(
            label: context.l10n.hostFormCopyEmbed,
            onPressed: onCopy,
            variant: CatchButtonVariant.secondary,
          ),
        ),
      ],
    ),
  );
}

class _ShareSection extends StatelessWidget {
  const _ShareSection({
    required this.kicker,
    required this.body,
    required this.child,
  });

  final String kicker;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchKicker(label: kicker, color: t.ink3),
          gapH8,
          Text(body, style: CatchTextStyles.supporting(context, color: t.ink2)),
          gapH20,
          child,
        ],
      ),
    );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
