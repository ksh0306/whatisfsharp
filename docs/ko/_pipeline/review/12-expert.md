# 12챕터 전문가 검수 보고서 — 계산 식

대상: `docs/ko/12-computation-expressions.md` (627줄, 실행 단위 6개)
참고 원문: `.cache/src/12-computation-expressions.txt` (원서 pp.153-165)
실측 환경: .NET SDK 10.0.111, `dotnet fsi`, `FsToolkit.ErrorHandling, 5.2.0`

게이트는 둘 다 통과한다. `verify-examples.sh` 실행 단위 6개 전부 PASS,
`check-note.sh` 금지 패턴 위반 없음. 주석에 적힌 시그니처와 기대 출력은
`dotnet fsi --use:` 로 하나하나 대조했고 어긋난 것이 하나도 없다.
`id` 없는 블록 4개(37·140·274·525줄)는 모두 실제로 컴파일되지 않고, 적어 둔 오류 코드도 전부 맞다.

## 수정 필요 (기술 오류)

- [12-computation-expressions.md:460] 반환 타입 주석이 필요하다는 서술이 틀렸다.
  현재 문장은 "반환 타입 주석이 필요한 이유도 값 제한과 같은 사정이다. 주석이 있으면 `PassError` 가
  확정되어 `requireSome` 과 `mapError` 가 무엇으로 갈아 끼울지 정해진다" 다.
  두 가지가 틀렸다. 첫째, `requestPass` 는 매개변수가 둘 있는 함수 바인딩이라 값 제한과는 아무 관계가
  없다(값 제한은 매개변수 없는 `let` 에만 걸린다 — 용어집 `value restriction` 행). 둘째, 주석이 없어도
  컴파일된다. 실측으로 주석만 떼고 돌리면 여섯 줄 출력이 그대로 나오고 시그니처도
  `name: string -> pin: string -> Async<Result<DayPass,PassError>>` 로 유추된다.
  `UnknownRider`·`WrongPin` 과 `NotInGoodStanding`·`IssueFailed` 가 모두 `PassError` 의 케이스여서
  실패 타입이 그 자리에서 정해지기 때문이다.
  아래 문장으로 갈아라.

  ```
  반환 타입 주석은 없어도 컴파일된다. 네 줄에 나오는 `UnknownRider`·`WrongPin`·`NotInGoodStanding`·
  `IssueFailed` 가 모두 `PassError` 의 케이스라 실패 타입이 그 자리에서 정해지고, 주석을 떼도
  `Async<Result<DayPass,PassError>>` 로 유추된다(실측 확인). 주석은 네 단계를 겹친 반환 타입을
  한눈에 보이게 하려고 원서가 적어 둔 것이다.
  ```

