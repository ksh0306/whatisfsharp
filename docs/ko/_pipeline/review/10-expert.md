# 10챕터 검수 보고서 — 객체 프로그래밍 (F# 전문가)

검수 대상 `docs/ko/10-object-programming.md` (725줄, 실행 단위 6개)
참고 원문 `.cache/src/10-object-programming.txt` (원서 pp.130-140)
용어 후보 `.cache/review/10-glossary.md`

실측 환경: .NET SDK 10.0.111 / F# Interactive 14.0.111.0 (F# 10)
`verify-examples.sh` 6개 단위 전부 PASS, `check-note.sh` 위반 없음.
주석에 적힌 기대 출력은 실제 출력과 한 줄도 어긋나지 않았다.
아래 지적은 모두 FSI 실측을 근거로 한다. 줄 번호는 참고용이니 문자열로 대상을 특정하라.

## 수정 필요 (기술 오류)

- [10-object-programming.md:500,549,705] `[<AllowNullLiteral>]` 의 역할이 세 곳에서 틀렸다.

  line 549 는 "`[<AllowNullLiteral>]` 도 같은 목적으로, 다른 .NET 언어가 이 타입 자리에 `null` 을
  넣을 수 있게 한다"고 적었다. 그렇지 않다. 다른 .NET 언어는 이 특성이 있든 없든 F# 클래스 타입
  자리에 `null` 을 넘길 수 있다. 런타임에는 그런 제약이 아예 없다. 이 특성이 여는 쪽은 F# 이다.
  F# 은 자기가 선언한 클래스 타입에 `null` 리터럴을 허용하지 않고, `isNull : 'T -> bool` 은
  `when 'T : null` 제약을 요구한다. 그래서 이 특성은 상호운용을 위한 장식이 아니라 이 예제가
  컴파일되기 위한 필수 조건이다. 실측으로 특성만 떼면 이렇게 막힌다.

  ```
  error FS0001: 'Colour' 형식은 적절한 값으로 'null'을 가지지 않습니다.
  ```

  원인은 원서 p.139 다. "If we are going to use it in other .NET languages, we need to handle the
  equality operator using op_Equality and apply the AllowNullLiteral attribute" 로 성질이 다른
  둘을 한 문장에 묶어 두었다. `op_Equality` 쪽은 상호운용이 맞고 `AllowNullLiteral` 은 아니다.

  세 곳을 이렇게 고쳐라.

  line 500 불릿 뒷문장 → "다른 .NET 언어에서 `==` 로 쓰이게 하려면 `op_Equality` 정적 멤버를
  더한다. `[<AllowNullLiteral>]` 은 목적이 다르다. 그 특성이 있어야 F# 코드가 이 타입 자리에
  `null` 을 쓸 수 있고, 아래 예제의 `isNull` 도 그것 없이는 컴파일되지 않는다."

  line 549 불릿 → 불릿 두 개로 나눈다.
  "- `op_Equality` 는 F# 코드에서 쓰이지 않는다. F# 의 `=` 는 `Equals` 로 간다. C# 이나 VB.NET
  에서 `==` 로 견줄 수 있게 하려고 내놓는 계약이다.
  - `[<AllowNullLiteral>]` 은 상호운용 특성이 아니다. 다른 .NET 언어는 이 특성이 없어도 F# 클래스
  타입 자리에 `null` 을 넘긴다. 이 특성이 여는 것은 F# 쪽이다. F# 은 자기가 선언한 클래스 타입에
  `null` 리터럴을 허용하지 않으므로, 특성을 떼면 `isNull other` 가
  `error FS0001: 'Colour' 형식은 적절한 값으로 'null'을 가지지 않습니다.` 로 막힌다.
  원서 p.139 가 `op_Equality` 와 이 특성을 한 문장에 묶어 둔 것은 정확하지 않다."

  line 705 정리 뒷문장 → "다른 .NET 언어의 `==` 까지 맞추려면 `op_Equality` 정적 멤버를 더한다.
  `[<AllowNullLiteral>]` 은 상호운용용이 아니라 F# 코드가 그 타입에 `null` 리터럴을 쓸 수 있게
  하는 특성이고, `isNull` 을 쓰려면 반드시 붙여야 한다."

