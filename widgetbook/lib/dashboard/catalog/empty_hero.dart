import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Hero states',
  type: EmptyHeroCard,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEmptyHeroCardReviewStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'EmptyHeroCard',
    contractId: 'dashboard.home.empty_hero',
    children: [
      WidgetbookPageStateCard(
        label: 'card',
        child: WidgetbookDashboardPrimitiveFrame(child: EmptyHeroCard()),
      ),
      WidgetbookPageStateCard(
        label: 'full bleed',
        child: WidgetbookDashboardPrimitiveFrame(
          child: EmptyHeroCard(fullBleed: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero content states',
  type: EmptyHeroContent,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEmptyHeroContentReviewStates(BuildContext context) {
  final t = CatchTokens.of(context);
  Widget frame({required Widget child}) {
    return WidgetbookDashboardPrimitiveFrame(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: t.heroGrad,
          borderRadius: BorderRadius.circular(CatchRadius.heroCard),
        ),
        child: Padding(padding: CatchInsets.contentRelaxed, child: child),
      ),
    );
  }

  return WidgetbookPageCatalogFrame(
    title: 'EmptyHeroContent',
    contractId: 'dashboard.home.empty_hero_content',
    children: [
      WidgetbookPageStateCard(
        label: 'card copy',
        child: frame(child: EmptyHeroContent(onFindEvent: widgetbookNoop)),
      ),
      WidgetbookPageStateCard(
        label: 'welcome eyebrow',
        child: frame(
          child: EmptyHeroContent(
            onFindEvent: widgetbookNoop,
            showWelcomeEyebrow: true,
          ),
        ),
      ),
    ],
  );
}
