# 01 - 도메인 모델링 입문 연습 (원서 pp.8-25)

> 이 챕터는 이론이나 정의로 시작하지 않는다. 흔한 업무 요구사항 하나를 놓고, 그것을 F# 코드로 옮기는 과정을 처음부터 끝까지 보여 준다. 처음 버전은 순진하다. 참/거짓 플래그 몇 개로 도메인 개념을 표현하고, 그래서 명세상 있을 수 없는 상태까지 코드에서는 만들어진다. 그다음부터가 이 챕터의 본론이다. 레코드(record), 판별 유니온(discriminated union), 패턴 매칭(pattern matching)을 써서 같은 문제를 여러 번 다시 푼다. 그때마다 도메인의 단어가 타입 이름으로 올라오고, 잘못된 상태는 아예 표현할 수 없게 된다. 예제는 F# Interactive(FSI)로 돌려 가며 확인한다.

원서는 고객 등급별 할인 계산을 예제로 쓴다. 이 노트는 같은 구조를 전기차 충전 요금 도메인으로 바꿔 새로 짰다. 코드는 다르지만 각 절이 보여 주는 개념과 개선의 순서는 원서와 같게 맞췄다.

## The Problem — 명세 안에 이미 도메인이 있다 (원서 pp.8-9)

- 원서는 행위 주도 개발(BDD) 스타일로 쓰인 명세 하나를 출발점으로 삼는다. 명세에는 검증용 예시 표가 붙어 있고, 그 안에 도메인 고유의 단어와 개념이 이미 들어 있다.
- 이 노트가 쓸 명세는 전기차 충전소 요금 정산이다.
  - 충전 단가는 1 kWh 당 300원이다.
  - 요금제에 가입한 운전자 중 요금제가 유효한 사람만 감면 대상이다.
  - 감면 대상이 25 kWh 이상 충전하면 요금의 12퍼센트를 감면한다.
  - 비회원은 요금제 자체가 없으므로 감면 대상이 될 수 없다.
- 검증용 예시는 이렇다.

| 운전자 | 상태 | 충전량 | 청구액 |
|---|---|---|---|
| yujin | 요금제 유효 | 30 kWh | 7920원 |
| minho | 요금제 유효 | 20 kWh | 6000원 |
| soyeon | 요금제 만료 | 30 kWh | 9000원 |
| taeho | 비회원 | 30 kWh | 9000원 |

- 명세를 읽으면 "요금제 가입 / 미가입", "유효 / 만료" 같은 갈림이 보인다. 이 챕터가 계속 묻는 질문은 하나다. 그 갈림을 코드에서 어떻게 드러낼 것인가.
- 먼저 순진한 해법을 만들고, F# 의 타입 시스템으로 그것을 점점 도메인 중심으로 바꿔 간다. 그 과정에서 버그가 끼어들 자리도 함께 줄어든다.

## Getting Started — 튜플과 레코드로 데이터 모양 잡기 (원서 pp.9-11)

- F# 에는 `string`, `decimal`, `bool` 같은 원시 타입 말고도 대수적 타입 시스템(Algebraic Type System, ATS)이 있다. 작은 데이터 구조를 조립해 큰 구조를 만드는 재료로 보면 된다.
- 재료는 크게 두 종류다. 하나는 여러 값을 동시에 담는 AND 타입이고 튜플(tuple)과 레코드가 여기에 든다. 다른 하나는 여러 경우 중 하나만 담는 OR 타입이고 판별 유니온이 여기에 든다.
- 타입은 `type` 키워드로 정의한다. 타입 이름에는 첫 글자를 대문자로 쓰는 파스칼 표기(Pascal case)를, 그 밖의 대부분에는 첫 글자를 소문자로 쓰는 카멜 표기(camel case)를 쓴다.

```fsharp id=01-record-fee
// 이 단위가 보여주는 것: 튜플과 레코드, 첫 계산 함수, 커링된 매개변수와 튜플 매개변수, FSI 검증

// 타입 약어: string 하나와 bool 두 개를 묶은 AND 타입에 RawDriver 라는 별명을 붙인다
type RawDriver = string * bool * bool

// 타입 표기는 * 로 잇고, 값 표기는 , 로 잇는다. 값 쪽 괄호는 생략해도 된다
let rawYujin = ("yujin", true, true)

// 값 바인딩에 타입 주석을 붙일 수도 있다: RawDriver
let rawTaeho: RawDriver = ("taeho", false, false)
```

`type RawDriver = ...` 는 새 타입을 만드는 것이 아니라 타입 약어(type abbreviation)다. 기존 타입에 별명을 붙이는 것일 뿐이다. `RawDriver` 를 요구하는 자리에 `string * bool * bool` 을 그대로 넣을 수 있고 그 반대도 된다. 별명이 아니라 진짜 다른 타입을 만드는 방법은 9챕터에서 다룬다.

`let` 은 오른쪽 값을 왼쪽 이름에 묶는다. F# 의 데이터에는 기본적으로 불변성(immutability)이 적용되므로 `rawYujin` 을 변수로 생각하지 않는 편이 낫다. 값이 이름에 붙었을 뿐이고 그 값은 바뀌지 않는다.

`let` 은 튜플을 분해하는 데도 쓴다.

```fsharp id=01-record-fee
// 튜플을 세 이름으로 분해한다
let rawSoyeon = ("soyeon", true, false)
let (rawId, rawSubscribed, rawPlanActive) = rawSoyeon
printfn "%s / 가입=%b / 유효=%b" rawId rawSubscribed rawPlanActive   // 기대: soyeon / 가입=true / 유효=false

printfn "%A" rawTaeho   // 기대: ("taeho", false, false)
```

