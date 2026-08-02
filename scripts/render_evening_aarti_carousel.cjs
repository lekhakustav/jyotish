const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const date = process.argv[2] || "2026-08-02";
const base = path.join(root, "Instagram", date, "evening-aarti");
const content = JSON.parse(fs.readFileSync(path.join(base, "carousel-copy.json"), "utf8"));
const sharp = require(process.env.SHARP_MODULE || "sharp");
const totalSlides = 3;

const palette = {
  canvas: "#F4ECDD",
  card: "#FFFDF7",
  ink: "#3B1F14",
  muted: "#7A5C48",
  accent: "#B9331F",
  gold: "#B8860B",
  hairline: "rgba(184,134,11,0.28)"
};

const fontCss = `
  @font-face{font-family:FrauncesLocal;src:url('../../brand/fonts/Fraunces-Regular.ttf') format('truetype');font-weight:400}
  @font-face{font-family:FrauncesLocal;src:url('../../brand/fonts/Fraunces-Bold.ttf') format('truetype');font-weight:700}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-Regular.ttf') format('truetype');font-weight:400}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-SemiBold.ttf') format('truetype');font-weight:600}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-Bold.ttf') format('truetype');font-weight:700}
  .serif{font-family:FrauncesLocal,'Nirmala UI',serif}
  .sans{font-family:InterLocal,'Nirmala UI',sans-serif}
  .bilingual{font-family:FrauncesLocal,'Nirmala UI',serif}
`;

const escapeXml = (value) => String(value)
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;");

function dimensions(kind) {
  return kind === "tiktok"
    ? {
        width: 1080, height: 1920, cardX: 34, cardY: 42, cardW: 1012, cardH: 1836,
        logoY: 72, headerY: 96, dateY: 136, pageY: 104,
        introTitleY: 560, introTitleSize: 100, introTitleGap: 116, introSubY: 900, introCueY: 1580,
        labelY: 360, titleY: 450, titleSize: 78, titleGap: 92, titleRuleY: 650, lineStartY: 820, lineGap: 105, bodySize: 52,
        cueY: 1515, progressY: 1818, headerRuleOffset: 32, introRuleOffset: 62, brandSize: 32, dateSize: 26, pageSize: 25, cueSize: 32, subtitleSize: 50
      }
    : {
        width: 1080, height: 1350, cardX: 28, cardY: 28, cardW: 1024, cardH: 1294,
        logoY: 56, headerY: 82, dateY: 116, pageY: 88,
        introTitleY: 380, introTitleSize: 88, introTitleGap: 98, introSubY: 645, introCueY: 1100,
        labelY: 220, titleY: 320, titleSize: 60, titleGap: 72, titleRuleY: 485, lineStartY: 620, lineGap: 84, bodySize: 40,
        cueY: 1100, progressY: 1268, headerRuleOffset: 30, introRuleOffset: 54, brandSize: 28, dateSize: 23, pageSize: 21, cueSize: 30, subtitleSize: 40
      };
}

function logoData() {
  return `data:image/png;base64,${fs.readFileSync(path.join(base, "brand", "jyotish-logo-transparent.png")).toString("base64")}`;
}

