#!/usr/bin/env bash
# 18개 챕터 노트를 하나의 마크다운으로 합친다. PDF 변환용 읽기 사본이다.
#
# 사용법: docs/ko/_pipeline/build-single-doc.sh [출력파일]
# 기본 출력: docs/ko/essential-fsharp-ko.md
#
# 원본은 챕터별 노트다. 이 파일은 파생물이므로 직접 고치지 말고
# 노트를 고친 뒤 이 스크립트를 다시 돌려라.
#
# 코드 펜스의 `id=<이름>` 은 검증 스크립트용 표시이므로 읽기 사본에서는 떼어 낸다.
set -euo pipefail
cd "$(dirname "$0")/../../.."

OUT=${1:-docs/ko/essential-fsharp-ko.md}
mapfile -t NOTES < <(find docs/ko -maxdepth 1 -name '[0-9][0-9]-*.md' | sort)

[ ${#NOTES[@]} -eq 0 ] && { echo "노트를 찾지 못했다." >&2; exit 1; }

{
  cat <<'HEADER'
# Essential F# 한국어 학습 노트

이 문서는 Ian Russell 의 **Essential F#** 을 읽는 한국인 독자를 위한 학습 노트다.
원서의 번역이 아니다. 각 절의 개념을 한국어로 요약하고, 예제 코드는 같은 개념을 보여 주는
새로 작성한 F# 코드로 채웠다. 절 제목마다 원서 인쇄 페이지를 달아 두었으니
원서를 옆에 두고 대조하며 읽을 수 있다.

원서: Ian Russell, *Essential F#*, Leanpub (2023-01-30 판).
원서 자체를 대신하지 않는다. 원서에서 직접 읽어야 하는 대목은 페이지를 가리켜 두었다.

**코드 실행**: 본문의 F# 코드 블록은 `dotnet fsi` 로 실행해 검증한 것이다.
같은 절의 블록들은 위에서 아래로 이어 붙여 하나의 스크립트가 된다.
일부 블록은 실행되지 않는 조각이다 — 시그니처 표기, 일부러 컴파일 오류를 내는 예시,
NuGet 패키지나 `namespace` 선언 때문에 스크립트로 돌 수 없는 코드다. 본문에 그때마다 밝혀 두었다.

**환경**: .NET SDK 10.0.111 / F# 10 에서 확인했다. 원서는 2023년 1월 판이므로
그 사이 달라진 것은 실측해 본문에 적었다.

HEADER

  echo "## 차례"
  echo
  for f in "${NOTES[@]}"; do
    title=$(grep -m1 '^# ' "$f" | sed 's/^# //')
    echo "- $title"
  done
  echo

  for f in "${NOTES[@]}"; do
    echo "---"
    echo
    sed 's/^```fsharp id=[A-Za-z0-9-]*[[:space:]]*$/```fsharp/' "$f"
    echo
  done
} > "$OUT"

printf '%s  (%s줄, 챕터 %s개)\n' "$OUT" "$(wc -l < "$OUT")" "${#NOTES[@]}"
