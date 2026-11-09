-- 좋아요 + 책 ISBN (2026-11-09, SQL 편집기에서 실행 완료)
alter table rr_sessions add column if not exists isbn text;
create table if not exists rr_likes (
  session_id uuid not null references rr_sessions(id) on delete cascade,
  reader_id text not null references rr_readers(id) on delete cascade,
  room_id text not null references rr_rooms(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (session_id, reader_id)
);
alter table rr_likes enable row level security;
drop policy if exists "rr_likes anon all" on rr_likes;
create policy "rr_likes anon all" on rr_likes for all to anon using (true) with check (true);
alter publication supabase_realtime add table rr_likes;
