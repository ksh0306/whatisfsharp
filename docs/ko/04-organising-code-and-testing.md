# 04 - 코드 구성과 테스트 (원서 pp.52-62)

> 앞의 세 챕터가 언어 자체를 다뤘다면 이 챕터는 도구를 다룬다. 스크립트 파일 하나에 코드를 몰아넣는 단계를 벗어나는 방법이 나온다. 솔루션(solution)과 프로젝트(project)로 경계를 긋고, 네임스페이스(namespace)와 모듈(module)로 이름을 정리하고, xUnit 으로 단위 테스트(unit test)를 짠다. F# 에만 있는 규칙이 하나 끼어 있어서 다른 .NET 언어를 쓰던 독자가 가장 자주 걸려 넘어지는 지점이 여기다. F# 은 파일의 컴파일 순서가 고정되어 있고, 그 순서를 프로젝트 파일이 결정한다.

## Getting Started — 솔루션과 프로젝트 만들기 (원서 p.52)

- 원서 본문은 이 절에서 부록 1(원서 pp.195-196)의 스크립트를 실행하라고만 하고 넘어간다. 실제 명령은 부록에 있으므로 여기서는 그 명령을 현재 SDK 기준으로 정리한다.
- 만들 구조는 솔루션 하나에 프로젝트 둘이다. 코드용 콘솔 프로젝트와 테스트용 xUnit 프로젝트다.
- 코드 프로젝트는 `src/` 아래, 테스트 프로젝트는 `tests/` 아래에 둔다. 이것이 .NET 생태계의 관례이고, 이렇게 두면 나중에 프로젝트가 늘어나도 구조가 유지된다.

```bash
dotnet new sln -o ShopSolution
cd ShopSolution
mkdir src tests
dotnet new console -lang "F#" -o src/Shop
dotnet new xunit -lang "F#" -o tests/ShopTests
dotnet sln add src/Shop/Shop.fsproj tests/ShopTests/ShopTests.fsproj
```

- 따옴표를 빼도 셸은 낱말 첫 글자가 아닌 `#` 을 주석으로 보지 않으므로 명령은 그대로 동작한다. 그래도 `-lang "F#"` 처럼 붙여 두는 편이 안전하다.
- `dotnet sln add` 는 인자를 여러 개 받으므로 프로젝트마다 따로 실행할 필요가 없다.

테스트 프로젝트가 코드 프로젝트를 볼 수 있게 참조를 걸고, 어서션(assertion) 라이브러리인 FsUnit 을 넣는다.

```bash
cd tests/ShopTests
dotnet add reference ../../src/Shop/Shop.fsproj
dotnet add package FsUnit.xUnit
cd ../..
dotnet build
dotnet test
```

- 참조 방향은 한쪽뿐이다. 테스트 프로젝트가 코드 프로젝트를 참조한다. 반대 방향 참조까지 함께 걸면 두 프로젝트가 서로를 참조하게 되어, 복원 단계에서 순환 참조 오류 MSB4006 이 난다. 코드 프로젝트가 테스트 프로젝트를 참조하도록 방향만 뒤집어 걸면 빌드는 되지만, 테스트 프로젝트가 대상 코드를 볼 수 없어 의미가 없다.
- 원서 부록은 `FsUnit` 과 `FsUnit.xUnit` 두 패키지를 모두 넣지만, xUnit 만 쓸 때는 `FsUnit.xUnit` 하나로 충분하다. `FsUnit.xUnit` 은 `FsUnit` 을 의존하지 않는 독립 패키지이고, `FsUnit` 단독 패키지는 NUnit 용 어서션이다.
- `dotnet test` 를 솔루션 디렉터리에서 실행하면 솔루션에 속한 테스트 프로젝트 전부를 빌드해 실행한다. 처음에는 템플릿이 만들어 둔 테스트 하나만 통과한다. 아래 인용은 `DOTNET_CLI_UI_LANGUAGE=en` 을 붙여 얻은 영어 출력이다. CLI 메시지는 셸 로케일을 따라 번역돼 나오므로 한국어 로케일에서는 `통과!  - 실패:     0, ...` 로 찍힌다.

```
Passed!  - Failed:     0, Passed:     1, Skipped:     0, Total:     1, Duration: < 1 ms - ShopTests.dll (net10.0)
```

코드 프로젝트를 실행할 때는 그 프로젝트 디렉터리에서 `dotnet run` 을 쓴다.

```bash
cd src/Shop
dotnet run
```

