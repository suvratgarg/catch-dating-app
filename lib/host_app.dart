import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/widgets.dart';

class HostApp extends StatelessWidget {
  const HostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MyApp(routerProvider: hostGoRouterProvider);
  }
}
