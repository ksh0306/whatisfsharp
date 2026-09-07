# 03챕터 기술 검수 (F# 전문가)

검수 대상: `docs/ko/03-null-and-exceptions.md` (515줄)
실측 환경: .NET SDK 10.0.111 / F# Interactive 14.0.111.0 / FSharp.Core 10.0.0.0
검증: `docs/ko/_pipeline/verify-examples.sh docs/ko/03-null-and-exceptions.md` → 5개 실행 단위 전부 PASS(경고 0),
주석에 적은 기대 출력이 실제 출력과 전부 일치. 아래 지적은 모두 FSI 실측을 근거로 한다.

## 수정 필요 (기술 오류)

- [docs/ko/03-null-and-exceptions.md:126] "F# 9 부터 켜진 nullable 참조 타입 표기 때문에 `'a | null` 이라는 모양이 보인다."
  틀렸다. F# 9 의 null 안전성 검사는 옵트인이고 기본은 꺼져 있다. 실측: 기본 설정에서 `let s: string = null` 은
  경고가 없고, `dotnet fsi --checknulls+` 를 주면 `warning FS3261: Nullness warning: The type 'string' does not support 'null'`
  이 난다. `'a | null` 이 보이는 이유는 검사가 켜져 있기 때문이 아니라 FSharp.Core 시그니처에 nullness 표기가 붙어 있어서다.
  같은 문서 118줄의 `let missingNickname : string = null` 이 경고 없이 통과하는 것과도 어긋난다(챕터 내 자기모순).
  교체 문장:
  "`ofObj`/`toObj` 는 참조 타입에만, `ofNullable`/`toNullable` 은 값 타입에만 쓸 수 있다. `'a | null` 은 F# 9 에서
  들어온 null 허용 참조 타입(nullable reference types) 표기이고, FSharp.Core 시그니처에 nullness 정보가 붙어 있어
  이렇게 보인다. `'a` 또는 `null` 로 읽으면 된다. 검사 자체는 기본으로 꺼져 있어 위의 `null` 바인딩이 경고 없이 통과한다.
  켜려면 `--checknulls+` 를 준다."

- [docs/ko/03-null-and-exceptions.md:487] "반대 방향은 `Result` 의 실패 정보를 버리는 것이라 `Option.ofObj` 처럼 자연스러운 표준 함수가 없다."
  틀렸다. 실측: `Result.toOption : Result<'a,'b> -> 'a option` 이 FSharp.Core 에 있다. 같이 있는 것으로
  `Result.defaultValue : 'a -> Result<'a,'b> -> 'a`, `Result.defaultWith : ('a -> 'b) -> Result<'b,'a> -> 'b`,
  `Result.isOk`/`isError`, `Result.toList` 도 확인했다. (반대로 `Result.ofOption` 은 없다 — `error FS0039`.
  474줄의 "`ofOption` 은 표준 모듈에 없어 직접 만들었다"는 서술은 맞다.)
  교체 문장 + 실행 단위 `03-result-errors` 에 이어 붙일 블록:
  "- 반대 방향에는 표준 함수가 있다. `Result.toOption` 은 `Ok` 안의 값을 `Some` 으로 옮기고 `Error` 는 이유를 버린 `None` 이 된다.
  실패 이유를 버리는 것이 의도일 때만 쓴다."
  ```fsharp id=03-result-errors
  // Result.toOption : Result<'a,'b> -> 'a option
  // Error 의 이유는 버려진다
  printfn "%A" (upload 1024 |> Result.toOption)   // 기대: Some "업로드 1024 바이트"
  printfn "%A" (upload 0 |> Result.toOption)      // 기대: None
  ```
  (위 두 줄은 실측으로 그대로 출력됨을 확인했다.)

