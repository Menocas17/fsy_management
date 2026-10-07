import { Controller } from '@hotwired/stimulus';

// Entrar o activar la entrada con huella (passkeys / WebAuthn). El servidor manda las opciones en JSON con los
// binarios en base64url; el navegador los quiere como ArrayBuffer, y lo que devuelve va de vuelta en base64url.
//   data-passkey-options-url-value: de dónde salen las opciones
//   data-passkey-url-value:          a dónde va la passkey firmada
//   data-passkey-conditional-value:  en el inicio de sesión, el teléfono la ofrece al tocar el campo del correo
//   data-passkey-offer-value:        en un <dialog>: se abre solo (la invitación tras entrar con contraseña) si el
//                                    dispositivo tiene huella y aquí no se dijo «Ahora no» (dismissKey)
// Lo que solo sirve con passkeys (data-passkey-target="supported") queda oculto donde el navegador no las tiene.
export default class extends Controller {
  static targets = ['supported', 'unsupported', 'error', 'button'];
  static values = { optionsUrl: String, url: String, conditional: Boolean, offer: Boolean, dismissKey: String };

  async connect() {
    const available = await platformAvailable();
    this.supportedTargets.forEach((element) => (element.hidden = !available));
    this.unsupportedTargets.forEach((element) => (element.hidden = available));
    if (available && this.conditionalValue) this.startConditional();
    if (available && this.offerValue && !this.dismissed()) this.element.showModal?.();
  }

  disconnect() {
    this.abort?.abort();
  }

  // Activar en este dispositivo (Configuración o la invitación después de entrar con contraseña).
  async register() {
    await this.run(async () => {
      const options = await this.post(this.optionsUrlValue);
      const credential = await navigator.credentials.create({ publicKey: creationOptions(options) });
      return this.post(this.urlValue, { credential: creationJSON(credential) });
    });
  }

  // El botón «Entrar con huella».
  async signIn() {
    this.abort?.abort();
    await this.run(() => this.authenticate());
  }

  // Autocompletar del teléfono: sin botón, la passkey aparece sugerida al tocar el campo del correo.
  async startConditional() {
    if (!(await PublicKeyCredential.isConditionalMediationAvailable?.())) return;

    try {
      await this.finish(await this.authenticate('conditional'));
    } catch (error) {
      if (error.name !== 'AbortError' && error.name !== 'NotAllowedError') this.showError(error.message);
    }
  }

  async authenticate(mediation) {
    const options = await this.post(this.optionsUrlValue);
    const request = { publicKey: requestOptions(options) };
    if (mediation) {
      this.abort = new AbortController();
      Object.assign(request, { mediation, signal: this.abort.signal });
    }
    const credential = await navigator.credentials.get(request);
    return this.post(this.urlValue, { credential: requestJSON(credential) });
  }

  async run(step) {
    this.showError('');
    this.buttonTargets.forEach((button) => (button.disabled = true));
    try {
      await this.finish(await step());
    } catch (error) {
      // Cancelar el aviso de la huella no es un error que haya que explicar.
      if (error.name === 'NotAllowedError' || error.name === 'AbortError') return;
      this.showError(error.message || 'No se pudo usar la huella. Intenta de nuevo.');
    } finally {
      this.buttonTargets.forEach((button) => (button.disabled = false));
    }
  }

  finish(result) {
    if (result?.location) window.Turbo ? window.Turbo.visit(result.location) : (window.location = result.location);
  }

  // «Ahora no» de la invitación: no vuelve a preguntar en este dispositivo.
  dismiss() {
    try {
      if (this.dismissKeyValue) localStorage.setItem(this.dismissKeyValue, '1');
    } catch (_) {
      // Sin almacenamiento (navegación privada): vuelve a preguntar la próxima vez, nada más.
    }
    this.element.closest('dialog')?.close();
  }

  dismissed() {
    try {
      return !!this.dismissKeyValue && localStorage.getItem(this.dismissKeyValue) === '1';
    } catch (_) {
      return false;
    }
  }

  async post(url, body) {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json', 'X-CSRF-Token': csrfToken() },
      body: body ? JSON.stringify(body) : undefined,
      credentials: 'same-origin',
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.error || 'No se pudo usar la huella. Intenta de nuevo.');
    return data;
  }

  showError(message) {
    this.errorTargets.forEach((element) => {
      element.textContent = message;
      element.hidden = !message;
    });
  }
}

async function platformAvailable() {
  try {
    return !!window.PublicKeyCredential && (await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable());
  } catch (_) {
    return false;
  }
}

const csrfToken = () => document.querySelector('meta[name=csrf-token]')?.content;

const toBuffer = (value) => {
  const base64 = value.replace(/-/g, '+').replace(/_/g, '/');
  const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, '=');
  return Uint8Array.from(atob(padded), (char) => char.charCodeAt(0)).buffer;
};

const toBase64url = (buffer) => {
  if (!buffer) return null;
  let binary = '';
  new Uint8Array(buffer).forEach((byte) => (binary += String.fromCharCode(byte)));
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
};

const withIds = (list = []) => list.map((item) => ({ ...item, id: toBuffer(item.id) }));

const creationOptions = (options) => ({
  ...options,
  challenge: toBuffer(options.challenge),
  user: { ...options.user, id: toBuffer(options.user.id) },
  excludeCredentials: withIds(options.excludeCredentials),
});

const requestOptions = (options) => ({
  ...options,
  challenge: toBuffer(options.challenge),
  allowCredentials: withIds(options.allowCredentials),
});

const creationJSON = (credential) => ({
  type: credential.type,
  id: credential.id,
  rawId: toBase64url(credential.rawId),
  authenticatorAttachment: credential.authenticatorAttachment,
  response: {
    attestationObject: toBase64url(credential.response.attestationObject),
    clientDataJSON: toBase64url(credential.response.clientDataJSON),
    transports: credential.response.getTransports?.() || [],
  },
  clientExtensionResults: credential.getClientExtensionResults(),
});

const requestJSON = (credential) => ({
  type: credential.type,
  id: credential.id,
  rawId: toBase64url(credential.rawId),
  authenticatorAttachment: credential.authenticatorAttachment,
  response: {
    authenticatorData: toBase64url(credential.response.authenticatorData),
    clientDataJSON: toBase64url(credential.response.clientDataJSON),
    signature: toBase64url(credential.response.signature),
    userHandle: toBase64url(credential.response.userHandle),
  },
  clientExtensionResults: credential.getClientExtensionResults(),
});
