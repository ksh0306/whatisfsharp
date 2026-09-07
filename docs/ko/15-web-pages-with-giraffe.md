# 15 - Giraffe 로 웹 페이지 만들기 (원서 pp.185-191)

> 13챕터가 첫 화면 하나를 띄우고 14챕터가 API 를 채웠다. 이 챕터에서는 그 API 가 다루는 데이터를 사람이 볼 화면으로 내보내며 앱을 마무리한다. 새 문법은 거의 없다. 13챕터에서 훑어본 View Engine 의 DSL 을 실제 화면 두 개에 쓰고, 여러 화면이 공유할 공용 레이아웃을 함수 하나로 뽑고, 목록을 리스트 컴프리헨션으로 만들고, CSS·JavaScript 를 내보내려고 `configureApp` 에 미들웨어 한 줄을 더한다. 5챕터의 컬렉션, 9챕터의 단일 케이스 판별 유니온, 4챕터의 컴파일 순서가 화면 코드에서 다시 만난다.

14챕터에서 넘어오는 것은 이렇다. 프로젝트 `HiveLog` 는 파일이 넷이고 컴파일 순서가 `Domain.fs` → `Store.fs` → `Inspections.fs` → `Program.fs` 다. 도메인은 옥상 양봉장의 벌통 점검 기록이고 `HiveCode`·`Hive`·`hives`·`findHive`·`InspectionId`·`Inspection` 이 있다. 점검 기록 저장소 `InspectionStore` 는 의존성 주입 컨테이너에 싱글턴으로 등록되어 있어 핸들러가 `ctx.GetService<InspectionStore>()` 로 꺼내 쓴다. 라우팅은 세 층이다 — 바깥 `endpoints`, 그 안의 `subRoute "/api" apiEndpoints`, 다시 그 안의 `subRoute "/inspections" Inspections.inspectionEndpoints`. 뷰는 `indexView` 하나뿐이고 `wwwroot/` 는 아직 없다.

## Getting Started — 이 챕터가 더하는 것 (원서 p.185)

- 원서는 앞 챕터의 프로젝트를 계속 고쳐 나가고, HTML·CSS 를 직접 짜는 대신 w3schools 의 할 일 목록 예제를 가져와 View Engine 형식으로 옮긴다. 데이터는 서버가 만든 가짜 목록이다.
- 이 노트는 도메인을 13·14챕터에서 이어받으므로 화면도 점검 기록이다. 만드는 것은 셋이다. 여러 화면이 공유할 공용 레이아웃, 점검 기록 한 건을 목록의 한 줄로 바꾸는 부분 뷰, 그리고 저장소의 기록을 그 부분 뷰로 늘어놓는 화면이다.
- 경로는 둘로 갈린다. `/api/inspections` 는 14챕터가 만든 JSON 응답이고, 이 챕터가 더하는 `/inspections` 는 같은 데이터의 HTML 화면이다. 저장소 하나를 두 표현이 나눠 쓴다.

```
GET /                     첫 화면 (13챕터의 indexView 를 레이아웃 위에 올린다)
GET /inspections          점검 기록 화면 (이 챕터가 더한다)
GET /css/hive.css         정적 파일 (이 챕터가 더한다)
GET /js/hive.js           정적 파일 (이 챕터가 더한다)
GET /api/inspections      14챕터의 JSON 응답 (그대로 둔다)
```

- 뷰를 새 파일로 빼면 `Views.fs` 가 `Program.fs` 앞에 와야 한다. 뷰가 참조하는 것은 `Domain.fs` 의 타입뿐이고, 뷰를 참조하는 것은 `Program.fs` 의 핸들러다. 그래서 자리는 하나로 정해진다.

```xml
  <ItemGroup>
    <Compile Include="Domain.fs" />
    <Compile Include="Store.fs" />
    <Compile Include="Inspections.fs" />
    <Compile Include="Views.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>
```

- 원서는 공용 레이아웃을 `Shared.fs` 에 두고 화면 뷰는 `Todos.fs` 안의 `Views` 모듈에 둔다. 파일을 둘로 갈라야 할 이유가 이 규모에서는 없으므로 이 노트는 `Views.fs` 하나에 레이아웃과 화면을 함께 담는다.
- 14챕터가 응답에서 만난 제약은 화면에는 없다. `System.Text.Json` 이 `Option` 이 아닌 판별 유니온을 다루지 못해 API 는 평평한 DTO 를 따로 두어야 했지만, View Engine 은 F# 값을 직접 읽어 HTML 을 만들므로 `Inspection` 을 그대로 뷰 함수에 넘겨도 된다. 껍데기를 벗기는 일은 뷰 안에서 패턴으로 처리한다.

## Configuration — wwwroot 와 부록 2 (원서 p.185)

- 정적 파일(static files)은 서버가 내용을 손대지 않고 그대로 내보내는 파일이다. CSS·JavaScript·이미지·글꼴이 여기 든다. ASP.NET Core 의 기본 규칙은 콘텐츠 루트(content root) 아래 `wwwroot/` 를 웹 루트(web root)로 삼고 그 안의 파일만 내보내는 것이다. 프로젝트 폴더에 `wwwroot/` 를 만들면 따로 설정할 것이 없다.
- 원서는 `wwwroot/css/main.css` 와 `wwwroot/js/main.js` 를 만들고 그 내용을 부록 2 에서 복사해 오라고 안내한다. 부록 2 는 원서 pp.197-201 이고, w3schools 할 일 목록 예제의 CSS 와 JavaScript 가 그대로 실려 있다. CSS 쪽은 목록 항목 줄무늬·완료 표시·삭제 버튼·머리글 색과 입력란 배치를 정하고, JavaScript 쪽은 항목마다 닫기 버튼을 붙이고(누르면 그 항목이 숨는다) 클릭으로 완료 표시를 켜고 끄며 입력란의 값으로 새 항목을 만든다.
- 부록 2 의 코드는 원서 뷰의 `id` 와 클래스 이름(`myUL`·`myInput`·`checked`·`close`·`addBtn`)을 그대로 찾으므로, 뷰에서 그 이름을 바꾸면 CSS 와 JavaScript 도 같이 바꿔야 한다.
- 이 노트는 그 두 파일을 옮기지 않는다. 대신 벌통 점검 기록 화면에 맞는 최소한의 CSS 와 JavaScript 를 새로 짜서 `wwwroot/css/hive.css` 와 `wwwroot/js/hive.js` 에 둔다. 원서 부록의 내용과는 관계가 없고, 정적 파일이 실제로 내보내지는지 확인할 만큼만 짧다. 원서를 따라 실습한다면 부록 2 의 코드를 원서에서 직접 가져다 쓰면 된다.
- 파일을 두었다고 저절로 나가지는 않는다. `configureApp` 에 정적 파일 미들웨어를 한 줄 더해야 한다. 그 코드는 뒤의 설정 절에 있다.

```fsharp
// 이 챕터가 configureApp 에 더하는 한 줄
        .UseStaticFiles()
```

