import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostFormTemplatesScreen extends ConsumerStatefulWidget {
  const HostFormTemplatesScreen({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostFormTemplatesScreen> createState() =>
      _HostFormTemplatesScreenState();
}

class _HostFormTemplatesScreenState
    extends ConsumerState<HostFormTemplatesScreen> {
  String? _creatingTemplateId;

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(hostFormTemplatesProvider(widget.organizerId));
    final t = CatchTokens.of(context);
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostFormTemplatesTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CatchScreenBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.hostFormTemplatesSubtitle,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              gapH20,
              CatchAsyncValueView<List<HostFormTemplateSummary>>(
                value: templates,
                onRetry: () => ref.invalidate(
                  hostFormTemplatesProvider(widget.organizerId),
                ),
                initialLoadTimeout: null,
                loadingBuilder: (_) => const CatchSkeletonRows(count: 7),
                errorBuilder: (_, error, _) => CatchErrorState.fromError(
                  error,
                  context: AppErrorContext.forms,
                  onRetry: () => ref.invalidate(
                    hostFormTemplatesProvider(widget.organizerId),
                  ),
                ),
                builder: (context, values) => CatchSection.containedFieldRows(
                  children: [
                    for (final template in values)
                      CatchField.nav(
                        key: ValueKey(
                          'host-form-template-${template.templateId}',
                        ),
                        title: template.title,
                        body: template.description,
                        valueText: context.l10n.hostFormTemplateSummary(
                          purpose: hostFormPurposeLabel(
                            context,
                            template.purpose,
                          ),
                          count: template.questionCount,
                        ),
                        icon: template.templateId == 'blank_form'
                            ? CatchIcons.addRounded
                            : CatchIcons.descriptionOutlined,
                        status: _creatingTemplateId == template.templateId
                            ? CatchFieldStatus.saving
                            : CatchFieldStatus.idle,
                        onTap: _creatingTemplateId == null
                            ? () => _create(template)
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _create(HostFormTemplateSummary template) async {
    setState(() => _creatingTemplateId = template.templateId);
    try {
      final editor = await ref
          .read(hostFormsControllerProvider)
          .create(
            organizerId: widget.organizerId,
            templateId: template.templateId,
            requestId: _requestId(template.templateId),
          );
      if (!mounted) return;
      ref.invalidate(
        hostFormsDirectoryControllerProvider(
          HostFormListRequest(organizerId: widget.organizerId),
        ),
      );
      context.pushReplacementNamed(
        Routes.hostFormBuilderScreen.name,
        pathParameters: {'formId': editor.form.formId},
        queryParameters: {'organizerId': widget.organizerId},
      );
    } on Object catch (error) {
      if (!mounted) return;
      showCatchErrorSnackBar(context, error);
      setState(() => _creatingTemplateId = null);
    }
  }
}

String _requestId(String templateId) =>
    'create_${templateId}_${DateTime.now().microsecondsSinceEpoch}';
