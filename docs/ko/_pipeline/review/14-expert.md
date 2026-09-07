# 14챕터 F# 전문가 검수 보고서

검수 대상: `docs/ko/14-api-with-giraffe.md` (941줄, 실행 단위 3개)
참고 원문: `.cache/src/14-api-with-giraffe.txt` (원서 pp.178-184)
연속성 대조: `docs/ko/13-web-with-giraffe.md`, `docs/ko/15-web-pages-with-giraffe.md`, `docs/ko/04-organising-code-and-testing.md`
용어 후보: `docs/ko/_pipeline/review/14-glossary.md`

검증 환경: .NET SDK 10.0.111, ASP.NET Core 공유 프레임워크 10.0.11, Giraffe 8.3.0, Giraffe.ViewEngine 1.4.0.
아래 "실측"은 모두 이 환경에서 직접 돌려 확인한 결과다.

```
docs/ko/_pipeline/verify-examples.sh docs/ko/14-api-with-giraffe.md
  PASS 14-binding / PASS 14-server / PASS 14-store
docs/ko/_pipeline/check-note.sh docs/ko/14-api-with-giraffe.md
  OK
```

세 실행 단위를 따로 돌려 주석에 적힌 기대 출력과 실제 출력을 한 줄씩 대조했다. 전부 일치한다.
FSI 시그니처 주석도 `#load` 로 모듈을 올려 하나씩 확인했고 전부 일치한다(6번 항목에서 코드를
고치면 두 줄이 바뀐다).

---

## 수정 필요 (기술 오류)

### 1. [294줄] `GetService` 가 던지는 예외 타입이 틀렸다

현재 문장.

> - 등록하지 않은 타입을 `GetService` 로 꺼내면 실행 중에 `System.InvalidOperationException` 이 난다. 컴파일은 통과하므로 등록을 잊으면 첫 요청에서 500 을 받는다.

`System.InvalidOperationException` 은 `IServiceProvider.GetRequiredService` 가 던지는 것이다.
Giraffe 의 확장 멤버 `ctx.GetService<'T>()` 는 `RequestServices.GetService` 를 부른 뒤 `null` 이면
자기 예외를 던진다. 등록하지 않은 타입으로 실측한 결과는 이렇다.

```
Giraffe.MissingDependencyException | Could not retrieve object of type 'Unregistered' from ASP.NET
Core's dependency container. Please register all Giraffe dependencies by adding
`services.AddGiraffe()` to your startup code. ...
```

이렇게 고쳐라.

> - 등록하지 않은 타입을 `GetService` 로 꺼내면 실행 중에 `Giraffe.MissingDependencyException` 이 난다. 메시지가 `services.AddGiraffe()` 를 부르라고 안내하지만 실제 원인은 그 타입을 등록하지 않은 것이다. 컴파일은 통과하므로 등록을 잊으면 첫 요청에서 500 을 받는다.

### 2. [275줄] `ConcurrentDictionary.Values` 가 지연 평가되는 뷰라는 서술이 틀렸다

현재 문장.

> - `All` 이 `Seq` 를 그대로 내보내지 않고 `Seq.toList` 로 확정하는 것은 5챕터의 이야기다. `data.Values` 는 지연 평가되는 뷰이므로 밖으로 내보낸 뒤 다른 요청이 사전을 바꾸면 열거 도중에 내용이 달라질 수 있다.

`ConcurrentDictionary<'K,'V>.Values` 는 뷰가 아니다. 프로퍼티를 읽는 순간 잠금을 잡고 값을 복사해
`ReadOnlyCollection<'V>` 를 돌려준다. 실측.

```
타입: System.Collections.ObjectModel.ReadOnlyCollection`1[System.String]
값 개수: 2 (사전은 3)          // Values 를 읽은 뒤 항목을 하나 더 넣었다
```

지연 평가되는 뷰는 평범한 `Dictionary<'K,'V>.Values` 쪽이고, 그것은 열거 도중 사전이 바뀌면
`InvalidOperationException: Collection was modified; enumeration operation may not execute` 를 던진다
(실측). 즉 지금 서술은 두 타입의 성질을 뒤바꿔 적었고, `ConcurrentDictionary` 를 쓴 이유를 잘못
설명한다. 이렇게 고쳐라.

> - `All` 이 `Seq` 를 그대로 내보내지 않고 `Seq.toList` 로 확정하는 것은 5챕터의 이야기다. `data.Values` 는 그 순간의 값들을 복사한 `ReadOnlyCollection<'T>` 라 열거는 이미 안전하지만, `Seq.sortBy` 가 지연 평가되므로 그 결과를 그대로 내보내면 정렬이 언제 일어나는지 알 수 없는 `seq` 가 저장소 밖으로 나간다. `Seq.toList` 가 그 자리에서 정렬을 끝내고 타입도 `Inspection list` 로 못박는다.
> - 평범한 `Dictionary` 의 `Values` 는 반대로 살아 있는 뷰다. 열거 도중에 사전이 바뀌면 `InvalidOperationException` 이 나므로, 요청을 여러 스레드에서 받는 자리에서 `ConcurrentDictionary` 를 고른 이유가 여기서도 확인된다.

