# 05 - 컬렉션 입문 (원서 pp.63-79)

> 이 챕터부터 다루는 대상이 값 하나에서 값의 묶음으로 바뀐다. F# 이 데이터 중심 작업에 강하다는 평을 듣는 이유가 여기서 드러난다. 컬렉션(collection) 타입 자체가 불변이고, 그 타입마다 붙은 모듈에 미리 만들어 둔 고차 함수(higher-order function)가 잔뜩 들어 있어서 `for` 루프와 가변 누적 변수로 쓰던 코드가 파이프라인 몇 줄로 줄어든다. 원서는 세 가지 주요 컬렉션 중 `List` 하나에 집중하고, 마지막 절에서 배운 함수들을 묶어 실제 업무 로직 하나를 처음부터 끝까지 만든다. 이 노트도 같은 범위를 지킨다.

## Before We Start — 준비 (원서 p.63)

- 원서는 이 챕터용 폴더를 새로 만들고 `lists.fsx` 스크립트 파일을 하나 두라고만 한다.
- 마지막 실전 예제 절만 4챕터에서 만든 것과 같은 솔루션 구조를 쓰고, 나머지 절은 FSI 에서 조각조각 실행하며 읽는 내용이다. 이때 코드 프로젝트는 콘솔이 아니라 클래스 라이브러리(`dotnet new classlib -lang "F#"`)로 만든다. 실행할 진입점이 필요 없고 테스트 프로젝트가 참조할 대상만 필요하기 때문이다.
- 이 노트의 코드는 전부 스크립트 하나로 돌아가게 짰다. 실전 예제 절의 xUnit 테스트만 실행 대상에서 빼고, 같은 검증을 FSI 에서 비교식으로 대신한다.

## The Basics — 세 가지 컬렉션과 그 차이 (원서 p.63)

- F# 에서 쓸 수 있는 컬렉션은 여럿이지만 중심이 되는 것은 세 개다. `Seq`, `Array`, `List`.
- `Seq` 는 지연 평가(lazy evaluation)되는 시퀀스다. 필요할 때 한 원소씩 만들어 내므로 무한 시퀀스나 파일 스트림처럼 끝을 모르는 데이터에 맞는다. .NET 의 `IEnumerable<'T>` 와 같은 것이다.
- `Array` 는 즉시 평가(eager evaluation)되는 고정 길이 연속 메모리다. 인덱스 접근이 빠르고 수치 계산에 유리하다. 2·3·4차원 배열용 모듈이 따로 있다.
- `List` 는 즉시 평가되는 연결 리스트(linked list)다. 구조와 데이터가 모두 불변이다. 맨 앞에 원소를 붙이는 일이 싸고, 인덱스로 중간을 짚는 일은 비싸다.
- 세 타입 모두 같은 이름의 지원 모듈(`Seq`, `Array`, `List`)이 있고, 서로 변환하는 함수도 들어 있다. 그래서 `List` 모듈에서 익힌 함수 이름은 나머지 두 모듈에서도 거의 그대로 통한다.
- 원서는 이 챕터에서 `List` 타입과 `List` 모듈만 다루겠다고 못 박는다(원서 p.63). 이 노트도 그 범위를 따른다.

이름이 헷갈리는 지점이 하나 있다. C# 에서 쓰던 `List<'T>` 는 F# 의 `List` 가 아니다. F# 에서 그것은 `ResizeArray<'T>` 라는 별칭으로 부르고, 이름대로 크기가 변하는 가변 배열이다. F# 의 `List` 는 불변 연결 리스트이므로 성격이 정반대다.

## Core Functionality — 리스트 만들기와 핵심 함수 (원서 pp.63-68)

- 리스트 리터럴은 대괄호에 세미콜론으로 나열한다. `[2; 5; 3]`. 쉼표를 쓰면 튜플 하나만 담은 리스트가 되므로 주의한다. `[2, 5, 3]` 은 원소가 하나뿐인 `(int * int * int) list` 다.
- 연속된 정수는 범위 식 `[1..5]` 로, 간격을 두려면 `[0..5..20]` 으로 만든다.
- 리스트 컴프리헨션(list comprehension)은 `[ for x in ... do ... ]` 형태다. F# 4.7 부터 대부분의 경우 `yield` 를 생략할 수 있고, 이것을 암시적 `yield` 라 부른다(원서는 F# 5 부터라고 적는다). 같은 문법이 `Seq` 와 `Array` 에도 있지만 이 챕터에서는 쓰지 않는다.
- 빈 리스트 `[]` 는 원소 타입이 정해지지 않아 자동 일반화(auto-generalization)로 `'a list` 가 된다. 특정 타입으로 못 박아야 하면 타입 주석을 붙인다.
- 같은 빈 리스트라도 `let reversed = List.rev []` 처럼 함수를 적용한 결과를 이름에 묶으면 일반화가 막혀 값 제한(value restriction) 오류 FS0030 이 난다. 매개변수 없는 `let` 바인딩은 제네릭이 될 수 없다는 규칙이다. 타입 주석을 붙이거나 쓰이는 문맥에서 타입이 정해지면 풀린다.

```fsharp id=05-list-basics
// 이 단위가 보여주는 것: 리스트를 만드는 여러 방법과 머리/꼬리 구조

// 주석이 없으면 'a list 로 일반화된다. int 로 못 박으려면 타입 주석을 붙인다
let noLaps : int list = []

// 구간별 기록(초)
let laps = [72; 68; 75; 70; 69]

let firstFive = [1..5]          // [1; 2; 3; 4; 5]
let everyFifth = [0..5..20]     // [0; 5; 10; 15; 20]

printfn "noLaps     = %A" noLaps        // []
printfn "laps       = %A" laps          // [72; 68; 75; 70; 69]
printfn "firstFive  = %A" firstFive     // [1; 2; 3; 4; 5]
printfn "everyFifth = %A" everyFifth    // [0; 5; 10; 15; 20]
```

값 제한이 어떤 모양에서 나는지 보면 규칙이 분명해진다. 리스트를 뒤집는 `List.rev` 에 빈 리스트를 넘긴 결과를 이름에 묶는 순간 일반화가 막힌다.