- 튜플의 문제는 부분에 이름이 없다는 점이다. 두 번째와 세 번째 이름을 뒤집어 `let (rawId, rawPlanActive, rawSubscribed) = rawSoyeon` 으로 묶어도 컴파일은 그대로 된다. `string * bool * bool` 어디에도 어느 쪽이 가입 여부인지 적혀 있지 않으니 컴파일러가 막아 줄 근거가 없다. 결국 뜻이 뒤집힌 값을 그대로 쓰게 되고, 쓰는 사람이 순서를 짐작해야 한다.
- 그래서 실제 모델에는 레코드를 쓴다. 레코드도 AND 타입이지만 각 부분에 이름이 붙는다.

```fsharp id=01-record-fee
// 레코드: 부분마다 이름이 붙은 AND 타입
type Driver = {
    DriverId: string
    IsSubscribed: bool
    IsPlanActive: bool
}
```

한 줄로 적을 수도 있다. 이때는 필드 사이에 세미콜론이 필요하다.

```fsharp
type Driver = { DriverId: string; IsSubscribed: bool; IsPlanActive: bool }
```

- 줄을 나눠 쓰면 세미콜론이 필요 없다. 대신 들여쓰기가 맞아야 한다. F# 은 유의미한 공백(significant whitespace)으로 스코프(scope)를 판단하므로 정렬이 문법의 일부다. 컴파일 오류가 났을 때 가장 먼저 볼 곳도 정렬이다.
- 탭 문자는 아예 지원하지 않는다. 탭을 넣으면 경고가 아니라 오류 FS1161 이 나고, 문구는 `#indent "off" 옵션을 사용하지 않는 한 TAB은 F# 코드에서 허용되지 않습니다.` 다. 편집기가 탭을 공백으로 바꾸도록 설정해 두는 것이 좋다.
- 레코드 식은 필드를 하나도 빠뜨릴 수 없어서, 인스턴스를 만들 때 모든 필드를 채워야 한다. 그리고 레코드 필드는 기본이 불변이라 만든 뒤에는 값을 바꿀 수 없다. 필드에 `mutable` 을 붙이면 이 규칙에서 벗어날 수 있지만 이 노트에서는 쓰지 않는다.

```fsharp id=01-record-fee
// 필드를 줄마다 나눠 쓰는 방식. 필드가 많을 때 읽기 좋다
let yujin = {
    DriverId = "yujin"
    IsSubscribed = true
    IsPlanActive = true
}

// 세미콜론으로 한 줄에 쓰는 방식. 타입 주석은 붙여도 되고 생략해도 된다
let minho: Driver = { DriverId = "minho"; IsSubscribed = true; IsPlanActive = true }
let soyeon = { DriverId = "soyeon"; IsSubscribed = true; IsPlanActive = false }
let taeho = { DriverId = "taeho"; IsSubscribed = false; IsPlanActive = false }
```

- 타입 주석을 생략해도 컴파일러가 필드 이름을 보고 `Driver` 로 추론한다. 단, 구조가 똑같은 레코드 타입이 여럿 정의돼 있으면 컴파일러는 가장 나중에 선언된 타입을 고른다. 다른 쪽을 원한다면 타입 주석을 붙여야 한다.
- F# 컴파일러는 파일 위에서 아래로 읽는다. 그래서 어떤 이름을 쓰려면 그 이름이 쓰는 자리보다 위에 정의돼 있어야 한다. 프로젝트 단위에서도 같은 규칙이 적용되므로 `.fs` 파일도 알파벳 순이 아니라 의존 순서대로 배열한다. C# 이나 Java 를 쓰던 사람에게는 처음에 낯설지만, 이 제약 덕분에 코드를 읽는 순서와 검증하는 순서가 일치한다.

## Getting Started — 계산 함수와 함수 시그니처 (원서 pp.11-13)

- 이제 `Driver` 와 충전량을 받아 청구액을 내는 함수를 만든다. 타입 정의 아래에 놓아야 한다.

```fsharp id=01-record-fee
// Driver -> decimal -> decimal
let chargeFeeAnnotated (driver: Driver) (kwh: decimal) : decimal =
    let gross = kwh * 300.0M
    let waiver =
        if driver.IsPlanActive && kwh >= 25.0M
        then gross * 0.12M else 0.0M
    let net = gross - waiver
    net
```

숫자 뒤의 `M` 접미사는 그 숫자가 `decimal` 이라는 표시다. 금액 계산에는 부동소수점보다 `decimal` 이 맞다.

이 함수에서 짚을 것들.

- 함수 정의도 `let` 이고, 함수 안에서 `gross`, `waiver`, `net` 을 묶은 것도 `let` 이다. 같은 키워드다.
- `gross`, `waiver`, `net` 은 함수 스코프 안에만 있다. 밖에서는 보이지 않는다.
- 함수를 담을 클래스 같은 껍데기를 적지 않는다. 모듈이나 스크립트 최상위에 `let` 을 그대로 놓을 수 있다.
- F# 에서 함수는 일급 함수(first-class function)다. 값과 똑같이 다룰 수 있어서 다른 함수에 넘기거나 함수에서 반환받을 수도 있다.
- 반환 타입 주석은 매개변수 오른쪽에 붙는다.
- `return` 키워드가 없다. 마지막 줄의 값이 그대로 반환된다.
- 들여쓰기가 스코프를 만든다. 탭은 쓸 수 없다.
- `if` 는 식(expression)이므로 참 쪽과 거짓 쪽이 같은 타입을 내야 한다. 값을 내지 않는 문(statement)과 달리 식은 항상 출력이 있어서 다른 식과 조합하기 쉽고 테스트하기도 쉽다. F# 코드가 식으로 가득한 이유가 이것이다.

