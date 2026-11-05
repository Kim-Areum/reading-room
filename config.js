// Supabase 공개 설정. anon 키는 브라우저에 노출되는 공개 키이고, 권한은 DB의 RLS 정책이 정합니다.
// 한 주 한 줄(hanjul) 프로젝트를 같이 써도 됩니다 (테이블은 rr_ 접두어로 분리됨).
// hanjul/.env.local 의 NEXT_PUBLIC_SUPABASE_URL / NEXT_PUBLIC_SUPABASE_ANON_KEY 값을 그대로 넣으세요.
window.RR_CONFIG = {
  url: "",      // 예: https://xxxxxxxx.supabase.co
  anonKey: "",  // 예: eyJhbGciOi...
};
