# 01챕터 F# 기술 검수 보고서 (후보 모드)

대상: `docs/ko/01-domain-modelling.md`
원문: `.cache/src/01-domain-modelling.txt` (원서 pp.8-25)
검증 환경: F# Interactive 14.0.111.0 (F# 10.0)
실행 단위 6개(`01-record-fee`, `01-du-explicit`, `01-du-eligible`, `01-du-flat`,
`01-du-in-record`, `01-du-named-fields`) 전부 PASS, 경고 0.

보고서에 적은 모든 판정은 FSI 로 직접 돌려 확인했다. 추측으로 쓴 항목은 없다.

---

## 수정 필요 (기술 오류)

### 1. [01-domain-modelling.md:124] "화살표가 둘 이상이면 커링된 매개변수다" 는 성립하지 않는다

현재 문장:

> 시그니처에 화살표가 둘 이상이면 커링된 매개변수다.

원서 p.12 의 "If a function signature has more than one arrow, then you have curried parameters"
를 그대로 옮긴 것이고, 원서 쪽이 틀렸다. 방향이 한쪽만 성립한다.
커링된 매개변수로 정의하면 화살표가 여럿 생기지만, 화살표가 여럿이라고 커링된 매개변수인 것은 아니다.

FSI 실측 반례 두 가지.

```
> let g (a: int, b: int) (c: int) = a + b + c
val g: a: int * b: int -> c: int -> int      // 화살표 2개인데 첫 매개변수는 튜플 매개변수다

> let f (x: int) = fun (y: int) -> x + y
val f: x: int -> y: int -> int               // 매개변수는 하나뿐이고 반환값이 함수다
```

이 문장은 2챕터 전체(커링 대 부분 적용)가 그 위에 쌓이는 자리라 그대로 두면 파급이 크다.
`GLOSSARY.md` 의 `partial application` 항목이 이미 같은 종류의 혼동을 경계하고 있다.

교체 문장:

> 매개변수를 `(driver: Driver) (kwh: decimal)` 처럼 나란히 적은 형태를 커링된 매개변수(curried parameters)라 한다. 커링된 매개변수로 정의하면 시그니처에 매개변수 개수만큼 화살표가 생긴다. 다만 화살표 개수만 보고 거꾸로 판정할 수는 없다. 튜플 매개변수 하나를 받고 함수를 반환하는 함수도 화살표가 둘이다. 정의 쪽을 봐야 구분이 된다. 튜플 하나로 묶어 받는 튜플 매개변수(tupled parameter) 형태로도 쓸 수 있다.

### 2. [01-domain-modelling.md:321] 구조가 같은 레코드 타입에서 컴파일러는 "못 고르는" 것이 아니라 조용히 고른다

현재 문장:

> `PlanHolder` 와 `Visitor` 는 구조가 똑같다. 이런 경우 `{ DriverId = "yujin" }` 만 놓으면 컴파일러가 어느 타입인지 못 고른다.

틀렸다. F# 은 라벨 집합이 같은 레코드 타입이 여럿 보일 때 가장 나중에 선언된 타입을 고른다.
오류도 경고도 나지 않는다. FSI 실측.

```
> type PlanHolder = { DriverId: string }
> type Visitor = { DriverId: string }
> let v = { DriverId = "yujin" }
val v: Visitor = { DriverId = "yujin" }      // 경고 없이 마지막 선언 타입으로 정해진다
```

실제 위험은 "못 고르는 것"이 아니라 "원하지 않은 쪽을 조용히 골라 버리는 것"이다.
오류는 그 값을 쓰는 자리에서 뒤늦게 난다.

```
> let d = ActivePlan v
error FS0001: 이 식에는 PlanHolder 형식이 필요하지만 Visitor 형식이 지정되었습니다
```

교체 문장:

> `PlanHolder` 와 `Visitor` 는 구조가 똑같다. 이럴 때 `{ DriverId = "yujin" }` 만 놓으면 컴파일러는 오류를 내지 않고 가장 나중에 선언된 타입, 곧 `Visitor` 를 고른다. 원한 타입이 아니었다면 그 자리에서는 조용히 넘어가고, 그 값을 쓰는 자리에서 타입이 안 맞는다는 오류가 뒤늦게 난다. 반면 케이스 식별자 뒤에 놓으면 그 케이스가 요구하는 타입이 정해져 있어 이런 일이 없다.

