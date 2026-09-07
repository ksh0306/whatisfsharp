# 03 - `null` 과 예외 처리 (원서 pp.39-51)

> 이 챕터는 "값이 없을 수도 있다"와 "실패할 수도 있다"를 F# 이 어떻게 다루는지 보여 준다. 답은 둘 다 타입이다. 없음은 `Option`, 실패는 `Result` 로 표현한다. 두 타입 모두 판별 유니온(discriminated union)이므로 특별한 문법을 새로 배울 필요 없이 1챕터에서 배운 도구로 이해할 수 있다. 여기서 함께 나오는 `map` 과 `bind` 는 시그니처가 맞물리지 않는 함수를 합성에 끼워 넣는 장치이며, 뒤 챕터 전체가 이 두 함수에 기댄다. 8챕터의 검증 파이프라인과 12챕터의 계산 식(computation expression)은 사실 이 챕터의 `Result.map`/`Result.bind` 를 더 읽기 좋게 감싼 것이다.

시작하기 전에 이 챕터에서 새로 등장하는 용어 하나를 정리해 둔다.

- 고차 함수(higher-order function)는 함수를 매개변수로 받거나 함수를 반환하는 함수다. `Option.map`, `Result.bind` 가 모두 여기 해당한다. 2챕터에서 본 `|>` 도 고차 함수였다.

## Null Handling — `Option` 으로 없음을 타입에 적기 (원서 pp.39-41)

- F# 코드를 쓰는 동안에는 `null` 을 거의 만지지 않는다. 값이 있을 수도 없을 수도 있는 자리에는 `Option` 을 쓴다.
- `Option` 은 언어에 내장된 판별 유니온이며 개념적으로 아래 모양이다. 값이 있으면 `Some`, 없으면 `None` 이다.
- `'T` 처럼 이름 앞에 붙은 작은따옴표는 타입 매개변수(type parameter) 표시다. 덕분에 어떤 타입이든 "있을 수도 없을 수도 있는 값"으로 감쌀 수 있다.
- 이 정의는 언어에 이미 있으므로 직접 선언하면 안 된다. 아래 블록에 `id` 를 붙이지 않은 이유가 그것이다.

```fsharp
// 개념 확인용. 실제로 선언하면 내장 Option 과 충돌한다
// 실제 정의는 None 이 먼저다
type Option<'T> =
    | Some of 'T
    | None
```

- `Option` 이 처음 등장하는 자리는 .NET 의 `TryParse` 계열이다. F# 에는 `out` 매개변수를 선언하는 문법이 없어서, 상호운용에서는 컴파일러가 `out` 매개변수를 반환값 쪽으로 옮겨 붙여 준다. 그 결과 `DateTime.TryParse` 는 `bool * DateTime` 튜플을 돌려준다. `let mutable` 값을 만들어 `&value` 로 직접 넘길 수도 있지만, 튜플로 받는 쪽이 관용적이다.

```fsharp id=03-option
// 이 단위가 보여주는 것: Option 을 만드는 방법과 Option 을 다루는 모듈 함수
open System

// string -> DateTime option
let tryParseDate (text: string) =
    let parsed, value =
        DateTime.TryParse(text, Globalization.CultureInfo.InvariantCulture, Globalization.DateTimeStyles.None)
    if parsed then Some value else None

// 날짜 값 자체를 출력하면 실행 환경의 문화권 설정에 따라 모양이 달라지므로 서식을 고정해 찍는다
printfn "%A" (tryParseDate "2024-03-18" |> Option.map (fun d -> d.ToString("yyyy-MM-dd")))   // 기대: Some "2024-03-18"
printfn "%A" (tryParseDate "내일" |> Option.map (fun d -> d.ToString("yyyy-MM-dd")))          // 기대: None
```

`if` 식 대신 `match` 식(match expression)으로 튜플을 분해해도 결과는 같다. 원서는 네 가지 표기를 차례로 보여 주는데, 갈라지는 지점은 실패 쪽 패턴을 얼마나 줄여 적는지뿐이다. `false, _` 로 명시하거나 `_, _` 로 두 자리를 모두 와일드카드(wildcard)로 두거나, `_` 하나로 튜플 전체를 받을 수 있다.

```fsharp id=03-option
// string -> DateTime option
let tryParseDateByMatch (text: string) =
    match DateTime.TryParse(text, Globalization.CultureInfo.InvariantCulture, Globalization.DateTimeStyles.None) with
    | true, value -> Some value
    | false, _ -> None
    // | _ -> None 으로 줄여도 같다. 튜플 전체가 와일드카드 하나에 걸린다

printfn "%b" (tryParseDateByMatch "2024-03-18" = tryParseDate "2024-03-18")   // 기대: true
```