- 이때 나오는 `Hello from F#` 은 템플릿이 만든 `Program.fs` 한 줄이 출력한 것이다.
- 원서(2023년 1월판)와 현재 SDK(.NET 10.0.111)의 차이는 두 군데다. 첫째, `dotnet new sln` 이 기본으로 XML 형식인 `.slnx` 를 만든다. 예전 `.sln` 형식이 필요하면 `dotnet new sln -f sln` 을 쓴다. 둘째, 대상 프레임워크가 `net5.0`/`net6.0` 대신 `net10.0` 이다. 명령 이름과 흐름 자체는 원서와 같다.
- `dotnet sln add` 가 `src/`, `tests/` 경로를 보고 같은 이름의 솔루션 폴더를 만들어 주는 것은 SDK 10 에서 새로 생긴 동작이 아니다. 이 동작을 끄는 옵션이 `--in-root` 이고 기본값이 끄지 않는 쪽이며, `-f sln` 으로 만든 `.sln` 에도 같은 폴더가 SolutionFolder 항목과 NestedProjects 절로 들어간다. 형식에 따라 적는 표기만 다르다. 이 폴더는 편집기 솔루션 탐색기의 분류일 뿐이고 디스크의 디렉터리도 컴파일 순서도 아니다.

## Solutions and Projects — 경계를 나누는 두 단위 (원서 p.52)

- 프로젝트는 컴파일 단위다. 프로젝트 하나가 어셈블리(`.dll`) 하나로 컴파일되고, 콘솔 프로젝트라면 그것을 띄우는 실행 파일이 함께 만들어진다.
- 솔루션은 프로젝트를 묶어 한 번에 빌드하고 테스트하기 위한 목록일 뿐이다. 솔루션 자체가 컴파일되는 것은 아니다.
- 그래서 "무엇을 별도 프로젝트로 뺄까"의 기준은 배포 단위다. 따로 배포하거나 따로 참조할 이유가 없으면 프로젝트를 늘리지 않는 편이 낫다. 코드 정리는 다음 절의 모듈로 하는 것이 가볍다.

## Adding a Source File — 파일을 추가하면 순서를 적어야 한다 (원서 pp.52-53)

- F# 프로젝트에서 파일을 추가하는 일은 두 단계다. 파일을 만드는 것과 그 파일을 `.fsproj` 의 컴파일 목록에 적는 것이다. 둘째 단계를 빼먹으면 그 파일은 없는 것과 같다.
- C# 프로젝트는 디렉터리의 `.cs` 파일을 자동으로 전부 컴파일하지만 F# 은 그렇지 않다. `.fsproj` 의 `<Compile Include=... />` 가 적힌 순서가 곧 컴파일 순서다.

`src/Shop` 에 `Learners.fs` 를 만들었다면 `Shop.fsproj` 를 이렇게 고친다.

```xml
<ItemGroup>
  <Compile Include="Learners.fs" />
  <Compile Include="Program.fs" />
</ItemGroup>
```

- `Program.fs` 가 `Learners.fs` 의 함수를 쓴다면 `Learners.fs` 가 위에 있어야 한다. 순서를 뒤집으면 `Program.fs` 는 아직 존재하지 않는 이름을 참조하는 셈이 되어 컴파일에 실패한다.
- VS Code 에서 Ionide 확장을 쓰면 F# 솔루션 탐색기에서 기존 파일을 마우스 오른쪽 버튼으로 클릭해 그 위나 아래에 새 파일을 만드는 메뉴를 쓸 수 있다. 이러면 파일 생성과 `.fsproj` 등록이 한 번에 된다. 일반 탐색기로 만들었다면 `.fsproj` 를 직접 고쳐야 한다.

이 "위에서 아래로만 보인다"는 규칙은 파일 사이에만 적용되는 것이 아니다. 파일 안에서도 똑같다.

```fsharp id=04-order
// 이 단위가 보여주는 것: 이름은 위에서 아래로만 보인다(파일 안이든 파일 사이든)

module Discount =
    // 아래에서 쓰는 값은 반드시 위에 있어야 한다
    let baseRate = 0.05

    // string -> float
    let rateFor grade = if grade = "gold" then baseRate * 2.0 else baseRate
```

`Discount` 를 먼저 정의했으므로 그 아래의 `Order` 는 `Discount` 를 볼 수 있다.

```fsharp id=04-order
module Order =
    // 앞에서 정의한 Discount 는 이 아래에서 보인다
    // string -> float -> float
    let total grade amount = amount * (1.0 - Discount.rateFor grade)

printfn "gold   1000.0 -> %.1f" (Order.total "gold" 1000.0)     // 기대: 900.0
printfn "silver 1000.0 -> %.1f" (Order.total "silver" 1000.0)   // 기대: 950.0
```

