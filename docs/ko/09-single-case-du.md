# 09 - 단일 케이스 판별 유니온 (원서 pp.118-129)

> 코드에 `string` 과 `decimal` 이 널려 있으면 컴파일러가 도와줄 여지가 없다. `decimal` 두 개를 받는 함수는 두 인자를 뒤바꿔 넘겨도 통과하고, 음수 금액이나 범위를 벗어난 좌표도 통과한다. 타입은 맞았지만 뜻이 틀린 값이 그대로 흐른다. 이런 상태를 원시 타입 강박(primitive obsession)이라 부른다. 이 챕터는 원시 타입을 도메인 이름으로 감싸 컴파일러가 뜻까지 검사하게 만드는 방법을 다룬다. 핵심 도구는 케이스가 하나뿐인 판별 유니온(discriminated union)이다. 여기에 `private` 접근 지정자와 스마트 생성자(smart constructor)를 얹으면, 만들어진 값이 언제나 유효하다는 사실을 타입 하나가 보증한다. 1챕터 노트가 "`DriverId` 가 아직 그냥 `string` 이다"라고 남겨 둔 숙제가 바로 이 챕터의 주제다.

## Setting Up — 준비 (원서 p.118)

- 원서는 1챕터에서 만든 코드를 이어서 손본다. 새 폴더에 `code.fsx` 하나를 만들고 FSI 로 돌리는 것이 전부다.
- 이 노트는 1챕터 코드를 다시 꺼내지 않고 새 도메인으로 같은 길을 걷는다. 반려동물 호텔의 숙박 요금 계산이다. 처음에는 숙박 일수와 마리 수가 그냥 `int` 이고, 챕터가 끝날 때는 둘 다 검증을 통과한 값만 담을 수 있는 타입이 된다.
- 원서는 이 챕터의 코드가 8챕터 코드에 어떻게 적용될지 생각해 보라는 숙제를 낸다. 여러 검증 결과를 하나로 모으는 방법은 8챕터의 주제이므로 이 노트에서는 다루지 않는다.

## Solving the Problem — 원시 타입을 도메인 이름으로 (원서 pp.118-125)

원서는 이 절 하나에서 세 단계를 밟는다. 타입 약어 → 단일 케이스 판별 유니온 → `private` 케이스와 스마트 생성자다. 단계마다 무엇이 새로 막히는지가 다르므로 나눠 본다.

### 1단계: 타입 약어로 시그니처에 이름 붙이기 (원서 pp.119-120)

- 시그니처가 `int -> int -> decimal` 이면 읽는 사람이 무엇을 어느 자리에 넣어야 하는지 알 수 없다. 타입 약어(type abbreviation)로 이름을 붙이면 시그니처가 설명 구실을 한다.
- 타입 약어는 기존 타입에 별명을 붙이는 것이고 새 타입을 만들지 않는다. 6챕터에서 함수 타입에 이름을 붙일 때 이미 썼다.
- 매개변수와 반환 타입에 타입 주석으로 약어를 적는 방식과, 함수 타입 전체에 약어 이름을 붙이는 방식이 있다. 결과로 만들어지는 함수는 같다.

```fsharp id=09-abbrev
// 이 단위가 보여주는 것: 타입 약어로 시그니처를 읽기 좋게 만들되, 잘못된 값은 여전히 통과한다
type Nights = int
type PetCount = int
type Fee = decimal

let nightlyRatePerPet = 35000M

// nights: Nights -> petCount: PetCount -> Fee
let estimateFee (nights: Nights) (petCount: PetCount) : Fee =
    decimal nights * decimal petCount * nightlyRatePerPet

printfn "3박 2마리: %M" (estimateFee 3 2)   // 3박 2마리: 210000
```

매개변수 자리마다 약어를 적는 대신, 함수 타입 전체에 이름을 붙이고 람다를 그 이름으로 바인딩하는 방식도 있다. 매개변수를 함수 이름 옆에 적을 수 없어 `fun` 으로 받는다는 점만 다르다.

```fsharp id=09-abbrev
type EstimateFee = Nights -> PetCount -> Fee

// nights: Nights -> petCount: PetCount -> Fee
let estimateFee2 : EstimateFee =
    fun nights petCount -> decimal nights * decimal petCount * nightlyRatePerPet

printfn "3박 2마리: %M" (estimateFee2 3 2)   // 3박 2마리: 210000
```

두 방식의 실측 시그니처는 같다. FSI 는 둘 다 `nights: Nights -> petCount: PetCount -> Fee` 로 보여 준다. 함수 타입 전체에 붙인 약어는 FSI 가 찍는 `val` 줄에 이름으로 남지 않고 화살표 형태로 펼쳐진다. `Nights` 나 `Fee` 처럼 타입 한 개에 붙인 약어는 그 자리에 이름으로 남는다. 어느 쪽이든 약어는 새 타입이 아니므로 실제 타입은 둘 다 `int -> int -> decimal` 이다.

