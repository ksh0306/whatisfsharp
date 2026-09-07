# 06챕터 용어 후보 (후보 모드 — GLOSSARY.md 미편집)

대상: `docs/ko/06-reading-data-from-file.md`
`docs/ko/GLOSSARY.md`(127항목) 기확정 표기와 대조했다. 아래는 기확정에 없는 항목만 올린다.
`[기확정 변경 제안]` 항목은 없다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| array pattern | 배열 패턴 | 패턴 자리에 적는 `[\| a; b; c \|]`. MS ko 도 "배열 패턴". 패턴에 적은 이름의 개수와 배열 길이가 정확히 같아야 그 케이스가 성립한다. 6챕터 본론 |
| `byref` | `byref` | 번역하지 않는다. FSI 가 .NET 의 `out`/`ref` 매개변수를 보여 줄 때 쓰는 표기(`Decimal.TryParse(s: string, result: byref<decimal>) : bool`). 기확정 `out` 매개변수 항목과 짝이다 |
| culture | 문화권 | MS ko 표기와 일치. 타입 이름 `CultureInfo` 는 번역하지 않는다. `CultureInfo.InvariantCulture` 는 "고정 문화권"(MS ko 표기)이라 부르되 코드에서는 원어 그대로 쓴다 |
| delimiter | 구분자 | 칸을 나누는 문자(`\|`, `,`). 원서의 "delimited text file" 은 "구분자로 나뉜 텍스트 파일" |
| dispose | 정리한다 | `Dispose()` 호출을 가리킨다. MS ko 는 "삭제"이나 이 챕터가 `File.Delete`(파일 삭제)를 함께 다루므로 헷갈려 채택하지 않는다. 커뮤니티 통용 "해제"도 있으나 노트는 "정리"로 고정한다. 명사형 "정리" |
| eager evaluation | 즉시 평가 | 지연 평가의 대비어. 5챕터가 `Array`/`List` 설명에서 이미 쓴다 |
| entry point | 진입점 | MS ko 표기와 일치. `[<EntryPoint>]` 특성 이름은 원어 백틱. F# 6 부터 마지막 코드 파일의 최상위 코드가 암시적 진입점이 된다 |
| exit code | 종료 코드 | `main` 이 마지막에 돌려주는 `int`. 0 이 성공. "반환 코드" 쓰지 않음 |
| fake (test double) | 가짜 | 테스트에서 실제 구현 대신 끼워 넣는 함수·객체. 원서 표기도 fake 이고 식별자는 `fakeDataReader` 다. "스텁(stub)"·"모의(mock)"도 통용되나 노트는 원서를 따라 "가짜"로 고정한다. 명사구는 "가짜 리더", "가짜 데이터". 4챕터 노트와 용어집에 관련 표기가 없어 여기서 정한다. 6챕터 노트는 식별자만 `stubReader` 로 어긋나 있어 `fakeReader` 로 고치도록 지시했다 |
| file handle | 파일 핸들 | 음차 고정. 열린 채 남으면 Windows 에서 같은 파일의 쓰기·삭제가 막힌다 |
| header row | 헤더 줄 | 구분자 텍스트의 첫 줄. MS ko 계열의 "머리글 행" 쓰지 않음 |
| identity function | 항등 함수 | `id : 'a -> 'a`. `fun x -> x` 와 같다. 5챕터가 이미 쓴다. 원서가 "id keyword"라 부른 것은 부정확하다(키워드가 아니라 `FSharp.Core.Operators.id` 함수) |
| `IDisposable` | `IDisposable` | 번역하지 않는다. 제네릭이 아니다 — 원서 p.81 의 `IDisposable<'T>` 는 오기 |
| `IEnumerable<'T>` | `IEnumerable<'T>` | 번역하지 않는다. `seq<'T>` 와 같은 것이다 |
| implicit yield | 암시적 yield | 시퀀스 식 안에서 `yield` 를 적지 않아도 값이 그대로 원소가 되는 것. `yield` 는 번역하지 않는다 |
| lazy evaluation | 지연 평가 | 값을 만드는 시점을 실제로 필요할 때까지 미루는 것. MS ko 는 "지연 계산"도 쓰나 노트는 "지연 평가"로 고정한다. 5챕터가 이미 `Seq` 설명에서 쓰고 있어 그 표기를 따른다. 형용사형은 "지연". `Lazy<'T>` 타입 이름은 번역하지 않는다 |
| partial function | 부분 함수 | 정의역의 일부 입력에서 결과가 정의되지 않는 함수. F# 에서는 그런 입력에 예외를 던진다. 이름만 비슷한 부분 적용(partial application)과는 무관하다. 5챕터가 `List.reduce`/`List.head` 에 이미 이 표기를 쓴다(05-collections.md:263, 273, 411). 6챕터는 `Seq.skip`. 지연 컬렉션에서는 예외가 호출 시점이 아니라 첫 순회 시점에 난다는 점을 비고로 남긴다 |
| sequence | 시퀀스 | 음차 고정. `seq<'T>` 이고 `IEnumerable<'T>` 와 같은 것. 5챕터가 이미 쓴다 |
| sequence expression | 시퀀스 식 | `seq { ... }`. MS ko 표기와 일치하고 기확정 `expression`→식, `computation expression`→계산 식 과 맞물린다. "시퀀스 표현식" 금지. 6챕터 본론 |

## 표기 판단 근거 메모

- `sequence expression`→시퀀스 식: `expression`→식이 기확정이고 `computation expression`→계산 식 이 이미 표에 있다. 같은 계열로 "시퀀스 식".
- `lazy evaluation`→지연 평가: 05챕터 노트가 이미 "지연 평가"를 쓰고 있어(05-collections.md:14, 135) 뒤집지 않는다.
- `partial function`→부분 함수: 05챕터 노트가 같은 표기를 쓰고 있고(05-collections.md:263), 정의도 "가능한 입력 전부에서 동작하지 않는다"로 06과 일치한다. 05 전문가가 다른 표기를 올려도 이 표기가 두 챕터 본문과 이미 맞물려 있다는 점이 근거다.
- `fake`→가짜: 원서가 fake 로 쓰고 식별자도 `fakeDataReader` 다. 4챕터에서 정해진 표기가 없으므로 원서 표기에 맞춘다. 스텁/모의의 구분이 필요해지는 챕터가 오면 그때 세분한다.
- `dispose`→정리: 이 챕터는 `Dispose()` 와 `File.Delete` 가 같은 문단에 나온다. MS ko 의 "삭제"를 쓰면 두 개념이 한국어로 구별되지 않는다.
