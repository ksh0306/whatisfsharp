# 12 - 계산 식 (원서 pp.153-165)

> 3챕터가 `Option` 과 `Result` 를 세우고 실패를 값으로 다루는 법을 알려 준 뒤로, 노트는 줄곧 `map` 과 `bind` 로 그 값을 이어 왔다. 이 방식은 정확하지만 함수가 네다섯 개로 늘어나면 파이프라인이 익명 함수와 괄호로 덮인다. 8챕터 후반에서 중첩이 다섯 겹까지 깊어지는 것도 이미 봤다. 계산 식(computation expression)은 그 이음매를 문법 설탕(syntactic sugar)으로 감춰 준다. 감추는 것은 실패 선로뿐이고 하는 일은 조금도 바뀌지 않는다. 이 챕터는 `Option` 용 계산 식 빌더를 직접 만들어 그 안을 들여다보고, 같은 문법이 `Result` 와 `Async` 에도 그대로 통하는 것을 확인한 뒤, 효과 둘을 겹친 `asyncResult` 까지 간다.

읽기 전에 챕터 둘을 전제한다.

- 3챕터의 `Option`·`Result`, `bind`·`map`·`mapError` 의미론, 그리고 여러 함수를 이으려면 실패 타입을 하나로 맞춰야 한다는 사정. 계산 식은 이 셋을 없애 주는 것이 아니라 부르는 자리를 감춰 주는 것이다.
- 8챕터의 `validation` 계산 식. 원서 p.153 이 이 챕터를 마치면 8챕터 검증 예제를 다시 보라고 권한다. 그쪽에서 `let!` 과 `and!` 의 차이는 이미 다뤘고, 여기서는 그 문법이 어느 멤버를 부르는지를 본다.

용어 하나를 먼저 못 박는다. 이 챕터에서 효과(effect)는 `Option`·`Result`·`Async` 처럼 값을 한 겹 감싸 성패나 비동기 같은 맥락을 함께 나르는 타입을 가리킨다. 원서 p.153 의 낱말이다. 3챕터부터 써 온 부수 효과(side effect)와는 다른 것이므로 이 노트는 부수 효과를 줄여 쓰지 않는다.

## Setting Up — 준비 (원서 p.153)

- 원서는 콘솔 프로젝트를 만들고 `OptionDemo.fs`·`ResultDemo.fs`·`AsyncDemo.fs`·`AsyncResultDemo.fs` 를 차례로 얹으며 `dotnet run` 으로 확인한다.
- 이 노트는 파일을 만들지 않고 FSI 스크립트로 확인한다. 원서의 네임스페이스와 모듈 구획은 실행 단위 구획으로 대신한다.
- 뒤쪽 두 절은 `FsToolkit.ErrorHandling` 패키지가 필요하다. 원서는 `dotnet add package` 를 쓰고 이 노트는 `#r "nuget: ..."` 로 버전을 못 박아 끌어온다. 처음 한 번은 네트워크가 있어야 패키지를 받아 오고 그 뒤에는 로컬 NuGet 캐시로 돈다. 받아 오지 못하면 `error FS0999` 로 실패한다.

## Introduction — 손으로 이은 파이프라인 (원서 pp.153-155)

- 출발점은 효과를 내는 함수와 내지 않는 함수가 섞인 파이프라인이다. 그대로 이으면 컴파일되지 않는다.
- 원서는 같은 함수를 세 번 다시 쓴다. `match` 로 펼친 것, `Option.map`/`Option.bind` 로 줄인 것, 계산 식으로 감싼 것이다. 세 번 다 결과가 같다는 점이 이 절의 요지다.
- 소재는 곡물 창고다. 총 중량을 트럭 수로 나눠 한 대에 실을 무게를 구하고, 덮개 무게를 더한 뒤, 그 무게를 자루 수로 다시 나눈다. 나눗셈이 두 번 나오므로 `0` 으로 나누는 경우가 두 번 생기고, 그것이 `Option` 을 쓸 이유가 된다.

```fsharp id=12-option-manual
// 이 단위가 보여주는 것: 효과를 계산 식 없이 잇는 두 방법과 그 결과가 같다는 것
// FSI 실측: split: total: int -> parts: int -> int option
let split total parts =
    if parts = 0 then None else Some (total / parts)

// FSI 실측: withCover: load: int -> int
let withCover load = load + 3
```

`split` 은 효과를 만드는 함수이고 `withCover` 는 만들지 않는 함수다. 이 차이가 뒤에 나오는 모든 판단의 기준이 된다. 두 함수를 그냥 이으면 다음처럼 되는데 이것은 컴파일되지 않는다.

```fsharp
let perSack total trucks sacks =
    split total trucks
    |> fun load -> withCover load          // error FS0001
    |> fun covered -> split covered sacks
```

`split total trucks` 가 내놓는 것은 `int option` 인데 `withCover` 는 `int` 를 받는다. 오류는 `'int' 형식이 필요하지만 ... 'int option' 형식이 지정되었습니다` 다. 위 블록의 마지막 줄이 익명 함수를 쓰는 것은 `split` 의 매개변수 순서가 앞으로 파이프하기에 맞지 않아서다. 파이프된 값이 둘째 자리에 들어가야 하므로 이름으로 받아 넘긴다. 이 군더더기도 계산 식이 없애 줄 것 가운데 하나다.

`match` 로 펼치면 컴파일된다. 코드는 길어지지만 무슨 일이 벌어지는지가 남김없이 드러난다.

```fsharp id=12-option-manual
// FSI 실측: perSackMatched: total: int -> trucks: int -> sacks: int -> int option
let perSackMatched total trucks sacks =
    split total trucks
    |> fun r ->
        match r with
        | Some load -> withCover load |> Some
        | None -> None
    |> fun r ->
        match r with
        | Some covered -> split covered sacks
        | None -> None
```

