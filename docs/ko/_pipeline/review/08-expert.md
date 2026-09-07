# 08챕터 전문가 검수 보고서 (기술 정확성)

검수 대상: `docs/ko/08-functional-validation.md` (852줄, 실행 단위 6개)
실측 환경: F# Interactive 14.0.111.0 (F# 10.0), .NET SDK 10.0.111, `FsToolkit.ErrorHandling` 5.2.0
실행 결과: `verify-examples.sh` 6개 단위 전부 PASS, `check-note.sh` OK.
아래 항목은 전부 FSI 로 직접 돌려 확인한 것이다. 실측값을 함께 적었다.

## 수정 필요 (기술 오류)

### 1. [08-functional-validation.md:11] 도입부의 도메인 규칙이 코드와 어긋난다
"뒤의 세 칸도 비어 있는 것은 허용한다"고 적었으나 `Chilled` 는 빈 값을 허용하지 않는다.
실측:

```
validateChilled ""  -> Error (BadFormat ("Chilled", ""))
validateChilled " " -> Error (BadFormat ("Chilled", " "))
validateCollectedOn "" -> Ok None
validateVolume ""      -> Ok None
```

`(|Flag|_|)` 가 `Y`/`YES`/`N`/`NO` 만 받고 그 밖은 `None` 이므로 빈 칸도 `BadFormat` 이 된다.
`ValidatedSample.Chilled` 가 `bool option` 이 아니라 `bool` 인 것도 필수 칸이라는 뜻이며,
노트 자신이 105~112줄에서 "없어도 되는 칸은 `Option` 이다"라고 규칙을 세워 두었다.
문장 뒷부분을 이렇게 고쳐라.

```
`Chilled` 는 참거짓이고 반드시 `Y` 나 `N` 중 하나여야 하고, `CollectedOn` 은 날짜, `VolumeMl` 은 수량이며 이 두 칸은 비어 있는 것을 허용한다.
```

### 2. [08-functional-validation.md:56] "마지막 세 줄"이 뒤에 드는 행 번호와 맞지 않는다
문제가 있는 줄은 3·4·6행이고, 마지막 세 줄은 4·5·6행이다. 5행(`S-1045`)은 통과한다(출력 확인).
첫 문장을 이렇게 고쳐라.

```
- 검증이 붙으면 걸릴 줄은 셋이다. 3행은 주소에 `@` 가 없고, 4행은 `Chilled` 칸이 `maybe` 이고, 6행은 `SampleId` 가 비어 있으면서 날짜와 수량도 읽을 수 없다. 검증이 없는 지금은 여섯 줄 전부가 통과한다.
```

### 3. [08-functional-validation.md:266] 케이스 순서 설명이 실측과 반대다
"케이스 순서가 결과를 바꾼다 … `NoValue` 를 아래로 내리면 빈 문자열이 어느 케이스에도 걸리지 않고
마지막 줄로 떨어진다"는 서술은 이 `match` 식에서 성립하지 않는다.

`NoValue` 를 `| other` 바로 위로 내려 실행해 보면 출력이 한 글자도 바뀌지 않는다(`빈 칸` 그대로).
다섯 패턴이 서로 겹치지 않기 때문이다. 입력별 매칭 실측:

```
'  '               -> ["NoValue"]
'Y' / 'no'         -> ["Flag"]
'4.25' / '1,000'   -> ["AsDecimal"]
'2024-03-05'       -> ["AsDate"]
'choi@lab.example' -> ["EmailLike"]
'2024-13-45' / '-' -> []            (어느 패턴에도 걸리지 않는다)
```

겹치는 패턴이 없으므로 이 예제에서는 순서를 어떻게 놓아도 결과가 같다. 원칙 자체는 옳으니
겹치는 사례를 근거로 바꿔 적어라. 원서의 `(|IsBoolean|_|)` 는 `1`/`0` 을 참거짓으로 받으므로
`(|IsDecimal|_|)` 와 겹치고, 그 경우가 정확히 순서가 결과를 가르는 사례다. 교체 문장:

