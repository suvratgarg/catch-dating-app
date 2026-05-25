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

  test('shareCsvFile forwards a named csv file to share launcher', () async {
    ShareParams? sharedParams;
    final controller = ExternalShareController((params) async {
      sharedParams = params;
    });

    await controller.shareCsvFile(
      csv: 'name,amount\nAsha,400\n',
      fileName: 'revenue.csv',
      subject: 'Revenue',
    );

    expect(sharedParams?.subject, 'Revenue');
    expect(sharedParams?.fileNameOverrides, ['revenue.csv']);
    expect(sharedParams?.files, hasLength(1));
    expect(
      await sharedParams!.files!.single.readAsString(),
      'name,amount\nAsha,400\n',
    );
  });
}