```fsharp
// 오류 FS0030: 값 제한. 값 'reversed'에 유추된 제네릭 형식이 있습니다.
//              val reversed: '_a list
let reversed = List.rev []

// let mutable pending = [] 도 같은 FS0030 이다
```

컴프리헨션은 `for` 뒤에 오는 식이 곧 원소가 된다. 조건을 끼우면 걸러 내기도 한 번에 된다.

```fsharp id=05-list-basics
let squares = [ for n in 1..5 do n * n ]          // 각 값을 변환
let longLaps = [ for t in laps do if t > 70 then t ]   // 조건을 만족하는 값만

printfn "squares  = %A" squares    // [1; 4; 9; 16; 25]
printfn "longLaps = %A" longLaps   // [72; 75]
```

리스트 맨 앞에 원소를 붙이는 연산자가 cons 연산자 `::` 다. 원본은 불변이라 손대지 않고, 새 리스트는 "새 원소 + 원본을 가리키는 포인터"로 만들어진다. 그래서 원소 수가 늘어도 복사 비용이 붙지 않는다.

```fsharp id=05-list-basics
// 앞 블록의 laps 를 그대로 쓴다
let withWarmUp = 80 :: laps

printfn "withWarmUp = %A" withWarmUp   // [80; 72; 68; 75; 70; 69]
printfn "laps       = %A" laps         // [72; 68; 75; 70; 69]  (원본 그대로)
```

- 비어 있지 않은 리스트는 원소 하나인 머리(head)와 나머지 리스트인 꼬리(tail)로 이루어진다. 꼬리는 빈 리스트일 수 있다.
- 이 구조가 그대로 패턴이 된다. `[]`, `[x]`, `h :: t` 세 가지로 리스트를 분해할 수 있다.
- `h`, `t` 라는 이름 자체에 의미는 없다. 그냥 바인딩 이름이므로 `first :: rest` 로 적어도 똑같이 동작한다.

```fsharp id=05-list-basics
// describe: route: int list -> string
let describe route =
    match route with
    | [] -> "구간 없음"
    | [only] -> $"구간 하나: {only}"
    | first :: rest -> sprintf "머리: %d, 꼬리: %A" first rest

printfn "%s" (describe [])       // 구간 없음
printfn "%s" (describe [72])     // 구간 하나: 72
printfn "%s" (describe laps)     // 머리: 72, 꼬리: [68; 75; 70; 69]
```

원소 하나인 케이스 `[only]` 를 지워도 코드는 여전히 빠짐없는 패턴 매칭(exhaustive pattern matching)이 된다. `[72]` 는 `first :: rest` 로도 매칭되고 그때 `rest` 가 `[]` 이기 때문이다. 케이스를 따로 둘 이유는 원소 하나일 때 다른 문장을 내보내야 할 때뿐이다.

위 코드에는 문자열을 만드는 방식이 두 가지 섞여 있다. `$"..."` 문자열 보간과 `sprintf` 다. 보간에서는 서식 지정자 없이 `{only}` 만 써도 되고, 필요하면 `%A{rest}` 처럼 서식을 붙일 수도 있다. `%A` 는 F# 의 구조 출력기를 쓴다. 리스트나 레코드를 사람이 읽을 수 있게 펼쳐 주고, 구조를 모르는 .NET 타입에서는 그 타입의 `ToString()` 결과를 그대로 쓴다. 원서 p.65 가 `%A` 를 `ToString()` 을 쓰는 것으로 적은 것은 이 뒷부분만 말한 것이다.

두 리스트를 이어 붙일 때는 `@` 연산자를 쓴다. 여러 개를 한 번에 이으려면 `List.concat` 을 쓴다.

```fsharp id=05-list-basics
let morning = [72; 68]
let evening = [75; 70]

// (@) : 'a list -> 'a list -> 'a list
printfn "%A" (morning @ evening)                    // [72; 68; 75; 70]
printfn "%A" (morning @ [])                         // [72; 68]

// List.concat : 'a list seq -> 'a list
printfn "%A" (List.concat [morning; evening; []])   // [72; 68; 75; 70]
```

`List.concat` 의 시그니처가 `'a list list -> 'a list` 가 아니라 `'a list seq -> 'a list` 라는 점이 눈에 띈다. 바깥 컬렉션은 리스트든 배열이든 아무 시퀀스나 받는다는 뜻이다. 그리고 불변이라는 성질 덕분에 `morning` 과 `evening` 은 이어 붙인 뒤에도 그대로 남아 있어 다른 곳에서 마음 놓고 재사용할 수 있다.

이제 모듈 함수 쪽이다. 걸러 내기, 합계, 변환, 반복이 기본 네 가지다.

```fsharp id=05-core
// 이 단위가 보여주는 것: filter / sum / map / iter 와 sumBy

// 택배 상자의 부피(L)
let volumes = [12; 7; 20; 3; 15; 9]

// List.filter : ('a -> bool) -> 'a list -> 'a list
let bulky = volumes |> List.filter (fun v -> v >= 10)
printfn "bulky = %A" bulky   // [12; 20; 15]

// List.sum : ^a list -> ^a
//   (when ^a : (static member (+) : ^a * ^a -> ^a) and ^a : (static member Zero : ^a))
printfn "합계  = %d" (volumes |> List.sum)   // 66
```

`List.filter` 에 넘기는 함수는 `'a -> bool` 형태의 술어(predicate)다. 술어가 참을 돌려준 원소만 남는다.

값을 바꿔서 새 리스트를 얻으려면 `List.map` 을, 결과를 만들지 않고 원소마다 부수 효과(side effect)만 일으키려면 `List.iter` 를 쓴다. 둘의 차이는 시그니처에 그대로 드러난다. `map` 에 넘기는 함수는 `'a -> 'b`, `iter` 에 넘기는 함수는 `'a -> unit` 이다.

