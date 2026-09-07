# 08 - 함수형 검증 (원서 pp.103-117)

> 6챕터가 만든 파이프라인은 파일을 읽어 레코드로 바꾸는 데까지 갔지만 모든 칸이 `string` 인 상태로 멈췄다. 날짜 칸에 무엇이 적혀 있어도 통과하고, 필수 칸이 비어도 알 수 없다. 이 챕터는 그 파이프라인에 검증(validation)을 끼워 넣는다. 새로 배울 도구는 거의 없다. 7챕터의 부분 액티브 패턴(partial active pattern)으로 문자열을 해석하고, 3챕터의 `Result` 로 실패를 값으로 돌려주고, 5챕터의 `List` 함수로 오류를 모은다. 요점은 마지막에 나온다. 검증은 한 칸이 틀려도 나머지 칸을 계속 검사해야 하는 작업인데, `Result.bind` 로 이으면 첫 오류에서 멈춘다. 첫 오류에서 멈추는 방식과 오류를 모으는 방식의 차이, 그리고 그 차이를 문법으로 감싼 F# 5 의 `and!` 를 이해하는 것이 이 챕터의 목표다.

시작하기 전에 이름이 닮아 헷갈리는 낱말 둘을 갈라 둔다.

- 부분 액티브 패턴은 이름 마지막 자리에 와일드카드가 붙은 `(|Name|_|)` 꼴이고 `option` 을 반환한다. 실패할 수 있는 판정과 파싱에 쓴다. 이 노트는 이후 "부분 패턴"으로 줄여 쓴다.
- 부분 함수(partial function)는 가능한 입력 전부에서 값을 돌려주지 못하고 그런 입력에 예외를 던지는 함수다. 이름이 닮은 부분 적용(partial application)과는 관계가 없다. 이 챕터에서도 부분 함수가 하나 등장하는데, 그것을 쓰지 않아도 되게 만드는 과정이 챕터 후반이다.
- 두 낱말을 가르는 것은 뒤에 붙는 "패턴"과 "함수"다. 앞의 낱말만 떼어 놓으면 어느 쪽을 말하는지 알 수 없으므로 이 노트는 그렇게 줄이지 않는다.

소재는 실험실 시료 접수 명세다. 칸은 다섯 개이고 구분자는 `|` 다. `SampleId` 는 반드시 있어야 하고, `ContactEmail` 은 비어도 되지만 적혀 있으면 주소 모양이어야 한다. `Chilled` 는 참거짓이며 `Y` 나 `N` 중 하나로 적어야 하고 빈 칸을 허용하지 않는다. `CollectedOn` 은 날짜, `VolumeMl` 은 수량이고 이 두 칸은 비어 있어도 된다.

## Setting Up — 검증을 붙일 자리 (원서 pp.103-105)

- 원서는 콘솔 프로젝트를 만들고 `resources/customers.csv` 를 둔 뒤 6챕터 마지막 코드를 그대로 붙여 넣는 것으로 시작한다. 이 챕터에서 새로 만드는 것은 없고, 이미 있는 파이프라인에 단계 하나를 끼우는 것이 전부다.
- 이 노트는 파일을 만들지 않는다. 6챕터가 데이터 출처를 `DataReader` 라는 함수 타입 약어로 빼 두었으므로, 같은 시그니처의 함수를 하나 만들면 파일 없이 같은 파이프라인을 돌릴 수 있다. 그 설계가 여기서 제값을 한다.
- 출발점의 특징은 하나다. `RawSample` 의 모든 필드가 `string` 이다. 파싱은 칸 개수만 확인하고 내용은 손대지 않는다.

```fsharp id=08-intake
// 이 단위가 보여주는 것: 검증이 없는 6챕터 파이프라인의 출발 상태
open System

// 모든 칸이 string 이다. 이 챕터가 고칠 지점이 여기다
type RawSample = {
    SampleId: string
    ContactEmail: string
    Chilled: string
    CollectedOn: string
    VolumeMl: string
}

// 6챕터가 정한 함수 타입 약어
type DataReader = string -> Result<string seq, exn>
```

데이터 출처는 파일이 아니어도 된다. `DataReader` 는 타입 약어일 뿐이므로 시그니처가 같은 함수는 무엇이든 그 자리에 들어간다.

```fsharp id=08-intake
let rows =
    [ "SampleId|ContactEmail|Chilled|CollectedOn|VolumeMl"
      "S-1041|choi@lab.example|Y|2024-03-02|12.5"
      "S-1042||N|2024-03-04|8"
      "S-1043|park.at.lab.example|Y|2024-03-05|4.25"
      "S-1044|yun@lab.example|maybe|2024-03-06|"
      "S-1045|seo@lab.example|N||3.0"
      "||Y|2024-13-45|-" ]

// FSI 실측: source: string -> Result<string seq,exn>
// : DataReader 로 적었지만 FSI 는 함수 바인딩의 타입을 화살표 꼴로 풀어 보여 준다
// 아래 import 의 reader 처럼 매개변수에 붙인 타입 약어는 이름이 그대로 남는다
let memoryReader : DataReader =
    fun source ->
        if source = "intake-2024-03" then rows |> Seq.ofList |> Ok
        else Error (exn $"알 수 없는 데이터 출처: %s{source}")
```

- 검증이 붙으면 걸릴 행은 셋이다. 3행은 주소에 `@` 가 없고, 4행은 `Chilled` 칸이 `maybe` 이고, 6행은 `SampleId` 가 비어 있으면서 날짜와 수량도 읽을 수 없다. 검증이 없는 지금은 여섯 행 전부가 통과한다.
- 오류 하나만 들어 있는 행과 셋이 들어 있는 행을 함께 둔 것은 뒤에서 오류를 모으는 방식과 첫 오류에서 멈추는 방식을 구별하려는 것이다.

```fsharp id=08-intake
// FSI 실측: row: string -> RawSample option
let parseRow (row: string) : RawSample option =
    match row.Split('|') with
    | [| sampleId; email; chilled; collectedOn; volume |] ->
        Some { SampleId = sampleId
               ContactEmail = email
               Chilled = chilled
               CollectedOn = collectedOn
               VolumeMl = volume }
    | _ -> None

// FSI 실측: data: string seq -> RawSample seq
let parse (data: string seq) =
    data
    |> Seq.skip 1
    |> Seq.map parseRow
    |> Seq.choose id

// FSI 실측: data: RawSample seq -> unit
let output data =
    data
    |> Seq.iter (fun r ->
        printfn "%-7s %-20s %-6s %-11s %s"
            r.SampleId r.ContactEmail r.Chilled r.CollectedOn r.VolumeMl)

// FSI 실측: reader: DataReader -> source: string -> unit
let import (reader: DataReader) source =
    match source |> reader with
    | Ok data -> data |> parse |> output
    | Error ex -> printfn "읽기 실패: %s" ex.Message

import memoryReader "intake-2024-03"
// S-1041  choi@lab.example     Y      2024-03-02  12.5
// S-1042                       N      2024-03-04  8
// S-1043  park.at.lab.example  Y      2024-03-05  4.25
// S-1044  yun@lab.example      maybe  2024-03-06
// S-1045  seo@lab.example      N                  3.0
//                              Y      2024-13-45  -
```

- 출력을 보면 문제가 눈에 보인다. `maybe` 도, `2024-13-45` 도, 빈 `SampleId` 도 아무 저항 없이 지나간다. 파싱은 칸이 다섯 개인지만 확인했다.
- `parse` 의 시그니처가 `string seq -> RawSample seq` 라는 점을 기억해 두면 좋다. 이 챕터가 끝날 때 이 시그니처가 어떻게 바뀌는지가 작업의 결과다.

## Solving the Problem — 검증된 값을 담을 타입 (원서 p.105)

- 검증은 "확인"이 아니라 "변환"으로 생각하는 편이 낫다. 확인만 하고 원래 값을 그대로 쓰면 확인했다는 사실이 타입에 남지 않는다.
- 그래서 원서는 검증을 통과한 값만 담는 레코드를 따로 만든다. 문자열 칸이 각자의 타입으로 바뀌고, 비어도 되는 칸은 `Option` 이 된다.
- 비어도 되는 칸을 빈 문자열로 두지 않고 `Option` 으로 옮기는 것이 요점이다. "값이 없음"과 "빈 문자열"을 구별할 수 있게 된다.

