# 14 - Giraffe 로 API 만들기 (원서 pp.178-184)

> 13챕터가 세운 `HiveLog` 에 쓰기 경로를 붙이는 챕터다. 읽기만 하던 API 에 POST·PUT·DELETE 가 생기고, 그러면 세 가지가 새로 필요해진다. 요청이 끝나도 남아 있어야 하는 저장소, 그 저장소를 핸들러에 건네주는 의존성 주입, 요청 본문을 F# 타입으로 되돌리는 모델 바인딩(model binding)이다. 새 문법은 없다. 10챕터의 클래스 타입, 3챕터의 `Option`·`Result`, 8챕터의 검증, 4챕터의 컴파일 순서가 API 코드에서 어떻게 만나는지 보는 챕터다.

13챕터에서 넘어오는 것은 이렇다. 프로젝트는 `dotnet new web -lang "F#"` 로 만든 단일 프로젝트 `HiveLog`, 패키지는 `Giraffe` 8.3.0 과 `Giraffe.ViewEngine` 1.4.0, 도메인은 옥상 양봉장의 벌통 점검 기록, 라우팅은 바깥 `endpoints` 와 그 안의 `subRoute "/api" apiEndpoints` 두 층이다. 이 챕터는 그 위에 점검 기록이라는 쓰기 대상을 하나 얹는다.

## Getting Started · Our Task — 이 챕터가 더하는 것 (원서 p.178)

- 원서는 Postman 같은 HTTP 도구를 준비하라고 안내하고, 항목을 만들고 고치고 지우는 API 를 목표로 잡는다. 이 노트는 13챕터의 도메인을 이어받아 벌통 점검 기록을 다루는 다섯 경로를 만든다.
- 13챕터의 `/api/hives` 는 등록된 벌통을 읽기만 한다. 새로 붙이는 `/api/inspections` 는 점검 기록을 쌓는 자리이므로 요청이 서버의 상태를 바꾼다. 상태가 바뀌는 순간부터 저장소·검증·상태 코드 선택이 모두 문제가 된다.

```
GET    /api/inspections        점검 기록 목록
GET    /api/inspections/{id}   한 건 조회
POST   /api/inspections        새 점검 기록 만들기
PUT    /api/inspections/{id}   한 건 교체
DELETE /api/inspections/{id}   한 건 삭제
```

- 원서는 이 라우팅 표를 먼저 적고 핸들러를 나중에 채운다. 이 노트는 스크립트가 위에서 아래로 컴파일되도록 순서를 뒤집어 저장소 → 요청·응답 타입 → 핸들러 → 엔드포인트 목록으로 적는다. 4챕터에서 본 "정의가 사용보다 앞" 이라는 규칙이 노트의 서술 순서까지 정한다.

## Handlers — 파일을 넷으로 나눈다 (원서 p.181)

- 13챕터의 `Program.fs` 는 도메인·뷰·핸들러·라우팅·진입점을 한 파일에 담고 있었다. 핸들러가 다섯 개 늘어나면 그 파일이 감당하지 못한다. 원서도 같은 판단으로 저장소와 핸들러를 새 파일로 뺀다.
- F# 에서 파일을 나누는 비용은 `.fsproj` 에 순서를 적는 것이다. 컴파일러가 파일을 적힌 순서대로 읽으므로, 뒤 파일은 앞 파일의 이름만 볼 수 있다.

```xml
  <ItemGroup>
    <Compile Include="Domain.fs" />
    <Compile Include="Store.fs" />
    <Compile Include="Inspections.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>
```

```
HiveLog/
├── HiveLog.fsproj
├── Domain.fs        module HiveLog.Domain       벌통 · 점검 기록 타입과 조회
├── Store.fs         module HiveLog.Store        점검 기록 저장소
├── Inspections.fs   module HiveLog.Inspections  요청 · 응답 타입, 핸들러, 엔드포인트 목록
└── Program.fs       뷰 · 벌통 핸들러 · 라우팅 · 설정 · 진입점
```

- 순서의 근거는 참조 방향 하나다. `Store.fs` 는 `Domain.fs` 의 타입을 쓰고, `Inspections.fs` 는 그 둘을 쓰고, `Program.fs` 는 셋을 다 쓴다. `[<EntryPoint>]` 가 붙은 함수는 마지막 파일에 있어야 하므로 `Program.fs` 는 자동으로 맨 끝이다.
- 원서는 파일 이름을 `TodoStore.fs` 로 잡고 그 안의 모듈 이름도 `GiraffeExample.TodoStore`, 타입 이름도 `TodoStore` 로 둔다. 컴파일에 문제는 없지만 세 이름이 겹쳐 읽기 어렵다. 이 노트는 파일과 모듈을 `Store`, 타입을 `InspectionStore` 로 갈라 두었다.
- `Program.fs` 에서 다른 파일의 이름을 쓰려면 `open` 을 적거나 `HiveLog.Inspections.inspectionEndpoints` 처럼 정규화된 이름을 쓴다. 모듈 전체를 열려면 `open HiveLog.Domain`, 모듈 이름을 접두로 남겨 두려면 `open HiveLog` 를 적고 `Inspections.inspectionEndpoints` 처럼 쓴다. 이 노트는 엔드포인트 목록만 접두를 남긴다.

## 스크립트에서 앱을 세우는 준비 (노트 보충)

- 검증 방식은 13챕터와 같다. `dotnet fsi` 스크립트 안에서 Giraffe 앱을 띄우고, 같은 스크립트의 `HttpClient` 로 요청을 보내 응답을 찍고, 마지막에 서버를 내린다. 준비 코드도 13챕터의 것을 그대로 쓴다.
- 선행 요구사항은 두 가지다. ASP.NET Core 공유 프레임워크가 포함된 .NET SDK(이 노트는 10.0.111 로 확인했다), 그리고 처음 한 번 `Giraffe` 8.3.0 과 `Giraffe.ViewEngine` 1.4.0 을 받아 올 네트워크다. 받아 오지 못하면 `error FS0999` 로 실패한다.
- 실제 개발은 프로젝트를 만들어 `dotnet run` 으로 확인하는 것이다. 아래 준비 코드는 노트의 예제를 자동으로 검증하기 위한 장치이고 `Program.fs` 에는 들어가지 않는다.

```fsharp id=14-server
// 이 단위가 보여주는 것: 저장소 · 모델 바인딩 · 다섯 메서드를 갖춘 API 를 띄워 응답까지 확인하기
// 준비 코드 — 프로젝트 코드에는 들어가지 않는다(13챕터와 같다)
open System
open System.IO
open System.Runtime.Loader

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

AssemblyLoadContext.Default.add_Resolving(
    Func<AssemblyLoadContext, Reflection.AssemblyName, Reflection.Assembly>(fun context name ->
        let dll = Path.Combine(sharedFramework, name.Name + ".dll")
        if File.Exists dll then context.LoadFromAssemblyPath dll else null))

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

참조와 `open` 은 13챕터에 `System.Collections.Concurrent` 한 줄만 더한 것이다. 저장소가 그 네임스페이스의 타입을 쓴다.

```fsharp id=14-server
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

open System.Collections.Concurrent
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

- 이 프로젝트는 파일마다 최상위 모듈 하나를 선언한다(4챕터에서 본 `module Shop.Learners` 형태다). 스크립트에서는 최상위 `module X.Y` 를 쓸 수 없으므로 그 구조를 중첩 모듈로 본뜬다. 아래 코드의 `module Domain =` 은 프로젝트의 `Domain.fs` 첫 줄 `module HiveLog.Domain` 에 해당하고, 그 아래 들여쓴 부분이 그 파일의 본문이다. 선언 순서가 곧 `.fsproj` 의 컴파일 순서다.
- 대응이 어긋나는 곳이 하나 있다. `open` 은 적힌 스코프 안에서만 유효하므로, 스크립트에서는 위쪽 준비 블록의 `open` 이 아래 중첩 모듈에 다 미치지만 프로젝트에서는 파일마다 다시 적어야 한다. `Store.fs` 는 `System` 과 `System.Collections.Concurrent`, `Inspections.fs` 는 `System`·`System.Text.Json`·`Microsoft.AspNetCore.Http`·`Giraffe`·`Giraffe.EndpointRouting` 이 필요하다.
- 코드 주석의 `FSI 실측` 은 13챕터와 같은 방식으로 네임스페이스와 모듈 접두를 벗겨 적었다. FSI 는 `Giraffe.Core.HttpFunc`, `Domain.Inspection`, `Giraffe.EndpointRouting.Routers.Endpoint` 처럼 접두를 붙여 찍는다.

## Sample Data — 쓸 수 있는 저장소 (원서 pp.178-179)

