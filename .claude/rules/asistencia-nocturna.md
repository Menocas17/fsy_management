---
paths:
  - "app/**/*night_attendance*"
  - "app/**/*night_attendance*/**"
  - "config/recurring.yml"
---

**Asistencia nocturna** (`NightAttendancesController`, nav "Seguimiento › Asistencia nocturna"): each night (6 pm–6 am counts as one, `NightAttendance.current_night`) every company has one list per gender, marked by hand — no QR — as present or absent with a reason (`NightAttendanceMark`: Enfermería, or Otro with text); every joven must be marked to confirm. Only the counselor of that gender in their company takes it, or the auxiliar of that gender in the branch when the counselor is missing (`Authorization#night_attendance_gender_for`, `can_take_night_attendance?`), and only tonight's. The panel (`User#night_attendance_viewer?`: full access, auxiliares, director_logistica) shows every company of both genders, only the event's nights (`NightAttendance.panel_nights`), and refreshes live (`broadcast_refresh_later_to "night_attendance"`). Before the event, tonight is a test night (`NightAttendance.testing?`): it shows in the panel and the superadmin may take any list; it turns itself off when the event starts. At 22:00 `NightAttendanceCheckJob` (`config/recurring.yml`) sends **one** consolidated `por_roles` alert (auxiliar, coordinador, director) listing lists not taken and absentees — never one alert per joven, and nothing if all is complete.
