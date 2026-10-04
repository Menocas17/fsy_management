---
paths:
  - "app/**/*alert*"
  - "app/**/*alert*/**"
---

**Notificaciones (campanita):** an `Alert` is one shared row for its whole audience, so deleting it from a bell is per person: `AlertDismissal` (one alert) or `users.alerts_cleared_at` ("Limpiar todo"); `Alert.inbox_for(user)` is what the bell, the Notificaciones page and the unread count show (`visible_to` still decides who may open an alert). Tapping a card opens `AlertsHelper#alert_destination_path` (its `link_path`, the activity in the agenda, the assignment in the profile, else the alert). Desktop deletes with the hover X; touch screens swipe the card left to reveal "Eliminar" (`alert_item_controller.js`, a long swipe deletes). The streams update the page and the bell's menu in place, never replacing the bell (it would close the open menu).
