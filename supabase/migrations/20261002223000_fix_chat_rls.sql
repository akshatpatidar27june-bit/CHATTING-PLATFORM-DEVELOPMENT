-- Just Us: allow the no-login client to read and write the chat data.
-- The app intentionally uses the two fixed roles (her/him) instead of Supabase Auth.

create policy "just_us_read_rooms"
on public.rooms
for select
to anon, authenticated
using (true);

create policy "just_us_read_messages"
on public.messages
for select
to anon, authenticated
using (true);

create policy "just_us_insert_messages"
on public.messages
for insert
to anon, authenticated
with check (
  sender in ('her'::public.chat_sender, 'him'::public.chat_sender)
  and exists (
    select 1 from public.rooms r where r.id = room_id
  )
);

create policy "just_us_update_messages"
on public.messages
for update
to anon, authenticated
using (true)
with check (true);

alter table public.rooms replica identity full;
alter table public.messages replica identity full;
