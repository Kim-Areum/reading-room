-- 같이 읽는 방: Supabase 스키마 (SQL Editor에서 한 번 실행)
-- 친구끼리 테스트용이라 로그인 없이 anon 키로 읽고 씁니다.

create table if not exists public.rr_readers (
  id text primary key,
  animal text not null,
  nickname text not null,
  status text not null default 'idle',
  started_at bigint,
  accum bigint default 0,
  session_started_at bigint,
  updated_at bigint
);

create table if not exists public.rr_sessions (
  id uuid primary key default gen_random_uuid(),
  reader_id text not null references public.rr_readers(id) on delete cascade,
  started_at bigint,
  ended_at bigint not null,
  seconds integer not null default 0,
  title text default '',
  note text default '',
  created_at timestamptz default now()
);
create index if not exists rr_sessions_reader_idx on public.rr_sessions(reader_id, ended_at desc);

alter table public.rr_readers enable row level security;
alter table public.rr_sessions enable row level security;

-- 프로토타입 정책: 링크를 아는 사람은 모두 읽고 쓸 수 있음
drop policy if exists "rr_readers_all" on public.rr_readers;
create policy "rr_readers_all" on public.rr_readers for all to anon, authenticated using (true) with check (true);
drop policy if exists "rr_sessions_all" on public.rr_sessions;
create policy "rr_sessions_all" on public.rr_sessions for all to anon, authenticated using (true) with check (true);

-- 실시간 반영 (친구가 타이머 켜면 바로 보이게)
do $$ begin
  alter publication supabase_realtime add table public.rr_readers;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.rr_sessions;
exception when duplicate_object then null; end $$;

-- ---- 2026-11-06 방 여러 개 ----
create table if not exists public.rr_rooms (
  id text primary key,
  name text not null,
  created_at timestamptz default now()
);
alter table public.rr_rooms enable row level security;
drop policy if exists "rr_rooms_all" on public.rr_rooms;
create policy "rr_rooms_all" on public.rr_rooms for all to anon, authenticated using (true) with check (true);
insert into public.rr_rooms (id, name) values ('home', '첫 번째 방') on conflict (id) do nothing;
alter table public.rr_readers add column if not exists room_id text not null default 'home';
alter table public.rr_sessions add column if not exists room_id text not null default 'home';
-- 기존 캐릭터 id를 방 범위 id('home:u_xxx')로 옮김
insert into public.rr_readers (id, room_id, animal, nickname, status, started_at, accum, session_started_at, updated_at)
  select 'home:' || id, 'home', animal, nickname, status, started_at, accum, session_started_at, updated_at
  from public.rr_readers where id not like '%:%'
  on conflict (id) do nothing;
update public.rr_sessions set reader_id = 'home:' || reader_id where reader_id not like '%:%';
delete from public.rr_readers where id not like '%:%';
create index if not exists rr_readers_room_idx on public.rr_readers(room_id);
create index if not exists rr_sessions_room_idx on public.rr_sessions(room_id, ended_at desc);
