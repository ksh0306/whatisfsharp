# 10 - 객체 프로그래밍 (원서 pp.130-140)

> F# 은 함수 우선(functional-first) 언어이지만 객체를 쓸 수 있고, 쓰는 편이 나은 자리도 있다. 원서가 드는 이유는 두 가지다. 함수형 색이 덜한 다른 .NET 언어로 쓴 코드와 맞물려야 할 때, 그리고 내부 자료구조나 가변 상태를 밖에서 못 만지게 감싸고 싶을 때다. 이 챕터는 그 목적에 필요한 만큼만 골라 다룬다. 클래스 타입, 인터페이스, 캡슐화, 동등성 네 가지다. 원서는 F# 이 C#/VB.NET 의 객체 기능을 거의 다 할 수 있다고 적으면서도, 기능 목록을 늘어놓는 대신 "함수만으로는 안 되는 자리에서 무엇을 꺼내 쓰는가"만 본다.

## Setting Up — 준비 (원서 p.130)

- 원서는 새 폴더에 스크립트 세 개(`FizzBuzz.fsx`, `RecentlyUsedList.fsx`, `Coordinate.fsx`)를 만들어 두고 절마다 다른 파일에서 실습하게 한다. FSI 로 조각조각 실행하는 방식이라 프로젝트는 필요하지 않다.
- 이 노트는 원서와 겹치지 않는 도메인 하나를 챕터 전체에 깐다. 설비 점검 일정이다. 점검 주기 규칙표를 받아 며칠째에 어떤 점검이 걸리는지 알려주는 객체를 만들고, 거기에 인터페이스·캡슐화·동등성을 차례로 얹는다.
- 실행 단위가 나뉘어 있으므로 단위끼리는 서로의 타입을 볼 수 없다. 한 단위 안에서 같은 개념을 단계별로 보여줄 때는 단계마다 타입 이름을 달리 둔다.

## 언제 객체를 쓰는가 (원서 p.130)

- 원서의 판단 기준은 상호운용(interop)과 캡슐화다. 4챕터에서 본 대로 함수를 담는 그릇으로는 모듈이 기본이고, 클래스 타입은 상태와 동작을 한 덩어리로 묶어야 할 때 꺼낸다.
- 3챕터가 .NET 라이브러리를 F# 에서 부르는 쪽(`TryParse`, 예외 처리)을 다뤘다면, 이 챕터는 방향이 반대다. C# 쪽에서 자연스럽게 쓰이는 모양을 F# 으로 내놓는 법이다. 동등성 절의 `op_Equality` 가 그 예다.
- 원서는 인터페이스 절 끝에서 한 번 제동을 건다. 함수 하나짜리 인터페이스를 만들고 있다면 그 추가 코드와 복잡도가 정말 필요한지, 그냥 함수로 충분하지 않은지 자문하라는 것이다(원서 p.134). 6챕터에서 함수를 매개변수로 넘겨 가짜(fake)를 끼워 넣던 방식과 같은 이야기다.
- 즉 원서의 태도는 "객체를 피하라"가 아니라 "객체가 제 몫을 하는 자리인지 확인하고 쓰라"다. 이 챕터의 예제 대부분은 그 확인을 통과하는 자리, 곧 가변 상태를 감싸거나 .NET 계약을 구현하는 자리다.

## Class Types — 클래스 타입 (원서 pp.130-132)

- 클래스 타입(class type) 선언은 `type 이름() =` 으로 시작한다. 타입 이름 뒤의 괄호는 생략할 수 없다. 이 괄호가 생성자(constructor) 자리이고, 안에 생성자 매개변수를 적는다. 타입 이름 뒤 괄호로 선언하는 이 생성자가 주 생성자(primary constructor)다.
- `member` 키워드가 밖에서 볼 수 있는 멤버(member)를 정의한다. `member` 다음의 `_` 는 인스턴스 자신을 받는 자기 식별자(self identifier)다. 이름은 무엇이든 쓸 수 있지만 관례는 `_` 아니면 `this` 둘 중 하나다.
- 인스턴스를 만들 때 C# 과 달리 `new` 를 쓰지 않는다. `IDisposable` 을 구현한 타입만 예외인데, 그쪽은 `let` 대신 `use` 로 바인딩하고 `new` 도 함께 적는다. `new` 를 빠뜨려도 컴파일은 되고 경고만 뜬다(이 노트 마지막 절).
- 멤버를 호출할 때 인자 괄호는 생략할 수 있지만 적어 두는 편이 낫다. 생성자와 메서드의 인자는 튜플이고, 괄호가 있으면 함수 적용이 아니라 객체 멤버 호출임이 눈에 보인다. 원하면 `|>` 로 넘겨도 된다.

```fsharp id=10-class
// 이 단위가 보여주는 것: 클래스 타입 선언, 주 생성자, 멤버 호출, 멤버의 평가 시점
type FixedSchedule() =
    member _.Label(day) =
        let hits =
            [(7, "주간"); (30, "월간")]
            |> List.filter (fun (period, _) -> day % period = 0)
            |> List.map snd
        if List.isEmpty hits then $"D{day}" else String.concat "+" hits
```

FSI 가 보여주는 이 타입의 모양은 아래와 같다. 매개변수 없는 생성자(default constructor)가 `unit -> FixedSchedule` 로 나오고, 멤버는 `day: int -> string` 으로 추론된다. `day % period` 와 `$"D{day}"` 만으로 `int` 가 확정된다.

```fsharp
type FixedSchedule =
  new: unit -> FixedSchedule
  member Label: day: int -> string
```

```fsharp id=10-class
let schedule = FixedSchedule()

printfn "%s" (schedule.Label(7))       // 주간
printfn "%s" (schedule.Label(30))      // 월간
printfn "%s" (schedule.Label(210))     // 주간+월간
printfn "%s" (schedule.Label(4))       // D4
printfn "%s" (210 |> schedule.Label)   // 주간+월간
```

규칙표가 코드 안에 박혀 있으면 쓸 데가 하나뿐이다. 규칙표를 생성자 매개변수로 받으면 같은 클래스로 여러 일정을 만들 수 있다. 생성자 매개변수는 `let` 바인딩으로 다시 받아 둘 필요 없이 클래스 본문 어디서나 그대로 보인다.

```fsharp id=10-class
type RuleSchedule(rules) =
    member _.Label(day) =
        let hits =
            rules
            |> List.filter (fun (period, _) -> day % period = 0)
            |> List.map snd
        if List.isEmpty hits then $"D{day}" else String.concat "+" hits

// rules: (int * string) list -> days: int list -> string list
let labelAll rules days =
    let schedule = RuleSchedule(rules)
    days |> List.map schedule.Label

labelAll [(3, "여과기"); (5, "윤활")] [1..6]
|> String.concat " / "
|> printfn "%s"
// D1 / D2 / 여과기 / D4 / 윤활 / 여과기
```

