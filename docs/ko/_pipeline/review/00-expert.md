# 00챕터 기술 검수 보고서 (F# 전문가, 후보 모드)

대상: `docs/ko/00-preface-getting-started.md`
원문 대조: `.cache/src/00-preface-getting-started.txt`, `docs/essential-fsharp.pdf`
검증 환경: SDK 10.0.111 / 런타임 10.0.11 / FSI `F# 10.0용 14.0.111.0` / 기본 langversion `10.0 (Default)`
실행 검증: `verify-examples.sh docs/ko/00-preface-getting-started.md` → `PASS 00-fsi-smoke-test`
금지 표기 grep → 빈 결과

---

## 수정 필요 (기술 오류)

### 1. [00-preface-getting-started.md:116] FSI 가 `val` 줄을 되돌려 주는 조건이 빠졌다

현재 문장: "FSI 는 이렇게 값이나 함수를 정의할 때마다 `val <이름>: <시그니처>` 를 되돌려 준다."

틀린 이유. `val` 줄은 대화형 세션에서만 나온다. 바로 앞 문장(97줄)이 "파일로 저장해
`dotnet fsi` 로 돌리거나"라고 안내하는데, `dotnet fsi smoke.fsx` 로 스크립트를 실행하면
`printfn` 출력만 나오고 `val` 줄은 한 줄도 나오지 않는다. 실측 결과다.

```
$ dotnet fsi 00-fsi-smoke-test.fsx
F# 환경 확인 완료
add 19 23 = 42
런타임 = 10.0.11
```

독자가 안내대로 스크립트를 돌리면 115줄이 약속한 `val add: a: int -> b: int -> int` 을
볼 수 없다. 이 노트는 "시그니처는 FSI 로 실측한다"를 학습 습관으로 내세우는데, 그 습관을
실행할 방법을 잘못 알려 주는 셈이다.

고칠 방법. 116줄 불릿을 아래로 교체한다. 세 명령 모두 실측했다.

```
- FSI 는 대화형 세션에서 값이나 함수를 정의할 때마다 `val <이름>: <시그니처>` 를 되돌려 준다.
  VS Code 에서 `ALT+ENTER` 로 보낼 때, 그리고 `dotnet fsi` 로 진입한 세션에 직접 입력할 때가 그렇다.
  반면 `dotnet fsi <파일>.fsx` 로 스크립트를 실행하면 `printfn` 출력만 나오고 `val` 줄은 나오지 않는다.
  스크립트 파일에서 시그니처를 확인하려면 표준 입력으로 밀어 넣어 세션으로 처리하게 한다.
- 이 줄을 읽는 습관이 F# 학습의 절반이다. 노트에서 시그니처를 주석으로 적을 때도 손으로 예상한 값이
  아니라 FSI 가 출력한 값을 그대로 옮긴다.
```

그리고 89-95줄 bash 블록에 아래 두 줄을 덧붙인다(실측 확인).

```bash
# 스크립트를 표준 입력으로 밀어 넣으면 정의마다 val 줄이 보인다
dotnet fsi --nologo < smoke.fsx
```

### 2. [00-preface-getting-started.md:120] 런타임 확인 주석이 성립하지 않는 대조를 지시한다

현재 주석: `// 실행 중인 런타임 버전. 설치한 SDK 와 맞는지 눈으로 확인한다`
현재 기대 출력: `// 이 저장소 출력 예: 런타임 = 10.0.11`

틀린 이유. SDK 는 10.0.111, 런타임은 10.0.11 이다. 두 값은 원래 같아질 수 없다.
.NET 의 SDK 패치 번호(`1xx` 대역)와 런타임 패치 번호는 서로 다른 체계다.
"맞는지 확인한다"고 시키면 독자는 두 숫자가 다른 것을 보고 설치가 잘못됐다고 판단한다.
게다가 `System.Environment.Version` 은 버전 숫자만 돌려주므로 이것이 .NET 런타임 버전인지
다른 무엇인지 출력만 봐서는 알 수 없다.

