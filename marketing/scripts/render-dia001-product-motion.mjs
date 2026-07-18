import { chromium } from "playwright";
import { execFileSync } from "node:child_process";
import { mkdir, rm } from "node:fs/promises";
import path from "node:path";
import { pathToFileURL } from "node:url";

const root = path.resolve(import.meta.dirname, "../..");
const source = path.join(
  root,
  "marketing/creative/campaigns/launch-001/product-motion/dia001.html",
);
const outputDir = path.join(
  root,
  "marketing/media/launch-001/prototypes/dia001",
);
const recordingDir = path.join(outputDir, ".recording");
const output = path.join(
  outputDir,
  "med_20260718_dia001dr__cmp_20260716_launch__product-motion-draft__sita-sharma.mp4",
);

await mkdir(recordingDir, { recursive: true });

const browser = await chromium.launch({
  headless: true,
  executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  args: [
    "--allow-file-access-from-files",
    "--autoplay-policy=no-user-gesture-required",
  ],
});
const context = await browser.newContext({
  viewport: { width: 1080, height: 1920 },
  deviceScaleFactor: 1,
  recordVideo: {
    dir: recordingDir,
    size: { width: 1080, height: 1920 },
  },
});
const page = await context.newPage();
await page.goto(pathToFileURL(source).href, { waitUntil: "load" });
await page.waitForFunction(() => document.fonts.status === "loaded");
await page.waitForFunction(() => document.querySelector("video")?.readyState >= 2);

const recording = page.video();
await page.evaluate(() => window.startMotion());
await page.waitForTimeout(17_250);
await context.close();
await browser.close();

const recordedPath = await recording.path();
execFileSync(
  "ffmpeg",
  [
    "-y",
    "-i",
    recordedPath,
    "-vf",
    "fps=30,scale=1080:1920:flags=lanczos",
    "-an",
    "-c:v",
    "libx264",
    "-preset",
    "medium",
    "-crf",
    "23",
    "-pix_fmt",
    "yuv420p",
    "-movflags",
    "+faststart",
    output,
  ],
  { stdio: "inherit" },
);

await rm(recordingDir, { recursive: true, force: true });
console.log(output);
