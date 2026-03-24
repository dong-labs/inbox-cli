import 'package:inbox_cli/db/database.dart';
import 'package:inbox_cli/utils/output.dart';
import 'package:inbox_cli/exceptions.dart';
import 'package:drift/drift.dart';

/// 搜索笔记命令
class SearchCommand {
  final AppDatabase db;

  SearchCommand(this.db);

  /// 执行命令
  Future<void> run({
    required String? keyword,
    int limit = 10,
  }) async {
    // 验证关键词
    if (keyword == null || keyword.trim().isEmpty) {
      throw MissingKeywordException();
    }

    // 构建查询（使用 LIKE 搜索）
    final query = db.select(db.notes)
      ..where((tbl) =>
        (tbl.content.contains(keyword) | tbl.title.like('%$keyword%')) &
        tbl.isRemoved.equals(false)
      )
      ..limit(limit)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    // 执行查询
    final notes = await query.get();

    // 输出结果
    OutputFormatter.printSearchResults(notes, keyword);
  }
}