- 주석에 적은 `Driver -> decimal -> decimal` 이 이 함수의 시그니처(signature)다. 마지막 화살표 뒤가 반환 타입이다. 편집기에서 함수 이름에 마우스를 올리면 볼 수 있다. 시그니처를 읽는 습관은 F# 을 읽는 데 결정적이다.
- 매개변수를 `(driver: Driver) (kwh: decimal)` 처럼 나란히 적은 형태를 커링된 매개변수(curried parameters)라 하고, 튜플 하나로 묶어 받는 형태를 튜플 매개변수(tupled parameter)라 한다. 커링된 매개변수로 정의하면 시그니처에 매개변수 개수만큼 화살표가 생긴다. 다만 화살표 개수만 보고 거꾸로 판정할 수는 없다. 튜플 매개변수 하나를 받고 함수를 반환하는 함수도 화살표가 둘이다. 어느 쪽인지는 정의를 봐야 구분된다.

```fsharp id=01-record-fee
// Driver * decimal -> decimal — 본문은 그대로고 매개변수만 튜플 하나로 바뀌었다
let chargeFeeTupled (driver: Driver, kwh: decimal) : decimal =
    let gross = kwh * 300.0M
    let waiver =
        if driver.IsPlanActive && kwh >= 25.0M
        then gross * 0.12M else 0.0M
    gross - waiver
```

시그니처가 `Driver -> decimal -> decimal` 에서 `Driver * decimal -> decimal` 로 바뀐 것을 보면 된다. `*` 가 `->` 보다 강하게 묶이므로 튜플 매개변수는 하나다. 원서는 함수 대부분을 커링된 매개변수 형태로 쓰라고 권한다. 그 이유는 다음 챕터에서 다룬다.

- 타입 추론(type inference) 덕분에 위의 주석은 대부분 지울 수 있다. 컴파일러가 쓰임새를 보고 타입을 알아낸다.

```fsharp id=01-record-fee
// Driver -> decimal -> decimal — 타입 주석을 모두 지웠는데도 시그니처는 같다
let chargeFee driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        if driver.IsPlanActive && kwh >= 25.0M then gross * 0.12M
        else 0.0M
    gross - waiver

printfn "yujin  30kWh -> %.0f원" (float (chargeFee yujin 30.0M))    // 기대: 7920원
printfn "minho  20kWh -> %.0f원" (float (chargeFee minho 20.0M))    // 기대: 6000원
printfn "soyeon 30kWh -> %.0f원" (float (chargeFee soyeon 30.0M))   // 기대: 9000원
printfn "taeho  30kWh -> %.0f원" (float (chargeFee taeho 30.0M))    // 기대: 9000원
```

- `net` 바인딩은 읽기에 도움이 되지 않아 없앴다. `kwh` 가 `decimal` 로 정해지는 근거는 `kwh * 300.0M` 과 `kwh >= 25.0M` 처럼 `decimal` 리터럴과 나란히 쓰인 자리다.
- 타입 추론이 안 되는 자리도 있다. `DateTime.TryParse` 처럼 오버로드가 여럿인 .NET 함수를 쓰면 컴파일러가 어느 것인지 고를 수 없어 매개변수에 타입 주석을 달아 줘야 한다.

## Getting Started — FSI 로 검증하고, `=` 의 세 가지 얼굴 (원서 pp.13-15)

- 정식 단위 테스트는 4챕터에서 다룬다. 그전까지는 FSI 에서 `bool` 바인딩으로 간단히 확인하면 된다. 명세의 예시 표를 그대로 옮기는 것으로 충분하다.

```fsharp id=01-record-fee
// 명세의 예시를 그대로 검증한다. 괄호는 없어도 된다
let assertYujin = (chargeFee yujin 30.0M = 7920.0M)
let assertMinho = chargeFee minho 20.0M = 6000.0M
let assertSoyeon = chargeFee soyeon 30.0M = 9000.0M
let assertTaeho = chargeFee taeho 30.0M = 9000.0M

printfn "%b %b %b %b" assertYujin assertMinho assertSoyeon assertTaeho   // 기대: true true true true
```

- F# 에는 `==` 도 `===` 도 없다. `=` 하나가 바인딩, 필드 값 지정, 동등성 비교를 모두 맡는다. 레코드 필드뿐 아니라 뒤에서 볼 케이스 데이터 필드에도 같은 `=` 를 쓴다. 문맥이 어느 쪽인지 결정한다.
- 값을 바꿔 쓰려면 바인딩을 `mutable` 로 명시해야 하고, 대입에는 `<-` 를 쓴다.

```fsharp id=01-record-fee
// mutable 을 명시해야 값을 바꿔 쓸 수 있다. 대입은 <-, 비교는 =
let mutable sessionCount = 0
let beforeAssign = (sessionCount = 1)   // 여기의 = 는 동등성 비교
sessionCount <- 1                       // 여기가 대입
printfn "대입 전 비교=%b, 대입 후 비교=%b" beforeAssign (sessionCount = 1)   // 기대: 대입 전 비교=false, 대입 후 비교=true
```

`mutable` 은 그 이름에 다른 값을 다시 대입할 수 있게 해 주는 것이지, 담긴 데이터를 가변으로 만드는 것이 아니다. `mutable` 로 묶은 이름이 레코드를 담고 있어도 그 레코드의 필드는 여전히 바꿀 수 없다.

- 검증 의도를 더 드러내려면 비교를 함수로 뽑아도 된다. 이 함수는 특정 타입에 묶이지 않고 제네릭(generic)으로 일반화된다. 같은 타입의 두 값이면 `=` 로 비교할 수 있다는 사실만 필요하기 때문이다.

