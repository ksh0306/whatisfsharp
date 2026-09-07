# 06 - 파일에서 데이터 읽기 (원서 pp.80-89)

> 이 챕터에서는 3챕터의 `Result` 와 5챕터의 컬렉션을 합쳐 바깥 세계의 데이터를 프로그램 안으로 들여온다. 소재는 구분자로 나뉜 텍스트 파일 하나지만, 얻어 가야 할 것은 두 가지다. 하나는 지연 평가되는 시퀀스를 `try/with` 로 감싸면 예외를 놓친다는 사실이고, 다른 하나는 데이터 출처를 함수 매개변수로 빼면 파일 없이도 테스트할 수 있다는 설계다. 파싱한 결과를 문자열 그대로 두는 원서의 선택도 의도된 것이며, 실패 이유를 남기는 검증은 8챕터의 몫이다.

시작하기 전에 이 챕터가 계속 쓰는 용어 셋을 정리해 둔다.

- 시퀀스 식(sequence expression)은 `seq { ... }` 안에서 값을 차례로 내놓아 `seq<'T>` 를 만드는 문법이다. `seq<'T>` 는 .NET 의 `IEnumerable<'T>` 와 같은 것이다.
- 지연 평가(lazy evaluation)는 값을 만드는 시점을 실제로 필요할 때까지 미루는 것이다. 시퀀스는 순회할 때 비로소 원소를 만든다.
- 부분 함수(partial function)는 입력 중 일부에서 값을 돌려주지 못하고 예외를 던지는 함수다. 이름이 비슷한 부분 적용(partial application)과는 아무 관계가 없다.

## Setting Up — 예제 데이터를 어디에 둘까 (원서 p.80)

- 원서는 콘솔 프로젝트를 만들고 프로젝트 폴더 아래 `resources` 에 데이터 파일을 둔 뒤, 내장 상수 `__SOURCE_DIRECTORY__` 로 소스 폴더 경로를 얻어 파일 경로를 조립한다.
- `main` 이 마지막에 돌려주는 `0` 은 프로세스 종료 코드다. F# 6 부터는 `[<EntryPoint>]` 를 붙이지 않아도 되고, 마지막 코드 파일의 최상위 코드가 그대로 진입점이 된다.
- 이 노트는 프로젝트 대신 스크립트로 검증하므로 저장소 안에 데이터 파일을 만들지 않는다. 각 실행 단위가 시스템 임시 경로에 자기 입력 파일을 만들고, 끝에서 지운다.
- 소재는 도서관 대출 기록이다. 열은 `LoanId|MemberId|Title|DueDate|Renewed|Fine` 여섯 개이고 구분자는 `|` 다. 마지막 줄은 값이 거의 빈 기록으로, 뒤에서 파싱이 어디까지 버텨 주는지 보는 데 쓴다.

```fsharp
// 원서와 같은 프로젝트 구성이라면 진입점이 이런 모양이 된다. `__SOURCE_DIRECTORY__` 는
// 이 코드가 적힌 파일의 폴더를 가리키므로 실행 폴더가 어디든 같은 파일을 찾는다.
// 여기 쓰인 importFromFile 은 이 노트 마지막 절에서 만든다
[<EntryPoint>]
let main _ =
    Path.Combine(__SOURCE_DIRECTORY__, "resources", "loans.csv")
    |> importFromFile
    0
```

아래부터는 이 노트의 방식이다. 같은 구성을 프로젝트 없이 재현하려고 데이터 파일을 임시 경로에 만든다.

```fsharp id=06-load
// 이 단위가 보여주는 것: 입력 파일을 임시 경로에 만들어 시퀀스로 읽어 들이는 방법
open System
open System.IO

// 저장소를 더럽히지 않는다. 임시 경로에 만들고 이 단위 끝에서 지운다
let loansPath =
    Path.Combine(Path.GetTempPath(), "loans-" + Guid.NewGuid().ToString("N") + ".csv")

let rows =
    [ "LoanId|MemberId|Title|DueDate|Renewed|Fine"
      "L-1001|M-07|자료구조 첫걸음|2024-05-02|1|0.00"
      "L-1002|M-11|정보 검색 개론|2024-05-11|0|1.50"
      "L-1003|M-04|근현대사 강의|2024-04-28|1|3.20"
      "L-1004|||||" ]

File.WriteAllLines(loansPath, rows)
printfn "입력 파일 준비: %b" (File.Exists loansPath)   // 기대: 입력 파일 준비: true
```

## Loading Data — 파일을 문자열 시퀀스로 (원서 pp.80-82)

