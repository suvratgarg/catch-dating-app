import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> appConnectivity(Ref ref) =>
    Connectivity().onConnectivityChanged;

@Riverpod(keepAlive: true)
bool isObviouslyOffline(Ref ref) {
  final results = ref.watch(appConnectivityProvider).asData?.value;
  return results != null && connectivityResultsAreOffline(results);
}

bool connectivityResultsAreOffline(List<ConnectivityResult> results) {
  return results.isEmpty ||
      results.every((result) => result == ConnectivityResult.none);
}

NetworkException obviousOfflineException({BackendErrorContext? context}) {
  return NetworkException(
    'offline',
    'No internet connection. Connect to the internet and try again.',
    context: context,
  );
}
