import 'package:catch_dating_app/events/domain/event_check_in_qr_payload.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum EventCheckInQrScanResult { ignored, invalid, wrongEvent, matched }

EventCheckInQrScanResult classifyEventCheckInQrCode(
  String? rawValue, {
  required String eventId,
}) {
  if (rawValue == null) return EventCheckInQrScanResult.ignored;
  final payload = EventCheckInQrPayload.tryParse(rawValue);
  if (payload == null) return EventCheckInQrScanResult.invalid;
  if (payload.eventId != eventId) return EventCheckInQrScanResult.wrongEvent;
  return EventCheckInQrScanResult.matched;
}

class EventCheckInQrScanner extends StatefulWidget {
  const EventCheckInQrScanner({
    super.key,
    required this.eventId,
    required this.onResult,
  });

  final String eventId;
  final ValueChanged<EventCheckInQrScanResult> onResult;

  @override
  State<EventCheckInQrScanner> createState() => _EventCheckInQrScannerState();
}

class _EventCheckInQrScannerState extends State<EventCheckInQrScanner> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _matched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(controller: _controller, onDetect: _handleCapture);
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_matched) return;
    for (final barcode in capture.barcodes) {
      final result = classifyEventCheckInQrCode(
        barcode.rawValue,
        eventId: widget.eventId,
      );
      if (result == EventCheckInQrScanResult.ignored) continue;
      if (result == EventCheckInQrScanResult.matched) {
        _matched = true;
      }
      widget.onResult(result);
      if (_matched) return;
    }
  }
}
