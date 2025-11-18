import axios from "axios";

function baseTemplate(title, bodyHtml) {
  return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${title}</title></head><body style="font-family: Arial, sans-serif; background:#f7f7f7; padding:20px;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width:600px; margin:0 auto; background:#fff; border-radius:8px; overflow:hidden;">
    <tr><td style="background:#4B7BEC; color:#fff; padding:16px 24px; font-size:18px;">${title}</td></tr>
    <tr><td style="padding:24px; color:#333;">${bodyHtml}</td></tr>
    <tr><td style="padding:16px 24px; font-size:12px; color:#888;">Si no solicitaste este correo, puedes ignorarlo.</td></tr>
  </table>
</body></html>`;
}

function hasConfig() {
  return !!process.env.SENDGRID_API_KEY && !!process.env.EMAIL_FROM;
}

async function sendEmail(to, subject, html) {
  if (!hasConfig()) return { sent: false };
  const apiKey = process.env.SENDGRID_API_KEY;
  const from = process.env.EMAIL_FROM;
  const payload = {
    personalizations: [{ to: [{ email: to }] }],
    from: { email: from },
    subject,
    content: [{ type: "text/html", value: html }],
  };
  const res = await axios.post("https://api.sendgrid.com/v3/mail/send", payload, {
    headers: { Authorization: `Bearer ${apiKey}` },
    timeout: 5000,
  });
  return { sent: res.status === 202 };
}

function buildBaseUrl() {
  return process.env.FRONTEND_URL || process.env.API_BASE_URL || "";
}

export async function sendVerificationEmail(to, token) {
  const base = buildBaseUrl();
  const link = `${base}/verify?token=${encodeURIComponent(token)}`;
  const subject = "Verify your email";
  const html = baseTemplate("Verifica tu email", `<p>Haz clic para verificar tu email:</p><p><a href="${link}">${link}</a></p>`);
  return sendEmail(to, subject, html);
}

export async function sendResetEmail(to, token) {
  const base = buildBaseUrl();
  const link = `${base}/reset-password?token=${encodeURIComponent(token)}`;
  const subject = "Reset your password";
  const html = baseTemplate("Restablece tu contraseña", `<p>Haz clic para restablecer tu contraseña:</p><p><a href="${link}">${link}</a></p>`);
  return sendEmail(to, subject, html);
}

export default {
  sendVerificationEmail,
  sendResetEmail,
}