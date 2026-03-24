# inBox CLI 技术实现文档

## 一、技术选型

| 技术 | 版本 | 说明 |
|------|------|------|
| Dart | >=3.0 | 与主项目共享代码模型 |
| drift | ^2.0 | SQLite 数据库访问（与 Flutter app 共享） |
| args | ^2.5 | 命令行参数解析 |
| path | ^1.9 | 跨平台路径处理 |

### 为什么选择直接读 SQLite？

1. **简单**：独立运行，无需启动 App
2. **实时**：直接操作数据，无中间层
3. **可靠**：使用与 App 相同的 Drift ORM

---

## 二、项目结构

```
inbox_cli/
├── bin/
│   └── inbox.dart                 # CLI 入口，命令路由
├── lib/
│   ├── main.dart                  # 程序入口
│   ├── commands/                  # 命令实现
│   │   ├── add.dart               # 添加笔记
│   │   ├── list.dart              # 列出笔记
│   │   ├── search.dart            # 搜索笔记
│   │   └── base.dart              # 命令基类
│   ├── models/                    # 数据模型（与 app 共享）
│   │   └── note.dart              # 从 app 复用
│   ├── db/                        # 数据库层
│   │   ├── database.dart          # Drift 数据库连接
│   │   ├── tables.dart            # 表定义（从 app 复用）
│   │   └── path.dart              # 数据库路径配置
│   ├── config/                    # 配置
│   │   └── config.dart            # 配置文件管理
│   ├── utils/                     # 工具函数
│   │   ├── date.dart              # 日期处理
│   │   ├── output.dart            # 输出格式化
│   │   └── logger.dart            # 日志工具
│   └── exceptions.dart            # 自定义异常
├── pubspec.yaml
└── README.md
```

---

## 三、数据模型

### 3.1 表结构（从 app 共享）

```dart
// lib/db/tables.dart
@DataClassName('Note')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  BoolColumn get isRemoved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 3.2 Note 模型

```dart
// lib/models/note.dart
class Note {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isStarred;
  final List<Tag> tags;

  Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isStarred = false,
    this.tags = const [],
  });
}
```

---

## 四、数据库连接

### 4.1 路径配置

```dart
// lib/db/path.dart
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'dart:io';

class DatabasePath {
  static String getDatabasePath() {
    // 1. 读取配置文件
    final configPath = _getConfigPath();
    if (File(configPath).existsSync()) {
      final config = jsonDecode(File(configPath).readAsStringSync());
      if (config['database_path'] != null) {
        return config['database_path'];
      }
    }

    // 2. 使用默认路径
    return _getDefaultPath();
  }

  static String _getDefaultPath() {
    if (Platform.isMacOS) {
      return '/Users/gudong/Library/Containers/com.gudong.inbox/Data/data.db';
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      return p.join(appData ?? '', 'com.gudong.inbox', 'data.db');
    } else if (Platform.isLinux) {
      return p.join(Platform.environment['HOME'] ?? '', '.local', 'share', 'com.gudong.inbox', 'data.db');
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String _getConfigPath() {
    if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      return p.join(home ?? '', '.config', 'com.gudong.inbox', 'cli_config.json');
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      return p.join(appData ?? '', 'com.gudong.inbox', 'cli_config.json');
    }
    throw UnsupportedError('Unsupported platform');
  }
}
```

### 4.2 数据库连接

```dart
// lib/db/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'tables.dart';
import 'path.dart';

class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    final dbPath = DatabasePath.getDatabasePath();
    final file = File(dbPath);

    if (!file.existsSync()) {
      throw DatabaseNotFoundException('数据库不存在: $dbPath');
    }

    return NativeDatabase.createInBackground(file);
  }
}

class DatabaseNotFoundException implements Exception {
  final String message;
  DatabaseNotFoundException(this.message);

  @override
  String toString() => '✗ 错误: $message';
}
```

---

## 五、命令实现

### 5.1 命令基类

```dart
// lib/commands/base.dart
abstract class Command {
  final AppDatabase db;

