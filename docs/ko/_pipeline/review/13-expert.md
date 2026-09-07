# 13챕터 검수 보고서 (F# 전문가, 후보 모드)

대상: `docs/ko/13-web-with-giraffe.md` (674줄, 실행 단위 4개)
참고: `.cache/src/13-web-with-giraffe.txt`(원서 pp.166-177), `docs/ko/14-api-with-giraffe.md`,
`docs/ko/15-web-pages-with-giraffe.md`
환경: .NET SDK 10.0.111, `Microsoft.AspNetCore.App` 10.0.11, Giraffe 8.3.0, Giraffe.ViewEngine 1.4.0

검증 실행 결과: `13-mutability`·`13-payload`·`13-server`·`13-view` 전부 PASS, 경고 0건.
`13-server` 를 직접 돌려 응답 6건이 주석의 기대 출력과 한 글자도 다르지 않은 것을 확인했다.

용어 후보는 `docs/ko/_pipeline/review/13-glossary.md` 에 따로 있다.

---

## 수정 필요 (기술 오류)

### 1. [13:161] 어셈블리 해석기가 필요한 이유가 틀렸다

현재 서술: "(2)의 해석기가 없으면 실행 중에 어셈블리 버전이 어긋나 `FileNotFoundException` 이
난다. 패키지가 담고 있는 어셈블리가 `net9.0` 용이라 참조 버전이 9.0.0 으로 적혀 있는 반면,
실제 로드 대상은 10.0.x 이기 때문이다."

왜 틀렸는가. 해석기에 로그를 심어 실행하며 요청되는 어셈블리 이름과 버전을 전부 찍어 보면
요청 버전이 하나도 빠짐없이 `10.0.0.0` 이다. 9.0.0 을 요구하는 요청은 한 건도 없다.
해석기를 지우고 돌리면 실제로 나는 오류는 이것이다.

```
System.IO.FileNotFoundException: Could not load file or assembly
'Microsoft.Extensions.Features, Version=10.0.0.0, ...'
```

`Microsoft.Extensions.Features` 는 `#r` 로 적은 10개에 없다. 즉 버전이 어긋난 것이 아니라
탐색 경로에 아예 없는 것이다. FSI 의 기본 로드 컨텍스트는 런타임 디렉터리(`Microsoft.NETCore.App`)와
명시적으로 준 어셈블리 쪽만 뒤지고, ASP.NET Core 공유 프레임워크 폴더는 아무도 뒤지지 않는다.
`#r` 로 적은 10개의 전이 의존성 약 50개(Kestrel, Configuration, Options, Primitives, ...)가
그 폴더에만 있어 실행 중에 찾지 못한다.

확증. 빠진 `Microsoft.Extensions.Features` 하나를 `#r` 목록에 더하면 해석기 없이도
서버가 정상으로 뜬다(실측). 해석기가 하는 일은 버전 보정이 아니라 폴더 하나를 탐색 경로에
얹어 주는 것이다.

교체 문장:

```
- (2)의 해석기가 없으면 실행 중에 `FileNotFoundException` 이 난다. FSI 의 기본 로드 컨텍스트는
  런타임 폴더와 명시적으로 준 어셈블리 쪽만 뒤지고 ASP.NET Core 공유 프레임워크 폴더는 뒤지지
  않는다. `#r` 로 적은 10개가 실행 중에 다시 끌어오는 어셈블리는 50개가 넘는데(Kestrel,
  Configuration, Options, Primitives 같은 것들) 그것이 모두 그 폴더에만 있다. 이름만 보고 그
  폴더에서 찾아 주면 해결된다. 그래서 `#r` 에는 코드가 타입 이름을 직접 적는 어셈블리만
  적으면 되고 나머지는 실행 중에 해석기가 채운다. 해석기가 `null` 을 돌려주는 것은 "나는
  모른다"는 뜻이며 다음 처리기로 넘어간다 — `Giraffe` 처럼 NuGet 캐시에서 오는 어셈블리가
  그 경로로 해결된다.