### 3. [895줄] 브라우저로 `negotiate` 경로를 열면 406 이 온다는 서술이 틀렸다

현재 문장.

> - `text/html` 은 규칙에 없으므로 406 이다. 브라우저는 보통 `text/html` 을 먼저 요구하므로, `negotiate` 를 붙인 경로를 주소창으로 열면 406 을 보게 된다. ...

브라우저는 `text/html` 만 보내지 않는다. Chrome·Firefox 가 보내는 값은
`text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8` 이고,
Giraffe 의 협상은 q 값 순서대로 규칙에 있는 첫 형식을 고른다. `text/html` 과
`application/xhtml+xml` 에는 규칙이 없고 그다음 `application/xml`(q=0.9)에 규칙이 있으므로
XML 이 선택되어, 이 챕터가 665줄에서 설명한 XML 직렬화 실패로 500 이 나간다. 실측.

```
Accept: text/html                                          406  text/html is unacceptable by the server.
Accept: text/html,*/*;q=0.8                                200  application/json; charset=utf-8
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,...,*/*;q=0.8   500
```

이렇게 고쳐라.

> - `Accept: text/html` 만 보내면 규칙에 없으므로 406 이다. 그런데 브라우저가 실제로 보내는 값은 `text/html,application/xhtml+xml,application/xml;q=0.9,...,*/*;q=0.8` 이고, 협상은 q 값 순서대로 규칙에 있는 첫 형식을 고른다. `text/html` 을 지나 `application/xml` 이 먼저 걸리므로 주소창으로 열면 406 이 아니라 앞에서 본 XML 직렬화 실패로 500 이 온다. 13챕터의 첫 화면처럼 HTML 을 내보내야 하는 경로에는 `negotiate` 를 붙이지 않고 `htmlView` 를 그대로 쓴다.

