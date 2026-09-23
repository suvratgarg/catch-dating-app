part of 'go_router.dart';

HostResponseReviewQueue? _responseReviewQueue(Object? extra) =>
    extra is HostResponseReviewQueue ? extra : null;

GoRoute _hostApplicationReviewRoute(_RouterNavigatorKeys keys) => GoRoute(
  path: 'applications/:applicationId',
  name: Routes.hostApplicationDetailScreen.name,
  parentNavigatorKey: keys.root,
  builder: (context, state) => HostApplicationDetailScreen(
    organizerId: state.uri.queryParameters['organizerId'] ?? '',
    applicationId: state.pathParameters['applicationId']!,
    queue: _responseReviewQueue(state.extra),
  ),
);

GoRoute _hostFormResponseReviewRoute(_RouterNavigatorKeys keys) => GoRoute(
  path: 'responses/:responseId',
  name: Routes.hostFormResponseDetailScreen.name,
  parentNavigatorKey: keys.root,
  builder: (context, state) => HostFormResponseDetailScreen(
    organizerId: state.uri.queryParameters['organizerId'] ?? '',
    responseId: state.pathParameters['responseId']!,
    queue: _responseReviewQueue(state.extra),
  ),
);
