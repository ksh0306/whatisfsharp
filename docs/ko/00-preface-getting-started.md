# 00 - 서문과 시작하기 (원서 pp.1-7)

> 이 챕터는 F# 문법을 가르치지 않는다. 책이 무엇을 겨냥하는지, 열다섯 챕터가 어떤 순서로 쌓이는지, 그리고 코드를 실제로 돌려 보려면 무엇을 설치해야 하는지를 알려 주는 안내문이다. 여기서 얻어 갈 것은 두 가지다. 하나는 챕터 구성 지도이고, 다른 하나는 동작하는 개발 환경이다. 원서는 2023년 1월 판이라 환경 설정 부분의 버전 정보가 지금과 맞지 않는다. 이 노트는 그 부분을 2026년 현재 기준으로 바꿔 적고, 원서와 달라진 점을 함께 표시했다.

## Preface — 이 책이 겨냥하는 것 (원서 pp.1-2)

- 대상 독자는 F# 도 함수형 프로그래밍도 처음인 사람이다. C# 이나 VB.NET 경험이 있으면 도움이 되지만 전제 조건은 아니다.
- 저자는 F# 을 순수 함수형 언어로 소개하지 않는다. 범주론, 람다 대수, 모나드 같은 이론은 다루지 않겠다고 미리 선을 긋는다. 함수형 개념은 문제를 풀다가 필요해서 딸려 나오는 것으로 취급한다.
- 대신 반복해서 강조하는 표현이 함수 우선(functional-first)이다. 함수형 스타일이 기본값이지만 명령형과 객체 지향도 쓸 수 있고, 실무에서는 F# 이 권하는 방식대로 쓰는 편이 순수주의를 고집하는 것보다 오히려 쉽다는 주장이다.
- "F# 은 무엇에 좋은가"라는 물음에 저자는 커뮤니티 멤버 Dave Thomas 의 답을 인용한다. 웹, 클라우드, 머신러닝, AI, 데이터 과학 같은 목록을 늘어놓기보다 그냥 프로그래밍에 좋다는 쪽이 더 정확하다는 것이다.
- F# 은 C#, VB.NET 과 나란히 .NET 플랫폼용 범용 언어다. 2010년부터 Visual Studio 에, 이후 .NET SDK 에 함께 실려 왔고 그 사이 언어가 크게 흔들리지 않았다. 2010년에 쓴 코드가 지금도 유효할 뿐 아니라 스타일까지 비슷하다는 점을 저자는 안정성의 근거로 든다.
- F# 을 고를 이유로 저자가 꼽는 것은 다섯 가지다. 표현력 있는 타입 시스템, 정방향 파이프 연산자(forward pipe operator)로 하는 합성, 패턴 매칭, 컬렉션, 그리고 REPL. 다만 저자는 개별 기능보다 이들이 서로 맞물리는 방식이 F# 의 강점이라고 덧붙인다. 다른 언어에 있으니 따라 넣은 기능이 아니라 설계된 기능이라는 뜻이다.

이 다섯 가지는 이후 챕터에서 하나씩 다시 나온다. 타입 시스템은 1챕터와 9챕터, 합성은 2챕터, 패턴 매칭은 1챕터와 7챕터, 컬렉션은 5챕터, REPL 은 이 챕터의 F# Interactive(FSI) 절이 각각 담당한다.

## Contents — 열다섯 챕터의 구성 (원서 pp.2-4)

- 원서의 뿌리는 저자가 2020~2021년 Trustbit 블로그에 쓴 연재 두 편이다. 책으로 옮기면서 설명을 늘리고, VS Code + Ionide 환경에서 코드가 돌아가도록 손보고, F# 5 와 6 에서 들어온 기능을 반영했다.
- 다루는 범위는 Trustbit 에서 실제로 만드는 종류의 업무용 애플리케이션(LOB, Line of Business)에 필요한 핵심으로 한정된다. 타입과 함수 합성, 패턴 매칭, 테스트에서 출발해 Giraffe 라이브러리로 만든 간단한 웹사이트와 API 로 끝난다.
- 원서는 15챕터 뒤에 부록 둘을 더 붙인다. 부록 1 은 VS Code 에서 솔루션과 프로젝트를 만드는 절차(원서 pp.195-196), 부록 2 는 15챕터에서 쓰는 CSS 와 JavaScript 코드다.