- 파일을 읽는 함수의 목표 시그니처는 `string -> string seq` 다. 경로를 받아 줄들의 시퀀스를 돌려준다.
- 리스트나 배열로 만들 수도 있지만 `File.ReadLines` 나 `Directory.EnumerateFiles` 처럼 `IEnumerable<'T>` 를 돌려주는 `System.IO` 메서드가 있어 시퀀스가 그대로 맞물린다.
- `StreamReader` 는 `IDisposable` 을 구현한다. `use` 로 바인딩하면 스코프가 끝날 때 `Dispose()` 가 호출된다. C# 의 `using` 문에 대응한다. 여기서 스코프는 들여쓰기가 정한 시퀀스 식 안쪽이고, 시퀀스 순회가 끝나는 시점에 해제된다. 순회를 중간에 끊어도 끊는 자리에서 해제된다. 반대로 한 번도 순회하지 않으면 이 줄 자체가 실행되지 않아 파일이 열리지도 않는데, 그 성질이 다음 절의 함정을 만든다.
- `IDisposable` 타입의 인스턴스를 만들 때는 `new` 를 붙인다. 붙이지 않으면 컴파일러가 경고 FS0760 으로 알려 준다. 원서가 이 인터페이스를 `IDisposable<'T>` 로 적은 것은 오기이며, 실제 `IDisposable` 은 제네릭이 아니다.

```fsharp id=06-load
// string -> string seq
// while ... do 안에서 값을 그대로 두면 시퀀스의 원소가 된다(암시적 yield)
let readWithReader path =
    seq {
        use reader = new StreamReader(File.OpenRead path)
        while not reader.EndOfStream do
            reader.ReadLine()
    }

// Seq.iter : ('a -> unit) -> 'a seq -> unit
readWithReader loansPath |> Seq.iter (printfn "%s")
// 기대:
// LoanId|MemberId|Title|DueDate|Renewed|Fine
// L-1001|M-07|자료구조 첫걸음|2024-05-02|1|0.00
// L-1002|M-11|정보 검색 개론|2024-05-11|0|1.50
// L-1003|M-04|근현대사 강의|2024-04-28|1|3.20
// L-1004|||||
```

`Seq.iter` 는 원소마다 넘겨받은 함수를 실행하고 `unit` 을 돌려준다. `List` 와 `Array` 모듈에 있는 함수는 대부분 같은 이름으로 `Seq` 모듈에도 있다.

직접 `StreamReader` 를 다루지 않아도 되는 지름길이 둘 있다. 시그니처를 F# Interactive(FSI) 로 실측하면 이렇게 갈린다.

```fsharp
File.ReadLines    : string -> string seq     // .NET 원형은 IEnumerable<string> 을 돌려준다
File.ReadAllLines : string -> string array
```

- `File.ReadAllLines` 는 호출한 자리에서 파일 전체를 읽어 배열로 고정한다. 그 뒤 파일이 바뀌어도 손에 든 배열은 바뀌지 않는다.
- `File.ReadLines` 는 시퀀스를 돌려주고 내용 읽기를 미룬다. 다만 파일을 여는 일은 호출 시점에 한다. 순회를 두 번 하면 두 번째 순회부터 파일을 다시 열어 읽는다.
- 큰 파일을 한 번만 훑을 때는 `File.ReadLines` 가 메모리에 유리하다. 여러 번 훑을 값이라면 `List.ofSeq` 나 `Seq.cache` 로 한 번만 읽어 고정하는 편이 낫다.

아래 블록은 지연 쪽을 `File.ReadLines` 대신 앞에서 만든 `readWithReader` 로 대표하게 두었다. 순회할 때까지 파일을 열지 않으므로, 값을 만든 뒤에 같은 파일로 쓰기를 해도 막히지 않는다.

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

덧붙인 줄이 `lazyLines` 쪽에만 보인다. 시퀀스는 순회할 때 비로소 파일을 읽기 때문이다. 값을 만든 순서가 아니라 순회한 순서가 결과를 정한다는 점이 다음 절의 함정으로 이어진다.

```fsharp id=06-load
File.Delete loansPath
printfn "임시 파일 정리: %b" (not (File.Exists loansPath))   // 기대: 임시 파일 정리: true
```

## 읽기 실패를 `Result` 로 옮기기 (원서 pp.82-83)

- 파일 읽기는 실패할 수 있다. 경로가 없거나 권한이 없으면 예외가 날아온다. 3챕터에서 본 대로 `try/with` 로 받아 `Result` 로 돌려주면 시그니처가 실패 가능성을 말해 준다.
- 목표 시그니처는 `string -> Result<string seq, exn>` 다.
- 여기서 원서가 짚는 함정이 나온다. `try` 블록 안에서 시퀀스 식을 만들어 `Ok` 로 감싸면, `try` 가 끝나는 시점에는 파일을 아직 열지 않았다. 예외는 나중에 순회할 때 터지므로 `with` 절이 잡지 못한다.

```fsharp id=06-reader-result
// 이 단위가 보여주는 것: 지연 평가되는 시퀀스를 try/with 로 감쌀 때 생기는 함정과 그 고침
open System
open System.IO

let tempCsv prefix =
    Path.Combine(Path.GetTempPath(), prefix + "-" + Guid.NewGuid().ToString("N") + ".csv")

let rows =
    [ "LoanId|MemberId|Title|DueDate|Renewed|Fine"
      "L-1001|M-07|자료구조 첫걸음|2024-05-02|1|0.00" ]

let loansPath = tempCsv "loans"
File.WriteAllLines(loansPath, rows)

// 경로 문자열만 만들고 파일은 쓰지 않았다. 읽으려 하면 실패한다
let missingPath = tempCsv "missing"
```