고칠 방법. 118-121줄 블록을 아래로 교체한다. `verify-examples.sh` 로 warning 0 개 PASS 를 확인했다.

```fsharp id=00-fsi-smoke-test
// 실행 중인 런타임. SDK 와 메이저·마이너 버전이 같은지 눈으로 확인한다
printfn "런타임 = %s" System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription
// 이 저장소 출력: 런타임 = .NET 10.0.11  (SDK 10.0.111 과 앞의 10.0 이 같다)
```

`FrameworkDescription` 은 `.NET 10.0.11` 처럼 이름까지 붙여 돌려주므로 무엇을 본 것인지가 분명하다.
`System.Environment.Version` 을 그대로 두겠다면 주석을 "SDK 와 메이저·마이너 버전이 같은지"로 바꾸고
`10.0.11` 과 `10.0.111` 의 뒷자리가 다른 것이 정상이라는 한 줄을 붙여야 한다.

### 3. [00-preface-getting-started.md:66] 검증 스크립트의 추출 경로가 틀렸다

현재 문장: "실습 코드는 검증 스크립트가 `.cache/examples/` 로 뽑아 실행한다."

틀린 이유. `docs/ko/_pipeline/verify-examples.sh` 는 `.cache/examples/` 를 쓰지 않는다.
호출마다 `mktemp -d "${TMPDIR:-/tmp}/fsnote-examples.XXXXXX"` 로 시스템 임시 경로에 고유
디렉터리를 만든다. 스크립트 주석이 "반드시 시스템 임시 경로를 쓴다"고 명시적으로 못박아 두었다.
독자가 `.cache/examples/` 를 찾아도 그런 디렉터리는 없다.

고칠 방법. 해당 문장을 경로를 박지 않는 표현으로 바꾼다.

```
- 폴더 구성은 원서 방식대로 책 폴더 하나를 만들고 그 안에 챕터별 폴더를 두는 것으로 충분하다.
  이 저장소는 노트가 `docs/ko/` 에 있고, 실습 코드는 검증 스크립트가 임시 디렉터리로 뽑아 실행한다.
  뽑아낸 스크립트를 직접 보고 싶으면 `KEEP=1` 을 붙여 실행하면 경로를 알려 준다.
```

참고. `docs/ko/_pipeline/STYLE.md:20` 에도 같은 `.cache/examples/` 서술이 남아 있다.
집필자 잘못이 아니라 지침서가 스크립트보다 뒤처진 것이다. STYLE.md 는 내 편집 대상이 아니니
파이프라인 담당자에게 함께 올려 둔다.

### 4. [00-preface-getting-started.md:128] `.fsx` 와 `.fs` 의 차이를 "컴파일 대상 여부"로 단정했다

현재 문장: "차이는 컴파일 대상 여부다. `.exe` 나 `.dll` 로 빌드되는 것은 `.fs` 뿐이고,
`.fsx` 는 F# Interactive 로 이것저것 시험해 보는 용도가 주된 쓰임이다."

틀린 이유. `.fsx` 도 `.fsproj` 의 `Compile` 항목에 넣으면 그대로 빌드된다. 직접 확인했다.

```
<ItemGroup>
  <Compile Include="Extra.fsx" />
  <Compile Include="Program.fs" />
</ItemGroup>
```
→ `빌드했습니다. 경고 0개 오류 0개`, 실행 결과에 `Extra.fsx` 의 코드가 그대로 나온다.

원서는 "The primary differences **in VS Code** are that only .fs files are compiled..."라고
관행을 말하는 문장인데, 노트가 "차이는 ~이다"로 단정해 규칙으로 격상시켰다.
반면 컴파일러가 실제로 확장자를 보고 갈라 놓는 지점은 지시문이다. `.fs` 에 `#r` 을 쓰면

```
error FS0076: 이 지시문은 F# 스크립트 파일(확장명 .fsx 또는 .fsscript)에서만 사용할 수 있습니다.
```

