# 배치 D 용어집 병합 보고서 (12·13·14·15챕터)

작업 모드: 병합 모드. `docs/ko/GLOSSARY.md` 를 이 세션에서만 편집했다. 노트 본문(`docs/ko/[0-9]*.md`)은
한 글자도 고치지 않았다. 아래 4·5·6절이 4단계 집필자가 문자열로 치환할 목록이다.
찾을 문자열과 교체문은 모두 펜스 블록에 넣었다. 블록 안의 백틱은 이스케이프가 아니라 실제 글자다.
모든 찾을 문자열은 이 보고서를 만들 때 대상 파일에서 출현 횟수 1 을 단정해 확인했다.

입력: `12-glossary.md`·`13-glossary.md`·`14-glossary.md`·`15-glossary.md`,
`12-expert.md`·`13-expert.md`·`14-expert.md`·`15-expert.md`,
판례 `batchA/B/C-glossary-merge.md`·`batchD-glossary-pre.md`·`glossary-abbrev-fix.md`.
실측 환경: .NET SDK 10.0.111, `Microsoft.AspNetCore.App` 10.0.11, Giraffe 8.3.0,
`Giraffe.ViewEngine` 1.4.0, `FsToolkit.ErrorHandling` 5.2.0.

---

## 1. 결과 요약

- 신규 등재 60행. 표 데이터 행 273 → 333.
- `[기확정 변경 제안]` 4건 전부 적용(비고만 수정, 표기 무수정). 그 밖의 기확정 행은 손대지 않았다.
- 머리말 정렬 규칙에 한 문장 추가(기호만으로 된 항목의 정렬 키 판례).
- 검증: 정렬 위반 0건, 영어 키 중복 0건, 한국어 표기 중복 0건, 표 칸 수 이상 0건
  (`\|` 이스케이프를 한 글자로 환산해 셌다).
  `check-note.sh docs/ko/GLOSSARY.md` 의 FAIL 항목 9건은 전부 기존 행이다(금지 표기를 금지하려고
  인용한 행과 `**확정.**` 표기). 신규 60행과 수정한 4행은 어느 검사에도 걸리지 않는다.
- 챕터별 수정 목록 총 40곳. 갈래별로 나누면 이렇다.

| 갈래 | 챕터 수 | 곳 | 어디 |
|---|---|---|---|
| 코드 버그 — 버전 선택 | 3 | 3 | 13·14·15 각 1곳 (4.1) |
| 코드 버그 — 끊긴 링크 | 3 | 3 | 13·14·15 각 1곳 (4.2) |
| 코드 버그의 짝 주석·산문 | 1 | 2 | 13챕터 (4.3) |
| 과하게 넓은 서술(`System.Text.Json`) | 2 | 6 | 13챕터 2곳, 14챕터 4곳 (4.4) |
| 전파된 오류(브라우저 `Accept`) | 2 | 2 | 14·15 각 1곳 (4.5) |
| 챕터 간 예고 | 1 | 1 | 08챕터 (4.6) |
| 표기 — 미들웨어 파이프라인 | 3 | 6 | 13챕터 3곳, 14챕터 1곳, 15챕터 2곳 (5.1) |
| 표기 — `HttpContext` | 1 | 2 | 13챕터 (5.2, 세 번째 곳은 전문가 교체문에 포함) |
| 표기 — 콘텐츠 협상 | 2 | 8줄 9곳 | 14챕터 8줄(15챕터 1곳은 4.5 에 포함) (5.3) |
| 표기 — HTTP 메서드·웹 애플리케이션 | 1 | 2 | 13챕터 (5.4) |
| 배치 A·B·C 소급(권장) | 3 | 5 | 06챕터 3곳, 07·11챕터 각 1곳 (6.1·6.2) |

  이 가운데 두 챕터 이상에 걸친 것은 코드 버그 6곳, 과잉 서술 6곳, 전파 오류 2곳,
  미들웨어 파이프라인 6곳, 콘텐츠 협상 9곳이다.
- 코드 교체는 세 챕터 노트 사본에 실제로 적용해 실행 단위 10개를 전부 다시 돌렸다. 모두 PASS, 경고 0건.
- 전파 오류(브라우저 `Accept` → 406)는 병합자가 다시 실측해 14·15챕터 전문가의 정정이 옳음을 확인했다.

---

## 2. 표기 충돌과 결정

### 2.1 두 후보 이상이 같은 낱말을 올린 것

