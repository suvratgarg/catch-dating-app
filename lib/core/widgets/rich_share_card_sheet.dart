import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

abstract final class RichShareCardSheetKeys {
  static const cardPreview = ValueKey('rich_share_card_sheet.card_preview');
  static const shareButton = ValueKey('rich_share_card_sheet.share_button');
}

class RichShareCardSheet extends StatefulWidget {
  const RichShareCardSheet({
    super.key,
    required this.card,
    required this.share,
    required this.fileName,
    required this.buttonLabel,
    required this.footnote,
    this.subject,
    this.text,
    this.maxWidth = CatchLayout.richShareCardWidth,
    this.pixelRatio = CatchLayout.richShareCardPixelRatio,
  });

  final Widget card;
  final ExternalShareController share;
  final String fileName;
  final String buttonLabel;
  final String footnote;
  final String? subject;
  final String? text;
  final double maxWidth;
  final double pixelRatio;

  @override
  State<RichShareCardSheet> createState() => _RichShareCardSheetState();
}

class _RichShareCardSheetState extends State<RichShareCardSheet> {
  final _captureKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share(BuildContext buttonContext) async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      final box = buttonContext.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      if (!mounted) return;

      final bytes = await _captureCardPng(
        key: _captureKey,
        pixelRatio: widget.pixelRatio,
      );
      await widget.share.sharePngFile(
        pngBytes: bytes,
        fileName: widget.fileName,
        subject: widget.subject,
        text: widget.text,
        origin: origin,
      );
    } catch (error) {
      if (!mounted) return;
      showCatchErrorSnackBar(
        context,
        ExternalActionException('Unable to share this card.', cause: error),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: CatchSpacing.s4,
          right: CatchSpacing.s4,
          top: CatchSpacing.s4,
          bottom: MediaQuery.viewInsetsOf(context).bottom + CatchSpacing.s4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetGrabber(),
            gapH16,
            RepaintBoundary(
              key: _captureKey,
              child: ConstrainedBox(
                key: RichShareCardSheetKeys.cardPreview,
                constraints: BoxConstraints(maxWidth: widget.maxWidth),
                child: widget.card,
              ),
            ),
            gapH12,
            Text(
              widget.footnote,
              textAlign: TextAlign.center,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH16,
            Builder(
              builder: (buttonContext) => CatchButton(
                key: RichShareCardSheetKeys.shareButton,
                label: widget.buttonLabel,
                fullWidth: true,
                isLoading: _sharing,
                icon: Icon(
                  CatchIcons.platformShare(
                    platform: Theme.of(context).platform,
                  ),
                ),
                onPressed: () => unawaited(_share(buttonContext)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Uint8List> _captureCardPng({
  required GlobalKey key,
  required double pixelRatio,
}) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  final image = await boundary?.toImage(pixelRatio: pixelRatio);
  final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
  image?.dispose();
  final bytes = byteData?.buffer.asUint8List();
  if (bytes == null) {
    throw StateError('Share card did not render.');
  }
  return bytes;
}
