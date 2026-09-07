# 배치 A 용어집 병합 보고서 (챕터 00·01·03·04)

병합 대상: `.cache/review/00-glossary.md`, `01-glossary.md`, `03-glossary.md`, `04-glossary.md`
병합 결과: `docs/ko/GLOSSARY.md`

## 1. 확정 항목 총수

- 병합 전 49행 → 병합 후 126행 (신규 77행)
- 표는 영어 알파벳 순으로 재정렬했고 중복 행은 없다(백틱·괄호·하이픈을 제거한 키로 기계 검사).
- 마크다운 표 셀 수도 전 행 3칸으로 검사했다(표 내부 `|` 는 `\|` 로 이스케이프).

신규 항목의 출처별 분포
- 00챕터 소유: backward compatibility, breakpoint, code file, compiler directive, F# Interactive (FSI),
  functional-first, general-purpose language, Line of Business (LOB), REPL, runtime, script file, SDK,
  solution, target framework, template
- 00챕터가 먼저 쓰지만 소유는 뒤 챕터: collection(5챕터), computation expression(8·12챕터),
  pattern matching(1챕터), primitive(9챕터) — 배치 A 노트에 실제로 쓰였으므로 등재했다.
  `effect`(효과, 12챕터 소유)는 배치 A 노트에 단독 용어로 등장하지 않아 등재를 보류했다.
- 01챕터 소유: active pattern, Algebraic Type System (ATS), AND type, behaviour driven development (BDD),
  camel case, case data, case identifier, exhaustive pattern matching, field, guard clause, illegal state,
  `match` expression, OR type, Pascal case, sealed trait, significant whitespace, type abbreviation, union case
- 03챕터 소유: `bind`, call chain, Domain-Driven Design, exception, `exn`, interop, `map`, `null`,
  nullable reference types, `Nullable<'T>`, nullness, `Option`, optional data, `out` parameter,
  placeholder value, Railway Oriented Programming, `Result`, Scott Wlaschin, type test operator, type test pattern, upcast
- 04챕터 소유: assembly, assertion, attribute, circular reference, compile order, FsUnit, import declaration,
  Ionide, module, namespace, nested module, project, project reference, qualified name, shadowing,
  test runner, top-level module, unit test, xUnit

## 2. 표기 충돌과 결정

### 2.1 `match` expression — "일치 식"(03) vs "`match` 식"(01) → `match` 식 으로 확정

근거
- 노트는 `pattern matching`을 MS ko "패턴 일치" 대신 "패턴 매칭"으로 확정했다(01·03 후보 모두 동의).
  같은 문법을 가리키는 개별 이름에서 "일치"를 되살리면 한 문서 안에서 계열이 어긋난다.
  03챕터는 "패턴 매칭"을 한 번도 쓰지 않고 "일치 식"만 쓰므로 이 어긋남이 아직 드러나지 않았을 뿐이다.
- "일치 식"은 `=` 비교식으로 오독될 소지가 있다. 키워드가 보이는 표기가 검색·원서 대조에 유리하다.
- 기확정 `expression`→식 원칙과 충돌하지 않는다. 바뀌는 것은 수식어뿐이다.

영향: 03챕터 9곳(아래 4.2 목록). 01챕터는 이미 확정 표기와 일치한다.

### 2.2 case 계열 — "케이스 데이터 / 케이스 식별자 / 유니온 케이스"(01) vs "경우 이름"(03) → 01 표기로 확정

근거: `discriminated union`이 "판별 유니온"으로 이미 확정돼 있어 하위 용어를 "케이스"로 맞추는 것이
일관된다. FSI 한국어 메시지의 "공용 구조체 사례"는 "구별된 공용 구조체"를 기각한 것과 같은 이유로 쓰지 않는다.
"케이스 데이터"는 음차이지만 대체 역어("사례 데이터", "경우 값")가 통용되지 않으므로 음차 우선 원칙에 따른다.

영향: 03챕터 1곳(217줄 "두 경우 이름은").

### 2.3 F# Interactive 표기 — "FSI"(00) vs "`F# Interactive`(FSI)"(01) → 백틱 없이 F# Interactive(FSI)

근거: 식별자가 아니라 도구 이름이다. 노트 실제 사용(00챕터 절 제목, 01챕터 3줄)도 백틱 없이 쓴다.
행은 하나로 합쳤다. 영향 없음(현재 노트가 이미 이 형태다).

### 2.4 xUnit / XUnit → xUnit

