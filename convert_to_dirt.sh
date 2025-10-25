#!/usr/bin/env bash
set -u
set -o pipefail

# Convert all Uxn PCM banks to SuperDirt WAV banks.
# Input:  uxn/{11025,22050}/<bank>/*.pcm (8-bit unsigned, mono)
# Output: dirt/{11,22}_<bank>/<originalname>.wav (16-bit signed, mono, 44.1kHz)

INPUT_ROOT="uxn"
OUTPUT_ROOT="dirt"
STRICT_NAMES="${STRICT_NAMES:-0}"  # 0 = sanitize illegal names, 1 = abort on them

command -v sox >/dev/null 2>&1 || {
  echo "Error: sox not installed. Try: sudo apt install sox" >&2
  exit 1
}

LOG_ERR="$OUTPUT_ROOT/convert_errors.log"
MAP_LOG="$OUTPUT_ROOT/name_map.tsv"
mkdir -p "$OUTPUT_ROOT"
: >"$LOG_ERR"
: >"$MAP_LOG"

short_rate_for() {
  case "$1" in
    */11025/*) echo "11" ;;
    */22050/*) echo "22" ;;
    *) echo "" ;;
  esac
}

sr_for() {
  case "$1" in
    */11025/*) echo "11025" ;;
    */22050/*) echo "22050" ;;
    *) echo "" ;;
  esac
}

is_windows_reserved_basename() {
  local b="$1"
  shopt -s nocasematch
  if [[ "$b" =~ ^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$ ]]; then
    shopt -u nocasematch
    return 0
  fi
  shopt -u nocasematch
  return 1
}

has_windows_illegal_chars() {
  [[ "$1" =~ [\<\>\:\"\/\\\|\?\*] ]]
}

sanitize_basename() {
  local in="$1"
  local out="${in//[<>:\"/\\|?*]/_}"
  if is_windows_reserved_basename "$out"; then
    out="_$out"
  fi
  printf "%s" "$out"
}

process_bank_dir() {
  local bank_dir="$1"
  local sr_short sr_val bank_name out_dir total ok fail
  sr_short="$(short_rate_for "$bank_dir")"
  sr_val="$(sr_for "$bank_dir")"
  [[ -z "$sr_short" || -z "$sr_val" ]] && return 0

  bank_name="$(basename "$bank_dir")"
  out_dir="$OUTPUT_ROOT/${sr_short}_${bank_name}"
  mkdir -p "$out_dir"

  echo "Converting $bank_name (${sr_val} Hz) → $out_dir"

  total=0; ok=0; fail=0
  while IFS= read -r -d '' src; do
    ((total++))
    base="$(basename "$src")"
    stem="${base%.*}"
    out_base="${stem}.wav"

    if has_windows_illegal_chars "$out_base" || is_windows_reserved_basename "$out_base"; then
      if [[ "$STRICT_NAMES" == "1" ]]; then
        echo "  fail  $base (illegal on Windows; STRICT_NAMES=1)" | tee -a "$LOG_ERR" >/dev/null
        ((fail++))
        continue
      else
        safe="$(sanitize_basename "$out_base")"
        if [[ "$safe" != "$out_base" ]]; then
          printf "%s\t%s\n" "$out_base" "$safe" >>"$MAP_LOG"
          out_base="$safe"
        fi
      fi
    fi

    dst="$out_dir/$out_base"
    if sox -t raw -r "$sr_val" -c 1 -e unsigned -b 8 "$src" \
            -t wav -r 44100 -c 1 -e signed -b 16 "$dst" \
            gain -n -1 dither -s 2>>"$LOG_ERR"; then
      printf "   ok   %s\n" "$out_base"
      ((ok++))
    else
      echo "  fail  $base (see $LOG_ERR)" >&2
      ((fail++))
    fi
  done < <(find "$bank_dir" -maxdepth 1 -type f -iname '*.pcm' -print0 | sort -z)

  echo "  summary: $ok ok, $fail failed (total $total)"
}

for rate_dir in "$INPUT_ROOT/11025" "$INPUT_ROOT/22050"; do
  [[ -d "$rate_dir" ]] || continue
  while IFS= read -r -d '' bank; do
    process_bank_dir "$bank"
  done < <(find "$rate_dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
done

echo "✅ Done. Output under $OUTPUT_ROOT/{11,22}_<bank>/"
[[ -s "$LOG_ERR" ]] && echo "⚠️  Some errors logged to $LOG_ERR"
[[ -s "$MAP_LOG" ]] && echo "ℹ️  Sanitized names logged to $MAP_LOG"
