# 17챕터 용어 후보

`docs/ko/17-appendix-1-solution-setup.md` 검수에서 새로 올라온 용어와 표기 후보다.
`docs/ko/GLOSSARY.md` 는 읽기만 했고 편집하지 않았다. 병합은 2b 단계에서 한다.

부록 1 은 개념어가 거의 없고 도구·산출물 이름이 대부분이다. 그래서 후보도 셸 명령과
편집기 조작 쪽 이름에 몰려 있다. 표기는 서문 챕터와 4·13·14챕터가 이미 쓰던 것을 따랐다.

| 영어 | 한국어 표기 | 비고 |
|---|---|---|
| BOM | BOM | byte order mark. 번역하지 않고 대문자 세 글자로 쓴다. "바이트 순서 표시"·"바이트 순서 마크" 쓰지 않는다. `dotnet new` 템플릿이 만든 `.fs`·`.fsproj` 는 BOM 이 붙은 UTF-8 이고 `.slnx` 는 BOM 이 없다(실측). BOM 을 떼도 빌드는 성공한다. 17챕터 |
| CLI | CLI | 번역하지 않는다. `dotnet` CLI. "명령줄 인터페이스"로 풀어 쓰지 않는다. 기확정 `SDK`(SDK) 행과 같은 규칙이다. 14·17챕터 |
| command palette | 명령 팔레트 | VS Code 의 `CTRL+SHIFT+P` 패널. MS ko 표기와 일치. 서문 챕터가 이미 쓰고 있다. 서문·17챕터 |
| exit code | 종료 코드 | [기확정 변경 제안] 현재 비고가 "`main` 이 마지막에 돌려주는 `int`" 로만 좁혀져 있다. 17챕터는 `dotnet new sln` 이 덮어쓰기 확인을 요구하며 내는 종료 코드 73 을 같은 낱말로 부른다(실측). 표기는 그대로 두고 비고에 "CLI 프로세스가 셸에 돌려주는 값도 같은 말로 부른다" 를 덧붙이자는 제안이다. 표기 변경이 아니므로 앞 챕터 본문을 고칠 일은 없다. 오류 번호(`오류 FS0222`)와는 성격이 다른 것이라는 구분도 함께 적어 두면 좋다 |
| integrated terminal | 통합 터미널 | VS Code 창 안에 붙은 터미널 패널. MS ko 표기와 일치. "내장 터미널"·"인테그레이티드 터미널" 쓰지 않는다. 새로 여는 것은 `CTRL+SHIFT+백틱`, 이미 열린 패널을 접었다 펴는 것은 `CTRL+백틱` 이다. 17챕터 |
| keyboard shortcut | 단축키 | 서문 챕터 표기와 일치. "키보드 지름길"·"키 바인딩" 쓰지 않는다. 키 이름은 원서 표기를 따라 대문자와 `+` 로 적는다(`CTRL+SHIFT+P`, `CTRL+F2`). 백틱 키는 인라인 코드 안에 기호를 넣기 어려우므로 `CTRL+백틱` 처럼 낱말로 적는다. 서문·17챕터 |
| locale | 로케일 | 1챕터 표기와 일치. `dotnet` CLI 와 컴파일러 메시지는 셸 로케일을 따라 번역돼 나온다(실측: 한국어 로케일에서 `통과!  - 실패:     0, ...`). 영어 출력을 인용하는 대목은 `DOTNET_CLI_UI_LANGUAGE=en` 으로 얻은 것임을 밝힌다. 1·17챕터 |
| package reference | 패키지 참조 | `dotnet add package` 로 거는 관계. `.fsproj` 의 `PackageReference` 항목은 원어 백틱으로 쓴다. 기확정 `project reference`(프로젝트 참조) 행과 같은 규칙. 4·17챕터 |
| preface chapter | 서문 챕터 | 00 노트를 가리키는 표기. 16챕터가 이미 여섯 번 "서문 챕터"로 쓰고 있고(16챕터 13·18·38·43·68·83행), STYLE.md 의 `N챕터` 통일 규칙과도 맞는다. 17챕터가 쓴 "서문 노트(`00-preface-getting-started.md`)" 는 이쪽으로 맞춘다. 노트 파일 이름을 본문에 직접 적는 교차 참조는 17챕터 두 곳(3·19행)이 유일한 용례이므로 관례로 굳히지 않는다. 16·17챕터 |
| solution file | 솔루션 파일 | `dotnet new sln` 이 만드는 파일. SDK 10 기본 산출물은 `.slnx`(XML, `<Solution>` 두 줄)이고 `-f sln` 을 주면 예전 `.sln` 이 나온다(실측). 확장자는 원어 백틱으로 쓴다. 기확정 `solution`(솔루션) 행의 하위 항목이며, 디스크의 솔루션 루트를 가리키는 "솔루션 디렉터리"와 구분해 쓴다 |
| solution folder | 솔루션 폴더 | `.slnx` 의 `<Folder Name="/src/">`. 예전 `.sln` 에서는 SolutionFolder 유형의 Project 항목과 NestedProjects 절로 적힌다(실측). 편집기 솔루션 탐색기에 보이는 분류일 뿐이고 디스크의 디렉터리도 F# 컴파일 순서도 아니다. `dotnet sln add` 가 프로젝트 경로에서 만들며 `--in-root`(기본값 False)로 끈다. MS ko 표기와 일치. "솔루션 디렉터리"와 반드시 구분한다 |
| template short name | 템플릿 짧은 이름 | `dotnet new list` 출력의 Short Name 칸 값(`console`, `xunit`). MS ko 는 "약식 이름"도 쓰나 노트는 "짧은 이름"으로 고정한다. 기확정 `template`(템플릿) 행의 하위 항목 |

## 병합 때 판단할 것

- `preface chapter` 는 16챕터 전문가와 결론이 갈릴 수 있다. 근거는 위 행에 적었다.
  16챕터가 이미 여섯 번 쓴 표기이므로 17챕터를 고치는 쪽이 수정량이 적다.
- `exit code` 는 표기를 바꾸는 제안이 아니라 비고를 넓히는 제안이다. 그대로 넘겨도 노트 본문에
  손댈 곳은 없다.
- `solution file`·`solution folder` 는 기확정 `solution` 행의 하위 항목이므로, 병합할 때
  `solution` 행 비고에 두 항목을 가리키는 한 줄을 넣는 편이 찾기 쉽다.
