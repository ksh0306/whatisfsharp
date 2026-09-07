# 09챕터 전문가 검수 — 단일 케이스 판별 유니온

검수 대상: `docs/ko/09-single-case-du.md` (493행, 실행 단위 6개)
환경: .NET SDK 10.0.111 / F# Interactive 14.0.111.0 (F# 10), 한국어 메시지

게이트 상태
- `verify-examples.sh` — 6개 단위 전부 PASS, 경고 0
- `check-note.sh` — OK, 금지 패턴 위반 없음
- 주석에 적은 기대 출력 21곳을 실행 결과와 대조했다. 전부 일치한다.

`id` 배정은 옳다. `id` 없는 블록 세 개(91-96행, 160-165행, 178-181행)를 따로 떼어 컴파일해
보았고 셋 다 노트에 적힌 오류 코드가 그대로 났다. `id` 를 빠뜨린 실행 가능 블록은 없다.

---

## 수정 필요 (기술 오류)

### 1. [09-single-case-du.md:41,48] 함수 타입 약어의 FSI 표시가 사실과 다르다

48행: "두 방식의 실측 시그니처가 다르게 표시된다. 앞의 `estimateFee` 는 `Nights -> PetCount -> Fee`
로 펼쳐 보이고, 뒤의 `estimateFee2` 는 `EstimateFee` 라는 이름 하나로 보인다."

FSI 는 둘을 같은 모양으로 보여 준다. 실측값이다.

```
val estimateFee: nights: Nights -> petCount: PetCount -> Fee
val estimateFee2: nights: Nights -> petCount: PetCount -> Fee
```

바인딩에 함수 타입 약어를 적어도 FSI 는 그 약어 이름을 `val` 줄에 남기지 않고 화살표 형태로
펼쳐 표시한다. `type Wrapper = { Fn : EstimateFee }` 처럼 다른 타입 정의 안에 놓았을 때만
`EstimateFee` 라는 이름이 그대로 보인다. 노트의 서술은 뒤집혀 있고, 41행 시그니처 주석
`// estimateFee2: EstimateFee` 도 실측과 어긋난다.

41행 주석을 이렇게 고쳐라.

```
// nights: Nights -> petCount: PetCount -> Fee
```

48행 단락을 이렇게 고쳐라.

> 두 방식의 실측 시그니처는 같다. FSI 는 둘 다 `nights: Nights -> petCount: PetCount -> Fee` 로
> 보여 준다. 함수 타입 전체에 붙인 약어는 `val` 줄에 이름으로 남지 않고 화살표 형태로 펼쳐진다.
> `Nights` 나 `Fee` 처럼 타입 한 개에 붙인 약어는 그 자리에 이름으로 남는다. 어느 쪽이든 약어는
> 새 타입이 아니므로 실제 타입은 둘 다 `int -> int -> decimal` 이다.

### 2. [09-single-case-du.md:233] 타입 이름과 모듈 이름이 겹치지 않는 이유가 틀렸다

233행: "타입 이름과 모듈 이름이 같아도 충돌하지 않는다. 타입과 모듈이 다른 이름 공간에 있기
때문이다."

타입과 모듈은 다른 이름 공간에 있지 않다. 모듈도 컴파일되면 타입(정적 클래스)이 되고, 같은
스코프에 같은 이름의 타입이 둘 있을 수 없다. 겹치지 않는 진짜 이유는 컴파일러가 모듈 쪽
컴파일 이름에 `Module` 을 붙여 주기 때문이다. 실측값이다.

```
PetHotel+Nights
PetHotel+NightsModule
```

75행의 "타입 이름과 케이스 식별자를 같은 이름으로 쓴다 ... 둘은 다른 이름 공간에 있어 충돌하지
않는다"는 맞는 서술이다(타입 이름과 값/패턴 이름은 실제로 다른 이름 공간이다). 233행이 그
문장의 설명을 그대로 재사용하면서 성립하지 않는 곳에 갖다 붙였다.

233행을 이렇게 고쳐라.