- [docs/ko/03-null-and-exceptions.md:23] "F# 에는 `out` 매개변수가 없으므로, 상호운용 과정에서 `out` 매개변수가 반환값 쪽으로 옮겨 붙는다."
  원서 p.41 의 "the F# language does not support out parameters" 를 그대로 옮긴 결과이고 부정확하다. F# 은 `out`
  매개변수를 선언하는 문법이 없을 뿐, 호출 쪽에서는 `byref` 로 넘길 수 있다. 실측:
  `let mutable v = DateTime.MinValue` 뒤에 `DateTime.TryParse("2024-03-18", &v)` 는 경고 없이 컴파일되고 `true` 를 낸다.
  교체 문장:
  "`Option` 이 처음 등장하는 자리는 .NET 의 `TryParse` 계열이다. F# 에는 `out` 매개변수를 선언하는 문법이 없어서,
  상호운용에서는 컴파일러가 `out` 매개변수를 반환값 쪽으로 옮겨 붙여 준다. 그 결과 `DateTime.TryParse` 는
  `bool * DateTime` 튜플을 돌려준다. `let mutable` 값을 만들어 `&value` 로 직접 넘기는 길도 있지만, 튜플로 받는 쪽이 관용적이다."

- [docs/ko/03-null-and-exceptions.md:227] "`:?` 는 타입 검사 패턴이다. 예외가 지정한 타입이나 그 하위 타입으로 캐스팅되는지를 본다."
  용어 판단(원서의 "cast operator" 를 버리고 타입 테스트 패턴으로 부른 것)은 맞다. 캐스팅 연산자는 `:>`(상향 변환)와
  `:?>`(하향 변환)이고 `:?` 는 변환이 아니다. 그런데 설명 문장에 "캐스팅되는지를 본다"가 남아 원서의 부정확한 틀을 되살린다.
  `:?` 는 런타임 타입 테스트이고, 값을 바꾸지 않는다.
  표기는 용어집 후보에서 "타입 테스트 패턴"으로 확정했다(`타입 검사`는 정적 타입 검사와 헷갈린다). 교체 문장:
  "- `try/with` 안의 `:?` 는 타입 테스트 패턴(type test pattern)이다. 던져진 예외가 적은 타입이거나 그 하위 타입인지를
  런타임에 검사할 뿐 값을 변환하지 않는다. 일치하면 `as ex` 가 그 타입으로 좁혀진 예외 인스턴스를 묶어 주고,
  이것을 `Error` 의 경우 데이터로 넘긴다."
  (실측 근거: 253-255줄 `tryDivideNarrow` 에서 `as ex` 로 받은 값의 타입이 `DivideByZeroException` 으로 잡혀
  함수 시그니처가 `Result<decimal,System.DivideByZeroException>` 이 된다.)

- [docs/ko/03-null-and-exceptions.md:492] 책 제목 `Domain Modelling Made Functional` — 실제 제목은
  `Domain Modeling Made Functional` 이다. 원서 본문은 영국식 철자로 적었지만 원서 각주 URL 자체가
  `pragprog.com/book/swdddf/domain-modeling-made-functional` 이다. 서지 정보이므로 실제 제목으로 적는다.

## 개선 권장

- [docs/ko/03-null-and-exceptions.md:230-267] `tryDivide` 세 판의 순서. 세 판을 다 싣는 것 자체는 유지할 값이 있다
  (하나만 남기면 원서와 대조할 때 독자가 컴파일러 동작을 오해한다). 문제는 순서다. 지금은 이유를 말하기 전에
  주석판이 먼저 나와 "반환 타입 주석을 붙이는 것이 기본"으로 읽힌다. 컴파일러 기본 동작 → 왜 그것이 불편한지 →
  넓히는 두 방법 순으로 뒤집기를 권한다. 즉 `tryDivideNarrow` 를 먼저 보여 실패 타입이 `DivideByZeroException` 으로
  좁혀지는 것을 확인시키고, 267줄의 "여러 단계를 이어 붙이려면 실패 타입이 같아야 한다"를 그 자리로 끌어올린 다음,
  넓히는 두 방법(반환 타입 주석, `Error (ex :> exn)`)을 나란히 놓는 것이다. 그리고 세 판을 묶는 한 문장을 붙여라:
  "세 판은 같은 계산이고 다른 것은 실패 타입뿐이다. 파이프라인에 넣을 것은 실패 타입이 `exn` 으로 통일된 판이다."

