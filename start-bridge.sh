#!/bin/bash
# Figma Edit MCP — WebSocket Bridge Launcher
# Run this before using FigmaEdit tools in Claude Code.
# Keep this terminal window open while working.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUN="$HOME/.bun/bin/bun"

echo "🔌 Starting Figma Edit MCP WebSocket Bridge..."
echo "   Bridge: ws://localhost:3055"
echo "   Press Ctrl+C to stop"
echo ""

cd "$SCRIPT_DIR" && "$BUN" socket
