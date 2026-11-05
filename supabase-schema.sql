-- ============================================================
-- 日常计数器 · 云同步版（Supabase）建表脚本
-- 在 Supabase 控制台 -> SQL Editor 里粘贴全部内容运行一次即可
-- ============================================================

-- 1) 数据表：整份状态（所有人/弹幕/背景）存在一行 JSON 里
create table if not exists public.state (
  id          integer primary key,
  data        jsonb   not null,
  updated_at  timestamptz default now()
);

-- 2) 行级安全：允许匿名（anon）读写。
--    说明：本 App 是朋友间公开共享，anon key 本就是公开的设计，
--    任何人拿到网址都能读写，靠"房间"共享。若日后想加口令再收紧策略。
alter table public.state enable row level security;

drop policy if exists "anon_all_state" on public.state;
create policy "anon_all_state"
  on public.state
  for all
  to anon
  using (true)
  with check (true);

-- 3) 开启 Realtime（实时推送）：把表加入 supabase_realtime 发布
alter publication supabase_realtime add table public.state;
