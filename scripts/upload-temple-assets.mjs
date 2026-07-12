#!/usr/bin/env node
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(process.cwd());
loadEnv(resolve(root, ".env.local"));

const supabaseURL = process.env.SUPABASE_URL || "https://ghfcssxptpazfbtiwshz.supabase.co";
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const bucket = "temple-of-day";
const manifestPath = resolve(root, "assets/temple-of-day/2083/manifest.json");

if (!serviceRoleKey) {
  console.error("SUPABASE_SERVICE_ROLE_KEY is required for trusted temple asset upload.");
  process.exit(1);
}

const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
const assets = manifest.items.map((item) => ({
  path: item.storagePath,
  file: resolve(root, "assets/temple-of-day/2083", item.file),
  contentType: "image/png",
}));

const remoteManifest = await fetchPublicManifest();
const itemsByDate = new Map((remoteManifest?.items ?? []).map((item) => [item.adDate, item]));
for (const item of manifest.items) itemsByDate.set(item.adDate, item);
const mergedManifest = {
  ...(remoteManifest ?? {}),
  ...manifest,
  status: "uploaded-to-supabase",
  updatedAt: new Date().toISOString(),
  items: [...itemsByDate.values()].sort((a, b) => a.adDate.localeCompare(b.adDate)),
};

for (const asset of assets) {
  if (!existsSync(asset.file)) {
    console.error(`Missing temple asset: ${asset.file}`);
    process.exit(1);
  }
  await upload(asset.path, readFileSync(asset.file), asset.contentType);
}

const manifestBody = Buffer.from(JSON.stringify(mergedManifest, null, 2));
await upload("2083/manifest.json", manifestBody, "application/json");
await upload("manifest.json", manifestBody, "application/json");

const verificationPaths = [...assets.map((asset) => asset.path), "2083/manifest.json", "manifest.json"];
for (const path of verificationPaths) {
  const response = await fetch(publicURL(path), { method: "HEAD" });
  if (!response.ok) {
    console.error(`Public verification failed for ${path} (${response.status}).`);
    process.exit(1);
  }
}

console.log(`Uploaded and publicly verified ${assets.length} temple PNGs plus both manifests.`);

async function upload(path, body, contentType) {
  const response = await fetch(`${supabaseURL}/storage/v1/object/${bucket}/${path}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${serviceRoleKey}`,
      apikey: serviceRoleKey,
      "Content-Type": contentType,
      "x-upsert": "true",
    },
    body,
  });
  if (!response.ok) {
    const detail = await response.text();
    console.error(`Upload failed for ${path} (${response.status}): ${detail}`);
    process.exit(1);
  }
}

function publicURL(path) {
  return `${supabaseURL}/storage/v1/object/public/${bucket}/${path}`;
}

async function fetchPublicManifest() {
  try {
    const response = await fetch(publicURL("manifest.json"));
    if (!response.ok) return null;
    const value = await response.json();
    return Array.isArray(value.items) ? value : null;
  } catch {
    return null;
  }
}

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