```fsharp id=05-core
// List.map : ('a -> 'b) -> 'a list -> 'b list
let inLitres = volumes |> List.map (fun v -> float v * 0.7)
printfn "inLitres = %A" inLitres
// [8.4; 4.9; 14.0; 2.1; 10.5; 6.3]

// List.iter : ('a -> unit) -> 'a list -> unit
volumes |> List.iter (fun v -> printfn "  부피 %2d L" v)
// 부피 12 L / 부피  7 L / ... 여섯 줄
```

`List.map` 은 고차 함수다. `'a -> 'b` 함수를 받아 `'a list` 를 `'b list` 로 바꾼다. `'a` 와 `'b` 가 같아도 되고 위 예처럼 `int list` 에서 `float list` 로 타입이 바뀌어도 된다. C# 을 써 봤다면 LINQ 의 `Select` 가 가장 가깝지만 `Select` 는 지연 평가된다. 지연 평가가 필요하면 `Seq.map` 을 쓰면 된다. 다만 시퀀스는 순회할 때마다 다시 계산되므로 `List` 파이프라인을 그대로 `Seq` 로 바꿔 두면 같은 계산을 여러 번 하게 된다. 이 문제는 6챕터에서 다룬다.

구조가 바뀌는 예를 보자. 튜플 `(int * decimal)` 의 리스트가 있고 앞이 개수, 뒤가 개당 무게라고 하자. 총 무게는 `map` 으로 튜플 리스트를 `decimal` 리스트로 바꾼 뒤 합하면 된다.

```fsharp id=05-core
// 캠핑 장비: (개수, 개당 무게 kg)
let gear = [ (2, 0.35M); (1, 1.80M); (4, 0.12M); (1, 2.40M) ]

// totalWeight: items: (int * decimal) list -> decimal
let totalWeight items =
    items
    |> List.map (fun (count, kg) -> decimal count * kg)
    |> List.sum

printfn "총 무게 = %M kg" (totalWeight gear)   // 5.38 kg
```

여기서 두 가지를 짚어야 한다. 첫째, `decimal count` 라는 변환이 명시적으로 들어갔다. F# 은 계산에서 타입에 엄격해서 `int` 값과 `decimal` 값을 곧바로 곱하는 것 같은 암시적 변환(implicit conversion)을 허용하지 않는다. 둘째, 람다의 매개변수 자리에 `(count, kg)` 라고 적어 튜플을 그 자리에서 분해했다. 람다 매개변수도 패턴이므로 이런 분해가 된다.

`map` 다음에 바로 `sum` 이 오는 이 모양은 흔해서 한 함수로 합쳐 놓았다. `List.sumBy` 다.

```fsharp id=05-core
// List.sumBy : ('a -> ^b) -> 'a list -> ^b
//   (when ^b : (static member (+) : ^b * ^b -> ^b) and ^b : (static member Zero : ^b))
let totalWeightBy items =
    items
    |> List.sumBy (fun (count, kg) -> decimal count * kg)

printfn "총 무게 = %M kg" (totalWeightBy gear)   // 5.38 kg
```

같은 이름 규칙을 따르는 함수가 여럿 있지만 돌려주는 것은 제각각이다. `List.averageBy` 는 `sumBy` 처럼 뽑아낸 값을 집계해 값 하나를 내놓는다. `List.maxBy` 와 `List.minBy` 는 뽑아낸 값을 기준으로 고른 원소를 그대로 돌려주고, `List.countBy` 는 `(키 * 개수)` 튜플의 리스트를 돌려준다. 뒤의 셋은 `map` 뒤에 집계 함수를 붙인 것과 결과 타입이 다르므로 쓰기 전에 시그니처를 확인한다. 그리고 `List.average` 와 `List.averageBy` 에는 함정이 하나 더 있다.

```fsharp id=05-core
// List.averageBy : ('a -> ^b) -> 'a list -> ^b
//   (when ^b : (static member (+) : ^b * ^b -> ^b)
//     and ^b : (static member DivideByInt : ^b * int -> ^b)
//     and ^b : (static member Zero : ^b))
let avgKg = gear |> List.averageBy (fun (_, kg) -> kg)
printfn "평균 무게 = %M kg" avgKg   // 1.1675 kg
```

제약에 `DivideByInt` 가 걸려 있는데 `int` 에는 이 멤버가 없다. 그래서 정수 리스트의 평균을 `List.average` 나 `List.averageBy` 로 바로 구할 수 없고, 아래 코드는 오류 FS0001 로 컴파일에 실패한다.

```fsharp
// 오류 FS0001: 'int' 형식에는 필수(실제 또는 기본 제공) 멤버 'DivideByInt'이(가) 없기 때문에
//              'List.average'이(가) 이 형식을 지원하지 않습니다.
[1; 2; 3] |> List.average
```

`float`, `decimal`, `float32` 에는 컴파일러가 `DivideByInt` 를 기본 제공하므로, 정수 리스트의 평균이 필요하면 먼저 이 세 타입 중 하나로 올려야 한다. `[1; 2; 3] |> List.averageBy float` 로 쓰면 `2.0` 이 나온다. 나눗셈이 들어가는 함수라서 정수를 조용히 잘라 버리는 사고를 타입 수준에서 막아 둔 셈이다.

## Folding — 누적값을 직접 굴리기 (원서 pp.68-69)

- `List.fold` 는 초기값을 상태에 넣고 원소를 하나씩 훑으면서 상태를 갱신하다가, 다 훑으면 마지막 상태를 돌려준다. LINQ 의 `Aggregate` 에 해당한다.
- 앞 절에서 본 `sum`, `sumBy`, `average` 는 전부 `fold` 로 표현할 수 있는 특수한 경우다. 반대로 `fold` 로는 그 함수들이 못 하는 일까지 할 수 있다.
- 그렇다고 `fold` 를 먼저 꺼내지는 말아야 한다. 원서도 목적이 뚜렷한 함수(`sumBy` 같은 것)를 먼저 찾아보라고 권한다. `fold` 는 그런 함수가 없을 때 쓴다.

