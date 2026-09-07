# 17챕터 전문가 검수 — 부록 1: VS Code 에서 솔루션과 프로젝트 만들기

검수 대상: `docs/ko/17-appendix-1-solution-setup.md` (222행)
원문: `.cache/src/17-appendix-1-solution-setup.txt` (원서 pp.195-196)
대조: `docs/ko/04-organising-code-and-testing.md`, `docs/ko/00-preface-getting-started.md`

실측 환경: .NET SDK 10.0.111, F# 10, VSTest 18.0.2. 임시 디렉터리에서 전 과정을 세 번
새로 돌렸고 확인 뒤 지웠다. `verify-examples.sh` 는 `17-shipping` PASS, `check-note.sh` 는
위반 없음이다. 집필자가 보고한 실측값은 아래 "확인 완료" 에 적은 것 전부가 재현됐다.
아래 지적은 재현이 안 된 것과 04챕터와 갈린 것만이다.

## 수정 필요 (기술 오류)

- [17:101-111] `ShopTests.fsproj` XML 블록이 실제 결과와 다르다. `FsUnit.xUnit` 은
  자기 `<ItemGroup>` 을 새로 얻지 않는다. 템플릿이 이미 만들어 둔 패키지 `<ItemGroup>` 안에
  이름 순으로 끼어든다(실측: `coverlet.collector` 다음, `Microsoft.NET.Test.Sdk` 앞).
  새 `<ItemGroup>` 을 얻는 것은 `<ProjectReference>` 쪽뿐이다. 지금 블록을 보면 독자가
  `.fsproj` 에 `<ItemGroup>` 이 하나 더 붙는다고 읽는다. 산문의 "템플릿이 이미 넣어 둔 패키지
  넷은 그대로 남는다" 도 그 오해를 굳힌다.
  산문 한 줄을 이렇게 바꾸고
  `두 명령을 돌린 뒤 `tests/ShopTests/ShopTests.fsproj` 의 `<ItemGroup>` 두 개가 이렇게 된다. `FsUnit.xUnit` 은 템플릿이 만들어 둔 패키지 `<ItemGroup>` 안에 이름 순으로 끼어들고, 프로젝트 참조만 새 `<ItemGroup>` 을 하나 얻는다.`
  블록을 실측한 그대로 갈아라.
  ```xml
  <ItemGroup>
    <PackageReference Include="coverlet.collector" Version="6.0.4" />
    <PackageReference Include="FsUnit.xUnit" Version="7.1.1" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="xunit" Version="2.9.3" />
    <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\src\Shop\Shop.fsproj" />
  </ItemGroup>
  ```

- [17:153] `Shipping.fs` 를 `Program.fs` 앞에 두는 이유가 틀렸다. "`Program.fs` 가 이 파일을
  쓰므로 위에 온다" 고 적었으나, 이 부록의 절차에서 `Program.fs` 는 템플릿이 만든
  `printfn "Hello from F#"` 한 줄 그대로이고 `feeFor` 를 부르지 않는다. 그런데도 순서를
  뒤집으면 빌드는 실패한다. 실측하면 나오는 것은 사용처 오류 FS0039 가 아니라 오류 FS0222 다.
  템플릿 `Program.fs` 에는 모듈 선언이 없고, 선언을 생략할 수 있는 것은 애플리케이션의 마지막
  파일 하나뿐이기 때문이다. 이 규칙이 4챕터 노트에 있으므로 그리로 넘기는 문장도 함께 넣어라.
  교체 문장:
  `이 코드를 `src/Shop/Shipping.fs` 로 저장했다면 `Shop.fsproj` 의 컴파일 목록에 적어야 한다. 자리는 `Program.fs` 앞이다. `Program.fs` 에서 `feeFor` 를 부를 생각이면 정의가 앞에 와야 하고, 부르지 않아도 순서를 뒤집으면 빌드가 실패한다. 템플릿이 만든 `Program.fs` 에는 모듈 선언이 없고 선언을 생략할 수 있는 파일은 마지막 하나뿐이라, `Shipping.fs` 를 뒤에 적으면 오류 FS0222 가 난다. 이 규칙은 4챕터 노트에 있다.`

