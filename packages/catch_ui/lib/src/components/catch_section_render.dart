part of 'catch_section.dart';

extension _CatchSectionRendering on CatchSection {
  Widget _renderSection(BuildContext context) {
    if (_rowSection case final rows?) return rows;
    if (_horizontalConfig case final rail?) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSectionHeader(
            title: title!,
            heavy: true,
            padding: rail.headerPadding,
          ),
          CatchHorizontalScrollView(
            itemCount: rail.itemCount,
            itemBuilder: rail.itemBuilder,
            footer: footer,
            height: rail.height,
            spacing: rail.spacing,
            listPadding: rail.listPadding,
            itemWidth: rail.itemWidth,
          ),
          if (rail.showDivider)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CatchSpacing.screenPx),
              child: CatchDivider.section(),
            ),
        ],
      );
    }
    final groups = fieldGroups;
    assert(
      groups == null ||
          (groups.isNotEmpty &&
              groups.every((group) => group.children.isNotEmpty)),
      'containedFieldGroups requires at least one non-empty field group.',
    );
    final t = CatchTokens.of(context);
    final variant = _variant;
    final fieldRows = _fieldRows;
    final sectionTrailing = trailing;
    final sectionFooter = footer;
    final displayTitle = title?.trim();
    final displayCount = count?.toString().trim();
    final hasTitle = displayTitle != null && displayTitle.isNotEmpty;
    final hasCount = displayCount != null && displayCount.isNotEmpty;
    final hasHeader = hasTitle || hasCount || sectionTrailing != null;
    final bodyMode = !fieldRows
        ? CatchSectionRowListMode.content
        : variant == _CatchSectionVariant.contained
        ? CatchSectionRowListMode.containedFields
        : CatchSectionRowListMode.dividedFields;
    final body = CatchSectionRowList(
      mode: bodyMode,
      dividerIndent: dividerIndent,
      dividerVariant: internalDividerVariant,
      showInternalDividers: showInternalDividers,
      children: children ?? const [],
      child: child,
    );
    Widget section;
    if (variant == _CatchSectionVariant.divided) {
      final effectiveTitleColor = titleColor ?? (fieldRows ? t.ink2 : t.ink);
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader) ...[
            CatchSectionHeader.kicker(
              title: hasTitle ? displayTitle : null,
              count: hasCount ? displayCount : null,
              trailing: sectionTrailing,
              color: effectiveTitleColor,
              textVariant: fieldRows
                  ? CatchKickerTextVariant.fieldSection
                  : CatchKickerTextVariant.md,
            ),
            SizedBox(height: bodyGap),
          ],
          if (fieldRows)
            CatchDivider(
              color: dividerColor ?? CatchDivider.colorFor(t, dividerVariant),
              variant: dividerVariant,
            ),
          CatchFieldGeometryScope(
            gutterOwnership: CatchFieldGeometryScopeMode.container,
            interactionShape: fieldRows
                ? (dividedFieldInteraction ??
                              CatchDividedFieldInteractionScope.interactionOf(
                                context,
                              )) ==
                          CatchDividedFieldInteractionScopeMode.fullBleed
                      ? CatchFieldGeometryScopeVariant.fullBleedBand
                      : CatchFieldGeometryScopeVariant.roundedTile
                : CatchFieldGeometryScopeVariant.roundedTile,
            child: body,
          ),
        ],
      );
      section = first
          ? content
          : Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.s6),
              child: fieldRows
                  ? content
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                dividerColor ??
                                CatchDivider.colorFor(t, dividerVariant),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: CatchSpacing.s6),
                        child: content,
                      ),
                    ),
            );
    } else {
      final contained = variant == _CatchSectionVariant.contained;
      final hasInternalFieldHeader =
          fieldRows &&
          hasHeader &&
          fieldHeaderPlacement == CatchSectionHeaderPlacement.inside;
      Widget content;
      if (fieldRows) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasInternalFieldHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchFieldTokens.rowHorizontalPadding,
                  CatchFieldTokens.rowVerticalPadding,
                  CatchFieldTokens.rowHorizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CatchSectionHeader.kicker(
                      title: hasTitle ? displayTitle : null,
                      count: hasCount ? displayCount : null,
                      trailing: sectionTrailing,
                      color: titleColor ?? t.ink2,
                      textVariant: CatchKickerTextVariant.fieldSection,
                    ),
                    const SizedBox(height: CatchFieldTokens.sectionRuleGap),
                    const CatchDivider.section(),
                  ],
                ),
              ),
            if (groups != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final group in groups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CatchFieldTokens.rowHorizontalPadding,
                        CatchFieldTokens.rowVerticalPadding,
                        CatchFieldTokens.rowHorizontalPadding,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CatchSectionHeader.kicker(
                            title: group.title.trim(),
                            count: group.count?.toString().trim(),
                            trailing: group.trailing,
                            color: t.ink2,
                            textVariant: CatchKickerTextVariant.fieldSection,
                          ),
                          const SizedBox(
                            height: CatchFieldTokens.sectionRuleGap,
                          ),
                          const CatchDivider.section(),
                        ],
                      ),
                    ),
                    CatchSectionRowList(
                      mode: bodyMode,
                      dividerIndent: dividerIndent,
                      dividerVariant: internalDividerVariant,
                      showInternalDividers: showInternalDividers,
                      children: group.children,
                    ),
                  ],
                ],
              )
            else
              body,
            if (sectionFooter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchFieldTokens.rowHorizontalPadding,
                  CatchFieldTokens.containedSectionFooterTopPadding,
                  CatchFieldTokens.rowHorizontalPadding,
                  CatchFieldTokens.rowVerticalPadding,
                ),
                child: DefaultTextStyle.merge(
                  style: CatchTextStyles.fieldLabel(
                    context,
                    color: t.ink3,
                  ).copyWith(height: 1.5),
                  child: sectionFooter,
                ),
              ),
          ],
        );
      } else {
        final displaySubtitle = subtitle?.trim();
        final hasSubtitle =
            displaySubtitle != null && displaySubtitle.isNotEmpty;
        final header = !hasTitle && !hasSubtitle && sectionTrailing == null
            ? null
            : Row(
                crossAxisAlignment: hasSubtitle
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (hasTitle || hasSubtitle)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasTitle)
                            contained
                                ? Text(
                                    count == null
                                        ? displayTitle
                                        : '$displayTitle · $count',
                                    style: CatchTextStyles.sectionTitle(
                                      context,
                                      color: titleColor ?? t.ink,
                                    ),
                                  )
                                : CatchSectionHeader.kicker(
                                    title: displayTitle,
                                    count: count,
                                    color: titleColor ?? t.ink,
                                  ),
                          if (hasSubtitle) ...[
                            const SizedBox(height: CatchSpacing.s1),
                            Text(
                              displaySubtitle,
                              style: CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                  if (sectionTrailing != null) ...[
                    const SizedBox(width: CatchSpacing.s3),
                    DefaultTextStyle.merge(
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: t.ink,
                      ),
                      child: sectionTrailing,
                    ),
                  ],
                ],
              );
        content = header == null
            ? body
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  SizedBox(height: bodyGap),
                  body,
                ],
              );
      }
      if (!contained) {
        section = Padding(padding: padding ?? EdgeInsets.zero, child: content);
      } else {
        final surface = CatchFieldGeometryScope(
          gutterOwnership: fieldRows
              ? CatchFieldGeometryScopeMode.field
              : CatchFieldGeometryScopeMode.container,
          child: fieldRows
              ? CatchSectionSurface.fieldRows(
                  padding: padding ?? const EdgeInsets.all(CatchSpacing.s4),
                  states: states,
                  child: content,
                )
              : CatchSectionSurface(
                  padding: padding ?? const EdgeInsets.all(CatchSpacing.s4),
                  states: states,
                  child: content,
                ),
        );
        section = !fieldRows || !hasHeader || hasInternalFieldHeader
            ? surface
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CatchFieldTokens.rowHorizontalPadding,
                    ),
                    child: CatchSectionHeader.kicker(
                      title: hasTitle ? displayTitle : null,
                      count: hasCount ? displayCount : null,
                      trailing: sectionTrailing,
                      color: titleColor ?? t.ink2,
                      textVariant: CatchKickerTextVariant.fieldSection,
                    ),
                  ),
                  SizedBox(height: bodyGap),
                  surface,
                ],
              );
      }
    }
    if (sectionFooter == null ||
        (variant == _CatchSectionVariant.contained && fieldRows)) {
      return section;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section,
        if (fieldRows)
          Padding(
            padding: const EdgeInsets.only(
              top: CatchFieldTokens.dividedSectionFooterTopPadding,
            ),
            child: DefaultTextStyle.merge(
              style: CatchTextStyles.fieldLabel(
                context,
                color: t.ink3,
              ).copyWith(height: 1.5),
              child: sectionFooter,
            ),
          )
        else
          sectionFooter,
      ],
    );
  }
}
