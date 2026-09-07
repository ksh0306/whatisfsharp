# 08챕터 용어 후보 (후보 모드)

`docs/ko/GLOSSARY.md` 는 읽기만 했다. 아래는 병합 담당자가 반영할 후보다.
`[기확정 변경 제안]` 은 없다. 기존 181항목과 충돌하는 표기를 새로 만들지 않았다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| accumulating errors | 오류를 모으는 방식 | 검증 함수 전부를 실행해 실패를 리스트에 쌓는 합성 방식. 대비어는 `fail-fast`(첫 오류에서 멈추는 방식). "오류 누적"은 기확정 `accumulator`→누적값 과 겹쳐 `fold` 의 상태로 읽히므로 쓰지 않는다. 실패 자리가 리스트 타입인지로 시그니처에서 구별된다. 8챕터 본론 |
| applicative | 애플리커티브 | 원서 표기는 Applicatives(원서 p.114). 정착된 역어가 없다. "적용자"·"응용 함자"는 커뮤니티 통용이 아니고 "함자"는 functor 의 역어라 겹친다. 음차를 택한다. 첫 등장 1회 `애플리커티브(applicative)` 병기. 형용사 자리에서는 "애플리커티브 방식"으로 쓰고 `monadic`(모나드 방식)과 짝을 맞춘다. F# 5 의 `and!` 가 이 방식을 문법으로 감싼 것이다. 8·12챕터 본론 |
| `apply` | `apply` | 함수 이름은 번역하지 않는다. `Result<('a -> 'b),'e list> -> Result<'a,'e list> -> Result<'b,'e list>`. 성공 자리에 함수가 든 `Result` 를 받는 점이 `map`/`bind` 와 다르다. 관용 연산자 `<*>` 는 "`apply` 연산자", `<!>`(`Result.map` 의 다른 이름)는 "`map` 연산자"로 부른다. 두 연산자 모두 `<` 로 시작해 우선순위가 같고 왼쪽부터 묶인다 |
| capture group | 캡처 그룹 | MS ko 표기와 일치. 정규식의 `( )` 로 잡아내는 부분. `Match.Groups` 의 0번은 매칭된 전체 문자열이고 1번부터가 캡처 그룹이다. 8챕터 |
| fail-fast | 첫 오류에서 멈추는 방식 | `Result.bind` 로 이었을 때의 동작. 영어를 그대로 쓰지 않고 풀어 쓴다. "빠른 실패"는 뜻이 좁게 전달되지 않아 쓰지 않는다. 대비어는 `accumulating errors`(오류를 모으는 방식). 이 방식이 나쁜 것이 아니라 뒤 단계가 앞 단계 결과에 의존할 때 쓰는 방식이라는 점을 함께 적는다 |
| `FsToolkit.ErrorHandling` | `FsToolkit.ErrorHandling` | NuGet 패키지 이름. 등록 대소문자를 그대로 쓴다(`FsUnit`·`xUnit` 행과 같은 규칙). `validation` 계산 식과 `Validation<'a,'e>` 타입 약어를 제공한다. 계산 식만 쓰려면 `open FsToolkit.ErrorHandling.ValidationCE`, 타입 약어와 `Validation.ofResult` 까지 쓰려면 `open FsToolkit.ErrorHandling` 이 필요하다. 8·12챕터 |
| list pattern | 리스트 패턴 | 패턴 자리에 적는 `[ a; b ]`. MS ko 표기와 일치하고 기확정 `array pattern`→배열 패턴 과 계열이 맞다. 배열 패턴처럼 적은 이름의 개수와 리스트 길이가 정확히 같아야 그 케이스가 성립하며, 어긋나면 컴파일 오류가 아니라 그 케이스가 성립하지 않을 뿐이다. 7·8챕터 |
| monadic | 모나드 방식 | 원서 표기는 monadic(원서 p.117). `bind` 로 이어 첫 오류에서 멈추는 합성을 가리킨다. "모나딕" 음차는 형용사 어미가 한국어에 붙지 않아 문장에서 겉돌고, "모나드적"은 조어가 어색하다. 명사구 "모나드 방식"으로 고정한다. `monad` 자체를 설명하는 자리가 아니라 합성 방식을 가리키는 자리에만 쓴다. 8·12챕터 |
| regular expression | 정규식 | MS ko 표기와 일치하고 기확정 `expression`→식 과 맞물린다. "정규 표현식" 쓰지 않음(기확정 금지 표기 `표현식` 과 같은 이유). 타입 이름 `Regex` 는 번역하지 않는다. 7·8챕터 |
| `sequence` / `traverse` | `sequence` / `traverse` | 함수 이름이므로 백틱 원어를 유지하고 음차하지 않는다. `sequence` 는 `Result<'a,'e list> list -> Result<'a list,'e list>` 처럼 안팎을 뒤집는 함수, `traverse` 는 원소마다 함수를 적용한 뒤 뒤집는 함수(`map` + `sequence`)다. 둘을 뭉개 쓰지 않는다. 기확정 `sequence`→시퀀스 는 컬렉션 타입 `seq<'T>` 를 가리키는 별개 항목이므로, 함수 이름으로 쓸 때는 반드시 백틱을 붙여 구별한다. 8챕터가 "컬렉션 타입 `seq` 와는 상관이 없는 이름"이라는 한 줄을 붙인 처리를 그대로 따른다 |
| validation | 검증 | MS ko 는 "유효성 검사". 이 노트는 "검증"을 쓴다. 근거 세 가지 — 계산 식 이름 `validation` 과 챕터 제목(함수형 검증)이 같은 낱말로 묶이고, 9챕터의 스마트 생성자 설명이 이미 "검증"으로 쓰이며, 노트 12편에서 "유효성"이 한 번도 쓰이지 않았다. `validate` 함수는 "검증 함수", `ValidationError` 는 타입 이름이라 번역하지 않는다. 테스트의 `assertion` 은 "어서션"이므로 검증으로 부르지 않는다 |
| `Validation<'a,'e>` | `Validation` | 타입 이름이라 번역하지 않는다. `FsToolkit.ErrorHandling` 이 정의한 `Result<'a,'e list>` 의 타입 약어이며 새 타입이 아니다. 두 표기는 서로 대입된다. 반환 타입 주석이 없으면 FSI 가 `FsToolkit.ErrorHandling.Validation<Slip,ValidationError>` 로, 주석을 달면 `Result<Slip,ValidationError list>` 로 보여 준다(FSI 실측). 8·12챕터 |