```fsharp id=05-fold
// 이 단위가 보여주는 것: fold / foldBack / reduce 의 시그니처와 차이

// List.fold : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
// 인자 순서는 folder(상태, 원소) → 초기값 → 입력이고, 결과는 마지막 상태다
printfn "합 = %d" ([1..10] |> List.fold (fun acc v -> acc + v) 0)   // 55

// folder 가 연산자 하나로 끝나면 연산자의 함수 형태로 줄여 쓴다
printfn "합 = %d" ([1..10] |> List.fold (+) 0)   // 55
printfn "곱 = %d" ([1..10] |> List.fold ( * ) 1) // 3628800
```

시그니처를 뜯어보는 것이 중요하다. `folder` 의 타입이 `'a -> 'b -> 'a` 다. 앞이 상태 `'a`, 뒤가 원소 `'b` 이고 결과가 다시 상태 `'a` 다. 그래서 람다를 `fun acc v -> ...` 로 적을 때 첫 매개변수가 누적값(accumulator), 둘째가 원소다. 상태와 원소의 타입이 달라도 되는 것도 여기서 보인다. 초기값은 곱셈이면 `1`, 덧셈이면 `0` 처럼 그 연산의 항등원을 쓰는 것이 보통이다.

방향이 반대인 `List.foldBack` 이 따로 있다. 리스트 끝에서 앞으로 훑는다. 매개변수 순서까지 뒤집혀 있어서 처음 보면 헷갈리기 쉽다.

```fsharp id=05-fold
// List.foldBack : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
// 인자 순서는 folder(원소, 상태) → 입력 → 초기값이고, 결과는 마지막 상태다
// folder 의 첫 매개변수가 원소, 둘째가 상태다. fold 와 정반대다.
let steps = [1; 2; 3]

printfn "fold     = %A" (steps |> List.fold (fun acc v -> v :: acc) [])
// [3; 2; 1]  — 앞에서 뒤로 훑으며 앞에 붙였으므로 뒤집힌다

printfn "foldBack = %A" (List.foldBack (fun v acc -> v :: acc) steps [])
// [1; 2; 3]  — 뒤에서 앞으로 훑으며 앞에 붙였으므로 순서가 유지된다
```

세 가지 차이를 한 번에 정리하면 이렇다. 훑는 방향이 다르고, `folder` 의 매개변수 순서가 다르고, 인자 순서가 다르다. `fold` 는 `folder`, 초기값, 리스트 순이라 `리스트 |> List.fold f 초기값` 으로 파이프에 잘 맞는다. `foldBack` 은 `folder`, 리스트, 초기값 순이라 파이프 끝에 두기 어렵고 보통 `List.foldBack f 리스트 초기값` 으로 직접 적는다.

앞 절의 총 무게 계산도 `fold` 로 쓸 수 있다. 누적값에 튜플에서 계산한 값을 더해 나가면 된다.

```fsharp id=05-fold
let gear = [ (2, 0.35M); (1, 1.80M); (4, 0.12M); (1, 2.40M) ]

// totalWeight: items: (int * decimal) list -> decimal
let totalWeight items =
    items
    |> List.fold (fun acc (count, kg) -> acc + decimal count * kg) 0M

printfn "총 무게 = %M kg" (totalWeight gear)   // 5.38 kg
```

초기값 `0M` 이 누적값의 시작이다. 곱셈으로 누적한다면 `1M` 이 되어야 한다. 파이프 연산자에는 튜플 하나를 두 인자로 풀어 주는 `||>` 도 있어서 초기값과 리스트를 한 쌍으로 넘길 수도 있다.

```fsharp id=05-fold
// (||>) : 'a * 'b -> ('a -> 'b -> 'c) -> 'c
let totalWeightPiped items =
    (0M, items) ||> List.fold (fun acc (count, kg) -> acc + decimal count * kg)

printfn "총 무게 = %M kg" (totalWeightPiped gear)   // 5.38 kg
```

이런 연산자가 요긴한 자리가 분명히 있지만, 이 정도로 단순한 계산에서는 앞의 형태가 읽기 쉽다. 원서 저자도 같은 판단을 적어 두었다.

초기값을 아예 주지 않는 `List.reduce` 도 있다. 첫 원소를 초기값으로 삼는다.

```fsharp id=05-fold
// List.reduce : ('a -> 'a -> 'a) -> 'a list -> 'a
// 상태와 원소의 타입이 같아야 한다. fold 의 'a 와 'b 가 하나로 묶인 꼴이다.
printfn "reduce 합 = %d" ([1..10] |> List.reduce (+))   // 55

// longest: words: string list -> string
let longest words =
    words |> List.reduce (fun a b -> if String.length b > String.length a then b else a)

printfn "가장 긴 낱말 = %s" (longest ["장마"; "소나기"; "돌풍"])   // 소나기
```

`reduce` 는 부분 함수(partial function)다. 가능한 입력 전부에서 값을 돌려주지는 못한다. 빈 리스트에는 초기값으로 쓸 첫 원소가 없으므로 예외를 던진다.

```fsharp id=05-fold
try
    [] |> List.reduce (+) |> printfn "%d"
with :? System.ArgumentException as ex ->
    printfn "reduce [] 는 %s 예외를 던진다" (ex.GetType().Name)
// reduce [] 는 ArgumentException 예외를 던진다
```

`List` 모듈의 부분 함수 상당수에는 `Option` 을 돌려주는 `try` 짝이 있다. `List.head` 에는 `List.tryHead`, `List.find` 에는 `List.tryFind` 가 있다. 그런데 `reduce` 에는 없다. `List.tryReduce` 를 적으면 오류 FS0039 로 그런 이름이 없다는 말이 나온다. 그래서 `reduce` 를 쓸 때는 호출하는 쪽에서 빈 리스트를 직접 걸러야 한다. 반면 `fold` 는 초기값이 있으므로 빈 리스트에서도 그 초기값을 그대로 돌려준다. 빈 리스트 때문에 실패하는 일은 없다(`folder` 가 예외를 던지면 `fold` 도 함께 실패한다). 둘 중에 무엇을 쓸지 고민되면 `fold` 가 안전한 선택이다.

## Grouping Data and Uniqueness — 묶기와 중복 제거 (원서 pp.69-70)

