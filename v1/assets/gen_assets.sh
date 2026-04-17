#!/bin/bash

# gen_assets.sh
# Rekurzivno prolazi folder i generira ASSETS JSON za assets index.html
# Upotreba: ./gen_assets.sh [folder]
# Default folder: . (trenutni direktorij)

ROOT="${1:-.}"
IMG_EXTS="png jpg jpeg gif webp svg"
HTML_EXTS="html htm"

get_type() {
  local ext="${1##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  for e in $IMG_EXTS; do
    [[ "$ext" == "$e" ]] && echo "img" && return
  done
  for e in $HTML_EXTS; do
    [[ "$ext" == "$e" ]] && echo "html" && return
  done
  echo "other"
}

echo "const ASSETS = ["

# Pronađi sve direktorije rekurzivno, sortirano
find "$ROOT" -type d | sort | while read -r dir; do
  # Preskoči root dir
  [[ "$dir" == "$ROOT" ]] && continue

  # Relativni path foldera
  rel_dir="${dir#$ROOT/}"

  # Pronađi sve fileove u TOM direktoriju (ne rekurzivno)
  files=$(find "$dir" -maxdepth 1 -type f | sort)

  # Preskoči ako nema fileova
  [[ -z "$files" ]] && continue

  echo "  {"
  echo "    folder: '${rel_dir}',"
  echo "    files: ["

  first=1
  while IFS= read -r file; do
    name=$(basename "$file")
    # Preskoči skrivene fileove
    [[ "$name" == .* ]] && continue

    type=$(get_type "$name")
    rel_path="${file#$ROOT/}"

    comma=""
    [[ $first -eq 0 ]] && comma=","
    first=0

    echo "      ${comma}{ name: '${name}', path: '${rel_path}', type: '${type}' }"
  done <<< "$files"

  echo "    ]"
  echo "  },"
done

echo "];"