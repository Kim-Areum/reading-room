-- 푸시 구독 (기기별 web push 구독 정보). 2026-11-07
create table if not exists rr_push (
  id uuid primary key default gen_random_uuid(),
  reader_id text not null references rr_readers(id) on delete cascade,
  room_id text not null references rr_rooms(id) on delete cascade,
  endpoint text not null,
  p256dh text not null,
  auth text not null,
  created_at timestamptz not null default now(),
  unique (reader_id, endpoint)
);
alter table rr_push enable row level security;
drop policy if exists "rr_push anon all" on rr_push;
create policy "rr_push anon all" on rr_push for all to anon using (true) with check (true);