- 웹 루트를 `wwwroot` 가 아닌 곳으로 바꾸려면 호스트를 만들 때 `WebApplicationOptions(WebRootPath = "public")` 처럼 옵션으로 넘긴다. 빌더를 만든 뒤에 `builder.WebHost.UseWebRoot` 로 바꾸려 하면 `System.NotSupportedException` 이 난다. 뒤의 검증 코드가 옵션으로 넘기는 쪽을 쓰는데, 스크립트로 실행할 때는 콘텐츠 루트가 프로젝트 폴더가 아니어서 경로를 못박아야 하기 때문이다.
- 이 노트가 확인한 SDK 10.0.111 에는 `MapStaticAssets` 라는 다른 방법도 들어 있다. 빌드 때 만들어지는 자산 목록에 기대어 압축본과 캐시 헤더까지 함께 처리하는 쪽이다. 빌드 산출물이 필요하므로 `dotnet fsi` 스크립트에서는 쓸 수 없고, 이 노트는 원서와 같이 `UseStaticFiles` 를 쓴다.
- 웹 프로젝트 템플릿(`dotnet new web`)으로 만든 프로젝트라면 `UseStaticFiles` 를 쓰는 데 패키지를 더 받을 필요가 없다. 프레임워크 참조에 이미 들어 있다.

## Adding a Master Page — 공용 레이아웃 (원서 pp.186-187)

- 화면이 둘 이상 생기면 `<html>`·`<head>`·스타일시트 링크가 화면마다 반복된다. 원서는 그 껍데기를 함수 하나로 뽑고 제목과 본문을 넘겨받게 만든다. 다른 뷰 엔진에서 마스터 페이지나 레이아웃이라 부르는 것이고, View Engine 에서는 그저 함수다.
- 그래서 상속이나 특별한 규칙이 필요하지 않다. 레이아웃 함수는 `XmlNode list` 를 받아 `XmlNode` 를 돌려주고, 화면 뷰는 자기 본문 목록을 만들어 그 함수에 넘긴다.

아래 실행 단위는 `Views.fs` 에 들어갈 코드를 서버 없이 문자열로 렌더링해 확인한다. 선행 요구사항은 처음 한 번 `Giraffe.ViewEngine` 1.4.0 을 받아 올 네트워크다. 받아 오지 못하면 `error FS0999` 로 실패한다.

```fsharp id=15-view
// 이 단위가 보여주는 것: 공용 레이아웃 함수와 그 위에 올리는 화면 뷰
#r "nuget: Giraffe.ViewEngine, 1.4.0"

open System
open System.Globalization
open Giraffe.ViewEngine

// FSI 실측: heading: string -> content: XmlNode list -> XmlNode
let pageLayout (heading: string) (content: XmlNode list) =
    html [ _lang "ko" ] [
        head [] [
            meta [ _charset "utf-8" ]
            title [] [ str heading ]
            link [ _rel "stylesheet"; _href "/css/hive.css" ]
        ]
        body [] [
            header [ _class "bar" ] [ h1 [] [ str heading ] ]
            main [] content
            script [ _src "/js/hive.js" ] []
        ]
    ]
```

- 요소 함수 대부분이 리스트 둘을 받는다. 앞은 특성 목록, 뒤는 자식 목록이다. `meta`·`link` 처럼 자식을 담을 수 없는 요소는 특성 목록만 받는다. 자식 목록을 붙이려 하면 컴파일되지 않으므로, 자식을 담을 수 없는 요소에 내용을 넣는 실수가 애초에 생기지 않는다.
- 스타일시트 경로에 앞 슬래시를 붙인 것에 뜻이 있다. 원서는 `_href "css/main.css"` 로 적는데, 앞 슬래시가 없는 경로는 브라우저가 현재 주소를 기준으로 풀기 때문에 `/inspections` 화면에서는 `/inspections/css/main.css` 를 찾는다. 원서 예제는 화면이 `/` 하나뿐이라 드러나지 않는 문제다. 뒤의 확인 절에서 그 경로가 404 인 것을 본다.
- `script` 에는 `_type "text/javascript"` 를 적지 않았다. 원서는 적어 두지만 HTML5 에서 그 값이 기본이라 없어도 같다.

레이아웃을 쓰는 쪽은 본문 목록을 만들어 파이프로 넘긴다. 13챕터의 첫 화면 뷰를 그 형태로 고친다.

```fsharp id=15-view

// FSI 실측: indexView: XmlNode
let indexView =
    [
        p [ _class "lede" ] [ str "옥상 양봉장 점검 기록" ]
        nav [] [ a [ _href "/inspections" ] [ str "점검 기록 보기" ] ]
    ]
    |> pageLayout "HiveLog"

printfn "%s" (RenderView.AsString.htmlDocument indexView)
// <!DOCTYPE html>
// <html lang="ko"><head><meta charset="utf-8"><title>HiveLog</title><link rel="stylesheet" href="/css/hive.css"></head><body><header class="bar"><h1>HiveLog</h1></header><main><p class="lede">옥상 양봉장 점검 기록</p><nav><a href="/inspections">점검 기록 보기</a></nav></main><script src="/js/hive.js"></script></body></html>
```

- 본문 목록을 먼저 적고 `|> pageLayout "HiveLog"` 로 끝내면 읽는 순서가 화면의 내용에서 껍데기로 흐른다. 원서도 같은 형태를 쓴다.
- 13챕터의 `indexView` 는 `p [ _class "lede" ]` 를 쓰면서 정작 그 클래스를 정의한 CSS 가 없었다. 이 챕터가 `wwwroot/css/hive.css` 를 만들어 그 자리를 채운다. 13챕터의 표 예제가 링크한 파일도 같은 `/css/hive.css` 다.
- 렌더링 함수는 13챕터에서 본 그대로다. 문서 전체는 `RenderView.AsString.htmlDocument`(앞에 `<!DOCTYPE html>` 이 붙는다), 조각은 `RenderView.AsString.htmlNode` 이며 둘 다 `XmlNode -> string` 이다.

## str 이 문자를 이스케이프한다 (노트 보충)

- 원서 p.187 은 View Engine 방식의 이점을 타입 안전성으로 설명한다. 문자열을 찾아 바꾸는 다른 뷰 엔진과 달리 F# 코드로 구조를 만들기 때문이다. 실제로는 이점이 하나 더 있는데, 데이터가 HTML 문법으로 새어 나가지 못한다는 것이다.
- 사람이 적어 넣은 값을 화면에 뿌리는 자리에서 이 성질이 중요하다. 아래 결과가 곧 화면에 나가는 HTML 이다.

```fsharp id=15-escape
// 이 단위가 보여주는 것: str 은 이스케이프하고 rawText 는 하지 않는다
#r "nuget: Giraffe.ViewEngine, 1.4.0"

open Giraffe.ViewEngine

// 점검자가 적어 넣은 메모라고 하자. HTML 문법에 쓰이는 문자가 섞여 있다
let memo = """벌통 "H-07" & <급이기> 교체"""

printfn "%s" (RenderView.AsString.htmlNode (p [] [ str memo ]))
// <p>벌통 &quot;H-07&quot; &amp; &lt;급이기&gt; 교체</p>

printfn "%s" (RenderView.AsString.htmlNode (p [ _title memo ] [ str "메모" ]))
// <p title="벌통 &quot;H-07&quot; &amp; &lt;급이기&gt; 교체">메모</p>
```

