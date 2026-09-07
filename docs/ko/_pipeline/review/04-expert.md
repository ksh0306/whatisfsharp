# 04챕터 기술 검수 — 코드 구성과 테스트

검수 대상: `docs/ko/04-organising-code-and-testing.md`
실측 환경: .NET SDK 10.0.111, F# Interactive 14.0.111.0, FsUnit.xUnit 7.1.1, FsUnit 7.1.1,
xUnit 2.9.3(템플릿), Microsoft.NET.Test.Sdk 17.14.1.
임시 디렉터리에 솔루션을 실제로 만들어 빌드·테스트하고 정리했다. 저장소에는 손대지 않았다.

실행 단위 3개(`04-order`, `04-modules`, `04-learners`) 전부 PASS, 경고 0개.
주석에 적힌 기대 출력 8줄이 실제 출력과 한 글자도 다르지 않았다.

## 수정 필요 (기술 오류)

- [04-organising-code-and-testing.md:34] 순환 참조 서술이 틀렸다.
  현재: "참조 방향은 한쪽뿐이다. 테스트 프로젝트가 코드 프로젝트를 참조한다. 반대로 걸면 순환 참조가 되어 빌드되지 않는다."
  실측: 참조를 반대 방향으로만(코드 → 테스트) 걸면 빌드가 성공한다(`Build succeeded.`).
  순환 참조 오류는 양쪽을 다 걸었을 때만 나고, 오류는 F# 컴파일러가 아니라 MSBuild 가 낸다.
  `error MSB4006: There is a circular dependency in the target dependency graph involving target "_GenerateRestoreProjectPathWalk".`
  이렇게 고쳐라.
  ```
  - 참조 방향은 한쪽뿐이다. 테스트 프로젝트가 코드 프로젝트를 참조한다. 반대 방향 참조를 함께 걸면 두 프로젝트가 서로를 기다리게 되어 복원 단계에서 `MSB4006` 순환 의존 오류가 난다. 방향을 반대로만 걸어도 빌드는 되지만 테스트 프로젝트가 대상 코드를 볼 수 없어 의미가 없다.
  ```

- [04-organising-code-and-testing.md:75, 04-organising-code-and-testing.md:489] "언제나"가 과도한 일반화다.
  현재(75줄): "이 \"위에서 아래로만 보인다\"는 규칙은 파일 사이에만 있는 것이 아니라 파일 안에서도 똑같이 적용된다."
  현재(489줄): "이름은 언제나 위에서 아래로만 보인다. 파일 안에서도, 파일 사이에서도 그렇다."
  실측: 파일 사이에는 예외가 없지만 파일 안에는 있다. `module rec` / `namespace rec` 를 쓰면
  같은 파일 안에서 아래에 정의된 것을 위에서 참조할 수 있다. 다음이 `900.0` 을 출력한다.
  ```fsharp
  module rec Shop =
      module Order =
          let total grade amount = amount * (1.0 - Discount.rateFor grade)
      module Discount =
          let baseRate = 0.05
          let rateFor grade = if grade = "gold" then baseRate * 2.0 else baseRate
  ```
  489줄을 이렇게 고쳐라(75줄은 "언제나"가 없으므로 그대로 두어도 된다).
  ```
  - 이름은 위에서 아래로만 보인다. 파일 안에서도, 파일 사이에서도 그렇다. 파일 사이에는 이 규칙을 우회하는 수단이 없어 순환 의존이 생길 수 없고, 그래서 프로젝트의 계층이 파일 목록에 그대로 드러난다.
  ```
  파일 안의 예외를 짚어 두려면 113줄 불릿 뒤에 한 줄을 더한다.
  ```
  - 파일 안에서 서로를 참조해야 하는 드문 경우에는 `module rec` 이나 `namespace rec` 로 그 파일에 한해 규칙을 풀 수 있다. 파일 사이에는 같은 수단이 없다.
  ```