가 나온다. `dotnet fsi <파일>.fs` 도 스크립트로 실행되지 않는다(배너만 찍고 끝난다).
이 두 가지가 확장자에 묶인 진짜 차이고, 뒤 챕터에서 `#r "nuget: ..."` 를 쓸 때 바로 걸린다.

고칠 방법. 127-130줄 불릿을 아래로 교체한다.

```
- F# 파일은 두 종류다. 스크립트 파일 `.fsx` 와 코드 파일 `.fs`. 원서는 두 종류를 모두 쓴다.
- 가장 큰 차이는 프로젝트 파일이 필요한지다. `.fsx` 는 혼자 실행된다. `dotnet fsi <파일>.fsx` 로
  바로 돌아가고, 필요한 패키지와 다른 파일을 파일 안에서 `#r "nuget: ..."` 와 `#load "다른.fsx"` 로
  직접 끌어온다. `.fs` 는 의존성을 `.fsproj` 에서 받는다.
- 이 지시문은 컴파일러가 확장자를 보고 막는다. `.fs` 에 `#r` 을 쓰면 `error FS0076` 이 나고,
  `dotnet fsi` 도 `.fs` 파일은 스크립트로 실행하지 않는다.
- 빌드 쪽은 관행의 문제다. SDK 템플릿이 `.fs` 만 `Compile` 항목에 넣기 때문에 보통 `.fs` 만
  `.exe` 나 `.dll` 로 빌드된다. `.fsx` 를 `Compile` 에 직접 적으면 빌드 자체는 된다.
- 어느 쪽 파일이든 코드를 골라 `ALT+ENTER` 로 FSI 에 보내 실행할 수 있다. 파일 확장자가 FSI 전송을 막지는 않는다.
- 실무 감각으로 정리하면 이렇다. 개념을 확인하거나 데이터를 한 번 훑어보는 작업은 `.fsx` 에서 하고,
  빌드해 배포할 코드는 `.fs` 에 넣는다.
```

이어서 `id` 없는 블록 하나를 붙여 두면 뒤 챕터 준비가 된다(지시문 예시라 실행 대상에서 빼는 것이 맞다).

```fsharp
// .fsx 에서만 쓸 수 있는 지시문. .fs 에 쓰면 error FS0076 이다
#r "nuget: FsUnit.xUnit"
#load "Helpers.fsx"
```

### 5. [00-preface-getting-started.md:27] 5챕터 설명이 원서 내용과 다르다

현재 표기: "리스트, 배열, 시퀀스와 컬렉션 함수를 파이프라인으로 잇는 데이터 변환"

틀린 이유. 5챕터는 세 컬렉션의 이름만 소개하고 실습은 전부 `List` 로 한다. 원문이 두 번 못박는다.

- 원서 p.63: "In this chapter, we are going to concentrate on the List type and module."
- 원서 p.64: "They're also available for the other primary collection types in F#: Seq and Array,
  but we are not going to use them in this chapter."

5챕터 원문에서 `Array.` 로 시작하는 함수 호출은 0회, `Seq.` 는 1회(지나가며 언급)뿐이고
`List.` 는 68회다. 집필자가 우려한 대로 원서에 없는 정보가 섞인 자리다.
"배열, 시퀀스도 다룬다"고 읽으면 5챕터에서 헛것을 찾게 된다.

고칠 방법. 27줄 셀을 아래로 교체한다.

```
| 5 | Introduction to Collections | 컬렉션 함수를 파이프라인으로 이어 데이터를 변환한다. `Seq` 와 `Array` 는 종류만 소개하고 실습은 `List` 로 한다 |
```

---

## 개선 권장

### 6. [00-preface-getting-started.md:48, 66, 79] 원서 부록 1을 가리키는 안내가 없다

원서는 15챕터 뒤에 부록 둘이 붙어 있다. 부록 1(pp.195-196) "Creating Solutions and Projects
in VS Code" 가 바로 4챕터가 "Follow the instructions in the Appendix of this book"(원서 p.52)
라고 넘긴 그 절차다. 내용은 아래 스크립트다.

```
dotnet new sln -o MySolution / mkdir src / dotnet new console -lang F# -o src/MyProject
dotnet sln add ... / mkdir tests / dotnet new xunit -lang F# -o tests/MyProjectTests
dotnet add reference ../../src/MyProject/MyProject.fsproj
dotnet add package FsUnit / dotnet add package FsUnit.XUnit / dotnet build / dotnet test
```

00챕터가 환경 설정을 담당하는 자리인데 여기서 이 존재를 알려 주지 않으면, 4챕터에 가서
`dotnet new xunit` 만 있고 솔루션·프로젝트 참조·FsUnit 패키지 단계가 통째로 빈다.
79줄 불릿을 확장하기를 권한다.

```
- 4챕터의 테스트 실습에 필요한 템플릿도 SDK 에 함께 들어 있다. `dotnet new xunit -lang "F#"` 로 만든다.
- 4챕터는 솔루션 하나에 코드 프로젝트와 테스트 프로젝트를 나눠 담는 구성에서 출발하는데,
  그 절차는 원서 본문이 아니라 부록 1(원서 pp.195-196)에 있다. `dotnet new sln` 으로 솔루션을 만들고
  `dotnet sln add` 로 두 프로젝트를 넣은 뒤, 테스트 프로젝트에서 `dotnet add reference` 로 코드 프로젝트를
  참조하고 `dotnet add package FsUnit.xUnit` 을 더한다.