- 어느 표기든 옳다. 의도가 가장 빨리 읽히는 것은 `if` 식과 `true, value` / `false, _` 쌍이다. 와일드카드를 넓게 쓸수록 짧아지지만 무엇을 버리는지가 흐려진다.
- `Option` 의 두 번째 용도는 선택적 데이터다. 사람의 중간 이름, 곡의 부제처럼 원래 없을 수 있는 필드를 레코드(record)에 담을 때 쓴다.
- 타입을 적는 방법이 두 가지다. `Option<string>` 처럼 제네릭 표기를 쓰거나 `string option` 처럼 뒤에 붙이는 표기를 쓴다. 뜻은 같고, 실무에서는 뒤쪽 표기를 더 자주 본다.

```fsharp id=03-option
// Subtitle 은 있을 수도 없을 수도 있다. Option<string> 이라고 적어도 뜻은 같다
type Track = { Title: string; Subtitle: string option; Seconds: int }

let plain = { Title = "Aurora"; Subtitle = None; Seconds = 214 }

// 2챕터의 복사-수정 레코드 식(copy-and-update record expression)으로 부제만 채운다
let annotated = { plain with Subtitle = Some "Live at Oslo" }

// Track -> string
let describe track =
    match track.Subtitle with
    | Some sub -> $"%s{track.Title} (%s{sub})"
    | None -> track.Title

printfn "%s / %s" (describe plain) (describe annotated)   // 기대: Aurora / Aurora (Live at Oslo)
```

`Option` 을 꺼내 쓸 때마다 `match` 식을 적는 것은 손이 많이 간다. 자주 쓰는 조합은 `Option` 모듈에 이미 함수로 들어 있다. 네 함수의 시그니처를 FSI 로 실측한 값은 다음과 같다.

```fsharp
Option.map          : ('a -> 'b) -> 'a option -> 'b option
Option.bind         : ('a -> 'b option) -> 'a option -> 'b option
Option.defaultValue : 'a -> 'a option -> 'a
Option.defaultWith  : (unit -> 'a) -> 'a option -> 'a
```

- `Option.map` 은 `Some` 안의 값에 보통 함수를 적용하고 다시 `Some` 으로 감싼다. `None` 이면 함수를 부르지 않고 `None` 을 그대로 흘린다.
- `Option.bind` 는 함수 자체가 `Option` 을 돌려줄 때 쓴다. `map` 을 썼다면 `'b option option` 이 되어 겹쳐 버리는데, `bind` 는 한 겹으로 눌러 준다.
- `Option.defaultValue` 는 `Option` 을 벗겨 평범한 값으로 되돌린다. `None` 이면 미리 준 기본값이 나온다.
- `Option.defaultValue` 는 기본값을 먼저 평가한다. 기본값을 만드는 데 비용이 들면 `Option.defaultWith` 를 쓴다. 8챕터의 검증 파이프라인에서 다시 만난다.

```fsharp id=03-option
// DateTime -> DateTime option  (주말이면 없음으로 취급한다)
let onlyWeekday (d: DateTime) =
    match d.DayOfWeek with
    | DayOfWeek.Saturday | DayOfWeek.Sunday -> None
    | _ -> Some d

// onlyWeekday 가 Option 을 내므로 bind 로 잇는다. map 을 쓰면 두 겹이 된다
// 2024-03-18 은 월요일, 2024-03-17 은 일요일이다
let monday = tryParseDate "2024-03-18" |> Option.bind onlyWeekday |> Option.map (fun d -> d.DayOfWeek.ToString())
let sunday = tryParseDate "2024-03-17" |> Option.bind onlyWeekday |> Option.map (fun d -> d.DayOfWeek.ToString())

printfn "%A %A" monday sunday                                  // 기대: Some "Monday" None
printfn "%s | %s"
    (monday |> Option.defaultValue "평일 아님")
    (sunday |> Option.defaultValue "평일 아님")                 // 기대: Monday | 평일 아님
```

- 파이프라인 어디서든 `None` 이 한 번 나오면 뒤 단계는 계산되지 않고 `None` 이 끝까지 흐른다. `null` 검사를 단계마다 손으로 넣던 코드가 사라지는 지점이다.
- F# 코드만으로 이루어진 세계에서는 `null` 이 끼어들 틈이 거의 없다. 문제는 다른 .NET 언어와 맞닿는 경계다.

## Interop With .NET — `null` 이 넘어오는 유일한 통로 (원서 pp.42-43)

- C# 등 다른 .NET 언어로 쓰인 코드와 주고받는 값에는 `null` 이 섞일 수 있다. .NET 플랫폼 자체의 API 도 마찬가지다.
- 경계에서 곧바로 `Option` 으로 바꿔 놓고, 안쪽에서는 `Option` 만 다루는 것이 기본 전략이다.
- `null` 은 두 갈래로 온다. 참조 타입의 `null` 과, 값 타입을 감싼 `Nullable<'T>` 의 빈 상태다. 변환 함수도 갈래별로 따로 있다.