- 13챕터의 저장소는 최상위 `let hives = [ ... ]` 였다. 리스트는 불변이므로 요청이 값을 바꿀 수 없다. 쓰기를 받으려면 상태를 담을 그릇이 필요하다.
- 원서는 데이터베이스를 붙이지 않고 `ConcurrentDictionary` 를 클래스 타입으로 감싼다. 웹 서버는 요청을 여러 스레드에서 동시에 처리하므로 그냥 `Dictionary` 를 쓰면 동시 접근에서 깨진다. `ConcurrentDictionary` 는 그 조정을 스스로 한다.
- 프로세스가 끝나면 내용도 사라진다. 저장소를 인터페이스로 추상화하지 않은 것은 이 챕터의 범위를 좁히려는 선택이다. 클래스 하나가 사전을 감싸고 있으므로 그 안을 실제 데이터베이스로 바꾸는 일은 이 파일에서 끝나지만, 구현을 둘 이상 두고 갈아 끼우려면 그때 인터페이스가 필요해진다. 핸들러가 구체 클래스 이름으로 꺼내 쓰고 있다는 점도 그때 걸린다.

`ConcurrentDictionary` 를 F# 에서 쓸 때 알아 둘 관용구가 셋 있다. 저장소 코드를 읽기 전에 따로 확인한다.

```fsharp id=14-store
// 이 단위가 보여주는 것: ConcurrentDictionary 를 F# 에서 다루는 관용구
open System.Collections.Concurrent

type Reading = { Sensor: string; Celsius: float }

let readings = ConcurrentDictionary<string, Reading>()

// 인덱서에 값을 넣는 것은 없으면 추가, 있으면 덮어쓰기다
readings["r1"] <- { Sensor = "H-07"; Celsius = 34.2 }
readings["r1"] <- { Sensor = "H-07"; Celsius = 34.8 }
printfn "%d개 %.1f도" readings.Count readings["r1"].Celsius   // 1개 34.8도
```

- 첫째는 인덱서 설정이다. `<-` 는 13챕터에서 본 할당 연산자이고, 사전에서는 추가와 갱신을 한 번에 처리한다. 원서는 추가에 `TryAdd`, 갱신에 `TryUpdate` 를 따로 쓰는데 그러면 호출하는 쪽이 지금 키가 있는지 먼저 알아야 한다.

```fsharp id=14-store

// out 매개변수를 쓰는 .NET 메서드는 F# 에서 튜플을 돌려준다
// FSI 실측: key: string -> Reading option
let tryFind (key: string) =
    match readings.TryGetValue key with
    | true, found -> Some found
    | false, _ -> None

printfn "%A" (tryFind "r1" |> Option.map (fun reading -> reading.Celsius))   // Some 34.8
printfn "%A" (tryFind "r9" |> Option.map (fun reading -> reading.Celsius))   // None
```

- 둘째는 `out` 매개변수다. C# 에서 `dict.TryGetValue(key, out value)` 로 쓰는 메서드를 F# 은 `bool * 'Value` 튜플을 돌려주는 함수로 본다. 그래서 성공 여부와 값을 한 번의 패턴 매칭으로 갈라낼 수 있고, 그 결과를 3챕터의 `Option` 으로 바꿔 밖으로 내보내면 호출하는 쪽에서 `bool` 을 들고 다닐 일이 없다.
- 타입 주석 `(key: string)` 은 장식이 아니다. `TryRemove` 처럼 오버로드가 둘 이상인 메서드에서는 키 타입이 정해지지 않으면 컴파일러가 어느 것을 부를지 고르지 못한다. 그때 `bool` 만 돌려주는 오버로드가 잡혀 패턴 매칭에서 `error FS0001` 이 난다.

```fsharp id=14-store

// FSI 실측: key: string -> Reading option
let tryRemove (key: string) =
    match readings.TryRemove key with
    | true, removed -> Some removed
    | false, _ -> None

printfn "%A" (tryRemove "r1" |> Option.map (fun reading -> reading.Celsius))   // Some 34.8
printfn "%A" (tryRemove "r1" |> Option.map (fun reading -> reading.Celsius))   // None
printfn "%d개" readings.Count                                                  // 0개
```

- 셋째는 없는 키의 처리다. `TryRemove` 는 없는 키에도 `false` 를 돌려주지만, 인덱서로 읽으면 예외가 난다.

```fsharp id=14-store

// 없는 키를 인덱서로 읽으면 예외가 난다
try
    readings["r9"] |> ignore
with e ->
    printfn "%s" (e.GetType().Name)   // KeyNotFoundException

// 반면 TryUpdate 는 없는 키에도 예외 없이 false 를 돌려준다
let stale = { Sensor = "H-11"; Celsius = 0.0 }
printfn "%b" (readings.TryUpdate("r9", stale, stale))   // false
```

- 원서 p.179 의 `Update` 멤버는 `data.TryUpdate(todo.Id, todo, data[todo.Id])` 다. 세 번째 인자로 현재 값을 읽는데, 그 키가 없으면 `TryUpdate` 에 닿기 전에 인덱서가 `KeyNotFoundException` 을 던진다. 없는 항목에 PUT 을 보내면 의도한 410 대신 500 이 돌아온다는 뜻이다. 게다가 방금 읽은 값을 그대로 비교 인자로 넘기므로 비교가 거의 언제나 성공한다. 읽은 뒤 갱신에 닿기 전에 다른 스레드가 끼어들면 조용히 `false` 가 되는데, 그 결과를 본문에 실어 200 으로 답하니 호출한 쪽이 알 길도 없다. 이 노트는 갱신을 인덱서 설정 하나로 처리하고, 있는지 없는지는 핸들러에서 먼저 확인한다.

이제 도메인이다. 13챕터의 타입과 조회 함수를 그대로 옮기고, 점검 기록 타입 둘을 더한다.

```fsharp id=14-server
// Domain.fs — 프로젝트에서는 module HiveLog.Domain 으로 시작하는 파일이다
module Domain =
    // 여기까지 13챕터에서 그대로 이어받는다
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

    // 이 챕터가 더하는 것
    type InspectionId = InspectionId of Guid

    type Inspection = {
        Id: InspectionId
        Hive: HiveCode
        Frames: int
        QueenSeen: bool
        RecordedAt: DateTime
    }
```

- `InspectionId` 는 9챕터의 단일 케이스 판별 유니온이다. 원서는 `type TodoId = Guid` 로 타입 약어를 쓰는데, 약어는 이름만 붙일 뿐이어서 `Guid` 를 받는 자리에 아무 `Guid` 나 들어간다. 감싸 두면 벌통 코드와 점검 기록 id 를 뒤바꿔 넣는 실수가 컴파일에서 걸린다.
- 감싸는 대가는 뒤에서 치른다. `System.Text.Json` 은 `Option` 이 아닌 판별 유니온을 다루지 못하므로 이 타입은 응답에도 요청에도 그대로 실을 수 없다.

저장소는 클래스 타입이다. 10챕터에서 본 대로 본문의 `let` 은 밖에서 보이지 않는다.

```fsharp id=14-server
// Store.fs — module HiveLog.Store
module Store =
    open Domain

    // FSI 실측:
    //   new: unit -> InspectionStore
    //   member All: unit -> Inspection list
    //   member Remove: InspectionId -> Inspection option
    //   member Save: inspection: Inspection -> unit
    //   member TryFind: InspectionId -> Inspection option
    type InspectionStore() =
        let data = ConcurrentDictionary<Guid, Inspection>()

        member _.Save(inspection: Inspection) =
            let (InspectionId key) = inspection.Id
            data[key] <- inspection

        member _.TryFind(InspectionId key) =
            match data.TryGetValue key with
            | true, found -> Some found
            | false, _ -> None

        member _.Remove(InspectionId key) =
            match data.TryRemove key with
            | true, removed -> Some removed
            | false, _ -> None

        member _.All() =
            data.Values |> Seq.sortBy (fun item -> item.RecordedAt) |> Seq.toList
```

- 사전의 키는 `Guid` 이고 멤버가 받는 것은 `InspectionId` 다. 껍데기를 벗기는 자리를 저장소 안으로 모아 두어 밖에서는 감싼 타입만 쓰게 했다. `member _.TryFind(InspectionId key)` 처럼 매개변수 자리에 패턴을 적으면 받는 즉시 껍데기가 벗겨진다.
- `Save` 하나가 추가와 갱신을 겸한다. 그래서 저장소는 `bool` 을 돌려줄 일이 없고, 조회와 삭제만 `Option` 을 돌려준다. HTTP 상태 코드를 고르는 판단은 전부 핸들러 몫이다.
- `All` 이 `Seq` 를 그대로 내보내지 않고 `Seq.toList` 로 확정하는 것은 5챕터의 이야기다. `data.Values` 는 그 순간의 값을 복사해 담은 `ReadOnlyCollection<'T>` 라 열거는 이미 안전하지만, `Seq.sortBy` 가 지연 평가되므로 그 결과를 그대로 내보내면 정렬이 언제 일어나는지 알 수 없는 `seq` 가 저장소 밖으로 나간다. `Seq.toList` 가 그 자리에서 정렬을 끝내고 타입도 `Inspection list` 로 못박는다.
- 평범한 `Dictionary` 의 `Values` 는 반대로 살아 있는 뷰다. 열거 도중에 사전이 바뀌면 `InvalidOperationException` 이 나므로, 요청을 여러 스레드에서 받는 자리에서 `ConcurrentDictionary` 를 고른 이유가 여기서도 확인된다.

