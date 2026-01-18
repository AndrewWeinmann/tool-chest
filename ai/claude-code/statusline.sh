#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL=$(echo "$input" | jq -r '.model.display_name')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed')
PERCENT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd')

# Git branch detection
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 🌿 $BRANCH"
    fi
fi

# Format lines changed
CODE_DISPLAY=""
if [ "$LINES_ADDED" != "null" ] && [ "$LINES_REMOVED" != "null" ]; then
    CODE_DISPLAY=" | 💾 +$LINES_ADDED/-$LINES_REMOVED"
fi

# Formal context usage percentage
PERCENT_DISPLAY=" | 🧠 $PERCENT_USED%"

# Format cost (show in cents if under $1)
COST_DISPLAY=""
if [ "$COST" != "null" ] && [ -n "$COST" ]; then
    COST_DISPLAY=$(printf " | 💲%.2f" "$COST")
fi

echo "$MODEL$GIT_BRANCH$CODE_DISPLAY${PERCENT_DISPLAY}$COST_DISPLAY"
