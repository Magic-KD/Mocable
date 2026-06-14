import * as React from "react";

type InquiryPayload = {
  name: string;
  email: string;
  phone: string;
  company?: string;
  region?: string;
  productNeed?: string;
  message?: string;
};

type Props = {
  endpoint?: string;
  onSuccess?: () => void;
};

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/i;
const phonePattern = /^\+?[0-9\s\-().]{7,20}$/;
const minFillTimeMs = 3000;

export function AppacsInquiryForm({
  endpoint = "/api/inquiry",
  onSuccess
}: Props) {
  const startedAtRef = React.useRef(Date.now());
  const [form, setForm] = React.useState({
    name: "",
    email: "",
    phone: "",
    company: "",
    region: "",
    productNeed: "",
    message: "",
    website: ""
  });
  const [errors, setErrors] = React.useState<Record<string, string>>({});
  const [status, setStatus] = React.useState<{ type: "" | "success" | "error"; text: string }>({
    type: "",
    text: ""
  });
  const [submitting, setSubmitting] = React.useState(false);

  function updateField(name: keyof typeof form, value: string) {
    setForm((current) => ({ ...current, [name]: value }));
  }

  function validate() {
    const nextErrors: Record<string, string> = {};

    if (!form.name.trim()) nextErrors.name = "Please enter your full name.";
    if (!emailPattern.test(form.email.trim())) nextErrors.email = "Please enter a valid email address.";
    if (!phonePattern.test(form.phone.trim())) nextErrors.phone = "Please enter a valid phone number.";

    setErrors(nextErrors);

    if (Object.keys(nextErrors).length > 0) {
      setStatus({
        type: "error",
        text: "Please complete all required fields before submitting."
      });
      return false;
    }

    return true;
  }

  async function submitInquiry(payload: InquiryPayload) {
    const response = await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        ...payload,
        meta: {
          source: "react-inquiry-form",
          fillTimeMs: Date.now() - startedAtRef.current
        }
      })
    });

    if (!response.ok) {
      const message = await response.text();
      throw new Error(message || "Submission failed.");
    }

    return response.json().catch(() => ({}));
  }

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus({ type: "", text: "" });

    if (!validate()) return;

    if (form.website.trim()) {
      setStatus({
        type: "error",
        text: "Spam protection triggered. Please refresh and try again."
      });
      return;
    }

    if (Date.now() - startedAtRef.current < minFillTimeMs) {
      setStatus({
        type: "error",
        text: "Please review your details for a moment before submitting."
      });
      return;
    }

    setSubmitting(true);

    try {
      await submitInquiry({
        name: form.name.trim(),
        email: form.email.trim(),
        phone: form.phone.trim(),
        company: form.company.trim(),
        region: form.region.trim(),
        productNeed: form.productNeed.trim(),
        message: form.message.trim()
      });

      setForm({
        name: "",
        email: "",
        phone: "",
        company: "",
        region: "",
        productNeed: "",
        message: "",
        website: ""
      });
      setErrors({});
      setStatus({
        type: "success",
        text: "Inquiry submitted successfully. We will reply as soon as possible."
      });
      startedAtRef.current = Date.now();
      onSuccess?.();
    } catch (error) {
      const message = error instanceof Error ? error.message : "Submission failed.";
      setStatus({
        type: "error",
        text: message
      });
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <section
      style={{
        padding: 32,
        borderRadius: 24,
        background: "rgba(9,20,16,.78)",
        border: "1px solid rgba(255,255,255,.14)",
        boxShadow: "0 28px 80px rgba(0,0,0,.28)",
        color: "#eef8f2",
        backdropFilter: "blur(18px) saturate(140%)"
      }}
    >
      <h2 style={{ margin: 0, fontSize: 32 }}>Inquiry Form</h2>
      <p style={{ margin: "8px 0 24px", color: "rgba(238,248,242,.68)", lineHeight: 1.7 }}>
        Share your OEM/ODM USB cable project details. Required fields are clearly marked and validated.
      </p>

      <form
        onSubmit={handleSubmit}
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(2, minmax(0, 1fr))",
          gap: 16
        }}
      >
        {[
          {
            name: "name",
            label: "Full Name",
            required: true,
            placeholder: "e.g. David Chen",
            type: "text"
          },
          {
            name: "email",
            label: "Email",
            required: true,
            placeholder: "e.g. purchasing@company.com",
            type: "email"
          },
          {
            name: "phone",
            label: "Phone",
            required: true,
            placeholder: "e.g. +971 50 123 4567",
            type: "tel"
          },
          {
            name: "company",
            label: "Company Name",
            placeholder: "e.g. Global Mobile Accessories LLC",
            type: "text"
          },
          {
            name: "region",
            label: "Country / Region",
            placeholder: "e.g. UAE, Germany, Nigeria",
            type: "text"
          },
          {
            name: "productNeed",
            label: "Product Requirement",
            placeholder: "e.g. 3-in-1 cable, USB-C cable, custom logo packaging",
            type: "text"
          }
        ].map((field) => (
          <div key={field.name} style={{ display: "grid", gap: 8 }}>
            <label style={{ fontSize: 14, fontWeight: 800 }}>
              {field.label}
              {field.required ? <span style={{ color: "#30e47f", marginLeft: 8 }}>Required</span> : null}
            </label>
            <input
              type={field.type}
              value={form[field.name as keyof typeof form]}
              onChange={(event) => updateField(field.name as keyof typeof form, event.target.value)}
              placeholder={field.placeholder}
              style={{
                border: "1px solid rgba(255,255,255,.12)",
                borderRadius: 14,
                background: "rgba(255,255,255,.05)",
                color: "#fff",
                padding: "15px 16px"
              }}
            />
            <div style={{ minHeight: 16, color: errors[field.name] ? "#ff7272" : "rgba(255,255,255,.52)", fontSize: 12 }}>
              {errors[field.name] || " "}
            </div>
          </div>
        ))}

        <div style={{ gridColumn: "1 / -1", display: "grid", gap: 8 }}>
          <label style={{ fontSize: 14, fontWeight: 800 }}>Message</label>
          <textarea
            value={form.message}
            onChange={(event) => updateField("message", event.target.value)}
            placeholder="Tell us your quantity, target market, connector type, wattage, packaging or timeline."
            style={{
              minHeight: 150,
              border: "1px solid rgba(255,255,255,.12)",
              borderRadius: 14,
              background: "rgba(255,255,255,.05)",
              color: "#fff",
              padding: "15px 16px",
              resize: "vertical"
            }}
          />
          <div style={{ minHeight: 16, color: "rgba(255,255,255,.52)", fontSize: 12 }}>
            Optional: the more detail you add, the easier it is to quote accurately.
          </div>
        </div>

        <input
          type="text"
          name="website"
          value={form.website}
          onChange={(event) => updateField("website", event.target.value)}
          tabIndex={-1}
          autoComplete="off"
          aria-hidden="true"
          style={{ position: "absolute", left: -9999, opacity: 0, pointerEvents: "none" }}
        />

        <div style={{ gridColumn: "1 / -1", display: "flex", flexWrap: "wrap", gap: 14, alignItems: "center" }}>
          <button
            type="submit"
            disabled={submitting}
            style={{
              border: 0,
              borderRadius: 14,
              padding: "16px 22px",
              background: "linear-gradient(135deg, #19b85a, #30e47f)",
              color: "#051109",
              fontWeight: 900,
              cursor: submitting ? "wait" : "pointer",
              minWidth: 190
            }}
          >
            {submitting ? "Sending..." : "Send Inquiry"}
          </button>
          <div
            aria-live="polite"
            style={{
              minHeight: 20,
              color: status.type === "success" ? "#5de18c" : status.type === "error" ? "#ff7272" : "rgba(255,255,255,.74)",
              fontWeight: 700
            }}
          >
            {status.text}
          </div>
        </div>
      </form>
    </section>
  );
}

export default AppacsInquiryForm;