```fsharp id=03-interop
// 이 단위가 보여주는 것: .NET 경계에서 null 을 Option 으로 바꾸고 되돌리는 길
open System

// 참조 타입의 null
let missingNickname : string = null

// 값 타입을 감싼 Nullable. 인자를 주지 않으면 빈 상태다
let missingScore = Nullable<int>()

printfn "%b %b" (isNull missingNickname) missingScore.HasValue   // 기대: true false
```

`Option` 모듈의 변환 함수 네 개다. 시그니처는 FSI 로 실측한 값이며, 제약이 붙어 있다는 점이 중요하다. `ofObj`/`toObj` 는 참조 타입에만, `ofNullable`/`toNullable` 은 값 타입에만 쓸 수 있다. `'a | null` 은 F# 9 에서 들어온 null 허용 참조 타입(nullable reference types) 표기이고, FSharp.Core 시그니처에 nullness 정보가 붙어 있어 이렇게 보인다. `'a` 또는 `null` 로 읽으면 된다. 검사 자체는 기본으로 꺼져 있어 앞 블록의 `missingNickname` 바인딩이 경고 없이 통과한다. 켜려면 컴파일러나 FSI 에 `--checknulls+` 옵션을 준다.

```fsharp
Option.ofObj      : 'a | null -> 'a option             (when 'a : not struct and 'a : not null)
Option.toObj      : 'a option -> 'a | null            (when 'a : not struct)
Option.ofNullable : System.Nullable<'a> -> 'a option  (when 'a : (new : unit -> 'a) and 'a : struct and 'a :> System.ValueType)
Option.toNullable : 'a option -> System.Nullable<'a>  (when 'a : (new : unit -> 'a) and 'a : struct and 'a :> System.ValueType)
```

- 뒤쪽 두 제약은 `Nullable<'T>` 가 요구하는 값 타입 조건을 컴파일러가 풀어 쓴 것이다. 읽을 때는 `'a : struct` 하나만 보면 된다.

```fsharp id=03-interop
let presentNickname = "kestrel"
let presentScore = Nullable<int>(42)

// .NET -> Option
let nickNone = Option.ofObj missingNickname
let nickSome = Option.ofObj presentNickname
let scoreNone = Option.ofNullable missingScore
let scoreSome = Option.ofNullable presentScore

printfn "%A %A %A %A" nickNone nickSome scoreNone scoreSome
// 기대: None Some "kestrel" None Some 42
```

되돌리는 방향도 짝이 맞는다. `None` 은 `null` 또는 빈 `Nullable` 로, `Some` 은 안의 값으로 돌아간다.

```fsharp id=03-interop
// Option -> .NET
let backToNull = Option.toObj nickNone
let backToNullable = Option.toNullable scoreSome

printfn "%b %A" (isNull backToNull) backToNullable   // 기대: true 42
```

- `null` 대신 자리표시자 문자열을 기대하는 상대와 맞닿을 때도 있다. 그럴 때는 `Option` 이 판별 유니온이라는 사실을 이용해 `match` 식으로 꺼내거나, `Option.defaultValue` 를 쓴다.

```fsharp id=03-interop
// string option -> string
let byMatch input =
    match input with
    | Some value -> value
    | None -> "(닉네임 없음)"

printfn "%s" (byMatch nickNone)                                  // 기대: (닉네임 없음)
printfn "%s" (Option.defaultValue "(닉네임 없음)" nickNone)       // 기대: (닉네임 없음)
printfn "%s" (nickNone |> Option.defaultValue "(닉네임 없음)")    // 기대: (닉네임 없음)
```

- 세 줄이 모두 같은 값을 낸다. 셋째 줄은 파이프 연산자로 적은 것이라 파이프라인 중간에 그대로 끼워 넣을 수 있다.
- 같은 기본값을 여러 곳에서 쓴다면 2챕터의 부분 적용(partial application)이 잘 맞는다. `Option.defaultValue` 는 매개변수가 커링되어 있으므로 기본값만 먼저 주면 `Option` 을 기다리는 함수가 남는다.

```fsharp id=03-interop
// FSI 실측: val orAnonymous: (string option -> string)
let orAnonymous = Option.defaultValue "(닉네임 없음)"

printfn "%s / %s" (orAnonymous nickNone) (orAnonymous nickSome)   // 기대: (닉네임 없음) / kestrel

// 기본값의 타입이 곧 Option 의 내용 타입을 정한다
printfn "%d" (scoreNone |> Option.defaultValue 0)                 // 기대: 0
```

- 경계에서 이 변환을 성실히 해 두면 실행 중에 `NullReferenceException` 을 볼 일이 사실상 없어진다.

## Handling Exceptions — 시그니처가 거짓말하지 않게 (원서 pp.43-45)