```
- 이 다섯 패턴은 서로 겹치지 않으므로 여기서는 케이스 순서를 바꿔도 결과가 같다. 다만 겹치는 패턴이 있으면 위에 적은 케이스가 먼저 걸린다. 원서처럼 `Flag` 가 `1`/`0` 을 참거짓으로 받으면 `AsDecimal` 과 겹치고, 그때는 둘의 순서가 판정을 가른다. 겹칠 수 있는 자리에서는 좁은 판정을 위에 둔다.
```

### 4. [08-functional-validation.md:354-367] `id` 없는 오류 예시가 그 코드의 실제 메시지가 아니다
블록의 코드에는 반환 타입 주석 `: Result<ValidatedSample, ValidationError list>` 가 붙어 있다.
그 코드를 실제로 컴파일하면 나오는 메시지는 주석에 적힌 것과 다르다. 실측(오류 하나만 난다):

```
error FS0001: 이 식에는
    'Result<ValidatedSample,ValidationError list>' 형식이 필요하지만
여기에서는
    'ValidatedSample' 형식이 지정되었습니다.
```

노트가 적어 둔 `'string' 형식이 필요하지만 'Result<string,ValidationError>'` 메시지는
반환 타입 주석을 지웠을 때 나오는 것이다(그때는 첫 인자 자리를 짚는다). 두 경우를 실측으로 확인했다.
블록의 주석 네 줄을 위 실측 메시지로 바꾸고, 블록 뒤 불릿에 한 줄을 더해 두면 대조가 쉬워진다.

```
- 반환 타입 주석을 지우면 오류 메시지가 달라진다. 컴파일러가 `create` 의 첫 인자 자리를 짚어 `'string' 형식이 필요하지만 'Result<string,ValidationError>' 형식이 지정되었습니다` 라고 말한다. 주석이 있으면 식 전체를 짚고, 없으면 인자 자리를 짚는다.
```

또한 351줄의 "목표 타입을 적어 두면 컴파일러가 어긋난 자리를 정확히 짚어 주므로"는 실측과 어긋난다.
주석을 달면 짚는 자리가 인자에서 식 전체로 넓어진다. 원서가 말한 값어치는 자리를 좁히는 것이 아니라
반환 타입을 고쳐서 오류를 피하는 길을 막는 것이다("it forces us to fix any issues", 원서 p.108).
교체 문장:

```
- 원서는 이 함수에 반환 타입 주석을 먼저 달아 둔다. 목표 타입을 못 박아 두면 반환 타입을 슬쩍 바꿔 컴파일만 통과시키는 길이 막히므로, 고쳐야 할 것을 고치게 된다.
```

### 5. [08-functional-validation.md:659, 716, 830] `and!` 를 "나란히 실행"이라 적은 것
`and!` 는 병행 실행이 아니다. 같은 스레드에서 위에서 아래로 차례로 평가된다. 실측(오른쪽 식에
출력을 넣어 확인):

```
and! 판 : 평가 A (스레드 1) / 평가 B (스레드 1) / 평가 C (스레드 1) -> Error ["A"; "B"; "C"]
let! 판 : 평가 A (스레드 1)                                        -> Error ["A"]
```

차이는 실행 시점이 아니라 의존 관계다. `let!` 은 뒷줄이 앞줄의 값을 쓸 수 있으므로 앞줄이 실패하면
뒷줄을 실행할 방법이 없고, `and!` 는 뒷줄이 앞줄의 값을 쓰지 않겠다는 선언이므로 앞줄의 성패와
무관하게 전부 평가된다. "나란히 실행"은 같은 패키지에 실제로 병렬로 도는
`parallelAsyncValidation` 계산 식이 따로 있어 오해가 더 커진다. 세 곳을 고쳐라.

