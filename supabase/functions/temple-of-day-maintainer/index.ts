const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const BUCKET = "temple-of-day";
const MIN_BUFFER_DAYS = 3;
const TARGET_BUFFER_DAYS = 7;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "https://ghfcssxptpazfbtiwshz.supabase.co";
const IMAGE_MODEL = Deno.env.get("OPENAI_TEMPLE_IMAGE_MODEL") ?? "gpt-image-2";

const tithiNames = [
  "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashthi",
  "Saptami", "Ashtami", "Navami", "Dashami", "Ekadashi", "Dwadashi",
  "Trayodashi", "Chaturdashi", "Purnima",
];

type Temple = {
  id: string;
  nameEN: string;
  deity: string;
  setting: string;
  palette: string;
  blurbEN: string;
};

type Tithi = {
  index: number;
  inPaksha: number;
  isShukla: boolean;
  label: string;
};

type DayInfo = {
  adDate: string;
  weekday: number;
  tithi: Tithi;
};

type ManifestItem = {
  adDate: string;
  bsDate?: string;
  tithi?: string;
  deity?: string;
  templeId: string;
  templeName: string;
  nameEN?: string;
  nameNE?: string;
  blurbEN?: string;
  blurbNE?: string;
  file: string;
  storagePath: string;
  sourceScheduleReason: string;
  publicUrl: string;
  generatedAt?: string;
  model?: string;
};

type Manifest = {
  bucket: string;
  generatedAt: string;
  updatedAt?: string;
  style: string;
  status: string;
  items: ManifestItem[];
};

const catalog: Record<string, Temple> = {
  pashupatinath: {
    id: "pashupatinath",
    nameEN: "Pashupatinath Temple",
    deity: "Shiva",
    setting: "a riverside Kathmandu temple with stone ghats, shrines, and the Bagmati",
    palette: "saffron gold, brick red, indigo sky, deep blue-green water, Himalayan greens",
    blurbEN: "A Shiva shrine on the Bagmati, chosen for Shiva vrata and Monday remembrance.",
  },
  gokarneshwar: {
    id: "gokarneshwar",
    nameEN: "Gokarneshwar Mahadev Temple",
    deity: "Shiva and ancestors",
    setting: "a forested Kathmandu riverside shrine with old stone steps and quiet water",
    palette: "midnight indigo, blue-green forest, charcoal stone, antique gold lamp light",
    blurbEN: "A riverside Shiva shrine associated with ancestor remembrance on Aunsi.",
  },
  changu_narayan: {
    id: "changu_narayan",
    nameEN: "Changu Narayan Temple",
    deity: "Vishnu",
    setting: "an ancient hilltop Nepalese temple near Bhaktapur with carved stone guardians and valley terraces",
    palette: "soft gold, warm sandstone, terracotta, leaf green, pale cyan sky, lavender hills",
    blurbEN: "An ancient Vishnu temple chosen for a fresh lunar beginning.",
  },
  manakamana: {
    id: "manakamana",
    nameEN: "Manakamana Temple",
    deity: "Bhagwati",
    setting: "a hilltop Nepalese pagoda reached by a stone path above forested ridges and terraces",
    palette: "saffron gold, vermilion red, forest green, mossy stone, rose clouds",
    blurbEN: "A wish-granting Bhagwati shrine chosen for a quiet household sankalpa.",
  },
  guhyeshwari: {
    id: "guhyeshwari",
    nameEN: "Guhyeshwari Shakti Peeth",
    deity: "Shakti and Parvati",
    setting: "a sacred pagoda shrine embraced by ancient trees in a monsoon-green Kathmandu grove",
    palette: "peepal green, deep jade, wet charcoal stone, vermilion, marigold gold, clouded blue-gray",
    blurbEN: "A Shakti shrine chosen for Gauri and Devi vrata logic.",
  },
  dakshinkali: {
    id: "dakshinkali",
    nameEN: "Dakshinkali Temple",
    deity: "Kali",
    setting: "a Kali shrine in a lush forested gorge south of Kathmandu with stone steps and lamps",
    palette: "deep green, black stone, vermilion, saffron, misty blue",
    blurbEN: "A Devi shrine chosen for Ashtami and fierce protective tithis.",
  },
  gorkha_kalika: {
    id: "gorkha_kalika",
    nameEN: "Gorkha Kalika Temple",
    deity: "Bhagwati and Kali",
    setting: "a hilltop Nepalese pagoda above Gorkha Durbar with mountain ridges and prayer flags",
    palette: "gold, brick red, pine green, clear Himalayan blue, cloud white",
    blurbEN: "A Bhagwati shrine chosen for Durga and victory tithis.",
  },
  budhanilkantha: {
    id: "budhanilkantha",
    nameEN: "Budhanilkantha Temple",
    deity: "Narayana and Vishnu",
    setting: "a reclining Vishnu shrine in a lotus pond at the green northern rim of Kathmandu",
    palette: "deep teal water, lotus pink, forest green, stone gray, Vishnu gold",
    blurbEN: "The reclining Narayana shrine chosen for Vishnu vrata days.",
  },
  ashok_binayak: {
    id: "ashok_binayak",
    nameEN: "Ashok Binayak Temple",
    deity: "Ganesh",
    setting: "a compact Kathmandu Ganesh shrine in an old brick courtyard with marigold offerings",
    palette: "vermilion, marigold, warm brick, dark wood, soft morning blue",
    blurbEN: "A Ganesh shrine chosen for Chaturthi.",
  },
  nag_pokhari: {
    id: "nag_pokhari",
    nameEN: "Nag Pokhari",
    deity: "Naga",
    setting: "a quiet Kathmandu pond with a small serpent shrine, lotus leaves, and monsoon trees",
    palette: "jade, pond blue, moss, stone gray, copper lamps, lotus pink",
    blurbEN: "A naga shrine and pond chosen for Panchami.",
  },
  surya_binayak: {
    id: "surya_binayak",
    nameEN: "Surya Binayak Temple",
    deity: "Surya and Ganesh",
    setting: "a forested Bhaktapur hillside shrine with golden morning light and stone stairs",
    palette: "sunrise gold, leaf green, red brick, sky blue, warm stone",
    blurbEN: "A protective solar and Ganesh shrine for Shashthi and Saptami.",
  },
  doleshwar: {
    id: "doleshwar",
    nameEN: "Doleshwar Mahadev Temple",
    deity: "Shiva",
    setting: "a Bhaktapur stone temple courtyard with a Shiva shrine, lamps, and monsoon hills",
    palette: "charcoal stone, copper, saffron, forest green, violet dusk",
    blurbEN: "A second Nepal Shiva anchor for Chaturdashi and strong Shiva tithis.",
  },
  swayambhu: {
    id: "swayambhu",
    nameEN: "Swayambhunath",
    deity: "Buddha and sacred illumination",
    setting: "the hilltop Swayambhu stupa above Kathmandu with prayer flags, lamps, and valley haze",
    palette: "white, saffron, turquoise, dusk violet, Kathmandu greens",
    blurbEN: "A hilltop stupa chosen for full-moon illumination and pilgrimage.",
  },
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    authorize(req);
    const result = await maintainBuffer();
    return json(result, result.bufferDays >= MIN_BUFFER_DAYS ? 200 : 503);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return json({ error: message }, 500);
  }
});

