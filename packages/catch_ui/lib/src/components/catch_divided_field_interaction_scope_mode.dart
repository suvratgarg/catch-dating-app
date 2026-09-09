/// Section-level interaction mode published by CatchDividedFieldInteractionScope.
///
/// A page supplies its responsive default. One complete divided section may
/// override it; an individual field cannot choose its own interaction policy.
/// The geometry scope resolves this policy into the field's paint silhouette.
enum CatchDividedFieldInteractionScopeMode { fullBleed, roundedTile }