`trucks = 0` 인 경우를 따라가 보면 이 함수의 성격이 보인다. `trucks = 0` 이면 첫 `split` 이 `None` 을 내고, 그 뒤 두 `match` 는 `None` 갈래만 지난다. `withCover` 도 두 번째 `split` 도 아예 호출되지 않는다. 함수 중간에서 빠져나가는 조기 반환(early return)이 일어난 것이 아니다. 조기 반환은 F# 에 없다. 두 `match` 는 끝까지 평가되고, 다만 `None` 갈래가 아무것도 부르지 않는 것이다.

두 `match` 의 모양은 3챕터에서 본 것과 똑같다. 효과를 만들지 않는 함수를 적용하는 자리는 `Option.map` 이고 만드는 함수를 적용하는 자리는 `Option.bind` 다.

```fsharp id=12-option-manual
// FSI 실측: perSackPiped: total: int -> trucks: int -> sacks: int -> int option
let perSackPiped total trucks sacks =
    split total trucks
    |> Option.map withCover
    |> Option.bind (fun covered -> split covered sacks)

// %A 에는 폭 지정이 먹지 않으므로 sprintf 로 문자열을 만든 뒤 %-9s 로 폭을 맞춘다
let show label a b = printfn "%-9s %-9s %s" label (sprintf "%A" a) (sprintf "%A" b)
show "trucks=0" (perSackMatched 900 0 5) (perSackPiped 900 0 5)
show "sacks=0"  (perSackMatched 900 3 0) (perSackPiped 900 3 0)
show "ok"       (perSackMatched 900 3 5) (perSackPiped 900 3 5)
// trucks=0  None      None
// sacks=0   None      None
// ok        Some 60   Some 60
```

세 줄 모두 두 함수의 결과가 같고 시그니처도 같다. `map`/`bind` 로 줄인 것은 짧아졌을 뿐 동작이 달라지지 않았다.

## Introduction — `option` 계산 식을 직접 만든다 (원서 pp.155-156)

- F# 코어에는 `Option` 용 계산 식이 없다. 코어에 들어 있는 것은 `seq`·`async`·`task`·`query` 넷이다(실측 확인).
- 그래서 이 절은 사용자 정의 계산 식(custom computation expression)을 만든다. 계산 식 빌더는 정해진 이름의 멤버를 담은 클래스 타입이고, 계산 식 이름은 그 타입의 인스턴스를 묶은 소문자 값이다.
- 멤버 이름은 컴파일러가 이름으로 찾아 부르는 것이므로 원어 그대로 쓴다. `Bind` 가 `let!` 과 `do!` 를, `Return` 이 `return` 을, `ReturnFrom` 이 `return!` 을 받는다.

```fsharp id=12-option-builder
// 이 단위가 보여주는 것: option 계산 식 빌더를 만들어 앞 절의 파이프라인을 다시 쓰기
let split total parts =
    if parts = 0 then None else Some (total / parts)
let withCover load = load + 3

[<AutoOpen>]
module GrainCe =

    type OptionBuilder() =
        // let! 과 do! 를 받는다
        // FSI 실측: member Bind: x: 'c option * f: ('c -> 'd option) -> 'd option
        member _.Bind(x, f) = Option.bind f x
        // return 을 받는다
        // FSI 실측: member Return: x: 'b -> 'b option
        member _.Return(x) = Some x
        // return! 을 받는다
        // FSI 실측: member ReturnFrom: x: 'a -> 'a
        member _.ReturnFrom(x) = x

    // 계산 식 이름은 이 소문자 값이다. 쓰는 모양은 option { ... }
    let option = OptionBuilder()
```

`[<AutoOpen>]` 은 4챕터에서 이미 쓴 특성이다. 이 특성을 붙인 모듈은 그 네임스페이스나 어셈블리를 참조하기만 하면 모듈 안의 이름이 `open` 없이 보인다. 스크립트에서도 마찬가지인데, 이때는 암시적 모듈 안에 중첩된 `GrainCe` 가 그 자리에서 열린 상태가 되는 것이다. 특성을 떼고 `module GrainCe` 로만 두면 `option { ... }` 자리에서 `error FS0800: 형식 이름을 잘못 사용했습니다` 가 난다(실측 확인). 빌더가 안 보이면 컴파일러가 `option` 을 `Option<'T>` 의 타입 약어 이름으로 읽기 때문에 이런 낯선 오류가 나온다.

이제 앞 절의 함수를 계산 식으로 다시 쓴다.

```fsharp id=12-option-builder
// FSI 실측: perSackCe: total: int -> trucks: int -> sacks: int -> int option
let perSackCe total trucks sacks =
    option {
        let! load = split total trucks
        let covered = withCover load
        let! perSack = split covered sacks
        return perSack
    }
```

`map`/`bind` 로 쓴 것과 시그니처가 같고 결과도 같다. 달라진 것은 `None` 선로가 코드에서 사라진 점이다. 남은 네 줄은 실패가 한 번도 나지 않을 때 지나는 길, 곧 해피 패스(happy path)만 적고 있다.

줄마다 무엇이 일어나는지 보면 이렇다.

- `let!` 의 `!` 는 효과를 한 겹 벗기라는 표시다. `split total trucks` 의 타입은 `int option` 인데 `load` 의 타입은 `int` 다. 벗기는 일은 빌더의 `Bind` 가 하고, `Bind` 는 `None` 을 받으면 뒤에 오는 함수를 부르지 않는다. 앞 절 `match` 의 `None` 갈래가 여기로 들어간 것이다.
- `!` 가 없는 `let covered = ...` 는 평범한 `let` 바인딩이다. 원서 p.155 는 이 자리를 `Option.map` 을 쓸 뻔한 `let` 바인딩은 계산 식이 알아서 처리한다는 식으로 설명하는데, 그대로 읽으면 오해가 생긴다. 이 `let` 은 `map` 으로 바뀌지 않는다. 아래에서 실측으로 확인한다.
- `return` 은 `!` 의 반대다. 감싸지 않은 값을 받아 효과를 입힌다. 빌더의 `Return` 이 `Some x` 인 것이 그 일이다. F# 에서 `return` 이라는 낱말이 필요한 자리는 계산 식뿐이다.

`perSackCe` 의 네 줄이 각각 어느 멤버로 풀리는지는 빌더를 직접 불러 보면 눈으로 확인된다.