- [04-organising-code-and-testing.md:221] 챕터 안에서 서술과 예제가 어긋나고, 생략 가능 범위를 오해하게 만든다.
  현재: "테스트 파일에는 네임스페이스가 필요 없다. 배포되지 않는 코드라서 다른 어셈블리와 이름이 충돌할 일이 없다."
  그런데 같은 챕터의 예제 테스트 파일 세 개(237, 359, 434줄)가 모두 `namespace ShopTests` 로 시작한다.
  게다가 124줄이 "애플리케이션의 마지막 파일"만 선언을 생략할 수 있다고 적어 두었으므로,
  독자는 테스트 파일도 마지막 것은 선언을 생략할 수 있다고 읽을 수 있다. 실측하면 그렇지 않다.
  파일이 `Tests.fs` 하나뿐인 xUnit 템플릿 프로젝트에서 선언을 지우면 `FS0222` 가 난다.
  이유는 빌드 로그에서 확인된다. 컴파일 파일 목록의 마지막이 사용자 파일이 아니라
  테스트 SDK 가 붙이는 `Microsoft.NET.Test.Sdk.Program.fs` 다.
  이렇게 고쳐라.
  ```
  - 테스트 파일도 네임스페이스나 모듈 선언으로 시작해야 한다. 다만 네임스페이스까지 갈 필요는 없고 모듈 하나로 충분하다. 배포되지 않는 코드라서 다른 어셈블리와 이름이 충돌할 일이 없다.
  - 테스트 프로젝트에는 마지막 파일 예외가 통하지 않는다. 테스트 SDK 가 진입점 파일을 컴파일 목록 맨 뒤에 붙이므로 사용자 파일 중 마지막인 것이 없고, 선언을 빼면 파일이 하나뿐이어도 `FS0222` 가 난다.
  ```
  아래 예제들이 `namespace` 를 쓰는 것은 모듈 중첩을 함께 보여 주기 위한 것이므로 그대로 두면 된다.
  다만 237줄 블록 앞에 "네임스페이스 아래에 모듈을 두는 형태로 적으면 실패 출력이 어떻게 찍히는지 보인다" 정도의
  한 줄을 넣어 두면 221줄과의 어긋남이 사라진다.

## 개선 권장

- [04-organising-code-and-testing.md:285-303] 튜플 매개변수를 주석 한 줄로만 처리했다.
  `// Learner * int -> Learner  (튜플 매개변수)` 는 FSI 실측값과 정확히 일치한다
  (`val promoteIfEligible: learner: Learner * completed: int -> Learner`).
  그런데 이 챕터에서 가장 오해하기 쉬운 대목이 `settleMonth` 의 파이프라인이다.
  `findCompleted` 가 `Learner * int` 를 반환하고 `promoteIfEligible` 이 튜플 하나를 받으므로 파이프가 맞물리는데,
  독자는 `|>` 가 튜플을 두 인자로 풀어 준다고 읽을 수 있다. `|>` 는 값 하나를 넘길 뿐이다.
  303줄 블록 뒤 불릿에 다음을 더하라.
  ```
  - `promoteIfEligible` 의 매개변수는 두 개가 아니라 튜플 하나다. 시그니처가 `Learner -> int -> Learner` 가 아니라 `Learner * int -> Learner` 인 것이 그 표시다. `findCompleted` 가 돌려준 튜플이 그대로 이 하나의 매개변수에 들어가므로 파이프가 맞물리는 것이고, `|>` 가 튜플을 두 인자로 풀어 주는 것은 아니다. 튜플 매개변수는 절반만 적용할 수 없으므로 이 함수에는 부분 적용을 쓸 수 없다.
  ```

- [04-organising-code-and-testing.md:106, 04-organising-code-and-testing.md:118] 오류 메시지 인용 언어가 섞여 있다.
  118줄 `FS0222` 는 영어, 106줄 `FS0039` 는 한국어다. 컴파일러 메시지는 SDK 로케일에 따라 달라지므로
  한쪽으로 통일하는 편이 대조하기 쉽다. 영어로 통일하면 다음이 실측 문장이다(둘 다 그대로 확인했다).
  ```
  error FS0039: The value, namespace, type or module 'Discount' is not defined. Maybe you want one of the following:
  ```
  118줄의 `FS0222` 인용은 현재 SDK 출력과 마지막 구절까지 정확히 일치한다(`may omit such a declaration.`).
  원서가 적은 `may omit any declaration` 은 예전 문구이므로 노트가 맞다.

