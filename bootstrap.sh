#!/bin/bash
# ============================================================
# Figma Edit MCP — One-Command Bootstrap
# ============================================================
# Run this on any new Mac to set up the full Figma Edit MCP
# integration for Claude Code.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_REPO/main/bootstrap.sh | bash
#   — or —
#   bash bootstrap.sh
#
# What it does:
#   1. Installs Bun (if missing)
#   2. Clones figma-edit-mcp repo
#   3. Installs dependencies + builds
#   4. Configures Claude Code MCP integration
#   5. Creates bridge launcher script
#   6. Prints next steps (Figma plugin install)
# ============================================================

set -e

INSTALL_DIR="$HOME/Documents/CLAUDE/figma-edit-mcp"
MCP_CONFIG="$HOME/.claude/.mcp.json"
BUN_BIN="$HOME/.bun/bin/bun"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Figma Edit MCP — Bootstrap Installer       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# -----------------------------------------------------------
# 1. Install Bun
# -----------------------------------------------------------
if [ -f "$BUN_BIN" ]; then
  echo "✅ Bun already installed: $($BUN_BIN --version)"
else
  echo "📦 Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  # Source the updated path
  export PATH="$HOME/.bun/bin:$PATH"
  echo "✅ Bun installed: $($BUN_BIN --version)"
fi

# -----------------------------------------------------------
# 2. Clone repo (or pull if exists)
# -----------------------------------------------------------
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "📂 Repo already exists, pulling latest..."
  cd "$INSTALL_DIR" && git pull origin main
else
  echo "📥 Cloning figma-edit-mcp..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone https://github.com/neozhehan/figma-edit-mcp.git "$INSTALL_DIR"
fi

# -----------------------------------------------------------
# 3. Install dependencies + build
# -----------------------------------------------------------
cd "$INSTALL_DIR"
echo "📦 Installing dependencies..."
"$BUN_BIN" install

echo "🔨 Building MCP server..."
"$BUN_BIN" run build

echo "🔨 Building Figma plugin..."
"$BUN_BIN" run plugin:build

# -----------------------------------------------------------
# 4. Configure Claude Code MCP
# -----------------------------------------------------------
echo "⚙️  Configuring Claude Code..."
mkdir -p "$(dirname "$MCP_CONFIG")"

if [ -f "$MCP_CONFIG" ]; then
  # Check if FigmaEdit already exists in config
  if grep -q '"FigmaEdit"' "$MCP_CONFIG" 2>/dev/null; then
    echo "✅ FigmaEdit already in Claude Code MCP config"
  else
    # Use a temp file approach to merge into existing config
    # Insert FigmaEdit server before the closing braces
    python3 -c "
import json, sys
with open('$MCP_CONFIG', 'r') as f:
    config = json.load(f)
config.setdefault('mcpServers', {})
config['mcpServers']['FigmaEdit'] = {
    'type': 'stdio',
    'command': '$BUN_BIN',
    'args': ['run', '$INSTALL_DIR/dist/server.js']
}
with open('$MCP_CONFIG', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"
    echo "✅ Added FigmaEdit to Claude Code MCP config"
  fi
else
  cat > "$MCP_CONFIG" << MCPEOF
{
  "mcpServers": {
    "FigmaEdit": {
      "type": "stdio",
      "command": "$BUN_BIN",
      "args": ["run", "$INSTALL_DIR/dist/server.js"]
    }
  }
}
MCPEOF
  echo "✅ Created Claude Code MCP config"
fi

# -----------------------------------------------------------
# 5. Make bridge launcher executable
# -----------------------------------------------------------
chmod +x "$INSTALL_DIR/start-bridge.sh" 2>/dev/null || true

# Create launcher if it doesn't exist
if [ ! -f "$INSTALL_DIR/start-bridge.sh" ]; then
  cat > "$INSTALL_DIR/start-bridge.sh" << 'BRIDGEOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUN="$HOME/.bun/bin/bun"
echo "🔌 Starting Figma Edit MCP WebSocket Bridge..."
echo "   Bridge: ws://localhost:3055"
echo "   Press Ctrl+C to stop"
echo ""
cd "$SCRIPT_DIR" && "$BUN" socket
BRIDGEOF
  chmod +x "$INSTALL_DIR/start-bridge.sh"
fi

# -----------------------------------------------------------
# Done!
# -----------------------------------------------------------
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ Setup Complete!                         ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "📍 Installed to: $INSTALL_DIR"
echo ""
echo "━━━ NEXT STEPS (manual, one-time) ━━━━━━━━━━━━"
echo ""
echo "1. Install the Figma plugin:"
echo "   → Figma Desktop → Plugins → Development"
echo "   → Import plugin from manifest"
echo "   → Select: $INSTALL_DIR/src/figma_plugin/manifest.json"
echo ""
echo "━━━ EACH SESSION ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Start the bridge (keep terminal open):"
echo "   $INSTALL_DIR/start-bridge.sh"
echo ""
echo "2. In Figma Desktop, run the plugin and paste"
echo "   your frame link to set edit scope"
echo ""
echo "3. In Claude Code, FigmaEdit tools are ready!"
echo ""