- [17:199] "원서와 달라진 점" 표의 `dotnet sln add` 행이 SDK 버전 차이가 아니다. 프로젝트 경로에서
  솔루션 폴더를 만드는 것은 SDK 10 에서 새로 생긴 동작이 아니다. `dotnet sln add --help` 가
  `--in-root ... [default: False]` 로 적고 있고, `--in-root` 는 오래된 옵트아웃이다.
  게다가 `-f sln` 으로 만든 `.sln` 에도 같은 폴더가 SolutionFolder 항목과 NestedProjects 절로
  들어간다(실측). 즉 달라진 것은 폴더가 생기느냐가 아니라 그것을 적는 표기다.
  표 행을 이렇게 바꾸고
  `| `dotnet sln add` 결과 표기 | `.sln` 의 SolutionFolder 항목 | `.slnx` 의 `<Folder Name="/src/">` |`
  78행 불릿 뒤에 실측 한 줄을 보태라.
  `- 경로에서 솔루션 폴더를 만드는 것은 지금 SDK 에서 새로 생긴 동작이 아니다. `dotnet sln add` 의 `--in-root` 가 이 동작을 끄는 옵션이고 기본값은 끄지 않는 쪽이다. `-f sln` 으로 만든 `.sln` 에도 같은 폴더가 들어간다. SDK 10 에서 달라진 것은 그 폴더를 적는 표기뿐이다.`
  같은 서술이 4챕터 노트 50행에도 "원서와 현재 SDK 의 차이" 둘째 항목으로 들어 있다.
  두 노트가 같은 근거를 공유하므로 4챕터도 함께 손봐야 한다(아래 "04챕터에 함께 넘길 것" 참고).

- [17:200] 표의 원서 대상 프레임워크를 `net6.0` 으로 단정했는데 근거가 약하고 4챕터와 갈린다.
  원서가 인쇄한 유일한 대상 프레임워크 표기는 4챕터 테스트 출력의 `net5.0` 이다(원문 p.52).
  서문(원문 p.197)이 "6.0.x at time" 이라고 적은 것에서 `net6.0` 을 추론할 수는 있으나
  단정할 값은 아니다. 4챕터 노트 50행은 이 대목을 "`net5.0`/`net6.0`" 으로 병기해 두었다.
  같은 사실을 두 노트가 다르게 적으면 독자가 어느 쪽을 믿을지 알 수 없다. 4챕터 쪽에 맞춰라.
  `| 대상 프레임워크 | `net5.0`(원서가 인쇄한 출력 표기. SDK 6.0.x 기준이면 `net6.0`) | `net10.0` |`

- [17:162] BOM 불릿의 뒷부분이 실측과 다르다. "인코딩을 맞춰 주지 않으면 첫 줄이 깨진다" 는
  성립하지 않는다. `.fsproj` 와 `.fs` 에서 BOM 을 떼고 빌드해도 성공하고, 한글 이중 백틱
  이름이 든 테스트 파일에서 BOM 을 떼도 세 테스트가 그대로 통과한다(실측). 실제로 물리는 곳은
  다른 데다. BOM 세 바이트가 첫 줄 맨 앞에 있어서 `^<Project` 처럼 줄 앞을 잡는 패턴이
  조용히 안 맞는다(실측: `sed -i 's|^<Project|...|'` 가 아무것도 바꾸지 않는다).
  교체 문장:
  `- 템플릿이 만든 `.fsproj` 와 `.fs` 는 BOM 이 붙은 UTF-8 이다(`.slnx` 는 BOM 이 없다). BOM 을 떼도 빌드는 성공하므로 인코딩 자체가 문제가 되지는 않는다. 걸리는 것은 스크립트로 치환할 때다. BOM 세 바이트가 첫 줄 맨 앞에 있어서 `^<Project` 처럼 줄 앞을 잡는 패턴이 아무 말 없이 안 맞는다. 편집기로 고칠 때는 이 문제가 없다.`

