import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/crypto_ticker_banner.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/trade_hero_banner.dart';
import '../airtime/airtime_screen.dart';
import '../convert/convert_screen.dart';
import '../data/data_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/generic_info_screen.dart';
import '../rates/rates_screen.dart';
import '../support/live_chat_screen.dart';
import '../swap/swap_screen.dart';
import '../trade/trade_screen.dart';
import '../wallet/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // A single, subtle fade + rise on first load — the kind of small
    // polish that makes a screen feel considered rather than instant/flat.
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final user = context.watch<UserProvider>().user;
    final firstName = user.fullName.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      appBar: MainAppBar(
        greeting: firstName,
        onNotificationsTap: () => _push(context, const NotificationsScreen()),
        onAvatarTap: () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.personalInfo)),
        actions: [
          IconButton(
            tooltip: 'Rates',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => _push(context, const RatesScreen()),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: [
                BalanceCard(
                  balanceNgn: wallet.totalBalanceNgn,
                  hidden: wallet.balanceHidden,
                  portfolioChangePercent: 3.24,
                  onToggleVisibility: wallet.toggleBalanceVisibility,
                  onWalletTap: () => _push(context, const WalletScreen()),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Buy & Sell Crypto',
                  actionLabel: 'All rates',
                  onActionTap: () => _push(context, const RatesScreen()),
                ),
                const SizedBox(height: 4),
                TradeHeroBanner(
                  symbol: 'USDT',
                  onTap: (side) => _push(
                    context,
                    TradeScreen(initialSide: side, initialAsset: 'USDT'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 4),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        QuickActionButton(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Swap',
                          color: AppColors.info,
                          onTap: () => _push(context, const SwapScreen()),
                        ),
                        QuickActionButton(
                          icon: Icons.currency_exchange_rounded,
                          label: 'Convert',
                          color: AppColors.primary,
                          onTap: () => _push(context, const ConvertScreen()),
                        ),
                        QuickActionButton(
                          icon: Icons.phone_iphone_rounded,
                          label: 'Airtime',
                          color: AppColors.warning,
                          onTap: () => _push(context, const AirtimeScreen()),
                        ),
                        QuickActionButton(
                          icon: Icons.wifi_rounded,
                          label: 'Data',
                          color: AppColors.sol,
                          onTap: () => _push(context, const DataScreen()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Market Pulse',
                  actionLabel: 'View rates',
                  onActionTap: () => _push(context, const RatesScreen()),
                ),
                const SizedBox(height: 4),
                CryptoTickerBanner(assets: wallet.assets),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _push(context, const LiveChatScreen()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
        label: const Text('Live Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