| 영어 | 올라온 표기 | 결정 | 근거 |
|---|---|---|---|
| `status code` | 상태 코드(13) / 상태 코드(14) | 상태 코드 | 표기가 같다. 두 행을 하나로 합치고 비고를 병합했다(숫자 표기 규칙은 14쪽, 기확정 `exit code` 와의 구분은 병합자가 덧붙였다) |
| `overload` | 오버로드(12) / 오버로드(14) | 오버로드 | 표기가 같다. 12쪽의 `Source` 실측과 14쪽의 `ConcurrentDictionary.TryRemove` 실측을 한 행에 모았다 |
| `middleware` | 미들웨어(13) / 미들웨어(15) | 미들웨어 | 15가 13을 따랐다고 명시했다 |
| `routing`·`endpoint`·`handler`·`dependency injection`·`singleton`·`View Engine` | 13·14·15가 같은 표기 | 그대로 | 14·15 후보가 13·14 표기를 따랐다고 명시했다 |
| `content negotiation` | 내용 협상(15가 따라 씀) / 콘텐츠 협상(14) | 콘텐츠 협상 | MS Learn ko·MDN ko 표기이고, 같은 문서군의 `content root`→콘텐츠 루트 와 web 문맥 `content` 표기를 하나로 맞춘다. 14·15챕터 본문을 고친다(5.3) |
| `out` parameter | 14가 신규로 올림 | 기확정 행 유지 | 이미 확정된 행이다(표기 동일, 비고 내용도 어긋나지 않는다). 중복 등재하지 않았다 |

### 2.2 병합자가 판단한 것

- `>=>` 의 정렬 자리. 13 후보가 두 안을 남겼다. `bang (!)` 판례를 따라 영어 칸을
  `compose operator (>=>)` 로 적어 `c` 자리에 두었다. 표 맨 앞에 기호 행을 만들면 머리말의 정렬
  규칙에 기호 조항을 새로 세워야 하고, 뒤 배치에서 연산자 행이 늘 때마다 규칙이 흔들린다.
  한국어 칸과 본문 표기는 `>=>` 하나이며, 한국어 이름을 붙이지 않는다는 지시는 비고에 못박았다.
  머리말 정렬 규칙에 이 판례 한 문장을 더했다.
- `deserialization`→역직렬화 를 별개 행으로 등재했다. 14 후보가 "13 후보에 없으면 따로 넣으라"고
  남겼고, 13 후보의 `serialization` 행 비고만으로는 `System.Text.Json` 의 두 방향 지원 범위를
  담을 자리가 없다(4.4 의 과잉 서술 정정이 이 행에 기댄다).
- `request`→요청 / `response`→응답 두 행을 등재했다. 14 후보가 "병합 담당자가 13 후보와 함께 정하라"고
  남긴 항목이고 13 후보 표에는 없었다. 세 챕터가 이미 요청/응답으로만 쓰고 있어 본문 수정은 없다.
  본문을 가리킬 때는 "요청 본문"/"응답 본문" 으로 쓰고 `payload` 행이 이 표기를 참조한다.
- `htmlView` 행을 등재했다. 15 후보가 결정을 병합자에게 넘긴 항목이다. `text`·`json`·`negotiate` 를
  포함한 응답 핸들러 이름을 모두 원어 백틱으로 쓴다는 규칙을 이 한 행에 묶었다.
- `container` 는 별개 행을 만들지 않았다. `dependency injection` 행이 "의존성 주입 컨테이너" 와
  줄임 규칙을 이미 담는다.
- `static files` 는 15 후보의 복수형 표제어를 그대로 썼다(MS ko 도 복수형이다).
  정렬 키에서 `static file middleware` 가 `static files` 보다 앞이다(공백이 `s` 보다 작다).

### 2.3 지시받은 대로 반영한 것 (재론하지 않음)

- `middleware pipeline`→미들웨어 파이프라인 별개 행 등재. 기확정 `pipeline` 행은 표기를 그대로 두고
  웹 문맥 사용 금지만 비고에 넣었다. 두 행이 서로를 참조한다.
- `HttpContext` 산문 표기는 요청 컨텍스트. "요청 맥락" 금지.
- `>=>` 에 한국어 이름을 붙이지 않고 "함수 합성 연산자"로 부르지 않는다는 것을 비고에 못박았다.
- `content negotiation`→콘텐츠 협상.
- `master page` 표제어는 마스터 페이지, 본문의 "공용 레이아웃" 은 유지(비고에 적었다).
- `character reference`→문자 참조 유지, "엔티티" 는 이름 있는 참조만 가리킨다는 근거를 비고에 남겼다.

---

## 3. `[기확정 변경 제안]` 4건 적용 결과

네 건 모두 비고만 고치는 변경이라 앞 챕터 본문 파급이 없다. 표기는 한 건도 바꾸지 않았다.

