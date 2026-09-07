/// Owner of the external corners around field interaction chrome.
///
/// [CatchFieldInteractionShape.roundedTile] means the field paints its own complete rounded silhouette.
/// [CatchFieldInteractionShape.sectionClipped] means an ancestor section owns one rounded clip for the
/// complete group, so each descendant paints a rectangular internal band.
/// [CatchFieldInteractionShape.fullBleedBand] means a divided section paints one rectangular band to the
/// nearest page- or lane-owned interaction plane.
enum CatchFieldInteractionShape { roundedTile, sectionClipped, fullBleedBand }