- [docs/ko/03-null-and-exceptions.md:282, 303] FSI 가 넣는 괄호 설명이 없다. 주석은 `Result<(Reading * int),exn>`,
  소스 주석은 `Result<Reading * int, exn>`, 산문(303줄)도 괄호가 없어 독자가 괄호가 필수라고 오해할 수 있다.
  282줄 주석을 두 줄로 늘려라: "FSI 는 성공값이 튜플이면 `Result<(Reading * int),exn>` 처럼 괄호를 넣어 표시한다.
  소스에 적은 `Result<Reading * int, exn>` 과 같은 타입이고 표시 방식만 다르다."

- [docs/ko/03-null-and-exceptions.md:129-132] `ofNullable`/`toNullable` 제약을 실측 그대로 싣는 판단은 타당하다
  (요약하면 무엇이 진짜 제약인지 흐려진다). 다만 `(new : unit -> 'a) and 'a :> System.ValueType` 은 초보가 해독을
  시도하다 시간을 버리는 지점이니 한 줄을 붙여라: "뒤쪽 두 제약은 `Nullable<'T>` 가 요구하는 값 타입 조건을
  컴파일러가 풀어 쓴 것이다. 읽을 때는 `'a : struct` 하나만 보면 된다."

- [docs/ko/03-null-and-exceptions.md:349-362] `| Error err -> Error err` 를 `| e -> e` 로 줄일 수 없다는 사실을
  한 줄 주석으로 남겨라. `map`/`bind` 가 어디서 타입을 바꾸는지 이해하는 핵심이고, 초보가 반드시 시도하는 축약이다.
  실측: `| e -> e` 로 바꾸면 성공 타입이 고정되어 시그니처가 `('a -> 'a) -> Result<'a,'b> -> Result<'a,'b>` 가 되고
  `mapOk (fun (i: int) -> string i) (Ok 3)` 이 `error FS0001` 로 막힌다. 넣을 주석:
  "`| Error err -> Error err` 를 `| e -> e` 로 줄일 수 없다. 들어오는 타입은 `Result<'a,'c>`, 나가는 타입은
  `Result<'b,'c>` 라서 성공 타입이 다르다. 같은 값을 그대로 흘리면 `'a` 와 `'b` 가 같은 타입으로 묶여 제네릭이 무너진다."

- [docs/ko/03-null-and-exceptions.md:193-201] `divideUnsafe` 는 정의만 하고 한 번도 부르지 않는다. "시그니처가
  거짓말한다"는 이 절의 주장을 독자가 눈으로 확인할 수 없다. 실행 단위 `03-exceptions` 의 첫 블록에 3줄을 더해라
  (실측으로 아래 출력을 확인했다).
  ```fsharp id=03-exceptions
  // 시그니처가 말하지 않은 실패를 눈으로 확인한다. decimal 나눗셈은 0 으로 나누면 예외다
  // float 는 예외 없이 infinity 를 내므로 이 예제는 decimal 을 쓴다
  try printfn "%M" (divideUnsafe 7M 0M)
  with :? DivideByZeroException as ex -> printfn "%s" (ex.GetType().Name)   // 기대: DivideByZeroException
  ```

- [docs/ko/03-null-and-exceptions.md:40] 원서의 네 표기를 두 개로 줄인 판단은 타당하다. 빠진 학습 요소는 없다
  (와일드카드 범위 차이, `if` 식과 일치 식의 등가성이 모두 산문에 남아 있다). 한 가지만 보완하면 좋다.
  "`_` 하나로 튜플 전체를 받을 수 있다"는 초보가 자주 의심하는 지점이니, 42-48줄 블록 안에 대안 한 줄을
  주석으로 남겨라: `// | _ -> None 으로 줄여도 같다. 튜플 전체가 와일드카드 하나에 걸린다`.
  별도 함수를 더 만들 필요는 없다.