- [10-object-programming.md:608] 연산자 오버로딩의 피연산자 순서 서술이 틀렸다.

  현재 "정의 자리가 타입 안이므로 `+` 의 두 인자 중 적어도 하나가 이 타입이면 이 구현이 뽑힌다.
  `*` 처럼 왼쪽과 오른쪽 타입을 다르게 잡을 수도 있다." 뒷문장만 읽으면 순서가 자유롭다고 읽힌다.
  실측하면 노트의 `Pigment` 는 `(Pigment, float)` 순서로만 선언했으므로 뒤집으면 오류다.

  ```
  error FS0193: 형식 제약 조건이 일치하지 않습니다.
      'float'
  형식이
      'Pigment' 형식과 호환되지 않습니다.
  ```

  한편 후보 탐색은 양쪽 피연산자 타입을 모두 뒤지는 것이 맞다. `static member (*) (f: float, p: Pigment)`
  를 `Pigment` 안에 두면 왼쪽이 `float` 인 `0.5 * Pigment(200)` 도 통한다(실측). 둘 다 적어 두면
  양쪽 순서가 모두 통한다(실측).

  불릿 두 개로 교체하라.
  "- 컴파일러는 후보를 찾을 때 양쪽 피연산자의 타입을 모두 뒤진다. 왼쪽 피연산자 타입에 정의가
  없어도 오른쪽 타입에 있으면 뽑힌다.
  - 다만 선언한 매개변수 순서와 쓰는 순서는 맞아야 한다. 위 `*` 는 `(Pigment, float)` 순서로만
  선언했으므로 `Pigment(200, 100, 50) * 0.5` 는 통하고 `0.5 * Pigment(200, 100, 50)` 은
  `error FS0193: 형식 제약 조건이 일치하지 않습니다.` 다. 양쪽 순서를 다 쓰려면
  `static member (*) (factor: float, p: Pigment)` 를 오버로드로 하나 더 적는다."

- [10-object-programming.md:26] 코드 주석의 "기본 생성자" 가 본문과 어긋난다.

  본문 line 20 은 용어를 세우지 않고 "이 괄호가 생성자(constructor) 자리이고" 로 풀어 썼는데,
  같은 절의 코드 주석만 MS ko 표기 "기본 생성자"를 쓴다. 하필 그 블록의 `FixedSchedule()` 이
  실제로 매개변수 없는 생성자라서 독자는 "기본 생성자 = 매개변수 없는 생성자"로 굳힌다. 그런데
  같은 실행 단위 뒤쪽 `RuleSchedule(rules)` 는 매개변수가 있는 같은 자리다. 컴파일러도 이 표기를
  primary constructor 쪽에 쓴다 — `type I = let mutable x = 0 ...` 를 시도하면
  `error FS0963: 이 정의는 기본 생성자가 포함된 형식에서만 사용할 수 있습니다.` 다. 즉 "기본 생성자"
  는 이 노트가 피하려던 뜻으로 이미 점유돼 있다.

  `// 이 단위가 보여주는 것: 클래스 타입 선언, 기본 생성자, 멤버 호출, 멤버의 평가 시점`
  → `// 이 단위가 보여주는 것: 클래스 타입 선언, 생성자 매개변수, 멤버 호출, 멤버의 평가 시점`
  (용어집이 `primary constructor`→주 생성자를 채택하면 "주 생성자"로 적어도 된다.)

