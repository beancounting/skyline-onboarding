-- Skyline Accounting — AML/CTF Onboarding Schema
-- Run this in your Supabase Dashboard → SQL Editor → New query → paste → Run

-- ── submissions ───────────────────────────────────────────────────────
create table submissions (
  id                    uuid primary key default gen_random_uuid(),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  -- Primary contact
  contact_first         text not null,
  contact_last          text not null,
  contact_email         text not null,
  contact_phone         text,
  contact_dob           date,
  contact_legal_name    text,
  contact_address       text,
  contact_suburb        text,
  contact_state         text,
  contact_postcode      text,
  contact_occupation    text,
  contact_employer      text,
  contact_country_birth text,

  -- Structured sections (stored as JSON)
  services              jsonb,
  funds                 jsonb,
  pep                   jsonb,

  -- Declaration
  declaration_name      text,
  declaration_capacity  text,
  declaration_date      date,

  -- Audit / internal
  raw_state             jsonb,
  status                text not null default 'submitted',
  reviewed_by           text,
  reviewed_at           timestamptz,
  internal_notes        text,

  -- Processing flags
  pdf_generated         boolean default false,
  email_sent            boolean default false,
  dropbox_path          text
);

create index submissions_email_idx on submissions(contact_email);
create index submissions_created_at_idx on submissions(created_at desc);

-- ── persons ───────────────────────────────────────────────────────────
create table persons (
  id              uuid primary key default gen_random_uuid(),
  submission_id   uuid not null references submissions(id) on delete cascade,
  created_at      timestamptz not null default now(),

  frontend_id     text not null,
  first_name      text not null,
  last_name       text not null,
  dob             date,
  address         text,
  suburb          text,
  state_abbr      text,
  postcode        text,
  country         text default 'Australia',
  is_primary      boolean default false,

  id_doc_type     text,
  id_doc_path     text
);

create index persons_submission_idx on persons(submission_id);

-- ── entities ──────────────────────────────────────────────────────────
create table entities (
  id              uuid primary key default gen_random_uuid(),
  submission_id   uuid not null references submissions(id) on delete cascade,
  created_at      timestamptz not null default now(),

  frontend_id     text not null,
  type            text not null,
  name            text not null,
  data            jsonb
);

create index entities_submission_idx on entities(submission_id);

-- ── Automatic updated_at trigger ─────────────────────────────────────
create or replace function update_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger submissions_updated_at
  before update on submissions
  for each row execute function update_updated_at();

-- ══ ROW LEVEL SECURITY ══════════════════════════════════════════════════
-- anon can INSERT only — never read other people's submissions
alter table submissions enable row level security;
alter table persons enable row level security;
alter table entities enable row level security;

create policy "anon_insert_submissions" on submissions for insert to anon with check (true);
create policy "anon_insert_persons"     on persons     for insert to anon with check (true);
create policy "anon_insert_entities"    on entities    for insert to anon with check (true);

-- No SELECT policy for anon — submissions are never readable from the browser.
-- The client generates UUIDs locally (crypto.randomUUID()) so INSERT...RETURNING is not needed.

-- ══ STORAGE ═════════════════════════════════════════════════════════════
-- Create private bucket for ID documents
-- NOTE: Also create this in Dashboard → Storage → New bucket → "id-documents" → Private
insert into storage.buckets (id, name, public) values ('id-documents', 'id-documents', false)
on conflict do nothing;

-- Allow anon to upload (INSERT) but NOT read (SELECT) or delete
create policy "anon_upload_id_docs"
on storage.objects for insert to anon
with check (bucket_id = 'id-documents');
