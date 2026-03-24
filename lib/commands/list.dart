import 'package:inbox_cli/db/database.dart';
import 'package:inbox_cli/utils/output.dart';
import 'package:inbox_cli/utils/date.dart';
import 'package:drift/drift.dart';

/// 列出笔记命令
class ListCommand {
  final AppDatabase db;

  ListCommand(this.db);

  /// 执行命令
  Future<void> run({
    String? timeFilter, // today, yesterday, week, month
    int limit = 20,
  }) async {
    // 构建查询
    final query = db.select(db.notes)
      ..where((tbl) => tbl.isRemoved.equals(false))
      ..limit(limit)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    // 时间筛选
    switch (timeFilter) {
      case 'today':
        final todayStart = DateUtils.todayStart;
        query.where((tbl) => tbl.createdAt.isBiggerOrEqualValue(todayStart.toIso8601String()));
        break;
      case 'yesterday':
        final start = DateUtils.yesterdayStart;
        final end = DateUtils.yesterdayEnd;
        query.where((tbl) =>
          tbl.createdAt.isBiggerOrEqualValue(start.toIso8601String()) &
          tbl.createdAt.isSmallerOrEqualValue(end.toIso8601String())
        );
        break;
      case 'week':
        final weekAgo = DateUtils.weekAgo;
        query.where((tbl) => tbl.createdAt.isBiggerOrEqualValue(weekAgo.toIso8601String()));
        break;
      case 'month':
        final monthAgo = DateUtils.monthAgo;
        query.where((tbl) => tbl.createdAt.isBiggerOrEqualValue(monthAgo.toIso8601String()));
        break;
    }

    // 执行查询
    final notes = await query.get();

    // 输出结果
    OutputFormatter.printNotes(notes, timeFilter ?? 'all');
  }
}