- `List.groupBy` 는 키를 뽑는 함수를 받아 `(키 * 그 키로 묶인 원소들의 리스트)` 튜플의 리스트를 돌려준다.
- 여기서 키만 꺼내면 중복 없는 값 목록이 된다. 하지만 같은 결과를 훨씬 짧게 얻는 `List.distinct` 가 이미 있다.
- 중복 제거만이 목적이라면 `Set` 으로 변환하는 방법도 있다. 다만 정렬 순서가 바뀐다.

```fsharp id=05-group
// 이 단위가 보여주는 것: groupBy / distinct / distinctBy / Set 변환

let tiers = ["일반"; "학생"; "일반"; "경로"; "학생"; "일반"]

// List.groupBy : ('a -> 'b) -> 'a list -> ('b * 'a list) list  (when 'b : equality)
let grouped = tiers |> List.groupBy id
printfn "grouped = %A" grouped
// [("일반", ["일반"; "일반"; "일반"]); ("학생", ["학생"; "학생"]); ("경로", ["경로"])]
```

`fun x -> x` 를 그대로 넘길 자리에는 항등 함수(identity function) `id` 를 쓸 수 있다. `id : 'a -> 'a` 이고, "키를 원소 자체로 삼는다"는 뜻이 이름으로 드러나 읽기에 낫다.

묶인 결과에서 키만 뽑아도 같은 목록이 나온다. 하지만 이 일에는 전용 함수가 있다.

```fsharp id=05-group
// 묶은 뒤 키만 꺼내는 방법
// uniq: items: 'a list -> 'a list  (when 'a : equality)
let uniq items =
    items
    |> List.groupBy id
    |> List.map (fun (key, _) -> key)

printfn "uniq     = %A" (uniq tiers)   // ["일반"; "학생"; "경로"]

// List.distinct : 'a list -> 'a list  (when 'a : equality)
printfn "distinct = %A" (tiers |> List.distinct)   // ["일반"; "학생"; "경로"]

// Set.ofList : 'a list -> Set<'a>  (when 'a : comparison)
printfn "set      = %A" (tiers |> Set.ofList)
// set ["경로"; "일반"; "학생"]
```

세 결과가 담은 값은 같지만 순서가 다르다. `List.groupBy` 와 `List.distinct` 는 처음 나타난 순서를 지키는 반면 `Set` 은 정렬된 컬렉션이라 값의 비교 순서로 재배치한다. 원서 pp.69-70 의 결과 주석은 정렬된 순서로 적혀 있으나 실제 결과는 입력에서 처음 나타난 순서다. 그래서 순서가 의미 있는 데이터라면 `Set` 으로 우회하지 않는 편이 안전하다. 제약도 다르다. `distinct` 는 `equality` 제약만 요구하지만 `Set` 은 `comparison` 제약을 요구한다. 대부분의 컬렉션 타입 사이에는 이런 변환 함수가 양방향으로 준비되어 있다.

키를 따로 뽑아야 하는 경우가 실제로는 더 흔하다. 레코드 리스트를 특정 필드로 묶거나 그 필드 기준으로 중복을 제거하는 일이다.

```fsharp id=05-group
type Ticket = { Code: string; Tier: string }

let tickets =
    [ { Code = "T-01"; Tier = "일반" }
      { Code = "T-02"; Tier = "학생" }
      { Code = "T-03"; Tier = "일반" }
      { Code = "T-04"; Tier = "경로" } ]

// 등급별 장수 세기
let counts =
    tickets
    |> List.groupBy (fun t -> t.Tier)
    |> List.map (fun (tier, ts) -> tier, List.length ts)

printfn "counts = %A" counts
// [("일반", 2); ("학생", 1); ("경로", 1)]
```

`groupBy` 다음에 `List.length` 로 개수를 세는 모양에도 전용 함수가 있다. `List.countBy (fun t -> t.Tier)` 가 같은 결과를 낸다.

`List.distinctBy` 는 키가 중복되면 먼저 나온 원소를 남기고 나머지를 버린다. 돌려주는 것은 키가 아니라 원래 원소라는 점을 시그니처에서 확인해 두는 것이 좋다.

```fsharp id=05-group
// List.distinctBy : ('a -> 'b) -> 'a list -> 'a list  (when 'b : equality)
// 결과 타입이 'b list 가 아니라 'a list 다. 원소를 남긴다.
let samples = tickets |> List.distinctBy (fun t -> t.Tier)

samples |> List.iter (fun t -> printfn "  %s / %s" t.Code t.Tier)
// T-01 / 일반
// T-02 / 학생
// T-04 / 경로
```

## Solving a Problem in Many Ways — 같은 문제, 여러 풀이 (원서 pp.70-71)

- `List` 모듈에 함수가 넉넉하게 있으니 대부분의 문제는 여러 방식으로 풀린다.
- 여기서 풀 문제는 이렇다. 회선별 데이터 사용량 목록이 있고 무료 한도가 100 GB 다. 한도를 넘긴 회선의 초과분만 모아 합계를 구한다.
- 풀이마다 중간에 만들어지는 리스트의 개수와 실패 가능성이 다르다. 그 차이가 코드에 드러나게 나눠 본다.

```fsharp id=05-many-ways
// 이 단위가 보여주는 것: 같은 집계를 여섯 가지 방식으로 푸는 비교

// 회선별 데이터 사용량(GB), 무료 한도는 100
let usage = [40; 120; 95; 260; 100; 175]
```

첫째, 단계별로 나눠 쓰는 방법이다. 걸러 내고, 바꾸고, 합한다. 의도가 가장 명확하지만 중간 리스트가 두 개 만들어진다.

```fsharp id=05-many-ways
let stepByStep =
    usage
    |> List.filter (fun gb -> gb > 100)
    |> List.map (fun gb -> gb - 100)
    |> List.sum

printfn "단계별      = %d" stepByStep   // 255
```

둘째, `List.choose` 로 걸러 내기와 변환을 한 번에 하는 방법이다. `'a -> 'b option` 함수를 받아 `Some` 인 것만 남기고 껍데기를 벗겨 준다. 중간 리스트가 하나로 줄고, "골라내면서 바꾼다"는 뜻이 한 줄에 들어온다.

