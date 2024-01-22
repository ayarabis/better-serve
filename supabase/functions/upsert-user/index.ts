import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { supabase } from "../client.ts";

serve(async (req: Request) => {
  const { id, attributes, profile } = await req.json();

  attributes.email_confirm = true;

  const {
    data: { user },
    error,
  } = id
    ? await supabase.auth.admin.updateUserById(id, attributes)
    : await supabase.auth.admin.createUser(attributes);

  let newProfile;
  console.error(error);
  if (!error) {
    profile.id = user?.id;
    const { data, error } = await supabase.from("profiles").upsert(profile, {
      onConflict: "id",
    }).select("*,role:roles(id,name,permissions)").single();
    if (error) {
      console.error(error);
      return new Response(JSON.stringify({ error }), {
        headers: {
          "Content-Type": "application/json",
          "X-Error-Message": error.message,
          "X-Error-Details": error.details,
          "X-Error-Hint": error.hint,
        },
        status: 500,
      });
    }
    newProfile = data;
  }

  return new Response(JSON.stringify({ user, profile: newProfile, error }), {
    headers: {
      "Content-Type": "application/json",
      ...(error ? { "X-Error-Message": error?.message } : {}),
    },
    status: error ? 500 : 200,
  });
});