- [17:206] "명령 여덟 줄" 이 셈이 맞지 않는다. 스크립트에서 `set -euo pipefail` 과 주석을 뺀
  실행 줄은 열 줄이다(`dotnet new sln`, `cd`, `mkdir`, `dotnet new console`,
  `dotnet new xunit`, `dotnet sln add`, `dotnet add reference`, `dotnet add package`,
  `dotnet build`, `dotnet test`). 이어 열거한 여덟 가지는 줄이 아니라 단계이고,
  그중 "프로젝트 둘 만들기" 하나가 두 줄이며 `cd` 는 열거에 없다.
  `이 부록의 알맹이는 여덟 단계다.` 로 바꿔라(뒤 열거는 그대로 두면 맞는다).

## 개선 권장

- [17:16] `CTRL+SHIFT+'` 를 두고 "인쇄 과정에서 백틱이 바뀐 것으로 보인다" 고 원인까지 지목한
  대목은 근거보다 한 발 나갔다. 추정임을 밝힌 처리 자체는 옳다. 문제는 지목한 기제다.
  원문 바이트를 보면 그 글자는 U+2019(`e2 80 99`)이고, 같은 원문이 `doesn't` 의 아포스트로피와
  `'setup.txt'` 의 인용부호에도 똑같이 U+2019 를 쓴다. 즉 곧은 따옴표가 둔 따옴표로 바뀐 흔적이지
  백틱(U+0060)이 바뀐 흔적이라고 볼 근거는 없다. 확인 가능한 것만 남기고 원인 지목을 빼라.
  `- 통합 터미널을 새로 연다. VS Code 의 기본값은 `CTRL+SHIFT+백틱` 이고, 이미 열린 패널을 접었다 펴는 것은 `CTRL+백틱` 이다. 원서 표기는 `CTRL+SHIFT+'` 로 백틱이 아닌 따옴표다. 원서가 어느 키를 가리켰는지는 확인할 방법이 없으니 편집기 기본값을 따르면 된다.`

- [17:23] `set -euo pipefail` 을 통합 터미널에 골라 보내면 안 된다는 경고가 빠졌다. 이 절이
  원서의 "선택 텍스트를 터미널로 보내기" 와 대비되는 자리이므로 독자가 첫 줄만 보내 볼 소지가
  크다. 대화형 셸에서 `set -e` 가 걸린 뒤 명령 하나가 실패하면 그 셸이 그대로 종료된다(실측:
  `bash -i` 에 먹인 `false` 다음 줄이 실행되지 않는다). 단락 끝에 한 줄 보태라.
  `- 이 첫 줄은 파일에 넣어 `bash setup.sh` 로 돌릴 때만 쓴다. 통합 터미널에 골라 보내면 뒤이어 실패하는 명령 하나에 그 터미널이 닫힌다.`

- [17:23, 17:207] "첫 줄의 `set -euo pipefail`" 은 블록과 어긋난다. 블록 첫 줄은 주석이고
  `set` 은 둘째 줄이다. "맨 앞의" 로 바꾸면 두 곳 다 맞는다.

- [17:46] 재실행 실패 서술의 순서가 실제 실행과 어긋난다. `set -e` 가 걸려 있으므로
  `dotnet new sln` 이 종료 코드 73 으로 멈춘 뒤 `mkdir src tests` 는 아예 실행되지 않는다.
  `mkdir` 이 실패하는 것은 스크립트를 부분적으로 골라 다시 돌릴 때다. 또 CLI 가 스스로
  안내하는 `--force` 를 적어 두면 독자가 메시지를 읽고 헤매지 않는다.
  `- 이 스크립트는 같은 자리에서 두 번 돌릴 수 없다. `dotnet new sln` 이 기존 `.slnx` 를 덮어쓰겠다는 확인을 요구하며 종료 코드 73 으로 멈추고, `set -e` 때문에 뒤 명령은 실행되지 않는다. 메시지가 안내하는 `--force` 를 붙이면 덮어쓰기까지 진행한다. 스크립트를 부분적으로 골라 다시 돌리면 `mkdir src tests` 도 걸린다. 다시 만들 때는 솔루션 디렉터리를 지우고 처음부터 돌리는 것이 깔끔하다.`

