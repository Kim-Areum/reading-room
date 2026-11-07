// 같이 읽는 방 — push "friend started reading" to everyone else subscribed in the room.
// Deployed as the Supabase Edge Function `notify` (project hanjul). Secrets: VAPID_JWK (JSON {publicKey, privateKey} in JWK form).
import * as webpush from "jsr:@negrel/webpush@0.3.0";
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

let appServer: webpush.ApplicationServer | null = null;
async function server() {
  if (appServer) return appServer;
  const jwk = JSON.parse(Deno.env.get("VAPID_JWK") || "{}");
  const vapidKeys = await webpush.importVapidKeys(jwk, { extractable: false });
  appServer = await webpush.ApplicationServer.new({ contactInformation: "mailto:spongemook@gmail.com", vapidKeys });
  return appServer;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);
  try {
    const { room, from, name, roomName } = await req.json();
    if (!room || !from) return json({ error: "room and from are required" }, 400);
    const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: subs, error } = await sb.from("rr_push").select("id, endpoint, p256dh, auth, reader_id").eq("room_id", room).neq("reader_id", from);
    if (error) return json({ error: error.message }, 500);
    const app = await server();
    const payload = JSON.stringify({
      title: roomName || "같이 읽는 방",
      body: `${name || "친구"}가 책을 읽기 시작했어요`,
      url: `?room=${room}`,
      tag: "rr-" + room,
    });
    let sent = 0;
    const dead: string[] = [];
    await Promise.all((subs || []).map(async (s) => {
      try {
        const subscriber = app.subscribe({ endpoint: s.endpoint, keys: { p256dh: s.p256dh, auth: s.auth } });
        await subscriber.pushTextMessage(payload, { ttl: 600, urgency: "normal" });
        sent++;
      } catch (e) {
        const code = (e as { response?: { status?: number } })?.response?.status;
        if (code === 404 || code === 410) dead.push(s.id);
        else console.error("push failed", s.endpoint.slice(0, 40), String(e));
      }
    }));
    if (dead.length) await sb.from("rr_push").delete().in("id", dead);
    return json({ sent, removed: dead.length, total: (subs || []).length });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
