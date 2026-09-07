# 02 - 함수 (원서 pp.26-38)

> 이 챕터는 F# 프로그래밍의 중심에 있는 함수를 다룬다. 함수의 규칙은 놀랄 만큼 단순하다. 입력 하나를 받아 출력 하나를 낸다. 이 단순한 규칙 위에서 작은 함수를 이어 붙여 큰 일을 하게 만드는 함수 합성(function composition), 여러 매개변수를 한 입력/한 출력의 사슬로 바꿔 주는 커링(currying), 그리고 그 사슬 덕분에 가능해지는 부분 적용(partial application)이 나온다. 이 챕터가 반복해서 말하는 것은 하나다. F# 에서는 함수 시그니처(function signature)를 읽는 능력이 곧 코드를 읽는 능력이다.

## Getting Started — 함수의 규칙과 순수 함수 (원서 p.26)

- F# 함수의 규칙은 하나다. 입력 하나를 받고 출력 하나를 낸다. 1챕터에서 쓴, 매개변수를 두 개 받는 함수도 이 규칙과 충돌하지 않는다. 그 이유는 뒤의 커링 절에서 다룬다.
- 이 챕터는 그중 순수 함수(pure function)에 집중한다. 순수 함수는 두 가지 성질을 만족한다. 첫째, 결정적이다. 같은 입력에는 언제나 같은 출력을 낸다. 둘째, 부수 효과(side effect)를 만들지 않는다.

```fsharp id=02-signatures-and-composition
// 이 단위가 보여주는 것: 순수 함수, 시그니처 맞물림과 합성, 어댑터 함수, 레코드와 튜플

// string -> int
let charCount (text: string) = text.Length

// int -> float
let toDensity (n: int) = float n / 10.0

// float -> string
let describe (d: float) = sprintf "밀도 %.2f" d

// 세 함수 모두 결정적이고 부수 효과가 없다. 같은 입력이면 몇 번 불러도 같은 출력이 나온다
printfn "charCount \"hello\" 두 번: %d, %d" (charCount "hello") (charCount "hello")   // 기대: 5, 5
```

- 부수 효과란 데이터베이스 접근, 메일 발송, 사용자 입력 처리, 난수 생성, 현재 시각 조회 같은 활동이다. 부수 효과가 하나도 없는 프로그램은 현실에서 만들 수 없다. 목표는 완전히 제거하는 것이 아니라 순수한 부분과 분리하는 것이다.
- 순수 함수는 테스트하기 쉽다. 결과를 캐시해 두거나 여러 개를 병렬로 실행하기에도 유리하다.
- 한 함수에 모든 로직을 몰아넣을 수도 있지만, 작은 함수를 조합하면 재사용성이 훨씬 좋아진다. 이 조합을 함수 합성이라 부른다.

## Theory — 시그니처가 맞물려야 합성된다 (원서 pp.26-27)

- 합성의 조건은 단순하다. 앞 함수의 출력 타입이 뒤 함수의 입력 타입과 같아야 한다.
- `f1 : 'a -> 'b` 와 `f2 : 'b -> 'c` 가 있으면 `'b` 가 맞물리므로 `f1 >> f2` 로 `'a -> 'c` 인 새 함수를 만들 수 있다. `'a` 처럼 작은따옴표로 시작하는 이름은 어떤 타입이든 들어갈 수 있는 자리, 곧 타입 매개변수(type parameter)를 뜻한다.

```fsharp id=02-signatures-and-composition
// charCount 의 출력 int 가 toDensity 의 입력 int 와 맞물린다: string -> float
let density = charCount >> toDensity
printfn "density \"hello\" = %f" (density "hello")           // 기대: 0.500000

// 맞물리기만 하면 몇 개든 이어 붙는다: string -> string
let report = charCount >> toDensity >> describe
printfn "report \"functional\" = %s" (report "functional")   // 기대: 밀도 1.00
```

- `>>` 는 특정 타입 전용 도구가 아니라 임의의 두 함수를 이어 붙이는 범용 연산자로 보면 된다.
- 타입이 맞지 않을 때(`f1 : 'a -> 'b`, `f2 : 'c -> 'd`, `'b <> 'c`)는 사이에 끼울 어댑터 함수(adaptor function) `'b -> 'c` 를 새로 만들거나 이미 있는 함수를 찾아 넣는다. 그러면 전체가 다시 `'a -> 'd` 로 이어진다.

아래 두 함수는 `int` 와 `string` 이 달라 바로 합성되지 않는다.

```fsharp
// string -> int 과 string -> string 은 맞물리지 않는다
wordCount >> shout   // 컴파일 오류 FS0001
```

`int -> string` 어댑터를 사이에 끼우면 다시 이어진다.

```fsharp id=02-signatures-and-composition
// string -> int
let wordCount (text: string) = text.Split(' ').Length

// string -> string
let shout (text: string) = text.ToUpper() + "!"

// 어댑터 함수: int -> string
let toDashes (n: int) = String.replicate n "-"

// 어댑터를 끼우면 전체가 다시 이어진다: string -> string
let banner = wordCount >> toDashes >> shout
printfn "banner \"f sharp is fun\" = %s" (banner "f sharp is fun")   // 기대: ----!
```

- 이렇게 하면 함수를 몇 개든 계속 이어 붙일 수 있다.