```

### 2. [13:129, 13:160] 공유 프레임워크 버전 선택이 "가장 높은 것"이 아니다

현재 코드는 `Array.sortBy Path.GetFileName |> Array.last` 이고, 160줄 산문은 "폴더 목록에서
가장 높은 것을 고른다"고 적었다. 문자열 정렬이므로 버전 정렬이 아니다.

실측:

```
[|"/x/10.0.11"; "/x/10.0.9"; "/x/9.0.14"|]   // Array.sortBy Path.GetFileName 결과
last = /x/9.0.14                              // 고르는 것
by Version = /x/10.0.11                       // 골라야 하는 것
```

10.0.9 와 10.0.11 이 함께 깔린 흔한 상태에서 10.0.9 를 고르고, 9.0 과 10.0 이 함께 깔리면
9.0 을 고른다. 후자는 실행 중인 런타임과 메이저가 달라 무슨 일이 일어나는지 보장되지 않는다.
이 파일 하나의 문제가 아니라 14·15챕터의 준비 코드에도 같은 두 줄이 그대로 들어 있다.

122-130줄을 다음으로 교체한다(아래 코드로 `13-server` 전체를 다시 돌려 경고 0건, 출력 동일 확인).

```fsharp
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
        failwithf "%s 가 없다. ASP.NET Core 공유 프레임워크가 포함된 .NET SDK 가 필요하다." root
    let candidates = Directory.GetDirectories root |> Array.sortBy version
    match candidates |> Array.filter (fun d -> (version d).Major = (version core.FullName).Major) with
    | [||] -> Array.last candidates
    | sameLine -> Array.last sameLine
```

`Split('-')[0]` 은 `10.0.0-preview.1.25080.5` 같은 미리 보기 폴더 이름을 `Version.TryParse` 가
읽지 못하는 것을 피하려는 것이다.

160줄 산문도 함께 고친다.

```
- (1)의 계산은 `Microsoft.NETCore.App/10.0.11` 옆에 `Microsoft.AspNetCore.App/10.0.11` 이 있다는
  배치를 이용한다. 두 프레임워크의 버전이 항상 같다고 보장되지 않으므로, 실행 중인 런타임과
  메이저 버전이 같은 폴더 가운데 가장 높은 것을 고른다. 폴더 이름을 문자열로 비교하면
  `10.0.9` 가 `10.0.11` 보다 크게 나오므로 `Version` 으로 비교해야 한다.
```

### 3. [13:151-155] 원본이 없어도 끊긴 심볼릭 링크가 조용히 만들어진다

`File.CreateSymbolicLink` 는 원본이 없어도 예외를 던지지 않고 링크를 만든다(실측: 없는 경로를
가리키는 링크가 만들어지고 예외도 없다). 그래서 10개 중 하나라도 그 공유 프레임워크에 없으면
`try ... with` 에 걸리지 않고 넘어간 뒤 뒤쪽 `#r` 에서 엉뚱한 오류로 터진다. 원인을 짚을 수 없는
실패다. 151-152줄 사이에 검사를 넣는다.

```fsharp
    let source = Path.Combine(sharedFramework, name + ".dll")
    if not (File.Exists source) then
        failwithf "%s 를 %s 에서 찾지 못했다." name sharedFramework
    let target = Path.Combine(referenceDir, name + ".dll")
```

### 4. [13:303] `RequestErrors.notFound` 의 실행 순서 설명이 거꾸로다

현재 서술: "`text` 는 본문을 `text/plain` 으로 쓰고 상태 코드를 건드리지 않으므로 기본값 200 이
되며, `RequestErrors.notFound` 가 그것을 404 로 바꾼다."

`RequestErrors.notFound h` 는 `setStatusCode 404 >=> h` 다. 404 를 먼저 정하고 그다음에 감싼
핸들러가 돌아간다. 200 을 나중에 404 로 덮는 것이 아니다. 실측으로 갈라 확인했다.

```
route "/a" (RequestErrors.notFound (setStatusCode 500 >=> text "inner-500"))
route "/b" (RequestErrors.notFound (text "plain"))
```
```
/a -> 500  body=inner-500     // 안쪽이 나중에 돌아 404 를 덮는다
/b -> 404  body=plain
```

결과는 같아도 인과가 뒤집혀 있고, 하필 이 챕터의 핵심인 `>=>` 의 순서를 오해하게 만든다.
`>=>` 는 왼쪽이 먼저다. 교체 문장:

```
- 파이프 두 개로 읽으면 뜻이 그대로 드러난다. 문자열을 본문으로 쓰는 핸들러를 만들고,
  그것을 404 로 감싼다. `RequestErrors.notFound h` 의 속은 `setStatusCode 404 >=> h` 다.
  상태 코드를 404 로 먼저 정하고 그다음에 감싼 핸들러가 돌아간다. `text` 는 본문과
  `Content-Type` 만 건드리고 상태 코드를 건드리지 않으므로 404 가 그대로 남는다.
  200 을 나중에 404 로 덮는 것이 아니다 — `>=>` 는 왼쪽이 먼저다.
```

