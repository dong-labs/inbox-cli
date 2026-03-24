import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'tables.dart';
import 'path.dart';

part 'database.g.dart';

/// inBox 数据库
@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

/// 打开数据库连接
QueryExecutor _openConnection() {
  final dbPath = DatabasePath.getDatabasePath();
  final file = File(dbPath);

  if (!file.existsSync()) {
    throw DatabaseNotFoundException('数据库文件不存在: $dbPath');
  }

  // 使用 NativeDatabase
  return NativeDatabase.createInBackground(file);
}