`List.map (fun n -> schedule.Label(n))` 대신 `List.map schedule.Label` 로 적었다. 멤버도 함수 값으로 넘길 수 있다. 다만 멤버의 매개변수는 튜플로 묶이므로, 매개변수가 둘인 멤버를 이렇게 넘기면 값의 타입이 `int * int -> int` 처럼 튜플 하나를 받는 함수가 된다. 커링된 함수를 기대하는 자리에는 람다로 감싸 넘겨야 한다.

멤버 본문이 길어지면 계산을 클래스 본문의 내부 함수로 빼고 멤버는 그 함수를 부르게 하는 편이 읽기 좋다. 내부 `let` 은 밖에서 보이지 않으므로 공개하는 이름과 구현이 분리된다.

```fsharp id=10-class
type MaintenanceSchedule(rules) =
    let label day =
        let hits =
            rules
            |> List.filter (fun (period, _) -> day % period = 0)
            |> List.map snd
        if List.isEmpty hits then $"D{day}" else String.concat "+" hits

    member _.Label(day) = label day
    member _.RuleCount = List.length rules

let plan = MaintenanceSchedule([(3, "여과기"); (5, "윤활")])
printfn "규칙 %d개, D15 -> %s" plan.RuleCount (plan.Label 15)
// 규칙 2개, D15 -> 여과기+윤활
```

### 클래스 본문의 평가 시점 (노트 보충)

클래스 본문의 `let` 바인딩과 `do` 블록은 주 생성자의 본문이다. 인스턴스를 만들 때 위에서 아래로 한 번 실행되고, 그 결과가 인스턴스 안에 남는다. 반면 `member` 본문은 접근할 때마다 다시 실행된다. 아래처럼 표시를 찍어 보면 순서가 그대로 보인다.

```fsharp id=10-class
type ScheduleProbe(rules) =
    let ruleCount =
        printfn "  [let] 바인딩 평가"
        List.length rules

    do printfn "  [do] 블록 실행 (규칙 %d개)" ruleCount

    member _.RuleCount = ruleCount
    member _.CountedNow =
        printfn "  [member] 본문 평가"
        List.length rules

printfn "인스턴스를 만들기 전"
let probe = ScheduleProbe([(3, "여과기"); (5, "윤활")])
printfn "인스턴스를 만든 뒤"
printfn "RuleCount 1회: %d" probe.RuleCount
printfn "RuleCount 2회: %d" probe.RuleCount
printfn "CountedNow 1회: %d" probe.CountedNow
printfn "CountedNow 2회: %d" probe.CountedNow
// 인스턴스를 만들기 전
//   [let] 바인딩 평가
//   [do] 블록 실행 (규칙 2개)
// 인스턴스를 만든 뒤
// RuleCount 1회: 2
// RuleCount 2회: 2
//   [member] 본문 평가
// CountedNow 1회: 2
//   [member] 본문 평가
// CountedNow 2회: 2
```

`RuleCount` 는 생성 시점에 계산된 값을 읽기만 하므로 표시가 찍히지 않는다. `CountedNow` 는 읽을 때마다 본문을 다시 돈다. 비싼 계산을 멤버 본문에 그대로 두면 접근 횟수만큼 되풀이된다는 뜻이다.

`member val` 은 이 둘 사이에 있다. 오른쪽 식을 생성 시점에 한 번만 평가하고 그 값을 담아 두는 자동 프로퍼티(auto-property)를 만든다. 뒤에 `with get, set` 을 붙이면 밖에서 바꿀 수 있는 프로퍼티(property)가 되고, 붙이지 않으면 읽기 전용이다.

```fsharp id=10-class
let mutable issued = 0

let issueTicket () =
    issued <- issued + 1
    issued

type Gauge() =
    member val Serial = issueTicket ()          // 생성 시 한 번
    member _.NextTicket = issueTicket ()        // 접근마다
    member val Location = "미지정" with get, set

let gauge = Gauge()
printfn "Serial     1회/2회: %d / %d" gauge.Serial gauge.Serial
printfn "NextTicket 1회: %d" gauge.NextTicket
printfn "NextTicket 2회: %d" gauge.NextTicket
printfn "Location 초기값: %s" gauge.Location
gauge.Location <- "3라인 압축기"
printfn "Location 변경 후: %s" gauge.Location
// Serial     1회/2회: 1 / 1
// NextTicket 1회: 2
// NextTicket 2회: 3
// Location 초기값: 미지정
// Location 변경 후: 3라인 압축기
```

FSI 로 재어 본 `Gauge` 의 모양은 아래와 같다. 선언에 `with get, set` 을 붙인 프로퍼티에만 시그니처에도 그 표기가 붙는다.

```fsharp
type Gauge =
  new: unit -> Gauge
  member Location: string with get, set
  member NextTicket: int
  member Serial: int
```

## Interfaces — 인터페이스 (원서 pp.132-134)

- 인터페이스(interface)는 구현이 지켜야 할 계약이다. 선언은 `abstract member 이름 : 시그니처` 를 늘어놓는 것으로 끝난다. 이름 앞의 `I` 는 문법이 요구하는 것이 아니라 .NET 관례다.
- 클래스가 인터페이스를 구현할 때는 `interface 이름 with` 블록 안에 멤버를 적는다. F# 에는 암시적 구현이 없다. 같은 이름의 멤버를 클래스 본문에 적어 두는 것으로 인터페이스가 채워지지 않는다. `interface IMaintenanceSchedule` 한 줄만 적고 멤버를 클래스 본문에 두면 `error FS0366` 이 뜬다. 구현되지 않은 인터페이스 멤버를 열거하고, 모든 인터페이스 멤버를 `interface ... with member ...` 선언에 나열하라고 이어 말한다. 구현하지 않으면 FS0366, 구현했지만 변환 없이 부르면 뒤에 나오는 FS0039 다.
- 그래서 구현한 멤버는 클래스 타입의 멤버가 아니다. 인스턴스에서 바로 부르려고 하면 컴파일되지 않는다. 인터페이스 타입으로 상향 변환(upcast, `:>`)해야 보인다.
- 원서는 이것을 F# 이 암시적 변환을 지원하지 않는 탓으로 설명하고, 컴파일러의 마법에 기대지 않으니 코드가 무엇을 하는지 확실해진다는 이점을 든다(원서 p.134). 원서의 이 서술은 F# 5 시점 기준이다. F# 6 이 몇 자리에 암시적 변환을 넣었으므로 그 범위는 뒤에서 갈라 본다. 멤버 조회 자리에는 여전히 암시적 변환이 없으니 이 절의 결론은 그대로다.

