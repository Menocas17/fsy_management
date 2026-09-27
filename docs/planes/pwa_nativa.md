# Plan: PWA con experiencia cercana a nativa (y escáner QR al máximo)

> Estado: **en planificación, sin implementar**.

## Decisión

- **iPhone:** PWA instalada desde Safari ("Agregar a inicio"). Sin App Store: instalar apps nativas
  en iOS sin pagar los USD 99/año de Apple no es viable para repartirlas al staff.
- **Android:** la misma PWA. Un APK de Hotwire Native (distribuido por enlace, sin Play Store) queda
  como **fase opcional** y se decide después de usar la PWA con el staff en una capacitación.
- Todo el trabajo de la PWA se reaprovecha en el APK: Hotwire Native muestra las mismas vistas.

La app ya es una PWA (`pwa/manifest.json.erb`, `pwa/service-worker.js`, Web Push con
`push_subscriptions`); el plan es pulirla, no empezar de cero.

---

## 1. Escáner QR (prioridad)

### Estado actual

- Dos controladores con el mismo bucle de cámara copiado: `qr_scanner_controller.js` (inventario) y
  `checkin_scanner_controller.js` (llegadas, ya funciona sin señal con padrón local y cola).
- En **cada cuadro** (`requestAnimationFrame`, ~60/s) se copia el video completo a un canvas a
  resolución nativa (p. ej. 1920×1080) y se decodifica con `jsQR` en el hilo principal. Es lo más caro
  del escáner: gasta batería, calienta el teléfono y en equipos modestos se nota lento.
- No se usa `BarcodeDetector` (lector nativo, acelerado por hardware) donde existe (Chrome Android).
- El escáner de inventario **sale de la página** al leer (`window.location.href`): para contar cajas
  una tras otra, se cierra y reabre la cámara en cada artículo.
- **El QR del gafete no funciona en el escáner de inventario:** el gafete lleva la URL de la ficha del
  participante; el escáner toma el último tramo (el UUID) y lo busca como código de artículo.
- El atajo "Escanear QR" del dashboard está deshabilitado (inerte).
- Las etiquetas se imprimen con `border_modules: 0` (sin margen blanco alrededor del QR). El estándar
  pide un margen de 4 módulos; sin él algunos lectores fallan, sobre todo en papel o con poca luz.

### Mejoras

**Motor común de escaneo** (`qr_engine.js`), usado por inventario, llegadas y el escáner general:

1. **Lector nativo primero:** `BarcodeDetector` donde exista (Chrome Android); si no (Safari/iOS),
   `jsQR` dentro de un **Web Worker** para no trabar la interfaz. Evaluar `zxing-wasm` como alternativa
   más rápida a `jsQR` con una medición real antes de decidir.
2. **Menos trabajo por cuadro:**
   - Recortar solo el centro de la imagen (la zona del visor, ~60 %) en vez del cuadro completo.
   - Reducir a ~480–640 px de lado antes de decodificar.
   - Limitar a ~12–15 intentos por segundo, sin encolar si el anterior no terminó.
   - Usar `requestVideoFrameCallback` donde exista (se sincroniza con cuadros nuevos reales).
3. **Cámara:** pedir 1280×720 ideal, enfoque continuo donde se soporte, botón de **linterna**
   (Android) y zoom si el equipo lo permite.
4. **La cámara no se cierra entre lecturas:** el resultado aparece en una hoja inferior sobre la
   cámara (Turbo Frame), no en otra página.
   - Inventario: leer caja → hoja con el artículo y botones rápidos de +/– → seguir escaneando.
   - Llegadas: ya funciona así; pasa a usar el motor común.
5. **Respuesta inmediata:** visor con marco, vibración corta (Android; iOS no tiene API de vibración)
   y un sonido breve opcional; ignorar lecturas repetidas del mismo código por unos segundos.
6. **Un solo escáner que entiende todos los QR** (se activa el atajo "Escanear QR" del dashboard):
   - Código de artículo (`MAT-0042`) → ficha del artículo o ajuste rápido.
   - QR de gafete (URL o UUID de participante) → ficha del participante, o registro de llegada si el
     día del evento corresponde.
   - Cualquier otra cosa → mensaje claro, sin salir del escáner.
