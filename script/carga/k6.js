// Prueba de carga con k6 (https://grafana.com/docs/k6/): muchos usuarios a la vez, cada uno pidiendo las
// pantallas de su rol con una pausa entre una y otra (60 % jóvenes, 30 % consejeros, 10 % dirección), como
// usuarios.rb. Solo lee (GET), así que no cambia datos. Cómo correrla: script/carga/README.md.
//
//   k6 run -e BASE_URL=https://<APP_HOST> -e PASSWORD=… -e EMAIL_ADMIN=… -e EMAIL_CONSEJERO=… \
//          -e EMAIL_JOVEN=… -e COMPANIA_ID=… -e JOVEN_DE_LA_COMPANIA_ID=… script/carga/k6.js
//
// Opcionales: USUARIOS (650), PAUSA en segundos entre acciones de cada uno (12), DURACION del tramo a pleno (2m).
import http from "k6/http";
import { check, fail, sleep } from "k6";

const BASE_URL = __ENV.BASE_URL.replace(/\/$/, "");
const USUARIOS = Number(__ENV.USUARIOS || 650);
const PAUSA = Number(__ENV.PAUSA || 12);
const DURACION = __ENV.DURACION || "2m";

const ROLES = {
  joven: __ENV.EMAIL_JOVEN,
  consejero: __ENV.EMAIL_CONSEJERO,
  admin: __ENV.EMAIL_ADMIN,
};

// Las pantallas que abre cada rol el lunes (las mismas de config.rb). El nombre agrupa las métricas en el resumen.
const PANTALLAS = {
  joven: [
    ["Joven: inicio", "/dashboard"],
    ["Joven: mi perfil", "/participants/myprofile"],
    ["Joven: agenda", "/agenda"],
  ],
  consejero: [
    ["Consejero: inicio", "/dashboard"],
    ["Consejero: su compañía", `/companies/${__ENV.COMPANIA_ID}`],
    ["Consejero: ficha de un joven", `/participants/${__ENV.JOVEN_DE_LA_COMPANIA_ID}`],
  ],
  admin: [
    ["Dirección: inicio", "/dashboard"],
    ["Dirección: jóvenes", "/participants"],
    ["Dirección: compañías", "/companies"],
    ["Dirección: búsqueda", "/buscar?q=mar"],
    ["Dirección: notificaciones", "/notificaciones"],
  ],
};

export const options = {
  scenarios: {
    lunes: {
      executor: "ramping-vus",
      startVUs: 0,
      stages: [
        { duration: "1m", target: USUARIOS }, // van entrando en un minuto
        { duration: DURACION, target: USUARIOS }, // todos a la vez
        { duration: "30s", target: 0 },
      ],
      gracefulRampDown: "30s",
    },
  },
  // Lo que se considera aceptable: si no se cumple, k6 termina con error (y lo marca en rojo).
  // Una por pantalla además de la general: así el resumen muestra los tiempos de cada una.
  thresholds: Object.assign(
    { http_req_failed: ["rate<0.01"], http_req_duration: ["p(95)<1500"] },
    ...Object.values(PANTALLAS).flat().map(([nombre]) => ({ [`http_req_duration{name:${nombre}}`]: ["p(95)<1500"] })),
  ),
  summaryTrendStats: ["med", "p(90)", "p(95)", "max"],
  // k6 vacía las cookies en cada vuelta; aquí cada usuario conserva su sesión toda la prueba.
  noCookiesReset: true,
};

// Cualquier cosa que no sea 200 cuenta como error (una redirección al inicio de sesión también).
http.setResponseCallback(http.expectedStatuses(200));

// El inicio de sesión admite 10 intentos cada 3 minutos por IP: se entra una vez por rol aquí y todos los
// usuarios virtuales de ese rol comparten la sesión.
export function setup() {
  const sesiones = {};
  for (const [rol, email] of Object.entries(ROLES)) {
    if (!email) fail(`Falta EMAIL_${rol.toUpperCase()}`);
    const jar = http.cookieJar();
    jar.clear(BASE_URL);

    const formulario = http.get(`${BASE_URL}/session/new`);
    const token = (formulario.body.match(/name="csrf-token" content="([^"]+)"/) || [])[1];
    if (!token) fail("La página de inicio de sesión no trajo el token CSRF");

    const entrada = http.post(`${BASE_URL}/session`,
      { authenticity_token: token, email_address: email, password: __ENV.PASSWORD },
      { redirects: 0, responseCallback: http.expectedStatuses(302) });
    const destino = entrada.headers.Location || "";
    if (entrada.status !== 302 || destino.includes("/session")) {
      fail(`No pudo entrar ${email} (${entrada.status} → ${destino}). ¿Contraseña? ¿Más de 10 intentos en 3 minutos?`);
    }

    sesiones[rol] = Object.fromEntries(
      Object.entries(jar.cookiesForURL(BASE_URL)).map(([nombre, valores]) => [nombre, valores[0]]));
  }
  return sesiones;
}

export default function (sesiones) {
  const n = (__VU - 1) % 10;
  const rol = n < 6 ? "joven" : n < 9 ? "consejero" : "admin";

  if (__ITER === 0) {
    const jar = http.cookieJar();
    for (const [nombre, valor] of Object.entries(sesiones[rol])) jar.set(BASE_URL, nombre, valor);
    // Cada uno empieza en un momento distinto, como en la vida real.
    sleep(Math.random() * PAUSA);
  }

  const [nombre, path] = PANTALLAS[rol][Math.floor(Math.random() * PANTALLAS[rol].length)];
  const respuesta = http.get(`${BASE_URL}${path}`, { tags: { name: nombre }, redirects: 0 });
  check(respuesta, {
    "200": (r) => r.status === 200,
  }, { name: nombre });

  sleep(PAUSA * (0.5 + Math.random()));
}