```fsharp id=10-interface
// 이 단위가 보여주는 것: 인터페이스 선언과 명시적 구현, 상향 변환이 필요한 이유
type IMaintenanceSchedule =
    abstract member Label : int -> string
    abstract member RuleCount : int

type RuleTable(rules: (int * string) list) =
    let label day =
        let hits =
            rules
            |> List.filter (fun (period, _) -> day % period = 0)
            |> List.map snd
        if List.isEmpty hits then $"D{day}" else String.concat "+" hits

    interface IMaintenanceSchedule with
        member _.Label(day) = label day
        member _.RuleCount = List.length rules
```

FSI 가 보여주는 `RuleTable` 의 모양이 상황을 그대로 설명한다. 생성자와 `interface IMaintenanceSchedule` 한 줄뿐이고 멤버 목록이 비어 있다.

```fsharp
type RuleTable =
  interface IMaintenanceSchedule
  new: rules: (int * string) list -> RuleTable
```

그러니 인스턴스에서 `.Label` 을 바로 부르면 오류다. 실측한 메시지는 `error FS0039: 'RuleTable' 형식은 'Label' 필드, 생성자 또는 멤버를 정의하지 않습니다.` 다.

```fsharp
let table = RuleTable([(3, "여과기")])
table.Label 3    // error FS0039
```

고치는 방법은 두 갈래다. 바인딩할 때 한 번 상향 변환해 두거나, 쓰는 자리에서 변환한다. 전자가 멤버를 여러 번 부를 때 깔끔하다.

```fsharp id=10-interface
// 바인딩 시점에 변환해 두기
let table = RuleTable([(3, "여과기"); (5, "윤활")]) :> IMaintenanceSchedule
printfn "규칙 %d개, D15 -> %s" table.RuleCount (table.Label 15)
// 규칙 2개, D15 -> 여과기+윤활

// 쓰는 자리에서 변환하기
let raw = RuleTable([(2, "육안")])
printfn "D4 -> %s" ((raw :> IMaintenanceSchedule).Label 4)
// D4 -> 육안
```

변환을 손으로 적지 않아도 되는 자리가 둘 있다. 인터페이스 타입으로 주석을 단 `let` 바인딩과, 인터페이스 타입 매개변수를 받는 함수의 인자 자리다. 뒤쪽은 오래된 동작이지만 앞쪽은 `--langversion:5.0` 에서 `error FS0001: 이 식에는 'IMaintenanceSchedule' 형식이 필요하지만 여기에서는 'RuleTable' 형식이 지정되었습니다.` 로 막힌다. 실측해 보면 F# 6 부터 통한다.

```fsharp id=10-interface
// 타입 주석이 붙은 바인딩 — F# 6 부터 암시적 상향 변환이 붙는다
let annotated : IMaintenanceSchedule = RuleTable([(2, "육안")])
printfn "D3 -> %s" (annotated.Label 3)
// D3 -> D3

// 인터페이스 타입 매개변수 자리 — 변환을 적지 않아도 된다
let report (s: IMaintenanceSchedule) days =
    days |> List.map s.Label |> String.concat " / "

printfn "%s" (report (RuleTable([(3, "여과기")])) [1..6])
// D1 / D2 / 여과기 / D4 / D5 / 여과기
```

함수를 매개변수로 받는 것과 인터페이스를 받는 것을 견줘 보면, 계약에 멤버가 둘 이상이고 그 묶음이 함께 움직일 때 인터페이스가 제 몫을 한다. `Label` 하나만 필요했다면 `int -> string` 함수를 받는 편이 코드가 짧다. 원서가 경계하는 지점이 정확히 그것이다.

### 추상 클래스와 상속 (원서 p.133 확장)

원서는 인터페이스에 `[<AbstractClass>]` 특성을 붙이면 추상 클래스(abstract class)가 된다고 한 줄로만 언급한다. 실제로 추상 클래스는 인터페이스와 달리 구현과 상태를 함께 담을 수 있다. `abstract member` 는 하위 타입(derived type)이 반드시 채워야 하고, `default` 를 붙여 기본 구현을 주면 하위 타입이 선택적으로 재정의(override)한다. F# 인터페이스에는 기본 구현도 상태도 담을 수 없다. 인터페이스 선언에 `default` 를 붙이면 그 타입이 클래스가 되어 다른 타입에서 `interface ... with` 로 구현할 때 `error FS0887: 'IGreeter' 형식은 인터페이스 형식이 아닙니다.` 가 나고, 인터페이스 본문에 `let` 을 적으면 `error FS0963` 이다. 둘 중 하나라도 필요하면 추상 클래스로 간다.

```fsharp id=10-interface
[<AbstractClass>]
type ScheduleBase(rules: (int * string) list) =
    member _.Rules = rules
    abstract member Label : int -> string
    abstract member Owner : string
    default _.Owner = "미배정"
    member this.Describe(day) = $"D{day} [{this.Owner}] -> {this.Label day}"

type LineSchedule(rules, owner) =
    inherit ScheduleBase(rules)

    override this.Label(day) =
        let hits = this.Rules |> List.filter (fun (period, _) -> day % period = 0) |> List.map snd
        if List.isEmpty hits then "없음" else String.concat "+" hits

    override _.Owner = owner

type SparseSchedule(rules) =
    inherit ScheduleBase(rules)
    override _.Label(_) = "확인 필요"

printfn "%s" (LineSchedule([(3, "여과기"); (5, "윤활")], "2조").Describe 15)
// D15 [2조] -> 여과기+윤활
printfn "%s" (SparseSchedule([]).Describe 1)
// D1 [미배정] -> 확인 필요
```

- 상속(inheritance)은 `inherit 기반타입(인자)` 한 줄로 선언한다. 기반 타입(base type)의 생성자를 여기서 부른다.
- 인터페이스와 달리 상속받은 멤버(`Rules`, `Describe`)는 하위 타입의 멤버로 그대로 보인다. 변환이 필요하지 않다.
- 생성자 매개변수가 튜플로 묶인다는 점이 시그니처에 드러난다. FSI 는 `LineSchedule` 의 생성자를 `new: rules: (int * string) list * owner: string -> LineSchedule` 로 보여준다. 커링된 매개변수가 아니라 `*` 로 이어진 튜플이다.

## Object Expressions — 객체 식 (원서 pp.134-136)

- 객체 식(object expression)은 클래스 타입을 선언하지 않고 인터페이스 구현 하나를 그 자리에서 만드는 문법이다. `{ new 인터페이스 with 멤버들 }` 형태다.
- 만들어지는 것은 이름 없는 타입이다. 그래서 그 타입 이름으로 무언가를 더 할 수는 없지만, 대신 바인딩의 정적 타입이 곧바로 인터페이스가 되어 상향 변환을 적을 일이 없다.
- 원서가 드는 용도는 두 가지다. 한 번만 쓰고 버릴 서비스, 그리고 테스트다. 6챕터에서 함수를 넘겨 가짜를 끼워 넣던 방식의 인터페이스판이다.

