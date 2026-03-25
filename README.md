# Figma Edit MCP — Claude Code Bootstrap

One-command setup for [figma-edit-mcp](https://github.com/neozhehan/figma-edit-mcp) integrated with Claude Code.

## Quick Install (any Mac)

```bash
curl -fsSL https://raw.githubusercontent.com/MJB1000/figma-edit-mcp-setup/main/bootstrap.sh | bash
```

## What it does

1. **Installs Bun** (if not present)
2. **Clones** [figma-edit-mcp](https://github.com/neozhehan/figma-edit-mcp) to `~/Documents/CLAUDE/figma-edit-mcp`
3. **Builds** the MCP server + Figma plugin
4. **Registers** the MCP server in `~/.claude/settings.json` (user scope)
5. **Creates** a bridge launcher script

## After Install — 3 Steps

### 1. Start the WebSocket bridge
```bash
~/Documents/CLAUDE/figma-edit-mcp/start-bridge.sh
```
Keep this terminal open while working.

### 2. Install the Figma plugin
- Open **Figma Desktop**
- Menu → **Plugins** → **Development** → **Import plugin from manifest...**
- Select: `~/Documents/CLAUDE/figma-edit-mcp/src/figma_plugin/manifest.json`
- Run the plugin from **Plugins → Development → Figma Edit MCP**

### 3. Use in Claude Code
- Start a new Claude Code session
- The `figma-edit` MCP tools (40+) are automatically available
- Read designs, create/modify elements, manage design systems

## Update

```bash
cd ~/Documents/CLAUDE/figma-edit-mcp && git pull && bun run build && bun run plugin:build
```

## Architecture

```
Claude Code ←(stdio)→ MCP Server ←(WebSocket)→ Figma Plugin (in Figma Desktop)
```

- **MCP Server** (`dist/server.js`): 40+ tools for reading/editing Figma files
- **WebSocket Bridge** (`src/socket.ts`): Connects MCP server to Figma plugin
- **Figma Plugin**: Runs inside Figma Desktop, executes commands on the canvas

## Note on Device Independence

This setup requires **Figma Desktop** running on the same machine (the WebSocket bridge is `localhost`). When moving to a new device:
1. Run the bootstrap script
2. Re-import the Figma plugin
3. Start the bridge

Your Claude Code MCP config (`~/.claude/settings.json`) will be set up automatically.
