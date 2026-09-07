# 17 - 부록 1: VS Code 에서 솔루션과 프로젝트 만들기 (원서 pp.195-196)

> 원서 4챕터(p.52)는 솔루션(solution)과 프로젝트(project)를 먼저 만들어 두라고만 하고 실제 명령은 이 부록으로 넘긴다. 그래서 이 부록은 개념을 설명하는 곳이 아니라 명령을 순서대로 늘어놓은 곳이다. 이 노트도 그 성격을 그대로 지킨다. 솔루션과 프로젝트가 각각 무엇이고 F# 의 컴파일 순서가 왜 `.fsproj` 에 적히는지는 4챕터 노트에 있고, 편집기와 SDK 설치는 서문 챕터에 있다. 여기서는 셸에 무엇을 치면 4챕터 실습 환경이 만들어지는지만 다룬다. 아래 명령은 전부 .NET SDK 10.0.111 에서 실제로 돌려 확인했다.

## 이 부록의 자리 (원서 p.195)

- 원서가 만드는 구조는 솔루션 하나에 프로젝트 둘이다. 코드용 콘솔 프로젝트와 테스트용 xUnit 프로젝트를 각각 `src/` 와 `tests/` 아래에 둔다.
- 원서는 이 절차를 편집기 조작으로 안내한다. 텍스트 파일에 명령을 적어 두고 그것을 선택해 통합 터미널로 보내는 방식이다. 명령 자체는 `dotnet` CLI 이므로 편집기 없이 셸에서 그대로 돌려도 결과가 같다.
- 이 노트는 프로젝트 이름을 4챕터 노트와 맞춰 `ShopSolution`, `Shop`, `ShopTests` 로 쓴다. 원서의 `MySolution`, `MyProject`, `MyProjectTests` 자리에 그대로 대응한다. 이름은 무엇으로 잡아도 되지만, 콘솔 프로젝트와 테스트 프로젝트의 디렉터리 이름이 곧 프로젝트 이름이 되고 그 이름이 어셈블리 이름까지 결정한다는 점만 기억하면 된다.

## VS Code 쪽 조작 — 실행으로 확인할 수 없는 부분 (원서 pp.195-196)

아래 항목은 편집기 기능이라 셸에서 확인할 수 없다. 절차는 원서를 따라 적었고, 적어 둔 단축키는 현재 VS Code 문서의 기본값이다.

- 빈 디렉터리에서 시작한다. 그 디렉터리에서 `code .` 로 열면 거기가 VS Code 의 작업 폴더가 된다.
- 통합 터미널을 새로 연다. VS Code 의 기본값은 `CTRL+SHIFT+백틱` 이고, 이미 열린 패널을 접었다 펴는 것은 `CTRL+백틱` 이다. 원서가 적은 것은 `CTRL+SHIFT+'` 로 백틱이 아니라 따옴표다. 원서가 어느 키를 가리켰는지는 확인할 방법이 없으니 편집기 기본값을 따르면 된다.
- 명령을 적어 둔 파일에서 프로젝트 이름을 한꺼번에 바꿀 때 `CTRL+F2` 를 쓴다. 선택한 낱말과 같은 낱말 전부를 동시에 편집하는 Change All Occurrences 기능이다.
- 선택한 텍스트를 터미널로 보내는 길은 둘이다. Terminal 메뉴의 Run Selected Text 항목을 고르거나, `CTRL+SHIFT+P` 로 명령 팔레트를 열고 Terminal: Run Selected Text in Active Terminal 을 고른다.
- Ionide 확장 설치는 서문 챕터에서 다뤘으므로 여기서 반복하지 않는다. 부록 1 자체는 확장을 언급하지 않는다.

## 한 번에 돌리는 스크립트 (원서 pp.195-196)

원서처럼 명령을 파일에 모아 두는 방식을 쓴다면 확장자를 `.txt` 대신 `.sh` 로 잡고 셸에 파일째로 넘기는 편이 안전하다. 선택 텍스트를 터미널로 보내는 방식은 앞 명령이 실패해도 뒤 명령이 계속 실행되기 때문이다. 맨 앞의 `set -euo pipefail` 이 그 문제를 막는다. 다만 이 줄은 파일에 넣어 `bash setup.sh` 로 돌릴 때만 쓴다. 통합 터미널에 골라 보내면 뒤이어 실패하는 명령 하나에 그 터미널이 닫힌다.

