const fs = require("fs");
const path = require("path");
const sharp = require(process.env.SHARP_MODULE || "sharp");

const root = path.resolve(__dirname, "..");
const WIDTH = 1080;
const HANDLE = "@jyotishbajeapp";
const RASHI_NAMES = [
  "Mesh",
  "Vrish",
  "Mithun",
  "Karkat",
  "Simha",
  "Kanya",
  "Tula",
  "Vrischik",
  "Dhanu",
  "Makar",
  "Kumbha",
  "Meen",
];
const FORBIDDEN_ZODIAC_NAMES = [
  "Aries",
  "Taurus",
  "Gemini",
  "Cancer",
  "Leo",
  "Virgo",
  "Libra",
  "Scorpio",
  "Sagittarius",
  "Capricorn",
  "Aquarius",
  "Pisces",
];
const COLORS = {
  background: "#F8F5EF",
  accent: "#B4493B",
  text: "#2D2926",
  muted: "#716A63",
};
const LAYOUTS = {
  instagram: {
    height: 1350,
    scale: 1,
    cover: {
      brand: 102,
      date: 164,
      title: 327,
      highLabel: 492,
      highName: 590,
      highScore: 657,
      highGuidance: 716,
      lowLabel: 804,
      lowName: 901,
      lowScore: 968,
      lowGuidance: 1027,
      swipe: 1222,
    },
    sign: {
      centerX: 540,
      brand: 110,
      date: 166,
      name: 306,
      score: 380,
      energy: 428,
      statement: 545,
      loveLabel: 700,
      love: 748,
      workLabel: 855,
      work: 903,
      energyLabel: 1010,
      energyText: 1058,
      luckyLabel: 1170,
      lucky: 1215,
      footer: 1275,
    },
    ending: {
      brand: 112,
      date: 174,
      title: 440,
      line1: 690,
      line2: 778,
      line3: 866,
      app: 1010,
      handle: 1220,
    },
  },
  tiktok: {
    height: 1920,
    scale: 1.06,
    cover: {
      brand: 247,
      date: 313,
      title: 545,
      highLabel: 766,
      highName: 865,
      highScore: 932,
      highGuidance: 992,
      lowLabel: 1120,
      lowName: 1216,
      lowScore: 1283,
      lowGuidance: 1343,
      swipe: 1602,
    },
    sign: {
      centerX: 500,
      brand: 215,
      date: 278,
      name: 430,
      score: 515,
      energy: 570,
      statement: 700,
      loveLabel: 875,
      love: 930,
      workLabel: 1070,
      work: 1125,
      energyLabel: 1265,
      energyText: 1320,
      luckyLabel: 1460,
      lucky: 1510,
      footer: 1585,
    },
    ending: {
      brand: 245,
      date: 312,
      title: 675,
      line1: 960,
      line2: 1060,
      line3: 1160,
      app: 1340,
      handle: 1615,
    },
  },
};

function args() {
  const values = {};
  for (let index = 2; index < process.argv.length; index += 1) {
    const value = process.argv[index];
    if (!value.startsWith("--")) continue;
    const key = value.slice(2);
    values[key] = process.argv[index + 1]?.startsWith("--") ? true : process.argv[++index];
  }
  return values;
}

const options = args();
const edition = options.edition || "daily";
const reportDate = options.date || new Date().toISOString().slice(0, 10);
const dataPath = options.content || path.join(root, "content", "generated", `${edition}-rashifal-${reportDate}.json`);
const platformOption = String(options.platform || "instagram").toLowerCase();
const platforms = platformOption === "both" ? ["instagram", "tiktok"] : [platformOption];
const requestedSlides = options.slides
  ? String(options.slides).split(",").map((value) => Number(value.trim())).filter(Boolean)
  : Array.from({ length: 14 }, (_, index) => index + 1);
const data = JSON.parse(fs.readFileSync(dataPath, "utf8"));