### 타입 약어가 막지 못하는 것 (원서 p.120)

- 약어는 별명이므로 `Nights` 를 요구하는 자리에 아무 `int` 나 들어간다. `PetCount` 도 마찬가지다. 두 약어의 원래 타입이 같으면 서로 바꿔 넣어도 컴파일러가 아무 말을 하지 않는다.
- 범위도 통제하지 못한다. 숙박 일수가 음수든 마리 수가 400 이든 `int` 이기만 하면 통과한다.
- 원서는 위도와 경도를 뒤바꿔 넣는 예로 이 문제를 보인다. 여기서는 숙박 일수와 마리 수를 뒤집어 본다.

```fsharp id=09-abbrev
type Reservation = { Nights: Nights; PetCount: PetCount }

// 9박 2마리를 적으려다 두 칸을 뒤집었다. 그래도 컴파일된다
let swapped : Reservation = { Nights = 2; PetCount = 9 }
// 있을 수 없는 값도 통과한다
let absurd : Reservation = { Nights = -5; PetCount = 400 }

printfn "뒤집힌 예약: %A" swapped     // 뒤집힌 예약: { Nights = 2
                                      //   PetCount = 9 }
printfn "있을 수 없는 예약: %A" absurd   // 있을 수 없는 예약: { Nights = -5
                                         //   PetCount = 400 }
printfn "뒤집힌 요금: %M" (estimateFee 2 9)   // 뒤집힌 요금: 630000
```

이 함수는 두 값을 곱하기만 하므로 뒤집어 넣어도 요금이 같게 나왔다. 그러나 할인 규칙이 숙박 일수에만 걸리는 순간(아래에서 7박 이상 10% 할인을 쓴다) 두 결과가 갈린다. 이런 실수는 테스트를 더 써서 막을 일이 아니라 타입 시스템이 막아야 할 일이다.

### 2단계: 단일 케이스 판별 유니온 (원서 pp.120-122)

- 케이스가 하나뿐인 판별 유니온을 만들면 원래 타입이 같아도 서로 다른 타입이 된다. 이것이 단일 케이스 판별 유니온이다.
- 케이스가 하나라는 뜻을 드러내려고 앞의 `|` 를 생략하는 것이 관례다. 나중에 케이스가 늘어날 여지가 있으면 `|` 를 남겨 둔다.
- 타입 이름과 케이스 식별자를 같은 이름으로 쓰는 것이 보통이다. 둘은 다른 이름 공간에 있어 충돌하지 않는다. 케이스 식별자를 다른 이름으로 지으면 값을 만들 때와 분해할 때 그 이름을 써야 한다.

```fsharp id=09-singlecase
// 이 단위가 보여주는 것: 케이스가 하나뿐인 판별 유니온과 값을 꺼내는 방법들
type Nights = Nights of int
type PetCount = PetCount of int
type Fee = decimal

let nightlyRatePerPet = 35000M

let threeNights = Nights 3
printfn "%A" threeNights   // Nights 3
```

이제 두 타입은 원래 타입이 똑같이 `int` 이지만 서로 대입되지 않는다. 아래 코드는 컴파일되지 않는다.

```fsharp
type Reservation = { Nights: Nights; PetCount: PetCount }

// 오류 FS0001 — 필요한 타입은 Nights 인데 PetCount 가 왔다고 알려 준다
let swapped : Reservation = { Nights = PetCount 2; PetCount = Nights 9 }
```

FSI 가 내는 메시지는 `이 식에는 'Nights' 형식이 필요하지만 여기에서는 'PetCount' 형식이 지정되었습니다.` 다. 원시 타입과 타입 약어를 단일 케이스 판별 유니온으로 바꿔 두면 이런 뒤바뀜은 컴파일 단계에서 끝난다. 작정하고 우회하려는 사람을 막아 주지는 않지만, 넘어야 할 문턱이 하나 더 생긴다.

### 값을 꺼내는 방법 (원서 pp.121-122)

- 감쌌으면 꺼내야 계산할 수 있다. 이 절에서 세 가지를 보고, 네 번째 방법인 같은 이름의 모듈에 둔 함수는 뒤의 모듈 절에서 다룬다.
- 첫째는 `let` 바인딩에서 패턴으로 분해하는 것이다. 케이스가 하나뿐이므로 빠짐없는 패턴 매칭이 성립해 경고가 나지 않는다.
- 둘째는 함수 매개변수 자리에서 바로 분해하는 것이다. 함수 본문이 원시 타입을 쓰던 때와 똑같아지므로 코드가 가장 짧다.
- 셋째는 타입에 프로퍼티를 붙여 놓고 `.Value` 로 읽는 것이다. 다음 단계에서 쓴다.