```

패키지 이름은 실측 확인했다. `dotnet add package FsUnit.XUnit` 은 NuGet 이 대소문자를 가리지
않으므로 통하고, `.fsproj` 에는 `FsUnit.xUnit` 7.1.1 로 기록된다. .NET 10 에서 복원과 빌드가 정상이다.

원서 챕터가 15개라는 서술(1줄, 16줄, 39줄)은 맞지만, 부록 둘(부록 1은 프로젝트 생성, 부록 2는
15챕터용 CSS/JavaScript)이 따로 있다는 사실을 16-19줄 어딘가에 한 줄로 적어 두면 대조가 편해진다.

### 7. [00-preface-getting-started.md:64] Ionide 확장 식별자와 FSI 전송 명령을 정확히 적을 수 있다

Ionide 저장소의 `release/package.json` 을 확인했다. 게시자는 `Ionide`, 확장 이름은 `Ionide-fsharp`
이므로 정확한 식별자는 `Ionide.Ionide-fsharp` 다. 키 바인딩도 확인했다.

| 키 | 명령 |
|---|---|
| `alt+Enter` | `FSI: Send Selection` |
| `alt+/` | `FSI: Send Line` |
| `alt+shift+Enter` | `FSI: Send Selection Extended To Whole Line` |
| (바인딩 없음) | `FSI: Send File` |

64줄과 97줄에 반영하기를 권한다. 특히 `ALT+ENTER` 는 선택 영역을 보내는 명령이라 아무것도
고르지 않으면 아무 일도 일어나지 않는다. 한 줄만 보내는 `ALT+/`, 파일 전체를 보내는
`FSI: Send File` 을 함께 적어 두면 독자가 "전체를 골라"라는 수동 절차를 되풀이하지 않는다.

```
- 편집기는 VS Code 와 Ionide F# 확장 조합이 원서 기준이고 지금도 유효하다. 확장 마켓플레이스에서
  `Ionide.Ionide-fsharp` 를 찾아 설치한다. 명령줄로는 `code --install-extension Ionide.Ionide-fsharp` 다.
  설치 후 창을 다시 로드해야 할 수 있다.