준비가 끝났으니 함정이 있는 판을 먼저 만들어 본다.

```fsharp id=06-reader-result
// string -> Result<string seq, exn>
let readLazily path =
    try
        seq {
            use reader = new StreamReader(File.OpenRead path)
            while not reader.EndOfStream do
                reader.ReadLine()
        }
        |> Ok
    with ex -> Error ex

// 예외 메시지에는 실행마다 달라지는 경로가 들어가므로 타입 이름만 찍는다
let label result =
    match result with
    | Ok _ -> "Ok"
    | Error (ex: exn) -> "Error " + ex.GetType().Name

printfn "있는 파일: %s" (label (readLazily loansPath))     // 기대: 있는 파일: Ok
printfn "없는 파일: %s" (label (readLazily missingPath))   // 기대: 없는 파일: Ok
```

없는 파일인데도 `Ok` 다. `Ok` 안에 든 시퀀스는 아직 아무것도 하지 않은 약속일 뿐이고, 예외는 그 약속을 실제로 실행할 때 나온다.

```fsharp id=06-reader-result
match readLazily missingPath with
| Ok data ->
    try
        printfn "줄 수 %d" (Seq.length data)
    with ex ->
        printfn "순회 시점에 터진다: %s" (ex.GetType().Name)
        // 기대: 순회 시점에 터진다: FileNotFoundException
| Error _ -> printfn "여기로는 오지 않는다"
```

고치는 방법은 간단하다. `try` 안에서 하는 일이 즉시 실패를 드러내게 만들면 된다. `File.ReadLines` 는 내용 읽기는 미루지만 경로 검사와 파일 열기는 호출 시점에 하므로, 없는 경로는 그 자리에서 예외가 된다. 대신 호출만 해 놓고 순회하지 않으면 열린 파일 핸들(file handle)이 남으므로, 확인만 하는 자리에서도 시퀀스를 한 번 비워 줘야 한다.

```fsharp id=06-reader-result
// string -> Result<string seq, exn>
let readFile path =
    try
        File.ReadLines path |> Ok
    with ex -> Error ex

// File.ReadLines 는 호출 시점에 파일을 열어 두므로, Ok 안의 시퀀스를 순회하지 않고
// 버리면 열린 파일 핸들이 남는다. 확인만 하는 자리에서도 한 번 순회해 닫아 준다
let labelDrained result =
    match result with
    | Ok (data: string seq) ->
        data |> Seq.iter ignore
        "Ok"
    | Error (ex: exn) -> "Error " + ex.GetType().Name

printfn "있는 파일: %s" (labelDrained (readFile loansPath))     // 기대: 있는 파일: Ok
printfn "없는 파일: %s" (labelDrained (readFile missingPath))   // 기대: 없는 파일: Error FileNotFoundException
```

`Result` 를 돌려주게 되었으니 호출하는 쪽은 두 갈래를 모두 처리해야 한다. 성공이면 데이터를 쓰고, 실패면 이유를 알린다. 이 갈림길을 한 함수로 떼어 두면 호출부가 단순해진다.

```fsharp id=06-reader-result
let show path =
    match readFile path with
    | Ok data -> data |> Seq.iter (printfn "  %s")
    | Error ex -> printfn "  읽기 실패: %s" (ex.GetType().Name)

show loansPath
show missingPath
// 기대:
//   LoanId|MemberId|Title|DueDate|Renewed|Fine
//   L-1001|M-07|자료구조 첫걸음|2024-05-02|1|0.00
//   읽기 실패: FileNotFoundException

File.Delete loansPath
printfn "임시 파일 정리: %b" (not (File.Exists loansPath))   // 기대: 임시 파일 정리: true
```

## Parsing Data — 줄을 레코드로 (원서 pp.83-85)

- 다음 할 일은 줄 하나를 레코드 하나로 바꾸는 것이다. 이 단계에서는 모든 필드를 `string` 으로 둔다. 값의 의미를 따지는 일은 뒤로 미루고, 모양만 맞추는 데 집중한다.
- 타입 선언은 `let` 바인딩보다 위에 모아 두는 것이 관례다. F# 은 위에서 아래로만 이름이 보이므로 순서가 곧 규칙이다.
- 파일에서 읽은 데이터는 순수하지 않은 경계에서 온 값이다. 칸 수가 맞지 않을 수 있으니 파싱 결과는 `RawLoan` 이 아니라 `RawLoan option` 이어야 한다.