15챕터 451줄에 같은 서술("`negotiate` 의 기본 규칙에는 `text/html` 이 없어 브라우저 요청이 406 이
된다")이 있다. 그 챕터의 결론(화면과 API 를 경로로 갈라 둔다)은 그대로 유지되고 근거만
"브라우저 요청이 XML 쪽으로 걸려 500 이 된다"로 바뀐다. 15챕터 전문가에게 인계한다.

### 4. [664줄] 기본 협상 규칙 목록에 `text/xml` 이 빠졌다

현재 문장은 규칙을 열거하는 형태인데 `text/xml` 이 없다. `DefaultNegotiationConfig().Rules` 를
직접 찍어 보면 규칙이 다섯 개다.

```
규칙 수: 5
  */*   application/json   application/xml   text/xml   text/plain
```

`text/xml` 도 XML 쪽으로 가므로 F# 레코드에서는 500 이다(실측). 3번 항목의 설명이 성립하려면
XML 규칙이 둘이라는 사실이 앞에 있어야 한다. 이렇게 고쳐라.

> - `AddGiraffe()` 가 등록해 두는 기본 규칙이 `Accept` 값과 핸들러를 짝지어 준다. 규칙은 다섯 개다. `application/json` 과 `*/*` 는 JSON, `text/plain` 은 값의 문자열 표현, `application/xml` 과 `text/xml` 은 XML 이다. 어느 규칙에도 맞지 않으면 상태 코드 406 으로 답한다.

### 5. [602줄] 중괄호가 겹친 이유가 틀렸다

현재 문장.

> - 중괄호가 겹쳐 있는 것은 이 문자열이 서식 문자열이어서 `{` 를 이스케이프해 둔 것이다. 라우팅에 넘어갈 때 한 겹이 풀린다.

뒷문장은 맞고 앞문장이 틀렸다. Giraffe 는 `{%s:regex(%s)}` 라는 서식 문자열에 정규식을 `%s` 로
끼워 넣으므로 `%s` 자리의 `{{` 는 서식 처리와 무관하게 그대로 남는다(Giraffe.dll 안의 리터럴이
이미 `[0-9A-Fa-f]{{8}}` 이다). 한 겹을 푸는 쪽은 ASP.NET Core 의 경로 템플릿 파서다. 그 파서는
경로 템플릿에서 `{{`·`}}` 를 리터럴 중괄호의 이스케이프로 읽는다. 실측.

```fsharp
RoutePatternFactory.Parse "/{O0:regex(^[0-9A-Fa-f]{{8}}-...)}"
// policy=regex(^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-...)
```

이렇게 고쳐라.

> - 중괄호가 겹쳐 있는 것은 경로 템플릿의 이스케이프다. ASP.NET Core 의 템플릿 파서는 `{{` 와 `}}` 를 리터럴 중괄호로 읽으므로, Giraffe 가 미리 겹쳐 둔 것이 파싱 단계에서 한 겹 풀려 실제 제약에는 `{8}` 이 들어간다. 정규식의 반복 횟수 표기가 템플릿의 매개변수 표기와 같은 문자를 쓰는 탓에 생긴 일이다.

### 6. [419-432줄] 실패 응답 두 값이 값 제한에 걸리는 코드다. 시그니처 설명도 틀렸다

두 문제가 한 자리에 있다.

첫째, `let recordMissingHandler = RequestErrors.notFound (json {| ... |})` 는 매개변수 없는 `let`
바인딩이고 `json` 이 제네릭이라 타입이 열려 있다. 이 두 줄만 따로 파일에 두면 값 제한 오류가 난다.
실측.

```
error FS0030: 값 제한: 값 'recordMissingHandler'에 유추된 제네릭 함수 형식이 있습니다.
    val recordMissingHandler: (HttpFunc -> '_a -> HttpFuncResult) when '_a :> HttpContext
```

지금 노트에서 컴파일되는 것은 뒤의 핸들러들이 이 값을 구체적인 `HttpContext` 와 함께 써서
타입을 못박아 주기 때문이다. 즉 앞뒤 순서에 기대는 코드이고, 독자가 이 두 줄만 떼어 새 파일에
옮기면 바로 FS0030 을 만난다. 12챕터·2챕터가 값 제한을 이미 다뤘으므로 여기서 지뢰를 남길
이유가 없다.

둘째, 432줄의 설명이 틀렸다.

> - 두 값의 실측 시그니처가 `HttpHandler` 가 아니라 펼쳐진 형태로 나오는 것은 13챕터에서 본 타입 약어 세 겹 때문이다. 뜻은 같다.

13챕터 361줄은 정반대를 확인해 두었다. "`notFoundHandler` 처럼 함수를 조립해 만든 값은
`HttpHandler` 그대로 나온다." `recordMissingHandler` 도 함수를 조립해 만든 값인데 펼쳐져 나오므로
13챕터의 규칙과 어긋나 보인다. 실제 이유는 약어가 아니라 반환 타입 주석의 유무다. 실측.

```
let noAnnotation  = RequestErrors.notFound (json {| Error = "x" |})   // error FS0030
let withAnnotation : HttpHandler = RequestErrors.notFound (json {| Error = "x" |})
// val withAnnotation: HttpHandler
```

두 문제가 주석 한 줄로 함께 풀린다. 블록을 이렇게 갈아라.

```fsharp id=14-server

    module Handlers =

        // FSI 실측: HttpHandler
        let recordMissingHandler : HttpHandler = RequestErrors.notFound (json {| Error = "점검 기록이 없다" |})

        // FSI 실측: errors: string list -> HttpHandler
        let requestInvalidHandler (errors: string list) : HttpHandler =
            RequestErrors.badRequest (json {| Errors = errors |})
```

이 형태로 `14-server` 전체를 다시 돌려 확인했다. 경고 없이 통과하고 출력도 그대로다.
뒤따르는 두 불릿(431·432줄)은 이렇게 갈아라. 431줄은 7번 항목과 겹치므로 함께 고친다.

> - 매개변수 주석 `string list` 와 반환 주석 `HttpHandler` 둘 다 필요하다. `json` 은 어떤 타입이든 받는 제네릭 함수라서 매개변수 주석을 빼면 `requestInvalidHandler` 가 `errors: 'a -> ...` 로 자동 일반화되고, 반환 주석을 빼면 `recordMissingHandler` 가 매개변수 없는 `let` 바인딩이라 값 제한 오류 FS0030 에 걸린다. 지금 노트에서는 뒤의 핸들러가 이 값을 써서 타입이 정해지지만, 두 줄만 떼어 옮기면 바로 오류가 난다.
> - 주석을 달아 두면 FSI 도 약어 `HttpHandler` 를 그대로 찍는다. 13챕터의 `notFoundHandler` 와 같은 모양이고, 펼쳐진 형태로 나오는 것은 `fun _ ctx -> ...` 처럼 람다로 적은 핸들러 쪽이다.

### 7. [237·299·362·910줄] "`System.Text.Json` 은 판별 유니온을 다루지 못한다"가 너무 넓다

`Option` 도 판별 유니온인데 `System.Text.Json` 은 그것을 특별히 지원한다. 실측(.NET 10).

| 타입 | 결과 |
|---|---|
| 레코드 | 된다 |
| `int list`, `Set<int>`, `Map<string,int>`, 튜플 | 된다 |
| `int option`, `int voption` | 된다. `Some 5` ↔ `5`, `None` ↔ `null`/필드 없음 |
| 그 밖의 판별 유니온(`HiveCode`, 다중 케이스) | 방향에 상관없이 `NotSupportedException` |

DTO 를 따로 두어야 하는 이유는 그대로 성립한다. `InspectionId` 와 `HiveCode` 는 `Option` 이 아닌
판별 유니온이므로 실제로 막힌다. 문장만 좁히면 된다.

- 237줄: "`System.Text.Json` 은 판별 유니온을 다루지 못하므로" → "`System.Text.Json` 은 `Option` 을 뺀 판별 유니온을 다루지 못하므로"
- 299줄: "`InspectionId` 가 판별 유니온이라 역직렬화 자체가 되지 않는다" → "`InspectionId` 가 `Option` 이 아닌 판별 유니온이라 역직렬화 자체가 되지 않는다"
- 362줄: 첫 문장을 이렇게 갈아라.

> - 판별 유니온은 읽는 방향에서도 막힌다. `System.Text.Json` 의 F# 지원은 레코드·리스트·`Map`·튜플과 `Option` 까지이고, `Option` 이 아닌 판별 유니온은 방향에 상관없이 `NotSupportedException` 이다. 13챕터가 응답에서 만난 예외가 요청에서도 그대로 나오고, 본문을 어떤 모양으로 보내든 타입을 보는 순간 막히므로 본문을 고쳐 피할 방법이 없다.

- 910줄: "판별 유니온은 읽는 방향에서도 `NotSupportedException` 이고" → "`Option` 이 아닌 판별 유니온은 읽는 방향에서도 `NotSupportedException` 이고"

13챕터 333·647줄에도 같은 범위의 서술이 있다. 그 챕터가 다루는 것은 `HiveCode` 하나라
결론은 바뀌지 않으니, 13챕터 전문가에게 문장 범위만 좁히도록 인계한다.

이 정정이 8번 항목의 개선안과 맞물린다. `Option` 이 된다는 사실이 곧 "빠진 필드"를 잡는 수단이다.

### 8. [125줄] "파일 하나가 모듈 하나다"는 4챕터 서술과 어긋나고 이 챕터 자신의 코드와도 어긋난다

4챕터 139-147줄은 한 파일에 `namespace Shop` 을 적고 그 아래 `module Inventory =` 를 두는 형태를
이미 보여 준다. 이 챕터의 `Inspections.fs` 도 `module Inspections` 안에 중첩 모듈 `Handlers` 를
담고 있어 파일 하나에 모듈이 둘이다. 이렇게 고쳐라.

> - 이 프로젝트는 파일마다 최상위 모듈 하나를 선언한다(4챕터에서 본 `module Shop.Learners` 형태다). 스크립트에서는 최상위 `module X.Y` 를 쓸 수 없으므로 그 구조를 중첩 모듈로 본뜬다. 아래 코드의 `module Domain =` 은 프로젝트의 `Domain.fs` 첫 줄 `module HiveLog.Domain` 에 해당하고, 그 아래 들여쓴 부분이 그 파일의 본문이다. 선언 순서가 곧 `.fsproj` 의 컴파일 순서다.

---

## 개선 권장

### 9. [125줄 뒤] 중첩 모듈과 프로젝트 파일의 대응이 `open` 에서 깨진다

지시받은 확인 항목이라 따로 적는다. 컴파일 순서 쪽 대응은 정확하다. 어긋나는 곳은 `open` 하나다.
`open` 은 그것이 적힌 스코프 안에서만 유효하므로, 스크립트에서는 준비 블록의 최상위 `open` 이
아래 중첩 모듈 전부에 미치지만 실제 프로젝트에서는 파일마다 다시 적어야 한다. 지금 노트를 그대로
파일로 옮기면 `Store.fs` 는 `System`·`System.Collections.Concurrent` 가 없어 컴파일되지 않고,
`Inspections.fs` 는 `Microsoft.AspNetCore.Http`·`Giraffe`·`Giraffe.EndpointRouting`·`System.Text.Json`
이 없어 컴파일되지 않는다. 125줄 불릿 뒤에 한 줄 넣어라.

> - 대응이 어긋나는 곳이 하나 있다. `open` 은 적힌 스코프 안에서만 유효하므로, 스크립트에서는 위쪽 준비 블록의 `open` 이 아래 중첩 모듈에 다 미치지만 프로젝트에서는 파일마다 다시 적어야 한다. `Store.fs` 는 `System` 과 `System.Collections.Concurrent`, `Inspections.fs` 는 `System`·`System.Text.Json`·`Microsoft.AspNetCore.Http`·`Giraffe`·`Giraffe.EndpointRouting` 이 필요하다.

### 10. [329-337줄] `bool` 과 `int` 필드는 "빠진 것"과 "기본값"을 구별할 수 없다 — 이 챕터의 교훈이 여기서 가장 날카로워진다

지금 블록은 `null` 이 들어오는 `string` 필드에서 멈춘다. 그런데 `QueenSeen` 이 빠졌을 때 들어오는
`false` 는 클라이언트가 명시적으로 보낸 `false` 와 구별되지 않는다. 검증으로도 잡을 수 없다.
`Frames` 는 `0` 이 범위 밖이라 우연히 걸리는 것이고, `bool` 에는 그런 우연이 없다.

7번 항목에서 확인한 `Option` 지원이 이 문제의 해법이다. 아래 블록을 `14-binding` 마지막에 붙여라.
실측으로 돌려 통과를 확인했고 주석의 기대 출력도 실제 출력이다.

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

뒤에 붙일 설명.

> - `string` 필드는 `null` 이라는 표가 남지만 `bool` 과 `int` 에는 그것이 없다. `queenSeen` 을 보내지 않은 요청과 `false` 를 보낸 요청이 서버에서 똑같이 `false` 로 보이므로 어떤 검증을 붙여도 갈라낼 수 없다. `Frames` 가 `0` 에서 걸리는 것은 `0` 이 마침 범위 밖이어서 생긴 우연이다.
> - 필드가 빠진 것을 반드시 알아야 한다면 요청 타입의 필드를 `Option` 으로 적는다. `System.Text.Json` 은 `Option` 만은 특별히 지원해서 필드가 없거나 `null` 이면 `None`, 값이 있으면 `Some` 을 준다. 이 노트의 `InspectionRequest` 는 세 필드가 다 필수이고 빠진 자리를 검증이 400 으로 잡아 주므로 평평한 타입을 유지했다.

이 절을 넣으면 911줄의 정리 불릿에도 한 문장을 더할 만하다.

> ... 문자열 필드에 `null` 이 들어온다. `bool` 과 `int` 는 빠진 것과 기본값을 구별할 수 없으므로 그 구별이 필요하면 요청 타입의 필드를 `Option` 으로 적는다. ...

### 11. [665줄] XML 탈출구에 `[<CLIMutable>]` 을 하나 더 적을 만하다

지금은 "직렬화기를 갈아 끼우거나 XML 용 타입을 따로 두어야 한다"로 끝난다. 셋째 길이 있고
325줄과 짝을 이룬다. `[<CLIMutable>]` 을 붙인 레코드는 매개변수 없는 생성자와 설정 가능한
프로퍼티를 얻으므로 `XmlSerializer` 가 다룬다. 실측.

```
Plain    -> InvalidOperationException: ... does not have a parameterless constructor.
Mutable  -> OK: <Mutable ...><Apiary>성수</Apiary><Hives>2</Hives></Mutable>
```

문장 끝에 붙여라.

> ... XML 을 정말 내보내야 한다면 직렬화기를 갈아 끼우거나, 레코드에 `[<CLIMutable>]` 을 붙여 매개변수 없는 생성자를 만들어 주거나, XML 용 타입을 따로 두어야 한다. 앞 절에서 JSON 에는 이 특성이 필요 없다고 적은 것과 대비되는 자리다. 익명 레코드에는 특성을 붙일 수 없다.

### 12. [132줄] 인터페이스를 두지 않은 근거가 뒤집혀 있다

현재 문장.

> - ... 저장소를 인터페이스로 추상화하지 않고 클래스 타입 하나로 두는 것은 나중에 실제 저장소로 바꿀 때 손댈 자리를 좁혀 두려는 선택이다.

인터페이스를 두지 않는 것이 손댈 자리를 좁히지는 않는다. 오히려 핸들러가
`ctx.GetService<InspectionStore>()` 로 구체 클래스를 직접 꺼내 쓰고 있어 구현을 갈아 끼우려면
인터페이스가 그때 필요해진다. 이렇게 고쳐라.

> - 프로세스가 끝나면 내용도 사라진다. 저장소를 인터페이스로 추상화하지 않은 것은 이 챕터의 범위를 좁히려는 선택이다. 클래스 하나가 사전을 감싸고 있으므로 그 안을 실제 데이터베이스로 바꾸는 일은 이 파일에서 끝나지만, 구현을 둘 이상 두고 갈아 끼우려면 그때 인터페이스가 필요해진다. 핸들러가 구체 클래스 이름으로 꺼내 쓰고 있다는 점도 그때 걸린다.

### 13. [196줄] "비교 인자가 하는 일도 없다"는 동시성 문맥에서 지나치다

`TryUpdate(key, newValue, comparisonValue)` 는 현재 값이 `comparisonValue` 와 같을 때만 갱신한다.
방금 읽은 값을 그대로 비교 인자로 넘기면 거의 언제나 성공하지만, 읽은 뒤 `TryUpdate` 에
닿기 전에 다른 스레드가 그 키를 바꾸면 `false` 가 돌아온다. `ConcurrentDictionary` 를 쓰는
챕터에서 "하는 일도 없다"로 단정하면 그 창이 없어 보인다. 이렇게 고쳐라.

> ... 게다가 방금 읽은 값을 그대로 비교 인자로 넘기므로 비교가 거의 언제나 성공한다. 읽은 뒤 갱신에 닿기 전에 다른 스레드가 끼어들면 조용히 `false` 가 되는데, 그 결과를 본문에 실어 200 으로 답하니 호출한 쪽이 알 길도 없다. ...

### 14. [411줄] 검증의 실패 타입이 8챕터와 다른 이유를 한 마디 적어라

8챕터는 실패 타입을 `ValidationError` 판별 유니온으로 통일해 두었고(8챕터 273·357줄) 이 챕터는
`string list` 를 쓴다. "8챕터의 검증이 여기 그대로 쓰인다"만 있으면 앞 챕터를 따라온 독자가
왜 달라졌는지 되짚게 된다. 411줄 뒤에 붙여라.

> - 실패 타입이 8챕터의 `ValidationError` 판별 유니온이 아니라 `string list` 인 것은 이 자리의 소비자가 하나뿐이어서다. 오류는 곧 JSON 응답 본문이 되므로 케이스를 나눠 두고 다시 문자열로 되돌릴 이유가 없다. 오류마다 다른 상태 코드를 붙이거나 화면 쪽에서도 같은 검증을 쓴다면 8챕터처럼 판별 유니온으로 올려야 한다.

### 15. [47줄] `open` 이 필수인 것처럼 읽힌다

"`Program.fs` 에서 다른 파일의 이름을 쓰려면 `open` 이 필요하다"는 정확하지 않다.
`HiveLog.Inspections.inspectionEndpoints` 처럼 정규화된 이름으로 부르면 `open` 없이도 된다.
"`open` 이 필요하다" → "`open` 을 적거나 정규화된 이름을 쓴다" 정도로 눌러라.

### 16. 분량 판단 — 정당하다. 다만 설정 절의 중복 한 곳은 정리하라

세 챕터를 산문과 코드로 갈라 세어 보면 이렇다.

| 챕터 | 전체 | 코드 | 산문 |
|---|---|---|---|
| 13 | 674 | 349 | 325 |
| 14 | 941 | 579 | 362 |
| 15 | 707 | 451 | 256 |

산문은 13챕터보다 37줄 많을 뿐이다. 절 수도 16개로 13챕터와 같은 급이고 정리 불릿은 11개,
인계 문단은 1780자로 13챕터(10개, 1525자)와 비슷하다. 늘어난 것은 코드 230줄이고 전부
`14-server` 다(453줄. 13챕터 199줄, 15챕터 331줄).

`14-server` 를 뜯어 보면 준비 코드 62줄, 검증용 호스트·요청 코드 95줄, 앱 코드 296줄이다.
앱 코드 296줄 가운데 110줄가량은 13챕터 코드를 다시 적은 것이다(도메인, `notFoundHandler`,
`indexView`, 벌통 핸들러 둘, `endpoints`, `configureServices`·`configureApp`). 스크립트가
자기 완결이어야 실행되므로 이 반복은 피할 수 없고, 오히려 685줄의 "13챕터와 한 글자도 다르지
않다"를 독자가 눈으로 확인하게 만드는 자리다. 실제로 13챕터 487-493줄과 문자 단위로 같다.

결론: 941줄은 정당하다. 절을 덜어낼 자리는 없다. 다만 진짜 중복 한 곳이 있다.

- 282-285줄의 조각 블록과 그 앞뒤 두 불릿(279-287줄)이 698-722줄의 "설정" 절과 같은 내용을
  두 번 말한다. `.AddSingleton<InspectionStore>(InspectionStore())` 한 줄이 두 곳에 나오고,
  "13챕터의 `configureServices` 에 한 줄 더하는 것"이라는 설명도 280줄과 721줄에 두 번 나온다.
  282-285줄 블록과 280줄 뒷문장을 지우고, 등록 코드는 700-719줄의 완전한 블록 한 곳에만 두어라.
  280줄은 "ASP.NET Core 의 의존성 주입 컨테이너에 싱글턴으로 등록하면 그 하나를 앱 전체가
  공유한다. 등록 코드는 뒤의 설정 절에 있다."로 줄이면 된다(15챕터 44줄이 정적 파일
  미들웨어를 같은 방식으로 미룬다). 8줄이 줄고 절 구성은 그대로다.
