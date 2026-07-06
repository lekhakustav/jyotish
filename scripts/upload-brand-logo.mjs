#!/usr/bin/env node
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

loadEnv(resolve(process.cwd(), ".env.local"));

const supabaseURL = process.env.SUPABASE_URL || "https://ghfcssxptpazfbtiwshz.supabase.co";
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const bucket = process.env.SUPABASE_BRAND_BUCKET || "temple-of-day";
const objectPath = process.env.SUPABASE_BRAND_LOGO_PATH || "brand/jyotish-baje-logo-1024.png";
const filePath = resolve(process.cwd(), "assets/brand/jyotish-baje-logo-1024.png");

if (!serviceRoleKey) {
  console.error("SUPABASE_SERVICE_ROLE_KEY is required for trusted brand asset upload.");
  process.exit(1);
}

if (!existsSync(filePath)) {
  console.error(`Missing brand logo: ${filePath}`);
  process.exit(1);
}

const response = await fetch(`${supabaseURL}/storage/v1/object/${bucket}/${objectPath}`, {
  method: "POST",
  headers: {
    "Authorization": `Bearer ${serviceRoleKey}`,
    "apikey": serviceRoleKey,
    "Content-Type": "image/png",
    "x-upsert": "true",
  },
  body: readFileSync(filePath),
});

const body = await response.text();
if (!response.ok) {
  console.error(`Upload failed (${response.status}): ${body}`);
  process.exit(1);
}

console.log(`${supabaseURL}/storage/v1/object/public/${bucket}/${objectPath}`);

function loadEnv(path) {
  if (!existsSync(path)) return;
  const raw = readFileSync(path, "utf8");
  for (const line of raw.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    if (!process.env[key]) process.env[key] = value;
  }
}