  Command(this.db);

  Future<void> execute(Map<String, dynamic> args);
}
```

### 5.2 add 命令

```dart
// lib/commands/add.dart
class AddCommand extends Command {
  AddCommand(super.db);

  @override
  Future<void> execute(Map<String, dynamic> args) async {
    final content = args['content'] as String?;
    final tags = args['tag'] as List<String>?;
    final star = args['star'] as bool? ?? false;

    // 验证
    if (content == null || content.isEmpty) {
      throw MissingContentException();
    }

    // 生成 ID
    final id = 'note-${DateTime.now().millisecondsSinceEpoch}';

    // 提取标签（从内容中解析 #tag）
    final extractedTags = _extractTags(content);
    final allTags = {...?tags, ...extractedTags};

    // 插入数据库
    await db.into(db.notes).insert(
      NotesCompanion.insert(
        id: id,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isStarred: const Value(false),
      ),
    );

    // 处理标签
    for (final tag in allTags) {
      await _addTagToNote(id, tag);
    }

    print('✓ 添加成功: $id');
  }

  Set<String> _extractTags(String content) {
    final regex = RegExp(r'#(\w+|[\u4e00-\u9fa5]+)');
    return regex.allMatches(content).map((m) => '#${m[1]}').toSet();
  }

  Future<void> _addTagToNote(String noteId, String tag) async {
    // 标签处理逻辑
  }
}
```

### 5.3 list 命令

```dart
// lib/commands/list.dart
class ListCommand extends Command {
  ListCommand(super.db);

  @override
  Future<void> execute(Map<String, dynamic> args) async {
    final timeFilter = args['time'] as String?; // today/yesterday/week/month
    final limit = args['number'] as int? ?? 20;

    DateTime? startTime;
    DateTime? endTime;

    final now = DateTime.now();

    switch (timeFilter) {
      case 'today':
        startTime = DateTime(now.year, now.month, now.day);
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        startTime = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endTime = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case 'week':
        startTime = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startTime = now.subtract(const Duration(days: 30));
        break;
    }

    // 查询数据库
    final query = db.select(db.notes)
      ..where((tbl) => tbl.isRemoved.equals(false))
      ..limit(limit)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    if (startTime != null) {
      query.where((tbl) => tbl.createdAt.isBiggerOrEqualValue(startTime));
    }
    if (endTime != null) {
      query.where((tbl) => tbl.createdAt.isSmallerOrEqualValue(endTime));
    }

    final notes = await query.get();

    // 输出
    _printNotes(notes, timeFilter ?? 'all');
  }

  void _printNotes(List<Note> notes, String filter) {
    if (notes.isEmpty) {
      print('没有找到笔记');
      return;
    }

    print('📅 ${_getFilterLabel(filter)} (${notes.length}条)\n');

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      final star = note.isStarred ? '  ⭐' : '';
      final tags = note.tags.isNotEmpty ? '  ${note.tags.join(' ')}' : '';
      final time = _formatTime(note.createdAt);

      print('  [${i + 1}] ${_truncate(note.content, 40)}${tags}  $time$star');
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'today': return '今天';
      case 'yesterday': return '昨天';
      case 'week': return '最近一周';
      case 'month': return '最近一月';
      default: return '全部';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.month}/${dt.day}';
  }

  String _truncate(String s, int length) {
    return s.length > length ? '${s.substring(0, length)}...' : s;
  }
}
```

### 5.4 search 命令

```dart
// lib/commands/search.dart
class SearchCommand extends Command {
  SearchCommand(super.db);

