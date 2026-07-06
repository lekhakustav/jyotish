# Jyotish Agent Edge Function

This is the production path for Pandit Chat when there is no dedicated server.
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

Keep JWT verification enabled for production so public clients cannot anonymously spend
OpenAI tokens. The app already sends the Supabase session bearer token when one exists.
