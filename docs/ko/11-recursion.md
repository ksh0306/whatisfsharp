# 11 - 재귀 (원서 pp.141-152)

> 자기 자신을 부르는 함수로 반복을 표현하는 것이 재귀다. 명령형 언어의 `for`/`while` 이 하는 일을 함수 호출 하나로 바꿔 놓는 셈이고, 상태를 변경하지 않고도 반복을 쓸 수 있다는 점에서 함수형 코드와 잘 맞는다. 다만 소박하게 적은 재귀는 호출이 돌아올 때까지 할 일을 스택에 쌓아 두므로 입력이 커지면 메모리를 먹고 결국 스택을 넘긴다. 이 챕터는 그 문제를 누적값(accumulator)과 꼬리 재귀(tail recursion)로 푸는 방법, 같은 일을 5챕터의 `List.fold` 로 다시 쓰는 방법, 그리고 재귀가 가장 자연스러운 자리인 계층 데이터 처리를 다룬다. 5챕터에서 `fold` 의 `folder` 가 (상태, 원소) 순이었던 것을 기억해 두면 이 챕터의 절반은 이미 아는 이야기가 된다.

## Setting Up — 준비 (원서 p.141)

- 원서는 새 폴더를 만들고 `.fsx` 파일을 FSI 로 돌리는 것이 전부다. 패키지도 프로젝트도 필요 없다.
- 이 노트의 예제는 원서와 도메인을 달리 잡았다. 공연 편성 가짓수, 주간조·야간조 교대, 계단 오르는 경로 수, 공연 부대 행사표, 응답 시간 정렬, 창고 구역 트리, 섬 항로망 최단 경로다. 마지막 항로망 문제만 원서와 구조가 같고(계층 데이터에서 최단 경로 찾기) 데이터와 자료구조 정의는 새로 잡았다.
- 원서는 항로 데이터를 `resources/data.csv` 파일에서 읽는다. 파일 읽기는 6챕터의 주제이므로 이 노트는 같은 CSV 를 문자열 리터럴로 코드 안에 두고 파싱만 보인다.

## Solving The Problem — 재귀 함수의 두 갈래 (원서 pp.141-142)

- 재귀 함수를 만들려면 `let rec` 로 선언한다. `rec` 이 있어야 함수 본문에서 자기 이름을 볼 수 있다.
- 재귀 함수는 반드시 두 갈래로 갈린다. 재귀를 멈추고 값을 내놓는 기저 경우(base case)와, 자기를 다시 부르는 재귀 경우다.
- 기저 경우가 없거나 입력이 그 지점에 닿지 못하면 함수는 끝나지 않는다. 갈래를 패턴 매칭으로 적는 것이 관례인데, 와일드카드 없이 갈래를 늘어놓으면 빠뜨린 갈래를 컴파일러가 경고 FS0025 로 알려 주기 때문이다.
- 원서는 팩토리얼로 이 구조를 보인다. 여기서는 공연 `n` 편을 한 무대에 올릴 때 순서를 짜는 방법의 수로 같은 점화식을 쓴다.

```fsharp id=11-basics
// 이 단위가 보여주는 것: rec 키워드, 기저 경우와 재귀 경우, 상호 재귀
// 공연 n 편의 편성 순서 가짓수는 n! 이다
// orderCount: n: int -> int64
let rec orderCount n =
    match n with
    | 0 | 1 -> 1L
    | n -> int64 n * orderCount (n - 1)

printfn "5편 편성 = %d 가지" (orderCount 5)     // 5편 편성 = 120 가지
printfn "10편 편성 = %d 가지" (orderCount 10)   // 10편 편성 = 3628800 가지
```

기저 경우는 `0` 과 `1` 이고, 나머지가 재귀 경우다. 재귀 호출이 어떤 순서로 풀리는지 손으로 펼쳐 보면 이 구현의 성질이 드러난다.

```text
orderCount 4
→ 4 * orderCount 3
→ 4 * (3 * orderCount 2)
→ 4 * (3 * (2 * orderCount 1))
→ 4 * (3 * (2 * 1))
→ 4 * (3 * 2)
→ 4 * 6
→ 24
```

곱셈은 가장 안쪽 호출이 값을 내놓은 뒤에야 시작된다. 그때까지 `4 *`, `3 *`, `2 *` 라는 "돌아오면 할 일"이 전부 살아 있어야 하고, 그것을 담아 두는 자리가 스택 프레임(stack frame)이다. `n` 이 커지면 프레임 수가 그만큼 늘어난다. 이것이 꼬리 호출 절에서 고칠 문제다.

`rec` 을 빼면 이름을 아직 모르는 상태에서 자신을 부르는 꼴이 되어 컴파일되지 않는다.

```fsharp
// rec 이 없는 버전 — 오류 FS0039
let orderCount n =
    match n with
    | 0 | 1 -> 1L
    | n -> int64 n * orderCount (n - 1)
// error FS0039: 'orderCount' 값 또는 생성자가 정의되지 않았습니다.
```

기저 경우를 적었어도 입력이 그리로 가지 않으면 소용이 없다. 위 `orderCount` 에 음수를 넣으면 `n` 이 계속 작아지면서 `0` 을 지나쳐 버린다.

```fsharp
// 기저 경우에 닿지 못하는 호출 — 실행하면 프로세스가 죽는다
orderCount (-1)
```

인자를 `(-1)` 로 괄호에 넣은 것은 관례일 뿐이다. F# 은 앞에 공백이 있고 뒤에 공백이 없는 `-1` 을 음수 리터럴로 읽으므로 `orderCount -1` 도 `orderCount (-1)` 과 똑같이 파싱돼 그대로 실행된다. 적용으로 읽힌다는 것은 함수가 아닌 값에 붙여 보면 드러난다 — `let g = 10` 뒤에 `g -1` 을 적으면 `error FS0003: 이 값은 함수가 아니며 적용할 수 없습니다.` 가 난다. 뺄셈이 되는 것은 `orderCount - 1` 처럼 `-` 양쪽에 공백을 둘 때이고, 그때는 타입이 맞지 않아 오류 FS0001 이 난다. 이 호출은 예외로 잡히지 않는다. .NET 의 `StackOverflowException` 은 `try ... with` 로 잡을 수 없고 프로세스를 그대로 끝낸다. 실행하면 표준 오류에 `Stack overflow.` 한 줄과 같은 함수 이름이 반복되는 스택 목록이 찍히고 종료 코드 134 로 죽는다. 그래서 이 블록에는 `id` 를 붙이지 않았다. 같은 현상을 다른 함수로 실측한 값은 뒤의 꼬리 호출 절에 적어 뒀다. 재귀를 적을 때 기저 경우가 실제로 닿는지 확인하는 것은 문법 문제가 아니라 논리 문제다. 원서의 팩토리얼도 기저 경우가 `1` 하나뿐이어서 `0` 을 넣으면 같은 일이 벌어진다.

### 상호 재귀 — `and` 로 잇는다 (노트 보충)

