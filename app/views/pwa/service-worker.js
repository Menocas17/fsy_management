// Service worker de FSY Management: recibe las notificaciones push y abre la alerta al tocarlas.
// Vive en la raíz del sitio (/service-worker) para poder controlar toda la app.

self.addEventListener("push", async (event) => {
  if (!event.data) return;

  const { title, options } = event.data.json();
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const path = event.notification.data?.path || "/notificaciones";

  // Si la app ya está abierta en alguna pestaña, se reutiliza en vez de abrir otra.
  event.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ("focus" in client) {
          client.navigate(path);
          return client.focus();
        }
      }

      return self.clients.openWindow(path);
    })
  );
});

// El navegador puede rotar las llaves de una suscripción; cuando pasa, se vuelve a registrar sola.
self.addEventListener("pushsubscriptionchange", (event) => {
  event.waitUntil(
    self.registration.pushManager
      .subscribe(event.oldSubscription.options)
      .then((subscription) =>
        fetch("/notificaciones/suscripcion", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ subscription: subscription.toJSON() })
        })
      )
  );
});
