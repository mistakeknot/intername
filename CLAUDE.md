# Intername

> See `AGENTS.md` for full development guide.

## Overview

Agent and agency naming for legible orchestration — deterministic, memorable identities that persist across sessions and appear in every surface. 4 themes (culture, demarch, nato, custom), 2 commands, 1 library. No hooks, no MCP server.

## Quick Commands

```bash
bash -n hooks/lib-naming.sh             # Syntax check
bash tests/test_naming.sh               # Run 16 tests
python3 -c "import json; json.load(open('.claude-plugin/plugin.json'))"  # Manifest check
python3 -c "import json; [json.load(open(f'data/themes/{t}.json')) for t in ['culture','demarch','nato','custom']]"  # Theme check
```

## Design Decisions (Do Not Re-Ask)

- Fully deterministic names (same agent → same name always, regardless of project)
- Project shown as context alongside name, not encoded into it
- Dispatches inherit agent name + sequence number
- Custom overrides layer on top of any theme
- `INTERNAME_DISABLED=1` disables all naming (consumers fall back to raw IDs)
- Separate from intership (infrastructure identity vs. cosmetic spinner verbs)
- jq required for resolution; graceful fallback to raw IDs if jq missing
