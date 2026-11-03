#!/usr/bin/env bash
# Claude Code statusline (2줄)
#   dev1 ~/github/waylake-ssot   main* ↑1  +40 -27
#   Opus 5.5 medium │ ctx ●○○○○ 7% 70k/1M │ cache 94% exp 54m │ $0.63 │ 5h ●●●○○ 61% ↻2h10m  7d ●●●○○ 56% ↻3d
# 요구: bash, jq, git(선택). macOS·Linux 공통.
# 설정: ~/.claude/settings.json 에
#   "statusLine": { "type": "command", "command": "~/dotfiles/claude/statusline.sh", "padding": 0, "refreshInterval": 30 }
# 참고: MuQY1818/claude-code-statusline(캐시 만료 카운트다운), KitchenSink4AI(점 게이지),
#       Owloops/claude-powerline(git ahead/behind), raba.pl(흐린 구분선 그룹)
input=$(cat)
if ! command -v jq >/dev/null 2>&1; then printf '%s %s (jq 가 없어 간단 표시)' "$(hostname -s)" "${PWD/#$HOME/~}"; exit 0; fi
j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }
now=$(date +%s)

dim=$'\e[2m'; bold=$'\e[1m'; rst=$'\e[0m'
cyan=$'\e[36m'; blue=$'\e[34m'; mag=$'\e[35m'; yel=$'\e[33m'; grn=$'\e[32m'; red=$'\e[31m'
gap="  "
bar="${dim} │ ${rst}"

# 0-100 → 초록/노랑/빨강 (높을수록 나쁨)
level() { local p=${1%.*}; if [ "$p" -ge 80 ]; then printf '%s' "$red"; elif [ "$p" -ge 50 ]; then printf '%s' "$yel"; else printf '%s' "$grn"; fi; }
# 5칸 점 게이지
gauge() { local p=${1%.*} n i s=""; n=$(( (p + 10) / 20 )); [ "$n" -gt 5 ] && n=5
  for i in 1 2 3 4 5; do [ "$i" -le "$n" ] && s+="●" || s+="○"; done; printf '%s' "$s"; }
# 흐린 라벨 + 색 값
kv() { printf '%s%s%s %s%s%s' "$dim" "$1" "$rst" "$2" "$3" "$rst"; }
# 남은 초 → 2h10m / 3d4h / 54m
dur() { local s=$1; if [ "$s" -ge 86400 ]; then printf '%dd%dh' $((s/86400)) $(((s%86400)/3600));
  elif [ "$s" -ge 3600 ]; then printf '%dh%dm' $((s/3600)) $(((s%3600)/60)); else printf '%dm' $((s/60)); fi; }
# 토큰 수 → 70k / 1M
tok() { local n=$1; if [ "$n" -ge 1000000 ]; then
    if [ $((n % 1000000)) -eq 0 ]; then printf '%dM' $((n/1000000)); else printf '%d.%dM' $((n/1000000)) $(((n%1000000)/100000)); fi
  elif [ "$n" -ge 1000 ]; then printf '%dk' $((n/1000)); else printf '%d' "$n"; fi; }
join() { local out="" s; for s in "$@"; do [ -n "$s" ] && out+="${out:+$gap}$s"; done; printf '%s' "$out"; }

# ── 1줄: 위치 ─────────────────────────────────────
dir=$(j '.workspace.current_dir'); [ -z "$dir" ] && dir=$(j '.cwd'); [ -z "$dir" ] && dir=$PWD
sid=$(j '.session_id')

# git: 브랜치, dirty, upstream 대비 ahead/behind (세션별 5초 캐시)
# 파일 수정 시각(초): GNU stat 은 -c %Y, macOS stat 은 -f %m
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }
gcache="${TMPDIR:-/tmp}/claude-statusline-${sid:-x}-$(printf '%s' "$dir" | cksum | cut -d' ' -f1)"
if [ -f "$gcache" ] && [ $(( now - $(mtime "$gcache") )) -lt 5 ]; then
  git_seg=$(cat "$gcache")
else
  git_seg=""
  if branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null \
              || git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
    git_seg="${mag} ${branch}${rst}"
    [ -n "$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | head -1)" ] && git_seg+="${yel}*${rst}"
    if ab=$(git -C "$dir" --no-optional-locks rev-list --left-right --count '@{u}...HEAD' 2>/dev/null); then
      read -r behind ahead <<<"$ab"
      [ "$ahead" -gt 0 ] && git_seg+=" ${cyan}↑${ahead}${rst}"
      [ "$behind" -gt 0 ] && git_seg+=" ${yel}↓${behind}${rst}"
    fi
  fi
  printf '%s' "$git_seg" > "$gcache" 2>/dev/null
