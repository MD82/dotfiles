# Hyprland Keybinds

Modifiers:

- `SUPER`: main modifier
- `SUPER + ALT`: alternate modifier
- `SUPER + CTRL + ALT`: hyper modifier

## Apps and Session

| Key | Action | 설명 |
| --- | --- | --- |
| `SUPER + Space` | Cycle layout profile or restore tabbed group | 레이아웃을 Dwindle/Large main/Scrolling 순서로 순환하거나 탭 그룹을 복원합니다. |
| `SUPER + P` | Launch `fuzzel` | 앱 런처를 엽니다. |
| `SUPER + SHIFT + P` | Open power menu | 잠금, 화면 끄기, 절전, 로그아웃, 재부팅, 종료 메뉴를 엽니다. |
| `SUPER + \`` | Toggle Quickshell topbar | 상단 Quickshell 바를 보이거나 숨깁니다. |
| `SUPER + Return` | Launch profile terminal | 현재 프로필의 기본 터미널을 엽니다. |
| `SUPER + SHIFT + Return` | Launch `foot` | 새 foot 터미널을 엽니다. |
| `SUPER + R` | Reload Hyprland | Hyprland 설정을 다시 불러옵니다. |
| `SUPER + SHIFT + C` | Close active window | 현재 포커스된 창을 닫습니다. |
| `SUPER + SHIFT + Q` | Exit Hyprland | Hyprland 세션을 종료합니다. |
| `SUPER + E` | Launch Emacs Everywhere | Emacs Everywhere를 실행합니다. |
| `SUPER + V` | Paste clipboard text through `xdotool` | 클립보드 텍스트를 현재 창에 입력합니다. |

## Focus and Window Movement

| Key | Action | 설명 |
| --- | --- | --- |
| `SUPER + Arrow` | Move focus in direction | 방향키 방향의 창으로 포커스를 이동합니다. |
| `SUPER + SHIFT + Arrow` | Swap active window in direction | 현재 창을 방향키 방향의 창과 바꿉니다. |
| `SUPER + CTRL + Arrow` | Move active window to monitor in direction and follow | 현재 창을 방향키 방향의 모니터로 보내고 따라갑니다. |
| `SUPER + CTRL + SHIFT + Arrow` | Move active window to empty workspace on monitor in direction | 방향키 방향 모니터의 빈 워크스페이스로 현재 창을 보냅니다. |
| `SUPER + ALT + SHIFT + Arrow` | Resize active window | 현재 창 크기를 방향키 방향으로 조절합니다. |
| `SUPER + CTRL + ALT + Arrow` | Focus monitor in direction | 방향키 방향의 모니터로 포커스를 옮깁니다. |
| `SUPER + CTRL + ALT + SHIFT + Arrow` | Move active window to monitor in direction and follow | 현재 창을 방향키 방향의 모니터로 보내고 따라갑니다. |

## Layout and Window State

| Key | Action | 설명 |
| --- | --- | --- |
| `SUPER + SHIFT + Space` | Force Dwindle layout or restore tabbed group | Dwindle 레이아웃으로 전환하거나 탭 그룹을 복원합니다. |
| `SUPER + CTRL + Space` | Gather workspace into tabbed group | 현재 워크스페이스의 창들을 탭 그룹으로 모읍니다. |
| `SUPER + ]` | Next window, or visual right in scrolling | 그룹/monocle에서는 다음 창으로, scrolling에서는 오른쪽 창으로 이동합니다. |
| `SUPER + [` | Previous window, or visual left in scrolling | 그룹/monocle에서는 이전 창으로, scrolling에서는 왼쪽 창으로 이동합니다. |
| `SUPER + T` | Disable floating for active window | 현재 창의 floating 상태를 해제합니다. |
| `SUPER + O` | Toggle active window pin | 현재 창의 pin 상태를 토글합니다. |
| `SUPER + F` | Toggle active window fullscreen | 현재 창의 fullscreen 상태를 토글합니다. |
| `SUPER + M` | Minimize active window | 현재 창을 최소화합니다. |
| `SUPER + SHIFT + M` | Restore last minimized window | 마지막으로 최소화한 창을 복원합니다. |
| `SUPER + CTRL + SHIFT + M` | Pick minimized window | 최소화된 창 선택 모드로 들어갑니다. |
| `SUPER + CTRL + M` | Toggle swallowing | 창 swallowing 기능을 토글합니다. |
| `SUPER + '` | Focus next window with same class | 같은 앱/class의 다음 창으로 이동합니다. |
| `SUPER + ALT + W` | Show active window info | 현재 창 정보를 표시합니다. |
| `SUPER + Left Mouse Drag` | Float and drag active window | 현재 창을 floating으로 만들고 이동합니다. |
| `SUPER + Right Mouse Drag` | Float and resize active window | 현재 창을 floating으로 만들고 크기를 조절합니다. |

## Workspaces

