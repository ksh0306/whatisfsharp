# 13 - Giraffe 로 웹 프로그래밍 시작하기 (원서 pp.166-177)

> 여기서부터 마지막 세 챕터는 앞에서 배운 것을 웹 애플리케이션 하나에 얹는다. 도구는 Giraffe 다. ASP.NET Core 위에 얇게 덮인 함수형 껍데기이고, 라우팅을 값으로 적고 요청 처리를 함수로 적는다. 이 챕터에서 새로 나오는 문법은 둘이다. 값을 그 자리에서 만드는 익명 레코드(anonymous record) `{| ... |}` 와 핸들러를 이어 붙이는 `>=>` 다. 프로퍼티를 설정하는 할당 연산자 `<-` 와 그 짝인 `mutable` 은 1챕터와 10챕터에서 이미 나왔고, 비동기 작업을 적는 `task` 계산 식(computation expression)은 12챕터가 다뤘다. 이 챕터에서는 그 문법이 웹 애플리케이션을 구성하는 코드에 놓인다. 나머지는 2챕터의 함수 합성, 3챕터의 `Option`·`Result`, 9챕터의 단일 케이스 판별 유니온, 4챕터의 파일 컴파일 순서가 그대로 쓰이는 장면이다. 이 챕터에서 세운 프로젝트를 14챕터가 API 쪽으로, 15챕터가 화면 쪽으로 늘린다.

이 노트가 만드는 것은 옥상 양봉장의 벌통 점검 기록을 보여 주는 `HiveLog` 다. 벌통 코드로 점검 기록을 찾아 JSON 으로 돌려주는 API 와, 소개 문구만 담은 HTML 첫 화면이 이 챕터의 결과물이다.

## Getting Started — 빈 웹 프로젝트 만들기 (원서 pp.166-167)

- 원서는 폴더를 만들고 그 안에서 `dotnet new web -lang F#` 을 실행한다. 이 템플릿은 컨트롤러도 뷰도 없는 최소 웹 애플리케이션이다. 4챕터에서 쓴 `console` 템플릿과의 가장 큰 차이는 프로젝트 SDK 가 `Microsoft.NET.Sdk.Web` 이라는 점이고, 설정 파일 `appsettings.json` 과 실행 프로필 `Properties/launchSettings.json` 이 함께 만들어진다.
- 프로젝트 이름은 폴더 이름에서 온다. 이 노트는 `HiveLog` 로 잡는다. 14·15챕터가 같은 프로젝트를 이어 쓴다.

```bash
mkdir HiveLog
cd HiveLog
dotnet new web -lang "F#"
```

- `-lang "F#"` 은 따옴표를 빼도 동작하지만, 셸에 따라 `#` 이 주석으로 읽힐 수 있으므로 붙여 두는 편이 안전하다(4챕터에서 같은 이야기를 했다).

템플릿이 만든 `Program.fs` 는 다음과 같다. .NET 10.0.111 SDK 의 출력이 원서(2023년 1월판)의 코드와 한 글자도 다르지 않다.

```fsharp
open System
open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.Hosting

[<EntryPoint>]
let main args =
    let builder = WebApplication.CreateBuilder(args)
    let app = builder.Build()

    app.MapGet("/", Func<string>(fun () -> "Hello World!")) |> ignore

    app.Run()

    0 // Exit code
```

- `MapGet` 에는 C# 을 염두에 두고 만든 오버로드가 여럿 있다. 하나는 `RequestDelegate` 를 받고 다른 하나는 `System.Delegate` 를 받는다. F# 은 대상 델리게이트(delegate) 타입이 정해진 자리라면 람다를 자동으로 변환해 주지만, `fun () -> "Hello World!"` 를 그냥 넘기면 `RequestDelegate` 오버로드가 잡혀 `HttpContext` 를 요구하는 `error FS0001` 이 난다. `System.Delegate` 쪽은 어느 델리게이트를 만들지 정할 수 없다. 그래서 `Func<string>(...)` 으로 이름을 대 준다. 이 어색함이 Giraffe 를 쓰는 이유 중 하나다.
- `MapGet` 은 결과를 돌려주므로 `|> ignore` 로 버린다. 값을 버리지 않으면 경고 FS0020 이 난다.
- `[<EntryPoint>]` 가 붙은 함수는 프로젝트의 마지막 파일에 있어야 한다. 4챕터에서 본 컴파일 순서 규칙이 여기서도 그대로 적용된다.

프로젝트 파일은 이렇게 생겼다.

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>

</Project>
```

실행은 `dotnet run` 이다. 종료는 그 터미널에서 `CTRL+C` 다.

```bash
dotnet run
```

```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5291
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Development
```

- 포트 번호는 템플릿이 프로젝트를 만들 때 무작위로 정하고 `Properties/launchSettings.json` 에 적어 둔다. 그 파일에는 `http` 와 `https` 두 프로필이 들어 있고 `dotnet run` 은 첫 프로필인 `http` 를 쓴다. HTTPS 로 띄우려면 `dotnet run --launch-profile https` 다.
- 원서는 실행 로그에 URL 두 개가 나오는 화면을 보여 준다. 기본 프로필 `http` 의 `applicationUrl` 에는 URL 이 하나뿐이라 한 줄만 나오는 것이고, `https` 프로필로 띄우면 그 프로필의 `applicationUrl` 에 URL 이 둘이라 원서와 같이 두 줄이 나온다. 원서 화면과 다르다고 잘못 만든 것이 아니다.

## Using Giraffe — 패키지와 시작 코드 (원서 pp.168-169)

- Giraffe 는 두 조각으로 나뉘어 있다. 라우팅과 핸들러가 들어 있는 `Giraffe`, HTML 을 만드는 `Giraffe.ViewEngine` 이다. 이 챕터는 둘을 다 쓴다.
- 패키지 버전을 적어 두면 나중에 같은 코드를 다시 받아 돌릴 때 결과가 흔들리지 않는다. 이 노트는 `Giraffe` 8.3.0, `Giraffe.ViewEngine` 1.4.0 으로 확인했다.

```bash
dotnet add package Giraffe --version 8.3.0
dotnet add package Giraffe.ViewEngine --version 1.4.0
```

```xml
  <ItemGroup>
    <PackageReference Include="Giraffe" Version="8.3.0" />
    <PackageReference Include="Giraffe.ViewEngine" Version="1.4.0" />
  </ItemGroup>