659줄:
```
- `let!` 은 `Result` 안의 값을 꺼내 이름에 묶는다. `let!` 을 연달아 쓰면 뒷줄이 앞줄의 값을 쓸 수 있으므로 앞줄이 실패한 뒤에는 뒷줄을 실행할 방법이 없고, 그래서 첫 오류에서 멈춘다. `and!` 는 뒷줄이 앞줄의 값을 쓰지 않겠다는 선언이어서 모든 줄이 실행되고 오류가 모인다.
```

716줄:
```
- 첫 줄만 `let!` 이고 나머지가 `and!` 다. `and!` 는 앞줄의 결과에 기대지 않겠다는 선언이며, 그 덕에 세 검증이 모두 실행된다. 병행 실행이라는 뜻은 아니다. 세 줄은 위에서 아래로 차례로 평가된다.
```

830줄:
```
- F# 5 의 `and!` 는 `apply` 를 문법으로 감싼 것이다. `validation` 계산 식 안에서 `let!` 을 연달아 쓰면 뒷줄이 앞줄의 값에 의존해 첫 오류에서 멈추고, `and!` 로 이으면 의존이 끊겨 모든 줄이 실행되고 오류가 모인다. 계산 식은 `FsToolkit.ErrorHandling` 패키지가 제공하며, 그 `Validation<'a,'e>` 는 `Result<'a,'e list>` 의 타입 약어다.
```

### 6. [08-functional-validation.md:217] 리스트 패턴 개수가 어긋나면 조용히 실패한다
"정규식을 고쳐 그룹 개수를 바꾸면 이 자리가 곧바로 어긋나 준다"는 서술은 독자에게
컴파일러가 잡아 준다는 인상을 준다. 실측은 반대다. 캡처 그룹을 둘로 늘리고 `[ domain ]` 을
그대로 두면 컴파일 오류도 경고도 없이 `(|EmailLike|_|)` 가 항상 `None` 을 돌려준다.
결과는 모든 주소가 `BadFormat` 으로 반송되는 조용한 오작동이다.

```
let (|EmailLike|_|) input =
    match input with
    | Captures @"^([^@\s]+)@([^@\s]+\.[^@\s]+)$" [ domain ] -> Some domain
    | _ -> None
// "a@b.c" -> None   (경고 없음)
```

교체 문장:

```
- `[ domain ]` 은 리스트가 원소 하나인 경우만 받는 리스트 패턴이다. 부분 패턴이 돌려준 값에 다시 패턴을 적용한 것이며, 캡처 그룹이 정확히 하나일 때만 성립한다는 조건이 패턴에 적혀 있는 셈이다. 다만 정규식을 고쳐 그룹 개수를 바꾸면 컴파일러가 알려 주지 않는다. 이 케이스가 성립하지 않아 `None` 으로 조용히 떨어지므로, 정규식과 리스트 패턴은 함께 고쳐야 한다.
```

### 7. [08-functional-validation.md:541] `List.singleton` 을 5챕터에 돌린 것
`List.singleton` 은 노트 12편 어디에도 없고 8챕터에서 처음 나온다(`grep -rn singleton docs/ko/*.md`
결과가 8챕터 네 줄뿐이다). 원서도 p.115 에서 처음 소개한다. 교체:

```
오류 하나를 리스트로 감싸는 함수에는 이름을 붙여 둔다. 람다 식 `(fun e -> [ e ])` 를 쓸 수도 있지만 `List` 모듈의 `List.singleton` 이 정확히 그 일을 한다.
```

## 개선 권장

### A. 이식성 방침 — 1번(그대로 두기)을 권고한다. 대신 버전을 못 박고 요구사항을 적어라
실측으로 갈래를 확인했다.

- 패키지가 로컬 캐시에 있고 네트워크가 없는 경우: 통과한다(프록시를 막고 FSI 프로젝트 캐시를 새로
  만들어 확인했다). 버전을 적지 않아도 로컬 폴더에서 해결된다.