두 모듈의 순서를 바꾸면 컴파일되지 않는다. 파일 순서를 잘못 적었을 때 나오는 오류와 같은 것이다.

```fsharp
module Order =
    // 아래에 정의될 Discount 는 여기서 보이지 않는다
    let total grade amount = amount * (1.0 - Discount.rateFor grade)
    // error FS0039: The value, namespace, type or module 'Discount' is not defined

module Discount =
    let baseRate = 0.05
    let rateFor grade = if grade = "gold" then baseRate * 2.0 else baseRate
```

- 이 순서가 필요한 까닭은 F# 의 타입 추론이 위에서 아래로 한 번만 훑기 때문이다. 어떤 이름을 쓰는 지점에서 그 이름의 타입이 이미 확정되어 있어야 하므로, 정의가 사용보다 앞에 와야 한다.
- 이 제약은 불편해 보이지만 얻는 것이 있다. 의존 방향이 파일 목록에 그대로 드러나므로 순환 의존이 애초에 생길 수 없고, `.fsproj` 만 봐도 프로젝트의 계층을 읽을 수 있다.
- 한 파일 안의 두 모듈이 서로를 참조해야 하는 드문 경우에는 `module rec` 이나 `namespace rec` 로 그 파일에 한해 규칙을 풀 수 있다. 파일 사이에는 같은 수단이 없다.

선언 없이 만든 새 `.fs` 파일을 등록하고 빌드하면 순서와는 별개의 오류를 먼저 만난다.

```
error FS0222: Files in libraries or multiple-file applications must begin with a namespace
or module declaration, e.g. 'namespace SomeNamespace.SubNamespace' or
'module SomeNamespace.SomeModule'. Only the last source file of an application may omit
such a declaration.
```

- 파일이 둘 이상이면 각 파일은 네임스페이스나 모듈 선언으로 시작해야 한다. 예외는 애플리케이션의 마지막 파일 하나뿐이고, 그래서 템플릿이 만든 `Program.fs` 는 선언 없이 `printfn` 한 줄로 시작할 수 있다. 이 예외는 테스트 프로젝트에서는 통하지 않는다. 그 이유는 Writing Tests 절에서 다룬다.
- 다음 절이 이 선언을 다룬다.

## Namespaces and Modules — 이름을 정리하는 두 장치 (원서 pp.53-56)

- 모듈은 프로젝트 안에서 코드를 논리적으로 묶는 장치다. 네임스페이스는 다른 프로젝트의 코드를 참조할 때 이름이 충돌할 확률을 줄이는 장치다. 역할이 다르므로 둘 다 쓴다.
- 네임스페이스에 담을 수 있는 것은 타입 선언, `open` 선언, 모듈뿐이다. 값이나 함수를 네임스페이스 바로 아래에 두면 오류 FS0201 이 난다. 한편 같은 네임스페이스를 여러 파일에 걸쳐 쓸 수 있고, 모듈 이름은 파일이 달라도 한 네임스페이스 안에서 유일해야 한다. 겹치면 오류 FS0248 이 난다.
- 모듈은 네임스페이스를 뺀 무엇이든 담을 수 있고 모듈 안에 모듈을 넣을 수도 있다. 네임스페이스 대신 최상위 모듈을 둘 수도 있지만, 그 이름은 프로젝트의 모든 파일에 걸쳐 유일해야 한다. 겹치면 오류 FS0239 가 난다.

파일 첫 줄에 쓸 수 있는 선언 형태는 세 가지다.

```fsharp
// (1) 네임스페이스만. 함수는 파일 안의 모듈에 넣는다
namespace Shop.Inventory

// (2) 네임스페이스를 두고 그 아래에 모듈을 중첩한다
namespace Shop
module Inventory =
    // ...

// (3) 최상위 모듈. 점 앞은 네임스페이스, 마지막 조각이 모듈 이름이 된다
module Shop.Inventory
```

- (1)과 (3)의 차이가 헷갈리기 쉽다. (1)은 `Shop.Inventory` 전체가 네임스페이스이므로 파일 안에 모듈을 하나 더 만들어야 함수를 둘 수 있다. (3)은 `Shop` 이 네임스페이스, `Inventory` 가 모듈이므로 함수를 파일 최상위에 바로 쓸 수 있다.
- 실무에서 무난한 출발점은 각 파일 첫 줄에 프로젝트 이름으로 네임스페이스를 적고, 나머지 정리는 모듈로 하는 것이다.
- 모듈 하나마다 파일 하나로 쪼개려 애쓸 필요는 없다. 함께 바뀌는 코드는 같은 파일에 두는 편이 낫다. 기술적 계층(컨트롤러, 서비스, 리포지터리)이 아니라 기능이나 도메인 개념을 기준으로 묶으라는 것이 원서의 조언이다.