async function maintainBuffer() {
  const today = kathmanduDate(new Date());
  const manifest = await loadManifest(today);
  const generated: string[] = [];
  const skipped: string[] = [];
  const failed: { date: string; error: string }[] = [];

  for (let offset = 0; offset < TARGET_BUFFER_DAYS; offset += 1) {
    const day = addDays(today, offset);
    const existing = manifest.items.find((item) => item.adDate === day);
    if (existing && await publicObjectExists(existing.publicUrl)) {
      skipped.push(day);
      continue;
    }

    try {
      const info = dayInfo(day);
      const temple = chooseTemple(info);
      const file = `${day}_${temple.id}-${slug(info.tithi.label)}.png`;
      const storagePath = `${bsYear(day)}/${file}`;
      const image = await generateImage(info, temple);
      await uploadObject(storagePath, image, "image/png");
      const item: ManifestItem = {
        adDate: day,
        tithi: `${info.tithi.isShukla ? "Shukla" : "Krishna"} ${info.tithi.label}`,
        deity: temple.deity,
        templeId: temple.id,
        templeName: temple.nameEN,
        nameEN: temple.nameEN,
        blurbEN: temple.blurbEN,
        file,
        storagePath,
        sourceScheduleReason: reasonFor(info, temple),
        publicUrl: publicURL(storagePath),
        generatedAt: new Date().toISOString(),
        model: IMAGE_MODEL,
      };
      manifest.items = [...manifest.items.filter((candidate) => candidate.adDate !== day), item];
      generated.push(`${day}:${temple.id}`);
    } catch (error) {
      failed.push({ date: day, error: error instanceof Error ? error.message : String(error) });
    }
  }

  const bufferDays = await contiguousBufferDays(today, manifest.items);
  if (generated.length > 0) await saveManifest(manifest, today);

  return {
    generated,
    skipped,
    failed,
    bufferDays,
    minBufferDays: MIN_BUFFER_DAYS,
    targetBufferDays: TARGET_BUFFER_DAYS,
    checkedAt: new Date().toISOString(),
  };
}