- 자식 자리든 특성 값이든 `str` 과 특성 함수를 지나면 `<`·`>`·`&`·`"`·`'` 다섯 문자가 문자 참조(character reference)로 바뀐다. 이렇게 바꾸는 일을 이스케이프(escape)라 한다. 그래서 특성 값에 따옴표가 들어와도 특성이 조기에 닫히지 않고, 바로 아래 블록의 `&#39;` 가 홑따옴표가 바뀐 자리다.

```fsharp id=15-escape

printfn "%s" (RenderView.AsString.htmlNode (p [] [ rawText memo ]))
// <p>벌통 "H-07" & <급이기> 교체</p>

// 스크립트를 심으려는 입력도 str 을 지나면 글자가 된다
let attack = "<script>alert('!')</script>"
printfn "%s" (RenderView.AsString.htmlNode (li [] [ str attack ]))
// <li>&lt;script&gt;alert(&#39;!&#39;)&lt;/script&gt;</li>
printfn "%s" (RenderView.AsString.htmlNode (li [] [ rawText attack ]))
// <li><script>alert('!')</script></li>
```

- `rawText` 는 문자열을 그대로 끼워 넣는다. 이미 HTML 인 조각을 넣을 때 쓰는 함수이고, 바깥에서 들어온 값에는 쓰면 안 된다. 마지막 줄이 그 이유다.
- 이 노트의 부분 뷰가 벌통 코드와 소비 개수를 `str` 로 넣는 것은 이 성질에 기댄 것이다. 값이 어디서 왔는지 따지지 않아도 구조가 깨지지 않는다.

## 스크립트에서 앱을 세우는 준비 (노트 보충)

- 검증 방식은 13·14챕터와 같다. `dotnet fsi` 스크립트 안에서 Giraffe 앱을 띄우고, 같은 스크립트의 `HttpClient` 로 요청해 응답을 확인하고, 마지막에 서버를 내린다. 준비 코드도 14챕터의 것을 쓰되 정적 파일 미들웨어가 쓰는 어셈블리 하나를 참조 목록에 더한다.
- 선행 요구사항은 두 가지다. ASP.NET Core 공유 프레임워크가 포함된 .NET SDK(이 노트는 10.0.111 로 확인했다), 그리고 처음 한 번 `Giraffe` 8.3.0 과 `Giraffe.ViewEngine` 1.4.0 을 받아 올 네트워크다.
- 실제 개발은 프로젝트를 만들어 `dotnet run` 으로 확인하는 것이다. 아래 준비 코드는 노트의 예제를 자동으로 검증하기 위한 장치이고 `Program.fs` 에는 들어가지 않는다.

```fsharp id=15-server
// 이 단위가 보여주는 것: 레이아웃 · 부분 뷰 · 정적 파일을 갖춘 앱을 띄워 HTML 까지 확인하기
// 준비 코드 — 프로젝트 코드에는 들어가지 않는다(14챕터와 같다)
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
              "Microsoft.AspNetCore.StaticFiles"
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

- 새로 든 것은 `Microsoft.AspNetCore.StaticFiles` 하나다. `UseStaticFiles` 확장 메서드가 여기 들어 있고, 이 줄을 빼면 `error FS0039` 가 난다. 프로젝트에서는 프레임워크 참조에 들어 있어 적을 일이 없다.

```fsharp id=15-server
#r "aspnetcore/Microsoft.AspNetCore.dll"
#r "aspnetcore/Microsoft.AspNetCore.Hosting.dll"
#r "aspnetcore/Microsoft.AspNetCore.Hosting.Abstractions.dll"
#r "aspnetcore/Microsoft.AspNetCore.Http.dll"
#r "aspnetcore/Microsoft.AspNetCore.Http.Abstractions.dll"
#r "aspnetcore/Microsoft.AspNetCore.Routing.dll"
#r "aspnetcore/Microsoft.AspNetCore.StaticFiles.dll"
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

- 이 프로젝트는 파일마다 최상위 모듈 하나를 선언한다. 스크립트에서는 최상위 `module X.Y` 를 쓸 수 없으므로 그 구조를 중첩 모듈로 본뜨고 선언 순서를 `.fsproj` 의 컴파일 순서에 맞춘다. 도메인과 저장소는 14챕터의 것이므로 이 챕터가 쓰는 부분만 남겨 옮긴다.

```fsharp id=15-server

// Domain.fs · Store.fs — 14챕터에서 이어받는다(이 챕터가 쓰는 부분만 남겼다)
module Domain =
    type HiveCode = HiveCode of string
    type InspectionId = InspectionId of Guid

    type Inspection = {
        Id: InspectionId
        Hive: HiveCode
        Frames: int
        QueenSeen: bool
        RecordedAt: DateTime
    }

module Store =
    open Domain

    type InspectionStore() =
        let data = ConcurrentDictionary<Guid, Inspection>()

        member _.Save(inspection: Inspection) =
            let (InspectionId key) = inspection.Id
            data[key] <- inspection

        member _.All() =
            data.Values |> Seq.sortBy (fun item -> item.RecordedAt) |> Seq.toList
```

## Creating the View — 부분 뷰와 리스트 컴프리헨션 (원서 pp.187-191)

- 원서는 목록 항목 여섯 개를 뷰에 그대로 적었다가, 완료 여부에 따라 클래스가 달라지는 부분을 함수로 뽑는다. 원서가 부분 뷰(partial view)라 부르는 것이고 실체는 `Inspection -> XmlNode` 함수다. 13챕터에서 본 대로 모든 요소가 `XmlNode` 이기 때문에 조각을 함수로 뺄 수 있다.
- 원서는 같은 뷰를 두 번 싣는데 제목과 완료 표시가 서로 다르다(My To Do List / My ToDo List, `Read a book` 의 `checked` 여부, 여섯째 항목 이름). 화면이 책의 그림과 달라 보이는 것은 독자의 실수가 아니다.
- 이 노트의 부분 뷰는 여왕벌을 봤는지에 따라 특성 목록을 갈아 끼운다. 특성 목록도 그냥 리스트라서 `if` 로 고르면 된다.

```fsharp id=15-server

// Views.fs — 이 챕터가 더하는 파일. module HiveLog.Views 로 시작한다
module Views =
    open Domain

    let pageLayout (heading: string) (content: XmlNode list) =
        html [ _lang "ko" ] [
            head [] [
                meta [ _charset "utf-8" ]
                title [] [ str heading ]
                link [ _rel "stylesheet"; _href "/css/hive.css" ]
            ]
            body [] [
                header [ _class "bar" ] [ h1 [] [ str heading ] ]
                main [] content
                script [ _src "/js/hive.js" ] []
            ]
        ]

    // 부분 뷰 — 점검 기록 한 건이 목록의 한 줄이 된다
    // FSI 실측: inspection: Inspection -> XmlNode
    let private inspectionItemView (inspection: Inspection) =
        let (HiveCode code) = inspection.Hive
        let marks = if inspection.QueenSeen then [ _class "queen-seen" ] else []
        li marks [
            span [ _class "code" ] [ str code ]
            span [ _class "frames" ] [ str $"소비 {inspection.Frames}개" ]
            time [ _datetime (inspection.RecordedAt.ToString("yyyy-MM-ddTHH:mm:ssZ", CultureInfo.InvariantCulture)) ] [
                str (inspection.RecordedAt.ToString("MM-dd HH:mm", CultureInfo.InvariantCulture))
            ]
        ]
```

