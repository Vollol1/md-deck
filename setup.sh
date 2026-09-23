#!/bin/sh
# First-time setup script for md-deck
# Run this after cloning the repository

set -e

echo "md-deck setup\n"

# Detect mode: submodule or standalone
# Submodule: .git is a file (git worktree) or ../.git exists (parent project)
IS_SUBMODULE=0
if [ -f .git ] || [ -d ../.git ]; then
  IS_SUBMODULE=1
fi

# Also check if we're in a directory named 'decks' (common convention)
if [ "$(basename "$(pwd)")" = "decks" ] && [ -d ".." ]; then
  IS_SUBMODULE=1
fi

if [ "$IS_SUBMODULE" -eq 1 ]; then
  echo "Detected: Submodule mode"
  
  # Create parent slides directory if needed
  PARENT_SLIDES="../slides"
  if [ ! -d "$PARENT_SLIDES" ]; then
    echo "Creating ../slides/ directory..."
    mkdir -p "$PARENT_SLIDES"
  fi
  
  # Create ../deck.env for wrapper/submodule configuration
  DECK_ENV="../deck.env"
  if [ ! -f "$DECK_ENV" ]; then
    echo "Creating $DECK_ENV..."
    cat > "$DECK_ENV" << 'EOF'
# md-deck configuration
# Paths relative to the engine directory (decks/) where docker-compose runs
SLIDES_DIR=../slides
THEME_DIR=../themes
EOF
  else
    if ! grep -q "^SLIDES_DIR=" "$DECK_ENV" 2>/dev/null; then
      echo "Adding SLIDES_DIR to existing $DECK_ENV..."
      echo "SLIDES_DIR=../slides" >> "$DECK_ENV"
    else
      echo "SLIDES_DIR already set in $DECK_ENV."
    fi
    if ! grep -q "^THEME_DIR=" "$DECK_ENV" 2>/dev/null; then
      echo "Adding THEME_DIR to existing $DECK_ENV..."
      echo "THEME_DIR=../themes" >> "$DECK_ENV"
    else
      echo "THEME_DIR already set in $DECK_ENV."
    fi
  fi

  # Create parent themes directory and document the convention
  PARENT_THEMES="../themes"
  if [ ! -d "$PARENT_THEMES" ]; then
    echo "Creating $PARENT_THEMES/ directory..."
    mkdir -p "$PARENT_THEMES"
  fi
  if [ ! -f "$PARENT_THEMES/README.md" ]; then
    cat > "$PARENT_THEMES/README.md" << 'EOF'
# Themes

Brand themes for this wrapper. Each theme is a CSS file that imports
`base.css` from the engine and overrides the design tokens.

A theme and its assets (logos, fonts) must live in the **same** directory,
because the engine resolves `url(...)` values relative to the theme CSS file.

Usage: `?theme=<name>` — e.g. `?theme=mybrand` loads `mybrand.css`.
EOF
  fi
  
  # Add .gitignore for generated PDFs in slides directory
  if [ -d "$PARENT_SLIDES" ]; then
    if ! grep -Fxq "*.pdf" "$PARENT_SLIDES/.gitignore" 2>/dev/null; then
      echo "*.pdf" >> "$PARENT_SLIDES/.gitignore"
    fi
  fi

  # Copy a generic run-deck helper into the parent project root so that
  # `docker compose` resolves ${SLIDES_DIR} from deck.env. Docker Compose
  # reads .env only from the directory of docker-compose.yml, not from
  # ../deck.env, so an explicit --env-file is required.
  RUN_DECK="../run-deck.sh"
  if [ ! -f "$RUN_DECK" ]; then
    if [ -f "scripts/run-deck.sh.template" ]; then
      echo "Creating $RUN_DECK..."
      cp "scripts/run-deck.sh.template" "$RUN_DECK"
      chmod +x "$RUN_DECK"
    fi
  else
    echo "$RUN_DECK already exists, skipping."
  fi
  
else
  echo "Detected: Standalone mode"
  
  # Create .env in engine directory
  if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
  else
    echo ".env already exists, skipping."
  fi
  
  # Ensure slides directory exists
  if [ ! -d slides ]; then
    echo "Creating slides/ directory..."
    mkdir -p slides
  fi
fi

# Ensure engine .gitignore has entries
echo "Updating .gitignore..."
touch .gitignore
for entry in .env "*.pdf" node_modules/; do
  if ! grep -Fxq "$entry" .gitignore 2>/dev/null; then
    echo "$entry" >> .gitignore
  fi
done

echo ""
echo "Setup complete!"
echo ""
if [ "$IS_SUBMODULE" -eq 1 ]; then
  echo "Wrapper mode configured:"
  echo "  Config:   ../deck.env (commit to wrapper project)"
  echo "  Slides:   ../slides/"
  echo "  Themes:   ../themes/"
  echo ""
  echo "  Preview:  docker compose up preview"
  echo "  Export:   DECK=my-deck.md docker compose run --rm export"
  echo "  Styled:   DECK=my-deck.md THEME=mybrand docker compose run --rm export"
else
  echo "Standalone mode configured:"
  echo "  Slides: ./slides/"
  echo "  Themes: ./themes/"
  echo "  Preview:  docker compose up preview"
  echo "  Export:   DECK=template.md docker compose run --rm export"
fi