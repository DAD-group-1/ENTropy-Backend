#!/usr/bin/env bash
# =============================================================================
# sync-ms-to-gateway.sh
#
# Scans all ENTropy-Backend-MS-*/src directories, collects every
# *.interface.ts and *.dto.ts file, finds matching filenames inside
# ENTropy-Backend-Gateway, and syncs the post-import body block from
# the MS file into the Gateway file when they differ.
#
# Usage:
#   ./sync-ms-to-gateway.sh [ROOT_PATH] [GATEWAY_NAME]
#
# Defaults:
#   ROOT_PATH    = current working directory
#   GATEWAY_NAME = ENTropy-Backend-Gateway
#
# Options (env vars):
#   DRY_RUN=1   simulate without writing anything
#   VERBOSE=1   also log files with no Gateway match
# =============================================================================

set -euo pipefail

# ─── Arguments / config ──────────────────────────────────────────────────────

ROOT_PATH="${1:-$(pwd)}"
GATEWAY_NAME="${2:-ENTropy-Backend-Gateway}"
DRY_RUN="${DRY_RUN:-0}"
VERBOSE="${VERBOSE:-0}"

GATEWAY_ROOT="${ROOT_PATH}/${GATEWAY_NAME}"

# ─── Colours ─────────────────────────────────────────────────────────────────

CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
GRAY='\033[0;37m'
DARK_CYAN='\033[0;34m'
RED='\033[0;31m'
RESET='\033[0m'

# ─── Helpers ─────────────────────────────────────────────────────────────────

# Print the 0-based line index of the last "import " line, or -1 if none.
last_import_index() {
    local file="$1"
    local idx=-1
    local i=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*import[[:space:]] ]]; then
            idx=$i
        fi
        (( i++ )) || true
    done < "$file"
    echo "$idx"
}

# Extract lines AFTER the given 0-based index into stdout.
# If index is -1, print the whole file (no imports found).
body_block() {
    local file="$1"
    local last_import_idx="$2"
    local skip=$(( last_import_idx + 1 ))

    if (( last_import_idx == -1 )); then
        cat "$file"
    else
        tail -n +"$(( skip + 1 ))" "$file"
    fi
}

# Extract lines UP TO AND INCLUDING the given 0-based index.
import_block() {
    local file="$1"
    local last_import_idx="$2"

    if (( last_import_idx == -1 )); then
        return   # no imports — print nothing
    fi
    head -n "$(( last_import_idx + 1 ))" "$file"
}

# ─── Stats ───────────────────────────────────────────────────────────────────

stat_checked=0
stat_synced=0
stat_skipped=0
stat_no_match=0

# ─── Banner ──────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}==================================================${RESET}"
echo -e "${CYAN}  ENTropy MS -> Gateway sync${RESET}"
echo -e "${CYAN}==================================================${RESET}"
echo "  Root    : ${ROOT_PATH}"
echo "  Gateway : ${GATEWAY_NAME}"
[[ "$DRY_RUN" == "1" ]] && echo -e "  Mode    : ${YELLOW}DRY RUN (no files will be written)${RESET}"
echo ""

# ─── 1. Locate MS src directories ────────────────────────────────────────────

mapfile -t MS_SRC_DIRS < <(
    find "$ROOT_PATH" -maxdepth 2 \
        -type d \
        -name 'src' \
        -path '*/ENTropy-Backend-MS-*/src' \
    | sort
)