## In Practice — 네 가지 표기, 같은 결과 (원서 pp.27-29)

- 원서는 레코드(record) 타입 하나와 시그니처가 맞물리는 함수 세 개로 실제 합성을 보여 준다. 이 노트는 같은 구조를 게임 캐릭터 도메인으로 다시 짜서 예제로 실었다.
- 여기서 새로 등장하는 문법이 두 가지다. 하나는 튜플(tuple)이다. 함수 사이에서 값 여러 개를 한 덩어리로 옮길 때 쓴다. 이 챕터 뒤쪽에서는 매개변수 자리에 쓰인 튜플도 다룬다. 타입을 적을 때는 `(Character * int)` 처럼 `*` 로 쓰고, 값을 쓸 때나 분해할 때는 `(character, exp)` 처럼 쉼표로 쓴다는 점을 구분해야 한다.

```fsharp id=02-signatures-and-composition
type Character = { Name: string; Level: int; Hp: int }

// Character -> (Character * int)
// 튜플은 함수 사이에서 값 여러 개를 한 덩어리로 옮길 때 쓴다
let gainExp character =
    let exp = if character.Name.Length % 2 = 0 then 150 else 40
    character, exp   // 괄호는 생략 가능
```

- 다른 하나는 복사-수정 레코드 식(copy-and-update record expression)인 `{ record with Field = value }` 다. 기존 레코드를 바탕으로 일부만 바꾼 새 인스턴스를 만든다. 레코드와 그 필드는 기본적으로 바뀌지 않는다. 이 성질을 불변성(immutability)이라 하며, 그래서 원본은 그대로 남는다.

```fsharp id=02-signatures-and-composition
// (Character * int) -> Character
// 매개변수 자리에서 튜플을 분해했다.
// 매개변수를 하나로 받아 함수 안에서 `let (character, exp) = pair` 로 풀어도 같다
let levelUpIfEnough (character, exp) =
    if exp >= 100 then { character with Level = character.Level + 1 }   // 복사-수정 레코드 식
    else character

// Character -> Character
let refillHp character = { character with Hp = character.Level * 20 }
```

- 함수를 이어 붙이는 방법은 크게 네 가지다. 함수 합성 연산자(function composition operator) `>>` 로 쓰기, 호출을 중첩해서 쓰기(`h (g (f x))`), 중간 값에 이름을 붙여 절차적으로 쓰기, 정방향 파이프 연산자(forward pipe operator) `|>` 로 흘려보내기. 네 방식 모두 시그니처가 같고 같은 입력에 같은 결과를 낸다.

```fsharp id=02-signatures-and-composition
// 네 표기 모두 시그니처가 Character -> Character 다
let trainComposed = gainExp >> levelUpIfEnough >> refillHp

let trainNested character = refillHp (levelUpIfEnough (gainExp character))

let trainStepwise character =
    let withExp = gainExp character
    let leveled = levelUpIfEnough withExp
    refillHp leveled

let trainPiped character =
    character
    |> gainExp
    |> levelUpIfEnough
    |> refillHp
```

- `>>` 와 `|>` 의 차이는 놓이는 자리다. `>>` 는 함수와 함수 사이에, `|>` 는 값과 함수 사이에 놓인다. `|>` 로 쓴 파이프라인은 절차적 표기와 같은 일을 하면서 중간 값에 이름을 붙이는 수고를 없애 준다.
- 원서는 기본 스타일로 `|>` 를 쓰라고 권한다.
- 레코드에는 구조적 동등성(structural equality)이 있다. 담긴 값이 같으면 `=` 연산자가 참을 내므로 FSI 에서 결과를 검증하기 편하다.

```fsharp id=02-signatures-and-composition
let hero = { Name = "aria"; Level = 3; Hp = 10 }    // 이름 길이 4(짝수) -> exp 150 -> 레벨업
let rookie = { Name = "ken"; Level = 3; Hp = 10 }   // 이름 길이 3(홀수) -> exp 40 -> 유지

printfn "trainComposed hero = %A" (trainComposed hero)
printfn "네 표기의 결과가 모두 같은가: %b"
    (trainComposed hero = trainNested hero
     && trainNested hero = trainStepwise hero
     && trainStepwise hero = trainPiped hero)                                    // 기대: true

// 담긴 값이 같으면 `=` 가 true
printfn "hero 검증: %b" (trainComposed hero = { Name = "aria"; Level = 4; Hp = 80 })    // 기대: true
printfn "rookie 검증: %b" (trainComposed rookie = { Name = "ken"; Level = 3; Hp = 60 }) // 기대: true
```

## Unit — 입력도 출력도 없을 때 (원서 pp.30-31)

- 모든 함수는 입력 하나를 받고 출력 하나를 내야 한다. 그런데 받을 것이 없거나 돌려줄 것이 없는 함수도 필요하다. F# 은 이 자리를 채우려고 `unit` 이라는 특별한 타입을 둔다.
- 시그니처에는 `unit` 으로 나타나지만 코드에서는 `()` 로 쓴다. `let now () = DateTime.UtcNow` 의 시그니처는 `unit -> DateTime` 이다.
- `unit` 을 유일한 입력으로 받거나 유일한 출력으로 내는 함수는 대개 부수 효과를 일으키고 있다는 신호다. 시각 조회, 로그 기록, 난수 생성이 전형적이다.

