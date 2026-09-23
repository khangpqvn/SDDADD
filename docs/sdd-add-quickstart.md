# Báº¯t Ä‘áº§u nhanh SDD + ADD

TÃ i liá»‡u nÃ y hÆ°á»›ng dáº«n báº¡n hoÃ n thÃ nh **má»™t feature** tá»« Ã½ tÆ°á»Ÿng Ä‘áº¿n Git delivery. HÃ£y Ä‘i tuáº§n tá»± tá»«ng bÆ°á»›c; tuyá»‡t Ä‘á»‘i khÃ´ng nháº£y tá»« Ã½ tÆ°á»Ÿng sang viáº¿t code.

**Lá»™ trÃ¬nh:** `CONTEXT` → `SPEC` → `PLAN` → `TASKS` → `execute` → `validation` → `delivery`

---

## BÆ°á»›c 0: Chuáº©n bá»‹ vÃ  Äá»‹nh danh
TrÆ°á»›c khi báº¯t Ä‘áº§u, báº¡n cáº§n:
1. **Feature Slug**: Má»™t tÃªn viáº¿t báº±ng kebab-case (vÃ­ dá»¥: `feat-user-register`). DÃ¹ng slug nÃ y xuyÃªn suá»‘t má»i command.
2. **Outcome mong muá»‘n**: MÃ´ táº£ ngáº¯n gá»n káº¿t quáº£ cuá»‘i cÃ¹ng (vÃ­ dá»¥: "NgÆ°á»i dÃ¹ng Ä‘Äƒng nháº­p Ä‘Æ°á»£c báº±ng email").
3. **Kiá»ƒm tra Governance**: Äáº£m báº£o `.sdd/shared_context.md` Ä‘Ã£ xÃ¡c Ä‘á»‹nh `Project Ownership` (solo/team) vÃ  `Agent Execution` (direct/orchestrated).

---

## BÆ°á»›c 1: Thá»‘ng nháº¥t bÃ i toÃ¡n (`CONTEXT`)
**Má»¥c tiÃªu:** XÃ¡c Ä‘á»‹nh "ChÃºng ta Ä‘ang lÃ m gÃ¬, cho ai, vÃ  ranh giá»›i á»Ÿ Ä‘Ã¢u?" Ä‘á»ƒ khÃ´ng lÃ m sai hÆ°á»›ng.

- **Viá»‡c cáº§n lÃ m:**Cháº¡y `/sdd-context --feature=feat-user-register`
- **Káº¿t quáº£ kiá»ƒm chá»©ng:** Tá»‡p `.sdd/features/feat-user-register/CONTEXT.md` Ä‘Æ°á»£c táº¡o.
- **Äiá»ƒm máº¥u chá»‘t:**
    - `Intent Packet` pháº£i rÃµ rÃ ng.
    - Má»i cÃ¢u há»i mÆ¡ há»“ pháº£i Ä‘Æ°á»£c disposition (`resolved`, `approved assumption`, hoáº·c `blocking decision`).
- **Gate:** Human Ä‘á»c vÃ  ghi `/sdd-review ... --artifact=context --status=APPROVED`.
- **Tiáº¿p theo:** Sang BÆ°á»›c 2.

---

## BÆ°á»›c 2: Äá»‹nh nghÄ©a behavior (`SPEC`)
**Má»¥c tiÃªu:** Chuyá»ƒn Ã½ tÆ°á»Ÿng thÃ nh yÃªu cáº§u ká»¹ thuáº­t cÃ³ thá»ƒ kiá»ƒm tra (khÃ´ng gáº¯n vá»›i framework cá»¥ thá»ƒ).

- **Viá»‡c cáº§n lÃ m:**Cháº¡y `/sdd-spec --feature=feat-user-register`
- **Káº¿t quáº£ kiá»ƒm chá»©ng:** Tá»‡p `.sdd/features/feat-user-register/SPEC.md` Ä‘Æ°á»£c táº¡o.
- **Äiá»ƒm máº¥u chá»‘t:**
    - DÃ¹ng EARS Ä‘á»ƒ viáº¿t `REQ-XXX`.
    - Pháº£i cÃ³ Acceptance Criteria cho má»—i requirement.
    - **Clarification-First**: Agent pháº£i liá»‡t kÃª gap/edge case → Human tráº£ lá»i → má»›i viáº¿t REQ.
- **Gate:** Human ghi `/sdd-review ... --artifact=spec --status=APPROVED`. Spec lÃºc nÃ y Ä‘Æ°á»£c **LOCKED**.
- **Tiáº¿p theo:** Kiá»ƒm tra Architecture Profile rá»“i sang BÆ°á»›c 3.

---

## BÆ°á»›c 3: Thiáº¿t káº¿ ká»¹ thuáº­t (`PLAN`)
**Má»¥c tiÃªu:** XÃ¡c Ä‘á»‹nh "Sáº½ sá»­a file nÃ o, dÃ¹ng lá»‡nh gÃ¬ Ä‘á»ƒ verify, rá»§i ro á»Ÿ Ä‘Ã¢u?".