원서는 다루지 않지만 재귀 문법에는 갈래가 하나 더 있다. 두 함수가 서로를 부르는 상호 재귀(mutual recursion)다. `let rec` 로 첫 함수를 열고 둘째부터 `and` 로 잇는다.

```fsharp id=11-basics
// 상호 재귀: 주간조와 야간조가 하루씩 번갈아 근무한다
// dayShiftOn: n: int -> bool
let rec dayShiftOn n =
    if n = 0 then true else nightShiftOn (n - 1)
// nightShiftOn: n: int -> bool
and nightShiftOn n =
    if n = 0 then false else dayShiftOn (n - 1)

printfn "7일 뒤 주간조 근무? %b" (dayShiftOn 7)     // 7일 뒤 주간조 근무? false
printfn "7일 뒤 야간조 근무? %b" (nightShiftOn 7)   // 7일 뒤 야간조 근무? true
printfn "10000000일 뒤 주간조 근무? %b" (dayShiftOn 10_000_000)   // 10000000일 뒤 주간조 근무? true
```

F# 은 파일 위에서 아래로 이름을 확인하므로, `and` 없이 두 함수를 따로 적으면 먼저 나온 쪽이 아직 없는 이름을 부르게 되어 실패한다. `rec` 을 빼고 `and` 만 쓰는 것도 막혀 있다.

```fsharp
// rec 없이 and 만 쓴 경우 — 오류 FS0576
let dayShiftOn n = if n = 0 then true else nightShiftOn (n - 1)
and nightShiftOn n = if n = 0 then false else dayShiftOn (n - 1)
// error FS0576: 비재귀적 바인딩을 위한 선언 형식 'let ... and ...'는 F# 코드에서 사용되지 않습니다. 대신 'let' 바인딩 시퀀스를 사용하세요.
```

두 함수 모두 재귀 호출의 결과가 곧 자기 결과이므로 프레임이 쌓이지 않는다. 그래서 1000만 일도 즉시 끝난다. 다만 다른 함수로 넘어가는 재귀에서 이 성질이 성립하는 데는 조건이 하나 붙는데, 그 조건은 꼬리 호출을 정의한 다음 절에서 적는다. 물론 이 계산 자체는 `n % 2 = 0` 한 줄로 끝나므로 상호 재귀를 쓸 자리가 아니다. 상호 재귀가 제 몫을 하는 자리는 서로를 참조하는 타입 두 개를 함께 훑을 때다. 트리의 가지와 말단을 각각 다른 타입으로 정의했다면 두 순회 함수가 서로를 부르는 모양이 된다.

## Tail Call Optimisation — 꼬리 호출과 누적값 (원서 pp.142-143)

- 함수가 마지막으로 하는 일이 어떤 호출이고 그 호출의 결과가 곧 그 함수의 반환값이면, 즉 호출이 돌아온 뒤에 할 일이 남지 않으면 그 호출을 꼬리 호출(tail call)이라고 한다. 재귀 호출일 필요는 없다.
- 꼬리 호출은 돌아올 자리를 기억할 필요가 없으므로 컴파일러와 런타임이 프레임을 새로 쌓지 않고 재사용한다. 결과적으로 반복문과 같은 메모리를 쓴다. 이것이 꼬리 호출 최적화(tail call optimisation)다.
- 이 최적화에는 조건이 하나 붙는다. 자기 자신을 직접 부르는 꼬리 호출은 컴파일러가 반복문으로 바꿔 주므로 언제나 성립하지만, 앞 절의 상호 재귀처럼 다른 함수로 넘어가는 꼬리 호출은 컴파일러 옵션 `--tailcalls+` 가 켜져 있어야 한다. `dotnet fsi` 와 Release 빌드는 켜져 있고 Debug 프로젝트 빌드는 `--tailcalls-` 이므로, 앞 절의 `dayShiftOn` 을 프로젝트에 옮겨 Debug 로 빌드하면 1000만에서 스택을 넘긴다.
- 소박한 재귀를 꼬리 재귀로 바꾸는 표준 수법이 누적값이다. 지금까지 계산한 결과를 매개변수로 함께 넘겨서, 재귀 호출을 마지막 동작으로 만든다.
- 누적값을 공개 시그니처에 노출하지 않으려면 안쪽에 `loop` 같은 지역 함수를 두고 바깥 함수가 초기값을 넣어 첫 호출을 한다. 원서도 이 배치를 쓴다.
- 누적값을 한 연산으로 이어 붙여 나가는 꼴이면 초기값은 그 연산의 항등원이다. 곱셈이면 `1`, 덧셈이면 `0` 이다. 5챕터에서 `List.fold` 의 초기값을 정할 때와 똑같은 기준이다. 점화식의 시작 값을 나르는 누적값은 이 기준에서 벗어난다. 뒤에 나오는 `stepWays` 가 그런 경우다.

```fsharp id=11-tailrec
// 이 단위가 보여주는 것: 누적값을 나르는 꼬리 재귀
// 앞 절의 소박한 버전과 공개 시그니처가 같다
// orderCount: n: int -> int64
let orderCount n =
    let rec loop remaining acc =
        match remaining with
        | 0 | 1 -> acc
        | n -> loop (n - 1) (acc * int64 n)
    loop n 1L

printfn "5편 편성 = %d 가지" (orderCount 5)     // 5편 편성 = 120 가지
printfn "10편 편성 = %d 가지" (orderCount 10)   // 10편 편성 = 3628800 가지
```

바뀐 것은 세 가지다. 재귀를 지역 함수 `loop` 로 옮겼고, `acc` 매개변수를 더했고, 바깥 함수 끝에 `loop n 1L` 로 첫 호출을 하는 줄을 뒀다. 기저 경우가 돌려주는 값이 `1L` 이 아니라 `acc` 라는 점이 핵심이다. 계산이 이미 끝나 있으므로 그것을 그대로 내놓기만 한다.

```text
orderCount 4
→ loop 4 1
→ loop 3 4
→ loop 2 12
→ loop 1 24
→ 24
```

앞 절의 전개와 견주면 괄호가 사라졌다. 매 단계에서 살아 있어야 하는 값은 `remaining` 과 `acc` 두 개뿐이고, 돌아와서 할 일이 없으므로 프레임이 쌓이지 않는다.

```fsharp id=11-tailrec
// 덧셈으로 누적하면 초기값이 0 이다
// sumHours: n: int -> int64
let sumHours n =
    let rec loop remaining acc =
        match remaining with
        | 0 -> acc
        | n -> loop (n - 1) (acc + int64 n)
    loop n 0L

printfn "1..1000000 누적 = %d" (sumHours 1_000_000)   // 1..1000000 누적 = 500000500000
```

100만 번을 돌아도 즉시 끝난다. 같은 계산을 누적값 없이 적으면 어떻게 되는지가 이 절의 요점이다.

