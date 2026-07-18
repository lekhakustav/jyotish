#!/usr/bin/env node

import { mkdir, readFile, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";

const DEFAULT_ENV_ROOT = "/Users/sirishjoshi/Documents/New project 2";
const DEFAULT_NEPALI_VOICE_ID = "6oN9zQt5lDqGi7wZn5p2";
const DEFAULT_MODEL_ID = "eleven_v3";

function parseArgs(argv) {
  const values = {};
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (!argument.startsWith("--")) continue;
    const key = argument.slice(2);
    const value = argv[index + 1];
    if (!value || value.startsWith("--")) throw new Error(`Missing value for --${key}`);
    values[key] = value;
    index += 1;
  }
  return values;
}

async function parseEnvFile(filePath) {
  if (!existsSync(filePath)) return {};
  const result = {};
  const contents = await readFile(filePath, "utf8");
  for (const rawLine of contents.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) continue;
    const separator = line.indexOf("=");
    if (separator < 1) continue;
    const key = line.slice(0, separator).trim();
    let value = line.slice(separator + 1).trim();
    if ((value.startsWith("\"") && value.endsWith("\""))
      || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    result[key] = value;
  }
  return result;
}

async function loadElevenLabsKey(envRoot) {
  const base = await parseEnvFile(path.join(envRoot, ".env"));
  const local = await parseEnvFile(path.join(envRoot, ".env.local"));
  const apiKey = local.ELEVENLABS_API_KEY || base.ELEVENLABS_API_KEY;
  if (!apiKey) throw new Error(`ELEVENLABS_API_KEY is not configured under ${envRoot}`);
  return apiKey;
}

const args = parseArgs(process.argv.slice(2));
const text = args.text?.trim();
const output = args.output ? path.resolve(args.output) : null;
const envRoot = args["env-root"] || DEFAULT_ENV_ROOT;
const voiceId = args["voice-id"] || DEFAULT_NEPALI_VOICE_ID;
const modelId = args["model-id"] || DEFAULT_MODEL_ID;
const speed = Number(args.speed || "1.08");

if (!text) throw new Error("--text is required");
if (!output) throw new Error("--output is required");
if (!Number.isFinite(speed) || speed < 0.7 || speed > 1.2) {
  throw new Error("--speed must be between 0.7 and 1.2");
}

const apiKey = await loadElevenLabsKey(envRoot);
const endpoint = new URL(`https://api.elevenlabs.io/v1/text-to-speech/${encodeURIComponent(voiceId)}`);
endpoint.searchParams.set("output_format", "mp3_44100_128");

const response = await fetch(endpoint, {
  method: "POST",
  headers: {
    "content-type": "application/json",
    "xi-api-key": apiKey,
  },
  body: JSON.stringify({
    text,
    model_id: modelId,
    language_code: "ne",
    voice_settings: {
      stability: 0.34,
      similarity_boost: 0.76,
      style: 0.52,
      use_speaker_boost: true,
      speed,
    },
  }),
});

if (!response.ok) {
  const detail = (await response.text()).slice(0, 500);
  throw new Error(`ElevenLabs request failed (${response.status}): ${detail}`);
}

const contentType = response.headers.get("content-type") || "";
if (!contentType.startsWith("audio/")) {
  throw new Error(`ElevenLabs returned ${contentType || "an unknown content type"}`);
}

const bytes = Buffer.from(await response.arrayBuffer());
await mkdir(path.dirname(output), { recursive: true });
await writeFile(output, bytes);

console.log(JSON.stringify({
  output,
  bytes: bytes.length,
  voiceId,
  modelId,
  languageCode: "ne",
  speed,
}));
