# 16챕터 용어 후보 (F# 전문가 검수, 후보 모드)

`docs/ko/GLOSSARY.md` 는 읽기만 했고 편집하지 않았다(17챕터 전문가와 동시 작업 중).
아래 행을 알파벳 순 위치에 삽입하면 된다.

16챕터는 F# 문법이 나오지 않는 마무리 장이므로 새 F# 개념 용어는 없다. 올린 항목은
(1) 이 장이 처음 쓰는 자료·조직·문서 이름의 표기 규칙, (2) 앞 챕터에서 이미 쓰였는데
용어집에 없는 표기, (3) 17챕터와 맞춰야 하는 노트 안쪽 지칭 규칙이다.

`[기확정 변경 제안]` 은 없다. 16챕터가 쓰는 기확정 용어는 표기를 그대로 따르고 있다.

## 1. 확정 제안 (그대로 삽입)

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| API reference | API 참조 | 라이브러리의 타입과 멤버 목록을 담은 문서. 언어 안내서·튜토리얼과 구별해 쓴다 — 원서 자료 목록의 `F# Docs` 가 건 `fsharp.github.io/fsharp-core-docs` 는 `FSharp.Core` 의 API 참조이고, 언어 안내서는 Microsoft Learn 쪽이다. MS ko 표기와 일치. "API 레퍼런스"·"API 명세" 쓰지 않는다. 16챕터 |
| document database | 문서 데이터베이스 | 레코드를 문서 단위로 담는 데이터베이스. MS ko 표기와 일치. "도큐먼트 DB"·"문서형 DB" 쓰지 않는다. 16챕터가 저장소 뒤를 바꿀 후보로 한 번 든다 |
| ethos | 신조 | 원서 p.192 의 "My F# ethos is" 를 옮긴 것. 저자가 스스로 내놓는 한 줄짜리 원칙을 가리킨다. "에토스"·"기풍"·"철학" 쓰지 않는다. 16챕터 |
| F# Software Foundation | F# Software Foundation | 조직 이름이므로 번역하지 않는다. 한 절 안에서 되풀이할 때만 "재단" 으로 줄인다. 약어 FSSF 는 쓰지 않는다 — 원서 본문이 약어를 쓰지 않고 00·16챕터가 전체 이름과 "재단" 만으로 문장을 다 만든다(기확정 `dependency injection` 의 DI, `tail call optimisation` 의 TCO 를 쓰지 않기로 한 것과 같은 판단이다). "F# 소프트웨어 재단" 쓰지 않는다. 00·16챕터 |
| loop | 반복문 | `for`·`while` 로 같은 일을 되풀이하는 구문. 파이프라인과 견주는 자리에서는 "반복문" 으로 쓰고(11챕터 정리, 16챕터 표), 특정 구문을 짚을 때만 `for` 루프 처럼 키워드를 백틱으로 앞에 붙인다(5챕터 도입). "루프" 단독으로 쓰지 않는다. 5·11·16챕터 |
| Microsoft Learn | Microsoft Learn | 문서 사이트 이름이므로 원어를 유지한다. 한국어판을 가리킬 때는 경로에 `ko-kr` 이 든 주소를 그대로 적는다(`learn.microsoft.com/ko-kr/dotnet/fsharp/`). 용어집 비고에 쓰는 "MS ko" 는 이 파일 안에서만 쓰는 약칭이고 노트 본문에는 쓰지 않는다. "MS 런"·"마이크로소프트 러닝"·옛 이름 "docs.microsoft.com" 쓰지 않는다. 16챕터 |
| next steps | 다음 걸음 | 원서 뒤에 노트가 덧붙이는 방향 안내. 15챕터가 이미 "다음 걸음" 으로 쓰고 16챕터가 절 제목으로 올렸다. "다음 단계"·"넥스트 스텝" 쓰지 않는다. 15·16챕터 |
| preface | 서문 | 원서 pp.1-2 의 절 이름. 노트 `00-preface-getting-started.md` 를 가리킬 때는 "서문 노트" 로 쓰고 첫 등장에 파일 이름을 붙인다(17챕터 선례 — "서문 노트(`00-preface-getting-started.md`)"). "서문 챕터"·"0장"·"0챕터" 쓰지 않는다 — 00 노트에는 원서 챕터 번호가 없고 게이트가 `N장` 을 막는다. 원서 쪽을 가리킬 때는 "원서 서문" 으로 갈라 쓴다. 원서 서문의 범위는 pp.1-2 이고 FSI 절은 Getting Started(원서 p.6)이므로 둘을 섞어 적지 않는다. 00·16·17챕터 |
| resource (learning material) | 자료 | 원서 절 이름 Resources(원서 pp.193-194)는 절 제목에서 원어를 남기고 본문은 "자료" 로 쓴다. "리소스" 쓰지 않는다 — 메모리·파일 같은 자원 쪽으로 읽힌다. 16챕터 |
| SAFE Stack | SAFE Stack | 제품 이름이므로 원어를 유지한다. 서버와 브라우저 양쪽을 F# 로 쓰는 조합이고 원서가 15챕터 각주로 `safe-stack.github.io` 를 건다(원서 p.191). 낱자를 풀어 적거나 "세이프 스택" 으로 음차하지 않는다. 15·16챕터 |
| store | 저장소 | 데이터를 담아 두고 읽기·쓰기 멤버만 밖으로 여는 클래스(`InspectionStore`). 13~15챕터가 이미 이 표기를 쓴다. "리포지터리"·"리포지토리"·"스토어" 쓰지 않는다. 코드를 담은 git 저장소와 낱말이 겹치므로 헷갈릴 자리에서는 "점검 기록 저장소" 처럼 무엇을 담는지 붙여 적는다. 13·14·15·16챕터 |