```fsharp id=01-record-fee
// 'a -> 'a -> bool  (when 'a : equality)
let areEqual expected actual =
    actual = expected

printfn "%b %b" (areEqual 7920.0M (chargeFee yujin 30.0M)) (areEqual 6000.0M (chargeFee minho 20.0M))   // 기대: true true
```

`'a` 처럼 작은따옴표로 시작하는 이름은 어떤 타입이든 들어갈 수 있는 자리, 곧 타입 매개변수(type parameter)다. 여기서 컴파일러는 `'a` 에 동등성 비교가 가능해야 한다는 제약까지 함께 붙였다.

```fsharp id=01-record-fee
// 레코드에는 구조적 동등성이 기본으로 붙는다. 따로 만든 두 값도 = 가 참이다
let sameSoyeon = { DriverId = "soyeon"; IsSubscribed = true; IsPlanActive = false }
printfn "%b" (sameSoyeon = soyeon)                        // 기대: true
printfn "%b" (areEqual sameSoyeon soyeon)                 // 기대: true
```

따로 만든 두 레코드인데도 `=` 가 참이다. 레코드와 판별 유니온에는 구조적 동등성(structural equality)이 기본으로 붙는다. 참조가 아니라 담긴 값을 비교하므로 값이 같으면 `=` 가 참이다. `areEqual` 이 `'a : equality` 하나만 요구하고도 도메인 타입에 그대로 쓸 수 있는 이유가 이것이다.

- 여기까지의 코드는 동작한다. 그러나 도메인 개념을 `bool` 플래그로 표현한 것이 약점이다. `IsSubscribed = false` 이면서 `IsPlanActive = true` 인 값, 곧 가입하지도 않았는데 요금제가 유효한 운전자를 만들 수 있다. 명세상 있을 수 없는 상태인데 타입이 막아 주지 않는다.
- `driver.IsSubscribed` 검사를 조건에 추가하면 되지만, 그런 검사는 빼먹기 쉽다. 대신 타입 시스템으로 "가입" 과 "미가입" 이라는 개념 자체를 드러내는 쪽이 낫다.

## Making the Implicit Explicit — 판별 유니온과 패턴 매칭 (원서 pp.16-18)

- 먼저 가입 운전자와 비회원을 각각의 레코드 타입으로 나눈다. 담는 데이터가 다르기 때문이다.
- 그다음 "운전자는 가입자이거나 비회원이다" 를 표현할 재료가 필요하다. 대수적 타입 시스템의 OR 타입인 판별 유니온이 그것이다. 줄여서 DU 라고도 부른다.

```fsharp id=01-du-explicit
// 이 단위가 보여주는 것: 판별 유니온, match 식, 케이스 데이터 분해, when 가드, 와일드카드

type PlanHolder = {
    DriverId: string
    IsPlanActive: bool
}

type Visitor = {
    DriverId: string
}

// "운전자는 PlanHolder 를 담은 Subscribed 이거나, Visitor 를 담은 Walkup 이다"
type Driver =
    | Subscribed of PlanHolder
    | Walkup of Visitor
```

- `|` 로 나열한 항목을 유니온 케이스(union case)라 한다. 각 케이스는 케이스 식별자(case identifier)와 선택적인 케이스 데이터(case data)로 이뤄진다. 여기서는 `Subscribed` 와 `Walkup` 이 케이스 식별자이고, `of` 뒤에 붙는 타입이 케이스 데이터다. 케이스 데이터로는 어떤 타입이든 붙일 수 있고, 여러 타입을 섞어도 되고, 아예 붙이지 않아도 된다.
- 판별 유니온은 닫힌 집합이다. 타입 정의에 적힌 케이스만 존재하고, 케이스를 추가할 수 있는 곳은 타입 정의 한 곳뿐이다.
- 값을 만들 때는 케이스 식별자를 함수처럼 앞에 붙인다. `Driver` 자체를 직접 만들 수는 없고, 반드시 `Subscribed` 나 `Walkup` 중 하나여야 한다.

```fsharp id=01-du-explicit
// 케이스 식별자를 앞에 붙여 만든다. 네 값 모두 타입은 Driver 다
let taeho = Walkup { DriverId = "taeho" }
let yujin = Subscribed { DriverId = "yujin"; IsPlanActive = true }
let minho = Subscribed { DriverId = "minho"; IsPlanActive = true }
let soyeon = Subscribed { DriverId = "soyeon"; IsPlanActive = false }

printfn "%A" taeho   // 기대: Walkup { DriverId = "taeho" }
printfn "%A" yujin   // 기대: 레코드가 담긴 케이스는 %A 가 여러 줄로 출력한다
                     //       Subscribed { DriverId = "yujin"
                     //                    IsPlanActive = true }
```

- 타입이 레코드에서 판별 유니온으로 바뀌었으니 계산 함수도 바뀐다. 어느 케이스인지 확인하는 도구가 패턴 매칭이고, 그 문법이 `match` 식이다.

```fsharp id=01-du-explicit
// Driver -> decimal -> decimal
let chargeFee driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | Subscribed h ->
            if h.IsPlanActive && kwh >= 25.0M then gross * 0.12M else 0.0M
        | Walkup _ -> 0.0M
    gross - waiver
```

