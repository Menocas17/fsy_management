---
paths:
  - "app/helpers/navigation_helper.rb"
  - "app/views/shared/_nav*"
  - "app/javascript/controllers/nav_groups_controller.js"
  - "app/javascript/controllers/scroll_reveal_controller.js"
  - "app/components/button_component.*"
  - "app/assets/tailwind/**"
---

**Menú lateral:** `NavigationHelper#nav_sections` defines "Inicio" plus collapsible groups (Participantes, Evento, Logística, Seguimiento) shared by the sidebar and the phone drawer (`shared/_nav_sections`). Closed groups live in the `fsy_nav_closed` cookie (written by `nav_groups_controller.js`) so the server renders them closed and Turbo navigations don't flicker; the group holding the current page is always open (`nav_group_open?`, `nav_item_active?`, also used by `ButtonComponent#active?`). Groups animate open/closed with `.nav-group-panel` (grid rows 0fr↔1fr, closed panels are `inert`); the sidebar and drawer scroll areas use `.scroll-reveal` + `scroll_reveal_controller.js`, a thin scrollbar visible only while scrolling.
