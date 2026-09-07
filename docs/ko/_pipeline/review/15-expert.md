# 15챕터 (Creating Web Pages with Giraffe) F# 전문가 검수 보고서

검수 대상: `docs/ko/15-web-pages-with-giraffe.md` (707줄, 실행 단위 3개)
참고 원문: `.cache/src/15-web-pages-with-giraffe.txt` (원서 pp.185-191),
`.cache/src/18-appendix-2-css-and-js.txt` (원서 pp.197-201)
연속성 대조: `docs/ko/13-web-with-giraffe.md`, `docs/ko/14-api-with-giraffe.md`
환경: .NET SDK 10.0.111, ASP.NET Core 공유 프레임워크 10.0.11, `Giraffe` 8.3.0,
`Giraffe.ViewEngine` 1.4.0

게이트 결과: `verify-examples.sh` 3개 단위 전부 PASS, `check-note.sh` OK.
세 단위를 따로 실행해 주석의 기대 출력과 실제 출력을 한 줄씩 대조했고 전부 일치했다.
시그니처는 FSI 표준 입력 모드로 다시 뽑아 대조했다(아래 `확인 완료`).
집필자가 보고한 원서 오류 5건과 실측 3건은 전부 다시 확인했고, 그 가운데 하나가 사실과 달랐다.

줄 번호는 참고용이다. 적용할 때는 STYLE.md 의 절차대로 문자열로 대상을 특정하라.

## 수정 필요 (기술 오류)

- [15-web-pages-with-giraffe.md:326] `타입 주석 (inspections: Inspection list) 를 지우면 FSI 가
  이 함수를 inspections: Inspection seq -> XmlNode 로 잡는다 ... 주석을 남긴 이유는 List.length 를
  쓰기 때문이고` — 틀렸다. 앞뒤 두 주장이 서로를 무너뜨린다. 본문에 `List.length inspections` 가
  있으므로 그 한 줄이 이미 매개변수를 `'a list` 로 못박는다. 주석을 지우고 실측하면 그대로
  `inspections: Inspection list -> XmlNode` 다. `seq` 로 잡히는 것은 `List.length` 를 지우거나
  `Seq.length` 로 바꿀 때이고, 그때 비로소 `for ... in` 의 열거 가능성 제약만 남는다(둘 다 실측).
  지금 문장은 "이 코드에서 주석이 타입을 좁힌다" 는 잘못된 인상을 주고, 자동 일반화를 배우는
  독자가 제약의 출처를 `for ... in` 으로 오인하게 만든다.
  교체 불릿:
  `이 함수의 타입 주석은 없어도 같다. 본문의 List.length 가 매개변수를 리스트로 못박기 때문에 주석을 지워도 FSI 가 inspections: Inspection list -> XmlNode 로 잡는다. 반대로 건수를 세는 줄을 빼거나 Seq.length 로 바꾸면 for ... in 이 요구하는 것은 열거 가능성뿐이라 inspections: Inspection seq -> XmlNode 가 된다. 제약은 컴프리헨션이 아니라 함께 쓴 함수가 정한다.`

- [15-web-pages-with-giraffe.md:680] 정리 절의 같은 오류 —
  `타입 주석을 지우면 for ... in 이 열거 가능성만 요구하므로 매개변수가 seq 로 잡힌다`.
  교체 문장:
  `for ... in 이 요구하는 것은 열거 가능성뿐이므로 컴프리헨션만 있으면 매개변수가 seq 로 잡히고, 같은 본문에서 List.length 를 부르면 그쪽이 리스트로 못박는다.`

- [15-web-pages-with-giraffe.md:451] `negotiate 의 기본 규칙에는 text/html 이 없어 브라우저 요청이
  406 이 된다` — 결론이 틀렸다. 실측하면 세 갈래로 갈린다.
  `Accept: text/html` 만 보내면 406(`text/html is unacceptable by the server.`)이지만,
  브라우저가 실제로 보내는
  `text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8` 은
  품질값 0.9 의 `application/xml` 규칙에 걸려 XML 직렬화로 가고, 14챕터가 이미 적어 둔
  `System.InvalidOperationException: ... cannot be serialized because it does not have a
  parameterless constructor.` 로 500 이 된다. `text/html,*/*;q=0.8` 이면 `*/*` 규칙으로 200 JSON 이다.
  화면과 API 를 경로로 가르자는 결론은 그대로 두고 이유만 바꿔라.
  교체 문장:
  `14챕터에서 본 내용 협상으로 한 경로에 둘을 겹칠 수도 있지만, negotiate 의 기본 규칙에는 text/html 이 없어 HTML 을 골라 줄 방법이 없다. Accept: text/html 만 보내면 406 이고, 브라우저가 보내는 긴 Accept 헤더는 품질값 0.9 의 application/xml 규칙에 걸려 14챕터에서 본 XML 직렬화 실패로 500 이 된다. 화면과 API 를 경로로 갈라 두는 편이 단순하다.`

