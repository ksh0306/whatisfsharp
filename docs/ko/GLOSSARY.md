# F# 용어집 (한국어)

`docs/ko/` 학습 노트 전체가 이 표기를 따른다. F# 전문가 검수자만 편집한다.

표기 원칙
- 정착된 한국어가 있으면 그것을 쓴다(재귀, 불변, 튜플).
- 정착된 역어가 없으면 원어/음차를 택한다. 억지 신조어를 만들지 않는다.
- 타입 이름(`unit`, `Option`, `Result`)은 번역하지 않고 원어를 백틱으로 쓴다.
- 용어 첫 등장 1회만 `한국어(영어)`로 병기하고, 이후에는 한국어만 쓴다.
  각 챕터는 따로 읽히므로 병기는 챕터마다 1회까지 허용한다.
- MS 공식 한국어 문서와 F# 커뮤니티 표기가 갈리는 경우 비고에 둘 다 적고 하나를 택한다.
- F# 버전을 언급할 때는 원서 서술을 그대로 옮기지 말고 `--langversion` 으로 실측해 확인한다.
  "최신 F# 에서는" 같은 상대 표현을 쓰지 않고 버전 번호를 적는다.
- 컴파일러·FSI 메시지를 그대로 인용하는 대목은 원문 표기를 고치지 않는다(예: "활성 패턴", "형식").
- 이 노트는 `type`을 "타입"으로 쓴다(MS ko 는 "형식"). 따라서 "형식"이 들어가는
  MS 역어는 채택하지 않는다.
- 원서에 없는 절을 표시하는 꼬리말은 `(노트 보충)` 하나로 쓴다. 원서의 한 대목을 늘린 절은
  `(원서 p.48 확장)` 처럼 페이지를 함께 적는다. `(원서에 없음)`·`(원서에 없는 보충)` 쓰지 않는다.
- 외부 NuGet 패키지가 필요한 실행 단위는 이식성 규칙 세 가지를 지킨다.
  (1) `#r "nuget: ..."` 에 버전을 고정한다(예: `#r "nuget: FsToolkit.ErrorHandling, 5.2.0"`).
  버전을 적지 않으면 새 버전이 올라올 때 `open` 경로나 실측 시그니처 주석이 예고 없이 어긋난다.
  (2) `id` 를 떼지 않는다. 패키지 API 변화로 조용히 깨질 위험이 가장 큰 자리이므로 게이트를 남긴다.
  (3) 그 블록 앞 산문에 선행 요구사항을 한 줄 적는다 — 처음 한 번은 네트워크가 있어야 패키지를
  받아 오고 그 뒤에는 로컬 NuGet 캐시로 돌며, 받아 오지 못하면 `error FS0999` 로 실패한다.
- 표는 영어 칸의 정렬 키로 알파벳 순을 잡는다. 키는 백틱을 벗기고 `[<Struct>]` 같은 특성 표기는
  `[<`·`>]` 를 벗긴 안쪽 이름으로 삼으며 대소문자를 무시한다. 괄호 한정어와 타입 매개변수는
  벗기지 않고, 공백도 문자로 그대로 비교한다. 그래서 `[<Struct>]` 는 `string interpolation` 뒤
  `struct representation` 앞, `[<TailCall>]` 은 `tail recursion` 뒤 `target framework` 앞에 오고,
  `` `map` `` 이 `` `Map` (collection type) `` 보다, `nullable reference types` 가 `` `Nullable<'T>` `` 보다 앞에 온다.
  기호만으로 된 항목은 기호가 정렬 키가 되지 못하므로 `bang (!)` 판례를 따라 영어 칸에 이름을 적고
  괄호에 기호를 넣는다 — `compose operator (>=>)` 가 `c` 자리에 있다. 본문 표기는 기호 쪽이다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| abstract class | 추상 클래스 | `[<AbstractClass>]` 특성을 붙인 타입. MS ko 표기와 일치. 인터페이스와의 실질 차이는 상태(`let` 바인딩)를 담을 수 있다는 점이다 — F# 은 인터페이스에 `default` 구현을 적을 수 없고(적으면 그 타입이 클래스가 되어 `interface ... with` 로 구현하려 할 때 오류 FS0887), 인터페이스 본문에 `let` 을 적으면 오류 FS0963 이다. 10챕터 본론 |