| 원서 챕터 | 원서 제목 | 다루는 주제 |
|---|---|---|
| 1 | An Introductory Domain Modelling Exercise | 업무 문제 하나를 잡아 레코드, 판별 유니온, 패턴 매칭으로 도메인을 모델링해 본다 |
| 2 | Functions | 함수의 규칙, 함수 합성, 커링, 부분 적용을 다루고 시그니처를 읽는 법을 익힌다 |
| 3 | Null and Exception Handling | `Option` 과 `Result` 로 `null` 오류를 없애고 예외 발생을 줄인다 |
| 4 | Organising Code and Testing | 솔루션과 프로젝트, 네임스페이스와 모듈, 파일 순서를 정리하고 xUnit 과 FsUnit 으로 테스트를 처음 써 본다 |
| 5 | Introduction to Collections | 컬렉션 함수를 파이프라인으로 이어 데이터를 변환한다. `Seq` 와 `Array` 는 종류만 소개하고 실습은 `List` 로 한다 |
| 6 | Reading Data From a File | CSV 파일을 읽어 F# 타입으로 파싱한다. 짧은 챕터 |
| 7 | Active Patterns | 패턴 매칭을 확장해 직접 만든 매처로 코드를 단순하게 만든다 |
| 8 | Functional Validation | 6챕터에서 읽은 데이터에 검증을 붙이고, 계산 식(computation expression)을 처음 다룬다 |
| 9 | Single-Case Discriminated Unions | 원시 타입 의존을 줄이고 도메인 중심 타입으로 바꾼다 |
| 10 | Object Programming | 함수 우선 언어인 F# 이 지원하는 객체 프로그래밍 기능을 살펴본다 |
| 11 | Recursion | 누적값을 쓴 꼬리 재귀, `List.fold` 로 다시 쓰기, 퀵소트와 트리 순회를 다룬다 |
| 12 | Computation Expressions | `Option`, `Result`, `Async` 같은 효과를 다루는 일반적 장치로서 계산 식을 파고든다 |
| 13 | Introduction to Web Programming With Giraffe | Giraffe 와 Giraffe View Engine 으로 API 경로 하나와 웹 페이지 하나를 만든다 |
| 14 | Creating an API With Giraffe | 13챕터의 API 부분을 확장한다 |
| 15 | Creating Web Pages With Giraffe | Giraffe View Engine 의 기능을 더 살펴본다. 짧은 챕터 |

표의 원서 제목은 서문 Contents 절 표기를 따랐다. 9챕터는 본문 제목이 단수형 Single-Case Discriminated Union 이고, 13~15챕터는 본문 제목에서 with 가 소문자다.

읽는 순서를 고르는 데 참고할 만한 갈래는 이렇다. 1~5챕터는 건너뛰기 어려운 토대다. 6챕터와 8챕터는 이어지는 한 묶음이고, 7챕터는 8챕터의 준비물이다. 8챕터에서 맛만 본 계산 식을 12챕터가 제대로 파고들므로 두 챕터는 짝으로 읽는 편이 낫다. 12챕터를 끝낸 뒤 8챕터의 검증 예제로 돌아가 보라는 것은 원서 자신의 권고다(원서 p.153). 13~15챕터는 웹 실습이라 언어 자체를 익히는 것이 목적이면 뒤로 미뤄도 무리가 없다.

## F# Software Foundation, 저자, 감사의 말 (원서 pp.4-5)

