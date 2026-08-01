const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const date = process.argv[2] || new Date().toISOString().slice(0, 10);
const base = path.join(root, "content", "instagram", date);
const proofDir = path.join(root, "proof", date);
const content = JSON.parse(fs.readFileSync(path.join(base, "carousel-copy.json"), "utf8"));
const edition = content.daily;
const sharp = require(process.env.SHARP_MODULE || "sharp");
const logoData = `data:image/png;base64,${fs.readFileSync(path.join(base, "brand", "jyotish-logo-transparent.png")).toString("base64")}`;
const totalSlides = 14;

const palette = {
  bgCanvas: "#FCF7ED",
  inkPrimary: "#3B1F14",
  inkSecondary: "#7A5C48",
  sindoor: "#B9331F",
  templeGold: "#B8860B"
};

const escapeXml = (value) => String(value)
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;");

const fontCss = `
  @font-face{font-family:FrauncesLocal;src:url('../../brand/fonts/Fraunces-Regular.ttf') format('truetype');font-weight:400}
  @font-face{font-family:FrauncesLocal;src:url('../../brand/fonts/Fraunces-Bold.ttf') format('truetype');font-weight:700}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-Regular.ttf') format('truetype');font-weight:400}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-SemiBold.ttf') format('truetype');font-weight:600}
  @font-face{font-family:InterLocal;src:url('../../brand/fonts/Inter-Bold.ttf') format('truetype');font-weight:700}
  .serif{font-family:FrauncesLocal,serif}
  .sans{font-family:InterLocal,sans-serif}
`;

function shell(inner, page) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1350" viewBox="0 0 1080 1350">
    <defs><style>${fontCss}</style></defs>
    <rect width="1080" height="1350" fill="${palette.bgCanvas}"/>
    <text x="72" y="75" class="sans" font-size="20" font-weight="700" letter-spacing="3" fill="${palette.inkSecondary}">JYOTISH &#8226; ${edition.label}</text>
    <text x="1008" y="75" text-anchor="end" class="sans" font-size="20" fill="${palette.inkSecondary}">${String(page).padStart(2, "0")} / ${totalSlides}</text>
    <line x1="72" y1="110" x2="1008" y2="110" stroke="${palette.templeGold}" stroke-opacity=".18"/>
    ${inner.trim()}
  </svg>`;
}

function progress(current) {
  return Array.from({ length: 12 }, (_, index) => {
    const x = 72 + index * 78;
    const active = index <= current;
    return `<line x1="${x}" y1="1242" x2="${x + 56}" y2="1242" stroke="${active ? palette.sindoor : palette.templeGold}" stroke-opacity="${active ? ".82" : ".18"}" stroke-width="3"/>`;
  }).join("");
}

function cueRow(label, text, y) {
  return `<text x="72" y="${y}" class="sans" font-size="21" font-weight="700" letter-spacing="2" fill="${palette.sindoor}">${label}</text>
    <text x="250" y="${y}" class="sans" font-size="31" fill="${palette.inkPrimary}">${escapeXml(text)}</text>
    <line x1="72" y1="${y + 92}" x2="1008" y2="${y + 92}" stroke="${palette.templeGold}" stroke-opacity=".20"/>`;
}

function cover() {
  const highest = Math.max(...edition.signs.map((sign) => sign.rating)).toFixed(1);
  const inner = `
    <image href="${logoData}" x="72" y="155" width="92" height="92"/>
    <text x="72" y="360" class="serif" font-size="82" font-weight="700" fill="${palette.sindoor}">
      <tspan x="72" dy="0">${escapeXml(edition.hook[0])}</tspan>
      <tspan x="72" dy="105">${escapeXml(edition.hook[1])}</tspan>
    </text>
    <text x="76" y="570" class="sans" font-size="29" fill="${palette.inkSecondary}">${escapeXml(edition.subhook)}</text>
    <line x1="72" y1="690" x2="1008" y2="690" stroke="${palette.templeGold}" stroke-opacity=".28"/>
    <text x="72" y="755" class="sans" font-size="19" font-weight="700" letter-spacing="3" fill="${palette.inkSecondary}">HIGHEST ENERGY</text>
    <text x="72" y="875" class="serif" font-size="96" font-weight="700" fill="${palette.sindoor}">${highest} &#9733;</text>
    <text x="72" y="950" class="sans" font-size="25" fill="${palette.inkSecondary}">12 signs &#8226; decimal ratings &#8226; 4 useful cues each</text>
    <text x="72" y="1110" class="sans" font-size="21" font-weight="600" letter-spacing="2" fill="${palette.inkSecondary}">LOVE  &#8226;  WORK  &#8226;  ENERGY  &#8226;  LUCKY CUE</text>
    <text x="72" y="1205" class="serif" font-size="36" font-weight="700" fill="${palette.sindoor}">Swipe to find your sign  &#8594;</text>`;
  return shell(inner, 1);
}

