const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const date = process.argv[2] || new Date().toISOString().slice(0, 10);
const base = path.join(root, "Instagram", date);
const content = JSON.parse(fs.readFileSync(path.join(base, "carousel-copy.json"), "utf8"));
const edition = content.daily;
const sharp = require(process.env.SHARP_MODULE || "sharp");
const totalSlides = edition.signs.length + 2;

const palette = {
  bg: "#030923",
  ink: "#F7F4FF",
  muted: "#D6DDF4",
  gold: "#F6D483",
  accent: "#A8D7FF"
};

const constellationMaps = [
  { points: [[.18,.12],[.32,.28],[.45,.22],[.58,.36],[.72,.28],[.83,.48],[.65,.57],[.49,.50],[.34,.68]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,3],[7,8],[1,7]] },
  { points: [[.16,.28],[.29,.18],[.43,.31],[.57,.18],[.70,.30],[.82,.22],[.68,.49],[.49,.58],[.31,.48]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8],[8,0],[2,7]] },
  { points: [[.20,.20],[.38,.14],[.55,.26],[.73,.18],[.84,.40],[.63,.47],[.48,.62],[.29,.52]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,0],[2,5]] },
  { points: [[.14,.35],[.27,.18],[.44,.24],[.62,.14],[.78,.30],[.70,.52],[.51,.60],[.32,.51]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,0],[2,6]] },
  { points: [[.23,.14],[.40,.25],[.59,.16],[.79,.32],[.68,.50],[.49,.44],[.34,.62],[.18,.50]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,0],[1,5]] },
  { points: [[.17,.19],[.34,.33],[.50,.17],[.68,.28],[.84,.20],[.74,.45],[.55,.54],[.36,.49]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,0],[1,6]] },
  { points: [[.19,.30],[.31,.16],[.48,.29],[.64,.17],[.81,.34],[.66,.53],[.46,.60],[.27,.51]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,0],[2,6]] },
  { points: [[.16,.22],[.33,.13],[.51,.25],[.69,.16],[.85,.32],[.72,.53],[.52,.46],[.35,.64]], lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,0],[2,5]] }
];

const fontCss = `
  @font-face{font-family:FrauncesLocal;src:url('../../brand/fonts/Fraunces-Regular.ttf') format('truetype');font-weight:400}
  @font-face{font-family:FrauncesLocal;src:url('../../brand/fonts/Fraunces-Bold.ttf') format('truetype');font-weight:700}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-Regular.ttf') format('truetype');font-weight:400}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-SemiBold.ttf') format('truetype');font-weight:600}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-Bold.ttf') format('truetype');font-weight:700}
  .serif{font-family:FrauncesLocal,serif}
  .sans{font-family:InterLocal,sans-serif}
`;

const escapeXml = (value) => String(value)
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;");

function dimensions(kind) {
  return kind === "tiktok"
    ? {
        width: 1080, height: 1920, headerY: 88, pageY: 88, logoY: 52,
        titleY: 1240, titleSize: 76, titleGap: 104, omY: 1515,
        signY: 1270, dateY: 1350, rowStart: 1440, rowGap: 92,
        signSize: 112, dateSize: 21, scoreSize: 64, labelSize: 20,
        bodySize: 28, progressY: 1840, finalMetaY: 1380,
        finalActionStart: 1505, finalActionGap: 82
      }
    : {
        width: 1080, height: 1350, headerY: 72, pageY: 72, logoY: 42,
        titleY: 875, titleSize: 60, titleGap: 82, omY: 1080,
        signY: 870, dateY: 948, rowStart: 1008, rowGap: 66,
        signSize: 92, dateSize: 18, scoreSize: 52, labelSize: 16,
        bodySize: 22, progressY: 1295, finalMetaY: 1005,
        finalActionStart: 1110, finalActionGap: 48
      };
}

function logoData() {
  return `data:image/png;base64,${fs.readFileSync(path.join(base, "brand", "jyotish-logo-transparent.png")).toString("base64")}`;
}

let cachedBackgroundData;
function backgroundData() {
  if (!cachedBackgroundData) {
    cachedBackgroundData = `data:image/png;base64,${fs.readFileSync(path.join(base, "assets", "constellation-background.png")).toString("base64")}`;
  }
  return cachedBackgroundData;
}