if (platforms.some((platform) => !LAYOUTS[platform])) {
  throw new Error(`Unsupported platform "${platformOption}". Use instagram, tiktok, or both.`);
}
if (data.slides.length !== 12 || data.slides.some((slide, index) => slide.rashi_name !== RASHI_NAMES[index])) {
  throw new Error("The package must contain the 12 romanized Nepali rashi_name values in canonical order.");
}
const sourceText = JSON.stringify(data);
for (const forbidden of FORBIDDEN_ZODIAC_NAMES) {
  if (new RegExp(`\\b${forbidden}\\b`, "i").test(sourceText)) {
    throw new Error(`English zodiac name is not allowed in the package: ${forbidden}`);
  }
}

function fileData(filePath, mime) {
  return `data:${mime};base64,${fs.readFileSync(filePath).toString("base64")}`;
}

function findBrandAssetDate() {
  const instagramRoot = path.join(root, "content", "instagram");
  const candidates = fs.existsSync(instagramRoot)
    ? fs.readdirSync(instagramRoot).filter((entry) => /^\d{4}-\d{2}-\d{2}$/.test(entry)).sort().reverse()
    : [];
  return candidates.find((entry) => fs.existsSync(path.join(instagramRoot, entry, "brand", "fonts", "Inter-Regular.ttf")));
}

const brandDate = options["asset-date"] || findBrandAssetDate();
if (!brandDate) throw new Error("No brand font bundle was found.");
const fontDir = path.join(root, "content", "instagram", brandDate, "brand", "fonts");
const devaDir = path.join(root, "node_modules", "@fontsource", "noto-sans-devanagari", "files");
const fontCss = `
  @font-face{font-family:SocialSans;src:url(${fileData(path.join(fontDir, "Inter-Regular.ttf"), "font/ttf")}) format("truetype");font-weight:400}
  @font-face{font-family:SocialSans;src:url(${fileData(path.join(fontDir, "Inter-SemiBold.ttf"), "font/ttf")}) format("truetype");font-weight:600}
  @font-face{font-family:SocialSans;src:url(${fileData(path.join(fontDir, "Inter-Bold.ttf"), "font/ttf")}) format("truetype");font-weight:700}
  @font-face{font-family:DevaSans;src:url(${fileData(path.join(devaDir, "noto-sans-devanagari-devanagari-600-normal.woff"), "font/woff")}) format("woff");font-weight:600}
  .sans{font-family:SocialSans,Inter,-apple-system,BlinkMacSystemFont,"Helvetica Neue",sans-serif}
  .deva{font-family:DevaSans,"Noto Sans Devanagari","Kohinoor Devanagari",sans-serif}
`;

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function wrapText(value, maxChars) {
  const words = String(value).trim().split(/\s+/);
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
  return lines;
}

function centeredText(text, y, size, color, weight = 400, spacing = 0, className = "sans", centerX = WIDTH / 2) {
  return `<text x="${centerX}" y="${y}" text-anchor="middle" class="${className}" font-size="${size}" font-weight="${weight}" letter-spacing="${spacing}" fill="${color}">${escapeXml(text)}</text>`;
}

function centeredBlock(text, y, size, color, maxChars, lineHeight, weight = 400, centerX = WIDTH / 2) {
  const lines = wrapText(text, maxChars);
  return `<text x="${centerX}" y="${y}" text-anchor="middle" class="sans" font-size="${size}" font-weight="${weight}" fill="${color}">${lines.map((line, index) => `<tspan x="${centerX}" dy="${index === 0 ? 0 : lineHeight}">${escapeXml(line)}</tspan>`).join("")}</text>`;
}

function dateLabel() {
  return new Intl.DateTimeFormat("en-GB", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(`${reportDate}T00:00:00Z`)).toUpperCase();
}

function shell(platform, inner) {
  const { height } = LAYOUTS[platform];
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${WIDTH}" height="${height}" viewBox="0 0 ${WIDTH} ${height}"><defs><style>${fontCss}</style></defs><rect width="${WIDTH}" height="${height}" fill="${COLORS.background}"/>${inner}</svg>`;
}