## 저장소를 의존성 주입으로 넘긴다 (원서 p.179)

- 저장소 인스턴스는 하나만 있어야 한다. 요청마다 새로 만들면 방금 저장한 기록이 사라진다.
- ASP.NET Core 의 의존성 주입 컨테이너에 싱글턴(singleton)으로 등록하면 그 하나를 앱 전체가 공유한다. 등록 코드는 뒤의 설정 절에 있다.
- 핸들러는 그 인스턴스를 `HttpContext` 에서 받는다. Giraffe 가 붙여 주는 확장 멤버 `ctx.GetService<'T>()` 가 컨테이너에서 등록된 타입을 찾아 준다.

```fsharp
let store = ctx.GetService<InspectionStore>()
```

- 원서는 이 방식을 서비스 로케이션(service location)이라 부르고 의존성 주입의 간단한 형태라고 적는다. 생성자로 받는 대신 필요할 때 컨테이너에 물어보는 쪽이다. 함수가 매개변수로 받지 않은 것을 몸통에서 꺼내 쓰므로 테스트할 때 대신 넣어 주기가 까다롭다는 점은 알아 둘 만하다. 핸들러를 `InspectionStore -> HttpHandler` 로 적고 엔드포인트 목록을 만들 때 저장소를 넘기는 방법도 있고, 그러면 컨테이너 없이도 테스트가 된다.
- 등록하지 않은 타입을 `GetService` 로 꺼내면 실행 중에 `Giraffe.MissingDependencyException` 이 난다. 메시지가 `services.AddGiraffe()` 를 부르라고 안내하지만 실제 원인은 그 타입을 등록하지 않은 것이다. 컴파일은 통과하므로 등록을 잊으면 첫 요청에서 500 을 받는다.

## 요청 본문과 응답 본문을 위한 타입 (원서 p.182 확장)

- POST 와 PUT 은 요청 본문을 받는다. Giraffe 는 `ctx.BindJsonAsync<'T>()` 로 본문을 타입 있는 값으로 되돌려 준다. 이것이 모델 바인딩이다.
- 어떤 타입으로 되돌릴지가 설계 판단이다. 도메인 타입 `Inspection` 을 그대로 쓰면 id 와 기록 시각까지 클라이언트가 보내야 하고, `InspectionId` 가 `Option` 이 아닌 판별 유니온이라 역직렬화 자체가 되지 않는다. 그래서 요청과 응답에는 도메인과 별개인 평평한 타입을 쓴다. 이런 타입을 DTO(Data Transfer Object)라 부른다.
- 되돌리는 쪽이 실제로 어떻게 움직이는지 먼저 확인한다. Giraffe 의 모델 바인딩은 13챕터에서 등록한 직렬화기를 그대로 쓰므로, 아래 결과가 곧 서버가 보는 결과다.

```fsharp id=14-binding
// 이 단위가 보여주는 것: 요청 본문을 F# 타입으로 되돌릴 때 실제로 벌어지는 일
open System
open System.Text.Json

// Giraffe 의 BindJsonAsync 가 쓰는 설정과 같다(13챕터에서 등록한 직렬화기)
let options = JsonSerializerOptions(JsonSerializerDefaults.Web)

type InspectionRequest = {
    Hive: string
    Frames: int
    QueenSeen: bool
}

// FSI 실측: body: string -> InspectionRequest
let parse (body: string) = JsonSerializer.Deserialize<InspectionRequest>(body, options)

printfn "%A" (parse """{"hive":"H-07","frames":9,"queenSeen":true}""")
// { Hive = "H-07"
//   Frames = 9
//   QueenSeen = true }
```

- F# 레코드는 생성자 매개변수가 곧 필드이므로 `System.Text.Json` 이 그 생성자를 찾아 채운다. 프로퍼티를 설정 가능하게 만들지 않아도 되고 `[<CLIMutable>]` 같은 특성을 붙일 일도 없다.

```fsharp id=14-binding

// 필드가 빠진 본문도 예외 없이 통과한다. 빠진 자리에는 타입의 기본값이 들어간다
let partial = parse """{"queenSeen":true}"""
printfn "Hive=%A Frames=%d QueenSeen=%b" partial.Hive partial.Frames partial.QueenSeen
// Hive=<null> Frames=0 QueenSeen=true
printfn "Hive 가 null 인가: %b" (isNull partial.Hive)   // Hive 가 null 인가: true
```

- 이 결과가 이 절의 핵심이다. `hive` 를 보내지 않았는데 예외 없이 값이 만들어지고, `Hive` 필드에 `null` 이 들어 있다. F# 안에서만 만든 레코드라면 있을 수 없는 상태이고, 3챕터에서 `null` 을 밀어낸 노력이 바깥에서 들어오는 데이터에는 통하지 않는다는 뜻이다.
- 그래서 모델 바인딩 뒤에는 검증이 반드시 온다. 문자열 필드를 `String.IsNullOrWhiteSpace` 로 보고 숫자 필드의 범위를 보는 일까지 모델 바인딩이 해 주지는 않는다.

```fsharp id=14-binding

// 예외를 던지는 경우는 따로 있다. 타입 이름과 첫 문장만 찍는다
let describe (action: unit -> unit) =
    try
        action ()
    with e ->
        let message = e.Message.Split '.' |> Array.head
        // FSI 가 타입 이름 앞에 붙이는 모듈 접두는 지운다
        printfn "%s: %s." (e.GetType().Name) (Text.RegularExpressions.Regex.Replace(message, @"FSI_\d+\+", ""))

type HiveCode = HiveCode of string

describe (fun () -> JsonSerializer.Deserialize<HiveCode>("""["H-07"]""", options) |> ignore)
// NotSupportedException: F# discriminated union serialization is not supported.
describe (fun () -> parse """{"hive":}""" |> ignore)
// JsonException: '}' is an invalid start of a value.
describe (fun () -> parse "" |> ignore)
// JsonException: The input does not contain any JSON tokens.
describe (fun () -> parse """{"frames":"아홉"}""" |> ignore)
// JsonException: The JSON value could not be converted to InspectionRequest.
```

- 판별 유니온은 읽는 방향에서도 막힌다. `System.Text.Json` 의 F# 지원은 레코드·`list`·`Set`·`Map`·튜플과 `Option` 까지이고, `Option` 이 아닌 판별 유니온은 방향에 상관없이 `NotSupportedException` 이다. 13챕터가 응답에서 만난 예외가 요청에서도 그대로 나오고, 본문을 어떤 모양으로 보내든 타입을 보는 순간 막히므로 본문을 고쳐 피할 방법이 없다. 도메인 타입을 요청 타입으로 쓸 수 없는 이유가 이것이다.
- 나머지 셋은 모두 `JsonException` 이다. 깨진 JSON, 빈 본문, 타입이 맞지 않는 값이 한 종류의 예외로 모이므로 핸들러에서 한 번만 잡으면 된다. 잡지 않으면 500 이 나가는데, 잘못된 본문을 보낸 것은 클라이언트 쪽 문제이므로 400 이 맞다.

```fsharp id=14-binding

// bool 은 빠진 것과 false 를 구별할 수 없다. Option 은 구별한다
type StrictRequest = {
    Hive: string
    Frames: int option
    QueenSeen: bool option
}

// FSI 실측: body: string -> StrictRequest
let parseStrict (body: string) = JsonSerializer.Deserialize<StrictRequest>(body, options)

printfn "%A" (parseStrict """{"hive":"H-07"}""").QueenSeen                    // None
printfn "%A" (parseStrict """{"hive":"H-07","queenSeen":false}""").QueenSeen  // Some false
printfn "%A" (parseStrict """{"hive":"H-07","frames":9}""").Frames            // Some 9
```

- `string` 필드에는 `null` 이라는 표시가 남지만 `bool` 과 `int` 에는 그것이 없다. `queenSeen` 을 보내지 않은 요청과 `false` 를 보낸 요청이 서버에서 똑같이 `false` 로 보이므로 어떤 검증을 붙여도 갈라낼 수 없다. `Frames` 가 `0` 에서 걸리는 것은 `0` 이 마침 범위 밖이어서 생긴 우연이다.
- 필드가 빠진 것을 반드시 알아야 한다면 요청 타입의 필드를 `Option` 으로 적는다. `System.Text.Json` 은 `Option` 만은 특별히 지원해서 필드가 없거나 `null` 이면 `None`, 값이 있으면 `Some` 을 준다. 이 노트의 `InspectionRequest` 는 세 필드가 다 필수이고 빠진 자리를 검증이 400 으로 잡아 주므로 평평한 타입을 유지했다.

