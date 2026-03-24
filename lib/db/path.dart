import 'dart:io';
import 'package:path/path.dart' as p;

/// 数据库路径配置
class DatabasePath {
  /// 获取数据库文件路径
  ///
  /// 按以下顺序查找：
  /// 1. 配置文件指定的路径
  /// 2. 默认平台路径
  static String getDatabasePath() {
    // 检查配置文件
    final configPath = _getConfigPath();
    final configFile = File(configPath);
    if (configFile.existsSync()) {
      try {
        final content = configFile.readAsStringSync();
        // 简单的 JSON 解析
        final dbPathMatch = RegExp(r'"database_path"\s*:\s*"([^"]+)"').firstMatch(content);
        if (dbPathMatch != null) {
          final path = dbPathMatch.group(1);
          if (path != null && File(path).existsSync()) {
            return path;
          }
        }
      } catch (_) {
        // 配置文件解析失败，使用默认路径
      }
    }

    // 使用默认路径
    return _getDefaultPath();
  }

  /// 获取默认数据库路径
  static String _getDefaultPath() {
    if (Platform.isMacOS) {
      // macOS: ~/Library/Application Support/inBox/inbox.sqlite
      final home = Platform.environment['HOME'];
      if (home != null) {
        final dbPath = p.join(home, 'Library', 'Application Support', 'inBox', 'inbox.sqlite');
        if (File(dbPath).existsSync()) {
          return dbPath;
        }
        // 尝试 Debug 版本路径
        final debugPath = p.join(home, 'Library', 'Application Support', 'inBox-Debug', 'inbox.sqlite');
        if (File(debugPath).existsSync()) {
          return debugPath;
        }
      }
    } else if (Platform.isWindows) {
      // Windows: %APPDATA%/inBox/inbox.sqlite
      final appData = Platform.environment['APPDATA'];
      if (appData != null) {
        final dbPath = p.join(appData, 'inBox', 'inbox.sqlite');
        if (File(dbPath).existsSync()) {
          return dbPath;
        }
      }
    } else if (Platform.isLinux) {
      // Linux: ~/.local/share/inBox/inbox.sqlite
      final home = Platform.environment['HOME'];
      if (home != null) {
        final dbPath = p.join(home, '.local', 'share', 'inBox', 'inbox.sqlite');
        if (File(dbPath).existsSync()) {
          return dbPath;
        }
      }
    }

    throw DatabaseNotFoundException('无法找到数据库文件，请确保 inBox App 已安装并运行过');
  }

  /// 获取配置文件路径
  static String _getConfigPath() {
    if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      return p.join(home ?? '', '.config', 'inbox', 'config.json');
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      return p.join(appData ?? '', 'inbox', 'config.json');
    }
    throw UnsupportedError('Unsupported platform');
  }
}

/// 数据库未找到异常
class DatabaseNotFoundException implements Exception {
  final String message;
  DatabaseNotFoundException(this.message);

  @override
  String toString() => '✗ 错误: $message';
}
