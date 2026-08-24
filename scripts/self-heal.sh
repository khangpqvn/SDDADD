#!/usr/bin/env bash
# self-heal.sh — Self-Healing Loop cho workflow SDD + ADD.
# Tham chiếu: Slide 11.4 — Automated Self-Healing Loop.
#
# Luồng: chạy approved test → lấy lỗi → gọi Claude sửa → chạy lại test → Human review.
# An toàn: tối đa ba lần sửa; cạn lần thử thì escalate Human Director.
#
# Cách dùng:
#   ./scripts/self-heal.sh --test-cmd "<approved test command>"
#   ./scripts/self-heal.sh --test-cmd "<approved test command>" --feature=auth
#   ./scripts/self-heal.sh --test-cmd "<approved test command>" --max-attempts=2
#   ./scripts/self-heal.sh --test-cmd "<approved test command>" --dry-run
#
# Command phải khớp approved test command trong .sdd/architecture-profile.md.
# Script không tự commit; Human Director kiểm soát delivery.

set -euo pipefail

# Cấu hình
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
TEST_CMD="${TEST_CMD:-}"
FEATURE_SLUG=""
DRY_RUN=false
LOG_DIR=".sdd/reviews"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="${LOG_DIR}/self-heal-${TIMESTAMP}.log"

# Màu terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Không màu

# Phân tích tham số
for arg in "$@"; do
  case $arg in
    --test-cmd=*) TEST_CMD="${arg#*=}" ;;
    --feature=*) FEATURE_SLUG="${arg#*=}" ;;
    --max-attempts=*) MAX_ATTEMPTS="${arg#*=}" ;;
    --dry-run) DRY_RUN=true ;;
    *) echo "Tham số không hợp lệ: $arg"; exit 1 ;;
  esac
done

# Kiểm tra an toàn
if [[ -z "$TEST_CMD" ]]; then
  echo "[ERROR] Bắt buộc có --test-cmd. Hãy chọn và approve exact test command trong .sdd/architecture-profile.md trước."
  exit 1
fi

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${BLUE}[DRY RUN] Cấu hình Self-Heal:${NC}"
  echo "  Test command : $TEST_CMD"
  echo "  Max attempts : $MAX_ATTEMPTS"
  echo "  Feature scope: ${FEATURE_SLUG:-all}"
  echo "  Log file     : $LOG_FILE"
  exit 0
fi

# Bảo đảm thư mục review tồn tại.
mkdir -p "$LOG_DIR"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${RED}[ERROR] Không ở trong Git repository. Dừng.${NC}"
  exit 1
fi

# Hàm ghi log
log() { echo -e "$1" | tee -a "$LOG_FILE"; }

log_section() {
  log ""
  log "${BLUE}══════════════════════════════════════════${NC}"
  log "${BLUE}  $1${NC}"
  log "${BLUE}══════════════════════════════════════════${NC}"
}

# Chạy exact test command đã approved.
run_tests() {
  local output
  local exit_code=0
  output=$(eval "$TEST_CMD" 2>&1) || exit_code=$?
  echo "$output" >> "$LOG_FILE"
  echo "$output"
  return "$exit_code"
}

# Trích xuất tên test lỗi và error message cho Claude.
extract_errors() {
  local test_output="$1"
  echo "$test_output" | grep -E "(FAIL|✗|×|Error:|expect\(|●)" | head -50
}