- 예외를 던지는 함수의 문제는 시그니처가 사실을 다 말하지 않는다는 점이다.
- 아래 나눗셈 함수의 시그니처는 `decimal -> decimal -> decimal` 이다. 그런데 분모가 0 이면 값을 내지 않고 예외를 던진다. 이 사실은 구현을 열어 보거나 실행해서 터뜨려 봐야 안다. `try/with` 를 본 뒤에 실제로 터뜨려 확인한다.

```fsharp id=03-exceptions
// 이 단위가 보여주는 것: try/with 식, 예외를 던지는 함수의 시그니처, Result 로 실패를 드러내기
open System

// FSI 실측: decimal -> decimal -> decimal
// 시그니처만 보면 언제나 decimal 을 낸다고 읽히지만 사실이 아니다
let divideUnsafe (numerator: decimal) (denominator: decimal) =
    numerator / denominator
```

- F# 에서 `try/with` 는 문(statement)이 아니라 값을 내는 식(expression)이다. C# 의 `try-catch` 와 역할은 같지만, 두 갈래가 모두 같은 타입의 값을 내야 한다는 제약이 붙는다.
- 아래 함수를 FSI 에 넣으면 `text: string -> int` 로 나온다. `try` 쪽의 `Int32.Parse text` 와 `with` 쪽의 `0` 이 모두 `int` 이므로 식 전체가 `int` 다.

```fsharp id=03-exceptions
// FSI 실측: text: string -> int
// try 갈래와 with 갈래가 같은 타입을 내야 하나의 식이 된다
let parsedOrZero (text: string) =
    try Int32.Parse text
    with :? FormatException -> 0

printfn "%d %d" (parsedOrZero "17") (parsedOrZero "열일곱")   // 기대: 17 0
```

```fsharp id=03-exceptions
// 시그니처가 말하지 않은 실패를 눈으로 확인한다. decimal 나눗셈은 0 으로 나누면 예외다
// float 는 예외 없이 infinity 를 내므로 이 예제는 decimal 을 쓴다
try printfn "%M" (divideUnsafe 7M 0M)
with :? DivideByZeroException as ex -> printfn "%s" (ex.GetType().Name)   // 기대: DivideByZeroException
```

- `raise` 와 `failwith` 는 이 규칙에서 빠져나가는 것처럼 보인다. FSI 로 확인하면 `raise` 는 `System.Exception -> 'a`, `failwith` 는 `string -> 'a` 다. 반환 타입이 타입 매개변수인 이유는 정상적으로 값을 돌려주는 일이 없기 때문이다. 값을 내지 않으니 어떤 타입 자리에든 끼울 수 있고, 그래서 `with` 갈래에 `failwith` 를 두어도 타입이 어긋나지 않는다.
- 실패를 시그니처에 드러내려면 성공과 실패 중 하나를 담는 타입이 필요하다. 원서는 아래와 같은 직접 정의를 먼저 보여 주고, 곧 F# 4.1 부터 언어에 들어 있는 `Result` 로 넘어간다. 내장 타입의 두 케이스 식별자는 `Ok` 와 `Error` 다.

```fsharp
// 개념 확인용. 실제로는 내장 Result<'T,'TError> 를 쓴다
type Result<'TSuccess, 'TFailure> =
    | Success of 'TSuccess
    | Failure of 'TFailure
```

- `Result` 의 타입 매개변수는 두 개다. 앞이 성공값 타입, 뒤가 실패값 타입이다. `Option` 과 달리 실패에도 값이 실린다는 것이 핵심 차이다. 왜 실패했는지를 전달할 수 있다.
- `try/with` 안의 `:?` 는 타입 테스트 패턴(type test pattern)이다. 던진 예외가 `:?` 뒤에 적어 둔 타입이거나 그 하위 타입인지를 런타임에 검사할 뿐, 값을 변환하지는 않는다. 일치하면 `as ex` 가 그 타입으로 좁혀진 예외 인스턴스를 `ex` 에 바인딩하고, 그 값을 `Error` 의 케이스 데이터로 넘긴다.
- 여기에 걸리지 않은 예외는 그대로 호출 사슬 위로 올라간다. 다른 .NET 코드와 동작이 같다.
- 먼저 반환 타입 주석을 붙이지 않은 판을 본다. 실패 타입은 컴파일러가 `with` 갈래에서 잡은 예외 타입으로 좁혀 추론한다.

```fsharp id=03-exceptions
// 반환 타입 주석이 없는 판. 실패 타입이 잡은 예외 타입으로 좁혀진다
// FSI 실측: x: decimal -> y: decimal -> Result<decimal,System.DivideByZeroException>
let tryDivideNarrow (x: decimal) (y: decimal) =
    try Ok (x / y)
    with :? DivideByZeroException as ex -> Error ex

printfn "%b" (tryDivideNarrow 7M 2M = Ok 3.5M)   // 기대: true
```

