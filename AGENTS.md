# AGENTS.md

MoeGo AI Agent Plugin Marketplace。本仓库同时承担 marketplace（插件目录）和 plugin 代码宿主两个角色，服务于 MoeGo 宠物服务 SaaS 平台的研发团队。

## 架构

单仓自包含模式：marketplace.json 通过相对路径 `source: "./plugins/<name>"` 引用同仓库内的 plugin 目录。Claude Code Plugin System 安装时会将 plugin 目录复制到 `~/.claude/plugins/cache/`，`CLAUDE_PLUGIN_ROOT` 环境变量指向该 cache 副本。

## 安装命令

```bash
/plugin marketplace add MoeGolibrary/moego-ai-plugin
/plugin install develop@moego-ai-marketplace
```

## 版本管理

- `plugins/develop/.claude-plugin/plugin.json` 的 `version` 是唯一版本信息源
- marketplace.json 的 plugin entry 不设 `version`（避免双源冲突，由 plugin.json 决定）
- 发版流程：代码合入 main → bump plugin.json version → 打 git tag（`vX.Y.Z`）
- 版本三方一致：`plugin.json version` = `git tag` = marketplace 引用的 `ref`（如使用 github source type）

## 目录结构

```text
moego-ai-plugin/
├── .claude-plugin/
│   └── marketplace.json          # marketplace 配置，列出所有 plugin
├── plugins/
│   └── develop/                  # Plugin: develop（研发工具）
│       ├── .claude-plugin/
│       │   └── plugin.json       # plugin manifest（name, version, description）
│       ├── skills/               # 所有 skill（每个 skill 一个子目录）
│       │   ├── superflow/        #   AI Native 全流程开发工作流
│       │   ├── e2e/              #   E2E 测试规划与 Playwright 代码生成
│       │   ├── datadog/          #   Datadog 日志/Trace/服务依赖查询
│       │   ├── code-to-spec/     #   模块 SPEC 规格文档逆向编写
│       │   ├── skill-creator/    #   SKILL.md 编写与审查
│       │   ├── writing-prompts/  #   编写一次性 LLM Prompt
│       │   └── writing-system-documents/  # 编写 Agent 常驻系统文档
│       ├── adapters/             # 非 Claude Code 工具适配层
│       ├── install.sh            # 手工安装脚本（非 Claude Code 工具降级方案）
│       ├── bin/moego-skills      # CLI 管理命令（update/list）
│       └── docs/adr/             # 架构决策记录
├── AGENTS.md                     # 本文件（AI Agent 上下文）
├── CLAUDE.md                     # → AGENTS.md 的符号链接
└── README.md                     # 人类开发者文档
```

## Skill 开发规范

### 命名与路径

- SKILL.md `name` 字段用 bare name（如 `superflow`），不加 `develop-` 前缀
- Claude Code 自动拼接为 `/develop:<skill-name>`
- Codex/OpenCode 通过 adapter symlink 获得 `develop-<skill-name>` 别名
- 脚本路径用 `${CLAUDE_PLUGIN_ROOT}/skills/<skill-name>/scripts/`

### SKILL.md 写作约束

- `description` 字段强制英文（Agent 据此判断何时加载）
- 不使用 `triggers` 字段（由 Plugin System 接管）
- frontmatter + 核心指令 ≤ 1,500 词，超出拆到 `references/`
- `references/` 下的文件用于 Progressive Disclosure，降低每次推理的固定 token 开销

### 创建新 Skill

1. 创建目录 `plugins/develop/skills/<your-skill>/`
2. 创建 `SKILL.md`（frontmatter: name, version, description）
3. 脚本放 `scripts/`，参考文档放 `references/`
4. 运行 `bash plugins/develop/install.sh` 验证 adapter symlink
5. 提交 PR

### 添加新 Plugin

1. 在 `plugins/` 下创建新目录（如 `plugins/product/`）
2. 创建 `.claude-plugin/plugin.json` manifest
3. 在根 `.claude-plugin/marketplace.json` 的 `plugins` 数组中添加条目
4. 创建 `adapters/`、`install.sh` 等配套文件
5. 提交 PR

## 代码风格

- 文件编码：UTF-8（无 BOM）
- Markdown：标准 Markdown，代码块用反引号包裹
- Shell 脚本：`#!/usr/bin/env bash`，`set -e`
- Python 脚本：使用 `uv run` 执行，依赖 `requests`、`python-dateutil`
- 文档语言：中文（SKILL.md 的 description 字段用英文，Body 可中文）

## 提交规范

- 格式：`type(scope): description ENT-0`
- type：`feat` / `fix` / `refactor` / `docs` / `chore`
- scope：skill 名称或模块名（`superflow`、`e2e`、`datadog`、`plugin`、`marketplace`）
- 分支命名：`feature-xxx` / `bugfix-xxx` / `chore-xxx`
- main 分支有 PR 保护，不可直接 push

## 禁止操作

- 不修改 `plugin.json` 的 `name` 字段
- 不修改 `marketplace.json` 的 marketplace `name`
- 不在 SKILL.md `name` 字段添加前缀
- 不在 SKILL.md 中添加 `triggers` 字段
- 不删除 `adapters/` 目录（非 Claude Code 工具依赖此层）
- 不删除 `install.sh`（作为 Plugin System 的降级方案保留）
- 不在 Skill 脚本中硬编码凭证或 API Key（使用环境变量）
- 不修改已 Accepted 的 ADR（推翻需创建新 ADR 并标注 `Superseded by ADR-XXXX`）

## ADR（架构决策记录）

- 位置：`plugins/develop/docs/adr/NNNN-<title>.md`
- 状态流转：`Proposed` → `Accepted` → `Retired` | `Superseded`

## 多工具兼容

| 工具        | 安装方式                                               | Skill 名称格式     |
| ----------- | ------------------------------------------------------ | ------------------ |
| Claude Code | `/plugin install develop@moego-ai-marketplace`         | `/develop:<skill>` |
| Codex       | symlink 至 `~/.codex/skills/develop-<skill>`           | `develop-<skill>`  |
| OpenCode    | symlink 至 `~/.config/opencode/skills/develop-<skill>` | `develop-<skill>`  |
| Kiro        | copy 至 `~/.kiro/skills/develop-<skill>`               | `develop-<skill>`  |
| Cursor      | `.cursorrules` 引用 SKILL.md 内容                      | 手动配置           |

修改 Skill 后需验证：adapter 脚本（`install.sh`）能正确为新 Skill 创建 symlink（Codex/OpenCode）或复制目录（Kiro）。