- 캐시도 네트워크도 없는 경우: 실패한다. `error FS0999 … 'FsToolkit.ErrorHandling.5.2.0' 패키지를
  다운로드하지 못했습니다`.

2번(`id` 떼기)은 택하지 마라. 이 단위는 12챕터가 그대로 올라앉는 코드이고, 패키지 API 가 바뀌면
가장 먼저 깨지는 자리다. `id` 를 떼면 독자의 사정은 하나도 나아지지 않고 게이트만 눈을 감는다.
독자가 캐시도 네트워크도 없으면 원서의 `dotnet add package` 도 실패하므로, 이것은 노트가 만든
문제가 아니라 원서를 따라가면 어차피 한 번은 네트워크가 필요하다는 사실이다. 그 사실을 적는 것이 답이다.

세 가지를 권고한다. 12챕터도 같은 규칙으로 가져가면 된다.

1. 버전을 못 박는다. `#r "nuget: FsToolkit.ErrorHandling, 5.2.0"`. 실측으로 통과를 확인했다.
   버전을 적지 않으면 나중에 최신 버전이 올라올 때 `open FsToolkit.ErrorHandling.ValidationCE` 나
   703줄의 실측 시그니처 주석이 예고 없이 어긋난다.
2. 663줄 블록 앞 산문에 요구사항 한 줄을 넣는다.
   ```
   이 단위만 외부 패키지가 필요하다. 처음 한 번은 네트워크가 있어야 패키지를 받아 오고, 그 뒤에는 로컬 NuGet 캐시로 도니 네트워크가 없어도 된다. 받아 오지 못하면 `error FS0999` 로 실패한다.
   ```
3. 원서와 같은 이유로 패키지를 쓴다는 점을 그대로 남긴다(지금 698줄이 이미 그 일을 한다).

여차하면 3번 방안도 있다는 것을 확인해 두었다. 이 챕터의 `apply` 를 그대로 재사용해
`Return`/`Bind`/`BindReturn`/`MergeSources` 네 멤버만 있는 빌더를 15줄로 만들면 패키지 없이
`let!`/`and!` 가 똑같이 돈다(실측 확인). 다만 계산 식 빌더 만들기는 12챕터 주제이므로
8챕터에서 먼저 꺼내는 것은 권하지 않는다.

### B. [08-functional-validation.md:49 / 703-705] FSI 가 타입 약어를 보여 주는 규칙
49줄은 "FSI 는 약어를 풀어 보여 준다"고 일반화하는데, 705줄에서는 FSI 가 약어 이름
`FsToolkit.ErrorHandling.Validation<Slip,ValidationError>` 를 그대로 보여 준다. 독자가 두 곳을
나란히 놓으면 어긋나 보인다. 실측하면 규칙은 "함수 타입에 붙인 약어가 함수 바인딩의 타입으로
쓰이면 화살표 꼴로 풀리고, 그 밖의 약어는 이름이 남는다"다.

```
type DataReader = string -> Result<string seq, exn>
val r1: s: string -> Result<string seq,exn>          // let r1 : DataReader = fun s -> ...
val use1: reader: DataReader -> s: string -> ...     // 매개변수에 붙인 약어는 남는다
type Validation<'a,'e> = Result<'a,'e list>
val v3: x: int -> Validation<int,string>             // 함수 타입이 아닌 약어는 남는다
```

49줄 주석을 좁혀 적어라.
```
// : DataReader 로 적었지만 FSI 는 함수 바인딩의 타입을 화살표 꼴로 풀어 보여 준다
// 아래 import 의 reader 처럼 매개변수에 붙인 약어는 이름이 그대로 남는다
```

