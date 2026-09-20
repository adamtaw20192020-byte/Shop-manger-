import 'package:intl/intl.dart';

const currencySymbol = '₪';

String formatMoney(double value) {
  final formatter = NumberFormat.decimalPattern('ar');
  formatter.maximumFractionDigits = 2;
  return '${formatter.format(value)} $currencySymbol';
}

String formatDate(String iso) {
  final date = DateTime.parse(iso);
  return DateFormat('d MMM', 'ar').format(date);
}

String formatDateTime(String iso) {
  final date = DateTime.parse(iso);
  return DateFormat('d MMM, h:mm a', 'ar').format(date);
}
