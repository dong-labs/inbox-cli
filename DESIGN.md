# inBox CLI 设计文档

## 一、概述

inBox CLI 是 inBox 笔记应用的命令行工具，提供快速笔记录入、查询、搜索功能。

### 设计目标

- **简单快速**：一条命令完成操作，无需打开 App
- **数据互通**：直接操作 SQLite 数据库，与 App 数据实时同步
- **最小依赖**：独立运行，无需启动 App

---

## 二、命令设计

### 2.1 基本语法

```bash
inbox <command> [arguments] [options]
```

### 2.2 核心命令

#### add - 添加笔记

```bash
# 基础用法
inbox add "笔记内容"

# 带标签
inbox add "今天学习了 Dart CLI" --tag "#学习"

# 多标签
inbox add "项目进度更新" --tag "#工作" --tag "#项目"

# 收藏
inbox add "重要事项" --star

# 完整示例
inbox add "今天完成了 CLI 设计" --tag "#工作" --tag "#开发" --star
```

**参数说明**：
| 参数 | 说明 | 必填 |
|------|------|------|
| `<content>` | 笔记内容 | 是 |

**选项说明**：
| 选项 | 简写 | 说明 | 默认值 |
|------|------|------|--------|
| `--tag <tag>` | `-t` | 添加标签 | 无 |
| `--star` | | 标记收藏 | false |

---

#### list - 列出笔记

```bash
# 列出所有笔记（最近20条）
inbox list

# 今天
inbox list --today

# 昨天
inbox list --yesterday

# 最近一周
inbox list --week

# 最近一个月
inbox list --month

# 指定数量
inbox list -n 10

# 组合使用
inbox list --week -n 5
```

**选项说明**：
| 选项 | 简写 | 说明 | 时间范围 |
|------|------|------|----------|
| `--today` | | 今天 | 0:00 至今 |
| `--yesterday` | | 昨天 | 昨天 0:00-23:59 |
| `--week` | | 最近一周 | 最近7天 |
| `--month` | | 最近一月 | 最近30天 |
| `--number <n>` | `-n` | 限制数量 | 20 |

**时间选项互斥**：`--today`、`--yesterday`、`--week`、`--month` 只能选一个，不能同时使用。

---

#### search - 搜索笔记

```bash
# 关键词搜索
inbox search "Dart"

# 限制结果数量
inbox search "Flutter" -n 5
```

**参数说明**：
| 参数 | 说明 | 必填 |
|------|------|------|
| `<keyword>` | 搜索关键词 | 是 |

**选项说明**：
| 选项 | 简写 | 说明 | 默认值 |
|------|------|------|--------|
| `--number <n>` | `-n` | 限制结果数量 | 10 |

---

## 三、输出格式

### 3.1 成功操作

```bash
$ inbox add "测试笔记"

✓ 添加成功: note-xxx
```

### 3.2 列表输出

```bash
$ inbox list --today

📅 今天 (3条)

  [1] 今天学习了 Dart CLI                        #学习  10:30
  [2] 完成 inBox CLI 设计文档                     #工作  14:20  ⭐
  [3] 临时笔记                                    16:45
```

**格式说明**：
```
序号 内容                        标签    时间   星标
```

### 3.3 搜索输出

```bash
$ inbox search "Dart"

找到 2 条匹配笔记:

  [1] 今天学习了 Dart CLI                        #学习  3月14日
  [2] Dart 异步编程笔记                           #编程  3月10日  ⭐
```

### 3.4 错误输出

```bash
$ inbox add

✗ 错误: 缺少笔记内容

用法: inbox add <content> [options]

  inbox add "笔记内容" [--tag <tag>] [--star]
```

---

## 四、全局选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--help` | `-h` | 显示帮助信息 |
| `--version` | `-V` | 显示版本信息 |
| `--verbose` | `-v` | 详细输出模式 |

---

## 五、配置文件

CLI 通过配置文件获取数据库路径，支持跨平台。

### 5.1 配置文件位置

```bash
# macOS
~/Library/Application Support/com.gudong.inbox/cli_config.json

# Windows
%APPDATA%/com.gudong.inbox/cli_config.json

# Linux
~/.config/com.gudong.inbox/cli_config.json
```

### 5.2 配置内容

```json
{
  "database_path": "/path/to/database.db",
  "default_tags": ["#速记"]
}
```

### 5.3 自动发现

CLI 会按以下顺序自动查找数据库：

1. 配置文件指定的路径
2. 默认平台路径
   - macOS: `~/Library/Containers/com.gudong.inbox/Data/data.db`
   - Windows: `%APPDATA%/com.gudong.inbox/data.db`

---

## 六、命令优先级

### Phase 1: MVP（当前范围）

| 优先级 | 命令 | 说明 |
|--------|------|------|
| P0 | `add` | 添加笔记 |
| P0 | `list` | 列出笔记（时间筛选） |
| P0 | `search` | 搜索笔记 |
| P1 | `--help` | 帮助文档 |
| P1 | `--version` | 版本信息 |

### Phase 2: 后续扩展（不包含在 MVP）

| 命令 | 说明 |
|------|------|
| `view` | 查看笔记详情 |
| `edit` | 编辑笔记 |
| `delete` | 删除笔记 |
| `star` | 收藏管理 |
| `tag` | 标签管理 |
| `export` | 导出功能 |
| `sync` | 同步功能 |

---

## 七、使用示例

### 日常速记

```bash
# 快速记录想法
inbox add "需要重构 CLI 的命令解析逻辑"

# 带标签记录
inbox add "Flutter 3.27 发布了新特性" --tag "#技术"
```

### 回顾笔记

```bash
# 看今天记了什么
inbox list --today

# 看本周的笔记
inbox list --week

# 看最近5条
inbox list -n 5
```

### 搜索查找

```bash
# 找相关笔记
inbox search "CLI"
```

---

## 八、命名规范

### 8.1 命令命名

- 全小写
- 动词开头：add, list, search, view, edit, delete
- 单词优先，避免缩写

### 8.2 选项命名

- 长选项用 `--word`
- 短选项用 `-w`
- 布尔选项用 `--flag`（如 `--star`）
- 带值选项用 `--option <value>`（如 `--tag <tag>`）

### 8.3 输出风格

- 成功：✓
- 错误：✗
- 信息：📅
- 搜索：🔍

---

## 九、错误处理

### 9.1 常见错误

| 错误场景 | 提示信息 |
|----------|----------|
| 数据库不存在 | ✗ 错误: 找不到数据库，请确保 inBox App 已安装 |
| 缺少内容 | ✗ 错误: 缺少笔记内容 |
| 标签格式错误 | ✗ 错误: 标签必须以 # 开头 |
| 时间选项冲突 | ✗ 错误: --today 和 --week 不能同时使用 |

### 9.2 错误退出码

| 退出码 | 含义 |
|--------|------|
| 0 | 成功 |
| 1 | 通用错误 |
| 2 | 参数错误 |
| 3 | 数据库错误 |
