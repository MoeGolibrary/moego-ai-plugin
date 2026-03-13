# MoeGo AI Plugin Marketplace

MoeGo 研发团队 AI Agent Plugin Marketplace。为 MoeGo 宠物服务 SaaS 平台的工程师提供标准化的 AI 辅助工具集，支持 Claude Code、Codex、OpenCode、Kiro、Cursor 等主流 AI 编码工具。

## 快速开始

### Claude Code（推荐）

```bash
# 1. 添加 Marketplace（一次性）
/plugin marketplace add MoeGolibrary/moego-ai-plugin

# 2. 安装 Develop Plugin
/plugin install develop@moego-ai-marketplace
```

### 其他工具

| 工具     | 安装方式                                                                 | 调用格式             |
| -------- | ------------------------------------------------------------------------ | -------------------- |
| Codex    | [Codex Adapter](plugins/develop/adapters/codex/README.md)（symlink）     | `develop-<skill>`    |
| OpenCode | [OpenCode Adapter](plugins/develop/adapters/opencode/README.md)（symlink）| `develop-<skill>`    |
| Kiro     | [Kiro Adapter](plugins/develop/adapters/kiro/README.md)（copy）          | `/develop-<skill>`   |
| Cursor   | [Cursor Adapter](plugins/develop/adapters/cursor/README.md)              | 手动配置             |

或直接运行安装脚本（为 Codex/OpenCode/Kiro 配置 adapter）：

```bash
git clone https://github.com/MoeGolibrary/moego-ai-plugin ~/.claude/plugins/moego-ai-plugin
bash ~/.claude/plugins/moego-ai-plugin/plugins/develop/install.sh
```

> **注意**：手工 clone 仅为非 Claude Code 工具提供 adapter。Claude Code 用户请使用上方 Plugin System 安装方式。

### 更新

```bash
/plugin marketplace update    # 更新 Marketplace 目录
/plugin update develop        # 更新 Develop Plugin
```

## Develop Plugin — Skills 一览

| Skill | 调用 | 说明 |
|-------|------|------|
| superflow | `/develop:superflow` | AI Native 全流程开发工作流：需求分析 → 方案设计 → 实现 → Code Review → 提交，覆盖 MoeGo 前端（React SPA）和 BFF（Hono）技术栈 |
| e2e | `/develop:e2e` | E2E 测试规划与 Playwright 代码生成，基于 moego-e2e-autotest 项目的 Page Object 模式 |
| datadog | `/develop:datadog` | Datadog 日志查询、Trace/Span 分析、服务依赖拓扑，支持 APM 和 RUM |
| code-to-spec | `/develop:code-to-spec` | 从现有代码逆向生成模块 SPEC 规格文档，支持 UI 组件、Hook、脚本等多种模块类型 |
| skill-creator | `/develop:skill-creator` | SKILL.md 编写与审查工具，遵循 agentskills.io 开放标准 |
| writing-prompts | `/develop:writing-prompts` | 编写一次性 LLM Prompt 的结构化写作指南 |
| writing-system-documents | `/develop:writing-system-documents` | 编写 Agent 常驻系统文档（CLAUDE.md、System Prompt 等）的写作指南，关注 token 成本优化 |

## 目录结构

```text
moego-ai-plugin/                          ← 仓库根 = marketplace
├── .claude-plugin/
│   └── marketplace.json                  ← 插件目录（source 用相对路径）
├── plugins/
│   ├── develop/                          ← plugin: develop（研发工具）
│   │   ├── .claude-plugin/plugin.json    ← plugin manifest
│   │   ├── skills/                       ← 7 个 skill
│   │   ├── adapters/                     ← 5 个工具适配
│   │   ├── install.sh                    ← 手工安装脚本
│   │   ├── bin/moego-skills              ← CLI（update/list）
│   │   └── docs/adr/                     ← 架构决策记录
│   ├── product/                          ← (planned)
│   └── design/                           ← (planned)
├── CLAUDE.md
├── AGENTS.md
└── README.md
```

## 贡献

### 添加新 Skill

1. 创建 `plugins/develop/skills/<your-skill>/SKILL.md`

   ```yaml
   ---
   name: your-skill
   version: 1.0.0
   description: >
     This skill should be used when the user asks to [trigger conditions].
   ---
   ```

2. `name` 用 bare name，不加前缀；`description` 用英文
3. 核心内容 ≤ 1,500 词，详细文档放 `references/`
4. 脚本放 `scripts/`，路径用 `${CLAUDE_PLUGIN_ROOT}/skills/your-skill/scripts/`
5. 运行 `bash plugins/develop/install.sh` 验证 adapter
6. 提交 PR

### 添加新 Plugin

1. 在 `plugins/` 下创建目录（如 `plugins/product/`）
2. 创建 `.claude-plugin/plugin.json`
3. 在根 `marketplace.json` 添加 plugin entry（`source` 用相对路径）
4. 提交 PR

## License

UNLICENSED