```

Giraffe 를 쓰는 `Program.fs` 의 뼈대는 다음 세 조각이다. 각 조각의 속은 뒤 절에서 하나씩 채운다.

```fsharp
let configureServices (services: IServiceCollection) = ...   // 서비스 등록
let configureApp (appBuilder: IApplicationBuilder) = ...     // 요청 처리 순서
[<EntryPoint>]
let main args = ...                                          // 호스트 시작
```

- 최소 템플릿보다 코드가 길어지는 것은 Giraffe 탓이 아니다. 최소 템플릿이 생략한 서비스 등록과 요청 처리 순서를 직접 적기 때문이다. ASP.NET Core 를 다뤄 본 독자에게는 익숙한 두 함수다.
- `configureServices` 는 의존성 주입(dependency injection) 컨테이너에 무엇을 넣을지 정한다. 라우팅과 Giraffe 를 등록한다.
- `configureApp` 은 요청이 지나갈 미들웨어(middleware)의 순서를 정한다. 이 순서를 미들웨어 파이프라인(middleware pipeline)이라 부른다. 2챕터에서 `|>` 로 값을 흘려보낸 함수 파이프라인과는 다른 것이므로 줄여 쓰지 않고 온낱말로 적는다. 순서가 곧 동작이다. 라우팅을 먼저 켜고, Giraffe 엔드포인트를 등록하고, 어느 엔드포인트에도 걸리지 않은 요청을 받을 핸들러를 마지막에 둔다.
- 원서 코드에는 `if app.Environment.IsDevelopment() then app.UseDeveloperExceptionPage()` 가 들어 있다. 현재 SDK 에서는 `WebApplication` 이 개발 환경일 때 이 미들웨어를 자동으로 넣는다. 일부러 예외를 던지는 경로를 만들어 확인해 보면, 그 호출을 지워도 예외 화면이 그대로 나오고 스택 추적에 `DeveloperExceptionPageMiddlewareImpl` 이 찍힌다. 남겨 두어도 해가 없지만 없어도 같다.

## 이 노트의 예제를 돌리는 방법 (노트 보충)

- 앞선 챕터들의 예제는 `dotnet fsi` 로 검증했다. 웹 서버도 같은 방식으로 검증할 수 있다. 스크립트 안에서 서버를 띄우고, 같은 스크립트에서 `HttpClient` 로 요청을 보내 응답을 찍고, 서버를 내리면 된다. 이 노트의 `13-server` 실행 단위가 그것이다.
- 준비 코드가 하나 필요하다. FSI 는 ASP.NET Core 공유 프레임워크를 자동으로 참조하지 않는다. `#r "nuget: Giraffe, 8.3.0"` 만 적고 `open Microsoft.AspNetCore.Builder` 를 쓰면 `error FS0039: 'AspNetCore' 네임스페이스가 정의되지 않았습니다` 가 난다. 패키지가 프레임워크 참조(`FrameworkReference`)로 ASP.NET Core 를 요구하는데 FSI 의 패키지 해석은 그 요구를 채워 주지 않기 때문이다.
- 그래서 설치된 공유 프레임워크를 스크립트가 직접 찾아 참조한다. 선행 요구사항은 두 가지다. ASP.NET Core 공유 프레임워크가 포함된 .NET SDK(이 노트는 10.0.111 로 확인했다), 그리고 처음 한 번 패키지를 받아 올 네트워크다. 받아 오지 못하면 `error FS0999` 로 실패한다.
- `#r` 로 적는 어셈블리 10개는 SDK 버전이 정한 목록이 아니라 이 챕터의 코드가 타입 이름을 직접 적는 어셈블리다. 코드가 다른 네임스페이스를 건드리면 그만큼 줄을 더해야 한다. 실행 중에만 필요한 어셈블리는 아래 (2)의 해석기가 채우므로 적지 않아도 된다.
- 프로젝트를 만들어 `dotnet run` 으로 확인하는 것이 실제 개발 방식이다. 아래 준비 코드는 노트의 예제를 자동으로 검증하기 위한 장치일 뿐, `Program.fs` 에는 들어가지 않는다.

```fsharp id=13-server
// 이 단위가 보여주는 것: 스크립트에서 Giraffe 앱을 띄워 응답까지 확인하기
// 준비 코드 — Program.fs 에는 들어가지 않는다
open System
open System.IO
open System.Runtime.Loader

// (1) 설치된 ASP.NET Core 공유 프레임워크에서 실행 중인 런타임과 같은 계열의 가장 높은 버전을 고른다
let sharedFramework =
    let core =
        Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory().TrimEnd(Path.DirectorySeparatorChar)
        |> DirectoryInfo
    // 폴더 이름을 문자열로 비교하면 10.0.9 가 10.0.11 보다 크므로 Version 으로 비교한다
    let version (path: string) =
        match Version.TryParse((Path.GetFileName path).Split('-')[0]) with
        | true, v -> v
        | _ -> Version(0, 0)
    let root = Path.Combine(core.Parent.Parent.FullName, "Microsoft.AspNetCore.App")
    if not (Directory.Exists root) then
        failwithf "ASP.NET Core 공유 프레임워크 폴더가 없다: %s. 이 폴더가 포함된 .NET SDK 가 필요하다." root
    let candidates = Directory.GetDirectories root |> Array.sortBy version
    match candidates |> Array.filter (fun d -> (version d).Major = (version core.FullName).Major) with
    | [||] -> Array.last candidates
    | sameLine -> Array.last sameLine

// (2) 실행 중 찾지 못한 어셈블리는 그 폴더에서 직접 읽게 한다
AssemblyLoadContext.Default.add_Resolving(
    Func<AssemblyLoadContext, Reflection.AssemblyName, Reflection.Assembly>(fun context name ->
        let dll = Path.Combine(sharedFramework, name.Name + ".dll")
        if File.Exists dll then context.LoadFromAssemblyPath dll else null))

// (3) #r 은 문자열 리터럴만 받으므로 참조할 어셈블리를 스크립트 폴더 옆에 링크한다(안 되면 복사)
let referenceDir = Path.Combine(__SOURCE_DIRECTORY__, "aspnetcore")
Directory.CreateDirectory referenceDir |> ignore
for name in [ "Microsoft.AspNetCore"
              "Microsoft.AspNetCore.Hosting"
              "Microsoft.AspNetCore.Hosting.Abstractions"
              "Microsoft.AspNetCore.Http"
              "Microsoft.AspNetCore.Http.Abstractions"
              "Microsoft.AspNetCore.Routing"
              "Microsoft.Extensions.DependencyInjection.Abstractions"
              "Microsoft.Extensions.Hosting.Abstractions"
              "Microsoft.Extensions.Logging"
              "Microsoft.Extensions.Logging.Abstractions" ] do
    let source = Path.Combine(sharedFramework, name + ".dll")
    if not (File.Exists source) then
        failwithf "%s.dll 을 %s 에서 찾지 못했다." name sharedFramework
    let target = Path.Combine(referenceDir, name + ".dll")
    if not (File.Exists target) then
        try File.CreateSymbolicLink(target, source) |> ignore
        with _ -> File.Copy(source, target, true)

printfn "ASP.NET Core %s" (Path.GetFileName sharedFramework)   // ASP.NET Core 10.0.11
```