- [04-organising-code-and-testing.md:214] `[<RequireQualifiedAccess>]` 가 붙은 코어 모듈 목록이 좁다.
  `List`, `Array`, `Seq` 외에 `Map`, `Set`, `String`, `Event`, `Observable` 도 붙어 있다(전부 `open` 시 `FS0892`).
  `Option`, `ValueOption`, `Result`, `Printf` 는 붙어 있지 않아 `open` 이 통한다. 다음으로 바꾸면 정확해진다.
  ```
  - F# 코어의 `List`, `Array`, `Seq`, `Map`, `Set`, `String` 모듈에도 이 특성이 붙어 있다. 그래서 `open List` 는 오류이고 `List.map` 과 `Array.map` 이 섞일 일이 없다. 반면 `Option`, `Result` 모듈에는 붙어 있지 않아 `open` 이 가능하다.
  ```

- [04-organising-code-and-testing.md:203] `[<RequireQualifiedAccess>]` 는 판별 유니온에도 붙는다.
  실무에서 더 자주 보는 쓰임이 그쪽이므로 211줄 블록 뒤에 한 줄을 더하면 도움이 된다.
  ```
  - 이 특성은 모듈뿐 아니라 판별 유니온 타입에도 붙는다. `Tier` 에 붙이면 `Pro` 대신 `Tier.Pro` 로만 쓸 수 있어 케이스 이름이 다른 이름과 부딪히지 않는다.
  ```
  짝이 되는 `[<AutoOpen>]` 도 이 절에 한 줄 넣을 만하다. 원서는 다루지 않지만 `open` 절의 자연스러운 반대편이다.
  ```
  - 반대로 `[<AutoOpen>]` 을 붙인 모듈은 그 어셈블리를 참조하기만 하면 `open` 없이 이름이 보인다. 편하지만 어디서 온 이름인지 추적이 어려워지므로 아껴 쓴다.
  ```

- [04-organising-code-and-testing.md:220] 값 바인딩으로 적은 테스트에는 경고가 난다는 사실을 덧붙이면 진단에 도움이 된다.
  실측: `[<Fact>] let ``t`` = Assert.True(true)` 는 빌드는 되지만 테스트로 수집되지 않고
  `warning FS0842: This attribute cannot be applied to property, field, return value. Valid targets are: method` 가 난다.
  ```
  - 테스트 함수는 `unit` 을 받아 `unit` 을 반환한다. 매개변수 자리의 `()` 를 빼면 값 바인딩이 되어 특성을 붙일 자리가 사라지고, 경고 `FS0842` 와 함께 xUnit 이 그것을 테스트로 인식하지 못한다.
  ```

- [04-organising-code-and-testing.md:130] 네임스페이스에 값을 둘 수 없다는 서술에 오류 번호를 붙이면 다른 서술과 결이 맞는다.
  실측: `namespace Shop` 아래에 `let x = 1` 을 두면
  `error FS0201: Namespaces cannot contain values. Consider using a module to hold your value declarations.`
  같은 문단의 두 유일성 규칙도 오류 번호로 확인된다. 한 네임스페이스 안에서 모듈 이름이 겹치면 `FS0248`
  (`Two modules named 'Shop.Inv' occur in two parts of this assembly`), 최상위 모듈 이름이 겹치면 `FS0239`
  (`An implementation of the file or module 'Shop.Inv' has already been given`)다.

