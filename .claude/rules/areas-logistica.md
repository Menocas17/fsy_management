---
paths:
  - "app/**/*logistics_area*"
  - "app/**/*logistics_area*/**"
---

**Áreas de logística** (nav "Logística › Áreas", `LogisticsAreasController` + `LogisticsAreaMembersController`, managed by `User#logistics_areas_manager?`: full access and director_logistica): each logística member belongs to one `LogisticsArea`; an area's boolean flags (`LogisticsArea::FLAGS`: `checkin` → registro, `finance` → finanzas, `food` → the future alimentación module, `User#food_member?`) grant permissions to all its members — permissions follow flags, never area names. Adding a member from another area moves them. An area with expenses can't be deleted (`restrict_with_error`).