- 그 밖에 `%O` 경로 제약 이야기가 596-604·836·868·914줄 네 곳에 나오는데, 뒤 셋은 각각
  확인 결과와 정리라 중복으로 보지 않는다.

### 17. 원서 오류 판단에 대한 의견 — 핸들러 접미사 (원서 p.183)

집필자 판단에 동의한다. 근거를 셋 적어 둔다.

- 13챕터 498줄이 `<대상><동작>Handler` 를 못박고 "14·15챕터가 이 규칙을 이어 쓴다"고 예고했다.
  14챕터가 규칙을 바꾸면 그 예고가 거짓이 되고, 15챕터 인계 문단(920줄)도 다시 써야 한다.
- 원서의 권유는 원서 사정에서 나온 것이다. 원서는 핸들러를 `Todos.fs` 의 `Handlers` 모듈에만
  두므로 부르는 자리가 늘 `Handlers.viewTodo` 다. 이 노트는 `Program.fs` 에 `hiveListHandler`·
  `hiveStatusHandler`·`notFoundHandler` 를 모듈 없이 최상위에 두고 있어, 접미사를 떼면 같은
  프로젝트 안에서 어떤 핸들러는 접미사가 있고 어떤 핸들러는 없는 상태가 된다.
- 원서 자신도 "I'll leave these as tasks for the reader"로 적용하지 않고 넘긴다. 따르지 않아도
  원서와 어긋나지 않는다.

