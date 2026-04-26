#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
START_FILE="$STATE_DIR/focus.start"
TASK_FILE="$STATE_DIR/focus.task"
DURATION_SEC=1500   # 25 dakika
MIN_RECORD_SEC=120  # 2 dakikadan kısa kayda geçmesin
TIMER_UNIT="focus-end"

# ─────────────────────────────────────────────────────────
# start: rofi aç, görev seç, sayacı başlat
# ─────────────────────────────────────────────────────────
cmd_start() {
    # Zaten aktifse hiçbir şey yapma
    [ -f "$START_FILE" ] && exit 0

    # Kalmış timer varsa temizle (önceki çalışmadan artmış olabilir)
    systemctl --user stop "${TIMER_UNIT}.timer" 2>/dev/null || true
    systemctl --user stop "${TIMER_UNIT}.service" 2>/dev/null || true

    # Geçmiş görevleri timew'den çek
local tags
    tags=$(timew export 2>/dev/null \
        | jq -r '.[].tags[]?' \
        | sort -u \
        || true)
    # Rofi ile seçtir (yeni de yazılabilir)
    local choice
    choice=$(echo "$tags" | rofi -dmenu -i -p "Görev") || exit 0
    [ -z "$choice" ] && exit 0

    # State'i yaz
    date +%s > "$START_FILE"
    echo "$choice" > "$TASK_FILE"

    # 25 dk sonra otomatik stop
    systemd-run --user --quiet \
        --unit="$TIMER_UNIT" \
        --on-active="${DURATION_SEC}s" \
        "$0" stop
}

# ─────────────────────────────────────────────────────────
# stop: timew'e geriye dönük yaz, dosyaları sil
# ─────────────────────────────────────────────────────────
cmd_stop() {
    # Zaten boştaysa hiçbir şey yapma
    [ -f "$START_FILE" ] || exit 0

    # Timer'ı iptal et (varsa)
    systemctl --user stop "${TIMER_UNIT}.timer" 2>/dev/null || true
    systemctl --user stop "${TIMER_UNIT}.service" 2>/dev/null || true

    local start
    local now
    local task
    start=$(cat "$START_FILE")
    now=$(date +%s)
    task=$(cat "$TASK_FILE")
    local elapsed=$((now - start))

    # 2 dk altıysa kaydetme, sadece sıfırla
    if [ "$elapsed" -ge "$MIN_RECORD_SEC" ]; then
        local start_iso
        local end_iso
        start_iso=$(date -u -d "@$start" +"%Y%m%dT%H%M%SZ")
        end_iso=$(date -u -d "@$now" +"%Y%m%dT%H%M%SZ")
        timew track "$start_iso" - "$end_iso" "$task" >/dev/null 2>&1 || true
    fi

    rm -f "$START_FILE" "$TASK_FILE"
}

# ─────────────────────────────────────────────────────────
# status: waybar'ın saniyede bir çağırdığı şey
# ─────────────────────────────────────────────────────────
cmd_status() {
    if [ ! -f "$START_FILE" ]; then
        printf '{"text":"","tooltip":""}\n'
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

    # Görev rengi: teal-ish, süre rengi: açık gri
    local text
    text=$(printf "<span color='#9bc1bb'> %s</span> <span color='#c3c3bd'>%s</span>" \
        "$task" "$time_str")

    printf '{"text":"%s","tooltip":""}\n' "$text"
}

# ─────────────────────────────────────────────────────────
case "${1:-status}" in
    start)  cmd_start ;;
    stop)   cmd_stop ;;
    status) cmd_status ;;
    *) echo "kullanım: $0 {start|stop|status}" >&2; exit 1 ;;
esac
