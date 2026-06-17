import { redirect } from "next/navigation";

export const metadata = {
  title: "FAQs | APPACS OEM/ODM USB Cable Manufacturer",
  description:
    "B2B FAQ for APPACS USB cable factory, covering OEM/ODM services, custom logos, samples, MOQ, quality control, certifications and export support."
};

export default function FaqsPage() {
  redirect("/en/faq");
}