```fsharp id=06-parse
// 이 단위가 보여주는 것: 배열 패턴으로 줄을 쪼개 레코드로 바꾸고 실패한 줄을 걸러 내기
type RawLoan =
    { LoanId: string
      MemberId: string
      Title: string
      DueDate: string
      Renewed: string
      Fine: string }

// 마지막 줄은 칸이 셋뿐인 깨진 줄이다
let sample =
    seq {
        "LoanId|MemberId|Title|DueDate|Renewed|Fine"
        "L-1001|M-07|자료구조 첫걸음|2024-05-02|1|0.00"
        "L-1002|M-11|정보 검색 개론|2024-05-11|0|1.50"
        "L-1003|M-04|근현대사 강의|2024-04-28|1|3.20"
        "L-1004|||||"
        "L-1005|M-02|서지학 개론"
    }
```

문자열을 구분자로 쪼개는 것은 .NET 의 `Split` 메서드다. `char` 하나를 넘기는 오버로드는 `string array` 를 돌려준다.

```fsharp
// .NET 메서드 원형(F# 이 보여 주는 표기)
String.Split(separator: char, ?options: StringSplitOptions) : string array
```

돌려받은 배열을 배열 패턴(array pattern)으로 매칭하면 각 칸을 이름에 바로 묶을 수 있다. 이때 패턴에 적은 이름의 개수와 배열 길이가 정확히 같아야 그 케이스가 성립한다. 쓰지 않을 칸은 와일드카드로 둘 수 있다.

```fsharp id=06-parse
// string -> RawLoan option
let parseLine (line: string) : RawLoan option =
    match line.Split('|') with
    | [| loanId; memberId; title; dueDate; renewed; fine |] ->
        Some
            { LoanId = loanId
              MemberId = memberId
              Title = title
              DueDate = dueDate
              Renewed = renewed
              Fine = fine }
    | _ -> None

printfn "%A" (parseLine "L-1005|M-02|서지학 개론")   // 기대: None
printfn "%b" (parseLine "L-1004|||||" |> Option.isSome)   // 기대: true
```

칸 개수만 맞으면 값이 비어 있어도 `Some` 이다. `L-1004` 줄이 통과하는 것은 이 단계가 모양만 본다는 뜻이다. 값이 비었다는 사실을 문제로 삼으려면 판단 기준이 필요하고, 그것이 8챕터의 검증이다.

이제 시퀀스 전체에 적용한다. 첫 줄은 헤더 줄이므로 버려야 한다.

```fsharp id=06-parse
// string seq -> RawLoan seq
// Seq.skip  : int -> 'a seq -> 'a seq
// Seq.choose: ('a -> 'b option) -> 'a seq -> 'b seq
let parse (data: string seq) =
    data
    |> Seq.skip 1          // 헤더 줄 버리기
    |> Seq.map parseLine
    |> Seq.choose id       // None 은 버리고 Some 은 벗긴다

sample
|> parse
|> Seq.iter (fun loan -> printfn "%-7s %-6s %A" loan.LoanId loan.MemberId loan.Title)
// 기대:
// L-1001  M-07   "자료구조 첫걸음"
// L-1002  M-11   "정보 검색 개론"
// L-1003  M-04   "근현대사 강의"
// L-1004         ""

printfn "읽은 줄 %d, 만들어진 레코드 %d" (Seq.length sample) (sample |> parse |> Seq.length)
// 기대: 읽은 줄 6, 만들어진 레코드 4
```

- `Seq.map parseLine` 다음에 오는 `Seq.choose id` 가 `RawLoan option seq` 를 `RawLoan seq` 로 좁힌다. `id` 는 `'a -> 'a` 인 항등 함수이고 `fun x -> x` 와 같다.
- `Seq.map f >> Seq.choose id` 는 `Seq.choose f` 한 번과 결과가 같다. 원서는 두 단계로 보여 주지만 실무에서는 `Seq.choose parseLine` 으로 줄여 쓰는 쪽이 흔하다.
- 여기서 세 컬렉션 타입 표기가 모두 등장했다. 리스트는 `[ ... ]`, 배열은 `[| ... |]`, 시퀀스는 `seq { ... }` 다.
- `Seq.map` 에 넘긴 `parseLine` 처럼, 람다로 감싸지 않고 함수 이름만 적는 것이 관용적이다. `fun x -> parseLine x` 는 같은 뜻의 더 긴 표기다.

`Seq.skip` 에는 함정이 하나 있다. 원소가 모자라면 예외를 던지는 부분 함수다. 헤더 줄만 있고 데이터가 없는 파일은 흔하고, 아예 빈 파일도 있을 수 있다. 예외가 나는 시점은 앞 절과 같은 규칙을 따른다. `Seq.skip 1` 을 부르는 순간이 아니라 그 결과를 처음 순회하는 순간이다. 그래서 아래 `try` 는 순회까지 감싸야 한다.

```fsharp id=06-parse
try
    Seq.empty<string> |> parse |> Seq.length |> printfn "%d"
with ex ->
    printfn "빈 입력: %s" (ex.GetType().Name)   // 기대: 빈 입력: InvalidOperationException
```