- [10-object-programming.md:479,492] 정원 판정 정정의 근거가 실측과 맞지 않는다. "안전하다"는 성립하지 않는다.

  집필자가 예제를 다시 짠 판단 자체는 옳다. `Capacity` 는 정원의 이름이 될 수 없다. 그러나 근거로
  든 이야기가 원서 코드에서는 그대로 재현되지 않고, 노트 판이 예외까지 막아 주는 것도 아니다.
  실측 결과다.

  원서 판(`if items.Count = items.Capacity then items.RemoveAt 0`):

  ```
  cap=5 n=7 -> Size=5 Capacity=5
  cap=3 n=7 -> Size=3 Capacity=3
  cap=1 n=3 -> Size=1 Capacity=1
  cap=0 n=3 -> 예외 ArgumentOutOfRangeException
  ```

  노트 판(`if steps.Count = capacity then steps.RemoveAt 0`):

  ```
  cap=3 n=5 -> Depth=3
  cap=1 n=3 -> Depth=1
  cap=0 n=1 -> 예외 ArgumentOutOfRangeException
  cap=-1 n=1 -> 예외 ArgumentOutOfRangeException
  ```

  정원 1 이상에서는 원서 코드도 돈다. `ResizeArray<'T>(n)` 이 딱 `n` 칸을 잡아 두고, 판정 자체가
  `Count` 가 그 수를 넘는 것을 막기 때문에 `Capacity` 가 늘어날 일이 오지 않는다. 그리고 정원 0
  에서는 두 판이 똑같이 터진다. 빈 `ResizeArray` 에 `RemoveAt 0` 을 부르는 것은 노트 판도 같다.
  그러므로 노트가 얻은 것은 "정원 판정의 의미"이고 "예외 안전"이 아니다.

  line 479 앞부분 → "원서는 정원 판정에 `items.Capacity` 를 쓴다(원서 p.137). `ResizeArray` 의
  `Capacity` 는 정원이 아니라 미리 확보해 둔 자리 수이고, 자리가 모자라면 늘어난다. 실측하면 이렇다."

  line 492 → 두 단락으로 교체.
  "정원 0 으로 만든 뒤 항목 하나를 넣으면 `Capacity` 가 4 로 뛴다. 생성자에 넘긴 값과 이렇게
  갈라지므로 `Capacity` 는 정원의 이름이 될 수 없다. 위 코드가 생성자 인자를 그대로 붙잡아 두고
  그것으로 판정한 까닭이 그것이다.

  원서 코드도 정원 1 이상에서는 실제로 돈다. `ResizeArray<'T>(n)` 이 딱 `n` 칸을 잡아 두고 판정이
  `Count` 가 그 수를 넘는 것을 막기 때문에 `Capacity` 가 늘어날 일이 오지 않는다. 다만 그것은
  `List<'T>` 구현이 그렇다는 사정일 뿐 계약이 아니다. 정원 0 은 두 판 모두 빈 `ResizeArray` 에
  `RemoveAt 0` 을 불러 `ArgumentOutOfRangeException` 이 난다. 정원에 하한이 필요하면 생성자에서
  검사하는 편이 낫다."

## 개선 권장

- [10-object-programming.md:348] 시그니처 주석이 FSI 실측과 다르다. 노트는
  `// start: DateTime -> stepMinutes: float -> IClock` 인데 FSI 는 `open System` 이 있어도
  `val steppingClock: start: System.DateTime -> stepMinutes: float -> IClock` 로 찍는다.
  STYLE.md 가 시그니처 주석은 실측값을 적으라고 못 박았으므로 `System.DateTime` 으로 맞춰라.

- [10-object-programming.md:562] `equality` 제약과 실제 동작을 뒤섞었다. "`List.distinct` 처럼
  `equality` 제약을 요구하는 컬렉션 함수까지 제대로 맞물린다"고 적었으나, `equality` 제약은
  컴파일 시점 조건이라 재정의가 없어도 `List.distinct` 는 컴파일된다. 달라지는 것은 결과다.
  실측: 재정의 없는 `Swatch` 로 돌리면 `List.distinct [s1; s2] |> List.length` 가 2 다.

  `s1`·`s2` 가 같은 실행 단위(`10-equality`)에 아직 살아 있으므로, line 559 블록 끝에 대비를
  한 줄 넣으면 문장이 실측으로 받쳐진다.
  ```
  printfn "재정의 없는 Swatch: %d" (List.distinct [s1; s2] |> List.length)      // 2
  ```
  본문은 "`=` 가 참이 되었을 뿐 아니라 `List.distinct` 의 결과까지 달라진다. `equality` 제약은
  컴파일 시점 조건이라 재정의가 없어도 컴파일은 된다. 달라지는 것은 결과다. 참조는 여전히 다르다는
  것도 함께 확인해 둘 만하다." 정도로 바꾸면 된다.

- [10-object-programming.md:548] FS0346 서술에 두 가지를 보태라. 첫째, 메시지가 "구조체, 레코드
  또는 공용 구조체 형식"이라 말하지만 대상은 클래스 타입이다. 이 어긋남을 한 절 짚어 주지 않으면
  독자가 "클래스인데 왜 구조체라 하지"에서 멈춘다. 둘째, "둘 중 하나만 재정의하면"이라 했으니
  반대 방향의 코드도 적어라. 실측하면 `GetHashCode` 만 재정의한 경우는
  `warning FS0345: 구조체, 레코드 또는 공용 구조체 형식 'HalfColour2'에 'Object.GetHashCode'의
  명시적 구현이 있습니다. 'Object.Equals(obj)'에 대해 일치하는 재정의를 구현하세요.` 다.