- [12-computation-expressions.md:287] 함수 안에서 값 제한이 나지 않는 이유를 잘못 짚었다.
  현재 문장은 "함수 안에서 쓰면 이 문제가 나지 않는다. 위의 `settleCe` 가 그런 경우로, 함수 몸통에서
  `addSubsidy` 를 부르므로 실패 타입이 `exn` 으로 정해진다" 다. 뒷문장은 `settleCe` 에 대해서만 맞고,
  앞문장의 이유로는 성립하지 않는다. 함수 바인딩은 정해지지 않은 타입이 자동 일반화되므로 값 제한에
  애초에 걸리지 않는다. 실측하면 `let wrap (x: int) = result { return x }` 의 시그니처가
  `x: int -> Result<int,'a>` 다. 실패 타입이 미정인데도 오류가 아니다.
  이 챕터가 값 제한을 처음 만나는 자리가 아니므로(용어집이 이미 "매개변수 없는 `let` 바인딩" 으로
  못 박아 두었다) 이유를 바로잡아야 한다. 아래 문장으로 갈아라.

  ```
  함수 안에서 쓰면 이 문제가 나지 않는다. 값 제한은 매개변수 없는 `let` 에만 걸리고, 매개변수가 있으면
  정해지지 않은 타입이 자동 일반화된다. `let wrap (x: int) = result { return x }` 의 시그니처가
  `x: int -> Result<int,'a>` 로 나오는 것이 그 증거다(실측 확인). 위의 `settleCe` 는 자동 일반화까지
  갈 일도 없다. 몸통에서 `addSubsidy` 를 부르므로 실패 타입이 `exn` 으로 정해진다.
  ```

- [12-computation-expressions.md:386] 챕터 참조가 틀렸고 같은 문서 457줄과 부딪힌다.
  "9챕터가 세운 방식대로 각 단계가 제 실패 타입을 쓰고, 이어 붙이는 자리에서 `mapError` 로 갈아 끼우는
  구조다" 로 적혀 있는데, 단계마다 다른 실패 타입을 `mapError` 로 맞추는 방식을 세운 것은 3챕터다
  (`03-null-and-exceptions.md:442` "실패 타입을 직접 정하기 — `Result.mapError`", 같은 파일 473줄이
  `exn` 을 `UploadError` 로 맞추는 예제다). 9챕터는 단일 케이스 판별 유니온과 스마트 생성자를 다루고
  실패 타입 합성은 다루지 않는다(`mapError` 가 한 번도 안 나온다). 같은 문서 457줄이 이미
  "3챕터에서 실패 타입을 맞추려고 `mapError` 를 어댑터로 쓴 것과 똑같은 쓰임이다" 라고 적고 있어
  자기모순이기도 하다. `9챕터가` 를 `3챕터가` 로 고쳐라.

- [12-computation-expressions.md:347] 용어집 표기를 어겼다.
  "업무 애플리케이션(LOB, Line of Business)" 로 적혀 있는데 등재 표기는 "업무용 애플리케이션" 이고
  병기 형태도 `업무용 애플리케이션(LOB, Line of Business)` 로 못 박혀 있다
  (`GLOSSARY.md:166`, 00챕터 19줄이 이 형태를 쓴다). `업무용 애플리케이션(LOB, Line of Business)` 으로
  고쳐라.

- [12-computation-expressions.md:114] `[<AutoOpen>]` 설명이 가리키는 대상이 어긋났다.
  "이 특성을 붙인 모듈의 이름은 그 네임스페이스나 어셈블리를 참조하기만 하면 `open` 없이 보인다" 인데,
  `open` 없이 보이게 되는 것은 모듈의 이름이 아니라 모듈 안의 이름이다. 모듈 이름 자체는 특성이 없어도
  네임스페이스를 통해 보인다. 게다가 이 실행 단위에서 실제로 작동하는 기제는 어셈블리 참조가 아니라
  중첩 모듈 자동 열기다 — 스크립트의 암시적 모듈 안에 있는 `GrainCe` 가 그 자리에서 열린 상태가 되는
  것이다. 두 문장을 아래로 갈아라.

  ```
  `[<AutoOpen>]` 은 4챕터에서 이미 쓴 특성이다. 이 특성을 붙인 모듈 안의 이름은 그 네임스페이스나
  어셈블리를 참조하기만 하면 `open` 없이 보인다. 스크립트에서도 마찬가지인데, 이때는 암시적 모듈 안에
  중첩된 `GrainCe` 가 그 자리에서 열린 상태가 되는 것이다.
  ```

## 개선 권장

- [12-computation-expressions.md:43] 익명 함수가 필요한 이유가 첫 줄에는 해당하지 않는다.
  "매개변수 순서가 앞으로 파이프하기에 맞지 않아 익명 함수로 값을 받고 있는데" 로 적혀 있지만,
  37줄 블록의 `|> fun load -> withCover load` 는 `|> withCover` 와 같은 것이라 순서와 무관하다.
  순서가 맞지 않아 익명 함수가 필요한 것은 `|> fun covered -> split covered sacks` 쪽이다
  (`split` 의 둘째 매개변수에 파이프된 값이 들어가야 한다). 대상을 좁혀 적어라.

  ```
  마지막 줄이 익명 함수를 쓰는 것은 `split` 의 매개변수 순서가 앞으로 파이프하기에 맞지 않아서다.
  파이프된 값이 둘째 자리에 들어가야 하므로 이름으로 받아 넘긴다. 이 군더더기도 계산 식이 없애 줄 것
  가운데 하나다.
  ```

- [12-computation-expressions.md:127 뒤] `let!` 이 `Bind` 호출로 풀린다는 인과를 코드로 한 번 보여 주면
  이 챕터의 핵심이 확실히 박힌다. 지금은 133줄 산문만 그 말을 하고, 독자는 `Bind` 가 불린다는 것을
  믿어야 한다. `12-option-builder` 단위에 아래 블록을 하나 더 넣어라(실측으로 통과 확인했고,
  같은 단위의 첫 블록에만 기대므로 위치는 "줄마다 무엇이 일어나는지 보면 이렇다" 불릿 바로 앞이든
  뒤든 된다).

  ```fsharp id=12-option-builder
  // 계산 식이 풀린 모양을 손으로 적어 본 것. perSackCe 와 결과가 같다
  // FSI 실측: perSackByHand: total: int -> trucks: int -> sacks: int -> int option
  let perSackByHand total trucks sacks =
      option.Bind(split total trucks, fun load ->
          let covered = withCover load
          option.Bind(split covered sacks, fun perSack ->
              option.Return perSack))

  printfn "%-8s %A" "byHand" (perSackByHand 900 3 5)
  // byHand   Some 60
  ```

  블록 뒤에 한두 줄만 붙이면 된다 — `let!` 두 줄이 `option.Bind` 두 번으로, `return` 이
  `option.Return` 으로 풀린 것이고, `!` 없는 `let covered` 만 빌더를 거치지 않고 그대로 남았다.
  173줄의 `ReturnOnlyBuilder` 실험과 짝이 되어 "`let` 은 `map` 으로 바뀌지 않는다" 의 근거가 둘이 된다.

- [12-computation-expressions.md:189] `Zero`·`Combine` 이 필요해지는 조건이 뭉개져 있다.
  "여러 식을 이어 붙일 때" 로 읽으면 `printfn` 한 줄 뒤에 `return` 을 적는 것도 `Combine` 이 필요한
  줄로 오해된다. 실측하면 `Bind`·`Return`·`ReturnFrom` 세 멤버만 있는 빌더에서
  `option { printfn "hi"; return n }` 은 그대로 돈다. `Combine` 이 필요해지는 것은 계산 식 값을 내는
  식이 둘 이상 이어질 때다. `Zero` 쪽은 오류 코드를 함께 적어 두면 독자가 확인할 수 있다 —
  `else` 없는 `if` 를 적으면 `error FS0708` 이 나고 메시지가 어느 멤버를 원하는지 이름으로 알려 준다
  (컴파일러 한국어 메시지는 빌더를 "작성기" 로 부르므로, 인용한다면 원문 표기 그대로 적어라).
  마지막 문장을 아래로 갈아라.

  ```
  `Zero` 는 `else` 없는 `if` 를 적을 때 필요해지고, 없으면 `error FS0708` 로 그 멤버 이름을 알려 준다.
  `Combine` 은 계산 식 값을 내는 식이 둘 이상 이어질 때 필요해진다. 둘 다 원서의 범위 밖이다.
  ```

- [12-computation-expressions.md:151-159] `let! (load: int)` 의 타입 주석이 `return!` 형태의 필수
  요건처럼 읽힌다. 149줄 산문이 "타입 주석으로 같은 것을 확인할 수 있다" 로 이유를 대고 있으나,
  블록 위 주석은 `return!` 만 말한다. 주석 줄 옆에 한 마디만 붙여 두면 오해가 없다.

  ```fsharp
  let! (load: int) = split total trucks   // 주석은 ! 가 한 겹 벗겼음을 확인하려 단 것이고 없어도 된다
  ```

- [12-computation-expressions.md:251] `map`/`let` 의 대응을 짚는 문장이 134줄의 정정과 부딪혀 읽힐 수
  있다. "계산 식이 아닌 쪽에서 `Result.map` 을 쓸 자리가 `!` 없는 `let` 이고" 는 자리의 대응을 말한
  것이라 그 자체로는 맞지만, 134줄이 막으려던 오해("`let` 이 `map` 으로 바뀐다")로 되돌아갈 여지가
  있다. `map` 이 필요 없어지는 이유를 한 절 덧붙여라 — `Bind` 가 이미 한 겹 벗긴 값을 넘겨 주므로
  뒤에 오는 함수는 벗기지 않은 값을 그대로 받는다는 것이다. 배치 D 주의사항 2가 요구한 인과가
  노트 어디에도 명시돼 있지 않다.

- [12-computation-expressions.md:403] `warning FS0049` 가 나는 줄을 좁게 적었다.
  "그 줄에 `warning FS0049` 로" 라고 되어 있으나 실측하면 대문자 변수 패턴이 있는 모든 줄에 각각
  난다(케이스 셋을 대문자 이름으로 적으면 FS0049 가 세 번, FS0026 이 세 번 나온다). "그 줄에" 를
  "대문자 이름을 적은 줄마다" 로 고쳐라. 뒤 케이스의 FS0026 서술은 맞다.

## 확인 완료

- 계산 식이 무엇으로 풀리는지의 인과. `let!`→`Bind`, `return`→`Return`, `return!`→`ReturnFrom`,
  `do!`→`Bind` 서술(88·133·135·169·491줄) 전부 맞다. `Bind` 가 `None`·`Error` 를 받으면 뒤에 오는
  함수를 부르지 않는다는 설명과, 그것을 조기 반환이라 부르지 않는 이유(61·561·587줄)도 맞다.
  563줄 블록의 호출 흔적 실험이 그 주장을 실제로 증명한다.
- 최소 멤버 서술. `Bind`·`Return`·`ReturnFrom` 세 멤버로 `let!`·`let`·`return`·`return!`·`do!` 가
  전부 도는 것을 별도 빌더로 실측 확인했다. 세 멤버뿐인 빌더에서 `do! (unit option)` 이 돌고,
  `do!` 를 마지막 줄에 두어도 `Zero` 없이 돈다. 189줄의 주장은 성립한다.
- `!` 없는 `let` 이 `map` 으로 바뀌지 않는다는 정정(134·189·604줄)과 그 근거인 `ReturnOnlyBuilder`
  실험(173줄). `Return` 하나만 있는 빌더로 `let` 두 줄이 통과하는 것을 확인했다. 원서 p.155 를
  그대로 옮기지 않은 것이 옳다.
- 오류 코드 네 쌍 전부 실측과 일치한다. 빌더 없는 `option { }` 은 `error FS0800: 형식 이름을 잘못
  사용했습니다`, 패키지 없는 `result { }` 는 `error FS0039: 'result' 값 또는 생성자가 정의되지
  않았습니다`, 모듈 수준 `let staged = result { return bumper }` 는 `error FS0030` 이며 메시지의
  `val staged: Result<Farm,'_a>` 까지 274-275줄 주석과 글자가 같다. `[<Literal>]` 제거는
  `warning FS0049` + `warning FS0026` 이고 오류가 아니라 경고다.