- [15-web-pages-with-giraffe.md:48] `builder.WebHost.UseWebRoot "public" 을 부르면 된다` — 틀렸다.
  이 노트와 원서가 쓰는 `WebApplication.CreateBuilder` 호스팅 모델에서는 그 호출이 예외를 던진다.
  실측 메시지: `System.NotSupportedException: The web root changed from ".../wwwroot/" to
  ".../public/". Changing the host configuration using WebApplicationBuilder.WebHost is not
  supported. Use WebApplication.CreateBuilder(WebApplicationOptions) instead.`
  (예외를 던지는 자리는 `ConfigureWebHostBuilder.UseSetting` 이다.) `UseWebRoot` 가 통하는 것은
  옛 `IWebHostBuilder` 조립 방식이다. 덧붙여 `builder.Environment.WebRootPath <- ...` 도 답이
  아니다 — 실측하면 `app.Environment.WebRootPath` 값만 바뀌고 정적 파일은 여전히 `wwwroot/` 에서
  나간다. 통하는 방법은 옵션으로 넘기는 쪽 하나다.
  교체 문장(다음 문장의 `뒤의 검증 코드가 이 방법을 쓰는데` 도 가리키는 것이 하나뿐이 되어 명확해진다):
  `웹 루트를 wwwroot 가 아닌 곳으로 바꾸려면 호스트를 만들 때 WebApplicationOptions(WebRootPath = "public") 처럼 옵션으로 넘긴다. 빌더를 만든 뒤에 builder.WebHost.UseWebRoot 로 바꾸려 하면 System.NotSupportedException 이 난다.`

- [15-web-pages-with-giraffe.md:666] `같은 경로에 파일과 엔드포인트가 둘 다 있으면 먼저 등록된
  미들웨어가 응답한다. 요청이 지나는 길을 앞에서부터 순서대로 밟고, 응답을 쓴 미들웨어에서
  멈추기 때문이다.` — 기제 설명이 틀렸다. `UseRouting()` 은 응답을 쓰지 않는다. 엔드포인트를
  고르기만 하고, 실제로 부르는 것은 `UseGiraffe(endpoints)` 가 넣는 뒤쪽 미들웨어다. 그러므로
  `라우팅 먼저` 순서에서 정적 파일 미들웨어는 엔드포인트 미들웨어보다 앞에 있는데도 응답하지
  않는다. 실제 이유는 정적 파일 미들웨어가 이미 골라진 엔드포인트가 있으면(`HttpContext.GetEndpoint()`
  가 `null` 이 아니면) 파일을 내보내지 않고 그냥 넘기기 때문이다. 같은 `라우팅 먼저` 순서에서
  엔드포인트 경로를 `/other` 로 바꿔 겹치지 않게 하면 정적 파일이 200 `text/css` 로 응답한다(실측).
  교체 불릿:
  `순서가 결과를 갈라 놓는 이유는 UseRouting 이 응답을 쓰지 않고 엔드포인트만 골라 둔다는 데 있다. 정적 파일 미들웨어는 이미 골라진 엔드포인트가 있으면 파일을 내보내지 않고 요청을 그냥 넘긴다. 그래서 라우팅을 먼저 켜면 경로가 겹치는 순간 엔드포인트가 이기고, 정적 파일을 먼저 두면 라우팅에 닿기 전에 파일로 응답이 끝난다. 겹치지 않는 경로라면 어느 순서든 파일이 나간다.`

- [15-web-pages-with-giraffe.md:196] `새로 든 것은 Microsoft.AspNetCore.StaticFiles 와
  Microsoft.Extensions.FileProviders.Abstractions 다. 앞의 것이 UseStaticFiles 확장 메서드를,
  뒤의 것이 그 미들웨어가 파일을 찾는 데 쓰는 타입을 담고 있다.` — 뒤쪽이 사실과 다르다.
  `#r` 목록과 복사 목록에서 `Microsoft.Extensions.FileProviders.Abstractions` 두 줄을 지우고
  실행 단위 전체를 돌려 보면 경고 없이 통과하고 응답도 한 글자도 다르지 않다(실측).
  참조가 필요한 것은 `Microsoft.AspNetCore.StaticFiles` 뿐이고, 그 줄을 지우면
  `error FS0039: 'IApplicationBuilder' 형식은 'UseStaticFiles' 필드, 생성자 또는 멤버를
  정의하지 않습니다.` 가 난다(실측). 실행 중에 필요한 어셈블리는 준비 코드의 `add_Resolving`
  훅이 공유 프레임워크에서 찾아 주므로 `#r` 이 필요 없다.
  고치는 방법 둘 중 하나를 골라라. (1) `#r` 과 복사 목록에서 그 어셈블리를 빼고 불릿을
  `새로 든 것은 Microsoft.AspNetCore.StaticFiles 하나다. UseStaticFiles 확장 메서드가 여기 들어 있고, 이 줄을 빼면 error FS0039 가 난다. 프로젝트에서는 프레임워크 참조에 들어 있어 적을 일이 없다.`
  로 바꾼다. (2) 두 줄을 남기려면 불릿에서 필요하다는 서술을 지우고 "실행 중에 쓰이는
  어셈블리를 미리 챙겨 둔 것이고 빼도 돈다" 로 적는다. (1) 을 권한다.