- [17:130] 콘솔 프로젝트 실행 형태가 4챕터와 다르다. 4챕터 노트 42-46행은 원서를 따라
  `cd src/Shop` 뒤 `dotnet run` 을 쓰고, 이 노트는 `dotnet run --project src/Shop` 을 쓴다.
  둘 다 `Hello from F#` 이 나오므로 오류는 아니다. 다만 이 노트가 44행에서 `cd` 를 피하는
  이유를 따로 설명한 만큼, 같은 이유로 골랐다는 것과 4챕터의 형태를 함께 밝히는 편이
  독자가 두 노트를 겹쳐 읽을 때 걸리지 않는다.
  `- 콘솔 프로젝트를 돌리려면 `dotnet run --project src/Shop` 을 쓴다. 앞의 `dotnet add` 와 같은 이유로 `cd` 를 피한 형태이고, 4챕터 노트가 쓴 `cd src/Shop` 뒤 `dotnet run` 과 결과가 같다. 템플릿이 넣은 한 줄이 `Hello from F#` 을 출력한다.`

- [17:44] "원서 스크립트와 다른 점이 셋이다" 가 실제 차이를 다 세지 못한다. 원서는
  `mkdir src` → `dotnet new console` → `dotnet sln add` → `mkdir tests` →
  `dotnet new xunit` → `dotnet sln add` 로 갈라 적고, 이 노트는 `mkdir src tests` 와
  `dotnet sln add` 한 번으로 묶었다. `-lang F#` 을 `-lang "F#"` 으로 바꾼 것도 차이다.
  묶은 이유는 78행에, 따옴표는 4챕터 노트 20행에 이미 있으므로 여기서는 셈만 고치면 된다.
  `원서 스크립트와 달라진 것 중 짚어 둘 것이 셋이다.` 로 열고, 불릿 끝에 한 줄 보태라.
  `- 이 밖에 `mkdir` 두 줄과 `dotnet sln add` 두 줄을 각각 한 줄로 묶었다(이유는 아래에 적었다).`

- [17:202] 표의 "xUnit 템플릿이 넣는 패키지" 행은 원서와 달라진 점이 아니다. 원서 칸이
  "원서는 나열하지 않는다" 인 것이 그 증거다. 위 수정으로 103행 XML 블록이 패키지 넷을
  버전째로 그대로 보여주게 되므로 이 행은 중복이 된다. 행을 지우고, 필요하면 XML 블록 뒤
  불릿에 "버전은 SDK 10.0.111 의 xUnit 템플릿 기준이다" 한 줄만 남겨라. 같은 이유로
  "어서션 패키지" 행(201행)도 SDK 버전 차이가 아니라 이 노트의 편집 판단이다. 표에 남기려면
  표 앞머리를 `아래는 원서 이후 달라진 것과 이 노트가 달리 잡은 것이다.` 로 넓혀라.

- [17:3, 17:19] 노트 파일 이름을 본문에서 직접 부르는 교차 참조가 이 노트에만 있다.
  다른 열일곱 노트는 전부 `N챕터`/`N챕터 노트` 로 부르고, 서문은 16챕터가 여섯 번
  "서문 챕터" 로 부른다. STYLE.md 의 `N챕터` 통일 규칙과도 어긋난다.
  3행의 `` `04-organising-code-and-testing.md` 에 있고 ``→`4챕터 노트에 있고`,
  `` `00-preface-getting-started.md` 에 있다``→`서문 챕터에 있다`,
  19행의 `서문 노트(`00-preface-getting-started.md`)에서`→`서문 챕터에서` 로 바꿔라.
  용어 후보 파일에 `preface chapter` 행으로 근거를 남겼다.

