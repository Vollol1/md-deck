import { defineConfig } from 'vite';
import { existsSync, createReadStream, readdirSync, statSync } from 'fs';
import { resolve, dirname, extname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const isDirectory = (p) => {
  try { return statSync(p).isDirectory(); } catch { return false; }
};

const CONTENT_TYPES = {
  '.css':   'text/css; charset=utf-8',
  '.png':   'image/png',
  '.jpg':   'image/jpeg',
  '.jpeg':  'image/jpeg',
  '.svg':   'image/svg+xml',
  '.gif':   'image/gif',
  '.webp':  'image/webp',
  '.woff':  'font/woff',
  '.woff2': 'font/woff2',
  '.ttf':   'font/ttf',
  '.otf':   'font/otf',
};

const contentTypeFor = (p) =>
  CONTENT_TYPES[extname(p).toLowerCase()] || 'application/octet-stream';

export default defineConfig({
  server: {
    port: 5173,
    fs: { allow: ['..'] },
  },
  plugins: [{
    name: 'serve-parent-slides',
    configureServer(server) {
      // Vite normalizes browser URLs: '../slides/file.md' becomes '/slides/file.md'.
      // This middleware serves /slides/ requests first from the parent slides/
      // directory (project repo), falling back to decks/slides/ otherwise.
      server.middlewares.use((req, res, next) => {
        const url = req.url?.split('?')[0];

        // Deck list for the browser picker
        if (url === '/api/slides') {
          // Docker: slides at /slides/ (parent of /decks/); npm: slides/ inside project
          const parentDir = resolve(__dirname, '..', 'slides');
          const localDir  = resolve(__dirname, 'slides');
          const collect = (dir) => existsSync(dir)
            ? readdirSync(dir, { recursive: true })
                .map(f => f.toString())
                .filter(f => f.endsWith('.md'))
            : [];
          const files = [...new Set([
            ...collect(parentDir),
            ...collect(localDir),
          ])].sort();
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify(files));
          return;
        }

        if (!url?.startsWith('/slides/')) {
          // Vite does not serve .ico from the project root, so /favicon.ico
          // would 404 even though the file exists. Serve it explicitly.
          if (url === '/favicon.ico') {
            const ico = resolve(__dirname, 'favicon.ico');
            if (existsSync(ico)) {
              res.setHeader('Content-Type', 'image/x-icon');
              createReadStream(ico).pipe(res);
              return;
            }
          }

          // Serve theme files (CSS, logos) from the external theme directory
          // first, falling back to the engine's own themes/ directory.
          //
          // This is what makes wrapper repos possible: a wrapper sets
          // THEME_DIR=../themes and ships its own theme CSS plus assets.
          // Because index.html resolves url(...) values relative to the
          // theme CSS file, a theme and its logo just need to live in the
          // same directory — no engine changes required per brand.
          if (url?.startsWith('/themes/')) {
            const rel = url.slice('/themes/'.length);
            const themeDir = process.env.THEME_DIR || './themes';
            const candidates = [
              resolve(__dirname, themeDir, rel),
              resolve(__dirname, rel),
            ];
            const themeFile = candidates.find(p => existsSync(p));
            if (themeFile && !isDirectory(themeFile)) {
              res.setHeader('Content-Type', contentTypeFor(themeFile));
              createReadStream(themeFile).pipe(res);
              return;
            }
          }
          return next();
        }

        const parentFile = resolve(__dirname, '..', url.slice(1));
        if (existsSync(parentFile)) {
          res.setHeader('Content-Type', 'text/markdown; charset=utf-8');
          createReadStream(parentFile).pipe(res);
          return;
        }

        // Fallback: serve from slides/ inside the project (local npm dev)
        const localFile = resolve(__dirname, url.slice(1));
        if (existsSync(localFile)) {
          res.setHeader('Content-Type', 'text/markdown; charset=utf-8');
          createReadStream(localFile).pipe(res);
          return;
        }

        // Markdown file was requested but not found in either location.
        // Return 404 instead of Vite's SPA fallback so the browser/reveal.js
        // shows a clear failure instead of re-rendering index.html.
        res.statusCode = 404;
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.end(`Slide not found: ${url}\nChecked: /slides/ and /decks/slides/`);
        return;

      });
    },
  }],
});