- [15-web-pages-with-giraffe.md:625] `마지막 줄이 14챕터의 API 다. 화면을 더하는 동안 JSON 응답은
  그대로다.` — 자기모순이다. 바로 위 코드 주석이 다섯 핸들러를 하나로 줄였다고 밝혔고, 그
  축약본은 익명 레코드 `{| Hive = code; Frames = item.Frames |}` 를 내보내므로 응답이
  `[{"frames":8,"hive":"H-07"}, ...]` 로 필드가 둘이다. 14챕터의 실제 목록 응답은 `toPayload` 가
  만드는 다섯 필드다(`{"frames":9,"hive":"H-07","id":"...","queenSeen":true,"recordedAt":"..."}` —
  14챕터 노트 825줄). "그대로다" 를 읽은 독자는 14챕터의 API 가 바뀐 줄로 오해한다.
  교체 문장:
  `마지막 줄이 14챕터의 목록 경로다. 화면을 더하는 동안 API 는 손대지 않았다. 다만 이 단위는 핸들러를 축약했으므로 필드가 둘뿐이고, 프로젝트에서는 14챕터의 toPayload 가 만든 다섯 필드가 그대로 나간다.`

- [15-web-pages-with-giraffe.md:480] `반환 타입이 unit -> InspectionStore 인 것에 뜻이 있다` —
  용어가 틀렸다. 이 함수의 반환 타입은 `InspectionStore` 이고 `unit -> InspectionStore` 는
  시그니처다. 시그니처를 반환 타입이라 부르면 앞 챕터들이 세워 둔 "시그니처 읽는 법" 이 흔들린다.
  교체 문장 앞머리:
  `시그니처가 unit -> InspectionStore 인 것에 뜻이 있다.`

- [15-web-pages-with-giraffe.md:128] `자식 자리든 특성 값이든 str 과 특성 함수를 지나면 <·>·&·" 가 문자 참조로 바뀐다` — 목록이 하나 빠졌다. 홑따옴표도 바뀐다. 노트 자신의 출력이
  `&#39;` 를 보여 주고 있으므로(130-141줄 블록의 `alert(&#39;!&#39;)` 출력) 본문과 출력이 어긋난다.
  `<`·`>`·`&`·`"`·`'` 로 고쳐라. 정리 절의 같은 문장(681줄)도 함께 고쳐야 한다.

## 개선 권장

- [15-web-pages-with-giraffe.md:422] 축약 범위를 적은 주석이 실제보다 좁다.
  `14챕터의 API 핸들러 다섯 개 가운데 목록 하나만 남겼다` — 14챕터의 API 핸들러는 다섯이 아니다.
  점검 기록 핸들러 다섯 개에 요약 핸들러와 벌통 핸들러 둘이 더 있어 여덟이고, 이 단위는 그 셋도
  함께 뺐다. 게다가 `subRoute "/inspections" Inspections.inspectionEndpoints` 한 층이
  `route "/inspections"` 로 접혀 있어 바로 앞 산문의 `/api 아래는 손대지 않는다` 와도 어긋나 보인다.
  주석 교체:
  `14챕터의 점검 기록 핸들러 다섯 개 가운데 목록 하나만 남기고, 요약·벌통 핸들러와 subRoute "/inspections" 한 층도 접었다. 화면 쪽에 집중하기 위한 축약이고 프로젝트에서는 Inspections.fs 의 다섯 개와 세 층 라우팅이 그대로 있다`
  이 한 줄만 고치면 축약 자체는 학습에 문제가 없다(판단 근거는 `확인 완료` 참조).

- [15-web-pages-with-giraffe.md:576-596] HTML 응답 검사에 `<!DOCTYPE html>` 이 빠졌다.
  105줄과 391줄이 "문서로 내보낼 때는 `htmlDocument` 를 쓰거나 서버에서는 `htmlView` 가 알아서
  붙인다" 고 적었는데 그 주장만 검사되지 않는다. 실측하면 응답 본문은
  `<!DOCTYPE html>\n<html lang="ko">` 로 시작한다. 검사 한 줄을 앞에 넣어라.
  `check "문서 선언" "<!DOCTYPE html>\n<html lang=\"ko\">" indexBody`
  기대 출력 주석에도 `//   true  문서 선언` 한 줄을 같은 자리에 넣어야 한다.

