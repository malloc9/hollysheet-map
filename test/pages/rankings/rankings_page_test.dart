import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:holysheet_map/pages/rankings/rankings_page.dart';
import 'package:holysheet_map/providers/user_provider.dart';
import 'package:holysheet_map/services/firestore_service.dart';

void main() {
  group('RankingsPage', () {
    testWidgets('shows AppBar with title and back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserProvider(FirestoreService()),
            child: const RankingsPage(),
          ),
        ),
      );

      expect(find.text('Nationality Rankings'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows empty state message when no users loaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserProvider(FirestoreService()),
            child: const RankingsPage(),
          ),
        ),
      );

      // approvedUsers defaults to empty list before loadApprovedUsers is called
      expect(find.text('No users to display yet.'), findsOneWidget);
    });

    testWidgets('back button navigates to /map', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/rankings',
        routes: [
          GoRoute(
            path: '/rankings',
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => UserProvider(FirestoreService()),
              child: const RankingsPage(),
            ),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const Scaffold(body: Center(child: Text('MapPage'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Nationality Rankings'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('MapPage'), findsOneWidget);
    });
  });
}