### 5. [13:39] `Func<string>` 으로 감싸야 하는 이유가 틀렸다

현재 서술: "F# 함수는 델리게이트가 아니므로 `Func<string>(fun () -> ...)` 로 감싸야 한다."

F# 은 메서드 호출 자리에서 대상 델리게이트 타입이 정해져 있으면 람다를 델리게이트로 자동
변환한다. 이 규칙을 부정하는 문장을 그대로 두면 독자가 다른 .NET 상호운용 자리에서도
반드시 감싸야 한다고 잘못 배운다.

실제 원인은 오버로드다. 감싸지 않고 넘기면 이렇게 된다(실측, 프로젝트 빌드).

```
error FS0001: 이 식에는 'AspNetCore.Http.HttpContext' 형식이 필요하지만
              여기에서는 'unit' 형식이 지정되었습니다.
```

`RequestDelegate`(`HttpContext -> Task`) 오버로드가 잡힌 것이다. 최소 API 쪽 오버로드는
`System.Delegate` 를 받으므로 어느 델리게이트를 만들지 정할 수 없다. 그래서 `Func<string>` 이라고
직접 이름을 대 준다. 교체 문장:

```
- `MapGet` 은 C# 용으로 만들어진 오버로드다. 하나는 `RequestDelegate` 를 받고 하나는
  `System.Delegate` 를 받는다. F# 은 대상 델리게이트 타입이 정해진 자리라면 람다를 자동으로
  변환해 주지만, 여기서는 `fun () -> "Hello World!"` 를 그냥 넘기면 `RequestDelegate` 오버로드가
  잡혀 `error FS0001` 로 `HttpContext` 를 요구한다. `System.Delegate` 쪽은 어느 델리게이트를
  만들지 정할 수 없다. 그래서 `Func<string>(...)` 으로 이름을 대 준다. 이 어색함이 Giraffe 를
  쓰는 이유 중 하나다.
```

### 6. [13:3] 서두의 "새 문법은 사실상 두 개뿐이다" 가 챕터 내용과 어긋난다 (자기모순)

`<-` 와 `task` 만 든다. 그런데 이 챕터는 익명 레코드 `{| ... |}` 도 처음 도입하고(전 챕터
어디에도 `{|` 가 없다 — `grep` 확인), `mutable` 키워드도 처음 쓰고, `>=>` 도 처음 나온다.
308-309줄이 익명 레코드를 새 문법으로 소개하고 있으므로 서두와 정면으로 부딪힌다.

교체 문장:

```
새 문법이 몇 개 나온다. 프로퍼티를 설정할 때 쓰는 할당 연산자 `<-` 와 그 짝인 `mutable`,
값을 그 자리에서 만드는 익명 레코드 `{| ... |}`, 핸들러를 이어 붙이는 `>=>`, 비동기 작업을
적는 `task` 계산 식(computation expression)이다. 하나하나는 작고, 나머지는 2챕터의 함수 합성,
3챕터의 `Option`·`Result`, 9챕터의 단일 케이스 판별 유니온, 4챕터의 파일 컴파일 순서가
그대로 쓰이는 장면이다.
```

### 7. [13:162] "실행 중에 계산한 경로를 `#r` 에 넘길 방법이 없어서" 는 사실이 아니다

`#r` 목록을 파일로 써서 `#load` 하면 넘어간다(실측: 앞 블록에서 절대 경로 `#r` 열 줄을 담은
`aspnetcore.fsx` 를 만들고 뒤 블록에서 `#load "aspnetcore.fsx"` 로 들여오면 서버가 정상으로 뜬다).
링크를 쓴 것은 그 방법보다 읽기 쉽기 때문이지 다른 길이 없기 때문이 아니다.

교체 문장:

```
- (3)에서 링크를 만드는 것은 `#r` 이 문자열 리터럴만 받기 때문이다. 실행 중에 계산한 경로를
  `#r` 에 직접 넘길 수는 없으므로, 스크립트 폴더 옆에 정해진 이름으로 걸어 두고 상대 경로로
  참조한다. 링크가 막힌 환경에서는 복사로 넘어간다. `#r` 줄을 담은 스크립트를 만들어
  `#load` 하는 방법도 되지만, 참조하는 어셈블리가 노트에 그대로 보이는 쪽을 택했다.
