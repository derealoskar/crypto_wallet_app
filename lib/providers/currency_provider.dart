import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/mock_data_service.dart';

/// Controls which currency asset balances/prices are displayed in across
/// the app (Home, Wallet, Asset details). Everything is still stored and
/// computed in NGN under the hood — this only converts at display time
/// using [MockDataService.fiatRates] — so switching currency here never
/// touches balances, trades, or transaction records.
///
/// Trade orders and payments stay in NGN regardless of this setting, since
/// settlement happens over Nigerian bank transfer either way.
class CurrencyProvider extends ChangeNotifier {
  String _currency = 'USD';

  String get currency => _currency;
  List<String> get supportedCurrencies => MockDataService.fiatRates.keys.toList();

  void setCurrency(String code) {
    if (!MockDataService.fiatRates.containsKey(code) || code == _currency) return;
    _currency = code;
    notifyListeners();
  }

  double convertFromNgn(double ngnAmount) {
    final rate = MockDataService.fiatRates[_currency] ?? 1.0;
    return ngnAmount / rate;
  }

  String get symbol {
    switch (_currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'NGN':
      default:
        return '₦';
    }
  }

  /// Converts [ngnAmount] into the selected currency and formats it with
  /// the right symbol and thousands grouping — the one call most screens
  /// need for a portfolio/asset value.
  String format(double ngnAmount, {bool decimals = true}) {
    final value = convertFromNgn(ngnAmount);
    final fmt = NumberFormat.currency(symbol: symbol, decimalDigits: decimals ? 2 : 0);
    return fmt.format(value);
  }
}