```fsharp id=08-manual
// 이 단위가 보여주는 것: 원서가 이 챕터에서 완성하는 검증 파이프라인 전체
open System
open System.Globalization
open System.Text.RegularExpressions

type RawSample = {
    SampleId: string
    ContactEmail: string
    Chilled: string
    CollectedOn: string
    VolumeMl: string
}

// 검증을 통과한 값만 들어온다. 칸마다 제 타입이 있고, 없어도 되는 칸은 Option 이다
type ValidatedSample = {
    SampleId: string
    ContactEmail: string option
    Chilled: bool
    CollectedOn: DateTime option
    VolumeMl: decimal option
}
```

- `SampleId` 만 `string` 으로 남았다. 반드시 있어야 하는 칸이므로 `Option` 이 필요 없다. 9챕터에서는 이 `string` 마저 도메인 타입으로 감싸는 방법을 다룬다.
- `RawSample` 과 `ValidatedSample` 을 나란히 두면 검증이 무엇을 하는 일인지가 타입만 봐도 읽힌다. 왼쪽은 파일에서 방금 읽은 모양, 오른쪽은 프로그램이 믿고 쓸 수 있는 모양이다.

레코드를 만드는 함수를 따로 둔다. 뒤에서 이 함수를 부분 적용해 가며 조립하기 때문이다.

```fsharp id=08-manual
// FSI 실측: sampleId: string -> email: string option -> chilled: bool
//           -> collectedOn: System.DateTime option -> volume: decimal option -> ValidatedSample
let create sampleId email chilled collectedOn volume =
    { SampleId = sampleId
      ContactEmail = email
      Chilled = chilled
      CollectedOn = collectedOn
      VolumeMl = volume }
```

- 레코드 식으로 직접 만들 수도 있는데 함수를 따로 두는 이유는 시그니처다. 매개변수를 하나씩 받는 커링된 형태여야 뒤에서 인자를 하나씩 먹여 가며 조립할 수 있다.
- 필드 순서와 매개변수 순서를 맞춰 두어야 한다. 같은 타입의 칸이 이웃해 있으면 순서를 바꿔 넣어도 컴파일되므로, 이 함수를 쓰는 자리에서 실수하기 쉽다. 9챕터가 이 위험을 줄이는 방법을 다룬다.

## 오류를 판별 유니온으로 (원서 p.106)

- 실패 이유를 문자열로 두면 쓰는 쪽에서 문자열을 파싱해야 한다. 판별 유니온으로 두면 종류가 타입에 적히고 `match` 식에서 빠뜨린 케이스를 컴파일러가 잡아 준다. 3챕터에서 확립한 방식이다.
- 이 챕터에서 예상되는 실패는 두 가지다. 값이 없는 것과 값을 읽을 수 없는 것이다.
- 값이 없을 때는 어느 칸인지만 알면 되고, 읽을 수 없을 때는 어느 칸에 무엇이 적혀 있었는지 함께 알려 주는 편이 낫다. 그래서 케이스 데이터의 모양이 다르다.

```fsharp id=08-manual
type ValidationError =
    | MissingField of name: string
    | BadFormat of name: string * value: string
```

- 케이스 데이터에 이름(`name`, `value`)을 붙여 두면 읽는 쪽에서 무엇이 어느 자리인지 헷갈리지 않는다. 두 케이스 모두 첫 자리가 칸 이름이라는 규칙을 지켜 두면 오류를 사람이 읽을 문장으로 바꾸기도 쉽다.
- 실패 타입을 하나로 통일해 두는 것이 중요하다. 3챕터에서 봤듯이 `Result.bind` 로 이으려면 실패 타입이 같아야 하고, 다르면 `Result.mapError` 로 맞춰야 한다. 검증 함수를 처음부터 같은 실패 타입으로 만들어 두면 그 수고가 없어진다.

## 파싱을 부분 패턴으로 (원서 p.106)

- 문자열을 날짜나 수량으로 읽는 일은 실패할 수 있는 변환이다. 7챕터의 분류대로 부분 패턴이 맡을 자리다.
- `TryParse` 계열 메서드는 `bool * 'a` 튜플을 돌려준다. 그 튜플을 `option` 으로 바꾸고 이름을 바나나 클립으로 감싸면 그 판정을 `match` 식의 케이스 자리에서 쓸 수 있다.
- 정규식은 매개변수 있는 부분 액티브 패턴(parameterized partial active pattern)으로 한 번만 감싸 두고 패턴 문자열만 갈아 끼우는 편이 낫다. 7챕터에서 로그 한 줄을 파싱하던 패턴을 정규식 자체를 매개변수로 받는 꼴로 일반화한 것이다.

```fsharp id=08-patterns
// 이 단위가 보여주는 것: 문자열 해석을 부분 패턴으로 옮기기
open System
open System.Globalization
open System.Text.RegularExpressions

// FSI 실측: pattern: string -> input: string -> string list option
// 검사할 값이 마지막 매개변수여야 한다는 규칙을 지켰다
let (|Captures|_|) (pattern: string) (input: string) =
    let m = Regex.Match(input, pattern)
    if m.Success then
        m.Groups |> Seq.skip 1 |> Seq.map (fun g -> g.Value) |> List.ofSeq |> Some
    else None

printfn "%A" ("S-1041" |> (|Captures|_|) @"^S-(\d+)$")   // Some ["1041"]
printfn "%A" ("X-1041" |> (|Captures|_|) @"^S-(\d+)$")   // None
```

- `m.Groups` 의 0번은 매칭된 전체 문자열이고 1번부터가 캡처 그룹(capture group)이다. `Seq.skip 1` 로 0번을 버려 캡처 그룹만 리스트로 돌려준다.
- 바나나 클립째로 적으면 그냥 함수라서 패턴 자리 밖에서도 호출할 수 있다. 7챕터에서 확인한 성질이다.
- 6챕터에서 봤듯이 `Seq.skip` 은 원소가 모자라면 예외를 던진다. 여기서는 매칭이 성공했을 때만 이 줄에 닿고 그때는 0번 그룹이 반드시 있으므로 안전하다.

캡처 그룹 개수를 패턴 자리에 조건으로 적어 둘 수 있다는 것이 이 형태의 이점이다. 주소 판정은 캡처 그룹이 정확히 하나 잡힐 때만 성립하게 적는다.

```fsharp id=08-patterns
// FSI 실측: input: string -> string option
// 그룹 하나만 잡히는 경우로 한정하고, 잡힌 도메인을 돌려준다
let (|EmailLike|_|) input =
    match input with
    | Captures @"^[^@\s]+@([^@\s]+\.[^@\s]+)$" [ domain ] -> Some domain
    | _ -> None

// FSI 실측: input: string -> unit option
let (|NoValue|_|) (input: string) =
    if input.Trim() = "" then Some () else None

// FSI 실측: input: string -> bool option
let (|Flag|_|) (input: string) =
    match input.Trim().ToUpperInvariant() with
    | "Y" | "YES" -> Some true
    | "N" | "NO" -> Some false
    | _ -> None
```

- `[ domain ]` 은 리스트가 원소 하나인 경우만 받는 리스트 패턴이다. 부분 패턴이 돌려준 값에 다시 패턴을 적용한 것이며, 캡처 그룹이 정확히 하나일 때만 성립한다는 조건이 패턴에 적혀 있는 셈이다. 다만 정규식만 고쳐 그룹 개수를 바꾸면 컴파일러는 오류도 경고도 내지 않는다. 그때는 이 케이스가 성립하지 않아 `(|EmailLike|_|)` 가 언제나 `None` 을 돌려주므로, 정규식과 리스트 패턴은 함께 고쳐야 한다.
- `(|NoValue|_|)` 는 담아 보낼 값이 없어 `Some ()` 을 쓴다. 시그니처가 `unit option` 이 되고 패턴 자리에는 이름만 적는다.
- `(|Flag|_|)` 는 원서의 `1`/`0` 대신 `Y`/`N` 을 받는다. 어떤 표기를 참거짓으로 받아들일지는 도메인이 정하는 것이고, 그 규칙이 패턴 하나 안에 모여 있다는 점이 중요하다.

숫자와 날짜는 `TryParse` 를 감싼다. 문화권을 명시해 두면 실행 환경이 달라도 결과가 같다.