- **âš ï¸ Äiá»u kiá»‡n tiÃªn quyáº¿t:** Má»Ÿ `.sdd/architecture-profile.md`. Náº¿u feature cáº§n DB/API/Library mÃ  Profile chÆ°a cÃ³ binding `APPROVED`, báº¡n pháº£i cáº­p nháº­t Profile vÃ  xin duyá»‡t trÆ°á»›c.
- **Viá»‡c cáº§n lÃ m:**Cháº¡y `/sdd-plan --feature=feat-user-register`
- **Káº¿t quáº£ kiá»ƒm chá»©ng:** Tá»‡p `.sdd/features/feat-user-register/PLAN.md` Ä‘Æ°á»£c táº¡o.
- **Äiá»ƒm máº¥u chá»‘t:**
    - Map má»—i `REQ-XXX` vÃ o component/file cá»¥ thá»ƒ.
    - Sá»­ dá»¥ng **Exact approved command** tá»« Profile (khÃ´ng dÃ¹ng lá»‡nh Ä‘oÃ¡n).
- **Gate:** Human ghi `/sdd-review ... --artifact=plan --status=APPROVED`.
- **Tiáº¿p theo:** Sang BÆ°á»›c 4.

---

## BÆ°á»›c 4: Chia nhá» cÃ´ng viá»‡c (`TASKS`)
**Má»¥c tiÃªu:** Biáº¿n báº£n thiáº¿t káº¿ thÃ nh danh sÃ¡ch viá»‡c cáº§n lÃ m (Atomic tasks).

- **Viá»‡c cáº§n lÃ m:**Cháº¡y `/sdd-tasks --feature=feat-user-register`
- **Káº¿t quáº£ kiá»ƒm chá»©ng:** Tá»‡p `.sdd/features/feat-user-register/TASKS.md` Ä‘Æ°á»£c táº¡o.
- **Äiá»ƒm máº¥u chá»‘t:**
    - Má»—i task cÃ³: Boundary (file Ä‘Æ°á»£c sá»­a), Dependency, vÃ  Exact command Ä‘á»ƒ verify.
    - Task lá»›n (> 4h) pháº£i Ä‘Æ°á»£c tÃ¡ch nhá» hoáº·c cÃ³ `approved-exception`.
- **Gate:** Human ghi `/sdd-review ... --artifact=tasks --status=APPROVED`.
- **Tiáº¿p theo:** Sang BÆ°á»›c 5 (Thá»±c thi).

---

## BÆ°á»›c 5: Thá»±c thi vÃ  XÃ¡c minh (`EXECUTE`)
**Má»¥c tiÃªu:** Viáº¿t code vÃ  chá»©ng minh code cháº¡y Ä‘Ãºng.

- **Viá»‡c cáº§n lÃ m:**
    - Cháº¡y má»™t task: `/add-execute --feature=feat-user-register --task=T001`
    - Cháº¡y toÃ n bá»™ feature: `/add-execute --feature=feat-user-register --all`
- **Luá»“ng hoáº¡t Ä‘á»™ng:**
    1. Agent táº¡o **Shadow Plan** → Consumer Grant → Thá»±c thi → Ghi **Action Record**.
    2. Cháº¡y exact approved command Ä‘á»ƒ verify.
- **Äiá»ƒm máº¥u chá»‘t:**
    - KhÃ´ng tá»± Ã½ sá»­a file ngoÃ i boundary.
    - KhÃ´ng tá»± Ã½ Ä‘á»•i command verify.
    - Má»i material state change (Ä‘á»•i DB schema, v.v.) cáº§n **Human Checkpoint** trÆ°á»›c khi lÃ m.
- **Tiáº¿p theo:** Sang BÆ°á»›c 6.

---

## BÆ°á»›c 6: Kiá»ƒm tra cuá»‘i vÃ  Delivery (`GIT`)
**Má»¥c tiÃªu:** Äáº£m báº£o khÃ´ng cÃ³ regression vÃ  chuyá»ƒn giao vÃ o Git.

- **Viá»‡c cáº§n lÃ m:**
    1. Cháº¡y `/sdd-audit` vÃ  `/sdd-trace` Ä‘á»ƒ kiá»ƒm tra Ä‘á»™ phá»§ requirement.
    2. Táº¡o **Post-code review report** (náº¿u cÃ³ thay Ä‘á»•i source/contract).
    3. Cháº¡y `/git-validate --scope=commit --feature=feat-user-register`.
- **Káº¿t quáº£ cuá»‘i cÃ¹ng:** Khi nháº­n Ä‘Æ°á»£c `GIT VALIDATION: READY`, Human yÃªu cáº§u Agent commit.
- **Delivery:** Human tá»± thá»±c hiá»‡n `git push`.

---

## ðŸ›‘ Khi nÃ o pháº£i Dá»ªNG?
- Thiáº¿u review `APPROVED` cho báº¥t ká»³ artifact nÃ o.
- Spec bá»‹ mÃ¢u thuáº«n hoáº·c thiáº¿u rule → Quay láº¡i BÆ°á»›c 2.
- Architecture Profile thiáº¿u binding/command → Cáº­p nháº­t Profile.
- Test fail → PhÃ¢n tÃ­ch defect, khÃ´ng vÃ¡ code tÃ¹y tiá»‡n.