- [17:211] 정리의 "개념 설명은 이 부록에 없다" 가 본문과 충돌한다. 91행은 F# 컴파일 순서가
  `.fsproj` 에서 결정되고 솔루션 등록 순서와 무관하다는 개념을 적고 있고, 153-160행은
  컴파일 목록에 파일을 적는 이야기와 XML 블록을 담고 있다. 두 곳 다 필요한 서술이므로
  본문을 줄이는 대신 정리를 사실에 맞춰라.
  `- 이 부록은 개념을 설명하지 않는다. 산출물을 짚는 데 필요한 만큼만 규칙을 언급했다. 솔루션과 프로젝트의 경계, `.fsproj` 의 컴파일 순서, 네임스페이스와 모듈, 테스트 작성은 4챕터 노트로 간다.`

- [17:167] `id` 없는 테스트 파일 블록에 그 이유를 한 줄 적어 두면 좋다. 용어집 머리말
  19-24행이 "외부 NuGet 패키지가 필요한 실행 단위는 `id` 를 떼지 않는다" 를 규칙으로 두고
  있어서, 이 블록만 `id` 가 없는 것이 규칙 위반으로 보인다. 실제로는 패키지 문제가 아니라
  문법 문제다. `.fsx` 는 `namespace` 선언을 받지 않아 첫 줄에서 오류 FS0010 이 난다(실측).
  블록 앞 문장 끝에 한 줄 붙여라.
  `이 블록은 `namespace` 로 시작하므로 `.fsx` 로는 돌릴 수 없다(오류 FS0010). 검증 대상에서 빼고 파일 모양만 보인다.`
  4챕터 노트도 테스트 파일 블록을 같은 방식으로 `id` 없이 두었으므로 판단 자체는 맞다.

- [17:65] `-f sln` 불릿의 "나머지 명령은 같다" 는 맞지만 독자가 궁금해할 것을 한 걸음 앞에서
  막아 준다. `.sln` 에도 솔루션 폴더가 그대로 생긴다(실측). 199행 수정과 함께 다루면
  같은 사실을 두 번 적지 않아도 된다. 199행 쪽에 몰아 적는 편을 권한다.

## 확인 완료

04챕터 대조

- 갈래가 실제로 지켜졌다. 개념 서술은 4챕터에, 명령과 산출물은 이 부록에 있다.
  이 부록이 담은 개념은 91행 한 줄과 153행 한 문장뿐이고, 둘 다 산출물을 짚는 데 필요한
  최소한이다(정리 문구만 위 지적대로 고치면 된다).
- 넘긴 항목이 전부 4챕터에 실재한다. 컴파일 순서는 4챕터 56-63·70-73행,
  참조 방향과 순환 참조 MSB4006 은 34행, `FsUnit` 대 `FsUnit.xUnit` 은 35행,
  `open FsUnit.Xunit` 과 `open FsUnit` 이 왜 안 되는지는 428-436행,
  Ionide 파일 추가는 73행, 오류 FS0222 는 117-124행과 226행에 있다. 헛걸음할 자리가 없다.
  (이 부록 본문은 FS0222 를 직접 언급하지 않는데, 위 153행 수정으로 그 고리가 생긴다.)
- 이름 대응이 성립한다. `ShopSolution`/`Shop`/`ShopTests` 로 절차를 그대로 따라가면
  4챕터가 전제하는 환경이 나온다. 실측 확인: 솔루션 루트에 `ShopSolution.slnx`,
  `src/Shop/{Program.fs,Shop.fsproj}`, `tests/ShopTests/{Tests.fs,ShopTests.fsproj}`,
  테스트 프로젝트에서 코드 프로젝트로 향하는 `ProjectReference` 하나,
  `dotnet test` 가 템플릿 테스트 하나 통과. 4챕터의 "Getting Started" 이후 실습이
  요구하는 상태와 일치한다. 원서의 `MySolution`/`MyProject`/`MyProjectTests` 대응도 맞다.