요청 타입, 응답 만들기, 검증을 `Inspections.fs` 앞부분에 둔다.

```fsharp id=14-server
// Inspections.fs — module HiveLog.Inspections
module Inspections =
    open Domain
    open Store

    // 요청 본문을 받는 타입. 도메인 타입과 달리 평평하고 감싼 값이 없다
    type InspectionRequest = {
        Hive: string
        Frames: int
        QueenSeen: bool
    }

    // FSI 실측:
    //   inspection: Inspection ->
    //     {| Frames: int; Hive: string; Id: Guid; QueenSeen: bool; RecordedAt: string |}
    let toPayload (inspection: Inspection) =
        let (InspectionId id) = inspection.Id
        let (HiveCode hive) = inspection.Hive
        {| Id = id
           Hive = hive
           Frames = inspection.Frames
           QueenSeen = inspection.QueenSeen
           RecordedAt = inspection.RecordedAt.ToString("yyyy-MM-ddTHH:mm:ssZ", CultureInfo.InvariantCulture) |}
```

- `toPayload` 가 감싼 값 둘을 벗기고 시각을 문자열로 바꾼다. 응답을 만드는 자리를 이 함수 하나로 모아 두면 핸들러 다섯 개가 같은 모양의 JSON 을 내보낸다.
- 시각을 찍을 때 `CultureInfo.InvariantCulture` 를 넘긴 것은 이 문자열을 기계가 읽기 때문이다. `ToString` 은 문화권을 주지 않으면 실행 환경의 것을 쓰는데, 사용자 지정 형식의 `:` 는 문화권의 시간 구분 기호이고 연도는 문화권의 달력으로 계산된다. `fi-FI` 로캘에서는 `09.00.00`, `th-TH` 로캘에서는 불교력의 `2569` 년이 응답에 실린다(실측). 사람이 읽을 화면이라면 그것이 맞는 동작이지만 JSON 응답에서는 받는 쪽의 파싱을 깨뜨린다.
- 익명 레코드의 필드는 알파벳 순으로 정렬된다. FSI 가 보여 주는 타입에서 적은 순서와 다른 순서가 나오는 것이 그 때문이고, 응답 JSON 의 키 순서도 같다.

```fsharp id=14-server

    // FSI 실측: request: InspectionRequest -> Result<HiveCode,string list>
    let validate (request: InspectionRequest) : Result<HiveCode, string list> =
        let hiveResult =
            if String.IsNullOrWhiteSpace request.Hive then Error "hive 를 적어야 한다"
            else findHive request.Hive |> Result.map (fun hive -> hive.Code)
        let frameErrors =
            if request.Frames <= 0 then [ "frames 는 1 이상이어야 한다" ] else []
        match hiveResult, frameErrors with
        | Ok code, [] -> Ok code
        | Ok _, errors -> Error errors
        | Error message, errors -> Error (message :: errors)
```

- 8챕터의 검증이 여기 그대로 쓰인다. 실패를 문자열 리스트로 모으므로 클라이언트가 한 번의 응답으로 잘못된 곳을 다 볼 수 있다. 첫 실패에서 멈추는 `Result.bind` 사슬과 다른 점이다.
- 벌통 코드가 등록된 것인지는 13챕터의 `findHive` 가 판단한다. 조회 경로를 그 함수 하나로 좁혀 둔 덕에 검증이 새 코드를 쓰지 않는다.
- 검증이 돌려주는 것은 `HiveCode` 다. 문자열을 그대로 넘기지 않고 감싼 값으로 바꿔 내보내면, 검증을 지나지 않은 문자열이 도메인 타입에 들어갈 길이 막힌다.
- 실패 타입이 8챕터의 `ValidationError` 판별 유니온이 아니라 `string list` 인 것은 이 오류를 쓰는 곳이 하나뿐이어서다. 오류는 곧 JSON 응답 본문이 되므로 케이스를 나눠 두고 다시 문자열로 되돌릴 이유가 없다. 오류마다 다른 상태 코드를 붙이거나 화면 쪽에서도 같은 검증을 쓴다면 8챕터처럼 판별 유니온으로 올려야 한다.

## Handlers — 실패 응답과 GET 두 개 (원서 pp.181-182)

- 핸들러 다섯 개가 같은 실패 응답 둘을 나눠 쓴다. 먼저 그 둘을 값으로 뽑아 둔다.

```fsharp id=14-server

    module Handlers =

        // FSI 실측: HttpHandler
        let recordMissingHandler : HttpHandler = RequestErrors.notFound (json {| Error = "점검 기록이 없다" |})

        // FSI 실측: errors: string list -> HttpHandler
        let requestInvalidHandler (errors: string list) : HttpHandler =
            RequestErrors.badRequest (json {| Errors = errors |})
```

- 원서는 핸들러를 `Handlers` 라는 중첩 모듈에 담으므로 이름의 `Handler` 꼬리를 떼도 되겠다고 적어 둔다. 이 노트는 13챕터에서 정한 이름 규칙을 지켜 꼬리를 남긴다. 원서는 핸들러를 한 모듈에만 두지만 이 노트는 `Program.fs` 쪽에도 핸들러가 있어 접미사를 떼면 규칙이 반쪽이 된다. 규칙이 챕터마다 흔들리는 것보다는 조금 긴 이름이 낫다.
- 매개변수 타입 주석 `string list` 와 반환 타입 주석 `HttpHandler` 가 둘 다 필요하다. `json` 은 어떤 타입이든 받는 제네릭 함수라서 매개변수 타입 주석을 빼면 `requestInvalidHandler` 가 `errors: 'a -> ...` 로 자동 일반화되고, 반환 타입 주석을 빼면 `recordMissingHandler` 가 매개변수 없는 `let` 바인딩이라 값 제한 오류 FS0030 에 걸린다. 지금 노트에서는 뒤의 핸들러가 이 값을 써서 타입이 정해지지만, 두 줄만 떼어 옮기면 바로 오류가 난다.
- 타입 주석을 달아 두면 FSI 도 타입 약어 `HttpHandler` 를 그대로 찍는다. 13챕터의 `notFoundHandler` 와 같은 모양이고, 펼쳐진 형태로 나오는 것은 `fun _ ctx -> ...` 처럼 람다로 적은 핸들러 쪽이다.

목록과 한 건 조회부터 만든다.

```fsharp id=14-server

        // FSI 실측: HttpFunc -> ctx: HttpContext -> HttpFuncResult
        let inspectionListHandler : HttpHandler =
            fun _ ctx ->
                let store = ctx.GetService<InspectionStore>()
                store.All() |> List.map toPayload |> ctx.WriteJsonAsync

        // FSI 실측: id: Guid -> next: HttpFunc -> ctx: HttpContext -> HttpFuncResult
        let inspectionDetailHandler (id: Guid) : HttpHandler =
            fun next ctx ->
                task {
                    let store = ctx.GetService<InspectionStore>()
                    let handler =
                        match store.TryFind(InspectionId id) with
                        | Some inspection -> json (toPayload inspection)
                        | None -> recordMissingHandler
                    return! handler next ctx
                }
```

- 목록 핸들러는 다음 핸들러를 부르지 않고 응답을 끝내므로 첫 매개변수를 `_` 로 버린다. `task` 가 없는 것은 `ctx.WriteJsonAsync` 가 이미 `Task` 를 돌려주기 때문이다.
- 한 건 조회 핸들러는 매개변수로 `Guid` 를 받는다. 뒤에서 `routef "/%O"` 로 연결할 것이고, 그 `%O` 가 경로 조각을 `Guid` 로 바꿔 넘긴다. 13챕터의 `%s` 와 같은 자리이고 핸들러로 넘어오는 타입만 다르다.
- `match` 로 핸들러를 고르고 마지막에 한 번 부르는 형태를 눈여겨볼 만하다. 분기마다 `return!` 을 적는 것보다 짧고, 두 분기의 타입이 같아야 한다는 사실이 눈에 보인다. 원서도 같은 형태를 쓰는데 괄호로 감싸 `(match ... with ...) next ctx` 로 적는다. 이 노트는 중간 값에 이름을 붙였다.
- `store.TryFind` 가 `Option` 을 돌려주므로 핸들러가 하는 일은 없음을 404 로 옮기는 것뿐이다. 저장소는 HTTP 를 모르고 핸들러만 상태 코드를 안다. 13챕터에서 `findHive` 를 두고 했던 이야기가 그대로 반복된다.

## POST — 모델 바인딩과 201 Created (원서 p.182)

