# 04챕터 용어 후보 (F# 전문가 검수, 후보 모드)

`docs/ko/GLOSSARY.md` 는 이번에 편집하지 않았다(다른 챕터 전문가와 동시 작업 중).
아래 행을 알파벳 순 위치에 그대로 삽입하면 된다.

## 확정 제안 (그대로 삽입)

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| assembly | 어셈블리 | 프로젝트 하나가 컴파일된 결과물 `.dll`. MS ko 표기와 일치 |
| assertion | 어서션 | MS ko 는 "어설션", 일부 문서는 "단정문". 외래어 표기법대로 읽은 "어서션"을 택한다. `Assert.Equal`, `should equal` 같은 검증 한 줄을 가리킨다 |
| attribute | 특성 | `[<Fact>]`, `[<RequireQualifiedAccess>]`. MS ko 표기와 일치. "어트리뷰트"도 통용되나 "타입" 과 충돌하지 않으므로 MS 표기를 택한다 |
| circular reference | 순환 참조 | 프로젝트 A 가 B 를, B 가 A 를 참조하는 상태. F# 파일 사이의 관계를 말할 때는 "순환 의존" |
| compile order | 컴파일 순서 | `.fsproj` 의 `<Compile Include=... />` 가 적힌 순서. F# 에서 의미를 갖는다 |
| import declaration | `open` 선언 | 원서와 F# 명세는 "import declaration". 노트는 실제 키워드를 드러내는 "`open` 선언"을 쓴다 |
| Ionide | Ionide | 음차가 "아이오나이드"/"이오니데"로 갈려 라틴 표기로 고정. VS Code 의 F# 확장 |
| module | 모듈 | 음차 고정. 값·함수·타입·모듈을 담는 F# 의 코드 묶음 단위 |
| namespace | 네임스페이스 | 음차 고정. MS ko 도 "네임스페이스". 타입·`open` 선언·모듈만 담는다 |
| nested module | 중첩 모듈 | `module X =` 로 다른 모듈 안에 둔 모듈. MS ko 표기와 일치 |
| project | 프로젝트 | 음차 고정. 컴파일 단위이자 어셈블리 하나에 대응한다 |
| project reference | 프로젝트 참조 | `dotnet add reference` 로 거는 관계 |
| qualified name | 정규화된 이름 | `Inventory.Create.item` 처럼 모듈 이름을 앞에 붙인 이름. MS ko 표기와 일치. 동작을 말할 때는 "정규화된 접근" |
| shadowing | 이름 가림 | 나중에 `open` 한 모듈의 같은 이름이 앞의 것을 가리는 일. "섀도잉"도 통용되나 뜻이 바로 읽히는 "이름 가림"을 택한다 |
| solution | 솔루션 | 음차 고정. 프로젝트를 묶은 목록이며 그 자체가 컴파일되지는 않는다 |
| target framework | 대상 프레임워크 | `net10.0`. MS ko 표기와 일치 |
| test runner | 테스트 러너 | 테스트를 찾아 실행하는 쪽. 노트 429줄의 "테스트 실행 장치"를 이 표기로 바꿀 것을 권한다 |
| top-level module | 최상위 모듈 | 파일 첫 줄의 `module X` / `module X.Y`. `=` 없이 적고 이름이 프로젝트 전체에서 유일해야 한다 |
| unit test | 단위 테스트 | MS ko 표기와 일치. 01챕터·03챕터에서 이미 이 표기를 썼다 |

## 고유명사 표기 고정

| 표기 | 비고 |
|---|---|
| xUnit | 공식 이름은 xUnit.net 이고 소문자 x 로 시작한다. 원서는 "XUnit" 으로 적지만 노트는 "xUnit" 으로 쓴다. `docs/ko/01-domain-modelling.md:350` 에 "XUnit" 이 남아 있어 고쳐야 한다 |
| FsUnit | 어서션 라이브러리. NUnit 용 패키지 이름이 `FsUnit`, xUnit 용이 `FsUnit.xUnit`(NuGet 등록 대소문자 그대로) |
| NUnit / MSTest / Expecto | 라틴 표기 그대로 |
| `Xunit` | F# 코드에서 `open` 하는 xUnit 의 네임스페이스. 이름 자체이므로 백틱 원어. FsUnit 쪽은 `FsUnit.Xunit` |
| .slnx / .sln | 확장자는 원어 그대로 |

## 판단 근거를 남긴 항목

- `assertion` → 어서션: MS ko 는 "어설션"(Debug.Assert 문서), 테스트 관련 번역서는 "단언"/"단정문"도 쓴다.
  세 가지가 갈리므로 원어 발음을 외래어 표기법대로 옮긴 "어서션" 하나로 고정한다.
- `solution`/`project`: "해법"/"과제" 같은 역어는 통용되지 않는다. 음차 고정.
- `Ionide`: 개발자 본인들도 발음을 통일해 부르지 않는다. 라틴 표기 고정이 안전하다.
- `shadowing`: "가려짐", "은닉"(→ information hiding 과 혼동), "섀도잉" 중에서
  노트가 이미 쓰고 있는 서술형 "이름 가림"을 표준으로 삼는다.
