"use client";

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

export default function AppacsInquiryForm({
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
          source: "mocable-next-form",
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
        text: "Inquiry submitted successfully. Please check your inbox workflow."
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

  const fields = [
    {
      name: "name",
      label: "Name",
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
      placeholder: "e.g. +86 159 2002 6822",
      type: "tel"
    },
    {
      name: "company",
      label: "Company",
      placeholder: "e.g. Mocable Trading",
      type: "text"
    },
    {
      name: "region",
      label: "Country / Region",
      placeholder: "e.g. UAE, Germany",
      type: "text"
    },
    {
      name: "productNeed",
      label: "Product Need",
      placeholder: "e.g. 3-in-1 cable, 60W USB-C cable",
      type: "text"
    }
  ] as const;

  return (
    <form onSubmit={handleSubmit} noValidate>
      {fields.map((field) => (
        <div className="form-field" key={field.name}>
          <label htmlFor={field.name}>
            {field.label}
            {field.required ? <span className="required-text">Required</span> : null}
          </label>
          <input
            id={field.name}
            type={field.type}
            value={form[field.name]}
            onChange={(event) => updateField(field.name, event.target.value)}
            placeholder={field.placeholder}
            aria-invalid={errors[field.name] ? "true" : "false"}
          />
          <div className={`form-hint ${errors[field.name] ? "error" : ""}`}>{errors[field.name] || " "}</div>
        </div>
      ))}

      <div className="form-field form-field-full">
        <label htmlFor="message">Message</label>
        <textarea
          id="message"
          value={form.message}
          onChange={(event) => updateField("message", event.target.value)}
          placeholder="Tell us your quantity, target market, connector type, wattage, packaging or timeline."
        />
        <div className="form-hint">Optional: more detail helps us quote more accurately.</div>
      </div>

      <input
        type="text"
        name="website"
        value={form.website}
        onChange={(event) => updateField("website", event.target.value)}
        tabIndex={-1}
        autoComplete="off"
        aria-hidden="true"
        className="honeypot"
      />

      <div className="form-actions">
        <button type="submit" disabled={submitting}>
          {submitting ? "Sending..." : "Submit Inquiry"}
        </button>
        <div className={`form-status ${status.type}`} aria-live="polite">
          {status.text}
        </div>
      </div>
    </form>
  );
}