```

---

## 개선 권장

### 검증 방식에 대한 판단 — 현재 방식을 유지하는 데 찬성한다

집필자의 판단 과정 세 단계를 모두 재현해 확인했다.

- `#r "nuget: Giraffe, 8.3.0"` 만으로는 `error FS0039` 가 난다(실측). 원인도 정확하다 —
  Giraffe 8.3.0 의 `.nuspec` 에 `frameworkReference name="Microsoft.AspNetCore.App"` 이 있다.
- 이식성 있는 패키지 우회로는 없다. `#r "nuget: Microsoft.AspNetCore.App.Ref, 10.0.0"` 은
  `NU1213`(패키지 형식이 `DotnetPlatform`)으로 거부된다(실측). 런타임 팩 기각도 타당하다.
- 채택한 방식은 이 환경에서 그대로 재현된다. 응답 6건이 주석과 정확히 일치한다.

`dotnet run` 전제 + `id` 없는 블록으로 바꾸는 대안에는 반대한다. 근거는 셋이다.

1. 이 챕터의 가장 값나가는 부분이 실측 시그니처다. `hiveListHandler` 가 `HttpHandler` 로 적혀
   있는데도 FSI 가 `HttpFunc -> ctx: HttpContext -> HttpFuncResult` 로 펼쳐 찍는 것,
   `notFoundHandler` 는 `HttpHandler` 로 남는 것 — 타입 약어가 무엇인지 독자가 눈으로 보는
   자리다. `id` 를 떼면 이 주석들의 근거가 사라진다.
2. 13~15챕터는 조용히 낡을 위험이 가장 큰 자리다. 외부 패키지 + 공유 프레임워크 + 프레임워크
   참조가 겹쳐 있다. 용어집 머리말의 이식성 규칙 (2)("`id` 를 떼지 않는다")가 정확히
   이 상황을 겨냥한다.
3. 준비 코드가 독자의 읽는 길을 막지 않는다. `(노트 보충)` 절 안에 있고, 블록 첫 줄 주석과
   113줄 산문이 "`Program.fs` 에는 들어가지 않는다"를 두 번 못박는다.

다만 위 수정 필요 2·3번(버전 선택, 원본 존재 검사)은 이식성 문제이므로 반드시 함께 적용해야
한다. 14·15챕터의 같은 두 곳도 같이 고쳐야 한다.

`#load` 변형(수정 필요 7번)에 대한 의견: 지금 바꿀 만한 이득은 아니다. 심볼릭 링크의 실패
경로(Windows 권한)는 이미 `File.Copy` 로 막혀 있고, 원본 검사만 더하면 남는 실패 모드가 없다.
세 챕터를 함께 고치는 비용이 이득보다 크다.

### [13:112] 준비 코드의 이식성 한계를 한 줄 더 알려야 한다

지금은 선행 요구사항으로 SDK 와 네트워크만 든다. 다음 두 가지가 빠져 있다.

- `#r` 로 적은 어셈블리 10개는 SDK 버전이 정한 목록이 아니라 이 챕터의 코드가 타입 이름을
  직접 적는 어셈블리 목록이다. 코드가 다른 네임스페이스를 건드리면 줄을 더해야 한다
  (14챕터가 `System.Collections.Concurrent` 를 더하면서도 `#r` 은 그대로 둔 것이 그 예다 —
  그 네임스페이스는 공유 프레임워크가 아니라 기본 런타임에 있다).
- 공유 프레임워크가 여러 버전 설치돼 있으면 어느 것을 고르는지가 결과를 바꾼다.

112줄 뒤에 한 줄을 더한다.

```
- `#r` 로 적는 어셈블리 10개는 SDK 버전이 정한 목록이 아니라 이 챕터의 코드가 타입 이름을
  직접 적는 어셈블리다. 코드가 다른 네임스페이스를 건드리면 그만큼 줄을 더해야 한다.
  실행 중에만 필요한 어셈블리는 아래 (2)의 해석기가 채우므로 적지 않아도 된다.