### 3. [01-domain-modelling.md:93] 같은 오류의 짝. "추론이 갈리므로" 를 정확히 고쳐라

현재 문장:

> 단, 구조가 똑같은 레코드 타입이 여럿 정의돼 있으면 추론이 갈리므로 그때는 타입 주석이 필요하다.

원서 p.10 의 "the compiler will not be able to infer the type" 를 옮긴 것이고 역시 틀렸다.
추론은 갈리지 않는다. 마지막 선언 타입으로 확정된다.

교체 문장:

> 단, 구조가 똑같은 레코드 타입이 여럿 정의돼 있으면 컴파일러는 가장 나중에 선언된 타입을 고른다. 다른 쪽을 원한다면 타입 주석을 붙여야 한다.

### 4. [01-domain-modelling.md:77] 불변성과 "모든 필드를 채워야 한다" 사이에 인과가 없다

현재 문장:

> 레코드는 불변이라 만든 뒤에 바꿀 수 없다. 그래서 인스턴스를 만들 때 모든 필드를 채워야 한다.

두 군데가 부정확하다. 불변성의 범위를 처음 말하는 자리라 그냥 두면 뒤 챕터까지 끌고 간다.

(a) 레코드 필드는 기본이 불변이지만 `mutable` 을 붙일 수 있다. 예외 없는 규칙이 아니다.
(b) 인과가 성립하지 않는다. `mutable` 필드가 있어도 레코드 식은 여전히 모든 필드를 채워야 한다.
필드를 다 채워야 하는 이유는 불변성이 아니라 레코드 식 자체의 규칙이다. FSI 실측.

```
> type Counter = { Name: string; mutable Hits: int }
> let c = { Name = "a"; Hits = 0 }    // mutable 필드가 있어도 Hits 를 생략할 수 없다
> c.Hits <- 5                          // 이건 된다
> printfn "%A" c
{ Name = "a"
  Hits = 5 }
```

교체 문장:

> 레코드 식은 필드를 하나도 빠뜨릴 수 없다. 인스턴스를 만들 때 모든 필드를 채워야 한다. 그리고 레코드 필드는 기본이 불변이라 만든 뒤에는 값을 바꿀 수 없다. 필드에 `mutable` 을 붙이면 예외를 만들 수 있지만 이 노트에서는 쓰지 않는다.

---

## 개선 권장

### 5. [01-domain-modelling.md:127, 136] `(Driver * decimal) -> decimal` 은 FSI 출력이 아니다

FSI 는 괄호 없이 출력한다.

```
> let chargeFeeTupled (driver: Driver, kwh: decimal) : decimal = kwh
val chargeFeeTupled: driver: Driver * kwh: decimal -> decimal
```

`*` 가 `->` 보다 강하게 묶이므로 뜻은 같고, 괄호가 틀린 것은 아니다. 원서 p.12 도 괄호를 쓴다.
다만 STYLE.md 는 시그니처 주석을 FSI 실측값으로 적으라고 하니 둘 중 하나를 골라라.

- 괄호를 유지하려면 136행 문장에 한 줄을 덧붙인다.
  "FSI 는 `Driver * decimal -> decimal` 로 괄호 없이 출력한다. `*` 가 `->` 보다 강하게 묶이므로 같은 뜻이고, 이 노트는 튜플 매개변수가 하나임을 눈에 띄게 하려고 괄호를 남겨 둔다."
- 아니면 127행과 136행의 괄호를 빼고 `Driver * decimal -> decimal` 로 통일한다.

### 6. [01-domain-modelling.md:173-181] `mutable` 은 바인딩을 가변으로 만드는 것이지 데이터를 가변으로 만드는 것이 아니다

