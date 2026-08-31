/// Catch's reviewed, export-ready UI-system surface.
///
/// Application code inside this repository may still import focused source
/// files. External consumers and new shared packages should start here: the
/// barrel exposes semantic composition and field capabilities, never paint
/// scopes, perimeter renderers, or responsive implementation details.
library;

export 'core/forms/catch_form_descriptors.dart'
    show
        CatchFormCustomRow,
        CatchFormErrorText,
        CatchFormMultiChoiceRow,
        CatchFormRangeRow,
        CatchFormReadRow,
        CatchFormRowDescriptor,
        CatchFormRowList,
        CatchFormRowScope,
        CatchFormSave,
        CatchFormSingleChoiceRow,
        CatchFormTextCommitMode,
        CatchFormTextRow;
export 'core/theme/catch_tokens.dart'
    show
        CatchAspectRatio,
        CatchFieldTokens,
        CatchGaps,
        CatchInsets,
        CatchLayout,
        CatchMotion,
        CatchOpacity,
        CatchRadius,
        CatchSpacing,
        CatchStroke,
        CatchTokens;
export 'core/widgets/catch_field.dart'
    show
        CatchContractConstraints,
        CatchContractFieldConstraints,
        CatchDividedFieldInteraction,
        CatchField,
        CatchFieldChoiceControl,
        CatchFieldContentRow,
        CatchFieldEmphasis,
        CatchFieldLanes,
        CatchFieldSize,
        CatchFieldStatus,
        CatchFieldSupportTone,
        CatchFieldTone,
        CatchFieldVariant,
        CatchFieldVisibilityScope,
        CatchResponsiveFieldInteractionPolicy;
export 'core/widgets/catch_field_accordion.dart' show CatchFieldAccordion;
export 'core/widgets/catch_form_step_flow.dart'
    show
        CatchFormReviewState,
        CatchFormStepReviewItem,
        CatchFormStepSpec,
        CatchFormStepStatus;
export 'core/widgets/catch_master_detail_layout.dart'
    show CatchAdaptiveMasterDetailLayout, CatchMasterDetailLayout;
export 'core/widgets/catch_section_layout.dart'
    show
        CatchDetailSliverSectionList,
        CatchDivider,
        CatchDividerRole,
        CatchFormStepBody,
        CatchPageBody,
        CatchResponsiveSectionComposition,
        CatchResponsiveSectionItem,
        CatchResponsiveSectionLane,
        CatchResponsiveSectionLayout,
        CatchResponsiveSectionPage,
        CatchScreenBody,
        CatchScrollTerminalPadding,
        CatchSection,
        CatchSectionHeaderPlacement,
        CatchSectionList,
        CatchSectionStack,
        CatchSliverPageBody,
        CatchSliverTerminalPadding;