아래 실행 단위는 중첩 모듈과 정규화된 접근을 보여 준다. `namespace` 와 최상위 `module X.Y` 는 스크립트 파일에서 쓸 수 없어 F# Interactive(FSI) 로 검증할 수 없으므로, 여기서는 `module X =` 형태의 중첩 모듈로 같은 구조를 만든다.

```fsharp id=04-modules
// 이 단위가 보여주는 것: 중첩 모듈, 정규화된 접근, open, 이름 가림, RequireQualifiedAccess

module Inventory =

    // 두 하위 모듈이 함께 쓰는 타입은 바깥 모듈 스코프에 둔다
    type Item = { Sku: string; Qty: int }

    module Create =
        // string -> int -> Item
        let item sku qty = { Sku = sku; Qty = qty }

    module Format =
        // Item -> string
        let label (item: Item) = $"{item.Sku} / 재고 {item.Qty}"
```

- 하위 모듈은 바깥 모듈의 타입을 `open` 없이 그대로 쓴다. 원서가 네임스페이스 스코프에 `Customer` 타입을 두고 두 모듈이 그것을 쓰게 한 것과 같은 배치다.
- 바깥에서는 모듈 이름을 앞에 붙여 정규화된 이름으로 접근한다.

```fsharp id=04-modules
let bolt = Inventory.Create.item "BOLT-8" 12
printfn "%s" (Inventory.Format.label bolt)   // 기대: BOLT-8 / 재고 12

// open 하면 그 모듈 안의 이름을 한 단계 짧게 쓸 수 있다
open Inventory

let nut = Create.item "NUT-8" 40
printfn "%s" (Format.label nut)              // 기대: NUT-8 / 재고 40
```

- `open` 은 이름을 짧게 만들어 주지만 대가가 있다. 같은 이름이 여러 모듈에 있으면 나중에 `open` 한 쪽이 앞의 것을 가린다. 이것이 이름 가림(shadowing)이다. 오류나 경고 없이 조용히 가려지므로 주의할 만하다.

```fsharp id=04-modules
module Metric =
    // int -> string
    let describe (n: int) = $"{n} 개(미터법)"

module Imperial =
    // int -> string
    let describe (n: int) = $"{n} 개(야드파운드법)"

open Metric
open Imperial

// 나중에 open 한 Imperial 의 describe 가 이긴다
printfn "%s" (describe 3)   // 기대: 3 개(야드파운드법)
```

가려지면 곤란한 모듈에는 특성(attribute) `[<RequireQualifiedAccess>]` 를 붙인다. 그러면 그 모듈은 `open` 대상이 되지 못하고(오류 FS0892) 항상 모듈 이름을 앞에 붙여 써야 한다.

```fsharp id=04-modules
[<RequireQualifiedAccess>]
module Warehouse =
    // int -> string
    let describe (n: int) = $"{n} 상자"

printfn "%s" (Warehouse.describe 3)   // 기대: 3 상자
```

- F# 코어의 `List`, `Array`, `Seq`, `Map`, `Set`, `String` 모듈에도 이 특성이 붙어 있다. 그래서 `open List` 는 오류이고 `List.map` 과 `Array.map` 이 섞일 일이 없다. 반면 `Option`, `Result` 모듈에는 붙어 있지 않아 `open` 이 가능하다.
- 이 특성은 모듈뿐 아니라 판별 유니온 타입에도 붙는다. `Tier` 에 붙이면 `Pro` 대신 `Tier.Pro` 로만 쓸 수 있어 케이스 식별자가 다른 이름과 부딪히지 않는다.
- 반대로 `[<AutoOpen>]` 을 붙인 모듈은 그 어셈블리를 참조하기만 하면 `open` 없이 이름이 보인다. 편하지만 이름이 어디서 왔는지 추적하기 어려워지므로 아껴 쓴다.
- `open` 은 모듈 안에도 쓸 수 있다. 특정 모듈에서만 필요한 `System.IO` 같은 것은 파일 맨 위가 아니라 그 모듈 안에 두면 영향 범위가 좁아진다.

## Writing Tests — 첫 테스트와 이중 백틱 이름 (원서 pp.56-57)