> - 타입 이름과 모듈 이름을 같게 두어도 컴파일 오류가 나지 않는다. 컴파일된 이름이 겹치지
>   않도록 컴파일러가 모듈 쪽에 `Module` 접미사를 붙이기 때문이다(실측: `PetHotel+Nights` 와
>   `PetHotel+NightsModule`). F# 코드에서는 둘을 같은 이름으로 쓰고, `Nights.value` 는 모듈
>   함수로, `Nights.Create` 는 타입의 정적 멤버로 각각 찾아간다.

### 3. [09-single-case-du.md:291,360,364,384] 시그니처 주석 네 곳이 FSI 실측과 다르다

이 챕터의 나머지 시그니처 주석은 모두 FSI 표시를 그대로 적었다(153행 `nights: Stay.Nights -> decimal`
처럼 모듈 이름까지 붙인 것도 실측과 일치한다). 아래 네 곳만 어긋난다. 실측값으로 맞춰라.

- 291행 `// int -> int -> Result<decimal,ValidationError>`
  → `// nights: int -> pets: int -> Result<decimal,ValidationError>`
- 360행 `// reservation: Reservation -> DiscountRate`
  → `// reservation: Reservation -> PetHotel.DiscountRate`
- 364행 `// reservation: Reservation -> Fee`
  → `// reservation: Reservation -> PetHotel.Fee`
- 384행 `// guestId: string -> nights: int -> petCount: int -> Result<Fee,ValidationError>`
  → `// guestId: string -> nights: int -> petCount: int -> Result<PetHotel.Fee,ValidationError>`

### 4. [09-single-case-du.md:235,258] "동반 모듈"은 근거가 없는 신조어다

집필자가 스스로 표시한 대로 근거가 약하다. companion module 은 영어권에서도 정착된 F# 용어가
아니고, 원서는 "a module with the same name as the type"으로 풀어 쓰며 MS ko 문서에도 이 낱말이
없다. 용어집 원칙("정착된 역어가 없으면 원어 음차를 택한다. 억지 신조어를 만들지 않는다")에 따라
새 낱말을 만들지 말고 풀어 써라. 후보 파일에 `companion module | 같은 이름의 모듈` 로 올렸다.

- 235행 "그 안에 타입과 동반 모듈을 같이 넣으면"
  → "그 안에 타입과 같은 이름의 모듈을 같이 넣으면"
- 258행 "예약 레코드와 그 동반 모듈은 새 모듈에 둔다."
  → "예약 레코드와 같은 이름의 모듈은 새 모듈에 둔다."

---

## 개선 권장

### 5. [09-single-case-du.md:167,284,472] `private` 경계에 중첩 모듈 구멍이 남아 있다

이 챕터의 성립 근거가 `private` 이 무엇을 막는가이므로, 두 개의 구멍 중 하나만 적혀 있는 것이
아깝다. 167행은 "스크립트 최상위에 선언하면 파일 전체가 그 모듈이라 아무것도 막히지 않는다"는
구멍을 정확히 짚었다(실측으로 확인했다). 그런데 감싸는 모듈을 두더라도 그 모듈 안의 중첩 모듈은
`private` 케이스를 그대로 본다. 실측했다.

```
module PetHotel =
    type Nights = private Nights of int
    module Nights =
        let create i = if i >= 1 then Ok (Nights i) else Error "bad"
    module Booking =
        let bypass = Nights 999          // 통과한다. create 를 건너뛴 값이다
```

이것이 집필자가 `Booking` 을 `PetHotel` 밖에 둔 결정의 진짜 값어치다. 284행이 지금 "`Booking` 은
`PetHotel` 밖이므로 `private` 케이스가 보이지 않고"라고만 적어 두어, 안에 뒀으면 왜 안 되는지가
드러나지 않는다. 284행 뒤에 한 문장을 더하고, 167행 뒤 `Leaky` 블록 다음에 실행 단위를 하나
붙이는 것을 권한다. 아래 블록은 `09-smartctor` 에 이어 붙여 실행되며 통과함을 확인했다.

