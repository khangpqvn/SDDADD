#!/usr/bin/env bash
# Script tích hợp SDD + ADD bằng Bash cho Linux và macOS.
# Cách dùng: ./scripts/adopt.sh <duong-dan-repo-dich> [--force]

set -e

# Mã màu ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # Không màu

SHOW_HELP=0
FORCE=0
TARGET_PATH=""

for arg in "$@"; do
  case $arg in
    --force|-f)
      FORCE=1
      ;;
    --help|-h)
      SHOW_HELP=1
      ;;
    *)
      if [ -z "$TARGET_PATH" ]; then
        TARGET_PATH="$arg"
      fi
      ;;
  esac
done

if [ "$SHOW_HELP" -eq 1 ] || [ -z "$TARGET_PATH" ]; then
  echo -e "\n${BOLD}${CYAN}🚀 Công cụ tích hợp SDD + ADD bằng Bash (Linux / macOS)${NC}"
  echo -e "${CYAN}=================================================${NC}"
  echo -e "Tích hợp hạ tầng SDD + ADD vào repository có sẵn mà không cần phụ thuộc ngoài.\n"
  echo -e "${BOLD}Cách dùng:${NC}"
  echo -e "  ./scripts/adopt.sh <duong-dan-repo-dich> [--force]\n"
  echo -e "${YELLOW}Ví dụ:${NC}"
  echo -e "  ./scripts/adopt.sh /home/user/projects/my-api"
  echo -e "  ./scripts/adopt.sh ../my-existing-app\n"
  exit 0
fi

# Xác định thư mục script và thư mục template.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -d "$TARGET_PATH" ]; then
  echo -e "\n${RED}❌ Lỗi: Không tìm thấy thư mục đích: $TARGET_PATH${NC}\n"
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_PATH" && pwd)"

echo -e "\n${BOLD}${CYAN}🔍 Khởi tạo tích hợp SDD + ADD${NC}"
echo -e "   Nguồn template: $TEMPLATE_DIR"
echo -e "   Thư mục đích: $TARGET_DIR\n"

# Hàm hỗ trợ sao chép tệp, chỉ ghi đè khi có --force.
copy_file() {
  local src_rel="$1"
  local dest_rel="$2"
  local src="$TEMPLATE_DIR/$src_rel"
  local dest="$TARGET_DIR/$dest_rel"
  local dest_parent="$(dirname "$dest")"

  if [ ! -f "$src" ]; then
    echo -e "  ${YELLOW}[!] Không tìm thấy tệp nguồn, bỏ qua: $src_rel${NC}"
    return
  fi

  mkdir -p "$dest_parent"

  if [ -f "$dest" ] && [ "$FORCE" -eq 0 ]; then
    echo -e "  ${YELLOW}[=] Tệp đã tồn tại, giữ nguyên: $dest_rel${NC}"
    return
  fi

  cp "$src" "$dest"
  echo -e "  ${GREEN}[✓] Đã sao chép: $dest_rel${NC}"
}

# Hàm hỗ trợ sao chép nội dung thư mục đệ quy.
copy_folder() {
  local src_rel="$1"
  local dest_rel="$2"
  local src="$TEMPLATE_DIR/$src_rel"
  local dest="$TARGET_DIR/$dest_rel"

  if [ ! -d "$src" ]; then
    return
  fi

  mkdir -p "$dest"
  cp -R "$src/"* "$dest/" 2>/dev/null || true
  echo -e "  ${GREEN}[✓] Đã sao chép nội dung thư mục: $dest_rel/${NC}"
}

echo -e "${BOLD}${BLUE}📦 Bước 1: Sao chép slash commands trong .claude/skills/...${NC}"
copy_folder ".claude/skills" ".claude/skills"
copy_file ".claude/skills/_shared/ai-review-protocol.md" ".claude/skills/_shared/ai-review-protocol.md"
copy_file ".claude/skills/_shared/architecture-profile-protocol.md" ".claude/skills/_shared/architecture-profile-protocol.md"

echo -e "\n${BOLD}${BLUE}📄 Bước 2: Sao chép governance và context hygiene...${NC}"
copy_file "CONSTITUTION.md" "CONSTITUTION.md"
copy_file "AGENTS.md" "AGENTS.md"
copy_file "CLAUDE.md" "CLAUDE.md"
copy_file ".agentignore" ".agentignore"