- 본문을 읽는 부분을 따로 뽑는다. POST 와 PUT 이 같은 코드를 쓰고, 예외를 `Result` 로 바꾸는 자리를 한 곳으로 모을 수 있다.

```fsharp id=14-server

        // FSI 실측: ctx: HttpContext -> Task<Result<InspectionRequest,string list>>
        let bindRequest (ctx: HttpContext) =
            task {
                try
                    let! request = ctx.BindJsonAsync<InspectionRequest>()
                    return Ok request
                with :? JsonException ->
                    return Error [ "본문이 올바른 JSON 이 아니다" ]
            }
```

- `task { ... }` 는 12챕터에서 다룬 계산 식이다. 그 안에서도 `try ... with` 를 평범한 코드처럼 적을 수 있고, `let!` 이 기다리는 동안 난 예외도 여기서 걸린다.
- `:? JsonException` 은 3챕터에서 본 타입 테스트 패턴이다. 앞 절에서 확인한 대로 깨진 본문·빈 본문·타입 불일치가 모두 이 예외로 오므로 한 갈래로 충분하다.
- 예외를 잡아 `Result` 로 바꾸는 이 함수가 경계다. 여기서부터 아래로는 예외가 없고 값만 흐른다.

```fsharp id=14-server

        // FSI 실측: next: HttpFunc -> ctx: HttpContext -> HttpFuncResult
        let inspectionCreateHandler : HttpHandler =
            fun next ctx ->
                task {
                    let store = ctx.GetService<InspectionStore>()
                    let! bound = bindRequest ctx
                    let handler =
                        match bound with
                        | Error errors -> requestInvalidHandler errors
                        | Ok request ->
                            match validate request with
                            | Error errors -> requestInvalidHandler errors
                            | Ok code ->
                                let inspection =
                                    { Id = InspectionId(Guid.NewGuid())
                                      Hive = code
                                      Frames = request.Frames
                                      QueenSeen = request.QueenSeen
                                      RecordedAt = DateTime.UtcNow }
                                store.Save inspection
                                let (InspectionId id) = inspection.Id
                                setHttpHeader "Location" $"/api/inspections/{id}"
                                >=> Successful.CREATED(toPayload inspection)
                    return! handler next ctx
                }
```

- 흐름이 세 단계다. 본문을 읽고, 검증하고, 도메인 타입을 만들어 저장한다. 앞의 둘이 실패하면 400 이고 성공하면 201 이다.
- id 와 기록 시각은 서버가 정한다. 클라이언트가 보낸 것을 쓰지 않으므로 요청 타입에 그 두 필드가 없다.
- `Successful.CREATED` 가 상태 코드 201 을 붙인다. 원서는 저장소가 돌려준 `bool` 을 그대로 본문에 실어 200 으로 응답하는데, 그러면 만들기가 실패해도 200 이 나가고 클라이언트는 방금 만든 것의 id 를 알 수 없다. 201 과 함께 만들어진 것을 본문에 실어 주는 편이 낫다.
- `Location` 헤더는 만들어진 것을 어디서 볼 수 있는지 알려 준다. `>=>` 로 헤더 핸들러와 본문 핸들러를 이어 붙이는 것은 13챕터의 `apiSummaryHandler` 와 같은 형태다.

## PUT — 교체와 검증 (원서 p.182)

```fsharp id=14-server

        // FSI 실측: id: Guid -> next: HttpFunc -> ctx: HttpContext -> HttpFuncResult
        let inspectionUpdateHandler (id: Guid) : HttpHandler =
            fun next ctx ->
                task {
                    let store = ctx.GetService<InspectionStore>()
                    let! bound = bindRequest ctx
                    let handler =
                        match store.TryFind(InspectionId id), bound with
                        | None, _ -> recordMissingHandler
                        | Some _, Error errors -> requestInvalidHandler errors
                        | Some existing, Ok request ->
                            match validate request with
                            | Error errors -> requestInvalidHandler errors
                            | Ok code ->
                                let updated =
                                    { existing with
                                        Hive = code
                                        Frames = request.Frames
                                        QueenSeen = request.QueenSeen }
                                store.Save updated
                                json (toPayload updated)
                    return! handler next ctx
                }
```

- 있는지 확인한 결과와 본문을 읽은 결과를 튜플로 묶어 한 번에 매칭했다. 없는 id 면 본문이 잘못됐는지 따지지 않고 404 로 답한다.
- `{ existing with ... }` 는 2챕터의 복사-수정 레코드 식이다. 새 레코드를 만들어 저장하므로 원래 값은 그대로 남고, `Id` 와 `RecordedAt` 은 손대지 않는다. 점검 기록의 최초 기록 시각을 PUT 이 바꿔서는 안 된다.
- 원서는 갱신 결과로 `bool` 을 내보내고 실패에 상태 코드 410 을 쓴다. 410 은 있었는데 영구히 사라졌다는 뜻이라 없는 id 일반에 쓰기에는 좁다. 이 노트는 조회와 같은 404 로 맞췄다.

## DELETE — 204 No Content (원서 p.183)

```fsharp id=14-server

        // FSI 실측: id: Guid -> next: HttpFunc -> ctx: HttpContext -> HttpFuncResult
        let inspectionDeleteHandler (id: Guid) : HttpHandler =
            fun next ctx ->
                task {
                    let store = ctx.GetService<InspectionStore>()
                    let handler =
                        match store.Remove(InspectionId id) with
                        | Some _ -> Successful.NO_CONTENT
                        | None -> recordMissingHandler
                    return! handler next ctx
                }
```

- 삭제는 저장소의 `Remove` 한 번으로 끝난다. 지운 값을 `Option` 으로 돌려주므로 있었는지 없었는지가 그 결과에 담겨 있고, 원서처럼 먼저 조회하고 그 값으로 다시 지울 필요가 없다. 조회와 삭제를 두 번에 나누면 그 사이에 다른 요청이 끼어들 틈도 생긴다.
- `Successful.NO_CONTENT` 는 상태 코드 204 만 보내고 본문을 쓰지 않는다. 지운 것을 굳이 되돌려줄 이유가 없을 때 쓴다. 값을 받는 다른 핸들러들과 달리 인자 없는 값이다.

## Routes — 메서드별로 묶은 엔드포인트 목록 (원서 pp.179-180)

- 13챕터의 엔드포인트 목록은 `GET [ ... ]` 하나였다. 이제 네 가지 메서드가 붙는다. `GET`·`POST`·`PUT`·`DELETE` 는 각각 엔드포인트 목록을 받아 엔드포인트를 만드는 함수이므로, 메서드마다 묶음을 하나씩 적고 그것들을 리스트로 나열하면 된다.

```fsharp id=14-server

    // FSI 실측: Endpoint list
    let inspectionEndpoints =
        [
            GET [
                route "" Handlers.inspectionListHandler
                routef "/%O" Handlers.inspectionDetailHandler
            ]
            POST [
                route "" Handlers.inspectionCreateHandler
            ]
            PUT [
                routef "/%O" Handlers.inspectionUpdateHandler
            ]
            DELETE [
                routef "/%O" Handlers.inspectionDeleteHandler
            ]
        ]
```

- 같은 경로에 메서드만 다른 핸들러가 붙는다. `route ""` 가 `/api/inspections` 자체이고 `routef "/%O"` 가 그 아래 한 건이다. 접두는 이 목록을 얹는 쪽에서 붙인다.
- `routef` 의 서식 지정자는 경로 템플릿(route template)으로 번역되어 ASP.NET Core 라우팅에 넘어간다. 엔드포인트는 판별 유니온이고 `routef` 가 만든 값은 `TemplateEndpoint` 케이스에 그 템플릿 문자열을 담고 있으므로, 패턴 매칭으로 꺼내 볼 수 있다. `%O` 가 만드는 것은 이렇다.

```
GET  /{O0:regex(^[0-9A-Fa-f]{{8}}-[0-9A-Fa-f]{{4}}-[0-9A-Fa-f]{{4}}-[0-9A-Fa-f]{{4}}-[0-9A-Fa-f]{{12}}$|^[0-9A-Fa-f]{{32}}$|^[-_0-9A-Za-z]{{22}}$)}
```

- 중괄호가 겹쳐 있는 것은 경로 템플릿의 이스케이프다. ASP.NET Core 의 템플릿 파서는 `{{` 와 `}}` 를 리터럴 중괄호로 읽으므로, Giraffe 가 미리 겹쳐 둔 것이 파싱 단계에서 한 겹 풀려 실제 제약에는 `{8}` 이 들어간다. 정규식의 반복 횟수 표기가 템플릿의 매개변수 표기와 같은 문자를 쓰는 탓에 생긴 일이다.
- 제약이 있으니 `Guid` 모양이 아닌 조각은 이 엔드포인트에 아예 걸리지 않는다. `/api/inspections/oops` 는 핸들러에 닿지 못하고 13챕터에서 만든 `notFoundHandler` 로 떨어진다. 같은 404 라도 응답 본문이 다른 이유가 이것이다.
- 제약이 허용하는 모양은 셋이다. 하이픈이 들어간 보통 표기, 하이픈 없는 32자리, 그리고 22자리로 줄여 적은 표기다. 하이픈을 뺀 id 로 요청해도 같은 기록을 찾는 것을 뒤에서 확인한다.

