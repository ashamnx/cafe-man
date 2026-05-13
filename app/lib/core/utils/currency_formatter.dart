import 'package:intl/intl.dart';

String formatCurrency(double amount, {String symbol = 'Mvr'}) {
  final formatter = NumberFormat('#,##0.00');
  return '$symbol ${formatter.format(amount)}';
}

String formatPercentage(double value) {
  return '${value.toStringAsFixed(1)}%';
}
