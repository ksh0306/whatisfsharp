#!/usr/bin/env bash
# 원서 PDF를 챕터별 텍스트로 분리한다.
# 사용법: docs/ko/_pipeline/split-chapters.sh [출력디렉터리]
# 기본 출력: .cache/src/  (git 추적 대상 아님)
#
# 인쇄 페이지 -> PDF 페이지 오프셋은 +6 이다.
set -euo pipefail
cd "$(dirname "$0")/../../.."
PDF=docs/essential-fsharp.pdf
OUT=${1:-.cache/src}
OFFSET=6
mkdir -p "$OUT"
while IFS=: read -r id name first last; do
  [ -z "${id:-}" ] && continue
  pdftotext -f $((first + OFFSET)) -l $((last + OFFSET)) -layout "$PDF" "$OUT/$id-$name.txt"
  echo "$OUT/$id-$name.txt  (원서 pp.$first-$last)"
done < docs/ko/_pipeline/chapters.txt