## 13챕터의 나머지 조각과 콘텐츠 협상 (원서 p.184 확장)

여기부터 `Program.fs` 다. 뷰와 벌통 핸들러는 13챕터의 것을 그대로 쓴다.

```fsharp id=14-server

// Program.fs
open Domain
open Store

let notFoundHandler : HttpHandler =
    "요청한 경로가 없다"
    |> text
    |> RequestErrors.notFound

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

let hiveListHandler : HttpHandler =
    fun _ ctx ->
        hives
        |> List.map (fun hive ->
            let (HiveCode code) = hive.Code
            {| Hive = code; Frames = hive.Frames |})
        |> ctx.WriteJsonAsync

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

- 원서는 챕터를 맺으며 콘텐츠 협상(content negotiation)과 모델 검증을 아직 다루지 않았다고 적는다. 검증은 앞 절에서 했고, 콘텐츠 협상은 요약 핸들러 하나를 바꿔 보면 바로 확인된다.
- 콘텐츠 협상은 클라이언트가 `Accept` 헤더로 원하는 형식을 말하고 서버가 그중 만들 수 있는 것을 골라 응답하는 방식이다. Giraffe 의 핸들러 `negotiate` 가 그 판단을 한다. `json` 을 `negotiate` 로 바꾸면 같은 값이 형식만 달라져 나간다.

```fsharp id=14-server

// FSI 실측: apiSummaryHandler: HttpHandler
let apiSummaryHandler : HttpHandler =
    setHttpHeader "X-Apiary" "seongsu-rooftop"
    >=> negotiate {| Apiary = "성수 옥상"; Hives = List.length hives |}
