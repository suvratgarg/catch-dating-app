part of 'catch_section.dart';

/// Full-width collection controls between a pair of content-lane rules.
///
/// The collection owns the gutter and both boundaries. Callers supply only
/// controls, so result-state branches cannot add or omit a toolbar rule.
class _CatchCollectionToolbar extends StatelessWidget {
  const _CatchCollectionToolbar({
    required this.leading,
    this.trailing,
  });

  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      assert(
        constraints.hasBoundedWidth,
        'A collection toolbar needs a page or pane.',
      );
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: catchSectionContentGutter(constraints.maxWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CatchDivider.section(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: CatchSpacing.s4,
                runSpacing: CatchSpacing.s2,
                children: [leading, ?trailing],
              ),
            ),
            const CatchDivider.section(),
          ],
        ),
      );
    },
  );
}