```fsharp id=08-patterns
// FSI 실측: input: string -> decimal option
let (|AsDecimal|_|) (input: string) =
    match Decimal.TryParse(input, NumberStyles.Number, CultureInfo.InvariantCulture) with
    | true, value -> Some value
    | _ -> None

// FSI 실측: input: string -> System.DateTime option
// TryParseExact 로 형식을 고정하면 2024-13-45 같은 값이 확실히 걸러진다
let (|AsDate|_|) (input: string) =
    match DateTime.TryParseExact(input, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None) with
    | true, value -> Some value
    | _ -> None
```

- 원서는 `Decimal.TryParse input` 과 `DateTime.TryParse` 를 그대로 쓴다. 현재 스레드의 문화권을 따르므로 판정만 갈리는 것이 아니라 값이 조용히 어긋난다. `"12.5"` 는 고정 문화권(`CultureInfo.InvariantCulture`)에서 12.5 로 읽히지만 `de-DE` 에서는 `.` 이 천 단위 구분 기호라 125 로 통과한다. `ko-KR` 은 고정 문화권과 결과가 같아 이 차이가 눈에 띄지 않고, 그래서 더 위험하다. 6챕터도 같은 이유로 문화권을 명시했다.
- `TryParse` 와 `TryParseExact` 의 차이도 크다. `TryParse` 는 여러 형식을 관대하게 받아들인다. `"03/04/2024"` 는 `en-US` 에서 3월 4일, `de-DE` 에서 4월 3일로 통과한다. 형식이 정해진 입력이라면 `TryParseExact` 로 못 박는 편이 검증에 맞다.

만들어 둔 패턴을 한 `match` 식에 늘어놓으면 각자 무엇을 잡아내는지 한눈에 보인다.

```fsharp id=08-patterns
// FSI 실측: input: string -> string
let describe (input: string) =
    match input with
    | NoValue -> "빈 칸"
    | Flag value -> $"참거짓 %b{value}"
    | AsDecimal value -> $"수량 %M{value}"
    | AsDate value -> $"""날짜 %s{value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)}"""
    | EmailLike domain -> $"주소 도메인 %s{domain}"
    | other -> $"해석 불가 '%s{other}'"

[ "  "; "Y"; "no"; "4.25"; "2024-03-05"; "choi@lab.example"; "2024-13-45"; "-" ]
|> List.iter (describe >> printfn "%s")
// 빈 칸
// 참거짓 true
// 참거짓 false
// 수량 4.25
// 날짜 2024-03-05
// 주소 도메인 lab.example
// 해석 불가 '2024-13-45'
// 해석 불가 '-'
```

- 이 다섯 패턴은 서로 겹치지 않으므로 여기서는 케이스 순서를 바꿔도 결과가 같다. 다만 겹치는 패턴이 있으면 위에 적은 케이스가 먼저 걸린다. 앞에서 말한 원서의 규칙처럼 `Flag` 가 `1`/`0` 을 참거짓으로 받으면 `AsDecimal` 과 겹치고, 그때는 둘의 순서가 판정을 가른다. 겹칠 수 있는 자리에서는 좁은 판정을 위에 둔다.
- 마지막 `| other ->` 가 필요하다. 케이스에 쓴 것이 모두 부분 패턴이므로 컴파일러는 이 `match` 식이 빠짐없다고 판단하지 않는다. 빼면 경고 FS0025 가 난다.

## 필드별 검증 함수 (원서 p.107)

- 검증 함수의 목표 시그니처는 `string -> Result<'a, ValidationError>` 다. `'a` 자리에는 칸마다 다른 검증된 타입이 온다. 문자열을 받아 제 타입의 값을 돌려주거나 왜 안 되는지 알려 준다.
- 함수마다 실패 타입이 `ValidationError` 하나로 같다. 이렇게 맞춰 두면 뒤에서 오류를 한 리스트에 모을 수 있다.
- 비어도 되는 칸과 그렇지 않은 칸의 차이가 반환 타입에 나타난다. 앞의 것은 `Result<'a option, _>`, 뒤의 것은 `Result<'a, _>` 다.

```fsharp id=08-manual
// 앞 단위에서 만든 패턴 여섯 개를 그대로 다시 둔다
let (|Captures|_|) (pattern: string) (input: string) =
    let m = Regex.Match(input, pattern)
    if m.Success then
        m.Groups |> Seq.skip 1 |> Seq.map (fun g -> g.Value) |> List.ofSeq |> Some
    else None

let (|EmailLike|_|) input =
    match input with
    | Captures @"^[^@\s]+@([^@\s]+\.[^@\s]+)$" [ domain ] -> Some domain
    | _ -> None

let (|NoValue|_|) (input: string) = if input.Trim() = "" then Some () else None

let (|Flag|_|) (input: string) =
    match input.Trim().ToUpperInvariant() with
    | "Y" | "YES" -> Some true
    | "N" | "NO" -> Some false
    | _ -> None

let (|AsDecimal|_|) (input: string) =
    match Decimal.TryParse(input, NumberStyles.Number, CultureInfo.InvariantCulture) with
    | true, value -> Some value
    | _ -> None

let (|AsDate|_|) (input: string) =
    match DateTime.TryParseExact(input, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None) with
    | true, value -> Some value
    | _ -> None
```

패턴이 준비되었으니 검증 함수는 짧게 적힌다. 판정 규칙이 패턴 이름에 들어 있어 함수 본문은 어느 오류를 낼지만 정한다.

```fsharp id=08-manual
// FSI 실측: sampleId: string -> Result<string,ValidationError>
let validateSampleId sampleId =
    if sampleId <> "" then Ok sampleId else Error (MissingField "SampleId")

// FSI 실측: email: string -> Result<string option,ValidationError>
// 비어 있으면 Ok None, 모양이 맞으면 Ok (Some ...), 그 밖은 오류다
let validateEmail email =
    match email with
    | NoValue -> Ok None
    | EmailLike _ -> Ok (Some email)
    | _ -> Error (BadFormat ("ContactEmail", email))

// FSI 실측: chilled: string -> Result<bool,ValidationError>
let validateChilled chilled =
    match chilled with
    | Flag value -> Ok value
    | _ -> Error (BadFormat ("Chilled", chilled))

// FSI 실측: collectedOn: string -> Result<System.DateTime option,ValidationError>
let validateCollectedOn collectedOn =
    match collectedOn with
    | NoValue -> Ok None
    | AsDate value -> Ok (Some value)
    | _ -> Error (BadFormat ("CollectedOn", collectedOn))

// FSI 실측: volume: string -> Result<decimal option,ValidationError>
// 가드 절을 붙여 형식과 값 범위를 함께 검사한다
let validateVolume volume =
    match volume with
    | NoValue -> Ok None
    | AsDecimal value when value > 0m -> Ok (Some value)
    | _ -> Error (BadFormat ("VolumeMl", volume))
```

- `validateEmail` 의 `EmailLike _` 는 패턴이 돌려준 도메인을 버린다. 여기서는 모양이 맞는지만 필요하다. 도메인을 쓸 곳이 생기면 `_` 자리에 이름을 넣으면 된다.
- `validateVolume` 은 형식 검사와 값 범위 검사를 한 케이스에 붙였다. `AsDecimal` 로 읽히더라도 `0` 이하면 이 케이스가 성립하지 않아 마지막 줄로 떨어진다. 부분 패턴과 가드 절을 함께 쓰면 이런 이중 조건이 한 줄에 들어간다.
- 다섯 함수의 반환 타입이 저마다 다르지만 실패 타입은 전부 `ValidationError` 다. 이 통일이 다음 절의 조립을 가능하게 한다.

## `create` 가 `Result` 를 받지 못한다 (원서 p.108)

- 검증 함수와 `create` 를 바로 이으면 컴파일되지 않는다. `create` 는 `string`, `bool`, `decimal option` 을 기다리는데 검증 함수가 주는 것은 그것들을 `Result` 로 감싼 값이다.
- 원서는 아래 `validateSample` 에 반환 타입 주석을 먼저 달아 둔다. 목표 타입을 못 박아 두면 반환 타입을 바꿔 컴파일만 통과시키는 길이 막히고, 어긋난 자리를 실제로 고쳐야 한다.
- 3챕터에서 본 구조와 같다. `Result` 를 내는 함수와 `Result` 를 모르는 함수를 이으려면 사이에 무언가를 끼워야 한다.

