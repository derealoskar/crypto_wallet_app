import 'package:intl/intl.dart';

/// Shared formatting helpers so currency/date display stays consistent
/// across every screen.
class Formatters {
  Formatters._();

  static final _ngn = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
  static final _plain = NumberFormat.currency(locale: 'en_US', symbol: '');
  static final _compactDate = DateFormat('MMM d, h:mm a');
  static final _fullDate = DateFormat('EEEE, MMM d, y · h:mm a');
  static final _dayHeading = DateFormat('MMMM d, y');

  static String ngn(double value, {bool decimals = true}) {
    final fmt = decimals ? _ngn : NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);
    return fmt.format(value);
  }

  static String crypto(double value, {int decimals = 6}) {
    if (value == 0) return '0';
    final s = value.toStringAsFixed(decimals);
    return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  static String plain(double value) => _plain.format(value).trim();

  static String date(DateTime dt) => _compactDate.format(dt);

  static String fullDate(DateTime dt) => _fullDate.format(dt);

  /// Section heading for a date-grouped list — "Today"/"Yesterday" for the
  /// last two days, otherwise a full "Month d, y" (no time).
  static String dayHeading(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(dt.year, dt.month, dt.day);
    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';
    return _dayHeading.format(day);
  }

  static String percent(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';

  static String countdown(Duration d) {
    if (d.isNegative) return '00:00';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
