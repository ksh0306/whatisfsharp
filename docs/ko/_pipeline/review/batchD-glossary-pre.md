# 배치 D 사전 용어집 등재 보고서 (12챕터 착수 전)

작업 모드: 병합 모드. `docs/ko/GLOSSARY.md` 를 이 세션에서만 편집했다.
입력: `docs/ko/_pipeline/HANDOFF.md` "배치 D 착수 전에 처리할 것",
원문 `.cache/src/12-computation-expressions.txt`(원서 pp.153-165), 08챕터 노트와 08 검수 기록.

## 1. 결과 요약

- 신규 등재 21행. 표 데이터 행 252 → 273.
- 기확정 행은 한 곳도 고치지 않았다(표기·비고 모두 무수정).
- `[기확정 변경 제안]` 없음.
- 08챕터 노트 수정 필요 없음. 08 이 이미 쓴 "계산 식 빌더" 가 등재 표기와 정확히 일치한다.
- 검증: 표 칸 수 이상 0건(이상으로 잡히는 19행은 모두 셀 안 `\|` 이스케이프가 있는 기존 행),
  정렬 위반 0건, 영어 키 중복 0건, 한국어 표기 중복 0건.
  `check-note.sh docs/ko/GLOSSARY.md` 의 FAIL 항목은 전부 기존 행이다(금지 표기를 금지하려고
  인용한 행과 `**확정.**` 표기). 신규 21행은 어느 검사에도 걸리지 않는다.

## 2. 등재 항목 21개

정렬 위치는 머리말 규칙(백틱·`[<`·`>]` 를 벗기고 대소문자 무시, 괄호 한정어와 타입 매개변수는
벗기지 않음)으로 잡았다.

| 영어 | 확정 표기 | 근거 |
|---|---|---|
| `[<AutoOpen>]` | `[<AutoOpen>]` | 원서 p.155. 특성 이름은 번역하지 않는 기존 규칙(`[<Struct>]`·`[<TailCall>]`)에 맞춤 |
| `Async` | `Async` | 원서 p.153·158. 타입 이름은 번역하지 않는다. 지연 평가·`RunSynchronously` 를 비고에 실측으로 적었다 |
| `asyncResult` | `asyncResult` | 원서 p.159-162. 계산 식 이름은 소문자 값이라 번역하지 않는다 |
| bang (!) | `!` | 원서 p.155 "the bang (!)". 음차 "뱅" 을 막고 키워드를 그대로 적게 하는 표기 정책 행 |
| computation expression builder | 계산 식 빌더 | HANDOFF 지정 항목. 기확정 `computation expression`→계산 식 계열 |
| compound computation expression | 복합 계산 식 | 원서 p.159 절 제목 |
| custom computation expression | 사용자 정의 계산 식 | 원서 p.153. 기확정 `custom operator`→사용자 정의 연산자 와 "사용자 정의" 를 맞춤 |
| `do!` | `do!` | 원서 p.162. 키워드는 번역하지 않는다 |
| Domain-Specific Language (DSL) | 도메인 특화 언어 | 원서 p.164. 병기 규칙은 `Line of Business (LOB)` 행과 같게 |
| early return | 조기 반환 | 원서 p.154 "no early return" |
| effect | 효과 | 원서 p.153 이 `Option`·`Result`·`Async` 를 부르는 이름. 00챕터 대조표가 이미 "효과" 로 쓴다 |
| happy path | 해피 패스 | 원서 p.155. 정착된 역어가 없어 음차 |
| `let!` | `let!` | 원서 p.155. 키워드는 번역하지 않는다 |
| `[<Literal>]` | `[<Literal>]` | 원서 p.161 |
| `option` (computation expression) | `option` 계산 식 | 원서 p.155. 타입 `Option` 과 갈라야 해서 괄호 한정어를 붙였다(`map`/`Map` (collection type) 판례) |
| `result` (computation expression) | `result` 계산 식 | 원서 p.157. 타입 `Result` 와 갈라야 해서 같은 방식 |
| `return!` | `return!` | 원서 p.156 |
| syntactic sugar | 문법 설탕 | 원서 p.153. 한국어 위키백과 표제어와 같고 "구문 설탕"·음차보다 통용된다 |
| `Task` | `Task` | 원서 p.153·158. .NET 타입 이름은 번역하지 않는다 |
| track | 선로 | 원서 p.154·164 "None track"·"Ok track". 03챕터가 이미 "`Ok` 선로 / `Error` 선로" 로 썼다. 표기를 확정만 한 것이고 기존 노트 문장은 그대로 성립한다 |
| unwrap | 벗기다 | 원서 p.155 "unwraps the effect". 03·05·08챕터가 이미 "벗겨"·"감싸" 로 쓴다 |

## 3. 빌더 멤버 이름 표기 방침

`computation expression builder` 행에 넣었다.

- 멤버 이름(`Bind`·`Return`·`ReturnFrom`·`Zero`·`Combine`·`Delay`·`MergeSources` 등)은 번역하지 않고
  백틱 원어로 적는다. 컴파일러가 이름으로 찾아 부르는 멤버이므로 번역하면 코드와 어긋난다.
- 빌더 인스턴스에 붙은 소문자 값 이름(`option`·`result`·`asyncResult`·`validation`)도 번역하지 않는다.
  이 이름은 타입이 아니라 값이므로 대문자 타입 이름과 섞어 적지 않는다.
- "계산 식 빌더" 는 빌더 타입과 그 인스턴스를 함께 가리키는 말로 쓰고, 문맥이 분명하면 "빌더" 로 줄인다.
  "작성기"·"생성기"·"빌더 클래스" 는 쓰지 않는다.
