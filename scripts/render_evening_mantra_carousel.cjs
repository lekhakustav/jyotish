const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const date = process.argv[2] || "2026-08-02";
const base = path.join(root, "Instagram", date, "evening-mantra");
const content = JSON.parse(fs.readFileSync(path.join(base, "carousel-copy.json"), "utf8"));
const sharp = require(process.env.SHARP_MODULE || "sharp");
const totalSlides = content.days.length + 1;

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
        width: 1080, height: 1920, headerY: 72, dateY: 102, pageY: 82, logoY: 42,
        titleY: 1240, titleSize: 76, titleGap: 104, omY: 1515,
        dayY: 1280, mantraY: 1430, mantraSize: 72, mantraGap: 100,
        descriptionY: 1660, saveY: 1770, progressY: 1840,
        brandSize: 25, dateSize: 20, pageSize: 22, trySize: 23, descriptionSize: 30, saveSize: 22
      }
    : {
        width: 1080, height: 1350, headerY: 54, dateY: 82, pageY: 64, logoY: 30,
        titleY: 875, titleSize: 60, titleGap: 82, omY: 1080,
        dayY: 900, mantraY: 1025, mantraSize: 56, mantraGap: 78,
        descriptionY: 1170, saveY: 1242, progressY: 1295,
        brandSize: 21, dateSize: 17, pageSize: 20, trySize: 20, descriptionSize: 25, saveSize: 18
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
    <text x="128" y="${d.headerY}" class="sans" font-size="${d.brandSize}" font-weight="700" letter-spacing="3" fill="${palette.gold}" filter="url(#textShadow)">JYOTISH BAJE</text>
    <text x="128" y="${d.dateY}" class="sans" font-size="${d.dateSize}" font-weight="600" letter-spacing="2" fill="${palette.muted}" filter="url(#textShadow)">${escapeXml(content.date)}</text>
    <text x="1008" y="${d.pageY}" text-anchor="end" class="sans" font-size="${d.pageSize}" font-weight="600" fill="${palette.muted}" filter="url(#textShadow)">${String(page).padStart(2, "0")} / ${String(totalSlides).padStart(2, "0")}</text>
    ${constellationSvg(page - 1, kind)}
    ${inner}
  </svg>`;
}

function progress(page, kind) {
  const y = dimensions(kind).progressY;
  return Array.from({ length: totalSlides }, (_, index) => {
    const x = 72 + index * 118;
    const active = index < page;
    return `<line x1="${x}" y1="${y}" x2="${x + 86}" y2="${y}" stroke="${active ? palette.gold : palette.muted}" stroke-opacity="${active ? ".88" : ".28"}" stroke-width="4"/>`;
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
    <text x="${center}" y="${d.titleY}" text-anchor="middle" class="serif" font-size="${d.titleSize}" font-weight="700" fill="${palette.ink}" filter="url(#textShadow)">
      <tspan x="${center}" dy="0">${escapeXml(content.title[0])}</tspan>
      <tspan x="${center}" dy="${d.titleGap}">${escapeXml(content.title[1])}</tspan>
    </text>
    <text x="${center}" y="${d.omY}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 92 : 82}" fill="${palette.gold}" filter="url(#textShadow)">&#x0950;</text>
    ${progress(1, kind)}
  `, 1, kind);
}

function mantraLines(mantra) {
  if (mantra.length > 27) {
    const words = mantra.split(" ");
    const midpoint = Math.ceil(words.length / 2);
    return [words.slice(0, midpoint).join(" "), words.slice(midpoint).join(" ")];
  }
  return [mantra];
}

function daySlide(day, index, kind) {
  const d = dimensions(kind);
  const lines = mantraLines(day.mantra);
  const center = d.width / 2;
  const lineGap = kind === "tiktok" ? 102 : 82;
  const firstMantraY = lines.length === 1 ? d.mantraY + 42 : d.mantraY;
  const descriptionY = lines.length === 1 ? d.descriptionY : d.descriptionY + (kind === "tiktok" ? 58 : 45);
  return shell(`
    <text x="${center}" y="${d.dayY}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 112 : 92}" font-weight="700" fill="${palette.gold}" filter="url(#textShadow)">${escapeXml(day.day)}</text>
    <line x1="270" y1="${d.dayY + 62}" x2="810" y2="${d.dayY + 62}" stroke="${palette.gold}" stroke-opacity=".55"/>
    <text x="${center}" y="${firstMantraY}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 74 : d.mantraSize}" fill="${palette.ink}" filter="url(#textShadow)">${lines.map((line, lineIndex) => `<tspan x="${center}" dy="${lineIndex === 0 ? 0 : lineGap}">${escapeXml(line)}</tspan>`).join("")}</text>
    <text x="${center}" y="${descriptionY - 38}" text-anchor="middle" class="sans" font-size="${d.trySize}" font-weight="700" letter-spacing="3" fill="${palette.gold}" filter="url(#textShadow)">TRY THIS</text>
    <text x="${center}" y="${descriptionY}" text-anchor="middle" class="sans" font-size="${d.descriptionSize}" fill="${palette.muted}" filter="url(#textShadow)">${escapeXml(day.description)}</text>
    <text x="${center}" y="${d.saveY}" text-anchor="middle" class="sans" font-size="${d.saveSize}" font-weight="700" letter-spacing="2" fill="${palette.gold}" filter="url(#textShadow)">SAVE THIS POST FOR TONIGHT →</text>
    ${progress(index + 2, kind)}
  `, index + 2, kind);
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
    .toFile(path.join(base, "proof", `${kind}-evening-mantra-contact-sheet.png`));
}

async function renderKind(kind) {
  const exportDir = path.join(base, "exports", kind === "tiktok" ? "01-tiktok" : "02-instagram");
  const svgDir = path.join(base, "design-source", kind);
  fs.mkdirSync(exportDir, { recursive: true });
  fs.mkdirSync(svgDir, { recursive: true });
  const orderedDays = [content.days.at(-1), ...content.days.slice(0, -1)];
  const slides = [cover(kind), ...orderedDays.map((day, index) => daySlide(day, index, kind))];
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
  console.log(JSON.stringify({ date, slideCount: totalSlides, format: "evening-constellation-with-readable-utility-text", results }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