```fsharp
// 누적값이 없는 버전 — 재귀 호출 뒤에 덧셈이 남아 있어 꼬리 호출이 아니다
let rec sumHoursNaive n =
    match n with
    | 0 -> 0L
    | n -> int64 n + sumHoursNaive (n - 1)

printfn "%d" (sumHoursNaive 200_000)   // 이 저장소에서는 통과했다
printfn "%d" (sumHoursNaive 500_000)   // 스택을 넘긴다
```

이 저장소에서 실측한 결과는 이렇다. `sumHoursNaive 200_000` 은 `20000100000` 을 정상으로 돌려줬고, 이어서 `sumHoursNaive 500_000` 에서 `Stack overflow.` 와 `Repeated ... times:` 로 시작하는 스택 목록을 찍으며 종료 코드 134 로 프로세스가 죽었다. 반복 횟수는 26만 번대이고 실행마다 달라진다. 정확한 한계는 스택 크기와 프레임 크기에 따라 달라지므로 숫자 자체를 외울 것은 아니다. 중요한 것은 소박한 재귀에는 입력 크기에 비례하는 상한이 있고 그 상한을 넘기면 예외가 아니라 프로세스 종료로 나타난다는 점이다. 꼬리 재귀에는 그 상한이 없다.

### `[<TailCall>]` 로 컴파일러에게 확인받기 (노트 보충)

꼬리 호출인지 아닌지는 눈으로 판단해야 하는데, 함수가 길어지면 놓치기 쉽다. F# 8 부터는 `[<TailCall>]` 특성을 붙여 컴파일러에게 검사를 맡길 수 있다.

```fsharp id=11-tailrec
// F# 8 부터 쓸 수 있는 [<TailCall>] — 꼬리 호출이 맞으므로 조용히 통과한다
// countDown: remaining: int -> acc: int64 -> int64
[<TailCall>]
let rec countDown remaining acc =
    match remaining with
    | 0 -> acc
    | n -> countDown (n - 1) (acc + int64 n)

printfn "countDown 1000000 = %d" (countDown 1_000_000 0L)   // countDown 1000000 = 500000500000
```

특성을 꼬리 호출이 아닌 함수에 붙이면 경고가 나온다. `sumTo` 라는 이름으로 실측한 메시지가 `warning FS3569: 멤버 또는 함수 'sumTo'에 'TailCallAttribute' 특성이 있지만 비상 재귀적인 방식으로 사용되고 있지 않습니다.` 다. 실측에서 확인한 제약이 세 가지 있다. 첫째, 이 검사는 프로젝트 빌드에서만 돌고 `dotnet fsi` 로 스크립트를 실행할 때는 경고가 나오지 않았다. 둘째, `--langversion:7.0` 으로 낮추면 특성은 그대로 붙지만 검사가 돌지 않는다. 셋째, 지역 `let rec` 에는 특성을 붙일 수 없어 오류 FS0010 이 난다. 그래서 안쪽 `loop` 를 검사받고 싶으면 그 함수를 모듈 수준으로 끌어올려야 한다.

## Expanding the Accumulator — 누적값을 튜플로 넓히기 (원서 pp.143-144)

- 누적값은 숫자 하나일 필요가 없다. 튜플이나 레코드로 넓히면 여러 값을 함께 나를 수 있다.
- 원서는 피보나치 수열로 이것을 보인다. 직전 두 항이 필요한 점화식이므로 누적값이 값 두 개가 되어야 한다.
- 여기서는 같은 점화식을 계단으로 바꿔 쓴다. 한 번에 1칸 또는 2칸을 오를 수 있을 때 `n` 칸을 오르는 경로의 수는 직전 두 칸의 경로 수를 더한 값이다.

```fsharp id=11-tailrec
// 소박한 버전: 재귀 호출이 두 개라 같은 값을 몇 번씩 다시 센다
// stepWaysNaive: steps: int -> int64
let rec stepWaysNaive steps =
    match steps with
    | 0 | 1 -> 1L
    | n -> stepWaysNaive (n - 1) + stepWaysNaive (n - 2)

printfn "5칸 = %d 가지" (stepWaysNaive 5)      // 5칸 = 8 가지
printfn "30칸 = %d 가지" (stepWaysNaive 30)    // 30칸 = 1346269 가지
```

이 구현의 문제는 스택보다 시간이다. `stepWaysNaive 28` 을 계산하려고 `stepWaysNaive 27` 과 `stepWaysNaive 26` 을 부르는데, 앞의 호출도 안에서 `stepWaysNaive 26` 을 다시 계산한다. 겹치는 계산이 지수로 불어난다. 이 저장소에서 40칸은 약 1.0초, 45칸은 약 8.5초가 걸렸다. 원서가 `fib 50L` 로 1분 가까이 걸린다고 적은 것과 같은 현상이다.

```fsharp id=11-tailrec
// 누적값을 튜플로 넓혀 직전 두 값을 함께 나른다
// stepWays: steps: int -> int64
let stepWays steps =
    let rec loop remaining (prev, curr) =
        match remaining with
        | 0 -> prev
        | 1 -> curr
        | n -> loop (n - 1) (curr, prev + curr)
    loop steps (1L, 1L)

printfn "5칸 = %d 가지" (stepWays 5)      // 5칸 = 8 가지
printfn "90칸 = %d 가지" (stepWays 90)    // 90칸 = 4660046610375530309 가지
```

누적값 `(prev, curr)` 는 매 단계에서 한 칸 앞으로 밀린다. `(curr, prev + curr)` 가 그 밀기다. 계산 횟수가 `steps` 에 비례하므로 90칸도 즉시 나온다. 다만 이제는 다른 한계에 부딪힌다. 91칸까지는 `int64` 에 담기지만 92칸은 넘쳐서 `-6246583658587674878` 이 나온다. F# 의 산술은 기본적으로 넘침을 검사하지 않으므로, 값이 커지는 계산에서는 `bigint` 로 올리거나 상한을 코드에서 막아야 한다. 넘침을 조용히 지나치지 않게 하는 길도 있다. `open Microsoft.FSharp.Core.Operators.Checked` 로 검사판 연산자를 켜면 `System.Int64.MaxValue + 1L` 이 `OverflowException` 을 던진다.

기저 경우가 `0` 과 `1` 두 개인 것도 짚어 둘 만하다. 점화식이 직전 두 항을 참조하면 기저 경우도 두 개가 필요하다. 소박한 버전에서 `| 0 | 1 -> 1L` 로 묶어 둔 것을 꼬리 재귀 버전에서는 `| 0 -> prev` 와 `| 1 -> curr` 로 갈랐다. 누적값의 어느 칸을 내놓아야 하는지가 다르기 때문이다.

## Using Recursion to Solve FizzBuzz — 규칙 목록을 누적하기 (원서 pp.144-145)