- 실패 타입을 좁게 두면 그 함수 하나를 볼 때는 정보가 많아 좋다. 하지만 여러 단계를 이어 붙이려면 단계마다 실패 타입이 같아야 하므로, 파이프라인 전체가 공유하는 실패 타입을 미리 정해 두는 편이 편하다.
- 넓히는 방법은 두 가지다. 반환 타입을 `Result<decimal, exn>` 으로 주석하거나, `Error` 에 담을 때 `ex :> exn` 으로 상향 변환한다.

```fsharp id=03-exceptions
// 반환 타입 주석으로 실패 타입을 exn 으로 넓힌 판
// FSI 실측: numerator: decimal -> denominator: decimal -> Result<decimal,exn>
let tryDivide (numerator: decimal) (denominator: decimal) : Result<decimal, exn> =
    try
        Ok (numerator / denominator)
    with
    | :? DivideByZeroException as ex -> Error ex

// FSI 실측: label: string -> result: Result<decimal,exn> -> unit
let show label result =
    match result with
    | Ok value -> printfn "%-5s Ok %M" label value
    | Error (ex: exn) -> printfn "%-5s Error %s" label (ex.GetType().Name)

show "7/2" (tryDivide 7M 2M)   // 기대: 7/2   Ok 3.5
show "7/0" (tryDivide 7M 0M)   // 기대: 7/0   Error DivideByZeroException
```

- 원서 주석에는 `Result<decimal,exn>` 이라 적혀 있다. F# 10 컴파일러는 반환 타입 주석이 없으면 실패 타입을 `DivideByZeroException` 으로 좁히므로, 대조하며 읽을 때 혼동하지 않도록 두 판을 나란히 남겼다.
- 원서 p.45 의 `// Some 1M` 주석은 `// Ok 1M` 의 오기다. 그 시점 `tryDivide` 는 `Option` 이 아니라 `Result` 를 낸다.

```fsharp id=03-exceptions
// 명시적 상향 변환으로 넓힌 판. 반환 타입 주석 없이도 실패 타입이 exn 이 된다
// FSI 실측: x: decimal -> y: decimal -> Result<decimal,exn>
let tryDivideWide (x: decimal) (y: decimal) =
    try Ok (x / y)
    with :? DivideByZeroException as ex -> Error (ex :> exn)

printfn "%b" (tryDivideWide 7M 2M = Ok 3.5M)   // 기대: true
```

- 세 판은 같은 계산이고 다른 것은 실패 타입뿐이다. 파이프라인에 넣을 것은 실패 타입이 `exn` 으로 통일된 판이다.

## Function Composition With Result — `map` 과 `bind` (원서 pp.45-51)

- 2챕터에서 배운 합성 조건은 앞 함수의 출력 타입과 뒤 함수의 입력 타입이 같아야 한다는 것이었다. `Result` 를 도입하면 이 조건이 자주 깨진다.
- 원서는 관측소 예제가 아닌 고객 예제를 쓰지만 구조는 같다. 세 단계를 잇는데 가운데 단계만 `Result` 를 모른다.
- 스콧 블라신(Scott Wlaschin)은 이 구조를 나란한 두 선로에 비유해 철도 지향 프로그래밍(Railway Oriented Programming)이라 부른다. `Ok` 선로를 달리다가 실패가 나면 `Error` 선로로 갈아타고 끝까지 그 선로로 간다. 가운데 단계처럼 `Result` 를 내지 않는 함수는 한쪽 선로만 다니는 함수다.

```fsharp id=03-result-compose
// 이 단위가 보여주는 것: Result 가 끼면 합성이 끊기는 지점과 map/bind 로 다시 잇는 법
open System

type Reading = { StationId: int; Celsius: decimal; Verified: bool }

// 이력을 읽어 판독값과 결측 일수를 함께 돌려준다. 데이터베이스에서 읽어 오는 상황을 가정한 코드다
// FSI 실측: reading: Reading -> Result<(Reading * int),exn>
// FSI 는 성공값이 튜플이면 Result<(Reading * int),exn> 처럼 괄호를 넣어 표시한다
// 소스에 적은 Result<Reading * int, exn> 과 같은 타입이고 표시 방식만 다르다
let loadHistory reading : Result<Reading * int, exn> =
    try
        let missingDays = if reading.StationId % 3 = 0 then 7 else 1
        Ok (reading, missingDays)
    with ex -> Error ex

// 한쪽 선로만 다니는 함수. Result 를 받지도 내지도 않는다
// FSI 실측: reading: Reading * missingDays: int -> Reading
let markVerified (reading, missingDays) =
    if missingDays <= 3 then { reading with Verified = true } else reading

// 다시 Result 를 내는 함수
// FSI 실측: reading: Reading -> Result<Reading,exn>
let calibrate reading : Result<Reading, exn> =
    try
        let offset = if reading.Verified then 0.2M else 1.5M
        Ok { reading with Celsius = reading.Celsius + offset }
    with ex -> Error ex
```

