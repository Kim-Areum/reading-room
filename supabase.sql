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
