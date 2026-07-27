# Jyotish Agent Edge Function

This is the production path for Jyotish Baje chat when there is no dedicated server.
It keeps `OPENAI_API_KEY` in Supabase secrets and lets the iOS app call a Supabase-hosted
function using the user's Supabase Auth token.

Deploy:

```sh
supabase secrets set OPENAI_API_KEY=... OPENAI_JYOTISH_AGENT_MODEL=gpt-5.4-mini
supabase functions deploy jyotish-agent
```

Use this iOS setting for production builds:

```sh
JYOTISH_AGENT_ENDPOINT_URL=https://ghfcssxptpazfbtiwshz.supabase.co/functions/v1/jyotish-agent
```

JWT verification is source-controlled in `supabase/config.toml`. The function also verifies
the bearer token against Supabase Auth and applies a per-user request limit before spending
OpenAI tokens.