```fsharp id=10-objexpr
// 이 단위가 보여주는 것: 객체 식으로 인터페이스 구현을 그 자리에서 만들기
open System
open System.Globalization

type IClock =
    abstract member Now : DateTime
    abstract member Zone : string

// 클래스로 구현하면 쓸 때 상향 변환이 필요하다
type SystemClock() =
    interface IClock with
        member _.Now = DateTime.UtcNow
        member _.Zone = "UTC"

// 객체 식은 그 단계를 건너뛴다
let fixedClock =
    { new IClock with
        member _.Now = DateTime(2026, 3, 1, 9, 30, 0)
        member _.Zone = "UTC" }

printfn "IClock 구현인가: %b" (typeof<IClock>.IsAssignableFrom(fixedClock.GetType()))
printfn "고정 시각: %s" (fixedClock.Now.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture))
// IClock 구현인가: true
// 고정 시각: 2026-03-01 09:30
```

FSI 로 재어 보면 `val fixedClock: IClock` 이다. 런타임 타입은 컴파일러가 붙인 이름 없는 타입이지만, 정적 타입은 인터페이스 그 자체다. `SystemClock() :> IClock` 처럼 변환을 적을 필요가 없는 까닭이 여기 있다.

인터페이스를 생성자 매개변수로 받는 클래스를 두면, 실제 구현과 가짜를 같은 자리에 끼울 수 있다. 아래 클래스는 내부에 가변 카운터를 감춰 둔다. 클래스 안의 `let mutable` 은 밖에서 보이지 않고, 읽기 전용 프로퍼티로만 드러난다.

```fsharp id=10-objexpr
type BatchStamper(clock: IClock) =
    let mutable stamped = 0

    member _.Stamp(label) =
        stamped <- stamped + 1
        sprintf "[%s %s] %s" (clock.Now.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture)) clock.Zone label

    member _.Stamped = stamped

let stamper = BatchStamper(fixedClock)
printfn "%s" (stamper.Stamp "압축기 점검")
printfn "%s" (stamper.Stamp "냉각수 보충")
printfn "찍은 횟수: %d" stamper.Stamped
// [2026-03-01 09:30 UTC] 압축기 점검
// [2026-03-01 09:30 UTC] 냉각수 보충
// 찍은 횟수: 2
```

시각이 고정되어 있으니 출력이 결정적이다. 다만 시각을 고정한 것만으로는 문자열까지 고정되지 않는다. `DateTime` 을 문자열로 바꿀 때 문화권을 넘기지 않으면 실행 환경의 문화권이 쓰이고, 달력과 시간 구분 기호가 함께 갈린다. `IClock` 이 내놓는 것은 `DateTime` 이고 그것을 어떻게 적을지는 별개의 결정이므로, 가짜 시계를 끼워도 서식 쪽을 `CultureInfo.InvariantCulture` 로 못 박아야 출력이 어느 환경에서나 같다. 실제 시계를 넣으면 같은 코드가 현재 시각을 찍는다.

```fsharp id=10-objexpr
let live = SystemClock() :> IClock
printfn "시스템 시계가 2020년 이후인가: %b" (live.Now.Year >= 2020)
// 시스템 시계가 2020년 이후인가: true
```

객체 식은 만들어지는 자리의 지역 값을 붙잡아 둘 수 있다. 2챕터에서 본 클로저와 같은 성질이다. `let mutable` 도 붙잡히므로, 호출할 때마다 값이 바뀌는 가짜를 함수 하나로 찍어낼 수 있다. 테스트에서 시간이 흐르는 상황을 재현할 때 쓴다.

```fsharp id=10-objexpr
// start: System.DateTime -> stepMinutes: float -> IClock
let steppingClock (start: DateTime) (stepMinutes: float) =
    let mutable current = start
    { new IClock with
        member _.Now =
            current <- current.AddMinutes stepMinutes
            current
        member _.Zone = "UTC" }

let stepping = steppingClock (DateTime(2026, 3, 1, 9, 0, 0)) 15.0
printfn "1회: %s" (stepping.Now.ToString("HH:mm", CultureInfo.InvariantCulture))
printfn "2회: %s" (stepping.Now.ToString("HH:mm", CultureInfo.InvariantCulture))
printfn "3회: %s" (stepping.Now.ToString("HH:mm", CultureInfo.InvariantCulture))
// 1회: 09:15
// 2회: 09:30
// 3회: 09:45
```

이 함수의 반환 타입이 `IClock` 이라는 점을 눈여겨볼 만하다. 함수 하나가 인터페이스 구현을 값으로 돌려준다. 클래스 타입을 하나 늘리지 않고도 구현을 갈아 끼울 수 있다.

## Encapsulation — 캡슐화 (원서 pp.136-138)

- 캡슐화(encapsulation)는 객체를 쓸 이유 중 원서가 가장 무게를 두는 쪽이다. 가변 컬렉션을 클래스 안에 감추고, 정해 둔 멤버로만 만지게 한다.
- 예제로 쓰는 자료구조는 정원(capacity)이 정해진 최근 이력이다. 이 노트에서 정원은 도메인이 정한 최대 크기이고, `ResizeArray` 의 `Capacity` 프로퍼티와는 다른 것이다. 최신 항목이 앞에 오고, 같은 항목을 다시 올리면 앞으로 옮겨 오며, 정원을 넘으면 가장 오래된 항목이 밀려 나간다. 원서는 "최근 사용 목록"으로, 이 노트는 편집기의 되돌리기 이력으로 만든다.
- 내부 저장소로 쓰는 `ResizeArray<'T>` 는 .NET 의 가변 `List<'T>` 에 붙은 F# 타입 약어(type abbreviation)다. 이름이 `List` 와 겹쳐 혼란을 부르므로 F# 에서는 이 이름을 쓴다.
- 클래스 본문의 `let` 은 밖에서 보이지 않는다. 저장소에 직접 손댈 길이 없으니 불변식(invariant), 곧 중복 없음과 최신 순, 그리고 뒤에서 더할 정원 상한을 깨뜨릴 수 있는 코드가 이 타입 안으로 한정된다. 가변 상태를 두고도 마음을 놓을 수 있는 근거가 그것이다.

```fsharp id=10-encapsulation
// 이 단위가 보여주는 것: 가변 컬렉션을 클래스 안에 감추고 멤버로만 열어 주기
type StepLog() =
    let steps = ResizeArray<string>()

    let push step =
        steps.Remove step |> ignore
        steps.Add step

    let peek index =
        if index >= 0 && index < steps.Count then Some steps[steps.Count - index - 1]
        else None

    member _.IsEmpty = steps.Count = 0
    member _.Depth = steps.Count
    member _.Clear() = steps.Clear()
    member _.Push(step) = push step
    member _.TryPeek(index) = peek index
```

