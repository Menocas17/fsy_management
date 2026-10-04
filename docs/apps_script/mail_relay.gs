/**
 * Relevo de correo de FSY Management: la app (lib/apps_script_delivery.rb) le manda cada correo por HTTPS
 * y este script lo envía desde el Gmail de quien lo publica. Pasos en docs/deploy_render.md, sección 3.
 *
 * La clave va en Configuración del proyecto → Propiedades de la secuencia de comandos → SECRET, nunca
 * aquí: es la misma que MAIL_RELAY_SECRET en Render.
 */

function doPost(e) {
  try {
    const secret = PropertiesService.getScriptProperties().getProperty("SECRET");
    const data = JSON.parse(e.postData.contents);
    if (!secret || data.secret !== secret) return reply({ ok: false, error: "clave incorrecta" });

    const inlineImages = {};
    (data.inline || []).forEach(function (image) {
      inlineImages[image.cid] = Utilities.newBlob(Utilities.base64Decode(image.data), image.mime, image.cid);
    });

    const message = {
      to: data.to,
      subject: data.subject || "",
      body: data.text || " ",
      inlineImages: inlineImages
    };
    if (data.html) message.htmlBody = data.html;
    if (data.name) message.name = data.name;
    if (data.cc) message.cc = data.cc;
    if (data.bcc) message.bcc = data.bcc;
    if (data.reply_to) message.replyTo = data.reply_to;

    MailApp.sendEmail(message);
    return reply({ ok: true, remaining: MailApp.getRemainingDailyQuota() });
  } catch (error) {
    return reply({ ok: false, error: String(error) });
  }
}

// Córrelo una vez desde el editor (botón Ejecutar) para darle permiso de mandar correos.
function autorizar() {
  Logger.log("Correos que quedan hoy: " + MailApp.getRemainingDailyQuota());
}

function reply(object) {
  return ContentService.createTextOutput(JSON.stringify(object)).setMimeType(ContentService.MimeType.JSON);
}