```fsharp id=09-smartctor
// 감싸는 모듈 안의 중첩 모듈은 private 케이스를 그대로 본다
module Inner =

    type Days = private Days of int

    module Days =
        let create input =
            if input >= 1 then Ok (Days input)
            else Error (OutOfRange "1 이상이어야 한다")

    // 같은 모듈 안이므로 create 를 건너뛸 수 있다
    module Bypass =
        let skipped = Days (-999)

printfn "%A" Inner.Bypass.skipped   // Days -999
```

284행에 더할 문장.

> `Booking` 을 `PetHotel` 안에 중첩 모듈로 넣으면 `private` 케이스가 다시 보이므로 `create` 를
> 건너뛴 값을 만들 수 있다. 검증을 통제하려면 쓰는 쪽이 그 모듈 밖에 있어야 한다.

472행의 "감싸는 모듈을 반드시 둬야 한다"도 한 걸음 더 정확하게 적을 수 있다. 감싸는 모듈을
두는 것만으로는 부족하고, 그 모듈 안에 들어가는 코드를 타입과 스마트 생성자로 한정해야 한다.

> - 케이스 식별자에 `private` 을 붙이면 그 타입을 담은 모듈 밖에서는 값 생성과 패턴 분해가 모두
>   막히고, 위반하면 오류 FS1093 이다. 막히는 기준은 "모듈 밖"이므로 스크립트 최상위에 선언하면
>   파일 전체가 그 모듈이라 아무것도 막히지 않고, 감싸는 모듈 안의 중첩 모듈도 케이스를 그대로
>   본다. 타입과 스마트 생성자만 담은 모듈을 두고 쓰는 코드는 그 밖에 두어야 경계가 선다.

### 6. [09-single-case-du.md:197-200] `inline` + SRTP 블록을 요즘 문법으로 바꿔라

지금 블록은 옛 멤버 제약 호출 문법을 쓴다.

```fsharp
let inline nightlyFee nights =
    decimal (^a : (member Value : int) nights) * 35000M
```

타입 주석 자리에 제약을 적으면 본문에서 평소처럼 `.Value` 를 쓸 수 있다. 시그니처도 출력도
같다(실측: `val inline nightlyFee: nights: ^a -> decimal when ^a: (member Value: int)`, 출력
`Ok 70000M`). `--langversion:6.0` 까지 내려도 통과하므로 버전 단서를 달 필요가 없다.

```fsharp id=09-smartctor
// nights: ^a -> decimal when ^a: (member Value: int)
let inline nightlyFee (nights: 'a when 'a: (member Value: int)) =
    decimal nights.Value * 35000M

Nights.Create 2 |> Result.map nightlyFee |> printfn "%A"   // Ok 70000M
```

이 형태가 205행의 결론과도 더 잘 맞물린다. "제약을 손으로 적어야 추론이 성립한다"는 말이
`.Value` 를 그대로 쓴 코드에서 눈에 보이기 때문이다. 471행의 요약에 적힌 `^a : (member Value : int)`
표기도 같이 손대는 것이 좋다.

### 7. [09-single-case-du.md:176-183] FS0072 가 나는 이유를 한 문장으로 적어라

원서가 "the compiler is unable to determine the type"이라고만 하고 넘어가는 대목이다. 176행은
"컴파일러는 `nights` 가 어떤 타입인지 모르므로 멤버 조회를 확정할 수 없다"까지 갔는데, 왜
모르는 채로 놔두는지가 빠져 있다. `inline` 보충 절이 사실 그 답이므로 183행 끝에 한 문장을
붙여 두면 두 절이 이어진다.

> 일반 함수는 구체 타입 하나로 컴파일되어야 하므로 컴파일러가 멤버 이름만 보고 타입을 거꾸로
> 찾아 주지 않는다. 타입 변수에 멤버 제약을 걸 수 있는 것은 호출 지점마다 코드를 새로 만드는
> `inline` 함수뿐이다.

### 8. [09-single-case-du.md:141] `Value` 멤버를 관용적인 형태로 써라

```fsharp
member this.Value = this |> fun (Nights n) -> n
```

원서 p.122 표기 그대로다. `|>` 로 자기 자신을 람다에 흘려보내는 우회로이고, 하는 일은 케이스
하나짜리 패턴 매칭이다. 아래가 짧고 뜻이 바로 읽히며, 107행에서 가르친 패턴 분해와도 이어진다.
경고 없이 컴파일되고 시그니처도 `member Value: int` 로 같다(실측).