- (1)의 계산은 `Microsoft.NETCore.App/10.0.11` 옆에 `Microsoft.AspNetCore.App/10.0.11` 이 있다는 배치를 이용한다. 두 프레임워크의 버전이 항상 같다고 보장되지 않으므로, 실행 중인 런타임과 메이저 버전이 같은 폴더 가운데 가장 높은 것을 고른다. 폴더 이름을 문자열로 비교하면 `10.0.9` 가 `10.0.11` 보다 크게 나오므로 `Version` 으로 비교해야 한다.
- (2)의 해석기가 없으면 실행 중에 `FileNotFoundException` 이 난다. FSI 의 기본 로드 컨텍스트(`AssemblyLoadContext.Default`)는 런타임 폴더와 명시적으로 준 어셈블리 쪽만 뒤지고 ASP.NET Core 공유 프레임워크 폴더는 뒤지지 않는다. `#r` 로 적은 10개가 다시 끌어오는 어셈블리는 50개가 넘는데(Kestrel, Configuration, Options, Primitives 같은 것들) 그 어셈블리가 모두 그 폴더에만 있다. 이름만 보고 그 폴더에서 찾아 주면 해결된다. 해석기가 `null` 을 돌려주는 것은 "나는 모른다"는 뜻이고, 그러면 로더가 다음 방법을 시도한다 — `Giraffe` 처럼 NuGet 캐시에서 오는 어셈블리는 그 경로로 해결된다.
- (3)에서 링크를 만드는 것은 `#r` 이 문자열 리터럴만 받기 때문이다. 실행 중에 계산한 경로를 `#r` 에 직접 넘길 수는 없으므로, 스크립트 폴더 옆에 정해진 이름으로 걸어 두고 상대 경로로 참조한다. 원본이 없어도 링크는 조용히 만들어지므로 원본이 있는지 먼저 확인하고, 없으면 그 자리에서 어느 어셈블리가 빠졌는지 알리며 실패한다. 링크가 막힌 환경에서는 복사로 넘어간다. `#r` 줄을 담은 스크립트를 만들어 `#load` 하는 방법도 있지만, 참조하는 어셈블리가 노트에 그대로 보이는 쪽을 택했다.

준비가 끝나면 참조와 `open` 을 적는다. 여기부터는 프로젝트의 `Program.fs` 와 같은 코드다.

```fsharp id=13-server
#r "aspnetcore/Microsoft.AspNetCore.dll"
#r "aspnetcore/Microsoft.AspNetCore.Hosting.dll"
#r "aspnetcore/Microsoft.AspNetCore.Hosting.Abstractions.dll"
#r "aspnetcore/Microsoft.AspNetCore.Http.dll"
#r "aspnetcore/Microsoft.AspNetCore.Http.Abstractions.dll"
#r "aspnetcore/Microsoft.AspNetCore.Routing.dll"
#r "aspnetcore/Microsoft.Extensions.DependencyInjection.Abstractions.dll"
#r "aspnetcore/Microsoft.Extensions.Hosting.Abstractions.dll"
#r "aspnetcore/Microsoft.Extensions.Logging.dll"
#r "aspnetcore/Microsoft.Extensions.Logging.Abstractions.dll"
#r "nuget: Giraffe, 8.3.0"
#r "nuget: Giraffe.ViewEngine, 1.4.0"

open System.Globalization
open System.Text.Encodings.Web
open System.Text.Json
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Http
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Logging
open Giraffe
open Giraffe.EndpointRouting
open Giraffe.ViewEngine
```

- `open Giraffe` 는 핸들러(`text`, `json`, `htmlView`, `RequestErrors`)를, `open Giraffe.EndpointRouting` 은 라우팅 함수(`GET`, `route`, `routef`, `subRoute`)를, `open Giraffe.ViewEngine` 은 HTML 요소 함수를 들여온다. 세 개를 다 열어야 이 챕터의 코드가 컴파일된다.

도메인은 벌통과 점검 기록이다. 코드는 9챕터의 단일 케이스 판별 유니온으로 감싸고, 찾기 실패는 3챕터의 `Result` 로 돌려준다.

```fsharp id=13-server
type HiveCode = HiveCode of string

type Hive = {
    Code: HiveCode
    Frames: int
    LastCheckedOn: DateOnly
    QueenSeen: bool
}

let hives =
    [ { Code = HiveCode "H-07"; Frames = 8; LastCheckedOn = DateOnly(2026, 4, 12); QueenSeen = true }
      { Code = HiveCode "H-11"; Frames = 10; LastCheckedOn = DateOnly(2026, 4, 19); QueenSeen = false } ]

// FSI 실측: code: string -> Result<Hive,string>
let findHive (code: string) : Result<Hive, string> =
    hives
    |> List.tryFind (fun hive -> hive.Code = HiveCode(code.ToUpperInvariant()))
    |> Option.map Ok
    |> Option.defaultWith (fun () -> Error $"등록되지 않은 벌통 코드: {code}")
```

- 저장소는 지금 메모리 안의 리스트다. 14챕터가 이 자리를 손볼 것이므로, 조회 경로를 `findHive` 하나로 좁혀 두었다.
- `Option` 을 `Result` 로 바꾸는 두 줄은 3챕터에서 본 형태다. 실패에 이유를 담아야 하는데 `tryFind` 는 이유를 알려 주지 않으므로, 없다는 사실을 메시지로 바꿔 붙인다. 메시지는 값을 끝에 두는 모양으로 적었다. `{code}` 뒤에 `은`/`는` 을 붙이면 코드가 `H-11` 일 때와 `H-12` 일 때 맞는 조사가 달라지는데 문자열 보간은 그것을 가릴 수 없다. `Option.defaultValue` 는 대안 값을 미리 만들어 두고 `Option.defaultWith` 는 없을 때만 만든다. 여기서는 문자열 하나라 차이가 없지만, 대안 값을 만드는 데 비용이 든다면 뒤쪽을 골라야 한다.

## Mutability — 가변 바인딩과 할당 연산자 (원서 p.169)

- ASP.NET Core 를 설정하려면 .NET 객체의 프로퍼티에 값을 넣어야 한다. 그래서 이 챕터에서 가변(mutable) 바인딩과 할당 연산자 `<-` 를 다시 짚는다. 문법 자체는 1챕터가 `=` 의 세 가지 얼굴을 가르며 이미 보여 주었고, 10챕터는 클래스 본문과 객체 식이 감춰 두는 상태에 썼다. 달라지는 것은 쓰는 자리다. 도메인 코드가 아니라 애플리케이션을 구성하는 코드에서 필요해진다.
- 원서 p.169 는 여기까지 가변을 직접 쓴 적이 없다고 적었는데, 원서 1챕터의 `Multi-purpose = operator` 사이드바(원서 p.14)가 이미 `let mutable myInt = 0` 과 `<-` 를 보여 준다. 이 노트의 1챕터도 그 자리를 따라갔다.
- F# 의 `let` 바인딩은 기본이 불변이다. 값을 바꿀 수 있게 하려면 `mutable` 키워드를 붙인다.
- 값을 바꾸는 연산자는 `<-` 다. `=` 는 F# 에서 비교 연산자이므로 값이 바뀌지 않고 참거짓만 나온다. 이 실수가 위험한 것은 컴파일이 실패하지 않는다는 점이다. 프로젝트에서 `frames = 8` 을 문장으로 적으면 경고 FS0020 이 나는데, 현재 컴파일러의 메시지는 같음 식의 결과가 `bool` 이라 버려진다는 것을 알려 주고 `frames <- expression` 을 쓰라고 대안까지 적어 준다. 경고를 지나치면 아무 일도 하지 않는 코드가 남는다.
- 스크립트에서는 사정이 다르다. 같은 한 줄을 `.fsx` 최상위에 적고 `dotnet fsi` 로 돌려 보면 경고가 아예 나오지 않는다. FSI 가 최상위 식의 결과를 `it` 에 묶어 두므로 버려지는 값으로 보지 않는 것이다. 경고에 기대 이 실수를 잡을 생각이면 프로젝트에서 확인해야 한다.

