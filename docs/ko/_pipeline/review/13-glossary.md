# 13챕터 용어 후보 (F# 전문가 검수, 후보 모드)

`docs/ko/GLOSSARY.md` 는 읽기만 했고 편집하지 않았다(다른 챕터 전문가와 동시 작업 중).
아래 행을 알파벳 순 위치에 그대로 삽입하면 된다.

이 챕터가 웹 용어를 처음 도입하므로 신규 행이 많다. 14·15챕터 노트가 이미 아래 표기를
따르고 있는지 `grep` 으로 확인했고, 어긋나는 곳은 마지막 절에 챕터별로 적었다.

## 확정 제안 (그대로 삽입)

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| anonymous record | 익명 레코드 | `{\| ... \|}`. 이름 없는 레코드를 그 자리에서 만드는 것. 필드는 이름의 서수 순으로 정렬되고 적은 순서는 타입에 영향을 주지 않는다(실측: `{\| Hive = ...; Frames = ... \|} = {\| Frames = ...; Hive = ... \|}` 이 `true`). 기확정 `anonymous function`→익명 함수 와 계열을 맞춘다. "무명 레코드"·"익명 기록" 쓰지 않는다. 13챕터 본론 |
| assignment operator | 할당 연산자 | `<-`. MS ko 표기와 일치. `=`(비교)와 갈라 쓴다. 기확정 `mutable`(가변)과 짝으로 쓰인다. "대입 연산자" 쓰지 않는다. 13챕터 |
| delegate | 델리게이트 | .NET 의 함수 타입. MS ko 는 "대리자"이나 커뮤니티 통용 음차를 택한다. F# 함수는 델리게이트가 아니지만 메서드 호출 자리에서는 대상 델리게이트 타입이 정해져 있으면 컴파일러가 람다를 자동으로 변환한다 — 변환이 안 되는 것은 매개변수 타입이 `System.Delegate` 처럼 추상 기반 타입이어서 어느 델리게이트를 만들지 정할 수 없는 경우다(실측: `app.MapGet("/", fun () -> "x")` 는 `RequestDelegate` 오버로드가 잡혀 오류 FS0001). 13챕터에만 나온다 |
| dependency injection | 의존성 주입 | MS ko 는 "종속성 주입"이나 커뮤니티 통용을 택한다. 담는 그릇은 "의존성 주입 컨테이너"이고 문맥이 분명하면 "컨테이너"로 줄인다. 약어 DI 는 쓰지 않는다. 13챕터 도입, 14챕터 본론 |
| endpoint | 엔드포인트 | 음차 고정. HTTP 메서드와 경로에 핸들러를 붙인 한 항목. Giraffe 에서는 값이고 타입은 `Endpoint list` 다. "종점"·"단말" 쓰지 않는다 |
| endpoint routing | 엔드포인트 라우팅 | ASP.NET Core 의 라우팅 API 에 얹혀 동작하는 방식. Giraffe 5 부터 쓸 수 있다(실측: `EndpointRouting` 이 Giraffe 5.0.0 어셈블리에 있고 4.1.0 에는 없다). `Giraffe.EndpointRouting` 모듈 이름은 원어 백틱 |
| framework reference | 프레임워크 참조 | `.nuspec`/`.fsproj` 의 `FrameworkReference`. 패키지가 공유 프레임워크 전체를 요구하는 표기이며 `dotnet fsi` 의 `#r "nuget: ..."` 은 이 요구를 채워 주지 않는다(실측: `open Microsoft.AspNetCore.Builder` 가 오류 FS0039). MS ko 표기와 일치 |
| handler | 핸들러 | 음차 고정. 요청 하나에 응답을 만드는 함수. 타입 이름 `HttpHandler` 는 원어 백틱으로 쓰고, 일반명사로 가리킬 때만 "핸들러"로 쓴다. "처리기"·"핸들러 함수" 쓰지 않는다 |
| header (HTTP) | 헤더 | HTTP 요청·응답의 머리 부분 항목. 기확정 `header row`(헤더 줄, 구분자 텍스트의 첫 줄)과 낱말이 겹치므로 6챕터 계열과 같은 문장에서 섞어 쓰지 않는다. 웹 맥락에서는 한정어 없이 "헤더"로 쓴다. MS ko 표기와 일치 |
| host | 호스트 | 음차 고정. 앱을 띄워 요청을 받는 껍데기(`WebApplication`). "숙주"·"호스팅" 쓰지 않는다. 동작을 가리킬 때만 "호스팅" 허용 |
| HTTP method | HTTP 메서드 | `GET`·`POST`·`PUT`·`DELETE`. 원서는 verb 라고 부르지만 노트는 MS ko 와 같은 "HTTP 메서드"로 통일한다. "동사"·"HTTP 동사" 쓰지 않는다 |
| `HttpContext` | `HttpContext` | 타입 이름은 번역하지 않는다. 산문에서 풀어 쓸 때는 "요청 컨텍스트". "요청 맥락"은 쓰지 않는다 — 기확정 `effect` 행이 "성패나 비동기 같은 맥락"으로 "맥락"을 이미 쓰고 있어 12챕터를 읽은 독자에게 겹친다. 웹 쪽은 정착된 음차 "컨텍스트"로 갈라 쓴다 |
| `HttpFunc` | `HttpFunc` | 타입 이름은 번역하지 않는다. `HttpContext -> HttpFuncResult` 의 타입 약어(실측 확인) |
| `HttpFuncResult` | `HttpFuncResult` | 타입 이름은 번역하지 않는다. `Task<HttpContext option>` 의 타입 약어(실측 확인). `None` 은 "이 핸들러가 이 요청을 처리하지 않았다"는 뜻이다 |
| `HttpHandler` | `HttpHandler` | 타입 이름은 번역하지 않는다. `HttpFunc -> HttpContext -> HttpFuncResult` 의 타입 약어. FSI 는 약어를 펼쳐 찍기도 하고 `HttpHandler` 로 찍기도 한다 — 람다로 적은 값은 펼쳐지고 함수를 조립해 만든 값은 약어 이름이 남는다(실측) |
| launch profile | 실행 프로필 | `Properties/launchSettings.json` 의 `profiles` 항목. `dotnet run` 은 첫 프로필을 쓰고 `--launch-profile <이름>` 으로 고른다. MS ko 는 "시작 프로필"도 쓰나 노트는 "실행 프로필"로 고정한다. 기확정 `template`(템플릿)이 이 파일을 만든다 |
| middleware | 미들웨어 | 음차 고정. 요청이 차례로 지나며 각자 일을 하는 조각. "중간 계층"·"미들웨어 계층" 쓰지 않는다 |
| middleware pipeline | 미들웨어 파이프라인 | `configureApp` 이 정하는 미들웨어의 순서. 기확정 `pipeline`(파이프라인, `\|>` 로 값을 흘려보낸 코드 형태)과 가리키는 것이 다르므로 웹 챕터에서는 반드시 온낱말 "미들웨어 파이프라인"으로 적고 "파이프라인"으로 줄이지 않는다(기확정 `effect`/`side effect`, `tail`/`tail recursion`, `overflow`/`stack overflow` 와 같은 갈라 쓰기 규칙). 함수 파이프라인과 다른 것이라는 한 문장을 13챕터에서 한 번 붙인다. "요청 파이프라인"은 같은 것을 가리키는 다른 이름이므로 비고로만 남기고 본문에는 쓰지 않는다 |
| query string | 쿼리 문자열 | `?code=H-07` 의 `code=H-07` 부분. MS ko 표기와 일치. 원서 표기는 한 낱말 querystring 이다. "쿼리스트링"·"질의 문자열" 쓰지 않는다. `route parameter` 와 다른 것이며 원서 p.171 이 이 둘을 뒤바꿔 적었다 |
| route | 경로 | HTTP 요청이 가리키는 자리. `route` 함수 이름은 원어 백틱. `path` 도 "경로"로 옮기므로 한 문장에서 둘을 구분해야 할 때는 "요청 경로"/"파일 경로"처럼 한정어를 붙인다. "라우트" 쓰지 않는다 |
| route parameter | 경로 매개변수 | `routef "/hives/%s"` 의 `%s` 자리로 핸들러에 넘어오는 값. MS ko 표기와 일치. 기확정 `parameter`(매개변수) 계열. 쿼리 문자열 항목이 아니다 |
| routing | 라우팅 | 음차 고정. MS ko 표기와 일치. "경로 배정"·"라우트 지정" 쓰지 않는다 |
| serialization | 직렬화 | 값을 JSON 같은 형식의 텍스트로 바꾸는 것. 반대는 "역직렬화"(deserialization). MS ko 는 "직렬화"·"역직렬화"와 함께 "직렬 변환"도 쓰나 노트는 "직렬화"로 고정한다 |
| serializer | 직렬화기 | 직렬화를 하는 객체. MS ko 는 "직렬 변환기"이나 커뮤니티 통용을 택한다. Giraffe 는 `Json.ISerializer` 로 갈아 끼울 수 있고 타입·인터페이스 이름은 원어 백틱으로 쓴다. "시리얼라이저" 쓰지 않는다 |
| shared framework | 공유 프레임워크 | 여러 앱이 함께 쓰는 런타임 어셈블리 묶음. `Microsoft.NETCore.App` 과 `Microsoft.AspNetCore.App` 이 있고 `dotnet --list-runtimes` 로 확인한다. MS ko 표기와 일치. 기확정 `target framework`(대상 프레임워크)·`runtime`(런타임)과 다른 것이다 — 대상 프레임워크는 `.fsproj` 에 적는 컴파일 대상이고, 공유 프레임워크는 디스크에 설치된 어셈블리 묶음이다 |
| status code | 상태 코드 | HTTP 응답의 숫자 코드. MS ko 표기와 일치. "상태 번호" 쓰지 않는다. 숫자는 그대로 적는다(200, 404, 500) |
| `subRoute` | `subRoute` | 함수 이름은 번역하지 않는다. 접두 경로를 한 번만 적고 그 아래 `Endpoint list` 를 묶는다. 절 제목 등에서 개념을 우리말로 가리킬 때는 "하위 경로"로 쓰고 "서브라우트" 쓰지 않는다 |
| view | 뷰 | 음차 고정. 화면을 만드는 값 또는 그 값을 만드는 함수. 이름 규칙은 `<이름>View`. "화면"은 사람이 보는 결과를 가리킬 때만 쓰고 코드 쪽은 "뷰"로 쓴다 |
| View Engine | View Engine | `Giraffe.ViewEngine` 은 제품 이름이므로 원어를 그대로 쓴다. 일반명사로 다른 뷰 엔진과 견줄 때만 "뷰 엔진". 요소 함수의 결과 타입은 `XmlNode` 하나이며 타입 이름은 원어 백틱 |
| web application | 웹 애플리케이션 | 줄여 "웹 앱"으로 쓰지 않는다. 한 챕터 안에서 두 표기를 섞지 않는다 |
| web framework | 웹 프레임워크 | Giraffe 를 가리킬 때 쓴다. 제품 이름 Giraffe·ASP.NET Core 는 번역하지 않는다 |
| `>=>` | `>=>` | 연산자는 번역하지 않고, 한국어 이름도 붙이지 않는다. 서술할 때는 "핸들러를 이어 붙이는 `>=>`" 처럼 풀어 쓴다. Giraffe 의 `compose` 에 붙은 연산자이고, `h1 >=> h2` 는 `h2` 를 `h1` 의 다음 핸들러로 넘기므로 `h1` 이 다음을 부르지 않으면 `h2` 는 실행되지 않는다. 기확정 `function composition operator`(`>>`, 함수 합성 연산자)와 다른 것이므로 "함수 합성 연산자"라고 부르지 않는다. 커뮤니티의 "fish operator"·"피시 연산자"·"어부 연산자" 쓰지 않는다 |