# Gọi Claude CLI để phân tích và áp dụng sửa đổi.
invoke_claude_fix() {
  local error_summary="$1"
  local attempt="$2"

  log "${YELLOW}[ATTEMPT $attempt/$MAX_ATTEMPTS] Gọi Claude để phân tích lỗi...${NC}"

  if ! command -v claude &> /dev/null; then
    log "${YELLOW}[WARN] Không tìm thấy Claude CLI. Bỏ qua tự động sửa.${NC}"
    log "${YELLOW}       Cài đặt: https://claude.ai/code${NC}"
    return 1
  fi

  local prompt
  prompt=$(cat <<EOF
Bạn là Senior Engineer đang sửa test failure.
Phân tích các lỗi test sau và sửa code:

TEST THẤT BẠI:
$error_summary

QUY TẮC:
1. Tuân thủ Fix the Spec, not the Code — nếu business logic sai, cập nhật .sdd/features/*/SPEC.md.
2. Tuân thủ constraint trong CONSTITUTION.md.
3. Không hardcode secret, không dùng raw DELETE không có WHERE.
4. Sửa root cause, không chỉ sửa symptom.
5. Giữ thay đổi tối thiểu và đúng scope.

Áp dụng sửa đổi ngay.
EOF
)

  claude --print "$prompt" 2>> "$LOG_FILE" || return 1
}

# Tạo incident report để Human Director xử lý.
escalate_to_human() {
  local error_summary="$1"
  local incident_file="${LOG_DIR}/self-heal-incident-${TIMESTAMP}.md"

  cat > "$incident_file" <<EOF
# Báo cáo sự cố Self-Heal

**Ngày:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Status:** ESCALATED — Requires Human Review
**Feature:** ${FEATURE_SLUG:-all}
**Số lần thử:** $MAX_ATTEMPTS (đã cạn)

## Lỗi test thất bại

\`\`\`
$error_summary
\`\`\`

## Bước tiếp theo cho Human Director

1. Review lỗi bên trên.
2. Kiểm tra Spec có cần cập nhật không: \`.sdd/features/${FEATURE_SLUG:-*}/SPEC.md\`.
3. Áp dụng sửa đổi thủ công.
4. Chạy lại: \`./scripts/self-heal.sh --test-cmd "<approved test command>" ${FEATURE_SLUG:+--feature=$FEATURE_SLUG}\`.

## Log file

\`$LOG_FILE\`
EOF

  log ""
  log "${RED}╔══════════════════════════════════════════╗${NC}"
  log "${RED}║  ⚠️  CẦN ESCALATE                         ║${NC}"
  log "${RED}║  Đã cạn $MAX_ATTEMPTS lần thử                     ║${NC}"
  log "${RED}║  Incident: $incident_file${NC}"
  log "${RED}╚══════════════════════════════════════════╝${NC}"
  log ""
  log "AI RECOMMENDATION: PENDING HUMAN REVIEW"
  log "HUMAN DECISION REQUIRED: Review test failures and fix Spec or code"
  log "NEXT STEP: Human Director reviews $incident_file"
}

main() {
  log_section "Bắt đầu Self-Healing Loop — $(date)"
  log "Cấu hình: cmd='$TEST_CMD' | max_attempts=$MAX_ATTEMPTS | feature=${FEATURE_SLUG:-all}"

  local attempt=0
  local test_output
  local errors

  log_section "Lần chạy test đầu tiên"
  if test_output=$(run_tests 2>&1); then
    log "${GREEN}✅ Tất cả test PASS ngay từ đầu. Không cần self-heal.${NC}"
    exit 0
  fi

  errors=$(extract_errors "$test_output")
  log "${RED}❌ Test FAILED. Bắt đầu self-heal loop...${NC}"
  log "Lỗi phát hiện:"
  log "$errors"

  while [[ "$attempt" -lt "$MAX_ATTEMPTS" ]]; do
    attempt=$((attempt + 1))
    log_section "Lần self-heal $attempt / $MAX_ATTEMPTS"

    if ! invoke_claude_fix "$errors" "$attempt"; then
      log "${YELLOW}[WARN] Claude không sửa được hoặc bỏ qua lần $attempt.${NC}"
    fi

    log "Chạy lại test sau lần sửa $attempt..."
    if test_output=$(run_tests 2>&1); then
      log ""
      log "${GREEN}╔══════════════════════════════════════════╗${NC}"
      log "${GREEN}║  ✅ TẤT CẢ TEST PASS sau lần $attempt             ║${NC}"
      log "${GREEN}╚══════════════════════════════════════════╝${NC}"
      log ""
      log "${GREEN}Self-Heal hoàn tất. Thay đổi vẫn uncommitted để Human review. Log: $LOG_FILE${NC}"
      exit 0
    fi

    errors=$(extract_errors "$test_output")
    log "${RED}Test vẫn thất bại sau lần $attempt.${NC}"

    if [[ "$attempt" -lt "$MAX_ATTEMPTS" ]]; then
      log "Thử lại với error context đã cập nhật..."
    fi
  done

  escalate_to_human "$errors"
  exit 1
}

main
