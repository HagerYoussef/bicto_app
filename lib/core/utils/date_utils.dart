import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd', 'ar').format(dateTime);
    } catch (e) {
      return dateStr.split('T').first;
    }
  }

  static String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('HH:mm', 'en').format(dateTime);
    } catch (e) {
       final timePart = dateStr.contains('T') ? dateStr.split('T').last : dateStr;
       return timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
    }
  }

  static String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(dateTime);
    } catch (e) {
      return dateStr.replaceAll('T', ' ');
    }
  }
}