| 행 | 무엇을 넣었나 | 실측 재확인 |
|---|---|---|
| `do!` | "평범한 `unit` 을 주면 `error FS0001`(`async`·직접 만든 빌더) 또는 `error FS0041`(`FsToolkit.ErrorHandling` 의 `result` — 빌더의 `Source` 오버로드 해결에서 먼저 걸린다)이다" | 병합자가 다시 실측했다. `result { do! plain () }` 이 `error FS0041: 'Source' 메서드와 일치하는 오버로드가 없습니다` 와 `ResultBuilder.Source` 오버로드 세 개를 찍는다 |
| `computation expression builder` | 멤버 열거에 `Source` 추가, `Source` 가 하는 일 한 문장(`do!` 행 상호 참조) | 위와 같은 실측 |
| `format specifier` | `%A` 는 폭 지정을 무시한다, `sprintf "%A"` 우회, `%A` 로 찍은 `None` 은 `None` 이다 | 병합자가 다시 실측했다. `[%-9A]`·`[%9A]` 모두 `[Some 60]`, `sprintf "%A"` 를 `%-9s` 로 찍으면 `[Some 60  ]`, `%A` 의 `None` 은 `[None]` |
| `pipeline` | "웹 문맥의 request pipeline·middleware pipeline 에는 이 낱말을 쓰지 않는다 — 13-15챕터는 온낱말 미들웨어 파이프라인으로 적고 파이프라인으로 줄이지 않는다" | 14 후보의 원안은 "13-15챕터는 '요청이 지나는 길'로 풀어 쓴다" 였으나, 13챕터 전문가가 용어 회피를 기각하고 `middleware pipeline` 등재가 확정되었으므로 문면을 새 결정에 맞췄다 |

---

## 4. 챕터를 넘어 번진 것 — 세 챕터를 함께 고쳐야 한다

### 4.1 코드 버그: 공유 프레임워크 버전 선택이 문자열 정렬이다 (13·14·15, 3챕터 3곳)

`Array.sortBy Path.GetFileName |> Array.last` 는 버전 정렬이 아니다. 실측하면
`10.0.9` > `10.0.11` 이고 `9.0.14` > `10.0.11` 이다. 패치 둘이 깔린 환경에서 낮은 쪽을 고르고,
9.0 과 10.0 이 함께 깔리면 실행 중인 런타임과 메이저가 다른 쪽을 고른다.

```text
[|"/x/10.0.11"; "/x/10.0.9"; "/x/9.0.14"|]   // Array.sortBy Path.GetFileName 결과
last        = /x/9.0.14                       // 지금 고르는 것
by Version  = /x/10.0.11                      // 골라야 하는 것
```

대상은 `docs/ko/13-web-with-giraffe.md`·`docs/ko/14-api-with-giraffe.md`·`docs/ko/15-web-pages-with-giraffe.md`
세 파일이다. 아래 네 줄이 세 파일에서 바이트 단위로 동일하고 각 파일에 1회씩 나온다.
교체문도 세 파일이 같다. 세 파일 모두 앞에 `open System`·`open System.IO` 가 있으므로 새 `open` 은
필요 없다.

찾을 문자열 (1회):
```text
    Path.Combine(core.Parent.Parent.FullName, "Microsoft.AspNetCore.App")
    |> Directory.GetDirectories
    |> Array.sortBy Path.GetFileName
    |> Array.last
```
교체:
```text
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
읽지 못하는 것을 피하려는 것이다(실측: 그 이름이 `10.0.0` 으로 읽힌다).

### 4.2 코드 버그: 끊긴 심볼릭 링크가 조용히 만들어진다 (13·14·15, 3챕터 3곳)

`File.CreateSymbolicLink` 는 원본이 없어도 예외를 던지지 않는다(실측). 어셈블리 하나가 그 공유
프레임워크에 없으면 `try ... with` 에 걸리지 않고 넘어간 뒤 뒤쪽 `#r` 에서 원인을 짚을 수 없는
오류로 터진다. 13챕터 전문가가 4.1 과 함께 세 챕터에 모두 적용해야 한다고 지시했다.
아래 두 줄도 세 파일에 1회씩 있고 교체문이 같다.

찾을 문자열 (1회):
```text
    let source = Path.Combine(sharedFramework, name + ".dll")
    let target = Path.Combine(referenceDir, name + ".dll")
```
교체:
```text
    let source = Path.Combine(sharedFramework, name + ".dll")
    if not (File.Exists source) then
        failwithf "%s 를 %s 에서 찾지 못했다." name sharedFramework
    let target = Path.Combine(referenceDir, name + ".dll")
```

### 4.1·4.2 검증

세 노트의 사본에 4.1 과 4.2 를 함께 적용해 `verify-examples.sh` 를 다시 돌렸다.

```text
PASS 13-mutability / 13-payload / 13-server / 13-view
PASS 14-binding / 14-server / 14-store
PASS 15-escape / 15-server / 15-view
모든 실행 단위 통과 (경고 0건)
```

고친 코드가 찍는 값도 그대로다 — `printfn "ASP.NET Core %s"` 가 `ASP.NET Core 10.0.11` 을 찍어
주석의 기대 출력과 일치한다.

### 4.3 4.1 의 짝 — 13챕터에만 있는 주석과 산문 (13챕터 2곳)

14·15챕터에는 이 두 줄에 해당하는 주석·산문이 없다(`grep` 확인).

찾을 문자열 (1회):
```text
// (1) 설치된 ASP.NET Core 공유 프레임워크에서 가장 높은 버전 폴더를 고른다
```
교체:
```text
// (1) 설치된 ASP.NET Core 공유 프레임워크에서 실행 중인 런타임과 같은 계열의 가장 높은 버전을 고른다
```