### C. [08-functional-validation.md:238-239] 문화권 선택은 타당하다. 근거를 실측으로 못 박아라
결론부터 — 이 선택은 군더더기가 아니다. 두 가지 근거가 있다.
첫째, 6챕터가 이미 같은 선택을 했다(`Decimal.TryParse(text, NumberStyles.Number, invariant)`,
`DateTime.TryParse(text, invariant, DateTimeStyles.None)`). 8챕터가 원서로 되돌아가면 시리즈가 갈린다.
둘째, 위험이 "판정이 갈린다"보다 크다. 값이 조용히 어긋난다.

다만 238줄의 서술은 근거가 약하고, 한국어 로케일 독자에게는 재현되지도 않는다. 실측:

```
ko-KR : Decimal.TryParse "12.5" -> true 12.5    (고정 문화권과 같다)
de-DE : Decimal.TryParse "12.5" -> true 125     (통과하면서 값이 열 배가 된다)
fr-FR : Decimal.TryParse "12.5" -> false
```
```
DateTime.TryParse "2024-13-45" -> 모든 문화권에서 false
DateTime.TryParse "03/04/2024" -> en-US 2024-03-04 / de-DE 2024-04-03  (통과하면서 날이 달라진다)
DateTime.TryParse "2024-03-05" -> 모든 문화권에서 같다
```

두 불릿을 이렇게 고쳐 두면 독자가 왜 원서와 다른지, 자기 환경에서 왜 차이가 안 보이는지 함께 안다.

```
- 원서는 `Decimal.TryParse input` 과 `DateTime.TryParse` 를 그대로 쓴다. 현재 스레드의 문화권을 따르므로 판정만 갈리는 것이 아니라 값이 조용히 어긋난다. `12.5` 는 고정 문화권에서 12.5 지만 `de-DE` 에서는 `.` 이 자리 구분 기호라 125 로 통과한다. 한국어 로케일은 고정 문화권과 같은 결과라서 이 차이가 눈에 띄지 않고, 그래서 더 위험하다. 6챕터도 같은 이유로 문화권을 명시했다.
- `TryParse` 와 `TryParseExact` 의 차이도 크다. `TryParse` 는 여러 형식을 관대하게 받아들인다. `03/04/2024` 는 `en-US` 에서 3월 4일, `de-DE` 에서 4월 3일로 통과한다. 형식이 정해진 입력이라면 `TryParseExact` 로 못 박는 편이 검증에 맞다.
```

### D. [08-functional-validation.md:555] "시그니처가 결정적인 증거다"를 조금 좁혀라
이 조립에서는 옳다. 실패 타입이 `ValidationError` 이므로 오류를 둘 담을 자리가 없다.
다만 751줄에서 시그니처가 같은 두 함수(`validateSlip`, `validateSlipStopping`)가 다르게 동작하는 것을
직접 보여 주므로, 555줄을 그대로 읽은 독자는 뒤에서 걸린다. 방향을 한쪽으로만 적어라.

```
- 시그니처가 증거다. 실패 타입이 `ValidationError` 하나로 남고 리스트가 되지 않는다. 오류를 둘 이상 담을 자리 자체가 없으니 이 조립으로는 모을 수 없다. 거꾸로 실패 타입이 리스트라고 해서 오류를 모으는 방식인 것은 아니다. 그 경우는 뒤에서 다시 본다.
```

### E. [08-functional-validation.md:571-578] `bind` 가 멈추는 인과를 시그니처로 한 줄 더
지금 서술("앞 단계가 `Error` 면 넘긴 함수를 부르지 않는다")은 맞지만 결과만 말한다.
3챕터가 이미 시그니처를 실었으므로 한 줄로 원인까지 닿을 수 있다. 571줄 다음에 넣어라.