```fsharp id=05-many-ways
// List.choose : ('a -> 'b option) -> 'a list -> 'b list
let withChoose =
    usage
    |> List.choose (fun gb -> if gb > 100 then Some (gb - 100) else None)
    |> List.sum

printfn "choose      = %d" withChoose   // 255
```

셋째, `List.collect` 를 쓰는 방법이다. `'a -> 'b list` 함수를 받아 결과 리스트들을 하나로 이어 붙인다. 원소 하나가 결과 0개나 여러 개로 늘어나는 경우에 맞는 함수이고, 이 문제에서는 `choose` 로 충분하므로 굳이 쓸 이유가 없다.

```fsharp id=05-many-ways
// List.collect : ('a -> 'b list) -> 'a list -> 'b list
let withCollect =
    usage
    |> List.collect (fun gb -> if gb > 100 then [gb - 100] else [])
    |> List.sum

printfn "collect     = %d" withCollect   // 255
```

넷째, `fold` 로 한 번만 훑는 방법이다. 중간 리스트가 아예 없다. 대신 누적값과 조건 판단이 한 람다에 섞여 읽기가 무거워진다.

```fsharp id=05-many-ways
let withFold =
    usage
    |> List.fold (fun acc gb -> acc + (if gb > 100 then gb - 100 else 0)) 0

printfn "fold        = %d" withFold   // 255
```

다섯째는 쓰면 안 되는 방법이다. `fold` 를 `reduce` 로 바꾸고 싶어지지만 이 문제에서는 틀린 답이 나온다. 이유가 두 가지다. `reduce` 는 부분 함수라 빈 리스트를 따로 처리해야 하고, 더 중요한 것은 첫 원소가 `reduce` 에 넘긴 함수(FSharp.Core 의 매개변수 이름은 `reduction` 이다)를 거치지 않고 그대로 초기 상태가 된다는 점이다. 즉 첫 회선의 사용량 `40` 이 초과분 계산 없이 합계에 얹힌다.

```fsharp id=05-many-ways
let withReduce =
    match usage with
    | [] -> 0
    | items ->
        items
        |> List.reduce (fun acc gb -> acc + (if gb > 100 then gb - 100 else 0))

printfn "reduce      = %d" withReduce   // 295  — 틀렸다. 첫 원소 40 이 그대로 더해졌다
```

여섯째, 권장하는 형태다. `sumBy` 하나로 끝난다. 넘지 않은 회선은 `0` 을 내놓게 하면 걸러 내기가 필요 없다.

```fsharp id=05-many-ways
let recommended =
    usage
    |> List.sumBy (fun gb -> if gb > 100 then gb - 100 else 0)

printfn "sumBy       = %d" recommended   // 255
```

정리하면 고르는 순서는 이렇다. 목적이 뚜렷한 전용 함수(`sumBy`, `countBy`, `maxBy`)를 먼저 찾고, 없으면 `filter`/`map`/`choose` 를 조합하고, 그래도 표현이 안 되면 `fold` 로 내려간다. `reduce` 는 상태와 원소의 타입이 같고 빈 리스트가 들어올 수 없다고 확신할 때만 쓴다.

## Working Through a Practical Example — 배운 것을 묶어 쓰기 (원서 pp.71-79)

- 여기서 만드는 것은 불변 리스트를 품은 도메인 타입과 그 리스트를 갱신하는 함수다. 원서는 주문과 주문 항목으로 예를 들었다. 이 노트는 커피 배합표로 같은 구조를 만든다.
- 필요한 기능은 다섯 가지다. 원두 추가, 이미 있는 원두의 양 늘리기, 원두 제거, 양 줄이기, 전부 비우기.
- 갱신 함수는 모두 새 `Blend` 를 돌려준다. 원본은 손대지 않는다. 리스트도 레코드도 불변이므로 이것이 자연스러운 형태다.

```fsharp id=05-blend
// 이 단위가 보여주는 것: 불변 리스트를 품은 도메인에 갱신 기능을 붙이는 과정

type Portion = { BeanId: int; Grams: int }
type Blend = { BlendId: int; Portions: Portion list }
```

원서는 의사 코드로 순서를 먼저 적고 단계별로 채워 나간다. 같은 방식으로 생각하면 원두를 추가하는 함수는 네 단계다. 새 항목을 리스트 앞에 붙이고, 같은 원두를 하나로 합치고, 원두 번호로 정렬하고, 배합표를 새 리스트로 갱신한다.

첫 시도는 1단계와 4단계만 하는 것이다.

```fsharp
// 아직 미완성이다. 같은 원두를 추가하면 항목이 둘로 남는다.
let addPortion portion blend =
    { blend with Portions = portion :: blend.Portions }
```

이 상태로는 이미 있는 원두를 추가했을 때 `[{1; 300}; {1; 250}]` 처럼 같은 번호가 두 줄로 남는다. 원두별로 합치려면 `List.groupBy` 가 필요하다. 그런데 `groupBy` 는 `(int * Portion list) list` 를 돌려주므로 `Portions` 필드가 기대하는 `Portion list` 와 타입이 맞지 않아 컴파일되지 않는다. 묶은 결과를 `List.map` 으로 다시 `Portion` 으로 만들어야 한다. 마지막으로 정렬까지 넣으면 완성이다. 정렬이 있어야 리스트의 구조적 동등성(structural equality) 비교가 항목 순서에 흔들리지 않는다.

세 함수가 이 "합치고 정렬하기"를 공유하므로 처음부터 따로 뽑아 둔다.

```fsharp id=05-blend
// recalculate: portions: Portion list -> Portion list
let recalculate portions =
    portions
    |> List.groupBy (fun p -> p.BeanId)              // (int * Portion list) list
    |> List.map (fun (beanId, ps) ->                  // 다시 Portion list 로
        { BeanId = beanId; Grams = ps |> List.sumBy (fun p -> p.Grams) })
    |> List.sortBy (fun p -> p.BeanId)                // 동등성 비교를 쉽게 하려고 정렬

// addPortion: portion: Portion -> blend: Blend -> Blend
let addPortion portion blend =
    let portions =
        portion :: blend.Portions
        |> recalculate
    { blend with Portions = portions }
```