근거: 공식 명칭이 xUnit.net 이고 소문자 x 로 시작한다. 원서 "XUnit" 표기를 따르지 않는다.
NuGet 패키지 이름은 `xunit` / `FsUnit.xUnit`, `open` 하는 네임스페이스는 `Xunit` / `FsUnit.Xunit` 이다.
영향: 01챕터 350줄, 04챕터 35줄.

### 2.5 중복 등재를 한 행으로 합친 것

- `solution` (00 "음차 고정. `dotnet new sln`" + 04 "컴파일되지 않는 프로젝트 목록") → 비고 병합
- `target framework` (00 + 04) → 비고 병합, `net10.0` 예시 유지
- `computation expression` (00 + 03) → 비고 병합, 소유 챕터 8·12 로 표기
- `pattern matching` (00 + 01 + 03) → 01·03 비고 병합, "개별 문법 이름도 이 계열로 맞춘다" 문장 추가
- `F# Interactive` (00 + 01) → 2.3 참조

### 2.6 판단이 필요하다고 넘어온 항목 — 결정

| 항목 | 결정 | 근거 |
|---|---|---|
| exhaustive pattern matching | 용어로 등재. 표기 "빠짐없는 패턴 매칭", 명사형 "빠짐없음" | 경고 FS0025 를 설명하는 대목마다 되풀이되는 개념이라 이름이 필요하다. "망라적"은 기각(생소). 서술문에서 "모든 케이스를 빠짐없이 적어야 한다"로 풀어 쓰는 것도 허용하되, 원어 병기는 등재 표기에 붙인다 |
| union case / case identifier / case data | 유니온 케이스 / 케이스 식별자 / 케이스 데이터 | 2.2 참조 |
| assertion | 어서션 | MS ko "어설션", 번역서 "단정문"·"단언"이 갈린다. 셋 중 하나를 고르는 근거가 없어 외래어 표기법대로 옮긴 음차로 고정. 04챕터가 이미 11곳에서 이 표기를 쓴다 |
| significant whitespace | 유의미한 공백 | "의미 있는 공백"도 통용이나 서술어와 붙을 때 짧다. 01챕터 사용과 일치 |
| guard clause | 가드 절 | `when` 절을 가리키는 통용 표기. 01챕터 사용과 일치 |
| active pattern | 액티브 패턴 | MS ko "활성 패턴"은 켜짐/꺼짐 상태로 읽힌다. 커뮤니티 통용 음차 채택 |
| solution / project | 솔루션 / 프로젝트 | 역어("해법", "과제")가 통용되지 않는다. 음차 고정 |
| unit test | 단위 테스트 | 정착 역어. MS ko 와도 일치 |
| Ionide | Ionide | 음차가 갈려 라틴 표기 고정 |

## 3. `[기확정 변경 제안]` 항목

없다. 네 챕터 후보 파일과 검수 보고서 모두 기확정 49항목을 뒤집자는 제안을 내지 않았다.
기존 49행의 표기와 비고는 그대로 유지했다.

머리말에 문장 하나만 보탰다(원칙 변경이 아니라 모호함 해소).
- 기존: "용어 첫 등장 1회만 `한국어(영어)`로 병기하고, 이후에는 한국어만 쓴다."
- 추가: "각 챕터는 따로 읽히므로 병기는 챕터마다 1회까지 허용한다."
- 근거: 노트 5개가 이미 챕터 단위로 병기하고 있다(`(wildcard)`, `(record)`, `(discriminated union)`,
  `(type parameter)` 가 01·02·03 각 1회). 코퍼스 전체 1회로 읽으면 세 챕터 중 두 곳을 지워야 하는데,
  챕터별 독립 학습 노트라는 성격과 맞지 않는다. 사용자가 반대하면 이 한 줄만 되돌리면 된다.

## 4. 챕터별 수정 목록 (4단계 재작업 지시)

노트 파일은 이 병합에서 수정하지 않았다. 아래는 집필자가 그대로 적용할 목록이다.

### 4.1 `docs/ko/01-domain-modelling.md`

1. 350줄 — `XUnit` → `xUnit`.
   교체: "...여기서 손으로 만든 검증을 xUnit 단위 테스트로 옮기는 방법은 4챕터에서 다룬다."
2. 29줄 — "기본 타입" → "원시 타입"(용어집 `primitive`).
   교체: "- F# 에는 `string`, `decimal`, `bool` 같은 원시 타입 말고도 대수적 타입 시스템(Algebraic Type System, ATS)이 있다. 작은 데이터 구조를 조립해 큰 구조를 만드는 재료로 보면 된다."
