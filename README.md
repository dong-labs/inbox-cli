# inBox CLI

inBox 笔记应用的命令行工具。

## 功能

- `add` - 快速添加笔记，支持标签和收藏
- `list` - 列出笔记，支持时间筛选（今天/昨天/本周/本月）
- `search` - 搜索笔记内容

## 快速开始

```bash
# 添加笔记
dart run bin/inbox.dart add "今天学习了 Dart CLI"

# 带标签添加
dart run bin/inbox.dart add "项目进度更新" -t "#工作"

# 查看今日笔记
dart run bin/inbox.dart list --today

# 查看本周笔记
dart run bin/inbox.dart list --week

# 搜索笔记
dart run bin/inbox.dart search "Dart"
```

## 命令参考

### add - 添加笔记

```bash
dart run bin/inbox.dart add <content> [options]

选项:
  -t, --tag <tag>     添加标签（可多次使用）
  --star              标记收藏
```

### list - 列出笔记

```bash
dart run bin/inbox.dart list [options]

选项:
  --today             今天
  --yesterday         昨天
  --week              最近一周
  --month             最近一月
  -n, --number <n>    限制数量（默认：20）
```

### search - 搜索笔记

```bash
dart run bin/inbox.dart search <keyword> [options]

选项:
  -n, --number <n>    限制结果数量（默认：10）
```

## 数据库位置

CLI 会按以下顺序查找数据库：

1. 配置文件：`~/.config/inbox/config.json` 中的 `database_path`
2. 默认路径：
   - macOS: `~/Library/Application Support/inBox/inbox.sqlite`
   - Windows: `%APPDATA%/inbox/inbox.sqlite`
   - Linux: `~/.local/share/inbox/inbox.sqlite`

## 开发

```bash
# 安装依赖
flutter pub get

# 运行
dart run bin/inbox.dart <command>

# 编译为可执行文件
dart compile exe bin/inbox.dart -o inbox
```

## 文档

- [DESIGN.md](./DESIGN.md) - 详细设计文档
- [IMPLEMENTATION.md](./IMPLEMENTATION.md) - 技术实现文档
- [CLI_DESIGN.md](./CLI_DESIGN.md) - 原始命令设计
