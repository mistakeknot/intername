#!/usr/bin/env bash
# lib-naming.sh — Agent and agency naming for legible orchestration.
#
# Provides deterministic, memorable names for agents and agencies.
# Names are permanent (same agent always gets same name) and appear
# consistently across all surfaces (TUI, CLI, logs, verdicts, trust reports).
#
# Usage:
#   source hooks/lib-naming.sh
#   name=$(_name_resolve "fd-safety")          # → "Lapsed Pacifist"
#   name=$(_name_resolve_agency "flux-drive")  # → "The Difficult Second Album"
#   _name_dispatch "fd-safety" 2 5             # → "Lapsed Pacifist (2/5)"
#
# Disable: export INTERNAME_DISABLED=1

[[ -n "${_LIB_NAMING_LOADED:-}" ]] && return 0
_LIB_NAMING_LOADED=1

_NAMING_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_NAMING_DATA_DIR="${_NAMING_SCRIPT_DIR}/../data"

# ─── Configuration ────────────────────────────────────────────────────────────

# Load active theme name from config.json.
_name_theme() {
    local config="${_NAMING_DATA_DIR}/config.json"
    if [[ -f "$config" ]] && command -v jq &>/dev/null; then
        jq -r '.theme // "culture"' "$config" 2>/dev/null || echo "culture"
    else
        echo "culture"
    fi
}

# Check if custom overrides are enabled.
_name_custom_enabled() {
    local config="${_NAMING_DATA_DIR}/config.json"
    if [[ -f "$config" ]] && command -v jq &>/dev/null; then
        local val
        val=$(jq -r '.customOverrides // true' "$config" 2>/dev/null)
        [[ "$val" == "true" ]]
    else
        return 0  # enabled by default
    fi
}

# ─── Resolution ───────────────────────────────────────────────────────────────

# Check if naming is enabled. Returns 0 (enabled) or 1 (disabled).
_name_enabled() {
    [[ "${INTERNAME_DISABLED:-}" != "1" ]]
}

# Resolve an agent type to its display name.
# Falls back to the raw agent_type if disabled, no mapping exists, or jq unavailable.
# Args: $1 = agent_type (e.g., "fd-safety")
_name_resolve() {
    local agent_type="${1:?agent_type required}"

    # Disabled → return raw ID
    _name_enabled || { echo "$agent_type"; return 0; }

    # No jq → return raw ID
    command -v jq &>/dev/null || { echo "$agent_type"; return 0; }

    local name=""

    # Check custom overrides first
    if _name_custom_enabled; then
        local custom="${_NAMING_DATA_DIR}/themes/custom.json"
        if [[ -f "$custom" ]]; then
            name=$(jq -r ".agents[\"$agent_type\"] // empty" "$custom" 2>/dev/null)
        fi
    fi

    # Fall back to active theme
    if [[ -z "$name" ]]; then
        local theme
        theme=$(_name_theme)
        local theme_file="${_NAMING_DATA_DIR}/themes/${theme}.json"
        if [[ -f "$theme_file" ]]; then
            name=$(jq -r ".agents[\"$agent_type\"] // empty" "$theme_file" 2>/dev/null)
        fi
    fi

    echo "${name:-$agent_type}"
}

# Resolve an agency type to its display name.
# Args: $1 = agency_type (e.g., "flux-drive")
_name_resolve_agency() {
    local agency_type="${1:?agency_type required}"

    _name_enabled || { echo "$agency_type"; return 0; }
    command -v jq &>/dev/null || { echo "$agency_type"; return 0; }

    local name=""

    if _name_custom_enabled; then
        local custom="${_NAMING_DATA_DIR}/themes/custom.json"
        if [[ -f "$custom" ]]; then
            name=$(jq -r ".agencies[\"$agency_type\"] // empty" "$custom" 2>/dev/null)
        fi
    fi

    if [[ -z "$name" ]]; then
        local theme
        theme=$(_name_theme)
        local theme_file="${_NAMING_DATA_DIR}/themes/${theme}.json"
        if [[ -f "$theme_file" ]]; then
            name=$(jq -r ".agencies[\"$agency_type\"] // empty" "$theme_file" 2>/dev/null)
        fi
    fi

    echo "${name:-$agency_type}"
}

# Format a dispatch identifier: "Display Name (n/total)" or just "Display Name".
# Args: $1 = agent_type, $2 = sequence (optional), $3 = total (optional)
_name_dispatch() {
    local agent_type="${1:?agent_type required}"
    local seq="${2:-}"
    local total="${3:-}"

    local name
    name=$(_name_resolve "$agent_type")

    if [[ -n "$seq" && -n "$total" ]]; then
        echo "${name} (${seq}/${total})"
    elif [[ -n "$seq" ]]; then
        echo "${name} (${seq})"
    else
        echo "$name"
    fi
}

# List all named agents in the active theme + custom overrides.
# Output: agent_type\tdisplay_name (TSV, one per line).
_name_list() {
    _name_enabled || return 0
    command -v jq &>/dev/null || return 0

    local theme
    theme=$(_name_theme)
    local theme_file="${_NAMING_DATA_DIR}/themes/${theme}.json"
    local custom="${_NAMING_DATA_DIR}/themes/custom.json"

    # Start with theme agents
    local -A agents=()
    if [[ -f "$theme_file" ]]; then
        while IFS=$'\t' read -r key val; do
            [[ -n "$key" ]] && agents["$key"]="$val"
        done < <(jq -r '.agents // {} | to_entries[] | [.key, .value] | @tsv' "$theme_file" 2>/dev/null)
    fi

    # Override with custom
    if _name_custom_enabled && [[ -f "$custom" ]]; then
        while IFS=$'\t' read -r key val; do
            [[ -n "$key" ]] && agents["$key"]="$val"
        done < <(jq -r '.agents // {} | to_entries[] | [.key, .value] | @tsv' "$custom" 2>/dev/null)
    fi

    # Output sorted
    for key in $(printf '%s\n' "${!agents[@]}" | sort); do
        printf '%s\t%s\n' "$key" "${agents[$key]}"
    done
}

# List all named agencies in the active theme + custom overrides.
# Output: agency_type\tdisplay_name (TSV, one per line).
_name_list_agencies() {
    _name_enabled || return 0
    command -v jq &>/dev/null || return 0

    local theme
    theme=$(_name_theme)
    local theme_file="${_NAMING_DATA_DIR}/themes/${theme}.json"
    local custom="${_NAMING_DATA_DIR}/themes/custom.json"

    local -A agencies=()
    if [[ -f "$theme_file" ]]; then
        while IFS=$'\t' read -r key val; do
            [[ -n "$key" ]] && agencies["$key"]="$val"
        done < <(jq -r '.agencies // {} | to_entries[] | [.key, .value] | @tsv' "$theme_file" 2>/dev/null)
    fi

    if _name_custom_enabled && [[ -f "$custom" ]]; then
        while IFS=$'\t' read -r key val; do
            [[ -n "$key" ]] && agencies["$key"]="$val"
        done < <(jq -r '.agencies // {} | to_entries[] | [.key, .value] | @tsv' "$custom" 2>/dev/null)
    fi

    for key in $(printf '%s\n' "${!agencies[@]}" | sort); do
        printf '%s\t%s\n' "$key" "${agencies[$key]}"
    done
}

# Get the active theme name.
_name_active_theme() {
    _name_theme
}