```fsharp id=09-singlecase
// let 바인딩에서 분해한다
let (Nights nightCount) = threeNights
printfn "숙박 일수: %d" nightCount   // 숙박 일수: 3
```

매개변수 자리에서 분해하면 본문에 `nights` 라는 이름의 `int` 가 그대로 들어온다. 감싸기 전 코드와 본문이 같아지는 것이 이 방식의 장점이다.

```fsharp id=09-singlecase
// Nights -> PetCount -> Fee
let estimateFee (Nights nights) (PetCount petCount) : Fee =
    decimal nights * decimal petCount * nightlyRatePerPet

printfn "3박 2마리: %M" (estimateFee (Nights 3) (PetCount 2))   // 3박 2마리: 210000
```

시그니처는 실측으로 `Nights -> PetCount -> decimal` 이다. 반환 타입에 `Fee` 를 적어 두면 FSI 는 `Nights -> PetCount -> Fee` 로 보여 준다. 약어는 새 타입이 아니지만 표시에는 남으므로 문서 구실을 계속 한다.

### 3단계: private 케이스와 스마트 생성자 (원서 pp.122-124)

- 여기까지는 뒤바뀜만 막았다. 숙박 일수 자리에 `Nights (-3)` 을 넣는 것은 아직 통과한다. 도메인 값은 범위가 있는 것이 보통이므로, 범위 밖의 값으로는 아예 만들어지지 않게 해야 한다.
- 케이스 식별자에 `private` 을 붙이면 그 타입을 담은 모듈 밖에서는 값을 만들 수도 분해할 수도 없다. 남는 생성 경로는 그 모듈 안에 둔 코드뿐이다. 여기서는 타입에 붙인 정적 멤버를 그 경로로 쓴다. 이것이 스마트 생성자다.
- 검증에 실패했을 때 예외를 던지는 대신 `Result` 로 돌려준다. 실패 가능성이 반환 타입에 드러나므로 값을 쓰려면 `Ok` 와 `Error` 를 갈라 처리해야 한다. 예외처럼 시그니처에 안 보이는 채로 흐르지 않는다. `Result` 는 3챕터에서 다뤘다.

```fsharp id=09-smartctor
// 이 단위가 보여주는 것: private 케이스와 스마트 생성자로 검증을 타입 안에 넣기
type ValidationError =
    | OutOfRange of string

module PetHotel =

    type Nights = private Nights of int
        with
            // member Value: int
            member this.Value = match this with Nights n -> n

            // static member Create: input: int -> Result<Nights,ValidationError>
            static member Create input =
                if input >= 1 && input <= 30 then Ok (Nights input)
                else Error (OutOfRange "숙박 일수는 1박 이상 30박 이하여야 한다")

open PetHotel

printfn "%A" (Nights.Create 3)    // Ok Nights 3
printfn "%A" (Nights.Create 31)   // Error (OutOfRange "숙박 일수는 1박 이상 30박 이하여야 한다")
```

- `this` 는 인스턴스를 가리키는 자기 식별자(self identifier)일 뿐이고 F# 에서 특별한 뜻이 없다. `x` 나 `s` 로 지어도 되고, 본문에서 쓰지 않으면 `_` 도 된다.
- `Value` 는 프로퍼티라서 시그니처가 `member Value: int` 로 나온다. 함수가 아니므로 호출 괄호가 없다.
- `Create` 의 반환 타입은 실측으로 `Result<Nights,ValidationError>` 다. 성공 케이스에만 값이 들어 있으니, 이 관문을 통과한 `Nights` 는 언제나 1 이상 30 이하다.

`private` 이 실제로 막는 범위를 확인해 둘 필요가 있다. 아래는 `PetHotel` 모듈 밖이므로 컴파일되지 않는다.

```fsharp
// 오류 FS1093 — 케이스 식별자에 접근할 수 없다
let sneaky = Nights 99
// 분해도 같은 오류다
let peek n = match n with Nights v -> v
```

메시지는 `'Nights' 형식의 공용 구조체 케이스 또는 필드는 이 코드 위치에서 액세스할 수 없습니다.` 다. 주의할 점은 "담은 모듈"의 범위다. 스크립트 최상위에 그냥 선언하면 파일 전체가 그 모듈이므로 `private` 이 아무것도 막지 못한다.

```fsharp id=09-smartctor
// 스크립트 최상위 선언에서는 private 이 같은 파일 안의 코드를 막지 못한다
type Leaky = private Leaky of int
let leaked = Leaky 99
printfn "%A" leaked   // Leaky 99
```

구멍이 하나 더 있다. 감싸는 모듈을 두어도 그 모듈 안의 중첩 모듈은 `private` 케이스를 그대로 본다.

