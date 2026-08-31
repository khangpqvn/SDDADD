#!/usr/bin/env bash
# Cập nhật SDD + ADD template cho repository đã adopt.
# Cách dùng: ./scripts/update.sh <template-path> [--dry-run] [--force-governance]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=0
FORCE_GOVERNANCE=0
SHOW_HELP=0
TEMPLATE_PATH=""

for arg in "$@"; do
  case $arg in
    --dry-run)       DRY_RUN=1 ;;
    --force-governance) FORCE_GOVERNANCE=1 ;;
    --help|-h)       SHOW_HELP=1 ;;
    *)
      if [ -z "$TEMPLATE_PATH" ]; then
        TEMPLATE_PATH="$arg"
      fi
      ;;
  esac
done

if [ "$SHOW_HELP" -eq 1 ] || [ -z "$TEMPLATE_PATH" ]; then
  echo -e "\n${BOLD}${CYAN}SDD + ADD Template Updater (Bash)${NC}"
  echo -e "Cập nhật skills, docs và shared protocols từ template gốc.\n"
  echo -e "${BOLD}Cách dùng:${NC}"
  echo -e "  ./scripts/update.sh <template-path> [--dry-run] [--force-governance]\n"
  echo -e "${BOLD}Flags:${NC}"
  echo -e "  --dry-run           Báo cáo thay đổi, không ghi file."
  echo -e "  --force-governance  Backup và overwrite AGENTS.md, CLAUDE.md, .agentignore; CONSTITUTION.md vẫn phải stage qua RFC."
  echo -e "\n${YELLOW}Ví dụ:${NC}"
  echo -e "  ./scripts/update.sh /path/to/sddadd-template"
  echo -e "  ./scripts/update.sh /path/to/sddadd-template --dry-run\n"
  exit 0
fi

if [ ! -d "$TEMPLATE_PATH" ]; then
  echo -e "\n${RED}[ERROR] Không tìm thấy template: $TEMPLATE_PATH${NC}\n"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$(cd "$TEMPLATE_PATH" && pwd)"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
STAGING_DIR="$TARGET_DIR/.sdd/updates"

# Đọc template version từ template nguồn.
TEMPLATE_VER="unknown"
if [ -f "$TEMPLATE_DIR/.sdd/template-version.md" ]; then
  TEMPLATE_VER="$(grep '^template-version:' "$TEMPLATE_DIR/.sdd/template-version.md" | awk '{print $2}')"
fi

INSTALLED_VER="unknown"
if [ -f "$TARGET_DIR/.sdd/template-version.md" ]; then
  INSTALLED_VER="$(grep '^template-version:' "$TARGET_DIR/.sdd/template-version.md" | awk '{print $2}')"
fi

echo -e "\n${BOLD}${CYAN}SDD + ADD Template Update${NC}"
echo -e "   Template source : $TEMPLATE_DIR"
echo -e "   Repository      : $TARGET_DIR"
echo -e "   Installed ver.  : $INSTALLED_VER"
echo -e "   Template ver.   : $TEMPLATE_VER"
[ "$DRY_RUN" -eq 1 ] && echo -e "   ${YELLOW}Mode: DRY RUN — không ghi file${NC}"
[ "$FORCE_GOVERNANCE" -eq 1 ] && echo -e "   ${YELLOW}Mode: FORCE GOVERNANCE — overwrite với backup${NC}"
echo ""

UPDATED=0
SKIPPED=0
STAGED=0

# ─── Hàm tiện ích ────────────────────────────────────────────────────────────

overwrite_file() {
  local src_rel="$1"
  local dest_rel="${2:-$1}"
  local src="$TEMPLATE_DIR/$src_rel"
  local dest="$TARGET_DIR/$dest_rel"

  if [ ! -f "$src" ]; then
    echo -e "  ${YELLOW}[!] Không có file nguồn, bỏ qua: $src_rel${NC}"
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -f "$dest" ] && diff -q "$src" "$dest" > /dev/null 2>&1; then
      echo -e "  [=] Không đổi : $dest_rel"
    else
      echo -e "  ${GREEN}[~] Sẽ update : $dest_rel${NC}"
      UPDATED=$((UPDATED + 1))
    fi
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo -e "  ${GREEN}[✓] Updated   : $dest_rel${NC}"
  UPDATED=$((UPDATED + 1))
}

stage_governance_file() {
  local src_rel="$1"
  local src="$TEMPLATE_DIR/$src_rel"
  local dest="$TARGET_DIR/$src_rel"
  local staged="$STAGING_DIR/$src_rel"

  if [ ! -f "$src" ]; then return; fi

  if [ "$FORCE_GOVERNANCE" -eq 1 ] && [ "$src_rel" != "CONSTITUTION.md" ]; then
    # Backup bản hiện tại rồi overwrite governance không thuộc Constitution.
    if [ -f "$dest" ]; then
      local backup="$dest.bak-$TIMESTAMP"
      [ "$DRY_RUN" -eq 0 ] && cp "$dest" "$backup"
      echo -e "  ${YELLOW}[B] Backup    : $src_rel → $(basename "$backup")${NC}"
    fi
    overwrite_file "$src_rel"
    return
  fi

  if [ "$FORCE_GOVERNANCE" -eq 1 ] && [ "$src_rel" = "CONSTITUTION.md" ]; then
    echo -e "  ${YELLOW}[!] CONSTITUTION.md luôn stage: cần RFC đã APPROVED trước khi merge.${NC}"
  fi

  # Mặc định: stage vào .sdd/updates/ để human review.
  if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "  ${CYAN}[S] Sẽ stage  : $src_rel → .sdd/updates/$src_rel${NC}"
    STAGED=$((STAGED + 1))
    return
  fi

  mkdir -p "$(dirname "$staged")"
  cp "$src" "$staged"
  echo -e "  ${CYAN}[S] Staged    : .sdd/updates/$src_rel${NC}"
  STAGED=$((STAGED + 1))
}