- 원서는 FizzBuzz 를 `(나누는 수, 붙일 말)` 목록으로 두고 그 목록을 재귀로 훑는다. 규칙을 데이터로 빼 뒀으므로 규칙을 더하는 일이 목록에 한 줄 더하는 일이 된다.
- 여기서는 같은 구조를 공연 부대 행사표로 바꿔 쓴다. 회차 번호가 주기의 배수가 되면 그 행사 이름을 이어 붙이고, 걸리는 주기가 하나도 없으면 회차 번호를 그대로 적는다.
- 누적값이 문자열이므로 초기값은 빈 문자열이다. 문자열 이어 붙이기의 항등원이 빈 문자열이기 때문이다.
- 이 절에서 리스트를 머리(head)와 꼬리(tail)로 분해한다. 리스트의 꼬리와 꼬리 재귀의 "꼬리"는 글자만 같고 다른 말이다. 앞은 머리를 뗀 나머지 리스트이고, 뒤는 함수 본문에서 재귀 호출이 놓인 자리를 가리킨다. 헷갈리지 않게 이 노트는 분해한 나머지를 `rest` 로 적는다.

```fsharp id=11-fold
// 이 단위가 보여주는 것: 규칙 목록을 누적값에 접어 넣는 꼬리 재귀
// 공연 부대 행사표 — 회차 번호가 주기의 배수가 되면 그 행사를 연다
let eventPlan = [ (4, "사인회"); (6, "포토타임") ]

// eventsAt: plan: (int * string) list -> showNo: int -> string
let eventsAt plan showNo =
    let rec loop remaining acc =
        match remaining with
        | [] -> if acc = "" then string showNo else acc
        | (cycle, title) :: rest ->
            let label = if showNo % cycle = 0 then title else ""
            loop rest (acc + label)
    loop plan ""

printfn "%s" ([ 1 .. 14 ] |> List.map (eventsAt eventPlan) |> String.concat " ")
// 1 2 3 사인회 5 포토타임 7 사인회 9 10 11 사인회포토타임 13 14
```

패턴 매칭의 두 갈래가 각각 이렇게 읽힌다. 규칙이 다 떨어졌으면 누적값을 내놓는데, 빈 문자열이면 걸린 규칙이 없다는 뜻이므로 회차 번호를 문자열로 바꿔 돌려준다. 규칙이 남아 있으면 그 규칙의 판정 결과를 누적값에 붙이고 나머지 규칙으로 재귀한다. 12회차에서 `사인회포토타임` 이 나온 것은 4와 6이 동시에 걸려 두 이름이 이어 붙은 결과다.

`List.map (eventsAt eventPlan)` 은 매개변수 두 개짜리 함수에 첫 인자만 넘긴 부분 적용(partial application)이다. 규칙 목록을 먼저 고정해 두면 `int -> string` 함수가 남고 그것을 `List.map` 에 그대로 얹을 수 있다.

규칙을 늘리는 데 함수를 고칠 일이 없다는 것이 이 설계의 이점이다.

```fsharp id=11-fold
// 규칙을 하나 더해도 eventsAt 은 그대로다
let widePlan = [ (4, "사인회"); (6, "포토타임"); (10, "앙코르") ]

printfn "%s" ([ 1 .. 20 ] |> List.map (eventsAt widePlan) |> String.concat " ")
// 1 2 3 사인회 5 포토타임 7 사인회 9 앙코르 11 사인회포토타임 13 14 15 사인회 17 포토타임 19 사인회앙코르
```

### `List.fold` 로 다시 쓰기 (원서 p.145)

원서는 같은 문제를 `List.fold` 로 다시 쓴다. 그럴 수 있는 이유가 분명하다. 위 `loop` 가 하는 일이 정확히 `fold` 의 정의다. 리스트를 앞에서 훑으며 상태를 갱신하고 마지막 상태를 돌려준다.

```fsharp id=11-fold
// 같은 일을 List.fold 로 — 재귀 문법이 사라진다
// eventsAtFold: plan: (int * string) list -> showNo: int -> string
let eventsAtFold plan showNo =
    plan
    |> List.fold (fun acc (cycle, title) -> if showNo % cycle = 0 then acc + title else acc) ""
    |> fun labels -> if labels = "" then string showNo else labels

printfn "%s" ([ 1 .. 14 ] |> List.map (eventsAtFold eventPlan) |> String.concat " ")
// 1 2 3 사인회 5 포토타임 7 사인회 9 10 11 사인회포토타임 13 14
```

5챕터에서 본 대로 `folder` 의 첫 매개변수가 누적값이고 둘째가 원소다. 여기서는 원소가 `(int * string)` 튜플이라 람다 매개변수 자리에서 `(cycle, title)` 로 바로 분해했다. 초기값 `""` 는 꼬리 재귀 버전에서 `loop plan ""` 로 넘겼던 그 값이다. 기저 경우에 있던 "빈 문자열이면 회차 번호" 판정은 `fold` 가 끝난 뒤 파이프 한 칸으로 옮겨 갔다. `fold` 는 리스트가 다 떨어졌을 때 무엇을 할지 스스로 알기 때문에 그 갈래를 적을 자리가 없다.

`reduce` 는 여기서 후보가 아니다. 누적값이 `string` 이고 원소가 `(int * string)` 이라 타입이 갈리는데, `reduce` 는 상태와 원소의 타입이 같아야 한다.

두 버전의 실측 시그니처는 완전히 같다.

```fsharp
// eventsAt     : plan: (int * string) list -> showNo: int -> string
// eventsAtFold : plan: (int * string) list -> showNo: int -> string
```

결과도 같다.

```fsharp id=11-fold
// 240회차까지 두 구현의 결과를 맞춰 본다
printfn "두 구현이 같은가 = %b"
    ([ 1 .. 240 ] |> List.forall (fun n -> eventsAt eventPlan n = eventsAtFold eventPlan n))
// 두 구현이 같은가 = true
```

원서는 여기서 한 걸음 더 나아가 초기값을 빈 문자열이 아니라 입력을 문자열로 바꾼 값으로 두고, 마지막 판정까지 `folder` 안으로 끌어들인 변형을 보인다. 파이프 한 칸이 줄지만 `folder` 가 "이미 뭔가 붙었는지"를 직접 따져야 해서 읽기가 무거워진다. 5챕터에서 `fold` 한 방에 몰아넣은 코드가 읽기 어려워졌던 것과 같은 저울질이다. 원서가 결과를 출력할 때 `List.map` 대신 `List.iter (eventsAtFold eventPlan >> printfn "%s")` 처럼 합성 연산자를 쓰는 것도 취향 차이이고 결과는 같다.

무엇을 쓸지는 취향 문제가 아니라 형태 문제다. 리스트를 앞에서 한 번 훑으며 상태를 갱신하는 것이 전부라면 `fold` 가 짧고, 재귀 문법을 읽는 부담이 없고, 꼬리 호출 여부를 걱정할 일도 없다(`List.fold` 자체가 반복문으로 구현돼 있다). 재귀를 직접 적어야 하는 자리는 훑는 대상이 리스트가 아닐 때, 갈래마다 다르게 재귀해야 할 때, 중간에 멈춰야 할 때다. 이 챕터 마지막 절의 트리가 그런 경우다.

## Quicksort using recursion — 퀵소트 (원서 pp.145-146)

