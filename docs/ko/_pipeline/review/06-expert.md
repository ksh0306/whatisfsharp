# 06챕터 F# 전문가 검수 보고서

대상: `docs/ko/06-reading-data-from-file.md` (603줄, 실행 단위 5개)
원문: `.cache/src/06-reading-data-from-file.txt` (원서 pp.80-89)

검증 상태: `KEEP=1 docs/ko/_pipeline/verify-examples.sh docs/ko/06-reading-data-from-file.md`
→ `06-datareader` `06-load` `06-parse` `06-reader-result` `06-typed` 전부 PASS, 경고 0.
기대 출력 주석은 5개 단위 모두 실제 출력과 일치했다. 아래 지적은 전부 FSI 로 실측했고,
제시한 교체 코드는 직접 실행해 출력이 유지되고 경고가 나지 않는 것까지 확인했다.

## 수정 필요 (기술 오류)

### 1. [06-reading-data-from-file.md:585] `Seq.map f |> Seq.choose id` 는 컴파일되지 않는다

`Seq.map f` 는 `'a seq -> 'b option seq` 인 함수 값이고 `Seq.choose id` 는 `'b option seq` 를
받으므로 파이프가 맞물리지 않는다. 실측하면 이렇게 난다.

```
error FS0001: ''b -> string option seq' 형식이 ''a seq' 형식과 호환되지 않습니다
```

같은 문서 282줄은 `Seq.map f >> Seq.choose id` 로 옳게 적혀 있으므로 챕터 내 자기모순이기도 하다.
`|>` 와 `>>` 를 혼동한 자리다. 585줄을 이 줄로 교체하라.

```
- `Seq.choose` 는 `None` 을 버리고 `Some` 을 벗긴다. `Seq.map f >> Seq.choose id` 는 `Seq.choose f` 와 같다.
```

`Seq.map f >> Seq.choose id` 와 `Seq.choose f` 가 같은 결과를 내는 것은 실행해 확인했다.

### 2. [06-reading-data-from-file.md:203] 타입 이름이 틀렸다

이 절의 레코드는 `RawLoan` 이고 `Loan` 은 다음 절(확장)에서 처음 나오는 다른 타입이다.
지금 문장은 아직 존재하지 않는 타입을 가리킨다. 203줄을 이 줄로 교체하라.

```
- 파일에서 읽은 데이터는 순수하지 않은 경계에서 온 값이다. 줄 수가 맞지 않을 수 있으니 파싱 결과는 `RawLoan` 이 아니라 `RawLoan option` 이어야 한다.
```

### 3. [06-reading-data-from-file.md:286, 586] `Seq.skip` 이 예외를 던지는 시점 서술이 부정확하다

`Seq.skip` 은 지연이므로 호출만으로는 예외가 나지 않는다. 실측하면
`Seq.empty<string> |> Seq.skip 1` 도 `... |> Seq.skip 1 |> Seq.map id` 도 아무 일 없이 값을 만들고,
`InvalidOperationException` 은 결과 시퀀스를 처음 순회할 때 난다. 즉 289-292줄 예제에서 터지는
자리는 `parse` 안의 `Seq.skip 1` 이 아니라 `Seq.length` 다.

이 챕터의 주제가 바로 "지연 평가가 예외를 순회 시점으로 미룬다"인데 같은 원리가 `Seq.skip` 에도
그대로 적용된다는 사실을 노트가 짚지 않고 지나간다. 예제가 `try` 로 `Seq.length` 까지 감싼 것은
옳은 처리인데, 왜 그래야 하는지 설명이 없으니 독자가 `try` 의 범위를 잘못 배울 수 있다.

286줄을 이 문단으로 교체하라.

```
`Seq.skip` 에는 함정이 하나 있다. 원소가 모자라면 예외를 던지는 부분 함수다. 헤더만 있고 데이터가 없는 파일은 흔하고, 아예 빈 파일도 있을 수 있다. 예외가 나는 시점은 앞 절과 같은 규칙을 따른다. `Seq.skip 1` 을 부르는 순간이 아니라 그 결과를 처음 순회하는 순간이다. 그래서 아래 `try` 는 순회까지 감싸야 한다.
```