```fsharp id=02-unit
// 이 단위가 보여주는 것: `unit` 의 두 자리, 그리고 함수 바인딩과 값 바인딩의 차이
open System

// unit -> int
// 호출할 때마다 새로 평가되므로 결과가 달라질 수 있다(부수 효과 있음)
let ticks () = int (DateTime.UtcNow.Ticks % 1000L)

printfn "ticks() 1회: %d" (ticks ())
printfn "ticks() 2회: %d" (ticks ())   // 위와 다른 값이 나올 수 있다
```

`unit` 이 출력 자리에 오는 쪽은 돌려줄 값이 없는 작업이다.

```fsharp id=02-unit
// 'a -> unit
// 화면 출력, 로그 기록처럼 돌려줄 값이 없는 작업이 여기 해당한다
let record label =
    printfn "[기록] %A" label
    ()   // `printfn` 이 이미 `unit` 을 돌려주므로 이 줄은 생략할 수 있다

record "저장 완료"   // 기대: [기록] "저장 완료"
record 42            // 기대: [기록] 42
```

- 다만 확정 판정이 아니라 신호일 뿐이다. `ignore : 'a -> unit` 은 `unit` 을 돌려주면서도 부수 효과가 없는 순수 함수다.
- .NET 을 다뤄 온 독자는 `unit` 을 `void` 와 혼동하기 쉽다. `unit` 은 값이 `()` 하나뿐인 실제 타입이라 `Async<unit>`, `Result<unit, string>` 처럼 다른 타입의 타입 인자로 넣을 수 있고 `let x = printfn "hi"` 처럼 값으로 받을 수도 있다. `void` 는 반환값이 없다는 표지여서 타입 인자로 쓸 수 없다. 3챕터 이후 `Option`, `Async` 를 다룰 때 이 구분이 필요해진다.
- `()` 를 빼고 함수 이름만 쓰면 실행되지 않는다. 실행 결과 대신 `unit -> DateTime` 인 함수 자체가 값으로 남는다. 함수 이름 자체가 값이라는 뜻이다. 함수를 값처럼 다룰 수 있다는 이 성질을 일급 시민(first-class citizen)이라 하며, 익명 함수 절에서 다시 다룬다.

```fsharp id=02-unit
// () 를 빼고 부르면 실행되지 않고 함수 자체가 값으로 남는다
let notYetCalled = ticks
printfn "notYetCalled 는 아직 함수다. 인자를 주면 실행된다: %d" (notYetCalled ())
```

- 정의할 때 `()` 를 빼면 값 바인딩(value binding)이 된다. 오른쪽 식은 그 줄에서 한 번만 평가되고, 이후에는 그 결과가 계속 재사용된다.

```fsharp id=02-unit
// unit -> int : 함수 바인딩
let freshNumber () = int (DateTime.UtcNow.Ticks % 1000L)

// int : 값 바인딩. 이 줄이 평가된 순간의 값으로 고정된다
let frozenNumber = int (DateTime.UtcNow.Ticks % 1000L)

// 잠깐 시간을 흘려보낸다
Threading.Thread.Sleep 50

printfn "함수 바인딩 재호출: %d, %d" (freshNumber ()) (freshNumber ())
printfn "값 바인딩 재사용: %d, %d  (두 값이 같다)" frozenNumber frozenNumber
```

- 시그니처에 화살표 `->` 가 있으면 그 값은 호출할 수 있는 함수이며, 매개변수가 `unit` 하나뿐이어도 마찬가지다.
- 다만 화살표가 있다고 반드시 `let f x = ...` 형태의 함수 바인딩(function binding)인 것은 아니다. 값 바인딩에 함수를 담아도 화살표가 보인다. FSI 는 값 바인딩 쪽에 괄호를 붙여 `val f: (unit -> int)` 로 구분해 준다.

```fsharp id=02-unit
// (unit -> int) : 값 바인딩이지만 담긴 값이 함수라서 시그니처에 화살표가 있다.
// FSI 는 값 바인딩 쪽에 괄호를 붙여 val sharedNumber: (unit -> int) 로 구분해 준다
let sharedNumber =
    let captured = int (DateTime.UtcNow.Ticks % 1000L)   // 이 줄은 한 번만 평가된다
    fun () -> captured

Threading.Thread.Sleep 50

printfn "sharedNumber() 1회: %d" (sharedNumber ())
printfn "sharedNumber() 2회: %d  (붙잡아 둔 값이라 같다)" (sharedNumber ())
```

## Anonymous Functions — 이름 없는 함수 (원서 pp.31-32)

- 지금까지는 이름 있는 함수만 다뤘지만, 이름 없이 만드는 익명 함수(anonymous function)도 있다. `fun x y -> x + y` 처럼 `fun` 과 화살표로 쓰며 람다(lambda)라고 부른다.
- `let add x y = x + y` 와 `let add = fun x y -> x + y` 는 시그니처가 똑같이 `int -> int -> int` 다. 표기만 다르고 같은 함수다. 타입 주석(type annotation)을 달지 않으면 `+` 의 기본 대상인 정수로 추론된다.