- xUnit 템플릿이 만든 `Tests.fs` 는 최상위 모듈 선언, `open System`, `open Xunit`, `[<Fact>]` 가 붙은 함수 하나로 되어 있다. 아래 조각에서는 쓰이지 않는 `open System` 을 빼고 옮겼다.
- 테스트 함수는 `unit` 을 받아 `unit` 을 반환한다. 매개변수 자리의 `()` 를 빼면 값 바인딩이 되어 특성을 붙일 자리가 사라진다. 이때 경고 FS0842 가 나고 xUnit 은 그 바인딩을 테스트로 수집하지 않는다.
- 테스트 파일도 네임스페이스나 모듈 선언으로 시작해야 한다. 다만 네임스페이스를 둘 필요는 없고 모듈 하나로 충분하다. 배포되지 않는 코드라서 다른 어셈블리와 이름이 충돌할 일이 없다.
- 테스트 프로젝트에는 마지막 파일 예외가 통하지 않는다. 테스트 SDK 가 진입점 파일을 컴파일 목록 맨 뒤에 붙이므로 사용자가 만든 파일은 어느 것도 마지막이 아니다. 파일이 하나뿐이어도 선언을 빼면 오류 FS0222 가 난다.
- F# 이 테스트 작성에서 특히 편한 이유는 이중 백틱 이름이다. 식별자를 ` `` ` 로 감싸면 공백과 한글을 포함한 문장을 그대로 이름으로 쓸 수 있다.

```fsharp
module Tests

open Xunit

[<Fact>]
let ``My test`` () =
    Assert.True(true)
```

모듈에도 이중 백틱 이름을 쓸 수 있다. 모듈 이름을 상황, 테스트 이름을 기대 결과로 잡으면 출력이 그대로 문장이 된다. 아래 조각은 네임스페이스 아래에 모듈을 둔 형태다. 테스트 파일에 네임스페이스가 필수는 아니지만, 실패 출력에 네임스페이스와 모듈이 어떻게 함께 찍히는지 보이려고 이렇게 적었다.

```fsharp
namespace ShopTests

open Xunit

module ``테스트를 모듈로 묶으면`` =

    [<Fact>]
    let ``첫 번째 테스트가 통과한다`` () =
        Assert.True(true)

    [<Fact>]
    let ``두 번째 테스트도 통과한다`` () =
        Assert.True(true)
```

- 테스트가 깨지면 출력에 `어셈블리.모듈.테스트이름` 이 그대로 찍힌다. 이름을 문장으로 지어 두면 실패 목록만 읽어도 무엇이 어긋났는지 알 수 있다.

```
[xUnit.net 00:00:01.24]     ShopTests.테스트를 모듈로 묶으면.두 번째 테스트도 통과한다 [FAIL]
```

- 일부러 `Assert.True(false)` 로 바꿔 한 번 실패시켜 보면 이 출력 형식을 확인할 수 있다.
- 원서는 이중 백틱 이름에 `[ , | - ; .` 같은 문자를 넣으면 Ionide 확장이 죽는다고 경고한다(원서 기준 2022년 5월 확인). 오래된 정보이므로 지금은 다를 수 있으나, 특수문자를 피하는 습관 자체는 손해가 없다. 공백과 한글은 현재 SDK 에서 문제없이 동작했다.

## Writing Real Tests — 테스트할 대상을 두고 짜기 (원서 pp.57-61)

- 원서는 2챕터에서 만든 고객 승급 파이프라인을 테스트 대상으로 되돌려 쓴다. 이 노트는 같은 모양의 파이프라인을 온라인 강의 수강생 도메인으로 새로 짜서 쓴다.
- 대상 코드는 순수 함수 파이프라인이다. 같은 입력을 주면 언제나 같은 출력이 나오고 부수 효과(side effect)가 없으므로, 테스트가 준비 코드 없이 한 줄로 끝난다. 테스트하기 쉬운 코드는 대개 테스트 기법이 좋아서가 아니라 대상이 순수해서 쉬운 것이다.

`src/Shop/Learners.fs` 에 들어갈 코드다. 실제 프로젝트라면 첫 줄이 `module Shop.Learners` 이지만, FSI 검증을 위해 여기서는 중첩 모듈 형태로 적는다.

```fsharp id=04-learners
// 이 단위가 보여주는 것: 테스트 대상이 될 순수 함수 파이프라인과 그 결과 확인

module Learners =

    type Tier =
        | Basic
        | Pro

    type Learner = { Id: int; Tier: Tier; Points: int }

    // Learner -> Learner * int
    // 수료한 강의 수를 조회한다고 가정한다. 실제로는 데이터베이스를 읽을 자리다
    let findCompleted learner =
        let completed = if learner.Id % 3 = 0 then 12 else 4
        learner, completed

    // Learner * int -> Learner  (튜플 매개변수)
    let promoteIfEligible (learner, completed) =
        if completed >= 10 then { learner with Tier = Pro } else learner

    // Learner -> Learner
    let awardPoints learner =
        let bonus =
            match learner.Tier with
            | Pro -> 300
            | Basic -> 100
        { learner with Points = learner.Points + bonus }

    // Learner -> Learner
    let settleMonth learner =
        learner
        |> findCompleted
        |> promoteIfEligible
        |> awardPoints
```