3. 254줄 — 원어 병기를 등재 표기에 맞춘다("빠짐없는 패턴 매칭").
   교체: "- 판별 유니온을 상대로 하는 패턴 매칭은 빠짐없는 패턴 매칭(exhaustive pattern matching)이어야 한다. 모든 케이스를 처리해야 하고, 빠뜨리면 컴파일러가 불완전한 패턴 매칭이라고 경고한다. 아래처럼 `Walkup` 을 빼면 경고 FS0025 가 난다."
4. (선택) 204줄 코드 주석의 "match 식" 은 주석이라 백틱을 쓰지 않는 것이 맞다. 그대로 둔다.

### 4.2 `docs/ko/03-null-and-exceptions.md`

1. "일치 식" → "`match` 식" 9곳: 40, 74, 159, 314, 318, 332, 417, 487, 497줄.
   - 40줄은 병기까지 함께: "`if` 식 대신 `match` 식(match expression)으로 튜플을 분해해도 결과는 같다. ..."
   - 318줄은 코드 주석이므로 백틱 없이: "// 익명 함수와 match 식으로 직접 메운 형태"
   - 나머지 7곳은 본문이므로 "`match` 식"으로 적는다.
2. 217줄 — "경우 이름" → "케이스 식별자".
   교체 후반부: "... 내장 타입의 두 케이스 식별자는 `Ok` 와 `Error` 다."
3. 227줄 — "타입 검사 패턴" → "타입 테스트 패턴"(03챕터 검수 보고서 46~51줄과 같은 지시).
   교체: "- `try/with` 안의 `:?` 는 타입 테스트 패턴(type test pattern)이다. 던져진 예외가 적은 타입이거나 그 하위 타입인지를 본다. `as ex` 로 실제 예외 인스턴스를 받아 `Error` 의 케이스 데이터로 넘긴다."
   (원문의 "`Error` 의 경우 데이터로" 도 "케이스 데이터"로 함께 고친다.)

### 4.3 `docs/ko/04-organising-code-and-testing.md`

1. 35줄 — 한 문장 안에 `FsUnit.XUnit` 과 `FsUnit.xUnit` 이 섞여 있다. NuGet 등록 이름이 `FsUnit.xUnit` 이므로 통일한다.
   교체: "- 원서 부록은 `FsUnit` 과 `FsUnit.xUnit` 두 패키지를 모두 넣지만, xUnit 만 쓸 때는 `FsUnit.xUnit` 하나로 충분하다. `FsUnit.xUnit` 은 `FsUnit` 을 의존하지 않는 독립 패키지이고, `FsUnit` 단독 패키지는 NUnit 용 어서션이다."
2. 429줄 — "테스트 실행 장치" → "테스트 러너"(용어집 `test runner`).
   교체: "- 테스트 러너는 여전히 xUnit 이다. FsUnit 이 바꾸는 것은 어서션을 적는 문법뿐이고, `[<Fact>]` 와 `dotnet test` 는 그대로다."
3. 50줄·258줄의 "형식"(파일 형식, 출력 형식)과 106줄 컴파일러 메시지 인용의 "형식"은 `type` 의 역어가 아니므로 그대로 둔다.

### 4.4 `docs/ko/00-preface-getting-started.md`

용어집과 어긋난 표기는 없다. 115줄의 "기본 타입 추론"은 `primitive` 가 아니라 "기본적인 타입 추론"의 뜻이므로
용어 위반이 아니지만, 2번 항목과 나란히 읽히면 오해를 부를 수 있다. 문장을 다듬을 때 "`+` 의 타입 추론 결과"로
줄이는 것을 권한다(문체 담당 판단).

### 4.5 `docs/ko/02-functions.md`

배치 A 대상이 아니지만 기계 검사에 걸린 것이 없다. 426·429·430줄의 "중위 연산자"는 용어집
`infix form` 비고가 허용한 용법(연산자 분류를 말할 때)이라 수정 대상이 아니다.

## 5. 등재 보류 / 다음 배치 판단거리

- `effect`(효과) — 12챕터 소유. 배치 A 노트에는 `side effect` 의 일부로만 등장한다. 12챕터에서 등재.
- `pipeline`(파이프라인) — 00·02·03·04 네 노트에서 15회 쓰이는데 용어집에 없다. 표기는 전 챕터가
  일치하므로 급하지 않지만, 다음 병합에서 등재를 검토할 것.
- `.slnx` / `.sln` — 확장자 원어 표기라 별도 행을 만들지 않았다. `solution` 행에서 다룬다.
