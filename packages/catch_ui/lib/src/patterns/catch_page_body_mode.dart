/// Semantic body geometry for root and nested-tab screen scroll owners.
///
/// The screen family, rather than a feature, resolves these roles to concrete
/// insets. [standard] is the one normal title/tab-to-content rhythm and
/// [fullBleed] is reserved for intrinsically edge-owned slivers such as maps,
/// media previews, and conversation canvases.
enum CatchPageBodyMode { standard, fullBleed }
