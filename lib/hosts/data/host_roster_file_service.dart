import 'dart:typed_data';

import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_roster_file_service.g.dart';

class PickedHostRosterFile {
  const PickedHostRosterFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

abstract interface class HostRosterFileService {
  Future<PickedHostRosterFile?> pickRosterFile();
}

class PluginHostRosterFileService implements HostRosterFileService {
  const PluginHostRosterFileService();

  @override
  Future<PickedHostRosterFile?> pickRosterFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx'],
      withData: true,
    );
    if (result == null) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      throw const HostRosterImportException(
        HostRosterImportIssue.unreadableXlsx,
      );
    }
    return PickedHostRosterFile(name: file.name, bytes: bytes);
  }
}

// keepalive: Host workflows share one process-wide file-picker boundary.
@Riverpod(keepAlive: true)
HostRosterFileService hostRosterFileService(Ref ref) =>
    const PluginHostRosterFileService();
