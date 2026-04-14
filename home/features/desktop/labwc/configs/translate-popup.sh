#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
#  translate-popup.sh — Wayland çeviri popup'ı (v4)
#
#  Tek trans çağrısı · Pango yok · Otomatik dil algılama
#  Kavram öğrenme odaklı kelime görünümü
# ─────────────────────────────────────────────────────────
set -euo pipefail

APP_NAME="translate"
TIMEOUT_WORD=20000
TIMEOUT_PHRASE=30000

# ── 1. Metni al ─────────────────────────────────────────
text=$(wl-paste -p 2>/dev/null || true)
if [ -z "$text" ]; then
    text=$(wl-paste 2>/dev/null || true)
fi

text=$(printf '%s' "$text" | tr '\n\r\t' '   ' | sed 's/  */ /g; s/^ //; s/ $//')

if [ -z "$text" ]; then
    notify-send -a "$APP_NAME" -t 3000 "Çeviri" "Seçili metin bulunamadı."
    exit 0
fi

# ── 2. Kelime mi, cümle mi? ─────────────────────────────
word_count=$(echo "$text" | wc -w)

if [ "$word_count" -le 2 ]; then
    # ═════════════════════════════════════════════════════
    #  KELİME MODU
    # ═════════════════════════════════════════════════════
    #
    # BAYRAKLAR:
    #   -show-dictionary y         → "Translations of" bölümü: tür + Türkçe anlamlar (İSTENEN)
    #   -show-original-dictionary n → "Definitions of" bölümü: İngilizce tanımlar (İSTENMEYEN)
    #   -show-alternatives n       → Alternatif çeviriler (İSTENMEYEN)
    #
    # Çıktı yapısı:
    #   inatçı                      ← ana çeviri
    #   Translations of obstinate   ← başlık → ATLA
    #   [ English -> Türkçe ]       ← başlık → ATLA
    #   adjective                   ← tür (indent 0)
    #       inatçı                  ← Türkçe anlam (indent 4)
    #           stubborn, obstinate ← İng. eşanlamlı (indent 8+) → ATLA
    #       dik kafalı              ← Türkçe anlam (indent 4)
    #           obstinate, pig...   ← İng. eşanlamlı (indent 8+) → ATLA

    raw=$(trans -no-ansi -no-theme -no-init \
          -show-original n \
          -show-translation y \
          -show-original-phonetics n \
          -show-translation-phonetics n \
          -show-prompt-message n \
          -show-languages n \
          -show-original-dictionary n \
          -show-dictionary y \
          -show-alternatives n \
          -t tr -- "$text" 2>/dev/null) || {
        notify-send -a "$APP_NAME" -t 5000 "Hata" "Bağlantı kurulamadı."
        exit 1
    }

    if [ -z "$raw" ]; then
        notify-send -a "$APP_NAME" -t 5000 "Hata" "Sonuç alınamadı."
        exit 1
    fi

    # ── Ana çeviri ───────────────────────────────────────
    main_tr=$(echo "$raw" \
            | sed '/^$/d' \
            | sed 's/^[[:space:]]*//' \
            | grep -v -i -E '^\[|translations of|definitions of' \
            | head -n1)

    # ── Sözlük parse ────────────────────────────────────
    types_re="^(noun|verb|adjective|adverb|pronoun|preposition|conjunction|interjection|determiner|exclamation|abbreviation|prefix|suffix|phrase|combining form)$"

    overview="$main_tr"       # tüm anlamlar: "inatçı, dik kafalı, dirençli"
    overview_count=1
    types_section=""           # tür satırları: "adjective — inatçı, dik kafalı"
    current_type=""
    type_meanings=""

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        echo "$line" | grep -q -i -E '^\[|translations of|definitions of' && continue

        stripped=$(echo "$line" | sed 's/^[[:space:]]*//')
        [ -z "$stripped" ] && continue

        leading="${line%%[! ]*}"
        indent=${#leading}

        # indent >= 8 → İngilizce eşanlamlılar → ATLA
        [ "$indent" -ge 8 ] && continue

        # indent 0 ve tür etiketi → yeni bölüm
        if [ "$indent" -eq 0 ]; then
            lc=$(echo "$stripped" | tr '[:upper:]' '[:lower:]')
            if echo "$lc" | grep -qE "$types_re"; then
                # Önceki türü flush et
                if [ -n "$current_type" ] && [ -n "$type_meanings" ]; then
                    types_section+="${current_type} — ${type_meanings}"$'\n'
                fi
                current_type="$stripped"
                type_meanings=""
                continue
            fi
        fi

        # indent 1-7 → Türkçe anlam
        if [ "$indent" -ge 1 ] && [ "$indent" -lt 8 ]; then
            # Tür satırına ekle
            if [ -n "$type_meanings" ]; then
                type_meanings+=", ${stripped}"
            else
                type_meanings="$stripped"
            fi

            # Overview'a ekle (tekrar yoksa, max 5)
            if [ "$overview_count" -lt 8 ]; then
                lc_s=$(echo "$stripped" | tr '[:upper:]' '[:lower:]')
                lc_o=$(echo "$overview" | tr '[:upper:]' '[:lower:]')
                if ! echo "$lc_o" | grep -qF "$lc_s"; then
                    overview+=", ${stripped}"
                    overview_count=$((overview_count + 1))
                fi
            fi
        fi
    done <<< "$raw"

    # Son türü flush et
    if [ -n "$current_type" ] && [ -n "$type_meanings" ]; then
        types_section+="${current_type} — ${type_meanings}"$'\n'
    fi

    # ── Bildirim gövdesini oluştur ───────────────────────
    #
    # Yapı:
    #   → inatçı, dik kafalı, dirençli, inadına giden    ← kavram genişliği
    #                                                      ← boşluk
    #   adjective — inatçı, dik kafalı, inadına giden     ← gramer detayı
    #   noun — inatçı kimse                                ← gramer detayı

    body="→ ${overview}"

    if [ -n "$types_section" ]; then
        body+=$'\n\n'"${types_section}"
    fi

    # Sondaki boş satırı temizle
    body=$(echo "$body" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

    notify-send -a "$APP_NAME" -t "$TIMEOUT_WORD" "$text" "$body"

else
    # ═════════════════════════════════════════════════════
    #  CÜMLE MODU
    # ═════════════════════════════════════════════════════
    translation=$(trans -b -no-ansi -no-theme -no-init \
                  -t tr -- "$text" 2>/dev/null) || {
        notify-send -a "$APP_NAME" -t 5000 "Hata" "Bağlantı kurulamadı."
        exit 1
    }

    if [ -z "$translation" ]; then
        notify-send -a "$APP_NAME" -t 5000 "Hata" "Sonuç alınamadı."
        exit 1
    fi

    short="$text"
    [ "${#text}" -gt 80 ] && short="${text:0:77}..."

    # Orijinal ile çeviri arasına boşluk
    body=$'\n'"${translation}"

    notify-send -a "$APP_NAME" -t "$TIMEOUT_PHRASE" "$short" "$body"
fi
