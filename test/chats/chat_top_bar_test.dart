import 'package:catch_dating_app/chats/presentation/widgets/chat_top_bar.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('opens profile from the chat identity title', (tester) async {
    final router = _buildRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pump();

    await tester.tap(find.text('Taylor'));
    await tester.pumpAndSettle();

    expect(find.text('Profile runner-2'), findsOneWidget);
  });

  testWidgets('keeps profile out of the overflow menu', (tester) async {
    final router = _buildRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Chat actions'));
    await tester.pumpAndSettle();

    expect(find.text('View profile'), findsNothing);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Block'), findsOneWidget);
  });
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          appBar: ChatTopBar(
            name: 'Taylor',
            photoUrl: null,
            otherUid: 'runner-2',
            profile: _profile,
            onReport: () {},
            onBlock: () {},
          ),
        ),
      ),
      GoRoute(
        path: '/profiles/:uid',
        name: Routes.publicProfileScreen.name,
        builder: (_, state) => Text('Profile ${state.pathParameters['uid']!}'),
      ),
    ],
  );
}

final _profile = PublicProfile(
  uid: 'runner-2',
  name: 'Taylor',
  age: 29,
  bio: 'Runner',
  gender: Gender.woman,
  city: IndianCity.mumbai,
);