```fsharp
// 컴파일되지 않는다
let validateSample (raw: RawSample) : Result<ValidatedSample, ValidationError list> =
    let sampleId = raw.SampleId |> validateSampleId
    let email = raw.ContactEmail |> validateEmail
    let chilled = raw.Chilled |> validateChilled
    let collectedOn = raw.CollectedOn |> validateCollectedOn
    let volume = raw.VolumeMl |> validateVolume
    create sampleId email chilled collectedOn volume
// error FS0001: 이 식에는
//     'Result<ValidatedSample,ValidationError list>' 형식이 필요하지만
// 여기에서는
//     'ValidatedSample' 형식이 지정되었습니다.
```

- 반환 타입에 `ValidationError list` 를 적은 것도 의도된 것이다. 검증은 오류 하나만 알려 주면 충분하지 않다. 다섯 칸이 다 틀렸으면 다섯 개를 다 알려 줘야 접수 창구에서 한 번에 고칠 수 있다.
- 반환 타입 주석을 지우면 오류 메시지가 달라진다. 컴파일러가 `create` 의 첫 인자 자리를 짚어 `'string' 형식이 필요하지만 'Result<string,ValidationError>' 형식이 지정되었습니다` 라고 말한다. 주석이 있으면 식 전체를 짚고, 없으면 인자 자리를 짚는다.
- 3챕터의 `Result.bind` 로 다섯 함수를 이으면 컴파일은 되지만 실패 타입이 `ValidationError` 하나로 남는다. 첫 오류에서 `Error` 선로로 갈아타고 나머지 검증은 아예 실행되지 않는다. 이 방식과의 차이는 뒤에서 코드로 비교한다.

## 오류를 모아 한 번에 돌려주기 (원서 p.109)

- 원서는 먼저 지금까지 배운 것만으로 해법을 만든다. 검증 결과에서 오류만 뽑는 함수와 값만 뽑는 함수를 두고, 오류를 전부 모아 비어 있는지 확인한다.
- 오류가 없다고 확인한 뒤에 값을 꺼내므로 순서가 안전을 보장한다. 대신 그 보장이 타입에 적혀 있지 않다는 것이 이 해법의 약점이다.
- 5챕터의 `List.concat` 이 리스트의 리스트를 한 겹 벗겨 준다. 오류가 없는 검증은 빈 리스트를 내므로 자연히 사라진다.

```fsharp id=08-manual
// FSI 실측: result: Result<'a,'b> -> 'b list
// 오류가 없으면 빈 리스트다. List.concat 에서 저절로 없어진다
let errorsOf result =
    match result with
    | Ok _ -> []
    | Error e -> [ e ]

// FSI 실측: result: Result<'a,'b> -> 'a
// 부분 함수다. Error 를 주면 예외를 던진다
let valueOf result =
    match result with
    | Ok value -> value
    | Error _ -> failwith "오류가 없다고 확인한 뒤에만 부를 수 있다"
```

- `valueOf` 가 이 챕터의 부분 함수다. 시그니처는 `Result<'a,'b> -> 'a` 라고 적혀 있어 어떤 `Result` 든 값을 준다고 약속하지만, `Error` 를 받으면 지키지 못하고 예외를 던진다. 6챕터의 `Seq.skip` 과 같은 성격이다.
- 시그니처가 거짓말을 하는 함수를 손으로 만들었다는 것이 곧 이 해법을 고쳐야 하는 이유다. 챕터 후반의 두 방식은 이 함수를 아예 없앤다.
- 두 함수 모두 자동 일반화되어 `Result<'a,'b>` 를 받는다. `ValidationError` 에 묶이지 않으므로 다른 검증에도 그대로 쓸 수 있다.

```fsharp id=08-manual
// FSI 실측: raw: RawSample -> Result<ValidatedSample,ValidationError list>
let validateSample (raw: RawSample) : Result<ValidatedSample, ValidationError list> =
    let sampleId = raw.SampleId |> validateSampleId
    let email = raw.ContactEmail |> validateEmail
    let chilled = raw.Chilled |> validateChilled
    let collectedOn = raw.CollectedOn |> validateCollectedOn
    let volume = raw.VolumeMl |> validateVolume
    let errors =
        [ sampleId |> errorsOf
          email |> errorsOf
          chilled |> errorsOf
          collectedOn |> errorsOf
          volume |> errorsOf ]
        |> List.concat
    match errors with
    | [] ->
        Ok (create (valueOf sampleId) (valueOf email) (valueOf chilled)
                   (valueOf collectedOn) (valueOf volume))
    | _ -> Error errors
```

- 다섯 검증이 모두 실행된다. `let` 바인딩 다섯 줄이 서로를 기다리지 않으므로 한 칸이 틀려도 나머지 넷은 그대로 검사된다. 이것이 검증에 필요한 동작이다.
- `[ ... ] |> List.concat` 자리는 `List.collect errorsOf [ sampleId; ... ]` 로 줄일 수 없다. 다섯 검증의 성공 타입이 서로 달라 한 리스트에 담기지 않기 때문이다. 리스트에 담는 것은 `errorsOf` 를 지난 결과이며 그 타입은 모두 `ValidationError list` 로 같다.
- `match errors with | [] -> ... | _ -> ...` 는 빈 리스트와 그 밖으로 나뉘어 빠짐없다. `| _ -> Error errors` 자리에서 `errors` 가 비어 있지 않다는 것은 사람만 아는 사실이고 타입은 모른다.

검증을 파이프라인에 끼운다. `parse` 마지막에 `Seq.map validateSample` 한 줄을 더하는 것이 전부다.

```fsharp id=08-manual
let rows =
    [ "SampleId|ContactEmail|Chilled|CollectedOn|VolumeMl"
      "S-1041|choi@lab.example|Y|2024-03-02|12.5"
      "S-1042||N|2024-03-04|8"
      "S-1043|park.at.lab.example|Y|2024-03-05|4.25"
      "S-1044|yun@lab.example|maybe|2024-03-06|"
      "S-1045|seo@lab.example|N||3.0"
      "||Y|2024-13-45|-" ]

let parseRow (row: string) : RawSample option =
    match row.Split('|') with
    | [| sampleId; email; chilled; collectedOn; volume |] ->
        Some { SampleId = sampleId
               ContactEmail = email
               Chilled = chilled
               CollectedOn = collectedOn
               VolumeMl = volume }
    | _ -> None

// FSI 실측: data: string seq -> Result<ValidatedSample,ValidationError list> seq
// 출발점의 string seq -> RawSample seq 와 비교해 보면 이 챕터가 한 일이 시그니처에 드러난다
let parse (data: string seq) =
    data
    |> Seq.skip 1
    |> Seq.map parseRow
    |> Seq.choose id
    |> Seq.map validateSample
```

- 시그니처가 `RawSample seq` 에서 `Result<ValidatedSample, ValidationError list> seq` 로 바뀌었다. 쓰는 쪽은 이제 성공과 실패를 모두 다루지 않으면 컴파일되지 않는다.
- 파이프라인에 단계를 끼우는 비용이 한 줄이라는 점이 이 설계의 값어치다. 앞뒤 함수는 하나도 고치지 않았다.

오류를 사람이 읽을 문장으로 바꾸는 함수를 두고 결과를 출력한다.

```fsharp id=08-manual
// FSI 실측: error: ValidationError -> string
let describeError error =
    match error with
    | MissingField name -> $"%s{name} 칸이 비었다"
    | BadFormat (name, value) -> $"%s{name} 칸: '%s{value}' 형식 오류"

// FSI 실측: result: Result<ValidatedSample,ValidationError list> -> unit
let show result =
    match result with
    | Ok s ->
        let email = s.ContactEmail |> Option.defaultValue "-"
        let date =
            s.CollectedOn
            |> Option.map (fun d -> d.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture))
            |> Option.defaultValue "-"
        let volume = s.VolumeMl |> Option.map (fun v -> $"%M{v}") |> Option.defaultValue "-"
        printfn "통과  %-7s %-20s %-6b %-11s %s" s.SampleId email s.Chilled date volume
    | Error errors ->
        printfn "반송  %s" (errors |> List.map describeError |> String.concat "; ")

rows |> Seq.ofList |> parse |> Seq.iter show
// 통과  S-1041  choi@lab.example     true   2024-03-02  12.5
// 통과  S-1042  -                    false  2024-03-04  8
// 반송  ContactEmail 칸: 'park.at.lab.example' 형식 오류
// 반송  Chilled 칸: 'maybe' 형식 오류
// 통과  S-1045  seo@lab.example      false  -           3.0
// 반송  SampleId 칸이 비었다; CollectedOn 칸: '2024-13-45' 형식 오류; VolumeMl 칸: '-' 형식 오류
```

