# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `THEME_DIR` — serve themes from an external directory (takes precedence over
  the engine's own `themes/`), enabling wrapper repos that ship their own brand
  without patching the engine
- `themes/example.css` — documented starting point for a custom brand theme
- `run-deck.sh` auto-detects the engine in `decks/` or `../md-deck/`, with
  `DECK_ENGINE_DIR` override for other layouts
- README section on wrapper repos and external theme directories

### Removed
- Brand-specific themes and the associated logo asset — the engine is now
  brand-neutral; shipping your own branding is the job of a wrapper repo

### Changed
- `setup.sh` writes both `SLIDES_DIR` and `THEME_DIR` to `deck.env` and creates
  a `themes/README.md` in wrapper mode
- Theme serving accepts assets (images, fonts), not just CSS
- `THEME` documented without the `.css` extension

## [0.1.0] - 12.05.2026

### Added
- Initial release of md-deck
- Docker-based presentation engine using Reveal.js
- Markdown-to-PDF export with PDF bookmarks
- Theme system with CSS custom properties
- Standalone and Git submodule modes
- Setup script with auto-detection of mode
- `deck.env` configuration file for submodule projects
- `template.md` example presentation

### Features
- **Presentations**: Write slides in Markdown with `---` horizontal and `--` vertical separators
- **Themes**: Base theme with override capability (`?theme=name` URL parameter)
- **Branding**: Logo, sidebar image, and footer via CSS variables
- **PDF Export**: decktape integration with PDF bookmarks for navigation
- **Deck Picker**: Browser-based deck selection when no `?md=` parameter
- **Docker**: Alpine-based image with Chromium for PDF generation

### Fixed
- PDF export in standalone mode (no root-owned directories)
- PDF export in submodule mode (correct source directory detection)
- `template.md` export now works in both modes
- Permission issues with output directory

### Documentation
- Comprehensive README with setup instructions
- CONTRIBUTING.md with development guidelines
- MIT License