function titleLockup(y, scale) {
  const latinSize = Math.round(104 * scale);
  const devaSize = Math.round(98 * scale);
  return `<text x="${WIDTH / 2}" y="${y}" text-anchor="middle" fill="${COLORS.accent}"><tspan class="sans" font-size="${latinSize}" font-weight="700" letter-spacing="-4">Rashifal/</tspan><tspan class="deva" font-size="${devaSize}" font-weight="600" letter-spacing="-2">राशिफल</tspan></text>`;
}

function microPrediction(score) {
  if (score >= 4) return "Use the momentum.";
  if (score >= 3) return "Keep your pace.";
  return "Protect your energy.";
}

function cover(platform) {
  const { scale, cover: layout } = LAYOUTS[platform];
  const highest = data.summary.highest;
  const lowest = data.summary.lowest;
  return shell(platform, [
    centeredText("JYOTISH BAJE", layout.brand, Math.round(30 * scale), COLORS.accent, 700, 3.2),
    centeredText(dateLabel(), layout.date, Math.round(36 * scale), COLORS.text, 600, 1.2),
    titleLockup(layout.title, scale),
    centeredText("HIGHEST RANKED", layout.highLabel, Math.round(34 * scale), COLORS.accent, 700, 1.5),
    centeredText(highest.rashi_name, layout.highName, Math.round(78 * scale), COLORS.text, 700, -2),
    centeredText(`${highest.score.toFixed(1)}/5`, layout.highScore, Math.round(54 * scale), COLORS.accent, 600, -1),
    centeredText(microPrediction(highest.score), layout.highGuidance, Math.round(40 * scale), COLORS.muted, 400, -1),
    centeredText("LOWEST RANKED", layout.lowLabel, Math.round(34 * scale), COLORS.accent, 700, 1.5),
    centeredText(lowest.rashi_name, layout.lowName, Math.round(78 * scale), COLORS.text, 700, -2),
    centeredText(`${lowest.score.toFixed(1)}/5`, layout.lowScore, Math.round(54 * scale), COLORS.accent, 600, -1),
    centeredText(microPrediction(lowest.score), layout.lowGuidance, Math.round(40 * scale), COLORS.muted, 400, -1),
    centeredText("Swipe for your rashi  →", layout.swipe, Math.round(36 * scale), COLORS.accent, 600, -1),
  ].join(""));
}

function detailBlock(label, value, labelY, valueY, scale, centerX, maxChars) {
  return [
    centeredText(label, labelY, Math.round(25 * scale), COLORS.accent, 700, 2.4, "sans", centerX),
    centeredBlock(value, valueY, Math.round(34 * scale), COLORS.text, maxChars, Math.round(43 * scale), 400, centerX),
  ].join("");
}