정렬 위치 확인: `>=>` 는 백틱을 벗기면 기호로 시작하므로 표 맨 앞(`abstract class` 앞)에 둔다.
기확정 표에 기호로 시작하는 행이 없어 판례가 없다. 머리말의 정렬 규칙에 기호 처리가 없으므로
병합자가 `bang (!)` 행의 판례(영어 칸을 `bang (!)` 로 적어 `b` 자리에 둔 것)를 따라
영어 칸을 `compose operator (>=>)` 로 적어 `c` 자리에 두는 편이 표가 흔들리지 않는다.
둘 중 어느 쪽이든 하나로 정하면 되고, 노트 본문 표기(`>=>`)는 어느 쪽이든 그대로다.

## 기확정 항목 변경 제안

없다. 기확정 `pipeline`(파이프라인) 행은 손대지 않고 `middleware pipeline` 을 새 행으로 갈라 두었다.
기확정 `header row` 행도 손대지 않고 `header (HTTP)` 를 새 행으로 두었다.

## 이 표기를 적용하려면 고쳐야 할 노트 (챕터별)

13챕터 (`docs/ko/13-web-with-giraffe.md`)
- `HttpContext` 풀이 3곳: 287줄 "현재 요청 맥락" → "현재 요청 컨텍스트", 344줄 "요청 맥락을 넘기는 합성"
  (이 문장은 검수 보고서에서 따로 교체를 지시했다), 367줄 "맥락에서 직접 꺼내야 한다" →
  "`HttpContext` 에서 직접 꺼내야 한다".