- 퀵소트는 재귀의 교과서 예제다. 기준값 하나를 고르고 나머지를 그보다 작거나 같은 쪽과 큰 쪽으로 나눈 다음, 두 쪽을 각각 다시 정렬해 이어 붙인다.
- `List` 모듈에 필요한 조각이 이미 있다. `List.partition` 이 술어(`'a -> bool`) 하나로 리스트를 두 개로 갈라 튜플로 돌려준다.
- 기저 경우는 빈 리스트다. 나눌 것이 없으면 그대로 정렬된 상태다.
- 원서는 정수 리스트로 보여 준다. 여기서는 응답 시간 측정값을 정렬한다.

```fsharp id=11-quicksort
// 이 단위가 보여주는 것: List.partition 을 쓴 퀵소트
// quickSort: values: 'a list -> 'a list  (when 'a : comparison)
let rec quickSort values =
    match values with
    | [] -> []
    | pivot :: rest ->
        let atMost, above = rest |> List.partition (fun v -> v <= pivot)
        quickSort atMost @ [ pivot ] @ quickSort above

let latency = [ 41; 12; 41; 7; 130; 12; 3; 88; 55; 7 ]
printfn "정렬 = %A" (quickSort latency)
// 정렬 = [3; 7; 7; 12; 12; 41; 41; 55; 88; 130]
```

머리를 기준값으로 쓰고 나머지만 나눈다는 점이 중요하다. 기준값까지 나누는 쪽에 넣으면 리스트가 줄지 않아 재귀가 끝나지 않는다. 술어를 `<=` 로 둘지 `<` 로 둘지는 결과를 바꾸지 않는다. 기준값과 같은 값이 앞쪽 묶음에 들어가느냐 뒤쪽 묶음에 들어가느냐만 달라지고, 어느 쪽이든 원소는 두 묶음 중 정확히 한 곳에 들어가므로 개수와 정렬 결과가 같다.

`List.partition` 이 무엇을 돌려주는지 따로 보면 이렇다.

```fsharp id=11-quicksort
// List.partition : ('a -> bool) -> 'a list -> 'a list * 'a list
// 술어를 만족하는 것과 그렇지 않은 것을 순서를 지킨 채 튜플로 돌려준다
printfn "나누기 = %A" ([ 12; 41; 7; 130; 12; 3; 88; 55; 7 ] |> List.partition (fun v -> v <= 41))
// 나누기 = ([12; 41; 7; 12; 3; 7], [130; 88; 55])
```

`quickSort` 는 비교할 수 있는 아무 타입에나 붙는다. 비교 연산자 `<=` 만 썼으므로 자동 일반화가 `'a list -> 'a list` 에 `when 'a : comparison` 제약을 붙여 줬다.

```fsharp id=11-quicksort
printfn "문자열 = %A" (quickSort [ "라"; "가"; "다"; "나" ])
// 문자열 = ["가"; "나"; "다"; "라"]
printfn "List.sort 와 같은가 = %b" (quickSort latency = List.sort latency)
// List.sort 와 같은가 = true
```

원서는 여기서 멈추지만 두 가지는 덧붙여 둘 만하다. 첫째, 이 `quickSort` 는 꼬리 재귀가 아니다. 재귀 호출이 두 개이고 그 결과를 `@` 로 이어 붙이는 일이 남아 있으므로 프레임이 쌓인다. 재귀 깊이는 분할이 고르게 되면 원소 수의 로그 규모이므로 실무 크기에서는 문제가 되지 않는다. 둘째, 이미 정렬된 입력에서는 분할이 매번 한쪽으로 몰려 깊이가 원소 수만큼 깊어지고 비교 횟수가 제곱 규모로 커진다. 이 저장소에서 실측하면 무작위 순서 2만 개는 0.15초에 끝나지만 이미 정렬된 2만 개는 12.3초가 걸렸고, 정렬된 1만 개가 3.5초였으니 입력이 두 배 될 때 시간이 세 배 반으로 뛴 셈이다. 이때 걱정되는 것은 스택이지만 실제로 먼저 한계에 닿는 것은 시간이다. 정렬된 10만 개는 재귀 깊이 10만으로 6분 19초를 쓰고도 스택 오버플로 없이 끝났다. 깊이를 더 키우려면 매 단계가 남은 원소를 다 훑어야 하므로, 스택이 터지기 전에 실행 시간이 먼저 감당할 수 없게 커진다. 실제 코드에서 리스트를 정렬할 일이 있으면 `List.sort` 를 쓰면 된다. 퀵소트를 직접 적는 것은 재귀를 익히기 위한 연습이다.

## Recursion with Hierarchical Data — 계층 데이터 (원서 pp.146-150)

- 재귀가 대안 없이 필요한 자리가 계층 데이터다. 트리는 자기 자신을 품는 구조이므로 그것을 훑는 코드도 자기 자신을 부르는 모양이 된다.
- 원서는 재귀형 판별 유니온(discriminated union)으로 트리를 정의한다. 가지 케이스가 같은 타입의 자식을 품는 것이 요령이다.
- 원서는 이 절에서 지역 간 거리 CSV 를 읽어 출발지에서 도착지까지 가능한 경로를 모두 트리로 펼치고 그중 가장 짧은 것을 고른다. 이 노트는 같은 순서를 밟되 섬 사이 항로망으로 데이터를 갈아 끼웠다.
- 작업을 세 토막으로 나눈다. 데이터 적재, 가능한 경로 펼치기, 최단 경로 고르기다. 긴 문제를 작은 함수로 쪼개 하나씩 FSI 로 확인하며 나아가는 것이 원서가 이 절에서 보여 주는 작업 방식이다.

### 트리 정의와 순회 (원서 pp.146-147, 149)

트리를 가지와 말단 두 케이스로 정의하고, 그것을 훑는 함수 두 개를 만들어 본다.

```fsharp id=11-tree
// 이 단위가 보여주는 것: 재귀형 판별 유니온과 그것을 훑는 재귀 함수
// 가지는 값과 자식 목록을 품고, 말단은 값만 품는다
type Hierarchy<'T> =
    | Node of 'T * Hierarchy<'T> list
    | Tip of 'T

let zones =
    Node ("A동", [
        Node ("1층", [ Tip "냉장"; Tip "상온" ])
        Node ("2층", [ Tip "위험물" ])
    ])
```

`Node` 케이스가 `Hierarchy<'T> list` 를 품는 것이 재귀형 정의다. 원서는 자식을 `seq` 로 두는데, 여기서는 `list` 로 잡았다. 지연 평가가 필요 없고 `%A` 로 찍어 보기 편하기 때문이다. 원서처럼 자식을 `seq` 로 두면 훑는 만큼만 만들어지고, `list` 로 두면 트리 전체가 먼저 만들어진다. 마지막 절에서 말하는 완전 탐색의 한계가 `list` 판에서는 더 이르게 드러난다.

트리를 훑는 함수도 케이스마다 한 갈래씩 적으면 자연히 재귀가 된다. 말단이 기저 경우다.

