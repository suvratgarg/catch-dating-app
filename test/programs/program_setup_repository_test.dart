import 'package:catch_dating_app/programs/data/program_setup_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('staff list requires explicit continuation metadata', () {
    expect(
      () => ProgramStaffList.fromCallableData({
        'programId': 'program',
        'members': [],
      }),
      throwsFormatException,
    );
  });

  test('staff listing serializes its cursor and reads the next one', () async {
    final functions = _Functions()
      ..response = {
        'programId': 'program',
        'members': [],
        'nextCursor': 'next-staff',
      };
    final repository = ProgramSetupRepository(functions);
    final page = await repository.listStaff('program', cursor: 'prior-staff');
    expect(functions.calls, ['listProgramStaff']);
    expect(functions.payload, {
      'programId': 'program',
      'cursor': 'prior-staff',
    });
    expect(page.nextCursor, 'next-staff');
  });

  for (final grant in [true, false]) {
    test(
      '${grant ? "grant" : "revoke"} accepts the committed mutation receipt',
      () async {
        final functions = _Functions()
          ..response = {
            'entityId': 'staff',
            'revision': 8,
            'alreadyApplied': false,
          };
        final repository = ProgramSetupRepository(functions);
        final expiry = DateTime(2030);
        final receipt = grant
            ? await repository.grantStaff(
                programId: 'program',
                phoneNumber: '+919900001111',
                duties: const [
                  ProgramDutyAssignment(
                    duty: ProgramStaffDuty.hotelDesk,
                    pickupPointIds: {},
                    hotelIds: {'hotel'},
                    functionIds: {},
                  ),
                ],
                expiresAt: expiry,
              )
            : await repository.revokeStaff(
                programId: 'program',
                member: ProgramStaffMember(
                  uid: 'staff',
                  displayName: 'Staff',
                  phoneLastFour: '1111',
                  duties: const [],
                  status: ProgramStaffStatus.active,
                  expiresAt: expiry,
                  revision: 7,
                ),
              );
        expect(receipt.entityId, 'staff');
        expect(receipt.revision, 8);
        expect(receipt.alreadyApplied, isFalse);
        expect(functions.calls, [
          grant ? 'grantProgramStaff' : 'revokeProgramStaff',
        ]);
        if (!grant) {
          expect(functions.payload, {
            'programId': 'program',
            'uid': 'staff',
            'expectedRevision': 7,
          });
        }
      },
    );
  }
}

class _Functions extends Fake implements FirebaseFunctions {
  Object? response;
  Object? payload;
  final calls = <String>[];
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    calls.add(name);
    return _Callable((value) {
      payload = value;
      return response;
    });
  }
}

class _Callable extends Fake implements HttpsCallable {
  _Callable(this.respond);
  final Object? Function(Object?) respond;
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async =>
      _Result(respond(parameters) as T);
}

class _Result<T> extends Fake implements HttpsCallableResult<T> {
  _Result(this.data);
  @override
  final T data;
}