세 함수를 그냥 이어 붙이면 두 곳에서 타입이 어긋난다. `loadHistory` 는 `Result<Reading * int, exn>` 을 내는데 `markVerified` 는 `Reading * int` 를 기다린다. `calibrate` 도 `Reading` 을 기다리지만, 앞 단계를 지난 결과는 이미 `Result` 로 감싸여 있다.

```fsharp
// 컴파일 오류. Result<Reading * int, exn> 을 Reading * int 자리에 넣을 수 없다
let refineBroken reading =
    reading
    |> loadHistory
    |> markVerified
    |> calibrate
```

- 첫 번째 틈은 익명 함수(anonymous function)에 `match` 식을 넣어 메울 수 있다. `Ok` 안의 튜플을 꺼내 `markVerified` 에 주고, 결과를 다시 `Ok` 로 감싼다. `Error` 는 손대지 않고 그대로 넘긴다.
- 두 번째 틈도 같은 방식인데 `calibrate` 가 이미 `Result` 를 내므로 `Ok` 로 감싸지 않는다. 이 차이가 곧 `map` 과 `bind` 의 차이다.

```fsharp id=03-result-compose
// 익명 함수와 match 식으로 직접 메운 형태
let refineRaw reading =
    reading
    |> loadHistory
    |> fun result ->
        match result with
        | Ok pair -> Ok (markVerified pair)      // Ok 로 다시 감싼다
        | Error ex -> Error ex
    |> fun result ->
        match result with
        | Ok r -> calibrate r                    // calibrate 가 이미 Result 를 낸다
        | Error ex -> Error ex
```

`fun result -> match result with` 처럼 받은 값을 바로 `match` 식에 넘길 때는 `function` 키워드로 줄여 쓸 수 있다. 둘 중 어느 쪽을 써도 좋다.

```fsharp id=03-result-compose
let refineFn reading =
    reading
    |> loadHistory
    |> function
        | Ok pair -> Ok (markVerified pair)
        | Error ex -> Error ex
    |> function
        | Ok r -> calibrate r
        | Error ex -> Error ex
```

- 다음 단계는 이 익명 함수를 이름 있는 함수로 빼내는 것이다. 빼내는 순간 매개변수가 두 개인 함수가 되는데, 첫 매개변수가 함수다. 즉 고차 함수다.
- 그리고 함수 본문에서 `Reading` 이나 `exn` 같은 구체 타입을 하나도 쓰지 않으므로, 타입 주석을 떼면 컴파일러가 자동 일반화(auto-generalization)로 제네릭 함수를 만들어 준다.

```fsharp id=03-result-compose
// FSI 실측: f: ('a -> 'b) -> result: Result<'a,'c> -> Result<'b,'c>
// 성공값만 바꾸고 실패 타입 'c 는 건드리지 않는다
// | Error err -> Error err 를 | e -> e 로 줄일 수 없다
// 들어오는 타입은 Result<'a,'c>, 나가는 타입은 Result<'b,'c> 라서 성공 타입이 다르다
// 같은 값을 그대로 흘리면 'a 와 'b 가 같은 타입으로 묶여 제네릭이 무너진다
let mapOk f result =
    match result with
    | Ok value -> Ok (f value)
    | Error err -> Error err

// FSI 실측: f: ('a -> Result<'b,'c>) -> result: Result<'a,'c> -> Result<'b,'c>
// 받는 함수 자체가 Result 를 내므로 겹치지 않게 그대로 흘린다
let bindOk f result =
    match result with
    | Ok value -> f value
    | Error err -> Error err

let refineMine reading =
    reading
    |> loadHistory
    |> mapOk markVerified
    |> bindOk calibrate
```

- 시그니처를 나란히 놓고 보면 차이가 한 군데뿐이다. `mapOk` 의 첫 매개변수는 `'a -> 'b`, `bindOk` 의 첫 매개변수는 `'a -> Result<'b,'c>` 다. 넘기는 함수가 `Result` 를 내느냐로 갈린다.
- 실패 타입 `'c` 는 두 함수 모두 그대로 통과시킨다. 제네릭이 된 순간 `'c` 는 예외일 필요가 없다. 문자열이든 판별 유니온이든 원하는 타입을 쓸 수 있다.
- 이 두 함수를 굳이 손으로 만들 필요는 없다. `Result` 모듈에 `Result.map` 과 `Result.bind` 라는 이름으로 똑같은 것이 이미 들어 있다. 원서가 앞의 두 함수에 `map`/`bind` 라는 이름을 붙인 것도 그래서다. 아래 시그니처는 FSI 실측값이다.