```fsharp id=11-tree
// 말단 값만 모아 평평한 리스트로 만든다
// tips: tree: Hierarchy<'a> -> 'a list
let rec tips tree =
    match tree with
    | Tip x -> [ x ]
    | Node (_, children) -> children |> List.collect tips

// 가장 깊은 갈래의 깊이
// depth: tree: Hierarchy<'a> -> int
let rec depth tree =
    match tree with
    | Tip _ -> 1
    | Node (_, children) -> 1 + (children |> List.map depth |> List.max)

printfn "말단 = %A" (tips zones)     // 말단 = ["냉장"; "상온"; "위험물"]
printfn "깊이 = %d" (depth zones)    // 깊이 = 3
```

`List.collect` 가 자식마다 나온 리스트를 하나로 이어 붙인다. 자식을 재귀로 처리하고 그 결과를 합치는 이 모양이 트리 순회의 기본형이다. `depth` 는 합치는 방법만 다르다. 자식들의 결과에서 최댓값을 골라 `1` 을 더한다. 둘 다 꼬리 재귀가 아니고 그렇게 만들기도 쉽지 않지만, 재귀 깊이가 트리 깊이를 넘지 않으므로 실무 크기의 트리에서는 문제가 되지 않는다. 한 가지 단서가 있다. 자식이 없는 `Node` 를 만들면 `List.max` 가 예외를 던진다. 이 노트의 트리는 그런 값을 만들지 않는다는 전제가 깔려 있다.

### 데이터 적재 (원서 pp.147-148)

원서는 CSV 파일을 읽어 `Map<string, Connection list>` 로 만든다. 왜 리스트가 아니라 `Map` 인지가 이 절의 요점이다. `Map` 은 키-값 쌍을 담는 불변 정렬 컬렉션이고, 이 데이터에 던질 질문이 "이 지점에서 갈 수 있는 곳은?" 이므로 키로 바로 찾는 쪽이 맞는 모양이다.

```fsharp id=11-tree
// 항로 한 구간
type Leg = { From: string; To: string; Km: int }

// 원서는 이 데이터를 resources/data.csv 에서 읽는다. 파일 읽기는 6챕터의 주제이므로
// 여기서는 같은 내용을 문자열 리터럴로 둔다
let legCsv = """출항,입항,km
소금항,노을항,62
소금항,물마루항,145
소금항,등대항,260
노을항,물마루항,71
노을항,바람골항,96
물마루항,바람골항,40
물마루항,등대항,120
바람골항,등대항,55
바람골항,자갈항,88
등대항,자갈항,30"""
```

한 줄이 한 구간이고 왕복 거리는 같다고 본다. 그래서 파싱할 때 한 줄에서 구간 두 개를 만든다.

```fsharp id=11-tree
// buildLegMap: csv: string -> Map<string,Leg list>
let buildLegMap (csv: string) =
    csv.Split('\n')
    |> Array.toList
    |> List.skip 1
    |> List.collect (fun row ->
        match row.Trim().Split(',') with
        | [| from; dest; km |] ->
            [ { From = from; To = dest; Km = int km }
              { From = dest; To = from; Km = int km } ]
        | _ -> failwithf "행 형식이 잘못됐다: %s" row)
    |> List.groupBy (fun leg -> leg.From)
    |> Map.ofList

let legMap = buildLegMap legCsv

printfn "항구 수 = %d" (legMap |> Map.count)   // 항구 수 = 6
printfn "노을항에서 = %A" (legMap["노을항"] |> List.map (fun leg -> leg.To, leg.Km))
// 노을항에서 = [("소금항", 62); ("물마루항", 71); ("바람골항", 96)]
```

헤더 줄을 `List.skip 1` 로 버리고, 각 줄을 배열 패턴 `[| from; dest; km |]` 로 받는다. 칸 수가 셋이 아니면 `failwithf` 로 던진다. 3챕터에서 본 대로 예외는 정말로 복구할 수 없는 경우에 쓰는 것이고, 이 자리에서는 데이터 파일이 깨졌다는 뜻이므로 계속 진행할 이유가 없다. 마지막의 `List.groupBy` 로 출항지별로 묶고 `Map.ofList` 로 `Map` 을 만든다. `List.groupBy` 가 `(키, 값 목록)` 튜플 리스트를 돌려주므로 `Map.ofList` 에 그대로 들어간다.

`legMap["노을항"]` 은 대괄호 인덱서 문법이다. F# 6 부터 쓸 수 있고, `--langversion:5.0` 으로 낮추면 오류 FS3217 이 나면서 인덱서를 쓰려던 것인지 되묻는다. 이 문법은 값이 없으면 예외를 던지므로 키가 확실할 때만 쓴다.

### 가능한 경로 펼치기 (원서 pp.148-150)

- 경로를 만들려면 지금 어디에 있고, 어디를 거쳐 왔고, 몇 km 를 왔는지를 함께 들고 다녀야 한다. 원서는 이것을 `Waypoint` 레코드로 잡는다. 사실 이 레코드가 이 절의 누적값이다.
- 거쳐 온 항구 목록이 있으면 되돌아가지 않을 수 있다. 이 조건이 재귀를 끝내는 장치 구실도 한다. 항구는 유한하므로 갈 곳이 언젠가 떨어진다.
- 트리로 만드는 이유는 갈림길이 여러 개이기 때문이다. 한 지점에서 갈 수 있는 곳이 셋이면 자식이 셋인 가지가 된다.

```fsharp id=11-tree
// 항해 중 한 시점 — 이 레코드 전체가 누적값 구실을 한다
type Voyage = { Port: string; Wake: string list; TotalKm: int }

// 아직 들르지 않은 다음 항구들
// nextHops: legs: Leg list -> current: Voyage -> Voyage list
let nextHops legs current =
    legs
    |> List.filter (fun leg -> current.Wake |> List.contains leg.To |> not)
    |> List.map (fun leg ->
        { Port = leg.To
          Wake = leg.From :: current.Wake
          TotalKm = leg.Km + current.TotalKm })
```

`Wake` 는 지나온 자취다. 지금 있는 항구는 아직 여기 들어 있지 않고, 다음 항구로 넘어갈 때 `leg.From :: current.Wake` 로 앞에 붙는다. 그래서 `Wake` 는 뒤집힌 순서로 쌓인다. `List.filter` 가 자취에 이미 있는 항구를 걸러 내므로 같은 항구를 두 번 들르는 경로는 만들어지지 않는다.

`nextHops legs current` 의 인자 순서는 원서 `getUnvisited connections current` 를 그대로 따른 것이다. 그래서 파이프에 바로 얹히지 않아 `|> fun legs -> nextHops legs current` 한 칸이 필요한데, 원서와 대조하며 읽는 편의를 택해 순서를 바꾸지 않았다.

원서 p.148 의 `getUnvisited` 주석은 첫 인자를 `Connection list` 로, p.151 완성 코드의 주석은 `Map<string, Connection list>` 로 적어 서로 다르다. 실제 인자는 `Map` 에서 꺼낸 리스트이므로 p.148 쪽이 맞다.

