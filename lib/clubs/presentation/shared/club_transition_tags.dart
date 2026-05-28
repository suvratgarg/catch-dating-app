import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:flutter/widgets.dart';

String clubInteractionHeroTag(String clubId) => 'club-interaction-$clubId';

/// Shared inset for the club tile media frame and the detail-page hero module.
///
/// The tile should feel like it expands into the detail page, so this spacing
/// must stay aligned across both surfaces.
const double clubInteractionMediaInset = CatchSpacing.s3;
const EdgeInsets clubInteractionMediaPadding = EdgeInsets.all(
  clubInteractionMediaInset,
);
