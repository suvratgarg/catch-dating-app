import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('native metrics and font family share the $platform target', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final expected = platform == TargetPlatform.iOS
          ? GeneratedCatchTypographyTokens.ios
          : GeneratedCatchTypographyTokens.android;
      expect(identical(CatchPlatformTokens.typography, expected), isTrue);
      late TextStyle name;
      late TextStyle field;
      await tester.pumpWidget(
        MaterialApp(
          // A theme override must not accidentally select different metrics from
          // the font family selected for the binary.
          theme: AppTheme.light.copyWith(
            platform: platform == TargetPlatform.iOS
                ? TargetPlatform.android
                : TargetPlatform.iOS,
          ),
          home: Builder(
            builder: (context) {
              name = CatchTextStyles.name(context);
              field = CatchTextStyles.fieldRowTitle(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(
        name.fontFamily,
        platform == TargetPlatform.iOS ? 'CupertinoSystemText' : 'Roboto',
      );
      expect(name.height, expected.name.height);
      expect(CatchFieldTokens.valueLineExtent, field.fontSize! * field.height!);
      expect(
        CatchFieldTokens.captionExtent,
        expected.fieldLabel.fontSize! * expected.fieldLabel.height!,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
      'identity header preserves its title lane with a divider at 2x $platform',
      (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const Scaffold(
              appBar: CatchTopBar(
                title: 'Ananya Rao',
                titleRole: CatchTopBarTitleRole.identity,
                divider: true,
                leadingType: CatchTopBarLeading.none,
              ),
              body: SizedBox.shrink(),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final header = tester.getRect(find.byType(CatchTopBar));
        final title = tester.getRect(find.text('Ananya Rao'));
        expect(title.top, greaterThanOrEqualTo(header.top));
        expect(title.bottom, lessThanOrEqualTo(header.bottom));
        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets('scaled tab rail reserves its actual height on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const CatchScreenScaffold.workspace(
            appBar: CatchTopBar(
              title: 'Customers',
              bottom: CatchTabRail<int>(
                selected: 0,
                options: [
                  CatchOption(value: 0, label: 'Overview'),
                  CatchOption(value: 1, label: 'History'),
                ],
              ),
            ),
            body: SizedBox.expand(key: ValueKey('scaled-header-body')),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final rail = find.byType(CatchTabRail<int>);
      expect(
        tester.getSize(rail).height,
        CatchTabRail.heightFor(tester.element(rail)),
      );
      expect(
        tester.getRect(rail).bottom,
        tester.getRect(find.byKey(const ValueKey('scaled-header-body'))).top,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    for (final direction in TextDirection.values) {
      testWidgets(
        'directory and controls stay readable at 2x $platform $direction',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          var selected = false;
          var commanded = false;
          var opened = false;
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                  child: Directionality(
                    textDirection: direction,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 320,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CatchPersonRow.directory(
                              data: const CatchPersonRowData(
                                name: 'Ananya Rao with a longer family name',
                              ),
                              onTap: () => opened = true,
                              metadata: const Text(
                                '8 events · Last seen 18 June 2026',
                              ),
                              contextContent: const Text(
                                'Returning customer from the weekend event',
                              ),
                              status: const CatchBadge.status(
                                label: 'Needs identity review',
                                tone: CatchBadgeTone.warning,
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: CatchOptionGroup<int>(
                                options: const [
                                  CatchOption(value: 1, label: 'Returning 148'),
                                ],
                                selected: 1,
                                variant: CatchOptionGroupVariant.summary,
                                onChanged: (_) => selected = true,
                              ),
                            ),
                            CatchButton.command(
                              label: 'Sort: Most recently attended',
                              onPressed: () => commanded = true,
                            ),
                            const CatchFieldSupportRow(
                              color: Colors.black,
                              text:
                                  'A complete explanation including its final sentence must remain visible.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          for (final element in find.byType(RichText).evaluate()) {
            expect(
              (element.renderObject! as RenderParagraph).didExceedMaxLines,
              isFalse,
              reason: (element.widget as RichText).text.toPlainText(),
            );
          }
          expect(
            tester.getTopLeft(find.text('Needs identity review')).dy,
            greaterThan(
              tester
                  .getBottomLeft(
                    find.text('Returning customer from the weekend event'),
                  )
                  .dy,
            ),
          );
          expect(
            tester.getSize(find.byType(CatchButton)).height,
            greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
          );
          expect(
            tester.getSize(find.byType(CatchOptionGroupItem<int>)).height,
            greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
          );
          await tester.tap(find.text('Ananya Rao with a longer family name'));
          expect(opened, isTrue);
          await tester.ensureVisible(find.text('Returning 148'));
          await tester.tap(find.text('Returning 148'));
          expect(selected, isTrue);
          await tester.ensureVisible(find.text('Sort: Most recently attended'));
          await tester.tap(find.text('Sort: Most recently attended'));
          expect(commanded, isTrue);
          expect(tester.takeException(), isNull);
          debugDefaultTargetPlatformOverride = null;
        },
      );
    }
  }

  testWidgets('unselected summary scope supports keyboard selection', (
    tester,
  ) async {
    var chosen = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchOptionGroup<int>(
            options: const [
              CatchOption(value: 1, label: 'All 214'),
              CatchOption(value: 2, label: 'Returning 148'),
            ],
            selected: null,
            variant: CatchOptionGroupVariant.summary,
            onChanged: (_) => chosen = true,
          ),
        ),
      ),
    );
    expect(
      tester
          .widgetList<CatchOptionGroupItem<int>>(
            find.byType(CatchOptionGroupItem<int>),
          )
          .every((option) => !option.selected),
      isTrue,
    );
    expect(tester.takeException(), isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(chosen, isTrue);
  });
}