```

97줄은 "VS Code 에서 전체를 골라 `ALT+ENTER` 로 FSI 에 보내거나, 명령 팔레트의 `FSI: Send File`
을 쓰면 된다" 정도로 다듬는다.

### 8. [00-preface-getting-started.md:57] `dotnet --version` 이 무엇을 돌려주는지

주석이 "설치된 SDK 버전"인데 정확히는 현재 디렉터리에서 유효한 SDK 버전이다. `global.json` 이
있으면 그쪽에 고정된 값이 나온다. 설치된 것을 전부 보는 명령은 바로 아래 `dotnet --list-sdks` 다.
주석 한 단어만 고치면 된다.

```bash
# 현재 디렉터리에서 쓰이는 SDK 버전 (global.json 이 있으면 그 값)
dotnet --version          # 이 저장소: 10.0.111
```

### 9. [00-preface-getting-started.md:50] 하위 호환 서술을 챕터 범위로 좁히는 편이 안전하다

"원서 예제는 .NET 10 에서도 그대로 돌아간다"는 언어 문법 얘기로는 맞다. 기본 언어 버전이
`10.0 (Default)` 이고 `--langversion:?` 에 `4.6` 부터 다 남아 있다. 다만 13~15챕터는 Giraffe
패키지 버전과 ASP.NET Core 호스팅 API 에 걸려 있어서 언어 하위 호환과 별개로 손볼 데가 생긴다.
"원서 예제"를 "원서의 F# 문법과 코어 라이브러리 예제"로 좁히고, 웹 챕터는 패키지 버전을 그때
맞춘다는 한 줄을 붙이기를 권한다.

### 10. [00-preface-getting-started.md:87, 130] "노트의 코드 블록이 전부"는 과장이다

`verify-examples.sh` 는 `id` 가 붙은 블록만 뽑는다. `id` 없는 블록은 실행하지 않는다.
00챕터에는 `id` 없는 `fsharp` 블록이 없어서 지금은 결과가 같지만, 4번 항목에서 제안한
`#r` 예시처럼 `id` 없는 블록이 생기면 두 문장이 곧 거짓이 된다.
"`id` 가 붙은 코드 블록이 전부 이 명령으로 실행되므로" 로 한정하기를 권한다.

### 11. [00-preface-getting-started.md:83] 원문은 "거의 없다"가 아니라 "한 번도 없다"다

원서 p.6: "I never debug any code with breakpoints when doing F# development."
노트는 "거의 없다고 말한다"로 약하게 옮겼다. 저자 주장의 세기를 임의로 낮춘 자리다.
"저자는 F# 개발에서 중단점을 걸고 디버깅한 일이 한 번도 없다고 적는다" 로 고치면 원문과 맞는다.

### 12. [00-preface-getting-started.md:99-121] 스모크 테스트에 FSI 상태 유지를 보여 주는 한 덩어리를 더할 만하다

지금 구성(값 바인딩 → 함수 바인딩 → 런타임 확인)은 환경 확인용으로 적절하다.
`verify-examples.sh` 통과, warning 0 개, 주석의 기대 출력이 실제 출력과 일치한다.

다만 85줄이 "앞서 보낸 정의를 뒤에서 이어 쓸 수 있다"고 설명한 FSI 의 성질을 정작 코드가
보여 주지 않는다. 세 블록이 같은 `id` 를 쓰므로 이어 붙었을 때 앞 정의를 재사용하는 모습을
한 줄 넣으면 설명과 코드가 맞물린다. 두 번째 블록 뒤에 이 정도가 좋다.

```fsharp id=00-fsi-smoke-test
// 앞 블록의 greeting 과 add 를 그대로 쓸 수 있다. FSI 는 정의를 세션에 남겨 둔다
printfn "%s (%d)" greeting (add 40 2)    // 기대: F# 환경 확인 완료 (42)
```

`|>` 를 여기 끌어들일 필요는 없다. 2챕터가 다루는 내용이고, 환경 확인 스크립트는 짧을수록 낫다.

### 13. [00-preface-getting-started.md:33] 11챕터 설명이 너무 뭉툭하다