430줄의 현재 서술("규칙이 챕터마다 흔들리는 것보다는 조금 긴 이름이 낫다")이면 충분하다.
굳이 보탤 것이 있다면 "원서는 핸들러를 한 모듈에만 두지만 이 노트는 `Program.fs` 쪽에도
핸들러가 있어 접미사를 떼면 규칙이 반쪽이 된다" 한 마디다.

### 18. 원서 p.180 의 두 `subRoute` 를 "우선순위가 불분명하다"고 적지 마라

696줄이 이 대목을 취향 문제로만 다루는 것이 옳다. 그대로 두어라. Giraffe 의 엔드포인트 라우팅은
목록 순서로 먼저 걸리는 것을 고르는 방식이 아니라 ASP.NET Core 에 엔드포인트를 등록하고 그쪽
우선순위 규칙에 맡긴다. `subRoute "/api/todo"` 아래의 `route ""` 는 템플릿 `/api/todo` 가 되고
`subRoute "/api"` 아래의 `route ""` 는 `/api` 가 되므로 두 템플릿이 겹치지 않는다. 순서를
바꿔도 결과가 같다. "우선순위가 불분명하다"는 서술을 넣으면 그것이 새 오류가 된다.

원서 p.181 의 `Project.fs`(`Program.fs` 오타)와 p.183 의 `subRoute "api/todo"`(앞 슬래시 누락,
p.180 은 `/api/todo`)도 확인했다. 둘 다 원서 오기가 맞지만 개념과 무관한 오타라 노트에서
언급하지 않는 지금 선택이 낫다. 언급한다면 46줄 근처에 한 문장으로 몰아 두는 편이 좋다.