```fsharp id=13-mutability
// 이 단위가 보여주는 것: 가변 바인딩, 할당 연산자 `<-`, 프로퍼티 설정
let mutable checkedFrames = 0

// = 는 비교다. 값은 그대로 0 이다
printfn "%b" (checkedFrames = 8)   // false
printfn "%d" checkedFrames         // 0
```

`<-` 를 써야 값이 바뀐다.

```fsharp id=13-mutability
checkedFrames <- 8
printfn "%b" (checkedFrames = 8)   // true
printfn "%d" checkedFrames         // 8
```

- .NET 객체의 프로퍼티도 같은 연산자로 설정한다. 객체 쪽에는 `mutable` 을 붙일 일이 없다. 이미 가변이다.

```fsharp id=13-mutability
open System.Text.Json

let options = JsonSerializerOptions(JsonSerializerDefaults.Web)
options.WriteIndented <- true
printfn "%b" options.WriteIndented   // true
```

- 이 절의 내용은 이 챕터 뒤쪽에서 JSON 직렬화기를 설정할 때 그대로 쓰인다. 설정 코드가 가변에 기대는 것은 F# 의 선택이 아니라 .NET 설정 API 의 모양 때문이다. 애플리케이션 코드는 계속 불변으로 쓴다.

## Endpoints — 라우팅을 값으로 적는다 (원서 p.170)

- 엔드포인트 라우팅(endpoint routing)은 ASP.NET Core 의 라우팅 기능에 얹혀 동작한다. 패키지를 들여다보면 5.0.0 에 `Giraffe.EndpointRouting` 이 들어 있고 4.1.0 에는 없다. Giraffe 5 부터 쓸 수 있는 방식이며 이 노트가 쓰는 8.3.0 도 같다.
- 핵심은 라우팅이 값이라는 점이다. 엔드포인트 목록의 타입은 `Endpoint list` 이고, 목록을 만드는 것과 서버에 등록하는 것이 분리되어 있다. 그래서 라우팅 표를 함수로 조립하거나 다른 모듈에서 만들어 넘길 수 있다.
- 이전 방식에서는 라우팅도 `HttpHandler` 였다. `choose [ ... ]` 로 후보를 늘어놓고 요청마다 위에서 아래로 시도해, 처리한 핸들러가 나오면 멈추는 식이었다. 엔드포인트 라우팅은 경로 표를 ASP.NET Core 라우팅에 넘겨 매칭을 그쪽에 맡기고, Giraffe 는 매칭된 뒤의 처리만 맡는다. 그래서 라우팅이 함수가 아니라 값이 되었다.

```fsharp
// 형태만 보이면 이렇다
GET [ route "/path" handler ]        // HTTP 메서드로 묶고, 경로에 핸들러를 붙인다
routef "/hives/%s" handlerTakingOne  // 경로 조각을 핸들러 인자로 넘긴다
subRoute "/api" nestedEndpoints      // 접두 경로를 묶는다
```

- 경로에 붙는 것은 모두 `HttpHandler` 다. Giraffe 가 제공하는 것(`text`, `json`, `htmlView`)을 그대로 쓰거나 직접 만든다.
- `HttpHandler` 는 타입 약어 세 개가 겹쳐 있다. 컴파일러에게 물어보면 이렇게 확인된다.

```fsharp id=13-server
// HttpFuncResult·HttpFunc·HttpHandler 가 무엇의 약어인지 컴파일러로 확인한다
// 타입 약어는 원래 타입과 같은 것이므로, 아래 세 정의가 컴파일된다는 것이 곧 약어가 그 모양이라는 뜻이다
let asHttpFuncResult (t: Threading.Tasks.Task<HttpContext option>) : HttpFuncResult = t
let asHttpFunc (f: HttpContext -> HttpFuncResult) : HttpFunc = f
let asHttpHandler (h: HttpFunc -> HttpContext -> HttpFuncResult) : HttpHandler = h
printfn "세 약어를 컴파일러가 받아들였다"
```

정리하면 세 줄이다.

```fsharp
type HttpFuncResult = Task<HttpContext option>
type HttpFunc = HttpContext -> HttpFuncResult
type HttpHandler = HttpFunc -> HttpContext -> HttpFuncResult
```

- 핸들러는 "다음 핸들러"와 "현재 요청 컨텍스트"를 받아 작업을 돌려준다. 첫 매개변수가 다음 핸들러라서 핸들러를 이어 붙일 수 있다. 이것이 2챕터에서 본 함수 합성과 같은 발상이 웹 코드에 나타난 모습이고, Giraffe 는 핸들러를 이어 붙이는 `>=>` 를 준다.
- 결과가 `Task<HttpContext option>` 인 것도 눈여겨볼 만하다. `None` 은 "이 핸들러가 이 요청을 처리하지 않았다"는 뜻이다. 3챕터에서 없음을 값으로 표현했던 것과 같은 방식이며, 그 덕분에 처리 여부를 예외 없이 판단할 수 있다.

## 404 - Not Found Handler — 못 찾은 요청을 받는 핸들러 (원서 p.170)

- 어느 엔드포인트에도 걸리지 않은 요청에 응답할 핸들러를 따로 만든다. HTTP 상태 코드 404 로 응답하는 것이 관례다.
- `RequestErrors` 모듈이 4xx 응답을 만드는 함수를 담고 있다. `RequestErrors.notFound` 는 다른 핸들러를 받아, 상태 코드를 404 로 정한 뒤 그 핸들러를 부르는 핸들러를 만든다.

```fsharp id=13-server
// FSI 실측: notFoundHandler: HttpHandler
let notFoundHandler : HttpHandler =
    "요청한 경로가 없다"
    |> text
    |> RequestErrors.notFound
```

- 파이프 두 개로 읽으면 뜻이 그대로 드러난다. 문자열을 본문으로 쓰는 핸들러를 만들고, 그것을 404 로 감싼다. `RequestErrors.notFound h` 의 실체는 `setStatusCode 404 >=> h` 다. 상태 코드를 404 로 먼저 정하고 그다음에 안쪽 핸들러가 실행된다. `text` 는 본문과 `Content-Type` 만 건드리고 상태 코드를 건드리지 않으므로 404 가 그대로 남는다. 200 을 나중에 404 로 덮는 것이 아니다 — `>=>` 는 왼쪽이 먼저다.
- 이 핸들러는 엔드포인트 목록에 넣지 않는다. 라우팅 뒤에 놓이는 마지막 미들웨어로 등록한다. 등록 코드는 뒤의 `configureApp` 에 나온다.

## Creating an API Route — json 핸들러와 익명 레코드 (원서 pp.170-171)

- JSON 을 돌려주는 데는 내장 핸들러 `json` 을 쓴다. 넘길 값의 타입은 무엇이든 된다. 원서처럼 익명 레코드를 쓰면 응답 전용 타입을 따로 선언하지 않아도 된다.
- 익명 레코드는 `{| ... |}` 로 그 자리에서 만든다. 이름이 없으므로 타입 선언이 없고, 필드 이름과 값만 적는다.

```fsharp id=13-payload
// 이 단위가 보여주는 것: 익명 레코드와 그 JSON 표현
open System.Text.Json

let payload = {| Hive = "H-07"; Frames = 8; QueenSeen = true |}

// 필드를 적은 순서와 무관하게 같은 타입이다. 구조적 동등성도 레코드와 같다
printfn "%b" (payload = {| Frames = 8; Hive = "H-07"; QueenSeen = true |})   // true
```

