# Figma Edit MCP — Setup Reference

Personal reference repo for setting up the [figma-edit-mcp](https://github.com/neozhehan/figma-edit-mcp) integration with Claude Code on any new Mac.

## One-Command Setup

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MJB1000/figma-edit-mcp-setup/main/bootstrap.sh)
```

## What This Does

1. Installs [Bun](https://bun.sh) runtime (if missing)
2. Clones the `figma-edit-mcp` repo to `~/Documents/CLAUDE/figma-edit-mcp/`
3. Installs dependencies and builds the MCP server + Figma plugin
4. Adds `FigmaEdit` to Claude Code's MCP config (`~/.claude/.mcp.json`)
5. Creates a bridge launcher script

## Architecture

```
Claude Code ←→ MCP Server (stdio/bun) ←→ WebSocket Bridge (port 3055) ←→ Figma Plugin (Desktop)
```

## After Bootstrap — Manual Steps

### One-Time: Install Figma Plugin
1. Open Figma Desktop
2. Plugins → Development → **Import plugin from manifest**
3. Select: `~/Documents/CLAUDE/figma-edit-mcp/src/figma_plugin/manifest.json`

### Each Session
1. **Start the bridge** (keep terminal open):
   ```bash
   ~/Documents/CLAUDE/figma-edit-mcp/start-bridge.sh
   ```
2. **In Figma Desktop**, run the "Figma Edit MCP Plugin" and paste your frame link to set edit scope
3. **In Claude Code**, FigmaEdit tools (40+) are available

## Available Tools (40+)

| Category | Tools |
|---|---|
| **Document** | `get_document_info`, `get_nodes_info`, `scan_nodes_by_types`, `set_selections` |
| **Create** | `create_frame`, `create_rectangle`, `create_text`, `create_node_from_svg` |
| **Modify** | `clone_node`, `move_node`, `resize_node`, `delete_multiple_nodes`, `set_node_name` |
| **Style** | `set_fill_color`, `set_stroke_color`, `set_corner_radius`, `set_effects` |
| **Layout** | `set_layout_mode`, `set_padding`, `set_axis_align`, `set_layout_sizing`, `set_item_spacing` |
| **Text** | `scan_text_nodes`, `set_multiple_text_contents` |
| **Components** | `create_component`, `create_component_instance`, `get_instance_overrides`, `set_instance_overrides` |
| **Variables** | `get_variables`, `get_node_variables`, `set_bound_variable`, `manage_variables` |
| **Export** | `export_node_as_image` (PNG, JPG, SVG, PDF) |

## Key Differences from Official Figma MCP

| | Official Figma MCP | FigmaEdit |
|---|---|---|
| **Write access** | Limited (`use_figma` single script) | 40+ dedicated write tools |
| **Batch ops** | Manual scripting | Built-in batch tools |
| **Safety** | No guardrails | Name-matching + scope locking |
| **Dependency** | HTTP (works anywhere) | Requires Figma Desktop + bridge |

**Best practice**: Use both together. Official MCP for reads/screenshots, FigmaEdit for heavy editing.

## Requirements
- macOS
- Figma Desktop (with plugin support)
- Claude Code (CLI or VS Code)

## MCP Config Reference

`~/.claude/.mcp.json`:
```json
{
  "mcpServers": {
    "FigmaEdit": {
      "type": "stdio",
      "command": "/Users/YOUR_USERNAME/.bun/bin/bun",
      "args": ["run", "/Users/YOUR_USERNAME/Documents/CLAUDE/figma-edit-mcp/dist/server.js"]
    }
  }
}
```