function authorize(req: Request) {
  const key = trustedServiceKey();
  if (!key || req.headers.get("authorization") !== `Bearer ${key}`) {
    throw new Error("Unauthorized");
  }
}

async function loadManifest(today: string): Promise<Manifest> {
  const empty = (): Manifest => ({
    bucket: BUCKET,
    generatedAt: today,
    style: "16-bit pixel art, square PNG, Nepal temple with relevant natural or sacred background",
    status: "generated-ready-for-upload",
    items: [],
  });
  const urls = [publicURL("manifest.json"), publicURL(`${bsYear(today)}/manifest.json`)];
  for (const url of urls) {
    try {
      const response = await fetch(url);
      if (!response.ok) continue;
      const parsed = await response.json() as Partial<Manifest>;
      return {
        ...empty(),
        ...parsed,
        items: Array.isArray(parsed.items) ? parsed.items : [],
      };
    } catch {
      // A missing public manifest is expected on the first run.
    }
  }
  return empty();
}

async function saveManifest(manifest: Manifest, today: string) {
  const value: Manifest = {
    ...manifest,
    status: "uploaded-to-supabase",
    updatedAt: new Date().toISOString(),
    items: [...manifest.items].sort((a, b) => a.adDate.localeCompare(b.adDate)),
  };
  const body = new TextEncoder().encode(JSON.stringify(value, null, 2));
  await uploadObject("manifest.json", body, "application/json");
  await uploadObject(`${bsYear(today)}/manifest.json`, body, "application/json");
}

async function generateImage(info: DayInfo, temple: Temple): Promise<Uint8Array> {
  const key = Deno.env.get("OPENAI_API_KEY");
  if (!key) throw new Error("OPENAI_API_KEY is missing");
  const response = await fetch("https://api.openai.com/v1/images/generations", {
    method: "POST",
    headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: IMAGE_MODEL,
      prompt: imagePrompt(info, temple),
      size: "1024x1024",
      quality: Deno.env.get("OPENAI_TEMPLE_IMAGE_QUALITY") ?? "medium",
      output_format: "png",
      background: "opaque",
    }),
  });
  const data = await response.json() as { data?: { b64_json?: string }[]; error?: { message?: string } };
  if (!response.ok) throw new Error(`OpenAI image generation failed (${response.status}): ${data.error?.message ?? "unknown error"}`);
  const encoded = data.data?.[0]?.b64_json;
  if (!encoded) throw new Error("OpenAI image response did not contain b64_json");
  return Uint8Array.from(atob(encoded), (character) => character.charCodeAt(0));
}

function imagePrompt(info: DayInfo, temple: Temple): string {
  return `Create a square 1:1 premium Nepal devotional pixel-art background for the Temple of the Day app.
The selected temple is ${temple.nameEN}, associated with ${temple.deity}. It should visibly depict ${temple.setting}.
This is ${info.tithi.isShukla ? "Shukla" : "Krishna"} ${info.tithi.label}, so the atmosphere should quietly reflect that lunar tithi and its deity association without adding any text.
Use richly detailed hand-crafted pixel art with crisp visible square pixels, 16-bit-inspired but high-resolution painterly pixel clusters, layered nature depth, authentic Nepalese architecture, and a calm sacred composition with the temple fully visible and centered.
Use this palette: ${temple.palette}.
No readable text, no signage, no logo, no watermark, no border, no close-up people, no modern buildings, no fantasy architecture.`;
}

function chooseTemple(info: DayInfo): Temple {
  const tithi = info.tithi.inPaksha;
  const id = info.weekday === 1 && tithi <= 10
    ? "pashupatinath"
    : tithi === 4 ? "ashok_binayak"
    : tithi === 5 ? "nag_pokhari"
    : tithi === 8 ? "dakshinkali"
    : tithi === 9 || tithi === 10 ? "gorkha_kalika"
    : tithi === 11 ? "budhanilkantha"
    : tithi === 12 || tithi === 13 ? "pashupatinath"
    : tithi === 14 ? "doleshwar"
    : tithi === 15 && !info.tithi.isShukla ? "gokarneshwar"
    : tithi === 15 ? "swayambhu"
    : tithi === 1 ? "changu_narayan"
    : tithi === 2 ? "manakamana"
    : tithi === 3 ? "guhyeshwari"
    : tithi === 6 || tithi === 7 ? "surya_binayak"
    : "changu_narayan";
  return catalog[id];
}

function reasonFor(info: DayInfo, temple: Temple): string {
  return `${info.tithi.isShukla ? "Shukla" : "Krishna"} ${info.tithi.label} is matched to ${temple.deity} worship; ${temple.nameEN} is the selected Nepal anchor.`;
}

