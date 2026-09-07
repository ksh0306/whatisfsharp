#!/usr/bin/env bash
# 학습 노트(.md) 안의 ```fsharp id=<이름> 블록을 실행 단위별로 모아 dotnet fsi 로 검증한다.
#
# 사용법:
#   docs/ko/_pipeline/verify-examples.sh                     # docs/ko/*.md 전부
#   docs/ko/_pipeline/verify-examples.sh docs/ko/02-*.md     # 지정한 파일만
#   KEEP=1 docs/ko/_pipeline/verify-examples.sh ...          # 추출한 스크립트를 지우지 않고 경로를 알려준다
#
# 호출마다 시스템 임시 경로에 고유 디렉터리를 만들어 쓰므로 병렬 실행에 안전하고,
# 저장소의 .cache 를 지우거나 재생성하는 작업과도 충돌하지 않는다.
#
# 같은 id 를 가진 블록은 문서에 나온 순서대로 이어 붙여 하나의 스크립트가 된다.
# id 가 없는 블록은 실행하지 않는다(시그니처 조각, 컴파일 오류 예시 등).
set -uo pipefail
cd "$(dirname "$0")/../../.."

# 호출마다 고유 디렉터리를 쓴다. 고정 경로를 rm -rf 하면 병렬 실행에서 서로를 지운다.
# 저장소 안(.cache 등)에 두면 다른 작업이 .cache 를 통째로 재생성할 때 함께 지워지므로
# 반드시 시스템 임시 경로를 쓴다.
OUT=$(mktemp -d "${TMPDIR:-/tmp}/fsnote-examples.XXXXXX")
trap '[ "${KEEP:-}" = "1" ] || rm -rf "$OUT"' EXIT

FILES=("$@")
if [ ${#FILES[@]} -eq 0 ]; then
  mapfile -t FILES < <(find docs/ko -maxdepth 1 -name '[0-9]*.md' | sort)
fi

for md in "${FILES[@]}"; do
  awk -v outdir="$OUT" '
    /^```fsharp/ {
      id = ""
      n = split($0, p, /[ \t]+/)
      for (i = 2; i <= n; i++) if (p[i] ~ /^id=/) id = substr(p[i], 4)
      if (id != "") { inblock = 1; cur = id; seen[id] = 1 } else { skipping = 1 }
      next
    }
    /^```/ && (inblock || skipping) { inblock = 0; skipping = 0; next }
    inblock { print >> (outdir "/" cur ".fsx") }
  ' "$md"
done

shopt -s nullglob
scripts=("$OUT"/*.fsx)
if [ ${#scripts[@]} -eq 0 ]; then
  # 실행 단위가 없는 노트도 있다(16챕터 마무리 장처럼 코드가 아예 없는 경우).
  # 실패로 처리하지 않되, 집필 실수(id 누락)와 구분되도록 눈에 띄게 알린다.
  echo 'SKIP  실행 단위 없음 — 코드가 없는 노트이거나 id=<이름> 이 빠졌다. 의도한 것인지 확인하라.'
  exit 0
fi

fail=0
for f in "${scripts[@]}"; do
  out=$(dotnet fsi "$f" 2>&1)
  rc=$?
  warn=$(printf '%s' "$out" | grep -c 'warning FS')
  if [ $rc -eq 0 ] && [ "$warn" -eq 0 ]; then
    printf 'PASS  %-28s\n' "$(basename "$f" .fsx)"
  else
    fail=1
    printf 'FAIL  %-28s\n' "$(basename "$f" .fsx)"
    printf '%s\n' "$out" | grep -E 'error FS|warning FS' | sed 's/^/      /' | head -8
  fi
done

[ "${KEEP:-}" = "1" ] && echo "추출한 스크립트: $OUT"
[ $fail -eq 0 ] && echo "모든 실행 단위 통과" || echo "실패한 실행 단위가 있다" >&2
exit $fail
