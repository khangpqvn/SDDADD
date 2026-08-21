#!/usr/bin/env node

/**
 * SDD + ADD Adoption / Migration Script
 * Cross-platform script for Linux, macOS, and Windows.
 *
 * Usage:
 *   node scripts/adopt.js <target-repo-path>
 *
 * Examples:
 *   node scripts/adopt.js /path/to/my-existing-project
 *   node scripts/adopt.js C:\Projects\my-existing-project
 *   node scripts/adopt.js ../my-existing-project
 */

const fs = require('fs');
const path = require('path');

// Colors for terminal output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  red: '\x1b[31m'
};

function log(msg, color = colors.reset) {
  console.log(`${color}${msg}${colors.reset}`);
}

// 1. Parse target path parameter
const args = process.argv.slice(2);
if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
  log('\n🚀 SDD + ADD Migration & Adoption Tool', colors.bright + colors.cyan);
  log('=================================================', colors.cyan);
  log('Integrate SDD + ADD framework into an existing repository (Linux, macOS, Windows).\n');
  log('Usage:', colors.bright);
  log('  node scripts/adopt.js <target-repo-path> [--force]\n');
  log('Examples:', colors.yellow);
  log('  node scripts/adopt.js /home/user/projects/my-api');
  log('  node scripts/adopt.js C:\\Projects\\my-legacy-app');
  log('  node scripts/adopt.js ./my-existing-app\n');
  process.exit(args.length === 0 ? 1 : 0);
}

const targetInputPath = args[0];
const isForce = args.includes('--force');
const targetDir = path.resolve(process.cwd(), targetInputPath);
const templateDir = path.resolve(__dirname, '..');

log(`\n🔍 SDD + ADD Adoption Initialized`, colors.bright + colors.cyan);
log(`   Template Source: ${templateDir}`);
log(`   Target Directory: ${targetDir}\n`);

// 2. Validate target directory
if (!fs.existsSync(targetDir)) {
  log(`❌ Error: Target directory does not exist: ${targetDir}`, colors.red);
  process.exit(1);
}

const stats = fs.statSync(targetDir);
if (!stats.isDirectory()) {
  log(`❌ Error: Target path is not a directory: ${targetDir}`, colors.red);
  process.exit(1);
}

// Helper: Ensure directory exists
function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    log(`  [+] Created directory: ${path.relative(targetDir, dirPath)}`, colors.green);
  }
}

// Helper: Copy file safely
function copyFile(srcRel, destRel, overwrite = false) {
  const src = path.join(templateDir, srcRel);
  const dest = path.join(targetDir, destRel);

  if (!fs.existsSync(src)) {
    log(`  [!] Source file missing, skipped: ${srcRel}`, colors.yellow);
    return;
  }

  ensureDir(path.dirname(dest));

  if (fs.existsSync(dest) && !overwrite && !isForce) {
    log(`  [=] File already exists, preserved: ${destRel}`, colors.yellow);
    return;
  }

  fs.copyFileSync(src, dest);
  log(`  [✓] Copied: ${destRel}`, colors.green);
}

// Helper: Copy folder recursively
function copyFolder(srcFolderRel, destFolderRel, overwrite = false) {
  const srcFolder = path.join(templateDir, srcFolderRel);
  const destFolder = path.join(targetDir, destFolderRel);

  if (!fs.existsSync(srcFolder)) return;

  ensureDir(destFolder);

  const items = fs.readdirSync(srcFolder);
  for (const item of items) {
    const srcItem = path.join(srcFolder, item);
    const destItem = path.join(destFolder, item);
    const relItemSrc = path.join(srcFolderRel, item);
    const relItemDest = path.join(destFolderRel, item);

    const itemStat = fs.statSync(srcItem);
    if (itemStat.isDirectory()) {
      copyFolder(relItemSrc, relItemDest, overwrite);
    } else {
      copyFile(relItemSrc, relItemDest, overwrite);
    }
  }
}

try {
  log(`📦 Step 1: Copying .claude/skills/ slash commands...`, colors.bright + colors.blue);
  copyFolder('.claude/skills', '.claude/skills', true);

  log(`\n📄 Step 2: Copying Layer 1 Governance Files...`, colors.bright + colors.blue);
  copyFile('CONSTITUTION.md', 'CONSTITUTION.md', isForce);
  copyFile('AGENTS.md', 'AGENTS.md', isForce);
  copyFile('CLAUDE.md', 'CLAUDE.md', isForce);

  log(`\n📁 Step 3: Initializing .sdd/ specification framework...`, colors.bright + colors.blue);
  copyFile('.sdd/README.md', '.sdd/README.md', isForce);
  copyFile('.sdd/shared_context.md', '.sdd/shared_context.md', isForce);
  ensureDir(path.join(targetDir, '.sdd', 'features'));
  copyFile('.sdd/features/.gitkeep', '.sdd/features/.gitkeep', true);
  ensureDir(path.join(targetDir, '.sdd', 'rfcs'));
  copyFile('.sdd/rfcs/.gitkeep', '.sdd/rfcs/.gitkeep', true);

  log(`\n📚 Step 4: Copying Documentation...`, colors.bright + colors.blue);
  copyFile('docs/sdd-add-guide.md', 'docs/sdd-add-guide.md', true);

  log(`\n🎉 SDD + ADD Migration Successful!`, colors.bright + colors.green);
  log(`=================================================`, colors.green);
  log(`Target repo at '${targetDir}' is now SDD + ADD enabled.\n`);
  log(`Next steps for the target project:`, colors.bright);
  log(`  1. Open the target repo in Claude Code or your AI IDE.`);
  log(`  2. Run '/sdd-adopt' inside the target project to customize governance for its specific tech stack.`);
  log(`  3. Start a new feature using '/sdd-context --feature=<slug>'.`);
  log(`  4. To reverse-engineer spec for a legacy module: '/sdd-adopt --reverse-feature=<slug> --path=<module-path>'\n`);

} catch (err) {
  log(`\n❌ Migration failed: ${err.message}`, colors.red);
  process.exit(1);
}