586줄을 이 줄로 교체하라.

```
- `Seq.skip` 은 부분 함수다. 원소가 모자라면 첫 순회에서 `InvalidOperationException` 이 나므로, 빈 입력이 있을 수 있는 자리에서는 `Seq.indexed` 와 `Seq.filter` 처럼 개수를 요구하지 않는 방법을 쓴다.
```

참고로 `List.skip`/`Array.skip` 은 즉시 평가라 호출 자리에서 터지고 예외도 다르다
(실측: `List.skip 1 []` → `ArgumentOutOfRangeException`). 노트는 `Seq` 만 말하므로 본문에
덧붙일 필요는 없다.

### 4. [06-reading-data-from-file.md:52] `System.IO` 가 대개 `IEnumerable<'T>` 를 내놓는다는 서술은 사실과 다르다

원서 p.81 의 "most of the System.IO methods output IEnumerable<'T>" 를 그대로 따라간 자리다.
`File.ReadAllLines` 는 `string array`, `File.ReadAllText` 는 `string`, `Directory.GetFiles` 는
`string array` 를 돌려준다. `IEnumerable<'T>` 를 돌려주는 것은 `File.ReadLines` 와
`Directory.Enumerate*` 계열이다. 52줄을 이 줄로 교체하라.

```
- 리스트나 배열로 만들 수도 있지만 `File.ReadLines` 나 `Directory.EnumerateFiles` 처럼 `IEnumerable<'T>` 를 돌려주는 `System.IO` 메서드가 있어 시퀀스가 그대로 맞물린다.
```

### 5. [06-reading-data-from-file.md:86, 89-98, 100] `06-load` 가 열린 읽기 핸들을 쥔 채 같은 파일에 덧붙인다

`File.ReadLines` 는 호출 시점에 `StreamReader` 를 만들므로 90줄에서 파일이 열린다.
`/proc/self/fd` 로 세어 보면 94줄 `File.AppendAllLines` 직전에 `loansPath` 로 열린 핸들이 1개다.
리눅스에서는 통과하지만 `StreamReader` 가 잡는 공유 모드가 `FileShare.Read` 라서 Windows 에서는
이 append 가 `IOException` 이 된다. `use` 와 결정적 정리를 가르치는 챕터의 예제가 핸들을
쥐고 있는 것 자체도 문제다.

같은 이유로 86줄("순회할 때마다 파일을 다시 읽으므로")과 100줄("순회 시점에 파일을 읽기 때문이다")은
첫 순회에 대해서는 정확하지 않다. 첫 순회는 호출 시점에 열린 스트림을 이어 읽고, 파일을 다시 여는
것은 두 번째 순회부터다(실측: 한 번 소진한 뒤 append 하고 다시 `Seq.length` 하면 늘어난 줄까지 보인다).

89-98줄 블록을 이렇게 교체하라. 같은 단위에 이미 정의된 `readWithReader` 는 순회할 때까지 파일을
열지 않으므로 핸들을 쥐지 않고, 지연 대 즉시의 대비는 그대로 남는다.
실행 확인: append 직전 열린 핸들 0개, 정리 직전 0개, 6 대 5 결과 유지, 경고 0.

````
```fsharp id=06-load
// ReadAllLines 는 이 줄에서 파일을 다 읽고 닫는다
let eagerLines = File.ReadAllLines loansPath    // string array

// readWithReader 가 돌려준 시퀀스는 아직 파일을 열지도 않았다
let lazyLines = readWithReader loansPath        // string seq

// 두 값을 만든 뒤에 파일에 한 줄을 덧붙인다
File.AppendAllLines(loansPath, [ "L-1005|M-02|서지학 개론|2024-06-01|0|0.00" ])