"재귀를 F# 에서 활용하는 여러 방식"은 틀리지 않지만 정보가 거의 없다. 원문을 보면 누적기를 쓴
꼬리 호출 최적화가 챕터의 중심이고, `List.fold` 로 다시 쓰기, 퀵소트, 트리 순회가 뒤따른다.
2챕터 행처럼 소재를 늘어놓는 편이 표의 다른 행과 밀도가 맞는다.

```
| 11 | Recursion | 누적기를 쓴 꼬리 재귀, `List.fold` 로 다시 쓰기, 퀵소트와 트리 순회 |
```

### 14. [00-preface-getting-started.md:26] 4챕터 행에 네임스페이스가 빠졌다

4챕터 원문 절 제목은 Solutions and Projects, Adding a Source File, Namespaces and Modules,
Writing Tests, Using FsUnit for Assertions 다. 네임스페이스와 솔루션 구성이 절 하나씩을 차지한다.

```
| 4 | Organising Code and Testing | 솔루션과 프로젝트, 네임스페이스와 모듈, 파일 순서, XUnit 과 FsUnit 으로 테스트 첫 경험 |
```

### 15. [00-preface-getting-started.md:10] 원서 목록에서 AI 가 빠졌다

원서 p.1 은 "web programming, cloud programming, Machine Learning, AI, and Data Science" 다.
노트는 "웹, 클라우드, 머신러닝, 데이터 과학"으로 AI 를 뺐다. 문장 취지가 목록을 늘어놓지
말자는 것이라 크게 어긋나지는 않지만, 목록을 인용하는 자리이므로 넣어 두는 편이 낫다.

### 16. [00-preface-getting-started.md:44] "25년 경력"은 "25년 넘는 경력"이다

원서 p.4 는 "over 25 years of experience" 다.

### 17. 원서 제목 표기가 두 곳에서 갈린다 (참고용, 노트 잘못 아님)

노트 21-37줄 표는 서문의 Contents 절 표기를 따랐다. 그런데 원서 목차와 각 챕터 실제 제목은
일부가 다르다.

| 원서 서문(노트가 채택) | 원서 목차·챕터 제목 |
|---|---|
| Single-Case Discriminated Unions | Single-Case Discriminated Union (단수) |
| Introduction to Web Programming With Giraffe | ... with Giraffe (소문자 w) |
| Creating an API With Giraffe | ... with Giraffe |
| Creating Web Pages With Giraffe | ... with Giraffe |

노트가 서문을 대조하는 절이므로 서문 표기를 쓴 것은 일관적이다. 다만 뒤 챕터 노트들이 각자
챕터 제목을 적을 때 목차 표기를 따르면 00챕터 표와 어긋나 보인다. 표 아래에 "제목은 원서 서문
Contents 절 표기를 따랐다. 9챕터는 본문 제목이 단수형이고, 13~15챕터는 본문에서 with 가
소문자다" 정도의 한 줄을 두면 뒤 챕터와 충돌하지 않는다.

---

## 확인 완료

### 환경 설정 절차 — .NET 10 에서 전부 실측

임시 디렉터리에서 실행하고 정리했다. 저장소에는 아무것도 남기지 않았다.

- `dotnet --version` → `10.0.111`. 50줄, 57줄 서술과 일치.
- `dotnet --list-sdks` → `10.0.111 [/usr/lib/dotnet/sdk]`
- `dotnet --list-runtimes` → `Microsoft.NETCore.App 10.0.11`, `Microsoft.AspNetCore.App 10.0.11`
- `dotnet fsi --langversion:?` → `10.0 (Default)`. "F# 언어 버전은 F# 10 이다"(50줄) 맞다.
- FSI 배너 → `Microsoft (R) F# Interactive 버전 F# 10.0용 14.0.111.0`
- `dotnet new console -lang "F#" -o HelloFSharp` 정상. `-lang` 을 빼면 C# 이 생기는 것도 맞다(68줄).
- 생성된 `.fsproj` 는 `<TargetFramework>net10.0</TargetFramework>` 와
  `<Compile Include="Program.fs" />` 를 담는다. 78줄 서술이 글자까지 일치한다.