```fsharp
Result.map      : ('a -> 'b) -> Result<'a,'c> -> Result<'b,'c>
Result.bind     : ('a -> Result<'b,'c>) -> Result<'a,'c> -> Result<'b,'c>
Result.mapError : ('a -> 'b) -> Result<'c,'a> -> Result<'c,'b>
```

- `Result.mapError` 의 타입 매개변수 순서를 잘 봐야 한다. 성공 타입 `'c` 가 유지되고 실패 타입이 `'a` 에서 `'b` 로 바뀐다. `map` 의 거울상이다.
- `Option` 쪽 짝과 비교해 두면 기억하기 쉽다. `Option.map` 은 `('a -> 'b) -> 'a option -> 'b option`, `Option.bind` 는 `('a -> 'b option) -> 'a option -> 'b option` 이다. 감싸는 타입만 다르고 역할 분담은 같다.

```fsharp id=03-result-compose
// 직접 만든 mapOk/bindOk 를 표준 함수로 바꾼 최종 형태
let refine reading =
    reading
    |> loadHistory
    |> Result.map markVerified
    |> Result.bind calibrate

let quiet = { StationId = 1; Celsius = 21.0M; Verified = false }   // 결측 1일 -> 검증 통과
let gappy = { StationId = 3; Celsius = 21.0M; Verified = false }   // 결측 7일 -> 검증 실패

printfn "%b" (refine quiet = Ok { StationId = 1; Celsius = 21.2M; Verified = true })    // 기대: true
printfn "%b" (refine gappy = Ok { StationId = 3; Celsius = 22.5M; Verified = false })   // 기대: true
```

- 파이프라인이 마음에 들지 않으면 중간 결과를 `let` 으로 하나씩 받아도 된다. 같은 계산이다. 파이프라인 쪽이 짧고, 중간 이름을 지어 줄 필요가 없다.

```fsharp id=03-result-compose
let refineSteps reading =
    let loaded = loadHistory reading
    let marked = Result.map markVerified loaded
    Result.bind calibrate marked

// 지금까지 만든 다섯 가지 표기가 모두 같은 값을 낸다
printfn "%b %b %b %b"
    (refineRaw quiet = refine quiet)
    (refineFn quiet = refine quiet)
    (refineMine quiet = refine quiet)
    (refineSteps quiet = refine quiet)       // 기대: true true true true
```

## 실패 타입을 직접 정하기 — `Result.mapError` (원서 p.48 확장)

- 제네릭이 된 `Result` 의 실패 자리에는 어떤 타입이든 들어간다. 실무에서는 `exn` 대신 도메인 오류를 나열한 판별 유니온을 두는 편이 훨씬 유용하다. 실패 종류가 타입에 적히므로 `match` 식에서 빠뜨린 케이스를 컴파일러가 잡아 준다.
- 문제는 단계마다 실패 타입이 달라질 수 있다는 점이다. `Result.bind` 로 이으려면 실패 타입이 같아야 한다. `Result.mapError` 가 그 어긋남을 메운다.

```fsharp id=03-result-errors
// 이 단위가 보여주는 것: 도메인 오류 판별 유니온, Result.mapError 로 실패 타입 맞추기
open System

type UploadError =
    | EmptyPayload
    | TooLarge of limitKb: int
    | Unexpected of message: string

// FSI 실측: bytes: int -> Result<int,exn>
let readSize (bytes: int) : Result<int, exn> =
    try
        if bytes < 0 then raise (ArgumentException "음수 크기")
        Ok bytes
    with ex -> Error ex

// FSI 실측: ex: exn -> UploadError
let toUploadError (ex: exn) = Unexpected ex.Message

// FSI 실측: bytes: int -> Result<int,UploadError>
let checkSize bytes =
    if bytes = 0 then Error EmptyPayload
    elif bytes > 4096 then Error (TooLarge 4)
    else Ok bytes
```

`readSize` 의 실패 타입은 `exn`, `checkSize` 의 실패 타입은 `UploadError` 다. 그대로는 `Result.bind` 로 이어지지 않는다. `Result.mapError toUploadError` 를 사이에 끼워 앞 단계의 실패 타입을 뒤 단계에 맞춘다. 2챕터의 어댑터 함수와 발상이 같은데, 이번에는 실패 선로 쪽에 끼우는 것이다.

```fsharp id=03-result-errors
// FSI 실측: bytes: int -> Result<string,UploadError>
let upload bytes =
    bytes
    |> readSize
    |> Result.mapError toUploadError          // exn 을 UploadError 로 맞춘다
    |> Result.bind checkSize
    |> Result.map (fun b -> $"업로드 %d{b} 바이트")

// FSI 실측: result: Result<string,UploadError> -> string
let describeUpload result =
    match result with
    | Ok message -> message
    | Error EmptyPayload -> "실패: 빈 파일"
    | Error (TooLarge limit) -> $"실패: %d{limit}KB 초과"
    | Error (Unexpected msg) -> $"실패: %s{msg}"

for input in [ 1024; 0; 9000; -1 ] do
    printfn "%6d -> %s" input (describeUpload (upload input))
// 기대:
//   1024 -> 업로드 1024 바이트
//      0 -> 실패: 빈 파일
//   9000 -> 실패: 4KB 초과
//     -1 -> 실패: 음수 크기
```