```fsharp
member this.Value = match this with Nights n -> n
```

`docs/ko/_pipeline/STYLE.md` 가 원서 코드를 그대로 옮기지 말라고 못을 박은 것도 이 자리에 걸린다.

### 9. [09-single-case-du.md:428] 구조체 판별 유니온의 필드 이름 서술이 낡았다

"`[<Struct>]` 특성을 붙이면 값 타입이 된다. 케이스가 하나면 필드 이름을 따로 붙이지 않아도 되고 ..."

"케이스가 하나면"이라는 조건절이 "케이스가 둘 이상이면 붙여야 한다"는 뜻을 함축한다. 그 제약
(오류 FS3204)은 F# 9 에서 없어졌다. 실측했다.

```
--langversion:6.0 / 7.0 / 8.0 → error FS3204: 다중 사례 공용 구조체 형식이 구조체인 경우 모든 공용 구조체 사례의 이름이 고유해야 합니다.
--langversion:9.0 / preview  → 통과
```

다중 케이스 구조체 판별 유니온을 이 챕터에서 다루지 않기로 한 판단은 옳다. 챕터 주제가 단일
케이스이고, 버전별 제약 이력까지 끌고 들어오면 보충 절이 본론보다 커진다. 다만 지금 문장은
빼기로 한 그 이야기를 함축으로 남겨 두었으니 조건절을 지워라.

> - `[<Struct>]` 특성을 붙이면 값 타입이 된다. 패턴 분해, 구조적 동등성, `private` 케이스가 모두
>   그대로 작동한다.

(457행이 이미 "`private` 케이스와 `[<Struct>]` 는 함께 쓸 수 있다"고 적어 두었으므로 겹치면
457행 쪽을 줄여도 된다. `[<Struct>]` + `private` + 모듈 함수 조합이 실제로 작동하고 밖에서는
FS1093 이 나는 것을 확인했다.)

### 10. [09-single-case-du.md:128] "남는 유일한 생성 경로"가 지나치게 강하다

"케이스 식별자에 `private` 을 붙이면 ... 남는 유일한 생성 경로가 타입에 붙인 정적 멤버다."

정적 멤버가 유일한 경로는 아니다. 그 모듈 안의 코드는 무엇이든 값을 만들 수 있고, 230행부터의
절이 바로 모듈 함수라는 다른 경로를 보여 준다. 3단계에서 정적 멤버를 고른 것은 선택이다.

> - 케이스 식별자에 `private` 을 붙이면 그 타입을 담은 모듈 밖에서는 값을 만들 수도 분해할 수도
>   없다. 남는 생성 경로는 그 모듈 안에 둔 코드뿐이다. 여기서는 타입에 붙인 정적 멤버를 그
>   경로로 쓴다. 이것이 스마트 생성자다.

### 11. [09-single-case-du.md:129] 3챕터 서술보다 강하게 적혀 있다

"실패가 시그니처에 드러나므로 호출한 쪽이 처리를 빠뜨릴 수 없다."

컴파일러가 강제하지는 않는다. `Nights.create 3 |> ignore` 는 아무 말 없이 통과한다. 3챕터는
같은 대목을 "실패 종류가 타입에 적히므로 `match` 식에서 빠뜨린 케이스를 컴파일러가 잡아 준다"로
적어 두었다(`03-null-and-exceptions.md:444`). 3챕터 쪽 세기에 맞춰라.

> - 검증에 실패했을 때 예외를 던지는 대신 `Result` 로 돌려준다. 실패 가능성이 반환 타입에
>   드러나므로 값을 쓰려면 `Ok` 와 `Error` 를 갈라 처리해야 한다. 예외처럼 시그니처에 안 보이는
>   채로 흐르지 않는다. `Result` 는 3챕터에서 다뤘다.

### 12. [09-single-case-du.md 절 전체] 감싸는 모듈 이름이 단위마다 다르다