```

- `AddGiraffe()` 가 등록해 두는 기본 규칙이 `Accept` 값과 핸들러를 짝지어 준다. 규칙은 다섯 개다. `application/json` 과 `*/*` 는 JSON, `text/plain` 은 값의 문자열 표현, `application/xml` 과 `text/xml` 은 XML 이다. 어느 규칙에도 맞지 않으면 상태 코드 406 으로 답한다.
- XML 은 기대와 다르다. Giraffe 8 의 기본 XML 직렬화기는 매개변수 없는 생성자를 요구하는데 F# 레코드에는 그것이 없다. `Accept: application/xml` 로 요청하면 `System.InvalidOperationException: ... cannot be serialized because it does not have a parameterless constructor.` 가 나고 500 이 돌아온다. 익명 레코드도 이름을 붙인 레코드도 마찬가지다. XML 을 정말 내보내야 한다면 직렬화기를 갈아 끼우거나, 레코드에 `[<CLIMutable>]` 을 붙여 매개변수 없는 생성자를 만들어 주거나, XML 용 타입을 따로 두어야 한다. 앞 절에서 JSON 에는 이 특성이 필요 없다고 적은 것과 대비되는 자리다. 익명 레코드에는 특성을 붙일 수 없다.
- `Successful.CREATED` 도 콘텐츠 협상을 거친다. POST 에 `Accept: text/plain` 을 붙이면 201 응답 본문이 JSON 이 아니라 문자열 표현으로 온다. 뒤의 확인에서 그 줄을 볼 수 있다.

## subRoute 를 한 층 더 얹는다 (원서 p.180)

- 13챕터가 라우팅을 두 층으로 만들어 두었다. HTTP 메서드 묶음을 안쪽 `apiEndpoints` 에 둔 덕에 이 챕터가 손댈 곳은 한 줄이다.

```fsharp id=14-server

// FSI 실측: apiEndpoints: Endpoint list
let apiEndpoints =
    [
        GET [
            route "" apiSummaryHandler
            route "/hives" hiveListHandler
            routef "/hives/%s" hiveStatusHandler
        ]
        subRoute "/inspections" Inspections.inspectionEndpoints
    ]

// 13챕터와 한 글자도 다르지 않다
let endpoints =
    [
        GET [
            route "/" (htmlView indexView)
        ]
        subRoute "/api" apiEndpoints
    ]
```

- `subRoute "/inspections" Inspections.inspectionEndpoints` 한 줄이 다른 파일에서 만든 목록을 여기에 꽂는다. 라우팅이 값이라 이렇게 넘길 수 있다는 것이 13챕터에서 본 성질이고, 이 챕터가 그 값을 실제로 다른 파일에서 만들어 왔다.
- 원서는 새 경로를 바깥 `endpoints` 에 `subRoute "/api/todo" ...` 로 붙이고, 경로 문자열을 한곳에 모아 두는 편이 좋다고 적는다. 취향의 문제이고 원서도 그렇게 말한다. 이 노트는 `/api` 아래의 일을 `apiEndpoints` 안에서 끝내는 쪽을 골랐다. 접두가 한 번만 나오고, `/api` 밖의 경로와 안의 경로를 눈으로 갈라 볼 수 있다.

## 설정 — 저장소를 싱글턴으로 등록한다 (원서 p.179)

```fsharp id=14-server

// FSI 실측: services: IServiceCollection -> unit
let configureServices (services: IServiceCollection) =
    let options = JsonSerializerOptions(JsonSerializerDefaults.Web)
    options.Encoder <- JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    services
        .AddRouting()
        .AddGiraffe()
        .AddSingleton<Json.ISerializer>(Json.Serializer options)
        .AddSingleton<InspectionStore>(InspectionStore())
    |> ignore

// FSI 실측: appBuilder: IApplicationBuilder -> unit
let configureApp (appBuilder: IApplicationBuilder) =
    appBuilder
        .UseRouting()
        .UseGiraffe(endpoints)
        .UseGiraffe(notFoundHandler)
```

- 13챕터의 `configureServices` 에서 달라진 것은 마지막 등록 한 줄이다. `AddSingleton<InspectionStore>(InspectionStore())` 가 인스턴스를 직접 만들어 넘긴다. 초기 데이터를 넣어 두고 싶으면 그 생성자에 넘기면 된다.
- 등록 순서는 상관없다. `configureApp` 의 순서는 상관있다. 13챕터에서 본 대로 미들웨어 파이프라인을 정하는 코드라 라우팅을 먼저 켜고, 엔드포인트를 등록하고, 어디에도 걸리지 않은 요청을 받는 핸들러를 마지막에 둔다. 이 챕터가 여기는 건드리지 않는다.
- 진입점도 13챕터와 같다. `configureServices` 와 `configureApp` 을 부르고 `app.Run()` 으로 끝난다.

## Using the API — 실제 요청과 응답 (원서 pp.183-184)

- 원서는 Postman 으로 API 를 만져 보라고 안내하고 목록·생성 응답 두 개를 보여 준다. 프로젝트를 띄워 `curl` 로 확인하면 다음과 같다. 날짜와 전송 관련 헤더는 줄였다.

```bash
dotnet run
# 다른 터미널에서
curl -i -X POST http://localhost:5291/api/inspections \
     -H "Content-Type: application/json" \
     -d '{"hive":"h-07","frames":9,"queenSeen":true}'
```

```
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Location: /api/inspections/75eb055d-28ce-4a8a-89c4-4fe6886732f1

{"frames":9,"hive":"H-07","id":"75eb055d-28ce-4a8a-89c4-4fe6886732f1","queenSeen":true,"recordedAt":"2026-09-07T02:48:14Z"}
```

```
# curl -i -X DELETE http://localhost:5291/api/inspections/75eb055d-28ce-4a8a-89c4-4fe6886732f1
HTTP/1.1 204 No Content

# curl -i -X POST ... -d '{"queenSeen":true}'
HTTP/1.1 400 Bad Request
Content-Type: application/json; charset=utf-8

{"errors":["hive 를 적어야 한다","frames 는 1 이상이어야 한다"]}
```

- 원서 p.184 가 보여 주는 목록 응답은 `{"key": ..., "value": ...}` 를 원소로 담은 배열이다. 그런데 원서의 `GetAll` 은 `data.Values |> Seq.toArray` 여서 값만 나와야 하고 그 모양이 되지 않는다. 사전을 `KeyValuePair` 의 컬렉션으로 직렬화한 결과처럼 보이며, 코드와 지면의 출력 예가 어긋난 대목이다. 어느 쪽이든 사전의 구현 세부가 API 응답에 새어 나온 모양이므로 클라이언트가 볼 것이 아니다. 이 노트의 `All` 은 값만 담은 리스트를 돌려주므로 응답이 평평한 배열이다.

같은 확인을 스크립트에서 한다. 앞의 `14-server` 블록들이 프로젝트 코드와 같은 정의를 쌓아 두었으므로 남은 것은 호스트를 띄우고 요청을 보내는 부분이다.

```fsharp id=14-server

// 여기부터는 검증용 코드다
let builder = WebApplication.CreateBuilder()
configureServices builder.Services
builder.Logging.ClearProviders() |> ignore

let app = builder.Build()
configureApp app
app.Urls.Add "http://127.0.0.1:0"            // 0 = 빈 포트를 골라 달라는 뜻
app.StartAsync() |> Async.AwaitTask |> Async.RunSynchronously

let baseUrl = app.Urls |> Seq.head
let client = new Net.Http.HttpClient()

// 새로 만든 id 와 기록 시각은 실행마다 달라지므로 자리표시자로 바꿔 찍는다
let mask (value: string) =
    let replace (pattern: string) (replacement: string) (input: string) =
        Text.RegularExpressions.Regex.Replace(input, pattern, replacement)
    value
    |> replace "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}" "<id>"
    |> replace "[0-9a-f]{32}" "<id-n>"
    |> replace @"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z" "<time>"

let jsonBody (content: string) =
    new Net.Http.StringContent(content, Text.Encoding.UTF8, "application/json")

let call (method: string) (path: string) (body: string option) (accept: string option) =
    let request = new Net.Http.HttpRequestMessage(Net.Http.HttpMethod method, baseUrl + path)
    body |> Option.iter (fun content -> request.Content <- jsonBody content)
    accept |> Option.iter (fun value -> request.Headers.TryAddWithoutValidation("Accept", value) |> ignore)
    let response = client.SendAsync request |> Async.AwaitTask |> Async.RunSynchronously
    let text = response.Content.ReadAsStringAsync() |> Async.AwaitTask |> Async.RunSynchronously
    response, (if text = "" then "(본문 없음)" else mask text)

let send method path body =
    let response, text = call method path body None
    printfn "%-6s %-23s %d  %s" method (mask path) (int response.StatusCode) text
    response
```

먼저 빈 저장소를 확인하고 한 건을 만든다.

```fsharp id=14-server

send "GET" "/api/inspections" None |> ignore
// GET    /api/inspections        200  []
send "GET" "/api/inspections/2f8b0a4e-0000-4000-8000-000000000000" None |> ignore
// GET    /api/inspections/<id>   404  {"error":"점검 기록이 없다"}

let created = send "POST" "/api/inspections" (Some """{"hive":"h-07","frames":9,"queenSeen":true}""")
// POST   /api/inspections        201  {"frames":9,"hive":"H-07","id":"<id>","queenSeen":true,"recordedAt":"<time>"}
let createdPath = string created.Headers.Location
printfn "Location: %s" (mask createdPath)
// Location: /api/inspections/<id>
```

- 소문자로 보낸 `h-07` 이 `H-07` 로 저장되었다. 13챕터의 `findHive` 가 대문자로 바꿔 비교하고, 검증이 그 결과의 `HiveCode` 를 돌려주므로 정규화가 한 번만 일어난다.
- 만들기 전에 임의의 id 로 조회한 것이 404 이고 본문이 JSON 이다. 뒤에 나오는 경로 자체가 없는 404 와 비교할 자리다.

만든 것을 다시 읽는다. `Location` 헤더의 경로가 그대로 조회 경로다.

```fsharp id=14-server

send "GET" "/api/inspections" None |> ignore
// GET    /api/inspections        200  [{"frames":9,"hive":"H-07","id":"<id>","queenSeen":true,"recordedAt":"<time>"}]
send "GET" createdPath None |> ignore
// GET    /api/inspections/<id>   200  {"frames":9,"hive":"H-07","id":"<id>","queenSeen":true,"recordedAt":"<time>"}

// 하이픈을 뺀 32자리 표기도 경로 템플릿의 제약을 지나간다
let createdId = Guid(createdPath.Split('/') |> Array.last)
let dashless = createdId.ToString "N"
send "GET" $"/api/inspections/{dashless}" None |> ignore
// GET    /api/inspections/<id-n> 200  {"frames":9,"hive":"H-07","id":"<id>","queenSeen":true,"recordedAt":"<time>"}
```

- `<id>` 와 `<id-n>` 은 자리표시자다. 앞은 하이픈이 들어간 보통 표기, 뒤는 하이픈을 뺀 32자리다. 두 요청이 같은 기록을 찾아 왔다.

교체와 실패 경로를 확인한다.

```fsharp id=14-server

send "PUT" createdPath (Some """{"hive":"H-11","frames":10,"queenSeen":false}""") |> ignore
// PUT    /api/inspections/<id>   200  {"frames":10,"hive":"H-11","id":"<id>","queenSeen":false,"recordedAt":"<time>"}
send "POST" "/api/inspections" (Some """{"queenSeen":true}""") |> ignore
// POST   /api/inspections        400  {"errors":["hive 를 적어야 한다","frames 는 1 이상이어야 한다"]}
send "POST" "/api/inspections" (Some """{"hive":"H-99","frames":3}""") |> ignore
// POST   /api/inspections        400  {"errors":["등록되지 않은 벌통 코드: H-99"]}
send "POST" "/api/inspections" (Some """{"hive":}""") |> ignore
// POST   /api/inspections        400  {"errors":["본문이 올바른 JSON 이 아니다"]}
```

- PUT 이 `id` 와 `recordedAt` 을 그대로 두고 나머지만 바꿨다. 복사-수정 식에 그 두 필드를 적지 않았기 때문이다.
- 400 세 줄이 각각 다른 자리에서 나왔다. 첫 줄은 검증이 실패를 둘 모아 온 것이고, 둘째 줄은 `findHive` 가 낸 실패이며, 셋째 줄은 `bindRequest` 가 `JsonException` 을 잡아 바꾼 것이다. 세 갈래가 한 모양의 응답으로 모인다.

삭제와 없는 경로를 확인하고 서버를 내린다.

```fsharp id=14-server

send "DELETE" createdPath None |> ignore
// DELETE /api/inspections/<id>   204  (본문 없음)
send "DELETE" createdPath None |> ignore
// DELETE /api/inspections/<id>   404  {"error":"점검 기록이 없다"}
send "GET" "/api/inspections/oops" None |> ignore
// GET    /api/inspections/oops   404  요청한 경로가 없다
```

- 같은 요청을 두 번 보내면 204 다음에 404 다. 저장소가 지운 값을 `Option` 으로 돌려주므로 핸들러가 그 차이를 상태 코드로 옮길 수 있다.
- 마지막 줄이 앞에서 이야기한 경로 템플릿 제약이다. `oops` 는 `Guid` 모양이 아니어서 엔드포인트에 걸리지 않고, 응답이 `notFoundHandler` 의 평문이다. 같은 404 인데 본문이 JSON 이 아닌 것으로 어느 자리에서 나온 404 인지 구별된다.

콘텐츠 협상은 `Accept` 헤더를 붙여 확인한다.

```fsharp id=14-server

let negotiated method path body accept =
    let response, text = call method path body (Some accept)
    let oneLine = Text.RegularExpressions.Regex.Replace(text, @"\s+", " ")
    printfn "%-4s %-17s %d  %-31s %s" method accept (int response.StatusCode)
        (string response.Content.Headers.ContentType) oneLine

negotiated "GET" "/api" None "application/json"
// GET  application/json  200  application/json; charset=utf-8 {"apiary":"성수 옥상","hives":2}
negotiated "GET" "/api" None "text/plain"
// GET  text/plain        200  text/plain; charset=utf-8       { Apiary = "성수 옥상" Hives = 2 }
negotiated "GET" "/api" None "text/html"
// GET  text/html         406  text/plain; charset=utf-8       text/html is unacceptable by the server.
negotiated "POST" "/api/inspections" (Some """{"hive":"H-11","frames":7,"queenSeen":true}""") "text/plain"
// POST text/plain        201  text/plain; charset=utf-8       { Frames = 7 Hive = "H-11" Id = <id> QueenSeen = true RecordedAt = "<time>" }

app.StopAsync() |> Async.AwaitTask |> Async.RunSynchronously
client.Dispose()
printfn "서버를 내렸다"   // 서버를 내렸다
```

- 같은 요약 핸들러가 `Accept` 에 따라 세 가지로 답했다. `text/plain` 응답의 본문은 값의 문자열 표현이고, 원래 여러 줄로 오는 것을 위에서는 한 줄로 줄여 찍었다. 마지막 줄은 `Successful.CREATED` 도 같은 협상을 거친다는 것을 보여 준다.
- `Accept: text/html` 만 보내면 규칙에 없으므로 406 이다. 그런데 브라우저가 실제로 보내는 값은 `text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8` 이고, 협상은 품질값(`q`)이 큰 것부터 규칙에 있는 첫 형식을 고른다. `text/html` 을 지나 `application/xml` 이 먼저 걸리므로 주소창으로 열면 406 이 아니라 앞에서 본 XML 직렬화 실패로 500 이 온다. `text/html,*/*;q=0.8` 처럼 `*/*` 가 붙은 값이면 200 JSON 이다. 13챕터의 첫 화면처럼 HTML 을 내보내야 하는 경로에는 `htmlView` 를 그대로 쓴다.
- 마지막 두 줄이 중요하다. 서버를 내리고 클라이언트를 해제해야 스크립트가 끝나고, 다음 검증이 막히지 않는다.

## Summary — 원서의 챕터 요약 (원서 p.184)

- 원서는 Giraffe 로 API 를 만드는 방법의 겉만 훑었다고 적고, 콘텐츠 협상과 모델 검증 같은 것이 더 있으니 Giraffe 문서를 읽어 보라고 권한다.
- 이 노트는 그중 둘을 앞당겨 확인했다. 검증은 8챕터의 방식을 그대로 쓰면 되고, 콘텐츠 협상은 핸들러 하나를 바꾸는 것으로 되지만 XML 쪽에는 함정이 있다.
- 다음 챕터에서는 HTML 뷰로 돌아가 View Engine 을 깊게 다룬다.

## 정리 — 이 노트의 요약

- 쓰기를 받는 API 에는 상태를 담을 그릇이 필요하다. `ConcurrentDictionary` 를 클래스 타입으로 감싸 저장소를 만들고, 의존성 주입 컨테이너에 싱글턴으로 등록해 앱 전체가 하나를 쓰게 한다.
- 핸들러는 `ctx.GetService<InspectionStore>()` 로 그 인스턴스를 꺼낸다. 원서가 서비스 로케이션이라 부르는 방식이고, 매개변수로 받지 않으므로 테스트에서 갈아 끼우기는 까다롭다.
- `out` 매개변수를 쓰는 .NET 메서드는 F# 에서 튜플을 돌려주므로 `match dict.TryGetValue key with | true, v -> Some v | false, _ -> None` 이 관용구다. 오버로드가 둘 이상인 `TryRemove` 같은 메서드는 키 타입을 주석으로 못박아야 한다.
- 저장소가 `bool` 대신 `Option` 을 돌려주면 상태 코드 선택이 핸들러 한 곳으로 모인다. 원서의 `Update` 구현은 없는 키에서 인덱서가 `KeyNotFoundException` 을 던져 500 이 나가므로, 갱신은 인덱서 설정으로 하고 존재 확인은 핸들러가 한다.
- 요청 본문은 `ctx.BindJsonAsync<'T>()` 로 받는다. 도메인 타입을 그대로 쓸 수 없다. `Option` 이 아닌 판별 유니온은 읽는 방향에서도 `NotSupportedException` 이고, 서버가 정하는 id 와 시각을 클라이언트가 보낼 이유도 없다. 요청과 응답에는 평평한 DTO 를 따로 둔다.
- 모델 바인딩은 검증이 아니다. 필드가 빠진 본문도 예외 없이 통과하고 문자열 필드에 `null` 이 들어온다. `bool` 과 `int` 는 빠진 것과 기본값을 구별할 수 없으므로 그 구별이 필요하면 요청 타입의 필드를 `Option` 으로 적는다. 모델 바인딩 뒤에 검증이 반드시 와야 하고, 검증은 8챕터처럼 실패를 모아 한 번에 400 으로 내보내면 된다.
- 깨진 본문·빈 본문·타입 불일치는 모두 `JsonException` 이다. `task { try ... with :? JsonException -> ... }` 로 한 번 잡아 `Result` 로 바꾸면, 그 아래로는 예외 없이 값만 흐른다. 잡지 않으면 클라이언트 잘못에 500 이 나간다.
- 상태 코드는 `Successful.CREATED`(201), `Successful.NO_CONTENT`(204), `RequestErrors.badRequest`(400), `RequestErrors.notFound`(404) 로 고른다. 만든 것의 위치는 `Location` 헤더로 알려 준다.
- `routef "/%O"` 는 `Guid` 모양을 요구하는 정규식 제약이 붙은 경로 템플릿으로 번역된다. 모양이 맞지 않는 조각은 핸들러에 닿지 못하고 `notFoundHandler` 로 떨어지며, 하이픈을 뺀 32자리 표기는 제약을 지나간다.
- `negotiate` 는 `Accept` 헤더를 보고 형식을 고른다. JSON 과 평문은 바로 되지만, Giraffe 8 의 기본 XML 직렬화기는 매개변수 없는 생성자를 요구해서 F# 레코드를 다루지 못한다. 규칙에 없는 형식은 406 이다.
- 파일을 나누는 대가는 컴파일 순서를 적는 것이다. 참조 방향이 순서를 정하고 `[<EntryPoint>]` 는 마지막 파일에 있어야 한다. 라우팅이 값이므로 엔드포인트 목록을 다른 파일에서 만들어 `subRoute` 로 꽂을 수 있다.

### 15챕터가 이어받는 것

프로젝트는 `HiveLog` 이고 이제 파일이 넷이다. `.fsproj` 의 컴파일 순서는 `Domain.fs`, `Store.fs`, `Inspections.fs`, `Program.fs` 이며 15챕터가 뷰를 새 파일로 뺀다면 `Program.fs` 앞에 넣어야 한다. 도메인은 `Domain.fs` 로 옮겨졌고 `HiveCode`·`Hive`·`hives`·`findHive` 에 `InspectionId`·`Inspection` 이 더해졌다. 점검 기록 저장소 `InspectionStore` 는 `AddSingleton` 으로 등록되어 있어 핸들러가 `ctx.GetService<InspectionStore>()` 로 꺼내 쓴다. 라우팅은 세 층이다. 바깥 `endpoints` 에 첫 화면과 `subRoute "/api" apiEndpoints`, `apiEndpoints` 에 벌통 경로들과 `subRoute "/inspections" Inspections.inspectionEndpoints` 가 있다. 15챕터가 화면용 경로를 더할 자리는 바깥 `endpoints` 이고, `/api` 아래는 건드릴 일이 없다. 이름 규칙은 13챕터와 같다. 핸들러 `<대상><동작 또는 응답 내용>Handler`, 엔드포인트 목록 `<영역>Endpoints`, 뷰 `<이름>View` 이며 핸들러를 담는 중첩 모듈은 `Handlers` 다. 원서에서 온 `notFoundHandler` 는 대상이 없어 규칙 밖이다. 뷰는 `indexView` 하나뿐이고 `p [ _class "lede"; _id "intro" ]` 가 CSS 클래스를 하나 쓰고 있는데, 그 클래스를 정의할 `/css/hive.css` 와 그것을 담을 `wwwroot/` 는 아직 없으므로 15챕터가 만든다. 정적 파일을 내보내려면 `configureApp` 에 `UseStaticFiles` 계열의 미들웨어가 한 줄 더 들어가야 한다는 점도 그 챕터의 일이다. 응답에 도메인 타입을 그대로 실을 수 없다는 제약은 뷰에는 해당하지 않는다. View Engine 은 F# 값을 직접 읽어 HTML 을 만들므로 `Inspection` 을 그대로 넘겨도 된다. 검증 방식은 그대로 물려받는다. `14-server` 실행 단위의 준비 코드를 쓰고, 포트 `0` 으로 띄워 `HttpClient` 로 요청한 뒤 `StopAsync` 로 내린다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Getting Started · Our Task — 이 챕터가 더하는 것 | p.178 | — |
| Handlers — 파일을 넷으로 나눈다 | p.181 | — |
| 스크립트에서 앱을 세우는 준비 | (노트 보충) | `14-server` |
| Sample Data — 쓸 수 있는 저장소 | pp.178-179 | `14-store`, `14-server` |
| 저장소를 의존성 주입으로 넘긴다 | p.179 | — |
| 요청 본문과 응답 본문을 위한 타입 | p.182 확장 | `14-binding`, `14-server` |
| Handlers — 실패 응답과 GET 두 개 | pp.181-182 | `14-server` |
| POST — 모델 바인딩과 201 Created | p.182 | `14-server` |
| PUT — 교체와 검증 | p.182 | `14-server` |
| DELETE — 204 No Content | p.183 | `14-server` |
| Routes — 메서드별로 묶은 엔드포인트 목록 | pp.179-180 | `14-server` |
| 13챕터의 나머지 조각과 콘텐츠 협상 | p.184 확장 | `14-server` |
| subRoute 를 한 층 더 얹는다 | p.180 | `14-server` |
| 설정 — 저장소를 싱글턴으로 등록한다 | p.179 | `14-server` |
| Using the API — 실제 요청과 응답 | pp.183-184 | `14-server` |
| Summary — 원서의 챕터 요약 | p.184 | — |