function signSlide(sign, index) {
  const page = index + 2;
  const inner = `
    <text x="72" y="245" class="serif" font-size="88" font-weight="700" fill="${palette.sindoor}">${escapeXml(sign.name)}</text>
    <text x="76" y="300" class="sans" font-size="19" font-weight="600" letter-spacing="4" fill="${palette.inkSecondary}">${escapeXml(sign.dates)}</text>
    <text x="1008" y="242" text-anchor="end" class="serif" font-size="52" font-weight="700" fill="${palette.sindoor}">${sign.rating.toFixed(1)} &#9733;</text>
    ${cueRow("LOVE", sign.love, 430)}
    ${cueRow("WORK", sign.work, 590)}
    ${cueRow("ENERGY", sign.energy, 750)}
    ${cueRow("LUCKY CUE", sign.cue, 910)}
    <text x="72" y="1105" class="serif" font-size="31" font-weight="700" fill="${palette.sindoor}">gentle note</text>
    <text x="310" y="1105" class="sans" font-size="23" fill="${palette.inkSecondary}">This rating reflects a mood, not a rule. Keep what feels useful.</text>
    ${progress(index)}
    <text x="1008" y="1295" text-anchor="end" class="sans" font-size="20" font-weight="600" fill="${palette.inkSecondary}">save &#8226; share &#8226; swipe  &#8594;</text>`;
  return shell(inner, page);
}

function finalSlide() {
  const inner = `
    <image href="${logoData}" x="72" y="175" width="118" height="118"/>
    <text x="72" y="420" class="serif" font-size="86" font-weight="700" fill="${palette.sindoor}">
      <tspan x="72" dy="0">Your chart.</tspan>
      <tspan x="72" dy="102">Explained simply.</tspan>
    </text>
    <text x="76" y="595" class="sans" font-size="25" font-weight="700" letter-spacing="3" fill="${palette.inkSecondary}">JYOTISH BAJE &#8226; AI-BASED JYOTISH APP</text>
    <line x1="72" y1="670" x2="1008" y2="670" stroke="${palette.templeGold}" stroke-opacity=".28"/>
    <text x="72" y="755" class="serif" font-size="37" font-weight="700" fill="${palette.sindoor}">TRY JYOTISH  &#8594;</text>
    <text x="72" y="845" class="serif" font-size="37" font-weight="700" fill="${palette.sindoor}">COMMENT YOUR SIGN  &#8595;</text>
    <text x="72" y="935" class="serif" font-size="37" font-weight="700" fill="${palette.sindoor}">SAVE THIS POST  +</text>
    <text x="72" y="1025" class="serif" font-size="37" font-weight="700" fill="${palette.sindoor}">SHARE WITH A FRIEND  &#8594;</text>
    <text x="72" y="1165" class="sans" font-size="24" fill="${palette.inkPrimary}">Birth-chart insights &#8226; Daily guidance &#8226; Ask questions</text>
    <text x="72" y="1220" class="sans" font-size="19" fill="${palette.inkSecondary}">AI guidance for reflection, not certainty.</text>`;
  return shell(inner, 14);
}

async function renderContactSheet(pngPaths) {
  const thumbWidth = 540;
  const thumbHeight = 675;
  const columns = 4;
  const rows = Math.ceil(pngPaths.length / columns);
  const composites = [];

  for (let index = 0; index < pngPaths.length; index += 1) {
    const input = await sharp(pngPaths[index]).resize(thumbWidth, thumbHeight, { fit: "fill" }).png().toBuffer();
    composites.push({ input, left: (index % columns) * thumbWidth, top: Math.floor(index / columns) * thumbHeight });
  }

  fs.mkdirSync(proofDir, { recursive: true });
  await sharp({ create: { width: columns * thumbWidth, height: rows * thumbHeight, channels: 4, background: palette.bgCanvas } })
    .composite(composites)
    .png()
    .toFile(path.join(proofDir, "daily-carousel-14-slide-contact-sheet.png"));
}

async function main() {
  const svgDir = path.join(base, "design-source", "daily");
  const pngDir = path.join(base, "daily");
  fs.mkdirSync(svgDir, { recursive: true });
  fs.mkdirSync(pngDir, { recursive: true });

  const slides = [cover(), ...edition.signs.map(signSlide), finalSlide()];
  const pngPaths = [];
  for (let index = 0; index < slides.length; index += 1) {
    const number = String(index + 1).padStart(2, "0");
    const svgPath = path.join(svgDir, `${number}.svg`);
    const pngPath = path.join(pngDir, `${number}.png`);
    fs.writeFileSync(svgPath, slides[index], "utf8");
    await sharp(svgPath).png().toFile(pngPath);
    pngPaths.push(pngPath);
  }
  await renderContactSheet(pngPaths);
  console.log(`Rendered ${pngPaths.length} daily slides for ${date}.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