- 껍데기를 벗기는 자리가 `let (HiveCode code) = inspection.Hive` 한 줄이다. 도메인 타입을 그대로 받아 뷰 안에서 벗기므로 API 처럼 DTO 를 따로 둘 필요가 없다.
- `marks` 가 빈 리스트면 `li marks [ ... ]` 는 `li [] [ ... ]` 와 같다. 원서도 같은 방식으로 완료 표시를 켜고 끈다. 클래스 이름을 문자열로 이어 붙이는 것보다 리스트를 고르는 편이 실수하기 어렵다.
- `time` 요소는 사람이 읽을 표기와 기계가 읽을 표기를 따로 담는다. 특성 쪽에 `yyyy-MM-ddTHH:mm:ssZ` 로 정렬도 되고 시간대까지 드러나는 표기를 넣고, 자식 쪽에 짧은 표기를 넣었다. 14챕터의 `toPayload` 가 쓴 형식과 같으므로 같은 기록이 두 챕터에서 같은 문자열로 나간다. 두 표기 모두 불변 문화권으로 찍는다 — 사용자 지정 형식의 `:` 는 문화권의 시간 구분 기호라서 그러지 않으면 `fi-FI` 로캘에서 `09.00` 이 나온다(실측).
- `private` 을 붙였으므로 이 함수는 `Views` 모듈 밖에서 보이지 않는다. 화면 조각을 쓰는 것은 같은 모듈의 화면 뷰뿐이므로 밖으로 내보낼 이유가 없다.

목록을 만드는 부분이 원서가 말하는 리스트 컴프리헨션이다. 5챕터의 그 문법이 자식 목록 자리에 그대로 들어간다.

```fsharp id=15-server

    // FSI 실측: indexView: XmlNode
    let indexView =
        [
            p [ _class "lede" ] [ str "옥상 양봉장 점검 기록" ]
            nav [] [ a [ _href "/inspections" ] [ str "점검 기록 보기" ] ]
        ]
        |> pageLayout "HiveLog"

    // FSI 실측: inspections: Inspection list -> XmlNode
    let inspectionBoardView (inspections: Inspection list) =
        [
            p [ _class "count" ] [ str $"기록 {List.length inspections}건" ]
            ul [ _id "inspection-list" ] [
                for inspection in inspections do
                    inspectionItemView inspection
            ]
        ]
        |> pageLayout "점검 기록"
```

- `for inspection in inspections do` 아래에 값을 적기만 하면 그것이 목록의 원소가 된다. `yield` 를 적지 않아도 되는 암시적 yield 다. `inspections |> List.map inspectionItemView` 로 써도 결과는 같고, 13챕터의 표 뷰는 그렇게 적었다. 조건에 따라 어떤 항목을 건너뛰거나 항목 사이에 다른 요소를 끼워 넣어야 할 때는 컴프리헨션 쪽이 편하다.
- 이 함수의 타입 주석은 없어도 시그니처가 같다. 본문의 `List.length` 가 매개변수를 리스트로 못박기 때문에 주석을 지워도 FSI 가 `inspections: Inspection list -> XmlNode` 로 잡는다. 반대로 건수를 세는 줄을 빼거나 `Seq.length` 로 바꾸면 `for ... in` 이 요구하는 것은 열거 가능성뿐이라 `inspections: Inspection seq -> XmlNode` 가 된다. 제약은 컴프리헨션이 아니라 함께 쓴 함수가 정한다.
- 이 화면의 렌더링 결과는 아래 `15-view` 단위에서 문자열로 확인한다.

같은 코드를 서버 없이 확인해 둔다. 앞의 `15-view` 단위에 부분 뷰와 화면 뷰를 이어 붙인 것이다.

```fsharp id=15-view

// Domain.fs 의 타입 둘을 이 단위에서만 다시 적는다.
// Inspection 은 뷰가 쓰는 필드만 남겼다
type HiveCode = HiveCode of string

type Inspection = {
    Hive: HiveCode
    Frames: int
    QueenSeen: bool
    RecordedAt: DateTime
}

// FSI 실측: inspection: Inspection -> XmlNode
let inspectionItemView (inspection: Inspection) =
    let (HiveCode code) = inspection.Hive
    let marks = if inspection.QueenSeen then [ _class "queen-seen" ] else []
    li marks [
        span [ _class "code" ] [ str code ]
        span [ _class "frames" ] [ str $"소비 {inspection.Frames}개" ]
        time [ _datetime (inspection.RecordedAt.ToString("yyyy-MM-ddTHH:mm:ssZ", CultureInfo.InvariantCulture)) ] [
            str (inspection.RecordedAt.ToString("MM-dd HH:mm", CultureInfo.InvariantCulture))
        ]
    ]

let samples =
    [ { Hive = HiveCode "H-07"; Frames = 8; QueenSeen = true; RecordedAt = DateTime(2026, 5, 3, 9, 0, 0, DateTimeKind.Utc) }
      { Hive = HiveCode "H-11"; Frames = 10; QueenSeen = false; RecordedAt = DateTime(2026, 5, 3, 11, 0, 0, DateTimeKind.Utc) }
      { Hive = HiveCode "H-07"; Frames = 9; QueenSeen = true; RecordedAt = DateTime(2026, 5, 17, 9, 0, 0, DateTimeKind.Utc) } ]

printfn "%s" (RenderView.AsString.htmlNode (inspectionItemView samples[0]))
// <li class="queen-seen"><span class="code">H-07</span><span class="frames">소비 8개</span><time datetime="2026-05-03T09:00:00Z">05-03 09:00</time></li>
printfn "%s" (RenderView.AsString.htmlNode (inspectionItemView samples[1]))
// <li><span class="code">H-11</span><span class="frames">소비 10개</span><time datetime="2026-05-03T11:00:00Z">05-03 11:00</time></li>
```

- 첫 줄과 둘째 줄의 차이가 `marks` 하나다. 여왕벌을 본 기록에만 클래스가 붙었고, 못 본 기록의 `<li>` 에는 특성이 아예 없다.

```fsharp id=15-view

// FSI 실측: inspections: Inspection list -> XmlNode
let inspectionBoardView (inspections: Inspection list) =
    [
        p [ _class "count" ] [ str $"기록 {List.length inspections}건" ]
        ul [ _id "inspection-list" ] [
            for inspection in inspections do
                inspectionItemView inspection
        ]
    ]
    |> pageLayout "점검 기록"

let board = RenderView.AsString.htmlNode (inspectionBoardView samples)
// 읽기 좋게 항목마다 줄을 나눠 찍는다
printfn "%s" (board.Replace("</li>", "</li>\n"))
// <html lang="ko"><head><meta charset="utf-8"><title>점검 기록</title><link rel="stylesheet" href="/css/hive.css"></head><body><header class="bar"><h1>점검 기록</h1></header><main><p class="count">기록 3건</p><ul id="inspection-list"><li class="queen-seen"><span class="code">H-07</span><span class="frames">소비 8개</span><time datetime="2026-05-03T09:00:00Z">05-03 09:00</time></li>
// <li><span class="code">H-11</span><span class="frames">소비 10개</span><time datetime="2026-05-03T11:00:00Z">05-03 11:00</time></li>
// <li class="queen-seen"><span class="code">H-07</span><span class="frames">소비 9개</span><time datetime="2026-05-17T09:00:00Z">05-17 09:00</time></li>
// </ul></main><script src="/js/hive.js"></script></body></html>
```

