# md-deck 1.0.0

Write and version Reveal.js presentations in Markdown, export them as PDF —
no PowerPoint, no binaries.

**1.0 means the interfaces are frozen.** The URL parameters (`?md=`,
`?theme=`), the `deck.env` keys (`SLIDES_DIR`, `THEME_DIR`), the CSS custom
properties and the `run-deck.sh` helper that `setup.sh` generates for wrapper
repos will not change without a major version bump. You can pin this tag and
upgrade on your own schedule.

## Why 1.0

The engine has been in production use in a wrapper repo since 0.1.0: decks
versioned in an application repo, branded via an external theme directory,
exported to PDF for handouts. That setup is stable, so the API is declared
stable with it.

## Highlights

- **Brand-neutral by design.** The engine ships no brand of its own. Branding
  and decks live in a wrapper repo that pulls this in as a submodule — see
  the README section *Using an External Theme Directory*.
- **Themes from anywhere.** `THEME_DIR` serves themes *and their assets*
  (logo images, fonts) from outside the engine, so a wrapper repo can ship
  its own corporate design without patching this repository.
- **PDF with real bookmarks.** `#` headings become top-level PDF bookmarks and
  `##` become nested ones. The catalog carries `/PageMode /UseOutlines`, so
  viewers open the PDF with the bookmark sidebar already expanded.
- **Both Docker and npm.** Docker needs no local Node.js; the npm path works
  if you prefer to run Vite directly.

## Fixed since 0.1.0

- **Branding was never applied when a theme loaded late.** `applyBranding()`
  ran two animation frames after the `?theme=` stylesheet was enabled, but
  stylesheets load asynchronously — the custom properties were still empty at
  that point. So `--slide-logo`, `--slide-footer` and the title suffix had no
  effect. Symptom: a missing logo in both the live presentation and the PDF.
  It now waits for the stylesheet's `load` event.
- **`/favicon.ico` returned 404** even when the file existed, because Vite has
  no mapping for the `.ico` extension. The middleware now serves it
  explicitly.

## Breaking change

Bundled brand-specific themes and their logo asset were removed. The engine now
ships `base.css` and a documented `themes/example.css` as a starting point.

If you were relying on a bundled branded theme, move that CSS and its assets
into your own wrapper repo, point `THEME_DIR` at that folder and pass
`THEME=<name>` (or `?theme=<name>`) as before.

## Upgrading a wrapper repo

The engine files live in the Docker image, not in a mounted volume, so a pull
alone is not enough — rebuild after updating the submodule pointer:

```bash
cd decks
git fetch --tags && git checkout v1.0.0
cd ..
git add decks
git commit -m "Update md-deck to v1.0.0"
docker compose build
```

> The engine is a submodule **two levels deep** in a typical setup
> (`project → wrapper → md-deck`), which means two pins: `git add decks` in the
> wrapper, then `git add <wrapper>` in the project. Clones need
> `--recurse-submodules`.

## Known issue

decktape logs one `404 (Not Found)` per PDF export. It comes from decktape's
own browser requesting `/decktape/favicon.ico`; the dev server answers that
path with the SPA fallback (`index.html`), which is not an image. Cosmetic —
the exported PDF contains all slides, theme assets and bookmarks. Documented
under *Known Issues* in the README.

## Install

```bash
# as a submodule in your project
git submodule add https://github.com/Vollol1/md-deck.git decks
cd decks && ./setup.sh

# or standalone
git clone --branch v1.0.0 https://github.com/Vollol1/md-deck.git
cd md-deck && ./setup.sh
```

MIT licensed.