```

### [13:273-276] 세 번째 타입 약어도 컴파일러에게 물어라

`asHttpFuncResult`·`asHttpFunc` 두 줄로 `HttpFuncResult`·`HttpFunc` 를 확인한 것은 좋다.
그런데 정작 이 절의 주인공인 `HttpHandler` 는 확인하지 않고 279-285줄에서 선언만 한다.
한 줄 더하면 세 줄 모두 근거가 생긴다. 그리고 276줄의 `printfn` 은 문자열 리터럴을 찍는
것이라 아무것도 증명하지 않는다. 블록을 이렇게 바꾼다.

```fsharp
// HttpFunc·HttpFuncResult·HttpHandler 가 무엇의 약어인지 컴파일러로 확인한다
// 타입 약어는 원래 타입과 같은 것이므로, 아래 세 정의가 컴파일된다는 것이 곧 약어가 그 모양이라는 뜻이다
let asHttpFuncResult (t: Threading.Tasks.Task<HttpContext option>) : HttpFuncResult = t
let asHttpFunc (f: HttpContext -> HttpFuncResult) : HttpFunc = f
let asHttpHandler (h: HttpFunc -> HttpContext -> HttpFuncResult) : HttpHandler = h
printfn "세 약어를 컴파일러가 받아들였다"
```

(`asHttpHandler` 를 더해 실행해 확인했다. 통과하고 경고도 없다.)

### [13:344] `>=>` 와 `>>` 의 대비를 정확히 하라

"2챕터의 `>>` 가 값을 넘기는 합성이었다면 `>=>` 는 요청 맥락을 넘기는 합성이다" 는 `ctx` 가
왼쪽에서 오른쪽으로 값처럼 흐른다는 그림을 만든다. 실제로는 오른쪽 핸들러가 왼쪽 핸들러의
`next` 자리로 들어가고, 왼쪽이 `next` 를 부르지 않으면 오른쪽은 아예 돌지 않는다.
이 짧게 끊는 성질이 `>=>` 를 쓰는 이유인데 챕터 어디에도 없다. 교체 문장:

```
- `>=>` 가 핸들러 두 개를 이어 붙인다. 왼쪽 핸들러가 응답 헤더를 하나 달고 다음 핸들러를
  부르며, 오른쪽 핸들러가 본문을 쓴다. `>>` 와는 잇는 방식이 다르다. `>>` 는 앞 함수의
  결과를 뒤 함수의 입력으로 넘기지만, `>=>` 는 오른쪽 핸들러를 왼쪽 핸들러의 `next` 자리로
  넣는다. 그래서 왼쪽이 `next` 를 부르지 않으면 오른쪽은 아예 돌지 않는다. 상태 코드를
  먼저 정하고 본문을 나중에 쓰는 `RequestErrors.notFound` 가 이 순서에 기대고 있다.
- 이어 붙인 결과의 타입도 `HttpHandler` 다. 그래서 몇 개를 이어도 경로에 붙이는 방법은
  달라지지 않는다.
```

### [13:530-538, 540] 진입점에서 두 함수를 부르는 순서의 근거를 적어라

`configureServices` 가 `Build()` 앞, `configureApp` 이 뒤인 것이 요지인데 이유가 없다.
실측으로 확인했다 — `Build()` 뒤에 `builder.Services` 를 건드리면
`InvalidOperationException: The service collection cannot be modified because it is read-only.` 다.
540줄 앞에 한 줄 더한다.

```
- 순서에 이유가 있다. `configureServices` 는 `builder.Build()` 앞이어야 한다. 컨테이너는
  `Build()` 에서 굳으므로 그 뒤에 서비스를 더하려 하면 `InvalidOperationException` 이 난다.
  `configureApp` 은 만들어진 앱에 미들웨어를 붙이는 것이므로 `Build()` 뒤여야 한다.
```

### [13:105] 미들웨어 파이프라인이라는 이름을 한 번은 적어라

"요청이 지나갈 미들웨어 순서"로 풀어 쓰고 용어를 한 번도 쓰지 않았다. ASP.NET Core 문서나
다른 자료로 넘어갈 독자가 이 이름을 모르면 다리가 끊긴다. 용어집 후보 파일에
`middleware pipeline`→미들웨어 파이프라인 을 별개 행으로 올렸다(기확정 `pipeline` 은 손대지 않았다).
105줄을 이렇게 바꾼다.

```
- `configureApp` 은 요청이 지나갈 미들웨어의 순서를 정한다. 이 순서를 미들웨어
  파이프라인(middleware pipeline)이라 부른다. 2챕터에서 `|>` 로 값을 흘려보낸 함수
  파이프라인과는 다른 것이므로 이 챕터에서는 줄여 쓰지 않고 온낱말로 적는다.
  순서가 곧 동작이다. 라우팅을 먼저 켜고, Giraffe 엔드포인트를 등록하고, 어느 엔드포인트에도
  걸리지 않은 요청을 받을 핸들러를 마지막에 둔다.