```fsharp id=02-anonymous-functions
// 이 단위가 보여주는 것: 익명 함수, 함수를 매개변수로 받는 함수, 와일드카드, 클로저
open System

// int -> int -> int
let joinNamed x y = x * 10 + y

// int -> int -> int : 시그니처가 위와 완전히 같다
let joinLambda = fun x y -> x * 10 + y

printfn "joinNamed 3 7  = %d" (joinNamed 3 7)    // 기대: 37
printfn "joinLambda 3 7 = %d" (joinLambda 3 7)   // 기대: 37
```

- F# 에서 함수는 일급 시민이다. 다른 값처럼 함수의 인자로 넘길 수 있다. `let apply f x y = f x y` 를 쓰면 컴파일러가 `('a -> 'b -> 'c) -> 'a -> 'b -> 'c` 라는 제네릭(generic) 시그니처를 추론한다. 시그니처가 맞는 이름 있는 함수든 익명 함수든 넘길 수 있다.

```fsharp id=02-anonymous-functions
// ('a -> 'b -> 'c) -> 'a -> 'b -> 'c
// f 가 함수 자리다. 타입 주석이 없으므로 컴파일러가 제네릭으로 일반화한다
let runWith f a b = f a b

printfn "runWith joinNamed 3 7               = %d" (runWith joinNamed 3 7)                 // 기대: 37
printfn "runWith (fun x y -> x * 10 + y) 3 7 = %d" (runWith (fun x y -> x * 10 + y) 3 7)   // 기대: 37
printfn "runWith (fun a b -> a + b) 3 7      = %d" (runWith (fun a b -> a + b) 3 7)        // 기대: 10

// 제네릭이므로 문자열에도 같은 함수를 쓸 수 있다
printfn "runWith (+) \"F\" \"#\" = %s" (runWith (+) "F" "#")   // 기대: F#
```

- 한 번 쓰고 버릴 간단한 작업까지 작은 함수로 만들어 이름을 붙이는 수고를 익명 함수가 덜어 준다. 3챕터의 고차 함수(higher-order function)에서 본격적으로 쓴다.
- 밑줄 `_` 은 와일드카드(wildcard)라고 부르며, 그 값을 쓰지 않겠다고 컴파일러에 알리는 표시다. `List.init 50 (fun _ -> rnd ())` 에서 인덱스를 버리는 용도로 쓰인다.
- 스코프(scope) 규칙을 이용하면 무거운 객체를 한 번만 만들어 재사용할 수 있다. `let rnd () = let r = Random() in r.Next(100)` 은 호출마다 새 인스턴스를 만든다. 반면 `let rnd = let r = Random() in fun () -> r.Next(100)` 은 인스턴스를 한 번만 만들고, 반환된 람다가 그 인스턴스를 계속 붙잡아 쓴다. 이렇게 정의 시점의 값을 붙잡아 두는 함수 값을 클로저(closure)라 한다.

```fsharp id=02-anonymous-functions
// unit -> int : 호출할 때마다 Random 인스턴스를 새로 만든다
let dieRollFresh () =
    let generator = Random(20260904)
    generator.Next(1, 7)

// (unit -> int) : Random 을 한 번만 만들고 람다가 그것을 계속 붙잡아 쓴다(클로저)
let dieRollShared =
    let generator = Random(20260904)
    fun () -> generator.Next(1, 7)
```

- 뒤쪽 `rnd` 는 값 바인딩이다. 담긴 값이 함수라서 시그니처에 화살표가 보이고, FSI 출력에는 괄호가 붙는다.
- 예제는 이 차이를 눈에 보이게 하려고 시드를 고정했다. 시드를 주지 않으면 .NET Core 는 인스턴스마다 다른 시드를 쓰므로 두 버전의 출력이 비슷해져 차이가 드러나지 않는다.

```fsharp id=02-anonymous-functions
// 인덱스 값이 필요 없으므로 `_` 로 버린다
let freshRolls = List.init 8 (fun _ -> dieRollFresh ())
let sharedRolls = List.init 8 (fun _ -> dieRollShared ())

printfn "매번 새로 만든 경우: %A" freshRolls    // 시드가 같으니 같은 값만 반복된다
printfn "하나를 재사용한 경우: %A" sharedRolls  // 난수 수열이 이어지므로 값이 매번 달라진다
// 기대: [6; 6; 6; 6; 6; 6; 6; 6] / [6; 2; 3; 2; 3; 1; 4; 6]
```

## Multiple Parameters — 커링 (원서 p.32)

- 챕터 앞에서 함수는 입력 하나를 받고 출력 하나를 낸다고 했는데, 1챕터에서 만든 `calculateTotal customer spend` 는 매개변수가 둘이었다. 이 모순은 시그니처를 다시 읽으면 풀린다.
- `Customer -> decimal -> decimal` 은 실제로 `Customer -> (decimal -> decimal)` 이다. 즉 `Customer` 하나를 입력으로 받아 `decimal -> decimal` 인 함수를 출력으로 내는 함수다. `->` 는 오른쪽 결합이라 두 표기의 뜻이 같다. 매개변수를 두 줄로 쪼개 `let calculateTotal customer = fun spend -> ...` 로 써 보면 같은 뜻임이 눈에 보인다.