---

## 확인 완료

집필자가 원서 오류로 판단한 것 — 전부 재확인했고 판단이 옳다.

- 원서 p.179 `member _.Update(todo) = data.TryUpdate(todo.Id, todo, data[todo.Id])` 는 실제 버그다.
  원서 코드를 그대로 옮겨 없는 키로 불러 확인했다.
  `System.Collections.Generic.KeyNotFoundException: The given key '...' was not present in the dictionary.`
  F# 은 인자를 왼쪽부터 평가하므로 `data[todo.Id]` 가 `TryUpdate` 에 닿기 전에 터진다. 없는 항목에
  PUT 을 보내면 410 이 아니라 500 이다. `TryUpdate` 자체는 없는 키에 예외 없이 `false` 를 돌려주는 것도
  확인했다(193줄 블록 실측 `false`). 196줄과 909줄 서술이 정확하다.
- 원서 p.184 의 목록 응답과 원서 자신의 `GetAll` 이 어긋난다. `data.Values |> Seq.toArray` 는 값만
  담은 배열이므로 `{"key":..., "value":...}` 모양이 나올 수 없다. 756줄의 진단이 정확하다.
- 원서가 410 Gone 을 고른 근거가 없다. 410 은 그 자원이 있었고 영구히 사라졌음을 아는 경우에
  쓰는 코드이므로 없는 id 일반에는 404 가 맞다. 548줄 판단이 정확하다.
