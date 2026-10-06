// Lo que comparten los escáneres (qr_scanner y checkin_scanner) para leer un QR de la cámara sin trabar el
// teléfono. jsQR corre en el mismo hilo que el scroll y los toques: con la cámara a 4K y el cuadro entero
// (8 millones de puntos, ocho veces por segundo) el teléfono se quedaba sin tiempo para nada más.

// 1080p: de sobra para un QR, y los teléfonos la dan sin forzar. Sin pedirla, muchos abren a 640×480.
export const CAMERA = { facingMode: "environment", width: { ideal: 1920 }, height: { ideal: 1080 } }

// Se lee el cuadrado del centro (lo que se ve en el visor, que recorta con object-cover) a su resolución
// real, hasta este lado: con 1080p no se pierde ni un punto, y es un séptimo de lo que era el cuadro a 4K.
const READ_SIDE = 1080

// Entre lectura y lectura, al menos esto, y nunca menos del doble de lo que tardó la última: así el
// teléfono siempre tiene la mitad del tiempo libre para el scroll y el botón de atrás, por lento que sea.
const MIN_GAP_MS = 120

// ¿Toca leer ya? Lleva la cuenta en `state` ({ nextAt }) del controlador.
export function readyToRead(state, video, now = performance.now()) {
  return video.readyState === video.HAVE_ENOUGH_DATA && now >= (state.nextAt || 0)
}

// Lee el centro del cuadro actual y deja agendada la próxima lectura. Devuelve el texto del QR o null.
export function readCenter(jsQR, video, canvas, state) {
  const started = performance.now()
  const side = Math.min(video.videoWidth, video.videoHeight)
  const size = Math.min(side, READ_SIDE)
  canvas.width = canvas.height = size

  const context = canvas.getContext("2d", { willReadFrequently: true })
  context.drawImage(video, (video.videoWidth - side) / 2, (video.videoHeight - side) / 2, side, side, 0, 0, size, size)
  const image = context.getImageData(0, 0, size, size)
  const found = jsQR(image.data, size, size, { inversionAttempts: "dontInvert" })

  const spent = performance.now() - started
  state.nextAt = performance.now() + Math.max(MIN_GAP_MS, spent * 2)
  return found?.data || null
}
