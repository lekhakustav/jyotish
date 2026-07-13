import { Stack } from "expo-router/stack";
import { StatusBar } from "expo-status-bar";
import { useFonts } from "expo-font";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { AppStateProvider } from "@/app-state";
import { palette } from "@/theme";

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    "Inter-Regular": require("../assets/expo/fonts/Inter-Regular.ttf"),
    "Inter-SemiBold": require("../assets/expo/fonts/Inter-SemiBold.ttf"),
    "Inter-Bold": require("../assets/expo/fonts/Inter-Bold.ttf"),
    "Fraunces-Regular": require("../assets/expo/fonts/Fraunces-Regular.ttf"),
    "Fraunces-Light": require("../assets/expo/fonts/Fraunces-Light.ttf"),
    "Fraunces-Medium": require("../assets/expo/fonts/Fraunces-Medium.ttf"),
    "Fraunces-SemiBold": require("../assets/expo/fonts/Fraunces-SemiBold.ttf"),
    "Fraunces-Bold": require("../assets/expo/fonts/Fraunces-Bold.ttf")
  });

  if (!fontsLoaded) return null;

  return (
    <GestureHandlerRootView style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
      <SafeAreaProvider>
        <AppStateProvider>
          <StatusBar style="auto" />
          <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: palette.bgCanvas } }} />
        </AppStateProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