- 마지막 행에서 오류 세 개가 함께 나온 것이 이 해법의 성과다. 첫 오류에서 멈추는 방식이라면 `SampleId` 하나만 보고했을 것이다.
- 빈 칸이 `-` 로 나온 것은 `Option.defaultValue` 가 `None` 을 대신 채운 것이다. 값이 없다는 사실이 타입에 남아 있으므로 출력 단계에서 어떻게 보일지 고를 수 있다. 빈 문자열로 뭉개 두면 이 선택지가 없다.

## Where are we now? — 원서가 정리하는 지점 (원서 pp.110-114)

- 원서는 여기서 지금까지의 코드를 한 파일로 모아 다섯 페이지에 걸쳐 보여 준다. 위 `08-manual` 단위가 그 전체에 대응한다.
- 파일 안의 순서에 규칙이 있다. 타입 선언, 액티브 패턴, 검증 함수, 도우미 함수, 조립 함수, 파이프라인 순이다. F# 은 위에서 아래로만 이름이 보이므로 의존 방향이 그대로 순서가 된다.
- 원서는 이 코드가 잘 돌아가지만 F# 과 대부분의 함수형 언어에서 더 관용적인 방법이 있다고 말하며 다음 절로 넘어간다. 그 이름이 애플리커티브(applicative)다.
- 원서를 옆에 두고 읽을 때 걸리는 대목이 셋 있다. p.109 의 `ConversionError list` 는 오기이고 pp.110-113 은 다시 `ValidationError list` 다. p.104 의 `DataReader` 가 p.110 에서 `FileReader` 로 이름이 바뀌는데 이 노트는 6챕터를 따라 `DataReader` 로 둔다. pp.110-112 전체 코드에는 p.106 의 `(|IsValidDate|_|)` 가 빠져 있어 그대로 붙여 넣으면 컴파일되지 않는다.
- 이 지점에서 남은 문제를 정리해 두면 다음 절이 무엇을 고치는지 분명해진다. 첫째, `valueOf` 라는 부분 함수를 손으로 만들었다. 둘째, 칸이 하나 늘 때마다 `let` 한 줄, `errorsOf` 한 줄, `valueOf` 한 개를 세 곳에 나눠 적어야 한다. 셋째, 그 셋 중 하나를 빠뜨려도 컴파일은 통과한다.

## 오류 타입의 모양을 정하기 (원서 pp.114-116)

- 오류를 모으려면 실패 자리가 리스트여야 한다. 검증 함수 하나는 오류를 하나만 내므로 어딘가에서 리스트로 감싸는 일이 필요하다.
- 감싸는 자리는 두 곳 중 하나다. 검증 함수가 오류 하나를 내고 쓰는 쪽에서 `Result.mapError` 로 감싸든가, 검증 함수가 처음부터 오류 리스트를 내든가다.
- 원서는 둘 중 무엇을 고르든 상관없지만 하나로 통일하라고 말한다. 이 노트는 앞의 것을 고른다. 검증 함수를 다른 곳에서도 쓸 수 있게 남겨 두는 편이 낫다는 판단이다.

```fsharp id=08-compose
// 이 단위가 보여주는 것: 첫 오류에서 멈추는 방식과 오류를 모으는 방식의 차이
open System
open System.Globalization

type ValidationError =
    | MissingField of name: string
    | BadFormat of name: string * value: string

// 합성 방식만 비교하려고 칸을 세 개로 줄인 축소판이다. 검증 함수의 모양은 앞 단위와 같다
type Slip = { SampleId: string; Chilled: bool; VolumeMl: decimal }

// FSI 실측: sampleId: string -> chilled: bool -> volume: decimal -> Slip
let makeSlip sampleId chilled volume =
    { SampleId = sampleId; Chilled = chilled; VolumeMl = volume }

// FSI 실측: sampleId: string -> Result<string,ValidationError>
let validateSampleId sampleId =
    if sampleId <> "" then Ok sampleId else Error (MissingField "SampleId")

// FSI 실측: chilled: string -> Result<bool,ValidationError>
let validateChilled (chilled: string) =
    match chilled.Trim().ToUpperInvariant() with
    | "Y" -> Ok true
    | "N" -> Ok false
    | _ -> Error (BadFormat ("Chilled", chilled))

// FSI 실측: volume: string -> Result<decimal,ValidationError>
let validateVolume (volume: string) =
    match Decimal.TryParse(volume, NumberStyles.Number, CultureInfo.InvariantCulture) with
    | true, value when value > 0m -> Ok value
    | _ -> Error (BadFormat ("VolumeMl", volume))
```

오류 하나를 리스트로 감싸는 함수에는 이름을 붙여 둔다. 람다 식 `(fun e -> [ e ])` 를 쓸 수도 있지만 `List` 모듈에 있는 `List.singleton` 이 정확히 그 일을 한다.

```fsharp id=08-compose
// FSI 실측: result: Result<'a,'b> -> Result<'a,'b list>
// List.singleton 의 시그니처는 'a -> 'a list 이고 (fun e -> [ e ]) 와 같다
let asList result = result |> Result.mapError List.singleton
```

- `Result.mapError` 는 성공값은 그대로 두고 실패값에만 함수를 적용한다. 3챕터에서 실패 타입을 맞추는 어댑터로 쓴 것과 같은 함수이며, 여기서는 `ValidationError` 를 `ValidationError list` 로 넓히는 데 쓴다.
- 검증 함수가 처음부터 오류 리스트를 내게 만들면 이 감싸기가 사라져 조립 코드가 짧아진다. 대신 오류 하나만 필요한 다른 자리에서 쓰기 불편해진다. 원서가 말한 취향 문제가 이 맞바꿈이다.

## 첫 오류에서 멈추는 방식 (원서 p.117 확장)

- 3챕터의 `Result.bind` 로 검증 함수 셋을 이으면 첫 오류에서 멈춘다. 원서는 이 방식을 모나드 방식(monadic)이라 부른다.
- 시그니처가 증거다. 실패 타입이 `ValidationError` 하나로 남고 리스트가 되지 않는다. 오류를 둘 이상 담을 자리 자체가 없으니 이 조립으로는 모을 수 없다. 거꾸로 실패 타입이 리스트라고 해서 오류를 모으는 방식인 것은 아니다. 그 경우는 뒤에서 다시 본다.
- 이 방식이 나쁜 것이 아니다. 뒤 단계가 앞 단계의 결과에 의존할 때는 이것이 유일한 방법이다. 검증은 그런 작업이 아니라서 맞지 않는 것이다.

```fsharp id=08-compose
// FSI 실측: sampleId: string -> chilled: string -> volume: string
//           -> Result<Slip,ValidationError>
// 실패 자리가 리스트가 아니다. 오류를 하나만 담는다
let validateFirstError sampleId chilled volume =
    validateSampleId sampleId
    |> Result.bind (fun id ->
        validateChilled chilled
        |> Result.bind (fun cold ->
            validateVolume volume
            |> Result.map (fun ml -> makeSlip id cold ml)))
```

- `Result.bind` 는 앞 단계가 `Error` 면 넘긴 함수를 부르지 않는다. `validateSampleId` 가 실패하면 `validateChilled` 와 `validateVolume` 은 실행되지 않는다.
- 원인은 `Result.bind` 의 시그니처에 있다. 첫 매개변수가 `'a -> Result<'b,'c>` 이므로 뒤 계산은 앞 단계의 값을 받아야 비로소 만들어진다. 앞이 실패하면 그 값이 없어 뒤 계산을 만들 수조차 없다. `apply` 의 두 매개변수는 둘 다 이미 만들어진 `Result` 라서 이 의존이 없다.
- 마지막만 `Result.map` 인 것은 `makeSlip` 이 `Result` 를 내지 않기 때문이다. 3챕터에서 정리한 대로 넘기는 함수가 `Result` 를 내면 `bind`, 내지 않으면 `map` 이다.
- 중첩이 깊어지는 것도 눈에 걸린다. 칸이 다섯 개면 다섯 겹이 된다. 12챕터의 계산 식(computation expression)이 이 중첩을 평평하게 펴 준다.