```fsharp id=09-smartctor
// 감싸는 모듈 안의 중첩 모듈은 private 케이스를 그대로 본다
module Inner =

    type Days = private Days of int

    module Days =
        let create input =
            if input >= 1 then Ok (Days input)
            else Error (OutOfRange "일수는 1 이상이어야 한다")

    // 같은 모듈 안이므로 create 를 건너뛸 수 있다
    module Bypass =
        let skipped = Days (-999)

printfn "%A" Inner.Bypass.skipped   // Days -999
```

`Inner.Bypass` 는 `Inner` 안에 있으므로 `Days.create` 를 건너뛰고 값을 만들 수 있다. `private` 이 세우는 경계는 타입을 담은 모듈의 안팎이고, 그 안의 중첩 구조까지 나누지는 않는다.

값을 꺼내 쓸 때는 `.Value` 를 읽는다. 이때 타입 추론이 한계에 부딪힌다. 매개변수에 타입 주석이 없으면 컴파일러는 `nights` 가 어떤 타입인지 모르므로 멤버 조회를 확정할 수 없다.

```fsharp
// 오류 FS0072 — 어떤 타입의 .Value 인지 알 수 없다
let estimateFee nights = decimal nights.Value * 35000M
```

메시지는 `이 프로그램 지점 전의 정보를 기반으로 하는 확인할 수 없는 형식의 개체를 대상으로 조회를 수행합니다.` 로 시작한다. 매개변수에 타입 주석을 달면 해결된다. 타입 추론에 기대는 것이 원칙이지만, 멤버 조회처럼 추론이 닿지 않는 자리에서는 타입 주석을 적는다. 일반 함수는 구체 타입 하나로 컴파일되어야 하므로 컴파일러가 멤버 이름만 보고 타입을 거꾸로 찾아 주지 않는다. 타입 매개변수에 멤버 제약을 걸 수 있는 것은 호출 지점마다 코드를 새로 만드는 `inline` 함수뿐이다.

```fsharp id=09-smartctor
// nights: PetHotel.Nights -> decimal
let estimateFee (nights: Nights) =
    decimal nights.Value * 35000M

Nights.Create 4 |> Result.map estimateFee |> printfn "%A"   // Ok 140000M
```

#### 보충: 타입 주석 없이 `.Value` 를 쓰는 방법 (노트 보충)

타입 주석을 달지 않고도 멤버 조회를 컴파일하는 길이 하나 있다. 함수를 `inline` 으로 선언하고 타입 매개변수에 멤버 제약(member constraint)을 직접 적는 것이다. 코드에는 `'a` 로 적지만 `inline` 함수의 타입 매개변수는 호출 지점마다 확정되므로, FSI 시그니처에는 정적으로 확인되는 타입 매개변수(statically resolved type parameter, SRTP)를 뜻하는 `^a` 로 나타난다. `Value: int` 프로퍼티가 있는 타입이면 무엇이든 받는다.

```fsharp id=09-smartctor
// nights: ^a -> decimal when ^a: (member Value: int)
let inline nightlyFee (nights: 'a when 'a: (member Value: int)) =
    decimal nights.Value * 35000M

Nights.Create 2 |> Result.map nightlyFee |> printfn "%A"   // Ok 70000M
```

`inline` 만 붙이고 `nights.Value` 라고 쓰면 여전히 오류 FS0072 다. 제약을 손으로 적어야 추론이 성립한다. 도메인 코드에서 이렇게까지 할 이유는 거의 없다. 여기서 얻을 교훈은 프로퍼티 방식이 타입 추론과 잘 맞물리지 않는다는 점이고, 그래서 다음 절의 모듈 방식이 더 편하다.

### 타입에 동작을 붙이면 (원서 pp.124-125)

- 판별 유니온이나 레코드에도 멤버를 붙일 수 있다. 할인율 계산 같은 규칙을 데이터 정의 옆에 두면 재사용하기 좋다.
- 다만 멤버로 옮기는 과정에서 규칙이 쪼개지기 쉽다. 원서는 할인율을 고객 타입의 멤버로 뽑았다가 "고객 등급과 결제 금액이 함께 걸리는 규칙"이 끊어지는 것을 보이고, 두 값을 함께 받는 멤버로 다시 고친다.
- 결론은 멤버를 쓰지 말자는 쪽이다. 데이터와 동작을 섞지 않는 편이 낫다는 것이 원서의 권고다. 규칙이 아니라 강한 안내라고 못을 박는다.

```fsharp id=09-smartctor
// 데이터 정의에 동작을 붙인 형태. 7박 이상이면 10% 할인이다
type Reservation =
    { Nights: Nights
      Pets: int }
    with
        // member DiscountRate: decimal
        member this.DiscountRate =
            if this.Nights.Value >= 7 then 0.1M else 0.0M

match Nights.Create 8 with
| Ok n -> printfn "할인율: %M" { Nights = n; Pets = 2 }.DiscountRate   // 할인율: 0.1
| Error _ -> ()
```