```fsharp id=12-option-builder
// 계산 식이 풀린 모양을 손으로 적어 본 것. perSackCe 와 결과가 같다
// FSI 실측: perSackByHand: total: int -> trucks: int -> sacks: int -> int option
let perSackByHand total trucks sacks =
    option.Bind(split total trucks, fun load ->
        let covered = withCover load
        option.Bind(split covered sacks, fun perSack ->
            option.Return perSack))

printfn "%-8s %A" "byHand" (perSackByHand 900 3 5)
// byHand   Some 60
```

`let!` 두 줄이 `option.Bind` 두 번으로, `return` 이 `option.Return` 으로 풀린 것이다. `!` 없는 `let covered` 만 빌더를 거치지 않고 그대로 남았다.

`let!` 에서 `!` 를 떼면 어긋나는 지점이 바로 드러난다.

```fsharp
let perSackBroken total trucks sacks =
    option {
        let load = split total trucks
        let covered = withCover load   // error FS0001: 'int' 형식이 필요하지만 'int option'
        let! perSack = split covered sacks
        return perSack
    }
```

`load` 가 `int option` 으로 묶여 `withCover` 에 들어가지 못한다. 원서는 마우스를 얹어 타입을 확인해 보라고 하는데, 스크립트에서는 타입 주석으로 같은 것을 확인할 수 있다. `!` 가 있는 자리에 `int` 주석을 달아 두면 `load` 가 한 겹 벗겨져 `int` 가 된 것이 눈으로 확인되고, 주석이 없어도 컴파일된다.

```fsharp id=12-option-builder
// return! 을 쓰는 형태. 마지막 식이 이미 int option 이므로 return 이 아니라 return! 이다
// FSI 실측: perSackFrom: total: int -> trucks: int -> sacks: int -> int option
let perSackFrom total trucks sacks =
    option {
        let! (load: int) = split total trucks   // 주석은 ! 가 한 겹 벗겼음을 보이려고 단 것이고 없어도 된다
        let covered = withCover load
        return! split covered sacks
    }

printfn "%-8s %A" "return"  (perSackCe 900 3 5)
printfn "%-8s %A" "return!" (perSackFrom 900 3 5)
printfn "%-8s %A" "fail"    (perSackFrom 900 3 0)
// return   Some 60
// return!  Some 60
// fail     None
```

`return` 과 `return!` 의 갈림은 오른쪽 식이 효과를 만드는지 하나로 정해진다. `split covered sacks` 는 이미 `int option` 이므로 `Return` 으로 한 겹 더 감싸면 `int option option` 이 된다. 그래서 `ReturnFrom` 이 필요하고, 빌더에 적은 `member _.ReturnFrom(x) = x` 가 아무 일도 하지 않는 것이 옳다. 실측 시그니처가 `x: 'a -> 'a` 인 것도 같은 말이다.

`!` 없는 `let` 이 `map` 으로 바뀌지 않는다는 것은 빌더를 하나 더 만들면 확인된다. `Return` 하나만 있는 빌더로도 `let` 은 돈다.

```fsharp id=12-option-builder
// Bind 도 ReturnFrom 도 없는 빌더
type ReturnOnlyBuilder() =
    member _.Return(x) = Some x
let onlyReturn = ReturnOnlyBuilder()

// FSI 실측: plain: n: int -> int option
let plain n =
    onlyReturn {
        let doubled = n * 2
        let raised = doubled + 1
        return raised
    }
printfn "%A" (plain 20)   // Some 41
```

`map` 에 해당하는 멤버가 빌더에 없는데도 `let` 두 줄이 통과한다. 계산 식 안의 `!` 없는 `let` 은 빌더 멤버를 부르지 않는 보통 바인딩이다. 뒤집어 말하면 `Bind`·`Return`·`ReturnFrom` 세 멤버만 적어 두면 `let!`·`let`·`return`·`return!`·`do!` 가 전부 돈다(실측 확인). `Zero` 는 `else` 없는 `if` 를 적을 때 필요해지는데, 빌더에 없으면 컴파일러가 `error FS0708` 로 그 멤버 이름을 알려 준다. `Combine` 은 계산 식 값을 내는 식이 둘 이상 이어질 때 필요해진다. 둘 다 원서의 범위 밖이다.

## The Result Computation Expression — 효과가 바뀌어도 문법은 그대로 (원서 pp.156-158)

- 계산 식의 값어치는 효과마다 문법을 새로 배우지 않아도 된다는 점에 있다. `Option` 에서 `Result` 로 갈아타도 `let!`·`let`·`return!` 의 쓰임은 그대로다.
- `result` 계산 식은 F# 코어에 없다. 빌더를 또 만드는 대신 원서는 `FsToolkit.ErrorHandling` 이 제공하는 것을 쓴다. 이 패키지는 8챕터에서 `validation` 계산 식을 쓸 때 이미 끌어왔다.
- 소재는 농가 정산이다. 수확량을 조회하고, 기준을 넘으면 인증 표시를 붙이고, 인증 여부에 따라 보조금을 더한다. 세 함수 가운데 둘이 `Result` 를 내고 하나는 내지 않는다.

아래 블록은 처음 한 번 네트워크로 패키지를 받아 오고 그 뒤에는 로컬 NuGet 캐시로 돈다. 받아 오지 못하면 `error FS0999` 로 실패한다.

```fsharp id=12-result-ce
// 이 단위가 보여주는 것: 효과가 Result 로 바뀌어도 계산 식 문법이 그대로라는 것
#r "nuget: FsToolkit.ErrorHandling, 5.2.0"
open FsToolkit.ErrorHandling

type Farm = {
    Code: string
    Certified: bool
    Subsidy: decimal
}

// FSI 실측: fetchYield: farm: Farm -> Result<(Farm * decimal),exn>
let fetchYield farm =
    try
        // 실제로는 수확 기록 저장소를 조회하는 자리다
        let tons = if farm.Code.EndsWith "0" then 42M else 17M
        Ok (farm, tons)
    with ex -> Error ex

// FSI 실측: certifyIfAbundant: farm: Farm * tons: decimal -> Farm
let certifyIfAbundant (farm, tons) =
    if tons > 30M then { farm with Certified = true } else farm

// FSI 실측: addSubsidy: farm: Farm -> Result<Farm,exn>
let addSubsidy farm =
    try
        let extra = if farm.Certified then 300M else 120M
        Ok { farm with Subsidy = farm.Subsidy + extra }
    with ex -> Error ex
```

