# Codex Adapter

Codex 会从以下目录加载 Skills：

- 用户级：`~/.codex/skills`（默认 `$CODEX_HOME/skills`）
- 项目级：`<repo>/.codex/skills`

Codex 直接读取 SKILL.md 的 `name` 字段作为 Skill 名称。Develop Plugin 的 SKILL.md 使用 bare name（如 `superflow`），需通过 adapter 脚本创建带 `develop-` 前缀的符号链接，避免命名冲突。

## 手动配置

```bash
mkdir -p ~/.codex/skills
PLUGIN_ROOT=~/.claude/plugins/moego-ai-plugin/plugins/develop
for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
  skill=$(basename "$skill_dir")
  [ -f "$skill_dir/SKILL.md" ] && ln -sfn "${skill_dir%/}" ~/.codex/skills/develop-${skill}
done
```

**注意：** Codex 将以 `develop-superflow`、`develop-e2e` 等带前缀名称识别这些 Skills（通过 symlink 目录名，而非 SKILL.md name 字段）。

如需项目级生效，可在仓库下创建 `.codex/skills` 并建立同样的链接。
