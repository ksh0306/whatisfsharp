# 12챕터 용어 후보 (후보 모드)

검수 대상: `docs/ko/12-computation-expressions.md`
`docs/ko/GLOSSARY.md` 는 읽기만 했다. 편집하지 않았다.

선행 등재된 21항목(`batchD-glossary-pre.md`)은 노트가 모두 등재 표기대로 썼다.
어긋난 곳은 한 곳뿐이고 그것은 용어집이 아니라 노트를 고칠 일이다
(`Line of Business (LOB)` — 노트 347줄이 "업무 애플리케이션", 등재 표기는 "업무용 애플리케이션".
검수 보고서에 지시했다).

아래는 노트 본문에 실제로 쓰였으나 등재되지 않은 낱말과, 실측으로 비고를 보강할 만한 기확정 행이다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| computation expression builder | 계산 식 빌더 | [기확정 변경 제안] 표기는 그대로 두고 비고의 멤버 열거에 `Source` 를 넣는다. 현재 열거는 `Bind`·`Return`·`ReturnFrom`·`Zero`·`Combine`·`Delay`·`MergeSources` 인데, `FsToolkit.ErrorHandling` 의 `result` 빌더에는 오른쪽 식을 한 번 걸러 주는 `Source` 오버로드가 있고 12챕터 본론이 이 이름을 쓴다(오류 코드가 계산 식마다 갈리는 이유가 이 멤버다). 근거 — 실측: `result { do! (평범한 unit) }` 이 `error FS0041: 'Source' 메서드와 일치하는 오버로드가 없습니다` 를 낸다. 비고만 고치는 변경이라 앞 챕터 본문 파급은 없다 |
| constant pattern | 상수 패턴 | `match` 케이스에 리터럴이나 `[<Literal>]` 상수를 적는 패턴. 대비어는 변수 패턴이며 둘을 한 문장에서 짝으로 쓴다. MS ko 는 "리터럴 패턴"도 쓰지만 F# 문법 이름을 따라 "상수 패턴" 으로 고정한다. 기확정 `[<Literal>]` 행이 이미 "상수 패턴" 을 쓰고 있어 표기를 확정만 하는 것이다. 12챕터 본론 |
| `do!` | `do!` | [기확정 변경 제안] 표기는 그대로 두고 비고의 오류 코드 서술을 보강한다. 현재 "평범한 `unit` 을 주면 `error FS0001` 이다" 는 계산 식에 따라 갈린다. 근거 — 실측(.NET SDK 10.0.111, `FsToolkit.ErrorHandling, 5.2.0`): `async` 와 손으로 만든 빌더는 `Bind` 첫 매개변수 타입이 어긋나 `error FS0001`, `FsToolkit.ErrorHandling` 의 `result` 는 `Source` 오버로드 해결에서 먼저 걸려 `error FS0041` 이다. "평범한 `unit` 을 주면 `error FS0001`(`async`·직접 만든 빌더) 또는 `error FS0041`(`FsToolkit.ErrorHandling` 의 `result` — `Source` 오버로드 때문)이다" 로 고칠 것을 제안한다. 비고만 고치는 변경이라 파급은 없다 |
| format specifier | 서식 지정자 | [기확정 변경 제안] 표기는 그대로 두고 비고에 한 절을 덧붙인다 — `%A` 에는 폭 지정이 먹지 않는다. 근거 — 실측: `printfn "[%-9A]" (Some 60)` 도 `printfn "[%9A]" (Some 60)` 도 `[Some 60]` 을 낸다. 폭을 맞추려면 `sprintf "%A"` 로 문자열을 만든 뒤 `%-9s` 로 찍는다. 12챕터가 실제로 이 우회를 쓰고 있고 앞으로도 `%A` 로 표를 찍는 자리마다 되풀이될 문제다. `%A` 로 찍은 `None` 은 `None` 이고 `<null>` 이 아니라는 것도 같은 자리에 적어 두면 좋다(실측). 비고만 고치는 변경이라 파급은 없다 |
| helper function | 도우미 함수 | 라이브러리가 손질용으로 얹어 준 작은 함수(`AsyncResult.requireSome`·`Result.requireTrue`·`Result.mapError`). 기확정 `asyncResult` 행이 이미 "도우미 함수" 로 쓰고 있어 표기를 확정만 하는 것이다. "헬퍼"·"보조 함수"·"유틸 함수" 쓰지 않는다. 12챕터 본론 |
| overload | 오버로드 | 같은 이름에 시그니처가 다른 멤버가 여럿 있는 것. 명사로 "오버로드", 컴파일러가 그중 하나를 고르는 일은 "오버로드 해결" 로 쓴다. 기확정 `operator overloading`(연산자 오버로딩)과는 다른 자리다 — 그쪽은 타입에 연산자를 정의하는 일이고 이쪽은 멤버 시그니처가 여러 개인 상태다. "다중 정의"·"과부하" 쓰지 않는다. 10챕터의 멤버 서술과 12챕터의 `Source` 서술에서 쓰인다 |
| `parallelAsyncValidation` | `parallelAsyncValidation` | 계산 식 이름은 소문자 값 이름이라 번역하지 않는다. `FsToolkit.ErrorHandling` 이 제공하고(5.2.0 에서 이름 해석 실측 확인) `and!` 로 이은 오른쪽 식들을 진짜 병렬로 돌린다. `validation` 의 `and!` 는 병렬이 아니라 의존이 없어지는 것이라는 서술 뒤에 대비로 붙는 이름이다(8챕터 721·836줄, 12챕터 593줄이 이미 이 이름을 쓴다). 8·12챕터 |
| variable pattern | 변수 패턴 | 이름 하나를 적어 어떤 값이든 받아 그 이름에 묶는 패턴. 상수 패턴과 짝으로 쓴다. `[<Literal>]` 을 빼면 대문자 이름이 상수 패턴이 아니라 변수 패턴이 되어 모든 입력을 삼킨다는 12챕터 본론의 요점이 이 낱말에 걸려 있다. "변수형 패턴"·"바인딩 패턴" 쓰지 않는다. 12챕터 본론 |