```bash
# setup.sh — 빈 디렉터리에서 bash setup.sh 로 실행한다
set -euo pipefail

dotnet new sln -o ShopSolution
cd ShopSolution
mkdir src tests

dotnet new console -lang "F#" -o src/Shop
dotnet new xunit -lang "F#" -o tests/ShopTests
dotnet sln add src/Shop/Shop.fsproj tests/ShopTests/ShopTests.fsproj

dotnet add tests/ShopTests/ShopTests.fsproj reference src/Shop/Shop.fsproj
dotnet add tests/ShopTests/ShopTests.fsproj package FsUnit.xUnit --version 7.1.1

dotnet build
dotnet test
```

- 원서 스크립트와 달라진 점 가운데 짚어 둘 것이 셋이다. 첫째, 테스트 프로젝트로 `cd` 해 들어가는 대신 `dotnet add <프로젝트 경로> reference|package` 형태를 썼다. 스크립트가 끝난 뒤 셸이 어디에 서 있는지 헷갈릴 일이 없다. 둘째, `FsUnit` 패키지를 넣지 않고 `FsUnit.xUnit` 하나만 넣었다(이유는 4챕터 노트에 적었다). 셋째, 버전을 고정했다.
- 이 밖에 `mkdir` 두 줄과 `dotnet sln add` 두 줄을 각각 한 줄로 묶었다(`dotnet sln add` 를 한 번만 불러도 되는 이유는 아래 절에 적었다).
- 스크립트를 파일로 만들었다면 실행한 뒤 지워도 된다. 만들어진 것은 솔루션과 프로젝트 쪽이고 스크립트 자체는 남을 필요가 없다.
- 이 스크립트는 같은 자리에서 두 번 돌릴 수 없다. `dotnet new sln` 이 기존 `.slnx` 를 덮어쓰겠다는 확인을 요구하며 종료 코드 73 으로 멈추고, `set -e` 때문에 뒤 명령은 실행되지 않는다. 메시지가 안내하는 `--force` 를 붙이면 `dotnet new sln` 이 기존 파일을 덮어쓰고 넘어간다. 스크립트를 부분적으로 골라 다시 돌리면 `mkdir src tests` 도 실패한다. 다시 만들 때는 솔루션 디렉터리를 지우고 처음부터 돌리는 것이 깔끔하다.
- CLI 메시지는 셸 로케일을 따라 번역돼 나온다. 아래 인용은 `DOTNET_CLI_UI_LANGUAGE=en` 을 붙여 얻은 영어 출력이다.

## 명령을 하나씩 확인하기 (원서 pp.195-196)

솔루션 파일부터 만든다.

```bash
dotnet new sln -o ShopSolution
cd ShopSolution
```

- 만들어지는 파일은 `ShopSolution/ShopSolution.slnx` 다. 내용은 빈 껍데기 두 줄이다.

```xml
<Solution>
</Solution>
```

- 예전 `.sln` 형식이 필요하면 `dotnet new sln -f sln -o ShopSolution` 처럼 형식을 지정한다. 그러면 `ShopSolution.sln` 이 생긴다. 두 형식 중 무엇을 써도 이 부록의 나머지 명령은 같다.
- 템플릿 짧은 이름은 `dotnet new list --language "F#"` 출력의 Short Name 칸에서 확인한다. 이 부록에서 쓰는 것은 `console` 과 `xunit` 이다.

디렉터리 둘과 프로젝트 둘을 만들어 솔루션에 넣는다.

```bash
mkdir src tests
dotnet new console -lang "F#" -o src/Shop
dotnet new xunit -lang "F#" -o tests/ShopTests
dotnet sln add src/Shop/Shop.fsproj tests/ShopTests/ShopTests.fsproj
```