이 형태 자체는 잘 돌아간다. 문제는 요금 규칙이 늘어날수록 레코드 정의가 계산 코드로 뒤덮인다는 점이다. 다음 절이 대안이다.

## Using Modules — 모듈로 옮기기 (원서 pp.125-127)

- 타입과 같은 이름의 모듈을 만들어 함수를 그 안에 둔다. `List`, `Option`, `Result` 가 모두 이 구조다. F# 코드 전반의 관례이므로 읽는 사람에게 설명이 필요 없다.
- 타입 이름과 모듈 이름을 같게 두어도 컴파일 오류가 나지 않는다. 컴파일된 이름이 겹치지 않도록 컴파일러가 모듈 쪽에 `Module` 접미사를 붙이기 때문이다(실측한 컴파일 이름은 `PetHotel+Nights` 와 `PetHotel+NightsModule` 이다). F# 코드에서는 둘을 같은 이름으로 쓰고, 컴파일러가 `Nights.value` 는 모듈 함수로, `Nights.Create` 는 타입의 정적 멤버로 갈라 찾아 준다.
- 모듈 함수는 정의 타입의 인스턴스를 마지막 매개변수로 받는 것이 관례다. `List.map f list` 처럼 파이프라인 끝에 값이 흘러 들어오게 하려는 것이다.
- `private` 케이스는 그 타입을 담은 모듈 안에서만 보인다. 감싸는 모듈 하나를 두고 그 안에 타입과 같은 이름의 모듈을 같이 넣으면, 바깥에서는 `create` 를 거치지 않고 값을 만들 수 없다.
- 원서 p.126 의 `Spend.Value spend` 는 오기다. 그 시점 `Spend` 에는 인스턴스 프로퍼티만 있고 같은 이름의 모듈이 아직 없으므로 `spend.Value` 여야 한다(그대로 적으면 오류 FS0806). 모듈로 옮긴 p.127 부터는 소문자 `Spend.value spend` 다.

```fsharp id=09-module
// 이 단위가 보여주는 것: 타입과 같은 이름의 모듈로 생성 경로와 값 접근을 모으기
type ValidationError =
    | OutOfRange of string

module PetHotel =

    type Nights = private Nights of int

    module Nights =
        // Nights -> int
        let value (Nights n) = n

        // input: int -> Result<Nights,ValidationError>
        let create input =
            if input >= 1 && input <= 30 then Ok (Nights input)
            else Error (OutOfRange "숙박 일수는 1박 이상 30박 이하여야 한다")
```

`Nights.value` 는 매개변수 자리에서 값을 바로 분해한다. 프로퍼티 방식과 달리 이쪽은 시그니처가 `Nights -> int` 로 확정되므로, 이 함수를 쓰는 코드에는 타입 주석이 필요 없다. 앞 절에서 본 오류 FS0072 를 만나지 않는다.

예약 레코드는 새 모듈에 두고, 그 레코드와 같은 이름의 모듈을 함께 넣는다. 마리 수는 아직 `int` 로 남겨 둔다.

```fsharp id=09-module
module Booking =

    open PetHotel

    type Reservation =
        { Nights: Nights
          Pets: int }

    module Reservation =
        let nightlyRatePerPet = 35000M

        // reservation: Reservation -> decimal
        let discountRate reservation =
            if Nights.value reservation.Nights >= 7 then 0.1M else 0.0M

        // reservation: Reservation -> decimal
        let fee reservation =
            let nights = decimal (Nights.value reservation.Nights)
            let pets = decimal reservation.Pets
            nights * pets * nightlyRatePerPet * (1.0M - discountRate reservation)
```

- 모듈 이름을 `Booking` 으로 새로 뒀다. 한 스크립트 안에서 `PetHotel` 을 한 번 더 선언해 내용을 이어 붙일 수는 없다. 같은 이름의 모듈을 두 번 적으면 오류 FS0037(`형식, 예외 또는 모듈입니다. 'PetHotel'의 정의가 중복되었습니다.`)이 난다. 앞 절의 `PetHotel` 은 따로 실행되는 코드이므로 이 절과 부딪히지 않는다.
- 이렇게 나누면 경계가 오히려 분명해진다. `Booking` 은 `PetHotel` 밖이므로 `private` 케이스가 보이지 않고, `Nights.value` 와 `Nights.create` 만 쓸 수 있다. `Booking` 을 `PetHotel` 안에 중첩 모듈로 넣으면 `private` 케이스가 다시 보이므로 `create` 를 건너뛴 값을 만들 수 있다. 검증을 통제하려면 쓰는 쪽이 그 모듈 밖에 있어야 한다.
- `discountRate` 와 `fee` 는 둘 다 `Reservation` 을 마지막(이자 유일한) 매개변수로 받는다. 그래서 파이프라인에 그대로 얹힌다.