찾을 문자열 (1회):
```text
- (1)의 계산은 `Microsoft.NETCore.App/10.0.11` 옆에 `Microsoft.AspNetCore.App/10.0.11` 이 있다는 배치를 이용한다. 두 프레임워크의 버전이 항상 같다고 보장되지 않으므로 폴더 목록에서 가장 높은 것을 고른다.
```
교체:
```text
- (1)의 계산은 `Microsoft.NETCore.App/10.0.11` 옆에 `Microsoft.AspNetCore.App/10.0.11` 이 있다는 배치를 이용한다. 두 프레임워크의 버전이 항상 같다고 보장되지 않으므로, 실행 중인 런타임과 메이저 버전이 같은 폴더 가운데 가장 높은 것을 고른다. 폴더 이름을 문자열로 비교하면 `10.0.9` 가 `10.0.11` 보다 크게 나오므로 `Version` 으로 비교해야 한다.
```

### 4.4 과하게 넓은 서술: `System.Text.Json` 과 판별 유니온 (13·14, 2챕터 6곳)

실측(.NET 10)하면 막히는 것은 `Option` 이 아닌 판별 유니온뿐이다.

| 타입 | 결과 |
|---|---|
| 레코드, `list`, `Set`, `Map`, 튜플 | 된다 |
| `int option`, `int voption` | 된다. `Some 5` ↔ `5`, `None` ↔ `null`/필드 없음 |
| 그 밖의 판별 유니온(`HiveCode`·`InspectionId`·다중 케이스) | 방향에 상관없이 `NotSupportedException` |

DTO 를 따로 두어야 하는 결론은 그대로 성립한다. 문장 범위만 좁힌다.

13챕터 (`docs/ko/13-web-with-giraffe.md`) 2곳

찾을 문자열 (1회):
```text
`System.Text.Json` 은 판별 유니온을 직렬화하지 못한다.
```
교체:
```text
`System.Text.Json` 은 `Option` 이 아닌 판별 유니온을 직렬화하지 못한다.
```

찾을 문자열 (1회):
```text
`System.Text.Json` 은 판별 유니온을 직렬화하지 못하고 `NotSupportedException` 을 던지므로
```
교체:
```text
`System.Text.Json` 은 `Option` 이 아닌 판별 유니온을 직렬화하지 못하고 `NotSupportedException` 을 던지므로
```

14챕터 (`docs/ko/14-api-with-giraffe.md`) 4곳

찾을 문자열 (1회):
```text
`System.Text.Json` 은 판별 유니온을 다루지 못하므로 이 타입은 응답에도 요청에도 그대로 실을 수 없다.
```
교체:
```text
`System.Text.Json` 은 `Option` 이 아닌 판별 유니온을 다루지 못하므로 이 타입은 응답에도 요청에도 그대로 실을 수 없다.
```

찾을 문자열 (1회):
```text
`InspectionId` 가 판별 유니온이라 역직렬화 자체가 되지 않는다.
```
교체:
```text
`InspectionId` 가 `Option` 이 아닌 판별 유니온이라 역직렬화 자체가 되지 않는다.
```

찾을 문자열 (1회):
```text
판별 유니온은 읽는 방향에서도 `NotSupportedException` 이고,
```
교체:
```text
`Option` 이 아닌 판별 유니온은 읽는 방향에서도 `NotSupportedException` 이고,
```
이 문자열은 지금 파일 상태에서 1회다. 바로 아래 항목을 먼저 적용하면 두 곳이 되므로 이것을 먼저 적용하라.

찾을 문자열 (1회):
```text
- 판별 유니온은 읽는 방향에서도 막힌다. 13챕터가 응답에서 만난 `NotSupportedException` 이 요청에서도 그대로 나오고,
```
교체:
```text
- 판별 유니온은 읽는 방향에서도 막힌다. `System.Text.Json` 의 F# 지원은 레코드·`list`·`Set`·`Map`·튜플과 `Option` 까지이고, `Option` 이 아닌 판별 유니온은 방향에 상관없이 `NotSupportedException` 이다. 13챕터가 응답에서 만난 예외가 요청에서도 그대로 나오고,
```
불릿의 앞부분만 바꾸는 것이다. 뒤에 이어지는 "본문을 어떤 모양으로 보내든 ..." 은 그대로 둔다.

### 4.5 전파된 오류: 브라우저로 `negotiate` 경로를 열면 406 이 아니다 (14·15, 2챕터 2곳)

병합자가 14챕터 실행 단위에 요청 세 건을 더해 다시 실측했다.

```text
Accept: text/html                                                            406  text/html is unacceptable by the server.
Accept: text/html,*/*;q=0.8                                                  200  application/json; charset=utf-8
Accept: text/xml                                                             500  (본문 없음)
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,... 500  (본문 없음)
```

브라우저가 보내는 값은 `text/html` 단독이 아니다. 협상은 품질값 순서대로 규칙에 있는 첫 형식을
고르므로 `application/xml`(q=0.9)에 걸려 XML 직렬화 실패로 500 이 된다. 14챕터 전문가 보고서의
`text/xml` 규칙 보강(협상 규칙이 다섯 개라는 항목)이 이 서술의 전제이므로 그 항목을 먼저 적용하라.