printfn "지연 시퀀스 : %d" (Seq.length lazyLines)      // 기대: 지연 시퀀스 : 6
printfn "즉시 배열   : %d" (Array.length eagerLines)   // 기대: 즉시 배열   : 5
```
````

이 교체에 맞춰 86줄과 100줄도 손봐라.

```
- `File.ReadLines` 는 시퀀스를 돌려주고 내용 읽기를 미룬다. 다만 파일을 여는 일은 호출 시점에 한다. 순회를 두 번 하면 두 번째부터는 파일을 다시 열어 다시 읽는다.
```

```
덧붙인 줄이 `lazyLines` 쪽에만 보인다. 시퀀스는 순회할 때 비로소 파일을 읽기 때문이다. 값을 만든 순서가 아니라 순회한 순서가 결과를 정한다는 점이 다음 절의 함정으로 이어진다.
```

### 6. [06-reading-data-from-file.md:169-178] `06-reader-result` 가 파일 핸들을 새고 있다

176줄 `label (readFile loansPath)` 는 `Ok` 안의 시퀀스를 순회하지 않고 버린다. `File.ReadLines` 는
호출 시점에 파일을 열므로 그 핸들이 정리되지 않는다. 실측: 단위 끝 `File.Delete loansPath` 직전에
`loansPath` 로 열린 핸들이 1개 남아 있다. 리눅스라 삭제가 성공하고 그래서 검증이 통과하지만,
Windows 에서는 `File.Delete` 가 `IOException` 이 될 수 있다.

169-178줄 블록을 이렇게 교체하라. 출력은 그대로이고, 오히려 "`File.ReadLines` 는 호출 시점에
파일을 연다"는 이 절의 요점을 코드로 한 번 더 못 박는다. `label` 은 `readLazily` 쪽에서 계속
쓰이므로 남겨 둔다. 그쪽 시퀀스를 순회하면 예외가 나서 예제가 망가진다.
실행 확인: 출력 동일, 정리 직전 열린 핸들 0개, 경고 0.

````
```fsharp id=06-reader-result
// string -> Result<string seq, exn>
let readFile path =
    try
        File.ReadLines path |> Ok
    with ex -> Error ex

// File.ReadLines 는 호출 시점에 파일을 열어 두므로, Ok 안의 시퀀스를 순회하지 않고
// 버리면 열린 핸들이 남는다. 확인만 하는 자리에서도 한 번 순회해 닫아 준다
let labelDrained result =
    match result with
    | Ok (data: string seq) ->
        data |> Seq.iter ignore
        "Ok"
    | Error (ex: exn) -> "Error " + ex.GetType().Name