```fsharp id=02-currying
// 이 단위가 보여주는 것: 커링된 매개변수의 사슬, 그리고 튜플 매개변수와의 차이

// float -> float -> float
// 매개변수를 나란히 적는 보통 표기다
let applyTax rate amount = amount * (1.0 + rate)

// float -> float -> float
// 첫 인자를 받고 "함수"를 돌려주는 형태로 직접 써도 위와 같은 함수다
let applyTaxExplicit rate =
    fun amount -> amount * (1.0 + rate)

printfn "applyTax 0.1 1000.0         = %.1f" (applyTax 0.1 1000.0)           // 기대: 1100.0
printfn "applyTaxExplicit 0.1 1000.0 = %.1f" (applyTaxExplicit 0.1 1000.0)   // 기대: 1100.0
```

사슬 구조를 눈으로 보려면 시그니처에 괄호를 넣어 읽으면 된다. FSI 출력에는 괄호가 없다.

```fsharp
// FSI 가 실제로 출력하는 것은 괄호 없는 형태다.
// 아래 괄호는 사슬 구조를 눈으로 보려고 넣은 것이고, `->` 는 오른쪽 결합이라 뜻이 같다
applyTax        : float -> (float -> float)
applyTaxAndFee  : float -> (float -> (float -> float))
```

- 이렇게 한 입력/한 출력 함수를 자동으로 사슬로 엮어 주는 것을 커링이라 한다. 미국 수학자 해스컬 커리(Haskell Curry)의 이름에서 왔다.
- 덕분에 겉보기에는 매개변수가 여러 개인 함수를 쓰면서 실제로는 한 입력/한 출력 함수의 연쇄를 다루게 된다. 그리고 이 사슬 구조가 다음 절의 부분 적용을 가능하게 한다.

```fsharp id=02-currying
// float -> float -> float -> float
// 매개변수가 세 개여도 결국 한 입력/한 출력의 사슬이다
let applyTaxAndFee rate fee amount = amount * (1.0 + rate) + fee

printfn "applyTaxAndFee 0.1 500.0 1000.0 = %.1f" (applyTaxAndFee 0.1 500.0 1000.0)   // 기대: 1600.0

// 인자를 하나만 주면 아직 함수다. 시그니처: float -> float
let withVat = applyTax 0.1
printfn "withVat 2000.0 = %.1f" (withVat 2000.0)   // 기대: 2200.0
printfn "withVat 3000.0 = %.1f" (withVat 3000.0)   // 기대: 3300.0

// 인자를 하나씩 차례로 적용해도 결과는 같다
let step1 = applyTaxAndFee 0.1   // float -> float -> float
let step2 = step1 500.0          // float -> float
printfn "step2 1000.0 = %.1f" (step2 1000.0)       // 기대: 1600.0
```

## Partial Application (Part 1) — 인자를 나눠서 주기 (원서 p.33)

- 커링된 함수에 필요한 인자 전부가 아니라 앞쪽 일부만 주면, 남은 인자를 기다리는 새 함수가 결과로 나온다. 이것이 부분 적용이다.

```fsharp id=02-partial-application
// 이 단위가 보여주는 것: 부분 적용, 판별 유니온으로 만든 전용 로거, 튜플 매개변수의 한계

// string -> int -> string
let padCode (prefix: string) (number: int) =
    sprintf "%s-%04d" prefix number

// 첫 인자만 주면 시그니처가 int -> string 인 함수가 남는다
let orderCode = padCode "ORD"
let refundCode = padCode "RFD"

printfn "padCode \"ORD\" 7 = %s" (padCode "ORD" 7)   // 기대: ORD-0007
printfn "orderCode 7   = %s" (orderCode 7)           // 기대: ORD-0007
printfn "refundCode 42 = %s" (refundCode 42)         // 기대: RFD-0042
```

- `Customer -> decimal -> decimal` 인 함수에 첫 인자만 주면 결과의 시그니처는 `decimal -> decimal` 이다. 여기에 마지막 인자를 주면 원래 함수가 완성되어 최종 값을 낸다.
- 인자는 왼쪽에서 오른쪽 순서로 채워야 한다. 하나씩 채워도 되고 여러 개를 한꺼번에 채워도 되지만, 순서를 건너뛰면 타입이 맞지 않아 컴파일되지 않는다.

```fsharp
// 순서를 바꿔서 줄 수는 없다. 첫 인자는 string 자리다
padCode 7   // 컴파일 오류 FS0001
```

- 처음에는 이런 기능이 왜 필요한지 의문이 들 수 있다. 가장 가까운 답은 이 챕터에서 이미 쓰고 있는 `|>` 가 부분 적용 위에서 동작한다는 점이다.

## The Forward Pipe Operator — `|>` 의 내부 동작 (원서 pp.33-36)

- `|>` 는 원서 전체에서 계속 쓰이므로 원리를 한 번 짚어 둘 만하다. 핵심은 부분 적용이다.
- `let complete = 100.0M |> calculateTotal john` 은 부분 적용된 함수에 이름을 붙이는 단계를 생략한 것이다. 연산자 왼쪽의 값이 오른쪽 함수에서 아직 채워지지 않은 첫 인자 자리로 적용된다.