- [10-object-programming.md:548] `HalfColour` 는 노트 어디에도 없는 가상의 타입이라 독자가 재현할
  수 없다. 경고가 나므로 `id` 를 붙이면 검증이 FAIL 하니, `id` 없는 블록으로 넣어라. 아래 코드가
  실측으로 FS0346 을 낸다.
  ```
  // GetHashCode 를 빼면 warning FS0346 이 뜬다 (경고가 나므로 검증 대상에 넣지 않는다)
  type HalfColour(red: int) =
      member _.Red = red
      override _.Equals(candidate) =
          match candidate with
          | :? HalfColour as other -> red = other.Red
          | _ -> false
  ```

- [10-object-programming.md:176] "F# 에는 암시적 구현이 없다"에 오류 코드를 달아 주면 독자가 손으로
  확인할 수 있다. 실측: `interface IMaintenanceSchedule` 한 줄만 적고 같은 이름의 멤버를 클래스
  본문에 둔 코드는 `error FS0366: 'abstract IMaintenanceSchedule.Label: int -> string'에 대해
  지정된 구현이 없습니다. 모든 인터페이스 멤버가 구현되어 적절한 'interface' 선언에 나열되어야
  합니다(예: 'interface ... with member ...').` 다. 뒤에 나오는 FS0039 와 짝을 이루므로
  "구현하지 않으면 FS0366, 구현했지만 변환 없이 부르면 FS0039" 로 두 갈래가 정리된다.

- [10-object-programming.md:178] 원서의 "F# does not support implicit casting" 은 지금 그대로는
  성립하지 않는다. line 228 이 F# 6 이야기를 꺼내므로 챕터 안에서 두 서술이 부딪히는 것처럼 보인다.
  178 에 한 절 붙여 유효 범위를 미리 못 박아라. 예: "원서의 이 서술은 F# 5.0 시점 기준이다. F# 6
  이 몇 자리에 암시적 변환을 넣었으므로 그 범위는 뒤에서 갈라 본다. 멤버 조회 자리에는 여전히
  암시적 변환이 없으니 이 절의 결론은 그대로다."

- [10-object-programming.md:22,698] `new` 가 필수처럼 읽힌다. FS0760 은 경고이고 메시지도
  "만드는 것이 좋습니다"다. `use` 자체가 `new` 를 요구하는 것도 아니다. line 679 는 이 점을 제대로
  적었으니 앞쪽 두 곳을 맞춰라.

  line 22 → "- 인스턴스를 만들 때 C# 과 달리 `new` 를 쓰지 않는다. `IDisposable` 을 구현한 타입만
  예외인데, 그쪽은 `let` 대신 `use` 로 바인딩하고 `new` 도 함께 적는다. `new` 를 빠뜨려도 컴파일은
  되고 경고만 뜬다(이 노트 마지막 절)."

  line 698 뒷문장 → "인스턴스를 만들 때 `new` 는 쓰지 않는다. `IDisposable` 구현체만 예외이고
  그때는 `use` 와 `new` 를 함께 쓴다. `new` 를 빠뜨리면 오류가 아니라 경고 `FS0760` 이다."

- [10-object-programming.md:613] "원서 p.81 에도 같은 오기가 있다"가 정확하지 않다. 실측하면 두
  오기가 다르다. p.81(원문 `.cache/src/06-reading-data-from-file.txt:58,62`)은 `IDisposable<'T>`
  로 철자는 맞고 제네릭만 오기다. p.131(`.cache/src/10-object-programming.txt:42`)은
  `IDisposible<'T>` 로 철자까지 틀렸다. "원서 p.81 은 철자는 맞지만 제네릭 표기가 같은 오기다"
  정도로 갈라 적어라.

- [10-object-programming.md:246,719] 절 제목의 원서 페이지가 실제보다 넓다. 원서 p.133 에 있는 것은
  `[<AbstractClass>]` 사이드바 한 줄뿐이고 상속은 원서에 아예 없다. line 248 이 이미 "한 줄로만
  언급한다"고 밝히고 있으니 제목과 대조 표만 맞추면 된다.
  제목 → `### 추상 클래스와 상속 (원서 p.133 + 노트 보충)`
  대조 표 행 → `| 추상 클래스와 상속 | p.133 + 노트 보충 | \`10-interface\` |`