원서도 이 문제를 짚어 두지만 챕터 뒤에서 고치겠다고만 적고, 최종 코드에는 `Seq.skip 1` 이 그대로 남아 있다. 지금 고치려면 개수를 세지 말고 위치로 걸러 내면 된다. `Seq.indexed` 로 번호를 붙이고 0번만 버리는 방식은 입력이 비어도 조용히 빈 시퀀스를 돌려준다.

```fsharp id=06-parse
// string seq -> string seq
// Seq.indexed: 'a seq -> (int * 'a) seq
let dropHeader (data: string seq) =
    data
    |> Seq.indexed
    |> Seq.filter (fun (index, _) -> index > 0)
    |> Seq.map snd

let parseSafely (data: string seq) =
    data |> dropHeader |> Seq.choose parseLine

printfn "빈 입력(고친 뒤): %d" (Seq.empty<string> |> parseSafely |> Seq.length)   // 기대: 빈 입력(고친 뒤): 0
printfn "결과는 동일: %b" (List.ofSeq (parse sample) = List.ofSeq (parseSafely sample))   // 기대: 결과는 동일: true
```

마지막 비교가 참인 것은 레코드의 구조적 동등성 덕분이다. 리스트로 굳히면 `=` 한 번으로 전체를 비교할 수 있다.

## 타입 있는 필드로 한 걸음 더 (원서 pp.83-85 확장)

원서는 모든 필드를 `string` 으로 남겨 둔 채 챕터를 마치지만, 실무에서는 날짜와 금액을 알맞은 타입으로 옮겨 담게 된다. 그 자리에서 만나는 것이 .NET 의 `TryParse` 계열이다.

- .NET 의 `TryParse` 가 F# 에서 `bool * 'a` 튜플로 넘어오는 까닭은 3챕터에서 다뤘다. F# 에는 `out` 매개변수를 선언하는 문법이 없어 컴파일러가 그 값을 반환값 쪽으로 옮겨 주기 때문이다. 이 튜플을 패턴 매칭해 `Option` 으로 바꾸는 것이 관용적인 처리다.
- 문화권을 지정하는 오버로드를 쓰는 편이 안전하다. `CultureInfo.InvariantCulture` 로 고정하면 실행 환경의 지역 설정에 따라 소수점이나 날짜 해석이 달라지는 일을 막을 수 있다. 허용할 표기도 함께 지정하는데, 숫자 쪽은 `NumberStyles`, 날짜 쪽은 `DateTimeStyles` 다.

두 표기를 나란히 놓으면 `out` 매개변수가 어디로 옮겨 가는지 보인다.

```fsharp
// .NET 메서드 원형(F# 이 보여 주는 표기)
Decimal.TryParse(s: string, result: byref<decimal>) : bool

// F# 에서 호출하면 out 매개변수가 반환값에 붙는다
Decimal.TryParse : string -> bool * decimal
```

튜플을 매칭하는 `match` 를 `TryParse` 호출마다 되풀이할 이유는 없다. 한 자리에 모아 두고 재사용한다.

```fsharp id=06-typed
// 이 단위가 보여주는 것: TryParse 를 Option 으로 감싸는 어댑터와 타입 있는 레코드 만들기
open System
open System.Globalization

// (string -> bool * 'a) -> string -> 'a option
let tryParseWith (parser: string -> bool * 'a) (text: string) =
    match parser text with
    | true, value -> Some value
    | false, _ -> None
```

`tryParseWith` 는 "성공 여부와 값을 튜플로 돌려주는 함수"를 받아 `Option` 을 돌려주는 함수로 바꿔 준다. `TryParse` 를 쓰는 자리마다 같은 `match` 를 반복하지 않게 하는 어댑터다.

```fsharp id=06-typed
let invariant = CultureInfo.InvariantCulture

// 부분 적용으로 필드별 파서를 만든다
// FSI 실측: val tryDecimal: (string -> decimal option)
let tryDecimal = tryParseWith (fun text -> Decimal.TryParse(text, NumberStyles.Number, invariant))

// FSI 실측: val tryDate: (string -> System.DateTime option)
let tryDate = tryParseWith (fun text -> DateTime.TryParse(text, invariant, DateTimeStyles.None))

// string -> bool option
let tryFlag text =
    match text with
    | "1" -> Some true
    | "0" -> Some false
    | _ -> None

printfn "%A" (tryDecimal "3.20")   // 기대: Some 3.20M
printfn "%A" (tryDecimal "")       // 기대: None
printfn "%A" (tryDate "2024-05-02" |> Option.map (fun date -> date.ToString("yyyy-MM-dd")))
// 기대: Some "2024-05-02"
printfn "%A" (tryFlag "1", tryFlag "예")   // 기대: (Some true, None)
```

`tryDecimal` 과 `tryDate` 의 시그니처가 괄호에 싸여 나오는 것은 이 둘이 함수를 담은 값 바인딩이기 때문이다. FSI 는 매개변수를 적어 정의한 함수 바인딩과 이렇게 구분해 보여 준다.