1챕터가 불변성을 처음 말하는 자리이므로 이 구분을 한 줄 넣어 두는 편이 좋다.
`let mutable` 은 그 이름에 다른 값을 다시 대입할 수 있게 해 줄 뿐, 담긴 레코드의 필드는 그대로 불변이다.
FSI 실측.

```
> type D = { Id: string; Active: bool }
> let mutable d = { Id = "a"; Active = true }
> d <- { Id = "b"; Active = false }    // 바인딩 재대입은 된다
> d.Active <- true
error FS0005: 이 필드는 변경할 수 없습니다.
```

181행 블록 뒤에 추가할 문장:

> `mutable` 은 그 이름에 다른 값을 다시 대입할 수 있게 해 주는 것이지, 담긴 데이터를 가변으로 만드는 것이 아니다. `mutable` 로 묶은 이름이 레코드를 담고 있어도 그 레코드의 필드는 여전히 바꿀 수 없다.

### 7. [01-domain-modelling.md:254-259] FS0025 는 경고이지 오류가 아니다

노트는 "경고 FS0025 가 난다"까지만 적는다. 경고 번호는 정확하다. 다만 경고에 그친다는 사실,
곧 코드가 컴파일되고 실행 시점에 터진다는 점이 빠져 있다. 3챕터(예외)와 이어지는 지점이다.
FSI 실측: 빠뜨린 케이스가 들어오면 `Microsoft.FSharp.Core.MatchFailureException` 이 난다.

259행 블록 뒤에 추가할 문장:

> FS0025 는 오류가 아니라 경고다. 그래서 코드는 그대로 컴파일되고, 빠뜨린 케이스에 해당하는 값이 실제로 들어오면 실행 시점에 `MatchFailureException` 이 난다. 경고를 무시하면 컴파일러가 잡아 준 문제가 런타임으로 미뤄질 뿐이다.

### 8. [01-domain-modelling.md:261] `when` 가드가 빠짐없음 검사에 잡히지 않는다는 것을 명시하라

현재 문장은 "대신 요금제가 만료된 가입자를 처리하는 케이스를 따로 적어 줘야 모든 경우가 채워진다"로
결과만 말한다. 이유를 적어야 독자가 규칙을 일반화할 수 있다. 컴파일러는 가드의 참/거짓을 계산하지 않고,
가드가 붙은 케이스는 그 케이스를 다 덮지 못한 것으로 본다. FSI 실측: 케이스가 전부 적혀 있어도 경고가 난다.

```
> match d with
  | Subscribed h when h -> 1
  | Walkup -> 0
warning FS0025: 이 식의 패턴 일치가 완전하지 않습니다.
```

교체 문장:

> 중첩된 `if` 는 가드 절(guard clause)인 `when` 으로 펼 수 있다. 단, 컴파일러는 가드의 참/거짓을 계산하지 않는다. 가드가 붙은 케이스는 그 케이스를 다 덮지 못한 것으로 보므로, 요금제가 만료된 가입자를 처리하는 케이스를 따로 적어 줘야 모든 경우가 채워진다.

### 9. [01-domain-modelling.md:52-56] 튜플의 이름 없음을 지적하는 자리인데 예제 값이 그 문제를 드러내지 않는다

58행은 "두 `bool` 중 어느 쪽이 가입 여부이고 어느 쪽이 유효 여부인지 알 방법이 없다"고 하는데,
`rawYujin` 은 두 `bool` 이 모두 `true` 라 순서를 뒤집어도 출력이 같다. 논지가 코드로 보이지 않는다.
값이 갈리는 운전자를 쓰면 논지가 산다. 52-56행 블록 교체안.

```fsharp id=01-record-fee
// 튜플을 세 이름으로 분해한다
let rawSoyeon: RawDriver = ("soyeon", true, false)
let (rawId, rawSubscribed, rawPlanActive) = rawSoyeon
printfn "%s / 가입=%b / 유효=%b" rawId rawSubscribed rawPlanActive   // 기대: soyeon / 가입=true / 유효=false

printfn "%A" rawTaeho   // 기대: ("taeho", false, false)
```

이어질 설명 문장:

