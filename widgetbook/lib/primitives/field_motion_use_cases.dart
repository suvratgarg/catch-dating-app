import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Current vs proposed',
  type: CatchField,
  path: '[Review gates]/Field motion',
)
Widget catchFieldMotionReview(BuildContext context) {
  final accordionOpen = context.knobs.boolean(
    label: 'Accordion expanded',
    initialValue: true,
  );
  final drawerOpen = context.knobs.boolean(
    label: 'Disclosure drawer open',
    initialValue: true,
  );
  final status = context.knobs.object.dropdown<CatchFieldStatus>(
    label: 'Save status',
    options: CatchFieldStatus.values,
    initialOption: CatchFieldStatus.saved,
    labelBuilder: (value) => value.name,
  );
  final chipSelected = context.knobs.boolean(
    label: 'Chip selected',
    initialValue: true,
  );

  return _MotionReviewScreen(
    accordionOpen: accordionOpen,
    drawerOpen: drawerOpen,
    status: status,
    chipSelected: chipSelected,
  );
}

class _MotionReviewScreen extends StatelessWidget {
  const _MotionReviewScreen({
    required this.accordionOpen,
    required this.drawerOpen,
    required this.status,
    required this.chipSelected,
  });

  final bool accordionOpen;
  final bool drawerOpen;
  final CatchFieldStatus status;
  final bool chipSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody,
          children: [
            Text(
              'Field motion taste gate',
              style: CatchTextStyles.headline(context),
            ),
            gapH8,
            Text(
              'Four moments only. The proposal reuses CatchMotion.base, '
              'CatchMotion.fast, CatchMotion.standardCurve, and '
              'CatchMotion.easeOutBackCurve; no token additions are proposed.',
              style: CatchTextStyles.bodyLead(context, color: t.ink2),
            ),
            gapH20,
            _Comparison(
              title: 'Accordion / inline editor',
              current: _AccordionPreview(open: accordionOpen),
              proposed: _ProposedReveal(open: accordionOpen),
            ),
            gapH16,
            _Comparison(
              title: 'Disclosure drawer',
              current: _DrawerPreview(
                open: drawerOpen,
                revealDuration: CatchFieldTokens.reveal,
                opacityDuration: CatchFieldTokens.fast,
              ),
              proposed: _DrawerPreview(
                open: drawerOpen,
                revealDuration: CatchMotion.base,
                opacityDuration: CatchMotion.base,
              ),
            ),
            gapH16,
            _Comparison(
              title: 'Idle → saving → saved',
              current: CatchField.read(
                title: 'Profile details',
                body: 'Status swaps immediately today',
                status: status,
              ),
              proposed: _ProposedStatus(status: status),
            ),
            gapH16,
            _Comparison(
              title: 'Selectable chip',
              current: CatchChip.selectable(
                label: 'Run club',
                selected: chipSelected,
                onChanged: (_) {},
              ),
              proposed: CatchChip.selectable(
                label: 'Run club',
                selected: chipSelected,
                onChanged: (_) {},
              ),
              note:
                  'Already uses the shared short motion token with no layout shift.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({
    required this.title,
    required this.current,
    required this.proposed,
    this.note,
  });

  final String title;
  final Widget current;
  final Widget proposed;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return CatchSurface.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          if (note case final note?) ...[
            gapH4,
            Text(note, style: CatchTextStyles.supporting(context)),
          ],
          gapH12,
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _Preview(label: 'Current', child: current),
                _Preview(label: 'Proposed', child: proposed),
              ];
              if (constraints.maxWidth < CatchLayout.maxContentWidth) {
                return Column(children: [cards.first, gapH12, cards.last]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards.first),
                  gapW12,
                  Expanded(child: cards.last),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CatchTextStyles.labelM(context, color: t.ink2)),
        gapH8,
        child,
      ],
    );
  }
}

class _AccordionPreview extends StatelessWidget {
  const _AccordionPreview({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Event description'),
          if (open) ...[
            gapH8,
            const Text('Add the details guests need before they book.'),
          ],
        ],
      ),
    );
  }
}

class _ProposedReveal extends StatelessWidget {
  const _ProposedReveal({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Event description'),
          TweenAnimationBuilder<double>(
            duration: CatchMotion.base,
            curve: CatchMotion.standardCurve,
            tween: Tween(end: open ? 1 : 0),
            builder: (context, value, child) => ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: value,
                child: Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, CatchSpacing.s2 * (1 - value)),
                    child: child,
                  ),
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: CatchSpacing.s2),
              child: Text('Add the details guests need before they book.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerPreview extends StatelessWidget {
  const _DrawerPreview({
    required this.open,
    required this.revealDuration,
    required this.opacityDuration,
  });

  final bool open;
  final Duration revealDuration;
  final Duration opacityDuration;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      child: CatchFieldDisclosureDrawer(
        open: open,
        offstage: !open,
        control: const Text('Drawer control content'),
        startPadding: CatchSpacing.s4,
        endPadding: CatchSpacing.s4,
        bottomPadding: CatchSpacing.s4,
        revealDuration: revealDuration,
        opacityDuration: opacityDuration,
        onRevealEnd: () {},
      ),
    );
  }
}

class _ProposedStatus extends StatelessWidget {
  const _ProposedStatus({required this.status});

  final CatchFieldStatus status;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Row(
        children: [
          const Expanded(child: Text('Profile details')),
          AnimatedSwitcher(
            duration: CatchMotion.base,
            switchInCurve: status == CatchFieldStatus.saved
                ? CatchMotion.easeOutBackCurve
                : CatchMotion.standardCurve,
            switchOutCurve: CatchMotion.standardCurve,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: status == CatchFieldStatus.saved
                  ? ScaleTransition(scale: animation, child: child)
                  : child,
            ),
            child: switch (status) {
              CatchFieldStatus.idle => const SizedBox.square(
                key: ValueKey('idle'),
                dimension: CatchIcon.md,
              ),
              CatchFieldStatus.saving => CatchFieldSpinner(
                key: const ValueKey('saving'),
                color: t.ink3,
              ),
              CatchFieldStatus.saved => Icon(
                CatchIcons.checkCircleFilled,
                key: const ValueKey('saved'),
                color: t.success,
              ),
            },
          ),
        ],
      ),
    );
  }
}