function shell(inner, page, kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${d.width}" height="${d.height}" viewBox="0 0 ${d.width} ${d.height}">
    <defs>
      <style>${fontCss}</style>
      <filter id="softShadow" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="9" stdDeviation="13" flood-color="#7A5C48" flood-opacity=".10"/></filter>
    </defs>
    <rect width="${d.width}" height="${d.height}" fill="${palette.canvas}"/>
    <rect x="${d.cardX}" y="${d.cardY}" width="${d.cardW}" height="${d.cardH}" rx="34" fill="${palette.card}" stroke="${palette.hairline}" stroke-width="2" filter="url(#softShadow)"/>
    <image href="${logoData()}" x="${d.cardX + 30}" y="${d.logoY}" width="54" height="54" opacity=".92"/>
    <text x="${center}" y="${d.headerY}" text-anchor="middle" class="sans" font-size="${d.brandSize}" font-weight="700" letter-spacing="3" fill="${palette.accent}">JYOTISH BAJE</text>
    <text x="${center}" y="${d.dateY}" text-anchor="middle" class="sans" font-size="${d.dateSize}" font-weight="600" letter-spacing="2" fill="${palette.muted}">${escapeXml(content.date)}</text>
    <text x="${d.cardX + d.cardW - 30}" y="${d.pageY}" text-anchor="end" class="sans" font-size="${d.pageSize}" font-weight="600" fill="${palette.muted}">${String(page).padStart(2, "0")} / ${String(totalSlides).padStart(2, "0")}</text>
    <line x1="${d.cardX + 38}" y1="${d.dateY + d.headerRuleOffset}" x2="${d.cardX + d.cardW - 38}" y2="${d.dateY + d.headerRuleOffset}" stroke="${palette.hairline}" stroke-width="2"/>
    ${inner}
  </svg>`;
}

function progress(page, kind) {
  const d = dimensions(kind);
  const step = 68;
  const width = 64;
  const start = (d.width - (step * (totalSlides - 1) + width)) / 2;
  return Array.from({ length: totalSlides }, (_, index) => {
    const x = Math.round(start + index * step);
    const active = index < page;
    return `<line x1="${x}" y1="${d.progressY}" x2="${x + width}" y2="${d.progressY}" stroke="${active ? palette.accent : palette.gold}" stroke-opacity="${active ? ".92" : ".22"}" stroke-width="7" stroke-linecap="round"/>`;
  }).join("");
}

function intro(kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  const titleParts = content.intro.title.split(" / ");
  const titleMarkup = kind === "tiktok"
    ? `<text x="${center}" y="${d.introTitleY}" text-anchor="middle" class="bilingual" font-size="${d.introTitleSize}" font-weight="700" fill="${palette.accent}"><tspan x="${center}" dy="0">${escapeXml(titleParts[0])} /</tspan><tspan x="${center}" dy="${d.introTitleGap}">${escapeXml(titleParts[1])}</tspan></text>`
    : `<text x="${center}" y="${d.introTitleY}" text-anchor="middle" class="bilingual" font-size="${d.introTitleSize}" font-weight="700" fill="${palette.accent}"><tspan x="${center}" dy="0">${escapeXml(titleParts[0])} /</tspan><tspan x="${center}" dy="${d.introTitleGap}">${escapeXml(titleParts[1])}</tspan></text>`;
  return shell(`
    ${titleMarkup}
    <text x="${center}" y="${d.introSubY}" text-anchor="middle" class="serif" font-size="${d.subtitleSize}" fill="${palette.ink}">${escapeXml(content.intro.subtitle)}</text>
    <line x1="${kind === "tiktok" ? 300 : 350}" y1="${d.introSubY + d.introRuleOffset}" x2="${kind === "tiktok" ? 780 : 730}" y2="${d.introSubY + d.introRuleOffset}" stroke="${palette.hairline}" stroke-width="2"/>
    <text x="${center}" y="${d.introCueY}" text-anchor="middle" class="sans" font-size="${d.cueSize}" font-weight="600" fill="${palette.accent}">${escapeXml(content.intro.cue)}</text>
    ${progress(1, kind)}
  `, 1, kind);
}

function aartiSlide(aarti, index, kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  const titleParts = aarti.title.split(" / ");
  const titleMarkup = kind === "tiktok"
    ? `<text x="${center}" y="${d.titleY}" text-anchor="middle" class="bilingual" font-size="${d.titleSize}" font-weight="700" fill="${palette.accent}"><tspan x="${center}" dy="0">${escapeXml(titleParts[0])} /</tspan><tspan x="${center}" dy="${d.titleGap}">${escapeXml(titleParts[1])}</tspan></text>`
    : `<text x="${center}" y="${d.titleY}" text-anchor="middle" class="bilingual" font-size="${d.titleSize}" font-weight="700" fill="${palette.accent}"><tspan x="${center}" dy="0">${escapeXml(titleParts[0])} /</tspan><tspan x="${center}" dy="${d.titleGap}">${escapeXml(titleParts[1])}</tspan></text>`;
  const lineMarkup = aarti.lines.map((line, lineIndex) => `<text x="${center}" y="${d.lineStartY + lineIndex * d.lineGap}" text-anchor="middle" class="serif" font-size="${d.bodySize}" fill="${palette.ink}">${escapeXml(line)}</text>`).join("");
  return shell(`
    <text x="${center}" y="${d.labelY}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 23 : 18}" font-weight="700" letter-spacing="3" fill="${palette.accent}">${escapeXml(aarti.label)}</text>
    ${titleMarkup}
    <line x1="${kind === "tiktok" ? 250 : 330}" y1="${d.titleRuleY}" x2="${kind === "tiktok" ? 830 : 750}" y2="${d.titleRuleY}" stroke="${palette.hairline}" stroke-width="2"/>
    ${lineMarkup}
    <text x="${center}" y="${d.cueY}" text-anchor="middle" class="sans" font-size="${d.cueSize}" font-weight="600" fill="${palette.accent}">${escapeXml(aarti.cue)}</text>
    ${progress(index + 2, kind)}
  `, index + 2, kind);
}

async function renderContactSheet(pngPaths, kind) {
  const d = dimensions(kind);
  const thumbWidth = kind === "tiktok" ? 360 : 432;
  const thumbHeight = Math.round(thumbWidth * d.height / d.width);
  const columns = 3;
  const rows = Math.ceil(pngPaths.length / columns);
  const composites = [];
  for (let index = 0; index < pngPaths.length; index += 1) {
    const input = await sharp(pngPaths[index]).resize(thumbWidth, thumbHeight, { fit: "fill" }).png().toBuffer();
    composites.push({ input, left: (index % columns) * thumbWidth, top: Math.floor(index / columns) * thumbHeight });
  }
  await sharp({ create: { width: columns * thumbWidth, height: rows * thumbHeight, channels: 4, background: palette.canvas } })
    .composite(composites)
    .png()
    .toFile(path.join(base, "proof", `${kind}-evening-aarti-contact-sheet.png`));
}

async function renderKind(kind) {
  const exportDir = path.join(base, "exports", kind === "tiktok" ? "01-tiktok" : "02-instagram");
  const svgDir = path.join(base, "design-source", kind);
  fs.mkdirSync(exportDir, { recursive: true });
  fs.mkdirSync(svgDir, { recursive: true });
  const slides = [intro(kind), ...content.aartis.map((aarti, index) => aartiSlide(aarti, index, kind))];
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
  const formatReference = path.join(root, "Instagram", "2026-08-02");
  const assetReference = path.join(root, "Instagram", "2026-08-01", "weekly-mantra");
  fs.mkdirSync(path.join(base, "brand", "fonts"), { recursive: true });
  copyIfMissing(path.join(formatReference, "brand", "jyotish-logo-transparent.png"), path.join(base, "brand", "jyotish-logo-transparent.png"));
  for (const font of fs.readdirSync(path.join(assetReference, "brand", "fonts"))) {
    copyIfMissing(path.join(assetReference, "brand", "fonts", font), path.join(base, "brand", "fonts", font));
  }
  fs.mkdirSync(path.join(base, "proof"), { recursive: true });
  const results = {};
  for (const kind of ["tiktok", "instagram"]) results[kind] = await renderKind(kind);
  console.log(JSON.stringify({ date, slideCount: totalSlides, format: "cream-rashifal-style-aarti", results }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