`push` 는 같은 항목을 먼저 지우고 다시 맨 뒤에 넣는다. 그래서 중복이 생기지 않고 최근에 올린 것이 항상 맨 뒤다. `peek` 은 인덱스를 뒤에서부터 세어 0 이 가장 최근이 되게 뒤집고, 범위를 벗어나면 예외 대신 `None` 을 준다.

FSI 가 보여주는 시그니처를 보면 어느 멤버가 프로퍼티이고 어느 것이 메서드인지 구분된다. `unit -> unit` 이 붙은 `Clear` 는 메서드이고, 타입만 적힌 `Depth`, `IsEmpty` 는 읽기 전용 프로퍼티다.

```fsharp
type StepLog =
  new: unit -> StepLog
  member Clear: unit -> unit
  member Push: step: string -> unit
  member TryPeek: index: int -> string option
  member Depth: int
  member IsEmpty: bool
```

```fsharp id=10-encapsulation
let log = StepLog()
printfn "처음에 비었나: %b" log.IsEmpty
log.Push "글꼴 변경"
log.Push "표 삽입"
log.Push "글꼴 변경"        // 이미 있는 항목 -> 앞으로 옮겨진다
printfn "깊이: %d" log.Depth
printfn "가장 최근: %A" (log.TryPeek 0)
printfn "그 다음: %A" (log.TryPeek 1)
printfn "범위 밖: %A" (log.TryPeek 5)
log.Clear()
printfn "비운 뒤: %b / 깊이 %d" log.IsEmpty log.Depth
// 처음에 비었나: true
// 깊이: 2
// 가장 최근: Some "글꼴 변경"
// 그 다음: Some "표 삽입"
// 범위 밖: None
// 비운 뒤: true / 깊이 0
```

여기에 정원을 붙이고 밖으로 내놓는 멤버 목록을 인터페이스로 옮긴다. 정원은 생성자 매개변수로 받는다.

```fsharp id=10-encapsulation
type IUndoHistory =
    abstract member IsEmpty : bool
    abstract member Depth : int
    abstract member Capacity : int
    abstract member Clear : unit -> unit
    abstract member Push : string -> unit
    abstract member TryPeek : int -> string option

type UndoHistory(capacity: int) =
    let steps = ResizeArray<string>(capacity)

    let push step =
        steps.Remove step |> ignore
        if steps.Count = capacity then steps.RemoveAt 0
        steps.Add step

    let peek index =
        if index >= 0 && index < steps.Count then Some steps[steps.Count - index - 1]
        else None

    interface IUndoHistory with
        member _.IsEmpty = steps.Count = 0
        member _.Depth = steps.Count
        member _.Capacity = capacity
        member _.Clear() = steps.Clear()
        member _.Push(step) = push step
        member _.TryPeek(index) = peek index

let history = UndoHistory(3) :> IUndoHistory
printfn "정원: %d" history.Capacity
["글꼴 변경"; "표 삽입"; "이미지 삽입"; "여백 조정"] |> List.iter history.Push
printfn "깊이: %d" history.Depth
printfn "0번: %A" (history.TryPeek 0)
printfn "2번: %A" (history.TryPeek 2)
printfn "3번: %A" (history.TryPeek 3)
history.Push "표 삽입"
printfn "다시 올린 뒤 0번: %A / 깊이 %d" (history.TryPeek 0) history.Depth
// 정원: 3
// 깊이: 3
// 0번: Some "여백 조정"
// 2번: Some "표 삽입"
// 3번: None
// 다시 올린 뒤 0번: Some "표 삽입" / 깊이 3
```

네 항목을 올렸지만 깊이가 3 에서 멈춘다. 정원이 찬 상태에서 새 항목이 들어오면 `RemoveAt 0` 이 가장 오래된 것을 밀어낸다.

한 가지 짚어 둘 것이 있다. 원서는 정원 판정에 `items.Capacity` 를 쓴다(원서 p.137). `ResizeArray` 의 `Capacity` 는 정원이 아니라 미리 확보해 둔 자리 수이고, 자리가 모자라면 늘어난다. 실측하면 이렇다.

```fsharp id=10-encapsulation
let probe = ResizeArray<string>(0)
printfn "0으로 만든 Capacity: %d" probe.Capacity
probe.Add "항목"
printfn "하나 넣은 뒤 Capacity: %d / Count: %d" probe.Capacity probe.Count
printfn "3으로 만든 Capacity: %d" (ResizeArray<string>(3).Capacity)
// 0으로 만든 Capacity: 0
// 하나 넣은 뒤 Capacity: 4 / Count: 1
// 3으로 만든 Capacity: 3
```

`Capacity` 를 0 으로 잡아 만든 뒤 항목 하나를 넣으면 그 값이 4 로 뛴다. 생성자에 넘긴 값과 이렇게 갈라지므로 `Capacity` 는 정원의 이름이 될 수 없다. 위 코드가 생성자 인자를 그대로 붙잡아 두고 그것으로 판정하는 이유다.

원서 코드도 정원 1 이상에서는 실제로 돈다. `ResizeArray<'T>(n)` 이 딱 `n` 칸을 잡아 두고 판정이 `Count` 가 그 수를 넘는 것을 막기 때문에 `Capacity` 가 늘어날 일이 오지 않는다. 다만 그것은 `List<'T>` 구현이 그렇다는 사정일 뿐 계약이 아니다. 정원 0 은 두 판 모두 빈 `ResizeArray` 에 `RemoveAt 0` 을 불러 `ArgumentOutOfRangeException` 이 난다. 정원에 하한이 필요하면 생성자에서 검사하는 편이 낫다.

멤버 단위로 노출을 조절하고 싶으면 접근 지정자(access modifier)를 붙여 `member private this.X` 나 `member internal this.X` 로 좁힐 수 있다. 다만 캡슐화의 큰 몫은 이미 클래스 본문의 `let` 이 해 준다.

## Equality — 동등성 (원서 pp.138-140)

- F# 의 대다수 타입(레코드, 튜플, 판별 유니온)은 구조적 동등성(structural equality)을 기본으로 준다. 담긴 값이 같으면 `=` 가 참이다.
- 클래스 타입은 그렇지 않다. .NET 의 다른 대다수와 마찬가지로 참조 동등성(reference equality)을 쓴다. 같은 인스턴스를 가리킬 때만 참이다.
- 값처럼 견주고 싶으면 손으로 붙여야 한다. `GetHashCode` 와 `Equals` 를 재정의하고 `IEquatable<'T>` 를 구현한다. 다른 .NET 언어에서 `==` 로 쓰이게 하려면 `op_Equality` 정적 멤버를 더한다. `[<AllowNullLiteral>]` 은 목적이 다르다. 그 특성이 있어야 F# 코드가 이 타입 자리에 `null` 을 쓸 수 있고, 아래 예제의 `isNull` 도 그것 없이는 컴파일되지 않는다.

