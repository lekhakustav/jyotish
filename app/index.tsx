import { MainScreen, ProfileScreen, WelcomeScreen } from "@/screens";
import { useAppState } from "@/app-state";

export default function IndexRoute() {
  const app = useAppState();
  const self = app.family.find((member) => member.relation === "selfMember");
  if (!app.account) return <WelcomeScreen />;
  if (!self?.kundali) return <ProfileScreen />;
  return <MainScreen />;
}