14챕터 1곳 — 불릿의 앞 두 문장만 바꾼다. 뒤에 이어지는 "13챕터의 첫 화면처럼 HTML 을 내보내야
하는 경로에는 `htmlView` 를 그대로 쓴다." 는 그대로 둔다.

찾을 문자열 (1회):
```text
- `text/html` 은 규칙에 없으므로 406 이다. 브라우저는 보통 `text/html` 을 먼저 요구하므로, `negotiate` 를 붙인 경로를 주소창으로 열면 406 을 보게 된다.
```
교체:
```text
- `Accept: text/html` 만 보내면 규칙에 없으므로 406 이다. 그런데 브라우저가 실제로 보내는 값은 `text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8` 이고, 협상은 품질값 순서대로 규칙에 있는 첫 형식을 고른다. `text/html` 을 지나 `application/xml` 이 먼저 걸리므로 주소창으로 열면 406 이 아니라 앞에서 본 XML 직렬화 실패로 500 이 온다. `text/html,*/*;q=0.8` 처럼 `*/*` 가 붙은 값이면 200 JSON 이다.
```

15챕터 1곳 — 15챕터 전문가 보고서에도 같은 항목이 있으나 그 교체문에 "내용 협상" 이 들어 있다.
5.3 의 콘텐츠 협상 결정을 함께 반영한 아래 문장을 쓰라. 불릿 한 줄 전체를 바꾼다.

찾을 문자열 (1회):
```text
- `/inspections` 와 `/api/inspections` 가 같은 저장소를 읽어 다른 형식으로 답한다. 앞은 사람이 볼 HTML, 뒤는 기계가 읽을 JSON 이다. 14챕터에서 본 내용 협상으로 한 경로에 둘을 겹칠 수도 있지만, `negotiate` 의 기본 규칙에는 `text/html` 이 없어 브라우저 요청이 406 이 된다. 화면과 API 를 경로로 갈라 두는 편이 단순하다.
```
교체:
```text
- `/inspections` 와 `/api/inspections` 가 같은 저장소를 읽어 다른 형식으로 답한다. 앞은 사람이 볼 HTML, 뒤는 기계가 읽을 JSON 이다. 14챕터에서 본 콘텐츠 협상으로 한 경로에 둘을 겹칠 수도 있지만, `negotiate` 의 기본 규칙에는 `text/html` 이 없어 HTML 을 골라 줄 방법이 없다. `Accept: text/html` 만 보내면 406 이고, 브라우저가 보내는 긴 `Accept` 헤더는 품질값 0.9 의 `application/xml` 규칙에 걸려 14챕터에서 본 XML 직렬화 실패로 500 이 된다. 화면과 API 를 경로로 갈라 두는 편이 단순하다.
```

### 4.6 챕터 간 예고 정리: 08챕터가 12챕터의 범위를 넘겨 예고한다 (08챕터 1곳)

12챕터가 직접 만드는 빌더 멤버는 `Bind`·`Return`·`ReturnFrom` 이고 `MergeSources` 는 만들지 않는다.
원서 범위에 `MergeSources` 구현이 없으므로 12챕터를 늘릴 일이 아니라 08챕터 쪽을 좁혀야 한다.
12챕터 본문은 이미 "이 챕터에서 만든 `Bind` 가 아니라 `MergeSources` 멤버를 부른다" 로 적어
오해를 만들지 않는다. 08챕터는 배치 C 챕터이므로 배치 D 적용과 분리해 처리하라.
08챕터에서 "빌더" 가 나오는 곳은 이 한 줄뿐이므로(`grep` 확인) 다른 서술이 낡지 않는다.

찾을 문자열 (1회):
```text
`let!` 은 계산 식 빌더의 `Bind` 멤버를, `and!` 는 `MergeSources` 멤버를 부르는데 그 멤버를 직접 만드는 것이 12챕터의 일이다.
```
교체:
```text
`let!` 은 계산 식 빌더의 `Bind` 멤버를, `and!` 는 `MergeSources` 멤버를 부른다. 빌더 멤버를 직접 만들어 보는 것이 12챕터의 일이다.
```

---

## 5. 표기 적용 목록

### 5.1 `middleware pipeline` → 미들웨어 파이프라인 (13챕터 3곳, 14챕터 1곳, 15챕터 2곳)

기확정 `pipeline`(함수 파이프라인)과 갈라 쓰는 행이 새로 생겼다. 13챕터에서 용어를 한 번 도입하고
세 챕터가 그 이름을 쓰게 한다. 줄여 "파이프라인" 으로 쓰지 않는다.

13챕터 (1) 필수 — 용어 도입. 불릿의 앞부분만 바꾼다(뒤의 "라우팅을 먼저 켜고, ..." 는 그대로).
13챕터 전문가 보고서의 같은 항목은 `미들웨어(middleware)` 병기를 떨어뜨렸으므로 아래 문장을 쓰라 —
용어집 머리말이 첫 등장 1회 병기를 요구하고 이 자리가 `middleware` 의 첫 등장이다.

