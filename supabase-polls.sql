create table if not exists public.poll_votes (
  id bigint generated always as identity primary key,
  poll_id text not null,
  option_text text not null,
  created_at timestamptz not null default now(),
  constraint poll_votes_allowed_choice check (
    (poll_id = 'first-failure' and option_text in ('Will''s back', 'Mick''s knee', 'Ross'' fridge', 'Flag pole'))
    or
    (poll_id = 'winning-manufacturer' and option_text in ('Ford', 'Chev', 'Porsche', 'Mercedes', 'BMW', 'Audi', 'KTM', 'Ferrari', 'Lambo'))
  )
);

alter table public.poll_votes enable row level security;

drop policy if exists "Public can read poll votes" on public.poll_votes;
create policy "Public can read poll votes"
  on public.poll_votes for select to anon
  using (true);

drop policy if exists "Public can submit valid poll votes" on public.poll_votes;
create policy "Public can submit valid poll votes"
  on public.poll_votes for insert to anon
  with check (
    (poll_id = 'first-failure' and option_text in ('Will''s back', 'Mick''s knee', 'Ross'' fridge', 'Flag pole'))
    or
    (poll_id = 'winning-manufacturer' and option_text in ('Ford', 'Chev', 'Porsche', 'Mercedes', 'BMW', 'Audi', 'KTM', 'Ferrari', 'Lambo'))
  );

grant usage on schema public to anon;
revoke all on public.poll_votes from anon, authenticated;
grant select, insert on public.poll_votes to anon;

create or replace view public.poll_vote_counts
with (security_invoker = true) as
select poll_id, option_text, count(*)::integer as vote_count
from public.poll_votes
group by poll_id, option_text;

revoke all on public.poll_vote_counts from anon, authenticated;
grant select on public.poll_vote_counts to anon;
