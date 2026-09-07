# 07 - 액티브 패턴 (원서 pp.90-102)

> 지금까지 패턴 자리에 쓸 수 있는 것은 언어가 미리 정해 둔 패턴뿐이었다. 판별 유니온의 케이스, 튜플, 리터럴, 리스트 모양, 와일드카드 정도다. 이 챕터는 그 목록에 직접 만든 패턴을 추가하는 방법을 다룬다. 액티브 패턴(active pattern)은 함수를 패턴 자리에서 쓸 수 있는 이름으로 바꿔 주는 장치다. "문자열이 연도로 읽히는가", "이 요청이 느린가" 같은 판정을 `match` 식의 케이스 식별자처럼 보이게 만들 수 있고, 판정 결과로 얻은 값을 그 자리에서 바로 바인딩할 수 있다. 종류가 네 가지이고 각각 반환 타입 규칙이 다르므로, 이 챕터의 목표는 네 종류를 구분해 두는 것이다. 다음 챕터의 검증 코드가 여기서 익힌 부분 액티브 패턴 위에 그대로 올라간다.

## Setting Up — 준비 (원서 p.90)

- 이 챕터의 코드는 전부 스크립트 파일(`.fsx`) 하나와 FSI 로 끝난다. 프로젝트를 만들 필요가 없다.
- 1챕터 노트 끝에서 `(|OnActivePlan|_|)` 을 한 번 맛보기로 썼다. 그때는 "필터를 케이스 식별자처럼 쓸 수 있다"는 감각만 얻고 넘어갔다. 여기서는 그 문법이 왜 그렇게 생겼는지와 나머지 세 종류를 다룬다. 맛보기 예제는 다시 쓰지 않는다.

## 네 종류를 먼저 구분한다 (원서 pp.90-98)

원서는 종류를 하나씩 순서대로 소개하지만, 먼저 전체 지도를 보아 두면 덜 헷갈린다. 액티브 패턴의 이름은 항상 `(|` 와 `|)` 사이에 들어간다. 이 괄호 짝을 바나나 클립(banana clips)이라 부른다.