`fetchYield` 와 `addSubsidy` 는 효과를 만들고 `certifyIfAbundant` 는 만들지 않는다. 앞 절의 `split`/`withCover` 와 같은 구도다. 실패 타입을 둘 다 `exn` 으로 맞춰 둔 것도 우연이 아니다. 3챕터에서 본 대로 실패 타입이 어긋나면 이을 수 없다.

```fsharp id=12-result-ce
// map/bind 로 이은 형태
// FSI 실측: settlePiped: farm: Farm -> Result<Farm,exn>
let settlePiped farm =
    farm
    |> fetchYield
    |> Result.map certifyIfAbundant
    |> Result.bind addSubsidy

// 같은 일을 result 계산 식으로
// FSI 실측: settleCe: farm: Farm -> Result<Farm,exn>
let settleCe farm =
    result {
        let! withYield = fetchYield farm
        let judged = certifyIfAbundant withYield
        return! addSubsidy judged
    }
```

`!` 가 붙은 줄은 효과를 만드는 함수 두 개뿐이다. 계산 식이 아닌 쪽에서 `Result.map` 을 쓸 자리가 `!` 없는 `let` 이고, `Result.bind` 를 쓸 자리가 `let!` 이며, 마지막 `Result.bind` 는 `return!` 이 받는다. `map` 이 따로 필요 없어지는 이유는 `Bind` 가 이미 한 겹 벗긴 값을 뒤에 오는 함수에 넘겨 주기 때문이다. `let! withYield = fetchYield farm` 이 지나간 뒤 `withYield` 의 타입은 `Result<(Farm * decimal),exn>` 이 아니라 `Farm * decimal` 이고, 그래서 다음 줄은 감싼 값을 열어 주는 `map` 없이 `certifyIfAbundant` 를 그대로 부른다. 어느 쪽이 읽기 좋은지는 취향이 갈리는데, 원서도 두 형태를 나란히 두고 계산 식 쪽을 권하는 정도로 말한다.

```fsharp id=12-result-ce
let show label (r: Result<Farm, exn>) =
    match r with
    | Ok f -> printfn "%-6s %s 인증=%-5b 보조금=%M" label f.Code f.Certified f.Subsidy
    | Error ex -> printfn "%-6s 실패 %s" label ex.Message

let bumper = { Code = "F-100"; Certified = false; Subsidy = 0M }
let lean = { Code = "F-101"; Certified = false; Subsidy = 0M }
show "piped" (settlePiped bumper)
show "ce"    (settleCe bumper)
show "piped" (settlePiped lean)
show "ce"    (settleCe lean)
// piped  F-100 인증=true  보조금=300
// ce     F-100 인증=true  보조금=300
// piped  F-101 인증=false 보조금=120
// ce     F-101 인증=false 보조금=120
```

한 가지 함정이 있다. 계산 식이 만든 값을 모듈 수준에 그냥 묶으면 실패 타입이 정해지지 않아 값 제한에 걸린다.

```fsharp
// error FS0030: 값 제한: 값 'staged'에 유추된 제네릭 형식이 있습니다.
//     val staged: Result<Farm,'_a>
let staged = result { return bumper }
```

`return bumper` 는 성공 타입만 알려 주고 실패 타입은 아무것도 정하지 않는다. `Result<Farm,'_a>` 의 `'_a` 가 그것이다. 타입 주석을 달면 해결된다.

```fsharp id=12-result-ce
// FSI 실측: staged: Result<Farm,exn>
let staged : Result<Farm, exn> = result { return bumper }
printfn "%A" (staged |> Result.map (fun f -> f.Code))   // Ok "F-100"
```

함수 안에서 쓰면 이 문제가 나지 않는다. 값 제한에 걸릴 수 있는 것은 매개변수 없는 `let` 뿐이고, 매개변수가 있으면 정해지지 않은 타입이 자동 일반화된다. `let wrap (x: int) = result { return x }` 의 시그니처가 `x: int -> Result<int,'a>` 로 나오는 것이 그 증거다(실측 확인). 위의 `settleCe` 는 자동 일반화까지 갈 일도 없다. 몸통에서 `addSubsidy` 를 부르므로 실패 타입이 `exn` 으로 정해진다. 참고로 `result { ... }` 를 패키지 없이 적으면 오류가 `error FS0039: 'result' 값 또는 생성자가 정의되지 않았습니다` 다. 앞 절의 `option` 은 타입 약어 이름과 겹쳐 `error FS0800` 이었는데, `result` 는 겹치는 이름이 없어 오류가 다르게 나온다.

## Introduction to Async — 지연 평가되는 효과 (원서 pp.158-159)

- `async` 는 코어에 들어 있는 계산 식이고 F# 의 비동기 지원이다. C# 의 async/await 와 결이 비슷하지만 지연 평가된다는 점이 다르다.
- `Async<'a>` 값을 만드는 것만으로는 본문이 돌지 않는다. `Async.RunSynchronously` 같은 실행 함수를 만나야 돈다. 원서는 이 함수를 애플리케이션 진입점에서만 쓰라고 못 박는다.
- .NET 라이브러리 함수는 `Async` 가 아니라 `Task` 를 내놓는다. `Async.AwaitTask` 로 바꿔야 `let!` 이 받는다.
- 원서는 `resources/customers.csv` 를 만들어 읽지만 이 노트는 스크립트가 임시 파일을 직접 만들어 쓰고 지운다.