if [[ ${#MS_SRC_DIRS[@]} -eq 0 ]]; then
    echo -e "${YELLOW}Warning: No 'ENTropy-Backend-MS-*/src' directories found under '${ROOT_PATH}'.${RESET}"
    exit 0
fi

echo -e "${YELLOW}Microservice /src directories found:${RESET}"
for d in "${MS_SRC_DIRS[@]}"; do echo "  $d"; done
echo ""

# ─── 2. Collect *.interface.ts and *.dto.ts from every MS src ────────────────

mapfile -t MS_FILES < <(
    for src in "${MS_SRC_DIRS[@]}"; do
        find "$src" -type f \( -name '*.interface.ts' -o -name '*.dto.ts' \)
    done | sort
)

if [[ ${#MS_FILES[@]} -eq 0 ]]; then
    echo -e "${YELLOW}Warning: No *.interface.ts or *.dto.ts files found.${RESET}"
    exit 0
fi

echo -e "${YELLOW}MS source files collected : ${#MS_FILES[@]}${RESET}"
echo ""

# ─── 3. Verify Gateway root ───────────────────────────────────────────────────

if [[ ! -d "$GATEWAY_ROOT" ]]; then
    echo -e "${RED}Error: Gateway directory not found: '${GATEWAY_ROOT}'${RESET}"
    exit 1
fi

# ─── 4. Index Gateway files: name -> list of full paths ──────────────────────

echo -e "${YELLOW}Indexing Gateway files...${RESET}"

declare -A GW_INDEX   # key = lowercase filename, value = newline-separated paths

while IFS= read -r gw_file; do
    key="${gw_file##*/}"          # basename
    key="${key,,}"                # lowercase
    if [[ -v GW_INDEX["$key"] ]]; then
        GW_INDEX["$key"]+=$'\n'"$gw_file"
    else
        GW_INDEX["$key"]="$gw_file"
    fi
done < <(find "$GATEWAY_ROOT" -type f | sort)

echo "Gateway files indexed     : ${#GW_INDEX[@]} unique names"
echo ""

# ─── 5. Process each MS file ─────────────────────────────────────────────────

for ms_file in "${MS_FILES[@]}"; do
    filename="${ms_file##*/}"
    key="${filename,,}"

    if [[ ! -v GW_INDEX["$key"] ]]; then
        [[ "$VERBOSE" == "1" ]] && echo -e "${GRAY}NO MATCH  : ${ms_file}${RESET}"
        (( stat_no_match++ )) || true
        continue
    fi

    # Parse MS file
    ms_last_import=$(last_import_index "$ms_file")
    ms_body=$(body_block "$ms_file" "$ms_last_import")

    # Iterate over every Gateway match (newline-separated)
    while IFS= read -r gw_path; do
        [[ -z "$gw_path" ]] && continue
        (( stat_checked++ )) || true

        echo -e "${GRAY}Checking  : ${filename}${RESET}"
        echo "  MS      : ${ms_file}"
        echo "  Gateway : ${gw_path}"

        # Parse Gateway file
        gw_last_import=$(last_import_index "$gw_path")
        gw_body=$(body_block "$gw_path" "$gw_last_import")

        # Compare bodies (normalise trailing whitespace per line)
        ms_body_norm=$(echo "$ms_body" | sed 's/[[:space:]]*$//')
        gw_body_norm=$(echo "$gw_body" | sed 's/[[:space:]]*$//')

        if [[ "$ms_body_norm" == "$gw_body_norm" ]]; then
            echo -e "  Status  : ${GREEN}UP-TO-DATE${RESET}"
            (( stat_skipped++ )) || true
            continue
        fi

        echo -e "  Status  : ${YELLOW}OUTDATED  (body differs after last import)${RESET}"

        if [[ -z "$ms_body" ]]; then
            echo -e "  Warning : ${YELLOW}MS file has no content after imports — skipping.${RESET}"
            (( stat_skipped++ )) || true
            continue
        fi

        # Build new content = Gateway import block + MS body block
        if [[ "$DRY_RUN" == "1" ]]; then
            echo -e "  Action  : ${DARK_CYAN}WOULD UPDATE (dry-run)${RESET}"
            (( stat_synced++ )) || true
        else
            {
                import_block "$gw_path" "$gw_last_import"
                echo "$ms_body"
            } > "${gw_path}.tmp"
            mv "${gw_path}.tmp" "$gw_path"
            echo -e "  Action  : ${CYAN}UPDATED${RESET}"
            (( stat_synced++ )) || true
        fi

    done <<< "${GW_INDEX[$key]}"
done

# ─── 6. Summary ──────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}==================================================${RESET}"
echo -e "${CYAN}  Summary${RESET}"
echo -e "${CYAN}==================================================${RESET}"
echo "  Files checked      : ${stat_checked}"
echo -e "  Files synced       : ${CYAN}${stat_synced}${RESET}"
echo -e "  Already up-to-date : ${GREEN}${stat_skipped}${RESET}"
echo -e "  No Gateway match   : ${GRAY}${stat_no_match}${RESET}"
echo ""