`09-smartctor` 는 `Stay`, `09-module`·`09-final` 은 `PetHotel`, `09-record` 는 `Kennel` 이다.
세 실행 단위가 각각 독립 스크립트라 이름이 겹쳐도 FS0037 이 나지 않으니 통일할 수 있다.
3단계 → 모듈로 옮기기 → 남은 원시 타입 정리는 같은 코드가 자라나는 흐름이므로 `Stay` 를
`PetHotel` 로 바꿔 세 단위가 같은 모듈 이름을 쓰게 하는 편이 읽기 쉽다. 레코드 절의 `Kennel` 은
"다른 방법"이라는 신호이므로 남겨도 된다.

### 13. [09-single-case-du.md:105,470] "값을 꺼내는 방법 세 가지"와 네 번째가 어긋난다

105행과 470행이 세 가지(`let` 분해 / 매개변수 자리 분해 / `.Value` 프로퍼티)로 못을 박는데,
256행부터 모듈 함수 `Nights.value` 를 넷째 방법으로 쓰고 그것을 가장 편한 방법으로 결론 낸다.
470행에 한 마디를 더해 매듭을 지어라.

> - 값을 꺼내는 방법은 네 가지다. `let (Nights n) = nights` 로 분해, 매개변수 자리에서
>   `(Nights nights)` 로 분해, `member this.Value` 를 붙여 `.Value` 로 읽기, 그리고 같은 이름의
>   모듈에 `let value (Nights n) = n` 을 두고 `Nights.value` 로 부르기다. 뒤의 두 방법 중
>   모듈 함수 쪽만 시그니처가 `Nights -> int` 로 확정되어 추론이 잘 붙는다.

470행이 지금 예시 변수명을 `value` 로 쓴 것(`let (Nights n) = value`)도 모듈 함수 `value` 와
글자가 겹치니 위처럼 `nights` 로 바꿔라.

### 14. [09-single-case-du.md:400] 레코드 필드 이름을 `Value` 로 두는 관례를 덧붙여라

"필드 이름을 타입 이름과 같게 두는 것이 원서 표기다"는 정확한 서술이다. 다만 `input.Nights` 는
읽는 사람에게 타입 이름인지 필드 이름인지 흔들린다. 실무에서 더 흔한 것은 필드 이름을 `Value` 로
두는 쪽이다. 한 문장 덧붙이면 원서 대조와 관용을 함께 얻는다.

> 필드 이름을 `Value` 로 두어 `input.Value` 로 읽는 형태도 흔하다. 여기서는 원서 표기를 따랐다.

### 15. [09-single-case-du.md:451,454] 배열 인덱스를 요즘 문법으로 써라

`structSlots.[0]` / `refSlots.[0]` 은 F# 6 이후 권장 형태가 아니다. `structSlots[0]` /
`refSlots[0]` 으로 써라. `docs/ko/` 안에서 `.[` 를 쓴 곳은 이 두 줄뿐이다(8챕터 두 곳은 정규식
문자열 안이라 무관하다).

### 16. [09-single-case-du.md:57-67] 통과해서는 안 될 값을 만들고 찍지 않는다

59행 주석은 "있을 수 없는 값도 통과한다"인데 `absurd` 를 출력하지 않는다. 통과한다는 사실이
출력으로 보이지 않으면 주석만 남는다. 한 줄 더해라.

```fsharp
printfn "있을 수 없는 예약: %A" absurd   // 있을 수 없는 예약: { Nights = -5
                                        //   PetCount = 400 }
```

### 17. [09-single-case-du.md] 원서 p.126 오기를 노트에 남겨라

집필자의 판단이 맞다. 원서 p.126 코드 블록의 `Spend.Value spend` 는 그 시점에 성립하지 않는
표기다. 그 시점 `Spend` 에는 인스턴스 프로퍼티 `Value` 만 있고 `Spend` 모듈이 아직 없어서,
`Spend.Value spend` 는 컴파일되지 않는다. 실측 오류다.

```
error FS0806: 'Value'은(는) 정적 속성이 아닙니다.
```