> 두 번째와 세 번째 이름을 뒤집어 `let (rawId, rawPlanActive, rawSubscribed) = rawSoyeon` 으로 묶어도 컴파일은 그대로 된다. `string * bool * bool` 어디에도 어느 쪽이 가입 여부인지 적혀 있지 않으니 컴파일러가 막아 줄 근거가 없다. 뜻이 뒤집힌 값을 그대로 쓰게 된다.

### 10. [01-domain-modelling.md:183-193] 구조적 동등성이 이 챕터에 이름으로 등장하지 않는다

`areEqual` 의 제약이 `when 'a : equality` 라는 것까지 적어 놓고, 레코드와 판별 유니온이
그 제약을 어떻게 만족하는지는 다루지 않는다. 독자가 `=` 를 참조 비교로 오해할 여지가 남는다.
`GLOSSARY.md` 에 `structural equality`(구조적 동등성)가 이미 등재돼 있으니 여기서 첫 등장시키면 된다.
FSI 실측으로 세 경우 모두 `true` 다.

193행 뒤에 추가할 블록과 설명.

```fsharp id=01-record-fee
// 레코드와 판별 유니온은 구조적 동등성이 기본으로 붙는다
let sameSoyeon = { DriverId = "soyeon"; IsSubscribed = true; IsPlanActive = false }
printfn "%b" (sameSoyeon = soyeon)                        // 기대: true
printfn "%b" (areEqual sameSoyeon soyeon)                 // 기대: true
```

> 따로 만든 두 레코드인데도 `=` 가 참이다. 레코드와 판별 유니온에는 구조적 동등성(structural equality)이 기본으로 붙어서, 담긴 값이 같으면 같은 값으로 본다. `areEqual` 이 `'a : equality` 하나만 요구하고도 도메인 타입에 그대로 쓸 수 있는 이유가 이것이다.

### 11. [01-domain-modelling.md:446-451] "튜플이 아니다" 의 범위를 좁혀 적어라

노트의 서술은 정확하다. 패턴에서는 다중 필드 케이스 데이터를 튜플 하나로 받을 수 없다.

```
> let f s = match s with | S t -> fst t | W -> "w"
error FS0727: 이 공용 구조체 사례에는 튜플 형식의 2 인수가 필요하지만 1이(가) 제공되었습니다.
```

다만 케이스 생성자를 값으로 쓰면 FSI 가 튜플 모양 시그니처를 주고 실제 튜플 값도 받아 준다.

```
> type D2 = | S of string * bool | W
> let ctor = S
val ctor: Item1: string * Item2: bool -> D2
> let t = ("b", false)
> printfn "%A" (S t)
S ("b", false)
```

직접 눌러 보는 독자가 걸릴 수 있는 지점이다. 451행 주석과 446행 문장을
"패턴에서 튜플 하나로 받을 수 없다"로 범위를 좁혀 적는 편이 안전하다.

> 판별 유니온의 케이스 데이터는 튜플처럼 `*` 로 이어 쓰지만 튜플이 아니다. 컴파일된 뒤에도 필드가 따로 놓이고, 패턴에서 `Subscribed t` 처럼 튜플 하나로 받으려 하면 오류가 난다. 그리고 튜플과 달리 각 부분에 이름을 붙일 수 있다.

### 12. [01-domain-modelling.md:117] 클래스 껍데기가 없는 이유와 일급 함수는 별개다

현재 문장:

> 함수를 담을 클래스 같은 껍데기가 없다. F# 에서 함수는 일급 함수(first-class function)여서 값과 똑같이 다뤄진다.

원서 p.12 의 인과를 그대로 옮겼는데 두 사실이 이어지지 않는다.
껍데기가 필요 없는 직접적인 이유는 F# 이 모듈과 스크립트 최상위에 `let` 을 놓을 수 있게 하기 때문이다.
컴파일되면 모듈에 대응하는 정적 클래스의 멤버가 된다. 일급 함수는 별개의 사실이다.
두 불릿으로 쪼개 적어라.

