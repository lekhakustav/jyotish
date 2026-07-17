// Deletes the calling user's account and every row keyed to it.
// The platform verifies the JWT before invoking (verify_jwt on); this function
// re-resolves the user from the token so deletion can never target anyone else.

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "Server is not configured" }, 500);
  }

  const bearer = req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  if (!bearer) {
    return json({ error: "Missing authorization" }, 401);
  }

  const userResponse = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: { apikey: serviceRoleKey, authorization: `Bearer ${bearer}` },
  });
  if (!userResponse.ok) {
    return json({ error: "Invalid session" }, 401);
  }
  const user = await userResponse.json();
  const userId = typeof user?.id === "string" ? user.id : "";
  if (!userId) {
    return json({ error: "Invalid session" }, 401);
  }

  const admin = {
    apikey: serviceRoleKey,
    authorization: `Bearer ${serviceRoleKey}`,
    "content-type": "application/json",
  };

  // Data rows first, so a failure leaves the account intact and retryable.
  for (const table of ["households", "analytics_events"]) {
    const wipe = await fetch(
      `${supabaseUrl}/rest/v1/${table}?user_id=eq.${userId}`,
      { method: "DELETE", headers: admin },
    );
    if (!wipe.ok && wipe.status !== 404) {
      return json({ error: `Could not delete ${table}` }, 502);
    }
  }

  const dropUser = await fetch(`${supabaseUrl}/auth/v1/admin/users/${userId}`, {
    method: "DELETE",
    headers: admin,
  });
  if (!dropUser.ok) {
    return json({ error: "Could not delete account" }, 502);
  }

  return json({ deleted: true });
});

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