- `Subscribed h` 를 값을 만들 때 쓴 `Subscribed { DriverId = "yujin"; IsPlanActive = true }` 와 나란히 놓고 보면 이해가 쉽다. 만들 때 케이스 데이터를 넣었던 자리에, 매칭할 때는 그 데이터를 받을 이름 `h` 를 놓는다.
- `Walkup _` 의 밑줄은 와일드카드(wildcard)다. 그 케이스 데이터를 쓰지 않겠다는 표시다.
- 판별 유니온을 상대로 하는 패턴 매칭은 빠짐없는 패턴 매칭(exhaustive pattern matching)이어야 한다. 모든 케이스를 처리해야 하고, 빠뜨리면 컴파일러가 경고 FS0025 를 낸다. 아래처럼 `Walkup` 을 빼면 그 경고가 난다.

```fsharp
match driver with
| Subscribed h -> ...      // Walkup 이 빠졌다 -> warning FS0025
```

편집기와 FSI 가 내놓는 문구는 이렇다. 이 노트가 "빠짐없는 패턴 매칭" 이라 부르는 것을 컴파일러는 "완전하지 않습니다" 로 말한다.

> warning FS0025: 이 식의 패턴 일치가 완전하지 않습니다. 예를 들어, 값 'Walkup (_)'은(는) 패턴에 포함되지 않은 케이스를 나타낼 수 있습니다.

어느 케이스가 빠졌는지까지 짚어 준다. 위 문구는 F# 10 한국어 로케일에서 실측한 것이고, SDK 버전과 로케일에 따라 표현이 달라질 수 있다.

FS0025 는 오류가 아니라 경고다. 그래서 코드는 그대로 컴파일되고, 빠뜨린 케이스에 해당하는 값이 실제로 들어오면 그 `match` 식이 실행 시점에 `MatchFailureException` 을 던진다. 그때 보게 되는 문구는 `Microsoft.FSharp.Core.MatchFailureException: 일치하는 케이스가 완전하지 않습니다.` 다. 경고를 무시하는 것은 컴파일러가 잡아 준 문제를 실행 시점으로 미루는 일일 뿐이다.

- 중첩된 `if` 는 가드 절(guard clause)인 `when` 으로 펼 수 있다. 단, 컴파일러는 가드의 참/거짓을 계산하지 않고, 가드가 붙은 케이스는 그 케이스 전체를 덮지 못한 것으로 본다. 케이스를 하나도 빠뜨리지 않고 적어도 가드를 붙인 쪽이 있으면 같은 FS0025 가 난다. 그래서 요금제가 만료된 가입자를 처리하는 케이스를 따로 적어 줘야 모든 경우가 채워진다.

```fsharp id=01-du-explicit
// Driver -> decimal -> decimal — when 가드로 중첩 if 를 없앴다
let chargeFeeGuarded driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | Subscribed h when h.IsPlanActive && kwh >= 25.0M -> gross * 0.12M
        | Subscribed _ -> 0.0M
        | Walkup _ -> 0.0M
    gross - waiver
```

- 같은 값을 내는 뒤쪽 두 케이스는 와일드카드 하나로 합칠 수 있다.

```fsharp id=01-du-explicit
// Driver -> decimal -> decimal — 나머지 케이스를 와일드카드로 합쳤다
let chargeFeeTerse driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | Subscribed h when h.IsPlanActive && kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver

// 세 버전 모두 명세를 만족한다
printfn "%b" (chargeFee yujin 30.0M = 7920.0M
              && chargeFeeGuarded yujin 30.0M = 7920.0M
              && chargeFeeTerse yujin 30.0M = 7920.0M)                 // 기대: true
printfn "%b" (chargeFeeTerse minho 20.0M = 6000.0M
              && chargeFeeTerse soyeon 30.0M = 9000.0M
              && chargeFeeTerse taeho 30.0M = 9000.0M)                 // 기대: true
```

- 다만 이런 식의 와일드카드에는 대가가 있다. 나중에 판별 유니온에 케이스를 추가해도 컴파일러가 알려 주지 않는다. 새 케이스가 조용히 `_` 로 흘러 들어가 엉뚱한 결과를 낼 수 있다.
- 검증 코드는 손댈 필요가 없었다. 처음 버전보다 로직이 읽기 쉬워졌고, 잘못된 상태를 만들 수 없게 됐다. 그렇다면 감면 자격까지 타입으로 올리면 더 나아질까.

## Going Further — 자격을 타입으로 올리기 (원서 pp.18-20)

- `IsPlanActive` 라는 `bool` 필드를 없애고, 요금제가 유효한 상태를 판별 유니온의 케이스로 올린다. 이렇게 하면 "유효" 가 플래그 값이 아니라 도메인 개념이 된다.

```fsharp id=01-du-eligible
// 이 단위가 보여주는 것: bool 플래그를 유니온 케이스로 올려 자격을 타입으로 표현하기

type PlanHolder = {
    DriverId: string
}

type Visitor = {
    DriverId: string
}

// 유효한 요금제 / 만료된 요금제 / 비회원 — 세 갈림이 케이스 이름으로 드러난다
type Driver =
    | ActivePlan of PlanHolder
    | ExpiredPlan of PlanHolder
    | Walkup of Visitor
```

- `PlanHolder` 와 `Visitor` 는 구조가 똑같다. 이럴 때 `{ DriverId = "yujin" }` 만 놓으면 컴파일러는 오류를 내지 않고 가장 나중에 선언된 타입, 곧 `Visitor` 를 고른다. 원한 타입이 아니어도 그 자리에서는 아무 신호가 없고, 그 값을 쓰는 자리에서 타입이 맞지 않는다는 오류 FS0001 이 뒤늦게 난다. 반면 케이스 식별자 뒤에 놓으면 그 케이스가 요구하는 타입이 정해져 있어 이런 일이 없다.

```fsharp id=01-du-eligible
let yujin = ActivePlan { DriverId = "yujin" }
let minho = ActivePlan { DriverId = "minho" }
let soyeon = ExpiredPlan { DriverId = "soyeon" }
let taeho = Walkup { DriverId = "taeho" }
```

