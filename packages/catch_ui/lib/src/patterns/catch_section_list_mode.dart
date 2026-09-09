/// Page-level section composition selected by the owning route.
///
/// [centered] keeps one readable lane at every width. [adaptiveTwoColumn]
/// preserves the same compact ordering, then moves complete sections into
/// primary and secondary lanes when the page's local width can support both.
enum CatchSectionListMode { centered, adaptiveTwoColumn }
