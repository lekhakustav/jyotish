import { Stack } from "expo-router/stack";
import { StatusBar } from "expo-status-bar";
import { useFonts } from "expo-font";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { AppStateProvider } from "@/app-state";
import { palette } from "@/theme";

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    "Inter-Regular": require("../assets/expo/fonts/Inter-Regular.ttf"),
    "Inter-SemiBold": require("../assets/expo/fonts/Inter-SemiBold.ttf"),
    "Inter-Bold": require("../assets/expo/fonts/Inter-Bold.ttf"),
    "Fraunces-Regular": require("../assets/expo/fonts/Fraunces-Regular.ttf"),
    "Fraunces-Bold": require("../assets/expo/fonts/Fraunces-Bold.ttf")
  });

  if (!fontsLoaded) return null;

  return (
    <GestureHandlerRootView style={{ flex: 1, backgroundColor: palette.bgCanvas }}>
      <AppStateProvider>
        <StatusBar style="dark" />
        <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: palette.bgCanvas } }} />
      </AppStateProvider>
    </GestureHandlerRootView>
  );
}
