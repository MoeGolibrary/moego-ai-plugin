# OpenCode Adapter

OpenCode 会从以下位置发现 Skills：

- 项目级：`.opencode/skills/<name>/SKILL.md`
- 用户级：`~/.config/opencode/skills/<name>/SKILL.md`
- 兼容路径：`.claude/skills` 与 `~/.claude/skills`

OpenCode 直接读取 SKILL.md 的 `name` 字段。MoeGo Plugin 使用 bare name，需通过 adapter 脚本创建带 `moego-` 前缀的符号链接。

## 手动配置

```bash
mkdir -p ~/.config/opencode/skills
PLUGIN_ROOT=~/.claude/plugins/moego-ai-plugin
for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
  skill=$(basename "$skill_dir")
  [ -f "$skill_dir/SKILL.md" ] && ln -sfn "${skill_dir%/}" ~/.config/opencode/skills/moego-${skill}
done
```

如需项目级生效，可在仓库下创建 `.opencode/skills` 并建立同样的链接。
