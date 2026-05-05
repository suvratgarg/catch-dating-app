import 'package:catch_dating_app/core/external_share.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test(
    'shareText forwards text, subject, and origin to share launcher',
    () async {
      ShareParams? sharedParams;
      final controller = ExternalShareController((params) async {
        sharedParams = params;
      });

      await controller.shareText(text: 'Hello', subject: 'Subject');

      expect(sharedParams?.text, 'Hello');
      expect(sharedParams?.subject, 'Subject');
    },
  );
}