- 배치 D 주의사항 1의 정밀화가 정확하다. 평범한 `unit` 을 `do!` 에 주면 `async` 는 `error FS0001`
  (`이 식에는 'Async<'a>' 형식이 필요하지만 ... 'unit' 형식이 지정되었습니다`), 손으로 만든 빌더는
  같은 `error FS0001`(`''a option' 형식이 필요하지만`), `FsToolkit.ErrorHandling` 의 `result` 는
  `error FS0041: 'Source' 메서드와 일치하는 오버로드가 없습니다` + `알려진 인수 형식: unit` 이다.
  529-530줄과 537줄의 주석은 메시지 문자열까지 맞다. 543줄이 그 차이를 `Source` 오버로드로 설명하는
  것도 맞다 — 오버로드 목록에 `Source: result: Result<'ok,'error> -> ...` 등 셋이 찍힌다.
  용어집 `do!` 행이 `error FS0001` 만 적고 있으므로 후보 파일에 `[기확정 변경 제안]` 으로 올렸다.
  비고만 고치는 변경이라 앞 챕터 파급은 없다.
- 실행 시점 차이. `async` 는 값을 만드는 시점에 본문이 돌지 않고 `Async.RunSynchronously` 에서 돌며,
  `task` 는 만드는 순간 본문이 돈다. 두 블록의 출력 순서가 그대로 증거이고 주석과 일치한다.
  `--langversion:5.0` 으로 낮추면 `task` 자리에 `error FS3350` 이 나고 6.0 이상을 쓰라고 한다.
  `Async.AwaitTask` 없이 `let! bytes = File.ReadAllBytesAsync(path)` 를 적으면 `error FS0193` 으로
  `Task<byte array>` 가 `Async<'a>` 와 호환되지 않는다고 하므로 293·315줄 서술이 맞다.
