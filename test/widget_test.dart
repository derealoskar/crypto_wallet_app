// Basic smoke test for the crypto wallet app.
//
// Now that AuthGate/AuthProvider sit in front of the app, a plain
// `pumpWidget(const CryptoWalletApp())` would try to reach real Firebase
// (via `FirebaseAuth.instance`) and throw, since tests never call
// `Firebase.initializeApp()`. We use `firebase_auth_mocks` to build a fake,
// already-signed-in `AuthRepository` instead, and assemble the same
// provider tree `CryptoWalletApp` builds internally so the widgets under
// test are exactly what ships.
//
// Run `flutter pub get` first so `firebase_auth_mocks` (a dev dependency)
// is available.

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:crypto_wallet_app/app.dart';
import 'package:crypto_wallet_app/providers/auth_provider.dart';
import 'package:crypto_wallet_app/providers/currency_provider.dart';
import 'package:crypto_wallet_app/providers/notification_provider.dart';
import 'package:crypto_wallet_app/providers/trade_provider.dart';
import 'package:crypto_wallet_app/providers/transaction_provider.dart';
import 'package:crypto_wallet_app/providers/user_provider.dart';
import 'package:crypto_wallet_app/providers/wallet_provider.dart';
import 'package:crypto_wallet_app/screens/auth/auth_gate.dart';
import 'package:crypto_wallet_app/services/auth_repository.dart';
import 'package:crypto_wallet_app/theme/app_theme.dart';

/// Builds the same provider tree as [CryptoWalletApp], but with
/// [AuthProvider] backed by a mock, already-signed-in Firebase user instead
/// of a real Firebase project.
Widget _testApp({required bool signedIn}) {
  final mockUser = MockUser(
    uid: 'test-uid',
    email: 'oscar@example.com',
    displayName: 'Oscar Test',
  );
  final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: signedIn);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(repository: AuthRepository(firebaseAuth: mockAuth)),
      ),
      ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ChangeNotifierProvider(create: (_) => WalletProvider()),
      ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ChangeNotifierProvider(create: (_) => TradeProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(authenticatedChild: RootShell()),
    ),
  );
}

void main() {
  testWidgets('Signed-out user sees the Welcome screen, then Sign In', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp(signedIn: false));
    await tester.pumpAndSettle();

    // AuthGate's unauthenticated state now shows WelcomeScreen first, not
    // the login form directly.
    expect(find.text('NairaChain'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // The "I already have an account" link is the screen's only TextButton.
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Signed-in user lands on the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp(signedIn: true));
    await tester.pumpAndSettle();

    // Home greeting is unique to the Home app bar.
    expect(find.textContaining('Hi, Oscar'), findsOneWidget);

    // All four bottom nav destinations are present.
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
  });

  testWidgets('Tapping the Wallet destination selects it', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp(signedIn: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pumpAndSettle();

    // Selected/unselected icon swap confirms the nav state changed.
    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}
