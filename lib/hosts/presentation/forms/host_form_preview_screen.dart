import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_renderer.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostFormPreviewScreen extends ConsumerWidget {
  const HostFormPreviewScreen({
    super.key,
    required this.organizerId,
    required this.formId,
  });

  final String organizerId;
  final String formId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      hostFormEditorControllerProvider(organizerId, formId),
    );
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostAudienceQuestionPreview,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: CatchRouteBody.standardConstrained(
        child: CatchAsyncValueView<HostFormEditorState>(
          value: state,
          onRetry: () => ref
              .read(
                hostFormEditorControllerProvider(organizerId, formId).notifier,
              )
              .reload(),
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 8),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.forms,
            onRetry: () => ref
                .read(
                  hostFormEditorControllerProvider(
                    organizerId,
                    formId,
                  ).notifier,
                )
                .reload(),
          ),
          builder: (context, value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.hostFormPreviewSubtitle,
                style: CatchTextStyles.supporting(context),
              ),
              gapH24,
              HostFormRenderer(definition: value.editor.definition),
            ],
          ),
        ),
      ),
    );
  }
}