이제 레코드의 필드 타입을 실제 의미에 맞춘다. 배열 패턴으로 칸을 나눈 뒤, 세 파서의 결과를 튜플로 묶어 한 번에 매칭하면 전부 성공한 경우만 골라낼 수 있다.

```fsharp id=06-typed
type Loan =
    { LoanId: string
      MemberId: string
      Title: string
      DueDate: DateTime
      Renewed: bool
      Fine: decimal }

// string -> Loan option
let parseLine (line: string) : Loan option =
    match line.Split('|') with
    | [| loanId; memberId; title; dueDate; renewed; fine |] ->
        match tryDate dueDate, tryFlag renewed, tryDecimal fine with
        | Some due, Some isRenewed, Some amount ->
            Some
                { LoanId = loanId
                  MemberId = memberId
                  Title = title
                  DueDate = due
                  Renewed = isRenewed
                  Fine = amount }
        | _ -> None
    | _ -> None
```

세 파서가 모두 `Some` 을 내놓은 줄만 `Loan` 이 된다. 앞 절과 같은 입력에 이 `parseLine` 을 걸어 본다.

```fsharp id=06-typed
let sample =
    seq {
        "LoanId|MemberId|Title|DueDate|Renewed|Fine"
        "L-1001|M-07|자료구조 첫걸음|2024-05-02|1|0.00"
        "L-1002|M-11|정보 검색 개론|2024-05-11|0|1.50"
        "L-1003|M-04|근현대사 강의|2024-04-28|1|3.20"
        "L-1004|||||"
        "L-1005|M-02|서지학 개론"
    }

let parse (data: string seq) =
    data
    |> Seq.indexed
    |> Seq.filter (fun (index, _) -> index > 0)
    |> Seq.map snd
    |> Seq.choose parseLine

let loans = parse sample |> List.ofSeq

loans
|> List.iter (fun loan ->
    printfn "%-7s %s %-5b %6.2f" loan.LoanId (loan.DueDate.ToString("yyyy-MM-dd")) loan.Renewed loan.Fine)
// 기대:
// L-1001  2024-05-02 true    0.00
// L-1002  2024-05-11 false   1.50
// L-1003  2024-04-28 true    3.20

printfn "레코드 %d건" (List.length loans)                                  // 기대: 레코드 3건
printfn "연체료 합계 %.2f" (loans |> List.sumBy (fun loan -> loan.Fine))   // 기대: 연체료 합계 4.70
```

필드에 타입이 붙자 `L-1004` 줄이 탈락했다. 날짜와 금액 칸이 비어 있어 파싱에 실패했기 때문이다. 얻은 것은 확실하다. `Loan` 값을 손에 넣은 뒤에는 날짜 계산이나 금액 합계를 별도 검사 없이 할 수 있다.

잃은 것도 있다. `None` 은 어느 칸이 왜 틀렸는지 말해 주지 않는다. 칸 개수가 안 맞은 줄과 날짜가 깨진 줄이 결과에서 구별되지 않는다. 이유를 남기려면 `Option` 이 아니라 `Result` 가 필요하고, 여러 필드의 실패를 모아 보고하는 방법이 8챕터의 주제다.

## Testing the Code — 데이터 출처를 매개변수로 (원서 pp.85-87)

- 지금까지 만든 코드는 잘 동작하지만 테스트하기가 번거롭다. 확인하려면 매번 실제 파일이 있어야 한다.
- 열쇠는 읽기 함수의 시그니처다. `string -> Result<string seq, exn>` 는 "문자열을 주면 줄들을 돌려주거나 실패한다"는 뜻일 뿐, 디스크를 언급하지 않는다. 웹 서비스나 테스트용 가짜(fake) 데이터도 이 시그니처를 만족할 수 있다.
- 그러니 읽기 함수를 `import` 안에서 직접 부르지 말고 매개변수로 받는다. 함수를 매개변수로 받으므로 `import` 는 고차 함수가 된다. 매개변수 이름을 `dataReader` 로 두면 출처가 파일에 한정되지 않는다는 의도가 드러난다.
- 긴 함수 타입을 매개변수 자리에 계속 적으면 읽기에 좋지 않다. 타입 약어(type abbreviation)로 이름을 붙이면 시그니처가 문서 구실을 한다. 새 타입을 만드는 것이 아니라 별명을 붙이는 것이므로, 같은 시그니처의 함수는 무엇이든 그 자리에 들어간다.
- 함수 하나만 있는 인터페이스를 넘기는 것과 쓰임새가 같다. 다만 타입을 새로 정의하거나 클래스를 만들 필요가 없다.

```fsharp id=06-datareader
// 이 단위가 보여주는 것: 타입 약어로 데이터 출처를 추상화하고 가짜 리더로 테스트하기
open System
open System.IO

type RawLoan =
    { LoanId: string
      MemberId: string
      Title: string
      DueDate: string
      Renewed: string
      Fine: string }

// 이 시그니처만 맞으면 파일이든 웹이든 테스트용 가짜 데이터든 상관없다
type DataReader = string -> Result<string seq, exn>
```

