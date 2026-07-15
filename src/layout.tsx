import React from "react";
import {
  AccessibilityInfo,
  Pressable,
  ScrollView,
  View,
  type ScrollViewProps,
  type StyleProp,
  type ViewProps,
  type ViewStyle
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { AppIcon, type AppIconName } from "@/ornaments";
import { layoutMetrics, motion, palette, spacing } from "@/theme";

export function useReduceMotion() {
  const [reduceMotion, setReduceMotion] = React.useState(false);
  React.useEffect(() => {
    AccessibilityInfo.isReduceMotionEnabled().then(setReduceMotion).catch(() => undefined);
    const subscription = AccessibilityInfo.addEventListener("reduceMotionChanged", setReduceMotion);
    return () => subscription.remove();
  }, []);
  return reduceMotion;
}

type ScreenChromeProps = {
  gutter?: number;
  safeTop?: boolean;
  safeBottom?: boolean;
  backgroundColor?: string;
};

type FixedScreenProps = ViewProps & ScreenChromeProps & {
  contentStyle?: StyleProp<ViewStyle>;
};

/** Safe-area-aware fixed canvas for modal and non-scrolling screens. */
export function FixedScreen({
  children,
  gutter = layoutMetrics.screenGutter,
  safeTop = true,
  safeBottom = true,
  backgroundColor = palette.bgCanvas,
  style,
  contentStyle,
  ...props
}: FixedScreenProps) {
  const insets = useSafeAreaInsets();
  return (
    <View style={[{ flex: 1, backgroundColor }, style]} {...props}>
      <View
        style={[
          {
            flex: 1,
            paddingHorizontal: gutter,
            paddingTop: safeTop ? insets.top : 0,
            paddingBottom: safeBottom ? insets.bottom : 0
          },
          contentStyle
        ]}
      >
        {children}
      </View>
    </View>
  );
}

/** Default screen alias kept intentionally explicit at call sites. */
export function AppScreen(props: FixedScreenProps) {
  return <FixedScreen {...props} />;
}

type ScrollScreenProps = ScrollViewProps & ScreenChromeProps & {
  topInset?: number;
  bottomInset?: number;
  contentGap?: number;
};

/** Scroll canvas that owns its safe-area padding, avoiding status/navigation overlap. */
export function ScrollScreen({
  children,
  gutter = layoutMetrics.screenGutter,
  safeTop = true,
  safeBottom = true,
  backgroundColor = palette.bgCanvas,
  topInset = spacing.md,
  bottomInset = spacing.xl,
  contentGap = spacing.lg,
  style,
  contentContainerStyle,
  ...props
}: ScrollScreenProps) {
  const insets = useSafeAreaInsets();
  return (
    <ScrollView
      keyboardShouldPersistTaps="handled"
      automaticallyAdjustContentInsets={false}
      automaticallyAdjustsScrollIndicatorInsets={false}
      style={[{ flex: 1, backgroundColor }, style]}
      contentContainerStyle={[
        {
          paddingHorizontal: gutter,
          paddingTop: topInset + (safeTop ? insets.top : 0),
          paddingBottom: bottomInset + (safeBottom ? insets.bottom : 0),
          gap: contentGap
        },
        contentContainerStyle
      ]}
      scrollIndicatorInsets={{ top: safeTop ? insets.top : 0, bottom: safeBottom ? insets.bottom : 0 }}
      {...props}
    >
      {children}
    </ScrollView>
  );
}

export type BottomTabItem<T extends string> = {
  value: T;
  label: string;
  icon: AppIconName;
};

/**
 * Android counterpart to the iOS tab capsule. Geometry and selected state
 * match SwiftUI; the surface is deliberately opaque because Liquid Glass is
 * an iOS-only material.
 */
export function BottomTabShell<T extends string>({
  value,
  items,
  onChange
}: {
  value: T;
  items: readonly BottomTabItem<T>[];
  onChange: (value: T) => void;
}) {
  const insets = useSafeAreaInsets();
  const reduceMotion = useReduceMotion();
  return (
    <View
      pointerEvents="box-none"
      style={{
        position: "absolute",
        left: 0,
        right: 0,
        bottom: insets.bottom + layoutMetrics.bottomShellMargin,
        alignItems: "center"
      }}
    >
      <View
        style={{
          width: layoutMetrics.bottomShellWidth,
          height: layoutMetrics.bottomShellHeight,
          borderRadius: layoutMetrics.bottomShellHeight / 2,
          borderCurve: "continuous",
          padding: 6,
          flexDirection: "row",
          alignItems: "stretch",
          backgroundColor: palette.bgElevated,
          borderWidth: 1,
          borderColor: palette.hairline
        }}
      >
        {items.map((item) => {
          const selected = item.value === value;
          return (
            <Pressable
              key={item.value}
              accessibilityRole="tab"
              accessibilityLabel={item.label}
              accessibilityState={{ selected }}
              hitSlop={4}
              onPress={() => onChange(item.value)}
              style={({ pressed }) => ({
                flex: 1,
                minWidth: layoutMetrics.minimumTouchTarget,
                minHeight: layoutMetrics.minimumTouchTarget,
                borderRadius: 28,
                alignItems: "center",
                justifyContent: "center",
                backgroundColor: selected ? "rgba(242, 169, 59, 0.24)" : "transparent",
                opacity: pressed ? 0.72 : 1,
                transform: [{ scale: pressed && !reduceMotion ? motion.pressedScale : 1 }]
              })}
            >
              <AppIcon name={item.icon} size={24} color={selected ? palette.sindoor : palette.inkSecondary} strokeWidth={selected ? 2.1 : 1.8} />
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}
