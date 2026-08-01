const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const date = process.argv[2] || "2026-07-31";
const base = path.join(root, "Instagram", date);
const content = JSON.parse(fs.readFileSync(path.join(base, "carousel-copy.json"), "utf8"));
const edition = content.daily;
const sharp = require(process.env.SHARP_MODULE || "sharp");
const logoData = `data:image/png;base64,${fs.readFileSync(path.join(base, "brand", "jyotish-logo-transparent.png")).toString("base64")}`;

const palette = {
  bgCanvas: "#FCF7ED",
  inkPrimary: "#3B1F14",
  inkSecondary: "#7A5C48",
  sindoor: "#B9331F",
  templeGold: "#B8860B"
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

function layout(kind) {
  if (kind === "tiktok") {
    return {
      width: 1080,
      height: 1920,
      headerY: 82,
      ruleY: 120,
      titleY: 330,
      datesY: 388,
      ratingY: 328,
      rowYs: [590, 785, 980, 1175],
      noteY: 1435,
      progressY: 1710,
      footerY: 1818,
      coverLogoY: 190,
      coverHookY: 505,
      coverSubhookY: 760,
      coverRuleY: 875,
      coverEnergyLabelY: 945,
      coverEnergyY: 1080,
      coverMetaY: 1165,
      coverTopicsY: 1390,
      coverSwipeY: 1605,
      finalLogoY: 270,
      finalHookY: 610,
      finalAppY: 830,
      finalRuleY: 930,
      finalActionYs: [1080, 1190, 1300, 1410],
      finalMetaY: 1640,
      finalDisclaimerY: 1740,
      bodySize: 35,
      rowLabelSize: 21,
      titleSize: 92
    };
  }
  return {
    width: 1080,
    height: 1350,
    headerY: 75,
    ruleY: 110,
    titleY: 245,
    datesY: 300,
    ratingY: 242,
    rowYs: [430, 590, 750, 910],
    noteY: 1105,
    progressY: 1242,
    footerY: 1295,
    coverLogoY: 155,
    coverHookY: 360,
    coverSubhookY: 570,
    coverRuleY: 690,
    coverEnergyLabelY: 755,
    coverEnergyY: 875,
    coverMetaY: 950,
    coverTopicsY: 1110,
    coverSwipeY: 1205,
    finalLogoY: 175,
    finalHookY: 420,
    finalAppY: 595,
    finalRuleY: 670,
    finalActionYs: [755, 845, 935, 1025],
    finalMetaY: 1165,
    finalDisclaimerY: 1220,
    bodySize: 31,
    rowLabelSize: 21,
    titleSize: 88
  };
}

function shell(inner, page, kind) {
  const l = layout(kind);
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${l.width}" height="${l.height}" viewBox="0 0 ${l.width} ${l.height}">
    <defs><style>${fontCss}</style></defs>
    <rect width="${l.width}" height="${l.height}" fill="${palette.bgCanvas}"/>
    <text x="72" y="${l.headerY}" class="sans" font-size="20" font-weight="700" letter-spacing="2" fill="${palette.inkSecondary}">JYOTISH &#8226; ${escapeXml(edition.label)}</text>
    <text x="1008" y="${l.headerY}" text-anchor="end" class="sans" font-size="20" fill="${palette.inkSecondary}">${String(page).padStart(2, "0")} / 14</text>
    <line x1="72" y1="${l.ruleY}" x2="1008" y2="${l.ruleY}" stroke="${palette.templeGold}" stroke-opacity=".18"/>
    ${inner.trim()}
  </svg>`;
}

function progress(current, kind) {
  const l = layout(kind);
  return Array.from({ length: 12 }, (_, index) => {
    const x = 72 + index * 78;
    const active = index <= current;
    return `<line x1="${x}" y1="${l.progressY}" x2="${x + 56}" y2="${l.progressY}" stroke="${active ? palette.sindoor : palette.templeGold}" stroke-opacity="${active ? ".82" : ".18"}" stroke-width="3"/>`;
  }).join("");
}

function cueRow(label, text, y, kind) {
  const l = layout(kind);
  return `<text x="72" y="${y}" class="sans" font-size="${l.rowLabelSize}" font-weight="700" letter-spacing="2" fill="${palette.sindoor}">${label}</text>
    <text x="250" y="${y}" class="sans" font-size="${l.bodySize}" fill="${palette.inkPrimary}">${escapeXml(text)}</text>
    <line x1="72" y1="${y + (kind === "tiktok" ? 108 : 92)}" x2="1008" y2="${y + (kind === "tiktok" ? 108 : 92)}" stroke="${palette.templeGold}" stroke-opacity=".20"/>`;
}

function cover(kind) {
  const l = layout(kind);
  const highest = Math.max(...edition.signs.map((sign) => sign.rating)).toFixed(1);
  const inner = `
    <image href="${logoData}" x="72" y="${l.coverLogoY}" width="${kind === "tiktok" ? 112 : 92}" height="${kind === "tiktok" ? 112 : 92}"/>
    <text x="72" y="${l.coverHookY}" class="serif" font-size="${kind === "tiktok" ? 94 : 82}" font-weight="700" fill="${palette.sindoor}">
      <tspan x="72" dy="0">${escapeXml(edition.hook[0])}</tspan>
      <tspan x="72" dy="${kind === "tiktok" ? 118 : 105}">${escapeXml(edition.hook[1])}</tspan>
    </text>
    <text x="76" y="${l.coverSubhookY}" class="sans" font-size="${kind === "tiktok" ? 31 : 29}" fill="${palette.inkSecondary}">${escapeXml(edition.subhook)}</text>
    <line x1="72" y1="${l.coverRuleY}" x2="1008" y2="${l.coverRuleY}" stroke="${palette.templeGold}" stroke-opacity=".28"/>
    <text x="72" y="${l.coverEnergyLabelY}" class="sans" font-size="19" font-weight="700" letter-spacing="3" fill="${palette.inkSecondary}">HIGHEST ENERGY</text>
    <text x="72" y="${l.coverEnergyY}" class="serif" font-size="${kind === "tiktok" ? 108 : 96}" font-weight="700" fill="${palette.sindoor}">${highest} &#9733;</text>
    <text x="72" y="${l.coverMetaY}" class="sans" font-size="${kind === "tiktok" ? 27 : 25}" fill="${palette.inkSecondary}">12 signs &#8226; decimal ratings &#8226; 4 useful cues each</text>
    <text x="72" y="${l.coverTopicsY}" class="sans" font-size="21" font-weight="600" letter-spacing="2" fill="${palette.inkSecondary}">LOVE  &#8226;  WORK  &#8226;  ENERGY  &#8226;  LUCKY CUE</text>
    <text x="72" y="${l.coverSwipeY}" class="serif" font-size="${kind === "tiktok" ? 42 : 36}" font-weight="700" fill="${palette.sindoor}">Swipe to find your sign  &#8594;</text>`;
  return shell(inner, 1, kind);
}

function signSlide(sign, index, kind) {
  const l = layout(kind);
  const page = index + 2;
  const inner = `
    <text x="72" y="${l.titleY}" class="serif" font-size="${l.titleSize}" font-weight="700" fill="${palette.sindoor}">${escapeXml(sign.name)}</text>
    <text x="76" y="${l.datesY}" class="sans" font-size="19" font-weight="600" letter-spacing="4" fill="${palette.inkSecondary}">${escapeXml(sign.dates)}</text>
    <text x="1008" y="${l.ratingY}" text-anchor="end" class="serif" font-size="52" font-weight="700" fill="${palette.sindoor}">${sign.rating.toFixed(1)} &#9733;</text>
    ${cueRow("LOVE", sign.love, l.rowYs[0], kind)}
    ${cueRow("WORK", sign.work, l.rowYs[1], kind)}
    ${cueRow("ENERGY", sign.energy, l.rowYs[2], kind)}
    ${cueRow("LUCKY CUE", sign.cue, l.rowYs[3], kind)}
    <text x="72" y="${l.noteY}" class="serif" font-size="${kind === "tiktok" ? 37 : 31}" font-weight="700" fill="${palette.sindoor}">gentle note</text>
    <text x="310" y="${l.noteY}" class="sans" font-size="${kind === "tiktok" ? 25 : 23}" fill="${palette.inkSecondary}">This rating reflects a mood, not a rule. Keep what feels useful.</text>
    ${progress(index, kind)}
    <text x="1008" y="${l.footerY}" text-anchor="end" class="sans" font-size="20" font-weight="600" fill="${palette.inkSecondary}">save &#8226; share &#8226; swipe  &#8594;</text>`;
  return shell(inner, page, kind);
}

function finalSlide(kind) {
  const l = layout(kind);
  const inner = `
    <image href="${logoData}" x="72" y="${l.finalLogoY}" width="${kind === "tiktok" ? 142 : 118}" height="${kind === "tiktok" ? 142 : 118}"/>
    <text x="72" y="${l.finalHookY}" class="serif" font-size="${kind === "tiktok" ? 96 : 86}" font-weight="700" fill="${palette.sindoor}">
      <tspan x="72" dy="0">Your chart.</tspan>
      <tspan x="72" dy="${kind === "tiktok" ? 118 : 102}">Explained simply.</tspan>
    </text>
    <text x="76" y="${l.finalAppY}" class="sans" font-size="${kind === "tiktok" ? 28 : 25}" font-weight="700" letter-spacing="3" fill="${palette.inkSecondary}">JYOTISH BAJE &#8226; AI-BASED JYOTISH APP</text>
    <line x1="72" y1="${l.finalRuleY}" x2="1008" y2="${l.finalRuleY}" stroke="${palette.templeGold}" stroke-opacity=".28"/>
    <text x="72" y="${l.finalActionYs[0]}" class="serif" font-size="${kind === "tiktok" ? 44 : 37}" font-weight="700" fill="${palette.sindoor}">TRY JYOTISH  &#8594;</text>
    <text x="72" y="${l.finalActionYs[1]}" class="serif" font-size="${kind === "tiktok" ? 44 : 37}" font-weight="700" fill="${palette.sindoor}">COMMENT YOUR SIGN  &#8595;</text>
    <text x="72" y="${l.finalActionYs[2]}" class="serif" font-size="${kind === "tiktok" ? 44 : 37}" font-weight="700" fill="${palette.sindoor}">SAVE THIS POST  +</text>
    <text x="72" y="${l.finalActionYs[3]}" class="serif" font-size="${kind === "tiktok" ? 44 : 37}" font-weight="700" fill="${palette.sindoor}">SHARE WITH A FRIEND  &#8594;</text>
    <text x="72" y="${l.finalMetaY}" class="sans" font-size="${kind === "tiktok" ? 27 : 24}" fill="${palette.inkPrimary}">Birth-chart insights &#8226; Daily guidance &#8226; Ask questions</text>
    <text x="72" y="${l.finalDisclaimerY}" class="sans" font-size="21" fill="${palette.inkSecondary}">AI guidance for reflection, not certainty.</text>`;
  return shell(inner, 14, kind);
}

async function renderContactSheet(pngPaths, kind) {
  const l = layout(kind);
  const thumbWidth = kind === "tiktok" ? 360 : 432;
  const thumbHeight = Math.round(thumbWidth * l.height / l.width);
  const columns = 4;
  const rows = Math.ceil(pngPaths.length / columns);
  const composites = [];
  for (let index = 0; index < pngPaths.length; index += 1) {
    const input = await sharp(pngPaths[index]).resize(thumbWidth, thumbHeight, { fit: "fill" }).png().toBuffer();
    composites.push({ input, left: (index % columns) * thumbWidth, top: Math.floor(index / columns) * thumbHeight });
  }
  const proofDir = path.join(base, "proof");
  fs.mkdirSync(proofDir, { recursive: true });
  await sharp({ create: { width: columns * thumbWidth, height: rows * thumbHeight, channels: 4, background: palette.bgCanvas } })
    .composite(composites)
    .png()
    .toFile(path.join(proofDir, `${kind}-carousel-14-slide-contact-sheet.png`));
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

async function main() {
  const results = {};
  for (const kind of ["tiktok", "instagram"]) results[kind] = await renderKind(kind);
  console.log(JSON.stringify({ date, results }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