| abstract member | 추상 멤버 | `abstract member Label : int -> string`. 구현 없이 시그니처만 적는 멤버. 인터페이스 선언과 추상 클래스에 함께 쓰인다. 키워드를 가리킬 때는 `abstract member` 를 백틱으로 쓴다. 10챕터 본론 |
| access modifier | 접근 지정자 | `private`/`internal`/`public`. MS ko F# 문서의 절 제목은 "액세스 제어"(Access Control)이고 MS ko C# 문서는 "액세스 수정자"이나, 노트는 통용 표기 "접근 지정자"를 택한다. "접근 제어자"·"액세스 수정자" 쓰지 않는다. 원서 p.122 는 이것을 "the private accessor"라 부르지만 accessor 는 보통 프로퍼티의 get/set 을 가리키므로 원서 표기를 옮기지 않는다. 컴파일러·FSI 메시지 인용에서는 원문의 "액세스"를 그대로 남긴다. 9챕터 본론, 10챕터 캡슐화 절과 공유 |
| accumulating errors | 오류를 모으는 방식 | 검증 함수 전부를 실행해 실패를 리스트에 쌓는 합성 방식. 대비어는 `fail-fast`(첫 오류에서 멈추는 방식). "오류 누적"은 `accumulator`→누적값 과 겹쳐 `fold` 의 상태로 읽히므로 쓰지 않는다. 실패 자리가 리스트 타입인지로 시그니처에서 구별된다. 8챕터 본론 |
| accumulator | 누적값 | `fold` 의 상태. 코드에서는 `acc`. MS ko 는 "누산기"이나 하드웨어 레지스터 뉘앙스가 강해 쓰지 않는다. 문맥에 따라 "상태"로 풀어 쓰는 것도 허용. "누적기" 쓰지 않음 |
| active pattern | 액티브 패턴 | `(\|Name\|_\|)` 형태. MS ko 는 "활성 패턴"이나 켜짐/꺼짐 상태로 읽혀 오해를 부른다. 커뮤니티 통용 음차를 택한다. 부분 액티브 패턴은 기본형이 `option` 을 반환하고, F# 6 이후 `[<return: Struct>]` 로 `voption`, F# 9 이후 `bool` 도 반환할 수 있다. 컴파일러·FSI 메시지를 인용할 때는 원문의 "활성 패턴"을 그대로 남긴다. 네 종류의 줄임 규칙 — 각 챕터 첫 등장은 전체 이름(부분 액티브 패턴 등)으로 쓰고, 이후에는 "액티브"만 떼어 "부분 패턴 / 매개변수 있는 부분 패턴 / 다중 케이스 패턴 / 단일 케이스 패턴"으로 줄여 쓴다. "패턴"까지 떼어 "부분"·"다중 케이스"·"단일 케이스" 한 낱말로 쓰지 않는다. 표의 종류 칸도 이 줄임형을 쓴다. 7챕터 본론 |
| adaptor function | 어댑터 함수 | 합성이 안 맞물릴 때 사이에 끼우는 `'b -> 'c` 함수 |
| aggregation function | 집계 함수 | `sum`, `average`, `max` 처럼 컬렉션을 값 하나로 줄이는 함수. LINQ 의 `Aggregate` 에 대응하는 것은 `List.fold` 다 |
| Algebraic Type System (ATS) | 대수적 타입 시스템 | 원서 고유 표기(원서 p.9). 함수형 일반 통용은 algebraic data type(대수적 데이터 타입, ADT). 원서 대조를 위해 "대수적 타입 시스템"을 쓰고 약어는 ATS 로 둔다 |
| AND type | AND 타입 | 여러 값을 동시에 담는 타입(튜플, 레코드). 영문 대문자를 그대로 쓴다. "곱 타입"으로 번역하지 않는다 |
| anonymous function | 익명 함수 | `fun x -> ...`. 같은 것을 람다라고도 부른다 |
| anonymous record | 익명 레코드 | `{\| ... \|}`. 이름 없는 레코드를 그 자리에서 만드는 것. 필드는 이름의 서수 순으로 정렬되고 적은 순서는 타입에 영향을 주지 않는다(실측: `{\| Hive = ...; Frames = ... \|} = {\| Frames = ...; Hive = ... \|}` 이 `true`). 기확정 `anonymous function`→익명 함수 와 계열을 맞춘다. "무명 레코드"·"익명 기록" 쓰지 않는다. 13챕터 본론, 14챕터. 15챕터는 이 표기 없이 `{\| ... \|}` 를 한 번 쓴다 |
| API reference | API 참조 | 라이브러리의 타입과 멤버 목록을 담은 문서. 언어 안내서·튜토리얼과 갈라 쓴다 — 원서 자료 목록의 `F# Docs` 가 건 `fsharp.github.io/fsharp-core-docs` 는 `FSharp.Core` 의 API 참조이고, 언어 안내서와 튜토리얼은 Microsoft Learn 쪽이다. MS ko 표기와 일치. "API 레퍼런스"·"API 명세" 쓰지 않는다. 16챕터 |
| applicative | 애플리커티브 | 원서 표기는 Applicatives(원서 p.114). 정착된 역어가 없다. "적용자"·"응용 함자"는 커뮤니티 통용이 아니고 "함자"는 functor 의 역어라 겹친다. 음차를 택한다. 첫 등장 1회 `애플리커티브(applicative)` 병기. 형용사 자리에서는 "애플리커티브 방식"으로 쓰고 `monadic`(모나드 방식)과 짝을 맞춘다. F# 5 의 `and!` 가 이 방식을 문법으로 감싼 것이다. 8챕터 본론 |
| `apply` | `apply` | 함수 이름은 번역하지 않는다. `Result<('a -> 'b),'e list> -> Result<'a,'e list> -> Result<'b,'e list>`. 성공 자리에 함수가 든 `Result` 를 받는 점이 `map`/`bind` 와 다르다. 관용 연산자 `<*>` 는 "`apply` 연산자", `<!>`(`Result.map` 의 다른 이름)는 "`map` 연산자"로 부른다. 두 연산자 모두 `<` 로 시작해 우선순위가 같고 왼쪽부터 묶인다. 8챕터 본론 |
| argument | 인자 | 호출 시 실제로 넘기는 값. 정의 쪽은 "매개변수" |
| `Array` | `Array` | 번역하지 않는다. 즉시 평가되는 고정 길이 연속 메모리이자 그 지원 모듈. 타입 표기는 `'a array` 또는 `'a[]`. 다차원용 모듈은 `Array2D`/`Array3D`/`Array4D`. 자료구조를 일반 명사로 가리킬 때는 "배열"로 써도 된다 |
| array pattern | 배열 패턴 | 패턴 자리에 적는 `[\| a; b; c \|]`. MS ko 표기와 일치. 패턴에 적은 이름의 개수와 배열 길이가 정확히 같아야 그 케이스가 성립한다. 6챕터 본론 |
| assembly | 어셈블리 | 프로젝트 하나가 컴파일된 결과물 `.dll`. MS ko 표기와 일치 |
| assertion | 어서션 | MS ko 는 "어설션", 테스트 관련 번역서는 "단정문"·"단언"도 쓴다. 셋이 갈리므로 외래어 표기법대로 옮긴 "어서션" 하나로 고정한다. `Assert.Equal`, `should equal` 같은 검증 한 줄을 가리킨다 |
| assignment operator | 할당 연산자 | `<-`. MS ko 표기와 일치. `=`(비교)와 갈라 쓴다. 기확정 `mutable`(가변)과 짝으로 쓰인다. "대입 연산자" 쓰지 않는다. 13챕터 |
| `Async` | `Async` | 타입 이름은 번역하지 않는다. `async { ... }` 계산 식으로 만들고 `Async.RunSynchronously` 로 실행한다. 지연 평가되므로 값을 만드는 것만으로는 본문이 돌지 않는다(실측 확인 — `async` 는 `RunSynchronously` 시점에, `task` 는 만드는 순간에 본문이 실행된다). 계산 식 이름은 소문자 값 `async` 이므로 타입과 구별해 백틱으로 적는다. `Async.RunSynchronously` 는 진입점에서만 쓴다. 12챕터 본론 |
| `asyncResult` | `asyncResult` | 계산 식 이름은 소문자 값 이름이라 번역하지 않는다. `FsToolkit.ErrorHandling` 이 제공하고 `Async<Result<'a,'e>>` 를 다룬다 — `Async` 가 `Result` 를 감싼 순서다. 도우미 함수는 비동기 쪽이 `AsyncResult` 모듈(`AsyncResult.requireSome`·`AsyncResult.mapError`), 동기 쪽이 `Result` 모듈(`Result.requireTrue`·`Result.mapError`)에 있다. "비동기 결과 계산 식" 처럼 풀어 옮기지 않는다. 12챕터 본론 |
| attribute | 특성 | `[<Fact>]`, `[<RequireQualifiedAccess>]`. MS ko 표기와 일치. "어트리뷰트"도 통용되나 "타입" 표기와 충돌하지 않으므로 MS 표기를 택한다 |
| attribute function | 특성 함수 | View Engine 에서 HTML 특성 하나를 만드는 함수. 이름 앞에 밑줄이 붙는다(`_class`·`_href`·`_datetime`). 기확정 `attribute`→특성 을 그대로 이어 쓴 것이고 `[<Fact>]` 류의 F# 특성과 영어 낱말이 겹치므로, 두 개념이 한 단락에 오는 자리에서는 "HTML 특성" 으로 갈라 쓴다. "속성 함수" 쓰지 않는다(`property`→프로퍼티 와 충돌한다). 13·15챕터 본론 |
| auto-generalization | 자동 일반화 | 컴파일러가 타입 주석 없는 정의를 제네릭으로 일반화하는 동작 |
| auto-property | 자동 프로퍼티 | `member val X = expr`. MS ko 는 "자동으로 구현된 속성"(auto-implemented property)이나 길고 "속성" 표기를 쓰지 않으므로 채택하지 않는다. 오른쪽 식은 생성 시점에 한 번만 평가된다. `with get, set` 을 붙이면 설정 가능, 붙이지 않으면 읽기 전용. 10챕터 |
| `[<AutoOpen>]` | `[<AutoOpen>]` | 특성 이름은 번역하지 않는다. 이 특성을 붙인 모듈은 그 네임스페이스나 어셈블리를 참조하기만 하면 `open` 없이 이름이 보인다(4챕터에서 이미 쓰였다). 원서 p.155 는 이것으로 직접 만든 `option` 계산 식을 자동으로 들여온다. 12챕터 |
| backward compatibility | 하위 호환 | 명사형은 "하위 호환성". MS ko 는 "이전 버전과의 호환성"이나 길어서 쓰지 않는다 |
| banana clips | 바나나 클립 | 액티브 패턴 이름을 감싸는 `(\|` `\|)` 괄호 짝. 원서 p.91 표기. 정착된 역어가 없어 음차한다. "바나나 괄호"·"바나나 클립스" 쓰지 않음. 7챕터 |
| bang (!) | `!` | 원서가 `let!`·`do!`·`return!` 의 `!` 를 "the bang" 이라 부른다(원서 p.155). "뱅" 으로 음차하지 않는다. 그 자리에서는 `let!` 처럼 키워드를 그대로 적거나 "`let!` 의 `!`" 로 쓰고, 기호 하나만 두고 설명할 때는 백틱을 씌운다. 문법의 일부이므로 값에 쓰는 연산자가 아니다. 12챕터 |
| base case | 기저 경우 | 재귀가 멈추고 값을 내놓는 갈래. 짝은 재귀 경우(recursive case). "기본 경우"·"종료 조건"·"베이스 케이스" 쓰지 않는다. 기저 경우를 적는 것과 입력이 그 갈래에 닿는 것은 다른 문제다. 상속의 기반 타입(base type)과는 영어 낱말만 겹치는 별개 개념이다. 11챕터 본론 |
| base type | 기반 타입 | `inherit` 로 물려받는 쪽. 짝은 하위 타입(derived type). MS ko 는 "기본 클래스"·"기본 형식"이나 "기본"이 default 와 겹쳐 쓰지 않는다. "부모 타입"·"상위 타입" 쓰지 않음. 단일 케이스 판별 유니온이 감싼 타입은 이것이 아니라 원래 타입(underlying type)이다 — 두 낱말을 섞어 쓰지 않는다. 10챕터 본론 |
| behaviour driven development (BDD) | 행위 주도 개발 | 약어 BDD 병기 허용 |
| `bigint` | `bigint` | 번역하지 않는다. `System.Numerics.BigInteger` 의 F# 별칭이고 표현 범위 제한이 없는 정수 타입. 리터럴 접미사는 `I`(`42I`). 11챕터 |
| `bind` | `bind` | 모듈 함수 이름은 번역하지 않는다. `Option.bind`, `Result.bind`. "바인드"로 음차하지 않고, `binding`(바인딩)과 같은 문장에서 섞어 쓰지 않는다 |
| binding | 바인딩 | `let` 바인딩. 억지 역어를 만들지 않고 음차 고정. 하위 구분은 함수 바인딩/값 바인딩 |
| BOM | BOM | byte order mark. 번역하지 않고 대문자 세 글자로 쓴다. "바이트 순서 표시"·"바이트 순서 마크" 쓰지 않는다. `dotnet new` 템플릿이 만든 `.fs`·`.fsproj` 와 `-f sln` 으로 만든 `.sln` 은 BOM 이 붙은 UTF-8 이고 `.slnx` 는 붙지 않는다(병합자 실측, SDK 10.0.111). BOM 을 떼도 빌드는 성공하므로 인코딩 자체가 걸림돌은 아니다. 실제로 걸리는 자리는 `^<Project` 처럼 줄 앞을 잡는 치환 패턴이 아무 말 없이 안 맞는 것이다(병합자 실측). 17챕터 |
| breakpoint | 중단점 | MS ko 표기와 일치. "브레이크포인트" 쓰지 않음 |
| `byref` | `byref` | 번역하지 않는다. FSI 가 .NET 의 `out`/`ref` 매개변수를 보여 줄 때 쓰는 표기(`Decimal.TryParse(s: string, result: byref<decimal>) : bool`). `out` 매개변수 항목과 짝이다 |
| call chain | 호출 사슬 | 처리되지 않은 예외가 올라가는 경로. "호출 체인"도 통용이나 노트는 "호출 사슬" |
| camel case | 카멜 표기 | 첫 글자 소문자. 값과 함수 이름에 쓴다. MS ko 는 "카멜식 대/소문자" |
| capacity (domain limit) | 정원 | 원서의 recently used list 가 받는 최대 크기(원서 p.137 "maximum size (capacity)"). .NET `ResizeArray.Capacity` 프로퍼티와 반드시 갈라 써야 하는 개념이므로 "용량"을 쓰지 않는다. `Capacity` 프로퍼티는 백틱 원어로 두고, 도메인 상한만 "정원"으로 쓴다. "최대 크기"도 후보였으나 한 낱말이 아니어서 문장이 늘어진다. 영어 칸의 (domain limit) 는 프로퍼티 쪽과 구분하기 위한 표시다. 10챕터 |
| capture group | 캡처 그룹 | MS ko 표기와 일치. 정규식의 `( )` 로 잡아내는 부분. `Match.Groups` 의 0번은 매칭된 전체 문자열이고 1번부터가 캡처 그룹이다. 8챕터 |
| case data | 케이스 데이터 | 케이스 식별자 뒤 `of` 에 붙는 타입. FSI 한국어 메시지는 "공용 구조체 사례"라고 하지만, `discriminated union`을 "판별 유니온"으로 확정했으므로 "사례" 대신 "케이스"로 계열을 맞춘다 |
| case identifier | 케이스 식별자 | `Subscribed`, `Ok` 처럼 케이스를 가리키는 이름. 값을 만들 때 함수처럼 앞에 붙인다. "경우 이름" 쓰지 않음 |
| cast / casting | 변환 | 총칭을 따로 음차하지 않는다. 방향을 밝힐 때는 상향 변환(`:>`)·하향 변환(`:?>`)을 쓰고, 방향을 가리지 않는 자리에서는 "변환" 한 낱말로 쓴다(원서 요약의 "interfaces/casting" → "인터페이스와 변환"). `conversion` 과 뜻이 갈리지 않는다 — 이 노트에서 "변환"이 나오는 자리는 모두 타입 변환이고, F# 6 의 additional implicit conversions 도 MS ko 가 "암시적 변환"으로 옮긴다. 음차 "캐스팅"은 상향 변환/하향 변환과 어울리지 않아 쓰지 않는다. 10챕터 |
| character reference | 문자 참조 | `&lt;`·`&amp;`·`&#39;` 처럼 HTML 에서 문자를 대신하는 표기. HTML 명세 용어 character reference 를 옮긴 것이다. 통용 표기는 "HTML 엔티티" 쪽이 흔하나 엔티티는 이름 있는 참조(`&amp;`)만 가리키고 숫자 참조(`&#39;`)를 담지 못한다. 15챕터가 실측한 출력에 숫자 참조가 나오므로 둘을 함께 덮는 "문자 참조" 를 택한다. 엔티티라 부르는 문헌도 있다는 것만 알아 두면 된다. 15챕터 본론 |
| `Choice` | `Choice` | 번역하지 않는다. 다중 케이스 액티브 패턴의 실제 반환 타입. `FSharp.Core` 에 `Choice<'T1,'T2>` 부터 `Choice<'T1,...,'T7>` 까지만 있고 이것이 케이스 상한 7개의 근거다. 케이스 식별자는 `Choice1Of3` 꼴이다 |
| circular reference | 순환 참조 | 프로젝트 A 가 B 를, B 가 A 를 참조하는 상태. F# 파일 사이의 관계를 말할 때는 "순환 의존" |
| class | 클래스 | MS ko 표기와 일치. 10챕터 본론 |
| class type | 클래스 타입 | F# 이 `type X() = ...` 로 선언하는 타입을 부르는 이름(원서 "class type"). MS ko "클래스 형식"에서 형식→타입만 치환한 표기. 레코드·판별 유니온과 구별해야 하는 자리에서는 반드시 "클래스 타입"으로 쓰고, 문맥이 분명하면 "클래스"로 줄인다. 10챕터 본론 |
| CLI | CLI | 번역하지 않는다. `dotnet` CLI 를 가리킨다. "명령줄 인터페이스"로 풀어 쓰지 않는다. 기확정 `SDK` 행과 같은 규칙이다. 14챕터의 `[<CLIMutable>]` 은 이 낱말과 무관한 특성 이름이므로 용례에 넣지 않는다. 4·17챕터 |
| closure | 클로저 | 정의 시점 스코프의 값을 붙잡아 두는 함수 값 |
| code file | 코드 파일 | `.fs`. 프로젝트가 빌드에 포함하는 쪽 |
| collection | 컬렉션 | 음차 고정. "모음/집합" 쓰지 않음(집합은 `Set`). 5챕터 본론 |
| command palette | 명령 팔레트 | VS Code 의 `CTRL+SHIFT+P` 패널. MS ko 표기와 일치. "커맨드 팔레트"·"명령 창" 쓰지 않는다. 서문 챕터·17챕터 |
| companion module | 같은 이름의 모듈 | 타입과 같은 이름을 붙여 그 타입 전용 함수를 담는 모듈(`Option` 타입과 `Option` 모듈, `Nights` 타입과 `Nights` 모듈). 영어권에서도 정착된 용어가 아니고 원서·MS ko 모두 쓰지 않는다. 원서는 "a module with the same name as the type"으로 풀어 쓴다. 새 역어를 만들지 않고 "타입과 같은 이름의 모듈"로 풀어 쓰며, 문맥이 분명하면 "같은 이름의 모듈"로 줄인다. "동반 모듈"·"컴패니언 모듈" 쓰지 않는다. 9챕터 본론 |
| `comparison` constraint | `comparison` 제약 | 시그니처의 `when 'a : comparison`. 순서 비교가 가능해야 한다는 뜻. `Set`/`Map`/`sortBy`/`maxBy` 가 요구한다. `equality` 제약보다 강하다 |
| compile order | 컴파일 순서 | `.fsproj` 의 `<Compile Include=... />` 가 적힌 순서. F# 에서 의미를 갖는다 |
| compiler directive | 지시문 | `#r`, `#load`, `#I`, `#time`. MS ko 는 "컴파일러 지시문"이고 문맥이 흐릴 때는 그렇게 늘려 쓴다. `#r`/`#load` 는 `.fsx`/`.fsscript` 에서만 쓸 수 있고 `.fs` 에 쓰면 `error FS0076` 이다 |
| compose operator (>=>) | `>=>` | 연산자는 번역하지 않고 한국어 이름도 붙이지 않는다. 서술할 때는 "핸들러를 이어 붙이는 `>=>`" 처럼 풀어 쓴다. Giraffe 의 `compose` 에 붙은 연산자이고, `h1 >=> h2` 는 `h2` 를 `h1` 의 다음 핸들러로 넘기므로 `h1` 이 다음을 부르지 않으면 `h2` 는 실행되지 않는다. 기확정 `function composition operator`(`>>`, 함수 합성 연산자)와 다른 것이므로 "함수 합성 연산자" 라고 부르지 않는다. 커뮤니티의 "fish operator"·"피시 연산자"·"어부 연산자" 쓰지 않는다. 영어 칸에 이름을 적고 괄호에 기호를 넣은 것은 정렬 키를 만들기 위한 것이며(`bang (!)` 판례) 본문 표기는 `>=>` 하나다. 13챕터 본론, 14챕터 |
| compound computation expression | 복합 계산 식 | 효과 둘을 겹쳐 다루는 계산 식(원서 p.159 절 제목 "Compound Computation Expressions"). `asyncResult` 가 `Async` 와 `Result` 를 겹친 예다. "합성 계산 식" 은 함수 합성(function composition)과 겹쳐 읽히므로 쓰지 않는다. 12챕터 본론 |
| computation expression | 계산 식 | MS ko 표기와 일치. `expression`→식 과 맞물린다. "계산 표현식" 금지. 8·12챕터 본론 |
| computation expression builder | 계산 식 빌더 | 계산 식이 부르는 멤버를 담은 클래스 타입(`type OptionBuilder() = ...`)과, 그 타입의 인스턴스를 묶은 소문자 값을 함께 가리킨다. 기확정 `computation expression`→계산 식 계열에 맞춘다. "작성기"·"생성기"·"빌더 클래스" 쓰지 않고 음차 "빌더" 를 쓴다. 문맥이 분명하면 "빌더" 로 줄인다. 멤버 이름(`Bind`·`Return`·`ReturnFrom`·`Zero`·`Combine`·`Delay`·`MergeSources`·`Source` 등)은 번역하지 않고 백틱 원어로 적는다 — 컴파일러가 이름으로 찾는 멤버라 번역하면 코드와 어긋난다. 빌더 인스턴스 이름(`option`·`result`·`asyncResult`·`validation`)도 번역하지 않는다. `Source` 는 `let!`·`do!` 오른쪽 식을 빌더가 다루는 타입으로 한 번 걸러 주는 멤버이고, `FsToolkit.ErrorHandling` 의 `result` 가 이 오버로드를 두고 있어 오류 코드가 계산 식마다 갈린다(`do!` 행 참고). 8챕터 한 곳·12챕터 본론 |
| cons operator | cons 연산자 | `::`. 라틴 표기 고정. "콘즈"로 음차하지 않는다. 리스트 맨 앞에 원소 하나를 붙이는 일만 하며, 우선순위가 `\|>` 보다 높다 |
| constant pattern | 상수 패턴 | `match` 케이스에 리터럴이나 `[<Literal>]` 상수를 적는 패턴. 대비어는 변수 패턴이며 둘을 한 문장에서 짝으로 쓴다. MS ko 는 "리터럴 패턴" 도 쓰지만 F# 문법 이름을 따라 "상수 패턴" 으로 고정한다. 기확정 `[<Literal>]` 행이 이미 이 표기를 쓴다. 12챕터 본론 |
| constructor | 생성자 | MS ko 표기와 일치. 주 생성자(primary constructor)·매개변수 없는 생성자(default constructor)·스마트 생성자(smart constructor) 세 행과 계열을 맞춘다. "컨스트럭터" 쓰지 않는다. 9·10챕터 |
| content negotiation | 콘텐츠 협상 | 클라이언트가 `Accept` 헤더로 원하는 형식을 말하고 서버가 규칙에 있는 것을 골라 응답하는 방식. Giraffe 는 `negotiate` 핸들러가 판단한다. MS Learn ko(ASP.NET Core 응답 형식 지정)와 MDN ko 가 둘 다 "콘텐츠 협상" 이고, 같은 문서군의 `content root`→콘텐츠 루트 와 web 문맥의 `content` 표기를 하나로 맞춘다. "내용 협상"·"컨텐츠 협상" 쓰지 않는다. 14챕터 본론, 15챕터 |
| content root | 콘텐츠 루트 | 앱이 자기 파일을 찾는 기준 폴더. 프로젝트 폴더가 기본이고 웹 루트(`wwwroot/`)가 그 아래에 놓인다. MS ko 표기와 일치. "내용 루트" 쓰지 않는다. 15챕터 |
| copy-and-update record expression | 복사-수정 레코드 식 | `{ r with F = v }`. MS ko 는 "복사 및 업데이트 레코드 식". 노트는 짧고 뜻이 분명한 "복사-수정"을 쓰되 첫 등장 시 원어 병기 |
| culture | 문화권 | MS ko 표기와 일치. 타입 이름 `CultureInfo` 는 번역하지 않는다. `CultureInfo.InvariantCulture` 는 "고정 문화권"(MS ko 표기)이라 부르되 코드에서는 원어 그대로 쓴다 |
| curried parameters | 커링된 매개변수 | 튜플 매개변수와 대비되는 짝 |
| currying | 커링 | 해스컬 커리(Haskell Curry)에서 온 이름. 음차 고정, "커리화" 쓰지 않음 |
| custom computation expression | 사용자 정의 계산 식 | 코어에 없는 효과를 다루려고 빌더를 직접 만들어 쓰는 계산 식. 기확정 `custom operator`→사용자 정의 연산자 와 "사용자 정의" 를 맞춘다. "커스텀 계산 식" 쓰지 않는다. 패키지가 주는 것(`validation`·`result`·`asyncResult`)은 "`FsToolkit.ErrorHandling` 이 제공하는 계산 식" 으로 쓰고 사용자 정의라 부르지 않는다. 12챕터 본론 |
| custom operator | 사용자 정의 연산자 | MS ko 는 "사용자 지정 연산자". 일반 프로그래밍 관용을 따라 "사용자 정의"를 택한다. `\|>` 는 표준 연산자이지 사용자 정의 연산자가 아니다(정의 방식만 같다) |
| default constructor | 매개변수 없는 생성자 | `type X() =` 로 선언한 인자 없는 생성자. FSI 는 `new: unit -> X` 로 보여 준다. MS ko 는 "기본 생성자"이나 그 표기는 오류 FS0963 메시지에서 primary constructor 쪽에 쓰이고 있어 겹친다. 그래서 "기본 생성자"를 쓰지 않고 풀어 쓴다. 10챕터 |
| delegate | 델리게이트 | .NET 의 함수 타입. MS ko 는 "대리자" 이나 커뮤니티 통용 음차를 택한다. F# 함수는 델리게이트가 아니지만 메서드 호출 자리에서 대상 델리게이트 타입이 정해져 있으면 컴파일러가 람다를 자동으로 변환한다 — 변환이 안 되는 것은 매개변수 타입이 `System.Delegate` 처럼 추상 기반 타입이어서 어느 델리게이트를 만들지 정할 수 없는 경우다(실측: `app.MapGet("/", fun () -> "x")` 는 `RequestDelegate` 오버로드가 잡혀 오류 FS0001). "F# 함수는 델리게이트가 아니므로 반드시 감싸야 한다" 로 적지 않는다. 13챕터 |
| delimiter | 구분자 | 칸을 나누는 문자(`\|`, `,`). 원서의 "delimited text file" 은 "구분자로 나뉜 텍스트 파일". "구분 문자" 쓰지 않음 |
| dependency injection | 의존성 주입 | MS ko 는 "종속성 주입" 이나 커뮤니티 통용을 택한다. 담는 그릇은 "의존성 주입 컨테이너" 이고 문맥이 분명하면 "컨테이너" 로 줄인다. 약어 DI 는 쓰지 않는다. 13챕터 도입, 14·15챕터 본론 |
| derived type | 하위 타입 | `inherit` 로 물려받은 쪽. 기반 타입(base type)과 짝이다. 타입 이론의 subtype 도 같은 표기로 쓴다. "파생 타입"·"자식 타입" 쓰지 않는다. 10챕터가 이미 이 표기를 쓴다. 짝 낱말이 갈리지 않게 배치 C 병합에서 등재했다 |
| deserialization | 역직렬화 | JSON 같은 텍스트를 값으로 되돌리는 것. 짝은 `serialization`→직렬화. MS ko 표기와 일치하고 "역직렬 변환"·"디시리얼라이즈" 쓰지 않는다. `System.Text.Json` 의 F# 지원 범위는 두 방향이 같다 — 레코드·`list`·`Set`·`Map`·튜플·`Option` 은 되고 `Option` 이 아닌 판별 유니온은 어느 방향이든 `NotSupportedException` 이다(실측, .NET 10). 14챕터 본론 |
| deterministic | 결정적 | 같은 입력에 항상 같은 출력 |
| discriminated union | 판별 유니온 | 약어 DU 허용. "구별 합집합" 쓰지 않음. MS ko 는 "구별된 공용 구조체"이나 커뮤니티 통용 표기를 택한다 |
| dispose | 해제한다 | `Dispose()` 호출을 가리킨다. 명사형은 "해제". MS ko 는 "삭제"(삭제 패턴)와 "해제"(리소스 해제)를 섞어 쓴다. 6챕터가 `File.Delete` 를 "삭제", 임시 파일 청소를 "정리"로 쓰고 있어 두 낱말을 피해 "해제"를 택한다 |
| `do!` | `do!` | 키워드는 번역하지 않는다. 효과가 감싼 `unit`(`Result<unit,'e>`·`Async<unit>`)을 받아 값은 버리고 실패만 흘려보내며, 빌더의 `Bind` 를 부른다. 원서 p.162 의 "supports functions that return unit" 을 그대로 옮기면 틀린다 — 평범한 `unit` 을 주면 `error FS0001`(`async`·직접 만든 빌더) 또는 `error FS0041`(`FsToolkit.ErrorHandling` 의 `result` — 빌더의 `Source` 오버로드 해결에서 먼저 걸린다)이다(실측 확인). "효과가 감싼 `unit`" 으로 쓰고 어순을 뒤집어 "`unit` 을 감싼 효과" 로 적지 않는다 — 감싸는 쪽이 `Async`·`Result` 같은 효과이고 감싸이는 쪽이 `unit` 이다. 12챕터 본론 |
| document database | 문서 데이터베이스 | 레코드를 문서 단위로 담는 데이터베이스. MS ko 표기와 일치. "도큐먼트 DB"·"문서형 DB" 쓰지 않는다. 16챕터가 저장소 뒤를 바꿀 후보로 한 번 든다 |
| Domain-Driven Design | 도메인 주도 설계 | 약어 DDD 허용 |
| Domain-Specific Language (DSL) | 도메인 특화 언어 | 첫 등장에서 `도메인 특화 언어(DSL, Domain-Specific Language)` 로 한 번만 병기하고 이후 약어를 쓴다(`Line of Business (LOB)` 행과 같은 규칙). 계산 식의 다른 쓰임으로 원서 p.164 가 Saturn·Farmer 를 든다. "도메인 한정 언어"·"영역 특화 언어" 쓰지 않는다 |
| downcast | 하향 변환 | `:?>`. 기확정 `upcast`(상향 변환) 행 비고에만 적혀 있어 검색이 되지 않으므로 독립 행으로 올린다. 상향 변환과 달리 실패할 수 있고 런타임 검사가 붙는다. MS ko 는 "다운캐스트". 3·10챕터가 쓰는 것은 상향 변환뿐이고 `:?>` 는 아직 어느 노트에도 나오지 않는다 — 짝 낱말이 갈리지 않게 미리 등재했다 |
| DTO | DTO | Data Transfer Object 의 약어. 첫 등장만 `DTO(Data Transfer Object)` 로 병기하고 이후 약어만 쓴다. 번역하지 않는다 — "데이터 전송 객체" 는 통용되지만 코드에 남는 이름이 아니다. 도메인 타입과 별개로 요청·응답 경계에만 쓰는 평평한 타입을 가리킨다. 14챕터 본론 |
| eager evaluation | 즉시 평가 | `List`/`Array` 의 평가 방식. 대비어는 지연 평가. 5챕터. 6챕터는 대비어 쪽만 쓴다 |
| early return | 조기 반환 | 함수 중간에서 값을 내고 빠져나오는 것. F# 에는 없다. 계산 식이 실패한 뒤 뒷줄을 건너뛰는 것도 조기 반환이 아니라 `Bind` 가 뒷줄의 함수를 아예 부르지 않는 것이다(원서 p.154 의 "no early return"). "이른 반환" 쓰지 않는다. 12챕터 |
| effect | 효과 | `Option`·`Result`·`Async` 처럼 값을 한 겹 감싸 성패나 비동기 같은 맥락을 함께 나르는 타입을 원서가 부르는 이름(원서 p.153). 기확정 `side effect`→부수 효과 와 다른 것이다. 두 낱말이 한 문장에 함께 나오면 부수 효과 쪽을 반드시 온낱말로 적고 "효과" 로 줄이지 않는다. 음차 "이펙트" 와 "작용" 쓰지 않는다. 12챕터 본론 |
| element function | 요소 함수 | View Engine 에서 HTML 요소 하나를 만드는 함수(`html`·`p`·`li`). 결과 타입이 모두 `XmlNode` 라서 조각을 함수로 뺄 수 있다. 요소 대부분이 특성 목록과 자식 목록 둘을 받고, `meta`·`link` 처럼 자식을 담을 수 없는 요소는 특성 목록만 받는다(자식 목록을 붙이면 오류 FS0003 — 실측). "태그 함수" 쓰지 않는다. 13·15챕터 본론 |
| encapsulation | 캡슐화 | MS ko 표기와 일치. F# 에서 그 뼈대는 클래스 본문의 `let`·`let mutable` 이 밖에서 보이지 않는다는 성질이다. 10챕터 |
| endpoint | 엔드포인트 | 음차 고정. HTTP 메서드와 경로에 핸들러를 붙인 한 항목. Giraffe 에서는 값이고 타입은 `Endpoint list` 다. "종점"·"단말" 쓰지 않는다. 13챕터 본론, 14·15챕터 |
| endpoint routing | 엔드포인트 라우팅 | ASP.NET Core 의 라우팅 API 에 얹혀 동작하는 방식. Giraffe 5 부터 쓸 수 있다(실측: `EndpointRouting` 이 Giraffe 5.0.0 어셈블리에 있고 4.1.0 에는 없다). `Giraffe.EndpointRouting` 모듈 이름은 원어 백틱으로 쓴다. 13챕터 본론 |
| entry point | 진입점 | MS ko 표기와 일치. `[<EntryPoint>]` 특성 이름은 원어 백틱. F# 6 부터 마지막 코드 파일의 최상위 코드가 암시적 진입점이 된다 |
| `enum` | 열거형 | MS ko 표기와 일치. `System.DayOfWeek` 같은 .NET 열거형. 선언된 이름 밖의 값도 담을 수 있어 이름을 다 적어도 빠짐없는 패턴 매칭으로 인정되지 않는다(경고 FS0104). 이 점이 판별 유니온과 다르다 |
| `equality` constraint | `equality` 제약 | 시그니처의 `when 'a : equality`. `=` 비교가 가능해야 한다는 뜻. `distinct`/`distinctBy`/`groupBy`/`countBy` 가 요구한다 |
| escape | 이스케이프 | HTML 문법에 쓰이는 문자를 문자 참조로 바꾸는 것. 정착된 음차를 쓰고 "탈출"·"회피" 로 옮기지 않는다. 동사형은 "이스케이프한다". View Engine 의 `str` 과 특성 함수가 `<`·`>`·`&`·`"`·`'` 다섯 문자를 바꾸고 `rawText` 는 바꾸지 않는다(실측). 15챕터 본론 |
| ethos | 신조 | 원서 p.192 의 "My F# ethos is" 를 옮긴 것. 저자가 스스로 내놓는 한 줄짜리 원칙을 가리킨다. "에토스"·"기풍"·"철학" 쓰지 않는다. 16챕터 |
| exception | 예외 | `throw`/`raise` 는 모두 "던진다"로 쓴다. "예외를 발생시킨다" 대신 "던진다" |
| exhaustive pattern matching | 빠짐없는 패턴 매칭 | 명사형은 "빠짐없음(exhaustiveness)". "망라적"은 생소해 쓰지 않는다. FSI 한국어 경고는 "패턴 일치가 완전하지 않습니다"로 "완전"을 쓰나, 노트는 뜻이 바로 읽히는 "빠짐없는"을 택한다. 서술문에서 "모든 케이스를 빠짐없이 적어야 한다"로 풀어 쓰는 것도 허용하되, 원어 병기는 이 표기에 붙인다. 케이스를 빠뜨리면 경고 FS0025 |
| exhaustive search | 완전 탐색 | 가능한 후보를 모두 만들어 보고 그중에서 고르는 방식. 기확정 "빠짐없는 패턴 매칭(exhaustive pattern matching)"과 영어 낱말이 겹치므로 알고리즘 쪽은 "완전 탐색"으로만 쓰고 "빠짐없는 탐색" 쓰지 않는다. 11챕터 |
| exit code | 종료 코드 | `main` 이 마지막에 돌려주는 `int`. 0 이 성공. CLI 프로세스가 셸에 돌려주는 값도 같은 말로 부른다 — 스택 오버플로로 죽은 `dotnet fsi` 가 134(11챕터), 덮어쓰기 확인을 요구하며 멈춘 `dotnet new sln` 이 73(17챕터, 실측)이다. 컴파일러 오류 번호(`오류 FS0222`)와 성격이 다르므로 섞어 쓰지 않는다. "반환 코드" 쓰지 않음. 6·11·13·17챕터 |
| `exn` | `exn` | 번역하지 않는다. `System.Exception` 의 F# 별칭 |
| expression | 식 | **확정.** MS 공식 한국어 F# 문서가 일관되게 "식"을 쓰고(`람다 식`, `계산 식`, `일치 식`, `복사 및 업데이트 레코드 식`) 복합어와 맞물린다. "표현식"도 통용되나 노트 전체를 "식"으로 통일한다. 대비어는 "문(statement)" |
| F# Interactive (FSI) | FSI | 번역하지 않는다. 첫 등장만 F# Interactive(FSI) 로 병기하고 이후 FSI 로 줄인다. 식별자가 아니라 도구 이름이므로 백틱을 쓰지 않는다. 명령줄 진입점은 `dotnet fsi` |
| F# Software Foundation | F# Software Foundation | 조직 이름이므로 번역하지 않는다. 한 절 안에서 되풀이할 때만 "재단" 으로 줄인다. 약어 FSSF 는 쓰지 않는다 — 원서 본문이 약어를 쓰지 않고 서문 챕터와 16챕터가 전체 이름과 "재단" 만으로 문장을 다 만든다(기확정 `dependency injection` 의 DI, `tail call optimisation` 의 TCO 를 쓰지 않기로 한 것과 같은 판단이다). "F# 소프트웨어 재단" 쓰지 않는다. 서문 챕터·16챕터 |
| fail-fast | 첫 오류에서 멈추는 방식 | `Result.bind` 로 이었을 때의 동작. 영어를 그대로 쓰지 않고 풀어 쓴다. "빠른 실패"는 뜻이 좁게 전달되지 않아 쓰지 않는다. 대비어는 `accumulating errors`(오류를 모으는 방식). 이 방식이 나쁜 것이 아니라 뒤 단계가 앞 단계 결과에 의존할 때 쓰는 방식이라는 점을 함께 적는다. 8챕터 본론 |
| fake (test double) | 가짜 | 테스트에서 실제 구현 대신 끼워 넣는 함수·객체. 원서 표기도 fake 다. "스텁(stub)"·"모의(mock)"도 통용되나 노트는 원서를 따라 "가짜"로 고정하고 식별자도 `fake` 로 시작하게 짓는다(`fakeReader`). 명사구는 "가짜 리더", "가짜 데이터". 구분이 필요한 챕터가 오면 그때 세분한다 |
| field | 필드 | 레코드의 이름 붙은 부분. MS ko 도 "필드" |
| file handle | 파일 핸들 | 음차 고정. 열린 채 남으면 Windows 에서 같은 파일의 쓰기·삭제가 막힌다 |
| first-class citizen | 일급 시민 | 함수를 값처럼 다룰 수 있다는 뜻. "일급 값/일급 객체"도 통용. 함수에 한정해 말할 때는 "일급 함수"를 쓴다 |
| first-class function | 일급 함수 | MS ko 표기와 일치 |
| `fold` | `fold` | 모듈 함수 이름은 번역하지 않는다. "접기"·"축약" 쓰지 않음. `List.fold` 의 `folder` 는 (상태, 원소) 순, `List.foldBack` 의 `folder` 는 (원소, 상태) 순이며 인자 순서도 `folder`→리스트→초기값 으로 뒤집힌다 |
| `folder` | `folder` | `fold`/`foldBack` 에 넘기는 함수의 매개변수 이름. 번역하지 않는다. `reduce` 쪽의 같은 자리 이름은 `reduction` 이므로 둘을 섞어 쓰지 않는다 |
| format specifier | 서식 지정자 | `%d`, `%s`, `%A`. MS ko 는 "형식 지정자"이나 이 노트는 `type`을 "타입"으로 쓰므로 "형식"과의 충돌을 피해 "서식"을 택한다. `%A` 에는 폭 지정이 먹지 않는다 — `printfn "[%-9A]" (Some 60)` 도 `printfn "[%9A]" (Some 60)` 도 `[Some 60]` 을 낸다(실측). 표를 맞추려면 `sprintf "%A"` 로 문자열을 만든 뒤 `%-9s` 로 찍는다. `%A` 로 찍은 `None` 은 `None` 이고 `<null>` 이 아니다 |
| forward pipe operator | 정방향 파이프 연산자 | `\|>`. MS ko 표기와 일치. 문맥이 분명하면 "파이프 연산자"로 줄여 쓴다 |
| framework reference | 프레임워크 참조 | `.nuspec`/`.fsproj` 의 `FrameworkReference`. 패키지가 공유 프레임워크 전체를 요구하는 표기이며 `dotnet fsi` 의 `#r "nuget: ..."` 은 이 요구를 채워 주지 않는다(실측: `open Microsoft.AspNetCore.Builder` 가 오류 FS0039). MS ko 표기와 일치. 13·15챕터. 14챕터는 같은 준비 코드를 쓰지만 이 표기는 쓰지 않는다 |
| `FsToolkit.ErrorHandling` | `FsToolkit.ErrorHandling` | NuGet 패키지 이름. 등록 대소문자를 그대로 쓴다(`FsUnit`·`xUnit` 행과 같은 규칙). `validation` 계산 식과 `Validation<'a,'e>` 타입 약어를 제공한다. 계산 식만 쓰려면 `open FsToolkit.ErrorHandling.ValidationCE`, 타입 약어와 `Validation.ofResult` 까지 쓰려면 `open FsToolkit.ErrorHandling` 이 필요하다. `#r "nuget: ..."` 로 참조할 때는 머리말의 이식성 규칙대로 버전을 고정한다(5.2.0 으로 실측). 8·12챕터 |
| FsUnit | FsUnit | 어서션 라이브러리. NUnit 용 패키지 이름이 `FsUnit`, xUnit 용이 `FsUnit.xUnit`. NuGet 등록 대소문자를 그대로 쓴다 |
| function binding | 함수 바인딩 | 매개변수가 최소 하나 있는 `let`. `unit` 하나뿐이어도 함수 바인딩 |
| function composition | 함수 합성 | |
| function composition operator | 함수 합성 연산자 | `>>`. "합성 연산자"로 줄여 씀 |
| function signature | 함수 시그니처 | |
| functional-first | 함수 우선 | MS 공식 한국어 F# 문서 표기. "함수형 우선"으로 늘려 쓰지 않는다. 순수 함수형(purely functional)과 구별되는 말이므로 "함수형 언어"로 뭉개지 않는다 |
| general-purpose language | 범용 언어 | |
| generic | 제네릭 | 음차 고정. "일반형" 쓰지 않음 |
| guard clause | 가드 절 | `match` 케이스의 `when` 절. 문맥이 분명하면 "`when` 가드"로 줄여 쓴다. 빠짐없음 검사는 가드의 참/거짓을 계산하지 않는다 |
| handler | 핸들러 | 음차 고정. 요청 하나에 응답을 만드는 함수. 타입 이름 `HttpHandler` 는 원어 백틱으로 쓰고 일반명사로 가리킬 때만 "핸들러" 로 쓴다. "처리기"·"핸들러 함수" 쓰지 않는다. 이름 규칙은 `<대상><동작 또는 응답 내용>Handler`. 13챕터 본론, 14·15챕터 |
| happy path | 해피 패스 | 실패가 한 번도 나지 않을 때 지나는 길(원서 p.155). 정착된 역어가 없어 음차한다. "행복 경로"·"행복한 경로" 쓰지 않는다. 3챕터가 세운 선로 비유와 함께 쓰는 자리에서는 "`Ok` 선로" 로 풀어 써도 된다. 12챕터 |
| head | 머리 | 비어 있지 않은 리스트의 첫 원소. 첫 등장 1회 `머리(head)` 병기. "헤드"로 음차하지 않는다. 함수 이름 `List.head`/`List.tryHead` 는 번역하지 않는다 |
| header (HTTP) | 헤더 | HTTP 요청·응답의 머리 부분 항목. MS ko 표기와 일치하며 웹 맥락에서는 한정어 없이 "헤더" 로 쓴다. 기확정 `header row`(헤더 줄, 구분자 텍스트의 첫 줄)과 낱말이 겹치므로 6·11챕터 계열과 같은 문장에서 섞어 쓰지 않고, 그쪽은 언제나 "헤더 줄" 온낱말로 적는다. 13·14챕터 |
| header row | 헤더 줄 | 구분자 텍스트의 첫 줄. MS ko 계열의 "머리글 행" 쓰지 않음. `header (HTTP)`→헤더 가 등재되어 같은 낱말이 두 개념을 가리키므로 "헤더" 로 줄여 쓰지 않고 언제나 온낱말로 적는다(기확정 `effect`/`side effect`, `pipeline`/`middleware pipeline` 과 같은 갈라 쓰기 규칙). 6·11챕터 |
| heap allocation | 힙 할당 | 참조 타입 값을 만들 때 힙에 객체가 생기는 것. `[<Struct>]` 를 붙이면 없어진다. 7챕터 `voption` 행의 "힙 할당이 없다"와 표기가 같다. 7·9챕터 |
| helper function | 도우미 함수 | 라이브러리가 손질용으로 얹어 준 작은 함수(`AsyncResult.requireSome`·`Result.requireTrue`·`Result.mapError`). 기확정 `asyncResult` 행이 이미 이 표기를 쓴다. "헬퍼"·"보조 함수"·"유틸 함수" 쓰지 않는다. 2·8·12챕터 |
| hierarchical data | 계층 데이터 | 트리처럼 자기 자신을 품는 구조의 데이터. "계층형 데이터"·"위계 데이터" 쓰지 않는다. 원서 절 제목 Recursion with Hierarchical Data(원서 p.146). 11챕터 본론 |
| higher-order function | 고차 함수 | 함수를 매개변수로 받거나 함수를 반환하는 함수 |
| host | 호스트 | 음차 고정. 앱을 띄워 요청을 받는 껍데기(`WebApplication`). "숙주" 쓰지 않는다. 명사는 "호스트" 로 쓰고, 앱을 띄워 두는 동작이나 그 방식을 가리킬 때만 "호스팅" 을 쓴다("호스팅 모델"). 13챕터 |
| `htmlView` | `htmlView` | 핸들러 이름은 번역하지 않는다. `XmlNode -> HttpHandler`. `text`·`json`·`negotiate` 와 같은 계열의 응답 핸들러이며 이 이름들도 모두 원어 백틱으로 쓴다. 13·15챕터 본론 |
| HTTP method | HTTP 메서드 | `GET`·`POST`·`PUT`·`DELETE`. 원서는 verb 라고 부르지만 노트는 MS ko 와 같은 "HTTP 메서드" 로 통일한다. "동사"·"HTTP 동사" 쓰지 않는다. 13챕터 본론, 14챕터 |
| `HttpContext` | `HttpContext` | 타입 이름은 번역하지 않는다. 산문에서 풀어 쓸 때는 "요청 컨텍스트". "요청 맥락" 은 쓰지 않는다 — 기확정 `effect` 행이 "성패나 비동기 같은 맥락" 으로 "맥락" 을 이미 쓰고 있어 12챕터를 읽은 독자에게 겹친다. 웹 쪽은 정착된 음차 "컨텍스트" 로 갈라 쓴다. 13챕터 본론, 14·15챕터 |
| `HttpFunc` | `HttpFunc` | 타입 이름은 번역하지 않는다. `HttpContext -> HttpFuncResult` 의 타입 약어(실측 확인). 13챕터 본론 |
| `HttpFuncResult` | `HttpFuncResult` | 타입 이름은 번역하지 않는다. `Task<HttpContext option>` 의 타입 약어(실측 확인). `None` 은 "이 핸들러가 이 요청을 처리하지 않았다" 는 뜻이다. 13챕터 본론 |
| `HttpHandler` | `HttpHandler` | 타입 이름은 번역하지 않는다. `HttpFunc -> HttpContext -> HttpFuncResult` 의 타입 약어. FSI 는 약어를 펼쳐 찍기도 하고 `HttpHandler` 로 찍기도 한다 — 람다로 적은 값은 펼쳐지고 함수를 조립해 만든 값은 약어 이름이 남는다(실측). 13챕터 본론, 14·15챕터 |
| identity element | 항등원 | 어떤 값에 적용해도 값을 바꾸지 않는 값. 누적값과 `fold` 의 초기값을 정하는 기준이다(곱셈 `1`, 덧셈 `0`, 문자열 이어 붙이기 `""`). 수학에서 정착된 표기를 그대로 쓴다. 기확정 항등 함수(identity function)와는 다른 것이므로 같은 문장에서 섞어 쓰지 않는다. 5·11챕터 |
| identity function | 항등 함수 | `id : 'a -> 'a`. `fun x -> x` 와 같다. 원서가 "id keyword" 라 부른 것은 부정확하다(키워드가 아니라 `FSharp.Core.Operators.id` 함수) |
| `IDisposable` | `IDisposable` | 번역하지 않는다. 제네릭이 아니다 — 원서 p.81 의 `IDisposable<'T>` 는 오기 |
| `IEnumerable<'T>` | `IEnumerable<'T>` | 번역하지 않는다. `seq<'T>` 와 같은 것이다 |
| `IEquatable<'T>` | `IEquatable` | 번역하지 않는다. 타입이 자기 자신과 값으로 비교되는 방법을 내놓는 .NET 계약. F# 의 `=` 는 이 인터페이스를 거치지 않고 `Object.Equals` 재정의로 간다. 10챕터 |
| illegal state | 잘못된 상태 | "잘못된 상태를 표현조차 할 수 없게 만든다(make illegal states unrepresentable)"가 1챕터의 모델링 지침 |
| immutability | 불변성 | 형용사형은 "불변" |
| implicit conversion | 암시적 변환 | MS ko 표기와 일치. "암묵적 변환" 쓰지 않음. F# 은 산술식에서 `int`→`decimal` 같은 암시적 변환을 하지 않으므로 변환 함수를 직접 적어야 한다. 변환을 손으로 적지 않아도 컴파일러가 끼워 넣는 자리는 따로 있다 — F# 6 의 additional implicit conversions 로 타입 주석이 붙은 `let` 바인딩 자리가 열렸고(F# 5.0 에서는 오류 FS0001), 함수·메서드의 인자 자리는 F# 4.7 에서도 통한다. 5·10챕터 |
| implicit yield | 암시적 yield | 시퀀스 식과 리스트 컴프리헨션 안에서 `yield` 를 적지 않아도 값이 그대로 원소가 되는 것. `yield` 는 번역하지 않는다. F# 4.7 부터 쓸 수 있다(원서는 F# 5 라고 적는다. `dotnet fsi --langversion:4.6`/`4.7` 로 실측 확인) |
| import declaration | `open` 선언 | 원서와 F# 명세는 "import declaration". 노트는 실제 키워드를 드러내는 "`open` 선언"을 쓴다 |
| indexer | 인덱서 | `dict[key]` 형태로 읽고 쓰는 멤버. MS ko 표기와 일치하고 11챕터가 이미 "대괄호 인덱서" 로 쓴다. 14챕터가 `ConcurrentDictionary` 를 다루며 "인덱서 설정"(쓰기)과 "인덱서로 읽기" 를 갈라 쓴다 — 전자는 추가·갱신을 겸하고 후자는 없는 키에서 `KeyNotFoundException` 을 던지므로 두 방향을 한 낱말로 뭉개지 않는다. "색인기"·"인덱서 접근자" 쓰지 않는다. 11·14챕터 |
| infix form | 중위 형태 | `a \|> f`. 연산자 분류를 말할 때는 "중위 연산자". MS ko 는 "중위 연산자" |
| inheritance | 상속 | MS ko 표기와 일치. 선언은 `inherit 기반타입(인자)` 한 줄이다. 10챕터 본론 |
| instance | 인스턴스 | 음차 고정. MS ko 도 "인스턴스". "객체"와 섞어 쓰지 않는다 — 타입에서 만들어 낸 하나를 가리킬 때만 인스턴스다. 1·2·3·6챕터가 이미 쓰고 9·10챕터가 이어 쓴다 |
| integrated terminal | 통합 터미널 | VS Code 창 안에 붙은 터미널 패널. MS ko 표기와 일치. "내장 터미널"·"인테그레이티드 터미널" 쓰지 않는다. 새로 여는 것은 `CTRL+SHIFT+백틱`, 이미 열린 패널을 접었다 펴는 것은 `CTRL+백틱` 이다. 17챕터 |
| interface | 인터페이스 | MS ko 표기와 일치. 10챕터 본론 |
| interop | 상호운용 | `interoperability`=상호운용성. MS ko 는 "상호 운용"으로 띄우나 노트는 붙여 쓴다 |
| Ionide | Ionide | 음차가 "아이오나이드"/"이오니데"로 갈려 라틴 표기로 고정. VS Code 의 F# 확장 |
| keyboard shortcut | 단축키 | 서문 챕터 표기와 일치. "키보드 지름길"·"키 바인딩" 쓰지 않는다. 키 이름은 원서 표기를 따라 대문자와 `+` 로 적는다(`CTRL+SHIFT+P`, `CTRL+F2`). 백틱 키는 인라인 코드 안에 기호를 넣기 어려우므로 `CTRL+백틱` 처럼 낱말로 적는다. 서문 챕터·17챕터 |
| lambda | 람다 | `fun x -> ...`. "익명 함수"와 같은 것을 가리킨다 |
| launch profile | 실행 프로필 | `Properties/launchSettings.json` 의 `profiles` 항목. `dotnet run` 은 첫 프로필을 쓰고 `--launch-profile <이름>` 으로 고른다. MS ko 는 "시작 프로필" 도 쓰나 노트는 "실행 프로필" 로 고정한다. 기확정 `template`(템플릿)이 이 파일을 만든다. 13챕터 |
| lazy evaluation | 지연 평가 | 값을 만드는 시점을 실제로 필요할 때까지 미루는 것. `Seq` 와 LINQ 의 평가 방식. MS ko 는 "지연 계산"도 쓰나 노트는 "지연 평가"로 고정한다. 형용사형은 "지연". `Lazy<'T>` 타입 이름은 번역하지 않는다. 6챕터 본론 |
| `let!` | `let!` | 키워드는 번역하지 않는다. 오른쪽 식의 효과를 한 겹 벗겨 이름에 묶고 빌더의 `Bind` 를 부른다. `!` 를 떼면 감싼 값이 그대로 묶여 타입이 달라진다. 효과를 만들지 않는 함수는 `!` 없이 평범한 `let` 으로 적는데, 이때 계산 식 안의 `let` 은 `map` 으로 바뀌는 것이 아니라 보통 `let` 바인딩 그대로다 — 원서 p.155 의 "Let bindings that would have used Option.map are automatically handled" 를 그대로 옮기지 않는다. 8챕터의 `and!` 는 앞줄에 기대지 않는 짝이고 빌더의 `MergeSources` 를 부른다. 8·12챕터 본론 |
| Line of Business (LOB) | 업무용 애플리케이션 | 첫 등장에서 `업무용 애플리케이션(LOB, Line of Business)` 으로 한 번만 병기하고 이후 한국어만 쓴다. MS ko 는 "기간 업무 애플리케이션"이나 뜻이 바로 오지 않아 채택하지 않는다 |
| linked list | 연결 리스트 | F# `List` 의 실제 구조. 앞에 붙이기는 싸고 인덱스 접근은 비싸다 |
| `List` | `List` | 번역하지 않는다. F# 의 불변 연결 리스트 타입이자 그 지원 모듈 이름. .NET 의 `List<'T>`(F# 에서는 `ResizeArray`)와 다른 것이므로 "리스트"라고만 쓸 때는 F# 쪽을 가리킨다 |
| list comprehension | 리스트 컴프리헨션 | `[ for x in ... do ... ]`. 정착된 역어가 없어 음차를 택한다. "리스트 내포"는 하스켈 계열 문헌에만 쓰여 원서 색인과 대조하기 어렵다. F# 명세는 이 문법을 "list expression"(리스트 식)이라 부르고 원서는 List Comprehension 이라 적는다. 한 문단 안에서 문맥이 분명하면 "컴프리헨션"으로 줄여 쓴다 |
| list pattern | 리스트 패턴 | 패턴 자리에 적는 `[ a; b ]`. MS ko 표기와 일치하고 기확정 `array pattern`(배열 패턴)과 계열이 맞다. 배열 패턴처럼 적은 이름의 개수와 리스트 길이가 정확히 같아야 그 케이스가 성립하며, 어긋나면 컴파일 오류가 아니라 그 케이스가 성립하지 않을 뿐이다. 7·8챕터 |
| `[<Literal>]` | `[<Literal>]` | 특성 이름은 번역하지 않는다. 컴파일 시점 상수를 만들어 그 이름을 `match` 케이스의 상수 패턴으로 쓸 수 있게 한다. 특성을 빼면 대문자 이름이 그냥 변수 패턴이 되어 모든 입력을 받아 삼키고, `warning FS0049` 와 뒤 케이스의 `warning FS0026` 이 난다(실측 확인). 특성을 윗줄에 두는 형태와 `let [<Literal>] X = ...` 형태가 모두 유효하다. 12챕터 본론 |
| locale | 로케일 | 1챕터 표기와 일치. 셸과 프로세스의 메시지 언어 설정을 가리킨다. `dotnet` CLI 와 컴파일러 메시지는 이 설정을 따라 번역돼 나오므로(실측: 한국어 로케일에서 `통과!  - 실패:     0, ...`), 영어 출력을 인용하는 대목은 `DOTNET_CLI_UI_LANGUAGE=en` 으로 얻은 것임을 밝힌다. .NET 타입 `CultureInfo` 쪽은 기확정 `culture`(문화권) 행이 맡으므로 둘을 섞어 쓰지 않는다. 1·4·17챕터 |
| loop | 반복문 | `for`·`while` 로 같은 일을 되풀이하는 구문. 파이프라인이나 재귀와 견주는 자리에서는 "반복문" 으로 쓰고(11·16챕터), 특정 구문을 짚을 때만 `for` 루프 처럼 키워드를 백틱으로 앞에 붙인다(5챕터 도입). "루프" 단독으로 쓰지 않는다. 5·11·16챕터 |
| `map` | `map` | 모듈 함수 이름은 번역하지 않는다. "사상"·"매핑" 쓰지 않음 |
| `Map` (collection type) | `Map` | 번역하지 않는다. 키-값 쌍을 담는 불변 정렬 컬렉션이자 그 모듈. "맵"·"사전" 쓰지 않음 — 다만 14·16챕터가 `ConcurrentDictionary` 를 "사전" 으로 부르는 자리는 이 컬렉션이 아니므로 그대로 둔다(기확정 `store` 행이 4챕터의 "리포지터리" 를 예외로 둔 것과 같은 처리다). 키에 `comparison` 제약이 붙는다. `List.map` 의 `map` 과 다른 것이므로 같은 문장에서 섞어 쓰지 않는다 |
| master page | 마스터 페이지 | 원서 절 제목 Adding a Master Page(원서 p.186)의 표기이고 MS ko 도 "마스터 페이지" 다. 여러 화면이 공유하는 껍데기를 가리키는 ASP.NET 계열 이름이다. Giraffe 에서 이 역할을 하는 것은 상속도 특별한 규칙도 없는 평범한 함수이므로, 노트 본문은 그 함수를 "공용 레이아웃" 이라 부르고 첫 등장에서 "다른 뷰 엔진에서 마스터 페이지나 레이아웃이라 부르는 것" 으로 잇는다. F# 코드를 설명하는 자리에서 "마스터 페이지" 를 쓰지 않는다. 15챕터 본론 |
| `match` expression | `match` 식 | MS ko 는 "일치 식". 노트는 키워드가 그대로 보이는 "`match` 식"을 쓴다. `pattern matching`을 "패턴 매칭"으로 확정했으므로 같은 문법 이름에 "일치"를 다시 쓰지 않는다. "매치 식" 쓰지 않음 |
| `MatchFailureException` | `MatchFailureException` | 번역하지 않는다. 빠짐없지 않은 `match` 식이 실행 시점에 어느 케이스에도 걸리지 않을 때 던지는 예외 |
| member | 멤버 | 타입 안에 선언하는 `member`/`static member`. 음차 고정, MS ko 도 "멤버". 키워드를 가리킬 때는 `member` 를 백틱으로 쓴다. 프로퍼티와 메서드를 아우르는 상위 낱말이므로 프로퍼티 하나를 가리키는 자리에서 "멤버"로 뭉개지 않는다. 9·10챕터 공통 |
| member constraint | 멤버 제약 | 시그니처의 `when ^a: (member Value: int)`. 기확정 `comparison` 제약 / `equality` 제약 과 계열을 맞춘다. `inline` 함수에서만 걸 수 있다. MS ko 는 "멤버 제약 조건". 9챕터 보충 |
| method | 메서드 | MS ko 표기와 일치. "메소드" 쓰지 않는다. 프로퍼티와 갈라야 하는 자리에서 쓴다 — FSI 시그니처에 `unit -> unit` 처럼 화살표가 붙으면 메서드, 타입만 적히면 프로퍼티다. 6·10챕터 |
| Microsoft Learn | Microsoft Learn | 문서 사이트 이름이므로 원어를 유지한다. 한국어판을 가리킬 때는 경로에 `ko-kr` 이 든 주소를 그대로 적는다(`learn.microsoft.com/ko-kr/dotnet/fsharp/`). 이 용어집 비고에 쓰는 "MS ko" 는 이 파일 안에서만 쓰는 약칭이고 노트 본문에는 쓰지 않는다. "MS 런"·"마이크로소프트 러닝"·옛 이름 "docs.microsoft.com" 쓰지 않는다. 16챕터 |
| middleware | 미들웨어 | 음차 고정. 요청이 차례로 지나며 각자 일을 하는 조각. "중간 계층"·"미들웨어 계층" 쓰지 않는다. 13챕터 본론, 14·15챕터 |
| middleware pipeline | 미들웨어 파이프라인 | `configureApp` 이 정하는 미들웨어의 순서. 기확정 `pipeline`(파이프라인, `\|>` 로 값을 흘려보낸 코드 형태)과 가리키는 것이 다르므로 웹 챕터에서는 반드시 온낱말 "미들웨어 파이프라인" 으로 적고 "파이프라인" 으로 줄이지 않는다(기확정 `effect`/`side effect`, `tail`/`tail recursion`, `overflow`/`stack overflow` 와 같은 갈라 쓰기 규칙). 함수 파이프라인과 다른 것이라는 한 문장을 13챕터에서 한 번 붙인다. "요청 파이프라인" 은 같은 것을 가리키는 다른 이름이므로 본문에 쓰지 않는다. 13챕터 본론, 14·15챕터 |
| model binding | 모델 바인딩 | 요청 본문·쿼리 문자열 같은 바깥 데이터를 타입 있는 값으로 되돌리는 일. Giraffe 에서는 `ctx.BindJsonAsync<'T>()`. MS ko 표기와 일치. 검증과 구별해 쓴다 — 모델 바인딩은 빠진 필드를 타입의 기본값으로 채우므로 `string` 필드에 `null` 이 들어온다(14챕터 실측). "모델 결합" 과 "바인딩" 단독 쓰지 않는다. 14챕터 본론 |
| module | 모듈 | 음차 고정. 값·함수·타입·모듈을 담는 F# 의 코드 묶음 단위 |
| monadic | 모나드 방식 | 원서 표기는 monadic(원서 p.117). `bind` 로 이어 첫 오류에서 멈추는 합성을 가리킨다. "모나딕" 음차는 형용사 어미가 한국어에 붙지 않아 문장에서 겉돌고, "모나드적"은 조어가 어색하다. 명사구 "모나드 방식"으로 고정한다. `monad` 자체를 설명하는 자리가 아니라 합성 방식을 가리키는 자리에만 쓴다. 8챕터 |
| multi-case active pattern | 다중 케이스 액티브 패턴 | `(\|A\|B\|C\|)`. 실패하지 않으므로 `option` 을 쓰지 않고 `Choice<...>` 를 반환한다. 케이스는 7개까지다(오류 FS0265). "다중 사례" 쓰지 않음. 줄임형은 "다중 케이스 패턴"이고 "다중 케이스" 한 낱말로 줄이지 않는다(줄임 규칙은 `active pattern` 행) |
| mutable | 가변 | `mutable` 키워드는 원어 백틱으로 쓴다 |
| mutual recursion | 상호 재귀 | 두 함수가 서로를 부르는 재귀. `let rec f ... and g ...` 로 잇는다. MS ko 표기와 일치. `rec` 없이 `and` 만 쓰면 오류 FS0576. 타입 정의에도 같은 `and` 를 쓴다. 11챕터 보충 |
| named function | 이름 있는 함수 | |
| namespace | 네임스페이스 | 음차 고정. MS ko 도 "네임스페이스". 타입·`open` 선언·모듈만 담는다 |
| nested module | 중첩 모듈 | `module X =` 로 다른 모듈 안에 둔 모듈. MS ko 표기와 일치 |
| next steps | 다음 걸음 | 원서 뒤에 노트가 덧붙이는 방향 안내. 15챕터가 이미 "다음 걸음" 으로 쓰고 16챕터가 절 제목으로 올렸다. "다음 단계"·"넥스트 스텝" 쓰지 않는다 — 절 제목과 방향 안내에 걸리는 규칙이고, 3·9챕터가 절차의 바로 다음 차례를 일반 명사 "다음 단계" 로 적은 두 곳은 그대로 둔다. 15·16챕터 |
| `null` | `null` | 번역하지 않는다. "널"로 음차하지 않는다 |
| nullable reference types | null 허용 참조 타입 | MS ko 는 "null 허용 참조 형식". F# 9 에서 들어온 옵트인 기능이고 기본은 꺼져 있다(`--checknulls+` 로 켠다) |
| `Nullable<'T>` | `Nullable` | 번역하지 않는다. 값 타입을 감싸는 .NET 제네릭 구조체 |
| nullness | nullness | 정착된 역어가 없어 원어를 쓴다. 시그니처에 보이는 `'a \| null` 표기를 가리킬 때만 등장한다 |
| object | 객체 | MS ko 는 "개체"(오류 FS0760 메시지도 "개체")이나 "객체 지향"이 이미 정착한 한국어이므로 "객체"를 택한다. 컴파일러·FSI 메시지를 인용하는 대목의 "개체"는 고치지 않는다. 타입 `obj` 는 백틱 원어로 쓰고 "객체"라 부르지 않는다. 인스턴스와 섞어 쓰지 않는다. 10챕터 본론 |
| object expression | 객체 식 | `{ new I with ... }`. MS ko 는 "개체 식"이나 위 `object` 행의 판단에 맞춘다. `expression`→식은 기확정. 만들어지는 것은 이름 없는 타입이고 바인딩의 정적 타입은 인터페이스 그 자체다. 10챕터 본론 |
| object programming | 객체 프로그래밍 | 원서 챕터 제목. 원서가 "object-oriented" 가 아니라 "object programming" 을 쓰므로 "객체 지향 프로그래밍"으로 바꾸지 않는다. 10챕터 |
| operator function form | 연산자의 함수 형태 | 연산자 이름을 괄호로 감싸 보통 함수처럼 적용하는 표기: `(\|>) v f`, `(+) 1 2`. "괄호 형태"도 허용 |
| operator overloading | 연산자 오버로딩 | 타입에 `static member (+) (a, b) = ...` 를 붙이는 것. MS ko 문서 제목은 "연산자 오버로드"이나 동작을 가리키는 명사로는 "오버로딩"이 통용된다. "연산자 다중 정의" 쓰지 않음. 기확정 사용자 정의 연산자(custom operator)와 다른 것이다 — 이쪽은 타입에 딸린 정적 멤버이고 인자가 튜플, 그쪽은 모듈 수준 `let` 이고 매개변수가 커링된다. 10챕터 보충 |
| `Option` | `Option` | 번역하지 않는다. 케이스 식별자는 `Some`/`None`. 실제 정의는 `None` 이 먼저다 |
| `option` (computation expression) | `option` 계산 식 | 계산 식 이름은 소문자 값 이름이라 번역하지 않는다. F# 코어에는 없다 — 빌더를 직접 만들거나 `FsToolkit.ErrorHandling` 것을 쓴다. 만들지 않고 `option { ... }` 을 적으면 `option` 이 타입 약어 이름으로 읽혀 `error FS0800` 이다(실측 확인). 타입 `Option` 과 구별해야 하므로 소문자 백틱 표기를 지킨다. 영어 칸의 (computation expression) 는 타입 쪽과 구분하기 위한 표시다. 12챕터 본론 |
| optional data | 선택적 데이터 | 원래 없을 수 있는 필드(중간 이름, 부제 등) |
| OR type | OR 타입 | 여러 경우 중 하나만 담는 타입(판별 유니온). "합 타입"으로 번역하지 않는다 |
| `out` parameter | `out` 매개변수 | 키워드는 원어. F# 은 `out` 매개변수를 선언할 수 없고, 상호운용 시 컴파일러가 반환값 튜플로 옮겨 준다 |
| overflow (arithmetic) | 넘침 | 계산 결과가 타입의 표현 범위를 벗어나는 것. F# 기본 산술 연산자는 넘침을 검사하지 않고 값이 감싸 돈다. 검사판은 `open Microsoft.FSharp.Core.Operators.Checked` 로 켠다(`Int64.MaxValue + 1L` 이 `OverflowException`). MS ko 는 "오버플로"이나, 이 노트는 "오버플로"를 스택 오버플로에만 남기고 산술 쪽은 "넘침"으로 갈라 쓴다. 11챕터 |
| overload | 오버로드 | 같은 이름에 시그니처가 다른 멤버가 여럿 있는 것. 명사로 "오버로드", 컴파일러가 그중 하나를 고르는 일은 "오버로드 해결" 로 쓴다. 기확정 `operator overloading`(연산자 오버로딩)과는 다른 자리다 — 그쪽은 타입에 연산자를 정의하는 일이고 이쪽은 멤버 시그니처가 여러 개인 상태다. "다중 정의"·"과부하" 쓰지 않는다. 10챕터에 있는 것은 연산자 오버로딩 쪽이다. 오버로드 해결이 결과를 갈라 놓는 실측 두 건 — `result { do! (평범한 unit) }` 은 빌더의 `Source` 오버로드에서 먼저 걸려 `error FS0041`, `ConcurrentDictionary.TryRemove` 는 키 타입 주석이 없으면 `bool` 만 돌려주는 오버로드가 잡혀 패턴 매칭에서 `error FS0001` 이다. 1·6·12·13·14챕터 |
| override | 재정의 | MS ko 표기와 일치하고 일반 통용이기도 하다. "오버라이드" 쓰지 않음. `override`·`default` 키워드는 백틱 원어로 쓰고, FSI 시그니처의 `override Owner: string` 같은 표기는 그대로 인용한다. 10챕터 본론 |
| package reference | 패키지 참조 | `dotnet add package` 로 거는 관계. `.fsproj` 의 `PackageReference` 항목은 원어 백틱으로 쓴다. 기확정 `project reference`(프로젝트 참조) 행과 같은 규칙. 4·17챕터는 명령과 `.fsproj` 항목으로만 쓰고 산문에서 이 표기를 아직 쓰지 않는다 — 표기가 갈리지 않게 등재해 둔다(`payload` 행과 같은 이유) |
| `parallelAsyncValidation` | `parallelAsyncValidation` | 계산 식 이름은 소문자 값 이름이라 번역하지 않는다. `FsToolkit.ErrorHandling` 이 제공하고(5.2.0 에서 이름 해석 실측 확인) `and!` 로 이은 오른쪽 식들을 진짜 병렬로 돌린다. `validation` 의 `and!` 는 병렬이 아니라 의존이 없어지는 것이라는 서술 뒤에 대비로 붙는 이름이다. 8·12챕터 |
| parameter | 매개변수 | 정의 쪽 이름. 호출 쪽은 "인자" |
| parameterized partial active pattern | 매개변수 있는 부분 액티브 패턴 | `(\|Name\|_\|) arg`. MS 공식 한국어 F# 문서가 "매개 변수가 있는 활성 패턴"을 쓰므로 "매개변수 있는"이 MS 표기와 계열이 맞다. "매개변수화된"은 `-ized` 직역이라 채택하지 않는다. 줄임형은 "매개변수 있는 부분 패턴"이고 "매개변수 있는 부분"으로 줄이지 않는다(줄임 규칙은 `active pattern` 행). 검사할 값이 항상 마지막 매개변수다 |
| partial active pattern | 부분 액티브 패턴 | `(\|Name\|_\|)`. 이름 마지막 자리의 와일드카드가 "입력 중 일부만 걸린다"는 뜻이고, 부분 적용(partial application)과는 관계가 없다. 기본형은 `option` 을 반환하고, F# 6 이후 `[<return: Struct>]` 로 `voption`, F# 9 이후 `bool` 도 반환할 수 있다. 줄임형은 "부분 패턴"이고 "부분" 한 낱말로 줄이지 않는다. 8챕터처럼 부분 함수(partial function)와 한 단락에 놓이는 자리에서도 머리 낱말이 아니라 뒤의 "패턴"/"함수"가 둘을 갈라 준다(줄임 규칙은 `active pattern` 행) |
| partial application | 부분 적용 | 필요한 인자 중 **일부**를 적용해 남은 인자를 기다리는 함수를 얻는 것. 인자를 하나도 적용하지 않은 함수 값 참조는 부분 적용이 아니다 |
| partial function | 부분 함수 | 가능한 입력 전부에서 값을 돌려주지 못하는 함수. F# 에서는 그런 입력에 예외를 던진다(`List.head`, `List.reduce`, `Seq.skip`). 이름이 비슷한 부분 적용(partial application)과는 관계가 없다. 표기 규칙 — 각 챕터 첫 등장에서 `부분 함수(partial function)` 로 병기한다. 같은 챕터에 부분 적용이 나오면 첫 등장에 "부분 적용과는 관계가 없다"를 한 절 덧붙인다. "부분"으로 줄여 쓰지 않고 "부분적 함수"도 쓰지 않는다. 액티브 패턴 쪽 줄임형이 "부분 패턴"이므로 "부분" 한 낱말은 어느 쪽도 가리키지 않는다. "순수한 부분", "각 부분에 이름이 붙는다"처럼 일반 명사로 쓰는 "부분"은 이 규칙과 무관하다. 지연 컬렉션에서는 예외가 호출 시점이 아니라 첫 순회 시점에 난다 |
| partial view | 부분 뷰 | 화면 조각을 만드는 함수. 원서 p.190 표기 partial view 를 옮긴 것이고 실체는 `Inspection -> XmlNode` 같은 함수다. "파셜 뷰"·"부분 화면" 쓰지 않는다. 13·15챕터 |
| Pascal case | 파스칼 표기 | 첫 글자 대문자. 타입 이름과 케이스 식별자에 쓴다. MS ko 는 "파스칼식 대/소문자" |
| pattern combinator | 패턴 조합 연산자 | 패턴 자리의 `&`(둘 다 만족)와 `\|`(하나라도 만족). 부정 조합은 없다. MS ko 는 개별 이름으로 "AND 패턴"/"OR 패턴"을 쓰나 기확정 "AND 타입"/"OR 타입"과 층위가 달라 헷갈리므로 노트는 두 연산자를 묶어 "패턴 조합 연산자"로 부른다. `\|` 패턴은 양쪽이 같은 변수 집합을 바인딩해야 한다(오류 FS0018) |
| pattern matching | 패턴 매칭 | MS ko 는 "패턴 일치"이나 커뮤니티 통용 "패턴 매칭"을 택한다. 동사형은 "매칭한다". 개별 문법 이름도 이 계열로 맞춘다(`match` 식, 타입 테스트 패턴) |
| payload | 페이로드 | 응답이나 요청 본문에 싣는 데이터 덩어리. 음차 고정이고 MS ko·커뮤니티가 함께 쓴다. 13·14챕터는 식별자로만 쓰고 있다(`payload`, `toPayload`) — 등재 이유는 산문에 쓸 때 "적재물"·"실은 값" 같은 갈래가 생기는 것을 막으려는 것이다. 표기가 필요 없으면 "응답 본문" 으로 풀어 쓰는 것도 허용한다. 13·14챕터 |
| pipeline | 파이프라인 | `\|>` 로 값을 함수에 차례로 흘려보낸 코드 형태. 음차 고정. "파이프 사슬" 쓰지 않음. 웹 문맥의 request pipeline·middleware pipeline 에는 이 낱말을 쓰지 않는다 — 13-15챕터는 온낱말 "미들웨어 파이프라인" 으로 적고 "파이프라인" 으로 줄이지 않는다(`middleware pipeline` 행) |
| placeholder value | 자리표시자 값 | MS ko 는 "자리 표시자". 노트는 붙여 쓴다. 타입 매개변수를 가리킬 때도 "자리표시자" |
| predicate | 술어 | `'a -> bool` 형태의 함수. 문장에서 함수임을 드러내야 하면 "술어 함수"로 늘려 쓴다. MS ko 는 "조건자"이나 커뮤니티 통용이 아니고, "조건 함수"는 가드 절의 조건과 헷갈린다. 논리학·전산학에서 정착된 "술어"를 택하고 첫 등장에 시그니처를 함께 보인다 |
| preface | 서문 | 원서 pp.1-2 의 절 이름. 노트 `00-preface-getting-started.md` 를 가리킬 때는 "서문 챕터" 로 쓴다 — 노트 열여덟 개가 서로를 부를 때 쓰는 형태는 `N챕터` 이고(320회), `N챕터 노트` 는 10회, 본문에 노트 파일 이름을 적은 자리는 17챕터 두 곳이 전부다(병합자 실측). 00 노트에는 원서 챕터 번호가 없고 게이트가 숫자와 "장" 을 붙인 형태를 막으므로 번호로 부를 수 없다. 원서 쪽을 가리킬 때는 "원서 서문" 으로 갈라 쓰고, 원서 서문의 범위는 pp.1-2 이므로 FSI·중단점 이야기가 있는 Getting Started(원서 p.6)를 여기에 섞지 않는다. "서문 노트" 쓰지 않는다. 서문 챕터·16·17챕터 |
| prefix form | 접두 형태 | `~-`, `!` 처럼 값 앞에 붙는 진짜 접두 연산자. MS ko 는 "접두사 연산자". `(\|>) a b` 는 접두 형태가 아니라 위의 "연산자의 함수 형태"다 |
| primary constructor | 주 생성자 | 타입 이름 뒤 괄호로 선언하는 생성자. 클래스 본문의 `let`·`do` 가 그 본문이다. MS ko 와 오류 FS0963 메시지는 "기본 생성자"인데 그 표기는 매개변수 없는 생성자(default constructor)로 읽히므로 채택하지 않는다. 컴파일러 메시지를 인용할 때는 원문의 "기본 생성자"를 그대로 남긴다. 용어를 쓰지 않고 "타입 이름 뒤 괄호의 생성자"로 풀어 쓰는 것도 허용하되, 줄여 부를 이름이 필요한 자리에서는 "주 생성자"를 쓴다. 10챕터 본론 |
| primitive | 원시 타입 | `int`, `string` 등. MS ko 는 "기본 형식"이나 이 노트는 "형식"을 쓰지 않으므로 "원시"를 택한다. "기본 타입" 쓰지 않음. 9챕터 본론 |
| primitive obsession | 원시 타입 강박 | 도메인 개념 자리에 `int`/`string`/`decimal` 을 그대로 쓰는 상태. 9챕터가 푸는 문제의 이름이며 원서 본문에는 없는 통용 표현(마틴 파울러의 코드 냄새 목록). 리팩터링 한국어판은 "기본형 집착"이나 기확정 `primitive`(원시 타입)과 계열이 맞지 않아 쓰지 않는다. 9챕터 도입부 1회 |
| project | 프로젝트 | 음차 고정. 컴파일 단위이자 어셈블리 하나에 대응한다 |
| project reference | 프로젝트 참조 | `dotnet add reference` 로 거는 관계 |
| property | 프로퍼티 | `member this.Value` 처럼 괄호 없이 읽는 멤버. MS ko 는 "속성"이나 기확정 `attribute`(특성)과 나란히 놓으면 속성/특성이 한 글자 차이로 헷갈린다. 커뮤니티 통용 음차를 택한다. 컴파일러·FSI 메시지는 "속성"을 쓰므로(`error FS0806: 'Value'은(는) 정적 속성이 아닙니다.`) 인용은 원문 표기를 그대로 남긴다. `member` 와 갈라 쓴다 — 프로퍼티는 멤버의 한 종류다. 읽기/쓰기 구분은 "읽기 전용 프로퍼티", "설정 가능 프로퍼티". 레코드의 `field` 는 필드이므로 프로퍼티라 부르지 않는다. 9·10챕터 공통 |
| pure function | 순수 함수 | 결정적이고 부수 효과가 없는 함수 |
| qualified name | 정규화된 이름 | `Inventory.Create.item` 처럼 모듈 이름을 앞에 붙인 이름. MS ko 표기와 일치. 동작을 말할 때는 "정규화된 접근" |
| query string | 쿼리 문자열 | `?code=H-07` 의 `code=H-07` 부분. MS ko 표기와 일치. 원서 표기는 한 낱말 querystring 이다. "쿼리스트링"·"질의 문자열" 쓰지 않는다. `route parameter` 와 다른 것이며 원서 p.171 이 이 둘을 뒤바꿔 적었다. 13챕터 |
| quicksort | 퀵소트 | 정착된 음차. "빠른 정렬"·"퀵 소트" 쓰지 않는다. 원서 절 제목 표기는 Quicksort(원서 p.145). 11챕터 |
| Railway Oriented Programming | 철도 지향 프로그래밍 | 약어 ROP 허용. 첫 등장 시 원어 병기. "레일웨이 지향 프로그래밍" 쓰지 않음 |
| range expression | 범위 식 | `[1..5]`, `[0..5..20]`. MS ko 표기와 일치 |
| `rawText` | `rawText` | 함수 이름은 번역하지 않는다. 문자열을 이스케이프하지 않고 그대로 끼워 넣는다. 이미 HTML 인 조각에만 쓰고 바깥에서 들어온 값에는 쓰지 않는다. 짝이 되는 `str` 은 이스케이프한다. 15챕터 본론 |
| `rec` | `rec` | 키워드는 번역하지 않는다. `let rec` 로 선언해야 함수 본문에서 자기 이름을 볼 수 있고, 빼면 오류 FS0039. "재귀 키워드"로 풀어 쓰는 것은 허용. 11챕터 |
| record | 레코드 | 음차 고정 |
| recursion | 재귀 | 정착된 한국어. 함수는 "재귀 함수", 자기 타입을 품는 정의는 "재귀형"(재귀형 판별 유니온), 갈래는 "재귀 경우". "되부름"·"리커전" 쓰지 않는다. 11챕터 본론 |
| recursive case | 재귀 경우 | 자기를 다시 부르는 갈래. 기저 경우와 짝. 원서는 general case 라고 부르지만(원서 p.141) 노트는 기저 경우와 대비가 분명한 "재귀 경우"를 쓴다. 11챕터 본론 |
| `reduce` | `reduce` | 번역하지 않는다. 상태와 원소의 타입이 같은 `fold` 의 특수한 경우이고, 첫 원소를 초기 상태로 쓰므로 그 원소는 함수를 거치지 않는다. 부분 함수이며 `List.tryReduce` 는 없다 |
| `reduction` | `reduction` | `reduce`/`reduceBack` 에 넘기는 함수의 매개변수 이름. FSharp.Core 의 공식 이름이 이것이므로 `reduce` 를 설명할 때 `folder` 라고 부르지 않는다. 번역하지 않는다 |
| reference equality | 참조 동등성 | 같은 인스턴스를 가리킬 때만 참. 기확정 구조적 동등성(structural equality)과 짝이다. 클래스 타입의 `=` 가 기본으로 쓰는 쪽. MS ko 일부 문서는 "참조 같음". 10챕터 |
| reference type | 참조 타입 | 힙에 놓이고 `null` 이 들어갈 수 있는 타입. `[<Struct>]` 를 붙이지 않은 판별 유니온·레코드·클래스가 여기 든다. MS ko 는 "참조 형식"이고 이 노트는 형식→타입만 치환해 쓴다. 3·9챕터 |
| regular expression | 정규식 | MS ko 표기와 일치하고 기확정 `expression`(식)과 맞물린다. "정규 표현식" 쓰지 않음(금지 표기 "표현식"과 같은 이유). 타입 이름 `Regex` 는 번역하지 않는다. 7·8챕터 |
| REPL | REPL | 원어 유지. read-eval-print loop 를 음차하거나 "대화형 셸"로 풀지 않는다. F# 의 REPL 이 FSI 다 |
| request | 요청 | 클라이언트가 서버에 보내는 한 건. 본문은 "요청 본문" 이라 쓴다. 음차 "리퀘스트" 쓰지 않는다. 13·14·15챕터 |
| `ResizeArray<'T>` | `ResizeArray` | 번역하지 않는다. .NET `List<'T>` 의 F# 타입 약어이며 가변 배열이다. F# 의 `List` 와 정반대 성격이므로 둘을 같은 문장에서 "리스트"로 뭉개지 않는다 |
| resource (learning material) | 자료 | 원서 절 이름 Resources(원서 pp.193-194)는 절 제목에서 원어를 남기고 본문은 "자료" 로 쓴다. "리소스" 쓰지 않는다 — 메모리·파일 같은 자원 쪽으로 읽힌다. 다만 컴파일러 경고를 인용하는 대목의 "리소스"(10챕터 `warning FS0760`)는 원문 표기를 그대로 남긴다. 16챕터 |
| response | 응답 | 서버가 돌려주는 한 건. 본문은 "응답 본문" 이라 쓴다. 음차 "리스폰스" 쓰지 않는다. 13·14·15챕터 |
| `Result` | `Result` | 번역하지 않는다. 케이스 식별자는 `Ok`/`Error`. 타입 매개변수는 앞이 성공값 타입, 뒤가 실패값 타입 |
| `result` (computation expression) | `result` 계산 식 | 계산 식 이름은 소문자 값 이름이라 번역하지 않는다. F# 코어에는 없고 `FsToolkit.ErrorHandling` 이 제공한다(없이 적으면 `error FS0039`). 모듈 수준에서 `let x = result { ... }` 로 묶으면 실패 타입이 정해지지 않아 값 제한(`error FS0030`)에 걸리므로, 타입 주석을 달거나 함수 안에서 쓴다(실측 확인). 영어 칸의 (computation expression) 는 타입 `Result` 쪽과 구분하기 위한 표시다. 12챕터 본론 |
| `return!` | `return!` | 키워드는 번역하지 않는다. 이미 효과가 감싼 값을 그대로 결과로 내고 빌더의 `ReturnFrom` 을 부른다. `return` 은 감싸지 않은 값을 받아 `Return` 이 효과를 입힌다. 둘의 구분은 오른쪽 식이 효과를 만드는지로 갈린다. 12챕터 본론 |
| route | 경로 | HTTP 요청이 가리키는 자리. `route` 함수 이름은 원어 백틱으로 쓴다. 파일 `path` 도 "경로" 로 옮기므로 한 문장에서 둘을 구분해야 할 때는 "요청 경로"/"파일 경로" 처럼 한정어를 붙인다. "라우트" 쓰지 않는다. 13챕터 본론, 14·15챕터 |
| route parameter | 경로 매개변수 | `routef "/hives/%s"` 의 `%s` 자리로 핸들러에 넘어오는 값. MS ko 표기와 일치하고 기확정 `parameter`(매개변수) 계열이다. 쿼리 문자열 항목이 아니다. 13챕터 |
| route template | 경로 템플릿 | ASP.NET Core 라우팅이 읽는 경로 패턴 문자열. `routef "/%O"` 는 `/{O0:regex(...)}` 라는 경로 템플릿으로 번역된다. MS ko 표기와 일치. "라우트 템플릿"·"경로 서식" 쓰지 않는다. 14챕터 본론 |
| routing | 라우팅 | 음차 고정. MS ko 표기와 일치. "경로 배정"·"라우트 지정" 쓰지 않는다. 13챕터 본론, 14·15챕터 |
| runtime | 런타임 | 음차 고정. `System.Environment.Version` / `RuntimeInformation.FrameworkDescription` 이 돌려주는 값이 이것이고 SDK 버전과 다르다 |
| SAFE Stack | SAFE Stack | 제품 이름이므로 원어를 유지한다. 서버와 브라우저 양쪽을 F# 로 쓰는 조합이고 원서가 15챕터 각주로 `safe-stack.github.io` 를 건다(원서 p.191). 낱자를 풀어 적거나 "세이프 스택" 으로 음차하지 않는다. 15·16챕터 |
| scope | 스코프 | 음차 고정. "유효 범위"도 뜻은 같으나 노트는 "스코프" |
| Scott Wlaschin | 스콧 블라신 | 통용 음차가 갈린다(블라시친·블라친). 근거가 확실한 표기가 없으므로 "스콧 블라신"으로 고정하고 첫 등장 시 원어를 병기한다 |
| script file | 스크립트 파일 | `.fsx`. 프로젝트 파일 없이 `dotnet fsi` 로 바로 실행되는 쪽 |
| SDK | SDK | 번역하지 않는다. `.NET SDK`. 컴파일러(`fsc`)와 FSI 가 함께 들어 있다 |
| sealed trait | 봉인된 트레이트 | Scala 용어. F# 판별 유니온에 대응한다. 1챕터 Postscript 절에서만 쓴다 |
| self identifier | 자기 식별자 | `member _.Label` 의 `_`, `member this.Describe` 의 `this`. 인스턴스 자신을 받는 자리다. MS ko 는 "자체 식별자"이나 한국어로 어색해 "자기 식별자"를 택한다. 관례는 `_` 아니면 `this` 둘 중 하나. 10챕터 |
| `Seq` | `Seq` | 번역하지 않는다. 지연 평가되는 시퀀스 타입이자 모듈. .NET 의 `IEnumerable<'T>` 와 같은 것이다. 서술문에서 값을 가리킬 때는 "시퀀스" |
| sequence | 시퀀스 | 음차 고정. `seq<'T>` 이고 `IEnumerable<'T>` 와 같은 것이다. 함수 이름 `sequence` 는 이것과 상관이 없는 별개 항목이다(`sequence` (function) 행 참조) |
| `sequence` (function) | `sequence` | 함수 이름이므로 백틱 원어를 유지하고 음차하지 않는다. `Result<'a,'e list> list -> Result<'a list,'e list>` 처럼 컨테이너의 안팎을 뒤집는 함수. 기확정 `sequence`(시퀀스)는 컬렉션 타입 `seq<'T>` 를 가리키는 별개 항목이므로, 함수 이름으로 쓸 때는 반드시 백틱을 붙이고 "컬렉션 타입 `seq` 와는 상관이 없는 이름"이라는 단서를 한 번 붙인다. `traverse` 와 뭉개 쓰지 않는다. 8챕터 |
| sequence expression | 시퀀스 식 | `seq { ... }`. MS ko 표기와 일치하고 기확정 `expression`→식, `computation expression`→계산 식 과 맞물린다. "시퀀스 표현식" 금지. 6챕터 본론 |
| serialization | 직렬화 | 값을 JSON 같은 형식의 텍스트로 바꾸는 것. 반대 방향은 `deserialization`(역직렬화). MS ko 는 "직렬화"·"역직렬화" 와 함께 "직렬 변환" 도 쓰나 노트는 "직렬화" 로 고정한다. 13챕터 본론, 14챕터 |
| serializer | 직렬화기 | 직렬화를 하는 객체. MS ko 는 "직렬 변환기" 이나 커뮤니티 통용을 택한다. Giraffe 는 `Json.ISerializer` 로 갈아 끼울 수 있고 타입·인터페이스 이름은 원어 백틱으로 쓴다. "시리얼라이저" 쓰지 않는다. 13·14챕터 |
| service location | 서비스 로케이션 | 의존성을 매개변수로 받지 않고 필요할 때 컨테이너에 물어보는 방식(`ctx.GetService<'T>()`). 원서 p.182 표기가 service location 이므로 그것을 음차한다. 패턴 이름으로는 "서비스 로케이터(Service Locator)" 가 더 널리 쓰이니 패턴 자체를 가리킬 때만 그 이름을 쓰고 본문은 "서비스 로케이션" 으로 통일한다. "서비스 위치 지정" 쓰지 않는다. 14챕터 본론 |
| `Set` | `Set` | 번역하지 않는다. "집합"으로 풀지 않는다. 정렬 컬렉션이므로 원소가 값의 비교 순서로 재배치되고 `comparison` 제약을 요구한다 |
| shadowing | 이름 가림 | 나중에 `open` 한 모듈의 같은 이름이 앞의 것을 가리는 일. "섀도잉"도 통용되나 뜻이 바로 읽히는 "이름 가림"을 택한다 |
| shared framework | 공유 프레임워크 | 여러 앱이 함께 쓰는 런타임 어셈블리 묶음. `Microsoft.NETCore.App` 과 `Microsoft.AspNetCore.App` 이 있고 `dotnet --list-runtimes` 로 확인한다. MS ko 표기와 일치. 기확정 `target framework`(대상 프레임워크)·`runtime`(런타임)과 다른 것이다 — 대상 프레임워크는 `.fsproj` 에 적는 컴파일 대상이고 공유 프레임워크는 디스크에 설치된 어셈블리 묶음이다. 여러 버전이 깔려 있을 때 폴더 이름을 문자열로 비교하면 `10.0.9` 가 `10.0.11` 보다 크게 나오므로 반드시 `Version` 으로 비교한다(실측). 13·14·15챕터 |
| side effect | 부수 효과 | **확정.** "부작용"은 의약품의 adverse effect 뉘앙스가 강해 피한다. MS ko 문서에 "부작용" 표기가 섞여 있으나 노트 전체를 "부수 효과"로 통일한다 |
| signature | 시그니처 | MS ko 표기와 일치. 음차 고정 |
| significant whitespace | 유의미한 공백 | 들여쓰기 정렬이 스코프를 정한다는 뜻. "의미 있는 공백"도 통용하나 노트는 "유의미한 공백"으로 고정한다. 탭 문자는 오류 FS1161 |
| single-case active pattern | 단일 케이스 액티브 패턴 | `(\|Name\|)`. 실패하지 않고 변환 결과 타입을 그대로 반환한다. 판정이 아니라 변환에 쓴다. 매개변수를 붙일 수 있다(`(\|RoundedTo\|) : int -> float -> float`). 줄임형은 "단일 케이스 패턴"이다. 9챕터의 단일 케이스 판별 유니온과 머리 낱말이 겹치므로 "단일 케이스" 한 낱말로 줄이지 않는다(줄임 규칙은 `active pattern` 행) |
| single-case discriminated union | 단일 케이스 판별 유니온 | 케이스가 하나뿐인 판별 유니온. 앞의 `\|` 를 생략해 적는 것이 관례다. 원시 타입에 도메인 이름을 붙여 다른 타입으로 만드는 데 쓴다. 7챕터의 단일 케이스 액티브 패턴과 머리 낱말이 겹치므로 "단일 케이스" 한 낱말로 줄이지 않고 언제나 전체 이름으로 쓴다(기확정 `single-case active pattern` 행의 규칙과 짝). 약어(SCDU 등) 쓰지 않는다. 9챕터 본론 |
| singleton | 싱글턴 | 의존성 주입 컨테이너에 인스턴스 하나만 두고 앱 전체가 공유하게 등록하는 수명(`AddSingleton`). 외래어 표기법대로 "싱글턴" 이며 노트가 이미 `stack overflow`→"스택 오버플로" 에서 같은 원칙을 택했다. MS ko 문서에는 "싱글톤" 과 원어 Singleton 이 섞여 나오지만 규범 표기를 따른다. "싱글톤"·"단일체" 쓰지 않는다. 14·15챕터 |
| smart constructor | 스마트 생성자 | 케이스 식별자를 `private` 으로 막고 검증을 통과한 값만 `Result` 로 돌려주는 생성 함수. 타입의 정적 멤버 형태(`Nights.Create`)와 같은 이름의 모듈 함수 형태(`Nights.create`) 둘이 있다. 정착된 역어가 없으나 "스마트 생성자"가 커뮤니티 통용이다. "똑똑한 생성자"·"스마트 컨스트럭터" 쓰지 않는다. 원서가 케이스 식별자를 "the type constructor"라 부르는 것은 옮기지 않는다 — 함수형 일반 용어에서 type constructor 는 `Option<_>` 처럼 타입을 받아 타입을 만드는 것을 가리키므로 기확정 케이스 식별자(case identifier)를 쓴다. 9챕터 본론 |
| solution | 솔루션 | 음차 고정. `dotnet new sln`. 프로젝트를 묶은 목록이며 그 자체가 컴파일되지는 않는다 |
| solution file | 솔루션 파일 | `dotnet new sln` 이 만드는 파일. SDK 10 기본 산출물은 `.slnx`(XML, `<Solution>` 두 줄)이고 `-f sln` 을 주면 예전 `.sln` 이 나온다(실측). 확장자는 원어 백틱으로 쓴다. 바로 위 `solution`(솔루션) 행의 하위 항목이며, 디스크의 솔루션 루트를 가리키는 "솔루션 디렉터리" 와 갈라 쓴다. 17챕터 |
| solution folder | 솔루션 폴더 | `.slnx` 의 `<Folder Name="/src/">`. 예전 `.sln` 에서는 SolutionFolder 유형의 Project 항목과 NestedProjects 절로 적힌다(병합자 실측). 편집기 솔루션 탐색기에 보이는 분류일 뿐이고 디스크의 디렉터리도 F# 컴파일 순서도 아니다. `dotnet sln add` 가 프로젝트 경로에서 만들며 `--in-root`(기본값 False)로 끈다 — 두 형식 모두에서 만들어지므로 SDK 10 에서 새로 생긴 동작이 아니다. MS ko 표기와 일치. `solution`(솔루션) 행의 하위 항목이고 "솔루션 디렉터리" 와 반드시 갈라 쓴다. 4·17챕터 |
| stack frame | 스택 프레임 | 호출 하나가 스택에 잡는 자리. 돌아갈 자리와 그 호출의 지역 값이 여기 들어간다. MS ko 표기와 일치. 음차 고정하고 "스택 틀" 쓰지 않는다. 11챕터 본론 |
| stack overflow | 스택 오버플로 | 스택 프레임이 한계를 넘는 것. .NET 의 `StackOverflowException` 은 `try ... with` 로 잡을 수 없고, 런타임이 표준 오류에 `Stack overflow.` 를 찍고 프로세스를 끝낸다(종료 코드 134). 외래어 표기법대로 "오버플로우" 아닌 "오버플로". 산술 쪽 overflow 는 "넘침"으로 갈라 쓴다. 11챕터 본론 |
| statement | 문 | `expression`(식)의 대비어. F# 은 거의 모든 것이 식이다 |
| static file middleware | 정적 파일 미들웨어 | `UseStaticFiles()` 가 미들웨어 파이프라인에 넣는 미들웨어. 확장자와 `Content-Type` 대응 표를 들고 있고 표에 없는 확장자는 내보내지 않는다(실측: `.xyz` 는 404). 라우팅이 아니라 미들웨어가 처리하므로 정적 파일 경로는 엔드포인트 목록에 적지 않는다. 15챕터 본론 |
| static files | 정적 파일 | 서버가 내용을 손대지 않고 그대로 내보내는 파일(CSS·JavaScript·이미지·글꼴). MS ko 표기와 일치. "스태틱 파일" 쓰지 않는다. 15챕터 본론 |
| static member | 정적 멤버 | `static member Create`. MS ko 표기와 일치. 인스턴스 없이 타입 이름으로 부른다. 9·10챕터 공통 |
| statically resolved type parameter (SRTP) | 정적으로 확인되는 타입 매개변수 | `^a`, `^b`. MS ko 는 "정적으로 확인된 형식 매개 변수"이고 이 노트는 형식→타입만 치환해 쓴다. 첫 등장에서 약어 SRTP 병기 허용. 5챕터는 `List.sumBy`/`List.averageBy` 시그니처 주석에 `^b` 가 보이는 것뿐이므로 용어를 쓰지 않아도 된다. 9챕터 본론 |
| status code | 상태 코드 | HTTP 응답의 세 자리 숫자. MS ko·MDN ko 표기와 일치. 숫자는 그대로 적고(200, 404, 500) 이름과 함께 적을 때는 `Successful.CREATED`(201) 처럼 괄호에 숫자를 넣는다. "상태 번호"·"응답 코드"·"HTTP 코드" 쓰지 않는다. 기확정 `exit code`(종료 코드)와 다른 것이다. 13·14·15챕터 |
| store | 저장소 | 데이터를 담아 두고 읽기·쓰기 멤버만 밖으로 여는 클래스(`InspectionStore`). 13~15챕터가 이미 이 표기를 쓴다. "리포지터리"·"리포지토리"·"스토어" 쓰지 않는다. 4챕터가 계층 이름을 열거하며 인용한 "리포지터리" 한 곳은 원서 조언을 옮긴 자리이므로 그대로 둔다. 코드를 담은 git 저장소와 낱말이 겹치고 서문 챕터·6·11챕터가 "이 저장소" 를 그 뜻으로 쓰므로, 헷갈릴 자리에서는 "점검 기록 저장소" 처럼 무엇을 담는지 붙여 적는다. 13·14·15·16챕터 |
| string interpolation | 문자열 보간 | `$"..."` |
| `[<Struct>]` | `[<Struct>]` | 특성 이름은 번역하지 않고 `[<Struct>]` 로 쓴다. 붙이면 판별 유니온·레코드가 값 타입이 된다. 서술문에서 결과물을 가리킬 때는 "구조체"(기확정 `struct representation`(구조체 표현)과 계열이 맞다). 다중 케이스 구조체 판별 유니온의 필드 이름 중복 제약(오류 FS3204)은 F# 9 에서 없어졌다(`--langversion:8.0` 까지 FS3204, `9.0` 이후 통과). 9챕터 보충 |
| struct representation | 구조체 표현 | 액티브 패턴에 `[<return: Struct>]` 를 붙여 반환 타입을 `option` 에서 `voption` 으로 바꾸는 것. FSI 한국어 메시지 표기가 "활성 패턴에 대한 구조체 표현"이다. F# 6 부터 쓸 수 있다(F# 5.0 에서는 오류 FS3350) |
| structural equality | 구조적 동등성 | 담긴 값이 같으면 `=` 가 참. MS ko 일부 문서는 "구조적 같음" |
| `subRoute` | `subRoute` | 함수 이름은 번역하지 않는다. 접두 경로를 한 번만 적고 그 아래 `Endpoint list` 를 묶는다. 절 제목 등에서 개념을 우리말로 가리킬 때는 "하위 경로" 로 쓰고 "서브라우트" 쓰지 않는다. 원서 p.174 는 이 목록을 "another HttpHandler" 라고 적었으나 `Endpoint list` 다. 13챕터 본론, 14·15챕터 |
| syntactic sugar | 문법 설탕 | 같은 일을 더 읽기 쉽게 적게 해 주는 문법. 원서 p.153 이 계산 식을 이렇게 소개한다. "구문 설탕"·"신택틱 슈거" 쓰지 않는다. 계산 식이 풀리는 결과를 짚을 때는 "빌더의 어느 멤버를 부른다" 로 쓰고 "탈당화" 같은 조어를 만들지 않는다. 12챕터 |
| tail | 꼬리 | 머리를 뗀 나머지 리스트. 빈 리스트일 수 있다. 첫 등장 1회 `꼬리(tail)` 병기. "테일"로 음차하지 않는다. 꼬리 재귀(tail recursion)·꼬리 호출(tail call)과 낱말이 같고 개념이 다르다. 두 계열이 한 챕터에 함께 나올 때는 다음 세 가지를 지킨다 — (1) 개념 이름은 이쪽만 "꼬리"로 쓰고 저쪽은 언제나 "꼬리 재귀"·"꼬리 호출" 전체 이름으로 쓴다. "꼬리" 한 낱말로 재귀 쪽을 가리키지 않는다. (2) 리스트를 분해하는 코드의 변수 이름은 `tail` 이 아니라 `rest` 로 짓는다. (3) 두 계열이 처음 만나는 자리에 둘이 다른 말이라는 문장을 한 번 넣는다. 11챕터가 이 규칙을 지킨다 |
| tail call | 꼬리 호출 | 함수가 마지막으로 하는 일이 어떤 호출이고 그 결과가 곧 그 함수의 반환값인 경우. 재귀 호출일 필요는 없다. MS ko 표기와 일치. 리스트의 꼬리(`tail`)와 낱말이 겹치므로 두 계열이 한 챕터에 함께 나올 때의 구분 규칙은 `tail` 행을 따른다. 11챕터 본론 |
| tail call optimisation | 꼬리 호출 최적화 | 꼬리 호출에서 프레임을 새로 쌓지 않는 것. 원서 표기는 영국식 optimisation(원서 p.142). 약어 TCO 는 쓰지 않는다. 자기 자신을 직접 부르는 꼬리 호출은 컴파일러가 반복문으로 바꾸므로 `--tailcalls-` 인 Debug 프로젝트 빌드에서도 성립하고, 상호 재귀처럼 다른 함수로 가는 꼬리 호출은 `--tailcalls+` 일 때만 성립한다. 11챕터 본론 |
| tail recursion | 꼬리 재귀 | 재귀 호출이 꼬리 호출인 재귀. 리스트의 꼬리(`tail`)와 낱말이 같고 개념이 다르므로, 두 계열이 한 챕터에 함께 나올 때는 `tail` 행의 구분 규칙을 따른다. 11챕터 본론 |
| `[<TailCall>]` | `[<TailCall>]` | 특성 이름은 번역하지 않는다. F# 8 부터 컴파일러가 꼬리 호출 여부를 검사해 아니면 경고 FS3569 를 낸다. 제약 세 가지 — 프로젝트 빌드에서만 검사하고 `dotnet fsi` 스크립트에서는 검사하지 않으며, `--langversion:7.0` 에서는 검사하지 않고, 지역 `let rec` 에는 붙일 수 없다(오류 FS0010). 11챕터 보충 |
| target framework | 대상 프레임워크 | MS ko 표기와 일치. `net10.0`. `.fsproj` 의 `TargetFramework` 속성은 원어 백틱으로 쓴다 |
| `Task` | `Task` | .NET 타입 이름은 번역하지 않는다. `System.Threading.Tasks.Task`/`Task<'T>` 이고 F# 6 부터 코어에 `task { ... }` 계산 식이 있다(실측 확인). `Async` 와 달리 만드는 순간 시작한다. `async` 안에서 쓰려면 `Async.AwaitTask` 로 바꾼다 — .NET 라이브러리 함수가 `Task` 를 내주기 때문에 필요한 변환이다. 12챕터 |
| `taskResult` | `taskResult` | 계산 식 이름은 소문자 값 이름이라 번역하지 않는다. `FsToolkit.ErrorHandling` 이 제공하고 `Task<Result<'a,'e>>` 를 다룬다. 12챕터의 `asyncResult`(`Async<Result<'a,'e>>`)와 짝이다. `asyncResult` 도 `Source` 오버로드로 `Task<Result<..>>` 를 `let!` 으로 받지만 결과가 `Async<Result<..>>` 이므로, `Task` 를 요구하는 자리에서는 `taskResult` 를 쓴다(5.2.0 실측 — `taskResult` 는 `Task<Result<int,DbError>>`, `asyncResult` 는 `Async<Result<int,DbError>>` 를 낸다). 시그니처를 적을 때는 FSI 가 찍는 이름을 그대로 쓴다 — 같은 실측에서 `taskResult` 값은 타입 약어 `TaskResult<int,DbError>` 로 찍히고 `asyncResult` 값은 `Async<Result<int,DbError>>` 로 찍힌다. 5.2.0 에 `TaskResult<'a,'e>` 타입 약어는 있고 `AsyncResult` 라는 타입 약어는 없어서 갈린 것이다(같은 이름의 모듈만 있어 타입 자리에 적으면 오류 FS0039). 기확정 `HttpFuncResult`·`HttpHandler` 행이 세운 규칙과 같다. 16챕터 |
| template | 템플릿 | `dotnet new console`, `dotnet new xunit` |
| template short name | 템플릿 짧은 이름 | `dotnet new list` 출력의 Short Name 칸 값(`console`, `xunit`). MS ko 는 "약식 이름" 도 쓰나 노트는 "짧은 이름" 으로 고정한다. 기확정 `template`(템플릿) 행의 하위 항목. 17챕터 |
| test runner | 테스트 러너 | 테스트를 찾아 실행하는 쪽. "테스트 실행 장치" 쓰지 않음 |
| top-level module | 최상위 모듈 | 파일 첫 줄의 `module X` / `module X.Y`. `=` 없이 적고 이름이 프로젝트 전체에서 유일해야 한다 |
| track | 선로 | `Ok` 선로·`Error` 선로·`None` 선로. 3챕터가 철도 지향 프로그래밍을 설명하며 세운 표기이고 12챕터도 그대로 쓴다. "트랙"·"레일" 로 음차하지 않고 "경로" 로 바꿔 쓰지도 않는다. 원서의 "on the None track" 은 "`None` 선로로 갈아탔다" 로 옮긴다 |
| traversal | 순회 | 트리나 컬렉션을 훑는 것. "트리 순회". search 쪽에 "탐색"을 남겨 두기 위해 traversal 은 "탐색"으로 옮기지 않는다. 함수 이름 `traverse` 와는 별개이므로 같은 문장에서 섞어 쓰지 않는다. 6·11챕터 |
| `traverse` | `traverse` | 함수 이름이므로 백틱 원어를 유지하고 음차하지 않는다. 원소마다 함수를 적용한 뒤 컨테이너의 안팎을 뒤집는 함수(`map` + `sequence`)다. `sequence` 와 뭉개 쓰지 않는다. 한국어 "순회"(traversal)와도 다른 것이다. 8챕터 |
| tuple | 튜플 | 타입 표기는 `*`, 값 표기는 `,` |
| tupled parameter | 튜플 매개변수 | 튜플 하나를 매개변수로 받는 형태. 튜플 자체를 절반만 채울 수 없다 |
| type abbreviation | 타입 약어 | `type RawDriver = string * bool * bool`. 새 타입을 만드는 것이 아니라 기존 타입에 별명을 붙이는 것. MS ko 는 "형식 약어" |
| type annotation | 타입 주석 | `(x: int)`. "타입 표기"도 허용 |
| type inference | 타입 추론 | |
| type parameter | 타입 매개변수 | `'a`, `'b`. `'a` 자체는 타입이 아니라 자리표시자다 |
| type test operator | 타입 테스트 연산자 | 식 위치의 `x :? T`. 결과는 `bool` 이고 변환이 아니다 |
| type test pattern | 타입 테스트 패턴 | `:? T as e`. MS ko "형식 테스트 패턴"에서 형식→타입만 치환한 표기. "타입 검사 패턴"은 정적 타입 검사(type checking)와 헷갈리므로 쓰지 않는다. 원서가 `:?` 를 "cast operator"로 부른 것은 부정확하다 |
| underlying type | 원래 타입 | 단일 케이스 판별 유니온이 감싼 타입(`Nights of int` 의 `int`), 타입 약어가 별명을 붙인 타입. MS ko 는 문서에 따라 "기본 형식"/"내부 형식"으로 갈리고 이 노트는 "형식"을 쓰지 않는다. "하부 타입"·"기저 타입" 쓰지 않는다(하위 타입과 헷갈린다). "기반 타입"도 쓰지 않는다 — 그 표기는 상속의 base type 쪽이다. 9챕터 |
| union case | 유니온 케이스 | `\|` 로 나열한 항목 하나. MS ko 는 "공용 구조체 사례". "판별 유니온" 표기와 맞물리게 "유니온 케이스"를 쓴다 |
| `unit` | `unit` | 번역하지 않는다. 값이 `()` 하나뿐인 타입 |
| unit test | 단위 테스트 | MS ko 표기와 일치 |
| unwrap | 벗기다 | 효과를 한 겹 벗겨 안의 값을 꺼내는 것. 반대는 "감싸다"(wrap). 3·5·8챕터가 이미 "벗겨"·"감싸" 로 쓴다. "언래핑"·"래핑" 쓰지 않고, 명사가 필요하면 "한 겹 벗기기" 로 풀어 쓴다 |
| upcast | 상향 변환 | `:>`. MS ko 는 "업캐스트". 짝인 하향 변환(`:?>`)은 `downcast` 행에 따로 있다 |
| validation | 검증 | MS ko 는 "유효성 검사". 이 노트는 "검증"을 쓴다. 계산 식 이름 `validation` 과 챕터 제목(함수형 검증)이 같은 낱말로 묶이고, 9챕터의 스마트 생성자 설명도 "검증"으로 쓴다. `validate` 함수는 "검증 함수", `ValidationError` 는 타입 이름이라 번역하지 않는다. 테스트의 `assertion` 은 "어서션"이므로 검증으로 부르지 않는다. 8·9챕터 |
| `Validation<'a,'e>` | `Validation` | 타입 이름이라 번역하지 않는다. `FsToolkit.ErrorHandling` 이 정의한 `Result<'a,'e list>` 의 타입 약어이며 새 타입이 아니다. 두 표기는 서로 대입된다. 반환 타입 주석이 없으면 FSI 가 `FsToolkit.ErrorHandling.Validation<Slip,ValidationError>` 로, 주석을 달면 `Result<Slip,ValidationError list>` 로 보여 준다. 8·12챕터 |
| value binding | 값 바인딩 | 매개변수가 없는 `let`. 그 줄이 평가된 순간의 값으로 고정된다. 담긴 값이 함수면 시그니처에 `->` 가 보이고, FSI 는 괄호로 구분해 준다(`val f: (unit -> int)`) |
| value restriction | 값 제한 | 매개변수 없는 `let` 바인딩이 제네릭 타입으로 유추될 때 나는 오류 FS0030. 컴파일러 한국어 메시지도 "값 제한"이다. `[]` 같은 인자 없는 케이스는 자동 일반화되므로 값 제한에 걸리지 않고, `let e = List.rev []` 처럼 함수 적용 결과를 묶을 때 걸린다 |
| value type | 값 타입 | `[<Struct>]` 를 붙인 타입, `int`/`decimal`/구조체 튜플 등. 기본값이 항상 존재하므로 `Array.zeroCreate`·`Unchecked.defaultof` 로 검증을 거치지 않은 값이 나올 수 있다. MS ko 는 "값 형식"이고 이 노트는 형식→타입만 치환해 쓴다. 3·9챕터 |
| variable pattern | 변수 패턴 | 이름 하나를 적어 어떤 값이든 받아 그 이름에 묶는 패턴. 상수 패턴과 짝으로 쓴다. `[<Literal>]` 을 빼면 대문자 이름이 상수 패턴이 아니라 변수 패턴이 되어 모든 입력을 삼킨다는 12챕터 본론의 요점이 이 낱말에 걸려 있다. "변수형 패턴"·"바인딩 패턴" 쓰지 않는다. 12챕터 본론 |
| view | 뷰 | 음차 고정. 화면을 만드는 값 또는 그 값을 만드는 함수. 이름 규칙은 `<이름>View`. "화면" 은 사람이 보는 결과를 가리킬 때만 쓰고 코드 쪽은 "뷰" 로 쓴다. 13·15챕터 |
| View Engine | View Engine | `Giraffe.ViewEngine` 은 제품 이름이므로 원어를 그대로 쓴다. 일반명사로 다른 엔진과 견줄 때만 "뷰 엔진" 이다("다른 뷰 엔진에서는..."). 첫 등장은 "Giraffe View Engine", 이후 "View Engine". 요소 함수의 결과 타입은 `XmlNode` 하나이며 타입 이름은 원어 백틱으로 쓴다. 13·15챕터 본론 |
| `void` | `void` | 번역하지 않는다. .NET 의 "반환값 없음" 표지. `unit` 과 달리 타입 인자로 쓸 수 없다 |
| `voption` | `voption` | 번역하지 않는다. `Option` 의 구조체판이고 정식 이름은 `ValueOption`. 케이스 식별자는 `ValueSome`/`ValueNone`. 힙 할당이 없다 |
| web application | 웹 애플리케이션 | 줄여 "웹 앱" 으로 쓰지 않는다. 한 챕터 안에서 두 표기를 섞지 않는다. 13챕터 |
| web framework | 웹 프레임워크 | Giraffe 를 가리킬 때 쓴다. 제품 이름 Giraffe·ASP.NET Core 는 번역하지 않는다. 13챕터는 Giraffe 를 "ASP.NET Core 위에 얇게 덮인 함수형 껍데기" 로 소개하며 이 표기를 쓰지 않는다 — 표기가 갈리지 않게 등재해 둔다 |
| web root | 웹 루트 | 정적 파일을 내보내는 기준 폴더. 기본값은 콘텐츠 루트 아래 `wwwroot/` 이고 폴더 이름은 번역하지 않고 `wwwroot/` 로 적는다. 바꾸려면 `WebApplication.CreateBuilder(WebApplicationOptions(WebRootPath = ...))` 로 넘긴다(실측 — 이 호스팅 모델에서 `builder.WebHost.UseWebRoot` 는 `NotSupportedException` 이다). MS ko 표기와 일치. 15챕터 |
| wildcard | 와일드카드 | `_`. 그 값을 쓰지 않겠다는 표시 |
| xUnit | xUnit | 공식 이름은 xUnit.net 이고 소문자 x 로 시작한다. 원서는 "XUnit" 으로 적지만 노트는 "xUnit" 으로 쓴다. `open` 하는 네임스페이스는 `Xunit`(FsUnit 쪽은 `FsUnit.Xunit`)이고 NuGet 패키지 이름은 `xunit` / `FsUnit.xUnit` 이다. NUnit / MSTest / Expecto 도 라틴 표기 그대로 쓴다 |
