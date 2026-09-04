import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_configuration.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_entry_content.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The proposed route view, with a single start action and optional editors.
/// The route controller supplies source loading, persistence and navigation.
class EventRehearsalEntryView extends StatelessWidget {
  const EventRehearsalEntryView({
    super.key,
    required this.configuration,
    required this.onChooseSource,
    required this.onChooseScenario,
    required this.onCustomise,
    required this.onStart,
    this.isPending = false,
  });

  final EventRehearsalConfiguration configuration;
  final VoidCallback onChooseSource;
  final VoidCallback onChooseScenario;
  final VoidCallback onCustomise;
  final VoidCallback onStart;
  final bool isPending;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !isPending,
    child: CatchRouteScaffold(
      topBarBuilder: (context, scrolled) => CatchTopBar(
        title: context.l10n.hostEventRehearsalTitle,
        showBackButton: !isPending,
        divider: scrolled,
      ),
      // The action overlay owns the edge-to-edge plane. Its body delegates the
      // ordinary content gutter, responsive width and scroll to the page owner.
      body: CatchRouteBody.fullBleed(
        child: CatchBottomActionOverlay(
          body: CatchResponsiveSectionPage(
            terminalExtra: CatchLayout.bottomActionOverlayScrimHeight,
            sections: [
              CatchResponsiveSectionItem(
                child: CatchSection.plain(
                  padding: EdgeInsets.zero,
                  child: EventRehearsalEntryContent(
                    configuration: configuration,
                    onChooseSource: isPending ? null : onChooseSource,
                    onChooseScenario: isPending ? null : onChooseScenario,
                    onCustomise: isPending ? null : onCustomise,
                  ),
                ),
              ),
            ],
          ),
          notice: Padding(
            padding: CatchInsets.content,
            child: Text(
              context.l10n.hostRehearsalSafety,
              textAlign: TextAlign.center,
              style: CatchTextStyles.recordContext(context),
            ),
          ),
          actions: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: CatchButton(
                label: context.l10n.hostRehearsalStart,
                fullWidth: true,
                size: CatchButtonSize.lg,
                isLoading: isPending,
                onPressed:
                    isPending ||
                        configuration.actorCount < 2 ||
                        configuration.actorCount > 50
                    ? null
                    : onStart,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
