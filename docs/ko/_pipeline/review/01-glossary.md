# 01챕터 용어 후보 (F# 전문가 검수, 후보 모드)

`docs/ko/GLOSSARY.md` 에 아직 없는 항목만 올린다. 기확정 항목은 손대지 않았다.
표는 영어 알파벳 순이다. 병합 담당자는 이 표를 그대로 `GLOSSARY.md` 본표에 끼워 넣으면 된다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| active pattern | 액티브 패턴 | `(\|Name\|_\|)` 형태. MS ko 는 "활성 패턴"이나 "활성"은 켜짐/꺼짐 상태를 연상시켜 오해를 부른다. 커뮤니티 통용 음차를 택한다. 부분 액티브 패턴(partial active pattern)은 `option` 을 반환한다. 7챕터 본론 |
| Algebraic Type System (ATS) | 대수적 타입 시스템 | 원서 고유 표기(원서 p.9). 함수형 일반 통용은 algebraic data type(대수적 데이터 타입, ADT). 노트는 원서 대조를 위해 "대수적 타입 시스템"을 쓰고 약어는 ATS 로 둔다 |
| AND type | AND 타입 | 여러 값을 동시에 담는 타입(튜플, 레코드). 영문 대문자를 그대로 쓴다. "곱 타입"으로 번역하지 않는다 |
| behaviour driven development (BDD) | 행위 주도 개발 | 약어 BDD 병기 허용 |
| camel case | 카멜 표기 | 첫 글자 소문자. 값과 함수 이름에 쓴다. MS ko 는 "카멜식 대/소문자" |
| case data | 케이스 데이터 | 케이스 식별자 뒤 `of` 에 붙는 타입. 음차 고정. FSI 한국어 오류 메시지는 "공용 구조체 사례"라고 하지만, 이 노트는 `discriminated union`을 "판별 유니온"으로 확정했으므로 "사례" 대신 "케이스"로 계열을 맞춘다 |
| case identifier | 케이스 식별자 | `Subscribed`, `Walkup` 처럼 케이스를 가리키는 이름. 값을 만들 때 함수처럼 앞에 붙인다 |
| exhaustive pattern matching | 빠짐없는 패턴 매칭 | 명사형은 "빠짐없음(exhaustiveness)". "망라적"은 생소해 쓰지 않는다. FSI 한국어 경고는 "패턴 일치가 완전하지 않습니다"로 "완전"을 쓰나, 노트는 뜻이 바로 읽히는 "빠짐없는"을 택하고 첫 등장 시 원어를 병기한다. 케이스를 빠뜨리면 경고 FS0025 |
| field | 필드 | 레코드의 이름 붙은 부분. MS ko 도 "필드" |
| F# Interactive (FSI) | `F# Interactive`(FSI) | 원어 그대로. 이후 FSI 로 줄인다. 0챕터 소관이므로 병합 시 중복 등재를 확인할 것 |
| guard clause | 가드 절 | `match` 케이스의 `when` 절. 문맥이 분명하면 "`when` 가드"로 줄여 쓴다. 빠짐없음 검사는 가드의 참/거짓을 계산하지 않는다 |
| illegal state | 잘못된 상태 | "잘못된 상태를 표현조차 할 수 없게 만든다(make illegal states unrepresentable)"가 이 챕터의 모델링 지침 |
| `match` expression | `match` 식 | MS ko 는 "일치 식". 노트는 키워드가 그대로 보이는 "`match` 식"을 쓴다. `expression`→식 확정 표기와 맞물린다 |
| OR type | OR 타입 | 여러 경우 중 하나만 담는 타입(판별 유니온). "합 타입"으로 번역하지 않는다 |
| Pascal case | 파스칼 표기 | 첫 글자 대문자. 타입 이름과 케이스 식별자에 쓴다. MS ko 는 "파스칼식 대/소문자" |
| pattern matching | 패턴 매칭 | MS ko 는 "패턴 일치"이나 커뮤니티 통용인 "패턴 매칭"을 택한다. 동사형은 "매칭한다" |
| sealed trait | 봉인된 트레이트 | Scala 용어. F# 판별 유니온에 대응한다. Postscript 절에서만 쓴다 |
| significant whitespace | 유의미한 공백 | 들여쓰기 정렬이 스코프를 정한다는 뜻. "의미 있는 공백"도 통용하나 노트는 "유의미한 공백"으로 고정한다. 탭 문자는 오류 FS1161 |
| type abbreviation | 타입 약어 | `type RawDriver = string * bool * bool`. 새 타입을 만드는 것이 아니라 기존 타입에 별명을 붙이는 것. MS ko 는 "형식 약어"이나 이 노트는 `type`을 "타입"으로 쓴다. 9챕터의 단일 케이스 판별 유니온과 대비되는 개념 |
| union case | 유니온 케이스 | `\|` 로 나열한 항목 하나. MS ko 는 "공용 구조체 사례". "판별 유니온" 표기와 맞물리게 "유니온 케이스"를 쓴다 |

## 기확정 항목 재검토 요청
없다. 01챕터에서 기확정 표기를 뒤집어야 할 근거는 발견하지 못했다.

## 병합 시 확인할 것
- 이미 등재된 `structural equality`(구조적 동등성)는 01챕터 본문에 아직 등장하지 않는다.
  검수 보고서의 개선 권장 항목을 반영하면 01챕터가 첫 등장 지점이 되므로,
  `한국어(영어)` 병기 위치가 01챕터로 옮겨진다.
- `mutable`(가변), `wildcard`(와일드카드), `record`(레코드), `discriminated union`(판별 유니온),
  `tuple`(튜플), `curried parameters`(커링된 매개변수), `tupled parameter`(튜플 매개변수)는
  이미 등재돼 있고 01챕터 사용이 표기와 일치한다.