```fsharp id=10-equality
// 이 단위가 보여주는 것: 클래스는 참조 동등성이 기본이고, 구조적 동등성은 손으로 붙인다
open System

type Swatch(red: int, green: int, blue: int) =
    member _.Red = red
    member _.Green = green
    member _.Blue = blue

let s1 = Swatch(200, 40, 40)
let s2 = Swatch(200, 40, 40)
let s3 = s1

printfn "값이 같은 두 인스턴스: %b" (s1 = s2)   // false
printfn "같은 인스턴스: %b" (s1 = s3)           // true
```

같은 세 숫자로 만들었는데 `s1 = s2` 가 거짓이다. 여기서 `=` 는 참조를 견준다. 아래는 같은 값을 담았으면 같다고 보게 만든 판이다.

```fsharp id=10-equality
// [<AllowNullLiteral>] 이 있어야 아래 isNull 이 컴파일된다
[<AllowNullLiteral>]
type Colour(red: int, green: int, blue: int) =
    let equals (other: Colour) =
        if isNull other then false
        else red = other.Red && green = other.Green && blue = other.Blue

    member _.Red = red
    member _.Green = green
    member _.Blue = blue

    override this.GetHashCode() = hash (this.Red, this.Green, this.Blue)

    override _.Equals(candidate) =
        match candidate with
        | :? Colour as other -> equals other
        | _ -> false

    interface IEquatable<Colour> with
        member _.Equals(other: Colour) = equals other

    static member op_Equality(left: Colour, right: Colour) = left.Equals(right)
```

- 실제 비교는 내부 함수 `equals` 하나에 모아 둔다. `Equals` 재정의와 `IEquatable<Colour>` 구현이 이 함수를 부르고, `op_Equality` 는 `Equals` 를 거쳐 같은 곳에 닿는다. 비교 규칙이 한곳에만 있으니 셋이 갈라질 일이 없다.
- `Equals(candidate)` 는 `obj` 를 받으므로 타입 테스트 패턴(type test pattern) `:? Colour as other` 로 좁힌다. 3챕터에서 예외를 걸러낼 때 쓴 것과 같은 패턴이다. 다른 타입이 들어오면 거짓이다.
- `isNull` 과 `hash` 는 F# 이 기본으로 주는 함수다. `hash` 에 튜플을 넘기면 구성 요소를 엮은 해시를 만들어 준다.
- 둘 중 하나만 재정의하면 컴파일러가 경고한다. `Equals` 만 재정의하고 `GetHashCode` 를 빼면 `warning FS0346: 구조체, 레코드 또는 공용 구조체 형식 'HalfColour'에 'Object.Equals'의 명시적 구현이 있습니다.` 로 시작하는 경고가 뜨고, `Object.GetHashCode()` 쪽 재정의도 맞춰 두라고 이어 말한다. 반대로 `GetHashCode` 만 재정의하면 `warning FS0345: 구조체, 레코드 또는 공용 구조체 형식 'HalfColour2'에 'Object.GetHashCode'의 명시적 구현이 있습니다.` 로 시작하는 경고가 뜨고, `Object.Equals(obj)` 쪽 재정의도 맞춰 두라고 이어 말한다. 두 메시지가 "구조체, 레코드 또는 공용 구조체 형식"이라고 말하지만 여기서 걸린 대상은 클래스 타입이다. 재정의 짝을 맞추지 않으면 해시가 어긋난 값을 딕셔너리 키로 쓸 때 넣어 둔 값을 다시 찾지 못한다.
- `op_Equality` 는 F# 코드에서 쓰이지 않는다. F# 의 `=` 는 `Equals` 로 간다. C# 이나 VB.NET 에서 `==` 로 견줄 수 있게 하려고 내놓는 계약이다.
- `[<AllowNullLiteral>]` 은 상호운용 특성이 아니다. 다른 .NET 언어는 이 특성이 없어도 F# 클래스 타입 자리에 `null` 을 넘긴다. 이 특성이 여는 것은 F# 쪽이다. F# 은 자기가 선언한 클래스 타입에 `null` 리터럴을 허용하지 않으므로, 특성을 떼면 `isNull other` 가 `error FS0001: 'Colour' 형식은 적절한 값으로 'null'을 가지지 않습니다.` 로 막힌다. 원서 p.139 가 `op_Equality` 와 이 특성을 한 문장에 묶어 둔 것은 정확하지 않다.

두 경고를 손으로 확인해 볼 코드다. 경고가 나므로 검증 대상에 넣지 않는다.

```fsharp
// GetHashCode 를 빼면 warning FS0346 이 뜬다
type HalfColour(red: int) =
    member _.Red = red
    override _.Equals(candidate) =
        match candidate with
        | :? HalfColour as other -> red = other.Red
        | _ -> false
```

```fsharp
// 반대로 Equals 를 빼면 warning FS0345 가 뜬다
type HalfColour2(red: int) =
    member _.Red = red
    override this.GetHashCode() = hash this.Red
```

```fsharp id=10-equality
let c1 = Colour(200, 40, 40)
let c2 = Colour(200, 40, 40)

printfn "값이 같은 두 인스턴스: %b" (c1 = c2)                       // true
printfn "참조가 같은가: %b" (obj.ReferenceEquals(c1, c2))            // false
printfn "해시가 같은가: %b" (c1.GetHashCode() = c2.GetHashCode())    // true
printfn "null 과 비교: %b" (c1.Equals(null))                        // false
printfn "List.distinct 후 개수: %d" (List.distinct [c1; c2] |> List.length)   // 1
printfn "재정의 없는 Swatch: %d" (List.distinct [s1; s2] |> List.length)      // 2
```

`=` 가 참이 되었을 뿐 아니라 `List.distinct` 의 결과까지 달라진다. `equality` 제약은 컴파일 시점 조건이라 재정의가 없어도 컴파일은 된다. 달라지는 것은 결과다. 참조는 여전히 다르다는 것도 함께 확인해 둘 만하다.

여기서 견줘 볼 것이 있다. 같은 일을 레코드로 하면 타입 선언 한 줄로 끝난다.

```fsharp id=10-equality
type ColourRecord = { Red: int; Green: int; Blue: int }

let r1 = { Red = 200; Green = 40; Blue = 40 }
let r2 = { Red = 200; Green = 40; Blue = 40 }
printfn "레코드 동등성: %b / 해시: %b" (r1 = r2) (r1.GetHashCode() = r2.GetHashCode())
// 레코드 동등성: true / 해시: true
```

