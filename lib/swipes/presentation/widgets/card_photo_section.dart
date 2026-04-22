import 'package:flutter/material.dart';

class CardPhotoSection extends StatelessWidget {
  const CardPhotoSection({
    super.key,
    required this.url,
    required this.height,
    this.overlayChild,
  });

  final String? url;
  final double height;
  final Widget? overlayChild;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null)
            Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFF2A2A2A)),
            )
          else
            const ColoredBox(color: Color(0xFF2A2A2A)),

          if (overlayChild != null) ...[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1.0],
                  colors: [Colors.transparent, Color(0xD8000000)],
                ),
              ),
            ),
            Positioned(left: 20, right: 20, bottom: 28, child: overlayChild!),
          ],
        ],
      ),
    );
  }
}