찾을 문자열 (1회):
```text
- `configureApp` 은 요청이 지나갈 미들웨어(middleware) 순서를 정한다. 순서가 곧 동작이다.
```
교체:
```text
- `configureApp` 은 요청이 지나갈 미들웨어(middleware)의 순서를 정한다. 이 순서를 미들웨어 파이프라인(middleware pipeline)이라 부른다. 2챕터에서 `|>` 로 값을 흘려보낸 함수 파이프라인과는 다른 것이므로 줄여 쓰지 않고 온낱말로 적는다. 순서가 곧 동작이다.
```
13챕터 (2) 권장

찾을 문자열 (1회):
```text
- `configureApp` 의 순서가 곧 요청이 지나는 길이다.
```
교체:
```text
- `configureApp` 에 적은 순서가 곧 미들웨어 파이프라인이다.
```
13챕터 (3) 권장 — 인수인계 문단

찾을 문자열 (1회):
```text
미들웨어 순서는 `configureApp` 이 담당하고 진입점은 그 둘을 부르기만 한다.
```
교체:
```text
미들웨어 파이프라인은 `configureApp` 이 정하고 진입점은 그 둘을 부르기만 한다.
```
14챕터 권장

찾을 문자열 (1회):
```text
- 등록 순서는 상관없다. `configureApp` 의 순서는 상관있다. 13챕터에서 본 대로 요청이 지나는 길을 정하는 코드라
```
교체:
```text
- 등록 순서는 상관없다. `configureApp` 의 순서는 상관있다. 13챕터에서 본 대로 미들웨어 파이프라인을 정하는 코드라
```
15챕터 권장 2곳

찾을 문자열 (1회):
```text
미들웨어 순서가 결과를 갈라 놓는 경우를 마지막에 확인한다.
```
교체:
```text
미들웨어 파이프라인의 순서가 결과를 갈라 놓는 경우를 마지막에 확인한다.
```

찾을 문자열 (1회):
```text
- 미들웨어 순서는 취향이 아니다.
```
교체:
```text
- 미들웨어 파이프라인의 순서는 취향이 아니다.
```
15챕터에 남은 "요청이 지나는 길" 한 곳은 15챕터 전문가가 불릿 전체를 교체하며 그 표현을
없앴으므로 따로 손대지 않는다.

### 5.2 `HttpContext` → 요청 컨텍스트 (13챕터 3곳)

찾을 문자열 (1회):
```text
현재 요청 맥락
```
교체:
```text
현재 요청 컨텍스트
```

찾을 문자열 (1회):
```text
쿼리 문자열을 읽으려면 `ctx.TryGetQueryStringValue` 처럼 맥락에서 직접 꺼내야 한다.
```
교체:
```text
쿼리 문자열을 읽으려면 `ctx.TryGetQueryStringValue` 처럼 `HttpContext` 에서 직접 꺼내야 한다.
```
세 번째 곳은 `>=>` 를 설명하는 불릿의 "`>=>` 는 요청 맥락을 넘기는 합성이다" 다. 13챕터 전문가가
그 불릿 전체를 교체했고 교체문에 "맥락" 이 없으므로 이중 수정하지 말 것.
적용 뒤 `grep -c 맥락 docs/ko/13-web-with-giraffe.md` 가 0 이어야 한다(12챕터의 "맥락" 은 기확정
`effect` 행이 쓰는 것이므로 그대로 둔다).

### 5.3 `content negotiation` → 콘텐츠 협상 (14챕터 8줄 9곳, 15챕터 1곳)

"내용 협상" 을 "콘텐츠 협상" 으로 바꾼다. 다른 낱말에 걸리는 부분 일치가 없으므로 파일 전체 치환이
안전하다. 14챕터는 `grep -Fc` 로 8줄, 실제 출현 9회다(한 줄에 두 번 나오는 곳이 있다).
절 제목과 원서 대조표 행도 함께 바뀐다. 첫 등장 병기는 `콘텐츠 협상(content negotiation)` 이 된다.

- 14챕터: 파일 전체에서 `내용 협상` → `콘텐츠 협상`
- 15챕터: 1곳이며 4.5 의 교체문에 이미 반영돼 있다. 4.5 를 적용하면 따로 할 일이 없다.
- 적용 뒤 두 파일에서 `grep -c "내용 협상"` 이 0 이어야 한다.

### 5.4 13챕터 후보 파일이 올린 나머지 표기 (13챕터 보고서에도 있는 항목)

중복 적용을 막기 위해 여기 모아 둔다.

찾을 문자열 (1회):
```text
안에서 동사별로 묶으면 되고
```
교체:
```text
안에서 메서드별로 묶으면 되고
```
`HTTP method` 행. 13챕터 전체에서 "동사" 가 쓰인 곳은 이 한 곳이다.

