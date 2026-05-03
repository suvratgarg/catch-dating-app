import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';

class PhotoSlot extends StatelessWidget {
  const PhotoSlot({
    super.key,
    required this.url,
    required this.isLoading,
    required this.isActive,
    required this.onTap,
  });

  final String? url;
  final bool isLoading;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final Widget content;
    if (url != null) {
      content = Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (isActive) {
      content = Container(
        color: t.primarySoft,
        child: Center(
          child: Icon(Icons.add_rounded, size: 36, color: t.primary),
        ),
      );
    } else {
      content = Container(color: t.raised);
    }

    return GestureDetector(
      onTap: isActive && !isLoading ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            if (isLoading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CatchLoadingIndicator(color: Colors.white),
                ),
              ),
            if (!isLoading && url != null)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: t.surface.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_outlined, size: 14, color: t.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
