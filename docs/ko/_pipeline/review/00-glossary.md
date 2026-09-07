# 00챕터 용어 후보 (F# 전문가 검수, 후보 모드)

`docs/ko/GLOSSARY.md` 는 이 세션에서 편집하지 않았다. 아래 표를 그대로 병합하면 된다.
표기 원칙은 `docs/ko/GLOSSARY.md` 머리말을 따랐다(`type`은 "타입", 정착 역어 우선, 없으면 음차, 타입 이름은 원어).

## A. 이 챕터가 소유 — 확정 (GLOSSARY.md 에 그대로 추가)

집필자가 판단을 요청한 세 항목은 모두 집필자가 쓴 표기를 채택한다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| backward compatibility | 하위 호환 | 명사형은 "하위 호환성". MS ko 는 "이전 버전과의 호환성"이나 길어서 쓰지 않는다 |
| breakpoint | 중단점 | MS ko 표기와 일치. "브레이크포인트" 쓰지 않음 |
| code file | 코드 파일 | `.fs`. 프로젝트가 빌드에 포함하는 쪽 |
| compiler directive | 지시문 | `#r`, `#load`, `#I`, `#time`. MS ko 표기와 일치. `#r`/`#load` 는 `.fsx`/`.fsscript` 에서만 쓸 수 있고 `.fs` 에서 쓰면 `error FS0076` 이다 |
| F# Interactive | FSI | 번역하지 않는다. 첫 등장만 `FSI(F# Interactive)`. 명령줄 진입점은 `dotnet fsi` |
| functional-first | 함수 우선 | 확정. MS 공식 한국어 F# 문서가 "함수 우선"을 쓴다. "함수형 우선"으로 늘려 쓰지 않는다. 순수 함수형(purely functional)과 구별되는 말이므로 "함수형 언어"로 뭉개지 말 것 |
| general-purpose language | 범용 언어 | |
| Line of Business (LOB) | 업무용 애플리케이션 | 확정. 원어 약어 LOB 는 첫 등장에서 `업무용 애플리케이션(LOB, Line of Business)` 으로 한 번만 병기하고 이후 한국어만 쓴다. MS ko 는 "기간 업무 애플리케이션"을 쓰지만 뜻이 바로 오지 않아 채택하지 않는다 |
| REPL | REPL | 확정. 원어 유지. read-eval-print loop 를 음차하거나 "대화형 셸"로 풀지 않는다. F# 의 REPL 이 FSI 다 |
| runtime | 런타임 | 음차 고정. `System.Environment.Version` / `RuntimeInformation.FrameworkDescription` 이 돌려주는 값이 이것이고, SDK 버전과 다르다 |
| script file | 스크립트 파일 | `.fsx`. 프로젝트 파일 없이 `dotnet fsi` 로 바로 실행되는 쪽 |
| SDK | SDK | 번역하지 않는다. `.NET SDK`. 컴파일러(`fsc`)와 FSI 가 함께 들어 있다 |
| solution | 솔루션 | 음차 고정. `dotnet new sln` |
| target framework | 대상 프레임워크 | MS ko 표기와 일치. `.fsproj` 의 `TargetFramework` 속성은 원어 백틱으로 쓴다 |
| template | 템플릿 | `dotnet new console`, `dotnet new xunit` |

## B. 00챕터가 처음 쓰지만 소유는 뒤 챕터 — 병합 시 조율 필요

00챕터의 챕터 구성 표에서 이 용어들이 문서 전체 기준 첫 등장이 된다. 뒤 챕터 담당자가
같은 항목을 올릴 수 있으니 표기만 아래로 맞추면 충돌이 없다. 항목 자체는 소유 챕터가 확정하면 된다.

| 영어 | 한국어 표기 | 소유 챕터 | 비고 |
|---|---|---|---|
| collection | 컬렉션 | 5 | 음차 고정. "모음/집합" 쓰지 않음(집합은 `Set`) |
| computation expression | 계산 식 | 8, 12 | MS ko 표기와 일치. `expression`→식 과 맞물린다. "계산 표현식" 금지. 00챕터 표(8행)에서 병기가 이미 소진되므로 8챕터는 병기 없이 "계산 식"만 쓴다 |
| effect | 효과 | 12 | `Option`, `Result`, `Async` 를 묶어 부르는 말. `side effect`(부수 효과)와 다른 개념이니 같은 문서에서 쓸 때 구별해 적는다 |
| pattern matching | 패턴 매칭 | 1 | 음차 고정. GLOSSARY.md 에 아직 없다 |
| primitive | 원시 타입 / 원시 값 | 9 | `int`, `string` 등. MS ko 는 "기본 형식"이나 이 노트는 "형식"을 쓰지 않으므로 "원시"를 택한다 |

## C. 기확정 항목 변경 제안

없다. 00챕터가 쓴 기존 용어(`정방향 파이프 연산자`, `바인딩`, `값 바인딩`, `함수 바인딩`,
`타입 추론`, `타입 주석`, `커링`, `시그니처`, `판별 유니온`, `레코드`, `부분 적용`)는 모두
GLOSSARY.md 표기와 일치한다. 뒤집을 근거가 없다.
