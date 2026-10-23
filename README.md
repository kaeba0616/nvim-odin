# nvim-odin

Odin 개발용 Neovim 설정입니다. 플러그인은 [lazy.nvim](https://github.com/folke/lazy.nvim)으로 관리하며, 처음 실행할 때 자동으로 설치됩니다.

## 필요한 프로그램

| 프로그램 | 용도 | 비고 |
|---|---|---|
| [Neovim](https://neovim.io) 0.11 이상 | 에디터 | `vim.lsp.config` API를 사용하므로 0.11 이상 필요 (0.12에서 사용 중) |
| [Git](https://git-scm.com) | 설정 받기, 플러그인 설치 | |
| [Nerd Font](https://www.nerdfonts.com) | 파일 아이콘 | 터미널 폰트를 Nerd Font로 설정 |
| [Odin](https://odin-lang.org) | 컴파일러 (`odin run/build/check`) | `odin`이 PATH에 있어야 함 |
| [ols](https://github.com/DanielGavin/ols) | Odin 언어 서버 (자동완성, 이동, 이름 변경) | `ols`, `odinfmt`가 PATH에 있거나 `D:/dev/ols/`에 있어야 함 |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | 텍스트 검색 (`<leader>fg`) | |
| C 컴파일러 | 없어도 됨 | blink.cmp는 미리 빌드된 바이너리를 받음 |
| PowerShell 7 (Windows) | `:terminal`, `:!` 셸 | 없으면 기본 셸 사용 |

Windows에서는 winget으로 대부분 설치할 수 있습니다.

```powershell
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC Microsoft.PowerShell
```

Odin과 ols는 각 저장소의 안내에 따라 빌드하거나 릴리스를 받은 뒤 PATH에 추가합니다.

## 설치

기존 설정이 있다면 먼저 백업합니다.

**Windows**

```powershell
git clone https://github.com/kaeba0616/nvim-odin.git $env:LOCALAPPDATA\nvim
```

**Linux / macOS**

```bash
git clone https://github.com/kaeba0616/nvim-odin.git ~/.config/nvim
```

그다음 `nvim`을 실행하면 플러그인이 자동 설치됩니다. 이 저장소와 똑같은 플러그인 버전으로 맞추려면 nvim 안에서 아래를 실행합니다.

```
:Lazy restore
```

### ols 경로 설정

`lua/plugins/lsp.lua`는 `ols`가 PATH에 있으면 그것을 쓰고, 없으면 `D:/dev/ols/ols.exe`를 씁니다. 다른 위치에 설치했다면 이 경로를 바꾸세요. `odinfmt` 경로도 같은 파일에 있습니다.

프로젝트 루트는 `ols.json` 또는 `.git`이 있는 폴더로 잡힙니다.

## 설정 동기화

설정을 바꾼 컴퓨터에서:

```powershell
git add -A; git commit -m "변경 내용"; git push
```

다른 컴퓨터에서:

```powershell
git pull
```

## 키맵

리더 키는 `Space`입니다.

### Odin (Odin 파일에서만)

저장한 뒤 아래쪽 터미널 창에서 실행합니다. 이전 실행 창은 자동으로 닫힙니다.

| 키 | 명령 |
|---|---|
| `<leader>or` | `odin run . -debug` |
| `<leader>os` | `odin run . -o:speed` |
| `<leader>ob` | `odin build . -debug` |
| `<leader>oc` | `odin check . -strict-style` |

### LSP

| 키 | 동작 |
|---|---|
| `gd` | 정의로 이동 |
| `gD` | 선언으로 이동 |
| `gr` | 참조 보기 |
| `K` | 호버 문서 |
| `<leader>rn` / `F2` | 이름 변경 (프로젝트 전체) |
| `<leader>ca` | 코드 액션 (비주얼 모드에서는 선택 영역) |
| `<leader>cr` | 리팩터링 액션만 보기 (비주얼 모드 가능) |
| `<leader>co` | import 정리 |
| `<leader>e` | 현재 줄 진단 보기 |
| `[d` / `]d` | 이전 / 다음 진단 |
| `<leader>th` | 인레이 힌트 켜기/끄기 |
| `<leader>q` | quickfix 창 열기/닫기 |

저장할 때 `odinfmt`로 자동 포맷됩니다.

### 자동완성 (blink.cmp)

| 키 | 동작 |
|---|---|
| `Tab` | 선택 항목 입력, 스니펫이면 다음 자리로 |
| `S-Tab` | 스니펫 이전 자리 |
| `Enter` | 선택 항목 입력 |
| `C-n` / `C-p` | 다음 / 이전 항목 |
| `C-Space` | 메뉴 열기, 문서 보기 |
| `C-e` | 메뉴 닫기 |

괄호와 따옴표는 nvim-autopairs가 자동으로 닫습니다.

### 파일 탐색기 (oil.nvim)

`nvim .`처럼 폴더를 열거나 `-` / `<leader>pv`를 누르면 Oil이 열립니다. 파일 목록을 일반 버퍼처럼 편집하고 `:w`로 저장하면 실제 파일에 반영됩니다.

| 동작 | 방법 |
|---|---|
| 새 파일 | `o`로 새 줄 → 이름 입력 (폴더는 `이름/`) |
| 이름 변경 | 줄의 이름을 직접 수정 |
| 삭제 | `dd` (휴지통으로 이동) |
| 복사 | `yy` → 다른 폴더에서 `p` |
| 이동 | `dd` → 다른 폴더에서 `p` |
| 반영 | `:w` |

| 키 | 동작 |
|---|---|
| `Enter` | 열기 |
| `-` | 상위 폴더 |
| `_` | 작업 폴더(cwd)로 이동 |
| `` ` `` | 현재 폴더를 cwd로 설정 |
| `C-v` / `C-s` | 세로 / 가로 분할로 열기 |
| `C-p` | 미리보기 |
| `g.` | 숨김 파일 토글 |
| `gs` | 정렬 변경 |
| `g?` | 도움말 |
| `q` | 닫기 |

### 검색 (Telescope)

| 키 | 동작 |
|---|---|
| `<leader>ff` | 파일 찾기 |
| `<leader>fg` | 텍스트 검색 (ripgrep 필요) |
| `<leader>fb` | 버퍼 목록 |
| `<leader>fs` | 문서 심볼 |

### 창과 터미널

| 키 | 동작 |
|---|---|
| `C-h/j/k/l` | 왼쪽/아래/위/오른쪽 창으로 이동 (터미널 안에서도 동작) |
| `Esc Esc` | 터미널 모드 빠져나오기 |
| `<leader>x` | 현재 창 닫기 (터미널이면 프로세스 종료) |
| `q` | 끝난 터미널 창 닫기 (일반 모드) |

`<leader>`를 누르고 잠시 기다리면 which-key가 사용 가능한 키 목록을 보여줍니다.

## 구성

```
init.lua                 기본 옵션, 키맵, lazy.nvim 부트스트랩, Odin 실행 키
lazy-lock.json           플러그인 버전 고정
lua/plugins/
  lsp.lua                ols, blink.cmp(자동완성), conform.nvim(odinfmt 포맷)
  oil.lua                파일 탐색기
  ui.lua                 tokyonight 테마, lualine, telescope, which-key
  icons.lua              nvim-web-devicons (Odin 아이콘 포함)
  autopairs.lua          괄호 자동 완성
```

테마는 투명 배경(tokyonight-night)이라 터미널 배경이 비쳐 보입니다. 끄려면 `lua/plugins/ui.lua`에서 `transparent = false`로 바꾸세요.
