# inBox CLI 设计文档

## 概述

inBox CLI 是 inBox 笔记应用的命令行工具，提供快速笔记录入、查询、管理功能。

## 命令规范

### 基本语法

```bash
inbox <command> [arguments] [options]
```

---

## 核心命令

### 1. add - 添加笔记

快速添加笔记内容，支持标签和快捷选项。

```bash
# 基础用法
inbox add "笔记内容"

# 带标签
inbox add "今天学习了 Dart CLI" --tag "#学习"

# 多标签
inbox add "项目进度更新" --tag "#工作" --tag "#项目"

# 收藏
inbox add "重要事项" --star

# 指定标题（独立于内容）
inbox add "内容..." --title "我的标题"

# 完整示例
inbox add "今天完成了 CLI 设计" --tag "#工作" --tag "#开发" --star
```

---

### 2. list - 列出笔记

```bash
# 列出所有笔记
inbox list

# 今日笔记
inbox list --today

# 按标签筛选
inbox list --tag "#工作"

# 按收藏筛选
inbox list --starred

# 限制数量
inbox list -n 10

# 详细模式
inbox list --verbose

# 组合使用
inbox list --today --tag "#工作" -n 5
```

---

### 3. search - 搜索笔记

```bash
# 关键词搜索
inbox search "关键词"

# 按标签搜索
inbox search --tag "#学习/编程"

# 搜索收藏笔记
inbox search "Dart" --starred

# 限制结果数量
inbox search "Flutter" -n 5
```

---

### 4. view - 查看笔记详情

```bash
# 按 ID 查看
inbox view note-xxx

# 按标题模糊匹配
inbox view --title "会议记录"

# 查看最后一条笔记
inbox view --last
```

---

### 5. edit - 编辑笔记

```bash
# 按 ID 编辑（打开编辑器）
inbox edit note-xxx

# 编辑最后一条
inbox edit --last

# 快速追加内容
inbox edit note-xxx --append "补充内容"

# 快速替换内容
inbox edit note-xxx --replace "新内容"
```

---

### 6. delete - 删除笔记

```bash
# 软删除（移到回收站）
inbox delete note-xxx

# 删除最后一条
inbox delete --last

# 按标题删除（交互确认）
inbox delete --title "临时笔记"

# 永久删除
inbox delete note-xxx --forever
```

---

### 7. star - 收藏/取消收藏

```bash
# 收藏
inbox star note-xxx

# 取消收藏
inbox unstar note-xxx

# 切换收藏状态
inbox star note-xxx --toggle
```

---

### 8. tag - 标签管理

```bash
# 列出所有标签
inbox tag list

# 查看标签下的笔记
inbox tag show "#工作"

# 重命名标签
inbox tag rename "#旧名称" "#新名称"

# 删除标签
inbox tag delete "#临时标签"
```

---

### 9. export - 导出笔记

```bash
# 导出为 JSON
inbox export --format json --output backup.json

# 导出指定标签
inbox export --tag "#工作" --output work.json

# 导出为 Markdown
inbox export --format md --output notes.md

# 导出今日笔记
inbox export --today --output today.json
```

---

### 10. sync - 手动同步

```bash
# 执行完整同步
inbox sync

# 仅上传
inbox sync --upload

# 仅下载
inbox sync --download
```

---

## 选项速查

| 选项 | 简写 | 说明 | 适用于 |
|------|------|------|--------|
| `--tag <tag>` | `-t` | 指定标签 | add, list, search, export |
| `--title <title>` | | 指定标题 | add, view, delete |
| `--star` | | 标记收藏 | add |
| `--starred` | | 筛选收藏 | list, search |
| `--today` | | 今日范围 | list, export |
| `--number <n>` | `-n` | 限制数量 | list, search |
| `--last` | | 最后一条 | view, edit, delete |
| `--verbose` | `-v` | 详细输出 | list |
| `--help` | `-h` | 帮助信息 | 所有命令 |
| `--version` | `-V` | 版本信息 | 根命令 |

---

## 输出格式

### 列表输出（简洁模式）
```
$ inbox list --today

[1] 今天学习了 Dart CLI           #学习  10:30  ⭐
[2] 完成设计文档                  #工作  14:20
[3] 临时笔记                      16:45
```

### 列表输出（详细模式）
```
$ inbox list --verbose -n 1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:     note-abc123
Title:  今天学习了 Dart CLI
Tags:   #学习, #开发
Time:   2025-03-10 10:30
Star:   ⭐

今天完成了 inBox CLI 的设计文档，
包括命令规范和实现方案。
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 配置文件

```bash
# 查看配置
inbox config

# 设置默认编辑器
inbox config set editor vim

# 设置默认标签
inbox config set default_tag "#速记"
```

---

## 别名

```bash
# 创建别名
inbox alias add n "inbox add"
inbox alias add ls "inbox list"

# 使用别名
n "快速笔记"
ls --today
```

---

## 交互模式

```bash
# 进入交互模式
inbox repl

> add "第一条笔记"
✓ Added: note-xxx

> list --today
[1] 第一条笔记  10:30

> exit
```

---

## 实现阶段规划

### Phase 1: MVP（最小可用）
- add - 添加笔记
- list - 列出笔记
- search - 搜索笔记

### Phase 2: 核心功能
- view - 查看详情
- edit - 编辑笔记
- delete - 删除笔记
- star - 收藏管理

### Phase 3: 高级功能
- tag - 标签管理
- export - 导出功能
- sync - 同步功能
- repl - 交互模式

---

## 技术选型

- **语言**: Dart（与主项目共享代码模型）
- **框架**: dart_cli / args
- **数据访问**: 本地 HTTP API（通过 inBox App 暴露）

---

## 数据通信

CLI 与 inBox App 通过本地 HTTP API 通信：

```
CLI → HTTP POST http://localhost:53100/api/notes/add → App
App → 处理业务逻辑 → SQLite → 同步队列
```

**端口**: 53100 (inbox → i n box → 5 31 00)