- 파일 이름·모듈 이름·타입 이름이 원서에서 `TodoStore` 로 셋 다 겹치는 것도 원문 그대로다(46줄).

집필자가 실측한 것 — 전부 재확인했다.

- `System.Text.Json` 이 빠진 필드를 기본값으로 채워 `string` 필드에 `null` 이 들어온다.
  `Hive=<null> Frames=0 QueenSeen=true`, `isNull partial.Hive` 가 `true`. 336-337줄의
  "모델 바인딩 뒤에는 검증이 반드시 온다"가 8챕터와 정확히 연결된다(8챕터 273·370줄의
  "오류를 모아 한 번에" 방식이 `validate` 에 그대로 쓰였고, 실패 둘이 한 응답으로 나오는 것을
  845줄 출력이 보여 준다). `Result.bind` 사슬과의 대비도 8챕터 372·582줄과 일치한다.
  단 `bool` 필드의 한계는 빠져 있다(10번 항목).
- 판별 유니온은 역직렬화도 `NotSupportedException` 이다(`Option` 은 예외 — 7번 항목).
- 깨진 본문·빈 본문·타입 불일치가 모두 `JsonException` 한 종류다. 세 메시지가 주석과 글자까지 같다.
- `routef "/%O"` 가 만드는 경로 템플릿을 `TemplateEndpoint` 에서 꺼내 확인했다. 599줄의 문자열이
  실측값과 문자 단위로 같다. 허용하는 모양이 셋(하이픈 표기, 32자리, 22자리)인 것도 맞고,
  하이픈 없는 32자리로 요청해 같은 기록이 오는 것도 833줄 출력대로다.
- `Successful.CREATED` 가 콘텐츠 협상을 거친다. `Accept: text/plain` 으로 POST 하면
  201 + `text/plain; charset=utf-8` + 값의 문자열 표현이다(887줄과 일치).
- Giraffe 8 의 기본 XML 직렬화기가 매개변수 없는 생성자를 요구해 F# 레코드를 직렬화하지 못한다.
  `Accept: application/xml` → 500,
  `System.InvalidOperationException: <>f__AnonymousType...cannot be serialized because it does not have a parameterless constructor.`
  665줄의 인용이 정확하다.
- `TryRemove` 는 키 타입 주석이 없으면 `error FS0001` 이다.
  `이 식에는 'bool' 형식이 필요하지만 여기에서는 ''a * 'b' 형식이 지정되었습니다.`
  166줄 서술이 정확하다.

챕터 사이 연속성.

