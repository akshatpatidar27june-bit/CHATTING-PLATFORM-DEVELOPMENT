-- Track exactly when each person opens the chat and reads messages.
alter table public.messages
  add column if not exists her_seen_at timestamptz,
  add column if not exists him_seen_at timestamptz;

create or replace function public.mark_seen(p_message_ids uuid[], p_viewer text)
returns void
language plpgsql
security definer
set search_path = public
as $function$
begin
  if p_viewer not in ('her','him') then
    raise exception 'Invalid viewer role';
  end if;

  if p_viewer = 'her' then
    update public.messages
    set her_seen = true,
        her_seen_at = coalesce(her_seen_at, now())
    where id = any(p_message_ids)
      and sender = 'him';
  else
    update public.messages
    set him_seen = true,
        him_seen_at = coalesce(him_seen_at, now())
    where id = any(p_message_ids)
      and sender = 'her';
  end if;
end;
$function$;
