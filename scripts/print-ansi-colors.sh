#!/usr/bin/env bash
# Print standard ANSI 16-color foreground and background codes: name, swatch, and the \e[…m form.

set -euo pipefail

# shellcheck disable=SC2016
esc() { printf ' \e[90m\\e[%sm\e[0m' "$1"; }

# Foreground: SGR in first column, then a sample, then the raw escape in gray.
print_row_fg() {
  local code=$1 name=$2
  printf '\e[%sm %3d  %-20s' "$code" "$code" "$name"
  printf ' Sample text'
  esc "$code"
  printf '\n'
}

# Background: same SGR in first column, sample with a contrasting default foreground.
print_row_bg() {
  local code=$1 name=$2
  local fgc
  fgc=$3
  printf '\e[%sm %3d  %-20s' "$code" "$code" "$name"
  printf '\e[%sm' "$fgc"
  printf ' Sample text'
  printf '\e[0m'
  esc "$code"
  printf '\n'
}

names_n=(Black Red Green Yellow Blue Magenta Cyan White)

echo "Normal foreground (30–37)"
echo "----"
for i in 0 1 2 3 4 5 6 7; do
  print_row_fg $((30 + i)) "${names_n[$i]}"
done

echo
echo "Bright / high foreground (90–97), often distinct from 30–37 on modern terminals"
echo "----"
for i in 0 1 2 3 4 5 6 7; do
  print_row_fg $((90 + i)) "Bright ${names_n[$i]}"
done

echo
echo "Normal background (40–47)"
echo "----"
# Contrasting text on each: mostly white, black on yellow / bright greens / light backgrounds.
fg_on_bg_n=(37 37 30 30 37 37 30 30)
for i in 0 1 2 3 4 5 6 7; do
  print_row_bg $((40 + i)) "On ${names_n[$i]}" "${fg_on_bg_n[$i]}"
done

echo
echo "Bright / high background (100–107)"
echo "----"
# Dark gray, bright red/green/yellow, blue, magenta, cyan, near-white: pick readable fg.
fg_on_bg_b=(37 30 30 30 37 37 30 30)
for i in 0 1 2 3 4 5 6 7; do
  print_row_bg $((100 + i)) "On bright ${names_n[$i]}" "${fg_on_bg_b[$i]}"
done

echo
echo "Tip: 256 and truecolor are also available (38;5;n, 38;2;r;g;b, 48;5;n, 48;2;r;g;b); not shown here."
exit 0
