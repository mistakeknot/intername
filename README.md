# intername

Memorable names for agents and agencies. Because "fd-safety reviewing auth.go" tells you nothing, but "Lapsed Pacifist reviewing auth.go" you'll remember tomorrow.

## What this does

When Demarch dispatches five review agents in parallel, you need to know who's doing what at a glance. Technical IDs like `fd-safety` and `fd-correctness` are functional but forgettable. Intername assigns each agent a permanent, distinctive display name that appears consistently across every surface: dispatch tables, tmux panes, trust reports, verdict attributions, and TUI dashboards.

Names are **deterministic** — fd-safety is always "Lapsed Pacifist", in every project, every session. You build recognition over time. After a few reviews you'll know that "Lapsed Pacifist" is the security reviewer and "Conditions Apply" checks correctness, without reading the fine print.

Four theme packs ship out of the box. Switch freely; your custom overrides layer on top of any theme.

## Install

First, add the [interagency marketplace](https://github.com/mistakeknot/interagency-marketplace) (one-time setup):

```bash
/plugin marketplace add mistakeknot/interagency-marketplace
```

Then install:

```bash
/plugin install intername
```

## Usage

Look up a name:

```
/intername:name fd-safety
```
```
fd-safety → Lapsed Pacifist (theme: culture)
```

List all agent names:

```
/intername:name --list
```
```
AGENT TYPE           DISPLAY NAME
fd-architecture      Fair Warning
fd-correctness       Conditions Apply
fd-game-design       Playing Both Sides
fd-performance       Whose Idea Was This
fd-quality           Conditions Of Satisfaction
fd-safety            Lapsed Pacifist
...
```

Switch themes:

```
/intername:name-theme demarch
```
```
Theme switched: culture → demarch

Sample names:
  fd-safety       → Sentinel (was: Lapsed Pacifist)
  fd-correctness  → Arbiter (was: Conditions Apply)
  flux-drive      → Threshold Caucus (was: The Difficult Second Album)
```

## Themes

### Culture (default)

Dry wit, polite menace, and bureaucratic absurdity — inspired by Iain M. Banks' Culture ship names.

> *The Difficult Second Album* dispatching... *Lapsed Pacifist* reviewing auth.go... *Fair Warning* found 3 findings... *Conditions Apply* checking data layer...

### Demarch

Boundary concepts, diplomatic terms, and liminal vocabulary — reflecting the inter-\* philosophy of the space between things.

> *Threshold Caucus* dispatching... *Sentinel* reviewing auth.go... *Surveyor* found 3 findings... *Arbiter* checking data layer...

### NATO

Short, distinctive, unambiguous — NATO phonetic alphabet with adjective modifiers. Maximum UI compatibility.

> *Strike Victor* dispatching... *Red Bravo* reviewing auth.go... *Steady Foxtrot* found 3 findings... *Sharp Charlie* checking data layer...

### Custom

Your own names. Add entries to `data/themes/custom.json` — they override any active theme.

```json
{
  "agents": {
    "fd-safety": "My Security Buddy"
  }
}
```

## Disabling

```bash
export INTERNAME_DISABLED=1
```

All consumers fall back to raw agent IDs. Unset the variable to re-enable.

## How it works

Agencies and agents get permanent, globally stable names. Dispatches inherit the agent name plus a sequence number. Project context is shown alongside the name, not encoded into it:

```
┌── The Difficult Second Album (███ 4/7) ──────────────────┐
│ Lapsed Pacifist (1/3)       │ reviewing auth.go          │
│ Conditions Apply (1/2)      │ reviewing api.go           │
│ Fair Warning                │ ✓ done (3 findings)        │
└──────────────────────────────────────────────────────────┘
```

The naming library (`hooks/lib-naming.sh`) is sourced by consumers — it's not a hook or MCP server. If intername isn't installed, consumers fall back silently to raw IDs.

## Related

- [intership](https://github.com/mistakeknot/intership) — Culture ship names as spinner verbs (cosmetic, transient)
- [intermux](https://github.com/mistakeknot/intermux) — agent visibility and tmux monitoring (primary display consumer)
- [interflux](https://github.com/mistakeknot/interflux) — multi-agent review engine (dispatch and verdict consumer)
- [intertrust](https://github.com/mistakeknot/intertrust) — agent trust scoring (report consumer)
