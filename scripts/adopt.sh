#!/usr/bin/env bash
# SDD + ADD Native Adoption Script for Linux and macOS
# Usage: ./scripts/adopt.sh <target-repo-path> [--force]

set -e

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

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

if [ $SHOW_HELP -eq 1 ] || [ -z "$TARGET_PATH" ]; then
  echo -e "\n${BOLD}${CYAN}🚀 SDD + ADD Native Migration & Adoption Tool (Linux / macOS)${NC}"
  echo -e "${CYAN}=================================================${NC}"
  echo -e "Integrate SDD + ADD framework into an existing repository natively.\n"
  echo -e "${BOLD}Usage:${NC}"
  echo -e "  ./scripts/adopt.sh <target-repo-path> [--force]\n"
  echo -e "${YELLOW}Examples:${NC}"
  echo -e "  ./scripts/adopt.sh /home/user/projects/my-api"
  echo -e "  ./scripts/adopt.sh ../my-existing-app\n"
  exit 0
fi

# Resolve script directory and target directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -d "$TARGET_PATH" ]; then
  echo -e "\n${RED}❌ Error: Target directory does not exist: $TARGET_PATH${NC}\n"
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_PATH" && pwd)"

echo -e "\n${BOLD}${CYAN}🔍 SDD + ADD Native Adoption Initialized${NC}"
echo -e "   Template Source: $TEMPLATE_DIR"
echo -e "   Target Directory: $TARGET_DIR\n"

# Helper functions
copy_file() {
  local src_rel="$1"
  local dest_rel="$2"
  local src="$TEMPLATE_DIR/$src_rel"
  local dest="$TARGET_DIR/$dest_rel"
  local dest_parent="$(dirname "$dest")"

  if [ ! -f "$src" ]; then
    echo -e "  ${YELLOW}[!] Source file missing, skipped: $src_rel${NC}"
    return
  fi

  mkdir -p "$dest_parent"

  if [ -f "$dest" ] && [ $FORCE -eq 0 ]; then
    echo -e "  ${YELLOW}[=] File already exists, preserved: $dest_rel${NC}"
    return
  fi

  cp "$src" "$dest"
  echo -e "  ${GREEN}[✓] Copied: $dest_rel${NC}"
}

copy_folder() {
  local src_rel="$1"
  local dest_rel="$2"
  local src="$TEMPLATE_DIR/$src_rel"
  local dest="$TARGET_DIR/$dest_rel"

  if [ ! -d "$src" ]; then
    return
  fi

  mkdir -p "$dest"

  # Copy directory contents recursively using cp -R
  cp -R "$src/"* "$dest/" 2>/dev/null || true
  echo -e "  ${GREEN}[✓] Copied folder contents: $dest_rel/${NC}"
}

echo -e "${BOLD}${BLUE}📦 Step 1: Copying .claude/skills/ slash commands...${NC}"
copy_folder ".claude/skills" ".claude/skills"

echo -e "\n${BOLD}${BLUE}📄 Step 2: Copying Layer 1 Governance Files...${NC}"
copy_file "CONSTITUTION.md" "CONSTITUTION.md"
copy_file "AGENTS.md" "AGENTS.md"
copy_file "CLAUDE.md" "CLAUDE.md"

echo -e "\n${BOLD}${BLUE}📁 Step 3: Initializing .sdd/ specification framework...${NC}"
copy_file ".sdd/README.md" ".sdd/README.md"
copy_file ".sdd/shared_context.md" ".sdd/shared_context.md"
mkdir -p "$TARGET_DIR/.sdd/features"
copy_file ".sdd/features/.gitkeep" ".sdd/features/.gitkeep"
mkdir -p "$TARGET_DIR/.sdd/rfcs"
copy_file ".sdd/rfcs/.gitkeep" ".sdd/rfcs/.gitkeep"

echo -e "\n${BOLD}${BLUE}📚 Step 4: Copying Documentation...${NC}"
copy_file "docs/sdd-add-guide.md" "docs/sdd-add-guide.md"

echo -e "\n${BOLD}${GREEN}🎉 SDD + ADD Native Migration Successful!${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "Target repo at '${TARGET_DIR}' is now SDD + ADD enabled.\n"
echo -e "${BOLD}Next steps for the target project:${NC}"
echo -e "  1. Open the target repo in Claude Code or your AI IDE."
echo -e "  2. Run '/sdd-adopt' inside the target project to customize governance for its specific tech stack."
echo -e "  3. Start a new feature using '/sdd-context --feature=<slug>'."
echo -e "  4. To reverse-engineer spec for a legacy module: '/sdd-adopt --reverse-feature=<slug> --path=<module-path>'\n"