- 코어 내장 계산 식이 `seq`·`async`·`task`·`query` 넷이라는 것(86·342·607줄). `query { for x in xs
  do select x }` 가 패키지 없이 도는 것을 확인했다. `task` 가 F# 6 부터라는 단서도 13챕터 388줄의
  서술과 어긋나지 않는다.
- 8챕터와의 관계. 593줄의 `and!` 서술은 8챕터 721·836줄과 낱말 단위로 맞물린다 — `MergeSources`,
  "병렬로 도는 것이 아니라 의존이 없어지는 것", "같은 스레드에서 차례로 평가", 진짜 병렬은
  `parallelAsyncValidation`. `parallelAsyncValidation` 이 5.2.0 에 실제로 있는 것도 확인했다.
  `Validation<'a,'e>` ↔ `Result<'a,'e list>` 와 `asList` 는 12챕터가 건드리지 않아 흔들린 곳이 없다.
  3줄이 인용한 "8챕터 후반에서 중첩이 다섯 겹까지" 도 8챕터 577줄과 맞다.
- 시그니처 주석 전수 대조. 6개 실행 단위를 `dotnet fsi --use:` 로 열어 val 선언을 전부 찍어 비교했고
  어긋난 것이 없다. 빌더 멤버 시그니처(`Bind: x: 'c option * f: ('c -> 'd option) -> 'd option`,
  `Return: x: 'b -> 'b option`, `ReturnFrom: x: 'a -> 'a`)까지 실측값과 같다. `ReturnFrom` 이
  `'a -> 'a` 라는 것이 169줄 주장("아무 일도 하지 않는 것이 옳다")의 근거로 정확하다.