- 13챕터가 잡아 둔 설계 의도가 지켜졌다. 686-692줄의 `endpoints` 는 13챕터 487-493줄과 문자 단위로
  같다. 13챕터 497줄의 예고("`apiEndpoints` 안에서 동사별로 묶으면 되고 바깥 `endpoints` 는
  손대지 않는다")가 그대로 실현되었고, 늘어난 것은 `apiEndpoints` 안의
  `subRoute "/inspections" Inspections.inspectionEndpoints` 한 줄이다. 집필자 보고가 맞다.
- 13챕터에서 물려받은 나머지도 정확히 이어졌다. 프로젝트 이름·패키지 버전·`findHive` 의 대문자
  정규화(817줄 출력 `H-07`)·`notFoundHandler` 의 평문 404 와 JSON 404 의 구별(868줄)·
  `>=>` 와 `X-Apiary` 헤더·`configureApp` 의 순서 설명이 모두 13챕터 서술과 맞물린다.
- 15챕터에 물려준 것도 실제와 맞다. 920줄의 인계 문단과 15챕터 5줄의 도입 문단이 파일 넷·컴파일
  순서·도메인 타입 목록·`InspectionStore` 싱글턴 등록·라우팅 세 층에서 한 항목씩 대응한다.
  `Views.fs` 를 `Program.fs` 앞에 넣어야 한다는 예고(920줄)가 15챕터 25-31줄의 `.fsproj` 와
  일치하고, `p [ _class "lede" ]` 의 CSS 가 없다는 지적이 15챕터 104줄에서 채워지며,
  `UseStaticFiles` 예고가 15챕터 44줄과 맞는다. View Engine 에는 직렬화 제약이 없다는 예고도
  15챕터 34·682줄과 같다.
- 4챕터의 컴파일 순서 서술과 어긋나지 않는다. `.fsproj` 의 `<Compile Include=... />` 순서가 곧
  컴파일 순서(4챕터 61줄), 정의가 사용보다 앞(4챕터 113줄), `[<EntryPoint>]` 는 마지막 파일
  (13챕터 41줄)이 모두 그대로 쓰였다. 스크립트를 중첩 모듈로 본뜨는 기법도 4챕터 154·271줄이
  이미 쓴 것과 같다. 다만 8번·9번 항목의 두 곳을 다듬어야 한다.

코드와 시그니처.

- 실행 단위 3개 전부 통과. 세 스크립트를 따로 돌려 주석의 기대 출력과 실제 출력을 한 줄씩
  대조했고 어긋난 곳이 없다. `send` 의 `%-6s %-23s` 폭도 `/api/inspections/<id-n>` 23자와 맞아
  열이 어긋나지 않는다.
- FSI 실측 주석 전부 일치. `#load` 로 모듈을 올려 확인했다. `findHive`·`InspectionStore` 의 다섯
  멤버(FSI 가 찍는 알파벳 순까지)·`toPayload` 의 익명 레코드 필드 순서·`validate`·`bindRequest`·
  다섯 핸들러·`inspectionEndpoints`·`apiSummaryHandler`·`apiEndpoints`·`endpoints`·
  `configureServices`·`configureApp` 이 모두 주석대로다. 126줄이 예고한 접두 제거 방식도 맞다.
- `id` 배정이 옳다. `id` 없는 두 블록(282-285, 289-291)은 완전한 코드가 아닌 조각이라 검증에서
  빼는 것이 맞고, 그 밖에 완전한 코드인데 `id` 가 빠진 블록은 없다. 오류 코드를 적어 둔 `id` 없는
  블록은 이 챕터에 없다(FS0001·FS0999 는 산문에만 있고 둘 다 실측으로 확인했다).
- 익명 레코드 필드가 알파벳 순으로 정렬되고 응답 JSON 키 순서도 같다(394줄, 출력
  `frames,hive,id,queenSeen,recordedAt`).
- 개념 서술이 정확한 곳. `Save` 하나로 추가와 갱신을 겸해 저장소가 `bool` 을 돌려줄 일이 없게
  만든 설계(274줄), `member _.TryFind(InspectionId key)` 로 매개변수 자리에서 껍데기를 벗기는
  것(273줄), `Option` 을 상태 코드로 옮기는 일을 핸들러에만 맡긴 것(460·567줄),
  `bindRequest` 가 예외를 `Result` 로 바꾸는 경계라는 것(481줄), `task` 안의 `try ... with` 가
  `let!` 이 기다리는 동안 난 예외까지 잡는다는 것(479줄), `:? JsonException` 이 3챕터의 타입 테스트
  패턴이라는 것(480줄, 3챕터 240줄과 일치), 목록 핸들러에 `task` 가 없는 이유(457줄 —
  `WriteJsonAsync` 가 이미 `Task<HttpContext option>` 을 돌려준다), `{ existing with ... }` 가
  `Id` 와 `RecordedAt` 을 보존하는 것(547줄, 843줄 출력으로 확인), `Successful.NO_CONTENT` 가
  인자 없는 값이라는 것(568줄, 실측 `HttpHandler`), 서비스 로케이션의 테스트 약점과 대안
  (293줄), DI 등록 순서는 상관없고 미들웨어 순서는 상관있다는 것(722줄)이 모두 맞다.
