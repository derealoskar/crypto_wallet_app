import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/trade_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'theme/app_theme.dart';

class CryptoWalletApp extends StatelessWidget {
  const CryptoWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => TradeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'NairaChain',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(authenticatedChild: RootShell()),
      ),
    );
  }
}

/// Hosts the persistent bottom NavigationBar with the four main sections:
/// Home, Wallet, Transactions, Profile. Only ever built once someone is
/// signed in — see [AuthGate] in `screens/auth/auth_gate.dart`.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  late final List<Widget> _tabs = [
    const HomeScreen(),
    const WalletScreen(embedded: true),
    const TransactionsScreen(embedded: true),
    const ProfileScreen(embedded: true),
  ];

  static const _titles = ['Home', 'Wallet', 'Transactions', 'Profile'];

  @override
  void initState() {
    super.initState();
    // Pull the real display name/email from the just-authenticated Firebase
    // user into the (still mostly mock) profile, so Home/Profile reflect
    // the actual signed-in account instead of the hardcoded "Oscar" seed.
    final firebaseUser = context.read<AuthProvider>().user;
    if (firebaseUser != null) {
      context.read<UserProvider>().syncFromFirebaseUser(
            fullName: firebaseUser.displayName,
            email: firebaseUser.email,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Home renders its own AppBar (with greeting); other tabs share one
    // MainAppBar with a plain title, wired up here so the bottom nav
    // persists across all four sections without rebuilding each Scaffold.
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _tabs[0],
          _ScaffoldedTab(title: _titles[1], child: _tabs[1]),
          _ScaffoldedTab(title: _titles[2], child: _tabs[2]),
          _ScaffoldedTab(title: _titles[3], child: _tabs[3]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ScaffoldedTab extends StatelessWidget {
  final String title;
  final Widget child;
  const _ScaffoldedTab({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}