## 2. 조건부 항목 (검수 지시를 적용할 때만 등재)

16챕터 검수 보고서가 `asyncResult` 를 `taskResult` 로 바로잡으라고 지시했다. 집필자가 그 교체를
적용하면 아래 행도 함께 넣어야 한다. 적용하지 않으면 넣지 않는다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| `taskResult` | `taskResult` | 계산 식 이름은 번역하지 않는다. `Task<Result<'a,'e>>` 를 다루는 복합 계산 식이고 `FsToolkit.ErrorHandling` 이 제공한다(5.2.0 실측 — `let!` 이 `Task<Result<..>>` 를 그대로 받고 결과도 `Task<Result<..>>` 다). 12챕터의 `asyncResult`(`Async<Result<'a,'e>>`)와 짝이며, `asyncResult` 도 `Source` 오버로드로 `Task<Result<..>>` 를 받지만 결과가 `Async<Result<..>>` 이므로 `Task` 를 요구하는 자리에서는 `taskResult` 를 쓴다(실측). 16챕터 |

## 3. 기확정 표기 확인 (표에 넣지 않음)

16챕터가 쓰는 기확정 용어는 다음과 같고 전부 표기를 지키고 있다. 변경 제안 없다.

- `expression`→식, `side effect`→부수 효과, `first-class citizen`→일급 시민,
  `parameter`→매개변수 / `argument`→인자: 16챕터에 나오는 자리마다 표기가 맞다.
- `happy path`→해피 패스(12챕터 선례), `syntactic sugar`→문법 설탕(12챕터 선례): 표의 12챕터
  행이 둘을 그대로 쓴다.
- `dependency injection`→의존성 주입, `service location`→서비스 로케이션, `singleton`→싱글턴:
  표의 14챕터 행과 다음 걸음 절에서 쓴다. 다만 표의 14챕터 행이 서비스 로케이션 쪽을
  "의존성 주입" 으로 뭉갰다 — 표기 문제가 아니라 서술 문제이므로 검수 보고서에서 고치도록 지시했다.
- `function composition`→함수 합성, `function composition operator`→`>>`: 표의 15챕터 행이
  이 낱말을 15챕터에 없는 개념에 붙였다. 표기 자체는 확정된 것을 썼으므로 용어집은 그대로 두고
  서술을 고치도록 지시했다.
- `computation expression`→계산 식, `compound computation expression`→복합 계산 식,
  `effect`→효과, `encapsulation`→캡슐화, `model binding`→모델 바인딩, `View Engine`,
  `middleware`→미들웨어, `static files`→정적 파일, `endpoint`→엔드포인트, `REPL`,
  `F# Interactive (FSI)`→FSI, `breakpoint`→중단점, `guard clause`→가드 절,
  `discriminated union`→판별 유니온, `tail call`→꼬리 호출, `immutability`→불변성: 모두 확정 표기다.
- 원어를 남긴 것들도 원칙대로다 — 원서 절 이름(Summary·Resources·And Finally), 사람 이름
  (Joe Armstrong·Kit Eason·Scott Wlaschin·Sergey Tihon), 자료 제목, 조직·제품 이름
  (Erlang·Slack·GitHub·YouTube·Compositional-IT·xUnit).
- `쓸모`(11·15챕터 선례)를 도입부에서 쓴 것도 선례와 같다.

## 4. 병합자에게

- `preface` 행은 17챕터 후보 파일과 반드시 맞춰야 한다. 16챕터는 지금 "서문 챕터" 로 적혀 있고
  17챕터는 "서문 노트(`00-preface-getting-started.md`)" 로 적혀 있다. 이 파일은 17챕터 쪽
  표기를 택했다. 표기를 뒤집기로 정한다면 16·17챕터 두 노트를 함께 고쳐야 한다.
- `store` 행은 13~15챕터에서 이미 쓰이는데 용어집에 등재되지 않은 채 남은 항목이다. 16챕터가
  처음 올리는 것이 아니므로 병합할 때 13~15챕터 후보 파일과 겹치는지 확인하라(확인한 바로는
  세 파일에 없다).
- `loop` 행은 5챕터("`for` 루프")와 16챕터("반복문")의 낱말이 갈려 있어 올린 것이다. 규칙을
  다르게 정한다면 5챕터 도입부와 16챕터 표의 5챕터 행을 함께 고쳐야 한다.