```

525줄의 "`configureApp` 의 순서가 곧 요청이 지나는 길이다" 는 그대로 두어도 된다.

### [13:258-259] 엔드포인트 라우팅 이전 방식과의 차이를 한 줄 적어라

원서 p.169 가 "the new endpoint routing" 이라 부르며 이전 방식을 전제한다. 노트는 새 방식만
설명하므로 "무엇에 대해 새로운지"가 비어 있다. 259줄 뒤에 한 줄 더한다.

```
- 이전 방식에서는 라우팅도 `HttpHandler` 였다. `choose [ ... ]` 로 후보를 늘어놓고 요청마다
  위에서 아래로 시도해 처리한 것이 나오면 멈추는 식이었다. 엔드포인트 라우팅은 경로 표를
  ASP.NET Core 라우팅에 넘겨 매칭을 그쪽에 맡기고, Giraffe 는 매칭된 뒤의 처리만 맡는다.
  그래서 라우팅이 함수가 아니라 값이 되었다.
```

### [13:472-473] 원서가 `Endpoint list` 를 `HttpHandler` 라고 적은 곳을 짚어라

원서 p.174 는 "We can extract routes to another HttpHandler" 라고 적었다. `subRoute` 가 받는
것은 `Endpoint list` 이고 `HttpHandler` 가 아니다(원서 자신의 코드 주석은 `// Endpoint list` 로
맞게 적혀 있다). 473줄이 "뺀 목록도 그냥 `Endpoint list` 다"로 사실은 바로잡았지만, 원서를
옆에 둔 독자가 p.174 문장에서 걸릴 자리이므로 명시하는 편이 낫다. 473줄에 한 문장 덧붙인다.

```
  원서 p.174 는 이 목록을 "another HttpHandler" 라고 적었는데 `Endpoint list` 다.
  원서 코드 주석 쪽은 `// Endpoint list` 로 맞게 적혀 있다.
```

### [13:75] 로그 줄이 하나인 이유가 정확하지 않다

"현재 템플릿은 프로필을 골라 하나만 띄우므로 로그에 한 줄만 나온다" 는 원인을 잘못 짚었다.
템플릿의 `launchSettings.json` 을 보면 `http` 프로필의 `applicationUrl` 이 URL 하나이고
`https` 프로필은 `"https://localhost:7122;http://localhost:5157"` 로 둘이다(실측).
`dotnet run --launch-profile https` 로 띄우면 원서 화면처럼 두 줄이 나온다. 교체 문장:

```
- 원서는 실행 로그에 URL 두 개가 나오는 화면을 보여 준다. 기본 프로필인 `http` 의
  `applicationUrl` 에 URL 이 하나뿐이라 한 줄만 나오는 것이고, `--launch-profile https` 로
  띄우면 그 프로필의 `applicationUrl` 에 URL 이 둘이라 원서와 같이 두 줄이 나온다.
```

### [13:214] `Option.defaultValue` 대신 `Option.defaultWith` 가 관용적이다

`|> Option.defaultValue (Error $"벌통 {code} 은 등록되어 있지 않다")` 는 성공한 경우에도
실패 메시지를 만든다. `defaultValue` 는 인자를 먼저 평가하기 때문이다. 여기서는 문자열 하나라
값이 싸지만, "없을 때만 만든다"를 코드로 보여 주는 자리이므로 `defaultWith` 가 맞다.

```fsharp
    |> Option.defaultWith (fun () -> Error $"벌통 {code} 은 등록되어 있지 않다")