```
- 원인은 `Result.bind` 의 시그니처에 있다. 첫 매개변수가 `'a -> Result<'b,'c>` 이므로 뒤 계산은 앞 단계의 값을 받아야 비로소 만들어진다. 앞이 실패하면 뒤 계산은 실행되지 않는 것이 아니라 만들어질 수조차 없다. `apply` 의 두 매개변수는 둘 다 이미 만들어진 `Result` 라서 이 의존이 없다.
```

### F. [08-functional-validation.md:699] `Validation` 타입 약어는 `ValidationCE` 만 열면 안 보인다
실측으로 확인했다. `open FsToolkit.ErrorHandling.ValidationCE` 만 열고
`let a : Validation<int,string> = Ok 1` 을 적으면 `error FS0039: 'Validation' 형식이 정의되지
않았습니다. 다음 중 하나가 필요할 수 있습니다: ValidationBuilder` 가 난다. 705·718줄이 약어를
설명하므로 독자가 직접 써 보다 걸릴 자리다. 699줄 뒤에 한 줄 붙여라.

```
- 이 `open` 은 계산 식만 들여오므로 `Validation<'a,'e>` 라는 이름은 아직 보이지 않는다. 그 약어를 코드에 적으려면 `open FsToolkit.ErrorHandling` 이 필요하다. 아래에서 반환 타입을 `Result<Slip, ValidationError list>` 로 적은 것도 그래서 편하다.
```

덧붙여 `asList` 가 없으면 계산 식이 컴파일되지 않는다는 것도 확인했다
(`error FS0001: 'FsToolkit.ErrorHandling.Validation<string,'a>'이(가) 필요하지만
'Result<string,string>'이(가) 지정되었습니다`). 즉 695줄의 `asList` 는 장식이 아니라 필수 단계다.
패키지가 같은 일을 하는 `Validation.ofResult` 를 제공하니(실측 확인) 한 줄 언급해 두면
12챕터에서 다시 만들 이유가 없어진다.

### G. [08-functional-validation.md:810] `sequence` 와 `traverse` 를 갈라 적어라
"컬렉션 타입 `seq` 와는 상관이 없는 이름이다"라는 처리는 적절하다. 그대로 두어라.
다만 두 이름을 같은 것으로 묶은 것은 부정확하다. 여기서 만든 것은 `sequence` 이고,
`traverse` 는 원소마다 함수를 적용한 뒤 뒤집는 함수(`map` + `sequence`)다.
그리고 이 `sequence` 는 오류를 모으는 판이다. 첫 오류에서 멈추는 판도 같은 이름으로 불리므로
구별해 두면 12챕터에서 패키지 함수 이름이 낯설지 않다. 교체:

```
- `Result<'a,'b list> list -> Result<'a list,'b list>` 라는 시그니처를 잘 보면 `Result` 와 `list` 의 안팎이 뒤집혔다. 함수형 언어에서는 이렇게 뒤집는 함수를 `sequence` 라 부르고, 원소마다 함수를 적용한 뒤 뒤집는 것을 `traverse` 라 부른다. 컬렉션 타입 `seq` 와는 상관이 없는 이름이다.
- 방금 만든 것은 오류를 모으는 판이다. 첫 오류에서 멈추는 판도 같은 이름으로 불리므로, `FsToolkit.ErrorHandling` 은 `List.sequenceResultA`(모으는 판)와 `List.sequenceResultM`(멈추는 판)처럼 접미사로 둘을 가른다.
```

### H. [08-functional-validation.md:149] 정의 쪽을 설명하며 "인자"를 썼다
"인자를 하나씩 받는 커링된 형태여야"는 `create` 의 정의 모양을 말하는 자리다.
용어집 규칙대로 정의 쪽은 매개변수다. `매개변수를 하나씩 받는 커링된 형태여야 뒤에서 인자를 하나씩
먹여 가며 조립할 수 있다` 로 고쳐라. (595·618줄의 "인자"는 호출 쪽이라 그대로 두면 된다.)

### I. [08-functional-validation.md:762] `08-collect` 의 입력은 "같은 모양"이 아니다
`results` 의 오류 타입은 `string` 이고 앞 파이프라인은 `ValidationError` 다.
블록 안 주석을 이렇게 고쳐라.

```
// 앞 파이프라인이 낸 결과를 오류 타입만 string 으로 줄여 적은 값이다. 6행은 오류가 세 개다
```

### J. [08-functional-validation.md:830] `and!` 가 부르는 것을 한 낱말로 짚어 두면 12챕터가 쉬워진다
`and!` 는 빌더의 `MergeSources` 를, `let!` 은 `Bind` 를 부른다. 실측으로 `ValidationBuilder` 에
`Bind`, `BindReturn`, `MergeSources` 세 멤버가 다 있는 것을 확인했다. 830줄이나 660줄에
"`let!` 은 빌더의 `Bind`, `and!` 는 `MergeSources` 를 부른다. 그 멤버를 직접 만드는 것이 12챕터다"
정도의 한 줄을 넣으면 다리가 놓인다.

### K. 원서 오기를 한 줄 적어 두는 편이 대조에 도움이 된다
아래 세 건은 모두 확인했다(집필자 판단이 옳다). 노트가 원서를 옆에 두고 읽는 독자를 위한 것이므로
"원서 대조" 성격의 한 줄을 남기는 편이 낫다. 특히 첫 번째는 독자가 p.109 에서 막힌다.

- 원서 p.108 은 반환 타입을 `Result<ValidatedCustomer, ValidationError list>` 로, p.109 는
  `Result<ValidatedCustomer, ConversionError list>` 로 적는다. `ConversionError` 는 원서 어디에도
  정의되지 않고 pp.110-113 전체 코드는 다시 `ValidationError list` 다. p.109 가 오기다.
- 원서 p.104 는 `type DataReader`, p.110 전체 코드는 `type FileReader` 로 이름이 바뀐다.
  6챕터 노트가 `DataReader` 를 쓰므로 그쪽에 맞춘 것이 옳다.
- 원서 p.106 의 `(|IsValidDate|_|)` 가 pp.110-112 전체 코드 목록에서 빠졌는데
  p.112 의 `validateDateRegistered` 가 그것을 쓴다. 목록을 그대로 붙여 넣으면 컴파일되지 않는다.

## 확인 완료

- 실행 단위 6개 전부 PASS(`08-intake`, `08-manual`, `08-patterns`, `08-compose`,
  `08-validation-ce`, `08-collect`). 주석에 적은 기대 출력이 실제 출력과 전부 일치한다.
  `check-note.sh` 도 OK. `id` 배정도 옳다. `id` 없는 블록은 354줄 하나뿐이고 컴파일 오류 예시로
  맞게 쓰였다(메시지 본문은 위 4번).
- 시그니처 주석 전부 FSI 실측과 일치한다. 확인한 것: `memoryReader`, `parseRow`, `parse`(두 판 모두),
  `output`, `import`, `create`, 부분 패턴 여섯 개, `validate*` 다섯 개, `errorsOf`, `valueOf`,
  `validateSample`, `describeError`, `show`, `makeSlip`, `asList`, `validateFirstError`, `apply`,
  `<!>`, `<*>`, `validateAll`, `fieldNames`, `showFirst`, `showAll`, `partitionResults`, `sequence`.
  특히 `apply` 의 `Result<('a -> 'b),'c list> -> Result<'a,'c list> -> Result<'b,'c list>` 와
  `validateFirstError` 의 `Result<Slip,ValidationError>` 대비가 실측대로다.