- 기대 출력 전수 대조. 6개 단위의 실제 출력이 주석과 한 글자도 다르지 않다. `%A` 에 폭 지정이 먹지
  않는다는 72줄 주석도 실측과 같고(`%-9A`·`%9A` 둘 다 폭이 무시된다), `%A` 로 찍은 `None` 이
  `None` 인 것도 맞다.
- `id` 배정. `id` 없는 블록 4개(37·140·274·525줄)는 모두 실제로 컴파일되지 않는다. 반대로 컴파일되는
  완전한 코드인데 `id` 가 없는 블록은 없다. 배정에 손볼 곳이 없다.
- 이식성. `#r "nuget: FsToolkit.ErrorHandling, 5.2.0"` 세 곳 모두 버전이 고정돼 있고, 세 실행 단위
  전부 `id` 를 달고 있으며, 각 블록 바로 앞 산문(197·351·494줄)에 선행 요구사항 한 줄이 있다.
  16줄이 챕터 앞머리에 같은 내용을 한 번 더 적어 둔 것까지 용어집 머리말 규칙 세 가지를 지켰다.
- 선행 등재 21항목의 표기를 노트가 모두 따랐다. 어긋난 곳은 `Line of Business (LOB)` 하나이고
  위에 지시했다. 등재되지 않은 채 쓰인 낱말은 후보 파일에 올렸다(상수 패턴·변수 패턴·도우미 함수·
  오버로드·`parallelAsyncValidation`).

## 참고 — 12챕터 밖의 일 (고치지 말고 파이프라인에 넘길 것)

`08-functional-validation.md:664` 가 "`let!` 은 계산 식 빌더의 `Bind` 멤버를, `and!` 는
`MergeSources` 멤버를 부르는데 그 멤버를 직접 만드는 것이 12챕터의 일이다" 라고 예고하는데,
12챕터가 직접 만드는 멤버는 `Bind`·`Return`·`ReturnFrom` 이고 `MergeSources` 는 만들지 않는다.
원서 범위에 `MergeSources` 구현이 없으므로 12챕터를 늘릴 일은 아니다. 8챕터 쪽 문장을
"그 멤버를 직접 만드는 것이 12챕터의 일이다" 에서 "빌더 멤버를 직접 만들어 보는 것이 12챕터의
일이다" 정도로 좁히는 편이 맞다. 12챕터 593줄은 "이 챕터에서 만든 `Bind` 가 아니라 `MergeSources`
멤버를 부른다" 로 적어 두어 오해를 만들지 않는다.