async function contiguousBufferDays(today: string, items: ManifestItem[]): Promise<number> {
  let count = 0;
  for (let offset = 0; offset < TARGET_BUFFER_DAYS; offset += 1) {
    const date = addDays(today, offset);
    const item = items.find((candidate) => candidate.adDate === date);
    if (!item || !(await publicObjectExists(item.publicUrl))) break;
    count += 1;
  }
  return count;
}

async function publicObjectExists(url: string): Promise<boolean> {
  try {
    const response = await fetch(url, { method: "HEAD" });
    return response.ok;
  } catch {
    return false;
  }
}

async function uploadObject(path: string, body: Uint8Array, contentType: string) {
  const key = trustedServiceKey();
  if (!key) throw new Error("TEMPLE_OF_DAY_SERVICE_ROLE_KEY is missing");
  const response = await fetch(`${SUPABASE_URL}/storage/v1/object/${BUCKET}/${path}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      apikey: key,
      "Content-Type": contentType,
      "x-upsert": "true",
    },
    body,
  });
  if (!response.ok) throw new Error(`Supabase storage upload failed (${response.status})`);
}

function trustedServiceKey(): string | undefined {
  return Deno.env.get("TEMPLE_OF_DAY_SERVICE_ROLE_KEY")
    ?? Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
}

function publicURL(path: string): string {
  return `${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${path}`;
}

function dayInfo(adDate: string): DayInfo {
  const [year, month, day] = adDate.split("-").map(Number);
  const jd = julianDay(year, month, day, 0);
  const sun = sunTropical(jd);
  const moon = moonTropical(jd);
  const diff = norm360(moon - sun);
  const index = Math.min(29, Math.floor(diff / 12));
  const isShukla = index < 15;
  const inPaksha = index % 15 + 1;
  const label = inPaksha === 15 ? (isShukla ? "Purnima" : "Aunsi") : tithiNames[inPaksha - 1];
  const weekday = new Date(`${adDate}T12:00:00Z`).getUTCDay();
  return { adDate, weekday, tithi: { index, inPaksha, isShukla, label } };
}

function kathmanduDate(date: Date): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kathmandu", year: "numeric", month: "2-digit", day: "2-digit",
  }).format(date);
}

function addDays(date: string, amount: number): string {
  const value = new Date(`${date}T12:00:00Z`);
  value.setUTCDate(value.getUTCDate() + amount);
  return value.toISOString().slice(0, 10);
}

function bsYear(adDate: string): number {
  const [year, month, day] = adDate.split("-").map(Number);
  return year + (month > 4 || (month === 4 && day >= 14) ? 57 : 56);
}

function slug(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function norm360(value: number): number {
  const result = value % 360;
  return result < 0 ? result + 360 : result;
}

function deg2rad(value: number): number { return value * Math.PI / 180; }

function julianDay(year: number, month: number, day: number, hourUT: number): number {
  let y = year;
  let m = month;
  if (m <= 2) { y -= 1; m += 12; }
  const a = Math.floor(y / 100);
  const b = 2 - a + Math.floor(a / 4);
  return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + day + b - 1524.5 + hourUT / 24;
}

function sunTropical(jd: number): number {
  const t = (jd - 2451545.0) / 36525;
  const l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  const m = deg2rad(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
  const c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * Math.sin(m)
    + (0.019993 - 0.000101 * t) * Math.sin(2 * m)
    + 0.000289 * Math.sin(3 * m);
  return norm360(l0 + c);
}

function moonTropical(jd: number): number {
  const t = (jd - 2451545.0) / 36525;
  const lp = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t;
  const d = deg2rad(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t);
  const m = deg2rad(357.5291092 + 35999.0502909 * t);
  const mp = deg2rad(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t);
  const f = deg2rad(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t);
  let lon = lp;
  lon += 6.288774 * Math.sin(mp);
  lon += 1.274027 * Math.sin(2 * d - mp);
  lon += 0.658314 * Math.sin(2 * d);
  lon += 0.213618 * Math.sin(2 * mp);
  lon -= 0.185116 * Math.sin(m);
  lon -= 0.114332 * Math.sin(2 * f);
  lon += 0.058793 * Math.sin(2 * d - 2 * mp);
  lon += 0.057066 * Math.sin(2 * d - m - mp);
  lon += 0.053322 * Math.sin(2 * d + mp);
  lon += 0.045758 * Math.sin(2 * d - m);
  lon -= 0.040923 * Math.sin(m - mp);
  lon -= 0.034720 * Math.sin(d);
  lon -= 0.030383 * Math.sin(m + mp);
  lon += 0.015327 * Math.sin(2 * d - 2 * f);
  lon -= 0.012528 * Math.sin(2 * f + mp);
  return norm360(lon);
}

function json(value: unknown, status = 200): Response {
  return new Response(JSON.stringify(value), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