- [04-organising-code-and-testing.md:35, 04-organising-code-and-testing.md:428] 원서를 따라 두 패키지를 다 넣었을 때
  무엇이 벌어지는지 한 줄 적어 두면 독자가 자기 상황을 판단할 수 있다.
  실측: `FsUnit` 과 `FsUnit.xUnit` 을 함께 넣으면 `open FsUnit` 이 컴파일되고 `should` 도 보인다.
  다만 그때 쓰이는 것은 NUnit 쪽 어서션이라 실패 메시지가 쓸 만하지 않게 나온다.
  ```
  [xUnit.net] BothPkgs.nunit flavored assertion inside xunit [FAIL]
     NUnit.Framework.AssertionException :   Assert.That(, )
  ```
  428줄 불릿에 이어 붙일 문장.
  ```
  - `FsUnit.xUnit` 만 넣은 프로젝트에서 `open FsUnit` 은 그 자체로는 오류가 아니다. `FsUnit` 이라는 네임스페이스가 있으므로 `open` 은 통과하고, `should` 를 쓰는 줄에서 `FS0039` 가 난다. 원서처럼 `FsUnit` 패키지까지 함께 넣으면 `should` 는 보이지만 NUnit 쪽 어서션이 쓰여 실패 메시지가 `NUnit.Framework.AssertionException : Assert.That(, )` 처럼 쓸 만하지 않게 나온다.
  ```

- [04-organising-code-and-testing.md:429] "테스트 실행 장치" 는 즉석 조어다. 용어집 후보대로 "테스트 러너"로 바꿔라.

- [04-organising-code-and-testing.md:264, 04-organising-code-and-testing.md:354] 이미 앞 챕터에서 병기를 끝낸 용어를 다시 병기했다.
  `부수 효과(side effect)`, `구조적 동등성(structural equality)` 둘 다 `docs/ko/02-functions.md` 에서
  첫 등장 병기를 했으므로(각각 02챕터 8줄, 02챕터 125줄) 이 챕터에서는 한국어만 쓴다.

- [04-organising-code-and-testing.md:192-200] 이름 가림 예제의 라벨이 개념을 흐린다.
  `Imperial.describe 3` 이 `"3 dozen"` 을 내는데, 3 개를 3 다스로 적은 셈이라 수와 단위가 어긋난다.
  한국어 주석·출력 사이에 영어 단위만 끼어 있는 것도 눈에 걸린다.
  어느 쪽이 이겼는지만 보이면 되므로 두 모듈 이름을 그대로 라벨에 넣는 편이 낫다.
  `Metric.describe` 는 `$"{n} 개(미터법)"`, `Imperial.describe` 는 `$"{n} 개(야드파운드법)"` 로 두면
  출력만 보고 어느 모듈이 이겼는지 바로 읽힌다. 이때 200줄 기대 출력 주석도 함께 고쳐야 한다.

- [04-organising-code-and-testing.md:73] Ionide 의 메뉴 항목 이름은 이 환경에서 확인할 수 없었다.
  원서는 `Add File Above` 하나만 적는다. `Add File Below` 까지 단정하지 않으려면
  "기존 파일을 오른쪽 클릭해 위/아래에 새 파일을 만드는 메뉴" 정도로 완화하는 편이 안전하다.

## 확인 완료

집필자가 실측으로 바로잡았다고 보고한 4건은 모두 재현했다.

1. `.slnx` 기본값 — 확인. `dotnet new sln -o ShopSolution` 이 `ShopSolution.slnx` 를 만든다.
   `dotnet new sln --help` 의 `-f, --format <sln|slnx>` 기본값이 `slnx` 로 표시되고,
   `dotnet new sln -f sln` 은 `.sln` 을 만든다. 50줄 서술이 정확하다.
   부수 확인: `dotnet sln add src/... tests/...` 가 `.slnx` 안에 `<Folder Name="/src/">`,
   `<Folder Name="/tests/">` 를 만든다. 50줄의 둘째 항목도 실측과 일치한다.
   대상 프레임워크는 `net10.0` 이다.
2. `FsUnit.xUnit` 의 독립성 — 확인. 해석된 버전은 7.1.1 이고 의존성은
   `FSharp.Core 5.0.2`, `NHamcrest 4.0.0`, `xunit.v3 1.0.0` 뿐이다(`project.assets.json` 기준).
   `FsUnit` 은 들어오지 않는다. `FsUnit` 패키지 단독 의존성은 `FSharp.Core`, `NUnit 4.0.1` 이므로
   35줄의 "NUnit 용 어서션" 서술도 맞다. NuGet 등록 대소문자도 `FsUnit.xUnit` 이 맞다.
