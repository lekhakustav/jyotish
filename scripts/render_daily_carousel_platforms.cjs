const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const date = process.argv[2] || new Date().toISOString().slice(0, 10);
const base = path.join(root, "Instagram", date);
const content = JSON.parse(fs.readFileSync(path.join(base, "carousel-copy.json"), "utf8"));
const edition = content.daily;
const sharp = require(process.env.SHARP_MODULE || "sharp");
const totalSlides = edition.signs.length + 2;

// This is the permanent daily Rashifal format: a warm cream app-style canvas,
// centered bilingual heading, quiet hairlines, and readable guidance rows.
const palette = {
  canvas: "#F4ECDD",
  card: "#FFFDF7",
  ink: "#3B1F14",
  muted: "#7A5C48",
  accent: "#B9331F",
  gold: "#B8860B",
  hairline: "rgba(184,134,11,0.28)",
  soft: "#F8F1E6"
};

const rashiNames = {
  Aries: "Mesh",
  Taurus: "Vrish",
  Gemini: "Mithun",
  Cancer: "Karkat",
  Leo: "Singh",
  Virgo: "Kanya",
  Libra: "Tula",
  Scorpio: "Vrischik",
  Sagittarius: "Dhanu",
  Capricorn: "Makar",
  Aquarius: "Kumbha",
  Pisces: "Meen"
};

const rashiNepali = {
  Aries: "मेष",
  Taurus: "वृषभ",
  Gemini: "मिथुन",
  Cancer: "कर्कट",
  Leo: "सिंह",
  Virgo: "कन्या",
  Libra: "तुला",
  Scorpio: "वृश्चिक",
  Sagittarius: "धनु",
  Capricorn: "मकर",
  Aquarius: "कुम्भ",
  Pisces: "मीन"
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
        width: 1080,
        height: 1920,
        cardX: 34,
        cardY: 42,
        cardW: 1012,
        cardH: 1836,
        logoY: 68,
        headerY: 86,
        dateY: 118,
        pageY: 94,
        titleY: 390,
        titleSize: 104,
        titleSubY: 468,
        rankOneY: 700,
        rankTwoY: 1070,
        swipeY: 1658,
        signY: 390,
        signSize: 104,
        signDateY: 475,
        introY: 560,
        rowStart: 700,
        rowGap: 190,
        rowLabelSize: 22,
        bodySize: 31,
        bodyLineHeight: 40,
        ctaY: 1515,
        ctaSize: 25,
        progressY: 1818
      }
    : {
        width: 1080,
        height: 1350,
        cardX: 28,
        cardY: 28,
        cardW: 1024,
        cardH: 1294,
        logoY: 52,
        headerY: 72,
        dateY: 102,
        pageY: 80,
        titleY: 258,
        titleSize: 82,
        titleSubY: 318,
        rankOneY: 490,
        rankTwoY: 765,
        swipeY: 1178,
        signY: 254,
        signSize: 82,
        signDateY: 326,
        introY: 410,
        rowStart: 510,
        rowGap: 138,
        rowLabelSize: 17,
        bodySize: 25,
        bodyLineHeight: 32,
        ctaY: 1080,
        ctaSize: 19,
        progressY: 1268
      };
}

function logoData() {
  return `data:image/png;base64,${fs.readFileSync(path.join(base, "brand", "jyotish-logo-transparent.png")).toString("base64")}`;
}

function dateLabel() {
  return edition.label.split(" - ")[0] || date.toUpperCase();
}

function wrapText(value, maxChars) {
  const words = String(value).split(/\s+/);
  const lines = [];
  let current = "";
  for (const word of words) {
    const next = current ? `${current} ${word}` : word;
    if (current && next.length > maxChars) {
      lines.push(current);
      current = word;
    } else {
      current = next;
    }
  }
  if (current) lines.push(current);
  return lines.length ? lines : [""];
}

