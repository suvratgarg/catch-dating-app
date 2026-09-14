/// Resolved interaction silhouette published by CatchFieldGeometryScope.
///
/// [roundedTile] gives a field its own corners; [sectionClipped] inherits the
/// containing section's single clip; [fullBleedBand] reaches the page/lane plane.
/// Section policy cannot request [sectionClipped]: only a contained section can
/// establish that perimeter for its descendants.
enum CatchFieldGeometryScopeVariant {
  roundedTile,
  sectionClipped,
  fullBleedBand,
}