3. `open FsUnit.Xunit` — 확인. `FsUnit.xUnit` 만 넣은 xUnit 프로젝트에서
   `actual |> should equal expected` 가 컴파일되고 테스트가 돈다. `open FsUnit` 으로 바꾸면
   `should` 를 쓰는 줄마다 `FS0039` 가 난다. 428줄 결론이 맞다(단서는 위 개선 권장 참조).
4. `Option`/`Result` 에는 `[<RequireQualifiedAccess>]` 가 없다 — 확인.
   `open Option`, `open Result`, `open ValueOption` 은 오류 없이 통과하고
   `open List`/`Array`/`Seq` 는 `FS0892` 다.

오류 번호 세 개 모두 실측과 일치한다.
- `FS0222` — 선언 없는 파일. 인용 문장이 현재 SDK 출력과 완전히 같다.
- `FS0039` — 순서 역전. 파일 안(중첩 모듈 순서 뒤집기)과 파일 사이(`.fsproj` 순서 뒤집기) 양쪽에서 재현했다.
- `FS0892` — `[<RequireQualifiedAccess>]` 모듈 `open`.

시그니처 주석 11개 전부 FSI 실측과 일치한다.
`rateFor: string -> float`, `total: string -> float -> float`, `item: string -> int -> Item`,
`label: Item -> string`, `describe: int -> string`(3곳), `findCompleted: Learner -> Learner * int`,
`promoteIfEligible: Learner * int -> Learner`, `awardPoints`/`settleMonth: Learner -> Learner`,
`describe: Learner -> string`, `areEqual: 'a -> 'a -> bool when 'a : equality`.

펜스 배정이 옳다. 실행 가능한데 `id` 가 빠진 블록은 없다.
`id` 없는 `fsharp` 블록 6개는 모두 FSI 단독 실행이 불가능한 것들이다.
- 102줄: 일부러 `FS0039` 를 내는 예.
- 135줄: 파일 첫 줄 선언 세 형태를 나란히 적은 조각. 한 파일에 셋이 함께 올 수 없다.
- 224, 236, 358, 433줄: `[<Fact>]` 와 xUnit·FsUnit 참조가 필요하다. 덧붙여 `namespace` 와
  최상위 `module X.Y` 는 `.fsx` 에서 파싱 자체가 안 된다(`FS0010`). 152줄·266줄이 그 이유를 밝힌 것도 맞다.
셸 명령은 `bash`, `.fsproj` 조각은 `xml`, 콘솔 출력은 펜스만, 배정이 일관된다.

도구 서술 실측 결과.
- 12-18줄, 25-32줄, 44-47줄 명령을 그대로 순서대로 실행해 `dotnet build`, `dotnet test`,
  `dotnet run` 까지 통과했다. `dotnet run` 출력은 `Hello from F#` 이다(원서의 `Hello world from F#` 은 옛 템플릿).
- 21줄: `dotnet sln add` 가 프로젝트 인자를 여러 개 받는다 — 확인.
- 20줄: `-lang F#` 을 따옴표 없이 써도 bash 가 `#` 을 주석으로 보지 않는다 — 확인.
  `#` 은 낱말 첫 글자일 때만 주석을 시작한다.
- 36줄: 솔루션 디렉터리에서 `dotnet test` 를 실행하면 솔루션의 테스트 프로젝트를 빌드해 실행한다 — 확인.
  39줄의 출력 형식도 실제 출력과 같은 모양이다.
- 54줄: 콘솔 프로젝트 출력 디렉터리에 `Shop.dll` 과 실행 파일 `Shop` 이 함께 생긴다 — 확인.
- 60-61줄: F# 은 `.fs` 파일을 자동 수집하지 않고 `<Compile Include=... />` 순서가 컴파일 순서다 — 확인.
- 185줄: `open` 으로 이름이 가려질 때 오류도 경고도 없다 — 확인(`04-modules` 실행 단위 경고 0개).
- 215줄: `open` 을 모듈 안에 둘 수 있다 — 확인.
- 252-256줄: 실패 출력이 `어셈블리.모듈.테스트이름` 으로 찍힌다 — 확인.
  실측 예: `ShopTests.월말 정산을 하면.Pro 수강생은 보너스 300점을 받는다 [FAIL]`.
  백틱 이름에 공백과 한글을 쓴 모듈·함수 이름이 그대로 나온다(259줄 서술과 일치).