- 직렬화 결과를 보면 두 가지가 눈에 띈다. 키가 알파벳 순으로 나오고, `JsonSerializerDefaults.Web` 을 주면 첫 글자가 소문자로 바뀐다.

```fsharp id=13-payload
// 필드 순서는 F# 이 익명 레코드를 만들 때 알파벳 순으로 정렬한 결과다
printfn "%s" (JsonSerializer.Serialize payload)
// {"Frames":8,"Hive":"H-07","QueenSeen":true}

// Giraffe 의 json 핸들러가 쓰는 기본값도 이쪽이다
printfn "%s" (JsonSerializer.Serialize(payload, JsonSerializerOptions(JsonSerializerDefaults.Web)))
// {"frames":8,"hive":"H-07","queenSeen":true}
```

- 응답 본문을 익명 레코드로 만드는 데는 또 하나의 이유가 있다. `System.Text.Json` 은 `Option` 이 아닌 판별 유니온을 직렬화하지 못한다. `HiveCode` 를 그대로 넘기면 `System.NotSupportedException: F# discriminated union serialization is not supported.` 가 나고, 웹에서는 응답 대신 500 을 받게 된다. 감싼 타입을 벗겨 평평한 익명 레코드로 만들어 넘기는 것이 이 문제를 피하는 가장 간단한 방법이다.

이제 API 의 첫 두 경로에 붙일 핸들러를 만든다.

```fsharp id=13-server
// FSI 실측: apiSummaryHandler: HttpHandler
let apiSummaryHandler : HttpHandler =
    setHttpHeader "X-Apiary" "seongsu-rooftop"
    >=> json {| Apiary = "성수 옥상"; Hives = List.length hives |}
```

- `>=>` 가 핸들러 두 개를 이어 붙인다. 왼쪽 핸들러가 응답 헤더를 하나 달고 다음 핸들러를 부르며, 오른쪽 핸들러가 본문을 쓴다. 2챕터에서 본 `>>` 와는 잇는 방식이 다르다. `>>` 는 앞 함수의 결과를 뒤 함수의 입력으로 넘기지만, `>=>` 는 오른쪽 핸들러를 왼쪽 핸들러의 `next` 자리로 넣는다. 그래서 왼쪽이 `next` 를 부르지 않으면 오른쪽은 아예 실행되지 않는다. 상태 코드를 먼저 정하고 본문을 나중에 쓰는 `RequestErrors.notFound` 가 이 순서에 기댄다.
- 이어 붙인 결과의 타입도 `HttpHandler` 다. 그래서 몇 개를 이어도 경로에 붙이는 방법은 달라지지 않는다.

두 번째 핸들러는 벌통 목록을 돌려준다. 여기서는 `HttpContext` 의 확장 멤버를 쓴다.

```fsharp id=13-server
// FSI 실측: hiveListHandler: HttpFunc -> ctx: HttpContext -> HttpFuncResult
let hiveListHandler : HttpHandler =
    fun _ ctx ->
        hives
        |> List.map (fun hive ->
            let (HiveCode code) = hive.Code
            {| Hive = code; Frames = hive.Frames |})
        |> ctx.WriteJsonAsync
```

- `ctx.WriteJsonAsync` 는 값을 JSON 으로 직렬화해 응답 본문에 쓰고, `Content-Type` 을 `application/json` 으로, `Content-Length` 를 맞게 설정한다. 다음 핸들러를 부르지 않고 여기서 응답을 끝내므로 첫 매개변수를 `_` 로 버렸다.
- `: HttpHandler` 라고 적었는데도 FSI 는 약어를 펼쳐 `HttpFunc -> ctx: HttpContext -> HttpFuncResult` 로 보여 준다. 앞 절의 세 줄을 확인하는 셈이다. 반대로 `notFoundHandler` 처럼 함수를 조립해 만든 값은 `HttpHandler` 그대로 나온다.
- `let (HiveCode code) = hive.Code` 는 9챕터의 감싼 값을 꺼내는 패턴이다.

## Creating a Custom HttpHandler — 직접 만드는 핸들러 (원서 pp.171-172)

- 경로 일부를 값으로 받는 핸들러는 `routef` 로 연결한다. `routef "/hives/%s"` 는 `%s` 자리의 경로 조각을 핸들러의 첫 인자로 넘긴다. 그래서 핸들러는 `string -> HttpHandler` 모양이 된다.
- 원서 p.171 은 이 값을 쿼리 문자열(query string) 항목이라고 적었는데, 실제로 넘어오는 것은 경로 매개변수다. `/api/hives/H-07` 의 `H-07` 처럼 경로의 한 조각이며 `?code=H-07` 이 아니다. 쿼리 문자열을 읽으려면 `ctx.TryGetQueryStringValue` 처럼 `HttpContext` 에서 직접 꺼내야 한다.

```fsharp id=13-server
// FSI 실측: code: string -> next: HttpFunc -> ctx: HttpContext -> HttpFuncResult
let hiveStatusHandler (code: string) : HttpHandler =
    fun next ctx ->
        task {
            match findHive code with
            | Ok hive ->
                let (HiveCode found) = hive.Code
                let payload =
                    {| Hive = found
                       Frames = hive.Frames
                       LastCheckedOn = hive.LastCheckedOn.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
                       QueenSeen = hive.QueenSeen |}
                return! json payload next ctx
            | Error message ->
                return! RequestErrors.notFound (json {| Error = message |}) next ctx
        }
```

- `task { ... }` 는 `System.Threading.Tasks.Task<'T>` 를 만드는 계산 식이고 C# 의 `async`/`await` 에 해당한다. F# 6 부터 코어에 들어 있어 패키지 없이 쓸 수 있다. F# 에는 `Async` 도 있지만 Giraffe 가 `Task` 를 직접 쓰기로 정했으므로 여기서는 `task` 를 쓴다. 계산 식 자체는 12챕터의 주제다.
- 날짜를 문자열로 바꾸는 자리에는 `CultureInfo.InvariantCulture` 를 함께 넘긴다. 형식 문자열과 문화권은 별개의 인자다. 형식을 `"yyyy-MM-dd"` 로 못박아도 문화권을 넘기지 않으면 `ToString` 이 실행 환경의 문화권을 쓴다. 응답에 실리는 값의 모양은 서버가 어디서 도는지에 따라 달라져서는 안 되므로 문화권까지 코드가 정한다.
- `return!` 은 다른 핸들러의 결과를 그대로 이 핸들러의 결과로 삼는다. `json payload next ctx` 처럼 핸들러에 `next` 와 `ctx` 를 직접 넘겨 부르는 것이 핸들러를 손으로 이어 붙이는 방법이다.
- 3챕터의 `Result` 가 웹에서 하는 일이 이것이다. 성공과 실패를 갈라 응답을 만든다. `Ok` 는 200, `Error` 는 404 로 대응시켰다. 조회 함수는 HTTP 를 모르고, 핸들러만 상태 코드를 안다. 이 경계 덕분에 `findHive` 는 그대로 테스트할 수 있다.
- 안쪽 람다를 밖으로 펼쳐 매개변수를 나란히 적어도 같은 타입이다. Giraffe 코드에서는 위의 형태가 관례다.

