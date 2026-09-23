# Contributing

Contributions are welcome — whether it's theme improvements, bug fixes, or documentation.

## Changing code (developers)

1. **Create a feature branch**
   ```bash
   git checkout -b feature/my-change
   ```

2. **Make your changes** — edit files in `themes/`, `scripts/`, or other engine files.

3. **Test** — start the dev server and verify your changes:
   ```bash
   npm start
   # → http://localhost:5173/?md=slides/template.md
   ```

4. **Commit**
   ```bash
   git add .
   git commit -m "feat: short description of the change"
   ```

5. **Open a pull request**
   Push the branch, open a PR on [GitHub](https://github.com/Vollol1/md-deck).

## Creating a new theme

See the [Theming section in README.md](README.md#creating-a-custom-theme) for instructions.

Themes go in `themes/` — just a CSS file that imports `base.css` and overrides CSS custom properties.

## Reporting issues

Open an issue on [GitHub](https://github.com/Vollol1/md-deck/issues) with:
- What you expected
- What happened instead
- Steps to reproduce (ideally a sample `.md` file)