- [docs/ko/03-null-and-exceptions.md:248] 원서 대조 메모가 이미 있는 자리이니, 집필자가 발견한 원서 p.45 의 오기도
  여기 한 줄로 남겨라. 판단은 맞다. 그 시점의 `tryDivide` 는 `Result` 를 내므로 `let goodDivide = tryDivide 1M 1M`
  의 주석 `// Some 1M` 은 `// Ok 1M` 의 오기다. 넣을 문장: "원서 p.45 의 `// Some 1M` 주석은 `// Ok 1M` 의 오기다.
  그 시점 `tryDivide` 는 `Option` 이 아니라 `Result` 를 낸다."

- [docs/ko/03-null-and-exceptions.md:415, 514] 절 제목의 `(원서 p.48)` 이 오해를 부른다. 이 절 내용(`Result.mapError`,
  도메인 오류 판별 유니온)은 원서에 없는 노트의 확장이다. 원서 p.48 은 실패 데이터가 예외가 아니어도 된다는 한 문단뿐이고
  `mapError` 는 03챕터 어디에도 나오지 않는다. 제목과 대조 표에 "원서 p.48 확장"처럼 적어 대조 시 혼동을 막아라.

- [docs/ko/03-null-and-exceptions.md:77-79] `Option.defaultValue` 는 기본값을 먼저 평가한다. 기본값을 만드는 데
  비용이 들면 `Option.defaultWith : (unit -> 'a) -> 'a option -> 'a` 를 쓴다는 한 줄을 시그니처 목록에 덧붙일 만하다
  (실측 시그니처다). 08챕터의 검증 파이프라인에서 다시 만난다.

- [docs/ko/03-null-and-exceptions.md:16-21] 개념 확인용 `Option` 정의의 경우 순서가 실제와 반대다. FSharp.Core 는
  `None` 이 먼저다. 원서도 `Some` 을 먼저 적었으니 그대로 둬도 되지만, 판별 유니온의 경우 순서가 비교 순서를 정하므로
  뒤 챕터에서 정렬을 다룰 때 걸린다(실측: `compare None (Some 1)` 은 `-1`, `List.sort [Some 2; None; Some 1]` 은
  `[None; Some 1; Some 2]`). 블록 주석에 "실제 정의는 `None` 이 먼저다" 한 줄을 남기는 정도가 적당하다.

## 확인 완료

- 시그니처 전수 실측 일치. 노트에 적힌 다음 시그니처가 FSI 출력과 문자 단위로 같다.
  `Option.map : ('a -> 'b) -> 'a option -> 'b option`, `Option.bind : ('a -> 'b option) -> 'a option -> 'b option`,
  `Option.defaultValue : 'a -> 'a option -> 'a`, `Option.ofObj : 'a | null -> 'a option (when 'a : not struct and 'a : not null)`,
  `Option.toObj : 'a option -> 'a | null (when 'a : not struct)`, `ofNullable`/`toNullable` 의 세 제약 전체,
  `Result.map : ('a -> 'b) -> Result<'a,'c> -> Result<'b,'c>`, `Result.bind : ('a -> Result<'b,'c>) -> Result<'a,'c> -> Result<'b,'c>`,
  `Result.mapError : ('a -> 'b) -> Result<'c,'a> -> Result<'c,'b>`, `raise : System.Exception -> 'a`, `failwith : string -> 'a`.
- 노트 코드에 적은 함수별 실측 주석도 전부 일치. `divideUnsafe`, `parsedOrZero`, `tryDivide`, `show`,
  `tryDivideNarrow`(`Result<decimal,System.DivideByZeroException>`), `tryDivideWide`, `loadHistory`(`Result<(Reading * int),exn>`),
  `markVerified`, `calibrate`, `mapOk`, `bindOk`, `readSize`, `toUploadError`, `checkSize`, `upload`, `describeUpload`,
  `ofOption`, `orAnonymous`(`(string option -> string)` 괄호까지) 모두 재현했다.