```

215줄 산문에 "대안 값을 만드는 데 값이 든다면 `Option.defaultWith` 로 미룬다" 한 마디를
붙이면 3챕터와의 연결도 촘촘해진다. 시그니처는 그대로다(실측 확인).

### [13:497] "동사별로" 를 "메서드별로" 로 고쳐라

같은 문서가 다른 두 곳에서는 "HTTP 메서드"라고 쓴다(259줄 근처, 656줄). 원서는 verb 라고
부르지만 노트는 한 낱말로 통일해야 한다. 용어집 후보에 `HTTP method`→HTTP 메서드 로 올렸다.

### [13:498] 이름 규칙 서술이 자기 예시와 맞지 않는다

`<대상><동작>Handler` 라고 적었는데 이 챕터의 이름은 `apiSummaryHandler`·`hiveListHandler`·
`hiveStatusHandler` 로 뒤가 동작이 아니고, `notFoundHandler` 는 규칙 밖이다. 14챕터는
`inspectionCreateHandler`·`inspectionUpdateHandler`·`inspectionDeleteHandler` 로 동작이 맞고
`recordMissingHandler`·`requestInvalidHandler` 는 또 다르다. 규칙을 넓혀 적는 편이 정확하다.

```
- 핸들러 이름은 `<대상><동작 또는 응답 내용>Handler`, 엔드포인트 목록 이름은 `<영역>Endpoints`,
  뷰 이름은 `<이름>View` 로 맞춰 두었다. 원서에서 온 `notFoundHandler` 는 대상이 없어 규칙
  밖이지만 이름이 널리 쓰이므로 그대로 둔다. 14·15챕터가 이 규칙을 이어 쓴다.
```

656줄 인수인계 문단의 같은 표기도 함께 고친다.

### [13:9] "최소 웹 앱" → "최소 웹 애플리케이션"

같은 문서 3줄이 "웹 애플리케이션"으로 쓴다. 용어집 후보에 `web application` 행을 올렸다.

---

## 확인 완료

집필자가 보고한 6건은 전부 재확인했다. 결과는 다음과 같다.

1. p.171 "querystring item" → 경로 매개변수다. 맞다. `routef "/hives/%s"` 가 넘기는 것은
   경로 조각이고, `/api/hives/h-07` 요청이 `h-07` 을 핸들러 첫 인자로 받는 것을 응답으로 확인했다.
   367줄과 648줄의 서술이 정확하다.
2. p.172 반환 타입 주석 → `HttpFuncResult` 여야 한다. 맞다. 원서 표기 그대로
   `(code: string) (next: HttpFunc) (ctx: HttpContext) : HttpHandler` 로 적어 컴파일하면
   `error FS0193: 형식 제약 조건이 일치하지 않습니다.` 가 난다(실측, 오류 코드와 메시지 문면
   모두 노트와 일치).
3. p.169 "`=` 를 쓰면 컴파일러가 경고한다" 의 조건. 맞다. 그리고 노트의 범위 한정이 정확하다.
   - 프로젝트 빌드: `warning FS0020: 이 같음 식의 결과는 'bool' 형식이며 암시적으로
     삭제됩니다. ... 값을 변경하려면 '<-' 연산자를 사용하세요(예: 'frames <- expression').`
   - `.fsx` 최상위: 경고 없음.
   - `.fsx` 안 함수 본문: 경고 남. 186줄이 "스크립트 최상위"로 한정한 것이 옳다.
4. p.169 `UseDeveloperExceptionPage` 불필요. 맞다. 그 호출 없이 개발 환경에서 예외를 던지는
   경로를 만들어 요청하면 500 응답 본문에 `DeveloperExceptionPageMiddlewareImpl` 이 찍힌다(실측).
5. "Giraffe 5.x 에서 도입" → 258줄 서술이 맞다. 4.1.0 과 5.0.0 패키지를 내려받아 어셈블리를
   확인했다. `EndpointRouting` 문자열이 5.0.0 에는 있고 4.1.0 에는 없다.
6. 판별 유니온 직렬화 함정. 맞다. 두 방향 모두 확인했다.
   - `JsonSerializer.Serialize (HiveCode "H-07")` →
     `System.NotSupportedException: F# discriminated union serialization is not supported.`
   - `Hive` 를 그대로 `json` 핸들러에 넘긴 경로를 만들어 요청하면 상태 코드 500(실측).
   333줄과 647줄의 서술이 정확하다.

그 밖에 확인한 것.

- 실행 단위 4개 전부 PASS, 경고 0건. `13-server` 의 응답 6건이 612-625줄 주석과 완전히 일치한다.
- 실측 시그니처 주석 10개 전부 일치한다. `findHive: code: string -> Result<Hive,string>`,
  `notFoundHandler: HttpHandler`, `apiSummaryHandler: HttpHandler`,
  `hiveListHandler: HttpFunc -> ctx: HttpContext -> HttpFuncResult`,
  `hiveStatusHandler: code: string -> next: HttpFunc -> ctx: HttpContext -> HttpFuncResult`,
  `apiEndpoints: Endpoint list`, `endpoints: Endpoint list`, `indexView: XmlNode`,
  `configureServices: services: IServiceCollection -> unit`,
  `configureApp: appBuilder: IApplicationBuilder -> unit`,
  `hiveRow: code: string * frames: int -> XmlNode`,
  `hiveTableView: rows: (string * int) list -> XmlNode`.