- [10-object-programming.md:248] 추상 클래스와 인터페이스의 차이를 "구현과 상태"라 했는데, F# 에서는
  "구현" 쪽이 더 강한 이야기라 실측 한 줄을 붙일 값이 있다. 인터페이스 선언에 `default` 를 붙이면
  그 타입이 더는 인터페이스가 아니라 클래스가 되어, 다른 타입에서 `interface ... with` 로 구현하려
  할 때 `error FS0887: 'IGreeter' 형식은 인터페이스 형식이 아닙니다.` 가 난다. 인터페이스 본문에
  `let` 을 적으면 `error FS0963` 이다. 즉 F# 인터페이스에는 기본 구현도 상태도 담을 수 없고, 둘 중
  하나라도 필요하면 추상 클래스로 가야 한다. 이 한 절이 "왜 굳이 추상 클래스인가"를 닫아 준다.

## 확인 완료

- 실행 단위 6개 전부 PASS, 경고 0. 주석의 기대 출력이 실제 출력과 전부 일치한다(6개 단위 출력을
  한 줄씩 대조했다).
- FSI 시그니처 블록 5개 전부 실측과 문자 단위로 일치한다. `FixedSchedule`(`new: unit -> FixedSchedule`,
  `member Label: day: int -> string`), `Gauge`(`with get, set` 이 `Location` 에만 붙는 것까지),
  `RuleTable`(`interface IMaintenanceSchedule` 한 줄과 빈 멤버 목록), `StepLog`(멤버 나열 순서까지),
  `val fixedClock: IClock`.
- `labelAll` 주석 시그니처 `rules: (int * string) list -> days: int list -> string list` 일치.
- line 280 의 `new: rules: (int * string) list * owner: string -> LineSchedule` 일치. 생성자 인자가
  커링이 아니라 튜플이라는 설명도 맞다.
- line 76 의 정정이 정확하다. 집필자가 초안에서 "안 된다"고 썼다가 뒤집은 그 대목이다. 실측하면
  `member _.Add(a, b) = a + b` 를 함수 값으로 넘긴 결과는 `val two: (int * int -> int)` 이고,
  `[(1,2); (3,4)] |> List.map two` 가 `[3; 7]` 로 돈다. "커링된 함수를 기대하는 자리에는 람다로
  감싸야 한다"는 뒷문장도 맞다.
- 평가 시점 세 갈래를 갈라 놓은 것이 실측과 정확히 맞는다. 클래스 본문 `let`·`do` 는 생성 시점 1회,
  `member` 본문은 접근마다, `member val` 은 생성 시점 1회. `Serial` 1/1 과 `NextTicket` 2/3 이
  그대로 재현된다. `RuleCount` 에 표시가 찍히지 않는 이유(생성 시점에 계산된 값을 읽기만 한다)도 맞다.
- 인터페이스 명시적 구현 서술이 정확하다. FSI 시그니처에 멤버가 비어 있는 것과 인스턴스 호출이
  `error FS0039: 'RuleTable' 형식은 'Label' 필드, 생성자 또는 멤버를 정의하지 않습니다.` 로 막히는
  것을 모두 재현했다. 인용 메시지가 원문 표기와 한 글자도 다르지 않다. 클래스 멤버와 인터페이스
  구현을 같은 이름으로 함께 둘 수 있다는 것도 확인했다(둘이 따로 뽑힌다).
- 암시적 변환 범위를 `--langversion` 으로 가른 것이 전부 맞다. 실측: 인터페이스 타입 매개변수를
  받는 함수·메서드의 인자 자리는 `--langversion:5.0` 과 `4.7` 에서도 통하고, 타입 주석이 붙은
  `let` 바인딩은 5.0 에서 `error FS0001`, 6.0 부터 통한다. line 228 의 FS0001 인용 문면도 일치한다.
  "F# 6 부터"라는 경계도 6.0 과 5.0 을 직접 갈라 확인했다.
- `use`/`let`/예외 경로 세 실측 전부 재현된다. `let` 이면 반납 기록이 없고, 예외 경로에서는 반납이
  예외 기록보다 앞에 온다. `new` 누락은 `warning FS0760`, `Dispose()` 직접 호출은 `error FS0039`
  이며 두 메시지 인용이 원문과 일치한다. `use` 가 변환 없이 `Dispose` 를 찾는다는 서술도 맞다.
- `Equals` 만 재정의했을 때 `warning FS0346` 이 나는 것과, 그 이유를 "해시가 어긋난 값을 딕셔너리
  키로 쓰면 다시 찾지 못한다"로 댄 것이 맞다. 인용 메시지도 원문과 일치한다.
