#!/bin/sh
set -eu

MODE="${1:-preview}"

# Normalize DECK: strip leading ../, strip trailing .md
DECK_NORM="${DECK:-}"
DECK_NORM="${DECK_NORM#../}"
DECK_NORM="${DECK_NORM%.md}"
DECK_NORM="${DECK_NORM:-slides/template}"

# THEME_DIR is only informational here (vite.config.js resolves it), but we
# report it so failures are diagnosable from the export log.
THEME_DIR="${THEME_DIR:-./themes}"

case "$MODE" in
  preview)
    exec npx vite --host 0.0.0.0 --port 5173
    ;;
  export)
    if [ -z "${DECK:-}" ]; then
      echo "ERROR: Set DECK to the slide file, e.g. DECK=slides/my-deck.md" >&2
      exit 1
    fi

    # Determine source directory (where the MD file lives)
    # /slides/ = user's external slides (submodule mode with SLIDES_DIR=../slides)
    # /decks/slides/ = engine's built-in slides (standalone mode, template.md)
    if [ -f "/slides/${DECK_NORM#slides/}.md" ]; then
      SOURCE_DIR="/slides"
    elif [ -f "/decks/slides/${DECK_NORM#slides/}.md" ]; then
      SOURCE_DIR="/decks/slides"
    else
      echo "ERROR: Slide not found: ${DECK_NORM#slides/}.md" >&2
      echo "Checked: /slides/ and /decks/slides/" >&2
      exit 1
    fi

    MD_FILE="${SOURCE_DIR}/${DECK_NORM#slides/}.md"
    PDF_FILE="${SOURCE_DIR}/${DECK_NORM#slides/}.pdf"
    mkdir -p "$(dirname "$PDF_FILE")"

    # Start Vite in the background and wait until it is ready
    npx vite --host 0.0.0.0 --port 5173 &
    VITE_PID=$!
    echo "Waiting for Vite to start..."
    until curl -sf http://localhost:5173 > /dev/null 2>&1; do sleep 0.5; done

    # URL for decktape - Vite middleware serves /slides/ from either location
    URL="http://localhost:5173/?md=slides/${DECK_NORM#slides/}.md"

    # Append theme if requested
    if [ -n "${THEME:-}" ]; then
      URL="${URL}&theme=${THEME}"
    fi

    echo "Exporting $MD_FILE → $PDF_FILE"
    echo "Theme dir: $THEME_DIR${THEME:+ (theme: $THEME)}"
    npx decktape reveal \
      --size 1680x945 \
      --chrome-arg=--no-sandbox \
      --chrome-arg=--disable-setuid-sandbox \
      "$URL" \
      "$PDF_FILE"
    kill "$VITE_PID" 2>/dev/null || true

    node scripts/pdf-bookmarks.js "$MD_FILE" "$PDF_FILE"

    # Match PDF ownership to the mounted slides directory so the host user can
    # move/delete it without sudo.
    chown "$(stat -c '%u:%g' "$SOURCE_DIR")" "$PDF_FILE" 2>/dev/null || true

    echo "Done: $PDF_FILE"
    ;;
  *)
    echo "Unknown mode: $MODE. Use 'preview' or 'export'." >&2
    exit 1
    ;;
esac
