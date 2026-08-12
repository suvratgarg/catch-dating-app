import 'package:catch_dating_app/hosts/data/host_event_staff_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hostEventStaffControllerProvider = Provider<HostEventStaffController>(
  HostEventStaffController.new,
);

class HostEventStaffController {
  const HostEventStaffController(this._ref);

  final Ref _ref;

  Future<HostEventStaffList> list(String eventId) =>
      _ref.read(hostEventStaffRepositoryProvider).listStaff(eventId);

  Future<HostEventStaffList> grant({
    required String eventId,
    required String phoneNumber,
    required HostEventStaffGrantWindow window,
  }) => _ref
      .read(hostEventStaffRepositoryProvider)
      .grant(
        eventId: eventId,
        phoneNumber: phoneNumber,
        expiresAt: window.expiresFrom(DateTime.now()),
      );

  Future<HostEventStaffList> revoke({
    required String eventId,
    required HostEventStaffMember member,
  }) => _ref
      .read(hostEventStaffRepositoryProvider)
      .revoke(eventId: eventId, member: member);
}