function shell(inner, page, kind) {
  const d = dimensions(kind);
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${d.width}" height="${d.height}" viewBox="0 0 ${d.width} ${d.height}">
    <defs>
      <style>${fontCss}</style>
      <linearGradient id="bottomFade" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#020718" stop-opacity="0"/><stop offset=".58" stop-color="#020718" stop-opacity=".08"/><stop offset="1" stop-color="#020718" stop-opacity=".88"/></linearGradient>
      <filter id="textShadow" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="4" stdDeviation="5" flood-color="#000616" flood-opacity=".8"/></filter>
    </defs>
    <image href="${backgroundData()}" x="0" y="0" width="${d.width}" height="${d.height}" preserveAspectRatio="xMidYMid slice"/>
    <rect width="${d.width}" height="${d.height}" fill="#020718" opacity=".18"/>
    <rect width="${d.width}" height="${d.height}" fill="url(#bottomFade)"/>
    <image href="${logoData()}" x="52" y="${d.logoY}" width="58" height="58" opacity=".96"/>
    <text x="1008" y="${d.pageY}" text-anchor="end" class="sans" font-size="20" font-weight="600" fill="${palette.muted}" opacity=".88">${String(page).padStart(2, "0")} / ${String(totalSlides).padStart(2, "0")}</text>
    ${constellationSvg(page - 1, kind)}
    ${inner}
  </svg>`;
}

function progress(page, kind) {
  const y = dimensions(kind).progressY;
  const step = 68;
  const width = 50;
  return Array.from({ length: totalSlides }, (_, index) => {
    const x = 72 + index * step;
    const active = index < page;
    return `<line x1="${x}" y1="${y}" x2="${x + width}" y2="${y}" stroke="${active ? palette.gold : palette.muted}" stroke-opacity="${active ? ".88" : ".28"}" stroke-width="4"/>`;
  }).join("");
}

function constellationSvg(index, kind) {
  const d = dimensions(kind);
  const map = constellationMaps[index % constellationMaps.length];
  const top = kind === "tiktok" ? 155 : 110;
  const mapHeight = kind === "tiktok" ? 980 : 700;
  const xy = ([x, y]) => [Math.round(72 + x * 936), Math.round(top + y * mapHeight)];
  const lines = map.lines.map(([from, to]) => {
    const [x1, y1] = xy(map.points[from]);
    const [x2, y2] = xy(map.points[to]);
    return `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${palette.accent}" stroke-opacity=".56" stroke-width="2"/>`;
  }).join("");
  const stars = map.points.map((point, starIndex) => {
    const [cx, cy] = xy(point);
    return `<circle cx="${cx}" cy="${cy}" r="${starIndex % 3 === 0 ? 6 : 4}" fill="#EAF5FF" opacity=".95"/><circle cx="${cx}" cy="${cy}" r="14" fill="${palette.accent}" opacity=".10"/>`;
  }).join("");
  return `<g>${lines}${stars}</g>`;
}

function cover(kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  return shell(`
    <text x="${center}" y="${d.titleY - 118}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 22 : 18}" font-weight="700" letter-spacing="4" fill="${palette.gold}" filter="url(#textShadow)">${escapeXml(edition.label)}</text>
    <text x="${center}" y="${d.titleY}" text-anchor="middle" class="serif" font-size="${d.titleSize}" font-weight="700" fill="${palette.ink}" filter="url(#textShadow)">
      <tspan x="${center}" dy="0">${escapeXml(edition.hook[0])}</tspan>
      <tspan x="${center}" dy="${d.titleGap}">${escapeXml(edition.hook[1])}</tspan>
    </text>
    <text x="${center}" y="${d.omY}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 92 : 82}" fill="${palette.gold}" filter="url(#textShadow)">&#x0950;</text>
    ${progress(1, kind)}
  `, 1, kind);
}

function bodySize(value, kind) {
  const base = dimensions(kind).bodySize;
  return String(value).length > 48 ? base - 3 : base;
}

function cueRow(label, value, y, kind) {
  const d = dimensions(kind);
  return `<text x="78" y="${y}" class="sans" font-size="${d.labelSize}" font-weight="700" letter-spacing="2" fill="${palette.gold}" filter="url(#textShadow)">${label}</text>
    <text x="250" y="${y}" class="sans" font-size="${bodySize(value, kind)}" fill="${palette.muted}" filter="url(#textShadow)">${escapeXml(value)}</text>`;
}

function signSlide(sign, index, kind) {
  const d = dimensions(kind);
  const page = index + 2;
  const score = Number(sign.rating).toFixed(1);
  return shell(`
    <text x="${d.width / 2}" y="${d.signY}" text-anchor="middle" class="serif" font-size="${d.signSize}" font-weight="700" fill="${palette.gold}" filter="url(#textShadow)">${escapeXml(sign.name)}</text>
    <line x1="270" y1="${d.signY + 62}" x2="810" y2="${d.signY + 62}" stroke="${palette.gold}" stroke-opacity=".55"/>
    <text x="78" y="${d.dateY}" class="sans" font-size="${d.dateSize}" font-weight="600" letter-spacing="3" fill="${palette.muted}" filter="url(#textShadow)">${escapeXml(sign.dates)}</text>
    <text x="1002" y="${d.dateY}" text-anchor="end" class="serif" font-size="${d.scoreSize}" font-weight="700" fill="${palette.gold}" filter="url(#textShadow)">${score} &#9733;</text>
    ${cueRow("LOVE", sign.love, d.rowStart, kind)}
    ${cueRow("WORK", sign.work, d.rowStart + d.rowGap, kind)}
    ${cueRow("ENERGY", sign.energy, d.rowStart + d.rowGap * 2, kind)}
    ${cueRow("LUCKY CUE", sign.cue, d.rowStart + d.rowGap * 3, kind)}
    ${progress(page, kind)}
  `, page, kind);
}