```fsharp id=09-module
open PetHotel
open Booking

// nights: int -> pets: int -> Result<decimal,ValidationError>
let quote nights pets =
    Nights.create nights
    |> Result.map (fun n -> { Nights = n; Pets = pets })
    |> Result.map Reservation.fee

printfn "%A" (quote 3 2)   // Ok 210000.0M
printfn "%A" (quote 7 1)   // Ok 220500.0M
printfn "%A" (quote 0 1)   // Error (OutOfRange "숙박 일수는 1박 이상 30박 이하여야 한다")
```

7박 1마리는 245000 에서 10% 를 뺀 220500 이다. `(1.0M - discountRate reservation)` 을 곱하므로 소수 자릿수가 하나 늘어 `220500.0M` 으로 표시된다.

## A Few Minor Improvements — 남은 원시 타입 정리 (원서 pp.127-129)

- 원서는 마지막으로 남은 원시 타입을 정리한다. 고객 식별자로 쓰던 `string` 을 단일 케이스 판별 유니온으로 감싸고, 계산 결과에 타입 약어를 붙인다.
- 이 노트에서 남은 것은 두 개다. 마리 수가 아직 `int` 이고, 손님 식별자(`GuestId`)가 아직 없다. 마리 수는 검증이 필요하니 `private` 케이스로, 손님 식별자는 범위 제약이 없으니 그냥 감싸기만 한다.
- 검증이 두 군데로 늘어나면 `Result` 두 개를 하나로 합쳐야 한다. 여기서는 튜플 패턴으로 직접 처리한다. 오류를 모아서 한꺼번에 보고하는 방법은 8챕터의 주제다.
- 코드량은 시작할 때보다 분명히 늘었다. 얻는 것은 잘못된 값이 도메인 안으로 들어올 수 없다는 보증이다.

```fsharp id=09-final
// 이 단위가 보여주는 것: 남은 원시 타입까지 감싼 완성 형태
type ValidationError =
    | OutOfRange of string

module PetHotel =

    type GuestId = GuestId of string
    type Fee = decimal
    type DiscountRate = decimal

    type Nights = private Nights of int

    module Nights =
        // Nights -> int
        let value (Nights n) = n

        // input: int -> Result<Nights,ValidationError>
        let create input =
            if input >= 1 && input <= 30 then Ok (Nights input)
            else Error (OutOfRange "숙박 일수는 1박 이상 30박 이하여야 한다")

    type PetCount = private PetCount of int

    module PetCount =
        // PetCount -> int
        let value (PetCount n) = n

        // input: int -> Result<PetCount,ValidationError>
        let create input =
            if input >= 1 && input <= 4 then Ok (PetCount input)
            else Error (OutOfRange "한 예약에 맡길 수 있는 마리 수는 1에서 4까지다")
```

`GuestId` 는 범위 검증이 없으니 케이스를 공개해 둔다. `private` 은 검증을 강제할 필요가 있을 때만 쓰는 장치다. `Fee` 와 `DiscountRate` 는 타입 약어이므로 새 타입이 아니고, 시그니처를 읽기 좋게 만드는 역할만 한다.

```fsharp id=09-final
module Booking =

    open PetHotel

    type Reservation =
        { GuestId: GuestId
          Nights: Nights
          PetCount: PetCount }

    module Reservation =
        let nightlyRatePerPet = 35000M

        // reservation: Reservation -> PetHotel.DiscountRate
        let discountRate reservation : DiscountRate =
            if Nights.value reservation.Nights >= 7 then 0.1M else 0.0M

        // reservation: Reservation -> PetHotel.Fee
        let fee reservation : Fee =
            let nights = decimal (Nights.value reservation.Nights)
            let pets = decimal (PetCount.value reservation.PetCount)
            nights * pets * nightlyRatePerPet * (1.0M - discountRate reservation)

        // guestId: string -> nights: int -> petCount: int -> Result<Reservation,ValidationError>
        let create guestId nights petCount =
            match Nights.create nights, PetCount.create petCount with
            | Ok n, Ok p -> Ok { GuestId = GuestId guestId; Nights = n; PetCount = p }
            | Error e, _ -> Error e
            | _, Error e -> Error e
```

`create` 는 두 스마트 생성자를 호출하고 결과를 튜플로 묶어 한 번에 분해한다. 성공 케이스가 하나뿐이므로 나머지 두 줄이 실패를 받아 낸다. 반환 타입은 실측으로 `Result<Reservation,ValidationError>` 다.

```fsharp id=09-final
open PetHotel
open Booking

// guestId: string -> nights: int -> petCount: int -> Result<PetHotel.Fee,ValidationError>
let quote guestId nights petCount =
    Reservation.create guestId nights petCount
    |> Result.map Reservation.fee

printfn "%A" (quote "G-001" 3 2)   // Ok 210000.0M
printfn "%A" (quote "G-002" 7 1)   // Ok 220500.0M
printfn "%A" (quote "G-003" 0 1)   // Error (OutOfRange "숙박 일수는 1박 이상 30박 이하여야 한다")
printfn "%A" (quote "G-004" 5 9)   // Error (OutOfRange "한 예약에 맡길 수 있는 마리 수는 1에서 4까지다")
```