- `op_Equality` 가 F# 의 `=` 경로에 끼지 않는다는 서술이 맞다. 실측하면 `c1 = Colour(1)` 도
  `c1.Equals(null)` 도 `Object.Equals` 재정의로 들어가고 `IEquatable<Colour>.Equals` 는 불리지 않는다.
- 원서 오기 판정 세 건 모두 확인했다. (1) p.131 `IDisposible<'T>` 는 철자와 제네릭 둘 다 오기다.
  (2) p.132 의 `calculate n` 본문 마지막 줄이 `|> fun s -> if s = "" then string value else s` 로
  스코프에 없는 `value` 를 참조한다(원문 `.cache/src/10-object-programming.txt:113`). `n` 이어야 한다.
  (3) pp.133-135 에서 같은 이름이 형태를 바꾼다 — `doFizzBuzz` 가 p.132 에서는
  `let doFizzBuzz mapping range = ...` 인데 p.133 부터 `let doFizzBuzz = ...` 로 값이 되고 범위가
  `[1..15]` 로 박힌다. `calculate` 의 마지막 줄도 p.132 `if s = "" then string value else s` 에서
  p.133 `if s <> "" then s else string n` 으로 갈린다.
- 용어집 `dispose`→해제 규칙 위반이 없다. 노트의 "정리" 2건은 `Dispose()` 맥락이 아니다 —
  line 691 은 "원서는 이 챕터를 ... 입문으로 정리한다"(요약한다는 뜻), line 696 은 절 제목
  "## 정리 — 이 노트의 요약"이다. `Dispose()` 맥락 3건은 모두 "해제"를 쓰고 있다.
- `id` 배정이 옳다. `id` 없는 블록 5개 중 4개(line 38, 165, 201, 399)는 FSI 시그니처 표시이고,
  1개(line 209)는 오류 예시다. 그 오류 예시가 실제로 주석에 적힌 FS0039 를 낸다는 것을 확인했다.
  `id` 붙은 블록 중 컴파일되지 않는 것은 없고, `id` 가 빠져 검증에서 누락된 실행 가능 블록도 없다.
- 원서의 태도 요약이 균형을 잡았다. line 3·13·16 이 상호운용과 캡슐화 두 자리를 들고(원문
  `.cache/src/10-object-programming.txt:2-7`), line 15 가 함수 하나짜리 인터페이스에 대한 제동을
  옮겼다(원문 `:191-193`). "객체는 나쁘다"로도 기울지 않고 과하게 권하지도 않는다. line 691 의
  요약 항목 네 개("스코프와 가시성, 캡슐화, 인터페이스와 변환, 동등성")도 원문 `:481` 과 일치한다.
- 객체 식 서술이 정확하다. 만들어지는 것이 이름 없는 타입이고 바인딩의 정적 타입이 인터페이스라서
  변환을 적을 일이 없다는 것, 지역 값과 `let mutable` 을 붙잡는다는 것, 한 번 쓰는 서비스와 테스트에
  알맞다는 것(원문 `:284`) 모두 맞다. `steppingClock` 이 `IClock` 을 값으로 돌려주는 예가 클로저
  성질을 정확히 짚는다.
- 캡슐화 서술이 정확하다. 클래스 본문 `let`·`let mutable` 이 밖에서 보이지 않는다는 것, `ResizeArray<'T>`
  가 .NET `List<'T>` 의 F# 쪽 이름이라는 것, `member private`·`member internal` 로 노출을 좁힐 수
  있다는 것 모두 맞다.
- 상속 서술이 정확하다. `inherit` 로 기반 타입 생성자를 부르는 것, 상속받은 멤버는 인터페이스와 달리
  변환 없이 보이는 것, `abstract member` 는 필수이고 `default` 를 주면 선택적 재정의가 되는 것.
- 다른 챕터 참조가 전부 맞다. 2챕터 클로저(`02-functions.md:251`), 3챕터 타입 테스트 패턴과
  `TryParse`/예외, 4챕터 모듈, 6챕터 가짜 리더 주입(`06-reading-data-from-file.md:461-462`)과
  `StreamReader`. "6챕터에서 함수를 매개변수로 넘겨 가짜를 끼워 넣던 방식"은 6챕터가 맞다.
- 용어집 기확정 표기와 충돌이 없다. 상향 변환(`:>`), 구조적 동등성, 타입 테스트 패턴, 사용자 정의
  연산자, `ResizeArray`, `IDisposable`, 가변, 가짜 모두 확정 표기대로 쓰였다.
