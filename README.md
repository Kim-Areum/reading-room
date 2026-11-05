# 같이 읽는 방

친구들과 한 방에서 책 읽는 시간을 재고, 읽은 책·한 줄 소감을 캐릭터별로 남기는 웹 프로토타입.
정적 페이지(GitHub Pages) + Supabase(DB·실시간).

## 구성
- `index.html` — 앱 전체 (HTML/CSS/JS 한 파일)
- `config.js` — Supabase URL과 anon 키 (공개 키)
- `supabase.sql` — 테이블·정책 생성 SQL (Supabase SQL Editor에서 한 번 실행)
- `fonts/Ownglyph_PDH.ttf` — 온글잎 손글씨 폰트 (하루 앱과 동일)

## 처음 한 번
1. `config.js`에 Supabase URL과 anon 키 입력 (hanjul 프로젝트를 같이 써도 됨)
2. Supabase 대시보드 → SQL Editor → `supabase.sql` 내용 붙여넣고 Run
3. GitHub 저장소 Settings → Pages → Branch `main` / root 로 배포
4. 배포 주소를 친구에게 공유. 로그인 없이 기기마다 캐릭터·닉네임만 정하면 입장

## 로컬에서 보기
```
python3 -m http.server 8765
```
→ http://localhost:8765

## 참고
- 로그인이 없어서 "내 기록"은 기기(브라우저) 기준. 같은 사람이 다른 기기로 열면 새 캐릭터로 들어옴.
- `config.js`를 비우면 서버 없이 이 기기에만 저장하는 혼자 모드로 동작.
