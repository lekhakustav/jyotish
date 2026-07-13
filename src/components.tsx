import * as Haptics from "expo-haptics";
import React from "react";
import { Image, Pressable, Text, TextInput, View, type PressableProps, type TextInputProps, type TextProps, type ViewStyle } from "react-native";
import { AppIcon, type AppIconName } from "@/ornaments";
import { useReduceMotion } from "@/layout";
import { layoutMetrics, motion, palette } from "@/theme";

export function AppText({ style, ...props }: TextProps) {
  return <Text style={[{ color: palette.inkPrimary, fontFamily: "Inter-Regular", letterSpacing: 0 }, style]} {...props} />;
}

export function SerifText({ style, ...props }: TextProps) {
  return <Text style={[{ color: palette.inkPrimary, fontFamily: "Fraunces-Regular", letterSpacing: 0 }, style]} {...props} />;
}

export function PrimaryButton({ title, icon, onPress, disabled }: { title: string; icon?: AppIconName; onPress: () => void; disabled?: boolean }) {
  return (
    <PressableScale
      disabled={disabled}
      onPress={onPress}
      style={{
        minHeight: layoutMetrics.primaryButtonHeight,
        borderRadius: layoutMetrics.primaryButtonRadius,
        borderCurve: "continuous",
        backgroundColor: disabled ? palette.bgSunken : palette.saffron,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "row",
        gap: 10,
        paddingHorizontal: 18
      }}
    >
      <ButtonIcon icon={icon} color={palette.inkPrimary} />
      <SerifText style={{ fontSize: 19, color: palette.inkPrimary, fontFamily: "Fraunces-Bold", textAlign: "center" }}>{title}</SerifText>
    </PressableScale>
  );
}

export function GhostButton({ title, icon, onPress, selected }: { title: string; icon?: AppIconName; onPress: () => void; selected?: boolean }) {
  return (
    <PressableScale
      onPress={onPress}
      style={{
        minHeight: 44,
        borderRadius: 16,
        borderCurve: "continuous",
        paddingHorizontal: 14,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "row",
        gap: 8,
        backgroundColor: selected ? "rgba(242, 169, 59, 0.28)" : palette.bgSunken
      }}
    >
      <ButtonIcon icon={icon} color={selected ? palette.sindoor : palette.inkSecondary} />
      <AppText style={{ color: selected ? palette.sindoor : palette.inkSecondary, fontFamily: selected ? "Inter-Bold" : "Inter-SemiBold" }}>{title}</AppText>
    </PressableScale>
  );
}

export function PressableScale({ children, onPress, style, disabled, ...props }: PressableProps & { style?: ViewStyle }) {
  const reduceMotion = useReduceMotion();
  return (
    <Pressable
      {...props}
      disabled={disabled}
      hitSlop={8}
      onPress={(event) => {
        Haptics.selectionAsync().catch(() => undefined);
        onPress?.(event);
      }}
      style={({ pressed }) => [style, { opacity: disabled ? 0.58 : pressed ? 0.72 : 1, transform: [{ scale: pressed && !reduceMotion ? motion.pressedScale : 1 }] }]}
    >
      {children}
    </Pressable>
  );
}

export function Hairline() {
  return <View style={{ height: 1, backgroundColor: palette.hairline }} />;
}

export function Field(props: TextInputProps) {
  return (
    <TextInput
      placeholderTextColor={palette.inkSecondary}
      style={{
        minHeight: 52,
        borderRadius: 16,
        borderCurve: "continuous",
        backgroundColor: palette.bgSunken,
        color: palette.inkPrimary,
        paddingHorizontal: 16,
        fontFamily: "Inter-Regular",
        fontSize: 16
      }}
      {...props}
    />
  );
}

export function Logo({ size = 96 }: { size?: number }) {
  return <Image source={require("../assets/expo/images/logo-transparent.png")} style={{ width: size, height: size }} resizeMode="contain" />;
}

export function SectionLabel({ children }: { children: React.ReactNode }) {
  return <AppText style={{ color: palette.inkSecondary, fontFamily: "Inter-SemiBold", textTransform: "uppercase", fontSize: 13 }}>{children}</AppText>;
}

export function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 16, minHeight: 34 }}>
      <AppText style={{ color: palette.inkSecondary }}>{label}</AppText>
      <AppText style={{ fontFamily: "Inter-SemiBold", textAlign: "right", flexShrink: 1 }}>{value}</AppText>
    </View>
  );
}

export function TypingIndicator() {
  const [dot, setDot] = React.useState(0);
  const reduceMotion = useReduceMotion();
  React.useEffect(() => {
    if (reduceMotion) return;
    const timer = setInterval(() => setDot((value) => (value + 1) % 3), 280);
    return () => clearInterval(timer);
  }, [reduceMotion]);
  return (
    <View style={{ flexDirection: "row", gap: 4, alignItems: "center", paddingVertical: 8 }}>
      {[0, 1, 2].map((i) => (
        <View
          key={i}
          style={{
            width: 7,
            height: 7,
            borderRadius: 4,
            backgroundColor: palette.templeGold,
            opacity: reduceMotion ? 0.56 : dot === i ? 1 : 0.32
          }}
        />
      ))}
    </View>
  );
}

function ButtonIcon({ icon, color }: { icon?: AppIconName; color: string }) {
  if (!icon) return null;
  return <AppIcon name={icon} size={19} color={color} strokeWidth={2} />;
}