echo -e "\n${BOLD}${BLUE}📁 Bước 3: Khởi tạo hạ tầng đặc tả .sdd/...${NC}"
copy_file ".sdd/README.md" ".sdd/README.md"
copy_file ".sdd/architecture-profile.md" ".sdd/architecture-profile.md"
copy_file ".sdd/shared_context.md" ".sdd/shared_context.md"
copy_file ".sdd/mcp-config.yaml" ".sdd/mcp-config.yaml"
copy_file ".sdd/constraints/global.md" ".sdd/constraints/global.md"
copy_file ".sdd/constraints/business.md" ".sdd/constraints/business.md"
copy_file ".sdd/constraints/safety.md" ".sdd/constraints/safety.md"
mkdir -p "$TARGET_DIR/.sdd/features"
copy_file ".sdd/features/.gitkeep" ".sdd/features/.gitkeep"
mkdir -p "$TARGET_DIR/.sdd/reviews"
copy_file ".sdd/reviews/.gitkeep" ".sdd/reviews/.gitkeep"
mkdir -p "$TARGET_DIR/.sdd/rfcs"
copy_file ".sdd/rfcs/.gitkeep" ".sdd/rfcs/.gitkeep"

echo -e "\n${BOLD}${BLUE}📚 Bước 4: Sao chép tài liệu và script hỗ trợ...${NC}"
copy_file "docs/sdd-add-guide.md" "docs/sdd-add-guide.md"
copy_file "docs/architecture-profile-guide.md" "docs/architecture-profile-guide.md"
copy_file "docs/multi-agent-orchestration-guide.md" "docs/multi-agent-orchestration-guide.md"
copy_file "scripts/self-heal.sh" "scripts/self-heal.sh"
copy_file "scripts/update.sh" "scripts/update.sh"

echo -e "\n${BOLD}${BLUE}🏷️  Bước 5: Ghi template version...${NC}"
TEMPLATE_VER="unknown"
if [ -f "$TEMPLATE_DIR/.sdd/template-version.md" ]; then
  TEMPLATE_VER="$(grep '^template-version:' "$TEMPLATE_DIR/.sdd/template-version.md" | awk '{print $2}')"
fi
ADOPTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
VERSION_FILE="$TARGET_DIR/.sdd/template-version.md"
cat > "$VERSION_FILE" <<EOF
# SDD + ADD Template Version

template-version: $TEMPLATE_VER
adopted-at: $ADOPTED_AT
last-updated: $ADOPTED_AT
template-source: $TEMPLATE_DIR

---

## Hướng dẫn

File này được \`scripts/adopt.sh\` / \`adopt.ps1\` tạo khi áp dụng template lần đầu và được \`scripts/update.sh\` / \`update.ps1\` cập nhật sau mỗi lần update.

- \`template-version\`: version template tại thời điểm adopt / update gần nhất.
- \`adopted-at\`: timestamp lần adopt đầu tiên (ISO-8601).
- \`last-updated\`: timestamp lần update gần nhất (ISO-8601).
- \`template-source\`: URL hoặc path của template gốc (tuỳ chọn, để trace nguồn).

Không sửa file này thủ công. Dùng \`/sdd-template-update\` để kiểm tra và cập nhật template.
EOF
echo -e "  ${GREEN}[✓] Đã ghi: .sdd/template-version.md (v$TEMPLATE_VER, adopted $ADOPTED_AT)${NC}"

echo -e "\n${BOLD}${GREEN}🎉 Tích hợp SDD + ADD hoàn tất.${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "Repository đích '$TARGET_DIR' đã có SDD + ADD.\n"
echo -e "${BOLD}Bước tiếp theo trong repository đích:${NC}"
echo -e "  1. Mở repository đích trong Claude Code hoặc AI IDE."
echo -e "  2. Chạy '/sdd-adopt' để khảo sát và đề xuất Architecture Profile theo tech stack thực tế."
echo -e "  3. Human Director review Architecture Profile; chỉ duyệt binding và command có evidence."
echo -e "  4. Bắt đầu feature bằng '/sdd-context --feature=<slug>'."
echo -e "  5. Đảo ngược Spec cho module cũ bằng '/sdd-adopt --reverse-feature=<slug> --path=<module-path>'."
echo -e "  6. Review AI recommendation trước mọi công việc downstream.\n"