function shell(inner, page, kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${d.width}" height="${d.height}" viewBox="0 0 ${d.width} ${d.height}">
    <defs>
      <style>${fontCss}</style>
      <filter id="softShadow" x="-20%" y="-20%" width="140%" height="140%">
        <feDropShadow dx="0" dy="9" stdDeviation="13" flood-color="#7A5C48" flood-opacity=".10"/>
      </filter>
    </defs>
    <rect width="${d.width}" height="${d.height}" fill="${palette.canvas}"/>
    <rect x="${d.cardX}" y="${d.cardY}" width="${d.cardW}" height="${d.cardH}" rx="34" fill="${palette.card}" stroke="${palette.hairline}" stroke-width="2" filter="url(#softShadow)"/>
    <image href="${logoData()}" x="${d.cardX + 30}" y="${d.logoY}" width="54" height="54" opacity=".92"/>
    <text x="${center}" y="${d.headerY}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 22 : 17}" font-weight="700" letter-spacing="3" fill="${palette.accent}">JYOTISH BAJE</text>
    <text x="${center}" y="${d.dateY}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 18 : 15}" font-weight="600" letter-spacing="2" fill="${palette.muted}">${escapeXml(dateLabel())}</text>
    <text x="${d.cardX + d.cardW - 30}" y="${d.pageY}" text-anchor="end" class="sans" font-size="${kind === "tiktok" ? 19 : 16}" font-weight="600" fill="${palette.muted}">${String(page).padStart(2, "0")} / ${String(totalSlides).padStart(2, "0")}</text>
    <line x1="${d.cardX + 38}" y1="${d.dateY + 26}" x2="${d.cardX + d.cardW - 38}" y2="${d.dateY + 26}" stroke="${palette.hairline}" stroke-width="2"/>
    ${inner}
  </svg>`;
}

function progress(page, kind) {
  const d = dimensions(kind);
  const step = 68;
  const width = 50;
  const start = (d.width - (step * (totalSlides - 1) + width)) / 2;
  return Array.from({ length: totalSlides }, (_, index) => {
    const x = Math.round(start + index * step);
    const active = index < page;
    return `<line x1="${x}" y1="${d.progressY}" x2="${x + width}" y2="${d.progressY}" stroke="${active ? palette.accent : palette.gold}" stroke-opacity="${active ? ".92" : ".22"}" stroke-width="5" stroke-linecap="round"/>`;
  }).join("");
}

function rankBlock(sign, heading, note, y, kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  const signName = rashiNames[sign.name] || sign.name;
  return `<g>
    <text x="${center}" y="${y}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 23 : 17}" font-weight="700" letter-spacing="3" fill="${palette.accent}">${heading}</text>
    <text x="${center}" y="${y + (kind === "tiktok" ? 64 : 54)}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 58 : 46}" font-weight="700" fill="${palette.ink}">${escapeXml(signName)}</text>
    <text x="${center}" y="${y + (kind === "tiktok" ? 119 : 99)}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 47 : 37}" font-weight="700" fill="${palette.accent}">${Number(sign.rating).toFixed(1)}/5</text>
    <text x="${center}" y="${y + (kind === "tiktok" ? 158 : 133)}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 22 : 17}" fill="${palette.muted}">${escapeXml(note)}</text>
  </g>`;
}

function cover(kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  const sorted = [...edition.signs].sort((left, right) => Number(right.rating) - Number(left.rating));
  const highest = sorted[0];
  const lowest = sorted[sorted.length - 1];
  return shell(`
    <text x="${center}" y="${d.titleY}" text-anchor="middle" class="bilingual" font-size="${d.titleSize}" font-weight="700" fill="${palette.accent}">Rashifal/राशिफल</text>
    <text x="${center}" y="${d.titleSubY}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 20 : 15}" font-weight="600" letter-spacing="2" fill="${palette.muted}">DAILY GUIDANCE</text>
    ${rankBlock(highest, "HIGHEST RANKED", "Use the momentum.", d.rankOneY, kind)}
    <line x1="${kind === "tiktok" ? 270 : 340}" y1="${kind === "tiktok" ? 920 : 625}" x2="${kind === "tiktok" ? 810 : 740}" y2="${kind === "tiktok" ? 920 : 625}" stroke="${palette.hairline}" stroke-width="2"/>
    ${rankBlock(lowest, "LOWEST RANKED", "Protect your energy.", d.rankTwoY, kind)}
    <text x="${center}" y="${d.swipeY}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 22 : 17}" font-weight="600" fill="${palette.accent}">Swipe for your rashi →</text>
    ${progress(1, kind)}
  `, 1, kind);
}

function cueRow(label, value, y, kind) {
  const d = dimensions(kind);
  const maxChars = kind === "tiktok" ? 46 : 39;
  const lines = wrapText(value, maxChars);
  const bodyX = kind === "tiktok" ? 292 : 280;
  const lineHeight = d.bodyLineHeight;
  const rendered = lines.map((line, index) => `<tspan x="${bodyX}" dy="${index === 0 ? 0 : lineHeight}">${escapeXml(line)}</tspan>`).join("");
  return `<g>
    <text x="${kind === "tiktok" ? 82 : 78}" y="${y}" class="sans" font-size="${d.rowLabelSize}" font-weight="700" letter-spacing="2" fill="${palette.accent}">${label}</text>
    <text x="${bodyX}" y="${y}" class="sans" font-size="${d.bodySize}" fill="${palette.ink}">${rendered}</text>
    <line x1="${kind === "tiktok" ? 78 : 74}" y1="${y + (kind === "tiktok" ? 82 : 61)}" x2="${d.width - (kind === "tiktok" ? 78 : 74)}" y2="${y + (kind === "tiktok" ? 82 : 61)}" stroke="${palette.hairline}" stroke-width="2"/>
  </g>`;
}

function signSlide(sign, index, kind) {
  const d = dimensions(kind);
  const page = index + 2;
  const score = Number(sign.rating).toFixed(1);
  const title = `${rashiNames[sign.name] || sign.name} / ${rashiNepali[sign.name] || ""}`;
  return shell(`
    <text x="${d.width / 2}" y="${d.signY}" text-anchor="middle" class="bilingual" font-size="${d.signSize}" font-weight="700" fill="${palette.accent}">${escapeXml(title)}</text>
    <text x="${d.width / 2}" y="${d.signDateY}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 20 : 15}" font-weight="600" letter-spacing="2" fill="${palette.muted}">${escapeXml(sign.dates)}</text>
    <text x="${d.width / 2}" y="${d.introY}" text-anchor="middle" class="serif" font-size="${kind === "tiktok" ? 38 : 28}" font-weight="700" fill="${palette.ink}">${score}/5 <tspan font-size="${kind === "tiktok" ? 25 : 19}" fill="${palette.accent}">today</tspan></text>
    ${cueRow("LOVE", sign.love, d.rowStart, kind)}
    ${cueRow("WORK", sign.work, d.rowStart + d.rowGap, kind)}
    ${cueRow("ENERGY", sign.energy, d.rowStart + d.rowGap * 2, kind)}
    ${cueRow("LUCKY CUE", sign.cue, d.rowStart + d.rowGap * 3, kind)}
    <text x="${d.width / 2}" y="${d.ctaY}" text-anchor="middle" class="sans" font-size="${d.ctaSize}" font-weight="600" fill="${palette.accent}">Save this guidance for today →</text>
    ${progress(page, kind)}
  `, page, kind);
}

function finalSlide(kind) {
  const d = dimensions(kind);
  const center = d.width / 2;
  const titleSize = kind === "tiktok" ? 86 : 66;
  const actionSize = kind === "tiktok" ? 32 : 24;
  const actionStart = kind === "tiktok" ? 1460 : 1000;
  const actionGap = kind === "tiktok" ? 78 : 52;
  const actions = ["TRY JYOTISH  →", "COMMENT YOUR SIGN  ↓", "SAVE THIS POST  +", "SHARE WITH A FRIEND  →"];
  return shell(`
    <text x="${center}" y="${kind === "tiktok" ? 590 : 420}" text-anchor="middle" class="bilingual" font-size="${titleSize}" font-weight="700" fill="${palette.accent}">
      <tspan x="${center}" dy="0">Your chart.</tspan>
      <tspan x="${center}" dy="${kind === "tiktok" ? 105 : 82}">Explained simply.</tspan>
    </text>
    <text x="${center}" y="${d.ctaY - (kind === "tiktok" ? 410 : 290)}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 22 : 17}" font-weight="700" letter-spacing="3" fill="${palette.muted}">JYOTISH BAJE  •  AI-BASED JYOTISH APP</text>
    ${actions.map((action, index) => `<text x="${center}" y="${actionStart + index * actionGap}" text-anchor="middle" class="serif" font-size="${actionSize}" font-weight="700" fill="${palette.accent}">${action}</text>`).join("")}
    <text x="${center}" y="${kind === "tiktok" ? 1760 : 1208}" text-anchor="middle" class="sans" font-size="${kind === "tiktok" ? 20 : 15}" fill="${palette.muted}">AI guidance for reflection, not certainty.</text>
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
  const output = path.join(base, "proof", `${kind}-daily-rashifal-contact-sheet.png`);
  await sharp({ create: { width: columns * thumbWidth, height: rows * thumbHeight, channels: 4, background: palette.canvas } })
    .composite(composites)
    .png()
    .toFile(output);
  const commonName = `${kind}-carousel-14-slide-contact-sheet.png`;
  fs.copyFileSync(output, path.join(base, "proof", commonName));
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
  copyIfMissing(path.join(formatReference, "brand", "jyotish-logo-transparent.png"), path.join(base, "brand", "jyotish-logo-transparent.png"));
  for (const font of fs.readdirSync(path.join(formatReference, "brand", "fonts"))) {
    copyIfMissing(path.join(formatReference, "brand", "fonts", font), path.join(base, "brand", "fonts", font));
  }
  fs.mkdirSync(path.join(base, "proof"), { recursive: true });
  const results = {};
  for (const kind of ["tiktok", "instagram"]) results[kind] = await renderKind(kind);
  console.log(JSON.stringify({ date, slideCount: totalSlides, format: "permanent-cream-rashifal", results }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