> - 함수를 담을 클래스 같은 껍데기를 적지 않는다. 모듈이나 스크립트 최상위에 `let` 을 그대로 놓을 수 있다.
> - F# 에서 함수는 일급 함수(first-class function)여서 값과 똑같이 다뤄진다. 다른 함수에 넘길 수도 있고 반환받을 수도 있다.

### 13. [01-domain-modelling.md:37] `type RawDriver = string * bool * bool` 은 타입 약어라는 것을 이름 붙여 두라

현재 주석은 "튜플 타입"이라고만 적혀 있어, 독자가 새 타입이 하나 생겼다고 읽을 수 있다.
이것은 타입 약어(type abbreviation)라서 새 타입이 아니고 별명이다. `RawDriver` 와
`string * bool * bool` 은 서로 완전히 호환된다. 9챕터의 단일 케이스 판별 유니온이
바로 이 한계를 넘는 장치이므로, 여기서 이름을 붙여 두면 대비가 선다.

주석과 뒤따르는 문장 보강안.

```fsharp
// 타입 약어: string 하나와 bool 두 개를 묶은 AND 타입에 RawDriver 라는 별명을 붙인다
type RawDriver = string * bool * bool
```

> `type RawDriver = ...` 는 새 타입을 만드는 것이 아니라 타입 약어(type abbreviation), 곧 별명을 붙이는 것이다. `RawDriver` 를 요구하는 자리에 `string * bool * bool` 을 그대로 넣을 수 있고 그 반대도 된다. 별명이 아니라 진짜 다른 타입을 만드는 방법은 9챕터에서 다룬다.

### 14. [01-domain-modelling.md:158, 172] 절 제목의 "세 가지 얼굴"이 문서 뒤쪽과 어긋난다

172행은 `=` 의 용도를 바인딩, 레코드 필드 값 지정, 동등성 비교 셋으로 못 박는다.
그런데 415행과 456행에서 `Subscribed (IsPlanActive = true)` 로 케이스 데이터 필드를 지정하는
네 번째 용도가 나온다. 같은 문서 안에서 어긋난다.

두 가지 중 하나를 택하라.

- 172행을 "바인딩, 필드 값 지정, 동등성 비교" 로 넓히고(레코드에 한정하지 않는다) 절 제목도
  "`=` 의 여러 얼굴" 로 바꾼다.
- 412행 근처에 연결 문장을 넣는다. "여기의 `=` 는 앞 절에서 본 필드 값 지정 쪽이다. 비교가 아니다."

### 15. [01-domain-modelling.md:552-566] Scala 스케치가 `Double` 을 쓴다

111행에서 "금액 계산에는 부동소수점보다 `decimal` 이 맞다"고 못 박은 뒤라 대비가 어색하다.
원서 p.25 의 Scala 코드도 `Double` 을 쓰므로 그대로 옮긴 것은 사실에 맞다.
`BigDecimal` 로 바꾸거나, 앞 문장에 "원서에 실린 Scala 코드가 `Double` 을 쓰므로 그대로 두었다"는
한마디를 달아 111행과 부딪히지 않게 하라.

---

## 확인 완료

집필자가 실측했다고 보고한 것을 모두 재확인했다. 세 건 다 맞다.

- `areEqual : 'a -> 'a -> bool  (when 'a : equality)` — FSI 출력 `val areEqual: expected: 'a -> actual: 'a -> bool when 'a: equality`.
  `comparison` 이 아니라 `equality` 가 맞다. 본문이 `=` 만 쓰고 `<`/`>` 를 쓰지 않으므로 순서 비교 제약이 붙을 이유가 없다.
- `(|OnActivePlan|_|) : Driver -> unit option` — FSI 출력 `val (|OnActivePlan|_|) : driver: Driver -> unit option`. 일치.
  `| OnActivePlan when kwh >= 25.0M ->` 처럼 인자 없이 패턴 자리에 쓰는 것도 경고 없이 통과한다.
  `unit option` 을 반환하는 부분 액티브 패턴이라 꺼낼 값이 없어서 이렇게 쓸 수 있다.
- 튜플 매개변수형 — FSI 는 `Driver * decimal -> decimal` 로 출력한다.
  노트의 `(Driver * decimal) -> decimal` 은 뜻은 같지만 FSI 출력 그대로는 아니다(위 5번 참고).