- 여기까지 생긴 파일은 넷이다. `src/Shop/Program.fs`, `src/Shop/Shop.fsproj`, `tests/ShopTests/Tests.fs`, `tests/ShopTests/ShopTests.fsproj`.
- `dotnet sln add` 는 프로젝트 경로를 여러 개 받으므로 한 번만 호출하면 된다. 넣고 나면 `.slnx` 가 이렇게 채워진다. 경로의 `src`, `tests` 를 보고 같은 이름의 솔루션 폴더를 만들어 준다.

```xml
<Solution>
  <Folder Name="/src/">
    <Project Path="src/Shop/Shop.fsproj" />
  </Folder>
  <Folder Name="/tests/">
    <Project Path="tests/ShopTests/ShopTests.fsproj" />
  </Folder>
</Solution>
```

- 이 폴더 항목은 편집기의 솔루션 탐색기에 보이는 분류일 뿐이다. F# 의 컴파일 순서를 결정하는 것은 각 프로젝트의 `.fsproj` 이고, 솔루션에 프로젝트를 적은 순서와는 무관하다.
- 경로에서 솔루션 폴더를 만드는 것은 SDK 10 에서 새로 생긴 동작이 아니다. `dotnet sln add` 의 `--in-root` 가 이 동작을 끄는 옵션이고 기본값은 끄지 않는 쪽이다. `-f sln` 으로 만든 `.sln` 에도 같은 폴더가 SolutionFolder 항목과 NestedProjects 절로 들어간다. SDK 10 에서 달라진 것은 그 폴더를 적는 표기뿐이다.
- 등록 결과는 `dotnet sln list` 로 확인한다. 같은 프로젝트를 두 번 넣으면 already contains 메시지만 찍히고 종료 코드는 0 이다. 스크립트를 부분적으로 골라 다시 돌려도 이 명령은 걸림돌이 되지 않는다.

테스트 프로젝트에 참조와 어서션(assertion) 라이브러리를 붙인다.

```bash
dotnet add tests/ShopTests/ShopTests.fsproj reference src/Shop/Shop.fsproj
dotnet add tests/ShopTests/ShopTests.fsproj package FsUnit.xUnit --version 7.1.1
```

- 두 명령을 돌린 뒤 `tests/ShopTests/ShopTests.fsproj` 에서 패키지 `<ItemGroup>` 과 프로젝트 참조 `<ItemGroup>` 이 이렇게 된다. `FsUnit.xUnit` 은 템플릿이 만들어 둔 패키지 `<ItemGroup>` 안에 이름 순으로 끼어들고, 새 `<ItemGroup>` 을 얻는 것은 프로젝트 참조 쪽뿐이다. 파일 앞쪽의 `<Compile Include="Tests.fs" />` 항목은 그대로다.

```xml
<ItemGroup>
  <PackageReference Include="coverlet.collector" Version="6.0.4" />
  <PackageReference Include="FsUnit.xUnit" Version="7.1.1" />
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
  <PackageReference Include="xunit" Version="2.9.3" />
  <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
</ItemGroup>

<ItemGroup>
  <ProjectReference Include="..\..\src\Shop\Shop.fsproj" />
</ItemGroup>
```

- 블록에 적힌 템플릿 패키지 버전은 SDK 10.0.111 의 xUnit 템플릿 기준이다.
- 원서 스크립트는 패키지 이름을 `FsUnit.XUnit` 으로 적었다. NuGet 은 패키지 이름의 대소문자를 구분하지 않으므로 그대로 써도 복원은 되고, CLI 가 등록된 이름인 `FsUnit.xUnit` 으로 바꿔 적어 준다. 이 노트와 4챕터 노트는 등록된 이름 쪽을 쓴다.
- 참조 방향은 테스트 프로젝트에서 코드 프로젝트로 한 방향뿐이다. 반대로 걸면 어떻게 되는지는 4챕터 노트에 적었다.

빌드하고 테스트를 돌린다. 둘 다 솔루션 디렉터리에서 실행하면 솔루션에 든 프로젝트 전부가 대상이 된다.

```bash
dotnet build
dotnet test
```

- 빌드는 경고 없이 끝나고 어셈블리 둘이 나온다. `src/Shop/bin/Debug/net10.0/Shop.dll` 과 `tests/ShopTests/bin/Debug/net10.0/ShopTests.dll` 이다.
- 잡히는 테스트는 xUnit 템플릿이 만들어 둔 `My test` 하나다. 여기까지 오면 환경이 완성된 것이다.