| 종류 | 이름 형태 | 반환 타입 | 매개변수 추가 | 실패할 수 있는가 |
|---|---|---|---|---|
| 부분 패턴(partial) | `(\|Name\|_\|)` | `'a option`(F# 9 부터 `bool` 도) | 가능(붙이면 아래 종류가 된다) | 그렇다 |
| 매개변수 있는 부분 패턴(parameterized partial) | `(\|Name\|_\|) arg` | `'a option`(F# 9 부터 `bool` 도) | 이미 붙어 있다 | 그렇다 |
| 다중 케이스 패턴(multi-case) | `(\|A\|B\|C\|)` | `Choice<...>` | 불가 | 아니다 |
| 단일 케이스 패턴(single-case) | `(\|Name\|)` | 값 그대로 | 가능(별도 이름 없음) | 아니다 |

- 이름 끝에 `_|` 가 붙으면 부분 액티브 패턴이다. 이름 목록의 마지막 자리에 와일드카드가 있다는 뜻이고, "입력 중 일부만 이 패턴에 걸린다"는 선언이다. 그래서 반환 타입이 `option` 이다(F# 9 부터는 `bool` 도 되고, `[<return: Struct>]` 를 붙이면 `voption` 이다. 아래에서 짚는다). 이름이 비슷한 부분 적용(partial application)과는 관계가 없다.
- `_|` 가 없으면 모든 입력이 적어 둔 케이스 중 하나로 반드시 떨어진다. 그래서 `option` 으로 감싸지 않고 값을 그대로 반환한다.
- 케이스 식별자는 대문자로 시작해야 한다. 소문자로 쓰면 오류 FS0623(`활성 패턴 케이스 식별자는 대문자로 시작해야 합니다`)이 난다.
- 네 종류라는 이름은 원서와 공식 문서가 쓰는 관용 분류다. 실제 축은 두 개다. 하나는 실패할 수 있는가(이름에 `_|` 가 있는가)이고, 다른 하나는 케이스가 하나인가 여럿인가다. 매개변수는 두 축 위에 얹는 선택지이고 부분 패턴과 단일 케이스 패턴 양쪽에 붙는다.
- 두 축에 매개변수까지 격자로 놓으면 막힌 칸이 두 개다. 부분 패턴과 다중 케이스 패턴을 섞은 `(|Red|Black|_|)` 는 문법 자체가 없어 오류 FS3872 로 거부되고, 매개변수를 붙인 다중 케이스 패턴은 정의는 통과하지만 쓰는 순간 오류 FS0722 가 난다. 그래서 골라 쓸 조합이 네 이름에 거의 다 들어오고, 따로 이름이 붙지 않은 것은 매개변수 있는 단일 케이스 패턴뿐이다.

```fsharp
// 오류 FS3872: Multi-case partial active patterns are not supported.
// 오류는 이름 자리에서 난다. 본문을 어떻게 쓰든 이 이름 형태는 성립하지 않는다.
let (|Red|Black|_|) (n: int) =
    if n % 2 = 0 then Some Red else None
```

## Partial Active Patterns — 부분 액티브 패턴 (원서 pp.90-92)

- 입력 중 일부만 성공하는 판정에 쓴다. 반환 타입은 `option` 이고, 성공 케이스에서 값을 담아 보내면 패턴을 쓰는 쪽에서 그 값을 바인딩할 수 있다.
- 파싱과 검증이 대표적인 용도다. `TryParse` 계열 메서드의 튜플 반환을 `option` 으로 바꿔 패턴 자리로 옮기는 일이 가장 잦다.
- 값이 필요 없고 성공/실패만 알면 될 때는 `Some ()` 을 반환한다. 이때 시그니처는 `unit option` 이 된다.

먼저 액티브 패턴 없이 평범한 함수로 써 본다. 도서관 서지 데이터에서 출간 연도 칸을 읽는 상황이다.

```fsharp id=07-catalog
// 이 단위가 보여주는 것: 부분 액티브 패턴으로 파싱·검증을 패턴 자리로 옮기기
open System

// string -> int option
let tryPublishedYear (input: string) =
    match Int32.TryParse input with
    | true, year when year >= 1450 && year <= 2026 -> Some year
    | _ -> None

printfn "%A" (tryPublishedYear "1998")     // Some 1998
printfn "%A" (tryPublishedYear "간행연도미상")   // None
printfn "%A" (tryPublishedYear "1200")     // None
```

함수로도 잘 돌아간다. 다만 이 판정을 `match` 식의 케이스로는 쓸 수 없다. 가드 절에서 호출하는 것이 전부이고, 성공했을 때 얻은 연도 값을 케이스 안으로 끌어오려면 한 번 더 벗겨내야 한다. 이름만 바나나 클립으로 감싸면 사정이 달라진다.

```fsharp id=07-catalog
// string -> int option — 본문은 위 함수와 같고 이름만 (| ... |_|) 로 감쌌다
let (|PublishedYear|_|) (input: string) =
    match Int32.TryParse input with
    | true, year when year >= 1450 && year <= 2026 -> Some year
    | _ -> None
```

- 시그니처는 `tryPublishedYear` 와 완전히 같다. 액티브 패턴은 특별한 종류의 값이 아니라 이름 형태가 특별한 함수다.
- 달라지는 것은 이름을 쓸 수 있는 자리다. `PublishedYear y` 를 패턴으로 적을 수 있고, `Some` 안에 담아 보낸 값이 `y` 에 바인딩된다.

```fsharp id=07-catalog
// string -> string
let shelve (raw: string) =
    match raw with
    | PublishedYear y when y >= 2000 -> $"%d{y}년 — 개가 열람실"
    | PublishedYear y -> $"%d{y}년 — 보존 서고"
    | _ -> $"'%s{raw}' — 연도 확인 필요"

[ "2014"; "1998"; "삼국사기" ] |> List.iter (shelve >> printfn "%s")
// 2014년 — 개가 열람실
// 1998년 — 보존 서고
// '삼국사기' — 연도 확인 필요
```

- 같은 액티브 패턴을 두 케이스에서 쓰면서 한쪽에만 가드 절을 걸었다. 이렇게 판정과 분기를 나눠 적을 수 있는 것이 함수판과의 실질적 차이다.
- 부분 액티브 패턴만으로 `match` 식을 구성하면 마지막 `| _ ->` 를 반드시 적어야 한다. 컴파일러는 이 패턴이 실패할 수 있다는 것을 이름의 `_|` 로 알고 있으므로, 빼면 경고 FS0025 가 난다.

값이 필요 없는 경우도 있다. 그때는 `unit` 을 `Some` 에 담는다.

```fsharp id=07-catalog
// string -> unit option — 성공/실패만 알려 준다
let (|Blank|_|) (input: string) =
    if String.IsNullOrWhiteSpace input then Some () else None

// string -> bool
let hasYear (raw: string) =
    match raw with
    | Blank -> false
    | PublishedYear _ -> true
    | _ -> false

printfn "%b %b %b" (hasYear "  ") (hasYear "1998") (hasYear "미상")   // false true false
```

- `Some ()` 을 반환하는 패턴은 담아 보낼 값이 없으므로 패턴 자리에 이름만 적는다. 실리는 값이 `()` 하나여서 `Blank ()` 나 `Blank _` 도 통과하지만, 이름만 적는 쪽이 관용적이다.
- F# 9 부터는 `unit option` 대신 `bool` 을 반환해도 된다. `if ... then Some () else None` 을 그대로 조건식으로 줄일 수 있다. 원서는 `Some ()` 판으로 설명한다. 두 형태 모두 유효하다.
- `[<return: Struct>]` 를 붙여 `option` 대신 `voption` 을 반환하는 판도 F# 6 부터 쓸 수 있다. 힙 할당을 피하는 최적화이고 종류가 늘어나는 것은 아니어서 이 노트는 다루지 않는다.

```fsharp id=07-catalog
// string -> bool — bool 을 반환하는 부분 액티브 패턴. 값은 바인딩할 수 없다
let (|Numeric|_|) (input: string) =
    input.Length > 0 && input |> Seq.forall Char.IsDigit

printfn "%b %b" (match "1998" with Numeric -> true | _ -> false)
                (match "199a" with Numeric -> true | _ -> false)   // true false
```

- `bool` 을 반환하면 담아 보낼 값이 아예 없으므로 패턴 자리에 인자를 적을 수 없다. `Numeric x` 로 적으면 오류 FS3868(`이 활성 패턴에는 인수가 필요하지 않습니다`)이 난다. `unit option` 판과 달리 `Numeric _` 도 받아 주지 않는다.

액티브 패턴이 그냥 함수라는 사실은 실제로 확인할 수 있다. 이름을 바나나 클립째로 적으면 일반 함수처럼 호출하거나 고차 함수에 넘길 수 있다.

```fsharp id=07-catalog
// 패턴 자리 밖에서 함수로 쓴다
printfn "%A" ((|PublishedYear|_|) "1998")                        // Some 1998
printfn "%A" ([ "1998"; "미상"; "2014" ] |> List.choose (|PublishedYear|_|))
// [1998; 2014]
```

- `List.choose` 는 `'a -> 'b option` 을 받는다. 부분 액티브 패턴의 시그니처가 정확히 그 모양이므로 그대로 들어맞는다.
- 반대로 말하면, 부분 액티브 패턴 하나를 정의해 두면 패턴 자리와 파이프라인 양쪽에서 쓸 수 있다. 함수판을 따로 두는 대신 액티브 패턴 하나로 통일할 수 있다는 뜻이다.

## Parameterized Partial Active Patterns — 매개변수 있는 부분 액티브 패턴 (원서 pp.92-96)

- 판정 기준을 패턴을 쓰는 쪽에서 정하고 싶을 때 매개변수를 추가한다. 문법적으로 특별한 것은 없다. 매개변수를 더 받는 부분 액티브 패턴이다.
- 규칙은 하나뿐이다. 검사할 값이 항상 마지막 매개변수여야 한다. 앞쪽 매개변수는 패턴 자리에서 이름 뒤에 인자로 적는다.
- 패턴끼리 조합하는 연산자가 있다. `&` 는 둘 다 만족, `|` 는 하나라도 만족이다. 부정 연산자는 없다.

등산로 데이터에 난이도를 매기는 예다. 기준값을 패턴 쪽에서 지정한다.

```fsharp id=07-trail
// 이 단위가 보여주는 것: 매개변수 있는 부분 액티브 패턴과 패턴 조합 연산자
type Trail = { Name: string; DistanceKm: float; AscentM: int }

// float -> Trail -> unit option
let (|LongerThan|_|) limit (trail: Trail) =
    if trail.DistanceKm > limit then Some () else None

// int -> Trail -> unit option
let (|SteeperThan|_|) limit (trail: Trail) =
    if trail.AscentM > limit then Some () else None
```

- 시그니처를 보면 기준값이 앞, 검사 대상이 뒤다. 패턴 자리에 적은 `LongerThan 12.0` 은 컴파일러가 `(|LongerThan|_|) 12.0 <검사값>` 호출로 풀어낸다. `match` 식이 검사하는 값이 마지막 인자로 붙기 때문에 검사할 값을 마지막 매개변수에 두어야 한다.
- 매개변수 타입은 자동 일반화되지 않았다. `trail.DistanceKm` 과 비교하므로 `limit` 이 `float` 로, `trail.AscentM` 과 비교하므로 `int` 로 각각 확정되었다.

부정 연산자가 없다는 제약이 여기서 드러난다. "경사가 완만하다"는 조건이 필요하면 반대 판정을 하나 더 정의해야 한다.

```fsharp id=07-trail
// int -> Trail -> unit option — & 와 | 는 있지만 not 은 없어서 반대 패턴을 따로 만든다
let (|GentlerThan|_|) limit (trail: Trail) =
    if trail.AscentM <= limit then Some () else None

// Trail -> string
let grade trail =
    match trail with
    | LongerThan 12.0 & SteeperThan 900 -> "상급"
    | LongerThan 12.0 | SteeperThan 500 -> "중급"
    | GentlerThan 300 -> "가족 코스"
    | _ -> "초급"

let trails =
    [ { Name = "지리산 종주"; DistanceKm = 25.4; AscentM = 1650 }
      { Name = "관악산 사당길"; DistanceKm = 4.6; AscentM = 540 }
      { Name = "북한산 둘레길"; DistanceKm = 8.2; AscentM = 210 }
      { Name = "청계산 매봉"; DistanceKm = 5.3; AscentM = 380 } ]

trails |> List.iter (fun t -> printfn "%s: %s" t.Name (grade t))
// 지리산 종주: 상급
// 관악산 사당길: 중급
// 북한산 둘레길: 가족 코스
// 청계산 매봉: 초급
```

- `&` 와 `|` 는 패턴 전용 연산자다. `&&`, `||`, `not` 같은 일반 논리 연산자는 식에서 쓰는 것이고 패턴 자리에서는 쓸 수 없다.
- 가드 절에는 이 제약이 없다. `| t when t.AscentM <= 300 -> ...` 처럼 쓰면 일반 논리 연산자를 그대로 쓸 수 있다. 원서도 이 점을 짚으면서 액티브 패턴 판과 가드 절 판을 나란히 보여 준다.
- 원서는 FizzBuzz 와 윤년 판정을 예로 들어 조건 조합이 늘어날 때를 실험한다. 조건이 셋이 되면 `&` 조합을 일곱 줄 적어야 하고, 그중 하나를 빠뜨렸는지 눈으로 확인하기 어려워진다. 액티브 패턴이 항상 최선은 아니라는 결론이 이 실험의 요점이다.
- 원서는 이 실험 뒤에 액티브 패턴을 떠나 `List.map`/`List.reduce` 로 FizzBuzz 를 다시 쓰고 짝 목록을 매개변수로 빼는 데까지 간다. 액티브 패턴 이야기가 아니고 `List.reduce` 는 5챕터에서 이미 다뤘으므로 이 노트는 옮기지 않는다.

경우의 수가 늘어날 때 원서가 제시하는 우회로 중 하나는 매개변수를 리스트로 받는 것이다. 조합마다 패턴을 나열하는 대신 목록 하나로 표현한다.

```fsharp id=07-trail
// string list -> Trail -> unit option — 매개변수는 리스트여도 된다
let (|OneOf|_|) (names: string list) (trail: Trail) =
    if names |> List.contains trail.Name then Some () else None

// Trail -> string
let permit trail =
    match trail with
    | OneOf [ "지리산 종주"; "설악산 공룡능선" ] -> "입산 신고 필요"
    | _ -> "자유 입산"

trails |> List.iter (fun t -> printfn "%s: %s" t.Name (permit t))
// 지리산 종주: 입산 신고 필요
// 관악산 사당길: 자유 입산
// 북한산 둘레길: 자유 입산
// 청계산 매봉: 자유 입산
```

매개변수 있는 부분 액티브 패턴도 값을 반환할 수 있다. `unit option` 만 쓰는 것이 아니다. 문자열에서 단위를 떼어내는 예를 보면 매개변수와 반환값을 함께 쓰는 모양이 드러난다.

```fsharp id=07-trail
// string -> string -> string option — 접미사가 붙어 있으면 떼어낸 앞부분을 돌려준다
let (|EndingWith|_|) (suffix: string) (input: string) =
    if input.EndsWith suffix
    then Some (input.Substring(0, input.Length - suffix.Length))
    else None

// string -> string
let readPace input =
    match input with
    | EndingWith "km" stem -> $"거리 %s{stem}킬로미터"
    | EndingWith "m" stem -> $"고도 %s{stem}미터"
    | _ -> "단위를 읽을 수 없다"

printfn "%s / %s / %s" (readPace "25km") (readPace "1650m") (readPace "빠름")
// 거리 25킬로미터 / 고도 1650미터 / 단위를 읽을 수 없다
```

- 패턴 자리에 이름, 인자, 바인딩할 변수가 차례로 온다. `EndingWith "km" stem` 에서 `"km"` 은 인자이고 `stem` 은 결과를 받는 이름이다.
- 케이스 순서가 결과를 바꾼다. `"25km"` 는 `"m"` 으로도 끝나므로, 두 케이스를 뒤집으면 `"25k"` 가 고도로 읽힌다. 첫 매칭이 이긴다는 패턴 매칭의 기본 규칙은 액티브 패턴에도 그대로 통한다.
- `|` 로 묶은 두 패턴은 같은 변수 집합을 바인딩해야 한다. `EndingWith "km" x | EndingWith "m" x` 는 되지만 양쪽이 서로 다른 이름을 바인딩하면 오류 FS0018 이 난다.

매개변수는 부분 액티브 패턴과 단일 케이스 액티브 패턴에만 붙일 수 있다. 다중 케이스 패턴에 붙이면 정의는 통과하지만 쓰는 순간 오류 FS0722 가 난다. 원서도 이 조합이 "컴파일은 되는데 실제로는 쓸 수 없다"고 적어 두었다.

```fsharp
// 정의는 통과한다
let (|Above|Below|) threshold value =
    if value >= threshold then Above else Below

// 쓰는 순간 오류 FS0722: 하나의 결과를 반환하는 활성 패턴만 인수를 사용할 수 있습니다
let check limit n =
    match n with
    | Above limit -> "위"
    | Below limit -> "아래"
```

## Multi-Case Active Patterns — 다중 케이스 액티브 패턴 (원서 pp.96-97)

- 입력을 정해진 몇 가지 중 하나로 반드시 분류할 때 쓴다. 실패가 없으므로 `option` 을 쓰지 않고, 이름에 `_|` 도 붙지 않는다.
- 케이스를 전부 적으면 `match` 식이 빠짐없는 패턴 매칭이 되어 `| _ ->` 가 필요 없다. 하나라도 빠뜨리면 경고 FS0025 가 난다.
- 케이스는 최대 일곱 개다. 여덟 개를 적으면 오류 FS0265(`활성 패턴은 7개가 넘는 가능성을 반환할 수 없습니다`)가 난다.
- 실제 반환 타입은 `Choice` 다. 이 점은 시그니처를 실측해 보면 바로 보인다.
- 상한이 7개인 것은 `FSharp.Core` 에 `Choice<'T1,'T2>` 부터 `Choice<'T1,...,'T7>` 까지만 있기 때문이다. 담을 그릇이 없어서 생긴 한계다.

라디오 편성표를 짜면서 음원을 길이로 분류하는 예다.

```fsharp id=07-playlist
// 이 단위가 보여주는 것: 다중 케이스 액티브 패턴과 Choice 반환
type Track = { Title: string; Seconds: int }

// Track -> Choice<unit,unit,unit>
let (|Short|Standard|Extended|) (track: Track) =
    if track.Seconds < 150 then Short
    elif track.Seconds <= 420 then Standard
    else Extended

// Track -> string — 세 케이스를 다 적었으므로 와일드카드가 필요 없다
let slot track =
    match track with
    | Short -> "간주 구간"
    | Standard -> "정규 편성"
    | Extended -> "심야 편성"
```

- 시그니처가 `Choice<unit,unit,unit>` 이다. 케이스 세 개가 각각 값을 싣지 않으므로 세 자리 모두 `unit` 이다. `Short`, `Standard`, `Extended` 는 판별 유니온의 케이스가 아니라 이 액티브 패턴이 정의한 이름이다.
- 이 케이스 식별자는 패턴 자리에서만 쓸 수 있다. 정의 밖에서 `let x = Short` 처럼 값으로 쓰려 하면 오류 FS0039 가 난다. 바나나 클립째로 적어 `(|Short|Standard|Extended|) t` 로 호출하는 것은 되지만, 케이스 식별자 하나만 값으로 꺼내 쓸 수는 없다.
- 다만 그 패턴 자리 안에서는 판별 유니온 케이스와 이름 공간을 함께 쓴다. `Short` 케이스가 있는 판별 유니온이 이미 열려 있으면 뒤에 정의한 액티브 패턴이 그것을 가려서, 원래 판별 유니온을 매칭하던 곳에서 타입 불일치 오류 FS0001 이 난다. 정의 순서를 뒤집어도 마찬가지다. 이름을 겹치지 않게 짓는 편이 안전하다.
- 본문의 마지막 `else Extended` 가 남은 입력 전부를 받는다. 어느 케이스도 반환하지 않는 경로를 남기면 정의 본문의 `match` 식에서 경고 FS0025 가 나고, 실제로 그 경로를 타는 입력이 들어오면 실행 시점에 `MatchFailureException` 을 던진다. 컴파일이 막아 주지 않으므로 정의 안에서 모든 입력을 처리해 줘야 한다.
- 출력으로 쓰지 않는 케이스를 이름에 넣으면 그 케이스의 타입을 추론할 근거가 없어 정의 자리에서 오류 FS1210 이 난다. `: Choice<unit,unit,unit>` 처럼 반환 타입 주석을 달면 통과하지만, 그때는 쓰는 쪽에서 영원히 나오지 않는 케이스까지 적어야 한다. 실제로 반환하는 케이스만 이름에 적는 것이 맞다.

케이스가 값을 실을 수도 있다. 원서에는 없는 형태이지만 쓸 곳이 있다. 같은 입력을 서로 다른 단위로 꺼내 주는 식이다.

```fsharp id=07-playlist
// Track -> Choice<int,float> — 케이스마다 다른 타입의 값을 실을 수 있다
let (|Seconds|Minutes|) (track: Track) =
    if track.Seconds < 60 then Seconds track.Seconds
    else Minutes (float track.Seconds / 60.0)

// Track -> string
let runtime track =
    match track with
    | Seconds s -> $"%d{s}초"
    | Minutes m -> $"%.1f{m}분"

let playlist =
    [ { Title = "새벽 인트로"; Seconds = 48 }
      { Title = "빗소리"; Seconds = 132 }
      { Title = "네 번째 정류장"; Seconds = 305 }
      { Title = "긴 배웅"; Seconds = 610 } ]

playlist |> List.iter (fun t -> printfn "%s: %s / %s" t.Title (runtime t) (slot t))
// 새벽 인트로: 48초 / 간주 구간
// 빗소리: 2.2분 / 간주 구간
// 네 번째 정류장: 5.1분 / 정규 편성
// 긴 배웅: 10.2분 / 심야 편성
```

- 케이스 식별자 `Seconds` 는 `Track.Seconds` 필드와 이름이 같지만 가려지지 않는다. 레코드 필드와 케이스 식별자는 서로 다른 이름 공간이다. 앞에서 말한 주의는 판별 유니온 케이스와 겹칠 때의 이야기다.

케이스 일곱 개까지가 상한이라는 것도 확인해 둔다. 요일은 정확히 일곱 개라 상한에 딱 맞는다.

```fsharp id=07-playlist
open System

// DayOfWeek -> Choice<unit,unit,unit,unit,unit,unit,unit> — 상한인 7개
let (|Mon|Tue|Wed|Thu|Fri|Sat|Sun|) (d: DayOfWeek) =
    match d with
    | DayOfWeek.Monday -> Mon
    | DayOfWeek.Tuesday -> Tue
    | DayOfWeek.Wednesday -> Wed
    | DayOfWeek.Thursday -> Thu
    | DayOfWeek.Friday -> Fri
    | DayOfWeek.Saturday -> Sat
    | _ -> Sun

// DayOfWeek -> string — 액티브 패턴의 케이스도 | 로 묶을 수 있다
let studioDay (d: DayOfWeek) =
    match d with
    | Sat | Sun -> "휴무"
    | Wed -> "생방송"
    | _ -> "녹음"

[ DayOfWeek.Wednesday; DayOfWeek.Sunday; DayOfWeek.Monday ]
|> List.iter (studioDay >> printfn "%s")
// 생방송
// 휴무
// 녹음
```

- 마지막 `| _ -> Sun` 은 `DayOfWeek.Sunday` 로 바꿔 적어도 된다. 다만 그렇게 하면 경고 FS0104 가 난다. 열거형은 선언된 이름 밖의 값도 담을 수 있어서, 일곱 이름을 다 적어도 컴파일러는 값 범위가 닫혔다고 보지 않는다. 판별 유니온이라면 이 문제가 없다.
- 쓰는 쪽에서는 반대로 케이스 일부만 적고 나머지를 `| _ ->` 로 묶어도 된다. 위의 `studioDay` 가 그런 예다.

```fsharp
// 오류 FS0265: 활성 패턴은 7개가 넘는 가능성을 반환할 수 없습니다
let (|A|B|C|D|E|F|G|H|) n =
    match n with
    | 1 -> A | 2 -> B | 3 -> C | 4 -> D
    | 5 -> E | 6 -> F | 7 -> G | _ -> H
```

## Single-Case Active Patterns — 단일 케이스 액티브 패턴 (원서 pp.97-98)

- 케이스가 하나뿐이고 실패하지 않는다. 입력을 다른 형태로 바꿔 보여 주는 용도다. 판정이 아니라 변환에 가깝다.
- 반환 타입은 `option` 도 `Choice` 도 아니고 변환 결과 타입 그대로다. 항상 성공하므로 감쌀 것이 없다.
- 같은 입력을 여러 각도에서 분해해 두면, 규칙을 요구사항 문장에 가깝게 적을 수 있다.

검색어 문자열을 다루는 예다. 규칙은 두 개다. 공백을 정리한 뒤 두 글자 이상이어야 하고, 낱말은 네 개까지만 받는다.

```fsharp id=07-query
// 이 단위가 보여주는 것: 단일 케이스 액티브 패턴으로 입력을 여러 각도로 분해하기
open System

// string -> string
let (|Normalized|) (input: string) = input.Trim().ToLowerInvariant()

// string -> string list
let (|Tokens|) (input: string) =
    input.Split(' ', StringSplitOptions.RemoveEmptyEntries) |> List.ofArray

printfn "'%s'" (match "  Active  Pattern  " with Normalized q -> q)
// 'active  pattern'
printfn "%A" (match "  Active  Pattern  " with Tokens ts -> ts)
// ["Active"; "Pattern"]
```

- 같은 문자열 하나를 두 방향으로 열어 보았다. 하나는 정리된 문자열, 하나는 낱말 리스트다. 이것이 단일 케이스 패턴의 쓸모다.
- 단일 케이스 패턴은 항상 성공하므로 케이스 하나만으로 `match` 식이 완결된다. `| _ ->` 없이 `| Normalized q -> ...` 한 줄로 끝난다.

두 규칙을 판정 하나로 묶는다. 결과를 튜플로 돌려줄 수도 있지만, 판별 유니온을 쓰면 실패 이유가 없는 경우에 빈 문자열을 채우는 군더더기가 사라진다. 원서도 실제 코드라면 판별 유니온이 낫다고 적어 두었다.

```fsharp id=07-query
type Verdict =
    | Accepted of query: string
    | Rejected of reason: string

// string -> Verdict — 단일 케이스 패턴 안에서 다른 단일 케이스 패턴을 쓴다
let (|Checked|) (input: string) =
    match input with
    | Normalized q when q.Length < 2 -> Rejected "질의는 두 글자 이상이어야 한다"
    | Tokens ts when ts.Length > 4 -> Rejected "낱말은 네 개까지만 받는다"
    | Normalized q -> Accepted q
```

- 앞의 두 케이스는 가드 절이 붙어 실패할 수 있으므로, 가드 절이 없는 `| Normalized q ->` 케이스가 마지막에 있어야 빠짐없는 패턴 매칭이 된다.
- 규칙 판정 로직이 액티브 패턴 안에 들어가느냐 밖에 있느냐는 취향이다. `Normalized` 는 변환만 하고 길이 판정은 밖의 가드 절에서 한다. `Tokens` 도 같은 구조다. 판정까지 안에 넣으면 `(|ShortQuery|_|)` 같은 부분 액티브 패턴이 된다.

`Checked` 를 쓰는 쪽에서는 액티브 패턴이 만들어 준 값을 다시 패턴으로 분해한다.

```fsharp id=07-query
// string -> Result<string, string>
let search input =
    match input with
    | Checked (Accepted q) -> Ok q
    | Checked (Rejected why) -> Error why

[ "  Active Pattern  "; " F "; "액티브 패턴 이 다섯 낱말 이다" ]
|> List.iter (fun q ->
    match search q with
    | Ok query -> printfn "검색 실행: '%s'" query
    | Error why -> printfn "거절: %s" why)
// 검색 실행: 'active pattern'
// 거절: 질의는 두 글자 이상이어야 한다
// 거절: 낱말은 네 개까지만 받는다
```

- `Checked (Accepted q)` 처럼 액티브 패턴 안에 패턴을 중첩할 수 있다. `Checked` 가 만들어 낸 `Verdict` 값에 다시 판별 유니온 패턴을 적용한 것이다.
- `Accepted`/`Rejected` 두 케이스가 `Verdict` 를 다 덮으므로 여기도 `| _ ->` 가 필요 없다.
- 단일 케이스 패턴이 돌려준 값에는 이름 바인딩만 걸 수 있는 것이 아니다. 리터럴이든 판별 유니온 케이스든 어떤 패턴이라도 그 자리에 적을 수 있다.
- 매개변수는 단일 케이스 패턴에도 붙일 수 있다. `let (|RoundedTo|) (digits: int) (x: float) = Math.Round(x, digits)` 는 `int -> float -> float` 이고, 패턴 자리에서 `RoundedTo 2 v` 로 쓴다.

## Using Active Patterns in a Practical Example — 실전 예제 (원서 pp.99-102)

- 원서는 축구 스코어 예측 게임의 점수 계산을 예로 삼아 네 종류를 한자리에 모은다. 이 노트는 같은 구성을 웹 서버 접근 로그의 위험도 채점으로 옮긴다.
- 요구사항은 세 가지다. 로그 한 줄을 레코드로 파싱하고, 상태 코드를 부류로 나누고, 응답 시간과 경로에 따라 위험 점수를 매긴다.
- 파싱은 부분 패턴, 상태 코드 분류는 다중 케이스 패턴, 임계값 비교는 매개변수 있는 부분 패턴, 경로 분해는 단일 케이스 패턴이 각각 맡는다.

먼저 로그 한 줄을 레코드로 바꾸는 부분 액티브 패턴이다. 형식이 맞지 않는 줄이 섞여 들어오므로 실패할 수 있고, 따라서 `option` 을 반환한다.

```fsharp id=07-accesslog
// 이 단위가 보여주는 것: 네 종류를 한 문제에 함께 쓰기
open System
open System.Text.RegularExpressions

type Request = { Verb: string; Path: string; Status: int; Ms: int }

// string -> Request option
let (|AccessLine|_|) (line: string) =
    let m = Regex.Match(line, @"^(GET|POST|PUT|DELETE) (\S+) (\d{3}) (\d+)ms$")
    if m.Success then
        Some { Verb = m.Groups[1].Value
               Path = m.Groups[2].Value
               Status = int m.Groups[3].Value
               Ms = int m.Groups[4].Value }
    else None

printfn "%A" ((|AccessLine|_|) "GET /api/tracks 200 84ms")
// Some { Verb = "GET"
//        Path = "/api/tracks"
//        Status = 200
//        Ms = 84 }
printfn "%A" ((|AccessLine|_|) "PATCH /api/tracks 200 30ms")   // None
```

- 정규식으로 판정과 추출을 한 번에 하고, 성공했을 때만 값을 담아 보낸다. 다음 챕터에서 검증을 다룰 때 이 형태를 정규식 패턴 자체를 매개변수로 받는 꼴로 일반화해 다시 쓴다.
- 실패 가능성이 있는 파싱을 부분 액티브 패턴으로 감싸 두면, 쓰는 쪽에서 "파싱에 성공한 경우"와 "형식이 틀린 경우"를 `match` 식의 두 케이스로 나란히 적을 수 있다.

상태 코드는 반드시 넷 중 하나로 떨어진다. 실패가 없으므로 다중 케이스 패턴이다.

```fsharp id=07-accesslog
// Request -> Choice<unit,unit,unit,unit>
let (|Succeeded|Redirected|ClientError|ServerError|) req =
    if req.Status < 300 then Succeeded
    elif req.Status < 400 then Redirected
    elif req.Status < 500 then ClientError
    else ServerError

// Request -> int
let statusScore req =
    match req with
    | Succeeded -> 0
    | Redirected -> 1
    | ClientError -> 5
    | ServerError -> 40
```

임계값 비교는 기준을 쓰는 쪽에서 정하는 편이 낫다. 매개변수 있는 부분 액티브 패턴이다.

```fsharp id=07-accesslog
// int -> Request -> unit option
let (|SlowerThan|_|) limit req = if req.Ms > limit then Some () else None

// string -> Request -> unit option
let (|Under|_|) (prefix: string) req = if req.Path.StartsWith prefix then Some () else None

// Request -> int — 위에서 아래로 검사하므로 큰 임계값을 먼저 적는다
let latencyScore req =
    match req with
    | SlowerThan 1000 -> 20
    | SlowerThan 300 -> 5
    | _ -> 0

// Request -> int
let scopeScore req =
    match req with
    | Under "/admin" -> 10
    | Under "/api" -> 2
    | _ -> 0
```

- `SlowerThan 300` 을 먼저 적으면 1200밀리초짜리 요청도 5점을 받고 끝난다. 임계값이 겹치는 패턴을 나열할 때는 좁은 조건이 위에 와야 한다.
- 같은 판정을 기준값만 달리해 두 번 쓰는 것이 매개변수의 값어치다. `(|Slow|_|)` 와 `(|VerySlow|_|)` 를 따로 정의하지 않아도 된다.

경로를 세그먼트 리스트로 열어 주는 단일 케이스 액티브 패턴을 더하면 영역 이름을 뽑을 수 있다.

```fsharp id=07-accesslog
// Request -> string list
let (|Segments|) req =
    req.Path.Split('/', StringSplitOptions.RemoveEmptyEntries) |> List.ofArray

// Request -> string
let area req =
    match req with
    | Segments [] -> "root"
    | Segments (top :: _) -> top
```

- 단일 케이스 패턴이 리스트를 돌려주므로 리스트 패턴을 그대로 이어 쓸 수 있다. 빈 리스트와 `머리 :: 꼬리` 가 리스트 전부를 덮으므로 와일드카드가 필요 없다.

점수 규칙 세 개는 시그니처가 모두 `Request -> int` 로 같다. 같은 시그니처의 함수들은 리스트에 담아 한 번에 합산할 수 있다. 원서가 마지막에 쓰는 정리 기법이 이것이다.

```fsharp id=07-accesslog
// Request -> int — 함수도 리스트에 담을 수 있다. List.sumBy 는 List.map 뒤 List.sum 과 같다
let risk req =
    [ statusScore; latencyScore; scopeScore ]
    |> List.sumBy (fun rule -> rule req)

// int -> string
let alarm score =
    match score with
    | s when s >= 40 -> "긴급"
    | s when s >= 10 -> "주의"
    | _ -> "정상"
```

- 규칙을 추가할 때 `risk` 를 고치는 대신 리스트에 함수 이름 하나를 더 적으면 된다. 규칙 목록을 매개변수로 빼면 채점 정책을 호출하는 쪽에서 갈아 끼울 수도 있다.
- `alarm` 은 가드 절만 쓴다. 액티브 패턴으로 만들 수도 있지만, 한 곳에서만 쓰는 구간 판정은 가드 절이 더 짧다. 액티브 패턴은 재사용할 판정에 쓸 때 값어치가 나온다.

전체를 이어 붙여 로그를 훑는다.

```fsharp id=07-accesslog
let lines =
    [ "GET /api/tracks 200 84ms"
      "POST /admin/users 500 1240ms"
      "GET /admin/sessions 403 120ms"
      "GET / 200 12ms"
      "PATCH /api/tracks 200 30ms" ]

lines
|> List.iter (fun line ->
    match line with
    | AccessLine req ->
        let score = risk req
        printfn "%-6s %-4d %-16s %s" (area req) score req.Path (alarm score)
    | _ -> printfn "형식 불일치: %s" line)
// api    2    /api/tracks      정상
// admin  70   /admin/users     긴급
// admin  15   /admin/sessions  주의
// root   0    /                정상
// 형식 불일치: PATCH /api/tracks 200 30ms
```

- 점수 검산은 이렇게 된다. `/admin/users 500 1240ms` 는 서버 오류 40 + 1초 초과 20 + 관리 영역 10 으로 70점, `/admin/sessions 403 120ms` 는 5 + 0 + 10 으로 15점이다.
- 네 종류가 각자 맡은 자리가 분명하다. 실패할 수 있는 변환은 부분 패턴, 기준값이 필요한 판정은 매개변수 있는 부분 패턴, 반드시 하나로 떨어지는 분류는 다중 케이스 패턴, 모양만 바꾸는 분해는 단일 케이스 패턴이다. 이 대응만 잡아 두면 어떤 종류를 쓸지 고민할 일이 없다.

## Summary — 원서의 챕터 요약 (원서 p.102)

- 원서는 액티브 패턴이 유용하고 강력하지만 늘 최선의 선택은 아니라는 말로 챕터를 맺는다. 잘 쓰면 가독성이 올라간다는 조건부 권장이다.
- 이 챕터에서 다루지 않은 종류가 더 있고, 공식 문서를 찾아보라고 안내한다.
- 다음 챕터에서는 여기서 익힌 기능을 6챕터 코드에 얹어 검증을 붙인다.

## 정리 — 이 노트의 요약

- 액티브 패턴은 이름을 `(|` `|)` 로 감싼 함수다. 시그니처는 같은 본문의 일반 함수와 똑같고, 달라지는 것은 그 이름을 패턴 자리에서 쓸 수 있다는 점뿐이다. 그래서 `List.choose` 같은 고차 함수에 그대로 넘길 수도 있다.
- 이름에 `_|` 가 있으면 실패할 수 있다는 뜻이고 반환 타입이 `option` 이다(F# 9 부터는 `bool`, `[<return: Struct>]` 를 붙이면 `voption` 이다). 없으면 반드시 성공하며 값이나 `Choice` 를 그대로 반환한다. 이 한 가지 규칙이 네 종류의 반환 타입을 모두 설명한다.
- 종류별 실측 시그니처는 다음과 같다. 부분 패턴은 `string -> int option`, 매개변수 있는 부분 패턴은 `float -> Trail -> unit option`, 다중 케이스 패턴은 `Track -> Choice<unit,unit,unit>`, 단일 케이스 패턴은 `string -> string list` 다.
- 매개변수는 부분 패턴과 단일 케이스 패턴에만 붙는다. 다중 케이스 패턴에 붙이면 정의는 통과하지만 쓰는 순간 오류 FS0722 가 난다.
- 다중 케이스 패턴은 케이스 일곱 개가 상한(오류 FS0265)이고, 부분 패턴과 다중 케이스 패턴을 섞은 `(|A|B|_|)` 형태는 존재하지 않는다(오류 FS3872).
- 케이스 식별자는 대문자로 시작해야 한다(오류 FS0623). 이 식별자는 패턴 자리에서만 쓸 수 있고, 그 자리 안에서는 판별 유니온 케이스와 이름 공간을 함께 쓴다. 같은 이름의 판별 유니온 케이스가 이미 스코프에 있으면 나중 정의가 앞의 것을 가려 타입 불일치 오류 FS0001 이 난다.
- 패턴 조합 연산자는 `&` 와 `|` 둘뿐이고 부정이 없다. 부정 조건이 필요하면 반대 판정을 하나 더 정의하거나 가드 절로 옮긴다. 가드 절에서는 일반 논리 연산자를 그대로 쓴다.
- 부분 액티브 패턴은 F# 9 부터 `bool` 을 반환해도 된다. `[<return: Struct>]` 로 `voption` 을 반환해 힙 할당을 피하는 것은 F# 6 부터다. 둘 다 반환 표현만 바뀌는 것이고 종류가 늘지는 않는다. 원서 시점의 `Some ()` 형태도 그대로 유효하다.
- 액티브 패턴을 쓸지 판단하는 기준은 재사용이다. 여러 `match` 식에서 되풀이되는 판정이면 액티브 패턴으로 뽑고, 한 곳에서만 쓰는 구간 판정이면 가드 절이 짧다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Setting Up — 준비 | p.90 | — |
| 네 종류를 먼저 구분한다 | pp.90-98 | — |
| Partial Active Patterns — 부분 액티브 패턴 | pp.90-92 | `07-catalog` |
| Parameterized Partial Active Patterns — 매개변수 있는 부분 액티브 패턴 | pp.92-96 | `07-trail` |
| Multi-Case Active Patterns — 다중 케이스 액티브 패턴 | pp.96-97 | `07-playlist` |
| Single-Case Active Patterns — 단일 케이스 액티브 패턴 | pp.97-98 | `07-query` |
| Using Active Patterns in a Practical Example — 실전 예제 | pp.99-102 | `07-accesslog` |
| Summary — 원서의 챕터 요약 | p.102 | — |
