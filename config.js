// Supabase 공개 설정 (anon 키는 브라우저에 노출되는 공개 키, 권한은 RLS 정책이 결정)
window.RR_CONFIG = { url: "https://rcyoighczindwymbnthe.supabase.co", anonKey: "sb_publishable_YCP8c1Rs_67064et-8kBcA_93Qu-bzO",
  vapidPublicKey: "BKKOZNS2cr4EZesyWzezgDfNxHJ5Z8hORAMjInI5CirhP0rZ1v9l00JtSDsqaIBbLBIYdK81hh0aJINn4_ZhA-A",   // web push (공개키, 비밀키는 Supabase 함수 secrets에만)
  notifyUrl: "https://rcyoighczindwymbnthe.supabase.co/functions/v1/notify"
};