- 이 블록이 앞 절의 `pageLayout` 을 그대로 쓸 수 있는 것은 같은 `id` 를 쓰는 블록들이 문서 순서대로 이어 붙어 하나의 스크립트가 되기 때문이다. `Views.fs` 안에서 레이아웃과 화면 뷰가 이웃해 있는 것과 같은 모양이다.
- `RenderView.AsString.htmlNode` 로 찍었으므로 `<!DOCTYPE html>` 이 없다. 문서로 내보낼 때는 `htmlDocument` 쪽을 쓰거나, 서버에서는 `htmlView` 가 알아서 붙인다.

## 뷰 핸들러와 화면용 경로 (원서 p.189)

- 원서는 목록을 하드코딩한 뷰를 먼저 만들고 나중에 데이터를 넘기도록 고친다. 이 노트는 처음부터 저장소를 읽는다. 14챕터가 `InspectionStore` 를 싱글턴으로 등록해 두었으므로 핸들러가 `ctx.GetService` 로 꺼내면 된다.
- 뷰를 응답으로 내보내는 핸들러는 `htmlView` 다. 데이터를 받지 않는 화면은 `htmlView Views.indexView` 를 경로에 그대로 붙이고, 데이터를 읽어야 하는 화면은 핸들러를 하나 만들어 그 안에서 `htmlView` 를 부른다.
- 프로젝트에서는 `Program.fs` 에 `open HiveLog` 를 적어 `Views.` 접두를 남긴다. 14챕터가 엔드포인트 목록에 쓴 방식과 같다.

```fsharp id=15-server

// Program.fs
open Domain
open Store

let notFoundHandler : HttpHandler =
    "요청한 경로가 없다" |> text |> RequestErrors.notFound

// FSI 실측: next: HttpFunc -> ctx: HttpContext -> HttpFuncResult
let inspectionBoardHandler : HttpHandler =
    fun next ctx ->
        let store = ctx.GetService<InspectionStore>()
        htmlView (Views.inspectionBoardView (store.All())) next ctx
```

- `htmlView` 는 `XmlNode -> HttpHandler` 다. 화면 뷰가 만든 값을 넘겨 핸들러를 얻고, 그 핸들러에 `next` 와 `ctx` 를 넘겨 부른다. 14챕터의 핸들러들이 `match` 로 핸들러를 고른 뒤 마지막에 부른 것과 같은 형태이고, 여기는 고를 것이 없어 한 줄이다.
- 이 핸들러에는 `task { ... }` 가 없다. `htmlView` 가 돌려주는 핸들러를 부른 결과가 이미 `HttpFuncResult` 이므로 감쌀 것이 없다.
- 저장소가 비어 있어도 이 핸들러는 실패하지 않는다. `store.All()` 이 빈 리스트를 돌려주고 컴프리헨션이 빈 `<ul>` 을 만든다. API 의 404 판단과 달리 목록 화면에는 없음을 알릴 상태 코드가 필요하지 않다.

경로를 더할 자리는 바깥 `endpoints` 다. 13챕터가 HTTP 메서드 묶음을 안쪽 목록에 몰아 둔 덕에 `/api` 아래는 손대지 않는다.

```fsharp id=15-server

// 14챕터의 점검 기록 핸들러 다섯 개 가운데 목록 하나만 남기고, 요약·벌통 핸들러와
// subRoute "/inspections" 한 층도 접었다. 화면 쪽에 집중하기 위한 축약이고 프로젝트에서는
// Inspections.fs 의 다섯 개와 Program.fs 의 요약·벌통 핸들러, 세 층 라우팅이 그대로 있다
let inspectionListHandler : HttpHandler =
    fun _ ctx ->
        let store = ctx.GetService<InspectionStore>()
        store.All()
        |> List.map (fun item ->
            let (HiveCode code) = item.Hive
            {| Hive = code; Frames = item.Frames |})
        |> ctx.WriteJsonAsync

let apiEndpoints =
    [
        GET [
            route "/inspections" inspectionListHandler
        ]
    ]

// FSI 실측: endpoints: Endpoint list
let endpoints =
    [
        GET [
            route "/" (htmlView Views.indexView)
            route "/inspections" inspectionBoardHandler
        ]
        subRoute "/api" apiEndpoints
    ]
```

- `/inspections` 와 `/api/inspections` 가 같은 저장소를 읽어 다른 형식으로 답한다. 앞은 사람이 볼 HTML, 뒤는 기계가 읽을 JSON 이다. 14챕터에서 본 콘텐츠 협상으로 한 경로에 둘을 겹칠 수도 있지만, `negotiate` 의 기본 규칙에는 `text/html` 이 없어 HTML 을 골라 줄 방법이 없다. `Accept: text/html` 만 보내면 406 이고, 브라우저가 보내는 긴 `Accept` 헤더는 품질값 0.9 의 `application/xml` 규칙에 걸려 14챕터에서 본 XML 직렬화 실패로 500 이 된다. 화면과 API 를 경로로 갈라 두는 편이 단순하다.
- 정적 파일 경로는 이 목록에 적지 않는다. 라우팅이 아니라 미들웨어가 처리하기 때문이다. `wwwroot/` 아래 파일을 하나 더 두면 경로가 자동으로 늘어난다.
- 원서 p.191 의 마지막 라우팅 코드에는 괄호가 하나 빠져 있다(`route "/" (htmlView (Todos.Views.todoView Todos.Data.todoList)`). 그대로 옮겨 적으면 컴파일되지 않으니 짝을 맞춰야 한다.

## Loading Data on Startup — 표본 데이터 (원서 pp.189-190)

- 원서는 `Todos.fs` 안에 `Data` 모듈을 만들어 항목 여섯 개를 최상위 리스트로 적는다. 그러고는 레코드 필드가 반복되는 것을 보고 `create` 도우미 함수를 만들어 튜플 목록을 `List.map` 으로 옮기는 형태로 고친다.
- 이 노트는 그 리스트를 저장소에 넣는다. 화면과 API 가 같은 저장소를 읽어야 하고, 저장소는 14챕터에서 이미 등록되어 있으므로 데이터가 들어갈 자리도 거기다. 최상위 리스트를 따로 두면 화면은 그것을 보고 API 는 저장소를 봐서 둘이 어긋난다.

```fsharp id=15-server

// FSI 실측: unit -> InspectionStore
let storeWithSamples () =
    let store = InspectionStore()
    let entry hive frames queenSeen day hour =
        { Id = InspectionId(Guid.NewGuid())
          Hive = HiveCode hive
          Frames = frames
          QueenSeen = queenSeen
          RecordedAt = DateTime(2026, 5, day, hour, 0, 0, DateTimeKind.Utc) }
    [ entry "H-07" 8 true 3 9
      entry "H-11" 10 false 3 11
      entry "H-07" 9 true 17 9 ]
    |> List.iter store.Save
    store
```