- 405-413줄 `Assert.Equal` 실패 출력, 468-476줄 FsUnit 실패 출력 — 두 블록 모두 실측 출력과
  줄바꿈·들여쓰기까지 같다. FsUnit 쪽 기댓값에 `Equals` 가 붙는 것(466줄)도 확인했다.
- 465줄의 FsUnit 조합 — `should not' (equal 2)`, `should be True`, `should be Empty`,
  `should haveLength 3`, `should be (greaterThan 1)`, `should throw typeof<System.Exception>`
  여섯 개를 한 테스트에 넣어 통과시켰다. 전부 유효하다.
- 478줄: xUnit 어서션과 FsUnit 어서션을 한 파일에 섞어 쓸 수 있다 — 확인.

원서 오탈자 판단 2건 모두 맞다.
- 원서 p.54 `Db.save` 주석 `// Customer -> bool` 은 오류다. 본문이 `()` 를 반환하므로
  `Customer -> unit` 이 맞고, p.55·p.56 의 같은 코드는 `// Customer -> unit` 으로 적혀 있다.
  같은 책 안에서 어긋난 것이므로 p.54 쪽이 오탈자다.
- 원서 p.61 FsUnit 절 테스트 이름 `should not upgrade eligible STD customer to VIP` 은 오류다.
  본문은 `Id = 3`(홀수) 이라 구매액이 80M 에 머물러 조건을 못 채우는 경우이고,
  p.60 의 같은 테스트 이름은 `should not upgrade ineligible STD customer to VIP` 다. `in` 이 빠졌다.
  (같은 p.61 블록의 둘째 테스트는 `[<Fact>]` 들여쓰기와 `let actual` 들여쓰기도 깨져 있다.)

개념 서술 확인.
- 네임스페이스와 모듈의 역할 구분(129-131줄), 담을 수 있는 것의 차이, 파일 첫 줄 선언 세 형태와
  (1)/(3) 의 차이(148줄) 모두 정확하다.
- 컴파일 순서가 의미를 갖는 이유와 그 대가·이득(113줄)의 서술 방향이 맞다.
  다만 "왜 위에서 아래로만인가"의 근거가 빠져 있다. 113줄 앞에 한 줄 넣으면 초심자에게 도움이 된다.
  ```
  - 이 순서가 필요한 까닭은 F# 의 타입 추론이 위에서 아래로 한 번만 훑기 때문이다. 어떤 이름을 쓰는 지점에서 그 이름의 타입이 이미 확정되어 있어야 하므로, 정의가 사용보다 앞에 와야 한다.
  ```
- `Assert.Equal(expected, actual)` 의 인자 순서에 맞춰 `areEqual expected actual` 을 잡은 것(333줄),
  레코드의 구조적 동등성으로 필드 전체를 한 번에 비교한다는 서술(354줄) 모두 정확하다.
- 순수 함수라서 테스트가 쉬워진다는 264줄의 논지, `findCompleted` 만 주입 대상으로 남긴다는
  305줄의 조언 모두 타당하다.

용어 후보는 `.cache/review/04-glossary.md` 에 정리했다.
`docs/ko/GLOSSARY.md` 는 지시대로 읽기만 했다.

## 기확정 용어 변경 제안

없다. 이 챕터에서 기확정 항목을 뒤집을 근거는 나오지 않았다.
`tupled parameter`(튜플 매개변수), `structural equality`(구조적 동등성), `side effect`(부수 효과),
`parameter`/`argument` 구분 모두 이 챕터에서 어긋난 곳 없이 쓰였다.

챕터 밖 사항 하나: `docs/ko/01-domain-modelling.md:350` 이 "XUnit" 으로 적혀 있다.
04챕터는 전부 "xUnit" 이다. 공식 이름이 xUnit.net 이므로 01챕터 쪽을 "xUnit" 으로 맞춰야 한다.