```fsharp id=11-tree
// 출발지에서 도착지까지 가능한 경로를 전부 트리로 펼친다
// expandRoutes: start: string -> finish: string -> legMap: Map<string,Leg list> -> Hierarchy<Voyage>
let expandRoutes start finish (legMap: Map<string, Leg list>) =
    let rec grow current =
        let hops =
            legMap
            |> Map.tryFind current.Port
            |> Option.defaultValue []
            |> fun legs -> nextHops legs current
        if current.Port = finish || List.isEmpty hops then Tip current
        else Node (current, hops |> List.map grow)
    grow { Port = start; Wake = []; TotalKm = 0 }
```

가지를 더 뻗지 않는 경우가 두 가지다. 도착지에 닿은 경우와 갈 수 있는 곳이 남지 않은 경우다. 둘 다 `Tip` 이 되고 그 차이는 나중에 도착지인지 확인해서 가린다. `grow` 의 초기 인자가 이 재귀의 시작 누적값이다. 앞 절들의 `loop n 1L` 과 같은 자리다.

`Map.tryFind` 를 쓴 것은 의도적이다. 원서는 `routeMap[current.Location]` 으로 바로 읽는데, `Map.find` 와 인덱서는 부분 함수(partial function)다. 가능한 입력 전부에서 값을 돌려주지 못하고 없는 키에는 예외를 던진다. 이름이 비슷한 부분 적용과는 관계가 없다. 여기서는 왕복 구간을 다 만들었으므로 모든 항구에 항로가 하나 이상 있어서 실제로 실패할 일은 없지만, 데이터가 한쪽 방향만 담고 있을 때 예외 대신 빈 목록으로 흘러가는 편이 다루기 쉽다. `Option.defaultValue []` 가 그 처리다.

트리를 펼쳤으니 말단만 모아 보면 후보 경로가 나온다. 이때 도착지에 닿지 못한 막다른 경로를 걸러야 한다.

```fsharp id=11-tree
// candidates: start: string -> finish: string -> legMap: Map<string,Leg list> -> Voyage list
let candidates start finish legMap =
    expandRoutes start finish legMap
    |> tips
    |> List.filter (fun voyage -> voyage.Port = finish)

let routeTree = expandRoutes "소금항" "자갈항" legMap

printfn "말단 전체 = %d" (routeTree |> tips |> List.length)              // 말단 전체 = 23
printfn "완주 경로 = %d" (candidates "소금항" "자갈항" legMap |> List.length)   // 완주 경로 = 17
printfn "트리 깊이 = %d" (depth routeTree)                                // 트리 깊이 = 6
```

말단이 23개인데 도착지에 닿은 것은 17개다. 나머지 6개는 되돌아갈 수 없어 막힌 자리다. 앞 절에서 만들어 둔 `tips` 와 `depth` 를 그대로 쓴 것을 눈여겨볼 만하다. `Hierarchy<'T>` 를 제네릭으로 잡아 뒀으므로 창고 구역 트리에 쓴 함수가 항로 트리에도 그대로 붙는다.

### 최단 경로 고르기 (원서 p.150)

후보가 다 모였으니 남은 일은 거리로 하나를 고르는 것이다.

```fsharp id=11-tree
// shortest: start: string -> finish: string -> legMap: Map<string,Leg list> -> string list * int
let shortest start finish legMap =
    candidates start finish legMap
    |> List.minBy (fun voyage -> voyage.TotalKm)
    |> fun voyage -> (voyage.Port :: voyage.Wake |> List.rev), voyage.TotalKm

printfn "%A" (shortest "소금항" "자갈항" legMap)
// (["소금항"; "노을항"; "바람골항"; "등대항"; "자갈항"], 243)
```

거리를 이미 `TotalKm` 에 누적해 뒀으므로 고르는 일은 `List.minBy` 한 번이다. 경로를 사람이 읽을 형태로 되돌리려면 지금 항구를 자취 앞에 붙이고 `List.rev` 로 뒤집는다. 자취를 `::` 로 쌓았기 때문에 뒤집는 단계가 필요한 것이고, 이것은 리스트 앞에 붙이는 연산만 빠른 F# 리스트에서 흔히 쓰는 방식이다.

`List.minBy` 도 부분 함수다. 후보가 하나도 없으면 예외를 던진다. 도착지가 항로망에 없는 이름이면 그 일이 실제로 벌어지므로, 진짜 코드로 만들 것이라면 `List.isEmpty` 로 먼저 걸러 `Option` 이나 `Result` 를 돌려주는 것이 맞다.

거리 순으로 몇 개를 늘어놓아 보면 이 문제가 왜 최단 경로 문제인지 보인다.

```fsharp id=11-tree
candidates "소금항" "자갈항" legMap
|> List.sortBy (fun voyage -> voyage.TotalKm)
|> List.truncate 4
|> List.iter (fun voyage ->
    printfn "%5d km  %s" voyage.TotalKm (voyage.Port :: voyage.Wake |> List.rev |> String.concat " > "))
//   243 km  소금항 > 노을항 > 바람골항 > 등대항 > 자갈항
//   246 km  소금항 > 노을항 > 바람골항 > 자갈항
//   258 km  소금항 > 노을항 > 물마루항 > 바람골항 > 등대항 > 자갈항
//   261 km  소금항 > 노을항 > 물마루항 > 바람골항 > 자갈항
```

기항지를 하나 더 거치는 4구간 경로가 3구간 경로보다 짧다. 구간 수와 거리가 따로 움직이므로 눈으로 고를 수 없고 전부 계산해 봐야 한다는 점이 이 예제의 재미다.

한 가지 한계는 분명히 해 둘 만하다. 이 방식은 가능한 단순 경로를 모두 펼치는 완전 탐색이다. 항구 6개에 후보 17개였지만 항구가 늘면 후보 수가 지수로 불어난다. 최단 경로만 필요하다면 다익스트라 같은 알고리즘이 맞다. 원서가 이 예제로 보이려는 것은 최단 경로 알고리즘이 아니라 계층 구조를 재귀로 만들고 재귀로 허무는 방법이다.

### Finished Code — 완성된 코드 (원서 pp.151-152)

원서는 여기까지 만든 함수를 한 파일로 모아 다시 싣는다. 이 노트에서는 `11-tree` 실행 단위의 블록들이 문서 순서대로 이어 붙어 그 한 파일이 된다. 순서를 확인해 두면 이렇다. 트리 타입과 순회 함수(`tips`, `depth`) → 구간 타입과 CSV → `buildLegMap` → `Voyage` 와 `nextHops` → `expandRoutes` → `candidates` → `shortest` 다. 각 함수가 앞 함수의 결과 타입을 받는 모양이므로, 원서가 권하는 대로 한 토막씩 FSI 에 올려 결과를 눈으로 보며 쌓아 갈 수 있다.

## Other Uses Of Recursion — 그 밖의 쓸모 (원서 p.152)

