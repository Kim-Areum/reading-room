#!/bin/sh
# 배포: 버전 번호를 심고 커밋·푸시. 사용법: ./deploy.sh "커밋 메시지"
set -e
cd "$(dirname "$0")"
V=$(date +%Y%m%d%H%M%S)
echo "$V" > version.txt
sed -i '' -E "s/window\.APP_VERSION = \"[^\"]*\"/window.APP_VERSION = \"$V\"/" index.html
sed -i '' -E "s/const VERSION = '[^']*'/const VERSION = '$V'/" sw.js
git add -A
git commit -q -m "${1:-배포 $V}"
git push -q origin main
echo "배포됨: $V (1~2분 뒤 반영, 열려 있는 페이지는 자동으로 새 버전으로 바뀜)"
