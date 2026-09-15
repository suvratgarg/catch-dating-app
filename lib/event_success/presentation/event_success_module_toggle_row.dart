part of 'event_success_feature_blocks.dart';

class ModuleToggleRow extends StatelessWidget {
  const ModuleToggleRow({
    super.key,
    required this.module,
    required this.selected,
    required this.onChanged,
  });

  final EventSuccessModule module;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: _moduleToggleRowGap,
      child: CatchSurface(
        tone: selected ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
        radius: CatchRadius.sm,
        borderColor: selected
            ? t.surface.withValues(alpha: CatchOpacity.none)
            : t.line,
        padding: _moduleToggleContentPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                  const SizedBox(height: CatchSpacing.s1),
                  Text(
                    module.hostPromise,
                    style: CatchTextStyles.supporting(context),
                  ),
                ],
              ),
            ),
            CatchToggleInput(
              contract: CatchContractConstraints
                  .mobileFormStateEventSuccessModuleSelected,
              value: selected,
              onChanged: onChanged,
              semanticLabel: context.l10n
                  .eventSuccessEventSuccessFeatureBlocksLabelTitleTool(
                    title: module.title,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