```fsharp
// 같은 뜻이지만 관례가 아닌 형태
let hiveStatusHandler (code: string) (next: HttpFunc) (ctx: HttpContext) : HttpFuncResult =
    task { ... }
```

- 이 형태의 반환 타입은 `HttpFuncResult` 다. 원서 p.172 는 같은 코드에 `HttpHandler` 라고 적었는데, `next` 와 `ctx` 를 이미 받은 뒤에 남는 것은 결과뿐이므로 그렇게 적으면 `error FS0193: 형식 제약 조건이 일치하지 않습니다` 가 난다.

## Creating a View — HTML 을 F# 로 짜는 DSL (원서 pp.172-173)

- Giraffe View Engine 은 HTML 을 만드는 도메인 특화 언어(DSL, Domain-Specific Language)다. 요소 대부분이 리스트 두 개를 받는다. 앞은 특성 목록, 뒤는 자식 요소나 데이터 목록이다. `link` 나 `meta` 처럼 자식을 담을 수 없는 요소는 특성 목록만 받는다.
- 문자열 템플릿 대신 DSL 을 쓰는 이유는 구조가 깨진 HTML 을 만들 수 없다는 것이다. 태그를 닫는 것을 잊을 수 없고, 자식 자리에 요소가 아닌 것을 넣으면 컴파일되지 않는다.
- 아래 `13-view` 실행 단위는 `Giraffe.ViewEngine` 하나만 쓰므로 준비 코드가 필요 없다. 처음 한 번은 네트워크로 패키지를 받아 오고 그 뒤에는 로컬 NuGet 캐시로 돌며, 받아 오지 못하면 `error FS0999` 로 실패한다.

```fsharp id=13-view
// 이 단위가 보여주는 것: View Engine 의 요소 함수와 문자열로 렌더링하기
#r "nuget: Giraffe.ViewEngine, 1.4.0"

open Giraffe.ViewEngine

// FSI 실측: code: string * frames: int -> XmlNode
let hiveRow (code: string, frames: int) =
    tr [] [
        td [] [ str code ]
        td [] [ str (string frames) ]
    ]
```

- 요소 함수의 결과 타입은 `XmlNode` 하나다. 그래서 조각을 함수로 빼내 목록에 끼워 넣을 수 있다. 15챕터가 쓸 부분 뷰가 이 성질에 기댄다.

```fsharp id=13-view
// FSI 실측: rows: (string * int) list -> XmlNode
let hiveTableView rows =
    html [] [
        head [] [
            title [] [ str "HiveLog" ]
            link [ _rel "stylesheet"; _href "/css/hive.css" ]
        ]
        body [] [
            h1 [] [ str "벌통 점검 기록" ]
            table [ _class "hives" ] [
                thead [] [ tr [] [ th [] [ str "벌통" ]; th [] [ str "소비" ] ] ]
                tbody [] (rows |> List.map hiveRow)
            ]
        ]
    ]
```

- 특성 함수 이름에는 밑줄이 붙는다(`_class`, `_id`, `_href`). `class` 같은 이름이 F# 키워드이거나 요소 함수 이름과 겹치는 것을 피하려는 규칙이다.
- 렌더링은 `RenderView` 모듈이 한다. 문서 전체는 `htmlDocument`(앞에 `<!DOCTYPE html>` 이 붙는다), 조각은 `htmlNode` 다. 둘 다 `XmlNode -> string` 이다.

```fsharp id=13-view
printfn "%s" (RenderView.AsString.htmlDocument (hiveTableView [ ("H-07", 8); ("H-11", 10) ]))
// <!DOCTYPE html>
// <html><head><title>HiveLog</title><link rel="stylesheet" href="/css/hive.css"></head><body><h1>벌통 점검 기록</h1><table class="hives"><thead><tr><th>벌통</th><th>소비</th></tr></thead><tbody><tr><td>H-07</td><td>8</td></tr><tr><td>H-11</td><td>10</td></tr></tbody></table></body></html>

printfn "%s" (RenderView.AsString.htmlNode (hiveRow ("H-07", 8)))
// <tr><td>H-07</td><td>8</td></tr>
```

첫 화면에 쓸 뷰는 간단하게 둔다. 15챕터가 이 자리를 늘린다.

```fsharp id=13-server
// FSI 실측: indexView: XmlNode
let indexView =
    html [] [
        head [] [
            title [] [ str "HiveLog" ]
        ]
        body [] [
            h1 [] [ str "HiveLog" ]
            p [ _class "lede"; _id "intro" ] [ str "옥상 양봉장 점검 기록" ]
        ]
    ]
```

- 뷰를 응답으로 내보내는 핸들러는 `htmlView` 다. `htmlView indexView` 가 `HttpHandler` 이므로 경로에 그대로 붙는다.

## Adding Subroutes — 라우팅 중복 걷어내기 (원서 pp.173-175)

- 경로가 늘면 `/api` 접두가 반복된다. `subRoute` 로 접두를 한 번만 적고 그 아래 목록을 따로 뺀다.
- 뺀 목록도 그냥 `Endpoint list` 다. 다른 파일이나 모듈에서 만들어 넘겨도 된다. 14챕터가 그렇게 나눌 자리다. 원서 p.174 는 이 목록을 "another HttpHandler" 라고 적었는데 `Endpoint list` 다. 원서 코드 주석에는 `// Endpoint list` 로 맞게 적혀 있다.

```fsharp id=13-server
// FSI 실측: apiEndpoints: Endpoint list
let apiEndpoints =
    [
        GET [
            route "" apiSummaryHandler
            route "/hives" hiveListHandler
            routef "/hives/%s" hiveStatusHandler
        ]
    ]

// FSI 실측: endpoints: Endpoint list
let endpoints =
    [
        GET [
            route "/" (htmlView indexView)
        ]
        subRoute "/api" apiEndpoints
    ]
```

- 접두를 뺐으므로 안쪽 경로는 `""` 와 `"/hives"` 가 된다. `route ""` 가 `/api` 자체다.
- `GET` 을 안쪽 목록에 둔 것에 뜻이 있다. `/api` 아래에 POST 나 PUT 이 생기면 `apiEndpoints` 안에서 HTTP 메서드별로 묶으면 되고, 바깥 `endpoints` 는 손대지 않는다. 14챕터에서 실제로 그렇게 늘어난다.
- 핸들러 이름은 `<대상><동작 또는 응답 내용>Handler`, 엔드포인트 목록 이름은 `<영역>Endpoints`, 뷰 이름은 `<이름>View` 로 맞춰 두었다. 원서에서 온 `notFoundHandler` 는 대상이 없어 규칙 밖이지만 이름이 널리 쓰이므로 그대로 둔다. 14·15챕터가 이 규칙을 이어 쓴다.

## Reviewing the Code — 완성된 Program.fs (원서 pp.175-177)

서비스 등록과 미들웨어 파이프라인을 정하는 두 함수가 남았다.

