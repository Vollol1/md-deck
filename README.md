# md-deck

> Write and version Reveal.js presentations in Markdown, export them as PDF — no PowerPoint, no binaries.

This repo provides a **generic** reveal.js presentation engine with a pluggable theme system. Use it as a Git submodule in project repos — presentation content stays in the respective project, while the engine, CSS, and build tools live here centrally.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [Submodule Mode (Recommended)](#submodule-mode-recommended)
  - [Standalone Mode](#standalone-mode)
- [Usage](#usage)
  - [Preview](#preview)
  - [Export to PDF](#export-to-pdf)
- [File Structure](#file-structure)
- [Theming](#theming)
  - [Using a Theme](#using-a-theme)
  - [Creating a Custom Theme](#creating-a-custom-theme)
  - [Available Theme Variables](#available-theme-variables)
  - [Branding Elements](#branding-elements)
- [Markdown Syntax](#markdown-syntax)
- [Managing Decks](#managing-decks)
  - [Creating a New Deck](#creating-a-new-deck)
  - [Multiple Decks in One Project](#multiple-decks-in-one-project)
  - [Project README as a Presentation](#project-readme-as-a-presentation)
  - [Customizing the Browser Tab Title](#customizing-the-browser-tab-title)
- [Keeping the Submodule Up to Date](#keeping-the-submodule-up-to-date)
- [Known Issues](#known-issues)

## Prerequisites

Choose **Docker** (recommended) or **npm**:

**Docker (recommended):** No Node.js needed locally.
- **Docker ≥ 24** with the Compose plugin — install via [docs.docker.com](https://docs.docker.com/get-docker/)

**npm:** Run Vite and decktape directly on your machine.
- **Node.js ≥ 20** — install via [nodejs.org](https://nodejs.org/en/download), `nvm`, or `fnm`
- **npm** — bundled with Node.js; reveal.js is loaded from npm automatically

Verify your npm installation:

```bash
node --version   # >= v20 -> ok
npm --version
```

> **Tip:** Use [nvm](https://github.com/nvm-sh/nvm) or [fnm](https://github.com/Schniz/fnm) to manage Node versions — avoids permission issues and makes switching versions easy.

## Setup

### Submodule Mode (Recommended)

Use this when you want to separate your presentation content from the engine. Your slides live in the parent project (`../slides/`), not inside the submodule.

```
my-project/
├── slides/           # ← your decks go here
│   ├── my-deck.md
│   └── ...
└── decks/            # ← git submodule (md-deck engine)
```

**Setup:**

```bash
# In your project directory
git submodule add git@github.com:Vollol1/md-deck.git decks
git submodule update --init

cd decks
./setup.sh           # Creates ../slides/ and ../deck.env

cp slides/template.md ../slides/my-deck.md   # Create your first deck
```

> **Why a sibling `slides/` folder?** `docker compose` mounts `../slides` by default. This keeps your content separate from the engine and prevents conflicts when updating the submodule.

### Standalone Mode

Use this when you want to keep everything in one repository (slides inside the engine directory).

```bash
# Clone the repository
git clone git@github.com:Vollol1/md-deck.git
cd md-deck

# Run setup (creates ./slides/ and .env)
./setup.sh

# Create your first deck
cp slides/template.md slides/my-deck.md

# Start preview
docker compose up preview
# → http://localhost:5173 shows deck picker
```

## Usage

### Preview

**Docker (recommended):**
```bash
cd decks  # if using submodule mode
docker compose up preview
# → http://localhost:5173 shows deck picker
```

**npm:**
```bash
cd decks && npm install && npm start
# → http://localhost:5173 shows deck picker
# your deck: http://localhost:5173/?md=slides/my-deck.md
# with theme: http://localhost:5173/?md=slides/my-deck.md&theme=example
```

### Export to PDF

**Docker (recommended):** No separate dev server needed.

```bash
# cd decks (submodule mode) or cd md-deck (standalone)
DECK=my-deck.md docker compose run --rm export
# → writes ../slides/my-deck.pdf (submodule) or ./slides/my-deck.pdf (standalone)
```

**npm:** The dev server must be running first (`npm start`).

```bash
# In a second terminal:
DECK=slides/my-deck npm run export:pdf
# → reads ../slides/my-deck.md, writes ../slides/my-deck.pdf
```

> **Note:** On first run, decktape downloads Chromium (~100 MB). Subsequent exports are faster.

**Custom Themes in PDF:**

To include your custom theme in the PDF export:

```bash
THEME=example DECK=my-deck.md docker compose run --rm export
```

## File Structure

```sh
my-project/
├── slides/              # ← put presentations here (project repo)
│   ├── my-deck.md       # project-specific decks
│   └── ...
└── decks/               # git submodule → slide engine
    ├── README.md
    ├── CONTRIBUTING.md
    ├── Dockerfile         # Alpine-based, includes Chromium for PDF export
    ├── docker-compose.yml # preview + export services
    ├── entrypoint.sh      # starts Vite or exports PDF
    ├── .dockerignore      # build context exclusions
    ├── index.html
    ├── package.json
    ├── vite.config.js
    ├── themes/
    │   ├── base.css     # generic base theme (always loaded)
    │   └── example.css  # documented starting point for your own brand
    ├── scripts/
    │   └── pdf-bookmarks.js
    └── slides/
        └── template.md  # starting point / template (copy this, don't edit)
```

When running without `?md=` parameter, a deck picker lists all `.md` files in `slides/`.

## Theming

The engine uses a **base + override** theme system powered by CSS custom properties (design tokens).

### Using a Theme

Add `?theme=<name>` to the URL. The engine loads `themes/<name>.css` on top of `themes/base.css`.

```
http://localhost:5173/?md=slides/my-deck.md&theme=example
```

Without a `?theme=` parameter, only the neutral `base.css` is loaded.

### Creating a Custom Theme

1. Create a new CSS file in `themes/` (e.g. `themes/my-brand.css`)
2. Import the base theme and override only the variables you need:

```css
/* themes/my-brand.css */
@import 'base.css';

:root {
  --slide-primary:      #1a3c6e;   /* your brand color */
  --slide-accent:       #e04040;   /* your accent */
  --slide-bg:           #ffffff;
  --slide-font:         'Inter', system-ui, sans-serif;
  --slide-footer:       "My Company · contact@example.com";
  --slide-title-suffix: ' | My Brand';
  --slide-title-default: 'My Brand Presentation';
  --slide-logo:         url('../assets/my-brand/logo.png');
  --slide-sidebar:      url('../assets/my-brand/sidebar.jpg');
  --slide-padding-left:  108px;    /* wider padding for sidebar */
}
```

3. Open with `?theme=my-brand` — done!

### Available Theme Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `--slide-primary` | Headings, primary elements | `#2d2d2d` |
| `--slide-accent` | Bullets, borders, code accents | `#555` |
| `--slide-accent-bg` | Subtle backgrounds, alternating rows | `#f0f0f0` |
| `--slide-bg` | Viewport background | `#fafafa` |
| `--slide-text` | Body text | `#333` |
| `--slide-muted` | Secondary text, footer, slide number | `#888` |
| `--slide-link` | Link color | `#2a6ebb` |
| `--slide-link-hover` | Link hover color | `#1a4e8a` |
| `--slide-font` | Body font stack | `system-ui, sans-serif` |
| `--slide-font-heading` | Heading font (falls back to `--slide-font`) | `var(--slide-font)` |
| `--slide-font-mono` | Monospace font for code | `ui-monospace, Menlo` |
| `--slide-logo` | Logo image URL (set to `url(...)` to show) | `none` |
| `--slide-sidebar` | Left sidebar image URL (set to `url(...)` to show) | `none` |
| `--slide-footer` | Footer text string | `''` |
| `--slide-title-suffix` | Appended to browser tab title | `''` |
| `--slide-title-default` | Tab title when no deck is selected | `'Presentation'` |
| `--slide-padding-left` | Left padding (increase for sidebar) | `20px` |
| `--slide-padding-right` | Right padding | `20px` |

### Branding Elements

The base theme provides three branding containers that are automatically populated when the corresponding CSS variables are set:

- **Logo** (top-right) — shown when `--slide-logo` is set to a `url(...)`
- **Sidebar** (left) — shown when `--slide-sidebar` is set to a `url(...)`
- **Footer** (bottom-center) — shown when `--slide-footer` is non-empty

No need to edit `index.html` — just set the CSS variables in your theme file.

## Markdown Syntax

| Separator | Meaning |
| --- | --- |
| `---` | New horizontal slide (new chapter) |
| `--` | New vertical slide (sub-slide, same context) |
| `# Title` | Chapter heading → top-level bookmark in PDF |
| `## Title` | Slide title → nested bookmark in PDF |

Keyboard shortcuts in the browser: `←`/`→` navigate · `S` presenter notes · `F` fullscreen · `O` overview.

## Managing Decks

### Creating a New Deck

Copy `decks/slides/template.md` as a starting point:

```bash
# cd <my-project>
cp decks/slides/template.md slides/my-deck.md
```

Then open in the browser:

```
http://localhost:5173/?md=slides/my-deck.md
```

Or use the deck picker at `http://localhost:5173` to select from available decks.

### Multiple Decks in One Project

Add multiple `.md` files to `slides/` — one per topic or event:

```
slides/
├── my-deck.md           # project kickoff
├── architecture.md      # architecture docs
└── sprint-review.md     # sprint review
```

Each deck is independent and can be exported to PDF individually. The deck picker at `http://localhost:5173` lists all available decks.

### Project README as a Presentation

Create a symlink to use the project README directly as a deck:

```bash
# cd <my-project>
ln -s ../README.md slides/readme.md
# → http://localhost:5173/?md=slides/readme.md
```

> **Note:** The symlink target path is relative to the `slides/` directory, so `../README.md` resolves to the project root.

### Customizing the Browser Tab Title

The tab title is derived from the filename and the active theme's `--slide-title-suffix`.
E.g. `?md=slides/my-deck.md&theme=example` becomes `my-deck | Example`.
Without a `?md=` parameter, the title comes from `--slide-title-default` (default: "Presentation").

## Using an External Theme Directory (Wrapper Repos)

The engine is deliberately brand-neutral. To keep your own branding and decks
out of this repository, use a **wrapper repo** that pulls the engine in as a
submodule:

```sh
my-decks/
├── slides/         # your presentations
├── themes/         # your brand themes (CSS + logo in the same folder)
├── deck.env        # SLIDES_DIR=../slides, THEME_DIR=../themes
├── run-deck.sh
└── decks/          # git submodule → this engine
```

Run `./decks/setup.sh` once: in wrapper mode it creates `../deck.env` with both
`SLIDES_DIR` and `THEME_DIR`, plus a `themes/README.md` explaining the convention.

What makes this work:

- `THEME_DIR` (default `./themes`) points at your wrapper's theme folder.
- The engine serves `/themes/<file>` from `THEME_DIR` **first**, then falls back
  to its own `themes/`. So your `base.css` import and your themes both resolve.
- `index.html` resolves `url(...)` values **relative to the theme CSS file**,
  so a theme and its assets must live in the same directory — but that
  directory can be anywhere.

```bash
# in the wrapper repo
docker compose --env-file deck.env up preview      # or: ./run-deck.sh
DECK=my-deck.md THEME=mybrand docker compose --env-file deck.env run --rm export
```

## Keeping the Submodule Up to Date

Pull engine updates (CSS themes, bug fixes) from upstream:

```bash
cd decks
git pull origin main
# update the submodule pointer in the project repo
cd ..
git add decks
git commit
```

## Known Issues

- **decktape and themes** — decktape renders the page as-is. If your override theme sets branding elements (logo, sidebar), make sure to include the `?theme=` parameter in the export URL.
- **First PDF export is slow** — decktape downloads Chromium on first run (~100 MB). Subsequent exports are fast.