- 집필자가 보고한 원서와의 차이 5건은 전부 타당하다.
  (1) 타입 주석을 떼면 실패 타입이 `DivideByZeroException` 으로 좁혀진다 — 재현.
  (2) `ofObj`/`toObj` 가 `'a | null` 로 표시된다 — 재현(다만 그 이유 설명은 위 수정 필요 첫 항목 참고).
  (3) `ofNullable`/`toNullable` 제약 표기 — 실측 그대로다.
  (4) FSI 가 튜플 성공값에 괄호를 넣는다 — 재현.
  (5) 원서 p.45 의 `// Some 1M` 은 `// Ok 1M` 의 오기 — 맞다.
- `map` 과 `bind` 의 의미론이 정확하다. 넘기는 함수가 감싼 값을 내는지로 갈린다는 기준(371줄, 502줄), `map` 을
  잘못 쓰면 `'b option option` 으로 겹친다는 설명(83줄), 실패 선로는 함수를 부르지 않고 그대로 흐른다는 설명(104줄)
  모두 맞다. 08·12챕터가 이 위에 올라가도 흔들리지 않는다.
- `Result` 의 타입 매개변수 두 개의 역할, `mapError` 가 `map` 의 거울상이라는 설명, 실패 타입이 파이프라인 전체에서
  하나여야 하는 이유(`bind` 의 `'c` 가 공유되므로)와 그 어긋남을 `mapError` 로 메우는 흐름이 정확하다.
- `try/with` 가 값을 내는 식이고 두 갈래가 같은 타입을 내야 한다는 서술, `raise`/`failwith` 의 반환 타입이 `'a` 인
  이유(정상 반환이 없으므로 어떤 타입 자리에도 놓을 수 있다)의 서술이 정확하다.
- 실행 단위 5개 전부 PASS, 경고 0. 이어 붙인 상태 기준으로 주석의 기대 출력이 실제 출력과 모두 일치한다
  (`Some "Monday" None`, `Monday | 평일 아님`, `7/2 Ok 3.5`, `4KB 초과`, `-1 -> 실패: 음수 크기` 포함).
- `id` 가 빠진 블록 6개는 모두 규칙에 맞다. 시그니처 목록 3개(76-80, 128-133, 375-379줄), 개념 정의 2개
  (`Option`, `Result` — 붙여 실행하면 내장 타입과 충돌한다), 컴파일 오류 예시 1개(305-312줄 `refineBroken`).
  `refineBroken` 은 실제로 `error FS0001` 이고 오류 위치가 `markVerified` 줄임을 확인했다. 누락된 실행 가능 블록은 없다.
- `ofOption` 이 표준 모듈에 없다는 서술(474줄) 확인. `Result.ofOption` 은 `error FS0039` 다.
- 원서 페이지 대조가 맞다. Null Handling pp.39-41, Interop With .NET pp.42-43, Handling Exceptions pp.43-45,
  Function Composition With Result pp.45-51, Summary p.51.

## 집필자가 판단을 요청한 것

- `Scott Wlaschin` → 스콧 블라신. 확실한 근거가 있는 표기가 없어 집필자 표기를 고정한다. 첫 등장 시 원어 병기는 유지.
- `Railway Oriented Programming` → 철도 지향 프로그래밍. 유지. 약어 ROP 허용.
- `type test pattern` → 타입 테스트 패턴으로 확정한다. `:?` 를 타입 테스트로 본 집필자 판단은 맞고 원서의
  "cast operator" 가 부정확하다. 다만 "검사"는 정적 타입 검사(type checking)와 겹치므로 MS ko "형식 테스트 패턴"에서
  형식만 타입으로 바꾼 표기를 택했다. 227줄 한 곳이므로 교체 비용은 작다.
- 세 판(`tryDivide` 주석판·실측판·상향 변환판)을 다 싣는 것: 유지에 찬성한다. 원서와 대조하는 독자에게는 세 판이
  다 필요하다. 단 순서를 뒤집으라는 위 개선 권장을 함께 적용해야 혼란이 없다.
- Null Handling 절 네 표기를 두 개로 줄인 축약: 타당하다. 빠진 학습 요소 없음.