printfn "있는 파일: %s" (labelDrained (readFile loansPath))     // 기대: 있는 파일: Ok
printfn "없는 파일: %s" (labelDrained (readFile missingPath))   // 기대: 없는 파일: Error FileNotFoundException
```
````

## 개선 권장

### [06-reading-data-from-file.md:5] "새로 나오는 용어"가 아니다

지연 평가와 부분 함수는 5챕터가 이미 쓴다(05-collections.md:14, 263). 용어집 규칙상 챕터마다
1회 병기는 허용되지만 "새로 나오는"이라는 서술은 틀렸다.

```
시작하기 전에 이 챕터가 계속 쓰는 용어 셋을 정리해 둔다.
```

### [06-reading-data-from-file.md:315-436] 확장 절 분량 조정

"타입 있는 필드로 한 걸음 더"는 122줄이고 정리 절을 뺀 본문 577줄의 21%다. 원서에 없는 절임을
제목과 대조 표에 표시한 처리는 적절하고 내용도 틀린 데가 없다. 다만 319-320줄 두 불릿과
323-331줄 `byref` 시그니처 블록은 3챕터가 이미 다룬 내용이다. 3챕터는 `out` 매개변수가 반환값
튜플로 옮겨진다는 설명과 `DateTime.TryParse(text, CultureInfo.InvariantCulture, DateTimeStyles.None)`
예제까지 갖고 있다(03-null-and-exceptions.md:24, 31-37). 여기서 처음부터 다시 설명할 필요가 없다.

319-320줄을 이 한 불릿으로 줄여라.

```
- .NET 의 `TryParse` 가 F# 에서 `bool * 'a` 튜플로 넘어오는 까닭은 3챕터에서 봤다. `out` 매개변수를 선언하는 문법이 없어 컴파일러가 반환값 쪽으로 옮겨 주기 때문이다. 이 튜플을 패턴 매칭해 `Option` 으로 바꾸는 것이 관용적인 처리다.
```

323-331줄 블록은 F# 이 보여 주는 표기를 확인하는 값이 있으니 남길 만하다. 더 줄이려면
`Double.TryParse` 두 줄만 지워도 뜻이 유지된다.

남겨야 할 새 내용은 네 가지다. `tryParseWith` 어댑터, 부분 적용으로 필드별 파서를 찍어 내는 것,
세 `Option` 을 튜플로 한 번에 매칭하는 것, `Option` 이 실패 이유를 잃는다는 대비. 이 넷은 다 유지하라.

### [06-reading-data-from-file.md:55] `use` 스코프 설명 보강

실측으로 두 가지가 확인됐다. `Seq.truncate 1` 로 순회를 중간에 끊어도 열거자가 정리될 때
`Dispose()` 가 불린다(열린 핸들 0개). 반대로 아예 순회하지 않으면 `use` 줄 자체가 실행되지 않아
파일이 열리지도 않는다. 뒤쪽이 다음 절 함정의 뿌리이므로 여기서 한 문장 깔아 두면 좋다.
55줄 끝에 이어 붙여라.

```
순회를 중간에 끊어도 열거자가 정리되는 시점에 불린다. 반대로 한 번도 순회하지 않으면 이 줄 자체가 실행되지 않아 파일이 열리지도 않는데, 그 성질이 다음 절의 함정을 만든다.
```

### [06-reading-data-from-file.md:321, 352] `NumberStyles` 설명이 없다

352줄이 `Decimal.TryParse(text, NumberStyles.Number, invariant)` 를 쓰는데 321줄 불릿은 문화권만
말한다. 왜 인자가 셋으로 늘었는지 알기 어렵다. 321줄 끝에 한 마디 붙여라.

```
숫자 쪽은 허용할 표기를 `NumberStyles` 로 함께 지정한다.
```

### [06-reading-data-from-file.md:512, 522, 564] 식별자와 본문 표기가 어긋난다

식별자는 `stubReader` 인데 본문과 출력 문자열은 "가짜 리더"·"테스트용 가짜 데이터"다
(446, 458, 521, 524, 564줄). 원서도 `fakeDataReader` 로 fake 를 쓰므로 용어 후보 파일에서
`fake`→가짜로 정했다. 본문이 아니라 식별자를 고치는 쪽이 변경이 작다.

- 512줄 `let stubReader: DataReader =` → `let fakeReader: DataReader =`
- 522줄 `import stubReader "(이 경로는 쓰이지 않는다)"` → `import fakeReader "(이 경로는 쓰이지 않는다)"`
- 564줄 본문의 `stubReader` → `fakeReader`

`printfn "가짜 리더:"` 와 기대 출력 주석은 그대로 두면 된다.

### [06-reading-data-from-file.md:49, 597] 원서 대조 표의 페이지 범위가 겹친다

Loading Data 가 pp.80-83 인데 pp.82-83 은 바로 다음 줄 "읽기 실패를 `Result` 로 옮기기" 몫이다.
597줄과 49줄 절 제목을 pp.80-82 로 좁혀라.

## 확인 완료

- 이 챕터의 핵심 인과가 정확하다. `try { seq { use reader ... } } |> Ok` 는 `try` 가 끝나는 시점에
  파일을 열지 않았으므로 없는 경로에도 `Ok` 를 돌려주고, 예외는 순회할 때 `FileNotFoundException`
  으로 터진다. 실측 재확인했다. `label (readLazily missingPath)` → `Ok`, 이어지는 `Seq.length` 에서
  `FileNotFoundException`. 156-165줄 예제가 `Ok data` 갈래 안에 `try` 를 다시 둬서 "여기서 터진다"를
  눈에 보이게 만든 구성이 좋다. 154줄의 "아직 아무것도 하지 않은 약속"이라는 설명도 정확하다.
- `File.ReadLines` 로 바꾸면 호출 자리에서 `Error FileNotFoundException` 이 된다. 실측 재확인.
  167줄이 그 까닭을 "내용 읽기는 미루지만 경로 검사와 파일 열기는 호출 시점에 하므로"로 적은 것은
  원서가 "it is very easy to fix"(p.83)로만 넘어간 자리를 정확히 보충한 것이다. `File.ReadLines` 가
  호출 시점에 `StreamReader` 를 만든다는 사실을 열린 파일 서술자를 세어 직접 확인했다.
- 지연 대 즉시의 실측(6줄 대 5줄)이 재현된다. 수정 필요 5번의 핸들 문제와 첫 순회 정밀함만
  손보면 이 절의 논지는 그대로 살아 있다.
- 원서 p.81 의 `IDisposable<'T>` 가 오기라는 노트의 지적(56줄)이 옳다. `System.IDisposable` 은
  제네릭이 아니다. `new` 를 빼면 나는 경고와 번호도 실측 일치했다.
  `warning FS0760: IDisposable 인터페이스를 지원하는 개체는 ... 'new Type(args)' 구문을 사용하여 만드는 것이 좋습니다`
