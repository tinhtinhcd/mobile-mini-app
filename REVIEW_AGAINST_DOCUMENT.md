# Review lại lần nữa theo tài liệu (v3)

## Tài liệu đối chiếu
- `MASTER_SPEC.md`
- `ARCHITECTURE.md`
- `BUILD_PLAN.md`

## Phạm vi kiểm tra
- `pubspec.yaml` (workspace root)
- `packages/app_core/**`
- `packages/ui_kit/**`
- `apps/pomodoro_app/**`

## Cách đọc kết quả
- ✅: Đạt theo kỳ vọng hiện tại của roadmap.
- ⚠️: Có một phần nhưng chưa đủ để scale.
- ❌: Chưa có implementation.

---

## 1) Executive summary

- Dự án hiện **đúng hướng cho Phase 1**: kiến trúc monorepo, app demo Pomodoro, shared core/UI đã hoạt động theo mô hình “app mỏng + package dùng chung”.
- Dự án **chưa sẵn sàng cho mục tiêu app-factory 1–3 ngày/app** vì các engine và hạ tầng phase sau chưa có API/use-case thật.
- Điểm nghẽn lớn nhất: **timer logic đang nằm trong app**, chưa được đóng gói thành `timer_engine` để tái sử dụng.

---

## 2) Review matrix theo requirement

### A. Monorepo & workspace

| Requirement | Status | Nhận xét |
|---|---|---|
| Repo theo cấu trúc `packages/` + `apps/` | ✅ | Đúng với `MASTER_SPEC.md` |
| Phase 1 có `app_core`, `ui_kit`, `pomodoro_app` trong workspace | ✅ | `pubspec.yaml` đã khai báo đúng 3 module active |
| Module phase sau đã sẵn sàng tích hợp | ⚠️ | Có thư mục nhưng chưa vào workspace, chưa có package API thực tế |

### B. app_core

| Requirement | Status | Nhận xét |
|---|---|---|
| Routing/theme/scaffold dùng chung | ✅ | Có `FactoryApp`, `AppDefinition`, `createAppRouter`, `FactoryScaffold` |
| Logging/error handling tập trung | ❌ | Chưa thấy abstraction logger hay global error hook |

### C. ui_kit

| Requirement | Status | Nhận xét |
|---|---|---|
| Shared components (buttons/cards/inputs/dialogs/tiles/stats/empty state) | ✅ | Có đủ nhóm component Phase 1 cần demo |
| App demo dùng shared UI thay vì dựng riêng | ✅ | `pomodoro_screen.dart` đã dùng component từ `ui_kit` |

### D. pomodoro_app

| Requirement | Status | Nhận xét |
|---|---|---|
| App độc lập, wiring mỏng | ✅ | `main.dart` boot qua `FactoryApp`, cấu hình tách `app_config.dart` |
| Theo coding rules (Riverpod/go_router/modular) | ✅ | Controller dùng Riverpod, routing từ shared core |
| Offline-first ở mức Phase 1 | ✅ | Không có phụ thuộc backend runtime |
| Persistence local cho lịch sử phiên | ⚠️ | Chưa có storage integration (hợp roadmap: Phase 2) |

---

## 3) Các vấn đề ưu tiên cao (theo impact)

1. **High impact / High urgency** — Chưa tách `timer_engine`
   - Ảnh hưởng: khó tái sử dụng cho fasting/countdown/workout timer.
   - Rủi ro: duplicate logic + sai khác behavior giữa app.

2. **High impact / Medium urgency** — Thiếu logging + error boundary ở `app_core`
   - Ảnh hưởng: khó vận hành, khó trace lỗi khi thêm nhiều app.

3. **Medium impact / Medium urgency** — Package phase 2 mới là placeholder
   - Ảnh hưởng: chậm đạt mục tiêu monetization/local-data/notifications/export.

---

## 4) Kế hoạch sửa cụ thể (đề xuất sau review)

### Sprint A (ưu tiên ngay)
- Khởi tạo `packages/timer_engine` bản tối thiểu:
  - domain model: `TimerMode`, `TimerCycle`, `TimerMetrics`
  - controller/service: start/pause/resume/reset/skip
  - API đủ để `pomodoro_app` dùng trực tiếp, không giữ business logic ở app

### Sprint B
- Bổ sung `app_core`:
  - logger interface (`debug/info/warn/error`)
  - global error handling hook
  - default implementation cho môi trường local

### Sprint C
- Kích hoạt tối thiểu 1 package Phase 2 có use-case thật:
  - gợi ý bắt đầu với `storage` (vì liên quan trực tiếp history timer)
  - thêm test cơ bản cho read/write + mapping model

---

## 5) Re-score theo roadmap

- Phase 1: ✅ **Đạt** (demo chạy trên shared packages).
- Phase 2: ⚠️ **Chưa đạt** (hạ tầng chưa hoạt động thực tế).
- Phase 3: ⚠️ **Chưa đạt** (engine chưa tách ra khỏi app).
- Phase 4: ⚠️ **Chưa sẵn sàng** (chưa có nền tảng để build app mới trong vài ngày).

---

## 6) Definition of Done cho lần review tiếp theo

Checklist nên đạt tối thiểu:
- [ ] `pomodoro_app` dùng `timer_engine` thay vì controller local.
- [ ] `app_core` có logger + global error hook.
- [ ] `storage` có API thực + unit test cơ bản.
- [ ] Workspace phản ánh đúng tất cả module đang active.
- [ ] CI có ít nhất analyze + test cho các package đã active.
