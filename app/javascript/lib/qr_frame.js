// Cómo leen QR los escáneres (qr_scanner y checkin_scanner): lo más rápido posible, para el registro masivo,
// sin trabar el teléfono. Leer en el mismo hilo que el scroll y los toques es lo que lo trababa, así que se
// lee fuera de él, y apenas termina una lectura empieza la siguiente:
//   1. «nativo»: el lector del sistema (BarcodeDetector, Chrome en Android). Rápido y fuera del hilo.
//   2. «worker»: jsQR en un Web Worker (iPhone y los que no traen lector). La pantalla solo recorta el cuadro.
//   3. «hilo»: jsQR aquí mismo, si no hay worker; con pausas, para dejarle tiempo al teléfono.

// 1080p: de sobra para un QR, y los teléfonos la dan sin forzar. Sin pedirla, muchos abren a 640×480.
export const CAMERA = { facingMode: "environment", width: { ideal: 1920 }, height: { ideal: 1080 } }

// jsQR lee el cuadrado del centro (lo que se ve en el visor, que recorta con object-cover) a su resolución
// real, hasta este lado: con 1080p no se pierde ni un punto.
const READ_SIDE = 1080
// Solo en el hilo principal: entre lecturas, al menos esto y el doble de lo que tardó la última.
const MIN_GAP_MS = 120

// Abre la cámara en el video. Encenderla tarda: `stillWanted()` se pregunta después de cada espera y, si
// entretanto se salió de la pantalla o se pidió apagarla, la cámara se suelta en el acto y devuelve null.
// Sin esto, salir mientras se encendía la dejaba prendida en segundo plano, sin pantalla que la apagara.
export async function openCamera(video, stillWanted) {
  const stream = await navigator.mediaDevices.getUserMedia({ video: CAMERA, audio: false })
  if (!stillWanted()) return closeCamera(stream)

  video.srcObject = stream
  video.setAttribute("playsinline", true)
  try {
    await video.play()
  } catch (error) {
    closeCamera(stream, video)
    throw error
  }
  return stillWanted() ? stream : closeCamera(stream, video)
}

// Apaga la cámara de verdad (el foquito del teléfono se apaga) y suelta el video.
export function closeCamera(stream, video) {
  stream?.getTracks().forEach((track) => track.stop())
  if (video) video.srcObject = null
  return null
}

export class QrReader {
  // getJsQR: devuelve jsQR cuando ya llegó (solo lo usa «hilo»; el worker lo carga por su cuenta).
  static async create(getJsQR, { engine } = {}) {
    const reader = new QrReader(getJsQR)
    const wanted = engine || (await QrReader.nativeAvailable() ? "nativo" : "worker")
    if (wanted === "nativo") reader.useNative()
    else if (wanted === "worker" && await reader.useWorker()) reader.engine = "worker"
    else reader.engine = "hilo"
    return reader
  }

  static async nativeAvailable() {
    try {
      return "BarcodeDetector" in window && (await BarcodeDetector.getSupportedFormats()).includes("qr_code")
    } catch (error) {
      return false
    }
  }

  constructor(getJsQR) {
    this.getJsQR = getJsQR
    this.busy = false
    this.nextAt = 0
  }

  // ¿Se puede empezar otra lectura? Una a la vez; en «hilo», además, después de su pausa.
  ready(video) {
    return !this.busy && video.readyState === video.HAVE_ENOUGH_DATA && performance.now() >= this.nextAt
  }

  // El texto del QR del cuadro actual, o null.
  async read(video, canvas) {
    this.busy = true
    try {
      if (this.engine === "nativo") return (await this.detector.detect(video))[0]?.rawValue || null
      if (this.engine === "worker") return await this.readInWorker(video, canvas)
      return this.readHere(video, canvas)
    } catch (error) {
      return null
    } finally {
      this.busy = false
    }
  }

  close() {
    this.worker?.terminate()
    this.worker = null
  }

  // Motores ----------------------------------------------------------------
  useNative() {
    this.detector = new BarcodeDetector({ formats: [ "qr_code" ] })
    this.engine = "nativo"
  }

  async useWorker() {
    const jsqr = resolveModule("jsqr")
    const script = resolveModule("lib/qr_worker")
    if (!window.Worker || !jsqr || !script) return false

    try {
      this.worker = new Worker(script, { type: "module" })
      const ready = await new Promise((resolve) => {
        this.worker.onmessage = ({ data }) => resolve(data.ready)
        this.worker.onerror = () => resolve(false)
        this.worker.postMessage({ jsqr })
        setTimeout(() => resolve(false), 5000)
      })
      if (!ready) this.close()
      return ready
    } catch (error) {
      this.close()
      return false
    }
  }

  // El recorte se hace aquí (unos milisegundos); la lectura, que es lo pesado, en el worker.
  readInWorker(video, canvas) {
    const image = crop(video, canvas)
    const id = (this.lastId = (this.lastId || 0) + 1)
    return new Promise((resolve) => {
      this.worker.onmessage = ({ data }) => data.id === id && resolve(data.payload)
      this.worker.postMessage({ id, size: image.width, buffer: image.data.buffer }, [ image.data.buffer ])
    })
  }

  readHere(video, canvas) {
    const jsQR = this.getJsQR()
    if (!jsQR) return null

    const started = performance.now()
    const image = crop(video, canvas)
    const found = jsQR(image.data, image.width, image.height, { inversionAttempts: "dontInvert" })
    this.nextAt = performance.now() + Math.max(MIN_GAP_MS, (performance.now() - started) * 2)
    return found?.data || null
  }
}

// El cuadrado del centro del cuadro, a su resolución real (hasta READ_SIDE).
function crop(video, canvas) {
  const side = Math.min(video.videoWidth, video.videoHeight)
  const size = Math.min(side, READ_SIDE)
  canvas.width = canvas.height = size
  const context = canvas.getContext("2d", { willReadFrequently: true })
  context.drawImage(video, (video.videoWidth - side) / 2, (video.videoHeight - side) / 2, side, side, 0, 0, size, size)
  return context.getImageData(0, 0, size, size)
}

// La dirección de un módulo del importmap («jsqr» → /assets/jsqr-1a2b.js), para el worker.
function resolveModule(name) {
  try {
    if (import.meta.resolve) return import.meta.resolve(name)
  } catch (error) {
    // Sigue con el importmap escrito en la página.
  }
  const map = document.querySelector("script[type=importmap]")
  const url = map && JSON.parse(map.textContent).imports?.[name]
  return url && new URL(url, document.baseURI).href
}
