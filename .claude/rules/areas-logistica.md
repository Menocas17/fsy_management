---
paths:
  - "app/**/*logistics_area*"
  - "app/**/*logistics_area*/**"
---

**Áreas de logística** (nav "Logística › Áreas", `LogisticsAreasController` + `LogisticsAreaMembersController`, managed by `User#logistics_areas_manager?`: full access and director_logistica): each logística member belongs to one `LogisticsArea`; an area's boolean flags (`LogisticsArea::FLAGS`: `checkin` → registro, `finance` → finanzas (presents and consolidates expenses, never approves: only `User#expense_approver?` — superadmin, director, director_logistica — does), `food` → the future alimentación module, `User#food_member?`) grant permissions to all its members — permissions follow flags, never area names. The flags (registro, finanzas, alimentación, enfermería) only change in code. The index explains them with just the pills (`_flag_help_chip`: a CSS note on hover, its dialog on touch via `flag_help_controller.js`). The participant form shows the area picker only for the `logistica` role (`role_fields_controller.js`), and leaving the logistics committee drops the area. Adding a member from another area moves them. An area with expenses can't be deleted (`restrict_with_error`).
