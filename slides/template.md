# md-deck

### Presentations as Code

Note:
Welcome! If you're reading this, you found the speaker notes. Press S anytime to open the full speaker view with timer and next slide preview. Your audience will never see this. Magic!

---

## Why?

Because your slides deserve version control too.

Note:
Think about it: How many times did you lose that one important slide in a PowerPoint backup somewhere? Git has your back here.

--

## Why?

Because copying from old decks is easier than opening PowerPoint.

Note:
Be honest. We've all been there. Ctrl+C, Ctrl+V, done. No clicking through ribbon menus.

--

## Why?

Because Markdown is universal.

Note:
Works on Linux, Mac, Windows. Even on your phone if you're into that sort of thing.

---

## The Philosophy

> Less clicking, more writing.

Note:
The zen approach. Your fingers should do the work, not your mouse.

--

### The Philosophy

Write content in Markdown. Style once with CSS. Reuse everywhere.

Note:
One CSS file, infinite decks. Your brand colors live here, not in every single presentation.

---

## Architecture

### ASCII

```
┌──────────────┐     ┌─────────────────┐
│  slides/     │     │  decks/         │
│  my-deck.md ─┼────►│  (md-deck)      │
│              │     │  index.html     │
│              │     │  themes/        │
│              │     │  vite.config    │
└──────────────┘     └────────┬────────
                              │
                         npm start
                              ▼
                    ┌─────────────────┐
                    │  Vite :5173     │
                    └────────┬────────
                             │
                             ▼
                    ┌─────────────────┐
                    │  reveal.js +    │
                    │  Theme CSS      │
                    └─────────────────┘
```

--

<!-- .slide: style="text-align:center;" -->

### SVG

<div class="r-stretch" style="display:flex;align-items:center;justify-content:center;">
<svg viewBox="0 0 580 280" xmlns="http://www.w3.org/2000/svg" style="width:100%;max-width:700px;height:auto;font-family:system-ui,sans-serif;font-size:13px;">
  <defs>
    <marker id="arr-md" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L0,6 L8,3 z" fill="#c08830"/></marker>
  </defs>
  <rect x="10" y="10" width="270" height="120" rx="8" fill="none" stroke="#3a3a4a" stroke-width="2"/>
  <text x="145" y="32" text-anchor="middle" fill="#3a3a4a" font-weight="700" font-size="14">Your Project</text>
  <rect x="25" y="45" width="100" height="70" rx="6" fill="#f5f0e8" stroke="#c08830" stroke-width="2"/>
  <text x="75" y="68" text-anchor="middle" fill="#3a3a4a" font-weight="600">slides/</text>
  <rect x="35" y="78" width="80" height="28" rx="4" fill="#fff" stroke="#c08830"/>
  <text x="75" y="97" text-anchor="middle" fill="#2d2d2d" font-size="11">my-deck.md</text>
  <rect x="145" y="45" width="125" height="70" rx="6" fill="#faf8f5" stroke="#3a3a4a" stroke-width="2"/>
  <text x="207" y="68" text-anchor="middle" fill="#3a3a4a" font-weight="600">decks/</text>
  <text x="207" y="85" text-anchor="middle" fill="#7a7a8a" font-size="10">index.html</text>
  <text x="207" y="100" text-anchor="middle" fill="#7a7a8a" font-size="10">themes/</text>
  <line x1="125" y1="85" x2="140" y2="85" stroke="#c08830" stroke-width="2" marker-end="url(#arr-md)"/>
  <text x="145" y="155" fill="#7a7a8a" font-size="11">npm start</text>
  <line x1="145" y1="160" x2="145" y2="185" stroke="#3a3a4a" stroke-width="1.5" marker-end="url(#arr-md)"/>
  <rect x="60" y="190" width="170" height="50" rx="8" fill="#f5f0e8" stroke="#c08830" stroke-width="2"/>
  <text x="145" y="212" text-anchor="middle" fill="#3a3a4a" font-weight="700">Vite Server</text>
  <text x="145" y="230" text-anchor="middle" fill="#7a7a8a" font-size="11">localhost:5173</text>
  <line x1="230" y1="215" x2="275" y2="215" stroke="#3a3a4a" stroke-width="1.5" marker-end="url(#arr-md)"/>
  <text x="252" y="208" fill="#7a7a8a" font-size="10">serves</text>
  <rect x="285" y="190" width="170" height="50" rx="8" fill="#fff" stroke="#3a3a4a" stroke-width="2"/>
  <text x="370" y="212" text-anchor="middle" fill="#3a3a4a" font-weight="700">reveal.js</text>
  <text x="370" y="230" text-anchor="middle" fill="#7a7a8a" font-size="11">+ Theme CSS</text>
  <text x="370" y="265" text-anchor="middle" fill="#c08830" font-size="12" font-weight="600">Browser renders this!</text>
