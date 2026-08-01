const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const date = process.argv[2] || "2026-08-01";
const base = path.join(root, "Instagram", date, "weekly-mantra");
const content = JSON.parse(fs.readFileSync(path.join(base, "carousel-copy.json"), "utf8"));
const sharp = require(process.env.SHARP_MODULE || "sharp");

const palette = {
  bg: "#FCF7ED",
  ink: "#3B1F14",
  muted: "#7A5C48",
  gold: "#B8860B",
  red: "#B9331F",
  accents: ["#244A72", "#A04A1B", "#526B32", "#8E5B22", "#A72F50", "#243E72", "#9B4A1C"]
};

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
    ? { width: 1080, height: 1920, headerY: 82, ruleY: 120, pageY: 82, logoY: 155, titleY: 360, titleSize: 72, titleGap: 100, omY: 635, coverCardY: 820, coverCardH: 570, coverDayY: 965, coverMantraY: 1110, cardY: 980, cardH: 480, dayY: 1110, mantraY: 1260, mantraSize: 66, mantraGap: 92 }
    : { width: 1080, height: 1350, headerY: 75, ruleY: 110, pageY: 75, logoY: 145, titleY: 280, titleSize: 70, titleGap: 90, omY: 465, coverCardY: 590, coverCardH: 500, coverDayY: 710, coverMantraY: 855, cardY: 760, cardH: 360, dayY: 865, mantraY: 1010, mantraSize: 55, mantraGap: 78 };
}