- [15-web-pages-with-giraffe.md:598] 문자열 조각 검사의 한계를 한 줄 적어 두면 좋다.
  `body.Contains` 는 조각이 있는지만 보므로 항목 순서, 중첩 구조, 중복 출력은 잡히지 않는다.
  예를 들어 부분 뷰를 `List.map` 으로 두 번 붙여 항목이 여섯 개가 되어도 일곱 항목 모두 통과한다.
  구조와 순서는 `15-view` 단위가 문서 전체를 문자열로 찍어 대조하는 쪽이 잡는다. 두 단위가
  역할을 나눠 맡는다는 문장을 검사 뒤 불릿에 한 줄 더하면 독자가 검사의 성격을 오해하지 않는다.
  더 조이려면 서버 쪽에도 항목이 이웃해 있는지 보는 검사 한 줄을 넣을 수 있다. 아래 조각은
  첫 항목이 끝나고 곧바로 H-11 항목이 오는지를 보므로 순서와 중첩을 함께 잡고, 문화권에 따라
  달라지는 표시용 시각을 담지 않는다(실측으로 `true` 를 확인했다).
  `check "항목 순서" "</time></li><li><span class=\"code\">H-11</span>" boardBody`

- [15-web-pages-with-giraffe.md:290] `time [ _datetime (inspection.RecordedAt.ToString "s") ]` 는
  표본이 `DateTimeKind.Utc` 인데 특성 값에 시간대 표시가 없다. `s` 형식은 오프셋을 버리므로
  브라우저는 `2026-05-17T09:00:00` 을 현지 시각으로 읽는다. 14챕터의 `toPayload` 는 같은 값을
  `"yyyy-MM-ddTHH:mm:ssZ"` 로 내보내므로 두 챕터가 같은 기록을 다르게 표현하는 셈이다.
  `_datetime (inspection.RecordedAt.ToString "yyyy-MM-ddTHH:mm:ssZ")` 로 맞추면 된다(형식 문자열의
  `Z` 는 리터럴이라 그대로 붙는다 — 14챕터의 출력이 그 근거다). 두 실행 단위에 같은 코드가 있고,
  기대 출력 주석의 `datetime="2026-..."` 다섯 자리(361·363·384·385·386줄)와 588줄의 검사 조각도
  함께 고쳐야 한다. `15-view` 단위의 표본도 `DateTimeKind.Utc` 로 맞춰야 표기와 값이 어긋나지 않는다.
  고치지 않겠다면
  "표시용 형식이라 시간대는 담지 않았다" 를 한 줄 적어 두는 편이 낫다.

- [15-web-pages-with-giraffe.md:291] `RecordedAt.ToString "MM-dd HH:mm"` 의 결과가 문화권에 따라
  달라진다. 사용자 지정 형식의 `:` 는 문화권의 시간 구분 기호이므로 `fi-FI` 에서는 `05-17 09.00`
  이 나온다(실측). 노트의 기대 출력은 그런 로캘의 독자에게 어긋난다. `"s"` 는 불변 형식이라
  문제가 없다. 표시용 한 줄만 `.ToString("MM-dd HH:mm", CultureInfo.InvariantCulture)` 로 바꾸고
  `open System.Globalization` 을 더하면 출력이 못박인다. 두 실행 단위(`15-view`, `15-server`)에
  같은 코드가 있으므로 함께 고쳐야 한다.

- [15-web-pages-with-giraffe.md:39] 부록 2 를 가리키는 방식은 적절하지만(판단은 `확인 완료`),
  원서 부록 코드가 원서 뷰의 이름에 묶여 있다는 한 줄이 빠졌다. 부록 2 의 JavaScript 는
  `myUL`·`myInput` 이라는 id 와 `close`·`checked` 라는 클래스를, CSS 는 `header`·`addBtn`·`checked`
  를 그대로 찾는다. 원서를 따라 실습하면서 요소 이름만 바꾸면 화면이 조용히 어긋난다.
  40줄 불릿 끝에 한 문장을 더하면 충분하다.
  `부록 2 의 코드는 원서 뷰의 id 와 클래스 이름(myUL·myInput·checked·close·addBtn)을 그대로 찾으므로, 뷰에서 그 이름을 바꾸면 CSS 와 JavaScript 도 같이 바꿔야 한다.`

