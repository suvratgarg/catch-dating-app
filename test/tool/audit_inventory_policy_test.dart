import 'package:test/test.dart';

// Tool tests intentionally exercise the repository utility outside lib/.
// ignore: avoid_relative_lib_imports
import '../../tool/lib/audit_inventory_policy.dart';

void main() {
  test('aggregate audit policies match only their owned subtree', () {
    const manifest = <String, dynamic>{
      'auditPolicies': <Map<String, dynamic>>[
        <String, dynamic>{
          'pattern': 'design/visual_baselines/**',
          'review': 'aggregate',
          'kind': 'generated_evidence',
          'owner': 'design_system',
        },
      ],
    };

    expect(
      auditPolicyFor('design/visual_baselines/host/a.png', manifest),
      containsPair('review', 'aggregate'),
    );
    expect(
      auditPolicyFor('design/components/catch.components.json', manifest),
      isNull,
    );
  });

  test('platform aggregation stays narrow enough to expose live config', () {
    const manifest = <String, dynamic>{
      'auditPolicies': <Map<String, dynamic>>[
        <String, dynamic>{
          'pattern': 'android/app/src/*/res/**',
          'review': 'aggregate',
        },
      ],
    };

    expect(
      auditPolicyFor('android/app/src/main/res/drawable/splash.png', manifest),
      isNotNull,
    );
    expect(
      auditPolicyFor('android/app/src/main/AndroidManifest.xml', manifest),
      isNull,
    );
    expect(auditPolicyFor('android/app/build.gradle.kts', manifest), isNull);
  });
}