- `entry` 가 원서의 `create` 에 해당한다. 반복되는 필드 이름을 한 번만 적고 달라지는 값만 매개변수로 받는다. 원서는 튜플 목록을 `List.map` 으로 옮기지만, 매개변수가 다섯이면 커링된 함수를 그대로 부르는 편이 짧다.
- 기록 시각을 `DateTime.UtcNow` 가 아니라 못박은 값으로 넣었다. 원서는 표본 여섯 건 모두에 `DateTime.UtcNow` 를 쓰는데, 그러면 실행할 때마다 화면이 달라져 예제 출력과 대조할 수 없다. 정렬 순서를 확인하려면 서로 다른 시각이 필요하기도 하다.
- 시그니처가 `unit -> InspectionStore` 인 것에 뜻이 있다. `let storeWithSamples = ...` 로 적어 값으로 두면 스크립트를 읽는 시점에 인스턴스가 하나 만들어진다. 함수로 두면 부르는 쪽이 시점을 정한다.

## Configuration — UseStaticFiles 한 줄 (원서 p.185)

- 서비스 등록은 14챕터와 같다. 달라지는 것은 저장소 인스턴스를 만드는 방법 하나뿐이다.
- 미들웨어 쪽에 `UseStaticFiles()` 가 들어간다. 이것이 이 챕터가 설정에 더하는 전부다.

```fsharp id=15-server

// FSI 실측: services: IServiceCollection -> unit
let configureServices (services: IServiceCollection) =
    let options = JsonSerializerOptions(JsonSerializerDefaults.Web)
    options.Encoder <- JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    services
        .AddRouting()
        .AddGiraffe()
        .AddSingleton<Json.ISerializer>(Json.Serializer options)
        .AddSingleton<InspectionStore>(storeWithSamples ())
    |> ignore

// FSI 실측: appBuilder: IApplicationBuilder -> unit
let configureApp (appBuilder: IApplicationBuilder) =
    appBuilder
        .UseStaticFiles()
        .UseRouting()
        .UseGiraffe(endpoints)
        .UseGiraffe(notFoundHandler)
```

- 원서는 `UseStaticFiles()` 를 `UseRouting()` 뒤에 적는다. 이 노트는 앞에 두었다. 두 순서 모두 이 앱에서는 같은 결과를 내는데, 정적 파일 경로와 겹치는 엔드포인트가 없기 때문이다. 겹치면 결과가 갈린다 — 확인 절 마지막에서 실제로 갈리는 것을 본다.
- 정적 파일 미들웨어를 앞에 두는 것이 관례이고 이유는 두 가지다. 파일 요청이 라우팅 표를 뒤지지 않고 바로 끝나고, 실수로 같은 경로에 엔드포인트를 만들었을 때 파일 쪽이 이긴다.
- `configureApp` 의 순서가 곧 동작이라는 13챕터의 이야기를 이 절이 실제 응답으로 확인한다. `configureServices` 의 등록 순서는 상관없다.

## 정적 파일을 만들고 앱을 띄워 확인한다 (노트 보충)

- 프로젝트에서는 `wwwroot/css/hive.css` 와 `wwwroot/js/hive.js` 를 편집기로 만들면 된다. 스크립트로 검증하려면 그 두 파일을 스크립트가 직접 만들어야 하므로, 아래 코드가 임시 경로 안에 웹 루트를 만들어 쓴다.
- 내용은 이 노트가 새로 짠 것이고 원서 부록 2 와는 관계가 없다. CSS 는 머리글 색과 목록 모양, 여왕벌을 본 기록에 표시를 붙이는 규칙 셋이고, JavaScript 는 항목을 클릭하면 클래스가 켜지고 꺼지게 하는 몇 줄이다.

```fsharp id=15-server

// ---- 여기부터는 검증용 코드다
let webRoot = Path.Combine(__SOURCE_DIRECTORY__, "wwwroot")
Directory.CreateDirectory(Path.Combine(webRoot, "css")) |> ignore
Directory.CreateDirectory(Path.Combine(webRoot, "js")) |> ignore

File.WriteAllText(
    Path.Combine(webRoot, "css", "hive.css"),
    """.bar { background: #f5c451; padding: 12px }
#inspection-list { list-style: none; padding: 0 }
.queen-seen .code::after { content: " (여왕 확인)" }
""")

File.WriteAllText(
    Path.Combine(webRoot, "js", "hive.js"),
    """document.querySelectorAll("#inspection-list li").forEach(function (item) {
  item.addEventListener("click", function () { item.classList.toggle("open"); });
});
""")
```

- CSS 의 `.queen-seen .code::after` 는 부분 뷰가 붙인 클래스를 받는다. 클래스 이름 하나를 F# 코드와 CSS 파일이 나눠 쓰는 자리이고, View Engine 의 타입 안전성이 닿지 않는 경계이기도 하다. 오타가 나면 컴파일은 통과하고 화면만 어긋난다.
- 호스트를 세우는 부분은 13·14챕터와 같고 웹 루트를 못박는 한 줄만 다르다. 스크립트는 콘텐츠 루트가 프로젝트 폴더가 아니어서 기본 규칙으로 `wwwroot/` 를 찾지 못한다.

```fsharp id=15-server

let builder =
    WebApplication.CreateBuilder(
        WebApplicationOptions(ContentRootPath = __SOURCE_DIRECTORY__, WebRootPath = "wwwroot"))
configureServices builder.Services
builder.Logging.ClearProviders() |> ignore

let app = builder.Build()
configureApp app
app.Urls.Add "http://127.0.0.1:0"            // 0 = 빈 포트를 골라 달라는 뜻
app.StartAsync() |> Async.AwaitTask |> Async.RunSynchronously

let baseUrl = app.Urls |> Seq.head
let client = new Net.Http.HttpClient()

// 경로 · 상태 코드 · Content-Type 을 찍고 본문을 돌려준다
let get (path: string) =
    let response = client.GetAsync(baseUrl + path) |> Async.AwaitTask |> Async.RunSynchronously
    let body = response.Content.ReadAsStringAsync() |> Async.AwaitTask |> Async.RunSynchronously
    printfn "%-26s %d  %s" path (int response.StatusCode) (string response.Content.Headers.ContentType)
    body

let indexBody = get "/"
// /                          200  text/html; charset=utf-8
let boardBody = get "/inspections"
// /inspections               200  text/html; charset=utf-8
```

- `htmlView` 가 `Content-Type` 을 `text/html; charset=utf-8` 로 정한다. 14챕터의 JSON 응답과 갈리는 지점이고, 브라우저 주소창에 이 경로를 넣으면 화면이 그려진다.

응답 본문이 정말 기대한 HTML 인지 조각을 찾아 확인한다.

