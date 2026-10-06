// jsQR en su propio hilo (lib/qr_frame): mientras lee un cuadro, la pantalla sigue libre para el scroll y los
// toques. Sin imports fijos: el primer mensaje trae la dirección de jsQR (la del importmap, con su huella),
// porque dentro de un worker no hay importmap.
let jsQR

self.onmessage = async ({ data }) => {
  if (data.jsqr) {
    try {
      jsQR = (await import(data.jsqr)).default
      self.postMessage({ ready: true })
    } catch (error) {
      self.postMessage({ ready: false })
    }
    return
  }

  const found = jsQR(new Uint8ClampedArray(data.buffer), data.size, data.size, { inversionAttempts: "dontInvert" })
  self.postMessage({ id: data.id, payload: found?.data || null })
}
