# inBox CLI - Homebrew 安装指南

## 安装

```bash
brew install dong-labs/tap/dong-inbox
```

## 使用

安装后可以直接使用 `inbox` 命令：

```bash
# 查看帮助
inbox --help

# 添加笔记
inbox add "今天学习了 Dart CLI"
inbox add "会议记录" -t "#工作"

# 查看笔记
inbox list --today
inbox list --week -n 5

# 搜索笔记
inbox search "Dart"
```

## 更新

```bash
brew upgrade dong-inbox
```

## 卸载

```bash
brew uninstall dong-inbox
```

## 数据库位置

CLI 会自动查找 inBox App 的数据库文件：

- **macOS**: `~/Library/Application Support/inBox/inbox.sqlite`
- **Windows**: `%APPDATA%/inbox/inbox.sqlite`
- **Linux**: `~/.local/share/inbox/inbox.sqlite`

## 命令参考

| 命令 | 说明 | 示例 |
|------|------|------|
| `add` | 添加笔记 | `inbox add "内容" -t "#标签"` |
| `list` | 列出笔记 | `inbox list --today -n 10` |
| `search` | 搜索笔记 | `inbox search "关键词"` |

### 选项

| 选项 | 说明 |
|------|------|
| `--today` | 今天 |
| `--yesterday` | 昨天 |
| `--week` | 最近一周 |
| `--month` | 最近一月 |
| `-n, --number <n>` | 限制数量 |
| `-t, --tag <tag>` | 添加标签 |
| `--star` | 标记收藏 |

## 问题反馈

https://github.com/gudong/inBoxProject/issues