- 497줄 "동사별로 묶으면" → "메서드별로 묶으면"(`HTTP method` 행).
- 9줄 "최소 웹 앱" → "최소 웹 애플리케이션"(`web application` 행).
- `middleware pipeline` 도입: 66줄과 525줄이 "요청이 지나갈 미들웨어 순서"·"요청이 지나는 길"로
  풀어 쓰고 있다. 66줄에 용어를 한 번 붙이고 함수 파이프라인과 다르다는 것을 함께 적는다.
  교체 문장은 검수 보고서에 있다.

14챕터 (`docs/ko/14-api-with-giraffe.md`)
- 표기 어긋남 없음. "의존성 주입"·"미들웨어"·"엔드포인트"·"상태 코드"·"헤더"·"직렬화기"·"핸들러"·
  "익명 레코드"가 모두 위 표와 일치한다(`grep` 확인).
- "요청이 지나는 길"이 1곳 있다. 그대로 두어도 되고 미들웨어 파이프라인으로 바꿔도 된다.

15챕터 (`docs/ko/15-web-pages-with-giraffe.md`)
- "View Engine" 8곳과 "뷰 엔진" 2곳이 섞여 있다. `View Engine` 행 규칙대로,
  `Giraffe.ViewEngine` 을 가리키는 자리는 "View Engine", 다른 뷰 엔진과 견주는 자리만 "뷰 엔진"이다.
  15챕터 검수자에게 넘긴다.
- "요청이 지나는 길"이 2곳 있다. 위와 같다.

## 다른 챕터 소관으로 남긴 용어

14챕터가 처음 쓰는 것: `model binding`(모델 바인딩), `DTO`, `singleton`(싱글턴),
`ConcurrentDictionary`, `deserialization` 의 실제 쓰임.
15챕터가 처음 쓰는 것: `static file`(정적 파일), `layout`(레이아웃), `partial view`(부분 뷰),
`wwwroot`, `list comprehension`(리스트 컴프리헨션 — 5챕터 소관일 수 있다).
이 표에는 넣지 않았다. 13챕터에 나오지 않기 때문이다.
