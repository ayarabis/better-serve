import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { supabase } from "../client.ts";

serve(async (_: Request) => {
  const {
    data: { users },
  } = await supabase.auth.admin.listUsers();

  return new Response(JSON.stringify({ users }), {
    headers: { "Content-Type": "application/json" },
    status: 200,
  });
});
