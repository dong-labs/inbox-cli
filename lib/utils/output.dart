import 'package:inbox_cli/db/database.dart';

/// 输出格式化工具
class OutputFormatter {
  /// 截断文本
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// 格式化标签显示
  static String formatTags(String? tagsJson) {
    if (tagsJson == null || tagsJson.isEmpty) return '';
    try {
      // 简单的 JSON 数组解析
      final matches = RegExp(r'#([\u4e00-\u9fa5\w/-]+)').allMatches(tagsJson);
      final tags = matches.map((m) => '#${m[1]}').take(2).join(' ');
      return tags.isEmpty ? '' : '  $tags';
    } catch (_) {
      return '';
    }
  }

  /// 打印笔记列表
  static void printNotes(List<Note> notes, String timeFilter) {
    if (notes.isEmpty) {
      print('  没有找到笔记');
      return;
    }

    final label = _getTimeFilterLabel(timeFilter);
    print('📅 $label (${notes.length}条)\n');

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      final star = note.favorite ? '  ⭐' : '';
      final tags = formatTags(note.tags);
      final time = _formatNoteTime(note.createdAt);
      final content = truncate(note.content, 35);

      print('  [${i + 1}] $content$tags  $time$star');
    }
  }

  /// 打印搜索结果
  static void printSearchResults(List<Note> notes, String keyword) {
    if (notes.isEmpty) {
      print('  没有找到匹配 "$keyword" 的笔记');
      return;
    }

    print('找到 ${notes.length} 条匹配笔记:\n');

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      final star = note.favorite ? '  ⭐' : '';
      final tags = formatTags(note.tags);
      final date = _formatSearchDate(note.createdAt);
      final content = truncate(note.content, 40);

      print('  [${i + 1}] $content$tags  $date$star');
    }
  }

  static String _getTimeFilterLabel(String filter) {
    switch (filter) {
      case 'today': return '今天';
      case 'yesterday': return '昨天';
      case 'week': return '最近一周';
      case 'month': return '最近一月';
      default: return '全部';
    }
  }

  static String _formatNoteTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final isToday = date.year == now.year &&
                     date.month == now.month &&
                     date.day == now.day;

      if (isToday) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.month}/${date.day}';
      }
    } catch (_) {
      return '';
    }
  }

  static String _formatSearchDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.month}/${date.day}';
    } catch (_) {
      return '';
    }
  }
}

/// 错误输出
void printError(String message) {
  print('✗ 错误: $message');
}

/// 成功输出
void printSuccess(String message) {
  print('✓ $message');
}