- `promoteIfEligible` 의 매개변수는 두 개가 아니라 튜플 하나다. 시그니처가 `Learner -> int -> Learner` 가 아니라 `Learner * int -> Learner` 인 것이 그 표시다. `findCompleted` 가 돌려준 튜플이 이 매개변수 하나에 그대로 들어가므로 파이프가 맞물리는 것이고, `|>` 가 튜플을 두 인자로 풀어 주는 것은 아니다. 튜플은 절반만 채울 수 없으므로 이 함수에는 부분 적용을 쓸 수 없다.
- `findCompleted` 는 원래 데이터베이스를 읽을 자리다. 여기서는 `Id` 로 대신 계산해 결정적으로 만들었다. 실제 프로젝트에서 이 함수만 바깥에서 주입받도록 바꾸면 나머지 세 함수는 계속 순수하게 남는다.
- 테스트로 확인할 경로는 세 갈래다. 이미 `Pro` 인 수강생, 조건을 채워 승급하는 `Basic` 수강생, 조건을 못 채운 `Basic` 수강생이다.

```fsharp id=04-learners
open Learners

let proLearner = { Id = 1; Tier = Pro; Points = 0 }
let basicLearner = { Id = 3; Tier = Basic; Points = 500 }

// Learner -> string
let describe learner =
    sprintf "Id=%d Tier=%A Points=%d" learner.Id learner.Tier learner.Points

printfn "%-13s %s" "pro" (describe (settleMonth proLearner))
printfn "%-13s %s" "basic" (describe (settleMonth basicLearner))
printfn "%-13s %s" "basic(Id=4)" (describe (settleMonth { basicLearner with Id = 4 }))
// 기대:
// pro           Id=1 Tier=Pro Points=300
// basic         Id=3 Tier=Pro Points=800
// basic(Id=4)   Id=4 Tier=Basic Points=600
```

- 세 번째 줄이 `Points=600` 인 이유는 `Id = 4` 라 `4 % 3 = 1` 이므로 수료 수가 4 에 머물고, 승급 없이 `Basic` 보너스 100 점만 더해지기 때문이다.

원서가 2챕터에서 쓴 검증 방식은 `let 이름 = 실제값 = 기댓값` 처럼 비교 결과를 값 바인딩에 담아 FSI 출력으로 확인하는 것이었다. 그 방식을 테스트로 옮기기 전에 한 단계 다듬으면 형태가 그대로 옮겨진다. 비교를 `areEqual` 이라는 이름의 함수로 빼고, 기댓값에 `expected` 라는 이름을 붙이는 것이다.

```fsharp id=04-learners
// 'a -> 'a -> bool  (when 'a : equality)
// 매개변수 순서를 expected, actual 로 잡아 xUnit 의 Assert.Equal 과 같게 맞췄다
let areEqual expected actual = actual = expected

let checkProBonus =
    let expected = { proLearner with Points = 300 }
    areEqual expected (settleMonth proLearner)

let checkPromotion =
    let expected = { basicLearner with Tier = Pro; Points = 800 }
    areEqual expected (settleMonth basicLearner)

let checkNoPromotion =
    let expected = { basicLearner with Id = 4; Points = 600 }
    areEqual expected (settleMonth { basicLearner with Id = 4 })

printfn "%-15s %b" "ProBonus" checkProBonus         // 기대: ProBonus        true
printfn "%-15s %b" "Promotion" checkPromotion       // 기대: Promotion       true
printfn "%-15s %b" "NoPromotion" checkNoPromotion   // 기대: NoPromotion     true
```

- 여기까지 오면 각 검증은 기댓값 한 줄, 실제값 한 줄, 비교 한 줄이 된다. 이 세 줄이 그대로 `[<Fact>]` 함수 본문이 된다.
- 레코드는 구조적 동등성(structural equality)이 있어 `=` 로 필드 전체를 한 번에 비교할 수 있다. 필드를 하나씩 확인하는 어서션을 쓸 이유가 없다.

이제 `tests/ShopTests/LearnerTests.fs` 에 옮긴다. xUnit 의 `Assert.Equal` 을 쓴다.

