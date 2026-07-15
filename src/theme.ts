export type AppPalette = {
  bgCanvas: string;
  bgElevated: string;
  bgSunken: string;
  inkPrimary: string;
  inkSecondary: string;
  saffron: string;
  marigold: string;
  sindoor: string;
  templeGold: string;
  peepalGreen: string;
  lotusPink: string;
  hairline: string;
};

export const palette: AppPalette = {
  bgCanvas: "#FCF7ED",
  bgElevated: "#FFFDF7",
  bgSunken: "#F4ECDD",
  inkPrimary: "#3B1F14",
  inkSecondary: "#7A5C48",
  saffron: "#E8801A",
  marigold: "#F2A93B",
  sindoor: "#B9331F",
  templeGold: "#B8860B",
  peepalGreen: "#4F7942",
  lotusPink: "#D96C8A",
  hairline: "rgba(184, 134, 11, 0.22)"
};

/** Shared geometry mirrors Jyotish/DesignSystem/DesignTokens.swift. */
export const spacing = {
  xxs: 4,
  xs: 8,
  sm: 12,
  md: 16,
  lg: 24,
  xl: 32,
  section: 40
} as const;

export const layoutMetrics = {
  screenGutter: 24,
  sheetGutter: 20,
  minimumTouchTarget: 48,
  primaryButtonHeight: 56,
  primaryButtonRadius: 16,
  bottomShellWidth: 278,
  bottomShellHeight: 68,
  bottomShellMargin: 12
} as const;

export const motion = {
  springDuration: 450,
  springDamping: 0.85,
  pressedScale: 0.97
} as const;

export const darkPalette = {
  bgCanvas: "#17120C",
  bgElevated: "#1F1710",
  bgSunken: "#100B06",
  inkPrimary: "#F4E7CE",
  inkSecondary: "#C4A886",
  saffron: "#F49B3A",
  marigold: "#FFC15E",
  sindoor: "#E05A41",
  templeGold: "#D9A93F",
  peepalGreen: "#7FA86B",
  lotusPink: "#E68BA4",
  hairline: "rgba(217, 169, 63, 0.28)"
};

/**
 * React Native components consume one semantic palette object, matching the
 * SwiftUI Environment palette. Mutating the stable object keeps existing
 * imports live while the app-state update triggers the render using it.
 */
export function applyPalette(isDark: boolean) {
  Object.assign(palette, isDark ? darkPalette : lightPalette);
}

const lightPalette = { ...palette };
