#!/usr/bin/env bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Config
REPO_URL="https://github.com/MoeGolibrary/moego-ai-plugin.git"
INSTALL_DIR="$HOME/.claude/plugins/moego-ai-plugin"
BIN_DIR="$HOME/.local/bin"
PLUGIN_DIR="$INSTALL_DIR/plugins/develop"

echo -e "${GREEN}🚀 Installing MoeGo Skills...${NC}"

# Check git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

# Create directories
mkdir -p "$BIN_DIR"
mkdir -p "$(dirname "$INSTALL_DIR")"

# Clone or update
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Updating existing installation...${NC}"
    cd "$INSTALL_DIR"
    git pull --ff-only
else
    echo -e "${YELLOW}Cloning repository...${NC}"
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Install CLI command
if [ -f "$PLUGIN_DIR/bin/moego-skills" ]; then
    chmod +x "$PLUGIN_DIR/bin/moego-skills"
    ln -sf "$PLUGIN_DIR/bin/moego-skills" "$BIN_DIR/moego-skills"
fi

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}⚠️  Add this to your shell profile (.bashrc/.zshrc):${NC}"
    echo -e "   export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Setup adapters
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"
OPENCODE_SKILLS_DIR="$HOME/.config/opencode/skills"
KIRO_SKILLS_DIR="$HOME/.kiro/skills"
mkdir -p "$CLAUDE_SKILLS_DIR" "$CODEX_SKILLS_DIR" "$OPENCODE_SKILLS_DIR" "$KIRO_SKILLS_DIR"

# Create symlinks for skills (directory-level symlinks)
for skill_dir in "$PLUGIN_DIR/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
        # Clean up legacy moego-* prefix symlinks (from v1.x/v2.x era)
        rm -rf "$CLAUDE_SKILLS_DIR/moego-$skill_name" "$CODEX_SKILLS_DIR/moego-$skill_name" "$OPENCODE_SKILLS_DIR/moego-$skill_name" "$KIRO_SKILLS_DIR/moego-$skill_name"
        rm -rf "$CLAUDE_SKILLS_DIR/moego:$skill_name" "$CODEX_SKILLS_DIR/moego:$skill_name" "$OPENCODE_SKILLS_DIR/moego:$skill_name"
        # Clean up current develop-* prefix before re-creating
        rm -rf "$CODEX_SKILLS_DIR/develop-$skill_name" "$OPENCODE_SKILLS_DIR/develop-$skill_name" "$KIRO_SKILLS_DIR/develop-$skill_name"

        # Claude Code: skip symlink — Plugin System handles auto-discovery via .claude-plugin/
        # Codex / OpenCode: use develop- prefix symlink to maintain namespace
        ln -sfn "${skill_dir%/}" "$CODEX_SKILLS_DIR/develop-$skill_name"
        ln -sfn "${skill_dir%/}" "$OPENCODE_SKILLS_DIR/develop-$skill_name"

        # Kiro: copy instead of symlink — Kiro does not discover folder-level symlinks
        rm -rf "$KIRO_SKILLS_DIR/develop-$skill_name"
        cp -r "${skill_dir%/}" "$KIRO_SKILLS_DIR/develop-$skill_name"
    fi
done

echo -e "${GREEN}✅ MoeGo Skills installed successfully!${NC}"
echo -e "${YELLOW}⚠️  Kiro 用户注意：安装/更新 Skills 后需重启 Kiro 才能真正激活（仅 UI 显示不代表已完整加载）。${NC}"
echo ""
echo "Available commands:"
echo "  moego-skills update  - Update all skills"
echo "  moego-skills list    - List installed skills"
echo "  moego-skills help    - Show help"
echo ""
echo "Installed skills:"
ls -1 "$PLUGIN_DIR/skills/" 2>/dev/null | while read skill; do
    echo "  - $skill"
done