```fsharp
namespace ShopTests

open Xunit
open Shop.Learners

module ``월말 정산을 하면`` =

    let proLearner = { Id = 1; Tier = Pro; Points = 0 }
    let basicLearner = { Id = 3; Tier = Basic; Points = 500 }

    [<Fact>]
    let ``Pro 수강생은 보너스 300점을 받는다`` () =
        let expected = { proLearner with Points = 300 }
        let actual = settleMonth proLearner
        Assert.Equal(expected, actual)

    [<Fact>]
    let ``조건을 채운 Basic 수강생은 Pro 로 승급한다`` () =
        let expected = { basicLearner with Tier = Pro; Points = 800 }
        let actual = settleMonth basicLearner
        Assert.Equal(expected, actual)

    [<Fact>]
    let ``조건을 못 채운 Basic 수강생은 등급이 그대로다`` () =
        let learner = { basicLearner with Id = 4 }
        let expected = { learner with Points = 600 }
        let actual = settleMonth learner
        Assert.Equal(expected, actual)
```

- `open Shop.Learners` 하나로 타입과 함수가 다 들어온다. 코드 프로젝트 쪽 파일 첫 줄이 `module Shop.Learners` 였으므로 `Shop` 이 네임스페이스, `Learners` 가 모듈이다.
- 이 파일도 `.fsproj` 에 등록해야 실행된다. 테스트 프로젝트에서도 컴파일 순서 규칙은 똑같다.

```xml
<ItemGroup>
  <Compile Include="Tests.fs" />
  <Compile Include="LearnerTests.fs" />
</ItemGroup>
```

```bash
dotnet test
```

- `Assert.Equal` 이 실패하면 기댓값과 실제값을 레코드 모양 그대로 찍어 준다. 어느 필드가 다른지 눈으로 바로 찾을 수 있다.

```
Assert.Equal() Failure: Values differ
Expected: { Id = 1
            Tier = Pro
            Points = 100 }
Actual:   { Id = 1
            Tier = Pro
            Points = 300 }
```

- xUnit 은 선택지 중 하나일 뿐이다. NUnit, MSTest, Expecto 같은 다른 프레임워크를 써도 이 챕터의 구조는 그대로 통한다.

## Using FsUnit for Assertions — 어서션 문장을 파이프로 (원서 pp.61-62)

- `Assert.Equal(expected, actual)` 은 .NET 관례에 맞는 표기이지만 F# 의 파이프 흐름과는 어긋난다. 인자 순서를 헷갈리기 쉽다.
- FsUnit 은 같은 검증을 `actual |> should equal expected` 로 쓰게 해 준다. 실제값을 왼쪽에서 오른쪽으로 흘려보내는 모양이라 앞 절에서 짠 파이프라인 코드와 읽는 방향이 맞는다.

```fsharp
open FsUnit.Xunit

actual |> should equal expected
```

- `open` 할 이름은 `FsUnit.Xunit` 이다. 원서 본문은 `open FsUnit` 이라고 적었지만 그것은 NUnit 용 모듈이다. xUnit 과 함께 쓸 때는 `FsUnit.Xunit` 을 열어야 `should` 가 보인다.
- `FsUnit.xUnit` 만 넣은 프로젝트에서 `open FsUnit` 은 그 자체로는 오류가 아니다. `FsUnit` 이라는 네임스페이스가 있으므로 `open` 은 통과하고, `should` 를 쓰는 줄에서 오류 FS0039 가 난다. 원서처럼 `FsUnit` 패키지까지 함께 넣으면 `should` 는 보인다. 다만 이때 쓰이는 것은 NUnit 쪽 어서션이라, xUnit 으로 돌린 테스트인데도 실패 메시지가 `NUnit.Framework.AssertionException : Assert.That(, )` 로 찍히고 검증한 식이 괄호 안에 비어 나온다.
- 테스트 러너는 여전히 xUnit 이다. FsUnit 이 바꾸는 것은 어서션을 적는 문법뿐이고, `[<Fact>]` 와 `dotnet test` 는 그대로다.

앞 절의 세 테스트에서 `Assert.Equal` 만 바꾼 모습이다.

```fsharp
namespace ShopTests

open Xunit
open FsUnit.Xunit
open Shop.Learners

module ``월말 정산을 하면`` =

    let proLearner = { Id = 1; Tier = Pro; Points = 0 }
    let basicLearner = { Id = 3; Tier = Basic; Points = 500 }

    [<Fact>]
    let ``Pro 수강생은 보너스 300점을 받는다`` () =
        let expected = { proLearner with Points = 300 }
        let actual = settleMonth proLearner
        actual |> should equal expected

    [<Fact>]
    let ``조건을 채운 Basic 수강생은 Pro 로 승급한다`` () =
        let expected = { basicLearner with Tier = Pro; Points = 800 }
        let actual = settleMonth basicLearner
        actual |> should equal expected

    [<Fact>]
    let ``조건을 못 채운 Basic 수강생은 등급이 그대로다`` () =
        let learner = { basicLearner with Id = 4 }
        let expected = { learner with Points = 600 }
        let actual = settleMonth learner
        actual |> should equal expected
```