호출하는 쪽이 다루는 값은 `int` 와 `string` 이고, 도메인 안으로 들어가는 순간 검증된 타입으로 바뀐다. 검증 지점이 `create` 한 군데로 모이는 것이 이 구조의 이득이다.

## Using a Record Type — 레코드로도 된다 (원서 p.129)

- 같은 일을 레코드로도 할 수 있다. 필드를 하나만 둔 레코드에 `private` 을 붙이면 단일 케이스 판별 유니온과 역할이 같아진다.
- 값을 꺼낼 때 패턴 분해가 아니라 필드 접근을 쓴다는 점만 다르다. 필드 이름을 타입 이름과 같게 두는 것이 원서 표기다. 필드 이름을 `Value` 로 두어 `input.Value` 로 읽는 형태도 흔하다. 여기서는 원서 표기를 따랐다.
- 어느 쪽을 쓸지는 취향이다. F# 커뮤니티에서 더 자주 보이는 것은 단일 케이스 판별 유니온이다.

```fsharp id=09-record
// 이 단위가 보여주는 것: 레코드로 만든 같은 구조, 그리고 [<Struct>] 를 붙였을 때의 차이
type ValidationError =
    | OutOfRange of string

module Kennel =

    type Nights = private { Nights: int }

    module Nights =
        // input: Nights -> int
        let value input = input.Nights

        // input: int -> Result<Nights,ValidationError>
        let create input =
            if input >= 1 && input <= 30 then Ok { Nights = input }
            else Error (OutOfRange "숙박 일수는 1박 이상 30박 이하여야 한다")

open Kennel
printfn "%A" (Nights.create 5 |> Result.map Nights.value)   // Ok 5
```

### 보충: `[<Struct>]` 를 붙이면 (노트 보충)

- 단일 케이스 판별 유니온은 기본적으로 참조 타입이다. `int` 하나를 감싸기 위해 힙에 객체가 하나 생긴다. 값을 많이 만드는 코드에서는 이 비용이 눈에 보일 수 있다.
- `[<Struct>]` 특성을 붙이면 값 타입이 된다. 패턴 분해, 구조적 동등성, `private` 케이스가 모두 그대로 작동한다.

```fsharp id=09-record
[<Struct>]
type Weight = Weight of decimal
type Boxed = Boxed of decimal

printfn "Weight 값 타입인가: %b" (typeof<Weight>.IsValueType)   // Weight 값 타입인가: true
printfn "Boxed  값 타입인가: %b" (typeof<Boxed>.IsValueType)    // Boxed  값 타입인가: false

let (Weight kg) = Weight 4.5M
printfn "분해: %M" kg                                // 분해: 4.5
printfn "동등성: %b" (Weight 4.5M = Weight 4.5M)     // 동등성: true
```

대가가 하나 있다. 값 타입에는 항상 기본값이 있으므로, 검증을 건너뛴 값이 만들어질 틈이 생긴다. 참조 타입 쪽은 같은 자리에서 `null` 이 나오고, 값 타입 쪽은 겉보기에 정상인 값이 나온다.

```fsharp id=09-record
[<Struct>]
type StructNights = StructNights of int
type RefNights = RefNights of int

let structSlots : StructNights[] = Array.zeroCreate 1
printfn "struct 기본값: %A" structSlots[0]   // struct 기본값: StructNights 0

let refSlots : RefNights[] = Array.zeroCreate 1
printfn "ref 기본값이 null 인가: %b" (isNull (box refSlots[0]))   // ref 기본값이 null 인가: true
```

`StructNights 0` 은 `create` 를 거치지 않고 나온 값이고 검증 범위 밖이다. 두 경우 모두 정상적인 F# 코드에서는 만나지 않는 우회로이지만, `[<Struct>]` 쪽은 실패가 눈에 덜 띈다는 점을 알아 둘 만하다.

## Summary — 원서의 챕터 요약 (원서 p.129)

- 원시 타입을 줄이고 도메인 이름이 붙은 타입을 늘리면 코드가 견고해지고 읽기 좋아진다는 것이 이 챕터의 결론이다.
- 단일 케이스 판별 유니온을 쓰면 원시 타입을 그대로 쓸 때보다 담을 수 있는 값의 범위를 좁힐 수 있다.
- 원서는 타입을 확장하는 방법이 둘이라는 것도 정리한다. 멤버를 붙이는 방법과 같은 이름의 모듈에 함수를 두는 방법이다.
- 다음 챕터에서는 F# 의 객체 프로그래밍을 다룬다.

## 정리 — 이 노트의 요약