- 집필자가 보고한 원서 어긋남 4번(뷰 문구와 클래스가 두 목록 사이에서 달라진다)이 노트에 없다.
  원문을 다시 확인했고 사실이다 — 원서 p.188 의 뷰는 `str "My To Do List"` 인데 p.190 의 뷰는
  `str "My ToDo List"` 이고, p.188 은 `li [] [ str "Read a book" ]`·
  `li [ _class "checked" ] [ str "Organise office" ]` 인데 p.189-190 의 데이터는
  `("Read a book", true)` 이고 여섯째 항목이 `("Read Essential F#", false)` 로 바뀐다.
  원서를 옆에 두고 화면을 대조하는 독자는 목록이 달라진 이유를 찾게 된다. 넣는다면
  `Creating the View` 절 첫 불릿 뒤에 한 줄이 적당하다.
  `원서는 같은 뷰를 두 번 싣는데 제목과 완료 표시가 서로 다르다(My To Do List / My ToDo List, "Read a book" 의 checked 여부, 여섯째 항목 이름). 화면이 책의 그림과 달라 보이는 것은 독자의 실수가 아니다.`

- [15-web-pages-with-giraffe.md:5] 14챕터의 인계 문단과 도메인 나열이 어긋난다. 14챕터는
  `HiveCode`·`Hive`·`hives`·`findHive`·`InspectionId`·`Inspection` 을 넘긴다고 적었는데 이 문단은
  넷만 적었다. 정리 절의 최종 모습 문단은 `findHive` 를 다시 적으므로 노트 안에서도 갈린다.
  `HiveCode`·`Hive`·`hives`·`findHive`·`InspectionId`·`Inspection` 으로 맞추고,
  이 챕터가 쓰는 것만 옮겼다는 사실은 이미 229줄 주석이 밝히고 있으니 그대로 두면 된다.

- [15-web-pages-with-giraffe.md:396] 프로젝트에서 `Views.` 접두가 어떻게 보이는지가 빠졌다.
  14챕터 47줄이 "모듈 이름을 접두로 남겨 두려면 `open HiveLog` 를 적는다. 이 노트는 엔드포인트
  목록만 접두를 남긴다" 고 정해 두었는데, 15챕터는 뷰에도 접두를 남긴다(`Views.indexView`).
  원서도 같은 자리에서 `open GiraffeExample` 한 줄을 요구한다. 불릿 하나를 더해 두면
  프로젝트로 옮기는 독자가 막히지 않는다.
  `프로젝트에서는 Program.fs 에 open HiveLog 를 적어 Views. 접두를 남긴다. 14챕터가 엔드포인트 목록에 쓴 방식과 같다.`

- [15-web-pages-with-giraffe.md:689] 최종 모습 문단의 두 곳이 헷갈린다.
  `/api 아래의 요약·벌통 조회 둘과 점검 기록 다섯` 은 경로가 셋인지 둘인지 읽는 이가 갈라야 한다
  (실제로는 요약 하나 + 벌통 조회 둘 + 점검 기록 다섯이다). `요약 하나와 벌통 조회 둘,
  점검 기록 다섯` 으로 풀어라. 같은 문단이 `Program.fs` 의 내용을 열거할 때 요약 핸들러와
  `notFoundHandler` 가 빠져 있다 — `화면 핸들러·요약 핸들러·벌통 핸들러·마지막 핸들러·라우팅·설정·진입점`
  으로 채우면 세 챕터의 실제 파일과 맞는다.

- [15-web-pages-with-giraffe.md:333] `Domain.fs 의 타입 둘을 이 단위에서만 다시 적는다` 는 주석이
  실제와 조금 다르다. 여기 적은 `Inspection` 은 `Id` 필드를 뺀 축소판이다(뷰가 쓰지 않으므로
  합리적인 축약이다). `Domain.fs 의 타입 둘을 이 단위에서만 다시 적는다. Inspection 은 뷰가 쓰는
  필드만 남겼다` 로 한 절 더하면 `15-server` 단위의 정의와 달라 보이는 이유가 설명된다.

- [15-web-pages-with-giraffe.md:478] 매개변수와 인자가 뒤집혀 있다. `달라지는 값만 인자로 받는다`
  → `달라지는 값만 매개변수로 받는다`, `인자가 다섯이면` → `매개변수가 다섯이면`.
  같은 문장의 뒷부분("커링된 함수를 그대로 부르는")은 호출 쪽이라 그대로 두면 된다.
  396줄·683줄의 `인자가 필요 없는 화면` 은 `Views.indexView` 가 함수가 아니라 값이므로
  `데이터를 받지 않는 화면` 이 정확하다.

- [15-web-pages-with-giraffe.md:104] 13챕터와의 파일 이름 연속성. 13챕터의 `hiveTableView` 예제가
  `link [ _rel "stylesheet"; _href "/css/site.css" ]` 를 쓴다. 이 챕터가 만드는 파일은
  `hive.css` 이므로 13챕터를 되짚는 독자에게는 이름이 둘로 보인다. 104줄 불릿에
  `13챕터의 표 예제가 링크한 /css/site.css 는 그 절의 예시일 뿐 앱의 파일이 아니었다` 한 절을
  더하거나, 13챕터 쪽 예제 이름을 `hive.css` 로 맞추는 지시를 13챕터 검수자에게 넘겨라
  (후자는 13챕터 소관이므로 이 노트에서 결정하지 마라).

