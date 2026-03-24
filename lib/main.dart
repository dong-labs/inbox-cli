import 'dart:io';
import 'package:args/args.dart';
import 'package:inbox_cli/db/database.dart';
import 'package:inbox_cli/db/path.dart';
import 'package:inbox_cli/commands/add.dart';
import 'package:inbox_cli/commands/list.dart';
import 'package:inbox_cli/commands/search.dart';
import 'package:inbox_cli/exceptions.dart';
import 'package:inbox_cli/utils/output.dart' show printError;

const String version = '1.0.0';

/// 主函数
Future<void> main(List<String> args) async {
  // 如果没有参数，显示帮助
  if (args.isEmpty) {
    _printHelp();
    exit(0);
  }

  // 处理全局选项
  if (args[0] == '-h' || args[0] == '--help') {
    _printHelp();
    exit(0);
  }
  if (args[0] == '-V' || args[0] == '--version') {
    print('inbox v$version');
    exit(0);
  }

  // 获取命令
  final command = args[0];
  final cmdArgs = args.skip(1).toList();

  try {
    // 初始化数据库
    final db = AppDatabase();

    switch (command) {
      case 'add':
        await _runAdd(db, cmdArgs);
        break;
      case 'list':
        await _runList(db, cmdArgs);
        break;
      case 'search':
        await _runSearch(db, cmdArgs);
        break;
      default:
        printError('未知命令: $command');
        _printHelp();
        exit(2);
    }

    await db.close();
  } on DatabaseNotFoundException catch (e) {
    print(e.toString());
    exit(3);
  } on MissingContentException catch (_) {
    printError('缺少笔记内容');
    print('\n用法: inbox add <content> [options]');
    print('  示例: inbox add "今天学习了 Dart CLI"');
    exit(2);
  } on MissingKeywordException catch (_) {
    printError('缺少搜索关键词');
    print('\n用法: inbox search <keyword>');
    print('  示例: inbox search "Dart"');
    exit(2);
  } catch (e) {
    printError(e.toString());
    exit(1);
  }
}

/// 创建 add 命令解析器
ArgParser _createAddParser() {
  return ArgParser()
    ..addOption('tag', abbr: 't', help: '添加标签')
    ..addFlag('star', help: '标记收藏');
}

/// 创建 list 命令解析器
ArgParser _createListParser() {
  return ArgParser()
    ..addFlag('today', negatable: false, help: '今天')
    ..addFlag('yesterday', negatable: false, help: '昨天')
    ..addFlag('week', negatable: false, help: '最近一周')
    ..addFlag('month', negatable: false, help: '最近一月')
    ..addOption('number', abbr: 'n', help: '限制数量', defaultsTo: '20');
}

/// 创建 search 命令解析器
ArgParser _createSearchParser() {
  return ArgParser()
    ..addOption('number', abbr: 'n', help: '限制数量', defaultsTo: '10');
}

/// 运行 add 命令
Future<void> _runAdd(AppDatabase db, List<String> args) async {
  final parser = _createAddParser();
  final results = parser.parse(args);

  final content = args.isEmpty ? null : args[0];
  final tags = results['tag'] as List<String>?;
  final star = results['star'] == true;

  final cmd = AddCommand(db);
  await cmd.run(content: content, tags: tags, star: star);
}

/// 运行 list 命令
Future<void> _runList(AppDatabase db, List<String> args) async {
  final parser = _createListParser();
  final results = parser.parse(args);

  // 检查时间选项冲突
  final timeFlags = ['today', 'yesterday', 'week', 'month'];
  final activeCount = timeFlags.where((f) => results[f] == true).length;
  String? timeFilter;

  if (activeCount > 1) {
    throw ConflictingTimeOptionsException();
  } else if (activeCount == 1) {
    timeFilter = timeFlags.firstWhere((f) => results[f] == true);
  }

  final limit = int.tryParse(results['number'] as String) ?? 20;

  final cmd = ListCommand(db);
  await cmd.run(timeFilter: timeFilter, limit: limit);
}

/// 运行 search 命令
Future<void> _runSearch(AppDatabase db, List<String> args) async {
  final parser = _createSearchParser();
  final results = parser.parse(args);

  final keyword = args.isEmpty ? null : args[0];
  final limit = int.tryParse(results['number'] as String) ?? 10;

  final cmd = SearchCommand(db);
  await cmd.run(keyword: keyword, limit: limit);
}

/// 打印帮助信息
void _printHelp() {
  print('inBox 笔记命令行工具 v$version\n');
  print('用法: inbox <command> [arguments] [options]\n');
  print('命令:');
  print('  add     添加笔记');
  print('  list    列出笔记');
  print('  search  搜索笔记\n');
  print('选项:');
  print('  -h, --help     显示帮助信息');
  print('  -V, --version  显示版本信息\n');
  print('示例:');
  print('  inbox add "今天学习了 Dart CLI"');
  print('  inbox add "项目进度更新" -t "#工作"');
  print('  inbox list --today');
  print('  inbox list --week -n 5');
  print('  inbox search "Dart"\n');
  print('使用 "inbox <command> --help" 查看命令详细帮助');
}