```fsharp id=12-async
// 이 단위가 보여주는 것: async 계산 식, Async.AwaitTask, 그리고 지연 평가
open System.IO

type LogFacts = {
    Name: string
    Bytes: int
}

// FSI 실측: readFacts: path: string -> Async<LogFacts>
let readFacts path =
    async {
        printfn "  (async 본문 시작)"
        let! bytes = File.ReadAllBytesAsync(path) |> Async.AwaitTask
        let name = Path.GetFileName(path)
        return { Name = name; Bytes = bytes.Length }
    }
```

`File.ReadAllBytesAsync` 는 .NET 함수라서 `Task<byte array>` 를 내놓는다. `Async.AwaitTask` 를 끼우지 않으면 `let!` 이 그것을 벗길 수 없다. 벗긴 뒤 `bytes` 의 타입은 `byte array` 이고, `Path.GetFileName` 은 효과를 만들지 않으므로 `!` 없는 `let` 이다. 마지막 `return` 은 레코드를 `Async` 로 감싼다. 앞 두 절과 문법이 한 글자도 다르지 않다.

```fsharp id=12-async
let path = Path.Combine(Path.GetTempPath(), "grain-intake.log")
File.WriteAllText(path, "F-100|42\nF-101|17\n")

let job = readFacts path
printfn "async 값을 만든 뒤"
let facts = job |> Async.RunSynchronously
printfn "%s / %d 바이트" facts.Name facts.Bytes
// async 값을 만든 뒤
//   (async 본문 시작)
// grain-intake.log / 18 바이트
```

출력 순서가 지연 평가의 증거다. `readFacts path` 를 부른 시점에는 본문의 `printfn` 이 돌지 않았고, `Async.RunSynchronously` 를 만나서야 돌았다. `Task` 는 이 점이 반대다.

```fsharp id=12-async
let started = task { printfn "  (task 본문)"; return 7 }
printfn "task 를 만든 뒤"
printfn "%d" started.Result
File.Delete path
//   (task 본문)
// task 를 만든 뒤
// 7
```

`task` 는 만드는 순간 본문이 시작된다. 코어에 들어 있는 계산 식은 `seq`·`async`·`task`·`query` 넷인데 `task` 는 F# 6 부터다. F# 5 로 낮추면 `error FS3350` 으로 6.0 이상을 쓰라고 한다(실측 확인). 13챕터부터 웹 개발로 들어가면 `task` 를 쓰게 된다.

## Compound Computation Expressions — 효과 둘을 겹치기 (원서 pp.159-163)

- 효과가 하나면 여기까지로 충분하지만 실무에서는 둘이 겹친다. 비동기로 조회하면서 실패도 값으로 다루려면 타입이 `Async<Result<'a,'e>>` 가 된다.
- 이런 자리에 쓰는 것이 복합 계산 식(compound computation expression)이다. `asyncResult` 는 `FsToolkit.ErrorHandling` 이 제공하고 `Async` 가 `Result` 를 감싼 순서를 다룬다. 원서는 이 조합이 F# 로 쓴 업무용 애플리케이션(LOB, Line of Business)에서 아주 흔하다고 말한다.
- 겹친 만큼 실패 타입을 맞추는 일이 늘어난다. 그 손질을 패키지의 도우미 함수가 대신한다. 비동기 쪽 값은 `AsyncResult` 모듈, 동기 쪽 값은 `Result` 모듈에서 찾는다.
- 소재는 공유 자전거 일일 이용권 발급이다. 회원을 조회하고, 비밀번호를 확인하고, 이용 자격을 확인하고, 이용권을 발급한다. 네 단계가 각각 다른 모양의 효과를 낸다.

이 단위도 `FsToolkit.ErrorHandling` 이 필요하다. 처음 한 번은 네트워크로 받아 오고 그 뒤에는 로컬 NuGet 캐시로 돌며, 받아 오지 못하면 `error FS0999` 로 실패한다.

```fsharp id=12-asyncresult
// 이 단위가 보여주는 것: Async 와 Result 를 겹친 asyncResult 계산 식
#r "nuget: FsToolkit.ErrorHandling, 5.2.0"
open System
open FsToolkit.ErrorHandling

type StandingError =
    | AccountOnHold

type IssueError =
    | TerminalFault of string

// 네 단계의 실패를 한 타입으로 모은다
type PassError =
    | UnknownRider
    | WrongPin
    | NotInGoodStanding of StandingError
    | IssueFailed of IssueError

type DayPass = DayPass of Guid

type RiderStatus =
    | Good
    | Frozen
    | Barred

type Rider = {
    Name: string
    Pin: string
    Status: RiderStatus
}
```

실패 타입이 셋이라는 점을 눈여겨볼 만하다. 자격 확인은 `StandingError`, 발급은 `IssueError` 로 실패하고, 이용권 발급 함수 전체는 `PassError` 로 실패한다. `PassError` 의 두 케이스가 앞의 두 타입을 감싸고 있다. 3챕터가 세운 방식대로 각 단계가 제 실패 타입을 쓰고, 이어 붙이는 자리에서 `mapError` 로 갈아 끼우는 구조다.

```fsharp id=12-asyncresult
[<Literal>]
let GoodPin = "4821"
[<Literal>]
let GoodRider = "rider-ok"
[<Literal>]
let FrozenRider = "rider-frozen"
[<Literal>]
let BarredRider = "rider-barred"
[<Literal>]
let JinxedRider = "rider-jinxed"
[<Literal>]
let FaultMessage = "단말기 카드 리더가 응답하지 않는다"
```

`[<Literal>]` 은 컴파일 시점 상수를 만든다. 이 특성이 붙은 이름만 `match` 케이스의 상수 패턴으로 쓸 수 있다. 특성을 떼면 `| GoodRider ->` 가 상수 패턴이 아니라 변수 패턴이 되어 모든 입력을 받아 삼킨다. 그때 컴파일러는 대문자 이름을 적은 줄마다 `warning FS0049` 로 대문자 변수 식별자를 쓰지 말라고 알려 주고, 뒤 케이스들에는 `warning FS0026` 으로 이 규칙은 결코 일치하지 않는다고 알려 준다(실측 확인). 경고이지 오류가 아니어서 그대로 돌아가는 만큼 더 위험하다. 원서는 `[<Literal>]` 을 윗줄에 두는 형태와 `let [<Literal>] GoodPin = "4821"` 형태를 모두 보여 주는데 둘 다 유효하다.

