import 'package:catch_ui/src/primitives/catch_text_variant.dart';
import 'package:flutter/widgets.dart';

/// Text in one [CatchTextVariant] role.
///
/// The cross-framework text atom: the web `CatchText` takes the same variant,
/// color, line-limit and alignment props. A line limit ends in an ellipsis.
class CatchText extends StatelessWidget {
  const CatchText(
    this.data, {
    super.key,
    required this.variant,
    this.color,
    this.maxLines,
    this.textAlign,
  }) : assert(maxLines == null || maxLines > 0);

  final String data;
  final CatchTextVariant variant;

  /// Overrides the role's default color.
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: variant.style(context, color: color),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}
