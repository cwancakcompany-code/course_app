import 'package:intl/intl.dart';

class PriceFormatter {
  const PriceFormatter._();

  static final _iqd = NumberFormat('#,###', 'en_US');

  /// Example: 25000 + IQD → `25،000 د.ع`
  static String format(num amount, {String currency = 'IQD'}) {
    final code = currency.trim().toUpperCase().replaceAll('\$', '');
    final number = (code == 'IQD' || code == 'د.ع' || code.isEmpty || code == 'USD')
        ? _iqd.format(amount.round()).replaceAll(',', '،')
        : NumberFormat('#,##0.##', 'en_US').format(amount).replaceAll(',', '،');

    // Always IQD for storefront; never prefix/suffix with $.
    if (code == 'IQD' || code == 'د.ع' || code.isEmpty || code == 'USD') {
      return '$number د.ع';
    }
    return '$number $code';
  }
}