```fsharp id=15-server

// FSI 실측: label: string -> fragment: string -> body: string -> unit
let check (label: string) (fragment: string) (body: string) =
    printfn "  %-5b %s" (body.Contains fragment) label

check "문서 선언" "<!DOCTYPE html>\n<html lang=\"ko\">" indexBody
check "레이아웃의 stylesheet" "<link rel=\"stylesheet\" href=\"/css/hive.css\">" indexBody
check "레이아웃의 script" "<script src=\"/js/hive.js\"></script>" indexBody
check "목록 링크" "<a href=\"/inspections\">" indexBody
check "건수" "<p class=\"count\">기록 3건</p>" boardBody
check "여왕벌을 본 기록" "<li class=\"queen-seen\">" boardBody
check "여왕벌을 못 본 기록" "<li><span class=\"code\">H-11</span>" boardBody
check "부분 뷰가 낸 시각" "<time datetime=\"2026-05-17T09:00:00Z\">" boardBody
check "항목 순서" "</time></li><li><span class=\"code\">H-11</span>" boardBody
//   true  문서 선언
//   true  레이아웃의 stylesheet
//   true  레이아웃의 script
//   true  목록 링크
//   true  건수
//   true  여왕벌을 본 기록
//   true  여왕벌을 못 본 기록
//   true  부분 뷰가 낸 시각
//   true  항목 순서
```

- `문서 선언` 은 `htmlView` 가 응답 앞에 `<!DOCTYPE html>` 을 붙였다는 것을, 이어지는 셋은 공용 레이아웃이 두 화면에 같은 껍데기를 씌웠다는 것을, `건수` 부터 `항목 순서` 까지 다섯은 부분 뷰와 컴프리헨션이 저장소의 세 건을 순서대로 옮겼다는 것을 말한다. 여왕벌을 본 기록에만 클래스가 붙고 못 본 기록의 `<li>` 에는 특성이 없다는 차이도 확인된다.
- 표본 데이터의 기록 시각을 못박아 둔 덕에 `부분 뷰가 낸 시각` 검사처럼 시각까지 대조할 수 있다. `DateTime.UtcNow` 로 채웠다면 이 검사는 쓸 수 없다.
- `body.Contains` 는 조각이 있는지만 본다. 항목 순서와 중첩은 `항목 순서` 검사처럼 이웃한 두 조각을 이어 붙여야 잡히고, 부분 뷰를 두 번 붙여 항목이 여섯이 되는 중복은 이 검사들이 잡지 못한다. 문서 전체의 모양은 `15-view` 단위가 문자열로 찍어 대조하는 쪽이 맡는다. 두 단위가 역할을 나눠 맡는다.

정적 파일 차례다.

```fsharp id=15-server

printfn "%s" (get "/css/hive.css")
// /css/hive.css              200  text/css
// .bar { background: #f5c451; padding: 12px }
// #inspection-list { list-style: none; padding: 0 }
// .queen-seen .code::after { content: " (여왕 확인)" }
//
get "/js/hive.js" |> ignore
// /js/hive.js                200  text/javascript
get "/css/nope.css" |> ignore
// /css/nope.css              404  text/plain; charset=utf-8
get "/inspections/css/hive.css" |> ignore
// /inspections/css/hive.css  404  text/plain; charset=utf-8
printfn "%s" (get "/api/inspections")
// /api/inspections           200  application/json; charset=utf-8
// [{"frames":8,"hive":"H-07"},{"frames":10,"hive":"H-11"},{"frames":9,"hive":"H-07"}]
```

- 확장자를 보고 `Content-Type` 이 정해진다. `.css` 는 `text/css`, `.js` 는 `text/javascript` 이고 둘 다 문자 집합이 붙지 않는다. 이 대응 표를 들고 있는 것이 정적 파일 미들웨어이며, 표에 없는 확장자는 기본적으로 내보내지 않는다.
- 없는 파일 요청은 미들웨어가 그냥 흘려보내고, 라우팅에도 걸리지 않아 마지막 `notFoundHandler` 로 떨어진다. 그래서 응답이 평문 404 다. 정적 파일 전용 404 화면이 따로 나오지는 않는다.
- 넷째 줄이 앞에서 이야기한 상대 경로 문제다. 원서처럼 `_href "css/hive.css"` 로 적었다면 `/inspections` 화면의 브라우저가 이 경로를 찾고, 보다시피 404 다. 앞 슬래시를 붙이면 어느 화면에서 열어도 같은 파일을 가리킨다.
- 마지막 줄이 14챕터의 목록 경로다. 화면을 더하는 동안 API 는 손대지 않았다. 다만 이 단위는 핸들러를 축약했으므로 필드가 둘뿐이고, 프로젝트에서는 14챕터의 `toPayload` 가 만든 다섯 필드가 그대로 나간다. 같은 저장소의 세 건이 두 형식으로 나갔다.

미들웨어 파이프라인의 순서가 결과를 갈라 놓는 경우를 마지막에 확인한다. 앞의 앱을 내리고, 정적 파일 경로와 같은 엔드포인트를 하나 만들어 순서만 바꿔 두 번 띄운다.

```fsharp id=15-server

app.StopAsync() |> Async.AwaitTask |> Async.RunSynchronously
client.Dispose()

// 정적 파일과 라우팅이 같은 경로를 노릴 때 순서가 결과를 정한다
let raceEndpoints = [ GET [ route "/css/hive.css" (text "라우팅이 응답했다") ] ]

let probeOrder (label: string) (configure: IApplicationBuilder -> unit) =
    let raceBuilder =
        WebApplication.CreateBuilder(
            WebApplicationOptions(ContentRootPath = __SOURCE_DIRECTORY__, WebRootPath = "wwwroot"))
    configureServices raceBuilder.Services
    raceBuilder.Logging.ClearProviders() |> ignore
    let raceApp = raceBuilder.Build()
    configure raceApp
    raceApp.Urls.Add "http://127.0.0.1:0"
    raceApp.StartAsync() |> Async.AwaitTask |> Async.RunSynchronously
    use probe = new Net.Http.HttpClient()
    let body =
        probe.GetStringAsync((raceApp.Urls |> Seq.head) + "/css/hive.css")
        |> Async.AwaitTask
        |> Async.RunSynchronously
    printfn "%s = %s" label (body.Split '\n' |> Array.head)
    raceApp.StopAsync() |> Async.AwaitTask |> Async.RunSynchronously

probeOrder "정적 파일 먼저" (fun appBuilder ->
    appBuilder.UseStaticFiles().UseRouting().UseGiraffe(raceEndpoints).UseGiraffe(notFoundHandler))
// 정적 파일 먼저 = .bar { background: #f5c451; padding: 12px }

probeOrder "라우팅 먼저" (fun appBuilder ->
    appBuilder.UseRouting().UseStaticFiles().UseGiraffe(raceEndpoints).UseGiraffe(notFoundHandler))
// 라우팅 먼저 = 라우팅이 응답했다

printfn "서버를 내렸다"   // 서버를 내렸다
```

