#!/usr/bin/env node
import { chmodSync, readFileSync, writeFileSync } from "node:fs";

const sourcePath = ".env.local";
const serverPath = ".env.server.local";
const source = readFileSync(sourcePath, "utf8");
const publicLines = [];
const serverLines = [];

for (const line of source.split(/\r?\n/)) {
  const trimmed = line.trim();
  if (!trimmed) continue;
  if (trimmed.startsWith("#")) continue;
  const key = trimmed.split("=", 1)[0];
  if (key.startsWith("EXPO_PUBLIC_")) publicLines.push(line);
  else serverLines.push(line);
}

if (!publicLines.length || !serverLines.length) {
  throw new Error("Expected both public Expo and server-only variables in .env.local");
}

writeFileSync(sourcePath, `${publicLines.join("\n")}\n`, { mode: 0o600 });
writeFileSync(serverPath, `${serverLines.join("\n")}\n`, { mode: 0o600 });
chmodSync(sourcePath, 0o600);
chmodSync(serverPath, 0o600);
console.log(`Moved ${serverLines.length} server-only variables to ${serverPath}; kept ${publicLines.length} Expo public variables in ${sourcePath}.`);