```
Passed!  - Failed:     0, Passed:     1, Skipped:     0, Total:     1, Duration: 29 ms - ShopTests.dll (net10.0)
```

- 콘솔 프로젝트를 돌리려면 `dotnet run --project src/Shop` 을 쓴다. 앞의 `dotnet add` 와 같은 이유로 `cd` 를 피한 형태이고, 4챕터 노트가 쓴 `cd src/Shop` 뒤 `dotnet run` 과 결과가 같다. 템플릿이 넣은 한 줄이 `Hello from F#` 을 출력한다.

## 만든 환경에 파일을 얹어 보기 (노트 보충)

절차가 제대로 끝났는지는 파일을 하나씩 더해 보면 확실해진다. 4챕터의 실습이 바로 이 단계에서 시작한다. 아래 함수는 그 자리에 넣어 볼 가장 작은 예다.

```fsharp id=17-shipping
// 이 단위가 보여주는 것: src/Shop/Shipping.fs 에 넣을 순수 함수와 그 결과 확인
// 실제 파일이라면 첫 줄이 module Shop.Shipping 이지만, FSI 로 검증하려고 선언 없이 적었다

// float -> int
let feeFor weightKg =
    if weightKg <= 0.5 then 2500
    elif weightKg <= 5.0 then 4000
    else 4000 + int (ceil (weightKg - 5.0)) * 800

printfn "%-7s %d" "0.4kg" (feeFor 0.4)   // 기대: 0.4kg   2500
printfn "%-7s %d" "3.0kg" (feeFor 3.0)   // 기대: 3.0kg   4000
printfn "%-7s %d" "7.2kg" (feeFor 7.2)   // 기대: 7.2kg   6400
```

- 마지막 값은 이렇게 나온다. 5kg 초과분 2.2kg 을 `ceil` 로 3kg 으로 올리고 800 을 곱해 2400 을 얻은 뒤, 기본 요금 4000 에 더한다.

이 코드를 `src/Shop/Shipping.fs` 로 저장했다면 `Shop.fsproj` 의 컴파일 목록에 적어야 한다. 자리는 `Program.fs` 앞이다. `Program.fs` 에서 `feeFor` 를 부른다면 정의가 앞에 와야 하고, 부르지 않아도 순서를 뒤집으면 빌드가 실패한다. 템플릿이 만든 `Program.fs` 에는 모듈 선언이 없다. 선언을 생략할 수 있는 파일은 마지막 하나뿐이므로 `Shipping.fs` 를 뒤에 적으면 오류 FS0222 가 난다. 이 규칙은 4챕터 노트에 있다.

```xml
<ItemGroup>
  <Compile Include="Shipping.fs" />
  <Compile Include="Program.fs" />
</ItemGroup>
```

- 템플릿이 만든 `.fsproj` 와 `.fs` 는 BOM 이 붙은 UTF-8 이다(`.slnx` 는 BOM 이 없고 `-f sln` 으로 만든 `.sln` 에는 있다). BOM 을 떼도 빌드는 성공하므로 인코딩 자체가 문제가 되지는 않는다. 걸리는 자리는 스크립트로 문자열을 치환하는 대목이다. BOM 세 바이트가 첫 줄 맨 앞에 있어서 `^<Project` 처럼 줄 앞을 잡는 패턴이 아무 말 없이 안 맞는다. 편집기로 고칠 때는 이 문제가 없다.
- 파일 생성과 목록 등록을 한 번에 하려면 Ionide 의 F# 솔루션 탐색기를 쓴다. 이 기능과 컴파일 순서 규칙은 4챕터 노트에서 다뤘다.

테스트 쪽도 같다. `tests/ShopTests/ShippingTests.fs` 를 만들고 `ShopTests.fsproj` 의 목록에 `Tests.fs` 다음으로 적는다. 이 블록은 `namespace` 로 시작하므로 `.fsx` 로는 돌릴 수 없다(오류 FS0010). 그래서 실행 단위에서 빼고 파일 모양만 적었다.