원문 모호성으로 올린 구분자 비대칭도 판정했다. 집필자가 맞게 읽었다.

- 이름 붙은 케이스 데이터는 값 생성에서는 쉼표, 패턴에서는 세미콜론을 쓴다. 실제 F# 문법이다.
  값 생성은 이름 붙은 인자(named argument) 문법이고, 패턴은 레코드 패턴과 같은 계열의 필드 패턴 문법이라
  구분자가 다르다. 서로 바꿔 쓰면 각각 실패한다.
  - `Subscribed (DriverId = "x"; IsPlanActive = true)` → `error FS0039: 'DriverId' 값 또는 생성자가 정의되지 않았습니다`
  - `| Subscribed (DriverId = id, IsPlanActive = true) ->` → `error FS0010: 예기치 않은 '=' 기호입니다`
  502행의 서술("이때 필드 사이 구분자는 쉼표가 아니라 세미콜론이다")을 그대로 두어라. 정확하다.

나머지 확인 항목.

- 경고 번호 FS0025 정확. 케이스 누락과 가드만으로 덮은 경우 둘 다 FS0025 다.
- 탭 금지 서술(76행, 120행) 정확. 실제로 경고가 아니라 오류 FS1161 이다.
- `DateTime.TryParse` 오버로드 서술(156행) 정확. `let tryParse s = DateTime.TryParse s` 는 오류 FS0041 이 난다.
- 232-235행의 `%A` 기대 출력 정확. 레코드를 담은 케이스는 실제로 두 줄로 나오고,
  `IsPlanActive` 가 `DriverId` 와 같은 열에 정렬된다. 주석의 열 위치가 실제 출력과 맞다.
- 이름 붙은 필드 패턴은 필드 일부만 적어도 되고, 위치 패턴은 필드를 전부 적어야 한다(빠뜨리면 FS0727).
  475행의 "위치를 셀 필요가 없어 필드가 늘어나도 흔들리지 않는다" 는 이 차이를 정확히 짚었다.
- 판별 유니온이 닫힌 집합이라는 서술(222행), 케이스 식별자를 함수처럼 앞에 붙인다는 서술(223행),
  `Driver` 자체를 직접 만들 수 없다는 서술 모두 정확하다.
- 와일드카드로 뭉개면 케이스 추가 시 경고를 잃는다는 서술(296행, 575행) 정확하다.
- 위에서 아래로 컴파일한다는 서술과 `.fs` 파일 순서 서술(94행, 577행) 정확하다.
- `if` 가 식이므로 양쪽 타입이 같아야 한다는 서술(121행) 정확하다.
- 금액 계산: 30 kWh × 300 = 9000, 12퍼센트 감면 1080, 청구액 7920. 명세 표와 코드가 일치하고
  실행 단위 전부 `true` 를 낸다.
- 챕터 교차 참조 대상이 맞다. `Option`/`Some`/`None`/`unit` → 3챕터(`03-null-and-exceptions.md`),
  단위 테스트 → 4챕터(`04-organising-code-and-testing.md`), 액티브 패턴 → 7챕터,
  원시 타입 감싸기 → 9챕터(단일 케이스 판별 유니온).
- Postscript 의 F# 대비 정확하다. `sealed trait` + 케이스 클래스가 판별 유니온에,
  Scala 의 다중 매개변수 목록 `(driver: Driver)(kwh: Double)` 이 커링된 매개변수에,
  `case ActivePlan(_) if ...` 의 `if` 가 `when` 가드에 대응한다.
- `id` 누락 검증. `id` 없는 `fsharp` 블록은 두 개뿐이고 둘 다 정당하다.
  - 72-74행: 한 줄 레코드 정의. 완전한 코드이지만 `01-record-fee` 에 넣으면 `Driver` 중복 정의가
    되므로 `id` 를 빼는 것이 맞다. 조치 불필요.
  - 256-259행: `...` 가 들어간 컴파일 오류 예시. `id` 없는 것이 맞다.
  실행 가능한데 누락된 블록은 없다.