- `dotnet run --project HelloFSharp` → `Hello from F#`. 75줄 기대 출력 일치.
- `dotnet new xunit -lang "F#"` 정상. `net10.0`, `xunit 2.9.3`, `Microsoft.NET.Test.Sdk 17.14.1`,
  `Compile Include="Tests.fs"`. 79줄 맞다.
- .NET SDK 하나로 컴파일러와 FSI 가 함께 들어온다(51줄, 143줄). 원서 1단계 "Install F#" 을
  현재 사실에 맞게 고쳐 적은 판단이 옳다.

### FSI 사용법

- `dotnet fsi <파일>.fsx` 로 스크립트 실행 — 동작 확인.
- `dotnet fsi` 로 대화형 진입, `;;` 로 실행, `#quit;;` 로 종료 — 동작 확인. 86줄, 93줄 맞다.
- 파일에서 `ALT+ENTER` 로 보낼 때 `;;` 가 필요 없다는 서술(86줄) 맞다. Ionide 가 붙여 준다.
- `add` 시그니처 실측값이 노트 115줄과 정확히 같다.
  ```
  > val add: a: int -> b: int -> int
  ```
  매개변수 이름까지 나오는 F# 6 이후 출력 형식을 그대로 적었다. 화살표가 두 개인 이유를
  2챕터 커링 절로 넘긴 것도 맞는 배치다.
- 107줄의 값 바인딩/함수 바인딩 구분("매개변수가 없으면 값 바인딩, 하나 이상 있으면 함수 바인딩")은
  GLOSSARY.md 의 `value binding` / `function binding` 항목과 정확히 일치한다.
- 87줄 "원서는 명령줄 FSI 를 범위 밖이라고 적었다"는 원문 p.6 과 일치한다.
  ("There is a command-line version of FSI ... but that is outside the scope of this book.")

### 실행 단위와 펜스

- `00-fsi-smoke-test` → PASS. warning 0 개. 주석의 기대 출력 세 개가 실제 출력과 모두 일치한다.
- 셸 명령 세 블록(55-62, 70-76, 89-95)은 모두 ```bash, F# 코드 한 블록(99-121)은 ```fsharp.
  펜스 배정이 옳다.
- `id` 가 빠져 검증에서 누락된 실행 가능 블록은 없다. 문서의 유일한 `fsharp` 블록 세 덩어리가
  모두 `id=00-fsi-smoke-test` 로 이어 붙는다. 이어 붙인 상태에서 `greeting` 과 `add` 가
  중복 정의되지 않는다.
- 123줄의 "세 블록은 같은 `id` 를 쓰므로 문서 순서대로 이어 붙어 하나의 스크립트로 실행된다"는
  `verify-examples.sh` 의 awk 동작과 정확히 맞다.

### 챕터 구성 표 (5챕터 행 제외)

원서 서문 Contents 절과 각 챕터 원문을 대조했다. 5챕터 행 하나만 사실과 다르고
나머지 열넷은 원문에 근거가 있다.

- 1챕터에 레코드·판별 유니온·패턴 매칭을 적은 것 — 원문 키워드 빈도로 확인(record 11+, DU 8+).
- 2챕터에 커링·부분 적용·시그니처 읽기를 적은 것 — 원문 절 제목이 Multiple Parameters,
  Partial Application (Part 1/2), The Forward Pipe Operator 이고 signature 가 13회 나온다.
  원서 요약(p.38)도 "Curried and tupled parameters / Currying and partial application" 을 든다.
- 3챕터에 `Option` 과 `Result` 를 적은 것 — `Result` 97회, `Option` 41회.
- 8챕터 "계산 식을 처음 만난다" — 원문 p.103 이 "introduced to one of the more unique
  features of F#, the computation expression" 이라고 명시한다.
- 12챕터 "`Option`, `Result`, `Async` 같은 효과를 다루는 일반적 장치" — 원문 p.4 의
  "the generic way that F# handles working with effects like Option, Result, and Async" 와 일치.
