#!/usr/bin/env bash
# tw-manager: Timewarrior + Uair + Rofi entegrasyonu

STATE_FILE="${XDG_RUNTIME_DIR}/pomodoro_state"
TASK_LIST="${HOME}/.local/share/pomodoro_tasks.txt"

case "${1:-}" in
    start)
        # 1. Görev listesi yoksa oluştur
        if [ ! -f "$TASK_LIST" ]; then
            mkdir -p "$(dirname "$TASK_LIST")"
            echo -e "Îsâgūcî (Ebherî)\nİsaguci Şerhi (Ferruh Özpilavcı)\nKlasik Mantık (Mizan)\nNixOS / Wayland\nGenel Okuma" > "$TASK_LIST"
        fi

        # 2. Rofi ile görev seçimi
        TASK=$(cat "$TASK_LIST" | rofi -dmenu -p "Ne çalışıyoruz?" -i)
        
        if [ -n "$TASK" ]; then
            # Yeni görevse listeye kalıcı olarak ekle
            if ! grep -Fxq "$TASK" "$TASK_LIST"; then
                echo "$TASK" >> "$TASK_LIST"
            fi
            
            # 3. Durumu kaydet ve Timewarrior'ı GERÇEK ZAMANLI başlat
            echo "$TASK" > "$STATE_FILE"
            timew stop &>/dev/null || true # Önceki açık kalmışsa kapat
            timew start "$TASK"
            
            # 4. Uair'i Çalışma (Work - Index 1) moduna atlat ve başlat
            uairctl jump 1
            uairctl resume
        fi
        ;;
        
    toggle)
        # Sol tık: Duraklat / Devam Et
        if [ -f "$STATE_FILE" ]; then
            # Timewarrior akıyor mu kontrol et
            if timew | grep -q "Tracking"; then
                uairctl toggle
                timew stop
                notify-send -u low "Pomodoro" "Duraklatıldı. Süre donduruldu."
            else
                uairctl toggle
                timew continue
                notify-send -u low "Pomodoro" "Kaldığı yerden devam ediyor."
            fi
        else
            # Eğer sistem inaktifse, Sol tık başlatma menüsünü (Rofi) açar
            "$0" start
        fi
        ;;
        
    stop)
        # Sağ tık: Erken Bitir ve O Ana Kadarki Süreyi Kaydet
        if [ -f "$STATE_FILE" ]; then
            TASK=$(cat "$STATE_FILE")
            timew stop # Timewarrior o ana kadarki kaydı deftere işler
            rm "$STATE_FILE"
            uairctl jump 0 # Uair'i inaktif (Idle) moda çek
            notify-send -u low "Pomodoro İptal" "'$TASK' o ana kadarki süresiyle kaydedildi."
        fi
        ;;
        
    work-done)
        # Süre kendiliğinden (25dk) bittiğinde Uair burayı tetikler
        if [ -f "$STATE_FILE" ]; then
            TASK=$(cat "$STATE_FILE")
            timew stop
            rm "$STATE_FILE"
            notify-send -u critical "Pomodoro Bitti!" "25 dk '$TASK' olarak kaydedildi. Mola zamanı!"
        fi
        ;;
        
    break-done)
        # Mola bittiğinde Uair burayı tetikler
        notify-send -u normal "Mola Bitti!" "Kitap ikonuna tıklayıp yeni göreve başlayabilirsin."
        uairctl jump 0 # İniktif moda dön
        ;;
        
    summary)
        # Orta tık: Terminal açmadan Timewarrior özetini Rofi ile oku
        rofi -e "$(timew summary :week)" -theme-str 'window {width: 600px;} listview {lines: 15;}'
        ;;
        
waybar)
        # 1. Zombi uair süreçlerini temizle (Error 98'i önler)
        pkill -x uair || true
        sleep 0.5 
        
        # 2. Uair çıktısını JQ kullanmadan, saf Bash Regex ile okuyoruz
        uair | while read -r line; do
            [[ -z "$line" ]] && continue
            
            CLASS="idle"
            TIME="00:00"
            
            if [[ "$line" =~ \"class\":\"([^\"]+)\" ]]; then CLASS="${BASH_REMATCH[1]}"; fi
            if [[ "$line" =~ \"time\":\"([^\"]+)\" ]]; then TIME="${BASH_REMATCH[1]}"; fi
            
            if [[ "$CLASS" == "idle" ]] || [ ! -f "$STATE_FILE" ]; then
                echo '{"text": "󰂰", "class": "inactive", "tooltip": "Sol tık: Görev Seç"}'
            elif [[ "$CLASS" == "work" ]]; then
                TASK=$(cat "$STATE_FILE" 2>/dev/null || echo "Odak")
                TEXT="<span color='#d85c60'>󰂰 ${TASK}</span> <span color='#c3c3bd'>${TIME}</span>"
                echo "{\"text\": \"$TEXT\", \"class\": \"work\", \"tooltip\": \"Sol tık: Duraklat/Devam | Sağ tık: Erken Bitir\"}"
            elif [[ "$CLASS" == "break" ]]; then
                TEXT="<span color='#d4d987'>󰂰 Mola</span> <span color='#c3c3bd'>${TIME}</span>"
                echo "{\"text\": \"$TEXT\", \"class\": \"break\", \"tooltip\": \"Mola zamanı...\"}"
            fi
        done
        ;;    esac