같은 블록 안의 `calculateTotal` 이 `spend.Value` 를 쓰고 있으므로 자기모순이기도 하다. 모듈로
옮긴 p.127 에서 소문자 `Spend.value spend` 가 되는 것도 확인했다. 3챕터(`p.45 의 Some 1M`)와
6챕터·10챕터(`IDisposable<'T>`)가 이미 원서 오기를 한 줄로 남기는 선례를 만들어 두었으니 같은
형식으로 적어라. 230행 절의 불릿 자리가 알맞다.

> - 원서 p.126 의 `Spend.Value spend` 는 오기다. 그 시점 `Spend` 에는 인스턴스 프로퍼티만 있고
>   같은 이름의 모듈이 아직 없으므로 `spend.Value` 여야 한다(그대로 적으면 오류 FS0806). 모듈로
>   옮긴 p.127 부터는 소문자 `Spend.value spend` 다.

### 18. [09-single-case-du.md:193,425] 보충 절 꼬리말 표기

`(원서에 없음)` 은 9챕터만 쓰는 표기다. 10챕터는 `(노트 보충)`, 11챕터는 `(원서에 없는 보충)` 을
쓴다. 후보 파일의 "표기 조정 필요" 항목에 올려 두었다. 병합에서 정해지는 표기를 따르면 된다.

---

## 확인 완료

집필자가 실측으로 보고한 다섯 항목을 전부 재현했다. 다섯 개 모두 맞다.

- `private` 케이스 위반은 값 생성과 패턴 분해가 같은 번호 FS1093 이다. 둘을 따로 떼어
  컴파일해 각각 확인했다. 메시지도 노트 인용문과 글자까지 같다.
- 주석 없는 `.Value` 는 FS0072 다. 인용한 메시지 첫 문장도 실제 출력과 같다.
- `inline` + SRTP 시그니처는 `val inline nightlyFee: nights: ^a -> decimal when ^a: (member Value: int)`.
- `[<Struct>]` 를 붙이면 `typeof<_>.IsValueType` 이 `true` 다. 패턴 분해, 구조적 동등성,
  `private` 케이스가 모두 그대로 작동한다(`private` + `[<Struct>]` 조합도 밖에서 FS1093 이다).
- `[<Struct>]` 의 대가도 그대로다. `Array.zeroCreate 1` 이 구조체 쪽에서는 `StructNights 0` 을,
  참조 쪽에서는 `null` 을 만든다. 참조 쪽은 `Unchecked.defaultof` 도 같은 결과다.

특히 확인을 요청한 두 가지.

- 스크립트 최상위 선언에서 `private` 이 같은 파일 안의 코드를 막지 못한다는 서술은 정확하다.
  `type Leaky = private Leaky of int` 다음 줄의 `Leaky 99` 가 그대로 통과한다. 원서가 언급하지
  않는 함정이고, 감싸는 모듈이 필요하다는 결론도 맞다. 다만 감싸는 모듈만으로는 부족하다
  — 항목 5 를 보라.
- `inline` 만 붙여도 `.Value` 는 여전히 FS0072 라는 서술도 정확하다. 오류 위치만 한 칸
  옮겨갈 뿐 번호와 메시지가 같다.

구조 판단에 대한 의견.

- `PetHotel`(원시 타입 래퍼)과 `Booking`(예약 레코드)로 가른 결정은 타당하고, 내가 준 두 안보다
  낫다. FS0037 은 실측으로 확인했고(`형식, 예외 또는 모듈입니다. 'PetHotel'의 정의가 중복되었습니다.`),
  선언을 첫 블록에 몰면 뒤 블록이 모듈 헤더 없는 들여쓰기 덩어리가 되어 문서에서 독립적으로
  읽히지 않는다는 근거도 맞다. 무엇보다 `Booking` 이 `PetHotel` 밖에 있어야 `private` 경계가
  실제로 서기 때문에(중첩 모듈은 케이스를 본다) 이 배치는 부수 효과가 아니라 이 절이 가르쳐야
  할 내용 그 자체다. 항목 5 로 그 사실을 본문에 드러내라는 것만 더한다.
