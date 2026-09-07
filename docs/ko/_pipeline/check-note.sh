#!/usr/bin/env bash
# 학습 노트의 금지 패턴을 검사한다. 게이트의 단일 출처.
#
# 사용법:
#   docs/ko/_pipeline/check-note.sh                      # docs/ko/*.md 전부
#   docs/ko/_pipeline/check-note.sh docs/ko/05-*.md      # 지정한 파일만
#
# 컴파일러·FSI 메시지 인용은 원문 표기를 유지하므로 이 검사 대상이 아니다.
# 인용 안의 `형식`·`공용 구조체` 등은 여기서 잡지 않는다(용어집 머리말 규칙).
set -uo pipefail
cd "$(dirname "$0")/../../.."

FILES=("$@")
if [ ${#FILES[@]} -eq 0 ]; then
  mapfile -t FILES < <(find docs/ko -maxdepth 1 -name '[0-9]*.md' | sort)
fi

# 이름:정규식:인용제외
#   인용제외=1 이면 백틱 인라인 코드 안의 내용을 검사 전에 지운다.
#   컴파일러·FSI 메시지 인용이 백틱 안에 오고, 용어집 규칙상 그 표기는 고치지 않는다.
#   따라서 문체(합니다/해요)와 번역체(에 대해 등)는 인용을 면제한다 — 메시지 자체가
#   그런 표현을 쓰는 경우가 있고 노트가 고칠 수 없다.
#   have 직역·금지 표기는 백틱 안(유사 타입 표기 등)에서도 실제 위반이므로 면제하지 않는다.
CHECKS=(
  "금지 표기:표현식|부작용|일급 값|컴파일 에러|씨드:0"
  "have 직역:가진다|가져야|가지므로|가진 |가지고|갖는|갖고|가짐:0"
  "번역체:에 대해|을 통해|를 통해|되어진|되어짐:1"
  "원서 1인칭:우리는|우리가:0"
  "문체 혼입:합니다|해요:1"
  "장/챕터 혼용:[0-9]장:0"
  "굵은 글씨:\\*\\*:0"
  "폐기된 예제 링크:\\]\\(examples/|docs/ko/examples:0"
)

fail=0
for f in "${FILES[@]}"; do
  hits=""
  for c in "${CHECKS[@]}"; do
    name=${c%%:*}; rest=${c#*:}; pat=${rest%:*}; strip=${rest##*:}
    if [ "$strip" = "1" ]; then
      # 줄 번호를 보존하려고 인라인 코드만 비우고 줄 자체는 남긴다
      out=$(sed 's/`[^`]*`//g' "$f" | grep -nE "$pat" || true)
      # 원본 줄 내용을 다시 붙여 보여 준다
      if [ -n "$out" ]; then
        out=$(printf '%s' "$out" | cut -d: -f1 | while read -r n; do
          printf '%s:%s\n' "$n" "$(sed -n "${n}p" "$f")"
        done)
      fi
    else
      out=$(grep -nE "$pat" "$f" || true)
    fi
    [ -n "$out" ] && hits+=$(printf '\n  [%s]\n%s' "$name" "$(printf '%s' "$out" | sed 's/^/    /')")
  done
  if [ -n "$hits" ]; then
    fail=1
    printf 'FAIL  %s%s\n' "$(basename "$f")" "$hits"
  else
    printf 'OK    %s\n' "$(basename "$f")"
  fi
done

[ $fail -eq 0 ] && echo "금지 패턴 위반 없음" || echo "위반이 있다" >&2
exit $fail
