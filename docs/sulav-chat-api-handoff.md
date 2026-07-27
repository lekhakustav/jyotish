# Message for Sulav

Hi Sulav — please pull the latest Jyotish changes from GitHub. I fixed the chat API wiring.

The issue was that the app was calling the Supabase chat function without the required public API key, so it received `401` and silently used the local fallback. The app now embeds the Expo endpoint correctly and sends both the public Supabase `apikey` and the signed-in session token when available.

Use this public client configuration in the ignored root `.env.local`:

```sh
EXPO_PUBLIC_SUPABASE_URL=https://ghfcssxptpazfbtiwshz.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_2HN-eNePLicYuxRhCKKAFw_dm74f0SW
EXPO_PUBLIC_JYOTISH_AGENT_ENDPOINT_URL=https://ghfcssxptpazfbtiwshz.supabase.co/functions/v1/jyotish-agent
```

Then run:

```sh
npm install
npm run typecheck
npx expo start -c
```

For an installed Android or iOS app, create a new build because the Expo environment variables and JavaScript changes are bundled into the app. No simulator is required for the API check.

The deployed API has been verified with both normal JSON and streaming responses returning `200`. Please do not add or request private OpenAI, Supabase service-role, database, or ElevenLabs keys in the app or GitHub; those remain server-side.

Thanks!