- 617줄의 중간 타입 주장도 실측과 같다.
  `makeSlip <!> asList (validateSampleId ...)` → `Result<(bool -> decimal -> Slip),ValidationError list>`,
  다음 `<*>` 뒤 → `Result<(decimal -> Slip),ValidationError list>`, 마지막 → `Result<Slip,ValidationError list>`.
- 620줄의 값 제한 관련 서술은 실측과 맞다. `let (<!>) = Result.map` 은 오류 없이 일반화되고
  `val (<!>) : (('a -> 'b) -> Result<'a,'c> -> Result<'b,'c>)` 로 바깥 괄호가 붙는다.
  한 가지 덧붙이면 이것은 F# 10 특유의 동작이 아니다. `--langversion:5.0` 에서도 같고
  `let m = List.map`, `let (<*>) = apply` 도 같다. 값 제한은 `let e = List.rev []` 처럼
  함수 적용 결과를 값에 묶을 때 나는 것이라는 용어집 설명과 정확히 맞물린다.
  노트가 버전을 붙이지 않은 것이 옳으니 나중에도 "F# 10 이 …" 같은 문구를 넣지 마라.
- 703-705줄의 반환 타입 주장 확인. 주석을 지우면
  `FsToolkit.ErrorHandling.Validation<Slip,ValidationError>`, 주석을 달면
  `Result<Slip,ValidationError list>` 로 보인다. `Validation<'a,'e>` 와 `Result<'a,'e list>` 가
  서로 대입되는 것도 확인했다(타입 약어이므로 같은 타입이다).
