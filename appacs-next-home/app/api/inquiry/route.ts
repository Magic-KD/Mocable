type InquiryBody = {
  name?: string;
  email?: string;
  phone?: string;
  company?: string;
  region?: string;
  productNeed?: string;
  message?: string;
  website?: string;
  meta?: {
    source?: string;
    fillTimeMs?: number;
  };
};

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/i;
const phonePattern = /^\+?[0-9\s\-().]{7,20}$/;
const minFillTimeMs = 3000;

function validate(body: InquiryBody) {
  if (!body.name?.trim()) return "Name is required.";
  if (!body.email?.trim() || !emailPattern.test(body.email.trim())) return "A valid email is required.";
  if (!body.phone?.trim() || !phonePattern.test(body.phone.trim())) return "A valid phone number is required.";
  if (body.website?.trim()) return "Spam protection triggered.";
  if (typeof body.meta?.fillTimeMs === "number" && body.meta.fillTimeMs < minFillTimeMs) {
    return "Submission was too fast.";
  }
  return "";
}

async function sendEmailWithResend(body: Required<Pick<InquiryBody, "name" | "email" | "phone">> & InquiryBody) {
  const apiKey = process.env.RESEND_API_KEY;
  const toEmail = process.env.INQUIRY_TO_EMAIL || "mypetsdaily@outlook.com";
  const fromEmail = process.env.INQUIRY_FROM_EMAIL || "Mocable Inquiry <inquiry@mocable.com>";

  if (!apiKey) {
    throw new Error("Missing RESEND_API_KEY.");
  }

  const html = `
    <h2>New Website Inquiry</h2>
    <p><strong>Name:</strong> ${body.name}</p>
    <p><strong>Email:</strong> ${body.email}</p>
    <p><strong>Phone:</strong> ${body.phone}</p>
    <p><strong>Company:</strong> ${body.company || "-"}</p>
    <p><strong>Country / Region:</strong> ${body.region || "-"}</p>
    <p><strong>Product Need:</strong> ${body.productNeed || "-"}</p>
    <p><strong>Message:</strong><br/>${(body.message || "-").replace(/\n/g, "<br/>")}</p>
    <p><strong>Source:</strong> ${body.meta?.source || "-"}</p>
  `;

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      from: fromEmail,
      to: [toEmail],
      reply_to: body.email,
      subject: `New Mocable Inquiry from ${body.name}`,
      html
    })
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || "Failed to send inquiry email.");
  }
}

async function saveInquiryToDatabase(body: InquiryBody) {
  console.log("Store inquiry in database", body);
}

export async function POST(request: Request) {
  try {
    const body = (await request.json()) as InquiryBody;
    const error = validate(body);

    if (error) {
      return new Response(error, { status: 400 });
    }

    await Promise.all([
      saveInquiryToDatabase(body),
      sendEmailWithResend({
        ...body,
        name: body.name!.trim(),
        email: body.email!.trim(),
        phone: body.phone!.trim()
      })
    ]);

    return Response.json({
      ok: true,
      message: "Inquiry submitted successfully."
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Server error.";
    return new Response(message, { status: 500 });
  }
}