그러니 위의 긴 코드는 "F# 에서 값처럼 견주는 타입을 만드는 법"이 아니다. 클래스 타입이라야 하는 사정이 있을 때, 곧 다른 .NET 언어에 내놓는 타입이거나 상태를 감춰야 할 때 그 타입에 동등성을 붙이는 법이다. F# 안에서만 쓸 값이라면 레코드가 먼저다.

### 연산자 오버로딩 (노트 보충)

앞 절에서는 `op_Equality` 라는 .NET 내부 이름을 그대로 멤버 이름으로 적었다. F# 에서 연산자를 정의하는 보통 문법은 연산자 기호를 괄호에 담은 정적 멤버이고, 매개변수는 튜플로 받는다.

```fsharp id=10-equality
type Pigment(red: int, green: int, blue: int) =
    member _.Red = red
    member _.Green = green
    member _.Blue = blue

    static member (+) (left: Pigment, right: Pigment) =
        Pigment(
            min 255 (left.Red + right.Red),
            min 255 (left.Green + right.Green),
            min 255 (left.Blue + right.Blue))

    static member (*) (p: Pigment, factor: float) =
        Pigment(
            min 255 (int (float p.Red * factor)),
            min 255 (int (float p.Green * factor)),
            min 255 (int (float p.Blue * factor)))

let mixed = Pigment(100, 0, 0) + Pigment(200, 30, 0)
printfn "섞은 값: (%d, %d, %d)" mixed.Red mixed.Green mixed.Blue
// 섞은 값: (255, 30, 0)

let dimmed = Pigment(200, 100, 50) * 0.5
printfn "절반 값: (%d, %d, %d)" dimmed.Red dimmed.Green dimmed.Blue
// 절반 값: (100, 50, 25)
```

- 컴파일러는 후보를 찾을 때 양쪽 피연산자의 타입을 모두 뒤진다. 왼쪽 피연산자 타입에 정의가 없어도 오른쪽 타입에 있으면 뽑힌다.
- 다만 선언한 매개변수 순서와 쓰는 순서는 맞아야 한다. 위 `*` 는 `(Pigment, float)` 순서로만 선언했으므로 `Pigment(200, 100, 50) * 0.5` 는 통하고 `0.5 * Pigment(200, 100, 50)` 은 `error FS0193: 형식 제약 조건이 일치하지 않습니다.` 다. 양쪽 순서를 다 쓰려면 `static member (*) (factor: float, p: Pigment)` 를 정적 멤버로 하나 더 적는다.
- 2챕터에서 이름이 나온 사용자 정의 연산자(custom operator)는 모듈 수준 `let (+.) a b = ...` 형태다. 그쪽은 커링된 매개변수이고, 이쪽은 튜플이다. 타입에 딸린 연산자를 만들 때는 정적 멤버 형태를 쓴다.

## IDisposable 과 use (원서 p.131 확장)

원서는 클래스 타입 절에서 `new` 를 쓰지 않는다고 하면서 예외 하나를 단다. `IDisposable` 을 구현한 타입이면 `let` 이 아니라 `use` 로 스코프 블록을 만든다는 것이다. 6챕터에서 `StreamReader` 를 쓰는 쪽만 봤다면 이번에는 `IDisposable` 을 구현하는 쪽을 본다. (원서가 이 인터페이스를 `IDisposible<'T>` 로 적은 것은 오기다. 실제 `IDisposable` 은 제네릭이 아니고 이름 철자도 다르다. 원서 p.81 도 같은 대목에서 어긋나지만 그쪽은 철자는 맞고 제네릭 표기만 틀렸다(`IDisposable<'T>`).)

```fsharp id=10-dispose
// 이 단위가 보여주는 것: IDisposable 구현과 use 의 맞물림
open System

type MachineLock(machineId: string, trail: ResizeArray<string>) =
    let mutable released = false
    do trail.Add $"{machineId} 점유"

    member _.Inspect(part) = trail.Add $"{machineId}/{part}"

    interface IDisposable with
        member _.Dispose() =
            if not released then
                released <- true
                trail.Add $"{machineId} 반납"
```

- 점유와 반납을 `trail` 에 적어 두어 순서를 눈으로 확인한다. 점유는 `do` 블록이므로 생성 시점에 한 번 실행된다.
- `released` 로 두 번 해제되는 것을 막았다. `Dispose()` 가 여러 번 불려도 안전해야 한다는 것이 .NET 의 규약이다.

```fsharp id=10-dispose
let trail = ResizeArray<string>()

let inspectAll () =
    use held = new MachineLock("CMP-01", trail)
    held.Inspect "여과기"
    held.Inspect "윤활"

inspectAll ()
trail |> String.concat " -> " |> printfn "%s"
// CMP-01 점유 -> CMP-01/여과기 -> CMP-01/윤활 -> CMP-01 반납
```

`use` 로 바인딩했으므로 함수 스코프가 끝나는 자리에서 `Dispose()` 가 불렸다. `let` 으로 바꾸면 그 호출이 사라진다.

```fsharp id=10-dispose
let trail2 = ResizeArray<string>()

let leaky () =
    let held = new MachineLock("CMP-02", trail2)
    held.Inspect "여과기"

leaky ()
trail2 |> String.concat " -> " |> printfn "%s"
// CMP-02 점유 -> CMP-02/여과기
```

반납 기록이 없다. 스코프를 벗어난 뒤에도 설비가 점유된 채 남았다는 뜻이다. 6챕터에서 파일 핸들이 열린 채 남는 사고를 본 것과 같은 구조다. 반대로 예외가 나는 경로에서도 `use` 는 해제를 보장한다.

```fsharp id=10-dispose
let trail3 = ResizeArray<string>()

let failing () =
    use held = new MachineLock("CMP-03", trail3)
    held.Inspect "여과기"
    failwith "압력 이상"

try failing () with ex -> trail3.Add $"예외: {ex.Message}"
trail3 |> String.concat " -> " |> printfn "%s"
// CMP-03 점유 -> CMP-03/여과기 -> CMP-03 반납 -> 예외: 압력 이상
```

반납이 예외 기록보다 앞에 온다. 스코프를 벗어나는 시점에 해제가 먼저 일어나고 그 뒤에 예외가 호출 사슬을 올라간다.