- 원서가 `Seq.skip` 의 부분 함수 문제를 "We will fix this later in the chapter"(p.84)라고 적고도
  최종 코드(p.88)에 `Seq.skip 1` 을 그대로 남긴다는 노트의 지적(295줄)이 원문과 일치한다.
  `Seq.indexed` + `Seq.filter` + `Seq.map snd` 대안은 개수를 요구하지 않으므로 옳은 고침이다.
  `parse` 와 `parseSafely` 의 결과가 같다는 것을 리스트로 굳혀 `=` 로 비교한 것도 레코드의
  구조적 동등성을 정확히 쓴 처리다. 빈 입력 예외 타입 `InvalidOperationException` 재확인.
  시점 서술만 위 3번대로 고치면 된다.
- 원서가 `id` 를 "id keyword"라고 부르지만 `id` 는 키워드가 아니라 `FSharp.Core.Operators.id`
  함수다. 노트가 281줄에서 "`'a -> 'a` 인 항등 함수"로 옳게 적었다.
- 시그니처 주석 전부 FSI 실측과 일치했다.
  `readWithReader: path: string -> string seq`,
  `File.ReadLines: string -> string seq`, `File.ReadAllLines: string -> string array`,
  `Seq.iter: ('a -> unit) -> 'a seq -> unit`, `Seq.skip: int -> 'a seq -> 'a seq`,
  `Seq.choose: ('a -> 'b option) -> 'a seq -> 'b seq`, `Seq.indexed: 'a seq -> (int * 'a) seq`,
  `dropHeader: data: string seq -> string seq`,
  `tryParseWith: parser: (string -> bool * 'a) -> text: string -> 'a option`,
  `tryDecimal: (string -> decimal option)`, `tryDate: (string -> System.DateTime option)`,
  `readFile: path: string -> Result<string seq,exn>`,
  `import: dataReader: DataReader -> path: string -> unit`, `importFromFile: (string -> unit)`.
- .NET 메서드 원형 표기 두 블록도 F# 컴파일러가 실제로 보여 주는 문자열과 일치했다.
  오버로드 후보 목록을 강제로 띄워 확인했다.
  `System.String.Split(separator: char, ?options: System.StringSplitOptions) : string array`,
  `System.Decimal.TryParse(s: string, result: byref<decimal>) : bool`,
  `System.Double.TryParse(s: string, result: byref<float>) : bool`.
  네임스페이스만 생략한 노트 표기는 그대로 두면 된다.
- `Decimal.TryParse` 가 F# 에서 `string -> bool * decimal`, `Double.TryParse` 가
  `string -> bool * float` 가 되는 것 실측 확인. `out` 매개변수가 반환값 튜플로 옮겨진다는 설명이 옳다.
