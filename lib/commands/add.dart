import 'package:inbox_cli/db/database.dart';
import 'package:inbox_cli/utils/output.dart';
import 'package:inbox_cli/exceptions.dart';
import 'package:drift/drift.dart';

/// 添加笔记命令
class AddCommand {
  final AppDatabase db;

  AddCommand(this.db);

  /// 执行命令
  Future<void> run({
    required String? content,
    List<String>? tags,
    bool star = false,
  }) async {
    // 验证内容
    if (content == null || content.trim().isEmpty) {
      throw MissingContentException();
    }

    final now = DateTime.now();

    // 生成短 ID（20 字符）
    final id = _generateId();

    // 提取内容中的标签
    final contentTags = _extractTags(content);
    final allTags = {...?tags, ...contentTags};

    // 插入笔记
    await db.into(db.notes).insert(
      NotesCompanion.insert(
        id: id,
        content: content.trim(),
        createdAt: Value(now.toIso8601String()),
        updatedAt: Value(now.toIso8601String()),
        favorite: const Value(false),
      ),
    );

    // 如果有额外标签，更新 tags 字段
    if (allTags.isNotEmpty) {
      final tagsJson = '[${allTags.map((t) => '"$t"').join(',')}]';
      await db.update(db.notes).replace(
        Note(
          id: id,
          content: content.trim(),
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
          tags: tagsJson,
          favorite: star,
          isRemoved: false,
          isTop: false,
          title: null,
        ),
      );
    }

    printSuccess('添加成功: $id');
  }

  /// 生成短 ID（20 字符）
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecond % 10000).toString().padLeft(4, '0');
    return 'note-$timestamp-$random';
  }

  /// 从内容中提取标签
  Set<String> _extractTags(String content) {
    // 匹配 #标签 格式（支持中文）
    final regex = RegExp(r'#([\u4e00-\u9fa5\w/-]+)');
    final matches = regex.allMatches(content);
    return matches.map((m) => '#${m[1]}').toSet();
  }
}