```fsharp
namespace ShopTests

open Xunit
open FsUnit.Xunit
open Shop.Shipping

module ``배송비를 계산하면`` =

    [<Fact>]
    let ``0.5kg 이하는 소형 요금이다`` () =
        feeFor 0.4 |> should equal 2500

    [<Fact>]
    let ``5kg 를 넘으면 초과분에 kg 당 요금이 붙는다`` () =
        feeFor 7.2 |> should equal 6400
```

- `open` 할 이름은 `FsUnit.Xunit` 이다. 원서 본문의 `open FsUnit` 은 NUnit 쪽이라 이 프로젝트에서는 `should` 가 보이지 않는다. 4챕터 노트에 자세히 적었다.
- 다시 `dotnet test` 를 돌리면 템플릿 테스트까지 셋이 통과한다. 여기까지 확인했으면 부록의 역할은 끝이다.

```
Passed!  - Failed:     0, Passed:     3, Skipped:     0, Total:     3, Duration: 62 ms - ShopTests.dll (net10.0)
```

## 원서와 달라진 점 (노트 보충)

원서는 2023년 1월 판이고 아래 표는 SDK 10.0.111 에서 실측한 결과다. 원서 이후 달라진 것과 이 노트가 달리 잡은 것을 함께 적었다. 명령 이름과 순서는 원서 그대로 유효하다.

| 항목 | 원서 | SDK 10.0.111 |
|---|---|---|
| `dotnet new sln` 산출물 | `.sln` | `.slnx`(XML). 예전 형식은 `-f sln` |
| `dotnet sln add` 결과 표기 | `.sln` 의 SolutionFolder 항목과 NestedProjects 절 | `.slnx` 의 `<Folder Name="/src/">` |
| 대상 프레임워크 | `net5.0`(원서가 인쇄한 유일한 값. 원서가 쓴 SDK 6.0.x 를 따르면 `net6.0`) | `net10.0` |
| 어서션 패키지 | `FsUnit` 과 `FsUnit.XUnit` 둘 | `FsUnit.xUnit` 7.1.1 하나로 충분하다 |

## 정리

- 이 부록의 알맹이는 여덟 단계다. 솔루션 만들기, 디렉터리 둘 만들기, 프로젝트 둘 만들기, 솔루션에 넣기, 참조 걸기, 패키지 넣기, 빌드, 테스트.
- 원서처럼 명령을 파일에 모아 둘 때는 `.sh` 로 만들어 `set -euo pipefail` 을 맨 앞에 두고 파일째로 실행한다. 선택 텍스트를 터미널로 보내는 방식은 중간에 실패해도 멈추지 않는다.
- `cd` 대신 `dotnet add <프로젝트 경로> reference|package` 형태를 쓰면 스크립트가 끝난 뒤 셸 위치가 그대로 남는다.
- SDK 10 에서 달라진 것은 `dotnet new sln` 의 산출물이 `.slnx` 라는 점이다. `dotnet sln add` 가 경로에서 솔루션 폴더를 만드는 것은 예전 `.sln` 에서도 같고 적는 표기만 다르다. 이 폴더 항목은 분류일 뿐이고 F# 컴파일 순서와 관계가 없다.
- 어서션 패키지는 `FsUnit.xUnit` 하나로 충분하고, xUnit 테스트에서 여는 이름은 `FsUnit.Xunit` 이다.
- 이 부록은 개념을 설명하는 곳이 아니다. 산출물을 짚는 데 필요한 만큼만 규칙을 언급했다. 솔루션과 프로젝트의 경계, `.fsproj` 의 컴파일 순서, 네임스페이스와 모듈, 테스트 작성은 4챕터 노트로 간다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| 이 부록의 자리 | p.195 | — |
| VS Code 쪽 조작 — 실행으로 확인할 수 없는 부분 | pp.195-196 | — |
| 한 번에 돌리는 스크립트 | pp.195-196 | — |
| 명령을 하나씩 확인하기 | pp.195-196 | — |
| 만든 환경에 파일을 얹어 보기 | (노트 보충) | `17-shipping` |
| 원서와 달라진 점 | (노트 보충) | — |