- `tryParseWith` 의 제네릭 처리가 옳다. `parser` 에 타입 주석을 달아 `'a` 가 자동 일반화되게 두었고
  값 제한에 걸리지 않는다. `tryDecimal`/`tryDate` 는 인자 하나만 적용한 부분 적용이라 값 바인딩이
  되고 FSI 가 시그니처를 괄호로 감싸 보여 준다. 371줄 설명이 정확하고 용어집의 `value binding`,
  `partial application` 항목 서술과도 맞물린다.
- 타입 약어 관련 설명이 실측과 맞는다. FSI 는 `import` 의 매개변수는 `DataReader` 로 보여 주고
  `readFile` 은 펼친 `path: string -> Result<string seq,exn>` 로 보여 준다. 노트가 두 자리에 적은
  주석이 각각 그대로다. "약어는 새 타입이 아니라 별명"이라는 서술도 옳다.
- `id` 배정이 옳다. `id` 없는 블록은 넷이고 모두 실행할 수 없거나 실행할 필요가 없는 조각이다.
  `[<EntryPoint>]` 블록(18-27줄, 아직 정의되지 않은 `importFromFile` 을 쓰고 `open` 도 없다),
  `File.ReadLines`/`ReadAllLines` 시그니처 조각, `String.Split` 원형, `TryParse` 원형.
  누락된 실행 가능 블록은 없고, `id` 가 붙었는데 컴파일되지 않는 블록도 없다.
  오류 코드를 주석에 적은 블록은 없다(FS0760 은 본문 서술이고 그 번호가 맞다).
- 임시 파일 처리의 반복 실행 안전성은 확보돼 있다. `Path.GetTempPath()` +
  `Guid.NewGuid().ToString("N")` 이므로 이름 충돌이 없고 저장소 안에 파일을 만드는 경로도 없다.
  `__SOURCE_DIRECTORY__` 는 실행되지 않는 블록에만 나온다. 중간에 예외가 나면 `File.Delete` 를
  건너뛰어 파일이 남지만, 남는 위치가 OS 임시 경로이고 이름이 유일하므로 `try/finally` 로
  감쌀 필요는 없다고 본다. 단위마다 정리 성공을 `File.Exists` 로 찍어 확인하는 처리도 적절하다.
  손봐야 할 것은 파일 자체가 아니라 위에 적은 열린 핸들 두 곳이다.
- 14줄(F# 6 부터 `[<EntryPoint>]` 없이 마지막 코드 파일의 최상위 코드가 진입점), 7줄(`seq<'T>` 는
  `IEnumerable<'T>` 와 같다), 87줄(`List.ofSeq`/`Seq.cache` 로 고정), 282줄
  (`Seq.map f >> Seq.choose id` = `Seq.choose f`) 모두 옳다.
- 마지막 절의 설계 논지가 정확하다. `readFile` 하나만 파일 시스템에 닿고 나머지는 순수 함수라는 점,
  `DataReader` 시그니처가 디스크를 언급하지 않으므로 가짜 리더도 웹 서비스도 같은 자리에
  들어간다는 점, 가짜 리더·파일 리더·없는 파일 세 경우가 호출부 변경 없이 통과한다는 점이
  전부 실행으로 확인된다.

## 용어 후보

`.cache/review/06-glossary.md` 에 19항목. 영어 알파벳 순, 중복 없음. `[기확정 변경 제안]` 은 없다.
판단을 요청받은 셋은 이렇게 확정했다.

- `sequence expression` → 시퀀스 식. 기확정 `expression`→식, `computation expression`→계산 식 과 계열을 맞춘다.
- `lazy evaluation` → 지연 평가. 5챕터 노트가 이미 쓰고 있어 뒤집지 않는다.
- `partial function` → 부분 함수. 5챕터 노트가 같은 표기를 쓰고 정의도 일치한다. 근거를 후보 파일 하단에 남겼다.