- 타입 약어는 시그니처를 읽기 좋게 만들지만 새 타입이 아니다. 원래 타입이 같으면 서로 바꿔 넣어도 통과하고 범위 검증도 없다. 이름만 필요할 때 쓰는 도구다.
- 단일 케이스 판별 유니온은 진짜 새 타입이다. `type Nights = Nights of int` 형태로 적고, 케이스가 하나라는 뜻에서 앞의 `|` 를 생략하는 것이 관례다. 원래 타입이 같은 두 값을 뒤바꿔 넣으면 오류 FS0001 이 난다.
- 값을 꺼내는 방법은 네 가지다. `let (Nights n) = nights` 로 분해, 매개변수 자리에서 `(Nights nights)` 로 분해, `member this.Value` 를 붙여 `.Value` 로 읽기, 그리고 같은 이름의 모듈에 `let value (Nights n) = n` 을 두고 `Nights.value` 로 부르기다. 매개변수 자리 분해와 모듈 함수는 시그니처가 `Nights -> int` 로 확정되어 추론이 잘 붙고, `.Value` 만 타입 주석을 요구한다.
- `.Value` 프로퍼티는 타입 추론과 잘 맞물리지 않는다. 타입 주석 없는 매개변수에 `.Value` 를 쓰면 오류 FS0072 다. 매개변수에 타입 주석을 달거나, `inline` 함수의 타입 매개변수에 `'a when 'a: (member Value: int)` 제약을 손으로 적어야 한다. 실측 시그니처는 `nights: ^a -> decimal when ^a: (member Value: int)` 다.
- 케이스 식별자에 `private` 을 붙이면 그 타입을 담은 모듈 밖에서는 값 생성과 패턴 분해가 모두 막히고, 위반하면 오류 FS1093 이다. 막히는 기준은 "모듈 밖"이므로 스크립트 최상위에 선언하면 파일 전체가 그 모듈이라 아무것도 막히지 않고, 감싸는 모듈 안의 중첩 모듈도 케이스를 그대로 본다. 타입과 스마트 생성자만 담은 모듈을 두고 쓰는 코드는 그 밖에 두어야 경계가 선다.
- 스마트 생성자는 `int -> Result<Nights,ValidationError>` 처럼 실패 가능성을 시그니처에 드러낸다. 이 관문을 지나온 값은 언제나 유효하므로, 값을 쓰는 쪽에서 범위를 다시 검사할 이유가 없다.
- 함수를 어디에 둘지는 두 갈래다. 타입 멤버로 붙이면 데이터 정의 옆에 규칙이 모이지만 데이터와 동작이 섞인다. 타입과 같은 이름의 모듈에 두면 `List`·`Option` 과 같은 구조가 되고, 정의 타입을 마지막 매개변수로 받으면 파이프라인에 그대로 얹힌다. 원서는 후자를 권한다.
- 같은 구조를 필드 하나짜리 `private` 레코드로도 만들 수 있다. 값 접근이 필드 읽기로 바뀌는 것뿐이다.
- `[<Struct>]` 를 붙이면 값 타입이 되어 힙 할당이 사라진다. 패턴 분해, 구조적 동등성, `private` 케이스는 그대로 작동한다. 대신 기본값이 존재하므로 `Array.zeroCreate` 같은 경로로 검증을 거치지 않은 값이 나올 수 있다.
- 얻는 것과 치르는 것을 견줘 보면, 코드량이 늘어나는 대신 검증 지점이 한곳으로 모이고 잘못된 값이 도메인에 들어오지 못한다. 도메인 값에 범위가 있고 그 값이 여러 곳으로 흐른다면 해 볼 만한 거래다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Setting Up — 준비 | p.118 | — |
| Solving the Problem / 1단계: 타입 약어로 시그니처에 이름 붙이기 | pp.119-120 | `09-abbrev` |
| Solving the Problem / 타입 약어가 막지 못하는 것 | p.120 | `09-abbrev` |
| Solving the Problem / 2단계: 단일 케이스 판별 유니온 | pp.120-122 | `09-singlecase` |
| Solving the Problem / 값을 꺼내는 방법 | pp.121-122 | `09-singlecase` |
| Solving the Problem / 3단계: private 케이스와 스마트 생성자 | pp.122-124 | `09-smartctor` |
| Solving the Problem / 타입 주석 없이 `.Value` 를 쓰는 방법 (노트 보충) | — | `09-smartctor` |
| Solving the Problem / 타입에 동작을 붙이면 | pp.124-125 | `09-smartctor` |
| Using Modules — 모듈로 옮기기 | pp.125-127 | `09-module` |
| A Few Minor Improvements — 남은 원시 타입 정리 | pp.127-129 | `09-final` |
| Using a Record Type — 레코드로도 된다 | p.129 | `09-record` |
| `[<Struct>]` 를 붙이면 (노트 보충) | — | `09-record` |
| Summary — 원서의 챕터 요약 | p.129 | — |