- `Option` 과 `Result` 사이를 옮겨야 할 때도 있다. `Option` 은 왜 없는지를 담지 못하므로, `Result` 로 옮길 때 실패 이유를 새로 붙여 준다. 아래 변환 함수는 F# 표준 모듈에 없어 직접 만든 것이다.

```fsharp id=03-result-errors
// FSI 실측: error: 'a -> opt: 'b option -> Result<'b,'a>
let ofOption error opt =
    match opt with
    | Some value -> Ok value
    | None -> Error error

printfn "%A" (Some 3 |> ofOption EmptyPayload)                                    // 기대: Ok 3
printfn "%A" (None |> ofOption EmptyPayload |> Result.map (fun (v: int) -> v * 2)) // 기대: Error EmptyPayload
```

- 반대 방향에는 표준 함수가 있다. `Result.toOption` 은 `Ok` 안의 값을 `Some` 으로 옮기고, `Error` 는 이유를 버려 `None` 으로 바꾼다. 실패 이유를 버리는 것이 의도일 때만 쓴다.

```fsharp id=03-result-errors
// FSI 실측: Result.toOption : Result<'a,'b> -> 'a option
// Error 의 이유는 버려진다
printfn "%A" (upload 1024 |> Result.toOption)   // 기대: Some "업로드 1024 바이트"
printfn "%A" (upload 0 |> Result.toOption)      // 기대: None
```

## Summary — 원서의 챕터 요약 (원서 p.51)

- 원서는 이 챕터에서 `null` 처리, `Option` 타입과 모듈, 예외 처리, `Result` 타입과 모듈, 고차 함수를 다뤘다.
- 철도 지향 프로그래밍과 도메인 주도 설계를 더 보려면 스콧 블라신의 저서 "Domain Modeling Made Functional" 을 권한다고 적혀 있다.
- 다음 챕터에서는 코드를 프로젝트로 나누는 방법과 단위 테스트를 살펴본다.

## 정리 — 이 노트의 요약

- 없음은 `Option`, 실패는 `Result` 로 타입에 적는다. 둘 다 판별 유니온이므로 `match` 식으로 다룰 수 있고, 모듈 함수로 더 짧게 다룰 수 있다.
- `Option` 과 `Result` 의 차이는 실패 쪽에 값이 실리는지다. `Option` 의 `None` 은 이유를 담지 못하고, `Result` 의 `Error` 는 담는다. 이유가 필요하면 `Result` 다.
- `null` 은 다른 .NET 코드와 맞닿는 경계에서만 들어온다. `Option.ofObj`/`ofNullable` 로 즉시 `Option` 으로 바꾸고, 내보낼 때 `toObj`/`toNullable` 로 되돌린다.
- `try/with` 는 값을 내는 식이다. 두 갈래가 같은 타입을 내야 한다. `raise` 와 `failwith` 의 반환 타입이 `'a` 인 것은 정상적으로 값을 돌려주지 않기 때문이며, 그래서 어느 타입 자리에나 놓을 수 있다.
- 예외를 던지는 함수는 시그니처가 사실을 다 말하지 않는다. 실패를 반환값으로 옮기면 시그니처만 읽고 그 함수를 신뢰할 수 있다.
- `map` 은 성공값에 보통 함수를 적용하고 다시 감싸며, `bind` 는 이미 감싼 값을 내는 함수를 이어 겹침을 막는다. 넘길 함수의 반환 타입만 보면 어느 쪽을 쓸지 정해진다.
- `Result.mapError` 는 실패 선로에 끼우는 어댑터다. 단계마다 실패 타입이 다르면 이것으로 맞춘 뒤 `bind` 로 잇는다.
- 실패 타입을 도메인 판별 유니온으로 정해 두면 처리하지 않은 실패 종류를 컴파일러가 찾아 준다. 8챕터의 검증과 12챕터의 계산 식이 모두 이 형태 위에 올라간다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Null Handling — `Option` 으로 없음을 타입에 적기 | pp.39-41 | `03-option` |
| Interop With .NET — `null` 이 넘어오는 유일한 통로 | pp.42-43 | `03-interop` |
| Handling Exceptions — 시그니처가 거짓말하지 않게 | pp.43-45 | `03-exceptions` |
| Function Composition With Result — `map` 과 `bind` | pp.45-51 | `03-result-compose` |
| 실패 타입을 직접 정하기 — `Result.mapError` | p.48 확장 | `03-result-errors` |
| Summary — 원서의 챕터 요약 | p.51 | — |
