import '../models/app_models.dart';
import '../models/crypto_asset.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';

/// Central source of realistic mock data so the UI is fully usable before
/// the Firebase-backed repositories (see services/*_repository.dart) are
/// connected. Replace each method body with a live data call when ready —
/// the return types are the app's real models, so screens won't need to change.
class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  final AppUser currentUser = const AppUser(
    id: 'u_001',
    fullName: 'Oscar Eguavoen',
    username: '@oscar',
    email: 'oscar@example.com',
    avatarInitials: 'OE',
    kycStatus: KycStatus.pending,
  );

  /// `buyRateNgn` / `sellRateNgn` are the platform's own quoted rates (what
  /// you charge to sell an asset to a user, and what you pay to buy it
  /// from them) — set here by you, not pulled from a live market feed.
  /// `priceNgn` is kept as a separate reference market price, shown in the
  /// market list and used for wallet valuation.
  List<CryptoAsset> get assets => [
        const CryptoAsset(
          id: 'btc',
          symbol: 'BTC',
          name: 'Bitcoin',
          priceNgn: 98450000,
          change24h: 2.34,
          balance: 0.0142,
          accentColor: AppColors.btc,
          buyRateNgn: 99200000,
          sellRateNgn: 97600000,
          sparkline: [40, 42, 41, 45, 47, 44, 49, 52, 50, 55],
        ),
        const CryptoAsset(
          id: 'eth',
          symbol: 'ETH',
          name: 'Ethereum',
          priceNgn: 5320000,
          change24h: -1.12,
          balance: 0.86,
          accentColor: AppColors.eth,
          buyRateNgn: 5365000,
          sellRateNgn: 5270000,
          sparkline: [50, 48, 49, 47, 45, 46, 44, 43, 44, 42],
        ),
        const CryptoAsset(
          id: 'usdt',
          symbol: 'USDT',
          name: 'Tether',
          priceNgn: 1552,
          change24h: 0.02,
          balance: 420.35,
          accentColor: AppColors.usdt,
          buyRateNgn: 1550,
          sellRateNgn: 1540,
          sparkline: [50, 50, 51, 50, 50, 49, 50, 51, 50, 50],
        ),
        const CryptoAsset(
          id: 'usdc',
          symbol: 'USDC',
          name: 'USD Coin',
          priceNgn: 1550,
          change24h: 0.01,
          balance: 0,
          accentColor: AppColors.usdc,
          buyRateNgn: 1548,
          sellRateNgn: 1538,
          sparkline: [50, 50, 50, 49, 50, 50, 51, 50, 50, 50],
        ),
        const CryptoAsset(
          id: 'sol',
          symbol: 'SOL',
          name: 'Solana',
          priceNgn: 224000,
          change24h: 5.67,
          balance: 3.2,
          accentColor: AppColors.sol,
          buyRateNgn: 226500,
          sellRateNgn: 221000,
          sparkline: [30, 33, 32, 36, 38, 41, 40, 44, 47, 49],
        ),
        const CryptoAsset(
          id: 'bnb',
          symbol: 'BNB',
          name: 'BNB',
          priceNgn: 950000,
          change24h: -0.45,
          balance: 0,
          accentColor: AppColors.bnb,
          buyRateNgn: 959000,
          sellRateNgn: 941000,
          sparkline: [45, 46, 44, 45, 43, 44, 42, 43, 41, 42],
        ),
      ];

  double get totalBalanceNgn =>
      assets.fold(0.0, (sum, a) => sum + a.valueNgn);

  List<TransactionModel> get transactions => [
        TransactionModel(
          id: 't1',
          type: TransactionType.buy,
          assetSymbol: 'USDT',
          amount: 100,
          fiatAmountNgn: 155000,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          status: TransactionStatus.completed,
        ),
        TransactionModel(
          id: 't2',
          type: TransactionType.withdrawal,
          assetSymbol: 'BTC',
          amount: 0.002,
          fiatAmountNgn: 196900,
          date: DateTime.now().subtract(const Duration(hours: 6)),
          status: TransactionStatus.pending,
        ),
        TransactionModel(
          id: 't3',
          type: TransactionType.airtime,
          assetSymbol: 'NGN',
          amount: 1000,
          fiatAmountNgn: 1000,
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: TransactionStatus.completed,
          note: 'MTN · 0803 456 7890',
        ),
        TransactionModel(
          id: 't4',
          type: TransactionType.swap,
          assetSymbol: 'ETH',
          amount: 0.05,
          fiatAmountNgn: 266000,
          date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          status: TransactionStatus.completed,
        ),
        TransactionModel(
          id: 't5',
          type: TransactionType.sell,
          assetSymbol: 'SOL',
          amount: 1.5,
          fiatAmountNgn: 336000,
          date: DateTime.now().subtract(const Duration(days: 2)),
          status: TransactionStatus.failed,
        ),
        TransactionModel(
          id: 't6',
          type: TransactionType.data,
          assetSymbol: 'NGN',
          amount: 2000,
          fiatAmountNgn: 2000,
          date: DateTime.now().subtract(const Duration(days: 3)),
          status: TransactionStatus.completed,
          note: 'Glo · 2GB · 0805 234 1111',
        ),
        TransactionModel(
          id: 't7',
          type: TransactionType.deposit,
          assetSymbol: 'USDT',
          amount: 250,
          fiatAmountNgn: 387500,
          date: DateTime.now().subtract(const Duration(days: 4)),
          status: TransactionStatus.cancelled,
        ),
      ];

  List<AppNotification> get notifications => [
        AppNotification(
          id: 'n1',
          title: 'Purchase completed',
          body: 'Your USDT purchase of 100 USDT was completed.',
          category: NotificationCategory.transactions,
          date: DateTime.now().subtract(const Duration(minutes: 40)),
        ),
        AppNotification(
          id: 'n2',
          title: 'Withdrawal processing',
          body: 'Your withdrawal is being processed and may take up to 30 minutes.',
          category: NotificationCategory.transactions,
          date: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AppNotification(
          id: 'n3',
          title: 'New login detected',
          body: 'A new login was detected on Chrome, Lagos, Nigeria.',
          category: NotificationCategory.security,
          date: DateTime.now().subtract(const Duration(hours: 9)),
        ),
        AppNotification(
          id: 'n4',
          title: 'Rate updated',
          body: 'The USDT buy rate was updated to ₦1,550.',
          category: NotificationCategory.trade,
          date: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        AppNotification(
          id: 'n5',
          title: 'Zero-fee swap weekend',
          body: 'Swap any asset with zero network markup this weekend only.',
          category: NotificationCategory.promotions,
          date: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ];

  static const networks = ['MTN', 'Airtel', 'Glo', '9mobile'];

  static const dataPlans = [
    {'size': '500MB', 'validity': '1 day', 'price': 350.0},
    {'size': '1GB', 'validity': '1 day', 'price': 600.0},
    {'size': '2GB', 'validity': '30 days', 'price': 1500.0},
    {'size': '5GB', 'validity': '30 days', 'price': 3500.0},
    {'size': '10GB', 'validity': '30 days', 'price': 6500.0},
    {'size': '20GB', 'validity': '30 days', 'price': 12000.0},
  ];

  static const fiatRates = {
    'NGN': 1.0,
    'USD': 1550.0,
    'EUR': 1680.0,
    'GBP': 1970.0,
  };
}