## 오류를 모으는 방식 — 애플리커티브 (원서 p.114 확장)

- 오류를 모으려면 `Result` 두 개를 받아 둘 다 `Ok` 면 값을 적용하고 둘 다 `Error` 면 오류를 이어 붙이는 함수가 필요하다. 이 함수를 `apply` 라 부르고, 이 방식을 애플리커티브라 부른다.
- `Result.bind` 와의 차이는 함수를 부르는 시점이다. `bind` 는 앞 결과를 보고 다음 함수를 부를지 정하지만, `apply` 는 두 결과를 이미 손에 들고 합칠지 오류를 이어 붙일지만 정한다. 그래서 모든 검증이 실행된다.
- F# 5 의 `and!` 문법이 나오기 전에는 이 함수를 직접 만들어 썼다. 원서도 계산 식 이전의 관용적인 방식을 다룬 글을 소개하며 그 원리를 알아 둘 값어치가 있다고 말한다.

```fsharp id=08-compose
// FSI 실측: fResult: Result<('a -> 'b),'c list> -> xResult: Result<'a,'c list>
//           -> Result<'b,'c list>
// 성공 자리에 함수가 들어 있는 Result 를 받는다는 점이 map/bind 와 다르다
let apply fResult xResult =
    match fResult, xResult with
    | Ok f, Ok x -> Ok (f x)
    | Error left, Error right -> Error (left @ right)
    | Error left, Ok _ -> Error left
    | Ok _, Error right -> Error right
```

- 실패 타입이 `'c list` 로 유추되었다. `left @ right` 로 이어 붙이므로 컴파일러가 리스트라고 판단한 것이다. 오류를 모으는 방식이라는 사실이 시그니처에 저절로 적혔다.
- 네 케이스 중 두 번째가 이 함수의 핵심이다. 양쪽이 다 실패했을 때 하나를 버리지 않고 둘을 이어 붙인다. `Result.bind` 에는 이 자리가 없다.
- 첫 매개변수가 `Result<('a -> 'b), 'c list>` 라는 것이 이 방식의 요령이다. 성공 자리에 함수를 담아 두면 인자를 하나씩 먹여 가며 조립할 수 있다. 2챕터의 부분 적용이 `Result` 안에서 일어나는 셈이다.

관용적으로 쓰이는 연산자 이름을 붙이면 조립이 한 줄로 읽힌다.

```fsharp id=08-compose
// FSI 실측: f: ('a -> 'b) -> result: Result<'a,'c> -> Result<'b,'c>
let (<!>) f result = Result.map f result

// FSI 실측: fResult: Result<('a -> 'b),'c list> -> xResult: Result<'a,'c list>
//           -> Result<'b,'c list>
let (<*>) fResult xResult = apply fResult xResult

// FSI 실측: sampleId: string -> chilled: string -> volume: string
//           -> Result<Slip,ValidationError list>
// 실패 자리가 리스트다. 오류를 몇 개든 담는다
let validateAll sampleId chilled volume =
    makeSlip
    <!> asList (validateSampleId sampleId)
    <*> asList (validateChilled chilled)
    <*> asList (validateVolume volume)
```

- `<!>` 는 `Result.map` 의 다른 이름이다. `makeSlip <!> asList (validateSampleId sampleId)` 까지의 타입을 실측하면 `Result<(bool -> decimal -> Slip), ValidationError list>` 다. 세 인자 중 하나를 먹은 함수가 `Result` 안에 남았다.
- 이후 `<*>` 가 남은 인자를 하나씩 먹인다. 마지막 `<*>` 를 지나면 함수가 다 채워져 `Result<Slip, ValidationError list>` 가 된다.
- 두 연산자 모두 `<` 로 시작하므로 우선순위가 같고 왼쪽부터 묶인다. 그래서 괄호 없이 위에서 아래로 읽으면 된다.
- 매개변수를 생략하고 `let (<!>) = Result.map` 으로 적어도 통과한다. 다만 FSI 실측 시그니처가 `(('a -> 'b) -> Result<'a,'c> -> Result<'b,'c>)` 처럼 바깥 괄호가 붙은 함수 타입 값이 된다. 매개변수를 적어 함수로 정의하는 쪽이 시그니처가 깔끔하고, 뒤에서 부분 적용해 쓸 때 헷갈리지 않는다.

두 방식을 같은 입력에 걸어 보면 차이가 그대로 드러난다.

```fsharp id=08-compose
// FSI 실측: errors: ValidationError list -> string
let fieldNames errors =
    errors
    |> List.map (fun e -> match e with MissingField name -> name | BadFormat (name, _) -> name)
    |> String.concat ", "

// 실패 자리의 모양이 달라 출력 함수도 따로 만들어야 한다. 그 점이 곧 시그니처 차이다
let showFirst label result =
    match result with
    | Ok slip -> printfn "%-10s 통과 %s %b %M" label slip.SampleId slip.Chilled slip.VolumeMl
    | Error error -> printfn "%-10s 반송 1건 — %s" label (fieldNames [ error ])

let showAll label result =
    match result with
    | Ok slip -> printfn "%-10s 통과 %s %b %M" label slip.SampleId slip.Chilled slip.VolumeMl
    | Error errors -> printfn "%-10s 반송 %d건 — %s" label (List.length errors) (fieldNames errors)

showFirst "bind" (validateFirstError "" "maybe" "-")
showAll "apply" (validateAll "" "maybe" "-")
showFirst "bind" (validateFirstError "S-1041" "Y" "12.5")
showAll "apply" (validateAll "S-1041" "Y" "12.5")
// bind       반송 1건 — SampleId
// apply      반송 3건 — SampleId, Chilled, VolumeMl
// bind       통과 S-1041 true 12.5
// apply      통과 S-1041 true 12.5
```

- 성공하는 입력에서는 두 방식의 결과가 같다. 갈라지는 것은 실패할 때다.
- 출력 함수를 두 개 만들어야 했던 것이 시그니처 차이의 실제 비용이다. `Error` 안에 든 것이 `ValidationError` 냐 `ValidationError list` 냐가 다르므로 `match` 식의 두 번째 케이스가 서로 호환되지 않는다.
- 접수 창구에서 원하는 것은 `apply` 쪽이다. 접수자가 한 번에 세 칸을 고칠 수 있다.

## Functional Validation the F# Way — `validation` 계산 식 (원서 pp.116-117)

- `apply` 를 손으로 만드는 대신 F# 5 부터는 계산 식의 `and!` 문법으로 같은 일을 한다. 원서가 관용적이라고 말하는 방식이 이것이다.
- `let!` 은 `Result` 안의 값을 꺼내 이름에 묶는다. `let!` 을 연달아 쓰면 뒷줄이 앞줄의 값을 쓸 수 있다. 그 값이 없으면 뒷줄을 만들 수 없으므로 앞줄이 실패하는 순간 멈춘다. `and!` 는 뒷줄이 앞줄의 값을 쓰지 않겠다는 선언이어서 모든 줄이 평가되고 오류가 모인다.
- 계산 식 자체는 12챕터에서 다룬다. 여기서는 `let!` 과 `and!` 의 차이만 보아 두면 된다. `let!` 은 계산 식 빌더의 `Bind` 멤버를, `and!` 는 `MergeSources` 멤버를 부른다. 12챕터는 `Bind`·`Return`·`ReturnFrom` 세 멤버로 빌더를 직접 만들어 `let!` 쪽이 어떻게 도는지 확인하고, 그 자리에서 이 챕터의 `and!` 를 다시 짚는다. 원서가 12챕터를 마치면 이 챕터의 검증 예제로 돌아오라고 권하는 것도 그래서다.
- 검증용 계산 식은 언어에 들어 있지 않다. `FsToolkit.ErrorHandling` 패키지가 `validation` 이라는 이름으로 제공한다. 그래서 아래 블록은 이 챕터에서 유일하게 외부 패키지가 필요하다. 처음 한 번은 네트워크가 있어야 패키지를 받아 오고, 그 뒤에는 로컬 NuGet 캐시에 있는 것을 쓴다. 받아 오지 못하면 `error FS0999` 로 실패한다.

