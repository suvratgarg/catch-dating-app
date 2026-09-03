import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Routes { aliasRoute, tearOffRoute, wrappedRoute }

typedef GoRouteAlias = GoRoute;
typedef MaterialPageRouteAlias<T> = MaterialPageRoute<T>;

List<GoRoute> aliasRouteCollection() => <GoRoute>[
  GoRouteAlias(
    path: '/alias',
    name: Routes.aliasRoute.name,
    builder: (_, _) => const SizedBox(),
  ),
];

GoRoute goRouteTearOff() {
  final constructor = GoRoute.new;
  return constructor(
    path: '/tear-off',
    name: Routes.tearOffRoute.name,
    builder: (_, _) => const SizedBox(),
  );
}

GoRoute wrappedGoRoute() => _goRouteFactory();

GoRoute _goRouteFactory() => GoRoute(
  path: '/wrapped',
  name: Routes.wrappedRoute.name,
  builder: (_, _) => const SizedBox(),
);

PageRoute<void> materialAliasRoute() =>
    MaterialPageRouteAlias<void>(builder: (_) => const SizedBox());

PageRoute<void> cupertinoRoute() =>
    CupertinoPageRoute<void>(builder: (_) => const SizedBox());

PageRoute<void> pageRouteBuilderRoute() =>
    PageRouteBuilder<void>(pageBuilder: (_, _, _) => const SizedBox());

class CustomPageRoute<T> extends MaterialPageRoute<T> {
  CustomPageRoute({required super.builder});
}

PageRoute<void> customPageRoute() =>
    CustomPageRoute<void>(builder: (_) => const SizedBox());

PageRoute<void> pageRouteTearOff() {
  final constructor = MaterialPageRoute<void>.new;
  return constructor(builder: (_) => const SizedBox());
}

PageRoute<void> wrappedPageRoute() => _pageRouteFactory();

PageRoute<void> _pageRouteFactory() =>
    MaterialPageRoute<void>(builder: (_) => const SizedBox());