- 9행의 "디렉터리 이름이 곧 프로젝트 이름이 되고 그 이름이 어셈블리 이름까지 결정한다" 가
  맞다. `-o src/Shop` 으로 만든 프로젝트가 `Shop.fsproj` 이고 산출물이 `Shop.dll` 이다.

셸 명령과 산출물(전부 SDK 10.0.111 실측 재현)

- `dotnet new sln -o ShopSolution` → `ShopSolution/ShopSolution.slnx`. 내용은
  `<Solution>` / `</Solution>` 두 줄이고 BOM 이 없다. `-f sln` → `ShopSolution.sln`.
- `dotnet new console|xunit -lang "F#"` 산출 파일 넷과 `net10.0`, 그리고 템플릿 패키지 넷의
  이름과 버전이 보고된 값과 정확히 같다(`xunit` 2.9.3, `xunit.runner.visualstudio` 3.1.4,
  `Microsoft.NET.Test.Sdk` 17.14.1, `coverlet.collector` 6.0.4). `-lang F#` 을 따옴표 없이
  써도 동작한다.
- `dotnet sln add` 가 경로를 여러 개 받고 `<Folder Name="/src/">`, `<Folder Name="/tests/">` 를
  만든다. 같은 프로젝트를 다시 넣으면 already contains 메시지만 나오고 종료 코드는 0 이다.
  `dotnet sln list` 가 두 프로젝트를 찍는다.
- `dotnet add <프로젝트 경로> reference|package` 가 `cd` 없이 동작하고, `<ProjectReference>`
  경로가 블록에 적힌 `..\..\src\Shop\Shop.fsproj` 와 같다(백슬래시까지 일치).
- 원서 표기 `dotnet add package FsUnit.XUnit` 도 복원된다. CLI 가
  `Adding PackageReference for package 'FsUnit.XUnit'` 로 받고
  `PackageReference for package 'FsUnit.xUnit' version '7.1.1' added` 로 정규화해 적는다.
  113행 서술이 정확하다. 버전을 안 박아도 7.1.1 이 들어오므로 고정값도 맞다.
- `dotnet build` 가 0 Warning / 0 Error 로 끝나고 어셈블리 둘이 123행에 적힌 경로에 나온다.
  `dotnet test` 는 VSTest 18.0.2 로 1 passed, 127행 출력 형식이 글자까지 같다.
  `dotnet run --project src/Shop` → `Hello from F#`.
- 재실행 시 `dotnet new sln` 이 종료 코드 73. 안내 메시지에
  `refer to https://aka.ms/templating-exit-codes#73` 이 붙는다. `set -e` 가 여기서 멈춘다.
- 47행의 로케일 서술이 맞다. 환경 변수를 떼면 한국어로
  `통과!  - 실패:     0, 통과:     3, ...` 가 나온다. 영어 인용에 조건을 밝힌 것이 적절하다.
  (4챕터 39행의 영어 출력 인용에는 같은 조건이 없다. 아래 항목으로 넘긴다.)
- 66행의 `dotnet new list --language "F#"` 이 동작하고 Short Name 칸에 `console`, `xunit` 이
  있다.

만든 환경에 파일을 얹는 절 — 끝까지 실행해 확인했다

- `src/Shop/Shipping.fs`(`module Shop.Shipping`)와
  `tests/ShopTests/ShippingTests.fs`(167행 블록 그대로)를 만들고 두 `.fsproj` 의 컴파일 목록을
  155행·165행 지시대로 고쳤더니 `dotnet test` 가 3 passed 로 끝났다. 189행 출력이 맞다.
  `open Shop.Shipping`, `open FsUnit.Xunit`, 이중 백틱 한글 모듈·테스트 이름이 모두 통한다.
- `17-shipping` 실행 단위가 PASS 이고 주석 기대 출력이 실제 출력과 일치한다
  (`0.4kg   2500` / `3.0kg   4000` / `7.2kg   6400`). `%-7s` 폭도 어긋나지 않는다.
