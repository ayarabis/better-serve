import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { supabase } from "../client.ts";

serve(async (req: Request) => {
  const { id } = await req.json();

  const {
    data: { user },
    error,
  } = await supabase.auth.admin.deleteUser(id);

  return new Response(JSON.stringify({ user, error }), {
    headers: { "Content-Type": "application/json" },
    status: 200,
  });
});