- 두 모듈 구성의 학습 흐름도 자연스럽다. `PetHotel` 이 값 타입을, `Booking` 이 그 값을 조립한
  레코드와 계산을 담는 층 구분이 보인다. 이름만 아쉽다 — 도메인 전체 이름(`PetHotel`)과 그 안의
  개념(`Booking`)이 형제 모듈로 나란히 놓여 층위가 어긋나 보인다. 이름을 손댈 거면
  `PetHotel`/`Booking` 보다 `PetHotel`/`Reservations` 나 `Domain`/`Booking` 이 층위가 맞는다.
  다만 지금 이름으로도 오해가 생기지는 않으니 강하게 권하지 않는다.

원서 오기 판단.

- p.126 의 `Spend.Value spend` 가 오기라는 판단이 맞다(항목 17 에 실측 근거를 적었다).
- 원서가 `private` 을 "the private accessor"라 부르는 것을 "접근 지정자"로 바꿔 적은 것도
  옳은 판단이다. F# 에서 accessor 는 프로퍼티의 get/set 을 가리키므로 원서 표기를 옮기면
  10챕터의 프로퍼티 설명과 충돌한다.
- 원서가 케이스 식별자를 "the type constructor"라 부르는 것을 옮기지 않고 "케이스 식별자"로
  쓴 것도 옳다. 함수형 일반 용어의 type constructor 는 다른 것을 가리킨다.

정확하다고 확인한 개념.

- 타입 약어는 새 타입이 아니라 별명이다. 기반 타입이 같으면 서로 바꿔 넣어도 통과하고 범위
  검증도 없다는 서술과 실행 예제가 맞다.
- 단일 케이스 판별 유니온끼리 뒤바꿔 넣으면 FS0001 이고, 인용한 메시지가 실제 출력과 같다.
- 케이스가 하나뿐인 판별 유니온의 `let (Nights n) = x` 분해가 빠짐없는 패턴이라 FS0025 경고가
  나지 않는다는 서술이 맞다(다중 케이스라면 경고가 난다).
- 매개변수 자리 분해가 `Nights -> PetCount -> Fee` 로 실측되고, 모듈 함수 `value` 가
  `Nights -> int` 로 확정된다는 것도 맞다. 프로퍼티 방식과 갈리는 지점을 정확히 짚었다.
- 스마트 생성자 두 형태의 장단 서술이 맞다. 정적 멤버 쪽은 데이터 정의 옆에 규칙이 모이지만
  `.Value` 가 추론과 맞물리지 않고(FS0072), 모듈 함수 쪽은 시그니처가 확정되어 주석이 필요
  없으며 마지막 매개변수 관례로 파이프라인에 얹힌다. `List`/`Option`/`Result` 가 모두 이
  구조라는 것도 맞다.
- 3챕터 `Result` 와의 맞물림에 서술 충돌이 없다. 성공 케이스에만 값이 실리므로 관문을 지난
  값이 언제나 유효하다는 논지, `Result.map` 으로 파이프라인에 얹는 방식이 3챕터와 일관된다.
  세기 차이 하나만 항목 11 로 지적했다.
- 09-final 의 `create` 가 두 `Result` 를 튜플로 묶어 한 번에 분해하는 형태는 빠짐없는 매칭이고
  경고 없이 컴파일된다. 오류 누적을 8챕터로 넘긴 구분도 맞다.
- 필드 하나짜리 `private` 레코드가 단일 케이스 판별 유니온과 같은 역할을 한다는 서술이 맞다.
  밖에서 레코드 식으로 만드는 것과 필드를 읽는 것이 모두 FS1093 이다.
- `1.0M` 을 곱해 자릿수가 하나 붙어 `220500.0M` 으로 표시된다는 설명이 맞다. `decimal` 곱셈이
  두 자릿수를 더하기 때문이다.
- 1챕터(`01-domain-modelling.md:374` — `DriverId` 가 아직 `string`, 9챕터로 넘긴다)와 앞뒤가
  맞는다. 1챕터 46행이 "진짜 다른 타입을 만드는 방법은 9챕터에서 다룬다"고 예고한 것도 이
  챕터가 받아 준다.
- 기확정 용어 표기를 모두 지켰다. 특히 용어집 `single-case active pattern` 행이 예고한
  "단일 케이스 한 낱말로 줄이지 않는다" 규칙이 11곳 전부에서 지켜졌다.
