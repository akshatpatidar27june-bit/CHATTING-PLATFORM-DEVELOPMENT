alter table public.messages
  add column if not exists reply_to_id uuid references public.messages(id) on delete set null;

create table if not exists public.message_reactions (
  message_id uuid not null references public.messages(id) on delete cascade,
  reactor public.chat_sender not null,
  reaction text not null check (reaction in ('❤️','😂','🔥','😍','👍')),
  created_at timestamptz not null default now(),
  primary key (message_id, reactor)
);

alter table public.message_reactions enable row level security;

drop policy if exists "just_us_message_reactions_read" on public.message_reactions;
drop policy if exists "just_us_message_reactions_write" on public.message_reactions;

create policy "just_us_message_reactions_read" on public.message_reactions
for select to anon, authenticated using (true);

create policy "just_us_message_reactions_write" on public.message_reactions
for all to anon, authenticated
using (reactor in ('her'::public.chat_sender,'him'::public.chat_sender))
with check (reactor in ('her'::public.chat_sender,'him'::public.chat_sender));

grant select, insert, update, delete on public.message_reactions to anon, authenticated;
alter table public.message_reactions replica identity full;