- 함수에서 `IsPlanActive` 검사가 사라진다. 케이스 데이터도 필요 없으니 이름 대신 와일드카드를 놓는다.

```fsharp id=01-du-eligible
// Driver -> decimal -> decimal
let chargeFee driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | ActivePlan _ when kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver

printfn "%b %b %b %b"
    (chargeFee yujin 30.0M = 7920.0M)
    (chargeFee minho 20.0M = 6000.0M)
    (chargeFee soyeon 30.0M = 9000.0M)
    (chargeFee taeho 30.0M = 9000.0M)   // 기대: true true true true
```

- 감면 조건이 `ActivePlan` 케이스와 충전량 하나로 줄었다. 읽기도 쉬워졌고, 잘못된 상태도 만들 수 없다.
- 남은 개선 여지도 있다. `DriverId` 가 여전히 그냥 `string` 이다. 원시 타입을 도메인 개념으로 감싸는 방법은 9챕터에서 다루고, 여기서 손으로 만든 검증을 xUnit 단위 테스트로 옮기는 방법은 4챕터에서 다룬다.

`PlanHolder` 와 `Visitor` 가 필드 하나뿐이라면, 레코드를 없애고 `string` 을 케이스 데이터로 직접 붙일 수도 있다.

```fsharp id=01-du-flat
// 이 단위가 보여주는 것: 레코드 없이 원시 타입을 케이스 데이터로 직접 붙이기

// 케이스 데이터에 이름을 달아 두면 그 이름이 문서 역할을 한다
type Driver =
    | ActivePlan of DriverId: string
    | ExpiredPlan of DriverId: string
    | Walkup of DriverId: string
```

레코드를 없애도 세 갈림은 그대로 남는다. `of` 뒤에 `DriverId: string` 이라고 이름을 달았기 때문에 `string` 하나만 붙였을 때보다 뜻이 분명하다. 함수 쪽은 앞 절의 버전을 그대로 쓸 수 있다.

```fsharp id=01-du-flat
// Driver -> decimal -> decimal — 함수 본문은 앞의 버전과 똑같다
let chargeFee driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | ActivePlan _ when kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver

let yujin = ActivePlan "yujin"
let minho = ActivePlan "minho"
let soyeon = ExpiredPlan "soyeon"
let taeho = Walkup "taeho"

printfn "%b %b %b %b"
    (chargeFee yujin 30.0M = 7920.0M)
    (chargeFee minho 20.0M = 6000.0M)
    (chargeFee soyeon 30.0M = 9000.0M)
    (chargeFee taeho 30.0M = 9000.0M)   // 기대: true true true true
```

- 원서는 이 방식을 최종안으로 고르지 않는다. 실제 시스템이라면 가입자 쪽 케이스 데이터에 필드가 더 붙을 가능성이 높기 때문이다. 필드가 늘어날 일이 없는 비회원 쪽만 이렇게 펴는 절충도 가능하다.
- 판별 유니온으로 이 도메인을 모델링하는 방법이 하나뿐인 것은 아니다. 다음 두 절은 같은 문제를 다른 구성으로 다시 푼다.

## Alternative Approaches (1 of 2) — 판별 유니온을 레코드 필드로 (원서 pp.21-22)

- 앞의 방식은 판별 유니온을 최상위 타입으로 놓고 그 안에 레코드를 담았다. 순서를 뒤집을 수도 있다. 레코드를 최상위로 놓고, 그 필드 하나의 타입으로 판별 유니온을 쓰는 것이다.

```fsharp id=01-du-in-record
// 이 단위가 보여주는 것: 레코드 필드의 타입으로 판별 유니온을 쓰는 구성

// 케이스 데이터가 없는 케이스(Walkup)와 있는 케이스(Subscribed)를 섞을 수 있다
type Membership =
    | Subscribed of IsPlanActive: bool
    | Walkup

type Driver = { DriverId: string; Membership: Membership }

// Driver -> decimal -> decimal
let chargeFeeVerbose driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver.Membership with
        | Subscribed (IsPlanActive = isActive) when isActive && kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver
```

- `Subscribed (IsPlanActive = isActive)` 는 케이스 데이터의 `IsPlanActive` 필드를 `isActive` 라는 이름으로 꺼내는 패턴이다. 꺼낸 값을 `when` 절에서 검사한다.
- 값 쪽에서도 같은 문법으로 필드 이름을 지정해 만들 수 있다.

```fsharp id=01-du-in-record
let yujin = { DriverId = "yujin"; Membership = Subscribed (IsPlanActive = true) }
let minho = { DriverId = "minho"; Membership = Subscribed (IsPlanActive = true) }
let soyeon = { DriverId = "soyeon"; Membership = Subscribed (IsPlanActive = false) }
let taeho = { DriverId = "taeho"; Membership = Walkup }
```

- 값을 꺼낸 뒤 `when` 에서 검사하는 대신, 패턴 자체에 값을 박아 걸러낼 수도 있다. `IsPlanActive = true` 인 것만 이 케이스에 걸린다.

```fsharp id=01-du-in-record
// Driver -> decimal -> decimal — 패턴에 값을 직접 박아 걸러낸다
let chargeFee driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver.Membership with
        | Subscribed (IsPlanActive = true) when kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver

printfn "%b %b %b %b"
    (chargeFee yujin 30.0M = 7920.0M)
    (chargeFee minho 20.0M = 6000.0M)
    (chargeFee soyeon 30.0M = 9000.0M)
    (chargeFee taeho 30.0M = 9000.0M)                                  // 기대: true true true true
printfn "verbose 버전과 결과가 같은가: %b"
    (chargeFeeVerbose yujin 30.0M = chargeFee yujin 30.0M)             // 기대: true
```

