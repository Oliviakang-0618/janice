-- 1. 建立白名單資料表 (Allowlist)
CREATE TABLE public.allowlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL DEFAULT 'sales' CHECK (role IN ('admin', 'sales')),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 建立客戶資料表 (Customers)
CREATE TABLE public.customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact TEXT,
  phone TEXT,
  stage TEXT DEFAULT 'Lead' CHECK (stage IN ('Lead', 'Proposal', 'Negotiation', 'Closed')),
  amount NUMERIC(12, 2) DEFAULT 0,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 開啟 Row Level Security (RLS) 保護
ALTER TABLE public.allowlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- 4. 設定 RLS 讀寫權限 (僅已登入且被激活的使用者可讀寫)
CREATE POLICY "Allow authenticated read customers" ON public.customers 
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated insert customers" ON public.customers 
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated delete customers" ON public.customers 
  FOR DELETE TO authenticated USING (true);

-- 5. 初始化 Admin 帳號白名單 (請替換為貴公司的 Admin 信箱)
INSERT INTO public.allowlist (email, role) 
VALUES ('admin@yourcompany.com', 'admin');