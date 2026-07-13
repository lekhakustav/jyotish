import React from "react";
import Svg, { Circle, G, Line, Path, Polyline, Rect } from "react-native-svg";
import { View } from "react-native";
import type { RashiKey } from "@/types";
import { palette } from "@/theme";

export type AppIconName =
  | "home"
  | "sun"
  | "family"
  | "settings"
  | "calendar"
  | "history"
  | "close"
  | "plus"
  | "chevron-left"
  | "chevron-right"
  | "arrow-right"
  | "arrow-up-right"
  | "send"
  | "microphone"
  | "volume"
  | "profile"
  | "sparkle"
  | "clock"
  | "edit"
  | "trash"
  | "message"
  | "globe"
  | "moon"
  | "qr-code"
  | "scan";

export function AppIcon({ name, size = 24, color = palette.inkPrimary, strokeWidth = 1.8 }: {
  name: AppIconName;
  size?: number;
  color?: string;
  strokeWidth?: number;
}) {
  const common = { fill: "none", stroke: color, strokeWidth, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  let mark: React.ReactNode;
  switch (name) {
    case "home":
      mark = <><Path d="M3.5 10.5 12 3l8.5 7.5" {...common} /><Path d="M5.5 9.5V21h13V9.5M9 21v-7h6v7" {...common} /></>;
      break;
    case "sun":
      mark = <><Circle cx="12" cy="12" r="3.75" {...common} /><Path d="M12 2v2.2M12 19.8V22M2 12h2.2M19.8 12H22M4.9 4.9l1.55 1.55M17.55 17.55l1.55 1.55M19.1 4.9l-1.55 1.55M6.45 17.55 4.9 19.1" {...common} /></>;
      break;
    case "family":
      mark = <><Circle cx="9" cy="8" r="3" {...common} /><Circle cx="17" cy="10" r="2.4" {...common} /><Path d="M3.5 21v-2.2A5.5 5.5 0 0 1 9 13.3a5.5 5.5 0 0 1 5.5 5.5V21M14 14.8a4.5 4.5 0 0 1 6.5 4V21" {...common} /></>;
      break;
    case "settings":
      mark = <><Circle cx="12" cy="12" r="3" {...common} /><Path d="M19.4 15a1.7 1.7 0 0 0 .34 1.88l.06.06-2.83 2.83-.06-.06a1.7 1.7 0 0 0-1.88-.34 1.7 1.7 0 0 0-1.03 1.56V21h-4v-.08A1.7 1.7 0 0 0 9 19.37a1.7 1.7 0 0 0-1.88.34l-.06.06-2.83-2.83.06-.06A1.7 1.7 0 0 0 4.63 15 1.7 1.7 0 0 0 3.08 14H3v-4h.08A1.7 1.7 0 0 0 4.63 9a1.7 1.7 0 0 0-.34-1.88l-.06-.06 2.83-2.83.06.06A1.7 1.7 0 0 0 9 4.63 1.7 1.7 0 0 0 10 3.08V3h4v.08A1.7 1.7 0 0 0 15 4.63a1.7 1.7 0 0 0 1.88-.34l.06-.06 2.83 2.83-.06.06A1.7 1.7 0 0 0 19.37 9 1.7 1.7 0 0 0 20.92 10H21v4h-.08A1.7 1.7 0 0 0 19.4 15Z" {...common} /></>;
      break;
    case "calendar":
      mark = <><Rect x="3" y="5" width="18" height="16" rx="2.5" {...common} /><Path d="M7 3v4M17 3v4M3 10h18" {...common} /></>;
      break;
    case "history":
      mark = <><Path d="M3 12a9 9 0 1 0 3-6.7L3 8" {...common} /><Path d="M3 3v5h5M12 7v5l3.4 2" {...common} /></>;
      break;
    case "close":
      mark = <Path d="M5 5l14 14M19 5 5 19" {...common} />;
      break;
    case "plus":
      mark = <Path d="M12 4v16M4 12h16" {...common} />;
      break;
    case "chevron-left":
      mark = <Polyline points="15 4 7 12 15 20" {...common} />;
      break;
    case "chevron-right":
      mark = <Polyline points="9 4 17 12 9 20" {...common} />;
      break;
    case "arrow-right":
      mark = <><Path d="M4 12h16M14 6l6 6-6 6" {...common} /></>;
      break;
    case "arrow-up-right":
      mark = <><Path d="M5 19 19 5M10 5h9v9" {...common} /></>;
      break;
    case "send":
      mark = <Path d="m3 11 18-8-8 18-2-8-8-2Zm8 2 4-4" {...common} />;
      break;
    case "microphone":
      mark = <><Rect x="9" y="3" width="6" height="11" rx="3" {...common} /><Path d="M5.5 11.5a6.5 6.5 0 0 0 13 0M12 18v3M8.5 21h7" {...common} /></>;
      break;
    case "volume":
      mark = <><Path d="M4 10v4h4l5 4V6l-5 4H4Z" {...common} /><Path d="M16 9a4 4 0 0 1 0 6M18.5 6.5a7.5 7.5 0 0 1 0 11" {...common} /></>;
      break;
    case "profile":
      mark = <><Circle cx="12" cy="8" r="4" {...common} /><Path d="M4.5 21a7.5 7.5 0 0 1 15 0" {...common} /></>;
      break;
    case "sparkle":
      mark = <><Path d="M12 2c.8 5.5 2.5 8 8 10-5.5 2-7.2 4.5-8 10-.8-5.5-2.5-8-8-10 5.5-2 7.2-4.5 8-10Z" {...common} /><Path d="M19 3v4M17 5h4" {...common} /></>;
      break;
    case "clock":
      mark = <><Circle cx="12" cy="12" r="9" {...common} /><Path d="M12 7v5l3.5 2" {...common} /></>;
      break;
    case "edit":
      mark = <><Path d="m14.5 5.5 4 4L8 20H4v-4L14.5 5.5ZM12.5 7.5l4 4" {...common} /></>;
      break;
    case "trash":
      mark = <><Path d="M4 7h16M9 3h6l1 4H8l1-4ZM6.5 7l1 14h9l1-14M10 11v6M14 11v6" {...common} /></>;
      break;
    case "message":
      mark = <Path d="M4 4h16v12H9l-5 4V4Z" {...common} />;
      break;
    case "globe":
      mark = <><Circle cx="12" cy="12" r="9" {...common} /><Path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18" {...common} /></>;
      break;
    case "moon":
      mark = <Path d="M20 15.2A8.5 8.5 0 0 1 8.8 4a8.5 8.5 0 1 0 11.2 11.2Z" {...common} />;
      break;
    case "qr-code":
      mark = <><Rect x="3" y="3" width="7" height="7" rx="1" {...common} /><Rect x="14" y="3" width="7" height="7" rx="1" {...common} /><Rect x="3" y="14" width="7" height="7" rx="1" {...common} /><Path d="M15 15h2v2h-2zM19 14v3h2M14 20h3M20 20h1" {...common} /></>;
      break;
    case "scan":
      mark = <><Path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3M21 16v3a2 2 0 0 1-2 2h-3M8 21H5a2 2 0 0 1-2-2v-3" {...common} /><Rect x="8" y="8" width="8" height="8" rx="1" {...common} /></>;
      break;
  }
  return <Svg width={size} height={size} viewBox="0 0 24 24" accessible={false}>{mark}</Svg>;
}

const rashiPaths: Record<RashiKey, string> = {
  mesh: "M50 32 C30 6 4 2 13 12 C20 26 14 36 30 36 M50 32 C70 6 96 2 87 12 C80 26 86 36 70 36 M30 38 C30 64 36 88 50 88 C64 88 70 64 70 38",
  vrish: "M50 42 C28 30 10 32 5 16 M50 42 C72 30 90 32 95 16 M28 40 H72 V82 H28 Z M41 79 A9 7 0 1 0 59 79 A9 7 0 1 0 41 79",
  mithun: "M19 20 A8.5 8.5 0 1 0 17 0 M65 20 A8.5 8.5 0 1 0 17 0 M27.5 31 V80 M13 48 H42 M27.5 80 L15 94 M27.5 80 L40 94 M73.5 31 V80 M59 48 H88 M73.5 80 L61 94 M73.5 80 L86 94",
  karkat: "M27 56 A23 16 0 1 0 73 56 A23 16 0 1 0 27 56 M32 46 C20 42 11 32 7 20 C2 12 11 22 20 30 M68 46 C80 42 89 32 93 20 C98 12 89 22 80 30 M34 64 L20 78 M38 64 L14 82 M42 64 L8 86 M66 64 L80 78 M62 64 L86 82 M58 64 L92 86",
  simha: "M33 50 A17 17 0 1 0 67 50 A17 17 0 1 0 33 50",
  kanya: "M42 18 A8 8 0 1 0 58 18 A8 8 0 1 0 42 18 M50 26 V35 M38 37 C30 50 22 68 24 86 H76 C78 68 70 50 62 37 Z M60 44 L86 28 M70 40 L78 34 M80 27 L88 21 M90 14 L98 8",
  tula: "M50 18 V82 M30 82 H70 M14 32 H86 M6 32 H24 M6 32 C8 50 22 50 24 32 M76 32 H94 M76 32 C78 50 92 50 94 32",
  vrischik: "M18 32 C12 26 6 20 6 14 M32 32 C28 24 24 18 24 10 M18 32 L48 52 C68 62 90 58 85 38 C80 18 72 10 68 18 M68 18 L80 10",
  dhanu: "M22 14 C64 30 64 70 22 86 M22 14 V86 M16 50 H90 M90 50 L74 38 M90 50 L74 62",
  makar: "M24 18 C16 9 7 11 9 15 M24 18 L36 42 H19 M36 42 C52 44 62 48 74 58 C92 66 96 80 80 84 C68 86 60 80 58 74",
  kumbha: "M36 12 L32 26 C28 34 38 38 50 38 C62 38 62 28 60 22 L56 12 Z M12 58 C32 44 68 72 88 58 M12 80 C32 66 68 94 88 80",
  meen: "M13 30 C30 16 42 30 50 46 C42 58 28 68 13 58 L3 44 Z M87 42 C70 56 58 42 50 58 C58 70 72 80 87 70 L97 56 Z"
};

function RashiFill({ rashi, color }: { rashi: RashiKey; color: string }) {
  switch (rashi) {
    case "karkat": return <Rect x="27" y="40" width="46" height="32" rx="16" fill={color} />;
    case "simha": return <Circle cx="50" cy="50" r="17" fill={color} />;
    case "mithun": return <><Circle cx="27.5" cy="20.5" r="8.5" fill={color} /><Circle cx="73.5" cy="20.5" r="8.5" fill={color} /></>;
    case "vrish": return <Rect x="28" y="40" width="44" height="42" rx="12" fill={color} />;
    case "kanya": return <><Path d="M38 37 C30 50 22 68 24 86 H76 C78 68 70 50 62 37 Z" fill={color} /><Circle cx="50" cy="18" r="8" fill={color} /></>;
    default: return null;
  }
}

export function RashiMark({ rashi, size = 56, color = palette.sindoor }: { rashi: RashiKey; size?: number; color?: string }) {
  const mane = rashi === "simha" ? Array.from({ length: 12 }, (_, index) => {
    const angle = index / 12 * Math.PI * 2;
    return <Line key={index} x1={50 + 20 * Math.cos(angle)} y1={50 + 20 * Math.sin(angle)} x2={50 + 34 * Math.cos(angle)} y2={50 + 34 * Math.sin(angle)} stroke={color} strokeWidth="8" strokeLinecap="round" />;
  }) : null;
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100" accessible={false}>
      <Circle cx="50" cy="50" r="48" fill="none" stroke={palette.templeGold} strokeOpacity={0.4} strokeWidth={Math.max(1.2, size * 0.018) * 100 / size} />
      <G transform="translate(20 20) scale(.6)">
        <RashiFill rashi={rashi} color={color} />
        {mane}
        <Path d={rashiPaths[rashi]} fill="none" stroke={color} strokeWidth="8" strokeLinecap="round" strokeLinejoin="round" />
      </G>
    </Svg>
  );
}

function starPath(size: number) {
  const outer = size / 2;
  const inner = outer * 0.382;
  const points = Array.from({ length: 10 }, (_, index) => {
    const angle = index * Math.PI / 5 - Math.PI / 2;
    const radius = index % 2 === 0 ? outer : inner;
    return `${outer + Math.cos(angle) * radius},${outer + Math.sin(angle) * radius}`;
  });
  return `M${points.join(" L")} Z`;
}

export function YantraScore({ score, size = 12.5, accessibilityLabel }: { score: number; size?: number; accessibilityLabel?: string }) {
  const value = Math.max(0, Math.min(5, Math.round(score)));
  return (
    <View
      accessible
      accessibilityRole="text"
      accessibilityLabel={accessibilityLabel ?? `${value} of 5`}
      style={{ flexDirection: "row", gap: 3, alignItems: "center" }}
    >
      {Array.from({ length: 5 }, (_, index) => (
        <Svg key={index} width={size} height={size} viewBox={`0 0 ${size} ${size}`} accessible={false}>
          <Path d={starPath(size)} fill={index < value ? palette.templeGold : palette.inkSecondary} fillOpacity={index < value ? 1 : 0.36} />
        </Svg>
      ))}
    </View>
  );
}