function shell(inner, page, kind) {
  const d = dimensions(kind);
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${d.width}" height="${d.height}" viewBox="0 0 ${d.width} ${d.height}">
    <defs><style>${fontCss}</style></defs>
    <rect width="${d.width}" height="${d.height}" fill="${palette.bg}"/>
    <text x="72" y="${d.headerY}" class="sans" font-size="20" font-weight="700" letter-spacing="3" fill="${palette.muted}">JYOTISH</text>
    <text x="1008" y="${d.pageY}" text-anchor="end" class="sans" font-size="20" fill="${palette.muted}">${String(page).padStart(2, "0")} / 07</text>
    <line x1="72" y1="${d.ruleY}" x2="1008" y2="${d.ruleY}" stroke="${palette.gold}" stroke-opacity=".22"/>
    ${inner}
  </svg>`;
}

function logoData() {
  const logoPath = path.join(base, "brand", "jyotish-logo-transparent.png");
  return `data:image/png;base64,${fs.readFileSync(logoPath).toString("base64")}`;
}

function progress(page, kind) {
  const y = kind === "tiktok" ? 1775 : 1240;
  return Array.from({ length: 7 }, (_, index) => {
    const x = 72 + index * 130;
    const active = index < page;
    return `<line x1="${x}" y1="${y}" x2="${x + 92}" y2="${y}" stroke="${active ? palette.red : palette.gold}" stroke-opacity="${active ? ".8" : ".18"}" stroke-width="4"/>`;
  }).join("");
}

function cover(kind) {
  const d = dimensions(kind);
  const logo = logoData();
  const center = d.width / 2;
  const titleSize = d.titleSize;
  return shell(`
    <image href="${logo}" x="72" y="${d.logoY}" width="60" height="60"/>
    <text x="${center}" y="${d.titleY}" text-anchor="middle" class="serif" font-size="${titleSize}" font-weight="700" fill="${palette.red}">
      <tspan x="${center}" dy="0">${escapeXml(content.title[0])}</tspan>
      <tspan x="${center}" dy="${d.titleGap}">${escapeXml(content.title[1])}</tspan>
    </text>
    <text x="${center}" y="${d.omY}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 92 : 82}" fill="${palette.gold}">&#x0950;</text>
    <line x1="250" y1="${d.omY + 55}" x2="830" y2="${d.omY + 55}" stroke="${palette.gold}" stroke-opacity=".36"/>
    ${dayCard(content.days.at(-1), 6, kind, { cardY: d.coverCardY, cardH: d.coverCardH, dayY: d.coverDayY, mantraY: d.coverMantraY })}
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

function dayCard(day, index, kind, overrides = {}) {
  const d = dimensions(kind);
  const color = palette.accents[index];
  const lines = mantraLines(day.mantra);
  const center = d.width / 2;
  const lineGap = kind === "tiktok" ? 102 : 82;
  const cardY = overrides.cardY ?? d.cardY;
  const cardH = overrides.cardH ?? d.cardH;
  const dayY = overrides.dayY ?? d.dayY;
  const mantraY = overrides.mantraY ?? d.mantraY;
  const firstMantraY = lines.length === 1 ? mantraY + 45 : mantraY;
  const mantra = lines.map((line, lineIndex) => `<tspan x="${center}" dy="${lineIndex === 0 ? 0 : lineGap}">${escapeXml(line)}</tspan>`).join("");
  const daySize = overrides.daySize ?? (kind === "tiktok" ? 108 : 94);
  const mantraSize = overrides.mantraSize ?? (kind === "tiktok" ? 70 : d.mantraSize);
  return `
    <rect x="72" y="${cardY}" width="936" height="${cardH}" rx="28" fill="${color}" opacity=".10"/>
    <rect x="72" y="${cardY}" width="14" height="${cardH}" rx="7" fill="${color}"/>
    <text x="${center}" y="${dayY}" text-anchor="middle" class="serif" font-size="${daySize}" font-weight="700" fill="${color}">${escapeXml(day.day)}</text>
    <line x1="270" y1="${dayY + 56}" x2="810" y2="${dayY + 56}" stroke="${color}" stroke-opacity=".35"/>
    <text x="${center}" y="${firstMantraY}" text-anchor="middle" class="serif" font-size="${mantraSize}" fill="${palette.ink}">${mantra}</text>`;
}

function daySlide(day, index, kind) {
  return shell(`${dayCard(day, index, kind)}${progress(index + 2, kind)}`, index + 2, kind);
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
  fs.mkdirSync(path.join(base, "proof"), { recursive: true });
  await sharp({ create: { width: columns * thumbWidth, height: rows * thumbHeight, channels: 4, background: palette.bg } })
    .composite(composites)
    .png()
    .toFile(path.join(base, "proof", `${kind}-weekly-mantra-contact-sheet.png`));
}

async function renderKind(kind) {
  const exportDir = path.join(base, "exports", kind === "tiktok" ? "01-tiktok" : "02-instagram");
  const svgDir = path.join(base, "design-source", kind);
  fs.mkdirSync(exportDir, { recursive: true });
  fs.mkdirSync(svgDir, { recursive: true });
  for (const directory of [exportDir, svgDir]) {
    for (const stale of fs.readdirSync(directory).filter((file) => file === "08.png" || file === "08.svg")) {
      fs.unlinkSync(path.join(directory, stale));
    }
  }
  const slides = [cover(kind), ...content.days.slice(0, -1).map((day, index) => daySlide(day, index, kind))];
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

async function main() {
  fs.mkdirSync(path.join(base, "brand"), { recursive: true });
  const sourceLogo = path.join(root, "Instagram", "2026-07-31", "brand", "jyotish-logo-transparent.png");
  const targetLogo = path.join(base, "brand", "jyotish-logo-transparent.png");
  if (!fs.existsSync(targetLogo)) fs.copyFileSync(sourceLogo, targetLogo);
  const sourceFonts = path.join(root, "Instagram", "2026-07-31", "brand", "fonts");
  const targetFonts = path.join(base, "brand", "fonts");
  fs.mkdirSync(targetFonts, { recursive: true });
  for (const font of fs.readdirSync(sourceFonts)) {
    const sourceFont = path.join(sourceFonts, font);
    const targetFont = path.join(targetFonts, font);
    if (!fs.existsSync(targetFont)) fs.copyFileSync(sourceFont, targetFont);
  }
  const results = {};
  for (const kind of ["tiktok", "instagram"]) results[kind] = await renderKind(kind);
  console.log(JSON.stringify({ date, slideCount: content.days.length, results }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