- 원서가 꼽는 자리는 파일 시스템이나 XML 같은 계층 데이터 처리, 평평한 데이터와 계층 사이의 변환, 그리고 끝이 정해지지 않은 이벤트 반복이다. 어느 쪽이든 반복 횟수를 미리 알 수 없다는 공통점이 있다.
- 위 `tips` 와 `depth` 처럼 트리를 값 하나로 줄이는 함수는 리스트의 `fold` 와 같은 자리에 있다. 트리용 `fold` 를 한 번 만들어 두고 그것으로 순회 함수들을 적는 방식도 있는데, 원서는 스콧 블라신(Scott Wlaschin)의 글로 넘긴다.
- 반대 방향도 있다. 평평한 목록을 부모 키로 묶어 트리로 세우는 일도 재귀다. 앞의 계층 데이터 절에서 만든 `expandRoutes` 가 바로 그 방향이었다.

## Summary — 원서의 챕터 요약 (원서 p.152)

- 원서는 재귀의 기본, 누적값과 꼬리 호출 최적화, 그리고 계층 데이터 문제 하나를 이 챕터에서 다뤘다고 정리한다.
- 다음 챕터에서는 8챕터의 함수형 검증에서 잠깐 마주쳤던 계산 식(computation expression)을 정면으로 다룬다.

## 정리 — 이 노트의 요약

- 재귀 함수는 `let rec` 로 선언한다. `rec` 이 없으면 오류 FS0039 로 이름을 모른다는 말이 나온다. 상호 재귀는 `let rec` 뒤에 `and` 로 잇고, `rec` 없이 `and` 만 쓰면 오류 FS0576 이다.
- 재귀는 기저 경우와 재귀 경우로 갈린다. 기저 경우를 적는 것만으로는 부족하고 입력이 그 지점에 실제로 닿아야 한다. 닿지 못하면 `StackOverflowException` 이 나는데 이것은 `try ... with` 로 잡히지 않고 프로세스를 끝낸다.
- 함수가 마지막으로 하는 일이 어떤 호출이고 그 결과가 곧 반환값이면 그 호출이 꼬리 호출이다. 재귀 호출이 꼬리 호출이면 스택 프레임이 재사용되어 반복문과 같은 메모리로 돈다. 소박한 재귀를 꼬리 재귀로 바꾸는 표준 수법이 누적값을 매개변수로 나르는 것이다. 자기 자신을 직접 부르는 꼬리 호출은 언제나 최적화되지만, 상호 재귀처럼 다른 함수로 넘어가는 꼬리 호출은 `--tailcalls+` 가 켜져 있어야 한다.
- 누적값을 한 연산으로 이어 붙여 나갈 때 초기값은 그 연산의 항등원이다. 곱셈은 `1`, 덧셈은 `0`, 문자열 이어 붙이기는 `""` 다. `List.fold` 의 초기값을 정하는 기준과 같다. 점화식의 시작 값을 담는 누적값은 이 기준에서 벗어나고, `stepWays` 의 `(1L, 1L)` 이 그런 경우다.
- 누적값을 공개 시그니처에 드러내지 않으려면 안쪽에 지역 `loop` 를 두고 바깥 함수가 초기값을 넣어 첫 호출을 한다. 실측하면 소박한 버전과 꼬리 재귀 버전의 시그니처가 `n: int -> int64` 로 똑같다.
- 누적값은 튜플이나 레코드로 넓힐 수 있다. 직전 두 항이 필요한 점화식은 `(prev, curr)` 를 나르고 매 단계에서 `(curr, prev + curr)` 로 한 칸 민다. 계층 데이터 절의 `Voyage` 레코드도 같은 역할이다.
- 리스트를 앞에서 한 번 훑으며 상태를 갱신하는 재귀는 `List.fold` 로 그대로 옮겨진다. 실측하면 두 구현의 시그니처가 `plan: (int * string) list -> showNo: int -> string` 로 같고 결과도 같다. 리스트 하나를 훑는 일이라면 직접 재귀보다 `fold` 가 먼저다. 전용 집계 함수가 있으면 그쪽이 먼저라는 5챕터의 순서는 그대로다.
- `[<TailCall>]` 특성은 F# 8 부터 꼬리 호출 여부를 컴파일러에게 확인받는 수단이다. 검사는 프로젝트 빌드에서만 돌고 FSI 스크립트에서는 돌지 않으며, 지역 `let rec` 에는 붙일 수 없어 오류 FS0010 이 난다.
- 퀵소트는 `List.partition` 과 `@` 로 여섯 줄에 적힌다. 꼬리 재귀는 아니고 이미 정렬된 입력에서 시간이 제곱으로 늘어난다. 실측하면 무작위 2만 개 0.15초, 정렬된 2만 개 12.3초다. 실무에서는 `List.sort` 를 쓴다.
- 계층 데이터는 재귀형 판별 유니온으로 정의하고 케이스마다 한 갈래씩 적으면 순회 함수가 자연히 재귀가 된다. 자식 결과를 `List.collect` 로 합치는 형태가 기본형이다.
- `Map.find` 와 대괄호 인덱서, `List.minBy` 는 부분 함수다. 실패를 값으로 다루려면 `Map.tryFind` 와 `List.isEmpty` 검사를 앞에 둔다. 대괄호 인덱서 문법은 F# 6 부터이고 F# 5 에서는 오류 FS3217 이다.
- 긴 문제는 데이터 적재, 구조 만들기, 결과 고르기처럼 토막으로 쪼개고 토막마다 FSI 로 확인하며 나아간다. 원서가 이 챕터에서 보여 주는 작업 방식 자체가 배울 거리다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Setting Up — 준비 | p.141 | — |
| Solving The Problem — 재귀 함수의 두 갈래 | pp.141-142 | `11-basics` |
| 상호 재귀 — `and` 로 잇는다 (노트 보충) | — | `11-basics` |
| Tail Call Optimisation — 꼬리 호출과 누적값 | pp.142-143 | `11-tailrec` |
| `[<TailCall>]` 로 컴파일러에게 확인받기 (노트 보충) | — | `11-tailrec` |
| Expanding the Accumulator — 누적값을 튜플로 넓히기 | pp.143-144 | `11-tailrec` |
| Using Recursion to Solve FizzBuzz — 규칙 목록을 누적하기 | pp.144-145 | `11-fold` |
| `List.fold` 로 다시 쓰기 | p.145 | `11-fold` |
| Quicksort using recursion — 퀵소트 | pp.145-146 | `11-quicksort` |
| Recursion with Hierarchical Data / 트리 정의와 순회 | pp.146-147, 149 | `11-tree` |
| Recursion with Hierarchical Data / 데이터 적재 | pp.147-148 | `11-tree` |
| Recursion with Hierarchical Data / 가능한 경로 펼치기 | pp.148-150 | `11-tree` |
| Recursion with Hierarchical Data / 최단 경로 고르기 | p.150 | `11-tree` |
| Finished Code — 완성된 코드 | pp.151-152 | `11-tree` |
| Other Uses Of Recursion — 그 밖의 쓸모 | p.152 | — |
| Summary — 원서의 챕터 요약 | p.152 | — |