  @override
  Future<void> execute(Map<String, dynamic> args) async {
    final keyword = args['keyword'] as String?;
    final limit = args['number'] as int? ?? 10;

    if (keyword == null || keyword.isEmpty) {
      throw MissingKeywordException();
    }

    // 使用 LIKE 搜索
    final notes = await (db.select(db.notes)
          ..where((tbl) =>
              tbl.content.contains(keyword) &
              tbl.isRemoved.equals(false))
          ..limit(limit)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();

    if (notes.isEmpty) {
      print('没有找到匹配 "$keyword" 的笔记');
      return;
    }

    print('找到 ${notes.length} 条匹配笔记:\n');

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      final star = note.isStarred ? '  ⭐' : '';
      final tags = note.tags.isNotEmpty ? '  ${note.tags.join(' ')}' : '';
      final date = '${note.createdAt.month}/${note.createdAt.day}';

      print('  [${i + 1}] ${_truncate(note.content, 40)}${tags}  $date$star');
    }
  }

  String _truncate(String s, int length) {
    return s.length > length ? '${s.substring(0, length)}...' : s;
  }
}
```

---

## 六、入口文件

### 6.1 main.dart

```dart
// lib/main.dart
import 'package:args/command_runner.dart';
import 'db/database.dart';
import 'commands/add.dart';
import 'commands/list.dart';
import 'commands/search.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner('inbox', 'inBox 笔记命令行工具')
    ..addCommand(AddCommand())
    ..addCommand(ListCommand())
    ..addCommand(SearchCommand());

  try {
    await runner.run(args);
  } on DatabaseNotFoundException catch (e) {
    print(e);
    exit(3);
  } on MissingContentException catch (e) {
    print('✗ 错误: 缺少笔记内容');
    print('  用法: inbox add <content> [options]');
    exit(2);
  } catch (e) {
    print('✗ 错误: $e');
    exit(1);
  }
}
```

### 6.2 bin/inbox.dart

```dart
#!/usr/bin/env dart

import 'package:inbox_cli/main.dart' as cli;

Future<void> main(List<String> args) async {
  await cli.main(args);
}
```

---

## 七、依赖配置

### pubspec.yaml

```yaml
name: inbox_cli
version: 1.0.0
description: inBox 笔记命令行工具

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  drift: ^2.20.0
  sqlite3: ^2.4.0
  args: ^2.5.0
  path: ^1.9.0

dev_dependencies:
  lints: ^3.0.0
```

---

## 八、异常定义

```dart
// lib/exceptions.dart
class MissingContentException implements Exception {}

class MissingKeywordException implements Exception {}

class ConflictingTimeOptionsException implements Exception {
  @override
  String toString() => '时间选项冲突，只能使用一个时间筛选选项';
}
```

---

## 九、测试计划

### 9.1 单元测试

```dart
// test/commands/add_test.dart
void main() {
  test('add command should create note', () async {
    // 测试添加笔记
  });

  test('add command should extract tags', () async {
    // 测试标签提取
  });
}
```

### 9.2 集成测试

- 使用内存数据库进行测试
- 测试命令行参数解析

---

## 十、安装方式

### 10.1 开发模式

```bash
cd inbox_cli
dart pub get
dart run bin/inbox.dart add "测试"
```

### 10.2 全局激活

```bash
dart pub global activate --source path .
inbox add "测试"
```

### 10.3 编译二进制

```bash
dart compile exe bin/inbox.dart -o inbox
# macOS: ./inbox add "测试"
# Windows: inbox.exe add "测试"
```

---

## 十一、与 Flutter App 代码共享

### 11.1 需要共享的文件

从 `thinkflutter/lib/data/db/` 复制：

```
thinkflutter/lib/data/db/
├── tables.dart          → inbox_cli/lib/db/tables.dart
└── app_database.dart    → 参考，简化版
```

### 11.2 数据模型

从 `thinkflutter/lib/data/models/` 复制：

```
thinkflutter/lib/data/models/
└── note.dart            → inbox_cli/lib/models/note.dart
```

**注意**：CLI 版本需要简化，移除 UI 相关依赖。

---

## 十二、开发步骤

1. ✅ 创建项目结构
2. ✅ 配置 pubspec.yaml
3. ⬜ 实现数据库连接
4. ⬜ 实现 add 命令
5. ⬜ 实现 list 命令
6. ⬜ 实现 search 命令
7. ⬜ 测试
8. ⬜ 编写文档