- 9챕터 "원시 타입 의존을 줄이고 도메인 중심 타입으로" — 원문 p.4, p.118 과 일치.
- 14챕터 "13챕터의 API 부분을 확장한다" — 원문 p.4 와 일치.
- 6챕터와 15챕터를 "짧은 챕터"로 표시한 것 — 원문이 둘 다 "A short chapter" 라고 적는다.

### 읽는 순서 제안 (39줄) — 근거가 있다. 특히 8-12 짝은 원서가 직접 권한다

집필자가 판단을 요청한 부분이다. 확인한 결과 세 갈래 모두 실제 의존 관계와 맞는다.

- "7챕터는 8챕터의 준비물이다" — 맞다. 원서 p.103 이 "use the tools from the previous chapter"
  라고 적고, 8챕터 코드가 `(|ParseRegex|_|)`, `(|IsValidEmail|_|)`, `(|IsDecimal|_|)`,
  `(|IsValidDate|_|)` 같은 부분 활성 패턴을 직접 정의해 쓴다. 7챕터를 건너뛰면 8챕터 코드가 읽히지 않는다.
- "6챕터와 8챕터는 이어지는 한 묶음" — 맞다. 8챕터가 6챕터에서 읽은 CSV 데이터에 검증을 붙인다.
- "8챕터와 12챕터는 짝으로" — 맞다. 노트의 독자적 판단이라고 표시해 두었지만 실은 원서가
  같은 말을 한다. 원서 p.153: "Once you have finished this chapter, it might be worth going
  back to Chapter 8 and having another look at the functional validation example which used a
  custom computation expression." 방향까지 노트와 같다(8을 먼저 읽고 12 뒤에 되돌아본다).
  이 근거를 39줄에 한 문장으로 넣으면 "노트의 판단"이 아니라 "원서의 권고"로 격상된다.
  예: "12챕터를 끝낸 뒤 8챕터의 검증 예제로 돌아가 보라는 것은 원서 자신의 권고다(원서 p.153)."
- "1~5챕터는 건너뛰기 어려운 토대" — 맞다. 6·8·11챕터가 5챕터의 컬렉션 함수를 전제한다.
- "13~15챕터는 뒤로 미뤄도 무리가 없다" — 맞다. 13챕터가 앞 챕터 코드를 이어받지 않는다.

### 서문 요약의 사실관계

- 원서 판본 "2023년 1월 판"(3줄) — PDF 앞장이 "This version was published on 2023-01-30",
  메타데이터 CreationDate 가 2023-01-30 이다. 맞다.
- 다섯 가지 목록(12줄: 표현력 있는 타입 시스템, 정방향 파이프 연산자로 하는 합성, 패턴 매칭,
  컬렉션, REPL)과 "개별 기능보다 맞물리는 방식"이라는 저자의 단서 — 원문 p.2 와 일치.
- Dave Thomas 인용(10줄), 2010년부터 Visual Studio 에 동봉(11줄), 2020~2021년 Trustbit
  블로그 연재 두 편이 원본이고 F# 5·6 기능을 반영했다는 서술(18줄) — 모두 원문과 일치.
- F# Software Foundation 이 무료이고 입문자 채널이 있는 Slack 에 들어갈 수 있다는 서술(43줄) — 일치.

### 용어 표기

00챕터가 쓴 용어는 GLOSSARY.md 와 전부 일치한다. 뒤집을 것이 없다.
`정방향 파이프 연산자`, `바인딩`, `값 바인딩`, `함수 바인딩`, `타입 추론`, `타입 주석`,
`커링`, `시그니처`, `판별 유니온`, `레코드`, `부분 적용`, `불변`.
금지 표기 grep 도 빈 결과다.

새로 쓴 용어는 `.cache/review/00-glossary.md` 에 정리했다. 집필자가 물은 세 항목은
모두 집필자 표기를 채택한다. `functional-first`→함수 우선, `LOB`→업무용 애플리케이션, `REPL`→REPL.