```fsharp id=02-forward-pipe
// 이 단위가 보여주는 것: `|>` 가 값을 어느 자리에 넣는지, 그리고 그 정의와 `>>` 와의 차이

// float -> float -> float
let applyDiscount rate price = price * (1.0 - rate)

// 부분 적용으로 한 단계씩
let halfOff = applyDiscount 0.5   // float -> float
let step = halfOff 4000.0
printfn "부분 적용: %.1f" step                            // 기대: 2000.0

// 같은 일을 파이프로. 왼쪽 값이 아직 채워지지 않은 인자 자리로 들어간다
printfn "파이프:    %.1f" (4000.0 |> applyDiscount 0.5)   // 기대: 2000.0
```

왼쪽 값이 언제나 "마지막" 인자로 들어가는 것은 아니다. 오른쪽 함수에 인자가 둘 다 남아 있으면 첫 인자 자리로 들어간다.

```fsharp id=02-forward-pipe
// 반례: 0.5 가 rate, 즉 첫 인자로 들어가고 결과는 아직 함수다
let stillAFunction = 0.5 |> applyDiscount   // (float -> float)
printfn "0.5 |> applyDiscount 는 아직 함수: %.1f" (stillAFunction 4000.0)   // 기대: 2000.0
```

- 검증 코드를 읽기 좋게 만드는 데도 쓸 만하다. `areEqual 90.0M (calculateTotal john 100.0M)` 은 기대값이 앞에 나와 읽기 어색하다. 도우미 함수 이름을 `isEqualTo` 로 바꾸고 `calculateTotal john 100.0M |> isEqualTo 90.0M` 로 쓰면 영어 문장처럼 읽힌다. 이때 `isEqualTo` 는 인자 두 개 중 하나만 받은 부분 적용 상태이고, 남은 인자는 파이프가 넘겨 준다.

```fsharp id=02-forward-pipe
// 'a -> 'a -> bool  (when 'a : equality)
// `=` 를 썼으므로 컴파일러가 동등성 제약을 붙인다
let isEqualTo expected actual = (expected = actual)

// 도우미 함수를 그냥 쓰면 기대값이 앞에 온다
printfn "읽기 어려운 순서:   %b" (isEqualTo 2000.0 (applyDiscount 0.5 4000.0))       // 기대: true

// 파이프를 쓰면 "계산 결과가 2000.0과 같다" 순서로 읽힌다
printfn "문장처럼 읽는 순서: %b" (applyDiscount 0.5 4000.0 |> isEqualTo 2000.0)      // 기대: true

// 'a -> 'a -> bool  (when 'a : comparison) : 인자 순서가 결과를 바꾸는 비대칭 도우미
let isGreaterThan limit actual = actual > limit
printfn "결과가 1000.0 보다 큰가: %b" (applyDiscount 0.5 4000.0 |> isGreaterThan 1000.0)   // 기대: true
```

- `|>` 의 정의는 `FSharp.Core` 에 있고 대략 `let (|>) v f = f v` 형태다. 시그니처는 `'a -> ('a -> 'b) -> 'b` 다. 실제 정의에는 `inline` 이 붙어 `let inline (|>) arg func = func arg` 이며, 그 덕분에 호출마다 함수 값을 새로 만들지 않는다.

```fsharp id=02-forward-pipe
// 표준 `|>` 를 덮어쓰지 않도록 같은 동작의 별칭 연산자를 만들어 확인한다
// 'a -> ('a -> 'b) -> 'b
let (|~>) value func = func value

printfn "직접 만든 연산자:    %.1f" (4000.0 |~> applyDiscount 0.5)   // 기대: 2000.0
```

- `|>` 는 컴파일러에 특별 취급된 문법이 아니다. 사용자 정의 연산자(custom operator)와 똑같은 방식으로 `FSharp.Core` 에 정의된 보통 함수다.
- 정의할 때 `(|>)` 처럼 괄호를 씌우는 것은 기호로 된 이름을 식별자 자리에 놓기 위한 문법이다. 괄호로 감싼 이름은 보통 함수처럼 앞에 놓고 적용할 수 있다. 이것이 연산자의 함수 형태(operator function form)다: `(|>) (calculateTotal john 100.0M) (isEqualTo 90.0M)`.

```fsharp id=02-forward-pipe
// 연산자 이름을 괄호로 감싸면 보통 함수처럼 앞에 놓고 적용할 수 있다
printfn "함수 형태:           %.1f" ((|~>) 4000.0 (applyDiscount 0.5))   // 기대: 2000.0
// 표준 연산자도 마찬가지다
printfn "표준 `|>` 함수 형태: %.1f" ((|>) 4000.0 (applyDiscount 0.5))    // 기대: 2000.0
```

- 괄호를 벗기면 중위 형태(infix form)로 쓰인다: `calculateTotal john 100.0M |> isEqualTo 90.0M`. 두 표기는 같은 함수를 부른다.
- `|>` 는 중위 연산자다. `~-` 처럼 값 앞에 붙는 접두 형태(prefix form)로는 쓸 수 없다(`|> 3` 은 컴파일 오류다).

```fsharp
// 중위 연산자를 값 앞에 붙일 수는 없다
let x = |> 3   // 컴파일 오류 FS0010: 예기치 않은 중위 연산자
```

- `|>` 는 함수를 매개변수로 받으므로 고차 함수다. 고차 함수는 함수를 하나 이상 매개변수로 받거나 함수를 출력으로 내는 함수를 말한다.

