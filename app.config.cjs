const app = require("./app.json");

// These values are intentionally public client configuration. Private provider
// credentials must stay in the server environment and never enter Expo dotenv.
module.exports = {
  ...app,
  expo: {
    ...app.expo,
    extra: {
      ...(app.expo.extra || {}),
      jyotishPublicConfig: {
        supabaseUrl: "https://ghfcssxptpazfbtiwshz.supabase.co",
        supabasePublishableKey: "sb_publishable_2HN-eNePLicYuxRhCKKAFw_dm74f0SW",
        agentEndpoint: "https://ghfcssxptpazfbtiwshz.supabase.co/functions/v1/jyotish-agent",
      },
    },
  },
};
