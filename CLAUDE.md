# CLAUDE.md — Project Memory & Architecture DNA

# Version: 1.0.0
# Project: Starter Template (SDD + ADD Boilerplate)

---

## 1. TL;DR & Purpose
Repository này là **Starter Template chuẩn** được thiết kế theo phương pháp luận **SDD (Spec-Driven Development)** và **ADD (Agent-Driven Development)**.
Sử dụng template này để khởi tạo dự án mới với các quy tắc quản trị có sẵn, hệ thống Slash Commands tự động và tài liệu đặc tả chuẩn hóa.

---

## 2. Architecture & Directory Anatomy

### 2.1 Architectural Pattern
Hệ thống khuyến nghị tuân thủ **Clean Architecture / Hexagonal Architecture**:

```text
src/
├── domain/         # Entities, Value Objects, Domain Events (Pure TS, No external deps)
├── usecase/        # Business Logic, Interactors, Application Services
├── interface/      # HTTP Controllers, Event Consumers, Presenters, DTOs
├── infra/          # DB Repositories, Redis Cache, External Services
└── shared/         # Logger, Security Utils, Constitution Checks
```

### 2.2 Directory Standard Layout
```text
.
├── AGENTS.md               # Agent Constitution (Persona, Scope, Tool Permissions)
├── CLAUDE.md               # Project Memory & Architecture DNA (File hiện tại)
├── CONSTITUTION.md         # Hard Governance Rules (3-layer quality gates)
├── .claude/
│   └── skills/             # Thư mục Custom Slash Commands (9 SDD+ADD Skills)
├── .sdd/                   # Thư mục quản lý Đặc tả Kỹ thuật
│   ├── README.md           # Master Feature Registry
│   ├── shared_context.md   # Shared State & API Contracts giữa các feature
│   ├── rfcs/               # Đề xuất thay đổi Hiến pháp hệ thống
│   └── features/           # Nơi chứa bộ 4 file SDD cho từng feature
├── docs/
│   └── sdd-add-guide.md    # Hướng dẫn quy trình 5 bước phát triển
├── scripts/                # Shell scripts hỗ trợ migration native (adopt.sh, adopt.ps1)
├── src/                    # Source code thực thi
└── tests/                  # Executable Verification Suite
```

---

## 3. Core Architectural Principles

- **Spec-as-Code**: Tất cả đặc tả nằm trong Git dưới định dạng Markdown có cấu trúc để AI Agent đọc/ghi tự động.
- **EARS Notation**: Mọi Functional Requirement trong `SPEC.md` bắt buộc viết bằng EARS (Ubiquitous, Event-driven, State-driven, Optional, Unwanted).
- **Fix the Spec, not the Code**: Khi test thất bại, bổ sung điều kiện vào Spec trước khi re-generate code.

---

## 4. Engineering Conventions & Anti-Patterns

### 4.1 Conventions
- **Naming**: File kebab-case (`order-repository.ts`), Class PascalCase (`OrderRepository`), Interface/Type PascalCase (`OrderEntity`).
- **EARS Tagging**: Mọi function/method thực thi business rule phải có JSDoc tag `@ears SPEC.md#REQ-XXX`.

### 4.2 Anti-Patterns to Avoid
- ❌ **Direct DB access from Controllers**: Controller chỉ gọi Usecase.
- ❌ **Inline Magic Numbers**: Phải đưa vào constants hoặc configuration.
- ❌ **Patching Code directly on Spec mismatch**: Phải quay lại sửa `.sdd/features/{slug}/SPEC.md` trước.