## 확인 완료

집필자가 보고한 원서 어긋남 5건 — 전부 원문에서 다시 확인했다.

- 원서 p.191 의 마지막 라우팅 코드는 정말 괄호가 하나 부족하다.
  `route "/" (htmlView (Todos.Views.todoView Todos.Data.todoList)` 는 여는 괄호 둘에 닫는 괄호
  하나다. 453줄의 지적이 정확하다.
- 원서 p.186-187 은 `link [ _rel "stylesheet"; _href "css/main.css" ]` 로 앞 슬래시가 없다.
  화면이 `/` 하나뿐이라 원서에서는 드러나지 않는다. 노트가 앞 슬래시를 붙이고
  `/inspections/css/hive.css` 가 404 인 것을 실측으로 보인 처리가 정확하다(재현 확인).
- 원서 p.185 의 `configureApp` 은 `.UseRouting()` 다음에 `.UseStaticFiles()` 다. 노트가 앞으로
  옮긴 것과 관례라는 서술 모두 맞다(MS 문서의 미들웨어 순서도 정적 파일이 라우팅보다 앞이다).
  다만 왜 갈리는지의 설명은 위 `수정 필요` 항목대로 고쳐야 한다.
- 원서의 뷰 문구·클래스 불일치도 사실이다(위 `개선 권장` 에 사례를 적었다).
- 원서 p.189-190 의 `Data.todoList` 는 최상위 리스트이고, 원서 p.178 의 API 는 빈
  `TodoStore()` 를 싱글턴으로 등록한다. 그대로 따르면 화면은 여섯 건을 보여 주고
  `/api/todo` 는 빈 배열을 돌려준다. 표본을 저장소에 넣은 노트의 판단이 옳다.

집필자가 보고한 실측 3건 — 둘은 맞고 하나는 틀렸다.

- `str` 과 특성 함수의 이스케이프: 맞다. 자식 자리와 특성 값 모두에서
  `<`→`&lt;`, `>`→`&gt;`, `&`→`&amp;`, `"`→`&quot;`, `'`→`&#39;` 로 바뀌고 `rawText` 는 그대로
  내보낸다(재현 확인). 노트 본문의 문자 목록에 `'` 만 더하면 된다.
  참고로 U+00A0~U+00FF 구간의 문자도 숫자 참조가 된다(`\u00A0`→`&#160;`, `©`→`&#169;`).
  한글처럼 U+00FF 를 넘는 문자는 그대로 나간다. 노트가 이 구간을 다루지 않으므로 본문에
  적을 필요는 없지만, 예제에 `©` 를 넣으면 출력이 달라진다는 것만 알아 두면 된다.
- `inspectionBoardView` 의 `seq` 추론: 틀렸다. 위 `수정 필요` 첫 항목이 실측 결과다.
  손으로 예상한 것과 다른 대목이 맞지만 방향이 반대다 — 이 코드에서는 주석이 없어도 `list` 다.
- `MapStaticAssets`: 이 SDK 의 공유 프레임워크에 `Microsoft.AspNetCore.StaticAssets.dll` 이
  들어 있다(`/usr/lib/dotnet/shared/Microsoft.AspNetCore.App/10.0.11`). 도입 버전을 단정하지 않고
  "이 노트가 확인한 SDK 에는" 으로 적은 처리가 옳다. 검증 환경이 하나뿐이라 버전 경계를 실측할
  수 없으므로 그 표현을 유지하라. 빌드 산출물이 필요하다는 서술과 압축본·캐시 헤더 설명도 맞다.

시그니처 — FSI 표준 입력 모드로 다시 뽑아 주석과 한 글자씩 대조했다. 전부 일치한다.

- `pageLayout: heading: string -> content: XmlNode list -> XmlNode`
- `indexView: XmlNode`
- `inspectionItemView: inspection: Inspection -> XmlNode`
- `inspectionBoardView: inspections: Inspection list -> XmlNode`
- `inspectionBoardHandler: next: HttpFunc -> ctx: HttpContext -> HttpFuncResult`
  (`: HttpHandler` 주석이 붙어 있어도 람다 본문이 있으면 FSI 가 펼쳐 찍는다. 14챕터와 같은 현상이다.)
- `endpoints: Endpoint list`, `apiEndpoints: Endpoint list`
- `storeWithSamples: unit -> InspectionStore`
- `configureServices: services: IServiceCollection -> unit`,
  `configureApp: appBuilder: IApplicationBuilder -> unit`
- `check: label: string -> fragment: string -> body: string -> unit`
- `get: path: string -> string`, `probeOrder: label: string -> configure: (IApplicationBuilder -> unit) -> unit`

