# 03챕터 용어 후보 (F# 전문가 검수)

`docs/ko/GLOSSARY.md` 에 병합할 후보다. 03챕터에서 처음 등장하는 용어만 담았다.
기확정 항목과 충돌하는 것은 없다. 뒤집기를 요청하는 항목도 없다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| `bind` | `bind` | 모듈 함수 이름은 번역하지 않는다. `Option.bind`, `Result.bind`. "바인드"로 음차하지 않고, 기확정 `binding`(바인딩)과 같은 문장에서 섞어 쓰지 않는다 |
| call chain | 호출 사슬 | 처리되지 않은 예외가 올라가는 경로. 통용 표기 "호출 체인"도 있으나 노트는 "호출 사슬"로 고정 |
| computation expression | 계산 식 | MS ko 표기와 일치. 12챕터 주제이며 기확정 `expression`→식과 맞물린다 |
| Domain-Driven Design | 도메인 주도 설계 | 약어 DDD 허용 |
| exception | 예외 | throw/raise 는 모두 "던진다"로 쓴다. "예외를 발생시킨다" 대신 "던진다" |
| `exn` | `exn` | 번역하지 않는다. `System.Exception` 의 F# 별칭 |
| interop | 상호운용 | `interoperability`=상호운용성. MS ko 는 "상호 운용"으로 띄우나 노트는 붙여 쓴다 |
| `map` | `map` | 모듈 함수 이름은 번역하지 않는다. "사상"·"매핑" 쓰지 않음 |
| match expression | 일치 식 | MS ko 표기와 일치. "매치 식", "match 식" 쓰지 않음 |
| `null` | `null` | 번역하지 않는다. "널"로 음차하지 않는다 |
| nullable reference types | null 허용 참조 타입 | MS ko 는 "null 허용 참조 형식". F# 9 에서 들어온 옵트인 기능이고 기본은 꺼져 있다(`--checknulls+` 로 켠다) |
| `Nullable<'T>` | `Nullable` | 번역하지 않는다. 값 타입을 감싸는 .NET 제네릭 구조체 |
| nullness | nullness | 정착된 역어가 없어 원어를 쓴다. 시그니처에 보이는 `'a \| null` 표기를 가리킬 때만 등장한다 |
| `Option` | `Option` | 번역하지 않는다. 경우 이름은 `Some`/`None`. 실제 정의는 `None` 이 먼저다 |
| optional data | 선택적 데이터 | 원래 없을 수 있는 필드(중간 이름, 부제 등) |
| `out` parameter | `out` 매개변수 | 키워드는 원어. F# 은 `out` 매개변수를 선언할 수 없고, 상호운용 시 컴파일러가 반환값 튜플로 옮겨 준다 |
| pattern matching | 패턴 매칭 | MS ko 는 "패턴 일치". 활동 전체를 가리킬 때는 커뮤니티 통용인 "패턴 매칭"을 택한다(서술어 결합이 자연스럽다). 개별 문법 이름은 MS ko 를 따라 "일치 식", "타입 테스트 패턴"으로 쓴다. 05·06챕터에서 뒤집지 말 것 |
| placeholder value | 자리표시자 값 | MS ko 는 "자리 표시자". 노트는 붙여 쓴다 |
| Railway Oriented Programming | 철도 지향 프로그래밍 | 약어 ROP 허용. 첫 등장 시 원어 병기. "레일웨이 지향 프로그래밍" 쓰지 않음 |
| `Result` | `Result` | 번역하지 않는다. 경우 이름은 `Ok`/`Error`. 타입 매개변수는 앞이 성공값 타입, 뒤가 실패값 타입 |
| Scott Wlaschin | 스콧 블라신 | 통용 음차가 갈린다(블라시친·블라친). 근거가 확실한 표기가 없으므로 집필자 표기 "스콧 블라신"을 고정하고 첫 등장 시 원어를 병기한다 |
| type test operator | 타입 테스트 연산자 | 식 위치의 `x :? T`. 결과는 `bool` 이고 변환이 아니다 |
| type test pattern | 타입 테스트 패턴 | `:? T as e`. MS ko "형식 테스트 패턴"에서 형식→타입만 치환한 표기. "타입 검사 패턴"도 통용이지만 정적 타입 검사(type checking)와 헷갈리므로 택하지 않는다. 원서가 `:?` 를 "cast operator"로 부른 것은 부정확하다 |
| upcast | 상향 변환 | `:>`. MS ko 는 "업캐스트". 하향 변환은 `:?>` |
