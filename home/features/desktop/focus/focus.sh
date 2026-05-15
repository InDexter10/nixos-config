#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
START_FILE="$STATE_DIR/focus.start"
TASK_FILE="$STATE_DIR/focus.task"
DURATION_SEC=1500
MIN_RECORD_SEC=120
TIMER_UNIT="focus-end"

# Resolve focus binary's absolute path for systemd-run's PATH-isolated env
FOCUS_BIN=$(command -v focus 2>/dev/null || echo "$0")

cmd_start() {
    [ -f "$START_FILE" ] && exit 0

    # Cancel only the timer if it's lingering from a previous run.
    # Do NOT stop the .service — that's safe here (we're not inside it).
    systemctl --user stop "${TIMER_UNIT}.timer" 2>/dev/null || true
    systemctl --user reset-failed "${TIMER_UNIT}.service" 2>/dev/null || true

    local entries
    entries=$(timew export 2>/dev/null | jq -r '
        group_by(.tags[0]) | map({
            tag: .[0].tags[0],
            last: (map(.start) | max),
            total: (map(
                ((.end // (now | strftime("%Y%m%dT%H%M%SZ"))) | strptime("%Y%m%dT%H%M%SZ") | mktime)
                - (.start | strptime("%Y%m%dT%H%M%SZ") | mktime)
            ) | add)
        })
        | sort_by(.last) | reverse
        | .[] | "\(.tag)\t\(.total | floor)"
    ' 2>/dev/null || true)

    local rofi_input=""
    while IFS=$'\t' read -r tag secs; do
        [ -z "$tag" ] && continue
        local h=$((secs / 3600))
        local m=$(( (secs % 3600) / 60 ))
        local human
        if [ "$h" -gt 0 ]; then
            human=$(printf '%dh %dm' "$h" "$m")
        else
            human=$(printf '%dm' "$m")
        fi
        rofi_input+=$(printf '%s\t%s  <span foreground="#727b7c" size="small">· %s</span>' \
            "$tag" "$tag" "$human")
        rofi_input+=$'\n'
    done <<< "$entries"

    local raw
    raw=$(printf '%s' "$rofi_input" \
        | rofi -dmenu -i -markup-rows \
            -p "Task" \
            -sep $'\n' \
            -display-columns 2 \
            -input-columns 1) || exit 0

    [ -z "$raw" ] && exit 0

    local task
    task=$(printf '%s' "$raw" \
        | awk -F'\t' '{print $1}' \
        | sed 's|<[^>]*>||g' \
        | sed 's|^[[:space:]]*||; s|[[:space:]]*$||')

    [ -z "$task" ] && exit 0

    date +%s > "$START_FILE"
    echo "$task" > "$TASK_FILE"

    # Use absolute path; "auto-stop" tells the script not to suicide
systemd-run --user --quiet \
        --unit="$TIMER_UNIT" \
        --on-active="${DURATION_SEC}s" \
        --setenv=PATH="$PATH" \
        "$FOCUS_BIN" auto-stop

    #notify-send -a focus "Focus started" \
     #   "$(printf '%s — 25 min' "$task")"
}

# mode = "manual" (right-click) | "auto" (timer-triggered)
cmd_stop() {
    local mode="${1:-manual}"

    [ -f "$START_FILE" ] || exit 0

    if [ "$mode" = "manual" ]; then
        systemctl --user stop "${TIMER_UNIT}.timer" 2>/dev/null || true
    fi

    local start
    local now
    local task
    start=$(cat "$START_FILE")
    now=$(date +%s)
    task=$(cat "$TASK_FILE")
    local elapsed=$((now - start))

    if [ "$elapsed" -gt "$DURATION_SEC" ]; then
        elapsed=$DURATION_SEC
        now=$((start + DURATION_SEC))
    fi

    local mins=$((elapsed / 60))
    local secs=$((elapsed % 60))

    # Remove state files FIRST so the bar updates immediately
    rm -f "$START_FILE" "$TASK_FILE"

    # Then do the slow work (timew + notification)
    if [ "$elapsed" -ge "$MIN_RECORD_SEC" ]; then
        local start_iso
        local end_iso
        start_iso=$(date -u -d "@$start" +"%Y%m%dT%H%M%SZ")
        end_iso=$(date -u -d "@$now" +"%Y%m%dT%H%M%SZ")
        timew track "$start_iso" - "$end_iso" "$task" >/dev/null 2>&1 || true

        notify-send -a focus "Focus done" \
            "$(printf '%s — %d:%02d logged' "$task" "$mins" "$secs")"
    else
        notify-send -a focus "Focus discarded" \
            "$(printf '%s — under 2 min, not logged' "$task")"
    fi
}
cmd_status() {
    local BOOK
    BOOK=$'📖'

    if [ ! -f "$START_FILE" ]; then
        printf '{"text":"%s","tooltip":""}\n' "$BOOK"
        exit 0
    fi
    local start
    local task
    start=$(cat "$START_FILE")
    task=$(cat "$TASK_FILE")
    local now
    now=$(date +%s)
    local elapsed=$((now - start))
    local remaining=$((DURATION_SEC - elapsed))
    [ "$remaining" -lt 0 ] && remaining=0

    local mins=$((remaining / 60))
    local secs=$((remaining % 60))
    local time_str
    time_str=$(printf '%02d:%02d' "$mins" "$secs")

    local text
    text=$(printf "<span color='#9bc1bb'>%s %s</span> <span color='#c3c3bd'>%s</span>" \
        "$BOOK" "$task" "$time_str")

    printf '{"text":"%s","tooltip":""}\n' "$text"
}

case "${1:-status}" in
    start)      cmd_start ;;
    stop)       cmd_stop "manual" ;;
    auto-stop)  cmd_stop "auto" ;;
    status)     cmd_status ;;
    *) echo "usage: $0 {start|stop|auto-stop|status}" >&2; exit 1 ;;
esac