- 이 구성도 잘못된 상태를 막아 준다는 점에서는 문제가 없다. 그러나 `Membership` 이라는 이름은 원래 명세에 없던 말이다. 모델링을 하다가 이런 중간 이름을 발명해야 한다면, 도메인 중심 코드에서 한 발 멀어졌다는 신호로 볼 만하다.

## Alternative Approaches (2 of 2) — 케이스 데이터에 이름 붙이기 (원서 pp.22-24)

- 앞의 두 절에서도 케이스 데이터에 이름을 하나씩 달아 썼다. 이번 절은 여러 필드에 이름을 붙이고 그것을 꺼내는 방식을 정리한다. 판별 유니온의 케이스 데이터는 튜플처럼 `*` 로 이어 쓰지만 튜플이 아니다. 컴파일된 뒤에도 필드가 따로 놓이고, 패턴에서 `Subscribed t` 처럼 튜플 하나로 받으려 하면 오류 FS0727 이 난다. 그리고 튜플과 달리 각 부분에 이름을 붙일 수 있다.

```fsharp id=01-du-named-fields
// 이 단위가 보여주는 것: 이름 붙은 케이스 데이터, 세 가지 매칭 방식, 액티브 패턴 맛보기

// 튜플처럼 * 로 이어 쓰지만 패턴에서 튜플 하나로 받을 수는 없다. 각 부분에 이름이 붙는다
type Driver =
    | Subscribed of DriverId: string * IsPlanActive: bool
    | Walkup of DriverId: string

let yujin = Subscribed (DriverId = "yujin", IsPlanActive = true)
let minho = Subscribed (DriverId = "minho", IsPlanActive = true)
let soyeon = Subscribed (DriverId = "soyeon", IsPlanActive = false)
let taeho = Walkup (DriverId = "taeho")
```

- 매칭 방식은 여러 가지다. 첫째, 위치대로 이름을 나열해 꺼낸다.

```fsharp id=01-du-named-fields
// Driver -> decimal -> decimal — 위치 순서대로 꺼낸다. 쓰지 않는 자리는 와일드카드로 둔다
let chargeFeeByPosition driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | Subscribed (_, isActive) when isActive && kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver
```

- 둘째, 필드 이름을 써서 값을 박아 걸러낸다. 앞 절과 같은 문법이다. 위치를 셀 필요가 없어 필드가 늘어나도 흔들리지 않는다.

```fsharp id=01-du-named-fields
// Driver -> decimal -> decimal — 필드 이름으로 걸러내니 위치를 셀 필요가 없다
let chargeFee driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | Subscribed (IsPlanActive = true) when kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver

printfn "%b %b %b %b"
    (chargeFee yujin 30.0M = 7920.0M)
    (chargeFee minho 20.0M = 6000.0M)
    (chargeFee soyeon 30.0M = 9000.0M)
    (chargeFee taeho 30.0M = 9000.0M)                                       // 기대: true true true true
printfn "위치 방식과 결과가 같은가: %b"
    (chargeFeeByPosition yujin 30.0M = chargeFee yujin 30.0M)               // 기대: true
```

- 셋째, 걸러내면서 다른 필드 값도 함께 꺼낼 수 있다. 이때 필드 사이 구분자는 쉼표가 아니라 세미콜론이다.

```fsharp id=01-du-named-fields
// Driver -> decimal -> string — 걸러내는 동시에 DriverId 도 꺼낸다
let waiverNote driver kwh =
    match driver with
    | Subscribed (DriverId = id; IsPlanActive = true) when kwh >= 25.0M -> $"{id}: 12퍼센트 감면"
    | Subscribed (DriverId = id) -> $"{id}: 감면 없음"
    | Walkup (DriverId = id) -> $"{id}: 비회원"

printfn "%s" (waiverNote yujin 30.0M)    // 기대: yujin: 12퍼센트 감면
printfn "%s" (waiverNote minho 20.0M)    // 기대: minho: 감면 없음
printfn "%s" (waiverNote taeho 30.0M)    // 기대: taeho: 비회원
```

- 이렇게 반복되는 필터를 재사용 가능한 조각으로 뽑을 수도 있다. 그 기능이 액티브 패턴(active pattern)이고 7챕터에서 따로 다룬다. 여기서는 맛만 본다.

```fsharp id=01-du-named-fields
// Driver -> unit option — (| ... |_|) 로 감싸면 패턴 자리에서 쓸 수 있는 이름이 된다
let (|OnActivePlan|_|) driver =
    match driver with
    | Subscribed (IsPlanActive = true) -> Some ()
    | _ -> None

// Driver -> decimal -> decimal — 필터가 케이스 이름처럼 읽힌다
let chargeFeeWithPattern driver kwh =
    let gross = kwh * 300.0M
    let waiver =
        match driver with
        | OnActivePlan when kwh >= 25.0M -> gross * 0.12M
        | _ -> 0.0M
    gross - waiver

printfn "%b %b %b %b"
    (chargeFeeWithPattern yujin 30.0M = 7920.0M)
    (chargeFeeWithPattern minho 20.0M = 6000.0M)
    (chargeFeeWithPattern soyeon 30.0M = 9000.0M)
    (chargeFeeWithPattern taeho 30.0M = 9000.0M)   // 기대: true true true true
```

`Option`, `Some`, `None`, `unit` 은 3챕터에서, 액티브 패턴은 7챕터에서 제대로 다룬다.