function finalSlide(kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  const actionSize = kind === "tiktok" ? 38 : 27;
  const actions = ["TRY JYOTISH  →", "COMMENT YOUR SIGN  ↓", "SAVE THIS POST  +", "SHARE WITH A FRIEND  →"];
  return shell(`
    <text x="${center}" y="${d.titleY}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 88 : 70}" font-weight="700" fill="${palette.ink}" filter="url(#textShadow)">
      <tspan x="${center}" dy="0">Your chart.</tspan>
      <tspan x="${center}" dy="${d.titleGap}">Explained simply.</tspan>
    </text>
    <text x="${center}" y="${d.finalMetaY}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 25 : 20}" font-weight="700" letter-spacing="3" fill="${palette.gold}" filter="url(#textShadow)">JYOTISH BAJE  •  AI-BASED JYOTISH APP</text>
    ${actions.map((action, index) => `<text x="${center}" y="${d.finalActionStart + index * d.finalActionGap}" text-anchor="middle" class="serif" font-size="${actionSize}" font-weight="700" fill="${palette.gold}" filter="url(#textShadow)">${action}</text>`).join("")}
    <text x="${center}" y="${kind === "tiktok" ? 1810 : 1270}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 21 : 16}" fill="${palette.muted}" filter="url(#textShadow)">AI guidance for reflection, not certainty.</text>
    ${progress(totalSlides, kind)}
  `, totalSlides, kind);
}

async function renderContactSheet(pngPaths, kind) {
  const d = dimensions(kind);
  const thumbWidth = kind === "tiktok" ? 360 : 432;
  const thumbHeight = Math.round(thumbWidth * d.height / d.width);
  const columns = 4;
  const rows = Math.ceil(pngPaths.length / columns);
  const composites = [];
  for (let index = 0; index < pngPaths.length; index += 1) {
    const input = await sharp(pngPaths[index]).resize(thumbWidth, thumbHeight, { fit: "fill" }).png().toBuffer();
    composites.push({ input, left: (index % columns) * thumbWidth, top: Math.floor(index / columns) * thumbHeight });
  }
  await sharp({ create: { width: columns * thumbWidth, height: rows * thumbHeight, channels: 4, background: palette.bg } })
    .composite(composites)
    .png()
    .toFile(path.join(base, "proof", `${kind}-daily-rashifal-contact-sheet.png`));
}

async function renderKind(kind) {
  const exportDir = path.join(base, "exports", kind === "tiktok" ? "01-tiktok" : "02-instagram");
  const svgDir = path.join(base, "design-source", kind);
  fs.mkdirSync(exportDir, { recursive: true });
  fs.mkdirSync(svgDir, { recursive: true });
  const slides = [cover(kind), ...edition.signs.map((sign, index) => signSlide(sign, index, kind)), finalSlide(kind)];
  const pngPaths = [];
  for (let index = 0; index < slides.length; index += 1) {
    const number = String(index + 1).padStart(2, "0");
    const svgPath = path.join(svgDir, `${number}.svg`);
    const pngPath = path.join(exportDir, `${number}.png`);
    fs.writeFileSync(svgPath, slides[index], "utf8");
    await sharp(svgPath).png().toFile(pngPath);
    pngPaths.push(pngPath);
  }
  await renderContactSheet(pngPaths, kind);
  return pngPaths;
}

function copyIfMissing(source, target) {
  if (!fs.existsSync(target)) fs.copyFileSync(source, target);
}

async function main() {
  const formatReference = path.join(root, "Instagram", "2026-08-01", "weekly-mantra");
  fs.mkdirSync(path.join(base, "brand", "fonts"), { recursive: true });
  fs.mkdirSync(path.join(base, "assets"), { recursive: true });
  copyIfMissing(path.join(formatReference, "brand", "jyotish-logo-transparent.png"), path.join(base, "brand", "jyotish-logo-transparent.png"));
  copyIfMissing(path.join(formatReference, "assets", "constellation-background.png"), path.join(base, "assets", "constellation-background.png"));
  for (const font of fs.readdirSync(path.join(formatReference, "brand", "fonts"))) {
    copyIfMissing(path.join(formatReference, "brand", "fonts", font), path.join(base, "brand", "fonts", font));
  }
  fs.mkdirSync(path.join(base, "proof"), { recursive: true });
  const results = {};
  for (const kind of ["tiktok", "instagram"]) results[kind] = await renderKind(kind);
  console.log(JSON.stringify({ date, slideCount: totalSlides, format: "aug-01-constellation", results }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