찾을 문자열 (1회):
```text
컨트롤러도 뷰도 없는 최소 웹 앱이다.
```
교체:
```text
컨트롤러도 뷰도 없는 최소 웹 애플리케이션이다.
```
`web application` 행.
핸들러 이름 규칙 문장(`<대상><동작>Handler`)은 13챕터 전문가 보고서의 교체문을 따르라.
`handler` 행의 이름 규칙 `<대상><동작 또는 응답 내용>Handler` 와 일치한다.

### 5.5 수정 필요 없음으로 판정한 것

- 15챕터의 `View Engine`/`뷰 엔진` 혼용. 13챕터 후보 파일이 "View Engine 8곳과 뷰 엔진 2곳이 섞여
  있다" 고 넘겼으나, 실제로 세어 보면 `View Engine` 9곳, `뷰 엔진` 2곳이고 후자는 둘 다
  "다른 뷰 엔진에서 마스터 페이지나 레이아웃이라 부르는 것", "문자열을 찾아 바꾸는 다른 뷰 엔진과
  달리" 로 일반명사 자리다. `View Engine` 행이 허용하는 용법과 정확히 일치한다. 고칠 것 없음.
- 13챕터의 `HttpContext`·`middleware pipeline` 을 뺀 다른 웹 용어와 14챕터 전체의 표기.
  신규 등재 60행과 대조해 어긋나는 곳이 없다(`grep` 확인).
- `out` parameter 는 이미 확정된 행이고 14챕터 본문이 그 표기를 따른다.
- 12챕터는 신규 등재 표기(상수 패턴·변수 패턴·도우미 함수·오버로드·`parallelAsyncValidation`)를
  이미 그대로 쓴다.

---

## 6. 배치 A·B·C 챕터(00~11) 훑기 결과

16개 노트 전체를 신규 등재 60행의 금지 표기로 기계적으로 훑었다. 금지 표기 50여 개
("대리자"·"종속성 주입"·"직렬 변환"·"싱글톤"·"라우트"·"쿼리스트링"·"처리기"·"색인기"·
"무명 레코드"·"대입 연산자"·"리터럴 패턴"·"헬퍼"·"다중 정의"·"이펙트"·"엔티티"·"파셜 뷰" 등)의
출현은 00~11챕터에서 0건이다. 걸린 것은 13챕터의 "웹 앱" 1곳(5.4)뿐이다.

아래 두 건은 신규 등재 때문에 낱말이 겹치게 된 자리다. 둘 다 권장이고 기술 오류가 아니다.

### 6.1 (권장) `header (HTTP)`→헤더 등재로 생긴 겹침 — 06챕터 3곳, 11챕터 1곳

기확정 `header row`→헤더 줄 이 있는데도 노트 전체에 "헤더 줄" 이 한 번도 쓰이지 않았다
(`grep` 확인). 이번에 웹 쪽 `header`→헤더 가 등재되어 같은 낱말이 두 개념을 가리키게 되므로
구분자 텍스트 쪽을 온낱말로 되돌리는 편이 좋다.

찾을 문자열 (1회):
```text
이제 시퀀스 전체에 적용한다. 첫 줄은 헤더이므로 버려야 한다.
```
교체:
```text
이제 시퀀스 전체에 적용한다. 첫 줄은 헤더 줄이므로 버려야 한다.
```

찾을 문자열 (1회):
```text
|> Seq.skip 1          // 헤더 한 줄 버리기
```
교체:
```text
|> Seq.skip 1          // 헤더 줄 버리기
```
주석 앞 공백을 그대로 두어 열 정렬을 건드리지 않는다.

찾을 문자열 (1회):
```text
헤더만 있고 데이터가 없는 파일은 흔하고
```
교체:
```text
헤더 줄만 있고 데이터가 없는 파일은 흔하고
```

찾을 문자열 (1회):
```text
헤더 한 줄을 `List.skip 1` 로 버리고
```
교체:
```text
헤더 줄을 `List.skip 1` 로 버리고
```

### 6.2 (권장) `query string`→쿼리 문자열 등재로 생긴 겹침 — 07챕터 1곳

07챕터가 검색 도메인을 설명하며 "검색 질의 문자열" 을 쓴다. HTTP 쿼리 문자열과는 다른 것이지만
`query string` 행이 "질의 문자열" 을 금지 표기로 못박았으므로 낱말을 피하는 편이 낫다.

찾을 문자열 (1회):
```text
검색 질의 문자열을 다루는 예다.
```
교체:
```text
검색어 문자열을 다루는 예다.
```

### 6.3 확인만 하고 고칠 것이 없는 것

- 00~11챕터의 "파이프라인" 은 전부 `|>` 로 이은 함수 파이프라인이다. 웹 문맥 용법이 한 곳도 없어
  `pipeline` 행에 새로 넣은 금지 조항에 걸리는 곳이 0건이다.
- 01·06챕터의 "오버로드", 11챕터의 "대괄호 인덱서", 02·08챕터의 "도우미 함수" 가 신규 등재 표기와
  글자 그대로 일치한다. 비고의 챕터 표시에 이 챕터들을 함께 적었다.
