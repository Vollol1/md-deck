/**
 * Adds PDF bookmarks (outline) to a decktape-exported reveal.js PDF.
 * Parses the reveal.js markdown file to extract chapter/slide structure.
 *
 * Usage: node scripts/pdf-bookmarks.js [presentation.md] [input.pdf] [output.pdf]
 *
 * The markdown must use:
 *   ---   (horizontal separator → new slide column)
 *   --    (vertical separator  → sub-slide)
 *   #     (chapter heading     → top-level bookmark)
 *   ##    (slide heading       → nested bookmark under last chapter)
 */

import { readFileSync, writeFileSync } from 'fs';
import { PDFDocument, PDFName, PDFHexString, PDFNumber } from 'pdf-lib';

const mdFile = process.argv[2] || 'slides.md';
const pdfIn  = process.argv[3] || mdFile.replace(/\.md$/, '.pdf');
const pdfOut = process.argv[4] || pdfIn;

// ── 1. Parse slides and extract headings ────────────────────────────────────

function parseSlides(md) {
	const slides = [];
	let page = 1;

	// Split horizontal groups first (--- separator), then vertical (-- separator).
	// Order: horizontal split first so that --- is not re-matched by --.
	for (const hGroup of md.split(/\n[ \t]*---[ \t]*\n/)) {
		for (const slide of hGroup.split(/\n[ \t]*--[ \t]*\n/)) {
			const m = slide.match(/^(#{1,3})\s+(.+)$/m);
			slides.push({
				page,
				level: m ? m[1].length : 0,
				title: m ? m[2].replace(/\*\*/g, '').trim() : null,
			});
			page++;
		}
	}

	return slides;
}

// ── 2. Build hierarchical bookmark tree ─────────────────────────────────────

function buildTree(slides) {
	const roots = [];
	let lastH1 = null;

	for (const s of slides) {
		if (!s.title) continue;
		if (s.level === 1) {
			lastH1 = { ...s, children: [] };
			roots.push(lastH1);
		} else if (s.level === 2 && lastH1) {
			lastH1.children.push({ ...s });
		}
	}

	return roots;
}

// ── 3. Embed bookmarks into PDF via pdf-lib ──────────────────────────────────

async function addBookmarks(pdfBytes, slides) {
	const doc   = await PDFDocument.load(pdfBytes);
	const pages = doc.getPages();
	const ctx   = doc.context;
	const tree  = buildTree(slides);

	if (tree.length === 0) {
		console.warn('No chapter headings found — no bookmarks added.');
		return pdfBytes;
	}

	// /Fit destination: fits the full page in the viewer window (ideal for slides)
	const fitDest = (pageNum) => {
		const idx = Math.max(0, Math.min(pageNum - 1, pages.length - 1));
		return ctx.obj([pages[idx].ref, PDFName.of('Fit')]);
	};

	// Pre-allocate all refs so forward references work
	for (const h1 of tree) {
		h1.ref = ctx.nextRef();
		for (const h2 of h1.children) h2.ref = ctx.nextRef();
	}
	const outlineRef = ctx.nextRef();

	// Register child (h2) items
	for (const h1 of tree) {
		for (let i = 0; i < h1.children.length; i++) {
			const c = h1.children[i];
			ctx.assign(c.ref, ctx.obj({
				Title:  PDFHexString.fromText(c.title),
				Parent: h1.ref,
				Dest:   fitDest(c.page),
				...(i > 0                          && { Prev: h1.children[i - 1].ref }),
				...(i < h1.children.length - 1     && { Next: h1.children[i + 1].ref }),
			}));
		}
	}

	// Register top-level (h1) items
	for (let i = 0; i < tree.length; i++) {
		const h1 = tree[i];
		const nc = h1.children.length;
		ctx.assign(h1.ref, ctx.obj({
			Title:  PDFHexString.fromText(h1.title),
			Parent: outlineRef,
			Dest:   fitDest(h1.page),
			// Count negative = collapsed by default; positive = expanded
			...(nc > 0 && { First: h1.children[0].ref, Last: h1.children[nc - 1].ref, Count: PDFNumber.of(-nc) }),
			...(i > 0             && { Prev: tree[i - 1].ref }),
			...(i < tree.length - 1 && { Next: tree[i + 1].ref }),
		}));
	}

	// Register outline root
	ctx.assign(outlineRef, ctx.obj({
		Type:  PDFName.of('Outlines'),
		First: tree[0].ref,
		Last:  tree[tree.length - 1].ref,
		Count: PDFNumber.of(tree.length),
	}));

	// Hook outline into document catalog
	doc.catalog.set(PDFName.of('Outlines'), outlineRef);
	doc.catalog.set(PDFName.of('PageMode'),  PDFName.of('UseOutlines'));

	return doc.save();
}

// ── Main ─────────────────────────────────────────────────────────────────────

const slides = parseSlides(readFileSync(mdFile, 'utf8'));

console.log(`Parsed ${slides.length} slides from ${mdFile}`);
const chapters = slides.filter(s => s.level === 1);
console.log(`Found ${chapters.length} top-level chapters:`);
chapters.forEach(s => console.log(`  Page ${String(s.page).padStart(3)}: ${s.title}`));

addBookmarks(readFileSync(pdfIn), slides).then(bytes => {
	writeFileSync(pdfOut, bytes);
	console.log(`\nBookmarks written → ${pdfOut}`);
});