- `open FsToolkit.ErrorHandling.ValidationCE` 는 5.2.0 에서 그대로 유효하다. 원서 서술이 살아 있다.
- 267줄의 `FS0025` 확인. 마지막 `| other ->` 를 지우면
  `warning FS0025: 이 식의 패턴 일치가 완전하지 않습니다` 가 난다. 오류 코드 표기가 맞다.
- 193줄의 `Seq.skip` 안전성 주장이 맞다. 캡처 그룹이 없는 정규식이어도 `m.Groups` 에 0번이 있어
  원소가 하나이므로 `Seq.skip 1` 은 빈 시퀀스를 낼 뿐 예외를 던지지 않는다.
- 챕터의 핵심인 두 방식의 대비가 정확하다. `bind` 는 다음 함수를 부를지 앞 결과를 보고 정하고,
  `apply` 는 두 결과를 이미 손에 들고 합칠지 이어 붙일지만 정한다는 578줄 서술이 원인을 옳게 짚었고,
  593-595줄이 실패 타입 리스트와 "성공 자리에 함수를 담는다"는 요령을 정확히 설명한다.
  642-649줄의 나란한 실행 비교가 그 차이를 눈에 보이게 만든 것도 좋다.
- 3챕터 원칙과 어긋나지 않는다. 검증 함수 전부가 `ValidationError` 하나를 쓰고(346줄),
  `asList`(=`Result.mapError List.singleton`)가 실패 선로의 어댑터 역할을 하며(549줄),
  계산 식 안에서는 `ValidationError list` 로 통일된다(750줄). 3챕터의 `Result.mapError` 설명과
  같은 논리다.
- 7챕터와 어긋나지 않는다. 매개변수 있는 부분 액티브 패턴의 "검사할 값이 마지막 매개변수"(180줄),
  바나나 클립째로 적어 함수처럼 부르기(187-188, 192줄), 부분 패턴이 `option` 을 반환한다는 규칙이
  모두 7챕터 서술과 같다. 7챕터가 예고한 "정규식 자체를 매개변수로 받는 꼴로 일반화"를
  `(|Captures|_|)` 가 제대로 이어받았다.
- 부분 함수·부분 액티브 패턴·부분 적용 세 낱말을 5-9줄에서 가른 처리가 용어집 규칙대로다.
  `valueOf` 를 부분 함수로 짚고(394줄) 후반 두 방식이 그것을 없앤다는 구성(752줄)이 정확하다.
- 421줄의 "`List.collect errorsOf` 로 줄일 수 없다"가 옳다. 다섯 검증의 성공 타입이 달라
  한 리스트에 담기지 않는다.
- 812줄의 `values @ [ value ]` 비용 지적이 옳다.
- 717·831줄의 "`return` 이 필요한 자리는 계산 식뿐"이 원서 p.117 서술과 같고 사실이다.