- 04챕터의 네임스페이스 아래 중첩 모듈 서술은 그대로 둔다. 14챕터 전문가가 지적한 "파일 하나가
  모듈 하나다" 는 14챕터 쪽 문장을 고칠 일이고 04챕터의 서술이 옳다.
- 컴파일러·런타임 메시지 인용은 원문 표기를 유지했다(예: "활성 패턴"·"형식"·
  `text/html is unacceptable by the server.`). 위반으로 올리지 않았다.

---

## 7. 신규 등재 60행

| 영어 | 확정 표기 | 어느 후보에서 왔나 |
|---|---|---|
| anonymous record | 익명 레코드 | 13 |
| assignment operator | 할당 연산자 | 13 |
| attribute function | 특성 함수 | 15 |
| character reference | 문자 참조 | 15 |
| compose operator (>=>) | `>=>` | 13 (정렬 자리는 병합자 결정) |
| constant pattern | 상수 패턴 | 12 |
| content negotiation | 콘텐츠 협상 | 14 (15의 "내용 협상" 기각) |
| content root | 콘텐츠 루트 | 15 |
| delegate | 델리게이트 | 13 |
| dependency injection | 의존성 주입 | 13 |
| deserialization | 역직렬화 | 14 (병합자가 별개 행으로) |
| DTO | DTO | 14 |
| element function | 요소 함수 | 15 |
| endpoint | 엔드포인트 | 13 |
| endpoint routing | 엔드포인트 라우팅 | 13 |
| escape | 이스케이프 | 15 |
| framework reference | 프레임워크 참조 | 13 |
| handler | 핸들러 | 13 |
| header (HTTP) | 헤더 | 13 |
| helper function | 도우미 함수 | 12 |
| host | 호스트 | 13 |
| `htmlView` | `htmlView` | 15 (병합자 결정) |
| HTTP method | HTTP 메서드 | 13 |
| `HttpContext` | `HttpContext` | 13 |
| `HttpFunc` | `HttpFunc` | 13 |
| `HttpFuncResult` | `HttpFuncResult` | 13 |
| `HttpHandler` | `HttpHandler` | 13 |
| indexer | 인덱서 | 14 (11챕터 용법 반영) |
| launch profile | 실행 프로필 | 13 |
| master page | 마스터 페이지 | 15 |
| middleware | 미들웨어 | 13 |
| middleware pipeline | 미들웨어 파이프라인 | 13 |
| model binding | 모델 바인딩 | 14 |
| overload | 오버로드 | 12+14 병합 |
| `parallelAsyncValidation` | `parallelAsyncValidation` | 12 |
| partial view | 부분 뷰 | 15 |
| payload | 페이로드 | 14 |
| query string | 쿼리 문자열 | 13 |
| `rawText` | `rawText` | 15 |
| request | 요청 | 14 (병합자 결정) |
| response | 응답 | 14 (병합자 결정) |
| route | 경로 | 13 |
| route parameter | 경로 매개변수 | 13 |
| route template | 경로 템플릿 | 14 |
| routing | 라우팅 | 13 |
| serialization | 직렬화 | 13 |
| serializer | 직렬화기 | 13 |
| service location | 서비스 로케이션 | 14 |
| shared framework | 공유 프레임워크 | 13 (버전 비교 실측을 병합자가 덧붙임) |
| singleton | 싱글턴 | 14 |
| static file middleware | 정적 파일 미들웨어 | 15 |
| static files | 정적 파일 | 15 |
| status code | 상태 코드 | 13+14 병합 |
| `subRoute` | `subRoute` | 13 |
| variable pattern | 변수 패턴 | 12 |
| view | 뷰 | 13 |
| View Engine | View Engine | 13+15 |
| web application | 웹 애플리케이션 | 13 |
| web framework | 웹 프레임워크 | 13 |
| web root | 웹 루트 | 15 |

---

## 8. 적용 순서 권고

1. 4.4 의 14챕터 항목은 짧은 문자열(`판별 유니온은 읽는 방향에서도 ...`)을 긴 불릿보다 먼저 적용하라.
   순서를 뒤집으면 짧은 문자열이 두 곳이 된다. 보고서에 적은 순서가 그 순서다.
2. 4.5 의 14챕터 항목보다 14챕터 전문가 보고서의 협상 규칙 보강(규칙이 다섯 개, `text/xml` 포함)을
   먼저 적용하라. 500 이 나는 이유가 그 목록에 기대고 있다.
3. 5.3 의 파일 전체 치환(`내용 협상`→`콘텐츠 협상`)은 4.5 를 적용한 뒤에 돌려라.
   순서를 뒤집으면 4.5 의 15챕터 찾을 문자열이 어긋난다.
4. 4.1 을 먼저, 4.2 를 나중에 적용하라. 두 찾을 문자열이 서로 겹치지 않는다.
5. 4.6(08챕터)과 6.1·6.2(06·07·11챕터)는 배치 C 이전 챕터 소관이므로 배치 D 적용과 분리해 처리하라.