`portion :: blend.Portions |> recalculate` 가 의도대로 읽히는 것은 `::` 가 `|>` 보다 강하게 묶기 때문이다. cons 가 먼저 일어나고 그 결과가 파이프로 넘어간다.

원두를 여러 개 한 번에 넣으려면 cons 연산자만 `@` 로 바꾸면 된다. `::` 는 원소 하나를 앞에 붙이고 `@` 는 리스트 둘을 잇는다. 나머지 로직은 그대로다.

```fsharp id=05-blend
// addPortions: newPortions: Portion list -> blend: Blend -> Blend
let addPortions newPortions blend =
    let portions =
        newPortions @ blend.Portions
        |> recalculate
    { blend with Portions = portions }
```

제거는 `List.filter` 로 원두 번호가 다른 것만 남기면 된다.

```fsharp id=05-blend
// removeBean: beanId: int -> blend: Blend -> Blend
let removeBean beanId blend =
    let portions =
        blend.Portions
        |> List.filter (fun p -> p.BeanId <> beanId)
        |> List.sortBy (fun p -> p.BeanId)
    { blend with Portions = portions }
```

양을 줄이는 함수가 가장 재미있다. 줄일 양을 음수로 만들어 리스트에 넣고 `recalculate` 에 맡기면 합산만으로 차감이 된다. 그다음 `Grams` 가 0 이하인 항목을 버리면 "전량을 줄이면 항목이 사라진다"와 "없는 원두를 줄이려 하면 아무 일도 없다"가 동시에 처리된다. 없는 원두의 음수 항목은 합산 결과가 음수로 남아 필터에서 버려진다.

```fsharp id=05-blend
// reduceBean: beanId: int -> grams: int -> blend: Blend -> Blend
let reduceBean beanId grams blend =
    let portions =
        { BeanId = beanId; Grams = -grams } :: blend.Portions
        |> recalculate
        |> List.filter (fun p -> p.Grams > 0)
    { blend with Portions = portions }

// clearPortions: blend: Blend -> Blend
let clearPortions blend = { blend with Portions = [] }
```

원서는 함수를 하나 만들 때마다 xUnit 테스트를 붙이고 `dotnet test` 로 돌린다. 4챕터에서 만든 구조를 쓰고 이중 백틱 이름으로 상황을 문장처럼 적는다. 이 노트에서는 아래 형태가 그 테스트에 해당한다. 원서의 `Orders.fs` / `module Domain` 에 해당하는 것이 여기서는 `Blends.fs` / `module Recipe` 다. 테스트 파일의 네임스페이스는 원서 p.74 를 따랐다. 원서 p.71 은 같은 파일에 `namespace MyProject.Orders` 를 적으라고 했다가 p.74 에서 `namespace OrderTests` 로 바꾸는데, 앞의 것은 코드 쪽 파일의 네임스페이스이므로 그대로 따르면 `open` 이 자기 네임스페이스를 여는 모양이 된다.

```fsharp
namespace BlendTests

open MyProject.Blends
open MyProject.Blends.Recipe
open Xunit
open FsUnit

module ``원두를 배합표에 추가할 때`` =

    [<Fact>]
    let ``빈 배합표에 없던 원두를 넣으면 항목이 하나 생긴다`` () =
        let blend = { BlendId = 1; Portions = [] }
        let expected = { BlendId = 1; Portions = [ { BeanId = 1; Grams = 250 } ] }
        let actual = blend |> addPortion { BeanId = 1; Grams = 250 }
        actual |> should equal expected
```

FSI 로만 확인할 때는 기댓값과 실제값을 `=` 로 비교해 참인지 보면 된다. 레코드와 리스트 모두 구조적 동등성이 있어서 필드 하나씩 꺼내 볼 필요가 없다.

```fsharp id=05-blend
let check label expected actual =
    printfn "%s  %s" (if actual = expected then "OK  " else "FAIL") label

let house = { BlendId = 1; Portions = [ { BeanId = 1; Grams = 300 } ] }
let blank = { BlendId = 9; Portions = [] }

check "빈 배합표에 새 원두"
    { BlendId = 9; Portions = [ { BeanId = 1; Grams = 250 } ] }
    (blank |> addPortion { BeanId = 1; Grams = 250 })

check "없던 원두를 추가"
    { BlendId = 1; Portions = [ { BeanId = 1; Grams = 300 }; { BeanId = 2; Grams = 120 } ] }
    (house |> addPortion { BeanId = 2; Grams = 120 })

check "있던 원두를 추가하면 합산"
    { BlendId = 1; Portions = [ { BeanId = 1; Grams = 420 } ] }
    (house |> addPortion { BeanId = 1; Grams = 120 })
// OK    빈 배합표에 새 원두
// OK    없던 원두를 추가
// OK    있던 원두를 추가하면 합산
```

나머지 함수도 같은 방식으로 확인한다. 경계 조건을 빠뜨리지 않는 것이 요령이다. 빈 배합표, 없는 원두, 전량 차감이 그것이다.

```fsharp id=05-blend
check "여러 개를 한 번에"
    { BlendId = 1; Portions = [ { BeanId = 1; Grams = 400 }; { BeanId = 3; Grams = 50 } ] }
    (house |> addPortions [ { BeanId = 1; Grams = 100 }; { BeanId = 3; Grams = 50 } ])

check "원두 제거"
    { BlendId = 1; Portions = [] }
    (house |> removeBean 1)

check "없는 원두 제거는 무변화"
    house
    (house |> removeBean 7)

check "양 줄이기"
    { BlendId = 1; Portions = [ { BeanId = 1; Grams = 200 } ] }
    (house |> reduceBean 1 100)

check "전량을 줄이면 항목이 사라진다"
    { BlendId = 1; Portions = [] }
    (house |> reduceBean 1 300)

check "없는 원두를 줄여도 무변화"
    house
    (house |> reduceBean 5 50)

check "빈 배합표에서 줄여도 무변화"
    blank
    (blank |> reduceBean 5 50)

check "전부 비우기"
    { BlendId = 1; Portions = [] }
    (house |> clearPortions)

// 모든 갱신을 거친 뒤에도 원본은 그대로다
check "원본 불변"
    { BlendId = 1; Portions = [ { BeanId = 1; Grams = 300 } ] }
    house
// OK    여러 개를 한 번에
// OK    원두 제거
// OK    없는 원두 제거는 무변화
// OK    양 줄이기
// OK    전량을 줄이면 항목이 사라진다
// OK    없는 원두를 줄여도 무변화
// OK    빈 배합표에서 줄여도 무변화
// OK    전부 비우기
// OK    원본 불변
```

