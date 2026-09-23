# ──────────────────────────────────────────────────────────────────────────────
# md-deck — reveal.js presentation engine (Alpine-based)
#
# Build:  docker build -t md-deck:0.1.0 -t md-deck:latest .
# Preview: docker run --rm -p 5173:5173 md-deck:0.1.0
# Export:  docker run --rm -v $(pwd)/slides:/slides md-deck:0.1.0 export
# ──────────────────────────────────────────────────────────────────────────────

FROM node:20-alpine

LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.title="md-deck"
LABEL org.opencontainers.image.description="Write and version Reveal.js presentations in Markdown, export them as PDF"
LABEL org.opencontainers.image.source="https://github.com/Vollol1/md-deck"

# ── System dependencies ─────────────────────────────────────────────────────
# chromium: decktape/puppeteer rendering
# nss freetype harfbuzz ca-certificates ttf-freefont: Chromium runtime deps
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      curl

# Tell puppeteer/decktape to use the system Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

WORKDIR /decks

# ── Install npm dependencies (cached layer) ─────────────────────────────────
COPY package.json ./
RUN npm install && npm install --save-dev decktape && npm cache clean --force

# ── Copy engine files ────────────────────────────────────────────────────────
COPY index.html vite.config.js ./
COPY themes/ ./themes/
COPY scripts/ ./scripts/
COPY slides/ ./slides/

# Create the dist symlink that postinstall would normally create
RUN ln -sfn node_modules/reveal.js/dist dist

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown -R node:node /decks

USER node

EXPOSE 5173

ENTRYPOINT ["/entrypoint.sh"]
CMD ["preview"]
