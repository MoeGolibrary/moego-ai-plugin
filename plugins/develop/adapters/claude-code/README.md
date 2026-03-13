# Claude Code Adapter

Claude Code 通过 Plugin System 原生支持 Develop Plugin，无需手工配置 symlink。

## 推荐安装方式（Plugin System）

```bash
/plugin marketplace add MoeGolibrary/moego-ai-plugin
/plugin install develop@moego-ai-marketplace
```

安装后 Slash Command 自动可用：`/develop:superflow`、`/develop:e2e` 等。

## 手动安装（备用）

如无法使用 Marketplace，可克隆仓库后运行安装脚本：

```bash
git clone https://github.com/MoeGolibrary/moego-ai-plugin ~/.claude/plugins/moego-ai-plugin
bash ~/.claude/plugins/moego-ai-plugin/plugins/develop/install.sh
```

安装脚本会为 Codex、OpenCode、Kiro 创建 adapter symlink/copy。Claude Code 用户仍建议通过 Plugin System 安装（见上方推荐方式），因为手工 clone 的仓库根目录只有 `marketplace.json`，Claude Code 不会自动发现子目录中的 `plugin.json`。
