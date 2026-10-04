---
paths:
  - "app/**/*checkin*"
  - "app/**/*checkin*/**"
  - "app/**/*scan*"
  - "app/**/*scan*/**"
---

**Registro (escáner de llegadas y capacitaciones):** `CheckinsController` + `checkin_scanner_controller.js`, offline-first (roster and queue in localStorage per mode). Access: `User#checkin_registrar?` (full access, director_logistica, registrador, logística in the check-in area). Only one registro (the arrival or one training) is active at a time: `ScanWindow` keeps it in `AppSetting`, chosen with mutually exclusive switches in Configuración by `User#scan_manager?` (superadmin, director_logistica); the scanner page has no selector and opens the active one. Scans taken offline while the previous registro was active still sync after switching (`previous_scan`). A registration made in the line can be voided ("Anular" under the camera for the last scan, or in the recent list) with a reason from `CheckinsController::VOID_REASONS` plus optional detail; the void travels in the same queue (`kind: "void"`) so it works offline and in order, only deletes the record created by that scan (`target_token`) or the one picked (`record_id`) — never an earlier real arrival — and writes `AuditLog` category `registro`. Anyone may open a ficha by scanning a badge (`ScansController`, dashboard "Escanear gafete"); registering stays with the registrars.
