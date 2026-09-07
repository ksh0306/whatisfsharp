# 10챕터 용어 후보 (객체 프로그래밍)

집필자가 임시로 정한 12개를 전부 재검토했다. 결론부터: 12개 중 11개는 그대로 확정을 권한다.
`casting` 만 표기를 바꾼다(음차 총칭을 세우지 않고 "변환"으로 두고, 대신 `implicit conversion`
행을 따로 세워 `conversion` 과의 충돌 우려를 해소한다).

`primary constructor` 는 용어를 세우는 쪽을 권한다. 세우지 않으면 노트 안에서 이름 없는 개념이
슬며시 MS ko 표기("기본 생성자")로 새어 나온다. 실제로 10챕터 line 26 코드 주석에 그 일이
이미 일어났다(검수 보고서 참조).

9챕터와 겹치는 항목(`member`, `property`, `static member`, `access modifier`)은 두 챕터가
같은 표기를 쓰고 있음을 확인했다. 아래 비고에 근거를 남겼다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| abstract class | 추상 클래스 | `[<AbstractClass>]` 특성을 붙인 타입. MS ko 표기와 일치. 인터페이스와의 실질 차이는 상태(`let` 바인딩)를 담을 수 있다는 점이다 — F# 은 인터페이스에 `default` 구현을 적을 수 없고(적으면 그 타입이 클래스가 되어 `interface ... with` 로 구현하려 할 때 오류 FS0887), 인터페이스 본문에 `let` 을 적으면 오류 FS0963 이다 |
| abstract member | 추상 멤버 | `abstract member Label : int -> string`. 구현 없이 시그니처만 적는 멤버. 인터페이스 선언과 추상 클래스에 함께 쓰인다. 키워드를 가리킬 때는 `abstract member` 를 백틱으로 쓴다 |
| access modifier | 접근 지정자 | `private`, `internal`, `public`. MS ko 는 "액세스 제어" / "접근성"이나 일반 프로그래밍 관용을 따른다. 9챕터가 이미 같은 표기를 쓰고 있어 중복 행이면 그쪽과 합치면 된다 |
| auto-property | 자동 프로퍼티 | `member val X = expr`. MS ko 는 "자동으로 구현된 속성"(auto-implemented property)이나 길고 "속성" 표기를 쓰지 않으므로 채택하지 않는다. 오른쪽 식은 생성 시점에 한 번만 평가된다. `with get, set` 을 붙이면 설정 가능, 붙이지 않으면 읽기 전용 |
| base type | 기반 타입 | `inherit` 로 물려받는 쪽. MS ko 는 "기본 클래스"·"기본 형식"이나 "기본"이 default 와 겹쳐 쓰지 않는다. "부모 타입"·"상위 타입" 쓰지 않음 |
| capacity (도메인 상한) | 정원 | 원서의 recently used list 가 받는 최대 크기(원서 p.137 "maximum size (capacity)"). .NET `ResizeArray.Capacity` 프로퍼티와 반드시 갈라 써야 하는 개념이므로 "용량"을 쓰지 않는다. `Capacity` 프로퍼티는 백틱 원어로 두고, 도메인 상한만 "정원"으로 쓴다. "최대 크기"도 후보였으나 한 낱말이 아니어서 문장이 늘어진다 |
| cast / casting | 변환 | 총칭을 따로 음차하지 않는다. 방향을 밝힐 때는 기확정 표기 상향 변환(`:>`)·하향 변환(`:?>`)을 쓰고, 방향을 가리지 않는 자리에서는 "변환" 한 낱말로 쓴다(원서 요약의 "interfaces/casting" → "인터페이스와 변환"). `conversion` 과 구분이 안 된다는 우려는 실제로 문제가 되지 않는다 — 이 노트에서 "변환"이 나오는 모든 자리가 타입 변환이고, F# 6 의 `additional implicit conversions` 도 MS ko 가 "암시적 변환"으로 옮기므로 두 낱말이 같은 대상을 가리킨다. 음차 "캐스팅"은 상향 변환/하향 변환과 어울리지 않아 쓰지 않는다 |
| class | 클래스 | MS ko 표기와 일치 |
| class type | 클래스 타입 | F# 이 `type X() = ...` 로 선언하는 타입을 부르는 이름(원서 "class type"). MS ko "클래스 형식"에서 형식→타입만 치환한 표기. 레코드·판별 유니온과 구별해야 하는 자리에서는 반드시 "클래스 타입"으로 쓰고, 문맥이 분명하면 "클래스"로 줄인다 |
| constructor | 생성자 | MS ko 표기와 일치 |
| default constructor | 매개변수 없는 생성자 | `type X() =` 로 선언한 인자 없는 생성자. FSI 는 `new: unit -> X` 로 보여 준다. MS ko 는 "기본 생성자"이나 그 표기는 primary constructor 쪽에 이미 쓰이고 있어(오류 FS0963 메시지) 겹친다. 그래서 "기본 생성자"를 쓰지 않고 풀어 쓴다 |
| downcast | 하향 변환 | `:?>`. 기확정 `upcast` 행 비고에만 적혀 있어 검색이 안 된다. 독립 행으로 올린다. 상향 변환과 달리 실패할 수 있고 런타임 검사가 붙는다 |
| encapsulation | 캡슐화 | MS ko 표기와 일치. F# 에서 그 뼈대는 클래스 본문의 `let`·`let mutable` 이 밖에서 보이지 않는다는 성질이다 |
| `IEquatable<'T>` | `IEquatable` | 번역하지 않는다. 타입이 자기 자신과 값으로 비교되는 방법을 내놓는 .NET 계약. F# 의 `=` 는 이 인터페이스를 거치지 않고 `Object.Equals` 재정의로 간다 |
| implicit conversion | 암시적 변환 | 변환을 손으로 적지 않아도 컴파일러가 끼워 넣는 것. MS ko 표기와 일치. F# 6 의 `additional implicit conversions` 로 타입 주석이 붙은 `let` 바인딩 자리가 열렸다(F# 5.0 에서는 오류 FS0001). 함수·메서드의 인자 자리는 F# 4.7 에서도 통한다 |
| inheritance | 상속 | MS ko 표기와 일치. 선언은 `inherit 기반타입(인자)` 한 줄 |
| instance | 인스턴스 | MS ko 표기와 일치. "객체"와 섞어 쓰지 않는다 — 타입에서 만들어 낸 하나를 가리킬 때만 "인스턴스"다 |
| interface | 인터페이스 | MS ko 표기와 일치 |
| member | 멤버 | MS ko 표기와 일치. `member` 키워드는 백틱 원어. 9챕터도 같은 표기를 쓴다("타입에 붙인 정적 멤버") |
| method | 메서드 | MS ko 표기와 일치. 프로퍼티와 갈라야 하는 자리에서 쓴다 — FSI 시그니처에 `unit -> unit` 처럼 화살표가 붙으면 메서드, 타입만 적히면 프로퍼티다 |
| object | 객체 | MS ko 는 "개체"(오류 FS0760 메시지도 "개체")이나 "객체 지향"이 이미 정착한 한국어이므로 "객체"를 택한다. 컴파일러·FSI 메시지를 인용하는 대목의 "개체"는 고치지 않는다. 타입 `obj` 는 백틱 원어로 쓰고 "객체"라 부르지 않는다 |
| object expression | 객체 식 | `{ new I with ... }`. MS ko 는 "개체 식"이나 위 `object` 행의 판단에 맞춘다. `expression`→식은 기확정. 만들어지는 것은 이름 없는 타입이고 바인딩의 정적 타입은 인터페이스 그 자체다 |
| object programming | 객체 프로그래밍 | 원서 챕터 제목. 원서가 "object-oriented" 가 아니라 "object programming" 을 쓰므로 "객체 지향 프로그래밍"으로 바꾸지 않는다 |
| operator overloading | 연산자 오버로딩 | 타입에 `static member (+) (a, b) = ...` 를 붙이는 것. MS ko 문서 제목은 "연산자 오버로드"이나 동작을 가리키는 명사로는 "오버로딩"이 통용된다. "연산자 다중 정의" 쓰지 않음. 기확정 `custom operator`(사용자 정의 연산자)와 다른 것이다 — 이쪽은 타입에 딸린 정적 멤버이고 인자가 튜플, 그쪽은 모듈 수준 `let` 이고 매개변수가 커링된다 |
| override | 재정의 | MS ko 표기와 일치하고 일반 통용이기도 하다. "오버라이드" 쓰지 않음. `override`·`default` 키워드는 백틱 원어로 쓰고, FSI 시그니처의 `override Owner: string` 같은 표기는 그대로 인용한다 |
| primary constructor | 주 생성자 | 타입 이름 뒤 괄호로 선언하는 생성자. 클래스 본문의 `let`·`do` 가 그 본문이다. MS ko 와 오류 FS0963 메시지는 "기본 생성자"인데 매개변수 없는 생성자(default constructor)로 읽히므로 채택하지 않는다. 컴파일러 메시지를 인용할 때는 원문의 "기본 생성자"를 그대로 남긴다. 용어를 안 쓰고 "타입 이름 뒤 괄호의 생성자"로 풀어 쓰는 것도 허용하되, 줄여 부를 이름이 필요한 자리에서는 "주 생성자"를 쓴다 |
| property | 프로퍼티 | MS ko 는 "속성". F# 커뮤니티 통용과 9챕터 표기("`.Value` 프로퍼티")를 따라 "프로퍼티"로 고정한다. 읽기 전용/설정 가능 구분은 "읽기 전용 프로퍼티", "설정 가능 프로퍼티" |
| reference equality | 참조 동등성 | 같은 인스턴스를 가리킬 때만 참. 기확정 `structural equality`(구조적 동등성)와 짝이다. 클래스 타입의 `=` 가 기본으로 쓰는 쪽. MS ko 일부 문서는 "참조 같음" |
| self identifier | 자기 식별자 | `member _.Label` 의 `_`, `member this.Describe` 의 `this`. 인스턴스 자신을 받는 자리다. MS ko 는 "자체 식별자"이나 한국어로 어색해 "자기 식별자"를 택한다. 관례는 `_` 아니면 `this` 둘 중 하나 |
| static member | 정적 멤버 | MS ko 표기와 일치. 9챕터도 같은 표기를 쓴다. 중복 행이면 합치면 된다 |

## [기확정 변경 제안]

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| `IDisposable` | `IDisposable` | [기확정 변경 제안] 표기는 그대로 두고 비고만 보완한다. 현재 비고는 "원서 p.81 의 `IDisposable<'T>` 는 오기"인데, 원서 p.131 에는 철자까지 틀린 `IDisposible<'T>` 가 따로 있다(실측: `.cache/src/06-...txt:58,62` 는 `IDisposable<'T>`, `.cache/src/10-...txt:42` 는 `IDisposible<'T>`). 제안 문구 → "번역하지 않는다. 제네릭이 아니다 — 원서 p.81 의 `IDisposable<'T>`, 원서 p.131 의 `IDisposible<'T>` 는 모두 오기이고 p.131 쪽은 철자까지 틀렸다". 표기 변경이 아니라 비고 추가이므로 앞 챕터 본문을 고칠 일은 없다 |