- 원서가 제시하는 도메인 모델링 지침은 두 문장으로 요약된다. 최대한 도메인의 언어를 쓸 것, 그리고 잘못된 상태를 표현조차 할 수 없게 만들 것.
- 모델링에 정답은 없다. 여러 버전을 만들어 보면 처음 떠올린 것보다 나은 구성이 나올 때가 많다. 이 챕터가 같은 문제를 다섯 번 다시 푼 이유가 그것이다.

## Summary — 원서의 챕터 요약 (원서 pp.24-25)

- 원서는 이 챕터에서 타입을 여러 방식으로 조합해 하나의 업무 문제를 풀었다. 재료는 AND 타입(튜플, 레코드)과 OR 타입(판별 유니온)뿐인데도, 이것들을 겹쳐 쌓으면 꽤 다양한 도메인을 정확하게 표현할 수 있다.
- 다룬 항목은 FSI, 대수적 타입 시스템(튜플, 레코드, 판별 유니온, 타입 조합), 패턴 매칭(`match` 식, 가드 절), `let` 바인딩, 함수, 함수 시그니처다.
- 다음 챕터에서는 함수 합성을 살펴본다. 작은 함수를 이어 붙여 큰 함수를 만드는 방법이다.

## Postscript — 개념은 언어를 넘는다 (원서 p.25)

- 원서는 마지막에 동료가 작성한 Scala 판 해법을 실어, 이 챕터에서 다룬 개념이 F# 전용이 아니라는 점을 보여 준다.
- 봉인된 트레이트(sealed trait)와 케이스 클래스는 F# 의 판별 유니온에 대응하고, Scala 의 `match` 는 F# 의 `match` 식에 거의 그대로 대응한다. 아래는 같은 대응을 이 노트의 도메인으로 옮겨 본 스케치다.
- 아래 스케치는 원서에 실린 Scala 코드를 따라 `Double` 을 쓴다. 금액 계산에 `decimal` 이 맞다는 앞의 판단은 그대로 유효하고, 원서와 대조하기 쉽게 숫자 타입만 원서대로 두었다.

```scala
sealed trait Driver
case class ActivePlan(driverId: String) extends Driver
case class ExpiredPlan(driverId: String) extends Driver
case class Walkup(driverId: String) extends Driver

def chargeFee(driver: Driver)(kwh: Double) = {
    val gross = kwh * 300.0
    val waiver = driver match {
        case ActivePlan(_) if kwh >= 25.0 => gross * 0.12
        case _ => 0.0
    }
    gross - waiver
}
```

- 문법이 낯설어도 앞에서 F# 으로 짠 해법의 골격이 그대로 보인다. 배운 것은 F# 문법이 아니라 모델링 방식이다.

## 정리 — 이 노트의 요약

- 대수적 타입 시스템의 재료는 두 가지다. 여러 값을 동시에 담는 AND 타입(튜플, 레코드)과, 여러 경우 중 하나만 담는 OR 타입(판별 유니온).
- 튜플은 부분에 이름이 없어 뜻을 짐작해야 한다. 레코드와 이름 붙은 케이스 데이터가 그 문제를 없앤다.
- `bool` 플래그로 도메인 개념을 표현하면 명세상 있을 수 없는 상태까지 코드에서는 만들어진다. 그 갈림을 판별 유니온 케이스로 올리면 잘못된 상태가 표현 자체로 불가능해진다.
- 판별 유니온을 `match` 식으로 다룰 때는 모든 케이스를 빠짐없이 적어야 한다. 빠뜨리면 컴파일러가 경고 FS0025 를 낸다. `_` 로 뭉개면 그 경고를 잃는다는 점을 기억해야 한다.
- `when` 가드는 케이스 안에서 조건을 더 좁힌다. 필드 이름을 쓴 패턴(`Subscribed (IsPlanActive = true)`)은 조건을 패턴 자체로 옮겨 준다.
- F# 은 파일 위에서 아래로 컴파일한다. 타입이 함수보다 위에, 함수가 사용처보다 위에 있어야 한다. 프로젝트의 `.fs` 파일 순서도 같은 규칙을 따른다.
- 같은 도메인을 판별 유니온 안에 레코드를 담는 구성, 레코드 필드에 판별 유니온을 담는 구성, 케이스 데이터에 이름을 붙이는 구성으로 각각 모델링할 수 있다. 판단 기준은 도메인의 언어를 그대로 쓰는지, 그리고 잘못된 상태를 막아 주는지다.
- `=` 는 바인딩, 필드 값 지정, 동등성 비교를 겸한다. 대입은 `<-` 이고, 그 전에 바인딩을 `mutable` 로 명시해야 한다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| The Problem — 명세 안에 이미 도메인이 있다 | pp.8-9 | — |
| Getting Started — 튜플과 레코드로 데이터 모양 잡기 | pp.9-11 | `01-record-fee` |
| Getting Started — 계산 함수와 함수 시그니처 | pp.11-13 | `01-record-fee` |
| Getting Started — FSI 로 검증하고, `=` 의 세 가지 얼굴 | pp.13-15 | `01-record-fee` |
| Making the Implicit Explicit — 판별 유니온과 패턴 매칭 | pp.16-18 | `01-du-explicit` |
| Going Further — 자격을 타입으로 올리기 | pp.18-20 | `01-du-eligible`, `01-du-flat` |
| Alternative Approaches (1 of 2) — 판별 유니온을 레코드 필드로 | pp.21-22 | `01-du-in-record` |
| Alternative Approaches (2 of 2) — 케이스 데이터에 이름 붙이기 | pp.22-24 | `01-du-named-fields` |
| Summary — 원서의 챕터 요약 | pp.24-25 | — |
| Postscript — 개념은 언어를 넘는다 | p.25 | — |