파싱은 앞 절의 `parseSafely` 와 같은 방식이고, 출력은 리스트로 한 번 굳혀 놓고 두 번 훑는다.

```fsharp id=06-datareader
let parseLine (line: string) : RawLoan option =
    match line.Split('|') with
    | [| loanId; memberId; title; dueDate; renewed; fine |] ->
        Some
            { LoanId = loanId
              MemberId = memberId
              Title = title
              DueDate = dueDate
              Renewed = renewed
              Fine = fine }
    | _ -> None

let parse (data: string seq) =
    data
    |> Seq.indexed
    |> Seq.filter (fun (index, _) -> index > 0)
    |> Seq.map snd
    |> Seq.choose parseLine

// 시퀀스를 두 번 순회하면 파일을 다시 열어 두 번 읽는다. 리스트로 한 번 굳혀 놓고 쓴다
let report (loans: RawLoan seq) =
    let items = List.ofSeq loans
    items |> List.iter (fun loan -> printfn "  %-7s %-6s %A" loan.LoanId loan.MemberId loan.Title)
    printfn "  총 %d건" (List.length items)
```

`import` 는 리더를 받아 결과의 두 갈래를 처리한다. 첫 매개변수의 타입만 약어로 적어 두면 무엇을 넘겨야 하는지 시그니처가 말해 준다.

```fsharp id=06-datareader
// DataReader -> string -> unit
let import (dataReader: DataReader) path =
    match path |> dataReader with
    | Ok data -> data |> parse |> report
    | Error ex -> printfn "  가져오기 실패: %s" (ex.GetType().Name)
```

타입 약어를 반환 타입 자리가 아니라 바인딩 전체의 타입으로 쓰려면 함수 스타일을 바꿔야 한다. 매개변수를 이름 옆에 적는 대신 람다를 값으로 바인딩한다. 두 표기가 만드는 함수는 같다.

```fsharp id=06-datareader
// FSI 실측: val readFile: path: string -> Result<string seq,exn>
// 타입 약어는 새 타입이 아니라 별명이므로 펼친 시그니처와 같은 것이다
let readFile: DataReader =
    fun path ->
        try
            File.ReadLines path |> Ok
        with ex ->
            Error ex

// 테스트용 리더. 경로를 받고도 무시한다
let fakeReader: DataReader =
    fun _ ->
        seq {
            "LoanId|MemberId|Title|DueDate|Renewed|Fine"
            "L-2001|M-31|필사본 연구|2024-07-03|0|0.00"
            "L-2002|M-08|서양 서지학|2024-07-19|1|2.40"
        }
        |> Ok

printfn "가짜 리더:"
import fakeReader "(이 경로는 쓰이지 않는다)"
// 기대:
// 가짜 리더:
//   L-2001  M-31   "필사본 연구"
//   L-2002  M-08   "서양 서지학"
//   총 2건
```

파일에서 읽는 조합을 자주 쓴다면 부분 적용으로 이름을 붙여 둔다. 인자 하나만 적용한 새 함수가 되고, 남은 매개변수는 경로 하나다.

```fsharp id=06-datareader
// FSI 실측: val importFromFile: (string -> unit)
let importFromFile = import readFile

let loansPath =
    Path.Combine(Path.GetTempPath(), "loans-" + Guid.NewGuid().ToString("N") + ".csv")

File.WriteAllLines(
    loansPath,
    [ "LoanId|MemberId|Title|DueDate|Renewed|Fine"
      "L-3001|M-19|도서관 경영론|2024-08-02|1|0.00"
      "L-3002|M-19|장서 개발|2024-08-02|0|0.75" ]
)

printfn "파일 리더:"
importFromFile loansPath
// 기대:
// 파일 리더:
//   L-3001  M-19   "도서관 경영론"
//   L-3002  M-19   "장서 개발"
//   총 2건

printfn "없는 파일:"
importFromFile (Path.Combine(Path.GetTempPath(), "loans-" + Guid.NewGuid().ToString("N") + ".csv"))
// 기대:
// 없는 파일:
//   가져오기 실패: FileNotFoundException

File.Delete loansPath
printfn "임시 파일 정리: %b" (not (File.Exists loansPath))   // 기대: 임시 파일 정리: true
```

같은 `import` 가 세 상황을 모두 받아냈다. 파일도, 가짜 데이터도, 실패도 호출부를 고치지 않고 통과한다. 단위 테스트에서는 `fakeReader` 같은 함수를 넘기고 결과를 어서션으로 확인하면 된다. 이때 파일 시스템은 등장하지 않는다. 4챕터에서 본 "테스트하기 쉬운 코드는 대상이 순수한 코드"라는 기준을 파일 입출력이 섞인 코드에 적용한 것이 이 절이다.

## Final Code — 최종 형태 (원서 pp.87-89)

