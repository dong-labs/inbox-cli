import 'package:intl/intl.dart';

/// 日期工具类
class DateUtils {
  /// 解析 ISO-8601 日期字符串
  static DateTime? parseIsoDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// 格式化时间显示
  /// 今天：显示时间（HH:mm）
  /// 其他日期：显示月/日
  static String formatTime(String? isoDate) {
    final date = parseIsoDate(isoDate);
    if (date == null) return '';

    final now = DateTime.now();
    final isToday = date.year == now.year &&
                   date.month == now.month &&
                   date.day == now.day;

    if (isToday) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// 格式化完整日期
  static String formatFullDate(String? isoDate) {
    final date = parseIsoDate(isoDate);
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  /// 获取今天的开始时间（00:00:00）
  static DateTime get todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 获取昨天的开始时间（00:00:00）
  static DateTime get yesterdayStart {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateTime(yesterday.year, yesterday.month, yesterday.day);
  }

  /// 获取昨天的结束时间（23:59:59）
  static DateTime get yesterdayEnd {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
  }

  /// 获取一周前的时间
  static DateTime get weekAgo {
    return DateTime.now().subtract(const Duration(days: 7));
  }

  /// 获取一月前的时间
  static DateTime get monthAgo {
    return DateTime.now().subtract(const Duration(days: 30));
  }
}