마지막 검사가 이 절의 요점이다. 갱신 함수를 아무리 많이 호출해도 `house` 는 처음 값 그대로다. 상태를 제자리에서 바꾸지 않고 새 값을 만들어 돌려주기 때문에, 테스트가 서로 간섭하지 않고 순서에 상관없이 돌아간다.

## Summary — 원서의 챕터 요약 (원서 p.79)

- 원서는 이 챕터에서 `List` 모듈의 유용한 함수들을 살펴봤다고 정리한다. `Seq` 와 `Array` 모듈에도 비슷한 함수들이 있고 이어지는 챕터에서 나온다.
- 불변 데이터 구조만으로도 짧고 견고한 업무 기능을 만들 수 있다는 것을 실전 예제에서 확인했다는 말도 덧붙인다.
- 컬렉션으로 할 수 있는 일의 표면만 훑었으므로 `List` 모듈 전체는 F# 공식 문서를 보라고 권한다. 커뮤니티 기여로 모듈 함수마다 예제 코드가 붙어 있다.
- 다음 챕터에서는 CSV 파일에서 데이터 스트림을 읽어 처리하는 방법을 다룬다.

## 정리 — 이 노트의 요약

- F# 의 주요 컬렉션은 `Seq`(지연), `Array`(즉시·연속 메모리), `List`(즉시·불변 연결 리스트) 셋이다. C# 의 `List<'T>` 는 F# 에서 `ResizeArray<'T>` 이며 F# 의 `List` 와 다른 것이다.
- 리스트는 머리와 꼬리로 이루어지고, 그 구조가 `[]` / `[x]` / `h :: t` 패턴으로 그대로 쓰인다. `[x]` 케이스는 없어도 빠짐없는 패턴 매칭이 되며, 원소 하나일 때 다른 결과를 내야 할 때만 따로 둔다.
- 빈 리스트 `[]` 는 자동 일반화로 `'a list` 가 되지만, `List.rev []` 처럼 함수 적용 결과를 매개변수 없는 `let` 에 묶으면 값 제한 오류 FS0030 이 난다.
- `::` 는 원소 하나를 앞에 붙이고 `@` 는 리스트 둘을 잇는다. `::` 가 `|>` 보다 강하게 묶이므로 `x :: xs |> f` 는 `(x :: xs) |> f` 로 읽힌다.
- `List.map` 은 새 리스트를 만들고(`'a -> 'b`), `List.iter` 는 부수 효과만 낸다(`'a -> unit`). 시그니처의 반환 타입이 둘의 용도를 가른다.
- `map` 뒤에 `sum` 을 붙이는 모양은 `sumBy` 하나로 줄어들고 `averageBy` 도 같다. 다만 `maxBy`/`minBy` 는 뽑아낸 값이 아니라 원소를 돌려주고 `countBy` 는 `(키 * 개수)` 튜플의 리스트를 돌려주므로 결과 타입이 다르다.
- `List.average` 와 `List.averageBy` 는 `DivideByInt` 제약 때문에 `int` 에 쓸 수 없다(오류 FS0001). `float` 나 `decimal` 로 먼저 올려야 한다.
- `List.fold` 의 `folder` 는 `'a(상태) -> 'b(원소) -> 'a` 다. `List.foldBack` 의 `folder` 는 `'a(원소) -> 'b(상태) -> 'b` 로 매개변수 순서가 뒤집히고 인자 순서도 다르다.
- `List.reduce` 는 상태와 원소의 타입이 같아야 하고 첫 원소를 초기값으로 쓴다. 그래서 빈 리스트에서 `ArgumentException` 을 던지고, 첫 원소는 `reduction` 을 거치지 않는다. `List.tryReduce` 는 존재하지 않는다.
- `List.groupBy` 는 `('b * 'a list) list` 를 돌려준다. 중복 제거만 필요하면 `List.distinct` 가 짧고, `Set.ofList` 는 순서를 정렬 순서로 바꾸며 `comparison` 제약을 요구한다.
- `List.distinctBy` 가 돌려주는 것은 키가 아니라 원소다(`'a list`). 키가 겹치면 먼저 나온 원소가 남는다.
- 함수를 고르는 순서는 전용 집계 함수 → `filter`/`map`/`choose` 조합 → `fold` 다. `reduce` 는 조건이 맞을 때만 쓴다.
- 불변 컬렉션을 품은 레코드는 갱신 함수가 새 값을 돌려주게 만든다. 정렬을 한 번 끼워 두면 구조적 동등성 비교 한 줄로 전체를 검증할 수 있다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Before We Start — 준비 | p.63 | — |
| The Basics — 세 가지 컬렉션과 그 차이 | p.63 | — |
| Core Functionality — 리스트 만들기와 핵심 함수 | pp.63-68 | `05-list-basics`, `05-core` |
| Folding — 누적값을 직접 굴리기 | pp.68-69 | `05-fold` |
| Grouping Data and Uniqueness — 묶기와 중복 제거 | pp.69-70 | `05-group` |
| Solving a Problem in Many Ways — 같은 문제, 여러 풀이 | pp.70-71 | `05-many-ways` |
| Working Through a Practical Example — 배운 것을 묶어 쓰기 | pp.71-79 | `05-blend` |
| Summary — 원서의 챕터 요약 | p.79 | — |