```fsharp id=12-asyncresult
// FSI 실측: tryFindRider: name: string -> Async<Rider option>
let tryFindRider name =
    async {
        let rider = { Name = name; Pin = GoodPin; Status = Good }
        return
            match name with
            | GoodRider -> Some rider
            | FrozenRider -> Some { rider with Status = Frozen }
            | BarredRider -> Some { rider with Status = Barred }
            | JinxedRider -> Some rider
            | _ -> None
    }

// FSI 실측: isPinValid: pin: string -> rider: Rider -> bool
let isPinValid pin rider =
    pin = rider.Pin

// FSI 실측: checkStanding: rider: Rider -> Async<Result<unit,StandingError>>
let checkStanding rider =
    async {
        return
            match rider.Status with
            | Good -> Ok ()
            | _ -> AccountOnHold |> Error
    }

// FSI 실측: issuePass: rider: Rider -> Result<DayPass,IssueError>
let issuePass rider =
    try
        if rider.Name = JinxedRider then failwith FaultMessage
        else Guid.NewGuid() |> DayPass |> Ok
    with ex -> ex.Message |> TerminalFault |> Error
```

네 함수의 반환 타입이 제각각이다. `Async<Rider option>`, `bool`, `Async<Result<unit,StandingError>>`, `Result<DayPass,IssueError>` 다. 안이 어떻게 구현됐는지는 중요하지 않다. 이 네 모양을 한 줄기로 잇는 것이 다음 함수의 일이다.

```fsharp id=12-asyncresult
// FSI 실측: requestPass: name: string -> pin: string -> Async<Result<DayPass,PassError>>
let requestPass name pin : Async<Result<DayPass, PassError>> =
    asyncResult {
        let! rider = name |> tryFindRider |> AsyncResult.requireSome UnknownRider
        do! rider |> isPinValid pin |> Result.requireTrue WrongPin
        do! rider |> checkStanding |> AsyncResult.mapError NotInGoodStanding
        return! rider |> issuePass |> Result.mapError IssueFailed
    }
```

네 줄을 하나씩 읽는다.

- 첫 줄의 `AsyncResult.requireSome` 은 `Async<Rider option>` 을 `Async<Result<Rider,PassError>>` 로 바꾼다. `None` 이면 인자로 준 `UnknownRider` 를 실패로 삼는다. `let!` 이 두 겹을 한 번에 벗겨 `rider` 의 타입은 `Rider` 다.
- 둘째 줄의 `Result.requireTrue` 는 `bool` 을 `Result<unit,PassError>` 로 바꾼다. `isPinValid` 는 비동기가 아니므로 도우미 함수도 `Result` 모듈에서 가져온다. 비동기인 셋째 줄은 `AsyncResult` 모듈을 쓴다. 이 갈림이 원서 p.162 가 짚는 규칙이다.
- 셋째 줄의 `AsyncResult.mapError` 는 `StandingError` 를 `PassError` 로 갈아 끼운다. 3챕터에서 실패 타입을 맞추려고 `mapError` 를 어댑터로 쓴 것과 똑같은 쓰임이다.
- 마지막 줄은 `issuePass` 가 이미 `Result` 를 내놓으므로 `return!` 이다. `Result.mapError` 로 실패 타입만 `PassError` 로 넓힌다.

반환 타입 주석은 없어도 컴파일된다. 계산 식 네 줄에 나오는 `UnknownRider`·`WrongPin`·`NotInGoodStanding`·`IssueFailed` 가 모두 `PassError` 의 케이스라 실패 타입이 그 자리에서 정해지고, 주석을 떼도 `Async<Result<DayPass,PassError>>` 로 유추된다(실측 확인). 주석은 네 단계를 겹친 반환 타입을 한눈에 보이게 하려고 원서가 적어 둔 것이다.

```fsharp id=12-asyncresult
let run name pin = requestPass name pin |> Async.RunSynchronously

let show label (r: Result<DayPass, PassError>) =
    match r with
    | Ok (DayPass id) -> printfn "%s 발급 (%s)" label (if id = Guid.Empty then "빈 Guid" else "Guid 생성")
    | Error e -> printfn "%s 거절 %A" label e

show "정상발급" (run GoodRider GoodPin)
show "번호오류" (run GoodRider "0000")
show "회원없음" (run "rider-nobody" GoodPin)
show "계정정지" (run FrozenRider GoodPin)
show "이용제재" (run BarredRider GoodPin)
show "단말고장" (run JinxedRider GoodPin)
// 정상발급 발급 (Guid 생성)
// 번호오류 거절 WrongPin
// 회원없음 거절 UnknownRider
// 계정정지 거절 NotInGoodStanding AccountOnHold
// 이용제재 거절 NotInGoodStanding AccountOnHold
// 단말고장 거절 IssueFailed (TerminalFault "단말기 카드 리더가 응답하지 않는다")
```

여섯 경우가 네 단계 가운데 어디서 갈라졌는지를 실패값이 그대로 말해 준다. 원서는 이 확인을 `isOk`·`matchError` 같은 판정 함수와 `bool` 출력으로 하는데, 실패값을 그대로 찍으면 어느 단계에서 멈췄는지까지 보이므로 이 노트는 실패값을 그대로 찍는 형태를 택했다.

`Async.RunSynchronously` 는 `run` 에서 한 번만 부른다. `requestPass` 안에서 부르면 비동기의 의미가 없어진다. 원서가 이 함수를 진입점에서만 쓰라고 하는 것이 그 말이다.

## `do!` 가 실제로 받는 것 (원서 p.162 확장)