- `should` 뒤에는 `equal` 외에도 `not' (equal x)`, `be True`, `be Empty`, `haveLength 3`, `be (greaterThan 1)`, `throw typeof<...>` 같은 조합이 온다. 문장처럼 읽히는 어서션을 만드는 것이 이 라이브러리의 목적이다.
- 실패 메시지는 xUnit 의 것을 그대로 쓰되 기댓값 쪽에 `Equals` 가 붙어 나온다.

```
Assert.Equal() Failure: Values differ
Expected: Equals { Id = 3
            Tier = Pro
            Points = 900 }
Actual:   { Id = 3
            Tier = Pro
            Points = 800 }
```

- xUnit 어서션과 FsUnit 어서션은 한 파일 안에 섞어 써도 된다. 둘 중 무엇을 골라도 되지만, 팀 안에서 하나로 통일하는 편이 읽기에 낫다.

## Summary — 원서의 챕터 요약 (원서 p.62)

- 원서는 이 챕터에서 솔루션, 프로젝트, 네임스페이스, 모듈로 코드를 구성하는 방법과 xUnit 단위 테스트, FsUnit 어서션을 다뤘다.
- 코드베이스가 커져도 작업을 감당할 수 있는 것은 이 기능들 덕분이라는 말로 원서는 챕터를 맺는다.
- 다음 챕터에서는 컬렉션을 처음으로 살펴본다.

## 정리 — 이 노트의 요약

- F# 의 컴파일 순서는 `.fsproj` 의 `<Compile Include=... />` 순서다. 파일을 만드는 것과 등록하는 것은 별개의 일이며, 등록하지 않은 파일은 컴파일되지 않는다.
- 이름은 위에서 아래로만 보인다. 파일 안에서도, 파일 사이에서도 그렇다. 파일 사이에는 이 규칙을 우회하는 수단이 없어 순환 의존이 생길 수 없고, 그래서 프로젝트의 계층이 파일 목록에 그대로 드러난다.
- 파일이 둘 이상이면 각 파일은 네임스페이스나 모듈 선언으로 시작해야 한다(오류 FS0222). 애플리케이션의 마지막 파일만 예외이고, 테스트 프로젝트에는 그 예외조차 통하지 않는다.
- 네임스페이스는 타입 선언과 `open` 선언, 모듈만 담고 여러 파일에 걸칠 수 있다. 모듈은 무엇이든 담고 중첩할 수 있다. 함수를 파일 최상위에 바로 쓰고 싶으면 `module Namespace.Module` 형태를 쓴다.
- `open` 은 편하지만 같은 이름을 조용히 가린다. 가려지면 곤란한 모듈에는 `[<RequireQualifiedAccess>]` 를 붙인다.
- 이중 백틱 이름은 테스트 이름을 문장으로 만들어 준다. 실패 출력이 `어셈블리.모듈.테스트이름` 이라 모듈 이름을 상황, 테스트 이름을 기대 결과로 잡으면 그대로 읽힌다.
- 테스트하기 쉬운 코드의 조건은 대상이 순수한 것이다. 순수 함수 파이프라인은 기댓값 한 줄, 실제값 한 줄, 비교 한 줄로 검증이 끝난다.
- 레코드의 구조적 동등성 덕분에 `=` 나 `Assert.Equal` 하나로 필드 전체를 비교할 수 있다.
- 어서션은 xUnit 의 `Assert.Equal(expected, actual)` 이나 FsUnit 의 `actual |> should equal expected` 중 무엇을 써도 된다. 테스트 러너는 어느 쪽이든 xUnit 이다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Getting Started — 솔루션과 프로젝트 만들기 | p.52 (명령은 부록 1, pp.195-196) | — |
| Solutions and Projects — 경계를 나누는 두 단위 | p.52 | — |
| Adding a Source File — 파일을 추가하면 순서를 적어야 한다 | pp.52-53 | `04-order` |
| Namespaces and Modules — 이름을 정리하는 두 장치 | pp.53-56 | `04-modules` |
| Writing Tests — 첫 테스트와 이중 백틱 이름 | pp.56-57 | — |
| Writing Real Tests — 테스트할 대상을 두고 짜기 | pp.57-61 | `04-learners` |
| Using FsUnit for Assertions — 어서션 문장을 파이프로 | pp.61-62 | — |
| Summary — 원서의 챕터 요약 | p.62 | — |
