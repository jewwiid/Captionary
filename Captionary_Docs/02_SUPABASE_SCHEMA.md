# Supabase Schema (Core Tables)

```sql
create table profiles (
  uid uuid primary key,
  email text unique,
  display_name text,
  created_at timestamptz default now()
);

create type plan_t as enum ('free','premium','pro');

create table subscriptions (
  uid uuid references profiles(uid) on delete cascade,
  plan plan_t not null default 'free',
  renews_at timestamptz,
  status text check (status in ('active','in_grace','canceled')) default 'active',
  updated_at timestamptz default now()
);

create table usage_counters (
  uid uuid references profiles(uid),
  yyyymm char(6) not null,
  generations int default 0,
  primary key (uid, yyyymm)
);

create table captions (
  id uuid primary key default gen_random_uuid(),
  uid uuid references profiles(uid),
  request jsonb not null,
  variant jsonb not null,
  created_at timestamptz default now()
);
```