기대 출력 — 세 단위를 따로 돌려 주석과 대조했고 전부 일치한다. 정적 파일 응답의 상태 코드와
`Content-Type`, 일곱 항목의 `true`, 순서 실험의 두 줄, 마지막 `서버를 내렸다` 까지 그대로 나온다.

정적 파일 쪽 사실 확인.

- `.css`→`text/css`, `.js`→`text/javascript` 이고 문자 집합이 붙지 않는다(재현 확인).
- 대응 표에 없는 확장자는 내보내지 않는다: `wwwroot/note.xyz` 를 두고 요청하면 미들웨어를
  지나쳐 `notFoundHandler` 의 평문 404 가 온다(직접 확인). 노트의 서술이 맞다.
- 없는 파일과 `/inspections/css/hive.css` 가 404 로 떨어지는 경로도 노트 설명과 같다.
- `htmlView` 의 `Content-Type` 이 `text/html; charset=utf-8` 인 것, 응답 본문이
  `<!DOCTYPE html>` 로 시작하는 것도 확인했다.

개념 서술 — 다음 대목은 정확하다.

- 공용 레이아웃이 문법이 아니라 함수라는 서술. `XmlNode list -> XmlNode` 껍데기에 본문 목록을
  파이프로 넘기는 형태와 "상속이나 특별한 규칙이 필요하지 않다" 가 View Engine 의 성질과 맞다.
- 자식을 담을 수 없는 요소에 자식 목록을 붙이면 컴파일되지 않는다는 서술. 실측하면
  `link [ _rel "stylesheet" ] [ str "oops" ]` 가 `error FS0003: 이 값은 함수가 아니며 적용할 수
  없습니다.` 다. 노트가 오류 코드를 적지 않았으므로 틀릴 여지가 없다.
- 특성 목록도 리스트라서 `if` 로 골라 클래스를 켜고 끈다는 서술, 빈 리스트가 `li [] [...]` 와
  같다는 서술.
- 암시적 yield 와 `List.map` 이 같은 결과를 낸다는 서술.
- `htmlView` 가 `XmlNode -> HttpHandler` 이고 핸들러에 `task { ... }` 가 필요 없다는 서술.
  `htmlView ... next ctx` 의 결과가 이미 `HttpFuncResult` 이므로 감쌀 것이 없다.
- 저장소가 비어도 빈 `<ul>` 이 나가고 목록 화면에는 없음을 알릴 상태 코드가 필요 없다는 서술.
- 정적 파일 경로를 엔드포인트 목록에 적지 않는다는 서술, 파일을 하나 더 두면 경로가 저절로
  늘어난다는 서술.
- `configureServices` 의 등록 순서는 상관없고 `configureApp` 의 순서는 상관있다는 서술.
- API 의 직렬화 제약이 화면에는 해당하지 않는다는 서술. 판별 유니온이 든 도메인 타입을 뷰에
  그대로 넘기고 `let (HiveCode code) = ...` 한 줄로 벗기는 처리가 9챕터·14챕터와 맞물린다.
- `script` 의 `_type "text/javascript"` 를 생략한 판단(HTML 에서 그 값이 기본이다).
- CSS 클래스 이름이 F# 타입 검사가 닿지 않는 경계라는 서술.

`id` 배정 — 적절하다. `fsharp` 펜스 21개 중 `id` 가 없는 것은 43-46줄의 `.UseStaticFiles()` 한 줄
조각뿐이고, 그것은 컴파일 단위가 아니어서 `id` 를 붙일 수 없다(14챕터의 같은 형태와 맞춘 것이다).
`id` 가 붙은 20개는 세 단위로 이어 붙어 전부 통과하며, 이어 붙인 상태를 기준으로 보면
정의가 빠진 블록은 없다. 컴파일 오류를 예시로 든 `id` 없는 블록은 이 챕터에 없다.

부록 2 처리 — 적절하다. 필요한 정보 넷이 다 있다. 부록의 원서 페이지(pp.197-201), 만들 파일과
위치(`wwwroot/css/main.css`·`wwwroot/js/main.js`), 각 파일이 하는 일, 그리고 노트의 두 파일이
원서 부록과 무관하다는 사실. 원문과 대조해 보면 설명이 실제 내용과 맞다 — CSS 는 줄무늬
(`ul li:nth-child(odd)`)·완료 표시(`ul li.checked::before`)·삭제 버튼(`.close`)·머리글 색
(`.header`)·입력란 배치(`input`, `.addBtn`)를 정하고, JavaScript 는 항목마다 `close` 버튼을 붙이고
`ul` 클릭으로 `checked` 를 켜고 끄며 `newElement()` 로 입력란 값을 새 항목으로 만든다.
코드를 한 줄도 옮기지 않은 것도 STYLE.md 의 선과 맞다. 보탤 것은 위에 적은 한 줄(부록 코드가
원서 뷰의 id·클래스에 묶여 있다)뿐이고, 닫기 버튼을 누르면 항목이 숨는다는 동작을 한 낱말
더해 두면 설명이 완전해진다.

