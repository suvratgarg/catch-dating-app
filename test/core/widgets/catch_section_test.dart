import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CatchSection.fieldRows renders rows flush with lane-aligned dividers',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 360,
            child: CatchSection.fieldRows(
              title: 'Details',
              children: [
                CatchField.read(
                  title: 'First',
                  valueText: 'A',
                  icon: CatchIcons.helpOutline,
                ),
                CatchField.read(
                  title: 'Second',
                  valueText: 'B',
                  icon: CatchIcons.schedule,
                ),
              ],
            ),
          ),
        ),
      );

      final sectionRect = tester.getRect(find.byType(CatchSection));
      final firstIconRect = tester.getRect(find.byIcon(CatchIcons.helpOutline));
      expect(firstIconRect.left, sectionRect.left);

      final dividerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            widget.child is SizedBox &&
            (widget.child as SizedBox).height == CatchStroke.hairline,
      );
      final dividerRect = tester.getRect(dividerFinder.last);
      expect(dividerRect.left - sectionRect.left, CatchFieldRow.textLaneInset);
      expect(dividerRect.right, sectionRect.right);

      final dividerBox = tester.widget<ColoredBox>(dividerFinder.last);
      expect(
        dividerBox.color,
        CatchDivider.colorFor(
          CatchTokens.editorialLight,
          CatchDividerRole.fieldRow,
        ),
      );
    },
  );

  testWidgets(
    'CatchSection.fieldRows paints dividers from the preceding row layer',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.fieldRows(
              first: true,
              children: [
                CatchField.read(title: 'First', body: 'A'),
                CatchField.control(
                  title: 'Second',
                  body: 'B',
                  initiallyOpen: true,
                  control: Text('Second control'),
                ),
                CatchField.read(title: 'Third', body: 'C'),
              ],
            ),
          ),
        ),
      );

      final dividerPositions = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .where((positioned) => positioned.child is CatchDivider)
          .toList(growable: false);

      expect(dividerPositions, hasLength(2));
      for (final positioned in dividerPositions) {
        expect(positioned.top, isNull);
        expect(positioned.bottom, -CatchStroke.hairline);
      }
    },
  );

  testWidgets(
    'CatchSection field dividers do not change the global row divider tone',
    (tester) async {
      final tokens = CatchTokens.editorialLight;

      expect(
        CatchDivider.colorFor(tokens, CatchDividerRole.fieldSection),
        tokens.line,
      );
      expect(
        CatchDivider.colorFor(tokens, CatchDividerRole.fieldRow),
        tokens.line.withValues(alpha: CatchOpacity.fieldRowDivider),
      );
    },
  );

  testWidgets('CatchSection headerless field rows still own their top rule', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 360,
          child: CatchSection.fieldRows(
            first: true,
            children: [CatchField.read(title: 'Log out')],
          ),
        ),
      ),
    );

    final sectionRect = tester.getRect(find.byType(CatchSection));
    final ruleRect = tester.getRect(find.byType(CatchDivider));

    expect(ruleRect.top, sectionRect.top);
    expect(ruleRect.left, sectionRect.left);
    expect(ruleRect.right, sectionRect.right);
  });

  testWidgets(
    'CatchSection field rows preserve text-lane dividers for adapter children',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.fieldRows(
              first: true,
              children: [
                SizedBox(child: CatchField.read(title: 'First')),
                SizedBox(child: CatchField.read(title: 'Second')),
              ],
            ),
          ),
        ),
      );

      final sectionRect = tester.getRect(find.byType(CatchSection));
      final dividerRect = tester.getRect(
        find
            .byWidgetPredicate(
              (widget) => widget is Positioned && widget.child is CatchDivider,
            )
            .first,
      );

      expect(
        dividerRect.left - sectionRect.left,
        CatchFieldTokens.textLaneInset,
      );
    },
  );

  testWidgets('CatchSection divided footer uses handoff spacing and caption', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 360,
          child: CatchSection.fieldRows(
            first: true,
            footer: Text('We never show your birth year.'),
            children: [CatchField.read(title: 'Date of birth', body: '12 Aug')],
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final footerFinder = find.text('We never show your birth year.');
    final footerRect = tester.getRect(footerFinder);
    final footerStyle = DefaultTextStyle.of(tester.element(footerFinder)).style;

    expect(
      footerRect.top - fieldRect.bottom,
      closeTo(CatchFieldTokens.dividedSectionFooterTopPadding, 0.001),
    );
    expect(footerStyle.color, CatchTokens.editorialLight.ink3);
    expect(footerStyle.height, 1.5);
  });

  testWidgets('CatchSection section variant renders row variants', (
    tester,
  ) async {
    var toggleValue = false;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchSection.divided(
            title: 'Account',
            first: true,
            children: [
              CatchField.nav(
                icon: CatchIcons.personOutlineRounded,
                title: 'Aanya',
                body: 'Name',
                onTap: () {},
              ),
              const CatchField.add(title: '+ Add bio'),
              CatchField.toggle(
                title: 'Visible',
                value: toggleValue,
                onChanged: (value) => setState(() => toggleValue = value),
              ),
              CatchField.read(
                icon: CatchIcons.deleteOutline,
                title: 'Delete account',
                tone: CatchFieldTone.danger,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Aanya'), findsOneWidget);
    expect(find.text('+ Add bio'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.byType(CatchKicker), findsOneWidget);
    expect(find.bySemanticsLabel('Visible'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('catch-field-toggle')));
    await tester.pump();

    expect(toggleValue, isTrue);
  });

  testWidgets('CatchSection composes the shared kicker leaf', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        _wrap(
          const CatchSection.divided(
            title: 'Why you might click',
            first: true,
            child: Text('Body copy'),
          ),
        ),
      );

      expect(find.byType(CatchKicker), findsOneWidget);
      expect(find.text('WHY YOU MIGHT CLICK'), findsOneWidget);
      expect(find.text('Body copy'), findsOneWidget);
      expect(
        find.semantics.byLabel('WHY YOU MIGHT CLICK'),
        matchesSemantics(label: 'WHY YOU MIGHT CLICK', isHeader: true),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('CatchSectionStack lets Section own the handoff rhythm', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSectionStack(
          children: [
            CatchSection.divided(
              title: 'First',
              first: true,
              child: Text('First body'),
            ),
            CatchSection.divided(title: 'Second', child: Text('Second body')),
          ],
        ),
      ),
    );

    final stack = tester.widget<CatchSectionStack>(
      find.byType(CatchSectionStack),
    );

    expect(stack.gap, 0);
    expect(stack.padding, CatchInsets.pageBody);
    expect(find.byType(Divider), findsNothing);
    expect(find.text('SECOND'), findsOneWidget);
  });

  testWidgets('CatchSection accents only a lead activity section', (
    tester,
  ) async {
    late Color activityAccent;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            activityAccent = ActivityPalette.resolve(
              context,
              ActivityKind.socialRun,
            ).accent;
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchSection.divided(
                  title: 'The plan',
                  activityKind: ActivityKind.socialRun,
                  lead: true,
                  first: true,
                  child: Text('Lead body'),
                ),
                CatchSection.divided(
                  title: 'Details',
                  activityKind: ActivityKind.socialRun,
                  child: Text('Neutral body'),
                ),
              ],
            );
          },
        ),
      ),
    );

    final lead = tester.widget<Text>(find.text('THE PLAN'));
    final neutral = tester.widget<Text>(find.text('DETAILS'));
    expect(lead.style?.color, activityAccent);
    expect(neutral.style?.color, CatchTokens.editorialLight.ink);
  });

  testWidgets('CatchSection contained renders title and trailing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSection.contained(
          title: 'Profile strength',
          subtitle: '3 of 7 profile basics complete',
          trailing: Text('28%'),
          child: Text('Section body'),
        ),
      ),
    );

    expect(find.text('Profile strength'), findsOneWidget);
    expect(find.text('3 of 7 profile basics complete'), findsOneWidget);
    expect(find.text('28%'), findsOneWidget);
    expect(find.text('Section body'), findsOneWidget);
    expect(find.text('PROFILE STRENGTH'), findsNothing);
    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.role, CatchSurfaceRole.card);
    expect(surface.elevation, CatchSurfaceElevation.card);
  });

  testWidgets(
    'CatchSection contained field rows keep header and footer inside the card',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.containedFieldRows(
              title: 'Where',
              count: '2 OF 4',
              trailing: Text('Ready'),
              footer: Text('Attendees see this on event cards.'),
              children: [CatchField.read(title: 'Location', body: 'Bandra')],
            ),
          ),
        ),
      );

      final surfaceFinder = find
          .descendant(
            of: find.byType(CatchSectionFocusSurface),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final surfaceRect = tester.getRect(surfaceFinder);
      final titleRect = tester.getRect(find.text('WHERE'));
      final title = tester.widget<Text>(find.text('WHERE'));
      final countRect = tester.getRect(find.text('2 OF 4'));
      final trailingRect = tester.getRect(find.text('Ready'));
      final fieldRect = tester.getRect(find.byType(CatchField));
      final footerRect = tester.getRect(
        find.text('Attendees see this on event cards.'),
      );

      expect(find.text('Where · 2 OF 4'), findsNothing);
      expect(title.style?.fontSize, CatchFieldTokens.sectionKickerFontSize);
      expect(title.style?.fontWeight, FontWeight.w600);
      expect(
        title.style?.letterSpacing,
        CatchFieldTokens.sectionKickerLetterSpacing,
      );
      expect(
        titleRect.left - surfaceRect.left,
        CatchStroke.hairline + CatchFieldTokens.rowHorizontalPadding,
      );
      expect(
        titleRect.top - surfaceRect.top,
        CatchStroke.hairline + CatchFieldTokens.sectionHeaderTopPadding,
      );
      expect(countRect.right, lessThan(trailingRect.left));
      expect(
        surfaceRect.right - trailingRect.right,
        CatchStroke.hairline + CatchFieldTokens.rowHorizontalPadding,
      );
      expect(
        surfaceRect.bottom - footerRect.bottom,
        CatchStroke.hairline + CatchFieldTokens.rowVerticalPadding,
      );
      expect(
        footerRect.top - fieldRect.bottom,
        closeTo(CatchFieldTokens.containedSectionFooterTopPadding, 0.001),
      );
      expect(
        find.ancestor(
          of: find.text('Attendees see this on event cards.'),
          matching: find.byType(AnimatedContainer),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CatchSection headerless contained field rows start at the card edge',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.containedFieldRows(
              children: [CatchField.read(title: 'Prompt 1', body: 'Answer')],
            ),
          ),
        ),
      );

      final surfaceRect = tester.getRect(
        find
            .descendant(
              of: find.byType(CatchSectionFocusSurface),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final fieldRect = tester.getRect(find.byType(CatchField));

      expect(fieldRect.top, surfaceRect.top + CatchStroke.hairline);
    },
  );

  testWidgets('CatchSection contained reflects descendant focus', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _wrap(CatchSection.contained(child: TextField(focusNode: focusNode))),
    );

    focusNode.requestFocus();
    await tester.pump();

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.borderColor, CatchTokens.editorialLight.primary);
    expect(
      surface.boxShadow,
      CatchElevation.focusRing(CatchTokens.editorialLight),
    );
  });

  testWidgets(
    'CatchSection divided field rows expose the trailing header slot',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.fieldRows(
              first: true,
              title: 'Prompts',
              count: '3 OF 3 ANSWERED',
              trailing: Text('Edit'),
              children: [CatchField.read(title: 'Prompt', body: 'Answer')],
            ),
          ),
        ),
      );

      final titleRect = tester.getRect(find.text('PROMPTS'));
      final titleText = tester.widget<Text>(find.text('PROMPTS'));
      final countRect = tester.getRect(find.text('3 OF 3 ANSWERED'));
      final trailingRect = tester.getRect(find.text('Edit'));
      expect(titleRect.left, lessThan(countRect.left));
      expect(countRect.right, lessThan(trailingRect.left));
      expect(titleText.style?.color, CatchTokens.editorialLight.ink2);
      expect(titleText.style?.fontSize, CatchFieldTokens.sectionKickerFontSize);
      expect(titleText.style?.fontWeight, FontWeight.w600);
      expect(
        titleText.style?.letterSpacing,
        CatchFieldTokens.sectionKickerLetterSpacing,
      );
    },
  );

  testWidgets(
    'CatchSection contained field rows leave descendant focus to the field',
    (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _wrap(
          CatchSection.containedFieldRows(
            child: TextField(focusNode: focusNode),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      final surface = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(CatchSectionFocusSurface),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final decoration = surface.foregroundDecoration! as BoxDecoration;
      expect(
        decoration.border,
        Border.all(color: CatchTokens.editorialLight.line2),
      );
    },
  );

  testWidgets('CatchSection contained field rows honor explicit focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSection.containedFieldRows(
          focused: true,
          child: Text('Section body'),
        ),
      ),
    );

    final surface = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(CatchSectionFocusSurface),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final decoration = surface.foregroundDecoration! as BoxDecoration;
    expect(
      decoration.border,
      Border.all(color: CatchTokens.editorialLight.ink),
    );

    await tester.pumpWidget(
      _wrap(
        const CatchSection.containedFieldRows(
          focused: true,
          hasError: true,
          child: Text('Section body'),
        ),
      ),
    );
    final errorSurface = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(CatchSectionFocusSurface),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final errorDecoration = errorSurface.foregroundDecoration! as BoxDecoration;
    expect(
      errorDecoration.border,
      Border.all(color: CatchTokens.editorialLight.danger),
    );
  });

  testWidgets(
    'CatchSection contained perimeter and active edge fields share geometry',
    (tester) async {
      Future<void> pump({required bool firstOpen}) {
        return tester.pumpWidget(
          _wrap(
            SizedBox(
              width: 360,
              child: CatchSection.containedFieldRows(
                children: [
                  CatchField.control(
                    title: 'Prompt',
                    body: 'Question',
                    open: firstOpen,
                    onOpenChanged: (_) {},
                    control: const Text('Question choices'),
                  ),
                  CatchField.control(
                    title: 'Answer',
                    body: 'Response',
                    open: !firstOpen,
                    onOpenChanged: (_) {},
                    control: const Text('Answer editor'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      for (final firstOpen in [true, false]) {
        await pump(firstOpen: firstOpen);
        final surface = tester.widget<AnimatedContainer>(
          find
              .descendant(
                of: find.byType(CatchSectionFocusSurface),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final background = surface.decoration! as BoxDecoration;
        final perimeter = surface.foregroundDecoration! as BoxDecoration;
        final activeOverlayFinder = find.byWidgetPredicate((widget) {
          if (widget is! AnimatedContainer ||
              widget.key != const ValueKey('catch-field-active-overlay')) {
            return false;
          }
          final decoration = widget.decoration;
          return decoration is BoxDecoration && decoration.border != null;
        }, description: 'active CatchField overlay with a painted border');
        final activeFieldFinder = find.ancestor(
          of: activeOverlayFinder,
          matching: find.byType(CatchField),
        );
        expect(activeOverlayFinder, findsOneWidget);
        expect(activeFieldFinder, findsOneWidget);
        final activeOverlayRect = tester.getRect(activeOverlayFinder);
        final surfaceRect = tester.getRect(
          find.byType(CatchSectionFocusSurface),
        );
        final activeFieldRect = tester.getRect(activeFieldFinder);

        expect(background.border, isNull);
        expect(
          perimeter.border,
          Border.all(color: CatchTokens.editorialLight.line2),
        );
        expect(activeOverlayRect.left, closeTo(surfaceRect.left, 0.1));
        expect(activeOverlayRect.right, closeTo(surfaceRect.right, 0.1));
        expect(
          activeFieldRect.left,
          closeTo(surfaceRect.left + CatchStroke.hairline, 0.1),
        );
        expect(
          activeFieldRect.right,
          closeTo(surfaceRect.right - CatchStroke.hairline, 0.1),
        );
        if (firstOpen) {
          expect(activeOverlayRect.top, lessThanOrEqualTo(surfaceRect.top));
        } else {
          expect(
            activeOverlayRect.bottom,
            greaterThanOrEqualTo(surfaceRect.bottom),
          );
        }
      }
    },
  );

  testWidgets(
    'CatchSectionFocusSurface field rows own active edge geometry directly',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSectionFocusSurface(
              padding: EdgeInsets.zero,
              focused: false,
              hasError: false,
              fieldRows: true,
              child: CatchField.input(
                title: 'Answer',
                initialValue: 'The child owns this focus ring.',
                focused: true,
              ),
            ),
          ),
        ),
      );

      final surfaceRect = tester.getRect(find.byType(CatchSectionFocusSurface));
      final fieldRect = tester.getRect(find.byType(CatchField));
      final activeOverlayRect = tester.getRect(
        find.byKey(const ValueKey('catch-field-active-overlay')),
      );

      expect(activeOverlayRect.left, closeTo(surfaceRect.left, 0.1));
      expect(activeOverlayRect.right, closeTo(surfaceRect.right, 0.1));
      expect(
        fieldRect.left,
        closeTo(surfaceRect.left + CatchStroke.hairline, 0.1),
      );
      expect(
        fieldRect.right,
        closeTo(surfaceRect.right - CatchStroke.hairline, 0.1),
      );
    },
  );

  testWidgets(
    'CatchSection contained renders field rows flush to card padding',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 360,
            child: CatchSection.contained(
              child: CatchField.read(
                title: 'Notifications',
                valueText: 'On',
                icon: CatchIcons.helpOutline,
              ),
            ),
          ),
        ),
      );

      final surfaceRect = tester.getRect(find.byType(CatchSurface));
      final iconRect = tester.getRect(find.byIcon(CatchIcons.helpOutline));
      final labelLeft = tester.getTopLeft(find.text('Notifications')).dx;
      final valueRight = tester.getTopRight(find.text('On')).dx;

      expect(iconRect.left, closeTo(surfaceRect.left + CatchSpacing.s4, 0.1));
      expect(
        labelLeft,
        closeTo(
          surfaceRect.left + CatchSpacing.s4 + CatchFieldRow.textLaneInset,
          0.2,
        ),
      );
      expect(valueRight, closeTo(surfaceRect.right - CatchSpacing.s4, 0.1));
    },
  );

  testWidgets('CatchSection contained error owns the danger state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSection.contained(
          focused: true,
          hasError: true,
          child: Text('Section body'),
        ),
      ),
    );

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.borderColor, CatchTokens.editorialLight.danger);
    expect(surface.boxShadow, isNull);
  });

  testWidgets('CatchSection can suppress only its internal row dividers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 360,
          child: CatchSection.containedFieldRows(
            showInternalDividers: false,
            children: [
              CatchField.read(title: 'First', body: 'A'),
              CatchField.read(title: 'Second', body: 'B'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CatchDivider), findsNothing);
    expect(find.byType(CatchField), findsNWidgets(2));
  });
}

Widget _wrap(Widget child, {ThemeData? theme, double textScale = 1}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}
