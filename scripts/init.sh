#!/usr/bin/env bash
# init.sh - 初始化脚本: 将项目中所有硬编码的原始用户路径替换为当前用户的 HOME 路径
#
# 用法:
#   cd /path/to/PhD-Research
#   bash scripts/init.sh          # 预览模式(dry run), 只显示将要替换的内容
#   bash scripts/init.sh --apply  # 实际执行替换
#
# 说明:
#   扫描项目内所有 .md / .json / .yaml / .yml 文件,
#   将其中的 OLD_HOME (原始作者路径) 替换为当前机器的 $HOME.
#   如果已经是当前用户, 则跳过不做任何修改.

set -euo pipefail

# 项目根目录 (脚本所在目录的上一级)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 从文件中自动检测原始硬编码路径
OLD_HOME=$(grep -r --include="*.md" --include="*.json" --include="*.yaml" --include="*.yml" \
  -h "/Users/" "$REPO_ROOT" 2>/dev/null \
  | grep -oE '/Users/[^/]+' | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')

NEW_HOME="$HOME"

DRY_RUN=true
[[ "${1:-}" == "--apply" ]] && DRY_RUN=false

log()  { printf '[init] %s\n' "$*"; }

# 前置检查
if [[ -z "$OLD_HOME" ]]; then
  log "未检测到硬编码的用户路径, 无需替换."
  exit 0
fi

if [[ "$OLD_HOME" == "$NEW_HOME" ]]; then
  log "当前用户路径与项目内路径一致 ($NEW_HOME), 无需替换."
  exit 0
fi

log "检测到原始路径: $OLD_HOME"
log "当前用户路径:   $NEW_HOME"
echo ""

# 扫描受影响文件
mapfile -t FILES < <(
  grep -rl --include="*.md" --include="*.json" --include="*.yaml" --include="*.yml" \
    "$OLD_HOME" "$REPO_ROOT" 2>/dev/null
)

if [[ ${#FILES[@]} -eq 0 ]]; then
  log "没有找到包含 $OLD_HOME 的文件."
  exit 0
fi

log "共找到 ${#FILES[@]} 个文件需要处理:"
for f in "${FILES[@]}"; do
  rel="${f#$REPO_ROOT/}"
  count=$(grep -c "$OLD_HOME" "$f" 2>/dev/null || true)
  printf '  %-60s  (%d 处)\n' "$rel" "$count"
done
echo ""

# 执行替换
if $DRY_RUN; then
  log "以上是预览 (dry run). 使用 --apply 参数执行实际替换:"
  echo ""
  echo "  bash scripts/init.sh --apply"
  echo ""
else
  log "开始替换..."
  for f in "${FILES[@]}"; do
    # macOS sed 需要 -i '', Linux sed 需要 -i
    if sed --version 2>/dev/null | grep -q GNU; then
      sed -i "s|${OLD_HOME}|${NEW_HOME}|g" "$f"
    else
      sed -i '' "s|${OLD_HOME}|${NEW_HOME}|g" "$f"
    fi
    rel="${f#$REPO_ROOT/}"
    log "  已处理: $rel"
  done
  echo ""
  log "完成! 所有路径已替换为 $NEW_HOME"
  log "验证: grep -r '$NEW_HOME' . --include='*.md' -l"
fi
