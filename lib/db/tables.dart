import 'package:drift/drift.dart';

/// 笔记表（简化版，仅 CLI 使用）
class Notes extends Table {
  /// 短 UUID（20 字符）
  TextColumn get id => text()();

  /// Markdown 内容
  TextColumn get content => text()();

  /// 标题
  TextColumn get title => text().nullable()();

  /// 标签列表（JSON 数组字符串）
  TextColumn get tags => text().nullable()();

  /// 创建时间（ISO-8601 字符串）
  TextColumn get createdAt => text().nullable()();

  /// 最后修改时间（ISO-8601 字符串）
  TextColumn get updatedAt => text().nullable()();

  /// 软删除标记
  BoolColumn get isRemoved => boolean().withDefault(const Constant(false))();

  /// 置顶标记
  BoolColumn get isTop => boolean().withDefault(const Constant(false))();

  /// 收藏标记
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