- 저자는 F# Software Foundation 가입을 권한다. 무료이며, 가입하면 입문자용 채널이 잘 갖춰진 전용 Slack 에 들어갈 수 있다.
- 저자 소개(Ian Russell, 25년 넘게 일한 영국 개발자, Trustbit 근무)와 감사의 말(리뷰어들, Giraffe 와 Ionide 개발자들, F# 을 만든 Don Syme)은 원서 pp.4-5 에 있다. 요약할 내용은 아니다.

## Getting Started — 환경 설정 (원서 p.6)

원서가 제시하는 순서는 네 단계다. .NET SDK 설치, VS Code 설치, Ionide F# 확장 설치, 그리고 챕터별 폴더 만들기.

- 원서와 달라진 점: 원서는 출간 당시 최신인 .NET SDK 6.0.x 를 적었다. 2026년 현재 최신 LTS 는 .NET 10 이고, 이 저장소에는 SDK 10.0.111 이 설치돼 있다. F# 언어 버전은 F# 10 이다. 원서 코드는 F# 5~6 기준으로 쓰였지만 그 사이 F# 은 하위 호환을 지켜 왔으므로 원서의 F# 문법과 코어 라이브러리 예제는 .NET 10 에서도 그대로 돌아간다. 13~15챕터의 웹 실습만 Giraffe 패키지 버전과 ASP.NET Core 호스팅 API 가 달라져 있어 그 챕터에서 버전을 맞춰 적는다.
- F# 을 따로 설치하는 일은 없다. .NET SDK 를 깔면 컴파일러와 FSI 가 함께 들어온다.

설치 여부와 버전은 이렇게 확인한다.

```bash
# 현재 디렉터리에서 쓰이는 SDK 버전 (global.json 이 있으면 그 값)
dotnet --version          # 이 저장소: 10.0.111

# 설치된 SDK 목록과 런타임 목록
dotnet --list-sdks
dotnet --list-runtimes
```

- 편집기는 VS Code 와 Ionide F# 확장 조합이 원서 기준이고 지금도 유효하다. 확장 마켓플레이스에서 `Ionide.Ionide-fsharp` 를 찾아 설치한다. 명령줄에서는 `code --install-extension Ionide.Ionide-fsharp` 로 설치한다. 설치 후 창을 다시 로드해야 할 수 있다.
- Visual Studio 나 JetBrains Rider 를 쓰던 사람은 그쪽을 그대로 써도 된다. 원서 설명은 VS Code 단축키 기준이므로 다른 편집기라면 FSI 전송 단축키만 각자 환경에 맞게 찾으면 된다.
- 폴더 구성은 원서 방식대로 책 폴더 하나를 만들고 그 안에 챕터별 폴더를 두는 것으로 충분하다. 이 저장소는 노트가 `docs/ko/` 에 있고, 실습 코드는 검증 스크립트가 시스템 임시 경로로 뽑아 실행한다. 뽑아낸 스크립트를 직접 보고 싶으면 `KEEP=1` 을 붙여 실행하면 경로를 알려 준다.

프로젝트를 만들어 돌려 보는 명령은 다음과 같다. `-lang "F#"` 을 빼면 C# 프로젝트가 생기므로 반드시 붙인다.

```bash
# F# 콘솔 프로젝트 생성
dotnet new console -lang "F#" -o HelloFSharp

# 실행
dotnet run --project HelloFSharp    # 출력: Hello from F#
```

- 생성된 `.fsproj` 의 `TargetFramework` 는 `net10.0` 이고, `ItemGroup` 안에 `<Compile Include="Program.fs" />` 가 들어 있다. C# 과 달리 F# 프로젝트는 컴파일 대상 파일을 프로젝트 파일에 순서대로 나열한다. 이 순서가 왜 중요한지는 4챕터에서 다룬다.
- 4챕터의 테스트 실습에 필요한 템플릿도 SDK 에 함께 들어 있다. `dotnet new xunit -lang "F#"` 으로 만든다.
- 4챕터는 솔루션 하나에 코드 프로젝트와 테스트 프로젝트를 나눠 담는 구성에서 출발한다. 그 절차는 원서 본문이 아니라 부록 1(원서 pp.195-196)에 있다. `dotnet new sln` 으로 솔루션을 만들고 `dotnet sln add` 로 두 프로젝트를 넣는다. 그다음 테스트 프로젝트에서 `dotnet add reference` 로 코드 프로젝트를 참조하고 `dotnet add package FsUnit.xUnit` 을 더한다.

## F# Interactive (FSI) (원서 p.6)

- FSI 는 F# 의 REPL 이다. C# 의 Interactive Window 와 비슷한 위치이지만 쓰는 방식의 무게가 다르다. 저자는 F# 개발에서 중단점을 걸고 디버깅한 일이 한 번도 없다고 적는다. 코드가 맞는지 확인하는 수단이 디버거가 아니라 FSI 라는 것이다.
- VS Code 에서는 터미널 패널에 F# Interactive 창이 하나 더 생긴다. 여기에 직접 입력할 수도 있지만, 실제 작업은 파일에 쓴 코드를 골라 FSI 로 보내는 방식으로 한다.
- 코드를 골라 `ALT+ENTER` 를 누르면 그 부분이 FSI 로 넘어가 컴파일되고 실행된다. FSI 는 컴파일한 결과를 메모리에 남겨 두므로, 앞서 보낸 정의를 뒤에서 이어 쓸 수 있다.
- FSI 창에 직접 타이핑할 때는 입력 끝에 세미콜론 두 개 `;;` 를 붙여야 실행된다. 파일에서 보내는 경우에는 필요 없다.
- 원서와 달라진 점: 원서는 명령줄 FSI 를 범위 밖이라고 적었지만, 이 저장소의 검증 스크립트는 `dotnet fsi <파일>.fsx` 를 쓴다. `id` 가 붙은 코드 블록은 전부 이 명령으로 실행되므로 알아 두는 편이 낫다.

```bash
# 스크립트 파일을 명령줄에서 실행
dotnet fsi smoke.fsx

# 표준 입력으로 밀어 넣어 실행 (정의마다 val 줄이 보인다)
dotnet fsi --nologo < smoke.fsx

# 대화형 세션으로 진입 (입력 끝에 ;; 필요, #quit;; 으로 종료)
dotnet fsi
```

아래는 설치 직후 환경이 제대로 동작하는지 확인하는 최소 스크립트다. 파일로 저장해 `dotnet fsi smoke.fsx` 로 돌리거나, VS Code 에서 전체를 골라 `ALT+ENTER` 로 FSI 에 보내거나, 명령 팔레트에서 `FSI: Send File` 을 쓰면 된다.

```fsharp id=00-fsi-smoke-test
// 이 단위가 보여주는 것: 값 바인딩, 함수 바인딩, FSI 의 정의 유지, 런타임 버전 확인

// 값 바인딩: string
let greeting = "F# 환경 확인 완료"
printfn "%s" greeting                    // 기대: F# 환경 확인 완료
```

`let` 은 이름과 값을 묶는 바인딩(binding)이다. 매개변수가 없으면 값 바인딩, 하나 이상 있으면 함수 바인딩이다. 아래 `add` 는 매개변수가 둘이라 함수 바인딩이다.

```fsharp id=00-fsi-smoke-test
// 함수 바인딩: int -> int -> int
let add a b = a + b
printfn "add 19 23 = %d" (add 19 23)     // 기대: add 19 23 = 42
```

- `add` 의 시그니처를 FSI 로 실측하면 `val add: a: int -> b: int -> int` 가 나온다. 타입 주석(type annotation)을 하나도 적지 않았는데 `int` 로 정해진 것은 `+` 의 타입 추론(type inference) 결과다. 화살표가 두 개 보이는 이유, 곧 매개변수가 둘인 함수가 왜 `int -> int -> int` 로 적히는지는 2챕터의 커링(currying) 절에서 다룬다.
- FSI 는 대화형 세션에서 값이나 함수를 정의할 때마다 `val <이름>: <시그니처>` 를 되돌려 준다. VS Code 에서 `ALT+ENTER` 로 보낼 때, 그리고 `dotnet fsi` 로 진입한 세션에 직접 입력할 때가 그렇다. 반면 `dotnet fsi <파일>.fsx` 로 스크립트를 실행하면 `printfn` 출력만 나오고 `val` 줄은 나오지 않는다. 스크립트 파일의 시그니처를 보려면 `dotnet fsi --nologo < smoke.fsx` 처럼 표준 입력으로 밀어 넣어 대화형 세션으로 실행한다.
- 이 줄을 읽는 습관이 F# 학습의 절반이다. 노트에서 시그니처를 주석으로 적을 때도 손으로 예상한 값이 아니라 FSI 가 출력한 값을 그대로 옮긴다.

FSI 가 정의를 세션에 남겨 둔다는 것은 이렇게 확인한다. 앞 블록에서 만든 두 정의가 그대로 살아 있다.

```fsharp id=00-fsi-smoke-test
// 앞 블록의 greeting 과 add 를 그대로 쓸 수 있다. FSI 는 정의를 세션에 남겨 둔다
printfn "%s (%d)" greeting (add 40 2)    // 기대: F# 환경 확인 완료 (42)
```

마지막으로 실행 중인 런타임을 찍어 설치 상태를 확인한다.

```fsharp id=00-fsi-smoke-test
// 실행 중인 런타임. SDK 와 메이저·마이너 버전이 같은지 눈으로 확인한다
printfn "런타임 = %s" System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription
// 이 저장소 출력 예: 런타임 = .NET 10.0.11 (SDK 10.0.111 과 앞의 10.0 이 같다)
```

위 블록들이 오류 없이 돌아가면 환경 설정은 끝났다. 같은 `id` 를 쓴 블록은 문서 순서대로 이어 붙어 하나의 스크립트로 실행된다.

## Script Files vs Code Files (원서 p.6)

- F# 파일은 두 종류다. 스크립트 파일 `.fsx` 와 코드 파일 `.fs`. 원서는 두 종류를 모두 쓴다.
- 가장 큰 차이는 프로젝트 파일이 필요한지에 있다. `.fsx` 는 혼자 실행된다. `dotnet fsi <파일>.fsx` 로 바로 돌아가고, 필요한 패키지와 다른 스크립트를 `#r "nuget: ..."` 와 `#load "다른.fsx"` 로 자기 안에서 직접 끌어온다. `.fs` 는 의존성을 `.fsproj` 에서 받는다.
- 이 두 지시문(compiler directive)은 컴파일러가 확장자를 보고 막는다. `.fs` 에 `#r` 을 쓰면 `error FS0076` 이 난다. `dotnet fsi` 로 `.fs` 파일을 넘기는 것 자체는 되지만, 그 파일이 모듈이나 네임스페이스 선언으로 시작해야 하고 그렇지 않으면 `error FS0222` 가 난다. `.fsx` 는 그런 선언 없이 그냥 돌아간다.
- 빌드 쪽은 관행의 문제다. SDK 템플릿이 `.fs` 만 `Compile` 항목에 넣기 때문에 보통 `.fs` 만 `.exe` 나 `.dll` 로 빌드된다. `.fsx` 를 `Compile` 에 직접 적으면 빌드 자체는 된다.
- 어느 쪽 파일이든 코드를 골라 `ALT+ENTER` 로 FSI 에 보내 실행할 수 있다. 파일 확장자가 FSI 전송을 막지는 않는다.
- 실무 감각으로 정리하면 이렇다. 개념을 확인하거나 데이터를 한 번 훑어보는 작업은 `.fsx` 에서 하고, 빌드해 배포할 코드는 `.fs` 에 넣는다. 이 노트에서 `id` 가 붙은 코드 블록은 모두 `.fsx` 로 뽑혀 검증된다.

지시문의 모양만 미리 보면 이렇다. 13챕터부터 Giraffe 패키지를 끌어올 때 이 두 줄을 쓴다.

```fsharp
// .fsx 에서만 쓸 수 있는 지시문. .fs 에 쓰면 error FS0076 이다
#r "nuget: FsUnit.xUnit"
#load "Helpers.fsx"
```

## VS Code 와 Ionide, 그리고 마지막 한마디 (원서 p.7)

- VS Code + Ionide 조합은 Visual Studio 나 Rider 만큼 기능이 많지는 않다. 다만 저자는 F# 코드베이스를 다루는 데 그렇게 많은 기능이 필요하지 않다고 본다. 규모가 큰 코드베이스도 마찬가지라는 것이다.
- Ionide 는 VS Code 확장 하나로 끝나지 않는 프로젝트다. 원서는 Ionide 쪽 문서를 한 번 둘러보라고 권하고, VS Code + F# 단축키를 소개하는 Compositional-IT 의 YouTube 재생목록도 링크로 걸어 둔다.
- 저자가 마지막에 붙인 당부는 하나다. 책에 코드가 많이 나오는데 복사해 붙이지 말고 직접 타이핑하라는 것이다. 손으로 쳐 보는 쪽이 더 많이 남는다는 경험담이다.

이 노트의 코드도 같은 태도로 다루는 편이 좋다. 블록을 그대로 실행해 출력만 확인하고 넘어가기보다, 값을 바꿔 보고 타입을 일부러 틀리게 만들어 컴파일 오류 메시지를 읽어 보는 쪽이 남는 것이 많다.

## 정리

- 이 챕터에서 실제로 챙길 것은 챕터 구성 지도와 동작하는 환경, 이 둘뿐이다. F# 문법은 1챕터부터 시작한다.
- .NET SDK 하나를 설치하면 F# 컴파일러와 FSI 가 함께 들어온다. F# 을 별도로 설치하는 절차는 없다.
- 원서의 .NET 6 기준 서술은 2026년 현재 .NET 10 으로 읽으면 된다. F# 문법과 코어 라이브러리 예제는 하위 호환이 지켜져 그대로 동작하고, 13~15챕터의 웹 실습만 패키지 버전을 맞춰야 한다.
- FSI 는 F# 개발의 기본 도구다. 중단점 디버깅 대신 코드를 골라 FSI 로 보내 확인하는 흐름이 표준이다. VS Code 에서는 `ALT+ENTER`, 명령줄에서는 `dotnet fsi` 다.
- FSI 가 대화형 세션에서 되돌려 주는 `val <이름>: <시그니처>` 줄을 읽는 습관을 여기서부터 들여 두는 것이 좋다. 2챕터부터는 이 줄이 설명의 중심이 된다.
- `.fsx` 는 프로젝트 파일 없이 혼자 돌고 `#r`·`#load` 지시문을 쓸 수 있다. `.fs` 는 프로젝트에 담아 빌드한다. FSI 전송은 둘 다 된다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Preface — 이 책이 겨냥하는 것 | pp.1-2 | — |
| Contents — 열다섯 챕터의 구성 | pp.2-4 | — |
| F# Software Foundation, 저자, 감사의 말 | pp.4-5 | — |
| Getting Started — 환경 설정 | p.6 | — |
| F# Interactive (FSI) | p.6 | `00-fsi-smoke-test` |
| Script Files vs Code Files | p.6 | — |
| VS Code 와 Ionide, 그리고 마지막 한마디 | p.7 | — |
