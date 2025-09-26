import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:closer_acireale_flutter/main.dart';
import 'package:closer_acireale_flutter/core/providers/auth_provider.dart';
import 'package:closer_acireale_flutter/core/providers/user_provider.dart';

void main() {
  group('CloserAcirealeApp Widget Tests', () {
    testWidgets('App should build without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: const CloserAcirealeApp(),
        ),
      );

      // Verify that our app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login screen should be displayed initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: const CloserAcirealeApp(),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify login elements are present
      expect(find.text('Accedi'), findsOneWidget);
      expect(find.text('Sistema Gestione Closer Acireale'), findsOneWidget);
    });

    testWidgets('Login form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: const CloserAcirealeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Accedi');
      expect(loginButton, findsOneWidget);

      // Tap the login button without filling the form
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation messages appear
      expect(find.text('Inserisci la tua email'), findsOneWidget);
      expect(find.text('Inserisci la password'), findsOneWidget);
    });

    testWidgets('Email field accepts valid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: const CloserAcirealeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find email field and enter invalid email
      final emailField = find.widgetWithText(TextFormField, 'Inserisci Email');
      await tester.enterText(emailField, 'invalid-email');

      // Tap login button to trigger validation
      final loginButton = find.widgetWithText(ElevatedButton, 'Accedi');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation message for invalid email
      expect(find.text('Inserisci un\'email valida'), findsOneWidget);
    });
  });

  group('Theme Tests', () {
    testWidgets('App uses correct primary colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: const CloserAcirealeApp(),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      
      // Check primary color
      expect(app.theme?.colorScheme.primary, const Color(0xFF1E3A8A));
    });
  });
}