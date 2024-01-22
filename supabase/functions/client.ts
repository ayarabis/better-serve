import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SRK")!,
);

export { supabase };