```fsharp id=02-forward-pipe
let addShipping price = price + 3000.0
let toLabel (price: float) = sprintf "결제 금액 %.0f원" price

// `>>`: 함수와 함수 사이. 결과는 아직 함수다
let checkout = applyDiscount 0.2 >> addShipping >> toLabel   // float -> string
printfn "합성 함수 결과: %s" (checkout 10000.0)              // 기대: 결제 금액 11000원

// `|>`: 값과 함수 사이. 결과는 바로 값이다
let receipt =
    10000.0
    |> applyDiscount 0.2
    |> addShipping
    |> toLabel
printfn "파이프라인 결과: %s" receipt                         // 기대: 결제 금액 11000원

// 파이프는 함수를 매개변수로 받으므로 `List.map` 같은 고차 함수와 잘 붙는다
[ 5000.0; 12000.0; 30000.0 ]
|> List.map (applyDiscount 0.1)   // 부분 적용된 함수를 그대로 넘긴다
|> List.map toLabel
|> List.iter (printfn "  %s")     // 기대: 결제 금액 4500원 / 10800원 / 27000원
```

- 연산자 왼쪽의 값은 오른쪽 함수에서 아직 채워지지 않은 첫 인자 자리로 들어간다. 오른쪽에 인자를 하나만 남겨 두는 것이 관용적인 쓰임이므로, 실무에서는 "마지막 인자로 들어간다"라고 이해해도 무리가 없다.

## Partial Application (Part 2) — 로거 예제 (원서 pp.36-38)

- 원서는 `log` 함수로 부분 적용을 다시 보여 준다. 이 함수는 판별 유니온(discriminated union)으로 정의한 로그 레벨과 문자열 메시지를 받으며, 시그니처는 `LogLevel -> string -> unit` 이다.
- 모든 F# 함수는 출력을 내야 하므로 원서는 처음에 `()` 를 마지막 줄에 적는다. 그러나 `printfn` 자체가 `unit` 을 돌려주므로 그 줄은 지울 수 있다.

```fsharp id=02-partial-application
type LogLevel =
    | Error
    | Warning
    | Info

// LogLevel -> string -> unit
// message 에 타입 주석이 없어도 `%s` 때문에 string 으로 추론된다.
// `printfn` 이 `unit` 을 돌려주므로 함수 본문이 이 한 줄로 끝난다
let log (level: LogLevel) message =
    printfn "[%A] %s" level message

log Info "커링된 함수로 직접 호출"   // 기대: [Info] 커링된 함수로 직접 호출
```

- `printfn` 과 문자열 보간(string interpolation) 둘 다 서식 지정자(format specifier)를 지원한다. 지정자와 실제 타입이 맞지 않으면 런타임 오류가 아니라 컴파일 오류가 난다. 보간 문자열에서는 지정자를 생략할 수도 있지만, 그러면 지정자가 주던 타입 안전성을 잃는다. `printfn $"[{level}]: {message}"` 처럼 쓰면 메시지 쪽이 제네릭 `'a` 로 추론된다.

```fsharp id=02-partial-application
// LogLevel -> string -> unit
// 문자열 보간으로도 같은 출력을 낼 수 있다. 여기서는 보간 안에 서식 지정자를 함께 썼다
let logInterpolated (level: LogLevel) message =
    printfn $"[%A{level}] %s{message}"

// LogLevel -> 'a -> unit
// 지정자를 생략하면 메시지가 제네릭으로 추론된다(타입 안전성을 잃는다)
let logGeneric (level: LogLevel) message =
    printfn $"[{level}] {message}"

logInterpolated Info "보간 문자열 버전"   // 기대: [Info] 보간 문자열 버전
logGeneric Info "문자열도"                // 기대: [Info] 문자열도
logGeneric Info 42                        // 지정자가 없으니 int 도 통과한다. 기대: [Info] 42
```

- 레벨만 미리 채운 `let logError = log Error` 는 `string -> unit` 인 함수에 이름을 붙인 것이다. 이후에는 레벨을 매번 적지 않고 `logError "..."` 로 호출한다.

```fsharp id=02-partial-application
// 레벨만 고정한 전용 함수: string -> unit
let logError = log Error
let logWarning = log Warning
let logInfo = log Info

logError "부분 적용된 함수로 호출"       // 기대: [Error] 부분 적용된 함수로 호출
logWarning "레벨을 매번 적지 않아도 된다"  // 기대: [Warning] 레벨을 매번 적지 않아도 된다
```

부분 적용의 결과는 보통 값과 다르지 않으므로 다른 함수에 그대로 넘길 수 있다.

```fsharp id=02-partial-application
// ('a -> unit) -> 'a list -> unit
// string 으로 고정하지 않았으므로 컴파일러가 자동 일반화해 제네릭 함수가 된다
// logError 를 넘기는 순간 'a 가 string 으로 정해진다
let logAll writer messages =
    messages |> List.iter writer

// 로거 자체를 매개변수로 받는다. 부분 적용 결과가 그대로 값처럼 쓰인다
logAll logError [ "디스크 없음"; "연결 끊김" ]   // 기대: [Error] 디스크 없음 / [Error] 연결 끊김
```

