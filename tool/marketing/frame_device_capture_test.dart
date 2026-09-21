import 'dart:io';

import 'package:image/image.dart' as img;

import 'frame_device_capture.dart' as frame;

void main() {
  final directory = Directory.systemTemp.createTempSync('catch-device-frame-');
  try {
    final input = File('${directory.path}/native.png');
    final output = File('${directory.path}/framed.png');
    final screenshot = img.Image(width: 804, height: 1748, numChannels: 4);
    // Adjacent pixels distinguish native copy from resampling or interpolation.
    screenshot.setPixelRgba(200, 300, 255, 0, 0, 255);
    screenshot.setPixelRgba(201, 300, 0, 0, 255, 255);
    input.writeAsBytesSync(img.encodePng(screenshot));
    frame.main(['--input', input.path, '--output', output.path]);
    if (exitCode != 0 || !output.existsSync()) {
      throw StateError('Native 2x screenshot must frame successfully.');
    }
    final framed = img.decodePng(output.readAsBytesSync())!;
    if (framed.width != 1020 || framed.height != 1964) {
      throw StateError('Framed product image dimensions changed.');
    }
    // 2x frame margin32 + inset22 =108px from canvas to screen.
    final red = framed.getPixel(308, 408);
    final blue = framed.getPixel(309, 408);
    if (red.r != 255 || red.b != 0 || blue.r != 0 || blue.b != 255) {
      throw StateError('Native source pixels were resampled.');
    }
    output.deleteSync();
    input.writeAsBytesSync(img.encodePng(img.Image(width: 402, height: 874)));
    frame.main(['--input', input.path, '--output', output.path]);
    if (exitCode != 65 || output.existsSync()) {
      throw StateError('Undersampled inputs must fail before writing output.');
    }
    exitCode = 0;
    stdout.writeln(
      'Native framing dimensions, pixel preservation, and rejection passed.',
    );
  } finally {
    directory.deleteSync(recursive: true);
  }
}
