# nic: Neovim + Claude Code + Terminal (tmux 자동 레이아웃)
nic() {
  local dir="${1:-.}"
  local session_name
  session_name="nic-$(basename "$(realpath "$dir")")"

  # 이미 세션이 있으면 attach
  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
    return
  fi

  # 새 세션 생성 (detached), 첫 창 이름: editor
  # pane 0: nvim (좌상), pane 1: terminal (좌하), pane 2: claude (우)
  tmux new-session -d -s "$session_name" -n "editor" -c "$dir"

  # pane 0 기준으로 오른쪽 30% 분할 → pane 1 (claude)
  tmux split-window -h -p 30 -t "${session_name}:editor" -c "$dir"

  # pane 0 (왼쪽) 하단 20% 분할 → pane 1 (terminal), 기존 pane 1은 2로 밀림
  tmux split-window -v -p 20 -t "${session_name}:editor.0" -c "$dir"

  # 각 패널에 명령 전송
  # pane 0: nvim, pane 1: terminal(빈 쉘), pane 2: claude
  tmux send-keys -t "${session_name}:editor.0" "nvim ." Enter
  tmux send-keys -t "${session_name}:editor.2" "claude" Enter

  # neovim 패널(pane 0)에 포커스
  tmux select-pane -t "${session_name}:editor.0"

  tmux attach-session -t "$session_name"
}

# nicx: 프로젝트 디렉토리를 직접 지정해서 열기
nicx() {
  if [ -z "$1" ]; then
    echo "사용법: nicx <프로젝트 경로>"
    return 1
  fi
  nic "$1"
}

# nic-kill: 현재 디렉토리의 nic 세션 종료
nic-kill() {
  local session_name
  session_name="nic-$(basename "$(realpath "${1:-.}")")"
  tmux kill-session -t "$session_name" 2>/dev/null && echo "세션 '$session_name' 종료" || echo "세션 없음"
}

# nic-ls: 활성 nic 세션 목록
nic-ls() {
  tmux list-sessions 2>/dev/null | grep "^nic-" || echo "활성 nic 세션 없음"
}