- 순서가 결과를 갈라 놓는 이유는 `UseRouting` 이 응답을 쓰지 않고 엔드포인트만 골라 둔다는 데 있다. 정적 파일 미들웨어는 이미 골라진 엔드포인트가 있으면 파일을 내보내지 않고 요청을 그냥 넘긴다. 그래서 라우팅을 먼저 켜면 경로가 겹치는 순간 엔드포인트가 이기고, 정적 파일을 먼저 두면 라우팅에 닿기 전에 파일로 응답이 끝난다. 겹치지 않는 경로라면 어느 순서든 파일이 나간다.
- `configureApp` 이 값을 조립하는 코드가 아니라 순서를 적는 코드라는 것이 여기서 드러난다. 라우팅과 달리 우선순위 규칙이 따로 없고 적은 순서가 그대로 규칙이다.
- 두 앱 모두 `StopAsync` 로 내렸고 `HttpClient` 도 해제했다. 남은 프로세스나 포트가 없어야 이 노트를 반복해서 검증할 수 있다.

## Summary — 원서의 챕터 요약 (원서 p.191)

- 원서는 Giraffe 와 View Engine 으로 할 수 있는 일의 겉만 훑었다고 적고 View Engine 문서를 읽어 보라고 권한다.
- JavaScript 를 직접 쓰는 것이 싫으면 SAFE Stack 을 보라고도 권한다. 서버와 브라우저 양쪽을 F# 로 쓰는 조합이고 React 기반 단일 페이지 앱에도 쓴다는 소개다.
- 원서 본문은 여기서 끝난다. 다음 챕터는 맺음말과 이어서 읽을 자료 목록이다.

## 정리 — 이 노트의 요약

- 공용 레이아웃은 문법이 아니라 함수다. `heading: string -> content: XmlNode list -> XmlNode` 로 껍데기를 뽑아 두면 화면 뷰가 본문 목록을 만들어 파이프로 넘긴다. 상속이나 특별한 규칙이 필요하지 않다.
- 부분 뷰도 함수다. 모든 요소가 `XmlNode` 라서 `Inspection -> XmlNode` 함수를 자식 목록에 끼워 넣을 수 있다. 특성 목록도 리스트이므로 `if` 로 골라 클래스를 켜고 끈다.
- 목록은 자식 자리의 리스트 컴프리헨션으로 만든다. `for x in items do` 아래 값을 적으면 그대로 원소가 되고, `List.map` 으로 써도 결과는 같다. 타입 주석이 없으면 `for ... in` 이 요구하는 것은 열거 가능성뿐이라 매개변수가 `seq` 로 잡히고, 같은 본문에서 `List.length` 를 부르면 그 호출이 매개변수를 리스트로 못박는다.
- `str` 과 특성 함수는 `<`·`>`·`&`·`"`·`'` 다섯 문자를 문자 참조로 바꾼다. 바깥에서 들어온 값을 그대로 넣어도 HTML 구조가 깨지지 않는다. `rawText` 는 이스케이프하지 않으므로 이미 HTML 인 조각에만 쓴다.
- API 의 직렬화 제약은 화면에 해당하지 않는다. View Engine 은 F# 값을 직접 읽으므로 판별 유니온이 든 도메인 타입을 뷰 함수에 그대로 넘기고, 껍데기는 뷰 안에서 패턴으로 벗긴다. DTO 를 따로 둘 이유가 없다.
- 데이터를 읽는 화면은 핸들러를 하나 만들어 `ctx.GetService<InspectionStore>()` 로 저장소를 꺼내고 `htmlView` 에 뷰의 결과를 넘긴다. 데이터를 받지 않는 화면은 `htmlView Views.indexView` 를 경로에 바로 붙인다.
- 정적 파일은 콘텐츠 루트 아래 `wwwroot/` 에 두고 `configureApp` 에 `UseStaticFiles()` 를 더하면 나간다. 확장자에 따라 `Content-Type` 이 정해지고(`.css`→`text/css`, `.js`→`text/javascript`), 없는 파일은 미들웨어를 지나쳐 마지막 핸들러의 404 로 떨어진다.
- 미들웨어 파이프라인의 순서는 취향이 아니다. 정적 파일 경로와 엔드포인트 경로가 겹치면 `configureApp` 에 정적 파일을 먼저 적었을 때만 파일이 나간다. 정적 파일 미들웨어는 이미 골라진 엔드포인트가 있으면 요청을 그냥 넘기기 때문이다. 정적 파일을 앞에 두는 것이 관례다.
- 스타일시트와 스크립트 경로에는 앞 슬래시를 붙인다. 상대 경로는 브라우저가 현재 주소를 기준으로 풀어서 중첩된 경로의 화면에서 404 가 된다.
- 뷰를 새 파일로 빼면 컴파일 순서에서 `Program.fs` 앞에 와야 한다. 뷰는 `Domain.fs` 만 참조하고 핸들러가 뷰를 참조하므로 자리가 하나로 정해진다.

### 세 챕터를 지난 앱의 최종 모습

`HiveLog` 는 `dotnet new web -lang "F#"` 로 만든 단일 프로젝트이고 파일이 다섯이다. `Domain.fs` 가 `HiveCode`·`Hive`·`hives`·`findHive`·`InspectionId`·`Inspection` 을, `Store.fs` 가 `ConcurrentDictionary` 를 감싼 `InspectionStore` 를 담는다. `Inspections.fs` 에는 요청 타입·검증·API 핸들러 다섯 개와 `inspectionEndpoints` 가, `Views.fs` 에는 `pageLayout`·부분 뷰·`indexView`·`inspectionBoardView` 가, `Program.fs` 에는 화면 핸들러·요약 핸들러·벌통 핸들러·마지막 핸들러·라우팅·설정·진입점이 있다. 밖으로 드러난 경로는 세 갈래다. 화면 쪽에 `/` 와 `/inspections`, API 쪽에 `/api` 아래의 요약 하나와 벌통 조회 둘, 점검 기록 다섯(GET 두 개, POST, PUT, DELETE), 그리고 라우팅을 거치지 않는 `wwwroot/` 의 정적 파일이다. 미들웨어 파이프라인은 정적 파일 → 라우팅 → Giraffe 엔드포인트 → 어디에도 걸리지 않은 요청을 받는 핸들러 순이고, 서비스 등록은 라우팅·Giraffe·JSON 직렬화기·점검 기록 저장소 넷이다. 저장소 하나를 화면과 API 가 나눠 쓰므로 POST 로 만든 기록이 곧 화면에 나타난다. 데이터는 메모리에만 있어 프로세스가 끝나면 사라지고, 여기서 더 나아가려면 저장소 클래스 뒤에 실제 데이터베이스를 붙이는 것이 다음 걸음이다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Getting Started — 이 챕터가 더하는 것 | p.185 | — |
| Configuration — wwwroot 와 부록 2 | p.185 | — |
| Adding a Master Page — 공용 레이아웃 | pp.186-187 | `15-view` |
| str 이 문자를 이스케이프한다 | (노트 보충) | `15-escape` |
| 스크립트에서 앱을 세우는 준비 | (노트 보충) | `15-server` |
| Creating the View — 부분 뷰와 리스트 컴프리헨션 | pp.187-191 | `15-server`, `15-view` |
| 뷰 핸들러와 화면용 경로 | p.189 | `15-server` |
| Loading Data on Startup — 표본 데이터 | pp.189-190 | `15-server` |
| Configuration — UseStaticFiles 한 줄 | p.185 | `15-server` |
| 정적 파일을 만들고 앱을 띄워 확인한다 | (노트 보충) | `15-server` |
| Summary — 원서의 챕터 요약 | p.191 | — |