| Key | Action | 설명 |
| --- | --- | --- |
| `SUPER + 1..9` | Focus workspace | 해당 번호의 워크스페이스로 이동합니다. |
| `SUPER + SHIFT + 1..9` | Move active window to workspace | 현재 창을 해당 번호의 워크스페이스로 보냅니다. |
| `SUPER + CTRL + 1..9` | Move active window to workspace and focus it | 현재 창을 해당 워크스페이스로 보내고 그곳으로 이동합니다. |
| `SUPER + Z` | Focus next monitor | 다음 모니터로 포커스를 이동합니다. |
| `SUPER + SHIFT + Z` | Move active window to next monitor | 현재 창을 다음 모니터로 보냅니다. |
| `SUPER + Mouse Wheel` | Cycle workspace | 마우스 휠로 워크스페이스를 순환합니다. |
| `SUPER + SHIFT + E` | Move active window to next empty workspace and follow | 현재 창을 다음 빈 워크스페이스로 보내고 그곳으로 이동합니다. |
| `SUPER + CTRL + E` | Move active window to next empty workspace | 현재 창을 다음 빈 워크스페이스로 보냅니다. |
| `SUPER + CTRL + ALT + E` | Focus next empty workspace | 다음 빈 워크스페이스로 이동합니다. |
| `SUPER + CTRL + ALT + 5` | Enter workspace swap mode | 워크스페이스 교환 모드로 들어갑니다. |
| `SUPER + CTRL + ALT + G` | Gather focused class | 현재 앱/class의 창들을 모읍니다. |

## Scratchpads

| Key | Action | 설명 |
| --- | --- | --- |
| `SUPER + ALT + C` | Toggle Codex scratchpad | Codex scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + E` | Toggle Element scratchpad | Element scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + H` | Toggle htop scratchpad | htop scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + K` | Toggle Slack scratchpad | Slack scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + M` | Toggle Messages scratchpad | Messages scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + S` | Toggle Spotify scratchpad | Spotify scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + T` | Toggle Transmission scratchpad | Transmission scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + V` | Toggle volume scratchpad | 볼륨 설정 scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + Grave` | Toggle dropdown scratchpad | 드롭다운 터미널 scratchpad를 열거나 숨깁니다. |
| `SUPER + ALT + Space` | Minimize other classes | 현재 앱/class를 제외한 창들을 최소화합니다. |
| `SUPER + ALT + SHIFT + Space` | Restore focused class | 현재 앱/class의 최소화된 창들을 복원합니다. |
| `SUPER + ALT + Return` | Restore all minimized windows | 최소화된 모든 창을 복원합니다. |

## Media and Hardware

| Key | Action | 설명 |
| --- | --- | --- |
| `SUPER + I` | Increase volume and unmute | 볼륨을 올리고 음소거를 해제합니다. |
| `SUPER + K` | Decrease volume and unmute | 볼륨을 내리고 음소거를 해제합니다. |
| `SUPER + U` | Toggle mute | 음소거를 토글합니다. |
| `SUPER + ;` | Play/pause | 재생/일시정지를 토글합니다. |
| `SUPER + L` | Next track | 다음 트랙으로 넘깁니다. |
| `SUPER + J` | Previous track | 이전 트랙으로 돌아갑니다. |
| `XF86AudioPlay/Pause` | Play/pause | 미디어 키로 재생/일시정지를 토글합니다. |
| `XF86AudioNext/Prev` | Next/previous track | 미디어 키로 다음/이전 트랙으로 이동합니다. |
| `XF86AudioRaiseVolume/LowerVolume` | Increase/decrease volume and unmute | 미디어 키로 볼륨을 조절하고 음소거를 해제합니다. |
| `XF86AudioMute` | Toggle mute | 미디어 키로 음소거를 토글합니다. |
| `XF86MonBrightnessUp/Down` | Increase/decrease brightness | 화면 밝기를 올리거나 내립니다. |
| `XF86KbdBrightnessUp/Down` | Increase/decrease keyboard backlight | 키보드 백라이트를 올리거나 내립니다. |

## Utilities

| Key | Action | 설명 |
| --- | --- | --- |
| `SUPER + X` | Launch `rofi_command.sh` | rofi 명령 실행기를 엽니다. |
| `SUPER + SHIFT + X` | Toggle special workspace `NSP` | `NSP` special workspace를 토글합니다. |
| `SUPER + CTRL + ALT + V` | Clipboard picker | 클립보드 히스토리 선택기를 엽니다. |
| `SUPER + CTRL + ALT + P` | Password picker | 비밀번호 선택기를 엽니다. |
| `SUPER + CTRL + ALT + H` | Screenshot region and edit | 영역 스크린샷을 찍고 편집기를 엽니다. |
| `SUPER + CTRL + ALT + C` | Codex picker | Codex 선택기를 엽니다. |
| `SUPER + CTRL + ALT + SHIFT + C` | Codex resume picker | Codex resume 선택기를 엽니다. |
| `SUPER + CTRL + ALT + L` | Lock screen | 화면을 잠급니다. |
| `SUPER + CTRL + ALT + SHIFT + L` | Layout picker | 레이아웃 선택기를 엽니다. |
| `SUPER + CTRL + ALT + K` | Process kill picker | 프로세스 종료 선택기를 엽니다. |
| `SUPER + CTRL + ALT + SHIFT + K` | Kill-all picker | 여러 프로세스 종료 선택기를 엽니다. |
| `SUPER + CTRL + ALT + R` | systemd picker | systemd 서비스 선택기를 엽니다. |
| `SUPER + CTRL + ALT + /` | Toggle taffybar | taffybar를 토글하고 scratchpad 위치를 갱신합니다. |
| `SUPER + CTRL + ALT + I` | Audio input selector | 오디오 입력 장치 선택기를 엽니다. |
| `SUPER + CTRL + ALT + O` | Audio output selector | 오디오 출력 장치 선택기를 엽니다. |
| `SUPER + CTRL + ALT + ,` | Wallpaper picker | 배경화면 선택기를 엽니다. |
| `SUPER + CTRL + ALT + SHIFT + ,` | Wallpaper toggle | 배경화면 상태를 토글합니다. |
| `SUPER + CTRL + ALT + Y` | Agentic skill picker | agentic skill 선택기를 엽니다. |