function signSlide(platform, sign) {
  const { scale, sign: layout } = LAYOUTS[platform];
  const bodyMaxChars = platform === "tiktok" ? 48 : 54;
  const statementMaxChars = platform === "tiktok" ? 38 : 41;
  return shell(platform, [
    centeredText("JYOTISH BAJE", layout.brand, Math.round(26 * scale), COLORS.accent, 700, 3, "sans", layout.centerX),
    centeredText(dateLabel(), layout.date, Math.round(31 * scale), COLORS.text, 600, 1, "sans", layout.centerX),
    centeredText(sign.rashi_name, layout.name, Math.round(88 * scale), COLORS.text, 700, -2, "sans", layout.centerX),
    centeredText(`${sign.score.toFixed(1)}/5`, layout.score, Math.round(52 * scale), COLORS.accent, 600, -1, "sans", layout.centerX),
    centeredText(sign.energy_label, layout.energy, Math.round(24 * scale), COLORS.muted, 700, 2.6, "sans", layout.centerX),
    centeredBlock(sign.emotional_statement, layout.statement, Math.round(42 * scale), COLORS.text, statementMaxChars, Math.round(53 * scale), 600, layout.centerX),
    detailBlock("LOVE", sign.love, layout.loveLabel, layout.love, scale, layout.centerX, bodyMaxChars),
    detailBlock("WORK", sign.work, layout.workLabel, layout.work, scale, layout.centerX, bodyMaxChars),
    detailBlock("ENERGY", sign.energy, layout.energyLabel, layout.energyText, scale, layout.centerX, bodyMaxChars),
    centeredText("LUCKY CUE", layout.luckyLabel, Math.round(24 * scale), COLORS.accent, 700, 2.3, "sans", layout.centerX),
    centeredText(`${sign.lucky_color} · ${sign.lucky_number}`, layout.lucky, Math.round(32 * scale), COLORS.text, 600, 0, "sans", layout.centerX),
    centeredText(`${HANDLE}  ·  DAILY RASHIFAL`, layout.footer, Math.round(19 * scale), COLORS.muted, 600, 1.1, "sans", layout.centerX),
  ].join(""));
}

function ending(platform) {
  const { scale, ending: layout } = LAYOUTS[platform];
  return shell(platform, [
    centeredText("JYOTISH BAJE", layout.brand, Math.round(30 * scale), COLORS.accent, 700, 3.2),
    centeredText(dateLabel(), layout.date, Math.round(36 * scale), COLORS.text, 600, 1.2),
    centeredBlock("Mathematically produced Jyotish results.", layout.title, Math.round(72 * scale), COLORS.accent, 29, Math.round(84 * scale), 700),
    centeredText("Follow for more updates", layout.line1, Math.round(38 * scale), COLORS.text, 600, -0.8),
    centeredText("Save this for your next check-in", layout.line2, Math.round(38 * scale), COLORS.text, 600, -0.8),
    centeredText("Share with your friends", layout.line3, Math.round(38 * scale), COLORS.text, 600, -0.8),
    centeredText("Jyotish Baje App · Coming soon", layout.app, Math.round(34 * scale), COLORS.muted, 400, -0.6),
    centeredText(HANDLE, layout.handle, Math.round(34 * scale), COLORS.accent, 700, 0.4),
  ].join(""));
}

function slideSvg(platform, slideNumber) {
  if (slideNumber === 1) return cover(platform);
  if (slideNumber === 14) return ending(platform);
  const sign = data.slides[slideNumber - 2];
  if (!sign) throw new Error(`No sign data for slide ${slideNumber}`);
  return signSlide(platform, sign);
}

function outputRootFor(platform) {
  if (options["output-root"]) {
    return platforms.length > 1
      ? path.join(options["output-root"], platform)
      : options["output-root"];
  }
  return path.join(root, "content", platform, reportDate);
}

async function renderPlatform(platform) {
  const outputDir = path.join(outputRootFor(platform), edition);
  fs.mkdirSync(outputDir, { recursive: true });
  for (const slideNumber of requestedSlides) {
    const number = String(slideNumber).padStart(2, "0");
    const name = slideNumber === 1
      ? "cover"
      : slideNumber === 14
        ? "ending"
        : data.slides[slideNumber - 2].rashi_name.toLowerCase();
    const svg = slideSvg(platform, slideNumber);
    const svgPath = path.join(outputDir, `${number}-${name}.svg`);
    const pngPath = path.join(outputDir, `${number}-${name}.png`);
    fs.writeFileSync(svgPath, svg, "utf8");
    await sharp(Buffer.from(svg)).png().toFile(pngPath);
  }
  console.log(`Rendered ${requestedSlides.length} ${platform} ${edition} slide(s) at ${WIDTH}x${LAYOUTS[platform].height}.`);
}

async function render() {
  for (const platform of platforms) {
    await renderPlatform(platform);
  }
}

render().catch((error) => {
  console.error(error);
  process.exit(1);
});