</svg>
</div>

Note:
This SVG diagram renders directly in your browser! The architecture shows: your slides/ folder with markdown files, the decks/ submodule containing the engine, Vite dev server, and reveal.js rendering with your theme CSS.

--

### How it Works

1. Write `slides/deck.md`
2. Run `npm start`
3. Open browser at [http://localhost:5173](http://localhost:5173)

That's it.

Note:
No build step. No compilation. Just markdown and a browser. If you need more than 3 commands, something's wrong.

---

## Slide Structure

Horizontal slides use `---`

--

Vertical sub-slides use `--`

--

This creates depth without clutter.

Note:
Think of --- as turning the page. Think of -- as adding a note underneath. Your audience sees one slide at a time, but you know there's more coming.

---

## Example: Horizontal Flow

### Chapter One

Introduction to the topic.

---

## Example: Horizontal Flow

### Chapter Two

Deep dive into details.

Note:
Horizontal sections are your "chapters". Use them to separate major topics. Great for the overview slide!

---

## Example: Vertical Depth

### Overview

Here's what we'll cover:

--

### Point One

First aspect of the topic.

--

### Point Two

Second aspect of the topic.

--

### Summary

Both points together give the full picture.

Note:
Vertical slides are perfect for building up an argument. Start with the question, add points one by one, conclude at the end. Your audience follows naturally.

---

## Code Examples

JavaScript:

```js
const hello = (name) => `Hello, ${name}!`;
```

--

### Code Examples

Python:

```python
def hello(name):
    return f"Hello, ${name}!"
```

--

### Code Examples

Same logic. Different syntax. Your choice.

Note:
Syntax highlighting works for most languages: js, python, rust, go, yaml, json, bash, and many more. Just specify the language after the triple backticks.

---

## Tables

| Feature | Available |
|---------|-----------|
| Markdown | ✓ |
| Themes | ✓ |
| PDF | ✓ |

Note:
Tables are great for comparisons, feature lists, or showing that you've thought about things systematically.

--

### Tables

Here's a fact about tables:

--

They work on mobile too!

Note:
Tables are great for comparisons, feature lists, or showing that you've thought about things systematically.

---

## Fragments

Reveal content step by step:

- Step 1 <!-- .element: class="fragment" -->
- Step 2 <!-- .element: class="fragment" -->
- Step 3 <!-- .element: class="fragment" -->
- Done ✓ <!-- .element: class="fragment" -->

Note:
Fragments build suspense. Use them for:
- Revealing answers after asking questions
- Step-by-step explanations
- Dramatic effect (everyone loves drama)

Press → to see fragments appear one by one on the SAME slide!

Tip: reveal.js provides `highlight-red`, `highlight-green`, `highlight-blue` classes, but these are visible from the start (they only change color when active). For true hide/reveal behavior, use plain `fragment` class.

---

## Speaker Notes

Add `Note:` blocks in your markdown:

```markdown
Some content

Note:
This is only visible in speaker mode (S).
```

--

### Speaker Notes

Press **S** to see them.

Your audience never will.

Note:
Pro tip: Write your script in the notes. Read them in speaker view. Look like you're speaking freely. Nobody will know. (But maybe don't just read word-for-word, that's weird.)

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| S | Speaker mode |
| O | Overview |
| F | Fullscreen |
| Esc | Toggle overview |
| B | Blackout screen |
| → | Next slide |

Note:
S is the most important one. Opens speaker view with notes, timer, and next slide preview.
O shows all slides at once — great for jumping to a specific section.
F for when you need every pixel.
Esc exits fullscreen or toggles overview.
B blanks the screen (press any key to restore) — perfect for Q&A breaks!

---

## Customization

### Colors

```css
:root {
  --slide-primary: #your-color;
}
```

--

### Fonts

```css
:root {
  --slide-font: 'Your Font', sans-serif;
}
```

--

### Branding

```css
:root {
  --slide-footer: 'Your Name';
  --slide-logo: url('logo.png');
}
```

Note:
Check out themes/base.css for all available variables. Copy themes/example.css as a starting point for your own brand. Change one file, all your decks update automatically.

---

## PDF Export

```bash
npm run export:pdf
```

Creates a bookmarked PDF via decktape.

Note:
The dev server must be running. First export downloads Chromium (~100MB), then it's fast. Bookmarks are generated from your # and ## headings automatically.

---

## Getting Started

1. Copy `slides/template.md`
2. Make it yours
3. Present

Note:
Seriously, that's it. The template you're looking at IS the documentation. Copy it, change it, present it.

---

## That's the Spirit

Minimal setup. Maximum flexibility.

### Questions?

Edit this file. See the changes. Repeat.

Note:
Thanks for reading all the way through! You're now officially an md-deck expert. Go forth and present something awesome.

If you found this note helpful (or funny), you're welcome. If not, well — at least you learned something about speaker notes.