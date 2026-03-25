#!/bin/bash
# ============================================================
# Figma Edit MCP — One-Command Bootstrap for Claude Code
# ============================================================
# Run on any new Mac:
#   curl -fsSL https://raw.githubusercontent.com/MJB1000/figma-edit-mcp-setup/main/bootstrap.sh | bash
#
# What it does:
#   1. Installs Bun (if missing)
#   2. Clones figma-edit-mcp to ~/Documents/CLAUDE/figma-edit-mcp
#   3. Installs deps & builds MCP server + Figma plugin
#   4. Registers the MCP server with Claude Code (user scope)
#   5. Creates a launcher script for the WebSocket bridge
# ============================================================

set -e

INSTALL_DIR="$HOME/Documents/CLAUDE/figma-edit-mcp"
REPO_URL="https://github.com/neozhehan/figma-edit-mcp.git"

echo ""
echo "=========================================="
echo "  Figma Edit MCP — Bootstrap Setup"
echo "=========================================="
echo ""

# --- 1. Bun ---
if ! command -v bun &>/dev/null && [ ! -f "$HOME/.bun/bin/bun" ]; then
  echo "📦 Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
else
  echo "✅ Bun already installed"
  export PATH="$HOME/.bun/bin:$PATH"
fi

# --- 2. Clone ---
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "✅ Repo already cloned at $INSTALL_DIR"
  cd "$INSTALL_DIR"
  echo "   Pulling latest..."
  git pull --ff-only 2>/dev/null || echo "   (pull skipped — local changes exist)"
else
  echo "📥 Cloning figma-edit-mcp..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# --- 3. Build ---
echo "🔨 Installing dependencies..."
bun install

echo "🔨 Building MCP server..."
bun run build

echo "🔨 Building Figma plugin..."
bun run plugin:build

# --- 4. Claude Code MCP registration ---
echo ""
echo "🔧 Registering with Claude Code..."

SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# Use bun to merge the MCP config safely
bun -e "
const fs = require('fs');
const path = '$SETTINGS_FILE';
let settings = {};
try { settings = JSON.parse(fs.readFileSync(path, 'utf8')); } catch {}
if (!settings.mcpServers) settings.mcpServers = {};
settings.mcpServers['figma-edit'] = {
  command: process.env.HOME + '/.bun/bin/bun',
  args: ['run', '$INSTALL_DIR/dist/server.js'],
  type: 'stdio'
};
fs.writeFileSync(path, JSON.stringify(settings, null, 2));
console.log('   ✅ Added figma-edit to ~/.claude/settings.json');
"

# --- 5. Bridge launcher ---
BRIDGE_SCRIPT="$INSTALL_DIR/start-bridge.sh"
cat > "$BRIDGE_SCRIPT" << 'BRIDGE_INNER'
#!/bin/bash
cd "$(dirname "$0")"
export PATH="$HOME/.bun/bin:$PATH"
echo "🔌 Starting Figma Edit MCP WebSocket bridge..."
echo "   Keep this terminal open while using Figma + Claude Code"
echo "   Press Ctrl+C to stop"
echo ""
bun run src/socket.ts
BRIDGE_INNER
chmod +x "$BRIDGE_SCRIPT"

echo ""
echo "=========================================="
echo "  ✅ Setup Complete!"
echo "=========================================="
echo ""
echo "  NEXT STEPS:"
echo ""
echo "  1. START THE BRIDGE (keep running in a terminal):"
echo "     $BRIDGE_SCRIPT"
echo ""
echo "  2. INSTALL THE FIGMA PLUGIN:"
echo "     • Open Figma Desktop"
echo "     • Menu → Plugins → Development → Import plugin from manifest..."
echo "     • Select: $INSTALL_DIR/src/figma_plugin/manifest.json"
echo "     • Run the plugin from Plugins → Development → Figma Edit MCP"
echo ""
echo "  3. USE IN CLAUDE CODE:"
echo "     • Restart Claude Code (or start a new session)"
echo "     • The 'figma-edit' MCP tools will be available automatically"
echo ""
echo "  To update later:  cd $INSTALL_DIR && git pull && bun run build && bun run plugin:build"
echo ""