```fsharp id=08-validation-ce
// 이 단위가 보여주는 것: validation 계산 식의 let! 과 and!
// 프로젝트에서는 dotnet add package FsToolkit.ErrorHandling 로 넣는다
#r "nuget: FsToolkit.ErrorHandling, 5.2.0"

open System
open System.Globalization
open FsToolkit.ErrorHandling.ValidationCE

type ValidationError =
    | MissingField of name: string
    | BadFormat of name: string * value: string

type Slip = { SampleId: string; Chilled: bool; VolumeMl: decimal }

let makeSlip sampleId chilled volume =
    { SampleId = sampleId; Chilled = chilled; VolumeMl = volume }

let validateSampleId sampleId =
    if sampleId <> "" then Ok sampleId else Error (MissingField "SampleId")

let validateChilled (chilled: string) =
    match chilled.Trim().ToUpperInvariant() with
    | "Y" -> Ok true
    | "N" -> Ok false
    | _ -> Error (BadFormat ("Chilled", chilled))

let validateVolume (volume: string) =
    match Decimal.TryParse(volume, NumberStyles.Number, CultureInfo.InvariantCulture) with
    | true, value when value > 0m -> Ok value
    | _ -> Error (BadFormat ("VolumeMl", volume))

let asList result = result |> Result.mapError List.singleton
```

- 스크립트에서는 `#r "nuget: ..."` 로 패키지를 끌어온다. 버전을 못 박아 둔 것은 새 버전이 올라올 때 `open` 경로나 실측 시그니처 주석이 예고 없이 어긋나는 것을 막기 위한 것이다. 프로젝트라면 원서대로 `dotnet add package` 를 쓴다.
- `open FsToolkit.ErrorHandling.ValidationCE` 는 `validation` 계산 식만 들여온다. 그래서 `Validation<'a,'e>` 라는 타입 약어 이름은 아직 보이지 않고, 그 이름을 코드에 적으면 `error FS0039` 가 난다. 약어까지 쓰려면 `open FsToolkit.ErrorHandling` 이 필요하다. 아래에서 반환 타입을 `Result<Slip, ValidationError list>` 로 적은 것도 그래서다.
- 준비 코드는 앞 단위와 같다. 달라지는 것은 조립 방식뿐이다.
- `asList` 는 장식이 아니라 필수 단계다. 이 계산 식은 실패 자리가 리스트인 값을 요구하므로 `Result<string, ValidationError>` 를 그대로 넘기면 `error FS0001` 이 난다. 패키지가 같은 일을 하는 `Validation.ofResult` 를 제공하지만, 그 이름 역시 `open FsToolkit.ErrorHandling` 이 있어야 보인다.

```fsharp id=08-validation-ce
// FSI 실측(반환 타입 주석을 지우면): sampleId: string -> chilled: string -> volume: string
//           -> FsToolkit.ErrorHandling.Validation<Slip,ValidationError>
// Validation<'a,'e> 는 Result<'a,'e list> 의 타입 약어다. 그래서 아래 주석이 그대로 통과한다
let validateSlip sampleId chilled volume : Result<Slip, ValidationError list> =
    validation {
        let! id = validateSampleId sampleId |> asList
        and! cold = validateChilled chilled |> asList
        and! ml = validateVolume volume |> asList
        return makeSlip id cold ml
    }
```

- `let!` 의 느낌표는 `Result` 라는 껍데기를 벗기라는 표시다. `id` 의 타입은 `string` 이다. 느낌표를 떼면 `id` 가 `Result<string, ValidationError list>` 가 되고 `makeSlip` 에 넣을 수 없게 된다.
- 첫 줄만 `let!` 이고 나머지가 `and!` 다. `and!` 는 앞줄의 결과에 기대지 않겠다는 선언이며, 그 덕에 세 검증이 모두 실행된다. 병렬로 돈다는 뜻은 아니다. 세 오른쪽 식은 같은 스레드에서 위에서 아래로 차례로 평가된다. 진짜 병렬이 필요하면 같은 패키지의 `parallelAsyncValidation` 계산 식이 따로 있다.
- `return` 은 계산 식 안에서만 쓰는 낱말이고, F# 에서 `return` 이 필요한 자리는 계산 식뿐이다.
- 반환 타입을 `Result<Slip, ValidationError list>` 로 적어도 통과한다. 패키지가 정한 `Validation<'a,'e>` 는 `Result<'a,'e list>` 에 붙인 타입 약어이므로 같은 타입이다.

`and!` 를 `let!` 로 바꾸면 방금 만든 것이 모나드 방식으로 되돌아간다. 한 낱말이 동작을 가른다.

```fsharp id=08-validation-ce
// 세 줄 모두 let! 이다. 앞줄이 실패하면 뒷줄은 실행되지 않는다
let validateSlipStopping sampleId chilled volume : Result<Slip, ValidationError list> =
    validation {
        let! id = validateSampleId sampleId |> asList
        let! cold = validateChilled chilled |> asList
        let! ml = validateVolume volume |> asList
        return makeSlip id cold ml
    }

let fieldNames errors =
    errors
    |> List.map (fun e -> match e with MissingField name -> name | BadFormat (name, _) -> name)
    |> String.concat ", "

let show label result =
    match result with
    | Ok slip -> printfn "%-12s 통과 %s %b %M" label slip.SampleId slip.Chilled slip.VolumeMl
    | Error errors -> printfn "%-12s 반송 %d건 — %s" label (List.length errors) (fieldNames errors)

show "and! 수집" (validateSlip "" "maybe" "-")
show "let! 멈춤" (validateSlipStopping "" "maybe" "-")
show "and! 통과" (validateSlip "S-1041" "Y" "12.5")
// and! 수집      반송 3건 — SampleId, Chilled, VolumeMl
// let! 멈춤      반송 1건 — SampleId
// and! 통과      통과 S-1041 true 12.5
```

- 두 함수의 시그니처가 같다는 점을 눈여겨볼 만하다. 둘 다 `Result<Slip, ValidationError list>` 를 낸다. 계산 식 안이 `Validation` 으로 통일되어 있어 실패 자리가 이미 리스트이기 때문이다.
- 그래서 `let!` 판은 리스트를 낼 수 있는데도 원소를 하나만 담는다. 앞 절의 `Result.bind` 판은 애초에 리스트를 담을 자리가 없었다. 같은 "첫 오류에서 멈춘다"가 타입에 드러나는 정도가 다르다.
- 이 코드가 하는 일은 `08-manual` 단위의 `validateSample` 과 정확히 같다. `errorsOf`, `valueOf`, `List.concat`, 빈 리스트 검사가 전부 사라졌고 부분 함수도 없어졌다.

## 검증 결과 여러 개를 모으기 (원서 p.109 확장)

- 파이프라인의 결과는 `Result` 의 시퀀스다. 시료 하나하나의 성패는 알 수 있지만 "몇 건 통과했나", "전부 통과했나" 같은 질문에는 한 번 더 모아야 답할 수 있다.
- 5챕터의 `List.choose` 와 `List.collect` 로 통과분과 반송분을 갈라낼 수 있다. 오류 쪽은 리스트의 리스트이므로 `List.collect` 가 한 겹 벗겨 준다.
- 한 건이라도 틀리면 전량을 반송해야 하는 요구라면 `apply` 와 같은 논리를 리스트 수준으로 올린 함수를 쓴다. `List.fold` 한 번으로 만들 수 있다.

```fsharp id=08-collect
// 이 단위가 보여주는 것: Result 의 컬렉션을 List 함수로 모으는 두 방식
// 앞 파이프라인이 낸 결과를 오류 타입만 string 으로 줄여 적은 값이다. 6행은 오류가 세 개다
let results : Result<string, string list> list =
    [ Ok "S-1041"
      Ok "S-1042"
      Error [ "3행 ContactEmail" ]
      Error [ "4행 Chilled" ]
      Ok "S-1045"
      Error [ "6행 SampleId"; "6행 CollectedOn"; "6행 VolumeMl" ] ]

// FSI 실측: items: Result<'a,'b list> list -> 'a list * 'b list
let partitionResults items =
    let accepted = items |> List.choose (fun r -> match r with Ok v -> Some v | Error _ -> None)
    let rejected = items |> List.collect (fun r -> match r with Ok _ -> [] | Error e -> e)
    accepted, rejected

let accepted, rejected = partitionResults results
printfn "통과 %d건: %s" (List.length accepted) (String.concat ", " accepted)
printfn "반송 %d건: %s" (List.length rejected) (String.concat " / " rejected)
// 통과 3건: S-1041, S-1042, S-1045
// 반송 5건: 3행 ContactEmail / 4행 Chilled / 6행 SampleId / 6행 CollectedOn / 6행 VolumeMl
```