두 가지를 더 실측해 둔다. 하나는 `new` 를 빠뜨렸을 때다. `use held = MachineLock(...)` 로 적으면 `warning FS0760: IDisposable 인터페이스를 지원하는 개체는 생성 값이 리소스를 소유할 수도 있다는 것을 표시하기 위해 생성자를 나타내는 함수 값으로 'Type(args)' 또는 'Type'이 아니라 'new Type(args)' 구문을 사용하여 만드는 것이 좋습니다.` 가 뜬다. 다른 하나는 `Dispose()` 를 손으로 부를 때다. 이 멤버도 인터페이스 구현이므로 인스턴스에서 바로 부르면 `error FS0039: 'MachineLock' 형식은 'Dispose' 필드, 생성자 또는 멤버를 정의하지 않습니다.` 다. 상향 변환이 필요하다. 반면 `use` 는 변환을 적지 않아도 알아서 찾아 부른다.

```fsharp id=10-dispose
let trail4 = ResizeArray<string>()
let manual = new MachineLock("CMP-04", trail4)
(manual :> IDisposable).Dispose()
trail4 |> String.concat " -> " |> printfn "%s"
// CMP-04 점유 -> CMP-04 반납
```

## Summary — 원서의 챕터 요약 (원서 p.140)

- 원서는 이 챕터를 F# 객체 프로그래밍의 입문으로 정리한다. 다룬 것은 스코프와 가시성, 캡슐화, 인터페이스와 변환, 동등성이다.
- .NET 생태계의 나머지와 맞물릴 일이 늘어날수록 객체 프로그래밍이 필요해질 여지도 커진다는 것이 원서의 결론이다.
- 여기서 다룬 것은 F# 객체 프로그래밍의 표면이라고 밝히고, 더 파고들 독자에게 Kit Eason 의 Stylish F# 을 권한다.
- 다음 챕터에서는 F# 의 재귀를 다룬다.

## 정리 — 이 노트의 요약

- 클래스 타입은 `type 이름(생성자 매개변수) =` 으로 선언한다. 타입 이름 뒤 괄호는 생략할 수 없고, 생성자·메서드의 매개변수는 커링되지 않은 튜플로 묶인다. 인스턴스를 만들 때 `new` 는 쓰지 않는다. `IDisposable` 구현체만 예외이고 그때는 `use` 와 `new` 를 함께 쓴다. `new` 를 빠뜨리면 오류가 아니라 경고 `FS0760` 이다.
- 클래스 본문의 `let`·`do` 는 주 생성자의 본문이라서 인스턴스를 만들 때 한 번 실행된다. `member` 본문은 접근할 때마다 다시 실행된다. `member val` 은 생성 시점에 한 번 평가한 값을 담아 두는 자동 프로퍼티이고, `with get, set` 을 붙이면 밖에서 바꿀 수 있다.
- 내부 `let` 은 밖에서 보이지 않는다. 이 성질이 캡슐화의 핵이다. 가변 `ResizeArray` 를 안에 감추고 멤버로만 열어 주면, 불변식을 깨뜨릴 수 있는 코드가 그 타입 안으로 한정된다.
- 인터페이스 구현은 F# 에서 명시적이다. `interface I with` 블록에 적은 멤버는 클래스 타입의 멤버가 아니므로, 인스턴스에서 바로 부르면 `error FS0039` 다. `:>` 로 상향 변환해야 보인다. FSI 시그니처에도 `interface I` 한 줄만 찍히고 멤버 목록이 비어 있다.
- 변환을 적지 않아도 되는 자리는 인터페이스 타입 매개변수를 받는 함수의 인자 자리, 그리고 인터페이스 타입으로 주석을 단 `let` 바인딩이다. 뒤쪽은 실측하면 F# 6 부터 통하고 `--langversion:5.0` 에서는 `error FS0001` 이다.
- 객체 식은 `{ new I with ... }` 로 이름 없는 구현을 그 자리에서 만든다. 정적 타입이 곧 인터페이스라 변환이 필요 없고, 지역 값과 `let mutable` 을 붙잡을 수 있다. 한 번만 쓰는 서비스와 테스트용 가짜에 알맞다.
- 추상 클래스는 `[<AbstractClass>]` 로 만든다. `abstract member` 는 하위 타입이 반드시 채우고, `default` 를 붙이면 기본 구현이 된다. 상속은 `inherit` 한 줄이고, 상속받은 멤버는 인터페이스와 달리 변환 없이 보인다.
- 클래스 타입의 `=` 는 참조를 견준다. 값으로 견주게 하려면 `GetHashCode` 와 `Equals` 를 함께 재정의하고 `IEquatable<'T>` 를 구현한다. `Equals` 만 재정의하면 `warning FS0346`, `GetHashCode` 만 재정의하면 `warning FS0345` 다. 다른 .NET 언어의 `==` 까지 맞추려면 `op_Equality` 정적 멤버를 더한다. `[<AllowNullLiteral>]` 은 상호운용을 위한 특성이 아니라 F# 코드가 그 타입에 `null` 리터럴을 쓸 수 있게 하는 특성이고, `isNull` 로 그 타입의 값을 검사하려면 반드시 붙여야 한다.
- 그 모든 코드가 레코드에서는 선언 한 줄로 따라온다. 클래스에 동등성을 붙이는 일은 클래스라야 하는 사정이 있을 때 하는 작업이고, F# 안에서만 쓰는 값이라면 레코드가 먼저다.
- 타입에 딸린 연산자는 `static member (+) (a, b) = ...` 형태로 정의한다. 매개변수는 튜플이고, 왼쪽과 오른쪽 타입을 다르게 잡아도 된다. 다만 선언한 매개변수 순서와 쓰는 순서가 맞아야 하고, 뒤집어 쓰려면 순서를 바꾼 정적 멤버를 하나 더 적는다. 모듈 수준의 사용자 정의 연산자가 커링된 매개변수를 쓰는 것과 대비된다.
- 원서의 태도를 한 줄로 옮기면, 객체는 F# 의 기본값이 아니지만 상호운용과 캡슐화라는 두 자리에서는 함수보다 나은 도구다. 함수 하나짜리 인터페이스를 만들고 있다면 그 자리는 아마 아니다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Setting Up — 준비 | p.130 | — |
| 언제 객체를 쓰는가 | p.130 | — |
| Class Types — 클래스 타입 | pp.130-132 | `10-class` |
| 클래스 본문의 평가 시점 (노트 보충) | — | `10-class` |
| Interfaces — 인터페이스 | pp.132-134 | `10-interface` |
| 추상 클래스와 상속 (원서 p.133 확장) | p.133 | `10-interface` |
| Object Expressions — 객체 식 | pp.134-136 | `10-objexpr` |
| Encapsulation — 캡슐화 | pp.136-138 | `10-encapsulation` |
| Equality — 동등성 | pp.138-140 | `10-equality` |
| 연산자 오버로딩 (노트 보충) | — | `10-equality` |
| IDisposable 과 use (원서 p.131 확장) | p.131 | `10-dispose` |
| Summary — 원서의 챕터 요약 | p.140 | — |