fi

add=$(j '.cost.total_lines_added'); del=$(j '.cost.total_lines_removed')
diff_seg=""
[ "${add:-0}" != 0 ] || [ "${del:-0}" != 0 ] && diff_seg="${grn}+${add:-0}${rst} ${red}-${del:-0}${rst}"

line1="${cyan}$(hostname -s)${rst} ${blue}${dir/#$HOME/\~}${rst}"
[ -n "$git_seg" ] && line1+="   ${git_seg}"
[ -n "$diff_seg" ] && line1+="  ${diff_seg}"

# ── 2줄: 모델 │ 컨텍스트 │ 캐시 │ 비용 │ 한도 ─────
model=$(j '.model.display_name'); effort=$(j '.effort.level')
model_seg=""
if [ -n "$model" ]; then
  model_seg="${bold}${model}${rst}"
  [ -n "$effort" ] && model_seg+=" ${dim}${effort}${rst}"
  [ "$(j '.fast_mode')" = "true" ] && model_seg+=" ${yel}fast${rst}"
fi

# 컨텍스트: 게이지 + 현재/최대 토큰
ctx_seg=""; ctx=$(j '.context_window.used_percentage')
if [ -n "$ctx" ]; then
  c=$(level "$ctx")
  ctx_seg="${dim}ctx${rst} ${c}$(gauge "$ctx") ${ctx%.*}%${rst}"
  used=$(jq -r '.context_window.current_usage // empty | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' <<<"$input" 2>/dev/null)
  size=$(j '.context_window.context_window_size')
  [ -n "$used" ] && [ -n "$size" ] && ctx_seg+=" ${dim}$(tok "$used")/$(tok "$size")${rst}"
fi

# 캐시: 세션 적중률(prompt_cache.hit_ratio) + 만료 카운트다운
cache_seg=""; hit=$(j '.prompt_cache.hit_ratio')
if [ -n "$hit" ]; then
  hit=$(awk -v h="$hit" 'BEGIN{printf "%d", h*100}')
else  # 구버전 폴백: 마지막 요청 기준
  hit=$(jq -r '.context_window.current_usage // empty | (.cache_read_input_tokens // 0) as $r
    | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + $r) as $t
    | if $t > 0 then ($r * 100 / $t | floor) else empty end' <<<"$input" 2>/dev/null)
fi
if [ -n "$hit" ]; then
  cache_seg=$(kv cache "$(level $((100 - hit)))" "${hit}%")
  exp=$(j '.prompt_cache.expires_at'); ttl=$(j '.prompt_cache.ttl')
  if [ -n "$exp" ]; then
    left=$(( ${exp%.*} - now ))
    if [ "$left" -le 0 ]; then
      cache_seg+=" ${red}cold${rst}"
    else
      # 1h TTL이면 10분, 5m TTL이면 1분 남았을 때 노랑
      warn=600; [ "$ttl" = "5m" ] && warn=60
      [ "$left" -le "$warn" ] && tc=$yel || tc=$dim
      cache_seg+=" ${dim}exp${rst} ${tc}$(dur "$left")${rst}"
    fi
  fi
  [ "$ttl" = "5m" ] && cache_seg+=" ${yel}5m${rst}"
fi

# API 환산 비용 (세션 누적, 표준 단가 기준 추정치)
cost_seg=""; usd=$(j '.cost.total_cost_usd')
[ -n "$usd" ] && [ "$(awk -v u="$usd" 'BEGIN{print (u>=0.005)}')" = 1 ] && cost_seg="${yel}\$$(printf '%.2f' "$usd")${rst}"

# 요금제 한도: 게이지 + 사용률 + 리셋까지
limit() { # $1 라벨, $2 jq 경로
  local p r s; p=$(j ".rate_limits.$2.used_percentage"); [ -z "$p" ] && return
  s="${dim}$1${rst} $(level "$p")$(gauge "$p") ${p%.*}%${rst}"
  r=$(j ".rate_limits.$2.resets_at")
  [ -n "$r" ] && [ $(( ${r%.*} - now )) -gt 0 ] && s+=" ${dim}↻$(dur $(( ${r%.*} - now )))${rst}"
  printf '%s' "$s"
}
lim_seg=$(join "$(limit 5h five_hour)" "$(limit 7d seven_day)")

line2=""
for g in "$model_seg" "$ctx_seg" "$(join "$cache_seg" "$cost_seg")" "$lim_seg"; do
  [ -n "$g" ] && line2+="${line2:+$bar}$g"
done

printf '%s\n%s' "$line1" "$line2"