- 통과분은 3건인데 오류는 5건이다. 반송된 시료 수와 오류 수가 다르다는 것이 오류를 모으는 방식의 성질이다. 첫 오류에서 멈추는 방식이었다면 두 수가 같았을 것이다.
- 반환값을 튜플로 두면 두 결과를 한 번에 받을 수 있다. `let accepted, rejected = ...` 로 바로 풀어 쓴다.

전량 판정은 `apply` 의 네 케이스를 그대로 `List.fold` 안에 옮긴 모양이 된다.

```fsharp id=08-collect
// FSI 실측: items: Result<'a,'b list> list -> Result<'a list,'b list>
// 상태와 원소가 모두 Result 이고, 둘 다 실패면 오류를 이어 붙인다
let sequence items =
    let folder state item =
        match state, item with
        | Ok values, Ok value -> Ok (values @ [ value ])
        | Ok _, Error errors -> Error errors
        | Error errors, Ok _ -> Error errors
        | Error left, Error right -> Error (left @ right)
    items |> List.fold folder (Ok [])

printfn "%A" (sequence [ Ok "S-1041"; Ok "S-1042" ])
// Ok ["S-1041"; "S-1042"]

match sequence results with
| Ok values -> printfn "전량 통과: %d건" (List.length values)
| Error errors -> printfn "전량 반송: 오류 %d건" (List.length errors)
// 전량 반송: 오류 5건
```

- `Result<'a,'b list> list -> Result<'a list,'b list>` 라는 시그니처를 잘 보면 `Result` 와 `list` 의 안팎이 뒤집혔다. 함수형 언어에서는 이렇게 뒤집는 함수를 `sequence` 라 부르고, 원소마다 함수를 적용한 뒤 뒤집는 것을 `traverse` 라 부른다. 컬렉션 타입 `seq` 와는 상관이 없는 이름이다.
- 방금 만든 것은 오류를 모으는 판이다. 첫 오류에서 멈추는 판도 같은 이름으로 불리므로, `FsToolkit.ErrorHandling` 은 `List.sequenceResultA`(모으는 판)와 `List.sequenceResultM`(멈추는 판)처럼 접미사로 둘을 가른다.
- 네 케이스가 `apply` 와 같은 규칙이다. 애플리커티브를 이해해 두면 이런 함수를 필요할 때 만들 수 있다는 것이 원서가 말한 값어치다.
- `values @ [ value ]` 는 리스트 끝에 붙이는 연산이라 원소 수에 비례하는 비용이 든다. 원소가 많으면 앞에 붙인 뒤 마지막에 `List.rev` 하는 편이 낫다. 5챕터에서 짚은 연결 리스트의 성질이다.

## Summary — 원서의 챕터 요약 (원서 p.117)

- 원서는 이 챕터에서 액티브 패턴으로 검증을 붙이는 방법과, 데이터 처리 파이프라인에 기능을 더하는 일이 얼마나 간단한지를 다뤘다고 정리한다.
- 그리고 F# 5 의 계산 식 지원을 쓴 애플리커티브 방식의 해법이 처음 만든 해법보다 우아하다고 덧붙인다.
- 다음 챕터에서는 1챕터의 코드를 도메인 낱말에 가깝게 고치고 원시 타입 사용을 줄이는 방법을 살펴본다.

## 정리 — 이 노트의 요약

- 검증은 확인이 아니라 변환이다. 문자열만 담은 레코드를 받아 칸마다 제 타입이 붙은 레코드로 옮기고, 비어도 되는 칸은 `Option` 으로 만든다. 검증했다는 사실이 타입에 남는다.
- 검증 함수의 목표 시그니처는 `string -> Result<'a, ValidationError>` 이고 `'a` 는 칸마다 다르다. 실패 이유는 판별 유니온으로 두고 함수 전부가 같은 실패 타입을 쓰게 맞춰 둔다.
- 문자열 해석은 부분 패턴이 맡는다. 정규식은 매개변수 있는 부분 패턴으로 한 번만 감싸 두고 패턴 문자열을 갈아 끼운다. `TryParse` 는 문화권을 명시하고, 형식이 정해진 입력이라면 `TryParseExact` 가 검증에 맞다.
- 검증 함수와 레코드 생성 함수는 그대로 이어지지 않는다(오류 FS0001). 생성 함수는 `Result` 를 모르고 검증 함수는 `Result` 를 낸다.
- 원서가 먼저 내놓는 해법은 오류만 뽑는 함수와 값만 뽑는 함수를 두고 `List.concat` 으로 오류를 모으는 것이다. 돌아가지만 값을 뽑는 함수가 부분 함수이며, 칸이 늘 때마다 세 곳을 고쳐야 하고 하나를 빠뜨려도 컴파일이 통과한다.
- `Result.bind` 로 이으면 첫 오류에서 멈춘다. 실측 시그니처가 `... -> Result<Slip, ValidationError>` 로 실패 자리에 리스트가 없다. 오류를 둘 이상 담을 자리 자체가 없다는 뜻이다.
- 오류를 모으려면 `apply` 가 필요하다. 실측 시그니처는 `Result<('a -> 'b),'c list> -> Result<'a,'c list> -> Result<'b,'c list>` 이고, 양쪽이 다 실패했을 때 오류를 이어 붙이는 케이스가 이 함수의 핵심이다. `<!>`(`Result.map`)와 `<*>`(`apply`)를 이어 쓰면 생성 함수에 인자를 하나씩 먹여 조립할 수 있다.
- 오류 하나를 리스트로 넓히는 데는 `Result.mapError List.singleton` 을 쓴다. 검증 함수가 처음부터 리스트를 내게 만드는 선택도 있고, 어느 쪽이든 하나로 통일하는 것이 중요하다.
- F# 5 의 `and!` 는 `apply` 를 문법으로 감싼 것이다. `validation` 계산 식 안에서 `let!` 을 연달아 쓰면 뒷줄이 앞줄의 값에 의존해 첫 오류에서 멈추고, `and!` 로 이으면 의존이 끊겨 모든 줄이 평가되고 오류가 모인다. 병렬로 도는 것이 아니라 의존이 없어지는 것이다. 이 `validation` 계산 식은 `FsToolkit.ErrorHandling` 패키지가 제공하며, 그 `Validation<'a,'e>` 는 `Result<'a,'e list>` 의 타입 약어다.
- `return` 이 필요한 자리는 F# 에서 계산 식뿐이다.
- 파이프라인에 검증을 끼우는 비용은 `Seq.map validateSample` 한 줄이다. 대신 `parse` 의 시그니처가 `string seq -> RawSample seq` 에서 `string seq -> Result<ValidatedSample, ValidationError list> seq` 로 바뀌어 쓰는 쪽이 실패를 다루지 않을 수 없게 된다.
- `Result` 의 컬렉션은 `List.choose` 와 `List.collect` 로 통과분과 오류로 갈라낸다. 전량 판정이 필요하면 `Result<'a,'b list> list -> Result<'a list,'b list>` 로 안팎을 뒤집는 함수를 `List.fold` 로 만든다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Setting Up — 검증을 붙일 자리 | pp.103-105 | `08-intake` |
| Solving the Problem — 검증된 값을 담을 타입 | p.105 | `08-manual` |
| 오류를 판별 유니온으로 | p.106 | `08-manual` |
| 파싱을 부분 패턴으로 | p.106 | `08-patterns` |
| 필드별 검증 함수 | p.107 | `08-manual` |
| `create` 가 `Result` 를 받지 못한다 | p.108 | — |
| 오류를 모아 한 번에 돌려주기 | p.109 | `08-manual` |
| Where are we now? — 원서가 정리하는 지점 | pp.110-114 | `08-manual` |
| 오류 타입의 모양을 정하기 | pp.114-116 | `08-compose` |
| 첫 오류에서 멈추는 방식 | p.117 확장 | `08-compose` |
| 오류를 모으는 방식 — 애플리커티브 | p.114 확장 | `08-compose` |
| Functional Validation the F# Way — `validation` 계산 식 | pp.116-117 | `08-validation-ce` |
| 검증 결과 여러 개를 모으기 | p.109 확장 | `08-collect` |
| Summary — 원서의 챕터 요약 | p.117 | — |
