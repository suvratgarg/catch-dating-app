import 'package:catch_dating_app/hosts/domain/forms/form_operation_fields.dart';
import 'package:meta/meta.dart';

enum HostFormExportFormat { csv, xlsx }

enum HostFormExportStatus { pending, running, completed, failed, expired }

@immutable
class HostFormExportReceipt {
  const HostFormExportReceipt({
    required this.exportId,
    required this.status,
    required this.format,
    required this.rowCount,
    required this.downloadUrl,
    required this.expiresAt,
    required this.errorMessage,
  });

  factory HostFormExportReceipt.fromCallableData(Object? data) {
    final map = formOperationRequiredMap(data, 'form export');
    return HostFormExportReceipt(
      exportId: formOperationRequiredString(map, 'exportId'),
      status: formOperationEnumByName(
        HostFormExportStatus.values,
        formOperationRequiredString(map, 'status'),
      ),
      format: formOperationEnumByName(
        HostFormExportFormat.values,
        formOperationRequiredString(map, 'format'),
      ),
      rowCount: formOperationRequiredInt(map, 'rowCount'),
      downloadUrl: formOperationNullableString(map['downloadUrl']),
      expiresAt: formOperationDateTime(map, 'expiresAtMillis'),
      errorMessage: formOperationNullableString(map['errorMessage']),
    );
  }

  final String exportId;
  final HostFormExportStatus status;
  final HostFormExportFormat format;
  final int rowCount;
  final String? downloadUrl;
  final DateTime expiresAt;
  final String? errorMessage;
}
