import 'package:intl/intl.dart';

class PriceFormatter {
  const PriceFormatter._();

  static final _grouped = NumberFormat('#,###', 'en_US');
  static final _decimal = NumberFormat('#,##0.##', 'en_US');

  /// Example: 25000 + IQD → `25,000 IQD`
  /// Currency code always comes from the database (never hardcoded د.ع / $).
  static String format(num amount, {String currency = 'IQD'}) {
    final code = _normalizeCurrency(currency);
    final isWhole = code == 'IQD' || amount == amount.roundToDouble();
    final number = isWhole
        ? _grouped.format(amount.round())
        : _decimal.format(amount);

    if (code.isEmpty) return number;
    return '$number $code';
  }

  static String _normalizeCurrency(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'IQD';
    // Legacy Arabic dinar symbol stored in older rows → ISO code.
    if (trimmed == 'د.ع' || trimmed == 'د.ع.') return 'IQD';
    if (trimmed == '\$' || trimmed.toUpperCase() == 'USD') {
      return trimmed.toUpperCase() == 'USD' ? 'USD' : 'USD';
    }
    return trimmed.toUpperCase();
  }
}