```fsharp id=13-server
// FSI 실측: services: IServiceCollection -> unit
let configureServices (services: IServiceCollection) =
    let options = JsonSerializerOptions(JsonSerializerDefaults.Web)
    options.Encoder <- JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    services
        .AddRouting()
        .AddGiraffe()
        .AddSingleton<Json.ISerializer>(Json.Serializer options)
    |> ignore

// FSI 실측: appBuilder: IApplicationBuilder -> unit
let configureApp (appBuilder: IApplicationBuilder) =
    appBuilder
        .UseRouting()
        .UseGiraffe(endpoints)
        .UseGiraffe(notFoundHandler)
```

- `AddRouting` 과 `AddGiraffe` 는 라우팅과 Giraffe 가 쓰는 서비스를 등록한다. 등록 함수는 컨테이너를 돌려주므로 마지막에 `|> ignore` 가 필요하다.
- 세 번째 줄은 JSON 직렬화기를 바꿔 끼운 것이다. 기본 직렬화기는 ASCII 밖의 문자를 이스케이프해서 담으므로 `성수 옥상` 이 `\uC131\uC218 \uC625\uC0C1` 로 나간다. 한글 응답을 그대로 보려면 인코더를 갈아 준 직렬화기를 `Json.ISerializer` 로 등록한다. 이름에 `Unsafe` 가 붙은 것은 HTML 특수문자까지 이스케이프하지 않는다는 뜻이므로, JSON 을 HTML 안에 그대로 끼워 넣는 코드에서는 쓰지 않는다. `options.Encoder <- ...` 가 앞 절의 할당 연산자다.
- `configureApp` 에 적은 순서가 곧 미들웨어 파이프라인이다. `UseRouting` 이 라우팅을 켜고, `UseGiraffe(endpoints)` 가 엔드포인트를 등록하고, `UseGiraffe(notFoundHandler)` 가 어디에도 걸리지 않은 요청을 받는다. 앞의 두 호출은 빌더를 돌려주지만 마지막 오버로드는 `unit` 을 돌려주므로 함수 전체가 `unit` 이 되고 `ignore` 가 필요 없다.

`Program.fs` 의 마지막 조각은 진입점이다. 여기까지가 프로젝트 코드다.

```fsharp
[<EntryPoint>]
let main args =
    let builder = WebApplication.CreateBuilder(args)
    configureServices builder.Services
    let app = builder.Build()
    configureApp app
    app.Run()
    0
```

- 순서에 이유가 있다. `configureServices` 는 `builder.Build()` 앞이어야 한다. 컨테이너는 `Build()` 에서 굳으므로 그 뒤에 서비스를 더하려 하면 `InvalidOperationException` 이 난다. `configureApp` 은 만들어진 앱에 미들웨어를 붙이는 것이므로 `Build()` 뒤여야 한다.
- `app.Run()` 은 요청을 받기 시작하고 종료 신호가 올 때까지 돌아오지 않는다. 그 뒤의 `0` 이 종료 코드다.
- 이 챕터가 만든 프로젝트의 구조는 다음과 같다. 파일 하나에 다 들어 있는 상태이고, 14챕터에서 나눌 것이다.

```
HiveLog/
├── HiveLog.fsproj
├── Program.fs                     도메인 · 뷰 · 핸들러 · 라우팅 · 진입점
├── appsettings.json
├── appsettings.Development.json
└── Properties/
    └── launchSettings.json        프로필과 포트
```

- `Program.fs` 안의 순서도 컴파일 순서다. 도메인, 뷰, 핸들러, 엔드포인트 목록, 설정 함수, 진입점 순으로 두어야 이름이 보인다. 4챕터의 규칙이 파일 안에서도 그대로다.

프로젝트를 띄워 확인하는 명령과 결과는 다음과 같다.

```bash
dotnet run
# 다른 터미널에서
curl -i http://localhost:5291/api
curl http://localhost:5291/api/hives/h-07
curl -i http://localhost:5291/no-such-path
```

```
# curl -i http://localhost:5291/api
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-Apiary: seongsu-rooftop

{"apiary":"성수 옥상","hives":2}

# curl http://localhost:5291/api/hives/h-07
{"frames":8,"hive":"H-07","lastCheckedOn":"2026-04-12","queenSeen":true}

# curl -i http://localhost:5291/no-such-path
HTTP/1.1 404 Not Found
Content-Type: text/plain; charset=utf-8

요청한 경로가 없다
```

- 날짜나 전송 방식 같은 헤더는 위 출력에서 생략했다. 확인할 것은 상태 코드, `Content-Type`, 그리고 `apiSummaryHandler` 가 `>=>` 로 달아 둔 `X-Apiary` 헤더다.
- 브라우저로 `http://localhost:5291/` 을 열면 `indexView` 가 만든 HTML 이 보인다. API 경로는 브라우저로도 되고 `curl` 이나 Postman 같은 도구로도 된다.

## 스크립트에서 서버를 띄워 응답을 확인한다 (노트 보충)

- 앞의 `13-server` 블록들이 프로젝트 코드와 같은 정의를 쌓아 두었다. 남은 것은 진입점 대신 호스트를 직접 띄우고 요청을 보내는 부분이다.
- 포트는 `0` 으로 준다. 운영체제가 빈 포트를 골라 주므로 검증을 반복해도 충돌하지 않는다. 실제 포트는 `app.Urls` 에서 읽는다.

```fsharp id=13-server
let builder = WebApplication.CreateBuilder()
configureServices builder.Services
builder.Logging.ClearProviders() |> ignore   // 호스트 로그를 끈다

let app = builder.Build()
configureApp app
app.Urls.Add "http://127.0.0.1:0"            // 0 = 빈 포트를 골라 달라는 뜻
app.StartAsync() |> Async.AwaitTask |> Async.RunSynchronously

let baseUrl = app.Urls |> Seq.head
let client = new Net.Http.HttpClient()

let request (path: string) =
    let response = client.GetAsync(baseUrl + path) |> Async.AwaitTask |> Async.RunSynchronously
    let body = response.Content.ReadAsStringAsync() |> Async.AwaitTask |> Async.RunSynchronously
    printfn "%-18s %d  %s" path (int response.StatusCode) body
```

- `Async.AwaitTask` 로 `Task` 를 `Async` 로 바꿔 동기로 기다린다. 스크립트에서 결과를 순서대로 찍으려는 것이므로 이렇게 했다. 애플리케이션 코드에서 `Async.RunSynchronously` 를 곳곳에 쓰는 것은 좋은 습관이 아니다.

```fsharp id=13-server
request "/"
// /                  200  <!DOCTYPE html>
// <html><head><title>HiveLog</title></head><body><h1>HiveLog</h1><p class="lede" id="intro">옥상 양봉장 점검 기록</p></body></html>
request "/api"
// /api               200  {"apiary":"성수 옥상","hives":2}
request "/api/hives"
// /api/hives         200  [{"frames":8,"hive":"H-07"},{"frames":10,"hive":"H-11"}]
request "/api/hives/h-07"
// /api/hives/h-07    200  {"frames":8,"hive":"H-07","lastCheckedOn":"2026-04-12","queenSeen":true}
request "/api/hives/H-99"
// /api/hives/H-99    404  {"error":"등록되지 않은 벌통 코드: H-99"}
request "/no-such-path"
// /no-such-path      404  요청한 경로가 없다

app.StopAsync() |> Async.AwaitTask |> Async.RunSynchronously
client.Dispose()
printfn "서버를 내렸다"
```