- 원서 p.162 는 `do!` 가 `unit` 을 반환하는 함수를 지원한다고 설명하는데 그대로 읽으면 틀린다. `do!` 가 받는 것은 평범한 `unit` 이 아니라 효과가 감싼 `unit` 이다. `Result<unit,'e>` 나 `Async<unit>` 이다.
- `do!` 는 이름에 묶을 값이 없는 `let!` 이다. 부르는 멤버도 `Bind` 로 같다. 성공값이 `unit` 이니 버리고, 실패면 그 자리에서 실패 선로로 갈아탄다.
- 그래서 `do!` 는 검사 단계를 적는 자리다. 값을 얻으려는 것이 아니고 통과 여부만 확인하려는 것이다.

이 단위도 `FsToolkit.ErrorHandling` 이 필요하다. 처음 한 번은 네트워크로 받아 오고 그 뒤에는 로컬 NuGet 캐시로 돌며, 받아 오지 못하면 `error FS0999` 로 실패한다.

```fsharp id=12-do-bang
// 이 단위가 보여주는 것: do! 가 받는 타입과, 실패한 뒤 뒷줄이 호출되지 않는다는 것
#r "nuget: FsToolkit.ErrorHandling, 5.2.0"
open FsToolkit.ErrorHandling

// FSI 실측: ensureWeighed: net: decimal -> Result<unit,string>
let ensureWeighed net =
    if net > 0M then Ok () else Error "계근표가 비어 있다"

// FSI 실측: ensureSealed: seal: string -> Result<unit,string>
let ensureSealed seal =
    if seal <> "" then Ok () else Error "봉인 번호가 없다"

// FSI 실측: acceptLoad: seal: string -> net: decimal -> Result<string,string>
let acceptLoad seal net =
    result {
        do! ensureWeighed net
        do! ensureSealed seal
        return sprintf "%s/%.1fkg" seal net
    }

printfn "%A" (acceptLoad "S-77" 812.5M)   // Ok "S-77/812.5kg"
printfn "%A" (acceptLoad "S-77" 0M)       // Error "계근표가 비어 있다"
printfn "%A" (acceptLoad "" 812.5M)       // Error "봉인 번호가 없다"
```

두 검사 함수의 반환 타입은 `unit` 이 아니라 `Result<unit,string>` 이다. 성공 자리가 `unit` 이라서 얻을 값이 없고, 쓸모는 실패 자리에 있다. 여기에 평범한 `unit` 을 반환하는 함수를 넣으면 컴파일되지 않는다.

```fsharp
let logIt (net: decimal) : unit = printfn "%M" net

let brokenResult seal net =
    result {
        // error FS0041: 'Source' 메서드와 일치하는 오버로드가 없습니다.
        // 알려진 인수 형식: unit
        do! logIt net
        return seal
    }

let brokenAsync (net: decimal) =
    async {
        // error FS0001: 이 식에는 'Async<'a>' 형식이 필요하지만 'unit' 형식이 지정되었습니다.
        do! logIt net
        return net
    }
```

오류 코드가 계산 식마다 다른 것은 빌더에 적힌 멤버가 다르기 때문이다(실측 확인). `async` 나 앞 절에서 손으로 만든 빌더는 `Bind` 의 첫 매개변수 타입이 그대로 어긋나 `error FS0001` 이 난다. `FsToolkit.ErrorHandling` 의 `result` 는 오른쪽 식을 한 번 걸러 주는 `Source` 오버로드가 따로 있어서 `error FS0041` 로 그 오버로드 목록을 보여 준다. 어느 쪽이든 말하는 것은 하나다. `do!` 에 평범한 `unit` 은 들어가지 않는다.

`Async<unit>` 도 같은 자리에 들어간다. 아래의 `Async.Sleep` 이 그런 함수다.

```fsharp id=12-do-bang
// FSI 실측: dispatch: seal: string -> Async<string>
let dispatch seal =
    async {
        do! Async.Sleep 1
        return sprintf "%s 출차" seal
    }
printfn "%s" (dispatch "S-77" |> Async.RunSynchronously)   // S-77 출차
```

## Debugging Code — `Error` 선로로 갈아탄 뒤 (원서 p.164)

- 원서는 중단점을 걸어 디버깅하는 방법을 소개하며 F# 개발자가 그것을 자주 하지 않는다고 덧붙인다. 순수 함수와 FSI 로 확인하는 편이 빠르기 때문이다.
- 원서가 중단점으로 짚는 사실은 코드로도 확인된다. 한 번 실패 선로로 갈아타면 뒤에 남은 성공 선로의 코드는 아예 호출되지 않는다.
- 이것을 조기 반환이라고 부르지 않는 이유는 앞서 본 것과 같다. 빠져나가는 것이 아니라 `Bind` 가 뒷줄을 담은 함수를 부르지 않는 것이다.

```fsharp id=12-do-bang
// 호출되면 흔적을 남기는 함수
let makeSlip seal net =
    printfn "  (전표 발행 호출됨)"
    sprintf "%s/%.1fkg" seal net

let acceptLoadTraced seal net =
    result {
        do! ensureWeighed net
        do! ensureSealed seal
        return makeSlip seal net
    }

printfn "통과 경우"
printfn "%A" (acceptLoadTraced "S-77" 812.5M)
printfn "실패 경우"
printfn "%A" (acceptLoadTraced "S-77" 0M)
// 통과 경우
//   (전표 발행 호출됨)
// Ok "S-77/812.5kg"
// 실패 경우
// Error "계근표가 비어 있다"
```

실패 경우에는 흔적이 남지 않았다. 첫 `do!` 에서 `Bind` 가 `Error` 를 받고 뒷줄 전체를 담은 함수를 부르지 않았기 때문이다. 원서가 중단점이 두 번만 걸린다고 말하는 것도 같은 현상이다.

## Further Reading — 더 읽을 것 (원서 p.164)