- 원서는 마지막에 코드 전체를 한 파일로 모아 보여 준다. 위 `06-datareader` 단위가 그 형태에 대응한다.
- 파일 안의 순서에 규칙이 있다. 타입 선언(레코드, 타입 약어)이 먼저, 그다음이 리더, 파싱, 출력, 마지막이 이들을 엮는 `import` 다. F# 은 위에서 아래로만 이름이 보이므로 의존 방향이 그대로 순서가 된다.
- 원서의 최종 코드는 파일 시스템을 건드리는 함수가 `readFile` 하나뿐이다. 나머지는 모두 순수 함수이므로 입력만 주면 테스트할 수 있다. 경계를 한 지점으로 몰아 두는 것이 이 챕터의 설계 요점이다.

## Summary — 원서의 챕터 요약 (원서 p.89)

- 원서는 이 챕터에서 `Seq` 모듈의 자주 쓰는 함수와 시퀀스 식, 그리고 함수 타입을 써서 외부 데이터를 가져오는 방법을 다뤘다.
- 원서는 고차 함수 덕분에 실행 시점에 다른 함수를 끼워 넣을 수 있고 테스트도 쉬워진다는 점을 강조한다.
- 다음 챕터에서는 패턴 매칭을 더 읽기 좋게 만드는 액티브 패턴을 살펴본다.

## 정리 — 이 노트의 요약

- 파일 읽기 함수의 목표 시그니처는 `string -> Result<string seq, exn>` 다. 경로를 받아 줄들을 돌려주거나 실패를 값으로 알린다.
- 시퀀스는 지연 평가된다. `try/with` 안에서 시퀀스를 만들어 `Ok` 로 감싸면 예외는 순회 시점에 터지므로 `with` 절이 잡지 못한다. `try` 블록 안의 일이 즉시 실패를 드러내야 `Result` 가 정직해진다.
- `File.ReadAllLines` 는 그 자리에서 배열로 고정하고, `File.ReadLines` 는 내용 읽기를 미루되 경로 검사와 파일 열기는 호출 시점에 한다. 여러 번 순회할 값이라면 `List.ofSeq` 로 굳혀 두는 편이 낫다.
- `use` 는 스코프가 끝날 때 `Dispose()` 를 부른다. 시퀀스 식 안에서는 순회가 끝나거나 끊기는 시점이 그 지점이며, `IDisposable` 인스턴스는 `new` 로 만든다.
- `Split` 이 돌려준 배열을 배열 패턴으로 매칭하면 칸을 이름에 바로 묶을 수 있다. 개수가 다르면 그 케이스는 성립하지 않으므로 `_ -> None` 이 깨진 줄을 받아낸다.
- `Seq.choose` 는 `None` 을 버리고 `Some` 을 벗긴다. `Seq.map f >> Seq.choose id` 는 `Seq.choose f` 와 같다.
- `Seq.skip` 은 부분 함수다. 원소가 모자라면 첫 순회에서 `InvalidOperationException` 이 나므로, 빈 입력이 있을 수 있는 자리에서는 `Seq.indexed` 와 `Seq.filter` 처럼 개수를 요구하지 않는 방법을 쓴다.
- .NET 의 `TryParse` 는 F# 에서 `bool * 'a` 튜플로 넘어온다. 튜플을 매칭해 `Option` 으로 바꾸는 어댑터 함수 하나(`(string -> bool * 'a) -> string -> 'a option`)를 두면 필드별 파서를 부분 적용으로 찍어 낼 수 있다.
- 파싱 결과를 `Option` 으로 두면 실패 이유가 사라진다. 어느 칸이 왜 틀렸는지 알려야 한다면 `Result` 로 옮겨야 하며, 그 작업이 8챕터다.
- 데이터 출처를 매개변수로 받으면 `import` 가 고차 함수가 되어, 실제 파일 없이도 테스트할 수 있다. 긴 함수 타입에는 타입 약어로 이름을 붙인다. 약어는 별명이므로 시그니처가 같은 함수는 무엇이든 들어간다.
- 파일 시스템에 닿는 함수를 하나로 몰아 두면 나머지는 순수 함수로 남는다. 이 경계 설계가 이 챕터의 결론이다.

### 원서 대조 표

| 절 | 원서 페이지 | 실행 단위 |
|---|---|---|
| Setting Up — 예제 데이터를 어디에 둘까 | p.80 | `06-load` |
| Loading Data — 파일을 문자열 시퀀스로 | pp.80-82 | `06-load` |
| 읽기 실패를 `Result` 로 옮기기 | pp.82-83 | `06-reader-result` |
| Parsing Data — 줄을 레코드로 | pp.83-85 | `06-parse` |
| 타입 있는 필드로 한 걸음 더 | pp.83-85 확장 | `06-typed` |
| Testing the Code — 데이터 출처를 매개변수로 | pp.85-87 | `06-datareader` |
| Final Code — 최종 형태 | pp.87-89 | `06-datareader` |
| Summary — 원서의 챕터 요약 | p.89 | — |