- 별도 행으로 등재하지 않은 이유: 원문 12장에 실제로 나오는 멤버는 `Bind`·`Return`·`ReturnFrom` 뿐이고,
  나머지는 노트가 보충할 때에만 등장한다. 멤버 이름을 행으로 늘리는 대신 규칙 한 줄로 묶었다.

## 4. 08챕터 수정 필요 여부

수정 필요 없음.

- `08-functional-validation.md:664` 의 "계산 식 빌더의 `Bind` 멤버를, `and!` 는 `MergeSources` 멤버를"
  이 등재 표기와 문자 그대로 일치한다. 노트 전체에서 "빌더" 가 쓰인 곳은 이 한 곳뿐이다(`grep` 확인).
- 이번에 금지 표기로 못박은 낱말들("트랙", "이펙트", "언래핑", "커스텀 계산 식", "구문 설탕",
  "행복 경로", "이른 반환")이 기존 12개 노트에 쓰인 곳은 없다(`grep` 확인). 소급 수정 대상 0건.

## 5. 원문에 없어서 등재하지 않은 것

지시서가 예상 목록으로 든 것 중 원문 12장에 나오지 않는 항목은 만들지 않았다.

- `custom operation`, `state machine`, `desugaring`, `yield`/`yield!`, `Zero`·`Combine`·`Delay`·`MergeSources`
  단독 행 — 원문 12장에 없다. 멤버 이름은 3절 규칙으로 덮었고, `yield` 는 기확정 `implicit yield` 행이
  "`yield` 는 번역하지 않는다" 를 이미 못박아 두었다.
- `and!` — 원문 12장에 없다(08챕터 소재다). 기확정 `applicative` 행과 이번 `let!` 행이 함께 덮는다.
- `async`/`task` 계산 식을 따로 행으로 쪼개지 않았다. 정렬 키가 타입 이름과 겹쳐 표가 흔들리므로
  `Async`·`Task` 행 안에서 소문자 계산 식 이름을 함께 못박았다.

## 6. 12챕터 집필자에게 전달할 주의사항 (전부 FSI 실측)

실측 환경: .NET SDK 10.0.111, `dotnet fsi`, `FsToolkit.ErrorHandling, 5.2.0`.

1. 원서 p.162 의 `do!` 설명을 그대로 옮기면 틀린다. 원서는 "supports functions that return unit" 이라
   적지만, `do!` 가 받는 것은 `unit` 이 아니라 효과가 감싼 `unit`(`Async<unit>`·`Result<unit,'e>`)이다.
   평범한 `unit` 을 주면 `error FS0001` 이다. 노트는 "`unit` 을 감싼 효과" 로 써라.
2. 원서 p.155 의 "Let bindings that would have used `Option.map` are automatically handled by the
   underlying computation expression code" 도 그대로 옮기면 오해를 만든다. 계산 식 안의 `!` 없는 `let`
   은 `map` 으로 바뀌는 것이 아니라 보통 `let` 바인딩 그대로다. `map` 이 필요 없어지는 이유는
   `Bind` 가 이미 한 겹 벗긴 값을 넘겨 주기 때문이다.
3. `option { ... }` 을 빌더 없이 적으면 `error FS0039` 가 아니라 `error FS0800`(형식 이름을 잘못
   사용했습니다)이다. `option` 이 타입 약어 이름으로 먼저 읽힌다. 반면 `result { ... }` 는 `error FS0039` 다.
   오류 코드를 주석에 적을 때 이 둘을 뒤집지 마라.
4. `let x = result { ... }` 를 모듈 수준에 그냥 두면 실패 타입이 정해지지 않아 값 제한
   (`error FS0030`)에 걸린다. 노트의 실행 단위는 최상위 스크립트이므로 반드시 타입 주석
   (`let x : Result<int,string> = ...`)을 달거나 함수 안에서 써라.
5. 원서의 `[<Literal>]` 예제는 장식이 아니다. 특성을 빼면 `match username with | ValidUser -> ...` 의
   `ValidUser` 가 변수 패턴이 되어 모든 입력을 삼키고, `warning FS0049` 와 뒤 케이스의
   `warning FS0026` 이 난다. 상수 패턴이 되는 것이 `[<Literal>]` 의 요점이다.
6. `Async` 는 지연, `Task` 는 즉시다. 실측하면 `task { printfn ... }` 은 값을 만드는 순간 본문이 돌고
   `async { printfn ... }` 은 `Async.RunSynchronously` 에서 돈다. 원서 p.153·158 의 서술과 일치한다.
7. F# 코어에 들어 있는 계산 식은 `seq`·`async`·`task`(그리고 `query`)이고 `option`·`result` 는 없다.
   `task` 는 F# 6 부터 코어에 있다. 12챕터가 "코어에 없다" 를 말할 때 `task` 를 함께 묶지 마라.
8. `FsToolkit.ErrorHandling` 5.2.0 은 `result`·`option`·`asyncResult` 를 모두 준다. 원서처럼 빌더를
   직접 만드는 실행 단위와 패키지를 쓰는 실행 단위를 갈라 두면, 패키지 없이 도는 단위를 남길 수 있다.
   패키지가 필요한 단위는 머리말의 이식성 규칙 세 가지를 지켜라(버전 고정 `5.2.0`, `id` 유지,
   선행 요구사항 한 줄).
9. `Bind`·`Return`·`ReturnFrom` 세 멤버만 있는 빌더로 `let!`·`let`·`return`·`return!`·`do!` 가 모두
   돈다(실측). `Zero`·`Combine` 이 필요해지는 것은 `if` 에 `else` 가 없거나 여러 식을 이어 붙일 때다.
   원서 범위에서는 세 멤버로 충분하다.