- `feeFor` 시그니처를 FSI 로 실측하면 `val feeFor: weightKg: float -> int` 다.
  140행 주석 `// float -> int` 가 맞고, 매개변수 이름을 뺀 표기는 4챕터와 같은 관례다.
- 151행의 6400 설명이 맞다. 함수 적용이 `*` 보다 강하게 묶이므로
  `int (ceil (7.2 - 5.0)) * 800` 은 `3 * 800` 이고 `4000 + 2400 = 6400` 이다.
- 138행이 FSI 검증을 위해 모듈 선언을 뺐다고 밝힌 처리가 정확하다. 실제 파일에서는 선언이
  필요하다는 것을 오류 FS0222 로 확인했다.

펜스 배정

- 배정이 옳다. `bash` 5개는 셸 명령이므로 검증 대상이 아니고, 무언어 블록 2개는 CLI 출력
  인용이므로 옳다. `fsharp id=17-shipping` 하나가 실행 단위이고, `id` 없는 `fsharp` 하나는
  `namespace` 로 시작해 `.fsx` 로 돌 수 없으므로 `id` 를 뺀 것이 맞다.
  실행 가능한데 `id` 가 빠진 블록은 없다.
- 사소한 정정: 인계 내용의 "`xml` 5개" 는 실제로 4개다(60, 80, 103, 155행). 대신 언어 표시
  없는 출력 인용 블록이 2개(126, 188행) 있어 전체 펜스는 13개다.

원서 추가분 판단

- 원서 부록은 실패 처리를 다루지 않는다. `.txt` 를 `.sh` 로 바꾸고 `set -euo pipefail` 을
  올린 보탬은 학습에 도움이 되고 원서 범위를 넘지 않는다. 근거가 원서 자체에 있다.
  원서 방식(선택 텍스트를 터미널로 보내기)은 앞 명령이 실패해도 뒤 명령이 계속 돌아가므로,
  `dotnet new sln` 이 종료 코드 73 으로 멈춘 상태에서 `cd` 부터 아래가 다 돌면 엉뚱한
  디렉터리에 프로젝트가 생긴다. 실패 모드를 실측해 붙인 것도 부록의 성격(절차서)에 맞다.
  다만 위에 적은 두 가지 보완이 필요하다 — `set -e` 를 터미널에 붙여 넣지 말라는 경고와
  `mkdir` 실패가 언제 보이는지다.
- VS Code 조작을 절로 갈라 앞머리 한 줄(13행)로 구분한 처리는 분명하다. "아래 항목은 편집기
  기능이라 셸에서 확인할 수 없다" 가 절 맨 앞에 있어 독자가 경계를 놓치지 않는다.
  절 제목에도 "실행으로 확인할 수 없는 부분" 이 들어 있어 목차만 봐도 구분이 된다.
  단축키 서술 자체는 현재 VS Code 기본값과 맞다(새 터미널 `CTRL+SHIFT+백틱`,
  터미널 접기 `CTRL+백틱`, Change All Occurrences `CTRL+F2`, 명령 팔레트 `CTRL+SHIFT+P`).
  추정을 밝힌 처리도 옳다. 지목한 원인만 위 지적대로 좁히면 된다.

## 04챕터에 함께 넘길 것

이 부록만 고치면 두 노트가 갈리므로 4챕터도 같은 자리를 손봐야 한다. 결정은 파이프라인이
하되 근거는 여기 적어 둔다.

- [04:50] "둘째, `dotnet sln add` 가 ... 솔루션 폴더를 `.slnx` 안에 만들어 준다" 를
  원서 이후의 변화로 세고 있다. 위 [17:199] 와 같은 이유로 성립하지 않는다. 셋 중 하나가
  빠지므로 "차이가 세 군데" 도 함께 손봐야 한다. `.slnx` 산출과 `net10.0` 둘은 그대로 유효하다.
- [04:39] 영어 `Passed!` 출력을 인용하면서 로케일 조건을 밝히지 않았다. 17챕터 47행과 같은
  한 줄이 있으면 한국어 로케일 독자가 자기 출력과 대조할 때 헤매지 않는다.