7. **Permiso de cámara:** mantener el flujo en una sola página para no volver a pedir permiso en iOS,
   y explicar qué hacer si se negó.

**Del lado de la impresión:**

- Margen blanco de 4 módulos en los QR de etiquetas y gafetes.
- Gafetes: codificar un contenido más corto que la URL completa (p. ej. `P-` + id corto) para un QR
  menos denso que se lee más rápido y a más distancia; el escáner lo resuelve a la ficha.
- Mantener corrección de errores nivel M (tolera etiquetas algo dañadas).

**Opcional:** cola sin conexión para ajustes de inventario, igual que en llegadas (decidir si en
bodega hay mala señal).

**Meta medible:** lectura en menos de 0,5 s en un Android de gama baja y en un iPhone, con buena luz,
a 20–30 cm. Medir antes y después.

---

## 2. PWA cercana a nativa

### Navegación y aspecto

- **Pestañas inferiores** cuando la app está instalada (`display-mode: standalone`): Inicio,
  Participantes, Agenda, Inventario, Más. En navegador se mantiene el menú actual.
- **Pantalla completa** respetando muesca y barra inferior (`viewport-fit=cover`,
  `env(safe-area-inset-*)`), barra de estado del color de la app en iOS.
- **Transiciones entre pantallas** (View Transitions con Turbo) y **jalar para refrescar**.
- **Detalles de app:** inputs de 16 px o más (evita el zoom automático de iOS), sin selección de texto
  ni menú de mantener presionado en botones, áreas táctiles de 44 px mínimo.

### Instalación

- Manifest más completo: `id`, íconos 192/512 y maskable separado, `orientation`, capturas de
  pantalla y **atajos** (mantener presionado el ícono → "Escanear QR", "Registro de llegadas").
- Pantallas de inicio (splash) para iOS.
- **Guía de instalación dentro de la app:** botón nativo en Android (`beforeinstallprompt`) y pasos
  con imágenes en iPhone (Safari → Compartir → Agregar a inicio).

### Sin conexión y velocidad

- El service worker guarda el "cascarón" (CSS, JS, íconos) para que la app abra al instante.
- Pantalla sin conexión amigable en vez del error del navegador.
- Precarga de enlaces al tocar (Turbo) para que las pantallas se sientan inmediatas.

### Notificaciones

- En iPhone el push solo funciona con la app instalada (iOS 16.4+): pedir el permiso en ese momento y
  explicarlo si se abre desde Safari.
- Contador en el ícono de la app con las notificaciones sin leer (`navigator.setAppBadge`).

---

## 3. (Opcional) APK de Android con Hotwire Native

Solo si después de usar la PWA el staff lo necesita (p. ej. uso intensivo del escáner).

- Proyecto Android con pestañas nativas, escáner nativo y push por Firebase (FCM, gratis).
- Rails distingue la app y oculta la navegación web; `PushNotificationJob` envía por Web Push o FCM
  según el dispositivo.
- Distribución por enlace (instalar apps desconocidas); las actualizaciones nativas son manuales, lo
  web se actualiza solo. Guardar bien la llave de firma del APK.
- Se compila en Android Studio (en la Mac); el código lo puede escribir Claude, pero no compilarlo.

---

## Fases y tiempos (código con Claude)

| Fase | Contenido | Tiempo |
|---|---|---|
| 1. Motor QR | Motor común, lector nativo + worker, recorte/reducción, cámara, escáner unificado, hoja de resultado, margen en impresión | 2–3 días |
| 2. PWA nativa | Pestañas, pantalla completa, transiciones, manifest, guía de instalación, cascarón offline, push en iOS | 3–4 días |
| 3. Pruebas en teléfonos | iPhone y Android reales, medición de tiempos de lectura, ajustes | según disponibilidad |
| 4. APK (opcional) | Hotwire Native Android + FCM | 3–5 días + compilación y pruebas |

Calendario realista para 1 + 2 con revisión y pruebas: **1–2 semanas**. Conviene hacer primero la
fase 1: es la que más se nota en el día del evento.

## Pendiente de decidir

- ¿Cola sin conexión también para inventario?
- ¿Cambiar el contenido del QR de los gafetes (más corto) antes de imprimirlos?
  Si ya se imprimieron, el escáner debe seguir aceptando la URL actual.
- ¿Sonido al leer, o solo vibración/visual?
