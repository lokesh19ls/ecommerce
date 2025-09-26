import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ecommerce/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E-Commerce App Integration Tests', () {
    testWidgets('App launches and shows login screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the login screen is displayed
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('User can navigate to registration screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on Sign Up link
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify registration screen is displayed
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign up to get started'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(5)); // All form fields
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('User can login with demo credentials', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter demo credentials
      await tester.enterText(find.byType(TextField).first, 'eve.holt@reqres.in');
      await tester.enterText(find.byType(TextField).last, 'cityslicka');

      // Tap login button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Wait for navigation to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify that we're on the home screen
      expect(find.text('E-Commerce'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('User can browse products', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextField).first, 'eve.holt@reqres.in');
      await tester.enterText(find.byType(TextField).last, 'cityslicka');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify products are loaded
      expect(find.byType(GridView), findsOneWidget);
      
      // Wait for products to load
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Check if product cards are displayed
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('User can toggle theme', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextField).first, 'eve.holt@reqres.in');
      await tester.enterText(find.byType(TextField).last, 'cityslicka');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap theme toggle button
      await tester.tap(find.byIcon(Icons.light_mode));
      await tester.pumpAndSettle();

      // Verify theme changed (dark mode icon should appear)
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('User can logout', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextField).first, 'eve.holt@reqres.in');
      await tester.enterText(find.byType(TextField).last, 'cityslicka');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap profile menu
      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Confirm logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify we're back to login screen
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}