- 361줄의 관찰이 정확하다. 람다로 적은 핸들러는 FSI 가 약어를 펼쳐 찍고, 함수를 조립해 만든
  값은 `HttpHandler` 로 남는다. 둘을 나란히 확인했다.
- 타입 약어 세 줄(281-285줄)이 맞다. `HttpFuncResult = Task<HttpContext option>`,
  `HttpFunc = HttpContext -> HttpFuncResult`,
  `HttpHandler = HttpFunc -> HttpContext -> HttpFuncResult` 를 각각 항등 함수로 확인했다.
- 288줄의 `None` 해석이 맞다. 처리 여부를 값으로 나르는 것이고 3챕터와의 연결도 정확하다.
- 287줄의 "첫 인자가 다음 핸들러라서 핸들러를 이어 붙일 수 있다" 가 `>=>` 의 정확한 근거다.
- 익명 레코드 서술이 맞다. 필드를 적은 순서와 무관하게 같은 타입이고 구조적 동등성이 성립하며,
  직렬화 결과의 키가 이름 순으로 나오고 `JsonSerializerDefaults.Web` 에서 첫 글자가 소문자가
  된다. Giraffe 의 `json` 핸들러 기본값도 이쪽인 것을 응답 본문으로 확인했다.
- 525줄의 `UseGiraffe` 오버로드 서술이 맞다. 마지막 오버로드가 `unit` 을 돌려주므로
  `configureApp` 전체가 `unit` 이 되고 `ignore` 가 필요 없다(실측 시그니처가 이를 뒷받침한다).
- 524줄의 인코더 서술이 맞다. `Json.ISerializer` 로 갈아 끼운 직렬화기로 `성수 옥상` 이
  이스케이프 없이 나가는 것을 응답 본문으로 확인했고, `Unsafe` 이름에 대한 주의도 정확하다.
- 360줄의 `ctx.WriteJsonAsync` 서술이 맞다. `Content-Type` 이 `application/json` 으로 나가고,
  다음 핸들러를 부르지 않으므로 첫 인자를 `_` 로 버린 것이 옳다.
- 388줄의 `task` 계산 식 서술이 맞다. F# 6 부터 코어에 있고 Giraffe 가 `Task` 를 직접 쓴다.
- 20줄의 "템플릿 출력이 원서와 한 글자도 다르지 않다" 가 맞다. `dotnet new web -lang "F#"` 로
  만들어 대조했다. `.fsproj` 와 `launchSettings.json` 의 프로필 두 개, `http` 가 첫 프로필인
  것까지 노트와 같다.
- 40줄의 FS0020 서술이 맞다. `MapGet` 반환값을 버리지 않으면 경고가 난다.
- `id` 배정이 옳다. `id` 없는 블록 6개는 모두 컴파일되지 않는 조각이다 — 골격에 `...` 가 있는
  것(96-101, 393-397), 정의되지 않은 이름을 쓰는 것(261-266), 타입 약어 선언을 옮겨 적은 것
  (281-285), 스크립트에서 쓸 수 없는 `[<EntryPoint>]` 가 있는 것(22-37, 529-538).
  `id` 를 붙여야 하는데 빠진 블록은 없다.
- 14·15챕터와의 인수인계가 어긋나지 않는다. 프로젝트 `HiveLog`, `HiveCode`/`Hive`/`findHive`,
  바깥 `endpoints` + `subRoute "/api" apiEndpoints`(15챕터가 화면 경로를 바깥에만 더한다),
  `Json.ISerializer` 등록, `notFoundHandler : HttpHandler`, 이름 규칙 세 가지, 준비 코드,
  판별 유니온 직렬화 제약이 뷰에는 해당하지 않는다는 단서까지 세 챕터가 일관된다.
- 챕터 상호 참조가 맞다. 2챕터 함수 합성, 3챕터 `Option`·`Result`, 4챕터 컴파일 순서,
  9챕터 단일 케이스 판별 유니온, 12챕터 계산 식 — 해당 챕터의 실제 내용과 일치한다.
