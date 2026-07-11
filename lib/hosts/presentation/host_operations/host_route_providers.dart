part of '../host_operations_screen.dart';

final _hostClubsForUserProvider = Provider.autoDispose
    .family<AsyncValue<List<Club>>, String>(
      (ref, uid) => ref.watch(hostOperableClubsProvider(uid)),
    );
