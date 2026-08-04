create extension if not exists pgcrypto;
do $$ begin create type public.skill_level as enum ('beginner','intermediate','advanced'); exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (char_length(username) between 3 and 32),
  display_name text check (char_length(display_name) <= 80),
  avatar_path text,
  level public.skill_level,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.assessments (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  score integer not null check (score >= 0), level public.skill_level not null,
  completed_at timestamptz not null default now()
);
create table if not exists public.assessment_answers (
  id uuid primary key default gen_random_uuid(), assessment_id uuid not null references public.assessments(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade, question_key text not null,
  answer jsonb not null, score integer not null default 0
);
create table if not exists public.trainings (
  id uuid primary key default gen_random_uuid(), slug text not null unique, game text not null,
  title text not null, level public.skill_level not null, cognitive_skill text not null,
  objective text not null, instructions jsonb not null default '[]', duration_minutes integer check(duration_minutes > 0),
  is_active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.training_metrics (
  id uuid primary key default gen_random_uuid(), training_id uuid not null references public.trainings(id) on delete cascade,
  key text not null, label text not null, unit text, value_type text not null check(value_type in ('number','duration','percentage')),
  higher_is_better boolean not null default true, required boolean not null default true, unique(training_id,key)
);
create table if not exists public.training_results (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  training_id uuid not null references public.trainings(id) on delete restrict, metrics jsonb not null,
  notes text check(char_length(notes) <= 1000), performed_at timestamptz not null default now(), created_at timestamptz not null default now()
);
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  show_other_levels boolean not null default false, theme text not null default 'dark' check(theme in ('dark','light','system')),
  updated_at timestamptz not null default now()
);
create index if not exists assessments_user_date_idx on public.assessments(user_id,completed_at desc);
create index if not exists results_user_training_date_idx on public.training_results(user_id,training_id,performed_at desc);
create index if not exists trainings_level_game_idx on public.trainings(level,game) where is_active;

alter table public.profiles enable row level security; alter table public.assessments enable row level security;
alter table public.assessment_answers enable row level security; alter table public.trainings enable row level security;
alter table public.training_metrics enable row level security; alter table public.training_results enable row level security;
alter table public.user_settings enable row level security;

do $$ begin
  create policy "profiles own read" on public.profiles for select using (auth.uid()=id);
  create policy "profiles own update" on public.profiles for update using (auth.uid()=id) with check (auth.uid()=id);
  create policy "assessments own all" on public.assessments for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
  create policy "answers own all" on public.assessment_answers for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
  create policy "trainings authenticated read" on public.trainings for select to authenticated using (is_active);
  create policy "metrics authenticated read" on public.training_metrics for select to authenticated using (true);
  create policy "results own all" on public.training_results for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
  create policy "settings own all" on public.user_settings for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
exception when duplicate_object then null; end $$;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('avatars','avatars',false,5242880,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
do $$ begin
  create policy "avatar own read" on storage.objects for select to authenticated using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);
  create policy "avatar own insert" on storage.objects for insert to authenticated with check (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);
  create policy "avatar own update" on storage.objects for update to authenticated using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);
  create policy "avatar own delete" on storage.objects for delete to authenticated using (bucket_id='avatars' and (storage.foldername(name))[1]=auth.uid()::text);
exception when duplicate_object then null; end $$;