- 반환 타입이 `unit` 이면 결과를 `let` 으로 바인딩할 필요가 없다. 호출문만 적으면 된다.

```fsharp id=02-partial-application
// 반환 타입이 `unit` 이므로 결과를 `let` 으로 바인딩하지 않아도 된다
logInfo "let 바인딩 없이 그냥 호출"   // 기대: [Info] let 바인딩 없이 그냥 호출
```

- 부분 적용은 커링된 매개변수(curried parameters)가 있어야 가능하다. `(LogLevel * string) -> unit` 처럼 튜플 매개변수(tupled parameter) 하나를 받는 형태는 튜플 전체를 한꺼번에 줘야 하므로 부분 적용을 할 수 없다.

```fsharp id=02-currying
// float -> float -> float : 커링된 매개변수. 하나씩 줄 수 있다
let curriedArea width height = width * height

// (float * float) -> float : 튜플 하나를 받는다. 반드시 한꺼번에 줘야 한다
let tupledArea (width, height) = width * height

printfn "curriedArea 3.0 4.0   = %.1f" (curriedArea 3.0 4.0)     // 기대: 12.0
printfn "tupledArea (3.0, 4.0) = %.1f" (tupledArea (3.0, 4.0))   // 기대: 12.0

// 커링된 매개변수는 인자를 하나씩 채워 부분 적용할 수 있다
let heightOf3 = curriedArea 3.0
printfn "heightOf3 4.0 = %.1f, heightOf3 5.0 = %.1f" (heightOf3 4.0) (heightOf3 5.0)   // 기대: 12.0, 15.0
```

```fsharp id=02-partial-application
// (LogLevel * string) -> unit : 로거도 튜플 매개변수로 바꾸면 부분 적용을 잃는다
let logTupled (level: LogLevel, message: string) =
    printfn "[%A] %s" level message

logTupled (Warning, "튜플은 한꺼번에 줘야 한다")   // 기대: [Warning] 튜플은 한꺼번에 줘야 한다
```

튜플은 절반만 채울 수 없다. 아래 두 줄은 모두 타입 불일치로 컴파일되지 않는다.

```fsharp
tupledArea 3.0        // 컴파일 오류 FS0001
logTupled Error       // 컴파일 오류 FS0001
```

## Summary — 원서의 챕터 요약 (원서 p.38)

- 원서는 이 챕터에서 순수 함수, 익명 함수, 함수 합성, 튜플, 복사-수정 레코드 식, 커링된 매개변수와 튜플 매개변수, 커링과 부분 적용을 다뤘다.
- 여기까지 오면 F# 프로그래밍의 기본 재료가 갖춰진다. 타입과 함수의 조합, 식, 불변성이 그 재료다.
- 다음 챕터에서는 F# 이 `null` 과 예외를 다루는 방법을 살펴본다.

## 정리 — 이 노트의 요약

- 함수의 규칙은 입력 하나, 출력 하나다. 매개변수가 여러 개로 보이는 함수는 커링된 한 입력/한 출력 함수의 사슬이다.
- 시그니처를 읽으면 그 함수를 어떻게 쓸 수 있는지가 드러난다. 합성 가능성, 부분 적용 가능성, 함수인지 값인지가 모두 시그니처에 적혀 있다.
- `>>` 는 함수와 함수를 잇고, `|>` 는 값을 함수에서 아직 채워지지 않은 첫 인자 자리로 밀어 넣는다. 오른쪽에 인자를 하나만 남겨 두는 관용적인 쓰임에서는 그 자리가 마지막 인자와 같아진다. 기본 스타일은 `|>` 다.
- `|>` 는 마법이 아니라 `let (|>) v f = f v` 로 정의된 고차 함수이며, 부분 적용에 의존한다.
- 부분 적용은 커링된 매개변수 사슬에서 일어난다. 튜플 매개변수는 그 자체가 한 개의 인자여서 절반만 채울 수 없다.
- `unit` 은 입력이나 출력이 없는 자리를 채우는 타입이고, `unit` 이 유일한 입력이나 유일한 출력으로 보이면 대개 부수 효과를 의심할 만하다.
- 레코드는 불변이고 구조적 동등성이 있으므로, 복사-수정 식으로 새 값을 만들고 `=` 로 검증하는 흐름이 자연스럽다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Getting Started — 함수의 규칙과 순수 함수 | p.26 | `02-signatures-and-composition` |
| Theory — 시그니처가 맞물려야 합성된다 | pp.26-27 | `02-signatures-and-composition` |
| In Practice — 네 가지 표기, 같은 결과 | pp.27-29 | `02-signatures-and-composition` |
| Unit — 입력도 출력도 없을 때 | pp.30-31 | `02-unit` |
| Anonymous Functions — 이름 없는 함수 | pp.31-32 | `02-anonymous-functions` |
| Multiple Parameters — 커링 | p.32 | `02-currying` |
| Partial Application (Part 1) — 인자를 나눠서 주기 | p.33 | `02-partial-application` |
| The Forward Pipe Operator — `\|>` 의 내부 동작 | pp.33-36 | `02-forward-pipe` |
| Partial Application (Part 2) — 로거 예제 | pp.36-38 | `02-partial-application`, `02-currying` |
| Summary — 원서의 챕터 요약 | p.38 | — |
