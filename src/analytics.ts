import * as Crypto from "expo-crypto";
import * as SecureStore from "expo-secure-store";
import { supabase } from "@/supabase";

type PropertyValue = string | number | boolean | null;
type AnalyticsProperties = Record<string, PropertyValue>;

type PendingEvent = {
  event_id: string;
  session_id: string;
  install_id: string;
  event_name: string;
  properties: AnalyticsProperties;
  occurred_at: string;
};

const queueKey = "jyotish.analytics.pending.v1";
const installKey = "jyotish.analytics.install.v1";
const sessionID = Crypto.randomUUID();
let queue: PendingEvent[] = [];
let installID: string | undefined;
let loaded: Promise<void> | undefined;
let flushTimer: ReturnType<typeof setTimeout> | undefined;

function sanitizeName(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9_]+/g, "_").replace(/^_+|_+$/g, "").slice(0, 64) || "unknown";
}

function sanitizeProperties(properties: AnalyticsProperties): AnalyticsProperties {
  return Object.fromEntries(Object.entries(properties).slice(0, 32).map(([key, value]) => [sanitizeName(key), typeof value === "string" ? value.slice(0, 160) : value]));
}

async function load(): Promise<void> {
  if (loaded) return loaded;
  loaded = (async () => {
    installID = await SecureStore.getItemAsync(installKey) || Crypto.randomUUID();
    await SecureStore.setItemAsync(installKey, installID);
    const raw = await SecureStore.getItemAsync(queueKey);
    if (raw) queue = JSON.parse(raw) as PendingEvent[];
  })().catch(() => undefined);
  return loaded;
}

async function persist(): Promise<void> {
  await SecureStore.setItemAsync(queueKey, JSON.stringify(queue.slice(-250)));
}

async function flush(): Promise<void> {
  await load();
  if (!queue.length) return;
  const { data } = await supabase.auth.getUser();
  const userID = data.user?.id;
  if (!userID) return;
  const batch = queue.slice(0, 100);
  const { error } = await supabase.from("analytics_events").insert(batch.map((event) => ({ ...event, user_id: userID })));
  if (error) return;
  const sent = new Set(batch.map((event) => event.event_id));
  queue = queue.filter((event) => !sent.has(event.event_id));
  await persist();
}

/**
 * Records privacy-safe product telemetry. Never pass names, birth details,
 * email addresses, or raw chat text in `properties`.
 */
export function track(eventName: string, properties: AnalyticsProperties = {}): void {
  void load().then(async () => {
    queue.push({
      event_id: Crypto.randomUUID(),
      session_id: sessionID,
      install_id: installID || Crypto.randomUUID(),
      event_name: sanitizeName(eventName),
      properties: sanitizeProperties(properties),
      occurred_at: new Date().toISOString()
    });
    queue = queue.slice(-250);
    await persist();
    if (flushTimer) clearTimeout(flushTimer);
    flushTimer = setTimeout(() => void flush(), 1200);
  });
}

