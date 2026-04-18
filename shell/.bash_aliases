# nic: Neovim + AI + Terminal (tmux 자동 레이아웃)
# 사용법: nic [dir] [claude|codex|gemini]  (AI 생략 시 빈 pane)
nic() {
  local dir="${1:-.}"
  local ai="${2:-}"
  local ai_cmd=""

  if [ -n "$ai" ]; then
    case "$ai" in
      claude) ai_cmd="claude" ;;
      codex)  ai_cmd="codex" ;;
      gemini) ai_cmd="gemini" ;;
      *)
        echo "알 수 없는 AI: $ai (claude | codex | gemini)"
        return 1
        ;;
    esac
  fi

  local suffix="${ai:+-${ai}}"
  local session_name
  session_name="nic-$(basename "$(realpath "$dir")")${suffix}"

  # 이미 세션이 있으면 attach
  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
    return
  fi

  # 새 세션 생성 (detached), 첫 창 이름: editor
  tmux new-session -d -s "$session_name" -n "editor" -c "$dir"

  # pane ID를 캡처하여 번호 변동에 안전하게 처리
  local pane_nvim pane_ai
  pane_nvim=$(tmux display-message -p -t "${session_name}:editor" "#{pane_id}")

  # 오른쪽 30% 분할 → AI pane (빈 쉘 or AI 명령)
  pane_ai=$(tmux split-window -h -p 30 -t "$pane_nvim" -c "$dir" -P -F "#{pane_id}")

  # nvim pane 하단 20% 분할 → terminal pane
  tmux split-window -v -p 20 -t "$pane_nvim" -c "$dir"

  # 각 패널에 명령 전송
  tmux send-keys -t "$pane_nvim" "nvim ." Enter
  [ -n "$ai_cmd" ] && tmux send-keys -t "$pane_ai" "$ai_cmd" Enter

  # neovim 패널에 포커스
  tmux select-pane -t "$pane_nvim"

  tmux attach-session -t "$session_name"
}


# nic-kill: nic 세션 종료
# 사용법: nic-kill [dir] [claude|codex|gemini]  (AI 생략 시 AI 없는 세션)
nic-kill() {
  local suffix="${2:+-${2}}"
  local session_name
  session_name="nic-$(basename "$(realpath "${1:-.}")")${suffix}"
  tmux kill-session -t "$session_name" 2>/dev/null && echo "세션 '$session_name' 종료" || echo "세션 없음"
}

# nic-ls: 활성 nic 세션 목록 (AI 포함)
nic-ls() {
  tmux list-sessions 2>/dev/null | grep "^nic-" || echo "활성 nic 세션 없음"
}