# ─── 1. Safe-overwrite: skills và shared protocols ───────────────────────────

echo -e "${BOLD}${BLUE}Bước 1: Cập nhật .claude/skills/ (safe overwrite)...${NC}"
if [ -d "$TEMPLATE_DIR/.claude/skills" ]; then
  while IFS= read -r -d '' src_file; do
    rel="${src_file#$TEMPLATE_DIR/}"
    overwrite_file "$rel"
  done < <(find "$TEMPLATE_DIR/.claude/skills" -type f -print0)
else
  echo -e "  ${YELLOW}[!] Không có .claude/skills/ trong template.${NC}"
fi

# ─── 2. Safe-overwrite: docs và scripts hạ tầng ──────────────────────────────

echo -e "\n${BOLD}${BLUE}Bước 2: Cập nhật docs/ và scripts hạ tầng...${NC}"
for f in \
  "docs/sdd-add-quickstart.md" \
  "docs/sdd-add-guide.md" \
  "docs/sdd-add-field-guide.md" \
  "docs/sdd-add-scenario-playbook.md" \
  "docs/architecture-profile-guide.md" \
  "docs/multi-agent-orchestration-guide.md" \
  "scripts/adopt.sh" \
  "scripts/adopt.ps1" \
  "scripts/self-heal.sh" \
  "scripts/template-smoke.sh" \
  "scripts/template-smoke.ps1" \
  "scripts/start-claude.sh" \
  "scripts/start-claude.ps1" \
  "scripts/update.sh" \
  "scripts/update.ps1"
do
  overwrite_file "$f"
done

# ─── 3. Review-required: governance files ────────────────────────────────────

echo -e "\n${BOLD}${BLUE}Bước 3: Governance files (staged để review)...${NC}"
for f in "CONSTITUTION.md" "AGENTS.md" "CLAUDE.md" ".agentignore"; do
  stage_governance_file "$f"
done

# ─── 4. Cập nhật template-version.md ─────────────────────────────────────────

echo -e "\n${BOLD}${BLUE}Bước 4: Cập nhật .sdd/template-version.md...${NC}"
if [ "$DRY_RUN" -eq 0 ]; then
  VERSION_FILE="$TARGET_DIR/.sdd/template-version.md"
  # Giữ adopted-at gốc, chỉ cập nhật template-version và last-updated.
  ADOPTED_AT=""
  if [ -f "$VERSION_FILE" ]; then
    ADOPTED_AT="$(grep '^adopted-at:' "$VERSION_FILE" | awk '{print $2}')"
  fi
  [ -z "$ADOPTED_AT" ] && ADOPTED_AT="$TIMESTAMP"

  TEMPLATE_SOURCE=""
  if [ -f "$VERSION_FILE" ]; then
    TEMPLATE_SOURCE="$(grep '^template-source:' "$VERSION_FILE" | sed 's/^template-source: *//')"
  fi
  [ -z "$TEMPLATE_SOURCE" ] && TEMPLATE_SOURCE="$TEMPLATE_DIR"

  cat > "$VERSION_FILE" <<EOF
# SDD + ADD Template Version

template-version: $TEMPLATE_VER
adopted-at: $ADOPTED_AT
last-updated: $TIMESTAMP
template-source: $TEMPLATE_SOURCE

---

## Hướng dẫn

File này được \`scripts/adopt.sh\` / \`adopt.ps1\` tạo khi áp dụng template lần đầu và được \`scripts/update.sh\` / \`update.ps1\` cập nhật sau mỗi lần update.

- \`template-version\`: version template tại thời điểm adopt / update gần nhất.
- \`adopted-at\`: timestamp lần adopt đầu tiên (ISO-8601).
- \`last-updated\`: timestamp lần update gần nhất (ISO-8601).
- \`template-source\`: URL hoặc path của template gốc (tuỳ chọn, để trace nguồn).

Không sửa file này thủ công. Dùng \`/sdd-template-update\` để kiểm tra và cập nhật template.
EOF
  echo -e "  ${GREEN}[✓] Updated   : .sdd/template-version.md (v$TEMPLATE_VER)${NC}"
else
  echo -e "  ${GREEN}[~] Sẽ update : .sdd/template-version.md (v$TEMPLATE_VER)${NC}"
fi

# ─── Báo cáo ─────────────────────────────────────────────────────────────────

echo -e "\n${BOLD}${GREEN}Update hoàn tất.${NC}"
echo -e "  Updated  : $UPDATED file(s)"
echo -e "  Staged   : $STAGED governance file(s) tại .sdd/updates/"
echo -e "  Skipped  : $SKIPPED file(s)"

if [ "$STAGED" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  echo -e "\n${BOLD}${CYAN}Bước tiếp theo:${NC}"
  echo -e "  1. Dùng '/sdd-template-update --review' để AI so sánh staged files với bản hiện tại."
  echo -e "  2. Merge thủ công các thay đổi phù hợp."
  echo -e "  3. Xoá .sdd/updates/ sau khi merge xong."
fi