HTML 응답 검사 방식 — 충분하다. 조건은 위 `개선 권장` 의 두 항목(`<!DOCTYPE html>` 검사 추가,
조각 검사의 한계 한 줄)이다. 뷰가 깨지는 흔한 경우를 실제로 잡는다. 레이아웃에서 `link` 나
`script` 를 빠뜨리면 앞 두 항목이, 부분 뷰의 클래스 분기를 뒤집으면 다섯째·여섯째가, 컴프리헨션이
항목을 흘리면 넷째(건수)와 일곱째(마지막 항목의 시각)가 `false` 가 된다. 표본 시각을 못박은
덕에 시각까지 대조할 수 있다는 판단도 옳다 — `DateTime.UtcNow` 로는 일곱째 검사를 쓸 수 없다.
한계는 셋이다. (1) 부분 문자열 검사라 순서·중첩·중복을 보지 않는다. (2) 이스케이프가 서버
경로에서도 동작하는지는 검사하지 않는다(표본에 특수 문자가 없다. `15-escape` 단위가 따로
보이므로 중복까지 만들 필요는 없다). (3) 특성 순서가 바뀌면 조각이 어긋나 거짓 실패가 날 수
있는데, 이는 검사가 렌더링 구현에 묶여 있다는 뜻이고 회귀 검사로는 오히려 엄격한 편이다.
정적 파일을 200/404 와 `Content-Type` 으로 확인한 것도 이 챕터가 더한 미들웨어를 정확히 겨눈다.

축약 판단 — 학습에 문제가 없다. 조건은 위 `개선 권장` 첫 항목(주석의 범위를 정확히 적는 것)과
`수정 필요` 의 625줄 문장 교체다. 이 둘을 고치면 독자가 앱의 전체 모습을 오해할 자리가 없다.
근거는 셋이다. 이 챕터의 주제가 뷰이고 축약된 것은 14챕터에서 이미 실행·검증한 코드다.
`Domain`·`Store` 를 쓰는 멤버만 옮긴 것도 같은 이유로 타당하며, 그 사실이 주석에 적혀 있다.
그리고 정리 절의 최종 모습 문단이 다섯 파일과 세 갈래 경로를 다시 세워 주므로, 축약본만 보고
앱을 판단할 독자가 남지 않는다(그 문단의 두 곳은 위 `개선 권장` 대로 다듬어라).

세 챕터 연속성 — 14챕터의 `### 15챕터가 이어받는 것` 은 한 항목을 빼고 모두 반영됐다.
컴파일 순서와 `Views.fs` 자리(21-31줄), 저장소의 싱글턴 등록과 `ctx.GetService`(395줄·410줄),
세 층 라우팅과 화면 경로를 바깥 `endpoints` 에 더하는 것(5줄·441줄), 이름 규칙(핸들러·뷰
꼬리표를 그대로 지켰다), `p [ _class "lede" ]` 의 CSS 를 이 챕터가 만드는 것(104줄),
`UseStaticFiles` 한 줄(487줄), 뷰에는 직렬화 제약이 없다는 것(34줄), 검증 방식 계승(146-255줄)
까지 들어 있다. 빠진 것은 도메인 나열의 `hives`·`findHive` 하나이고 위 `개선 권장` 에 적었다.
정리 절의 최종 모습 문단은 세 노트의 실제 내용과 맞다 — 파일 다섯, 저장소 하나를 화면과 API 가
나눠 쓰는 구조, 미들웨어 순서, 서비스 등록 넷, 메모리 저장소의 휘발성까지 13·14챕터의 코드와
대조해 확인했다. 다듬을 곳은 위에 적은 두 곳(경로 개수 표현, `Program.fs` 내용 열거)뿐이다.

용어 — 13·14챕터 표기를 그대로 따르고 있고 웹 맥락의 `pipeline` 을 쓰지 않았다.
새로 정한 것들의 판단과 근거는 `docs/ko/_pipeline/review/15-glossary.md` 에 적었다.
요점만 옮기면, `master page` 는 원서 절 제목과 MS ko 표기가 "마스터 페이지" 이므로 용어집
표제어는 그쪽으로 올리되 본문이 함수를 "공용 레이아웃" 이라 부르는 처리는 그대로 두는 것이 좋다
(54줄이 이미 두 이름을 잇고 있어 원서 대조에 문제가 없다). `character reference`→문자 참조는
유지하라 — "엔티티" 는 이름 있는 참조만 가리키고 노트의 출력에 나오는 `&#39;` 를 담지 못한다.
`static files`·`web root`·`content root`·`partial view`·`escape`·요소 함수·특성 함수는 그대로 쓴다.