- 서버를 내리고 클라이언트를 해제하는 두 줄이 중요하다. 그래야 스크립트가 끝난다. 서버가 남아 있으면 다음 검증을 막는다.
- 소문자로 보낸 `h-07` 이 `H-07` 로 찾아지는 것은 `findHive` 가 대문자로 바꿔 비교하기 때문이다. 없는 코드로 요청하면 상태 코드 404 와 JSON 본문이 함께 오고, 라우팅에 아예 걸리지 않는 경로는 `notFoundHandler` 가 평문으로 답한다. 같은 404 지만 응답을 만든 자리가 다르다.

## Summary — 원서의 챕터 요약 (원서 p.177)

- 원서는 Giraffe 로 API 와 HTML 페이지를 만드는 방법을 맛보았다는 말로 챕터를 맺는다. 겉만 훑었다는 것도 함께 적어 두었다.
- 라우팅에서 `HttpHandler` 가 중심이라는 점, 내장 핸들러가 여럿 있다는 점, 직접 만들 수 있다는 점이 이 챕터의 요지다.
- 다음 챕터에서는 API 쪽을 늘린다.

## 정리 — 이 노트의 요약

- Giraffe 는 ASP.NET Core 위의 얇은 함수형 껍데기다. 라우팅은 `Endpoint list` 라는 값이고, 요청 처리는 `HttpHandler` 라는 함수다. 값과 함수로 되어 있으니 조립하고 나눠 담을 수 있다.
- `HttpHandler` 는 `HttpFunc -> HttpContext -> HttpFuncResult` 이고, `HttpFunc` 는 `HttpContext -> HttpFuncResult`, `HttpFuncResult` 는 `Task<HttpContext option>` 이다. 첫 매개변수가 다음 핸들러라서 `>=>` 로 이어 붙일 수 있고, 결과의 `option` 이 처리 여부를 나타낸다.
- 설정 코드에서만 가변이 필요하다. `let mutable` 로 선언하고 `<-` 로 값을 넣는다. `=` 는 비교이므로 값을 바꾸지 않으며, 프로젝트에서는 경고 FS0020 이 그 실수를 알려 주지만 스크립트 최상위에서는 그 경고조차 나오지 않는다.
- 응답 본문은 익명 레코드가 편하다. 필드는 알파벳 순으로 정렬되고, 웹 기본값에서는 키가 소문자로 시작한다. 한글을 이스케이프 없이 내보내려면 인코더를 바꾼 직렬화기를 `Json.ISerializer` 로 등록한다.
- 응답에 도메인 타입을 그대로 실어 보내지 않는다. `System.Text.Json` 은 `Option` 이 아닌 판별 유니온을 직렬화하지 못하고 `NotSupportedException` 을 던지므로, 감싼 값을 벗겨 익명 레코드로 만들어 넘긴다.
- `routef "/hives/%s"` 가 넘기는 것은 경로 매개변수다. 원서 p.171 은 쿼리 문자열이라고 적었지만 실제로는 경로의 한 조각이다.
- 매개변수를 펼쳐 적은 핸들러의 반환 타입은 `HttpFuncResult` 다. 원서 p.172 는 그 자리에 `HttpHandler` 라고 적었고, 그대로 쓰면 `error FS0193` 이 난다.
- 뷰는 요소마다 특성 목록과 자식 목록을 받는 DSL 로 짠다. 모든 요소가 `XmlNode` 라서 조각을 함수로 빼 재사용할 수 있고, `RenderView.AsString.htmlDocument` 로 문자열이 된다.
- 원서 코드의 `UseDeveloperExceptionPage` 호출은 현재 SDK 에서는 없어도 된다. 개발 환경이면 `WebApplication` 이 자동으로 넣는다.
- 검증은 스크립트에서 서버를 띄워 했다. FSI 가 ASP.NET Core 공유 프레임워크를 자동으로 참조하지 않으므로 준비 코드가 필요하지만, 그 대가로 라우팅·핸들러·뷰·상태 코드가 실제 응답으로 확인된다.

### 14·15챕터가 이어받는 것

프로젝트는 `HiveLog` 이고 `dotnet new web -lang "F#"` 로 만든 단일 프로젝트다. 패키지는 `Giraffe` 8.3.0 과 `Giraffe.ViewEngine` 1.4.0 이며 버전을 고정해 쓴다. 도메인은 옥상 양봉장의 벌통 점검 기록이고, 타입은 `HiveCode`(단일 케이스 판별 유니온)와 `Hive` 레코드, 저장소는 메모리 리스트 `hives`, 조회 경로는 `findHive : string -> Result<Hive,string>` 하나다. 라우팅은 바깥 `endpoints` 에 첫 화면과 `subRoute "/api" apiEndpoints` 를 두고, HTTP 메서드 묶음은 안쪽 `apiEndpoints` 에 둔다. 그래서 `/api` 아래에 POST 나 PUT 을 더할 때 바깥 목록을 건드릴 일이 없다. 이름 규칙은 핸들러 `<대상><동작 또는 응답 내용>Handler`, 엔드포인트 목록 `<영역>Endpoints`, 뷰 `<이름>View` 다. 원서에서 온 `notFoundHandler` 는 대상이 없어 규칙 밖이다. 서비스 등록은 `configureServices`, 미들웨어 파이프라인은 `configureApp` 이 정하고 진입점은 그 둘을 부르기만 한다. 지금은 `Program.fs` 한 파일이므로 14챕터에서 도메인과 핸들러를 앞쪽 파일로 나눌 때 `.fsproj` 의 `<Compile Include=... />` 순서를 함께 적어야 한다. 검증 방식도 그대로 물려받는다. `13-server` 실행 단위의 준비 코드(공유 프레임워크 탐색, 어셈블리 해석기, 참조 링크)를 그대로 쓰고, 포트 `0` 으로 띄워 `HttpClient` 로 요청한 뒤 `StopAsync` 로 내리면 반복 실행해도 안전하다. 15챕터가 CSS·JS 를 둘 `wwwroot/` 는 아직 없으므로 그 챕터에서 만든다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Getting Started — 빈 웹 프로젝트 만들기 | pp.166-167 | — |
| Using Giraffe — 패키지와 시작 코드 | pp.168-169 | — |
| 이 노트의 예제를 돌리는 방법 | (노트 보충) | `13-server` |
| Mutability — 가변 바인딩과 할당 연산자 | p.169 | `13-mutability` |
| Endpoints — 라우팅을 값으로 적는다 | p.170 | `13-server` |
| 404 - Not Found Handler — 못 찾은 요청을 받는 핸들러 | p.170 | `13-server` |
| Creating an API Route — json 핸들러와 익명 레코드 | pp.170-171 | `13-payload`, `13-server` |
| Creating a Custom HttpHandler — 직접 만드는 핸들러 | pp.171-172 | `13-server` |
| Creating a View — HTML 을 F# 로 짜는 DSL | pp.172-173 | `13-view`, `13-server` |
| Adding Subroutes — 라우팅 중복 걷어내기 | pp.173-175 | `13-server` |
| Reviewing the Code — 완성된 Program.fs | pp.175-177 | `13-server` |
| 스크립트에서 서버를 띄워 응답을 확인한다 | (노트 보충) | `13-server` |
| Summary — 원서의 챕터 요약 | p.177 | — |