- 계산 식의 쓰임은 효과 처리 하나가 아니다. 도메인 특화 언어(DSL, Domain-Specific Language)를 만드는 데도 쓰인다. 원서는 예로 Saturn 과 Farmer 를 든다. 둘 다 `let!` 로 값을 벗기는 것과는 결이 다르게, 중괄호 안에 선언을 쌓아 설정을 기술하는 형태다.
- 비동기는 이 챕터가 다룬 것보다 넓다. `Async` 와 `Task` 의 관계, 취소, 병행 실행은 MS 공식 문서의 비동기 프로그래밍 문서를 따라가는 것이 좋다.
- 8챕터의 `validation` 계산 식을 다시 볼 자리가 여기다. 그쪽의 `and!` 는 이 챕터에서 만든 `Bind` 가 아니라 `MergeSources` 멤버를 부른다. `let!` 을 연달아 쓰면 뒷줄이 앞줄의 값에 기대므로 첫 실패에서 멈추고, `and!` 로 이으면 그 의존이 끊겨 모든 줄이 평가되고 실패가 모인다. 병렬로 도는 것이 아니라 의존이 없어지는 것이며, `and!` 로 이은 오른쪽 식들은 같은 스레드에서 차례로 평가된다. 진짜 병렬이 필요하면 같은 패키지의 `parallelAsyncValidation` 계산 식이 따로 있다.

## Summary — 원서의 챕터 요약 (원서 p.165)

- 원서는 계산 식이 처음에는 헷갈리지만 효과를 다루는 일반적인 수단이고 코드를 짧고 읽기 좋게 만들어 준다고 정리한다.
- 다음 챕터부터는 Giraffe 라이브러리로 API 와 웹 페이지를 만들며 지금까지의 도구를 실제 애플리케이션에 쓴다.

## 정리 — 이 노트의 요약

- 계산 식은 효과를 다루는 코드에 씌우는 문법 설탕이다. `match` 로 펼친 것, `map`/`bind` 로 줄인 것, 계산 식으로 감싼 것은 시그니처도 결과도 같다. 감춰지는 것은 실패 선로이고 남는 것은 해피 패스다.
- 계산 식 빌더는 정해진 이름의 멤버를 담은 클래스 타입이고, 계산 식 이름은 그 인스턴스를 묶은 소문자 값이다. `Bind`·`Return`·`ReturnFrom` 세 멤버만 있으면 `let!`·`let`·`return`·`return!`·`do!` 가 전부 돈다(실측 확인).
- `let!` 은 효과를 한 겹 벗겨 이름에 묶고 `Bind` 를 부른다. `!` 를 떼면 감싼 값이 그대로 묶여 타입이 어긋난다. `!` 없는 `let` 은 보통 바인딩이며 `map` 으로 바뀌지 않는다. `Return` 하나만 있는 빌더로도 `let` 이 도는 것이 증거다.
- `return` 은 감싸지 않은 값에 효과를 입히고, `return!` 은 이미 감싼 값을 그대로 낸다. 오른쪽 식이 효과를 만드는지로 갈린다.
- `do!` 는 이름에 묶을 값이 없는 `let!` 이다. 받는 것은 평범한 `unit` 이 아니라 효과가 감싼 `unit`(`Result<unit,'e>`·`Async<unit>`)이다. 원서 p.162 의 서술을 그대로 읽으면 틀린다. 평범한 `unit` 을 주면 `async` 와 손으로 만든 빌더는 `error FS0001`, `FsToolkit.ErrorHandling` 의 `result` 는 `Source` 오버로드 때문에 `error FS0041` 이 난다(실측 확인).
- 코어에 들어 있는 계산 식은 `seq`·`async`·`task`·`query` 넷이고 `task` 는 F# 6 부터다. `option` 과 `result` 는 코어에 없다. 빌더 없이 `option { ... }` 을 적으면 `option` 이 타입 약어 이름으로 읽혀 `error FS0800`, `result { ... }` 는 `error FS0039` 다.
- `async` 는 지연 평가된다. `Async<'a>` 를 만드는 것만으로는 본문이 돌지 않고 `Async.RunSynchronously` 를 만나야 돈다. `task` 는 반대로 만드는 순간 시작한다. `Async.RunSynchronously` 는 진입점에서만 쓴다. .NET 함수가 내놓는 `Task` 는 `Async.AwaitTask` 로 바꿔야 `let!` 이 받는다.
- 효과가 둘 겹치면 복합 계산 식을 쓴다. `asyncResult` 는 `Async<Result<'a,'e>>` 를 다루고 `FsToolkit.ErrorHandling` 이 제공한다. 도우미 함수는 비동기 쪽 값에 `AsyncResult` 모듈, 동기 쪽 값에 `Result` 모듈을 쓴다. 단계마다 다른 실패 타입은 `mapError` 로 함수 전체의 실패 타입으로 갈아 끼운다.
- 계산 식이 만든 값을 모듈 수준에 그냥 묶으면 실패 타입이 미정이라 값 제한 `error FS0030` 에 걸린다. 타입 주석을 달거나 함수 안에서 쓴다.
- `[<Literal>]` 을 붙인 이름만 `match` 케이스의 상수 패턴이 된다. 떼면 변수 패턴이 되어 모든 입력을 삼키고 `warning FS0049` 와 뒤 케이스의 `warning FS0026` 이 난다. 오류가 아니라 경고이므로 더 조심할 자리다.
- 실패 선로로 갈아탄 뒤 뒷줄이 실행되지 않는 것은 조기 반환이 아니다. `Bind` 가 뒷줄을 담은 함수를 부르지 않는 것이며, 호출 흔적을 남기는 함수를 끼워 보면 그대로 확인된다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Setting Up — 준비 | p.153 | — |
| Introduction — 손으로 이은 파이프라인 | pp.153-155 | `12-option-manual` |
| Introduction — `option` 계산 식을 직접 만든다 | pp.155-156 | `12-option-builder` |
| The Result Computation Expression — 효과가 바뀌어도 문법은 그대로 | pp.156-158 | `12-result-ce` |
| Introduction to Async — 지연 평가되는 효과 | pp.158-159 | `12-async` |
| Compound Computation Expressions — 효과 둘을 겹치기 | pp.159-163 | `12-asyncresult` |
| `do!` 가 실제로 받는 것 | p.162 확장 | `12-do-bang` |
| Debugging Code — `Error` 선로로 갈아탄 뒤 | p.164 | `12-do-bang` |
| Further Reading — 더 읽을 것 | p.164 | — |
| Summary — 원서의 챕터 요약 | p.165 | — |
